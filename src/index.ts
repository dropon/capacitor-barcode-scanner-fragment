import { registerPlugin } from '@capacitor/core';

import type { BarcodeScannerFragmentPluginPlugin } from './definitions';

const BarcodeScannerFragmentPlugin = registerPlugin<BarcodeScannerFragmentPluginPlugin>('BarcodeScannerFragmentPlugin', {
  web: () => import('./web').then(m => new m.BarcodeScannerFragmentPluginWeb()),
});

export * from './definitions';
export { BarcodeScannerFragmentPlugin };
