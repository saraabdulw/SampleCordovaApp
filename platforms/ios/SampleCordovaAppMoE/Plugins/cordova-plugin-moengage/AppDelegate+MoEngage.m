
//
//  AppDelegate+MoEngage.m
//  MoEngage
//
//  Created by Chengappa C D on 18/08/2016.
//  Copyright MoEngage 2016. All rights reserved.
//


#import "AppDelegate+MoEngage.h"
#import <objc/runtime.h>
#import <MoEngage/MoEngage.h>
#import "MoECordova.h"

#define MoEngage_APP_ID_KEY                 @"MoEngage_APP_ID"
#define MoEngage_DICT_KEY                   @"MoEngage"
#define SDK_PROXY_KEY                       @"MoEngageAppDelegateProxyEnabled"
#define SDK_Version                         @"501"

static char pendingPushPayloadKey;
static char isAppInActiveKey;

@interface  AppDelegate (MoEngageNotifications) <MOInAppDelegate, UNUserNotificationCenterDelegate>

@property(retain, nonatomic) NSNumber* isAppInActive;
@property(retain, nonatomic) NSDictionary* pendingPushPayload;

@end

@implementation AppDelegate (MoEngageNotifications)

#pragma mark- Load Method

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        //ApplicationDidFinshLaunching Method
        SEL appDidFinishLaunching = @selector(application:didFinishLaunchingWithOptions:);
        SEL swizzledAppDidFinishLaunching = @selector(moengage_swizzled_application:didFinishLaunchingWithOptions:);
        [self swizzleMethodWithClass:class originalSelector:appDidFinishLaunching andSwizzledSelector:swizzledAppDidFinishLaunching];
        
        [self swizzleNotificationCallbacks];
    });
}

+(void)swizzleNotificationCallbacks{
    
    if ([self isSDKProxyEnabled]){
        return;
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        id delegate = [UIApplication sharedApplication].delegate;
        //Application Register for remote notification
        if ([delegate respondsToSelector:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)]) {
            SEL registerForNotificationSelector = @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:);
            SEL swizzledRegisterForNotificationSelector = @selector(moengage_swizzled_application:didRegisterForRemoteNotificationsWithDeviceToken:);
            [self swizzleMethodWithClass:class originalSelector:registerForNotificationSelector andSwizzledSelector:swizzledRegisterForNotificationSelector];
        } else {
            SEL registerForNotificationSelector = @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:);
            SEL swizzledRegisterForNotificationSelector = @selector(moengage_swizzled_no_application:didRegisterForRemoteNotificationsWithDeviceToken:);
            [self swizzleMethodWithClass:class originalSelector:registerForNotificationSelector andSwizzledSelector:swizzledRegisterForNotificationSelector];
        }
        
        if ([delegate respondsToSelector:@selector(application:didFailToRegisterForRemoteNotificationsWithError:)]) {
            SEL failRegisterForNotificationSelector = @selector(application:didFailToRegisterForRemoteNotificationsWithError:);
            SEL swizzledFailRegisterForNotificationSelector = @selector(moengage_swizzled_application:didFailToRegisterForRemoteNotificationsWithError:);
            [self swizzleMethodWithClass:class originalSelector:failRegisterForNotificationSelector andSwizzledSelector:swizzledFailRegisterForNotificationSelector];
        } else {
            SEL failRegisterForNotificationSelector = @selector(application:didFailToRegisterForRemoteNotificationsWithError:);
            SEL swizzledFailRegisterForNotificationSelector = @selector(moengage_swizzled_no_application:didFailToRegisterForRemoteNotificationsWithError:);
            [self swizzleMethodWithClass:class originalSelector:failRegisterForNotificationSelector andSwizzledSelector:swizzledFailRegisterForNotificationSelector];
        }
        
        //Application Register for  user notification settings
        if ([delegate respondsToSelector:@selector(application:didRegisterUserNotificationSettings:)]) {
            SEL registerForUserSettingsSelector = @selector(application:didRegisterUserNotificationSettings:);
            SEL swizzledRegisterForUserSettingsSelector = @selector(moengage_swizzled_application:didRegisterUserNotificationSettings:);
            [self swizzleMethodWithClass:class originalSelector:registerForUserSettingsSelector andSwizzledSelector:swizzledRegisterForUserSettingsSelector];
        } else {
            SEL registerForUserSettingsSelector = @selector(application:didRegisterUserNotificationSettings:);
            SEL swizzledRegisterForUserSettingsSelector = @selector(moengage_swizzled_no_application:didRegisterUserNotificationSettings:);
            [self swizzleMethodWithClass:class originalSelector:registerForUserSettingsSelector andSwizzledSelector:swizzledRegisterForUserSettingsSelector];
        }
        
        //Application Did Receive Remote Notification
        if ([delegate respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)]) {
            SEL receivedNotificationSelector = @selector(application:didReceiveRemoteNotification:fetchCompletionHandler:);
            SEL swizzledReceivedNotificationSelector = @selector(moengage_swizzled_application:didReceiveRemoteNotification:fetchCompletionHandler:);
            [self swizzleMethodWithClass:class originalSelector:receivedNotificationSelector andSwizzledSelector:swizzledReceivedNotificationSelector];
        } else if ([delegate respondsToSelector:@selector(application:didReceiveRemoteNotification:)]) {
            SEL receivedNotificationSelector = @selector(application:didReceiveRemoteNotification:);
            SEL swizzledReceivedNotificationSelector = @selector(moengage_swizzled_application:didReceiveRemoteNotification:);
            [self swizzleMethodWithClass:class originalSelector:receivedNotificationSelector andSwizzledSelector:swizzledReceivedNotificationSelector];
        } else {
            SEL receivedNotificationSelector = @selector(application:didReceiveRemoteNotification:);
            SEL swizzledReceivedNotificationSelector = @selector(moengage_swizzled_no_application:didReceiveRemoteNotification:);
            [self swizzleMethodWithClass:class originalSelector:receivedNotificationSelector andSwizzledSelector:swizzledReceivedNotificationSelector];
        }
        
    });
    
}

