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
#import "JALConstants.h"

static CGFloat const radius = 56;
static CGFloat const randomRadiusLimit = 6;
static double const animationDuration = 2.5;

@interface JALViewController ()

@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic) NSTimeInterval animateStartTime;
@property (nonatomic, strong) JALCircleView *circleView;
@property (nonatomic, strong) JALCircleView *progressCircleView;
@property (nonatomic, strong) JALCircleView *centerCircle;
@property (nonatomic) BOOL shouldReset;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) AVAudioPlayer * audioPlayer;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation JALViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor jal_orange];
    self.animateStartTime = 0;
    
    // Add the circle view
    [self setupCircleViews];
    [self setupPlayButton];
    [self setupAudioPlayer];
    self.shouldReset = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showCircleView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopDisplayLink];
    [self cancelTimer];
}

#pragma mark - Setup

- (void)setupPlayButton {
    // Make sure the play button is on top
    self.playButton.layer.zPosition = 1000;
    
    [self.playButton setTintColor:[UIColor jal_orange]];
}

- (void)loadPoints:(NSArray *)points {
    if (self.points == nil) {
        self.points = [[NSMutableArray alloc]init];
    }
    // Get the points from the circleView and add it to the JALBasePoint instance
    // to create reference points.
    for (int i = 0; i < points.count; i++) {
        CGPoint point = [points[i] CGPointValue];
        JALBasePoint *basePoint = [[JALBasePoint alloc]init];
        basePoint.basePoint = point;
        basePoint.currentPoint = point;
        [self.points addObject:basePoint];
    }
}

- (void) setupCircleViews {
    CGRect circleRect = CGRectMake(CGRectGetMidX(self.view.frame) - radius,
                                   CGRectGetMidY(self.view.frame) - radius,
                                   radius * 2.0,
                                   radius * 2.0);
    self.circleView = [[JALCircleView alloc]initWithFrame:circleRect];
    [self scaleView:self.circleView withScale:0.5];
    [self.view addSubview:self.circleView];
    
    CGRect centerRect = CGRectMake(CGRectGetMidX(self.view.frame) - radius + kLineWidth/2,
                                   CGRectGetMidY(self.view.frame) - radius + kLineWidth/2,
                                   radius * 2.0 - kLineWidth,
                                   radius * 2.0 - kLineWidth);
    self.centerCircle = [[JALCircleView alloc]initWithFrame:centerRect];
    self.centerCircle.strokeColor = [UIColor clearColor];
    [self.view addSubview:self.centerCircle];
    
    self.progressCircleView = [[JALCircleView alloc]initWithFrame:circleRect];
    self.progressCircleView.circleShape.fillColor = [[UIColor clearColor]CGColor];
    self.progressCircleView.circleShape.strokeColor = [[UIColor jal_cream]CGColor];
    self.progressCircleView.circleShape.strokeEnd = 0;
    [self.view addSubview:self.progressCircleView];
    
    [self loadPoints:self.circleView.points];
}

#pragma mark - Actions
- (IBAction)playButtonWasTapped:(id)sender {
    if (self.audioPlayer.isPlaying) {
        [self pauseAudio];
    } else {
        [self playAudio];
    }
    [self updatePlayButtonImage];
}


#pragma mark - Animation
- (void)updateCircle:(CADisplayLink *)sender {
    if (self.animateStartTime == 0 || CACurrentMediaTime() - animationDuration >= self.animateStartTime) {
        self.animateStartTime = CACurrentMediaTime();
        if (!self.shouldReset) {
            [self makeDestinationPoints];
        } else {
            [self resetCircle];
        }
    }
    NSMutableArray *newPoints = [[NSMutableArray alloc]init];
    for (JALBasePoint *point in self.points) {
        point.currentPoint = [JALPoint add:point.currentPoint point2:point.incrementBy];
        [newPoints addObject:[NSValue valueWithCGPoint:point.currentPoint]];
    }
    
    self.circleView.circleShape.path = [[self.circleView smoothPathWithPoints:newPoints]CGPath];
    self.progressCircleView.circleShape.path = self.circleView.circleShape.path;
    newPoints = nil;
    [self updateTimeLabel];
    [self updateProgressStrokeWithTime:self.audioPlayer.currentTime
                          withDuration:self.audioPlayer.duration];
}

