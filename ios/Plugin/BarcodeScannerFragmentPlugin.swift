import Foundation

@objc public class BarcodeScannerFragmentPlugin: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
}
