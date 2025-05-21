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

    @objc func addManualInput(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Manual Input", message: "Enter the barcode manually:", preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.placeholder = "Barcode"
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                call.reject("User cancelled manual input")
            })
            
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                let input = alert.textFields?.first?.text ?? ""
                let result = ["barcode": input]
                call.resolve(result)
            })

            self.bridge?.viewController?.present(alert, animated: true, completion: nil)
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

                    // 🔥 Ensure WebView is transparent
                    self.bridge?.webView?.backgroundColor = UIColor.clear
                    self.bridge?.webView?.isOpaque = false

                    // 🔥 Remove existing preview layers to prevent duplication
                    window.layer.sublayers?.forEach { layer in
                        if layer is AVCaptureVideoPreviewLayer {
                            layer.removeFromSuperlayer()
                        }
                    }

                    // 🔥 Set size: approximately 1/6th of the screen
                    let screenWidth = window.bounds.width
                    let screenHeight = window.bounds.height
                    let previewWidth = screenWidth / 3
                    let previewHeight = screenHeight / 3
                    let xPos = screenWidth - previewWidth - 10 // 10px padding from right
                    let yPos = screenHeight - previewHeight - 10 // 10px padding from bottom

                    self.previewLayer?.frame = CGRect(x: xPos, y: yPos, width: previewWidth, height: previewHeight)

                    // 🚀 Add preview layer
                    window.layer.addSublayer(self.previewLayer!)
                    self.previewLayer?.zPosition = CGFloat.greatestFiniteMagnitude
                    self.previewLayer?.isHidden = false
                    self.previewLayer?.opacity = 1.0

                    // 🔥 Force layout update
                    window.setNeedsLayout()
                    window.layoutIfNeeded()

                    // ✅ Debugging logs
                    if let frame = self.previewLayer?.frame {
                        print("✅ Preview Layer Positioned at Bottom-Right")
                        print("🟡 Preview Layer Frame: \(frame.origin.x), \(frame.origin.y), \(frame.width)x\(frame.height)")
                    } else {
                        print("❌ Failed to set preview layer frame")
                    }
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
            notifyListeners("onBarcodeScannerErrorOccurred", data: ["message": error.localizedDescription])
        }
    }

    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject, let stringValue = metadataObj.stringValue else {
            return
        }
        
        notifyListeners("onBarcodeScanned", data: ["value": stringValue])
    }
}

