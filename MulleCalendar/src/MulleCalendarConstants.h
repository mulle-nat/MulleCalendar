//
// MulleCalendarConstants.h
// MulleCalendar
//
// Created by Pavel Mazurin on 7/14/12.
// Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//
// Usurped by Nat! on 1/22/13.
// Copyright (c) 2012 Nat! All rights reserved.
//
// This is still MIT licensed
//

extern NSString   *MulleCalendarRedrawNotification;

enum
{
   // MulleCalendarArrowDirectionNo      = -1, <- TBI
   MulleCalendarArrowDirectionUp    = 1UL << 0,
   MulleCalendarArrowDirectionDown  = 1UL << 1,
   MulleCalendarArrowDirectionLeft  = 1UL << 2,
   MulleCalendarArrowDirectionRight = 1UL << 3,
   MulleCalendarArrowDirectionAny   = MulleCalendarArrowDirectionUp | MulleCalendarArrowDirectionDown |
   MulleCalendarArrowDirectionLeft | MulleCalendarArrowDirectionRight,
   MulleCalendarArrowDirectionUnknown = NSUIntegerMax
};
typedef NSUInteger MulleCalendarArrowDirection;
