# BLE-Connection iOS

## Features
- This BLE SDK for iOS provides a framework for iOS developers to develop Bluetooth 4.0 Low Energy (aka BLE) Apps easily using a simeple TXRX Service for exchanging data. It is based on Apple's CoreBluetooth framework.

- Search Device with service UUID define in the app
- Connection to any device support BLE 4.0 above
- Transmit data and receive data from device BLE
- The app look for the peripherals, connect to one and then look for the services and characteristics.
![a](https://user-images.githubusercontent.com/15991780/57281368-0e31cb00-70d5-11e9-9012-b55e5cdb40a4.png)

## Support
- For iOS devices, only device support BLE 4.0 above.
- iOS Deployment target 10.0 and above
- Support Swift and Objective-C

## Edit Service and Characteric UUID
- Check BLEDefines.h

## How to extract to framework
- Select HUD-Universal target and run
<img width="1149" alt="Screen Shot 2019-05-07 at 2 34 26 PM" src="https://user-images.githubusercontent.com/15991780/57281594-81d3d800-70d5-11e9-9fb5-fab2ab73eb81.png">

- After the xcode auto generate a HudFramework.framework in root project folder
<img width="551" alt="Screen Shot 2019-05-07 at 2 37 32 PM" src="https://user-images.githubusercontent.com/15991780/57281686-ac259580-70d5-11e9-9168-e49f93c35cb7.png">

## Installation
---- Manual ----
- Just drag the HudFramework.framework to your project.
- Import the HudFramework module to class you want to use.

## Example
    #import "ViewController.h"
    #import <HudFramework/PontusHUDManager.h>

    @interface ViewController ()<PontusHUDManagerDelegate>

    @end

    @implementation ViewController{
     PontusHUDSettings *settings;
    }

    - (void)viewDidLoad {
        [super viewDidLoad];
        // Do any additional setup after loading the view, typically from a nib.
        settings = [[PontusHUDSettings alloc] init];
        [[PontusHUDManager sharedInstance] setDelegate:self];
        [[PontusHUDManager sharedInstance] hudStartScaningDevices];
    }


    #pragma mark - HUDManagerDelegate
    - (void)pontusHudDidUpdateConnection:(BOOL)connected andIsTimeOut:(BOOL)isTimeout{
        if (connected) {
            printf("connected");
            //TEST REQUEST SETUP VALUE
            //217e060b 03610d00 00000001 0078019b 2f

            Byte timePayload[7] = {0x21,0x7E,0x10, 0x01,0x0,0xb0,0x2f};
            NSData *dataToSend = [NSData dataWithBytes:timePayload length:sizeof(timePayload)];
            NSLog(@"Send time sync %@",dataToSend);
            [PontusHUDManager.sharedInstance onSendCommandWithValue:dataToSend];

            //TEST REQUEST VERSION
            //        Byte timePayload[9] = {0x21,0x7E,0x04,0x03,0x01,0x00,0x28,0xCF,0x2F};
            //        NSData *dataToSend = [NSData dataWithBytes:timePayload length:sizeof(timePayload)];
            //        NSLog(@"Send time sync %@",dataToSend);
            //        [PontusHUDManager.sharedInstance.protocolM sendCommandWithValue:dataToSend];

        }else{
            printf("disconnected");
        }
    }

    - (void)pontusHudNotificationDidUpdateData:(NSData *)data{
        NSLog(@"%@",data);
    }

    - (void)pontusHudDidReceiveListDevice:(NSArray *)listDevice{
        settings.cbPeripheral = listDevice.firstObject;
        [[PontusHUDManager sharedInstance] hudSetupWithSetting:settings];
        [[PontusHUDManager sharedInstance] hudConnect];

    }


## Demo
There is a demo project added to this repository, so you can see how it works.

## License
Copyright (c) 2019 COVISOFT INCOPORATION

Author : mrrobo1510

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
