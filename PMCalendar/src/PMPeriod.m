//
// PMPeriod.m
// PMCalendar
//
// Created by Pavel Mazurin on 7/13/12.
// Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import "NSDate+Helpers.h"
#import "PMPeriod.h"


@implementation PMPeriod

- (NSDate *) startDate
{
   return( startDate_);
}


- (NSDate *) endDate
{
   return( endDate_);
}


+ (id) periodWithStartDate:(NSDate *) startDate
                   endDate:(NSDate *) endDate
{
   return( [[[PMPeriod alloc] initWithStartDate:startDate
                                        endDate:endDate] autorelease]);
}


+ (id) oneDayPeriodWithDate:(NSDate *) date
{
   NSDate   *adjusted;
   
   adjusted = [date pmDateWithoutTime];
   return( [[[PMPeriod alloc] initWithStartDate:adjusted
                                        endDate:adjusted] autorelease]);
}


- (id) initWithStartDate:(NSDate *) startDate
                 endDate:(NSDate *) endDate
{
   startDate_ = [startDate copy];
   endDate_   = [endDate copy];
   
   return( self);
}


- (void) dealloc
{
   [endDate_ release];
   [startDate_ release];
   
   [super dealloc];
}


- (BOOL) isEqualToPeriod:(PMPeriod *) other
{
   return( [startDate_ isEqualToDate:other->startDate_] &&
           [endDate_ isEqualToDate:other->endDate_]);
}


- (BOOL) isEqual:(id) other
{
   if( ! [other isKindOfClass:[PMPeriod class]])
      return( NO);

   return( [self isEqualToPeriod:other]);
}


// suspicious!
- (NSInteger) lengthInDays
{
   return( [endDate_ timeIntervalSinceDate:startDate_] / (60 * 60 * 24));
}


- (NSString *) description
{
   return( [NSString stringWithFormat:@"{ startDate = %@; endDate = %@ }", startDate_, endDate_]);
}


- (PMPeriod *) normalizedPeriod
{
   if( [startDate_ compare:endDate_] != NSOrderedDescending)
      return( self);

   return( [PMPeriod periodWithStartDate:endDate_
                                 endDate:startDate_]);
}


- (BOOL) containsDate:(NSDate *) date
{
   PMPeriod   *normalized;
   
   normalized = [self normalizedPeriod];

   return( [normalized->startDate_ compare:date] != NSOrderedDescending &&
           [normalized->endDate_ compare:date] != NSOrderedAscending);
}


- (id) copyWithZone:(NSZone *) zone
{
   return( [self retain]);
}


@end
