import { WebPlugin } from '@capacitor/core';

import type { BarcodeScannerFragmentPluginPlugin } from './definitions';

const manualScanButtonId = 'barcode-scanner-fragment-manual-input';

export class BarcodeScannerFragmentPluginWeb
  extends WebPlugin
  implements BarcodeScannerFragmentPluginPlugin
{
  private isScanningActive = false;
  private scanButton?: HTMLButtonElement;

  async startScanner(): Promise<void> {
    if (this.isScanningActive) return;

    const element = document.getElementById(manualScanButtonId);
    if (element) {
      element.parentElement?.removeChild(element);
    }

    this.scanButton = document.createElement('button');
    this.scanButton.id = manualScanButtonId;
    this.scanButton.style.padding = '10px 15px';
    this.scanButton.style.border = 'none';
    this.scanButton.style.color = 'white';
    this.scanButton.style.cursor = 'pointer';
    this.scanButton.onclick = () => {
      const code = window.prompt('Enter barcode value:');
      if (code) {
        this.notifyListeners('onBarcodeScanned', { value: code });
      }
    };

    document.getElementById('scan-plugins')?.appendChild(this.scanButton);
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
