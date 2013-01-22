//
//  MulleViewController.m
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
#import "MulleViewController.h"
#import "MulleCalendar.h"


@implementation MulleViewController

- (void) dealloc
{
   [controller_ release];
   [super dealloc];
}


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
   BOOL       isPopover;
   NSString   *themeName;
   MullePeriod   *period;
   
    if( [controller_ isCalendarVisible])
        [controller_ dismissCalendarAnimated:NO];
   
   isPopover   = [sender tag] == 10;
   themeName   = isPopover ? @"apple calendar" :  @"default";
   controller_ = [[MulleCalendarController alloc] initWithThemeName:themeName];
   
   [controller_ setDelegate:self];
   [controller_ setMondayFirstDayOfWeek:NO];

   if( ! isPopover)
      [controller_ presentCalendarFromView:sender
                  permittedArrowDirections:MulleCalendarArrowDirectionAny
                                 isPopover:YES
                                  animated:YES];
   else
      [controller_ presentCalendarFromRect:CGRectZero
                                    inView:[sender superview]
                  permittedArrowDirections:MulleCalendarArrowDirectionAny
                                 isPopover:NO
                                  animated:YES];

   period = [MullePeriod oneDayPeriodWithDate:[NSDate date]];
   [controller_ setPeriod:period];
   
   [self calendarController:controller_
            didChangePeriod:[controller_ period]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark MulleCalendarControllerDelegate methods

- (void) calendarController:(MulleCalendarController *) calendarController
            didChangePeriod:(MullePeriod *) newPeriod
{
   NSString  *s;

   s = [NSString stringWithFormat:@"%@ - %@",
        [newPeriod.startDate pmDateStringWithFormat:@"dd-MM-yyyy"],
        [newPeriod.endDate pmDateStringWithFormat:@"dd-MM-yyyy"]];
   [periodLabel_ setText:s];
}

@end
