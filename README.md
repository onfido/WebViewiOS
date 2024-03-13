# WebViewiOS

A sample iOS navtive app integration with Onfido’s [Web SDK](https://documentation.onfido.com/sdk/web/), using [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview) component.

## Summary

This app is a simple demonstration of the minimum configurations that are required to integrate with [onfido-sdk-ui](https://documentation.onfido.com/sdk/web/) using a iOS native WKWebView component. The example uses [Smart Capture Link](https://developers.onfido.com/guide/smart-capture-link).

You can find more detailed documentation here:

- [WKWebView](https://docs.usercentrics.com/cmp_in_app_sdk/latest/features/webview-continuity/)

- [onfido-sdk-ui](https://documentation.onfido.com/sdk/web/)

- [Smart Capture Link](https://developers.onfido.com/guide/smart-capture-link)

## Permissions

### iOS

You will need to enable Camera, Mic, Photo Library and Location Access in your `Info.plist` file:

```
    <key>NSCameraUsageDescription</key>
    <string>Camera Access</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Location Access</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>Mic Access</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Photo Library Access</string>
```

## Environment Variables

To load the WebView, we require an `API_KEY` and a `WORKFLOW_ID` defined within a `Env.xcconfig` file. 
This can file can be located anywhere, but for simplicity we recommend adding it within `SmartCaptureDemo/EnvironmentVariables`.

The file should have the following format:

```
// Configuration settings file format documentation can be found at:
// https://help.apple.com/xcode/#/dev745c5c974

API_KEY=<YOUR_API_KEY_HERE>
WORKFLOW_ID=<YOUR_WORKFLOW_ID_HERE>
SDK_TARGET_VERSION=<SDK_VERSION_YOU_WISH_TO_TARGET>
```

**Please Note:** The `SDK_TARGET_VERSION` can be left blank above if you wish to target the latest version.

 **Important note regarding the environment variable set up**
 The Environment variables are used for internal/demo purposes only. The method used here is appropriate for certain requirements, but it is not encouraged for secrets.
 Please see here for more details, specifically, the end regarding secrets: https://nshipster.com/xcconfig