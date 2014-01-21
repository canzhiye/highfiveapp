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
#import <FacebookSDK/FacebookSDK.h>

@interface HighFiveFirstViewController : UIViewController <NSURLConnectionDelegate, CLLocationManagerDelegate, FBLoginViewDelegate, UIAlertViewDelegate>
{
    NSString *screenName;
    NSString *userID;
    
    NSString *weatherString;

    NSString *receivedScreenName;
    NSString *receivedUserID;
    
    UILabel *usernameLabel;
    UIImageView *profilePicImageView;
    UIImageView *profilePicCirlceImageView;
    UIImageView *backgroundImageView;

    CLLocationManager *locationManager;
    
    NSArray *accountsArray;
    
    BOOL shouldContact;
    
    int indexOfAccount;
    
    NSString *customIntroMessage;
    
    NSString *uniqueID;
    
    NSMutableArray *likesArray;
    
    NSString *facebookID;
    NSString *facebookUsername;
    
    NSString *receivedFacebookID;
    NSString *receivedFacebookUsername;
    BOOL tweetPosted;
    
    BOOL canRequest;
}
@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet UIImageView *profilePicImageView;
@property (nonatomic, retain) IBOutlet UIImageView *profilePicCirlceImageView;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (nonatomic, retain) ACAccount *theAccount;

@property (nonatomic, retain) NSString *customIntroMessage;

-(void)setAccountIndex:(int)index;

@end
