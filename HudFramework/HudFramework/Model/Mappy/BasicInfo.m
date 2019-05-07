//
//  BasicInfo.m
//  HudFramework
//
//  Created by Mr.Robo on 11/5/18.
//  Copyright © 2018 HudFramework. All rights reserved.
//

#import "BasicInfo.h"

@implementation BasicInfo
- (instancetype)initReaminTime:(int)remainTime andRemainDist:(int)remainDist andSpeed:(int)speed andRegCode:(int)regMode andIsRoute:(BOOL)isRoute{
    self = [super init];
    if (self) {
        _remainTime = remainTime;
        _remainDist = remainDist;
        _speed = speed;
        _regMode = regMode;
        _isRoute = isRoute;
    }
    return self;
}

@end
