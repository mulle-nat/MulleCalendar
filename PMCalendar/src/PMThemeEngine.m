//
//  PMThemeEngine.m
//  PMCalendar
//
//  Created by Pavel Mazurin on 7/22/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import "PMThemeEngine.h"
#import "PMCalendarHelpers.h"
#import <CoreText/CoreText.h>


@interface PMThemeEngine ()

+ (NSString *) keyNameForElementSubtype:(PMThemeElementSubtype) type;
+ (NSString *) keyNameForElementType:(PMThemeElementType) type;
+ (NSString *) keyNameForGenericType:(PMThemeGenericType) type;

@end


@implementation PMThemeEngine

- (NSString *) themeName      { return( themeName_); }  // rename to name
- (CGSize)  arrowSize         { return( arrowSize_); }
- (CGFloat) cornerRadius      { return( cornerRadius_); }
- (BOOL)    dayTitlesInHeader { return( dayTitlesInHeader_); }
- (CGSize)  defaultSize       { return( defaultSize_); }
- (CGFloat) headerHeight      { return( headerHeight_); }
- (CGSize)  innerPadding      { return( innerPadding_); }
- (CGSize)  outerPadding      { return( outerPadding_); }
- (CGFloat) shadowBlurRadius  { return( shadowBlurRadius_); }
- (UIEdgeInsets) shadowInsets { return( shadowInsets_); }
- (UIFont *) defaultFont      { return( defaultFont_); }


+ (PMThemeEngine *) sharedInstance
{
   static PMThemeEngine   *sharedInstance;
   
   if( ! sharedInstance)
      sharedInstance = [PMThemeEngine new];
   return( sharedInstance);
}


+ (UIColor *) colorFromString:(NSString *) colorString
{
   CGFloat   a;
   CGFloat   b;
   CGFloat   g;
   CGFloat   r;
   NSArray   *elements;
   
   if( ! colorString)
      return( nil);
   
   NSParameterAssert( [colorString isKindOfClass:[NSString class]]);
   
   if( [colorString hasSuffix:@".png"])
      return( [UIColor colorWithPatternImage:[UIImage imageNamed:colorString]]);
   
   elements = [colorString componentsSeparatedByString:@","];
   
   NSAssert([elements count] >= 3 && [elements count] <= 4, @"Wrong count of color components.");
   
   r = [[elements objectAtIndex:0] floatValue];
   g = [[elements objectAtIndex:1] floatValue];
   b = [[elements objectAtIndex:2] floatValue];
   a = [elements count] > 3 ? [[elements objectAtIndex:3] floatValue] : 1.0;
   
   
   return( pmMakeRGBAUIColor( r, g, b, a));
}


// draws vertical gradient
+ (void) drawGradientInContext:(CGContextRef) context
                        inRect:(CGRect) rect
                     fromArray:(NSArray *) gradientArray
{
   // TODO: ADD CACHING! May be expensive!
   CGColorSpaceRef   colorSpace;
   CGFloat           *gradientLocations;
   CGGradientRef     gradient;
   NSMutableArray    *gradientColorsArray;
   NSNumber          *pos;
   NSString          *color;
   int               i;
   int               n;
   
   n                   = [gradientArray count];
   gradientColorsArray = [NSMutableArray arrayWithCapacity:n];
   gradientLocations   = alloca( sizeof( CGFloat) * n);
   
   // TODO: ADD CACHING! May be expensive!
   i = 0;
   for( NSDictionary *colElement in gradientArray)
   {
      color = [colElement pmElementInThemeDictOfGenericType:PMThemeColorGenericType];
      pos   = [colElement pmElementInThemeDictOfGenericType:PMThemePositionGenericType];
      
      [gradientColorsArray addObject:(id) [[PMThemeEngine colorFromString:color] CGColor]];
      gradientLocations[ i] = 1 - [pos floatValue];
      i++;
   }
   
   colorSpace = CGColorSpaceCreateDeviceRGB();
   gradient   = CGGradientCreateWithColors( colorSpace, (CFArrayRef) gradientColorsArray, gradientLocations);
   
   CGContextDrawLinearGradient( context,
                                gradient,
                                CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height),
                                CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y),
                                0);
   CGGradientRelease( gradient);
   CGColorSpaceRelease( colorSpace);
}


