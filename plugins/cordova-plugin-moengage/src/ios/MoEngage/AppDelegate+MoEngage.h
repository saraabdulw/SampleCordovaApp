
//
//  AppDelegate+MoEngage.h
//  MoEngage
//
//  Created by Chengappa C D on 18/08/2016.
//  Copyright MoEngage 2016. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (MoEngageNotification)

+ (void)swizzleMethodWithClass:(Class)class originalSelector:(SEL)originalSelector andSwizzledSelector:(SEL)swizzledSelector;

//Application LifeCycle methods
- (BOOL)moengage_swizzled_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (BOOL)moengage_swizzled_no_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

//Receive Remote Notification methods
- (void)moengage_swizzled_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
- (void)moengage_swizzled_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
- (void)moengage_swizzled_no_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

//Register for Remote Notification methods
- (void)moengage_swizzled_application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;
- (void)moengage_swizzled_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)moengage_swizzled_application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

- (void)moengage_swizzled_no_application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings;
- (void)moengage_swizzled_no_application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)moengage_swizzled_no_application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error ;

//Action Button Handlers
- (void)moengage_swizzled_application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(nullable NSDictionary *)userInfo completionHandler:(nullable void(^)())completionHandler;
- (void)moengage_swizzled_no_application:(nullable UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(nullable NSDictionary *)userInfo completionHandler:(nullable void(^)())completionHandler;
@end
