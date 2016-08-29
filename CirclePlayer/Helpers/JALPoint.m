//
//  JALPoint.m
//  CirclePlayer
//
//  Created by Jason Lew on 8/28/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

#import "JALPoint.h"

@implementation JALPoint

+ (CGFloat)dotProduct:(CGPoint)point1 point2:(CGPoint)point2 {
    return point1.x * point2.x + point1.y * point2.y;
}

+ (CGFloat)squareLength:(CGPoint)point {
    return [JALPoint dotProduct:point point2:point];
}

+ (CGFloat)pointLength:(CGPoint)point {
    return sqrt([JALPoint squareLength:point]);
}

+ (CGPoint)add:(CGPoint)point1 point2:(CGPoint)point2 {
    return CGPointMake(point1.x + point2.x, point1.y + point2.y);
}

+ (CGPoint)subtract:(CGPoint)point1 point2:(CGPoint)point2 {
    return CGPointMake(point1.x - point2.x, point1.y - point2.y);
}

+ (CGPoint)multiply:(CGPoint)point1 value:(CGFloat)value {
    return CGPointMake(point1.x * value, point1.y * value);
}

+ (CGPoint)pointOnCircleWithCenter:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle offset:(CGFloat)offset {
    CGFloat x = center.x + radius * cos([JALPoint degreesToRadians:angle + offset]);
    CGFloat y = center.y + radius * sin([JALPoint degreesToRadians:angle + offset]);
    return CGPointMake(x, y);
}

+ (CGPoint)randomPointInCircleWithCenter:(CGPoint)center radius:(CGFloat)radius {
    // Get random angle for point on circle
    CGFloat randomAngle = arc4random_uniform(361);
    // Get random value limited by radius
    CGFloat randomRadius = arc4random_uniform((int)radius - 1) + 1;
    return [JALPoint pointOnCircleWithCenter:center radius:randomRadius angle:randomAngle offset:0];
}

+ (CGFloat)degreesToRadians:(CGFloat)degrees {
    return degrees * M_PI / 180;
}

@end
