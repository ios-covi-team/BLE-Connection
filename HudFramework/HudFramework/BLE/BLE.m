

//
//  BLE.h
//  SBKApplication
//
//  Created by Covisoft Viet Nam on 6/6/16.
//  Copyright © 2016 Covisoft Viet Nam. All rights reserved.
//
#import "BLE.h"
#import "BLEDefines.h"
#define NOTIFICATION_TURN_ON_BLE @"NOTIFICATION_TURN_ON_BLE"
@implementation BLE
{
    /*! initialize a object bledata handle data from BLE device */
    BLEData *bleData;
    
    /*! initialize for check turn on or tun off bluetooth in phone */
    BOOL accessories;
    NSTimer *timerTimeOutSearch;
    BOOL isConnectting;
    
}
@synthesize delegate;
@synthesize CM;
@synthesize peripherals;
@synthesize activePeripheral;

static bool isConnected = false;
static int rssi = 0;

-(void) readRSSI
{
    [activePeripheral readRSSI];
}

-(BOOL) isConnected
{
    return isConnected;
}


#pragma mark - HANDLE DATA
// Read data from BLE device
- (instancetype)init{
    self = [super init];
    NSLog(@"Init BLE %@", self);
    
    return self;
}
-(void) read
{
    CBUUID *uuid_service = [CBUUID UUIDWithString:@RBL_SERVICE_UUID];
    CBUUID *uuid_char = [CBUUID UUIDWithString:@RBL_CHAR_R_UUID];
    
    [self readValue:uuid_service characteristicUUID:uuid_char p:activePeripheral];
}

-(void) readValue: (CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID p:(CBPeripheral *)p
{
    CBService *service = [self findServiceFromUUID:serviceUUID p:p];
    
    if (!service)
    {
        NSLog(@"Could not find service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:serviceUUID],
              p.identifier.UUIDString);
        
        return;
    }
    
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID andToUUID2:[CBUUID UUIDWithString:@RBL_CHAR_R_UUID] service:service];

    
    if (!characteristic)
    {
        NSLog(@"Could not find characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:characteristicUUID],
              [self CBUUIDToString:serviceUUID],
              p.identifier.UUIDString);
        
        return;
    }
    
    [p readValueForCharacteristic:characteristic];
}


// Write data from BLE device
-(void) write:(NSData *)d
{
    CBUUID *uuid_service = [CBUUID UUIDWithString:@RBL_SERVICE_UUID];
    CBUUID *uuid_char = [CBUUID UUIDWithString:@RBL_CHAR_W_UUID];
    
    [self writeValue:uuid_service characteristicUUID:uuid_char p:activePeripheral data:d];
}

// Write data from BLE device with data
- (void)writeWithRecivedData:(NSData*)d andBLEData:(BLEData *)bleDt{
    
    bleData = bleDt;
    CBUUID *uuid_service = [CBUUID UUIDWithString:@RBL_SERVICE_UUID];
    CBUUID *uuid_char = [CBUUID UUIDWithString:@RBL_CHAR_W_UUID];
    
    [self writeValue:uuid_service characteristicUUID:uuid_char p:activePeripheral data:d];
}
-(void) writeValue:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data
{
    CBService *service = [self findServiceFromUUID:serviceUUID p:p];
    
    if (!service)
    {
        NSLog(@"Could not find service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:serviceUUID],
              p.identifier.UUIDString);
        
        return;
    }

    
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID andToUUID2:[CBUUID UUIDWithString:@RBL_CHAR_W_UUID] service:service];

    if (!characteristic)
    {
        NSLog(@"Could not find characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:characteristicUUID],
              [self CBUUIDToString:serviceUUID],
              p.identifier.UUIDString);
        
        return;
    }
    
    [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
}

#pragma mark - NOTI
-(void) enableReadNotification:(CBPeripheral *)p
{
    CBUUID *uuid_service = [CBUUID UUIDWithString:@RBL_SERVICE_UUID];
    CBUUID *uuid_char = [CBUUID UUIDWithString:@RBL_CHAR_N_UUID];
    
    [self notification:uuid_service characteristicUUID:uuid_char p:p on:YES];
}

// Set notification
-(void) notification:(CBUUID *)serviceUUID characteristicUUID:(CBUUID *)characteristicUUID p:(CBPeripheral *)p on:(BOOL)on
{
    CBService *service = [self findServiceFromUUID:serviceUUID p:p];
    //CBService *service = [p.services objectAtIndex:0];
    if (!service)
    {
        NSLog(@"Could not find service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:serviceUUID],
              p.identifier.UUIDString);
        
        return;
    }
    
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID andToUUID2:[CBUUID UUIDWithString:@RBL_CHAR_N_UUID] service:service];
    
    if (!characteristic)
    {
        NSLog(@"Could not find characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:characteristicUUID],
              [self CBUUIDToString:serviceUUID],
              p.identifier.UUIDString);
        
        return;
    }
    
    [p setNotifyValue:on forCharacteristic:characteristic];
}