+(BOOL)isSDKProxyEnabled{
    // AppDelegate in core SDK is from version 5.0.0
    if (![self isSDKVersionGreaterThan5]) {
        return false;
    }
    
    // Check SDK Proxy key
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    if ( [infoDict objectForKey:SDK_PROXY_KEY] != nil && [infoDict objectForKey:SDK_PROXY_KEY] != [NSNull null]) {
        return [[infoDict objectForKey:SDK_PROXY_KEY] boolValue];
    }
    else{
        return true;
    }
}

+(BOOL)isSDKVersionGreaterThan5{
    NSDictionary *infoDictionary = [[NSBundle bundleForClass:[MoEngage class]] infoDictionary];
    NSString *sdk_version_str = [infoDictionary valueForKey:@"CFBundleShortVersionString"];
    if(sdk_version_str != nil){
        NSArray* version_arr = [sdk_version_str componentsSeparatedByString:@"."];
        NSString* major_version_str = version_arr[0];
        NSInteger major_version = [major_version_str integerValue];
        
        if(major_version < 5){
            return false;
        }
    }
    return true;
}


#pragma mark- Swizzle Method

+ (void)swizzleMethodWithClass:(Class)class originalSelector:(SEL)originalSelector andSwizzledSelector:(SEL)swizzledSelector {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma mark- Application LifeCycle methods

- (BOOL)moengage_swizzled_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    if (@available(iOS 10.0, *)) {
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    }

    //Add Observer for app termination
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moengage_applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moengage_applicationDidBecomeActive:)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
    
    [self initializeApplication:application andLaunchOptions:launchOptions];
    
    return [self moengage_swizzled_application:application didFinishLaunchingWithOptions:launchOptions];
}

