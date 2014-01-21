//
//  HighFiveFirstViewController.m
//  HighFive
//
//  Created by Canzhi Ye on 1/17/14.
//  Copyright (c) 2014 Canzhi Ye. All rights reserved.
//

#import "HighFiveFirstViewController.h"
#import "AccountsTableViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <FacebookSDK/FacebookSDK.h>
//#import "ASIHTTPRequest.h"
//#import <CFNetwork/CFNetwork.h>
//#import "ASIFormDataRequest.h"

@interface HighFiveFirstViewController ()

@property (nonatomic) ACAccountStore *accountStore;

@end

@implementation HighFiveFirstViewController
@synthesize profilePicImageView, usernameLabel, profilePicCirlceImageView, backgroundImageView, customIntroMessage;

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
-(void)setAccountIndex:(int)index
{
    indexOfAccount = index;
    [self finishLoggingIn];
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"goToLogin"])
    {
        AccountsTableViewController *vc = [segue destinationViewController];
        [vc setAccountsArray:accountsArray andPassVC:self];
    }
}
- (void)fetchUserInfo:(NSString*)username
{
    // Request access to the Twitter accounts
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted)
        {
            accountsArray = [accountStore accountsWithAccountType:accountType];
            
            // Check if the users has setup at least one Twitter account
            if (accountsArray.count > 0)
            {
                [self performSegueWithIdentifier:@"goToLogin" sender:self];
                
            }
        } else {
            NSLog(@"No access granted");
        }
    }];
}
-(void)finishLoggingIn
{
    ACAccount *twitterAccount = [accountsArray objectAtIndex:indexOfAccount];
    
    NSLog(@"WHAT IS MY USERNAME: %@", twitterAccount.username);
    // Creating a request to get the info about a user on Twitter
    SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"] parameters:[NSDictionary dictionaryWithObject:twitterAccount.username forKey:@"screen_name"]];
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
                //NSLog(@"MY OWN SHIT RESPONSE: %@",TWData);
                screenName = [TWData objectForKey:@"screen_name"];
                userID = [TWData objectForKey:@"id_str"];
                NSString *himothafucka = [NSString stringWithFormat:@"Hi, @%@",screenName];
                [usernameLabel setText:himothafucka];
                
                userID = [TWData objectForKey:@"id_str"];
                NSString *fuckinURL = [[TWData objectForKey:@"profile_image_url"] stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
                NSURL *profilePicURL = [NSURL URLWithString:fuckinURL];
                profilePicImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:profilePicURL]];
                
            }
        });
    }];
}
// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    NSLog(@"user: %@",user);
    facebookID = [user objectForKey:@"id"];
    facebookUsername = [user objectForKey:@"username"];
    
}
- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    //self.statusLabel.text = @"You're logged in as";
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@/likes?limit=5000",facebookID]
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              //post stuff
                              if (!error) {
                                  // Sucess! Include your code to handle the results here
                                  //NSLog(@"user likes: %@", result);
                                  NSError *error = nil;
                                 // NSDictionary *likesDictionary = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableLeaves error:&error];
                                  NSArray *ughLikesArray = [result objectForKey:@"data"];
                                  likesArray = [[NSMutableArray alloc]init];
                                  
                                  for (int i = 0; i < ughLikesArray.count; i++)
                                  {
                                      [likesArray addObject:[[ughLikesArray objectAtIndex:i] objectForKey:@"name"]];
                                  }
                              }
                              else
                              {
                                  NSLog(@"%@",error);
                              }
                          }];
    
}
// Handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}
- (void)viewDidLoad
{
    
    FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"basic_info", @"email", @"user_likes"]];
    loginView.delegate=self;
    loginView.frame = CGRectMake(20, 462, 280, 40);
    [self.view addSubview:loginView];
    
    uniqueID = [self uniqID];
    //[self disconnect];
    
    
    profilePicCirlceImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"profilePicBackground.png"]];
    backgroundImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"launchScreen.png"]];
    
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
    
    [self fetchUserInfo:@""];
    
    //receivedScreenName = @"jacobvangeffen";
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .2;
    self.motionManager.gyroUpdateInterval = .2;
    
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 [self outputAccelertionData:accelerometerData.acceleration];
                                                 if(error){
                                                     
                                                     NSLog(@"accel error %@", error);
                                                 }
                                             }];
    
