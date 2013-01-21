//
// PMThemeEngine.h
// PMCalendar
//
// Created by Pavel Mazurin on 7/22/12.
// Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum PMThemeElementType
{
   PMThemeGeneralElementType = 0,
   PMThemeBackgroundElementType,
   PMThemeSeparatorsElementType,
   PMThemeMonthArrowsElementType,
   PMThemeMonthTitleElementType,
   PMThemeDayTitlesElementType,
   PMThemeCalendarDigitsActiveElementType,
   PMThemeCalendarDigitsActiveSelectedElementType,
   PMThemeCalendarDigitsInactiveElementType,
   PMThemeCalendarDigitsInactiveSelectedElementType,
   PMThemeCalendarDigitsTodayElementType,
   PMThemeCalendarDigitsTodaySelectedElementType,
   PMThemeSelectionElementType,
} PMThemeElementType;


typedef enum PMThemeElementSubtype
{
   PMThemeNoSubtype = -1,
   PMThemeBackgroundSubtype,
   PMThemeMainSubtype,
   PMThemeOverlaySubtype,
} PMThemeElementSubtype;


typedef enum PMThemeGenericType
{
   PMThemeColorGenericType,
   PMThemeFontGenericType,
   PMThemeFontNameGenericType,
   PMThemeFontSizeGenericType,
   PMThemeFontTypeGenericType,
   PMThemePositionGenericType,
   PMThemeShadowGenericType,
   PMThemeShadowBlurRadiusType,
   PMThemeOffsetGenericType,
   PMThemeOffsetHorizontalGenericType,
   PMThemeOffsetVerticalGenericType,
   PMThemeSizeInsetGenericType,
   PMThemeSizeGenericType,
   PMThemeSizeWidthGenericType,
   PMThemeSizeHeightGenericType,
   PMThemeStrokeGenericType,
   PMThemeEdgeInsetsGenericType,
   PMThemeEdgeInsetsTopGenericType,
   PMThemeEdgeInsetsLeftGenericType,
   PMThemeEdgeInsetsBottomGenericType,
   PMThemeEdgeInsetsRightGenericType,
   PMThemeCornerRadiusGenericType,
   PMThemeCoordinatesRoundGenericType,
} PMThemeGenericType;


@interface PMThemeEngine : NSObject
{
@private
   NSDictionary   *dict_;
   
@protected
   NSString       *themeName_;
   
   UIFont         *defaultFont_;
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
- (UIFont *) defaultFont;

+ (PMThemeEngine *) sharedInstance;
+ (UIColor *) colorFromString:(NSString *) colorString;

- (void) setThemeName:(NSString *) s;  // rename to name

- (void) drawString:(NSString *) string
           withFont:(UIFont *) font
             inRect:(CGRect) rect
     forElementType:(PMThemeElementType) themeElementType
            subType:(PMThemeElementSubtype) themeElementSubtype
          inContext:(CGContextRef) context;

- (void) drawPath:(UIBezierPath *) path
   forElementType:(PMThemeElementType) themeElementType
          subType:(PMThemeElementSubtype) themeElementSubtype
        inContext:(CGContextRef) context;

- (id) elementOfGenericType:(PMThemeGenericType) genericType
                    subtype:(PMThemeElementSubtype) subtype
                       type:(PMThemeElementType) type;

- (NSDictionary *) themeDictForType:(PMThemeElementType) type
                            subtype:(PMThemeElementSubtype) subtype;

@end

@interface NSDictionary ( PMThemeAddons)

- (id) pmElementInThemeDictOfGenericType:(PMThemeGenericType) type;
- (CGSize) pmThemeGenerateSize;
// UIOffset is available from iOS 5.0 :(. Using CGSize instead.
// - (UIOffset) pmThemeGenerateOffset;
- (UIEdgeInsets) pmThemeGenerateEdgeInsets;
- (UIFont *) pmThemeGenerateFont;

@end
