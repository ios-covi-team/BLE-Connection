//
//  HighWayInfo.h
//  HudFramework
//
//  Created by Mr.Robo on 11/6/18.
//  Copyright © 2018 HudFramework. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HighWayInfo : NSObject
@property (nonatomic, assign) int remainDist;
@property (nonatomic, assign) int fee;
@property (nonatomic, assign) int speed;
- (instancetype)initReaminDist:(int)remainDist andFee:(int)fee andSpeed:(int)speed;

@end

NS_ASSUME_NONNULL_END