+ (NSString *) keyNameForElementType: (PMThemeElementType) type
{
   switch( type)
   {
   case PMThemeGeneralElementType                        : return( @"General");
   case PMThemeBackgroundElementType                     : return( @"Background");
   case PMThemeSeparatorsElementType                     : return( @"Separators");
   case PMThemeMonthTitleElementType                     : return( @"Month title");
   case PMThemeDayTitlesElementType                      : return( @"Day titles");
   case PMThemeCalendarDigitsActiveElementType           : return( @"Calendar digits active");
   case PMThemeCalendarDigitsActiveSelectedElementType   : return( @"Calendar digits active selected");
   case PMThemeCalendarDigitsInactiveElementType         : return( @"Calendar digits inactive");
   case PMThemeCalendarDigitsInactiveSelectedElementType : return( @"Calendar digits inactive selected");
   case PMThemeCalendarDigitsTodayElementType            : return( @"Calendar digits today");
   case PMThemeCalendarDigitsTodaySelectedElementType    : return( @"Calendar digits today selected");
   case PMThemeMonthArrowsElementType                    : return( @"Month arrows");
   case PMThemeSelectionElementType                      : return( @"Selection");
   }
   
   return( nil);
}


+ (NSString *) keyNameForElementSubtype:(PMThemeElementSubtype) type
{
   switch( type)
   {
   case PMThemeBackgroundSubtype : return( @"Background");
   case PMThemeMainSubtype       : return( @"Main");
   case PMThemeOverlaySubtype    : return( @"Overlay");
   case PMThemeNoSubtype         : ;
   }
   return( nil);
}

                   
+ (NSString *) keyNameForGenericType: (PMThemeGenericType) type
{
   switch( type)
   {
   case PMThemeColorGenericType            : return( @"Color");
   case PMThemeCoordinatesRoundGenericType : return( @"Coordinates round");
   case PMThemeCornerRadiusGenericType     : return( @"Corner radius");
   case PMThemeEdgeInsetsBottomGenericType : return( @"Bottom");
   case PMThemeEdgeInsetsGenericType       : return( @"Insets");
   case PMThemeEdgeInsetsLeftGenericType   : return( @"Left");
   case PMThemeEdgeInsetsRightGenericType  : return( @"Right");
   case PMThemeEdgeInsetsTopGenericType    : return( @"Top");
   case PMThemeFontGenericType             : return( @"Font");
   case PMThemeFontNameGenericType         : return( @"Name");
   case PMThemeFontSizeGenericType         : return( @"Size");
   case PMThemeFontTypeGenericType         : return( @"Type");
   case PMThemeOffsetGenericType           : return( @"Offset");
   case PMThemeOffsetHorizontalGenericType : return( @"Horizontal");
   case PMThemeOffsetVerticalGenericType   : return( @"Vertical");
   case PMThemePositionGenericType         : return( @"Position");
   case PMThemeShadowBlurRadiusType        : return( @"Blur radius");
   case PMThemeShadowGenericType           : return( @"Shadow");
   case PMThemeSizeGenericType             : return( @"Size");
   case PMThemeSizeHeightGenericType       : return( @"Height");
   case PMThemeSizeInsetGenericType        : return( @"Size inset");
   case PMThemeSizeWidthGenericType        : return( @"Width");
   case PMThemeStrokeGenericType           : return( @"Stroke");
   }
   return( nil);
}


- (void) _cacheGeneralSettings
{
   NSDictionary   *dict;
   
   dict = [self themeDictForType:PMThemeGeneralElementType
                         subtype:PMThemeNoSubtype];
   
   dayTitlesInHeader_ = [[dict objectForKey:@"Day titles in header"] boolValue];

   [defaultFont_ autorelease];
   defaultFont_       = [[[dict pmElementInThemeDictOfGenericType:PMThemeFontGenericType] pmThemeGenerateFont] retain];
   
   arrowSize_         = [[dict objectForKey:@"Arrow size"] pmThemeGenerateSize];
   defaultSize_       = [[dict objectForKey:@"Default size"] pmThemeGenerateSize];
   cornerRadius_      = [[dict objectForKey:@"Corner radius"] floatValue];
   headerHeight_      = [[dict objectForKey:@"Header height"] floatValue];
   outerPadding_      = [[dict objectForKey:@"Outer padding"] pmThemeGenerateSize];
   innerPadding_      = [[dict objectForKey:@"Inner padding"] pmThemeGenerateSize];
   shadowInsets_      = [[dict objectForKey:@"Shadow insets"] pmThemeGenerateEdgeInsets];
   shadowBlurRadius_  = [[dict objectForKey:@"Shadow blur radius"] floatValue];
}


