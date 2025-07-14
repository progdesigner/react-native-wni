import { RefObject } from 'react';
import type { WebView, WebViewMessageEvent } from 'react-native-webview';
export declare class ReactNativeWNInterface {
    static getProperties(): any;
}
export type WNInterfacePayload = {
    command: string;
    data: Record<string, any>;
};
type WNInterfaceOptions = {
    controller?: RefObject<WebView>;
    onCommand?: (payload: WNInterfacePayload) => void;
};
export declare class WNInterface {
    private _controller?;
    private _onCommand?;
    private _methods;
    constructor(options: WNInterfaceOptions);
    setWebView(webView: RefObject<WebView>): void;
    registerMethods(methods: {
        [key: string]: Function;
    }): void;
    /**
     * WebView에 SafeAreaInset 값을 주입합니다. 반드시 함수형 컴포넌트에서 useSafeAreaInsets로 값을 받아서 전달해야 합니다.
     * @param insets useSafeAreaInsets()로 얻은 값
     */
    setupAndroidSafeArea(insets: {
        top: number;
        left: number;
        right: number;
        bottom: number;
    }): void;
    handleMessage: (event: WebViewMessageEvent) => void;
    call(functionName: string, data: any): void;
    execute(payload: WNInterfacePayload): void;
    static _properties: any;
    static init(): Promise<void>;
    static get interfaceName(): string;
    static get isEmulator(): any;
    static get interfaceVersion(): any;
    static get appId(): any;
    static get appName(): any;
    static get appVersion(): any;
    static get buildVersion(): any;
    static get systemName(): any;
    static get systemVersion(): any;
    static get osType(): any;
    static get osVersion(): any;
    static get deviceId(): any;
    static get deviceUuid(): any;
    static get deviceLocale(): any;
    static get deviceModel(): any;
    static get deviceName(): any;
    static get deviceType(): any;
    static get deviceBrand(): any;
    static get userAgent(): any;
    static get webViewUserAgent(): any;
}
export {};
