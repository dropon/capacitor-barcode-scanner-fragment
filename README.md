# capacitor-barcode-scanner-fragment

This plugin appends Android fragment to the Main Activity of CapacitorJs app and allow barcode scanning functionality.

## Prerequisite

1) Open your Ionic+Capacitor project
2) Open Android app
3) Open MainActivity.java file and add this chunk inside of MainActivity
```javascript
 @SuppressLint("ResourceType")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        bridgeBuilder.setInstanceState(savedInstanceState);
        getApplication().setTheme(getResources().getIdentifier("AppTheme_NoActionBar", "style", getPackageName()));
        setTheme(getResources().getIdentifier("AppTheme_NoActionBar", "style", getPackageName()));
        setTheme(com.getcapacitor.android.R.style.AppTheme_NoActionBar);
        setContentView(R.layout.activity_main);
        PluginManager loader = new PluginManager(getAssets());

        try {
            bridgeBuilder.addPlugins(loader.loadPluginClasses());
        } catch (PluginLoadException ex) {
            Logger.error("Error loading plugins.", ex);
        }

        this.load();
    }
```
4) Add ``activity_main.xml`` to ``layout`` resource folder and put this inside:
```xml
<?xml version="1.0" encoding="utf-8"?>
<androidx.coordinatorlayout.widget.CoordinatorLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context="io.ionic.starter.MainActivity"
    >

    <FrameLayout
        android:id="@+id/root_frame_layout"
        android:layout_width="fill_parent"
        android:layout_height="fill_parent">

        <com.getcapacitor.CapacitorWebView
            android:id="@+id/webview"
            android:layout_width="fill_parent"
            android:layout_height="fill_parent" />
    </FrameLayout>


</androidx.coordinatorlayout.widget.CoordinatorLayout>

```
5) Go to ``BridgeActivity`` (``MainActivity`` extends it by default) class and replace its ``onCreateView`` method with this
```javascript
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }
```

## Install

```bash
npm install capacitor-barcode-scanner-fragment
npx cap sync
```

## API

<docgen-index>

* [`toggleScanner()`](#togglescanner)
* [`startScanner()`](#startscanner)
* [`stopScanner()`](#stopscanner)
* [`setIsTorchEnabled(...)`](#setistorchenabled)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### toggleScanner()

```typescript
toggleScanner() => Promise<void>
```

--------------------


### startScanner()

```typescript
startScanner() => Promise<void>
```

--------------------


### stopScanner()

```typescript
stopScanner() => Promise<void>
```

--------------------


### setIsTorchEnabled(...)

```typescript
setIsTorchEnabled(args: { enabled: boolean; }) => Promise<{ isEnabled: boolean; }>
```

| Param      | Type                               |
| ---------- | ---------------------------------- |
| **`args`** | <code>{ enabled: boolean; }</code> |

**Returns:** <code>Promise&lt;{ isEnabled: boolean; }&gt;</code>

--------------------

</docgen-api>
