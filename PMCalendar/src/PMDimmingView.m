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

- (id) initWithFrame:(CGRect) frame
          controller:(PMCalendarController *) controller
{
   if( ! (self = [super initWithFrame:frame]))
      return( nil);

   controller_ = controller;
   
   [self setBackgroundColor:pmMakeRGBAUIColor( 0, 0, 0, 0.3)];

   return( self);
}


- (void) touchesEnded:(NSSet *) touches
            withEvent:(UIEvent *) event
{
   id   delegate;
   
   delegate = [controller_ delegate];
   
   if( [delegate respondsToSelector:@selector( calendarControllerShouldDismissCalendar:)])
      if( ! [delegate calendarControllerShouldDismissCalendar:controller_])
         return;

   [controller_ dismissCalendarAnimated:YES];
}

@end
