//
//  ViewController.m
//  TestHudFrameWork
//
//  Created by Mr.Robo on 11/2/18.
//  Copyright © 2018 HudFramework. All rights reserved.
//

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
- (void)pontusHudDidReceiveListDevice:(NSArray *)listDevice{
//    settings.cbPeripheral = listDevice.firstObject;
//    [[PontusHUDManager sharedInstance] hudSetupWithSetting:settings];
//    [[PontusHUDManager sharedInstance] hudConnect];

}


@end
