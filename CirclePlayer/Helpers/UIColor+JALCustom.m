//
//  UIColor+JALCustom.m
//  CirclePlayer
//
//  Created by Jason Lew on 8/28/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

#import "UIColor+JALCustom.h"

@implementation UIColor (JALCustom)

+ (UIColor *)jal_orange {
    return [UIColor colorWithHue:0.12 saturation:0.75 brightness:0.9 alpha:1.0];
}

+ (UIColor *)jal_ltOrange {
    return [UIColor colorWithHue:0.12 saturation:0.6 brightness:0.9 alpha:1.0];
}

+ (UIColor *)jal_yellow {
    return [UIColor colorWithHue:0.1 saturation:0.8 brightness:0.8 alpha:1.0];
}

+ (UIColor *)jal_cream {
    return [UIColor colorWithHue:0.12 saturation:0.25 brightness:1.0 alpha:1.0];
}

@end
