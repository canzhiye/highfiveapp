//
//  HighFiveSecondViewController.h
//  HighFive
//
//  Created by Canzhi Ye on 1/17/14.
//  Copyright (c) 2014 Canzhi Ye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HighFiveSecondViewController : UIViewController <UITextViewDelegate>
{
    UITextView *introMessageTextView;
}
@property (nonatomic, retain) IBOutlet UITextView *introMessageTextView;

@end