-(void)initializeApplication:(UIApplication*)application andLaunchOptions:(NSDictionary*)launchOptions{
    NSString* appID = [self getMoEngageAppID];
    if (appID == nil) {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:SDK_Version forKey:MoEngage_Cordova_SDK_Version];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
#ifdef DEBUG
    [[MoEngage sharedInstance] initializeDevWithApiKey:appID inApplication:application withLaunchOptions:launchOptions openDeeplinkUrlAutomatically:YES];
#else
    [[MoEngage sharedInstance] initializeProdWithApiKey:appID inApplication:application withLaunchOptions:launchOptions openDeeplinkUrlAutomatically:YES];
#endif
    
    [MoEngage sharedInstance].delegate = self;
    
    if([application isRegisteredForRemoteNotifications]){
        if (@available(iOS 10.0, *)) {
            [[MoEngage sharedInstance] registerForRemoteNotificationWithCategories:nil withUserNotificationCenterDelegate:self];
        } else {
            [[MoEngage sharedInstance] registerForRemoteNotificationForBelowiOS10WithCategories:nil];
        }
    }
    
}

-(NSString*)getMoEngageAppID {
    NSString* moeAppID;
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    
    if ( [infoDict objectForKey:MoEngage_DICT_KEY] != nil && [infoDict objectForKey:MoEngage_DICT_KEY] != [NSNull null]) {
        NSDictionary* moeDict = [infoDict objectForKey:MoEngage_DICT_KEY];
        if ([moeDict objectForKey:MoEngage_APP_ID_KEY] != nil && [moeDict objectForKey:MoEngage_APP_ID_KEY] != [NSNull null]) {
            moeAppID = [moeDict objectForKey:MoEngage_APP_ID_KEY];
        }
    }
    
    if (moeAppID.length > 0) {
        return moeAppID;
    }
    else{
        NSLog(@"MoEngage - Provide the APP ID for your MoEngage App in Info.plist for key MoEngage_APP_ID to proceed. To get the AppID login to your MoEngage account, after that go to Settings -> App Settings. You will find the App ID in this screen.");
        return nil;
    }

}


- (void)moengage_applicationWillTerminate:(NSNotification *)notif {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}


- (void)moengage_applicationDidBecomeActive:(NSNotification *)notif {
    [self performSelector:@selector(delayedNotificationCallback) withObject:nil afterDelay:2.0];
}

-(void)delayedNotificationCallback{
    if (self.pendingPushPayload && ([self.isAppInActive boolValue] == true)) {
        NSDictionary* pushDictionary = [self.pendingPushPayload copy];
        NSLog(@"Push Payload : %@",pushDictionary);
        [[NSNotificationCenter defaultCenter] postNotificationName:MoEngage_Notification_Received_Notification object:[UIApplication sharedApplication] userInfo:pushDictionary];
        [self callbackForNotificationReceived:pushDictionary];
        self.pendingPushPayload = nil;
        self.isAppInActive = nil;
    }
}

#pragma mark- Register For Push methods

- (void)moengage_swizzled_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    if (![AppDelegate isSDKProxyEnabled]){
        [[MoEngage sharedInstance] setPushToken:deviceToken];
        
        if (![AppDelegate isSDKVersionGreaterThan5]) {
            NSDictionary* userInfo = @{MoEngage_Device_Token_Key: deviceToken};
            [[NSNotificationCenter defaultCenter] postNotificationName:MoEngage_Notification_Registered_Notification object:[UIApplication sharedApplication] userInfo:userInfo];
        }
    }
    [self callbackForRegisteredForNotificationWithToken:deviceToken];
    [self moengage_swizzled_application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)moengage_swizzled_no_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if (![AppDelegate isSDKProxyEnabled]){
        [[MoEngage sharedInstance] setPushToken:deviceToken];
        
        if (![AppDelegate isSDKVersionGreaterThan5]) {
            NSDictionary* userInfo = @{MoEngage_Device_Token_Key: deviceToken};
            [[NSNotificationCenter defaultCenter] postNotificationName:MoEngage_Notification_Registered_Notification object:[UIApplication sharedApplication] userInfo:userInfo];
        }
    }
    [self callbackForRegisteredForNotificationWithToken:deviceToken];
}

