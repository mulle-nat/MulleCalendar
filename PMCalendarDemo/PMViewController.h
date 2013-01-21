//
//  PMViewController.h
//  PMCalendarDemo
//
//  Created by Pavel Mazurin on 7/13/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMCalendar.h"


@class PMCalendarController;


@interface PMViewController : UIViewController < PMCalendarControllerDelegate>
{
   IBOutlet UILabel       *periodLabel_;
   
@private
   PMCalendarController   *controller_;
}


- (IBAction) showCalendar:(id)sender;

- (void) setPeriodLabel:(UILabel *) label;
- (UILabel *) periodLabel;

@end
