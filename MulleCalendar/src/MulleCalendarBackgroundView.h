//
//  MulleCalendarBackgroundView.h
//  MulleCalendar
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
#import "MulleCalendarConstants.h"

/**
 * MulleCalendarBackgroundView is an internal class.
 *
 * MulleCalendarBackgroundView is a view which contains backgound image including an arrow.
 */
@interface MulleCalendarBackgroundView : UIView
{
   MulleCalendarArrowDirection   arrowDirection_;
   CGPoint                    arrowPosition_;
   
   CGRect                     initialFrame_;
}

- (void) setArrowPosition:(CGPoint) pos;
- (void) setArrowDirection:(MulleCalendarArrowDirection) dir;

@end