-(void)moengage_swizzled_application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (![AppDelegate isSDKProxyEnabled]){
        [[MoEngage sharedInstance]didFailToRegisterForPush];
        
        if (![AppDelegate isSDKVersionGreaterThan5]) {
            NSDictionary* userInfo = @{@"error": error};
            [[NSNotificationCenter defaultCenter] postNotificationName:MoEngage_Notification_Registration_Failed_Notification object:[UIApplication sharedApplication] userInfo:userInfo];
        }
    }
    
    [self moengage_swizzled_application:application didFailToRegisterForRemoteNotificationsWithError:error];
}


-(void)moengage_swizzled_no_application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (![AppDelegate isSDKProxyEnabled]){
        [[MoEngage sharedInstance]didFailToRegisterForPush];
        
        if (![AppDelegate isSDKVersionGreaterThan5]) {
            NSDictionary* userInfo = @{@"error": error};
            [[NSNotificationCenter defaultCenter] postNotificationName:MoEngage_Notification_Registration_Failed_Notification object:[UIApplication sharedApplication] userInfo:userInfo];
        }
    }
}

-(void)moengage_swizzled_application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    if (![AppDelegate isSDKProxyEnabled]){
        [[MoEngage sharedInstance]didRegisterForUserNotificationSettings:notificationSettings];
    }
    
    NSDictionary* userInfo = @{MoEngage_Notification_Settings_Key: notificationSettings};
    [[NSNotificationCenter defaultCenter] postNotificationName:MoEngage_Notification_UserSettings_Registered_Notification object:[UIApplication sharedApplication] userInfo:userInfo];
    
    [self moengage_swizzled_application:application didRegisterUserNotificationSettings:notificationSettings];
}

-(void)moengage_swizzled_no_application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    if (![AppDelegate isSDKProxyEnabled]){
        [[MoEngage sharedInstance]didRegisterForUserNotificationSettings:notificationSettings];
    }
    
    NSDictionary* userInfo = @{MoEngage_Notification_Settings_Key: notificationSettings};
    [[NSNotificationCenter defaultCenter] postNotificationName:MoEngage_Notification_UserSettings_Registered_Notification object:[UIApplication sharedApplication] userInfo:userInfo];
    
}

#pragma mark- Receive Notification methods

- (void)moengage_swizzled_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)]) {
        [self moengage_swizzled_application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
    }
    
    
    if (![AppDelegate isSDKProxyEnabled]){
        [[MoEngage sharedInstance] didReceieveNotificationinApplication:application withInfo:userInfo openDeeplinkUrlAutomatically:NO];
        
        if (![AppDelegate isSDKVersionGreaterThan5]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:MoEngage_Notification_Received_Notification object:[UIApplication sharedApplication] userInfo:userInfo];
        }
    }
    
    [self callbackForNotificationReceived:userInfo];
}

- (void)moengage_swizzled_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self moengage_swizzled_application:application didReceiveRemoteNotification:userInfo];
    
    if (![AppDelegate isSDKProxyEnabled]){
        [[MoEngage sharedInstance] didReceieveNotificationinApplication:application withInfo:userInfo openDeeplinkUrlAutomatically:NO];
        
        if (![AppDelegate isSDKVersionGreaterThan5]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:MoEngage_Notification_Received_Notification object:[UIApplication sharedApplication] userInfo:userInfo];
        }
    }
    [self callbackForNotificationReceived:userInfo];
}

