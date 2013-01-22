//
//  MulleCalendarView.h
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

@class MulleDaysView;
@class MullePeriod;
@class MulleSelectionView;

@protocol MulleCalendarViewDelegate;

/**
 * MulleCalendarView is an internal class.
 *
 * MulleCalendarView is a view which manages user's interactions - tap, pan and long press.
 * It also renders text (month, weekdays titles, days).
 */
@interface MulleCalendarView : UIView <UIGestureRecognizerDelegate>
{
   id <MulleCalendarViewDelegate>    delegate_;
   
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
   MullePeriod     *allowedPeriod_;
   MullePeriod     *period_;
   UIFont       *font_;
   
   MulleDaysView   *daysView_;

   UILongPressGestureRecognizer   *longPressRecognizer_;
   UIPanGestureRecognizer         *panRecognizer_;
   UITapGestureRecognizer         *tapRecognizer_;
   MulleSelectionView                *selectionView_;

   BOOL         allowsLongPressMonthChange_;
   BOOL         allowsPeriodSelection_;
   BOOL         mondayFirstDayOfWeek_;
}

- (MullePeriod *) period;
- (MullePeriod *) allowedPeriod;
- (NSDate *) currentDate;

- (BOOL) isMondayFirstDayOfWeek;
- (BOOL) allowsPeriodSelection;
- (BOOL) allowsLongPressMonthChange;

- (void) setMondayFirstDayOfWeek:(BOOL) flag;
- (void) setAllowsPeriodSelection:(BOOL) flag;
- (void) setAllowsLongPressMonthChange:(BOOL) flag;

- (id <MulleCalendarViewDelegate>) delegate;

- (void) setDelegate:(id <MulleCalendarViewDelegate>) delegate;
- (void) setPeriod:(MullePeriod *) period;
- (void) setAllowedPeriod:(MullePeriod *) period;
- (void) setCurrentDate:(NSDate *) date;

@end


@protocol MulleCalendarViewDelegate <NSObject>

/**
 * Called on the delegate when user changes showed month.
 */
- (void) currentDateChanged: (NSDate *)currentDate;

/**
 * Called on the delegate when user changes selected period.
 */
- (void) periodChanged: (MullePeriod *)newPeriod;

@end
