 //
//  ProtocolManager.m
//  SBKApplication
//
//  Created by Covisoft Viet Nam on 8/9/16.
//  Copyright © 2016 Covisoft Viet Nam. All rights reserved.
//

#import "PontusProtocolManager.h"
#import "Util.h"
#import "Constant.h"
#import "BLEDefines.h"
#import "PontusHUDManager.h"
#import "Util.h"
@implementation PontusProtocolManager{
    BLE *ble;
}

- (instancetype)initProtocolManagerWithBLE:(BLE *)theBle{
    self = [super init];
    if (self) {
        _bleData = [[BLEData alloc] init];
        ble = theBle;
    }
    return self;
}

- (void)sendCommandWithValue:(NSData *)data{
    if (ble != nil && ble .isConnected && !_isUnSubmit) {
        NSLog(@"data send %@", data);
        [ble  writeWithRecivedData:data andBLEData:_bleData];
    }
}

- (UInt16)sumCRCWithData:(NSData *)data{
    return [Util sumCRCWithData:data];
}
@end
