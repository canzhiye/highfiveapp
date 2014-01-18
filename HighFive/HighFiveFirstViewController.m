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
                _theAccount = twitterAccount;
                
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
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
    {
        locationManager = [[CLLocationManager alloc] init];
    }
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = 500; // meters
    
    [locationManager startUpdatingLocation];
    
    [self fetchUserInfo:@"canzhiye"];
    
    receivedScreenName = @"jacobvangeffen";
    
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
   
    if (acceleration.z > 1.5 /*some arbitrary threshold*/) {
        
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
        
        
        double timestamp = [[NSDate date] timeIntervalSince1970];

        CLLocationDegrees loc_x =  locationManager.location.coordinate.latitude;
        CLLocationDegrees loc_y =  locationManager.location.coordinate.longitude;
        
        NSString *velocity = @"fuck";
        NSString *uid = @"2";
        NSString *twitter_id = screenName;
        
        NSString *post = [NSString stringWithFormat:@"&timestamp=%f&loc_x=%f&loc_y=%f&velocity=%@&uid=%@&twitter_id=%@",timestamp,loc_x,loc_y,velocity,uid,twitter_id];
        
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"http://direct.kywu.org/highfive/bump"]];
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
        
        NSString *city = @"Detroit";
        NSURL *getDatWeather = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.wunderground.com/api/dfb228b1988561b2/conditions/q/MI/%@.json",city]];
        
        [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:getDatWeather] queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
            
            if (error) {
                NSLog(@"Error: %@", error.localizedDescription);
                return;
            }
            // Check if there is some response data
            if (data) {
                NSError *error = nil;
                NSDictionary *weatherData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                // Filter the preferred data
                NSLog(@"WEATHER RESPONSE: %@",weatherData);
                NSString *shit = [[weatherData objectForKey:@"current_observation"] objectForKey: @"weather"];
                
                weatherString = [NSString stringWithFormat:@"Hey @%@, It is %@ in %@ according to @WeatherAPI", receivedScreenName, shit,city];
                
                SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"] parameters:[NSDictionary dictionaryWithObject:weatherString forKey:@"status"]];
                [twitterInfoRequest setAccount:_theAccount];
                
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
                        }
                    });
                }];

            }
            
        }];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"High Five!" message:@"High Five detected. Now suck each others' dicks." delegate:nil cancelButtonTitle:@"Sweet" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
