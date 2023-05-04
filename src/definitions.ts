export interface BarcodeScannerFragmentPluginPlugin {
  toggleScanner(): Promise<void>;
  startScanner(): Promise<void>;
  stopScanner(): Promise<void>;
  isScanning(): Promise<{isScanning: boolean}>;
  setIsTorchEnabled(args: {enabled: boolean}): Promise<{isEnabled: boolean}>;
}
