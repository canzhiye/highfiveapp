//
//  HighFiveFirstViewController.m
//  HighFive
//
//  Created by Canzhi Ye on 1/17/14.
//  Copyright (c) 2014 Canzhi Ye. All rights reserved.
//

#import "HighFiveFirstViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface HighFiveFirstViewController ()

@property (nonatomic) ACAccountStore *accountStore;

@end

@implementation HighFiveFirstViewController
@synthesize profilePicImageView, usernameLabel;

- (id)init
{
    self = [super init];
    if (self) {
        _accountStore = [[ACAccountStore alloc] init];
    }
    return self;
}

- (BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController
            isAvailableForServiceType:SLServiceTypeTwitter];
}

- (void)fetchUserInfo:(NSString*)username
{
    // Request access to the Twitter accounts
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted) {
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            // Check if the users has setup at least one Twitter account
            if (accounts.count > 0)
            {
                ACAccount *twitterAccount = [accounts objectAtIndex:0];
                // Creating a request to get the info about a user on Twitter
                SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"] parameters:[NSDictionary dictionaryWithObject:username forKey:@"screen_name"]];
                [twitterInfoRequest setAccount:twitterAccount];
                
                // Making the request
                [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // Check if we reached the reate limit
                        if ([urlResponse statusCode] == 429) {
                            NSLog(@"Rate limit reached");
                            return;
                        }
                        // Check if there was an error
                        if (error) {
                            NSLog(@"Error: %@", error.localizedDescription);
                            return;
                        }
                        // Check if there is some response data
                        if (responseData) {
                            
                            NSError *error = nil;
                            NSDictionary *TWData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                            // Filter the preferred data
                            NSLog(@"MOTHAFUCKIN RESPONSE: %@",TWData);
                            screenName = [TWData objectForKey:@"screen_name"];
                            NSString *himothafucka = [NSString stringWithFormat:@"Hi, %@",screenName];
                            [usernameLabel setText:himothafucka];
                            
                            userID = [TWData objectForKey:@"id_str"];
                            NSString *fuckinURL = [[TWData objectForKey:@"profile_image_url"] stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
                            NSURL *profilePicURL = [NSURL URLWithString:fuckinURL];
                            profilePicImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:profilePicURL]];
                            [profilePicImageView sendSubviewToBack:profilePicImageView];
                            
                        }
                    });
                }];
            }
        } else {
            NSLog(@"No access granted");
        }
    }];
}
- (void)viewDidLoad
{
    [self fetchUserInfo:@"canzhiye"];
    
    
    
    
    
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .2;
    self.motionManager.gyroUpdateInterval = .2;
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 [self outputAccelertionData:accelerometerData.acceleration];
                                                 if(error){
                                                     
                                                     NSLog(@"%@", error);
                                                 }
                                             }];
    
//    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
//                                    withHandler:^(CMGyroData *gyroData, NSError *error) {
//                                        [self outputRotationData:gyroData.rotationRate];
//                                    }];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data
{
    //Above method is used to receive the data which we get using post method.
    NSLog(@"did Receive Data: %@", data);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //This method , you can use to receive the error report in case of connection is not made to server.
    NSLog(@"did Receive Error: %@", error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"did Finish Loading: %@", connection);

}

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
   
    if (acceleration.z > 2 /*some arbitrary threshold*/) {
        NSLog(@"z accel: %3.2f",acceleration.z);
        NSLog(@"x accel: %3.2f",acceleration.x);
        NSLog(@"y accel: %3.2f",acceleration.y);
        
        //do shit
        // SHIT TO POST
        //    "timestamp",
        //    "loc_x",
        //    "loc_y",
        //    "velocity",
        //    "uid",
        //    "twitter_id",
        NSString *timestamp = @"fuck";
        NSString *loc_x = @"you";
        NSString *loc_y = @"fuck";
        NSString *velocity = @"you";
        NSString *uid = @"fack";
        NSString *twitter_id = @"u";
        
        NSString *post = [NSString stringWithFormat:@"&timestamp=%@&loc_x=%@&loc_y=%@&velocity=%@&uid=%@&twitter_id=%@",timestamp,loc_x,loc_y,velocity,uid,twitter_id];
        
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"http://10.255.144.69/bump"]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:postData];
        
        NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:NO];
        
        [connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                              forMode:NSDefaultRunLoopMode];
        [connection start];
        
        if(connection)
        {
            NSLog(@"Connection Successful");
        }
        else
        {
            NSLog(@"Connection could not be made");
        }
        

    }
    
    /*
    self.accX.text = [NSString stringWithFormat:@" %.2fg",acceleration.x];
    if(fabs(acceleration.x) > fabs(currentMaxAccelX))
    {
        currentMaxAccelX = acceleration.x;
    }
    self.accY.text = [NSString stringWithFormat:@" %.2fg",acceleration.y];
    if(fabs(acceleration.y) > fabs(currentMaxAccelY))
    {
        currentMaxAccelY = acceleration.y;
    }
    self.accZ.text = [NSString stringWithFormat:@" %.2fg",acceleration.z];
    if(fabs(acceleration.z) > fabs(currentMaxAccelZ))
    {
        currentMaxAccelZ = acceleration.z;
    }
    
    self.maxAccX.text = [NSString stringWithFormat:@" %.2f",currentMaxAccelX];
    self.maxAccY.text = [NSString stringWithFormat:@" %.2f",currentMaxAccelY];
    self.maxAccZ.text = [NSString stringWithFormat:@" %.2f",currentMaxAccelZ];
     */
}
-(void)outputRotationData:(CMRotationRate)rotation
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
