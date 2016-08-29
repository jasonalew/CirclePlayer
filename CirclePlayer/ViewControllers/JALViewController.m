//
//  JALViewController.m
//  CirclePlayer
//
//  Created by Jason Lew on 8/27/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

#import "JALViewController.h"
#import "JALCircleView.h"
#import "UIColor+JALCustom.h"
#import "JALBasePoint.h"
#import "JALPoint.h"

static CGFloat const radius = 56;
static CGFloat const randomRadiusLimit = 7;
static double const animationDuration = 3;

@interface JALViewController ()

@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic) NSTimeInterval animateStartTime;
@property (nonatomic, strong) JALCircleView *circleView;

@end

@implementation JALViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor jal_orange];
    self.animateStartTime = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGRect circleRect = CGRectMake(CGRectGetMidX(self.view.frame) - radius,
                                   CGRectGetMidY(self.view.frame) - radius,
                                   radius * 2.0,
                                   radius * 2.0);
    self.circleView = [[JALCircleView alloc]initWithFrame:circleRect];
    [self.view addSubview:self.circleView];
    [self loadPoints:self.circleView.points];
    [self startDisplayLink];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)loadPoints:(NSArray *)points {
    if (self.points == nil) {
        self.points = [[NSMutableArray alloc]init];
    }
    for (int i = 0; i < points.count; i++) {
        CGPoint point = [points[i] CGPointValue];
        JALBasePoint *basePoint = [[JALBasePoint alloc]init];
        basePoint.basePoint = point;
        basePoint.currentPoint = point;
        [self.points addObject:basePoint];
    }
}

# pragma mark - Animation
- (void)updateCircle:(CADisplayLink *)sender {
    if (self.animateStartTime == 0 || CACurrentMediaTime() - animationDuration >= self.animateStartTime) {
        self.animateStartTime = CACurrentMediaTime();
        [self makeDestinationPoints];
    }
    NSMutableArray *newPoints = [[NSMutableArray alloc]init];
    for (JALBasePoint *point in self.points) {
        point.currentPoint = [JALPoint add:point.currentPoint point2:point.incrementBy];
        [newPoints addObject:[NSValue valueWithCGPoint:point.currentPoint]];
    }
    
    self.circleView.circleShape.path = [[self.circleView smoothPathWithPoints:newPoints]CGPath];
    newPoints = nil;
    
}

- (CGPoint)findIncrementForBasePoint:(CGPoint)basePoint toDestinationPoint:(CGPoint)destinationPoint withDuration:(NSTimeInterval)duration {
    CGPoint diff = [JALPoint subtract:destinationPoint point2:basePoint];
    CGFloat x = diff.x / (duration * 60); // CADisplayLink refresh = 60
    CGFloat y = diff.y / (duration * 60);
    return CGPointMake(x, y);
}

- (void)makeDestinationPoints {
    for (JALBasePoint *point in self.points) {
        point.destinationPoint = [JALPoint randomPointInCircleWithCenter:point.basePoint radius:randomRadiusLimit];
        point.incrementBy = [self findIncrementForBasePoint:point.currentPoint toDestinationPoint:point.destinationPoint withDuration:animationDuration];
    }
}

- (void)startDisplayLink {
    if (self.displayLink == nil) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateCircle:)];
    }
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)pauseDisplayLink:(BOOL)pause {
    self.displayLink.paused = pause;
}

- (void)stopDisplayLink {
    [self.displayLink invalidate];
    self.displayLink = nil;
}

@end
