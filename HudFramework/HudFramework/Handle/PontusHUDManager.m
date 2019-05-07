//
//  HUDManager.m
//  HudFramework
//
//  Created by Mr.Robo on 11/1/18.
//  Copyright © 2018 HudFramework. All rights reserved.
//

#import "PontusHUDManager.h"
#import "Constant.h"
#import "HUDService.h"
#import "DefinePublic.h"
#import "PontusProtocolManager.h"
#import "Util.h"
#import "MappyModel.h"
#import "BLEDefines.h"
@interface PontusHUDManager()<BLEDelegate>
@property(nonatomic, assign) BOOL isStopSearch;
@property(nonatomic, assign) BOOL isSearching;
@property(nonatomic, assign) float timeWait;
@property(nonatomic, assign) NSTimer *timeOutConnection;

@end

@implementation PontusHUDManager{
    BOOL isReconnection;
    BOOL isStartMappy;
}

__strong static BLE *ble;
__strong static HUDService * service;
__strong static PontusProtocolManager *protocolM;
__strong static NSMutableData *missedData;

extern const struct MappyKeyReadable MappyKey;

+ (PontusHUDManager*) sharedInstance
{
    
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;

    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
        NSLog(@"sharedInstance");
        ble = [[BLE alloc] init];
        service = [[HUDService alloc] init];
        protocolM = [[PontusProtocolManager alloc] initProtocolManagerWithBLE:ble];
        missedData = [[NSMutableData alloc] init];
    });
    // returns the same object each time
    return _sharedObject;
    
    
}

- (PontusProtocolManager *)protocolM{
    return protocolM;
}

- (void)controlSetup{
    if (![self isConnected]) {
        ble.delegate = self;
        NSLog(@"ble.delegate : %@",ble.delegate);
        
        [ble controlSetup];

    }

}

- (NSString *)serialNumber{
    if (_hudSettings.cbPeripheral) {
        return _hudSettings.cbPeripheral.identifier.UUIDString;
    }
    
    return _hudSettings.bleUUID;
}

- (BLE *)ble{
    return ble;
}

- (NSString *)latestUUID{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"latestUUID"];
}

- (void)setLatestUUID:(NSString *)latestUUID{
    [[NSUserDefaults standardUserDefaults] setObject:latestUUID forKey:@"latestUUID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isConnected{
    return ble.isConnected;
}

- (void)terminateApp{
//    [self hudStopMappy];
}

- (void)checkUnSubmitData{
    if ([protocolM.bleData getCommand] == UPDATE_FILE_START_ACK_RESPONSE) {
        protocolM.isUnSubmit = true;
    }else if ([protocolM.bleData getCommand] == UPDATE_FILE_END_ACK_RESPONSE){
        protocolM.isUnSubmit = false;
    }
}

- (void)hudSetupWithSetting:(PontusHUDSettings *)settings{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(terminateApp) name:UIApplicationWillTerminateNotification object:nil];
    isReconnection = true;
    self.hudSettings = settings;
    self.currentUUID = settings.cbPeripheral.identifier.UUIDString;
    
}

- (void)checkParedInphoneSetting{
    NSLog(@"%s",__func__);
    [ble getListDeviceConnectingInPhone];
    NSMutableArray * listDevice = [service getListDevice:ble];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self onHandleWithListDevice:listDevice andBle:ble];
    });
    
}

- (void)hudStartScaningDevices{
    NSLog(@"%s",__func__);
    
    if (![self isConnected]) {
        // in the case connected and want to search again, we don't reset _hudSettings.because in this case we need keep current ssetting for device connect
//        _hudSettings = nil;
    }
    
    if ([self isBLEOff]) {
        if ([_delegate respondsToSelector:@selector(pontusTurnOnBluetoothWithAccessories:)]) {
            [_delegate pontusTurnOnBluetoothWithAccessories:false];
        }
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (!self.isSearching) {
                self.isSearching = YES;
                [ble findBLEPeripherals:MAXIMUM_SEARCH];
            }
            [self handleDataSearchWithTimeout:TIME_WAITING]; // time get list data
        });
        
    }
}

- (BOOL)isBLEOff{
    return ble.CM.state == CBManagerStateUnknown || ble.CM.state == CBManagerStatePoweredOff;
}

- (void)handleDataSearchWithTimeout:(int)timeOut{
    NSLog(@"%s",__func__);

    dispatch_queue_t queue = dispatch_queue_create("com.hud.search.getlistdevice", DISPATCH_QUEUE_SERIAL);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeOut * NSEC_PER_SEC)), queue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.isStopSearch) {
                NSMutableArray * listDevice = [service getListDevice:ble];
                [self onHandleWithListDevice:listDevice andBle:ble];
            }
            
        });
    });
}

- (void)hudStopScan{
    NSLog(@"%s",__func__);

    self.isStopSearch = NO;
    self.isSearching = NO;
    [ble stopScans];
}

