//
//  HighFiveSecondViewController.m
//  HighFive
//
//  Created by Canzhi Ye on 1/17/14.
//  Copyright (c) 2014 Canzhi Ye. All rights reserved.
//

#import "HighFiveSecondViewController.h"
#import "HighFiveFirstViewController.h"

@interface HighFiveSecondViewController ()

@end

@implementation HighFiveSecondViewController
@synthesize introMessageTextView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    HighFiveFirstViewController *myVC1ref = (HighFiveFirstViewController *)[self.tabBarController.viewControllers objectAtIndex:0];
    myVC1ref.customIntroMessage = textView.text;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }
    return YES;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
