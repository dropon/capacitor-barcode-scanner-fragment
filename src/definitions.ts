export interface BarcodeScannerFragmentPluginPlugin {
  toggleScanner(): Promise<void>;
  startScanner(): Promise<void>;
  stopScanner(): Promise<void>;
  setIsTorchEnabled(args: {enabled: boolean}): Promise<{isEnabled: boolean}>;
}
