//
//  AccountsTableViewController.h
//  HighFive
//
//  Created by Canzhi Ye on 1/18/14.
//  Copyright (c) 2014 Canzhi Ye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HighFiveFirstViewController.h"

@interface AccountsTableViewController : UITableViewController
{
    NSMutableArray *accountsArray;
    HighFiveFirstViewController *previousView;
}
-(void)setAccountsArray:(NSArray*)array andPassVC:(HighFiveFirstViewController*)vc;
@end
