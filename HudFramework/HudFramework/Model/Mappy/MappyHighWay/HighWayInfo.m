//
//  HighWayInfo.m
//  HudFramework
//
//  Created by Mr.Robo on 11/6/18.
//  Copyright © 2018 HudFramework. All rights reserved.
//

#import "HighWayInfo.h"

@implementation HighWayInfo
- (instancetype)initReaminDist:(int)remainDist andFee:(int)fee andSpeed:(int)speed{
    self = [super init];
    if (self) {
        _remainDist = remainDist;
        _fee = fee;
        _speed = speed;
    }
    
    return self;
}
@end
