// ReactNativeWni.h
#import <sys/utsname.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <React/RCTBridgeModule.h>

@interface ReactNativeWni : NSObject <RCTBridgeModule>
@property (nonatomic) bool isEmulator;
@property (nonatomic) WKWebView* webView API_AVAILABLE(ios(8.0));
@end
