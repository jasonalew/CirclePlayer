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

static CGFloat const radius = 40;

@interface JALViewController ()

@property (nonatomic, strong) NSMutableArray *points;

@end

@implementation JALViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor jal_ltOrange];
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
    JALCircleView *circleView = [[JALCircleView alloc]initWithFrame:circleRect];
    [self.view addSubview:circleView];
    [self loadPoints:circleView.points];
}

- (void)loadPoints:(NSArray *)points {
    if (self.points == nil) {
        self.points = [[NSMutableArray alloc]init];
    }
    for (NSValue *point in points) {
        JALBasePoint *basePoint = [[JALBasePoint alloc]init];
        basePoint.basePoint = [point CGPointValue];
        [self.points addObject:basePoint];
    }
}

@end
