//
//  MulleTheme.h
//  MulleCalendar
//
//  Created by Pavel Mazurin on 7/19/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//
//
// Usurped by Nat! on 1/22/13.
// Copyright (c) 2012 Nat! All rights reserved.
//
// This is still MIT licensed
//

#import "MulleCalendarHelpers.h"
#import "MulleThemeEngine.h"


#warning (nat) get rid of all this madness

static CGSize   MulleThemeArrowSize( void)
{
   return( [[MulleThemeEngine sharedInstance] arrowSize]);
}


static CGFloat   MulleThemeCornerRadius( void)
{
   return( [[MulleThemeEngine sharedInstance] cornerRadius]);
}


static BOOL   MulleThemeDayTitlesInHeader( void)
{
   return( [[MulleThemeEngine sharedInstance] dayTitlesInHeader]);
}


static int   MulleThemeDayTitlesInHeaderIntOffset( void)
{
   return( MulleThemeDayTitlesInHeader() ? 0 : 1);
}


static UIFont   *MulleThemeDefaultFont( void)
{
   return( [[MulleThemeEngine sharedInstance] defaultFont]);
}


static CGFloat   MulleThemeHeaderHeight( void)
{
   return( [[MulleThemeEngine sharedInstance] headerHeight]);
}


static CGSize   MulleThemeInnerPadding( void)
{
   return( [[MulleThemeEngine sharedInstance] innerPadding]);
}


static CGSize   MulleThemeOuterPadding( void)
{
   return( [[MulleThemeEngine sharedInstance] outerPadding]);
}


static CGFloat   MulleThemeShadowBlurRadius( void)
{
   return( [[MulleThemeEngine sharedInstance] shadowBlurRadius]);
}


static UIEdgeInsets   MulleThemeShadowInsets( void)
{
   return( [[MulleThemeEngine sharedInstance] shadowInsets]);
}


