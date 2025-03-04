package kz.rvssvl.cbsf;

import android.content.Context
import android.media.Image
import com.google.mlkit.vision.barcode.BarcodeScannerOptions
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.barcode.common.Barcode
import com.google.mlkit.vision.common.InputImage
import kotlinx.coroutines.tasks.await

class BarcodeScannerRepository(context: Context) {

    private val options = BarcodeScannerOptions.Builder()
            .setBarcodeFormats(Barcode.FORMAT_CODE_128, Barcode.FORMAT_DATA_MATRIX)
            .build()

    private val detector = BarcodeScanning.getClient(options)


    suspend fun detectBarcode(input: Input): List<Barcode>? {
        val firebaseVisionImage = InputImage.fromMediaImage(
                input.image,
                input.rotationDegrees
        )
        return detector.process(firebaseVisionImage).await()
    }


    data class Input(val image: Image, val rotationDegrees: Int)
}
