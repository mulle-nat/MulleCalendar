//
//  MulleViewController.h
//  MulleCalendarDemo
//
//  Created by Pavel Mazurin on 7/13/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//
//  Usurped by Nat! on 1/22/13.
//  Copyright (c) 2012 Nat! All rights reserved.
//
//  This is still MIT licensed
//
#import <UIKit/UIKit.h>
#import "MulleCalendar.h"


@class MulleCalendarController;


@interface MulleViewController : UIViewController < MulleCalendarControllerDelegate>
{
   IBOutlet UILabel       *periodLabel_;
   
@private
   MulleCalendarController   *controller_;
}


- (IBAction) showCalendar:(id)sender;

- (void) setPeriodLabel:(UILabel *) label;
- (UILabel *) periodLabel;

@end