-(NSString *) CBUUIDToString:(CBUUID *) cbuuid;
{
    NSData *data = cbuuid.data;
    
    if ([data length] == 2)
    {
        const unsigned char *tokenBytes = [data bytes];
        return [NSString stringWithFormat:@"%02x%02x", tokenBytes[0], tokenBytes[1]];
    }
    else if ([data length] == 16)
    {
        NSUUID* nsuuid = [[NSUUID alloc] initWithUUIDBytes:[data bytes]];
        return [nsuuid UUIDString];
    }
    
    return [cbuuid description];
}


- (void)setNotification:(BOOL)value{
    //  [self.activePeripheral setNotifyValue:YES forCharacteristic:(nonnull CBCharacteristic *)]
}

#pragma mark - BLE CENTRAR DELEGATE (CLIENT)
// GET LIST DEVICE CONNECT WITH MY IPHONE FOR CHECK RETRYCONNECT

- (void)getListDeviceConnectingInPhone{
    // GET LIST RETRY CONNECTING
    
    NSArray *listDevice  = [self listDevicePairPhone];
    
    for (CBPeripheral * reryCBPeripheral in listDevice) {
        
        if (![self.peripherals containsObject:reryCBPeripheral]) {
            [self.peripherals addObject:reryCBPeripheral];
        }
    }
    
  
}

- (NSArray *)listDevicePairPhone{
    return [self.CM retrieveConnectedPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@RBL_SERVICE_UUID]]];
}
// INIT BLE CENTRAR
- (void) controlSetup
{
    
    if (self.peripherals.count <= 0) {
        self.peripherals = [[NSMutableArray alloc] init];
    }
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber  numberWithBool:false], CBCentralManagerOptionShowPowerAlertKey, nil];
    
    self.CM = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:options];
    
    
}


