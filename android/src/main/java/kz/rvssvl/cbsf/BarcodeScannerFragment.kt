package kz.rvssvl.cbsf

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import android.util.Size
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import butterknife.internal.DebouncingOnClickListener
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.runBlocking
import java.util.concurrent.Executor
import java.util.concurrent.Executors
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min

/**
 * Created by dmitrytavpeko on 03/19/22.
 */

internal class BarcodeScannerFragment(var callback: Callback?) : Fragment() {

    private val imageAnalysisExecutor =
        Executors.newSingleThreadExecutor() // automatic clean up in finalize()
    private lateinit var mainExecutor: Executor

    private var previewView: PreviewView? = null

    private var camera: Camera? = null
    private var barcodeScanner: BarcodeScannerRepository? = null


    //region inherited

    public fun setIsTorchEnabled(enabled: Boolean): Boolean {
        try {
            camera?.cameraControl?.enableTorch(enabled)
            return enabled
        } catch (e: Exception) {
            Log.e(Tag, "Failed to enable a torch!", e)
        }
        return false
    }

    override fun onAttach(context: Context) {
        Log.d("Rassul", "1")
        super.onAttach(context)
        Log.d("Rassul", "2")
//        callback = parentFragment as? Callback ?: context as Callback
        Log.d("Rassul", "3")
        mainExecutor = ContextCompat.getMainExecutor(context)
        barcodeScanner = BarcodeScannerRepository(context)

//        if (!isPermissionsGranted()) {
//            callback!!.onBarcodeScannerCameraPermissionNotGranted()
//        }
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(
            R.layout.fragment_barcode_scanner,
            container,
            false
        )
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        previewView = view.findViewById<PreviewView?>(R.id.pv_preview).apply {
            this.setOnClickListener(object : DebouncingOnClickListener() {
                override fun doClick(v: View?) {
                    callback?.onBarcodeScannerPreviewClicked()
                }
            })
        }
    }

    override fun onStart() {
        super.onStart()
        if (isPermissionsGranted()) {
            requireContext().let {
                val cameraProviderFuture = ProcessCameraProvider.getInstance(it)
                cameraProviderFuture.addListener({
                    //  Instead of calling `startCamera()` on the main thread, we use `PreviewView.post { ... }`
                    //  to make sure that `pv_preview` has already been inflated into the view
                    //  when `startCamera()` is called.
                    previewView?.post {
                        bindCameraUseCases(cameraProviderFuture.get())
                    }
                }, mainExecutor)
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        Log.d("rassul", "onDestroyView")
        previewView = null
    }

    override fun onDetach() {
        super.onDetach()
        barcodeScanner = null
    }

    //endregion

    //region own methods

    private fun bindCameraUseCases(processCameraProvider: ProcessCameraProvider) {
        val previewView = previewView ?: return
        val rotation = previewView.display.rotation

        val aspectRatio = chooseOptimalAspectRatio(previewView.width, previewView.height)

        // Preview use case
        val preview = Preview.Builder()
            .setTargetAspectRatio(aspectRatio)
            .setTargetRotation(rotation)
            .build()

        // Image Analysis
        val imageAnalysis = ImageAnalysis.Builder()
            // In our analysis, we care more about the latest image than
            // analyzing *every* image
            .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
            // Set target rotation
            .setTargetRotation(rotation)
            // Set target resolution
            .setTargetResolution(AnalyzerDesiredResolution)
            .build().also {
                // The analyzer can then be assigned to the instance
                it.setAnalyzer(imageAnalysisExecutor, BarcodeAnalyzer(mainExecutor))
            }

        // Must unbind the use-cases before rebinding them.
        processCameraProvider.unbindAll()

        try {
            // Bind use cases to lifecycle
            camera = processCameraProvider.bindToLifecycle(
                this,
                CameraSelector.DEFAULT_BACK_CAMERA,
                preview,
                imageAnalysis
            )
            preview.setSurfaceProvider(previewView.surfaceProvider)
        } catch (e: Exception) {
            callback?.onBarcodeScannerErrorOccurred()
        }
    }

    private fun isPermissionsGranted(): Boolean {
        return ContextCompat.checkSelfPermission(
            requireContext(),
            Manifest.permission.CAMERA
        ) == PackageManager.PERMISSION_GRANTED
    }

    //endregion

    interface Callback {
        fun onBarcodeScannerCameraPermissionNotGranted()
        fun onBarcodeScannerPreviewClicked()
        fun onBarcodeScannerBarcodeDetected(result: List<String>)
        fun onBarcodeScannerErrorOccurred()
    }


    private inner class BarcodeAnalyzer(private val mainExecutor: Executor) :
        ImageAnalysis.Analyzer {

        private val Tag = "BarcodeAnalyzer"


        // Executed on a background thread
        override fun analyze(image: ImageProxy) {
            val androidImage = image.image ?: return
            runBlocking(CoroutineExceptionHandler { _, throwable ->
                Log.e(Tag, "Failed to process new image.", throwable)
                callback?.onBarcodeScannerErrorOccurred()
            }) {
                barcodeScanner?.detectBarcode(
                    BarcodeScannerRepository.Input(
                        androidImage,
                        image.imageInfo.rotationDegrees
                    )
                )
                    ?.takeIf { it.isNotEmpty() }
                    ?.let { rawResults ->
                        mainExecutor.execute {
                            callback?.onBarcodeScannerBarcodeDetected(rawResults.mapNotNull { it.rawValue })
                        }
                    }
            }
            try {
                image.close()
            } catch (e: Exception) {
                Log.e(Tag, "Failed to close image!", e)
            }
        }
    }

    companion object {
        private const val Tag = "BarcodeScannerFragment"

        private const val DesiredAspectRatio = AspectRatio.RATIO_4_3
        private val PreviewMinimumResolution =
            Size(640, 480) // must have [DesiredAspectRatio] aspect ration.
        private val AnalyzerDesiredResolution =
            Size(640, 480) // must have [DesiredAspectRatio] aspect ration.

        init {
            // We need to use the same aspect ration for preview and image analyzer use cases.
            when (DesiredAspectRatio) {
                AspectRatio.RATIO_4_3 -> {
                    check(AnalyzerDesiredResolution.height.toFloat() / AnalyzerDesiredResolution.width.toFloat() == 3f / 4f)
                    check(PreviewMinimumResolution.height.toFloat() / PreviewMinimumResolution.width.toFloat() == 3f / 4f)
                }
                else -> {
                    error("Unhandled aspect ration $DesiredAspectRatio.")
                }
            }
        }
    }
}


private const val Ratio_4_3_Value = 4.0 / 3.0
private const val Ratio_16_9_Value = 16.0 / 9.0


/**
 *  Detecting the most suitable ratio for dimensions provided in @params by counting absolute
 *  of preview ratio to one of the provided values.
 *
 *  @param width - width
 *  @param height - height
 *  @return suitable aspect ratio
 */
private fun chooseOptimalAspectRatio(width: Int, height: Int): Int {
    val previewRatio = max(width, height).toDouble() / min(width, height)
    if (abs(previewRatio - Ratio_4_3_Value) <= abs(previewRatio - Ratio_16_9_Value)) {
        return AspectRatio.RATIO_4_3
    }
    return AspectRatio.RATIO_16_9
}