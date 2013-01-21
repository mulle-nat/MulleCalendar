//
//  PMPeriod.h
//  PMCalendar
//
//  Created by Pavel Mazurin on 7/13/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * PMPeriod is an immutable simple class which represents a period of time.
 * PMPeriod has start and end date which could be the same in order to represent one-day period.
 */
@interface PMPeriod : NSObject <NSCopying>
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
- (PMPeriod *) normalizedPeriod;

/**
 * Checks if current (self) period contains a given date.
 */
- (BOOL) containsDate:(NSDate *) date;

- (NSDate *) startDate;
- (NSDate *) endDate;

@end
