//
// PMThemeShadow.m
// PMCalendar
//
// Created by Pavel Mazurin on 7/23/12.
// Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import "PMTheme.h"
#import "PMThemeEngine.h"
#import "PMThemeShadow.h"

@implementation PMThemeShadow

- (id) initWithDictionary:(NSDictionary *) shadowDict
{
   NSNumber   *nr;

   color_      = [[PMThemeEngine colorFromString:[shadowDict pmElementInThemeDictOfGenericType:PMThemeColorGenericType]] copy];
   offset_     = [[shadowDict pmElementInThemeDictOfGenericType:PMThemeOffsetGenericType] pmThemeGenerateSize];
   nr          = [shadowDict pmElementInThemeDictOfGenericType:PMThemeShadowBlurRadiusType];
   blurRadius_ = nr ? [nr floatValue] : PMThemeShadowBlurRadius();

   return (self);
}

- (UIColor *) color       { return( color_); }
- (CGSize)    offset      { return( offset_); }
- (CGFloat)   blurRadius  { return( blurRadius_); }

@end
