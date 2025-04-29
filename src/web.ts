import { WebPlugin } from '@capacitor/core';

import type { BarcodeScannerFragmentPluginPlugin } from './definitions';

const manualScanButtonWrapperId = 'barcode-scanner-fragment-manual-input';
const manualScanButtonId = 'barcode-scanner-manual-input-button';

export class BarcodeScannerFragmentPluginWeb
  extends WebPlugin
  implements BarcodeScannerFragmentPluginPlugin
{
  private isScanningActive = false;
  private scanButton?: HTMLDivElement;

  async startScanner(): Promise<void> {
    if (this.isScanningActive) return;

    this.scanButton = document.createElement('div');
    this.scanButton.id = manualScanButtonId;
    this.scanButton.style.position = 'absolute';
    this.scanButton.style.top = '0';
    this.scanButton.style.bottom = '0';
    this.scanButton.style.left = '0';
    this.scanButton.style.right = '0';

    this.scanButton.style.border = 'none';
    this.scanButton.style.color = 'white';
    this.scanButton.style.cursor = 'pointer';
    this.scanButton.onclick = () => {
      const code = window.prompt('Enter barcode value:');
      if (code) {
        this.notifyListeners('onBarcodeScanned', { value: code });
      }
    };

    document
      .getElementById(manualScanButtonWrapperId)
      ?.appendChild(this.scanButton);
    this.isScanningActive = true;
  }

  async stopScanner(): Promise<void> {
    if (this.scanButton) {
      document.body.removeChild(this.scanButton);
      this.scanButton = undefined;
    }
    this.isScanningActive = false;
  }

  async toggleScanner(): Promise<void> {
    if (this.isScanningActive) {
      return this.stopScanner();
    } else {
      return this.startScanner();
    }
  }

  async isScanning(): Promise<{ isScanning: boolean }> {
    return { isScanning: this.isScanningActive };
  }

  async setIsTorchEnabled(): Promise<{ isEnabled: boolean }> {
    // Not applicable on web
    return { isEnabled: false };
  }
}