- (void)onSendCommandWithValue:(NSData *)data{
    _isNotCheckReceivedData = false;
    [protocolM sendCommandWithValue:data];
    
}

- (void)onHandleWithListDevice:(NSArray *)list andBle:(BLE *)_ble{
    NSLog(@"%s",__func__);
    [self hudStopScan];
    if ([_delegate respondsToSelector:@selector(pontusHudDidReceiveListDevice:)]) {
        [_delegate pontusHudDidReceiveListDevice:list];
    }
}

- (void)hudConnect:(int)timeOut{
    _connectTimeout = timeOut;
    
    [self hudConnect];
}

- (void)hudConnect{
    isReconnection = true;
    if ([self isBLEOff]) {
        if ([_delegate respondsToSelector:@selector(pontusTurnOnBluetoothWithAccessories:)]) {
            [_delegate pontusTurnOnBluetoothWithAccessories:false];
        }
    }else{
        if (![self isConnected]) {
            NSLog(@"%s",__func__);
            NSLog(@"%@",self.hudSettings.cbPeripheral);
            
            if (self.hudSettings.cbPeripheral){
                NSLog(@"cbPeripheral");
                [ble connectPeripheral:self.hudSettings.cbPeripheral];
                if (_connectTimeout > 0) {
                    NSLog(@"start timeout");
                    self.timeOutConnection = [NSTimer scheduledTimerWithTimeInterval:_connectTimeout target:self selector:@selector(connectionTimeout) userInfo:nil repeats:NO];
                }
                
            }else{
                self.timeOutConnection = [NSTimer scheduledTimerWithTimeInterval:_connectTimeout target:self selector:@selector(connectionTimeout) userInfo:nil repeats:NO];
                //            // in case mappy
                //            NSArray *listDeviceConnected = [ble listDevicePairPhone];
                //            if (listDeviceConnected.count > 0) {
                //                for (CBPeripheral * retryCBPeripheral in listDeviceConnected) {
                //                    [ble connectPeripheral:retryCBPeripheral];
                //                    self.timeOutConnection = [NSTimer scheduledTimerWithTimeInterval:TIME_OUT_CONNECTION target:self selector:@selector(hudReconnection) userInfo:nil repeats:NO];
                //                    break;
                //                }
                //            }else{
                //                // recheck the list BLE connected in the iphone
                //               // [self performSelector:@selector(hudConnect) withObject:nil afterDelay:2.0];
                //            }
                //
                
            }
            
        }
    }
    
}

- (void)hudDidDisConnectWithIsReconnect:(BOOL)isReconnect{
    NSLog(@"hudDidDisConnectWithIsReconnect");

    isReconnection = isReconnect;
    [ble cancelConnect];
}

- (void)hudReconnection{
    [self.timeOutConnection invalidate];
    self.timeOutConnection = nil;
    if (self.hudSettings && isReconnection) {
        [self hudConnect];
    }
}

- (void)connectionTimeout{
    NSLog(@"connectionTimeout");

    NSLog(@"end timeout");
    if ([self isConnected]) {
        [ble cancelConnect];
    }else{
//        [ble cancelConnect];
        [self bleDidDisconnect];
    }
}

- (void)resetTimeout{
    if (self.timeOutConnection) {
        NSLog(@"%@ - resetTimeout", App);

        [self.timeOutConnection invalidate];
        self.timeOutConnection = nil;
    }
    _connectTimeout = 0;
}

#pragma mark - BLEDelegate

- (void)bleDidConnect{
    NSLog(@"%@ - bleDidConnect", App);
    isReconnection = true;
    protocolM.isUnSubmit = false;
    [self resetTimeout];

    if ([_delegate respondsToSelector:@selector(pontusHudDidUpdateConnection:andIsTimeOut:)]) {
        [_delegate pontusHudDidUpdateConnection:true andIsTimeOut:false];
    }
}


- (void)bleDidDisconnect{
    NSLog(@"%@ - bleDidDisconnect", App);
    isStartMappy = false;

    if ([_delegate respondsToSelector:@selector(pontusHudDidUpdateConnection:andIsTimeOut:)]) {
        if (_connectTimeout > 0) {
            [_delegate pontusHudDidUpdateConnection:false andIsTimeOut:true];
        }else{
            [_delegate pontusHudDidUpdateConnection:false andIsTimeOut:false];
        }
    }
    
    [self resetTimeout];
    
//    [self hudReconnection];
}

- (void)turnOnBluetoothWithAccessories:(BOOL)ret{
    [self hudStopScan];
    if ([_delegate respondsToSelector:@selector(pontusTurnOnBluetoothWithAccessories:)]) {
        [_delegate pontusTurnOnBluetoothWithAccessories:ret];
    }
}