- (CGPoint)findIncrementForBasePoint:(CGPoint)basePoint
                  toDestinationPoint:(CGPoint)destinationPoint
                        withDuration:(NSTimeInterval)duration {
    CGPoint diff = [JALPoint subtract:destinationPoint point2:basePoint];
    CGFloat x = diff.x / (duration * 60); // CADisplayLink refresh = 60
    CGFloat y = diff.y / (duration * 60);
    return CGPointMake(x, y);
}

- (void)makeDestinationPoints {
    [self makeNewDestinationPointsWithReset:NO];
}

- (void)makeNewDestinationPointsWithReset:(BOOL)reset {
    for (JALBasePoint *point in self.points) {
        if (reset) {
            point.destinationPoint = point.basePoint;
        } else {
            point.destinationPoint = [JALPoint randomPointInCircleWithCenter:point.basePoint
                                                                      radius:randomRadiusLimit];
        }
        
        point.incrementBy = [self findIncrementForBasePoint:point.currentPoint
                                         toDestinationPoint:point.destinationPoint
                                               withDuration:animationDuration];
    }
}

- (void)resetCircle {
    [self makeNewDestinationPointsWithReset:YES];
    if (self.timer == nil) {
        self.timer = [NSTimer timerWithTimeInterval:animationDuration
                                             target:self
                                           selector:@selector(stopDisplayLink)
                                           userInfo:nil
                                            repeats:NO];
    }
}

- (void)updateTimeLabel {
    int minutes = (int)self.audioPlayer.currentTime/60;
    int seconds = (int)self.audioPlayer.currentTime % 60;
    self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

- (void)updateProgressStrokeWithTime:(NSTimeInterval)currentTime
                        withDuration:(NSTimeInterval)duration {
    CGFloat progress = currentTime/duration;
    self.progressCircleView.circleShape.strokeEnd = MIN(progress, 1.0);
}

- (void)scaleView:(UIView *)aView withScale:(CGFloat)scale {
    CGAffineTransform transform = CGAffineTransformScale(aView.transform, scale, scale);
    aView.transform = transform;
}

- (void)showCircleView {
    [UIView animateWithDuration:1.5 delay:0.5 usingSpringWithDamping:20 initialSpringVelocity:10
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.circleView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self.centerCircle removeFromSuperview];
    }];
}

#pragma mark - Display Link

- (void)startDisplayLink {
    if (self.displayLink == nil) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self
                                                       selector:@selector(updateCircle:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop]
                               forMode:NSRunLoopCommonModes];
    } else {
        [self pauseDisplayLink:NO];
    }
}

- (void)pauseDisplayLink:(BOOL)pause {
    self.displayLink.paused = pause;
}

- (void)stopDisplayLink {
    [self.displayLink invalidate];
    self.displayLink = nil;
    self.shouldReset = NO;
}

- (void)cancelTimer {
    if (self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - Audio Player
- (void)setupAudioPlayer {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"shakuhachi"
                                                                       ofType:@"mp3"]];
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
    if (error) {
        NSLog(@"Audio player error: %@", error.localizedDescription);
    } else {
        self.audioPlayer.delegate = self;
        [self.audioPlayer prepareToPlay];
    }
}

- (void)playAudio {
    [self cancelTimer];
    [self.audioPlayer play];
    [self startDisplayLink];
}

- (void)pauseAudio {
    [self.audioPlayer pause];
    [self pauseDisplayLink:YES];
}

- (void)updatePlayButtonImage {
    NSString *imageName = self.audioPlayer.isPlaying ? @"pauseButtonRound" : @"playButtonRound";
    UIImage *playImage =  [UIImage imageNamed: imageName];
    [self.playButton setImage:playImage forState:UIControlStateNormal];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    self.audioPlayer.currentTime = 0;
    [self updatePlayButtonImage];
    self.shouldReset = YES;
    self.timeLabel.text = @"0:00";
    self.progressCircleView.circleShape.strokeEnd = 0;
}

@end
