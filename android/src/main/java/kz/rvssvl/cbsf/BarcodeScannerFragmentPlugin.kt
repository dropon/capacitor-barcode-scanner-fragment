package kz.rvssvl.cbsf

import android.Manifest
import android.content.pm.PackageManager
import android.view.View
import android.view.ViewGroup
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.getcapacitor.JSObject
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin


@CapacitorPlugin(name = "BarcodeScannerFragmentPlugin")
class BarcodeScannerFragmentPlugin : CustomPlugin() {

    private val implementation = BarcodeScannerFragmentHelper()

    private var fragment: BarcodeScannerFragment? = null

    @PluginMethod
    fun setIsTorchEnabled(call: PluginCall) {
        val enabled = call.getBoolean("enabled")
        if (fragment != null && enabled!!) {
            val ret = JSObject()
            ret.put("isEnabled", fragment!!.setIsTorchEnabled(enabled))
            call.resolve(ret)
        }
    }

    @PluginMethod
    fun toggleScanner(call: PluginCall) {
        if (fragment == null) {
            startScanner(call)
        } else {
            stopScanner(call)
        }
        call.resolve()
    }

    @PluginMethod
    fun startScanner(call: PluginCall) {
        if (!requestPermission()) {
            call.resolve()
            return
        }
        val fragmentManager = activity.supportFragmentManager
        val fragmentTransaction = fragmentManager.beginTransaction()
        if (fragment != null) {
            fragmentTransaction.remove(fragment!!).commit()
            fragment = null
        }
        fragment = BarcodeScannerFragment(BarcodeScannerFragmentPluginCallback(this))
        val parent  = activity.findViewById<ViewGroup>(android.R.id.content) 
        if (parent.id<=0) {
            parent.id = View.generateViewId()
        }
        fragmentTransaction.add(parent.id, fragment!!, "barcode-scanner").commit()
        call.resolve()
    }

    @PluginMethod
    fun stopScanner(call: PluginCall) {
        if (fragment != null) {
            val fragmentManager = activity.supportFragmentManager
            val fragmentTransaction = fragmentManager.beginTransaction()
            fragmentTransaction.remove(fragment!!).commit()
            fragment = null
        }
        call.resolve()
    }

    @PluginMethod
    fun isScanning(call: PluginCall) {
        val ret = JSObject()
        ret.put("isScanning", fragment != null)
        call.resolve(ret)
    }

    private fun requestPermission(): Boolean {
        if (ContextCompat.checkSelfPermission(
                context,
                Manifest.permission.CAMERA
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                activity,
                arrayOf(Manifest.permission.CAMERA),
                0
            )
            return false
        }
        return true
    }

    class BarcodeScannerFragmentPluginCallback(var plugin: CustomPlugin): BarcodeScannerFragment.Callback {

        override fun onBarcodeScannerCameraPermissionNotGranted() {
            if (ContextCompat.checkSelfPermission(
                    plugin.context,
                    Manifest.permission.CAMERA
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                ActivityCompat.requestPermissions(
                    plugin.activity,
                    arrayOf(Manifest.permission.CAMERA),
                    0
                )
            }
        }

        override fun onBarcodeScannerPreviewClicked() {

        }

        override fun onBarcodeScannerBarcodeDetected(result: List<String>) {
            plugin.emit("onBarcodeScanned", result[0]);
        }

        override fun onBarcodeScannerErrorOccurred() {
            TODO("Not yet implemented")
        }
    }
}