- (void)moengage_swizzled_no_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    if (![AppDelegate isSDKProxyEnabled]){
        [[MoEngage sharedInstance] didReceieveNotificationinApplication:application withInfo:userInfo openDeeplinkUrlAutomatically:NO];
        
        if (![AppDelegate isSDKVersionGreaterThan5]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:MoEngage_Notification_Received_Notification object:[UIApplication sharedApplication] userInfo:userInfo];
        }
    }
    [self callbackForNotificationReceived:userInfo];
}

#pragma mark- iOS10 UserNotification Framework delegate methods

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)())completionHandler{
    
    NSDictionary *pushDictionary = response.notification.request.content.userInfo;
    
    if (![AppDelegate isSDKProxyEnabled]){
        [[MoEngage sharedInstance] userNotificationCenter:center didReceiveNotificationResponse:response];
        if (![AppDelegate isSDKVersionGreaterThan5]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:MoEngage_Notification_Received_Notification object:[UIApplication sharedApplication] userInfo:pushDictionary];
        }
    }
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        self.pendingPushPayload = response.notification.request.content.userInfo;
        self.isAppInActive = [NSNumber numberWithBool:YES];
    }
    
    if ([self.isAppInActive boolValue] == false) {
        [self callbackForNotificationReceived:pushDictionary];
    }
    
    completionHandler();
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    completionHandler((UNNotificationPresentationOptionSound
                       | UNNotificationPresentationOptionAlert));
}

#pragma mark- InApp Delegate methods

-(void)inAppShownWithCampaignID:(NSString *)campaignID{
    if (!campaignID.length) {
        return;
    }
    MoECordova* cordovaHandler = [self getCommandInstance:@"MoEngage"];
    [cordovaHandler inAppShownWithCampaignID:campaignID];
}

-(void)inAppClickedForWidget:(InAppWidget)widget screenName:(NSString *)screenName andDataDict:(NSDictionary *)dataDict{
    MoECordova* cordovaHandler = [self getCommandInstance:@"MoEngage"];
    NSString* widgetStr = @"";
    switch (widget) {
        case BUTTON:
            widgetStr = @"Button";
            break;
        case IMAGE:
            widgetStr = @"Image";
            break;
        case LABEL:
            widgetStr = @"Label";
            break;
        case CLOSE_BUTTON:
            widgetStr = @"CloseButton";
            break;
        default:
            break;
    }
    [cordovaHandler inAppClickedWithWidget:widgetStr andScreenName:screenName andDataDict:dataDict];
}



#pragma mark- Push JS Callbacks

-(void)callbackForNotificationReceived:(NSDictionary*)userInfo{
    MoECordova* cordovaHandler = [self getCommandInstance:@"MoEngage"];
    [cordovaHandler pushNotificationClickedWithUserInfo:userInfo];
}

-(void)callbackForRegisteredForNotificationWithToken:(NSData*)deviceToken{
    MoECordova* cordovaHandler = [self getCommandInstance:@"MoEngage"];
    NSString* token = [self hexTokenForData:deviceToken];
    [cordovaHandler registeredWithdeviceToken:token];
}

#pragma mark- Utility methods

- (id) getCommandInstance:(NSString*)className
{
    return [self.viewController getCommandInstance:className];
}
     
// Gives Device token in Hex String
-(NSString *)hexTokenForData:(NSData *)data{
    if(!data){
        return @"";
    }
    const unsigned *tokenBytes = [data bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    return hexToken;
}


//Since you can't define a property in a category
- (NSMutableArray *)pendingPushPayload
{
    return objc_getAssociatedObject(self, &pendingPushPayloadKey);
}

- (void)setPendingPushPayload:(NSDictionary *)aDictionary
{
    objc_setAssociatedObject(self, &pendingPushPayloadKey, aDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)isAppInActive
{
    return objc_getAssociatedObject(self, &isAppInActiveKey);
}

- (void)setIsAppInActive:(NSNumber *)aNumber
{
    objc_setAssociatedObject(self, &isAppInActiveKey, aNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)dealloc
{
    self.pendingPushPayload = nil; // clear the association and release the object
    self.isAppInActive = nil;
}

@end





