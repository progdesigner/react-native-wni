#import <Security/Security.h>

@interface KeychainItemWrapper : NSObject
- (id)initWithIdentifier: (NSString *)identifier accessGroup:(NSString *)accessGroup;
- (void)setObject:(id)inObject forKey:(id)key;
- (id)objectForKey:(id)key;
- (void)resetKeychainItem;
@end

#if ! __has_feature(objc_arc)
#error THIS CODE MUST BE COMPILED WITH ARC ENABLED!
#endif

@interface KeychainItemWrapper (PrivateMethods)
- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert;
- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert;
- (void)writeToKeychain;
@end
