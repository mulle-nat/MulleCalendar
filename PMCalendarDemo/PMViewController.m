//
//  PMViewController.m
//  PMCalendarDemo
//
//  Created by Pavel Mazurin on 7/13/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import "PMViewController.h"
#import "PMCalendar.h"


@implementation PMViewController

- (void) setPeriodLabel:(UILabel *) label
{
   [periodLabel_ autorelease];
   periodLabel_ = [label retain];
}


- (UILabel *) periodLabel
{
   return( periodLabel_);
}


- (IBAction) showCalendar:(id) sender
{
   BOOL      isPopover;
   NSString  *themeName;
   
    if( [controller_ isCalendarVisible])
        [controller_ dismissCalendarAnimated:NO];
   
   isPopover   = [sender tag] == 10;
   themeName   = isPopover ? @"apple calendar" :  @"default";
   controller_ = [[PMCalendarController alloc] initWithThemeName:themeName];
   
   [controller_ setDelegate:self];
   [controller_ setMondayFirstDayOfWeek:NO];

    if( isPopover)
        [controller_ presentCalendarFromRect:CGRectZero
                                      inView:[sender superview]
                    permittedArrowDirections:PMCalendarArrowDirectionAny
                                   isPopover:YES
                                    animated:YES];
    else
        [controller_ presentCalendarFromView:sender
                    permittedArrowDirections:PMCalendarArrowDirectionAny
                                   isPopover:NO
                                    animated:YES];

   [controller_ setPeriod:[PMPeriod oneDayPeriodWithDate:[NSDate date]]];
   
   [self calendarController:controller_
            didChangePeriod:[controller_ period]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark PMCalendarControllerDelegate methods

- (void) calendarController:(PMCalendarController *) calendarController
            didChangePeriod:(PMPeriod *) newPeriod
{
   NSString  *s;

   s = [NSString stringWithFormat:@"%@ - %@",
        [newPeriod.startDate pmDateStringWithFormat:@"dd-MM-yyyy"],
        [newPeriod.endDate pmDateStringWithFormat:@"dd-MM-yyyy"]];
   [periodLabel_ setText:s];
}

@end
