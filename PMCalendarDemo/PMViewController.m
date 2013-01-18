//
//  PMViewController.m
//  PMCalendarDemo
//
//  Created by Pavel Mazurin on 7/13/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import "PMViewController.h"
#import "PMCalendar.h"

@interface PMViewController ()

@property (nonatomic, strong) PMCalendarController *pmCC;

@end

@implementation PMViewController

@synthesize pmCC;
@synthesize periodLabel;

- (IBAction)showCalendar:(id)sender
{
    if ([self.pmCC isCalendarVisible])
    {
        [self.pmCC dismissCalendarAnimated:NO];
    }
    
    BOOL isPopover = YES;
    if ([sender tag] == 10)
    {
        isPopover = NO;
        self.pmCC = [[PMCalendarController alloc] initWithThemeName:@"apple calendar"];
        // limit apple calendar to 2 months before and 2 months after current date
//        self.pmCC.allowedPeriod = [PMPeriod periodWithStartDate:[[NSDate date] dateByAddingMonths:-2]
//                                                        endDate:[[NSDate date] dateByAddingMonths:2]];
    }
    else
    {
        self.pmCC = [[PMCalendarController alloc] initWithThemeName:@"default"];
    }
    
    self.pmCC.delegate = self;
    self.pmCC.mondayFirstDayOfWeek = NO;

    if ([sender tag] == 10)
    {
        [self.pmCC presentCalendarFromRect:CGRectZero
                                    inView:[sender superview]
                  permittedArrowDirections:PMCalendarArrowDirectionAny
                                 isPopover:isPopover
                                  animated:YES];
    }
    else
    {
        [self.pmCC presentCalendarFromView:sender
                  permittedArrowDirections:PMCalendarArrowDirectionAny
                                 isPopover:isPopover
                                  animated:YES];
    }

    self.pmCC.period = [PMPeriod oneDayPeriodWithDate:[NSDate date]];
    [self calendarController:pmCC didChangePeriod:pmCC.period];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark PMCalendarControllerDelegate methods

- (void)calendarController:(PMCalendarController *)calendarController didChangePeriod:(PMPeriod *)newPeriod
{
    periodLabel.text = [NSString stringWithFormat:@"%@ - %@"
                        , [newPeriod.startDate pmDateStringWithFormat:@"dd-MM-yyyy"]
                        , [newPeriod.endDate pmDateStringWithFormat:@"dd-MM-yyyy"]];
}

@end