- (void) setThemeName:(NSString *) themeName
{
   NSDictionary   *plist;
   NSString       *filePath;
   
   if( [themeName_ isEqualToString:themeName])
      return;
   
   [themeName_ autorelease];
   themeName_ = [themeName copy];

   filePath   = [[NSBundle mainBundle] pathForResource:themeName
                                                ofType:@"plist"];
   plist      = [NSDictionary dictionaryWithContentsOfFile:filePath];

   NSParameterAssert( plist);
   [dict_ autorelease];
   dict_ = [plist retain];
   
   [self _cacheGeneralSettings];
}


- (void) drawString:(NSString *) string
           withFont:(UIFont *) font
             inRect:(CGRect) rect 
     forElementType:(PMThemeElementType) themeElementType
            subType:(PMThemeElementSubtype) themeElementSubtype
          inContext:(CGContextRef) context
{
   // Create an attributed string
   BOOL                    isGradient;
   CFAttributedStringRef   attrString;
   CFDictionaryRef         attr;
   CFStringRef             keys[ 2];
   CFTypeRef               values[ 2];
   CGPoint                 textPoint;
   CGRect                  realRect;
   CGSize                  offset;
   CGSize                  shadowOffset;
   CGSize                  sz;
   CTFontRef               ctFont;
   CTLineRef               line;
   NSDictionary            *shadowDict;
   NSDictionary            *themeDictionary;
   UIColor                 *shadowColor;
   UIFont                  *usedFont;
   id                      colorObj;   

   themeDictionary = [[PMThemeEngine sharedInstance] themeDictForType:themeElementType
                                                                             subtype:themeElementSubtype];
   colorObj        = [themeDictionary pmElementInThemeDictOfGenericType:PMThemeColorGenericType];
   shadowDict      = [themeDictionary pmElementInThemeDictOfGenericType:PMThemeShadowGenericType];
   offset          = [[themeDictionary pmElementInThemeDictOfGenericType:PMThemeOffsetGenericType] pmThemeGenerateSize];
   realRect        = CGRectOffset(rect, offset.width, offset.height);

   usedFont        = font;
    if( ! usedFont)
       usedFont = [[themeDictionary pmElementInThemeDictOfGenericType:PMThemeFontGenericType] pmThemeGenerateFont];

    if( ! usedFont)
       usedFont = [self defaultFont];

    NSAssert( usedFont != nil, @"Please provide proper font either in theme file or in a code.");
    
    sz           = [string sizeWithFont:usedFont];
    isGradient   = ! [colorObj isKindOfClass:[NSString class]];
    shadowOffset = CGSizeZero;

   CGContextSaveGState(context);

   /****/
   if (shadowDict)
   {
      shadowOffset = [[shadowDict pmElementInThemeDictOfGenericType:PMThemeOffsetGenericType] pmThemeGenerateSize];
      shadowColor  = [PMThemeEngine colorFromString:[shadowDict pmElementInThemeDictOfGenericType:PMThemeColorGenericType]];
      [shadowColor set];
   }
   
   textPoint = CGPointMake((int)(realRect.origin.x + (realRect.size.width - sz.width) / 2)
                           , (int)(realRect.origin.y + realRect.size.height - 1));
   
   ctFont     = CTFontCreateWithName( (CFStringRef) [usedFont fontName], usedFont.pointSize, NULL);
   
   keys[ 0]   = kCTFontAttributeName;
   keys[ 1]   = kCTForegroundColorFromContextAttributeName;
   values[ 0] = ctFont;
   values[ 1] = kCFBooleanTrue;
   
   // Create an attributed string
   attr       = CFDictionaryCreate( NULL,
                                   (void *) &keys,
                                   (void *) &values,
                                   sizeof( keys) / sizeof( keys[0]),
                                   &kCFTypeDictionaryKeyCallBacks,
                                   &kCFTypeDictionaryValueCallBacks);
   
   attrString = CFAttributedStringCreate( NULL, (CFStringRef) string, attr);
   CFRelease( attr);
   CFRelease( ctFont);
   
   // Draw the string
   line = CTLineCreateWithAttributedString( attrString);
   CFRelease( attrString);

   CGContextSetTextMatrix( context, CGAffineTransformIdentity);  //Use this one when using standard view coordinates
   CGContextSetTextMatrix( context, CGAffineTransformMakeScale( 1.0, -1.0)); //Use this one if the view's coordinates are flipped
   
   if( ! CGSizeEqualToSize( shadowOffset, CGSizeZero))
   {
      CGContextSetTextPosition( context,
                               textPoint.x + shadowOffset.width,
                               textPoint.y + shadowOffset.height);
      CGContextSetTextDrawingMode( context, kCGTextFill);
      CTLineDraw( line, context);
   }
   
   CGContextSetTextPosition( context, textPoint.x, textPoint.y);
   
   // Clean up
   if( isGradient)
   {
      CGContextSetTextDrawingMode(context, kCGTextClip);
      CTLineDraw( line, context);
      
      [PMThemeEngine drawGradientInContext:context
                                    inRect:CGRectMake( textPoint.x,
                                                      textPoint.y - [usedFont pointSize] + 1,
                                                      sz.width,
                                                      [usedFont pointSize])
                                 fromArray: colorObj];
   }
   else
   {
      CGContextSetTextDrawingMode(context, kCGTextFill);
      [[PMThemeEngine colorFromString:colorObj] setFill];
      
      CTLineDraw( line, context);
   }
   
   CFRelease( line);
   /****/
   
   CGContextRestoreGState(context);
}


