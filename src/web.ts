import { WebPlugin } from '@capacitor/core';

import type { BarcodeScannerFragmentPluginPlugin } from './definitions';

const manualScanButtonWrapperId = 'barcode-scanner-fragment-manual-input';
const manualScanButtonId = 'barcode-scanner-manual-input-button';

export class BarcodeScannerFragmentPluginWeb
  extends WebPlugin
  implements BarcodeScannerFragmentPluginPlugin
{
  constructor() {
    super();

    this.addListener('startScanner', () => {
      this.startScanner();
    });

    this.addListener('stopScanner', () => {
      this.stopScanner();
    });
  }

  private isScanningActive = false;
  private scanButton?: HTMLDivElement;

  addManualInput(wrapperEl: HTMLSpanElement, onManualInput: () => void): void {
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
      onManualInput();
    };

    wrapperEl.appendChild(this.scanButton);
  }

  removeManualInput(): void {
    const els = this.findAllWrappers();
    els.forEach(el => {
      el.removeChild(el);
    });
  }

  findAllWrappers(): NodeList {
    return document.querySelectorAll('#' + manualScanButtonWrapperId);
  }

  async startScanner(): Promise<void> {
    if (this.isScanningActive) return;

    this.isScanningActive = true;
  }

  async stopScanner(): Promise<void> {
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
