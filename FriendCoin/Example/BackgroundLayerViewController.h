//
//  BackgroundLayerViewController.h
//  FriendCoin
//
//  Created by Tyler Phelps on 7/27/13.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface BackgroundLayer : NSObject

+(CAGradientLayer*) greyGradient;
+(CAGradientLayer*) blueGradient;

@end