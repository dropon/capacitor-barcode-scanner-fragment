#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

CAP_PLUGIN(BarcodeScannerFragmentPlugin, "BarcodeScannerFragmentPlugin",
    CAP_PLUGIN_METHOD(startScanner, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(stopScanner, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(isScanning, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(setIsTorchEnabled, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(addManualInput, CAPPluginReturnPromise);
)

