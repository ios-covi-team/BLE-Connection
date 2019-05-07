//
//  ProtocolManager.h
//  SBKApplication
//
//  Created by Covisoft Viet Nam on 8/9/16.
//  Copyright © 2016 Covisoft Viet Nam. All rights reserved.
//

#import "BLEData.h"
#import "BLE.h"
@interface PontusProtocolManager : NSObject
- (void)sendCommandWithValue:(NSData *)data;
- (instancetype)initProtocolManagerWithBLE:(BLE *)theBle;
- (UInt16)sumCRCWithData:(NSData *)data;
@property (nonatomic, assign) BOOL isUnSubmit;
@property (nonatomic, strong) BLEData *bleData;

@end
