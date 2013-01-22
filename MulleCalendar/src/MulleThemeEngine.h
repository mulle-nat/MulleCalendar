//
// MulleThemeEngine.h
// MulleCalendar
//
// Created by Pavel Mazurin on 7/22/12.
// Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum MulleThemeElementType
{
   MulleThemeGeneralElementType = 0,
   MulleThemeBackgroundElementType,
   MulleThemeSeparatorsElementType,
   MulleThemeMonthArrowsElementType,
   MulleThemeMonthTitleElementType,
   MulleThemeDayTitlesElementType,
   MulleThemeCalendarDigitsActiveElementType,
   MulleThemeCalendarDigitsActiveSelectedElementType,
   MulleThemeCalendarDigitsInactiveElementType,
   MulleThemeCalendarDigitsInactiveSelectedElementType,
   MulleThemeCalendarDigitsTodayElementType,
   MulleThemeCalendarDigitsTodaySelectedElementType,
   MulleThemeSelectionElementType,
} MulleThemeElementType;


typedef enum MulleThemeElementSubtype
{
   MulleThemeNoSubtype = -1,
   MulleThemeBackgroundSubtype,
   MulleThemeMainSubtype,
   MulleThemeOverlaySubtype,
} MulleThemeElementSubtype;


typedef enum MulleThemeGenericType
{
   MulleThemeColorGenericType,
   MulleThemeFontGenericType,
   MulleThemeFontNameGenericType,
   MulleThemeFontSizeGenericType,
   MulleThemeFontTypeGenericType,
   MulleThemePositionGenericType,
   MulleThemeShadowGenericType,
   MulleThemeShadowBlurRadiusType,
   MulleThemeOffsetGenericType,
   MulleThemeOffsetHorizontalGenericType,
   MulleThemeOffsetVerticalGenericType,
   MulleThemeSizeInsetGenericType,
   MulleThemeSizeGenericType,
   MulleThemeSizeWidthGenericType,
   MulleThemeSizeHeightGenericType,
   MulleThemeStrokeGenericType,
   MulleThemeEdgeInsetsGenericType,
   MulleThemeEdgeInsetsTopGenericType,
   MulleThemeEdgeInsetsLeftGenericType,
   MulleThemeEdgeInsetsBottomGenericType,
   MulleThemeEdgeInsetsRightGenericType,
   MulleThemeCornerRadiusGenericType,
   MulleThemeCoordinatesRoundGenericType,
} MulleThemeGenericType;


@interface MulleThemeEngine : NSObject
{
@private
   NSDictionary   *dict_;
   
@protected
   NSString       *themeName_;
   
   // shortcuts derived from dict_
   UIFont         *defaultFont_;
   UIFont         *dayFont_;
   UIFont         *monthFont_;
   
   UIEdgeInsets   shadowInsets_;
   CGSize         innerPadding_;
   CGSize         outerPadding_;
   CGSize         arrowSize_;
   CGSize         defaultSize_;
   CGFloat        shadowBlurRadius_;
   CGFloat        headerHeight_;
   CGFloat        cornerRadius_;
   BOOL           dayTitlesInHeader_;
}

- (NSString *) themeName;  // rename to name

- (CGSize)  arrowSize;
- (CGFloat) cornerRadius;
- (BOOL)    dayTitlesInHeader;
- (CGSize)  defaultSize;
- (CGFloat) headerHeight;
- (CGSize)  innerPadding;
- (CGSize)  outerPadding;
- (CGFloat) shadowBlurRadius;
- (UIEdgeInsets) shadowInsets;

// lazy loaded fonts
- (UIFont *) defaultFont;
- (UIFont *) dayFont;
- (UIFont *) monthFont;

+ (MulleThemeEngine *) sharedInstance;
+ (UIColor *) colorFromString:(NSString *) colorString;

- (void) setThemeName:(NSString *) s;  // rename to name

- (void) drawString:(NSString *) string
           withFont:(UIFont *) font
             inRect:(CGRect) rect
     forElementType:(MulleThemeElementType) themeElementType
            subType:(MulleThemeElementSubtype) themeElementSubtype
          inContext:(CGContextRef) context;

- (void) drawPath:(UIBezierPath *) path
   forElementType:(MulleThemeElementType) themeElementType
          subType:(MulleThemeElementSubtype) themeElementSubtype
        inContext:(CGContextRef) context;

- (id) elementOfGenericType:(MulleThemeGenericType) genericType
                    subtype:(MulleThemeElementSubtype) subtype
                       type:(MulleThemeElementType) type;

- (NSDictionary *) themeDictForType:(MulleThemeElementType) type
                            subtype:(MulleThemeElementSubtype) subtype;

- (UIFont *) generateFontWithThemeDict:(NSDictionary *) info;

@end


@interface NSDictionary ( MulleThemeAddons)

- (id) pmElementInThemeDictOfGenericType:(MulleThemeGenericType) type;
- (CGSize) pmThemeGenerateSize;
- (UIEdgeInsets) pmThemeGenerateEdgeInsets;

@end
