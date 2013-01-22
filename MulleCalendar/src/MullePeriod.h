//
//  MullePeriod.h
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
#import <Foundation/Foundation.h>

/**
 * MullePeriod is an immutable simple class which represents a period of time.
 * MullePeriod has start and end date which could be the same in order to represent one-day period.
 */
@interface MullePeriod : NSObject <NSCopying>
{
   NSDate   *startDate_;
   NSDate   *endDate_;
}

/**
 * Creates new period with same startDate and endDate.
 */
+ (id) oneDayPeriodWithDate:(NSDate *) date;

/**
 * Creates new period.
 */
+ (id) periodWithStartDate:(NSDate *) startDate
                   endDate:(NSDate *) endDate;

- (id) initWithStartDate:(NSDate *) startDate
                 endDate:(NSDate *) endDate;

- (NSInteger) lengthInDays;

/**
 * Creates new period from the current (self) period self with proper order of startDate and endDate.
 */
- (MullePeriod *) normalizedPeriod;

/**
 * Checks if current (self) period contains a given date.
 */
- (BOOL) containsDate:(NSDate *) date;

- (NSDate *) startDate;
- (NSDate *) endDate;

@end
