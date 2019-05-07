//
//  PontusHUDManager.h
//  HudFramework
//
//  Created by Mr.Robo on 11/1/18.
//  Copyright © 2018 HudFramework. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <HudFramework/PontusHUDSettings.h>
#import "BLE.h"
#import "PontusProtocolManager.h"
#import "PontusHUDSettings.h"

NS_ASSUME_NONNULL_BEGIN

//! Project version number for HudFramework.
FOUNDATION_EXPORT double HudFrameworkVersionNumber;

//! Project version string for HudFramework.
FOUNDATION_EXPORT const unsigned char HudFrameworkVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <HudFramework/PublicHeader.h>

@protocol PontusHUDManagerDelegate <NSObject>
@optional

- (void)pontusTurnOnBluetoothWithAccessories:(BOOL)isOn;

/**
 Callback connection status
 
 @param connected connection status (true, false)
 */
- (void)pontusHudDidUpdateConnection:(BOOL)connected andIsTimeOut:(BOOL)isTimeout;

- (void)pontusHudNotificationDidUpdateData:(NSData *)data;
/**
 Callback data get from BLE device
 
 @param data a data get from BLE device
 */
- (void)pontusHudDidReceiveMessage:(NSData *)data;

/**
 Received a list BLE item after scan success

 @param listDevice list BLE item
 */
- (void)pontusHudDidReceiveListDevice:(NSArray *)listDevice;

@end

@interface PontusHUDManager : NSObject
@property(nonatomic,weak) id<PontusHUDManagerDelegate>delegate;
@property(nullable, strong) PontusHUDSettings *hudSettings;

/**
 In the case not need check any thing about data package received from device
 */
@property(nonatomic,assign) BOOL isNotCheckReceivedData;
@property(nonatomic,assign) int connectTimeout;

/**
 BLE connection status
 */
@property(readonly) BOOL isConnected;

/**
 It's BLE UUID string
 */
@property(readonly) NSString * serialNumber;
@property(nonatomic,strong) NSString * latestUUID;
@property(nullable,strong) NSString * currentUUID;


/**
 SingleTone share instance

 @return iself
 */
+ (instancetype)sharedInstance;

/**
 Connect to BLE device
 */
- (void)hudConnect;

/**
 Connect to BLE device
 */
- (void)hudConnect:(int)timeOut;


/**
 Disconnect to BLE device

 @param isReconnect reconnect condition
 */
- (void)hudDidDisConnectWithIsReconnect:(BOOL)isReconnect;

/**
 Start scan list device BLE
 */
- (void)hudStartScaningDevices;

/**
 Stop scan list device BLE
 */
- (void)hudStopScan;


- (void)hudSetupWithSetting:(PontusHUDSettings *)settings;
- (PontusProtocolManager *)protocolM;

- (void)onSendCommandWithValue:(NSData *)data;

- (BOOL)isBLEOff;

- (BLE *)ble;
- (void)controlSetup;
@end

NS_ASSUME_NONNULL_END
