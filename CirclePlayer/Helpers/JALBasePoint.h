//
//  JALBasePoint.h
//  CirclePlayer
//
//  Created by Jason Lew on 8/28/16.
//  Copyright © 2016 Jason Lew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JALBasePoint : NSObject
@property (nonatomic) CGPoint basePoint;
@property (nonatomic) CGPoint destinationPoint;
@property (nonatomic) CGPoint currentPoint;
@property (nonatomic) CGPoint incrementBy;
@end