- (void) drawPath:(UIBezierPath *) path
   forElementType:(PMThemeElementType) themeElementType
          subType:(PMThemeElementSubtype) themeElementSubtype
        inContext:(CGContextRef) context
{
   CGSize         shadowOffset;
   NSDictionary   *shadowDict;
   NSDictionary   *stroke;
   NSDictionary   *themeDictionary;
   NSNumber       *blurRadius;
   NSString       *strokeColorStr;
   UIColor        *shadowColor;
   UIColor        *strokeColor;
   id             colorObj;
   
   themeDictionary = [[PMThemeEngine sharedInstance] themeDictForType:themeElementType
                                                              subtype:themeElementSubtype];
   colorObj        = [themeDictionary pmElementInThemeDictOfGenericType:PMThemeColorGenericType];
   
   shadowDict      = [themeDictionary pmElementInThemeDictOfGenericType:PMThemeShadowGenericType];
   
   CGContextSaveGState(context);
   
   if (shadowDict)
   {
      shadowOffset = [[shadowDict pmElementInThemeDictOfGenericType:PMThemeOffsetGenericType] pmThemeGenerateSize];
      shadowColor  = [PMThemeEngine colorFromString:[shadowDict pmElementInThemeDictOfGenericType:PMThemeColorGenericType]];
      blurRadius   = [shadowDict pmElementInThemeDictOfGenericType:PMThemeShadowBlurRadiusType];
      
      CGContextSetShadowWithColor( context
                                  , shadowOffset
                                  , blurRadius ? [blurRadius floatValue] : [self shadowBlurRadius]
                                  , [shadowColor CGColor]);
      
      if( ! [shadowDict objectForKey:@"Type"])
      {
         [shadowColor setFill];
         [path fill];
      }
   }
   
   if( ! [shadowDict objectForKey:@"Type"])
   {
      CGContextRestoreGState(context);
      CGContextSaveGState(context);
   }
   
   [path addClip];
   
   if( [colorObj isKindOfClass:[NSString class]]) // plain color
   {
      [[PMThemeEngine colorFromString:colorObj] setFill];
      
      [path fill];
   }
   else
   {
      [PMThemeEngine drawGradientInContext:context
                                    inRect:[path bounds]
                                 fromArray:colorObj];
   }
   
   stroke = [themeDictionary pmElementInThemeDictOfGenericType:PMThemeStrokeGenericType];
   
   if (stroke)
   {
      strokeColorStr = [stroke pmElementInThemeDictOfGenericType:PMThemeColorGenericType];
      strokeColor    = [PMThemeEngine colorFromString:strokeColorStr];
      [strokeColor setStroke];
      
      [path setLineWidth:[[stroke pmElementInThemeDictOfGenericType:PMThemeSizeWidthGenericType] floatValue]]; // TODO: make separate stroke width generic type
      
      [path stroke];
   }
   
   CGContextRestoreGState(context);
}


