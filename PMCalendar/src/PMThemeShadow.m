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

@synthesize color      = _color;
@synthesize offset     = _offset;
@synthesize blurRadius = _blurRadius;

- (id) initWithShadowDict:(NSDictionary *) shadowDict
{
   NSNumber   *blurRadiusNumber;
   float      radius;

   [super init];

   [self setColor:[PMThemeEngine colorFromString:[shadowDict elementInThemeDictOfGenericType:PMThemeColorGenericType]]];
   [self setOffset:[[shadowDict elementInThemeDictOfGenericType:PMThemeOffsetGenericType] pmThemeGenerateSize]];

   blurRadiusNumber = [shadowDict elementInThemeDictOfGenericType:PMThemeShadowBlurRadiusType];
   radius           = blurRadiusNumber ? [blurRadiusNumber floatValue] : kPMThemeShadowBlurRadius;

   [self setBlurRadius:radius];


   return(self);
}


@end
