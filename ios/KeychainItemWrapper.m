#import <Security/Security.h>
#import "KeychainItemWrapper.h"

@implementation KeychainItemWrapper
{
    NSMutableDictionary *keychainItemData;
    NSMutableDictionary *genericPasswordQuery;
}

- (id)initWithIdentifier: (NSString *)identifier accessGroup:(NSString *) accessGroup
{
    if (self = [super init])
    {
        genericPasswordQuery = [[NSMutableDictionary alloc] init];
        [genericPasswordQuery setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        [genericPasswordQuery setObject:identifier forKey:(__bridge id)kSecAttrGeneric];
        if (accessGroup != nil)
        {
#if TARGET_IPHONE_SIMULATOR
#else
            [genericPasswordQuery setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
#endif
        }
        [genericPasswordQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
        [genericPasswordQuery setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
        NSDictionary *tempQuery = [NSDictionary dictionaryWithDictionary:genericPasswordQuery];
        CFMutableDictionaryRef outDictionary = NULL;
        if (!SecItemCopyMatching((__bridge CFDictionaryRef)tempQuery, (CFTypeRef *)&outDictionary) == noErr)
        {
            [self resetKeychainItem];
            [keychainItemData setObject:identifier forKey:(__bridge id)kSecAttrGeneric];
            if (accessGroup != nil)
            {
#if TARGET_IPHONE_SIMULATOR
#else
                [keychainItemData setObject:accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
#endif
            }
        }
        else
        {
            keychainItemData = [self secItemFormatToDictionary:(__bridge NSDictionary *)outDictionary];
        }
        if(outDictionary) CFRelease(outDictionary);
    }
    return self;
}

- (void)setObject:(id)inObject forKey:(id)key 
{
    if (inObject == nil) return;
    id currentObject = [keychainItemData objectForKey:key];
    if (![currentObject isEqual:inObject])
    {
        [keychainItemData setObject:inObject forKey:key];
        [self writeToKeychain];
    }
}

- (id)objectForKey:(id)key
{
    return [keychainItemData objectForKey:key];
}

- (void)resetKeychainItem
{
    OSStatus junk = noErr;
    if (!keychainItemData) 
    {
        keychainItemData = [[NSMutableDictionary alloc] init];
    }
    else if (keychainItemData)
    {
        NSMutableDictionary *tempDictionary = [self dictionaryToSecItemFormat:keychainItemData];
        junk = SecItemDelete((__bridge CFDictionaryRef)tempDictionary);
        NSAssert( junk == noErr || junk == errSecItemNotFound, @"Problem deleting current dictionary." );
    }
    [keychainItemData setObject:@"" forKey:(__bridge id)kSecAttrAccount];
    [keychainItemData setObject:@"" forKey:(__bridge id)kSecAttrLabel];
    [keychainItemData setObject:@"" forKey:(__bridge id)kSecAttrDescription];
    [keychainItemData setObject:@"" forKey:(__bridge id)kSecValueData];
}

- (NSMutableDictionary *)dictionaryToSecItemFormat:(NSDictionary *)dictionaryToConvert
{
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];
    [returnDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    NSString *passwordString = [dictionaryToConvert objectForKey:(__bridge id)kSecValueData];
    [returnDictionary setObject:[passwordString dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
    return returnDictionary;
}

- (NSMutableDictionary *)secItemFormatToDictionary:(NSDictionary *)dictionaryToConvert
{
    NSMutableDictionary *returnDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionaryToConvert];
    [returnDictionary setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [returnDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    CFDataRef passwordData = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)returnDictionary, (CFTypeRef *)&passwordData) == noErr)
    {
        [returnDictionary removeObjectForKey:(__bridge id)kSecReturnData];
        NSString *password = [[NSString alloc] initWithBytes:[(__bridge NSData *)passwordData bytes] length:[(__bridge NSData *)passwordData length] 
                                                     encoding:NSUTF8StringEncoding];
        [returnDictionary setObject:password forKey:(__bridge id)kSecValueData];
    }
    else
    {
        NSAssert(NO, @"Serious error, no matching item found in the keychain.\n");
    }
    if(passwordData) CFRelease(passwordData);
    return returnDictionary;
}

- (void)writeToKeychain
{
    CFDictionaryRef attributes = NULL;
    NSMutableDictionary *updateItem = nil;
    OSStatus result;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)genericPasswordQuery, (CFTypeRef *)&attributes) == noErr)
    {
        updateItem = [NSMutableDictionary dictionaryWithDictionary:(__bridge NSDictionary *)attributes];
        [updateItem setObject:[genericPasswordQuery objectForKey:(__bridge id)kSecClass] forKey:(__bridge id)kSecClass];
        NSMutableDictionary *tempCheck = [self dictionaryToSecItemFormat:keychainItemData];
        [tempCheck removeObjectForKey:(__bridge id)kSecClass];
#if TARGET_IPHONE_SIMULATOR
        [tempCheck removeObjectForKey:(__bridge id)kSecAttrAccessGroup];
#endif
        result = SecItemUpdate((__bridge CFDictionaryRef)updateItem, (__bridge CFDictionaryRef)tempCheck);
        NSAssert( result == noErr, @"Couldn't update the Keychain Item." );
    }
    else
    {
        result = SecItemAdd((__bridge CFDictionaryRef)[self dictionaryToSecItemFormat:keychainItemData], NULL);
        NSAssert( result == noErr, @"Couldn't add the Keychain Item." );
    }
    if(attributes) CFRelease(attributes);
}

@end
