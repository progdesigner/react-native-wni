// ReactNativeWni.h

#import <React/RCTBridgeModule.h>

@interface ReactNativeWni : NSObject <RCTBridgeModule>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, assign) BOOL isEmulator;
@end
