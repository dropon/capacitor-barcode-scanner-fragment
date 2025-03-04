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
            print("⚡️ BarcodeScannerFragmentPlugin: Starting Scanner...")
            self.setupScanner()
        }
        call.resolve(["status": "started"])
    }
    
    @objc func stopScanner(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            print("⚡️ BarcodeScannerFragmentPlugin: Stopping Scanner...")
            self.captureSession?.stopRunning()
            self.previewLayer?.removeFromSuperlayer()
            self.captureSession = nil
        }
        call.resolve(["status": "stopped"])
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
        print("⚡️ BarcodeScannerFragmentPlugin: setupScanner() called")

        guard let device = AVCaptureDevice.default(for: .video) else {
            print("❌ No camera device found!")
            notifyListeners("onBarcodeScannerErrorOccurred", data: ["message": "No camera device found"])
            return
        }

        do {
            print("✅ Camera device found, setting up input")
            let input = try AVCaptureDeviceInput(device: device)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)

            let output = AVCaptureMetadataOutput()
            captureSession?.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = [.qr, .ean8, .ean13, .code128, .dataMatrix]

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            previewLayer?.videoGravity = .resizeAspectFill

            DispatchQueue.main.async {
                if let window = UIApplication.shared.windows.first {
                    print("✅ Main window found, adding preview layer")

                    // 🔥 Make WebView transparent
                    self.bridge?.webView?.backgroundColor = UIColor.clear
                    self.bridge?.webView?.isOpaque = false

                    // Remove old layers
                    window.layer.sublayers?.forEach { layer in
                        if layer is AVCaptureVideoPreviewLayer {
                            layer.removeFromSuperlayer()
                        }
                    }

                    // 🔥 Set size: approximately 1/6th of the screen
                    let width = window.bounds.width / 3
                    let height = window.bounds.height / 3
                    let xPos = window.bounds.width - width - 10 // 10px padding from the right
                    let yPos = window.bounds.height - height - 10 // 10px padding from the bottom

                    self.previewLayer?.frame = CGRect(x: xPos, y: yPos, width: width, height: height)

                    // 🚀 Add preview layer
                    window.layer.addSublayer(self.previewLayer!)
                    self.previewLayer?.zPosition = CGFloat.greatestFiniteMagnitude
                    self.previewLayer?.isHidden = false
                    self.previewLayer?.opacity = 1.0

                    // 🔥 Force layout update
                    window.setNeedsLayout()
                    window.layoutIfNeeded()

                    // Debugging
                    print("✅ Preview Layer Positioned at Bottom-Right")
                    print("🟡 Preview Layer Frame: \(self.previewLayer!.frame)")
                } else {
                    print("❌ Main window is nil!")
                    self.notifyListeners("onBarcodeScannerErrorOccurred", data: ["message": "Main window is nil"])
                    return
                }
            }

            // 🚀 Start capture session in a background thread
            DispatchQueue.global(qos: .userInitiated).async {
                print("⚡️ Starting Camera Session on Background Thread...")
                self.captureSession?.startRunning()
                print("✅ Camera session started successfully!")
            }

        } catch {
            print("❌ Failed to set up camera: \(error.localizedDescription)")
            notifyListeners("onBarcodeScannerErrorOccurred", data: ["message": error.localizedDescription"])
        }
    }
   

    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject, let stringValue = metadataObj.stringValue else {
            return
        }
        
        notifyListeners("onBarcodeScanned", data: ["value": stringValue])
    }
}

