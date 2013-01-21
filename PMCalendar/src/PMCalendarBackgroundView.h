//
//  PMCalendarBackgroundView.h
//  PMCalendar
//
//  Created by Pavel Mazurin on 7/13/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMCalendarConstants.h"

/**
 * PMCalendarBackgroundView is an internal class.
 *
 * PMCalendarBackgroundView is a view which contains backgound image including an arrow.
 */
@interface PMCalendarBackgroundView : UIView
{
   PMCalendarArrowDirection   arrowDirection_;
   CGPoint                    arrowPosition_;
   
   CGRect                     initialFrame_;
}

- (void) setArrowPosition:(CGPoint) pos;
- (void) setArrowDirection:(PMCalendarArrowDirection) dir;

@end
