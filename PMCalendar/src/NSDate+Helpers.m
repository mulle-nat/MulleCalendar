//
// NSDate+Helpers.m
// PMCalendar
//
// Created by Pavel Mazurin on 7/14/12.
// Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import "NSDate+Helpers.h"


@implementation NSDate (Helpers)

- (NSDate *) pmDateWithoutTime
{
   NSCalendar         *calendar;
   NSDateComponents   *components;
   
   calendar   = [NSCalendar currentCalendar];
   components = [calendar components:(NSYearCalendarUnit
                                      | NSMonthCalendarUnit
                                      | NSDayCalendarUnit)
                            fromDate:self];
   
   return( [calendar dateFromComponents:components]);
}


- (NSDate *) pmDateByAddingDays:(NSInteger) days months:(NSInteger) months years:(NSInteger) years
{
   NSDateComponents   *components;
   
   components = [[NSDateComponents new] autorelease];

   [components setDay:days];
   [components setMonth:months];
   [components setYear:years];

   return( [[NSCalendar currentCalendar] dateByAddingComponents:components
                                                         toDate:self
                                                        options:0]);
}


- (NSDate *) pmDateByAddingDays:(NSInteger) days
{
   return( [self pmDateByAddingDays:days
                             months:0
                              years:0]);
}


- (NSDate *) pmDateByAddingMonths:(NSInteger) months
{
   return( [self pmDateByAddingDays:0
                             months:months
                              years:0]);
}


- (NSDate *) pmDateByAddingYears:(NSInteger) years
{
   return( [self pmDateByAddingDays:0
                             months:0
                              years:years]);
}


- (NSDate *) pmMonthStartDate
{
   NSDate   *monthStartDate;
   
   monthStartDate = nil;
   [[NSCalendar currentCalendar] rangeOfUnit:NSMonthCalendarUnit
                                   startDate:&monthStartDate
                                    interval:NULL
                                     forDate:self];
   
   return( monthStartDate);
}


- (NSDate *) pmMidnightDate
{
   NSDate   *midnightDate;
   
   midnightDate = nil;

   [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit
                                   startDate:&midnightDate
                                    interval:NULL
                                     forDate:self];

   return( midnightDate);
}


- (NSUInteger) pmNumberOfDaysInMonth
{
   return( [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit
                                              inUnit:NSMonthCalendarUnit
                                            forDate:self].length);
}


#warning (nat) curious, the only "gregorian" method in this category
- (NSUInteger) pmGregorianWeekday
{
   NSCalendar         *calendar;
   NSDateComponents   *components;

   calendar   = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
   components = [calendar components:NSWeekdayCalendarUnit
                            fromDate:self];
   
   return( [components weekday]);
}


- (NSString *) pmDateStringWithFormat:(NSString *) format
{
   NSDateFormatter   *formatter;
   
   formatter = [[NSDateFormatter new] autorelease];
   [formatter setDateFormat:format];
   return( [formatter stringFromDate:self]);
}


#warning (nat) this could be wrong
- (NSInteger) pmDaysSinceDate:(NSDate *) date
{ 
   return([self timeIntervalSinceDate:date] / (60 * 60 * 24));
}


- (BOOL) pmIsBefore:(NSDate *) date
{
   return( [self timeIntervalSinceDate:date] < 0);
}


- (BOOL) pmIsAfter:(NSDate *) date
{
   return( [self timeIntervalSinceDate:date] > 0);
}

@end
