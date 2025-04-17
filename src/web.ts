import { WebPlugin } from '@capacitor/core';
import type { BarcodeScannerFragmentPluginPlugin } from './definitions';

export class BarcodeScannerFragmentPluginWeb
  extends WebPlugin
  implements BarcodeScannerFragmentPluginPlugin
{
  private isScanningActive = false;
  private scanButton?: HTMLButtonElement;

  async startScanner(): Promise<void> {
    if (this.isScanningActive) return;

    this.scanButton = document.createElement('button');
    this.scanButton.innerText = 'Scan Barcode';
    this.scanButton.style.position = 'fixed';
    this.scanButton.style.top = '10px';
    this.scanButton.style.left = '10px';
    this.scanButton.style.zIndex = '9999';
    this.scanButton.style.padding = '10px 15px';
    this.scanButton.style.border = 'none';
    this.scanButton.style.borderRadius = '5px';
    this.scanButton.style.backgroundColor = '#007bff';
    this.scanButton.style.color = 'white';
    this.scanButton.style.cursor = 'pointer';
    this.scanButton.onclick = () => {
      const code = window.prompt('Enter barcode value:');
      if (code) {
        this.notifyListeners('onBarcodeScanned', { value: code });
      }
    };

    document.body.appendChild(this.scanButton);
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
