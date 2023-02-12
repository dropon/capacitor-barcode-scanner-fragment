import { WebPlugin } from '@capacitor/core';

import type { BarcodeScannerFragmentPluginPlugin } from './definitions';

export class BarcodeScannerFragmentPluginWeb extends WebPlugin implements BarcodeScannerFragmentPluginPlugin {
  async toggleScanner(): Promise<void> {
    return
  }
  async startScanner(): Promise<void> {
    return
  }
  async stopScanner(): Promise<void> {
    return
  }
  async setIsTorchEnabled(): Promise<{isEnabled: boolean }> {
    return { isEnabled: true }
  }
}
