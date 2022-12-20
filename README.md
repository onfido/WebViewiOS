# WebViewRN
A sample iOS navtive app integration with Onfido’s [Web SDK](https://documentation.onfido.com/sdk/web/), using [WKWebView] (https://developer.apple.com/documentation/webkit/wkwebview) component. 

## Summary

This app is a simple demonstration of the minimum configurations that are required to integrate with [onfido-sdk-ui](https://documentation.onfido.com/sdk/web/) using a iOS native WKWebView component. The example uses [Smart Capture Link](https://developers.onfido.com/guide/smart-capture-link).

You can find more detailed documentation here:
- [WKWebView](https://docs.usercentrics.com/cmp_in_app_sdk/latest/features/webview-continuity/)

- [onfido-sdk-ui](https://documentation.onfido.com/sdk/web/)

- [Smart Capture Link](https://developers.onfido.com/guide/smart-capture-link)



## Permissions

### iOS

You will need to enable Camera, Mic, Photo Library and Location Access in your `info.plist` file: 

```AndroidManifest.xml
    <key>NSCameraUsageDescription</key>
    <string>Camera Access</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Location Access</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>Mic Access</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Photo Library Access</string>
```    

  
