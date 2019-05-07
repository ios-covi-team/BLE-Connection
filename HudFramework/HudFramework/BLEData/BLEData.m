//
//  BLEData.m
//  SBKApplication
//
//  Created by Covisoft Viet Nam on 6/6/16.
//  Copyright © 2016 Covisoft Viet Nam. All rights reserved.
//

#import "BLEData.h"
#import "BLE.h"
#import "BLEDefines.h"
@implementation BLEData
// SET TO BLE
{
    NSMutableArray *dataBLE;
    NSData *dataRecevied;
}

- (void)findSKB:(BLE *)ble andData:(id)dataFind{
    
}
//GET FROM BLE
// recevied data from BLE
- (void)receiveDataBLE:(NSData *)data{
    dataRecevied = data;
}
- (NSData *)getDataBLE{
    // HANDLE AT HERE
    return dataRecevied;
}
- (Byte*)byteData{
    Byte *bytes = (Byte *)[dataRecevied bytes];
    return bytes;
}

- (int)getHeader{
    Byte *bytes = [self byteData];
    return  (bytes[HEADER_POSSITION] & 0xFF);
}

- (int)getID{
    Byte *bytes = [self byteData];
    return  (bytes[ID_POSSITION] & 0xFF);
}

- (int)getCommand{
    Byte *bytes = [self byteData];
    return  (bytes[2] & 0xFF);
}

- (int)getLenght{
    if (dataRecevied.length > LENGTH_POSSITION) {
        Byte *bytes = [self byteData];
        int length =  (int)(bytes[LENGTH_POSSITION] & 0xFF); //length value of payload
        int startPayloadPostion = LENGTH_POSSITION+1; // + 1 because with-out lehght value possitio
        
        NSRange payLoadRange = NSMakeRange(0, dataRecevied.length);
        NSRange range = NSMakeRange(startPayloadPostion, length);
        
        if ((NSEqualRanges(NSIntersectionRange(payLoadRange, range), range) && length < dataRecevied.length)) {
            //safe
            return length;
        }
    }
    return 0;
}

@end