//    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
//                                    withHandler:^(CMGyroData *gyroData, NSError *error) {
//                                        [self outputRotationData:gyroData.rotationRate];
//                                    }];
    
    shouldContact = YES;
    tweetPosted = NO;
    canRequest = YES;
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data
{
    //Above method is used to receive the data which we get using post method.
    //NSLog(@"did Receive Data: %@", data);
    NSError *error = nil;
    NSDictionary* newDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];

    NSLog(@"did Receive Data: %@", newDict);

    // check if connecting or disconnecting
    if ([[newDict objectForKey:@"action"] isEqualToString:@"bump"])
    {
        if ([newDict objectForKey:@"success"]!=nil)
        {
            if ([[newDict objectForKey:@"success"] isEqualToString:@"true"])
            {
                canRequest = YES;
                shouldContact = YES;
                [self performSelector:@selector(tryGettingMatched:) withObject:[NSNumber numberWithBool:shouldContact]  afterDelay:3];
                NSLog(@"Connected");
            }
        }
    }
    else if ([[newDict objectForKey:@"action"] isEqualToString:@"disconnect"])
    {
        if ([newDict objectForKey:@"success"]!=nil)
        {
            if ([[newDict objectForKey:@"success"] isEqualToString:@"true"])
            {
                NSLog(@"Disconnected");
                canRequest = YES;
                receivedScreenName = @"";
                receivedUserID = @"";
                
                if (tweetPosted == NO)
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Nothing" message:@"No High Fives around you... Try again, loner" delegate:nil cancelButtonTitle:@"Damn" otherButtonTitles:nil];
                    [alert show];
                }
            }
        }
    }
    
    //NOW WE ARE CONNECTED?!
    else if ([newDict objectForKey:@"twitter_handle"]!=nil)
    {
        NSLog(@"Matched With Other User");

        if (tweetPosted == NO)
        {
            //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"High Five!" message:@"High Five detected!" delegate:nil cancelButtonTitle:@"Sweet" otherButtonTitles: nil];
            //[alert show];
        }
        
        receivedUserID = [newDict objectForKey:@"twitter_id"];
        receivedScreenName = [newDict objectForKey:@"twitter_handle"];
        receivedFacebookID = [newDict objectForKey:@"fb_id"];
        receivedFacebookUsername = [newDict objectForKey:@"fb_username"];
        canRequest = YES;
        
        // GET THE WEATHER
        NSString *city = @"Detroit";
        NSURL *getDatWeather = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.wunderground.com/api/dfb228b1988561b2/conditions/q/MI/%@.json",city]];
        NSData *data = [NSData dataWithContentsOfURL:getDatWeather];
        
        // Check if there is some response data
        if (data) {
            NSError *error = nil;
            NSDictionary *weatherData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            // Filter the preferred data
            //NSLog(@"WEATHER RESPONSE: %@",weatherData);
            NSString *city = @"Detroit";
            NSString *current_observation = [[weatherData objectForKey:@"current_observation"] objectForKey: @"weather"];
            NSString *temperature = [[weatherData objectForKey:@"current_observation"] objectForKey: @"temp_f"];
            
            if (temperature.intValue<32)
            {
                
            }
            customIntroMessage = @"High Five!";
            
            weatherString = [NSString stringWithFormat:@"Hey @%@, %@. It's %@ and %@° in %@", receivedScreenName, customIntroMessage, current_observation, temperature, city];
            
            SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"] parameters:[NSDictionary dictionaryWithObject:weatherString forKey:@"status"]];
            [twitterInfoRequest setAccount:_theAccount];
            
            // Making the request
            [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
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
                // Check if tweet was successfully posted
                if (responseData) {
                    
                    NSError *error = nil;
                    NSDictionary *TWData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                    // Filter the preferred data
                    NSLog(@"TWEET POSTED RESPONSE: %@",TWData);
                    
                    [self followOtherUser];
                }
                
            }];
            
        }
        return;
    }
    else if (![[newDict objectForKey:@"action"] isEqualToString:@"disconnect"])
    {
        NSLog(@"Not Paired With Other");
        [self disconnect];
        tweetPosted = NO;
        canRequest = YES;
    }
    else
    {
       
    }
    
}
-(NSString*)uniqID
{
    NSString* uniqueIdentifier = nil;
    if( [UIDevice instancesRespondToSelector:@selector(identifierForVendor)] ) {
        // iOS 6+
        uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    } else {
        // before iOS 6, so just generate an identifier and store it
        uniqueIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:@"identiferForVendor"];
        if( !uniqueIdentifier ) {
            CFUUIDRef uuid = CFUUIDCreate(NULL);
            uniqueIdentifier = ( NSString*)CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
            CFRelease(uuid);
            [[NSUserDefaults standardUserDefaults] setObject:uniqueIdentifier forKey:@"identifierForVendor"];
        }
    }
    return uniqueIdentifier;
}//
-(void)tryGettingMatched:(NSNumber*)firstTime
{
    BOOL fuckYou = [firstTime boolValue];
    
    if (fuckYou == YES) {
        
        NSString *post = [NSString stringWithFormat:@"&uid=%@",uniqueID];
        
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"http://direct.kywu.org/highfive/contact"]];
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
        shouldContact = NO;
        
       
    }
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
    if (canRequest == YES)
    {
        if (YES)
        {
            //NSLog(@"z accel: %3.2f",acceleration.z);
            //NSLog(@"x accel: %3.2f",acceleration.x);
            //NSLog(@"y accel: %3.2f",acceleration.y);
            
            if (acceleration.z > 1.3 /*some arbitrary threshold*/)
            {
                canRequest = NO;
                
                NSString *path  = [[NSBundle mainBundle] pathForResource:@"slap" ofType:@"mp3"];
                NSURL *pathURL = [NSURL fileURLWithPath : path];
                
                SystemSoundID audioEffect;
                AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
                AudioServicesPlaySystemSound(audioEffect);
                
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
                //    "twitter_handle",
                
                
                // POSTING SHIT TO SERVER
                double timestamp = [[NSDate date] timeIntervalSince1970];
                
                CLLocationDegrees loc_x =  locationManager.location.coordinate.longitude;
                CLLocationDegrees loc_y =  locationManager.location.coordinate.latitude;
                
                NSString *velocity = @"fuck";
                NSString *uid = uniqueID;
                NSLog(@"Unique ID: %@", uniqueID);
                NSString *twitter_id = userID;
                NSString *twitter_handle = screenName;
                
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:likesArray,@"data", nil];
                
                NSError *error = nil;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                                   options:0 // Pass 0 if you don't care about the readability of the generated string
                                                                     error:&error];
                NSString *fb_likes = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                // NSLog(@"%@",fb_likes);
                
                NSString *fb_id = facebookID;
                NSString *fb_username = facebookUsername;
                
                NSString *post = [NSString stringWithFormat:@"&timestamp=%f&loc_x=%f&loc_y=%f&velocity=%@&uid=%@&twitter_id=%@&twitter_handle=%@&fb_id=%@&fb_username=%@",timestamp,loc_x,loc_y,velocity,uid,twitter_id,twitter_handle,fb_id,fb_username];
                
                NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
                NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)postData.length];
                
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
                [request setURL:[NSURL URLWithString:@"http://direct.kywu.org/highfive/bump"]];
                [request setHTTPMethod:@"POST"];
                [request setValue:@"application/json" forHTTPHeaderField:@"Current-Type"];
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
        }
    }
}

