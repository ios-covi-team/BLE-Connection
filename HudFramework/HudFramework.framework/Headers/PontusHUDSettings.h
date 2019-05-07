//
//  PontusHUDSettings.h
//  HudFramework
//
//  Created by Mr.Robo on 11/1/18.
//  Copyright © 2018 HudFramework. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface PontusHUDSettings : NSObject

/**
 UUID of BLE item
 */
@property(nonatomic, strong) NSString * bleUUID;
@property(nonatomic, strong) CBPeripheral * cbPeripheral;

@end
