//
// PMDimmingView.m
// PMCalendar
//
// Created by Pavel Mazurin on 7/18/12.
// Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import "PMCalendarConstants.h"
#import "PMCalendarController.h"
#import "PMCalendarHelpers.h"
#import "PMDimmingView.h"

@implementation PMDimmingView


@synthesize controller = _controller;


- (id) initWithFrame:(CGRect) frame controller:(PMCalendarController *) controller
{
   if( ! (self = [super initWithFrame:frame]))
      return( nil);

   [self setController:controller];
   [self setBackgroundColor:UIColorMakeRGBA(0, 0, 0, 0.3)];

   return( self);
}


- (void) touchesEnded:(NSSet *) touches
            withEvent:(UIEvent *) event
{
   PMCalendarController   *controller;
   id                     delegate;
   
   controller = [self controller];
   delegate   = [controller delegate];
   
   if( [delegate respondsToSelector:@selector( calendarControllerShouldDismissCalendar:)])
      if( ! [delegate calendarControllerShouldDismissCalendar:controller])
         return;

   [controller dismissCalendarAnimated:YES];
}


@end
