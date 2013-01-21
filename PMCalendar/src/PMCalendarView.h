//
//  PMCalendarView.h
//  PMCalendar
//
//  Created by Pavel Mazurin on 7/13/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMDaysView;
@class PMPeriod;
@class PMSelectionView;

@protocol PMCalendarViewDelegate;

/**
 * PMCalendarView is an internal class.
 *
 * PMCalendarView is a view which manages user's interactions - tap, pan and long press.
 * It also renders text (month, weekdays titles, days).
 */
@interface PMCalendarView : UIView <UIGestureRecognizerDelegate>
{
   id <PMCalendarViewDelegate>    delegate_;
   
   CGPoint      panPoint_;
   CGRect       initialFrame_;
   CGRect       leftArrowRect_;
   CGRect       rightArrowRect_;
   NSInteger    currentMonth_;
   NSInteger    currentYear_;
   NSInteger    fontSize_;

   NSDate       *currentDate_;
   NSTimer      *longPressTimer_;
   NSTimer      *panTimer_;
   PMPeriod     *allowedPeriod_;
   PMPeriod     *period_;
   UIFont       *font_;
   
   PMDaysView   *daysView_;

   UILongPressGestureRecognizer   *longPressRecognizer_;
   UIPanGestureRecognizer         *panRecognizer_;
   UITapGestureRecognizer         *tapRecognizer_;
   PMSelectionView                *selectionView_;

   BOOL         allowsLongPressMonthChange_;
   BOOL         allowsPeriodSelection_;
   BOOL         mondayFirstDayOfWeek_;
}

- (PMPeriod *) period;
- (PMPeriod *) allowedPeriod;
- (NSDate *) currentDate;

- (BOOL) isMondayFirstDayOfWeek;
- (BOOL) allowsPeriodSelection;
- (BOOL) allowsLongPressMonthChange;

- (void) setMondayFirstDayOfWeek:(BOOL) flag;
- (void) setAllowsPeriodSelection:(BOOL) flag;
- (void) setAllowsLongPressMonthChange:(BOOL) flag;

- (id <PMCalendarViewDelegate>) delegate;

- (void) setDelegate:(id <PMCalendarViewDelegate>) delegate;
- (void) setPeriod:(PMPeriod *) period;
- (void) setAllowedPeriod:(PMPeriod *) period;
- (void) setCurrentDate:(NSDate *) date;

@end


@protocol PMCalendarViewDelegate <NSObject>

/**
 * Called on the delegate when user changes showed month.
 */
- (void) currentDateChanged: (NSDate *)currentDate;

/**
 * Called on the delegate when user changes selected period.
 */
- (void) periodChanged: (PMPeriod *)newPeriod;

@end
