//
// MulleThemeShadow.m
// MulleCalendar
//
// Created by Pavel Mazurin on 7/23/12.
// Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import "MulleTheme.h"
#import "MulleThemeEngine.h"
#import "MulleThemeShadow.h"

@implementation MulleThemeShadow

- (id) initWithDictionary:(NSDictionary *) shadowDict
{
   NSNumber   *nr;
   NSString   *s;
   
   s           = [shadowDict pmElementInThemeDictOfGenericType:MulleThemeColorGenericType];
   color_      = [[MulleThemeEngine colorFromString:s] retain];
   offset_     = [[shadowDict pmElementInThemeDictOfGenericType:MulleThemeOffsetGenericType] pmThemeGenerateSize];
   nr          = [shadowDict pmElementInThemeDictOfGenericType:MulleThemeShadowBlurRadiusType];
   blurRadius_ = nr ? [nr floatValue] : MulleThemeShadowBlurRadius();

   return (self);
}


- (void) dealloc
{
   [color_ release];

   [super dealloc];
}


- (UIColor *) color       { return( color_); }
- (CGSize)    offset      { return( offset_); }
- (CGFloat)   blurRadius  { return( blurRadius_); }

@end