- (id) elementOfGenericType:(PMThemeGenericType) genericType
                    subtype:(PMThemeElementSubtype) subtype
                       type:(PMThemeElementType) type
{
    return( [[[PMThemeEngine sharedInstance] themeDictForType:type
                                                     subtype:subtype] pmElementInThemeDictOfGenericType:genericType]);
}


- (NSDictionary *) themeDictForType:(PMThemeElementType) type
                            subtype:(PMThemeElementSubtype) subtype
{
   NSDictionary   *result;
   NSString       *key;
   
   key    = [PMThemeEngine keyNameForElementType:type];
   result = [[self themeInfo] objectForKey:key];
   
   if( subtype != PMThemeNoSubtype)
   {
      key    = [PMThemeEngine keyNameForElementSubtype:subtype];
      result = [result objectForKey:key];
   }
   
   NSParameterAssert( ! result || [result isKindOfClass:[NSDictionary class]]);
   return( result);
}


- (NSDictionary *) themeInfo
{
   if( ! dict_)
      [self setThemeName:@"default"];
   
   NSParameterAssert( [dict_ isKindOfClass:[NSDictionary class]]);
   return( dict_);
}

@end


@implementation NSDictionary (PMThemeAddons)

- (id) pmElementInThemeDictOfGenericType:(PMThemeGenericType) type
{
   NSString  *key;
   
   key = [PMThemeEngine keyNameForGenericType:type];
   return( [self objectForKey:key]);
}


- (CGSize) pmThemeGenerateSize
{
   NSNumber   *height;
   NSNumber   *width;
   
   width  = [self pmElementInThemeDictOfGenericType:PMThemeSizeWidthGenericType];
   height = [self pmElementInThemeDictOfGenericType:PMThemeSizeHeightGenericType];
   
   NSParameterAssert( ! width  || [width isKindOfClass:[NSNumber class]]);
   NSParameterAssert( ! height || [height isKindOfClass:[NSNumber class]]);
   
   return( CGSizeMake( [width floatValue], [height floatValue]));
}


- (UIFont *) pmThemeGenerateFont
{
   CGFloat    sizef;
   NSNumber   *size;
   NSString   *name;
   NSString   *type;
   
   size = [self pmElementInThemeDictOfGenericType:PMThemeFontSizeGenericType];
   name = [self pmElementInThemeDictOfGenericType:PMThemeFontNameGenericType];
   
   if( ! size)
      return( [PMThemeEngine sharedInstance].defaultFont);
   
   NSParameterAssert( [size isKindOfClass:[NSNumber class]]);
   
   sizef = [size floatValue];
   
   if( name)
      return( [UIFont fontWithName:name
                              size:sizef]);

   type = [self pmElementInThemeDictOfGenericType:PMThemeFontTypeGenericType];
   if ([type isEqualToString:@"bold"])
      return( [UIFont boldSystemFontOfSize:sizef]);
      
   return( [UIFont systemFontOfSize:sizef]);
}


- (UIEdgeInsets) pmThemeGenerateEdgeInsets
{
   NSNumber   *bottom;
   NSNumber   *left;
   NSNumber   *right;
   NSNumber   *top;
   
   top    = [self pmElementInThemeDictOfGenericType:PMThemeEdgeInsetsTopGenericType];
   left   = [self pmElementInThemeDictOfGenericType:PMThemeEdgeInsetsLeftGenericType];
   bottom = [self pmElementInThemeDictOfGenericType:PMThemeEdgeInsetsBottomGenericType];
   right  = [self pmElementInThemeDictOfGenericType:PMThemeEdgeInsetsRightGenericType];
   
   if( ! top || ! bottom || ! left || ! right)
      return( UIEdgeInsetsZero);
   
   NSParameterAssert( [top isKindOfClass:[NSNumber class]]);
   NSParameterAssert( [left isKindOfClass:[NSNumber class]]);
   NSParameterAssert( [bottom isKindOfClass:[NSNumber class]]);
   NSParameterAssert( [right isKindOfClass:[NSNumber class]]);
   
   return( UIEdgeInsetsMake([top floatValue], [left floatValue], [bottom floatValue], [right floatValue]));
}

@end

