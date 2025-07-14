// ReactNativeWni.m

#import "ReactNativeWni.h"
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <sys/utsname.h>
#import <Security/Security.h>
#import "KeychainItemWrapper.h"

@interface ReactNativeWni : NSObject <RCTBridgeModule>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, assign) BOOL isEmulator;
@end

@implementation ReactNativeWni

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(getProperties:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    UIDevice *device = [UIDevice currentDevice];
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSLocale *currentLocale = [NSLocale currentLocale];
    NSString *appName = [mainBundle objectForInfoDictionaryKey:@"CFBundleName"] ?: @"";
    NSString *appVersion = [mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"";
    NSString *buildVersion = [mainBundle objectForInfoDictionaryKey:@"CFBundleVersion"] ?: @"";
    NSString *deviceName = [self deviceName];
    NSString *deviceUUID = [self keychainUUID];
    NSString *bundleId = mainBundle.bundleIdentifier ?: @"";
    NSArray *parts = [bundleId componentsSeparatedByString:@"."];
    NSString *shortPackageName = parts.count > 0 ? parts.lastObject : bundleId;
    NSString *systemName = device.systemName ?: @"iOS";
    NSString *systemVersion = device.systemVersion ?: @"";
    NSString *userAgent = [NSString stringWithFormat:@"%@/%@.%@ (%@ %@/%@)", shortPackageName, appVersion, buildVersion, deviceName, systemName, systemVersion];
    NSString *packageUserAgent = [NSString stringWithFormat:@"%@/%@.%@ %@", shortPackageName, appVersion, buildVersion, userAgent];

    if (!self.webView) {
        self.webView = [[WKWebView alloc] init];
    }
    [self.webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(NSString *webViewUserAgent, NSError *error) {
        NSDictionary *info = @{
            @"interfaceVersion": @"v1",
            @"appId": bundleId,
            @"appName": appName,
            @"appVersion": appVersion,
            @"buildVersion": buildVersion,
            @"osType": @"iOS",
            @"osVersion": systemVersion,
            @"deviceUuid": deviceUUID,
            @"deviceId": deviceUUID,
            @"deviceLocale": [currentLocale localeIdentifier] ?: @"",
            @"deviceModel": [device.model lowercaseString] ?: @"",
            @"deviceName": deviceName ?: @"",
            @"deviceType": @"mobile",
            @"deviceBrand": @"apple",
            @"systemName": systemName,
            @"systemVersion": systemVersion,
            @"packageName": bundleId,
            @"shortPackageName": shortPackageName,
            @"applicationName": appName,
            @"applicationVersion": appVersion,
            @"packageUserAgent": packageUserAgent,
            @"userAgent": userAgent,
            @"webViewUserAgent": webViewUserAgent ?: @""
        };
        resolve(info);
    }];
}

- (NSString *)keychainUUID {
    NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier ?: @"";
    NSString *account = [bundleIdentifier stringByAppendingString:@".uuid"];
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:account accessGroup:nil];
    NSString *uuid = [keychain objectForKey:(__bridge id)kSecValueData];
    if (uuid && uuid.length > 0) {
        return uuid;
    }
    uuid = [[NSUUID UUID] UUIDString];
    [keychain setObject:uuid forKey:(__bridge id)kSecValueData];
    return uuid;
}

- (NSString *)deviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceIdentifier = [NSString stringWithUTF8String:systemInfo.machine];
#if TARGET_IPHONE_SIMULATOR
    deviceIdentifier = [NSString stringWithFormat:@"%s", getenv("SIMULATOR_MODEL_IDENTIFIER")];
    self.isEmulator = YES;
#else
    self.isEmulator = NO;
#endif
    return deviceIdentifier;
}

@end
