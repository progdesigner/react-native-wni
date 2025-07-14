// ReactNativeWniModule.java

package com.reactlibrary;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.provider.Settings;
import android.webkit.WebSettings;
import android.webkit.WebView;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

import org.json.JSONObject;

import java.util.Locale;
import java.util.UUID;

public class ReactNativeWniModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;

    public ReactNativeWniModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "ReactNativeWni";
    }

    @ReactMethod
    public void getProperties(Promise promise) {
        try {
            JSONObject info = new JSONObject();
            PackageManager packageManager = reactContext.getPackageManager();
            String packageName = reactContext.getPackageName();
            String shortPackageName = packageName.substring(packageName.lastIndexOf(".") + 1);

            String applicationName = "";
            String applicationVersion = "";
            String buildVersion = "";
            String userAgent = getUserAgent();
            String packageUserAgent = userAgent;

            try {
                PackageInfo pkgInfo = packageManager.getPackageInfo(packageName, 0);
                applicationName = reactContext.getApplicationInfo().loadLabel(packageManager).toString();
                applicationVersion = pkgInfo.versionName;
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    buildVersion = Long.toString(pkgInfo.getLongVersionCode());
                } else {
                    buildVersion = Integer.toString(pkgInfo.versionCode);
                }
            } catch (PackageManager.NameNotFoundException e) {
                applicationName = "App";
                applicationVersion = "0.0.0";
                buildVersion = "0";
            }

            packageUserAgent = shortPackageName + '/' + applicationVersion + '.' + buildVersion + ' ' + userAgent;

            info.put("interfaceVersion", "v1");
            info.put("appId", packageName);
            info.put("appName", applicationName);
            info.put("appVersion", applicationVersion);
            info.put("buildVersion", buildVersion);

            info.put("osType", "Android");
            info.put("osVersion", Integer.toString(Build.VERSION.SDK_INT));

            info.put("deviceUuid", deviceUuid(reactContext));
            info.put("deviceId", deviceUuid(reactContext)); // 하위 호환
            info.put("deviceLocale", deviceLocale(reactContext));
            info.put("deviceModel", Build.MODEL);
            info.put("deviceName", deviceName());
            info.put("deviceType", "mobile");
            info.put("deviceBrand", Build.BRAND);

            // 데이터 호환
            info.put("systemName", "Android");
            info.put("systemVersion", Build.VERSION.RELEASE);
            info.put("packageName", packageName);
            info.put("shortPackageName", shortPackageName);
            info.put("applicationName", applicationName);
            info.put("applicationVersion", applicationVersion);
            info.put("packageUserAgent", packageUserAgent);
            info.put("userAgent", userAgent);
            info.put("webViewUserAgent", getWebViewUserAgent());

            promise.resolve(info.toString());
        } catch (Exception e) {
            promise.reject("ERR_PROPERTIES", e);
        }
    }

    private String deviceUuid(Context context) {
        String androidID = Settings.Secure.getString(context.getContentResolver(), Settings.Secure.ANDROID_ID);
        UUID deviceUUID = new UUID(androidID.hashCode(), ((long) androidID.hashCode() << 32));
        return deviceUUID.toString();
    }

    private String deviceLocale(Context context) {
        Locale current;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            current = context.getResources().getConfiguration().getLocales().get(0);
        } else {
            current = context.getResources().getConfiguration().locale;
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            return current.toLanguageTag();
        } else {
            StringBuilder builder = new StringBuilder();
            builder.append(current.getLanguage());
            if (current.getCountry() != null) {
                builder.append("-");
                builder.append(current.getCountry());
            }
            return builder.toString();
        }
    }

    private String deviceName() {
        String manufacturer = Build.MANUFACTURER;
        String model = Build.MODEL;
        if (model.startsWith(manufacturer)) {
            return model;
        }
        return manufacturer + " " + model;
    }

    private String getUserAgent() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            return System.getProperty("http.agent");
        }
        return "";
    }

    private String getWebViewUserAgent() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            return WebSettings.getDefaultUserAgent(reactContext);
        }
        WebView webView = new WebView(reactContext);
        String userAgentString = webView.getSettings().getUserAgentString();
        destroyWebView(webView);
        return userAgentString;
    }

    private void destroyWebView(WebView webView) {
        webView.loadUrl("about:blank");
        webView.stopLoading();
        webView.clearHistory();
        webView.removeAllViews();
        webView.destroyDrawingCache();
        webView.destroy();
    }
}
