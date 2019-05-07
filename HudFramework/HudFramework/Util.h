//
//  Util.h
//  HudFramework
//
//  Created by Mr.Robo on 11/5/18.
//  Copyright © 2018 HudFramework. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Util : NSObject
+ (UInt16)sumCRCWithData:(NSData *)data;
+ (NSInteger)estimateTimeWithRemainTime:(NSInteger)second;
+ (NSString *)getTimeFormatWithDate:(NSDate *)date;
+ (NSDateComponents *)getDateComponentsWithDate:(NSDate *)date;
+ (NSMutableDictionary*)dictionaryFromUrlParram:(NSString*)urlPararm;
@end

NS_ASSUME_NONNULL_END
