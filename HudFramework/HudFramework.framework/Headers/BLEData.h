//
//  BLEData.h
//  SBKApplication
//
//  Created by Covisoft Viet Nam on 6/6/16.
//  Copyright © 2016 Covisoft Viet Nam. All rights reserved.
//

#import <Foundation/Foundation.h>
//@class BLEDataPrtocol;
@interface BLEData : NSObject
/*!
 @discussion received data when ble update the new data
 @param data  data get from
 */
- (void)receiveDataBLE:(NSData *)data;

/*!
 @discussion received data of BLE after get from BLE
 @return NSData data of BLE
 */
- (NSData *)getDataBLE;

- (int)getHeader;
- (int)getID;
- (int)getCommand;
- (int)getLenght;

@end
