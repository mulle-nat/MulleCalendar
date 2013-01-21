//
//  PMTheme.h
//  PMCalendar
//
//  Created by Pavel Mazurin on 7/19/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import "PMCalendarHelpers.h"
#import "PMThemeEngine.h"


static CGSize   PMThemeArrowSize( void)
{
   return( [[PMThemeEngine sharedInstance] arrowSize]);
}


static CGFloat   PMThemeCornerRadius( void)
{
   return( [[PMThemeEngine sharedInstance] cornerRadius]);
}


static BOOL   PMThemeDayTitlesInHeader( void)
{
   return( [[PMThemeEngine sharedInstance] dayTitlesInHeader]);
}


static int   PMThemeDayTitlesInHeaderIntOffset( void)
{
   return( PMThemeDayTitlesInHeader() ? 0 : 1);
}


static UIFont   *PMThemeDefaultFont( void)
{
   return( [[PMThemeEngine sharedInstance] defaultFont]);
}


static CGFloat   PMThemeHeaderHeight( void)
{
   return( [[PMThemeEngine sharedInstance] headerHeight]);
}


static CGSize   PMThemeInnerPadding( void)
{
   return( [[PMThemeEngine sharedInstance] innerPadding]);
}


static CGSize   PMThemeOuterPadding( void)
{
   return( [[PMThemeEngine sharedInstance] outerPadding]);
}


static CGFloat   PMThemeShadowBlurRadius( void)
{
   return( [[PMThemeEngine sharedInstance] shadowBlurRadius]);
}


static UIEdgeInsets   PMThemeShadowInsets( void)
{
   return( [[PMThemeEngine sharedInstance] shadowInsets]);
}


