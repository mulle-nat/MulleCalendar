//
// PMCalendarHelpers.h
// PMCalendar
//
// Created by Pavel Mazurin on 7/18/12.
// Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import "NSDate+Helpers.h"

// Geometry helpers

static inline float radians(double degrees)
{
   return( degrees * M_PI / 180);
}


static inline CGPoint   pmOffsetPointByXY( CGPoint originalPoint, CGFloat dx, CGFloat dy)
{
   return( CGPointMake(originalPoint.x + dx, originalPoint.y + dy));
}


static inline CGPoint   pmOffsetPointByPoint( CGPoint originalPoint, CGPoint offsetPoint)
{
   return( pmOffsetPointByXY( originalPoint, offsetPoint.x, offsetPoint.y));
}


static inline CGPoint   pmOffsetPointBySize( CGPoint originalPoint, CGSize offsetSize)
{
   return( pmOffsetPointByXY( originalPoint, offsetSize.width, offsetSize.height));
}



static inline UIColor   *pmMakeRGBAUIColor( float r, float g, float b, float a)
{
   return( [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:a]);  // << ??
}

static inline UIColor   *pmMakeRGBUIColor( float r, float g, float b)
{
   return( pmMakeRGBAUIColor( r, g, b, 1.0f));
}