-(void)followOtherUser
{
    //asdkjfnalsdkjnf
    //get user id
    SLRequest* twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/users/lookup.json"] parameters:[NSDictionary dictionaryWithObject:receivedScreenName forKey:@"screen_name"]];
    [twitterInfoRequest setAccount:_theAccount];
    
    [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        // Check if there was an error
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
            return;
        }
        // Check if there is some response data
        if (responseData) {
            
            NSError *error = nil;
            NSArray *omgfucku = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
            // Filter the preferred data
            NSLog(@"k RESPONSE: %@",omgfucku);
            receivedUserID = [[omgfucku objectAtIndex:0] objectForKey:@"id_str"];
            
            
            // follow other dude
            NSArray *keys = [NSArray arrayWithObjects:@"screen_name", @"user_id", nil];
            
            NSArray *objects = [NSArray arrayWithObjects:receivedScreenName, receivedUserID, nil];
            SLRequest* twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/create.json"] parameters:[NSDictionary dictionaryWithObjects:objects forKeys:keys]];
            [twitterInfoRequest setAccount:_theAccount];
            
            [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // Check if there was an error
                    if (error) {
                        NSLog(@"Error: %@", error.localizedDescription);
                        return;
                    }
                    // Check if there is some response data
                    if (responseData) {
                        
                        NSError *error = nil;
                        NSDictionary *followtheotherguy = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                        // Filter the preferred data
                        //NSLog(@"FOLLOW RESPONSE: %@",followtheotherguy);
                        
                        
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"High Five!" message:[NSString stringWithFormat:@"You are now following @%@!",receivedScreenName] delegate:self cancelButtonTitle:@"Awesome" otherButtonTitles:nil];
                        alert.tag = 0;
                        [alert show];
                        
                        tweetPosted = YES;
                        

                    }
                });
            }];

        }
    }];
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 0 /*You are now following*/)
    {
        tweetPosted = YES;
        [self disconnect];

        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Connect on Facebook" message:@"Would you like to connect on Facebook?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        alert.tag = 1;
        [alert show];
        
        
    }
    else if (alertView.tag == 1)
    {
        if (buttonIndex == 0) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/%@",receivedFacebookID]];
            //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fb://profile/canzhiye"]];
            
            if ([[UIApplication sharedApplication] canOpenURL:url])
            {
                [[UIApplication sharedApplication] openURL:url];
            }
        }

    }
}
-(void)disconnect
{
    // POSTING SHIT TO SERVER
    NSString *uid = uniqueID;
    
    NSString *post = [NSString stringWithFormat:@"&uid=%@",uid];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"http://direct.kywu.org/highfive/disconnect"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
