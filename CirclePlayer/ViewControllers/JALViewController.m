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

static CGFloat const radius = 40;

@interface JALViewController ()

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
    
    CGRect circleRect = CGRectMake(self.view.center.x - radius , self.view.center.y - radius, radius * 2.0, radius * 2.0);
    JALCircleView *circleView = [[JALCircleView alloc]initWithFrame:circleRect];
    [self.view addSubview:circleView];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
