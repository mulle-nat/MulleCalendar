//
//  MulleDimmingView.h
//  MulleCalendar
//
//  Created by Pavel Mazurin on 7/18/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//
//
// Usurped by Nat! on 1/22/13.
// Copyright (c) 2012 Nat! All rights reserved.
//
// This is still MIT licensed
//

#import <UIKit/UIKit.h>

@class MulleCalendarController;

/**
 * MulleDimmingView is an internal class.
 *
 * MulleDimmingView is a view which is shown below the calendar. It catches  
 * user interaction outside of the calendar and dismisses calendar. 
 */
@interface MulleDimmingView : UIView
{
   MulleCalendarController   *controller_;  // non retained 
}

- (id) initWithFrame:(CGRect) frame
          controller:(MulleCalendarController*) controller;

@end