// DELEGATE DISCONNECTED WITH BLE
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
{
    NSLog(@"didDisconnectPeripheral");
//    [central cancelPeripheralConnection:peripheral];
    if (isConnected) {
        isConnected = false;
        [[self delegate] bleDidDisconnect];
    }
    
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    
    
    static int centralStatte = CBManagerStatePoweredOn;// default ON
    
    NSLog(@"Status of CoreBluetooth central manager changed %ld (%s)", (long)central.state, [self centralManagerStateToString:central.state]);
    NSLog(@"centralStatte %ld (%s)", (long)centralStatte, [self centralManagerStateToString:centralStatte]);
    NSLog(@"delegate delegate : %@", self.delegate);

    if (central.state == CBManagerStatePoweredOff || central.state == CBManagerStateUnknown) {
        isConnected = false;

        if (centralStatte == CBManagerStatePoweredOn) {
            NSLog(@"ble off");

            [self.delegate turnOnBluetoothWithAccessories:NO];
            centralStatte = CBManagerStatePoweredOff;
        }

    } else if (central.state == CBManagerStatePoweredOn){
        if (centralStatte == CBManagerStatePoweredOff) {
            NSLog(@"ble on");
            [self.delegate turnOnBluetoothWithAccessories:YES];
            centralStatte = CBManagerStatePoweredOn;
        }

    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"advertisementData");
    if (self.peripherals.count == 0) {
        [self.peripherals addObject:peripheral];
        NSLog(@"Device find first");
        
    }
    else
    {
        for(int i = 0; i < self.peripherals.count; i++)
        {
            CBPeripheral *p = [self.peripherals objectAtIndex:i];
            
            if ((p.identifier == NULL) || (peripheral.identifier == NULL))
                continue;
            
            if ([self UUIDSAreEqual:p.identifier UUID2:peripheral.identifier])
            {
                //                [self.peripherals replaceObjectAtIndex:i withObject:peripheral];
                NSLog(@"Duplicate UUID found updating...");
                return;
            }
        }
        
        
        [self.peripherals addObject:peripheral];
        
        NSLog(@"New UUID, adding");
    }
    
    [self printKnownPeripherals];
    
    NSLog(@"didDiscoverPeripheral");
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"---------%ld",(long)peripheral.state);
    
    if (peripheral.identifier != NULL)
        NSLog(@"Connected to %@ successful", peripheral.identifier.UUIDString);
    else
        NSLog(@"Connected to NULL successful");
    
    self.activePeripheral = peripheral;
    
    [self.activePeripheral discoverServices:@[[CBUUID UUIDWithString:@RBL_SERVICE_UUID]]];
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (!error)
    {
        NSLog(@"Characteristic discorvery successful");
        for (int i=0; i < service.characteristics.count; i++)
        {
            CBService *s = [peripheral.services objectAtIndex:(peripheral.services.count - 1)];
            if ([service.UUID isEqual:s.UUID])
            {
                isConnected = true;
                [self enableReadNotification:activePeripheral];
                [[self delegate] bleDidConnect];
                NSLog(@"Connected.....");
                
                break;
            }
        }
    }
    else
    {
        NSLog(@"Characteristic discorvery unsuccessful!");
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (!error)
    {
        NSLog(@"%@",characteristic.value);
        
        [[self delegate] notificationDidUpdateData:characteristic.value];
    }
    else
    {
        NSLog(@"updateValueForCharacteristic failed!");
    }
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (!isConnected)
        return;
    
    if (rssi != peripheral.RSSI.intValue)
    {
        rssi = peripheral.RSSI.intValue;
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (!error)
    {
        [self getAllCharacteristicsFromPeripheral:peripheral];
    }
    else
    {
        NSLog(@"Service discovery was unsuccessful!");
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (!error)
    {
        
    }
    else
    {
        NSLog(@"Error in setting notification state for characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@",
              [self CBUUIDToString:characteristic.UUID],
              [self CBUUIDToString:characteristic.service.UUID],
              peripheral.identifier.UUIDString);
        
        NSLog(@"Error code was %s", [[error description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
    }
}

/*
 #pragma mark - BLE PERIPHERAL DELEGATE (SERVER)
 - (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic {
 // [self sendData];
 //HANLDE SEND DATA
 }
 
 
 - (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral {
 // [self sendData];
 }
 
 - (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
 if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
 return;
 }
 
 }
 
 - (void)sendData{
 Byte dataIncommingCall[3] = {VIBRATION_LED,LED_VIBRATION_MOTOR,INCOMMING_CALL};
 NSData *dataToSend = [NSData dataWithBytes:dataIncommingCall length:sizeof(dataIncommingCall)];
 
 [self.peripheralManager updateValue:dataToSend forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
 
 }
 
 
 - (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict{
 NSLog(@"willRestoreState in ble class");
 
 }
 */
#pragma mark - BLE DELEGATE
// START CONNECTED TO PERIPHERAL (SERVER)
- (void) connectPeripheral:(CBPeripheral *)peripheral
{
    if (peripheral.state == CBPeripheralStateConnected || peripheral.state == CBPeripheralStateConnecting) {
        [self.CM cancelPeripheralConnection:peripheral];
    }
    NSLog(@"connectPeripheral:(CBPeripheral *)peripheral");

    [self cancelConnect];//cancel current
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.activePeripheral = peripheral;//
        self.activePeripheral.delegate = self;
        if (peripheral.state != CBPeripheralStateConnected) {
            NSLog(@"Connecting to peripheral with UUID : %@", peripheral.identifier.UUIDString);
            [self.CM connectPeripheral:peripheral options:nil];
        }
    });
}

- (void) cancelConnect{
    NSLog(@"cancelConnect");
    if (self.activePeripheral) {
        [self.CM cancelPeripheralConnection:self.activePeripheral];
    }
}


- (int) findBLEPeripherals:(int) timeout
{
    NSLog(@"start finding");
    /*
     if (self.CM.state != CBCentralManagerStatePoweredOn)
     {
     NSLog(@"CoreBluetooth not correctly initialized !");
     NSLog(@"State = %ld (%s)\r\n", (long)self.CM.state, [self centralManagerStateToString:self.CM.state]);
     return -1;
     }
     */
    
    timerTimeOutSearch = [NSTimer scheduledTimerWithTimeInterval:(float)timeout target:self selector:@selector(stopScans) userInfo:nil repeats:NO];
    
    [self startScans];
    return 0; // Started scanning OK !
}

- (void)startScans{
    [peripherals removeAllObjects];
    [self getListDeviceConnectingInPhone];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber  numberWithBool:false], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    
    [self.CM scanForPeripheralsWithServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:@RBL_SERVICE_UUID]] options:options]; // SEARCH  DEVICE with service FFF0 (FFF0 define by device)
    NSLog(@"scanForPeripheralsWithServices");
    
}
#pragma mark -OTHER

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals{
    NSLog(@"didRetrieveConnectedPeripherals called");
    for (CBPeripheral *a in peripherals){
        NSLog(a.name); //just log the name for now to see if it recognized it
    } //but it never ends up logging anything, and I have a BT keyboard paired/connected with the iPhone 5
}
- (const char *) centralManagerStateToString: (int)state
{
    switch(state)
    {
        case CBManagerStateUnknown:
            return "State unknown (CBCentralManagerStateUnknown)";
        case CBManagerStateResetting:
            return "State resetting (CBCentralManagerStateUnknown)";
        case CBManagerStateUnsupported:
            return "State BLE unsupported (CBCentralManagerStateResetting)";
        case CBManagerStateUnauthorized:
            return "State unauthorized (CBCentralManagerStateUnauthorized)";
        case CBManagerStatePoweredOff:
            return "State BLE powered off (CBCentralManagerStatePoweredOff)";
        case CBManagerStatePoweredOn:
            return "State powered up and ready (CBCentralManagerStatePoweredOn)";
        default:
            return "State unknown";
    }
    
    return "Unknown state";
}

