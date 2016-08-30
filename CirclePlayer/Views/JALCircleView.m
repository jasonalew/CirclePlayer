//
//  JALCircleView.m
//  CirclePlayer
//
//  Created by Jason Lew on 8/27/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

#import "JALCircleView.h"
#import "UIColor+JALCustom.h"
#import "JALPoint.h"
#import "JALConstants.h"

@interface JALCircleView()

@property (nonatomic) CGFloat radius;
@property (nonatomic) int numPoints;

@end

@implementation JALCircleView

static CGFloat const minLimit = 1.0e-5;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}
- (void)setup {
    self.circleShape = [[CAShapeLayer alloc]init];
    self.fillColor = [UIColor whiteColor];
    self.strokeColor = [UIColor jal_ltOrange];
    self.lineWidth = kLineWidth;
    self.radius = CGRectGetWidth(self.frame)/2.0;
    self.numPoints = kNumPoints;
    [self makeCirclePath];
    self.userInteractionEnabled = NO;
}

- (void)makeCirclePath {
    self.points = [self makePoints];
    self.circleShape.path = [[self smoothPathWithPoints:self.points]CGPath];
    [self.layer addSublayer:_circleShape];
}

- (NSMutableArray *)makePoints {
    NSMutableArray *points = [[NSMutableArray alloc]init];
    CGFloat offset = -90; // Start the stroke at the top
    CGFloat angle = 360 / self.numPoints;
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    for (int i = 0; i < self.numPoints; i++) {
        CGPoint point = [JALPoint pointOnCircleWithCenter:center
                                                   radius:self.radius
                                                    angle:angle * i
                                                   offset:offset];
        [points addObject:[NSValue valueWithCGPoint:point]];
    }
    return points;
}

- (UIBezierPath *)smoothPathWithPoints:(NSArray *) points {
    // Shout out to John Fisher for the basis of the code for this function
    // https://spin.atomicobject.com/2014/05/28/ios-interpolating-points/
    if (points.count < 4) { return nil; };
    int startIndex = 0;
    CGFloat alpha = 1;
    
    UIBezierPath *path = [[UIBezierPath alloc]init];
    for (int i = startIndex; i < points.count; i++) {
        CGPoint p0 = [points[i - 1 < 0 ? points.count - 1 : i -1]CGPointValue];
        CGPoint p1 = [points[i]CGPointValue];
        CGPoint p2 = [points[(i + 1) % points.count]CGPointValue];
        CGPoint p3 = [points[(i + 2) % points.count]CGPointValue];
        
        CGFloat d1 = [JALPoint pointLength:[JALPoint subtract:p1 point2:p2]];
        CGFloat d2 = [JALPoint pointLength:[JALPoint subtract:p2 point2:p1]];
        CGFloat d3 = [JALPoint pointLength:[JALPoint subtract:p3 point2:p2]];
        
        CGPoint c1;
        CGPoint c2;
        
        if (fabs(d1) < minLimit) {
            c1 = p1;
        } else {
            c1 = [JALPoint multiply:p2 value:pow(d1, 2 * alpha)];
            c1 = [JALPoint subtract:c1 point2:[JALPoint multiply:p0 value:pow(d2, 2 * alpha)]];
            c1 = [JALPoint add:c1
                        point2:[JALPoint multiply:p1
                                            value:(2 * pow(d1, 2 * alpha) +
                                                   (3 * pow(d1, alpha) * pow(d2, alpha)) +
                                                   pow(d2, 2 * alpha))]];
            c1 = [JALPoint multiply:c1 value:1.0 / (3 * pow(d1, alpha) * (pow(d1, alpha) + pow(d2, alpha)))];
        }
        
        if (fabs(d3) < minLimit) {
            c2 = p2;
        } else {
            c2 = [JALPoint multiply:p1 value:pow(d3, 2 * alpha)];
            c2 = [JALPoint subtract:c2 point2:[JALPoint multiply:p3 value:pow(d2, 2 * alpha)]];
            c2 = [JALPoint add:c2 point2:[JALPoint multiply:p2 value:(2 * pow(d3, 2 * alpha) +
                      (3 * pow(d3, alpha) * pow(d2, alpha)) + pow(d2, 2 * alpha))]];
            c2 = [JALPoint multiply:c2 value:1.0 / (3 * pow(d3, alpha) * (pow(d3, alpha) + pow(d2, alpha)))];
        }
        
        if (i == startIndex) {
            [path moveToPoint:p1];
        }
        [path addCurveToPoint:p2 controlPoint1:c1 controlPoint2:c2];
    }
    [path closePath];
    return path;
}

#pragma mark - Setters
- (void)setFillColor:(UIColor *)fillColor {
    self.circleShape.fillColor = fillColor.CGColor;
}

- (void)setStrokeColor:(UIColor *)strokeColor {
    self.circleShape.strokeColor = strokeColor.CGColor;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    self.circleShape.lineWidth = lineWidth;
}

@end
