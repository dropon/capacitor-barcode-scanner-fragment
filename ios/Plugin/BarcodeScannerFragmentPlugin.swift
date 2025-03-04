import Foundation
import Capacitor
import AVFoundation

@objc(BarcodeScannerFragmentPlugin)
public class BarcodeScannerFragmentPlugin: CAPPlugin, AVCaptureMetadataOutputObjectsDelegate {
    
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var barcodeScannedCallback: ((String) -> Void)?
    
    @objc func startScanner(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            self.setupScanner()
        }
        call.resolve()
    }
    
    @objc func stopScanner(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            self.captureSession?.stopRunning()
            self.previewLayer?.removeFromSuperlayer()
            self.captureSession = nil
        }
        call.resolve()
    }
    
    @objc func isScanning(_ call: CAPPluginCall) {
        let isRunning = captureSession?.isRunning ?? false
        call.resolve(["isScanning": isRunning])
    }

    @objc func setIsTorchEnabled(_ call: CAPPluginCall) {
        guard let enabled = call.getBool("enabled"), let device = AVCaptureDevice.default(for: .video) else {
            call.reject("Torch not available")
            return
        }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = enabled ? .on : .off
            device.unlockForConfiguration()
            call.resolve(["isEnabled": enabled])
        } catch {
            call.reject("Failed to set torch mode")
        }
    }
    
    private func setupScanner() {
        guard let device = AVCaptureDevice.default(for: .video) else {
            notifyListeners("onBarcodeScannerErrorOccurred", data: [:])
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            let output = AVCaptureMetadataOutput()
            captureSession?.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = [.qr, .ean8, .ean13, .code128, .dataMatrix]

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            previewLayer?.videoGravity = .resizeAspectFill
            if let webView = bridge?.webView {
                previewLayer?.frame = webView.bounds
                webView.layer.insertSublayer(previewLayer!, at: 0)
            }

            captureSession?.startRunning()
        } catch {
            notifyListeners("onBarcodeScannerErrorOccurred", data: [:])
        }
    }
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject, let stringValue = metadataObj.stringValue else {
            return
        }
        
        notifyListeners("onBarcodeScanned", data: ["value": stringValue])
    }
}