- (void) stopScans
{
    [self.CM stopScan];
    [timerTimeOutSearch invalidate];
    timerTimeOutSearch =  nil;
    NSLog(@"Stopped Scanning");
    NSLog(@"Known peripherals : %lu", (unsigned long)[self.peripherals count]);
    [self printKnownPeripherals];
}

- (void) printKnownPeripherals
{
    NSLog(@"List of currently known peripherals :");
    
    for (int i = 0; i < self.peripherals.count; i++)
    {
        CBPeripheral *p = [self.peripherals objectAtIndex:i];
        
        if (p.identifier != NULL)
            NSLog(@"%d  |  %@", i, p.identifier.UUIDString);
        else
            NSLog(@"%d  |  NULL", i);
        
        [self printPeripheralInfo:p];
    }
}

- (void) printPeripheralInfo:(CBPeripheral*)peripheral
{
    NSLog(@"------------------------------------");
    NSLog(@"Peripheral Info :");
    
    if (peripheral.identifier != NULL)
        NSLog(@"UUID : %@", peripheral.identifier.UUIDString);
    else
        NSLog(@"UUID : NULL");
    
    NSLog(@"Name : %@", peripheral.name);
    NSLog(@"-------------------------------------");
}

- (BOOL) UUIDSAreEqual:(NSUUID *)UUID1 UUID2:(NSUUID *)UUID2
{
    if ([UUID1.UUIDString isEqualToString:UUID2.UUIDString])
        return TRUE;
    else
        return FALSE;
}


-(void) getAllCharacteristicsFromPeripheral:(CBPeripheral *)p
{
    for (int i=0; i < p.services.count; i++)
    {
        CBService *s = [p.services objectAtIndex:i];
        //        printf("Fetching characteristics for service with UUID : %s\r\n",[self CBUUIDToString:s.UUID]);
        [p discoverCharacteristics:nil forService:s];
    }
}

-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2
{
    char b1[16];
    char b2[16];
    [UUID1.data getBytes:b1];
    [UUID2.data getBytes:b2];
    
    if (memcmp(b1, b2, UUID1.data.length) == 0)
        return 1;
    else
        return 0;
}


-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p
{
    
    for(int i = 0; i < p.services.count; i++)
    {
        CBService *s = [p.services objectAtIndex:i];
        if ([self compareCBUUID:s.UUID UUID2:UUID] == 1)
            return s;
    }
    
    return nil; //Service not found on this peripheral
}

-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID andToUUID2:(CBUUID *) UUID2 service:(CBService*)service
{
    for(int i=0; i < service.characteristics.count; i++)
    {
        //[CBUUID UUIDWithString:@RBL_CHAR_N_UUID]
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        //if ([self compareCBUUID:c.UUID UUID2:UUID])
        if ([self compareCBUUID:c.UUID UUID2:UUID2] == 1)
            return c;
    }
    
    //    CBCharacteristic *c = [service.characteristics objectAtIndex:2];
    //    if (c != nil) {
    //        return c;
    //    }
    
    return nil; //Characteristic not found on this service
}

#if TARGET_OS_IPHONE
//-- no need for iOS
#else

// CHECK BLE Capable Hardware
- (BOOL) isLECapableHardware
{
    NSString * state = nil;
    
    switch ([CM state])
    {
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
            
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
            
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            break;
            
        case CBCentralManagerStatePoweredOn:
            return TRUE;
            
        case CBCentralManagerStateUnknown:
        default:
            return FALSE;
            
    }
    
    NSLog(@"Central manager state: %@", state);
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:state];
    [alert addButtonWithTitle:@"OK"];
    [alert setIcon:[[NSImage alloc] initWithContentsOfFile:@"AppIcon"]];
    [alert beginSheetModalForWindow:nil modalDelegate:self didEndSelector:nil contextInfo:nil];
    
    return FALSE;
}
#endif

@end
