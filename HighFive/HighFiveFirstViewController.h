//
//  HighFiveFirstViewController.h
//  HighFive
//
//  Created by Canzhi Ye on 1/17/14.
//  Copyright (c) 2014 Canzhi Ye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface HighFiveFirstViewController : UIViewController <NSURLConnectionDelegate>
{
    NSString *screenName;
    NSString *userID;
    
    UILabel *usernameLabel;
    UIImageView *profilePicImageView;
}
@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet UIImageView *profilePicImageView;
@property (strong, nonatomic) CMMotionManager *motionManager;

@end