- (void)notificationDidUpdateData:(NSData *)data{
    
    if (data.length > 0) {
//        Byte timePayload[34] = {0x21,0x7e,0x05,0x0e ,0x00,0x01,0x03,0x05 ,0x00,0x01,0x08,0x00, 0x47,0x00,0x26,0xff,0xff,0xff,0x2e,0x2f ,0x21,0x7e,0x23,0x08 ,0x07,0x07,0x63,0x22 ,0x00,0x63,0x00,0x63 ,0x23,0x2f};
//        data = [NSData dataWithBytes:timePayload length:sizeof(timePayload)];
        if (_isNotCheckReceivedData) {
            [protocolM.bleData receiveDataBLE:data];
            if ([_delegate respondsToSelector:@selector(pontusHudNotificationDidUpdateData:)]) {
                [_delegate pontusHudNotificationDidUpdateData:data];
            }
        }else{
            NSData *missData = [self handleMissedData:data];
            if (missData) {
                NSMutableArray *datas = [self handleConjoinedData:missData];
                [self removeMissedData];
                for (NSData *dt in datas) {
                    [protocolM.bleData receiveDataBLE:dt];
                    // [self checkUnSubmitData];
                    if ([_delegate respondsToSelector:@selector(pontusHudNotificationDidUpdateData:)]) {
                        [_delegate pontusHudNotificationDidUpdateData:missData];
                    }
                    
                }

            }

        }
       
    }
}

- (void)removeMissedData{
    if (missedData.length > 0) {
        [missedData replaceBytesInRange:NSMakeRange(0, missedData.length) withBytes:NULL length:0]; //remove all
    }
}

- (NSData *)handleMissedData:(NSData *)data{
    BOOL isAvailable = [self isDataAvailable:data];
    if (isAvailable && [missedData length] == 0) {
        NSLog(@"isAvailable ok");

        return data;
    }else{
        NSLog(@"isAvailable fail");

        if ([missedData length] == 0) {
            [missedData appendData:data];
            NSLog(@"missedData : %@",missedData);
            return nil;
        }else{
            [missedData appendData:data];
            NSLog(@"missedData : %@",missedData);
            return [missedData mutableCopy];

        }
        
    }
}

- (NSMutableArray *)handleConjoinedData:(NSData *)data{
    if (data.length > 7) {
        // just test
    }
    int bytesLenght = 2;
    Byte bytes[2] = {HEADER, ID};
    NSData *sepdata = [NSData dataWithBytes:bytes length:bytesLenght];
    NSMutableArray *chunks = [[NSMutableArray alloc] init];
    NSRange searchRange = NSMakeRange(0, data.length);
    NSRange foundRange = [data rangeOfData:sepdata options:1 range:searchRange];
    while (foundRange.location != NSNotFound) {
        if (foundRange.location > searchRange.location) {
            // Append chunk (if not empty):

            NSData *subData = [data subdataWithRange:NSMakeRange(searchRange.location, (foundRange.location - searchRange.location))];
            if ([self isDataAvailable:data]) {
                [chunks addObject:subData];
            }
            
        }
        
        // Search next occurrence of separator:
        searchRange.location = (foundRange.location + foundRange.length);
        searchRange.length = data.length - searchRange.location;
        foundRange = [data rangeOfData:sepdata options:0 range:searchRange];

    }

    // Check for final chunk:
    if (searchRange.length > 0) {
        if (searchRange.location > 0 && searchRange.length > 0) {
            searchRange.location = searchRange.location - bytesLenght;
            searchRange.length = searchRange.length + bytesLenght;
            NSData *subData = [data subdataWithRange:searchRange];
            if ([self isDataAvailable:data]) {
                [chunks addObject:subData];
            }
        }

    }
    return chunks;
}

- (BOOL)isDataAvailable:(NSData *)data{
    unsigned char idChar = {ID};
    unsigned char headerChar = {HEADER};
    unsigned char tailChar = {TAIL};
    
    Byte *bytes = (Byte *)[data bytes];
    if (data.length > LENGTH_POSSITION) {
        int length =  (int)(bytes[LENGTH_POSSITION] & 0xFF); //length value of payload
        int startPayloadPostion = LENGTH_POSSITION+1; // + 1 because with-out lehght value possitio
       
        NSRange payLoadRange = NSMakeRange(0, data.length);
        NSRange range = NSMakeRange(startPayloadPostion, length);

        if ((NSEqualRanges(NSIntersectionRange(payLoadRange, range), range) && length < data.length) || length == 0) {
            //safe
            if (length == 0) {
                return true;
            }
            
            NSData *payload = [data subdataWithRange:NSMakeRange(startPayloadPostion, length)];
            int tailIndex = (int)data.length - 1 ; //  the last index
            return bytes[HEADER_POSSITION]  == headerChar && bytes[ID_POSSITION] == idChar && bytes[tailIndex] == tailChar && payload.length > 0;
        }
    }
    
    return false;
    
}
@end
