
//
//  MoECordova.m
//  MoEngage
//
//  Created by Chengappa C D on 27/07/2016.
//  Copyright MoEngage 2016. All rights reserved.
//

#import "MoECordova.h"
#import <MoEngage/MoEngage.h>

@implementation MoECordova

- (void)init:(CDVInvokedUrlCommand*)command;
{
    [self.commandDelegate runInBackground:^ {
        NSLog(@"MoECordova register called");
        self.callbackId = command.callbackId;
    }];
}
#pragma mark- Set AppStatus INSTALL/UPDATE

-(void)existing_user:(CDVInvokedUrlCommand*)command
{
    __block CDVPluginResult* pluginResult = nil;
    if (command.arguments.count >=1) {
        [self.commandDelegate runInBackground:^{
            NSDictionary* attributesDict = [command.arguments objectAtIndex:0];
            if ([self validObjectForKey:@"existing_user" inDictionary:attributesDict] != nil) {
                BOOL isExisting = [[self validObjectForKey:@"existing_user" inDictionary:attributesDict] boolValue];
                NSString* message;
                if (isExisting) {
                    message = @"UPDATE tracked";
                    [[MoEngage sharedInstance] appStatus:UPDATE];
                }
                else{
                    message = @"INSTALL tracked";
                    [[MoEngage sharedInstance] appStatus:INSTALL];
                }
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
            else{
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Arguments not sent correctly"];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
            
        }];
    }
    else{
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
}

#pragma mark- Show InApp method
-(void)showInApp:(CDVInvokedUrlCommand*)command{
    [[MoEngage sharedInstance] handleInAppMessage];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark- Reset method
-(void)logout:(CDVInvokedUrlCommand*)command{
    [[MoEngage sharedInstance]resetUser];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

#pragma mark- Track Event
- (void)track_event:(CDVInvokedUrlCommand*)command
{
    __block CDVPluginResult* pluginResult = nil;
    if (command.arguments.count >=1) {
        [self.commandDelegate runInBackground:^{
            NSDictionary* eventDict = [command.arguments objectAtIndex:0];
            
            NSString* eventName = [self validObjectForKey:@"event_name" inDictionary:eventDict];
            NSMutableDictionary* payloadDict = [self validObjectForKey:@"event_attributes" inDictionary:eventDict];
            if (eventName != nil) {
                [[MoEngage sharedInstance] trackEvent:eventName andPayload:payloadDict];
                NSString* message = [NSString stringWithFormat:@"%@ tracked", eventName];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Event name was null"];
            }
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }
    else{
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
}

#pragma mark- Set User Attributes

- (void)set_user_attribute:(CDVInvokedUrlCommand*)command
{
    __block CDVPluginResult* pluginResult = nil;
    if (command.arguments.count >=1) {
        
        [self.commandDelegate runInBackground:^{
            NSDictionary* userAttributeDict = [command.arguments objectAtIndex:0];
            if (userAttributeDict!=nil) {
                NSString* userAttributeName = [self validObjectForKey:@"attribute_name" inDictionary:userAttributeDict];
                id userAttributeVal  = [self validObjectForKey:@"attribute_value" inDictionary:userAttributeDict];
                if (userAttributeName != nil && userAttributeVal != nil) {
                    [[MoEngage sharedInstance]setUserAttribute:userAttributeVal forKey:userAttributeName];
                    
                    NSString* message = [NSString stringWithFormat:@"%@ tracked with Value %@", userAttributeName, userAttributeVal];
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
                } else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"User Attribute name or value was null"];
                }
            }
            else{
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"User Attribute name or value was null"];
            }
            
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
    }
    else{
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}


-(void)set_user_attribute_location:(CDVInvokedUrlCommand*)command
{
    __block CDVPluginResult* pluginResult = nil;
    if (command.arguments.count >=1) {
        [self.commandDelegate runInBackground:^{
            NSDictionary* userAttributeDict = [command.arguments objectAtIndex:0];
            if (userAttributeDict!=nil) {
                
                NSString* userAttributeName = [self validObjectForKey:@"attribute_name" inDictionary:userAttributeDict];
                id userAttributeLatVal  = [self validObjectForKey:@"attribute_lat_value" inDictionary:userAttributeDict];
                id userAttributeLonVal  = [self validObjectForKey:@"attribute_lon_value" inDictionary:userAttributeDict];
                
                if (userAttributeName != nil && userAttributeLonVal !=nil && userAttributeLatVal != nil) {
                    [[MoEngage sharedInstance] setUserAttributeLocationLatitude:[userAttributeLatVal doubleValue] longitude:[userAttributeLonVal doubleValue] forKey:userAttributeName];
                    
                    NSString* message = [NSString stringWithFormat:@"%@ tracked with Value %@ %@", userAttributeName, userAttributeLatVal, userAttributeLonVal];
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
                } else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"User Attribute name or Lat,Lon value was null"];
                }
            }
            else{
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"User Attribute name or value was null"];
            }
            
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
        
    }
    else{
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
}

- (void)set_user_attribute_timestamp:(CDVInvokedUrlCommand*)command
{
    __block CDVPluginResult* pluginResult = nil;
    if (command.arguments.count >=1) {
        [self.commandDelegate runInBackground:^{
            NSDictionary* userAttributeDict = [command.arguments objectAtIndex:0];
            if (userAttributeDict!=nil) {
                
                NSString* userAttributeName = [self validObjectForKey:@"attribute_name" inDictionary:userAttributeDict];
                id userAttributeTimestampVal  = [self validObjectForKey:@"attribute_value" inDictionary:userAttributeDict];
                
                if (userAttributeName != nil && userAttributeTimestampVal!= nil) {
                    [[MoEngage sharedInstance] setUserAttributeTimestamp:[userAttributeTimestampVal doubleValue] forKey:userAttributeName];
                    
                    NSString* message = [NSString stringWithFormat:@"%@ tracked with Value %@", userAttributeName, userAttributeTimestampVal];
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
                } else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"User Attribute name or TimeStamp value was null"];
                }
                
            }
            else{
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"User Attribute name or value was null"];
            }
            
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }];
        
    }
    else{
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
}

#pragma mark- Utility Methods

-(id)validObjectForKey:(NSString*)key inDictionary:(NSDictionary*)dict {
    id obj = [dict objectForKey:key];
    if (obj == [NSNull null]) {
        obj = nil;
    }
    return obj;
}

- (void)setLogLevelForiOS:(CDVInvokedUrlCommand*)command{
    __block CDVPluginResult* pluginResult = nil;
    if (command.arguments.count >=1) {
        [self.commandDelegate runInBackground:^{
            NSDictionary* attributesDict = [command.arguments objectAtIndex:0];
            if ([self validObjectForKey:@"log_level" inDictionary:attributesDict] != nil) {
                NSInteger logLevel = [[self validObjectForKey:@"log_level" inDictionary:attributesDict] integerValue];
                NSString* message;
                if (logLevel == 1) {
                    message = @"All Logs Enabled";
                    [MoEngage debug:LOG_ALL];
                }
                else if(logLevel == 2) {
                    message = @"Exception Logs Enabled";
                    [MoEngage debug:LOG_EXCEPTIONS];
                }
                else{
                    message = @"SDK Logs Disabled";
                    [MoEngage debug:LOG_NONE];
                }
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
            else{
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Arguments not sent correctly"];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
            
        }];
    }
    else{
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    
}


- (void)registerForPushNotification:(CDVInvokedUrlCommand*)command{
    if (@available(iOS 10.0, *)) {
        [[MoEngage sharedInstance] registerForRemoteNotificationWithCategories:nil withUserNotificationCenterDelegate:[UIApplication sharedApplication].delegate];
    } else {
        [[MoEngage sharedInstance] registerForRemoteNotificationForBelowiOS10WithCategories:nil];
    }
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

- (void)setAlias:(CDVInvokedUrlCommand*)command{
    __block CDVPluginResult* pluginResult = nil;
    if (command.arguments.count >=1) {
        [self.commandDelegate runInBackground:^{
            NSDictionary* attributesDict = [command.arguments objectAtIndex:0];
            if ([self validObjectForKey:@"set_alias" inDictionary:attributesDict] != nil) {
                id aliasVal = [self validObjectForKey:@"set_alias" inDictionary:attributesDict];
                [[MoEngage sharedInstance] setAlias:aliasVal];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Set Alias used to update User Attribute Unique ID"];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
            else{
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Arguments not sent correctly"];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            }
        }];
    }
    else{
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Insufficient arguments"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

#pragma mark- Callbacks to js

-(void)registeredWithdeviceToken:(NSString*)token {
    NSMutableDictionary* message = [NSMutableDictionary dictionaryWithCapacity:2];
    [message setObject:@"pushRegister" forKey:@"type"];
    [message setObject:token forKey:@"deviceToken"];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}


-(void)pushNotificationClickedWithUserInfo:(NSDictionary*)userInfo{
    
    NSMutableDictionary* message = [NSMutableDictionary dictionaryWithCapacity:2];
    [message setObject:@"pushClick" forKey:@"type"];
    [message setObject:userInfo forKey:@"notificationPayload"];
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

-(void)inAppShownWithCampaignID:(NSString*)campaignID{
    NSMutableDictionary* message = [NSMutableDictionary dictionaryWithCapacity:2];
    [message setObject:@"inAppShown" forKey:@"type"];
    [message setObject:campaignID forKey:@"campaignID"];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

-(void)inAppClickedWithWidget:(NSString*)widget andScreenName:(NSString*)screenName andDataDict:(NSDictionary*)dataDict{
    NSMutableDictionary* message = [NSMutableDictionary dictionaryWithCapacity:4];
    [message setObject:@"inAppClick" forKey:@"type"];
    [message setObject:widget forKey:@"widget"];
    if (screenName) {
        [message setObject:screenName forKey:@"screenName"];
    }
    else{
        [message setObject:@"" forKey:@"screenName"];
    }
    
    if (dataDict) {
        [message setObject:dataDict forKey:@"dataDict"];
    }
    else{
        [message setObject:[NSDictionary dictionary] forKey:@"dataDict"];
    }
    
    
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
    [pluginResult setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}


#pragma mark- Unused methods

- (void)pass_token:(CDVInvokedUrlCommand*)command{
    NSString* message = @"Not available for iOS";
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
- (void)pass_payload:(CDVInvokedUrlCommand*)command{
    NSString* message = @"Not available for iOS";
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setLogLevel:(CDVInvokedUrlCommand*)command{
    NSString* message = @"Not available for iOS";
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
@end
