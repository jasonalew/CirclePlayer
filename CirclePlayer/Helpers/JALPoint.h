//
//  JALPoint.h
//  CirclePlayer
//
//  Created by Jason Lew on 8/28/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JALPoint : NSObject

+ (CGFloat)dotProduct:(CGPoint)point1 point2:(CGPoint)point2;
+ (CGFloat)squareLength:(CGPoint) point;
+ (CGFloat)pointLength:(CGPoint) point;
+ (CGPoint)add:(CGPoint) point1 point2:(CGPoint) point2;
+ (CGPoint)subtract:(CGPoint) point1 point2:(CGPoint) point2;
+ (CGPoint)multiply:(CGPoint) point1 value: (CGFloat) value;
+ (CGPoint)pointOnCircleWithCenter:(CGPoint) center radius:(CGFloat) radius angle:(CGFloat) angle offset:(CGFloat) offset;
+ (CGFloat)degreesToRadians:(CGFloat) degrees;

@end
