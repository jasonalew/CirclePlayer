//
//  JALCircleView.h
//  CirclePlayer
//
//  Created by Jason Lew on 8/27/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JALCircleView : UIView
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic, strong) NSArray *points;

@end
