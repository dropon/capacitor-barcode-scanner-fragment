import Capacitor

@objc(BarcodeScannerFragmentPluginPlugin)
public class BarcodeScannerFragmentPluginPlugin: CAPPlugin {
    
    private let implementation = BarcodeScannerFragmentPlugin()

    @objc func startScanner(_ call: CAPPluginCall) {
        implementation.startScanner(call)
    }
    
    @objc func stopScanner(_ call: CAPPluginCall) {
        implementation.stopScanner(call)
    }
    
    @objc func isScanning(_ call: CAPPluginCall) {
        implementation.isScanning(call)
    }

    @objc func setIsTorchEnabled(_ call: CAPPluginCall) {
        implementation.setIsTorchEnabled(call)
    }

    @objc func addManualInput(_ call: CAPPluginCall) {
        implementation.setIsTorchEnabled(call)
    }

}

