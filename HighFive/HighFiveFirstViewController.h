//
//  HighFiveFirstViewController.h
//  HighFive
//
//  Created by Canzhi Ye on 1/17/14.
//  Copyright (c) 2014 Canzhi Ye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <Accounts/Accounts.h>
#import <CoreLocation/CoreLocation.h>

@interface HighFiveFirstViewController : UIViewController <NSURLConnectionDelegate, CLLocationManagerDelegate>
{
    NSString *screenName;
    NSString *userID;
    
    NSString *weatherString;

    NSString *receivedScreenName;
    
    UILabel *usernameLabel;
    UIImageView *profilePicImageView;
    
    CLLocationManager *locationManager;
}
@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet UIImageView *profilePicImageView;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (nonatomic, retain) ACAccount *theAccount;

@end
