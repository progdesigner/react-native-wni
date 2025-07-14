import React, { RefObject } from 'react';
import { NativeModules, Platform } from 'react-native';
import type { WebView, WebViewMessageEvent } from 'react-native-webview';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

// const { WNInterfaceModule } = NativeModules;

export class ReactNativeWNInterface {
  static getProperties() {
    console.log('NativeModules', NativeModules);
    console.log('NativeModules.ReactNativeWni', NativeModules.ReactNativeWni);
    return NativeModules.ReactNativeWni.getProperties();
  }
}

export type WNInterfacePayload = {
  command: string;
  data: Record<string, any>;
};

type WNInterfaceOptions = {
  controller?: RefObject<WebView>;
  onCommand?: (payload: WNInterfacePayload) => void;
};

export class WNInterface {
  private _controller?: RefObject<WebView>;
  private _onCommand?: (payload: WNInterfacePayload) => void;
  private _methods: { [key: string]: Function } = {};

  constructor(options: WNInterfaceOptions) {
    this._controller = options.controller ?? undefined;
    this._onCommand = options.onCommand ?? undefined;
  }

  setWebView(webView: RefObject<WebView>) {
    this._controller = webView;
  }

  registerMethods(methods: { [key: string]: Function }) {
    this._methods = methods;
  }

  setupAndroidSafeArea() {
    if (this._controller == null) {
      console.warn('WebView is not set');
      return;
    }
    
    const insets = useSafeAreaInsets();

    this._controller?.current?.injectJavaScript(`
      document.documentElement.style.setProperty('--android-safe-area-inset-top', '${insets.top.toString()}px');
      document.documentElement.style.setProperty('--android-safe-area-inset-left', '${insets.left.toString()}px');
      document.documentElement.style.setProperty('--android-safe-area-inset-right', '${insets.right.toString()}px');
      document.documentElement.style.setProperty('--android-safe-area-inset-bottom', '${insets.bottom.toString()}px');
    `);
  }

  handleMessage = (event: WebViewMessageEvent) => {
    try {
      const payload: WNInterfacePayload = JSON.parse(event.nativeEvent.data);
      if (this._onCommand) this._onCommand(payload);
      this.execute(payload);
    } catch (e) {
      // ignore
    }
  };

  call(functionName: string, data: any) {
    if (this._controller == null) {
      console.warn('WebView is not set');
      return;
    }

    const script = `${functionName}('${JSON.stringify(data).replace(/'/g, "\\'")}')`;
    this._controller?.current?.injectJavaScript(script);
  }

  execute(payload: WNInterfacePayload) {
    const handler = this._methods[payload.command];
    if (handler) {
      handler(payload.data);
    } else {
      // Unknown command
      console.error(`Unknown command: ${payload.command}`);
    }
  }

  static _properties: any = {};

  static async init() {
    console.log('WNInterface.init');
    this._properties = ReactNativeWNInterface.getProperties();
    console.log('WNInterface.this._properties', this._properties);
  }

  static get interfaceName() {
    return 'ReactNativeWebView';
  }

  static get isEmulator() {
    if (Platform.OS === 'ios') {
      return NativeModules.WNInterface.isEmulator;
    }
    return false;
  }

  static get interfaceVersion() {
    return this._properties.interfaceVersion;
  }
  static get appId() {
    return this._properties.appId;
  }
  static get appName() {
    return this._properties.appName;
  }
  static get appVersion() {
    return this._properties.appVersion;
  }
  static get buildVersion() {
    return this._properties.buildVersion;
  }
  static get systemName() {
    return this._properties.systemName;
  }
  static get systemVersion() {
    return this._properties.systemVersion;
  }
  static get osType() {
    return this._properties.osType;
  }
  static get osVersion() {
    return this._properties.osVersion;
  }
  static get deviceId() {
    return this._properties.deviceId;
  }
  static get deviceUuid() {
    return this._properties.deviceUuid;
  }
  static get deviceLocale() {
    return this._properties.deviceLocale;
  }
  static get deviceModel() {
    return this._properties.deviceModel;
  }
  static get deviceName() {
    return this._properties.deviceName;
  }
  static get deviceType() {
    return this._properties.deviceType;
  }
  static get deviceBrand() {
    return this._properties.deviceBrand;
  }
  static get userAgent() {
    return this._properties.userAgent;
  }
  static get webViewUserAgent() {
    return this._properties.webViewUserAgent;
  }
} 