export interface BarcodeScannerFragmentPluginPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
