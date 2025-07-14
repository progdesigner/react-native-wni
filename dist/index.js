"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.WNInterface = exports.ReactNativeWNInterface = void 0;
const react_native_1 = require("react-native");
const react_native_safe_area_context_1 = require("react-native-safe-area-context");
// const { WNInterfaceModule } = NativeModules;
class ReactNativeWNInterface {
    static getProperties() {
        console.log('NativeModules', react_native_1.NativeModules);
        console.log('NativeModules.ReactNativeWni', react_native_1.NativeModules.ReactNativeWni);
        return react_native_1.NativeModules.ReactNativeWni.getProperties();
    }
}
exports.ReactNativeWNInterface = ReactNativeWNInterface;
class WNInterface {
    constructor(options) {
        var _a, _b;
        this._methods = {};
        this.handleMessage = (event) => {
            try {
                const payload = JSON.parse(event.nativeEvent.data);
                if (this._onCommand)
                    this._onCommand(payload);
                this.execute(payload);
            }
            catch (e) {
                // ignore
            }
        };
        this._controller = (_a = options.controller) !== null && _a !== void 0 ? _a : undefined;
        this._onCommand = (_b = options.onCommand) !== null && _b !== void 0 ? _b : undefined;
    }
    setWebView(webView) {
        this._controller = webView;
    }
    registerMethods(methods) {
        this._methods = methods;
    }
    setupAndroidSafeArea() {
        var _a, _b;
        if (this._controller == null) {
            console.warn('WebView is not set');
            return;
        }
        const insets = (0, react_native_safe_area_context_1.useSafeAreaInsets)();
        (_b = (_a = this._controller) === null || _a === void 0 ? void 0 : _a.current) === null || _b === void 0 ? void 0 : _b.injectJavaScript(`
      document.documentElement.style.setProperty('--android-safe-area-inset-top', '${insets.top.toString()}px');
      document.documentElement.style.setProperty('--android-safe-area-inset-left', '${insets.left.toString()}px');
      document.documentElement.style.setProperty('--android-safe-area-inset-right', '${insets.right.toString()}px');
      document.documentElement.style.setProperty('--android-safe-area-inset-bottom', '${insets.bottom.toString()}px');
    `);
    }
    call(functionName, data) {
        var _a, _b;
        if (this._controller == null) {
            console.warn('WebView is not set');
            return;
        }
        const script = `${functionName}('${JSON.stringify(data).replace(/'/g, "\\'")}')`;
        (_b = (_a = this._controller) === null || _a === void 0 ? void 0 : _a.current) === null || _b === void 0 ? void 0 : _b.injectJavaScript(script);
    }
    execute(payload) {
        const handler = this._methods[payload.command];
        if (handler) {
            handler(payload.data);
        }
        else {
            // Unknown command
            console.error(`Unknown command: ${payload.command}`);
        }
    }
    static async init() {
        console.log('WNInterface.init');
        this._properties = ReactNativeWNInterface.getProperties();
        console.log('WNInterface.this._properties', this._properties);
    }
    static get interfaceName() {
        return 'ReactNativeWebView';
    }
    static get isEmulator() {
        if (react_native_1.Platform.OS === 'ios') {
            return react_native_1.NativeModules.WNInterface.isEmulator;
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
exports.WNInterface = WNInterface;
WNInterface._properties = {};
