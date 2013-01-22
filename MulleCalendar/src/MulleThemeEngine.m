//
//  MulleThemeEngine.m
//  MulleCalendar
//
//  Created by Pavel Mazurin on 7/22/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//
//
// Usurped by Nat! on 1/22/13.
// Copyright (c) 2012 Nat! All rights reserved.
//
// This is still MIT licensed
//

#import "MulleThemeEngine.h"
#import "MulleCalendarHelpers.h"
#import <CoreText/CoreText.h>


@interface MulleThemeEngine ()

+ (NSString *) keyNameForElementSubtype:(MulleThemeElementSubtype) type;
+ (NSString *) keyNameForElementType:(MulleThemeElementType) type;
+ (NSString *) keyNameForGenericType:(MulleThemeGenericType) type;

@end


@implementation MulleThemeEngine

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

- (UIFont *) defaultFont
{
   NSDictionary   *info;
   
   if( ! defaultFont_)
   {
      info          = [self themeDictForType:MulleThemeGeneralElementType
                                     subtype:MulleThemeNoSubtype];
      info          = [info pmElementInThemeDictOfGenericType:MulleThemeFontGenericType];
      defaultFont_  = [[self generateFontWithThemeDict:info] retain];

      NSParameterAssert( defaultFont_);
   }
   return( defaultFont_);
}

//
// should I really cache this ???
//
- (UIFont *) dayFont
{
   NSDictionary   *info;
   
   if( ! dayFont_)
   {
      info     = [self elementOfGenericType:MulleThemeFontGenericType
                                    subtype:MulleThemeMainSubtype
                                       type:MulleThemeDayTitlesElementType];
      dayFont_ = [[self generateFontWithThemeDict:info] retain];
   }
   return( dayFont_);
}


- (UIFont *) monthFont
{
   NSDictionary   *info;
   
   if( ! monthFont_)
   {
      info       = [self elementOfGenericType:MulleThemeFontGenericType
                                      subtype:MulleThemeMainSubtype
                                         type:MulleThemeMonthTitleElementType];
      monthFont_ = [[self generateFontWithThemeDict:info] retain];
   }
   return( monthFont_);
}


+ (MulleThemeEngine *) sharedInstance
{
   static MulleThemeEngine   *sharedInstance;
   
   if( ! sharedInstance)
      sharedInstance = [MulleThemeEngine new];
   return( sharedInstance);
}


- (void) _lazyFonts
{
   [defaultFont_ release];
   defaultFont_ = nil;
   [dayFont_ release];
   dayFont_ = nil;
   [monthFont_ release];
   monthFont_ = nil;
}


- (void) dealloc
{
   [self _lazyFonts];

   [themeName_ release];
   [dict_ release];
   
   [super dealloc];
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
      color = [colElement pmElementInThemeDictOfGenericType:MulleThemeColorGenericType];
      pos   = [colElement pmElementInThemeDictOfGenericType:MulleThemePositionGenericType];
      
      [gradientColorsArray addObject:(id) [[MulleThemeEngine colorFromString:color] CGColor]];
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


+ (NSString *) keyNameForElementType: (MulleThemeElementType) type
{
   switch( type)
   {
   case MulleThemeGeneralElementType                        : return( @"General");
   case MulleThemeBackgroundElementType                     : return( @"Background");
   case MulleThemeSeparatorsElementType                     : return( @"Separators");
   case MulleThemeMonthTitleElementType                     : return( @"Month title");
   case MulleThemeDayTitlesElementType                      : return( @"Day titles");
   case MulleThemeCalendarDigitsActiveElementType           : return( @"Calendar digits active");
   case MulleThemeCalendarDigitsActiveSelectedElementType   : return( @"Calendar digits active selected");
   case MulleThemeCalendarDigitsInactiveElementType         : return( @"Calendar digits inactive");
   case MulleThemeCalendarDigitsInactiveSelectedElementType : return( @"Calendar digits inactive selected");
   case MulleThemeCalendarDigitsTodayElementType            : return( @"Calendar digits today");
   case MulleThemeCalendarDigitsTodaySelectedElementType    : return( @"Calendar digits today selected");
   case MulleThemeMonthArrowsElementType                    : return( @"Month arrows");
   case MulleThemeSelectionElementType                      : return( @"Selection");
   }
   
   return( nil);
}


+ (NSString *) keyNameForElementSubtype:(MulleThemeElementSubtype) type
{
   switch( type)
   {
   case MulleThemeBackgroundSubtype : return( @"Background");
   case MulleThemeMainSubtype       : return( @"Main");
   case MulleThemeOverlaySubtype    : return( @"Overlay");
   case MulleThemeNoSubtype         : ;
   }
   return( nil);
}

                   
+ (NSString *) keyNameForGenericType: (MulleThemeGenericType) type
{
   switch( type)
   {
   case MulleThemeColorGenericType            : return( @"Color");
   case MulleThemeCoordinatesRoundGenericType : return( @"Coordinates round");
   case MulleThemeCornerRadiusGenericType     : return( @"Corner radius");
   case MulleThemeEdgeInsetsBottomGenericType : return( @"Bottom");
   case MulleThemeEdgeInsetsGenericType       : return( @"Insets");
   case MulleThemeEdgeInsetsLeftGenericType   : return( @"Left");
   case MulleThemeEdgeInsetsRightGenericType  : return( @"Right");
   case MulleThemeEdgeInsetsTopGenericType    : return( @"Top");
   case MulleThemeFontGenericType             : return( @"Font");
   case MulleThemeFontNameGenericType         : return( @"Name");
   case MulleThemeFontSizeGenericType         : return( @"Size");
   case MulleThemeFontTypeGenericType         : return( @"Type");
   case MulleThemeOffsetGenericType           : return( @"Offset");
   case MulleThemeOffsetHorizontalGenericType : return( @"Horizontal");
   case MulleThemeOffsetVerticalGenericType   : return( @"Vertical");
   case MulleThemePositionGenericType         : return( @"Position");
   case MulleThemeShadowBlurRadiusType        : return( @"Blur radius");
   case MulleThemeShadowGenericType           : return( @"Shadow");
   case MulleThemeSizeGenericType             : return( @"Size");
   case MulleThemeSizeHeightGenericType       : return( @"Height");
   case MulleThemeSizeInsetGenericType        : return( @"Size inset");
   case MulleThemeSizeWidthGenericType        : return( @"Width");
   case MulleThemeStrokeGenericType           : return( @"Stroke");
   }
   return( nil);
}

- (void) _cacheGeneralSettings
{
   NSDictionary   *dict;

   dict = [self themeDictForType:MulleThemeGeneralElementType
                         subtype:MulleThemeNoSubtype];
   
   dayTitlesInHeader_ = [[dict objectForKey:@"Day titles in header"] boolValue];

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
   
   [self _lazyFonts];
   [self _cacheGeneralSettings];
}


- (void) drawString:(NSString *) string
           withFont:(UIFont *) font
             inRect:(CGRect) rect 
     forElementType:(MulleThemeElementType) themeElementType
            subType:(MulleThemeElementSubtype) themeElementSubtype
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
   NSDictionary            *info;
   NSDictionary            *shadowDict;
   NSDictionary            *themeDictionary;
   UIColor                 *shadowColor;
   UIFont                  *usedFont;
   id                      colorObj;   

   themeDictionary = [self themeDictForType:themeElementType
                                    subtype:themeElementSubtype];
   colorObj        = [themeDictionary pmElementInThemeDictOfGenericType:MulleThemeColorGenericType];
   shadowDict      = [themeDictionary pmElementInThemeDictOfGenericType:MulleThemeShadowGenericType];
   offset          = [[themeDictionary pmElementInThemeDictOfGenericType:MulleThemeOffsetGenericType] pmThemeGenerateSize];
   realRect        = CGRectOffset(rect, offset.width, offset.height);

#warning (nat) may want to cache fonts by name 
   usedFont     = font;
    if( ! usedFont)
    {
       info     = [themeDictionary pmElementInThemeDictOfGenericType:MulleThemeFontGenericType];
       usedFont = [self generateFontWithThemeDict:info];
    }
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
      shadowOffset = [[shadowDict pmElementInThemeDictOfGenericType:MulleThemeOffsetGenericType] pmThemeGenerateSize];
      shadowColor  = [MulleThemeEngine colorFromString:[shadowDict pmElementInThemeDictOfGenericType:MulleThemeColorGenericType]];
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
      
      [MulleThemeEngine drawGradientInContext:context
                                    inRect:CGRectMake( textPoint.x,
                                                      textPoint.y - [usedFont pointSize] + 1,
                                                      sz.width,
                                                      [usedFont pointSize])
                                 fromArray: colorObj];
   }
   else
   {
      CGContextSetTextDrawingMode(context, kCGTextFill);
      [[MulleThemeEngine colorFromString:colorObj] setFill];
      
      CTLineDraw( line, context);
   }
   
   CFRelease( line);
   /****/
   
   CGContextRestoreGState(context);
}


- (void) drawPath:(UIBezierPath *) path
   forElementType:(MulleThemeElementType) themeElementType
          subType:(MulleThemeElementSubtype) themeElementSubtype
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
   
   themeDictionary = [self themeDictForType:themeElementType
                                    subtype:themeElementSubtype];
   colorObj        = [themeDictionary pmElementInThemeDictOfGenericType:MulleThemeColorGenericType];
   
   shadowDict      = [themeDictionary pmElementInThemeDictOfGenericType:MulleThemeShadowGenericType];
   
   CGContextSaveGState(context);
   
   if (shadowDict)
   {
      shadowOffset = [[shadowDict pmElementInThemeDictOfGenericType:MulleThemeOffsetGenericType] pmThemeGenerateSize];
      shadowColor  = [MulleThemeEngine colorFromString:[shadowDict pmElementInThemeDictOfGenericType:MulleThemeColorGenericType]];
      blurRadius   = [shadowDict pmElementInThemeDictOfGenericType:MulleThemeShadowBlurRadiusType];
      
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
      [[MulleThemeEngine colorFromString:colorObj] setFill];
      
      [path fill];
   }
   else
   {
      [MulleThemeEngine drawGradientInContext:context
                                    inRect:[path bounds]
                                 fromArray:colorObj];
   }
   
   stroke = [themeDictionary pmElementInThemeDictOfGenericType:MulleThemeStrokeGenericType];
   
   if (stroke)
   {
      strokeColorStr = [stroke pmElementInThemeDictOfGenericType:MulleThemeColorGenericType];
      strokeColor    = [MulleThemeEngine colorFromString:strokeColorStr];
      [strokeColor setStroke];
      
      [path setLineWidth:[[stroke pmElementInThemeDictOfGenericType:MulleThemeSizeWidthGenericType] floatValue]]; // TODO: make separate stroke width generic type
      
      [path stroke];
   }
   
   CGContextRestoreGState(context);
}

#warning (nat) ugh...
- (id) elementOfGenericType:(MulleThemeGenericType) genericType
                    subtype:(MulleThemeElementSubtype) subtype
                       type:(MulleThemeElementType) type
{
    return( [[self themeDictForType:type
                            subtype:subtype] pmElementInThemeDictOfGenericType:genericType]);
}


- (NSDictionary *) themeDictForType:(MulleThemeElementType) type
                            subtype:(MulleThemeElementSubtype) subtype
{
   NSDictionary   *result;
   NSString       *key;
   
   key    = [MulleThemeEngine keyNameForElementType:type];
   result = [[self themeInfo] objectForKey:key];
   
   if( subtype != MulleThemeNoSubtype)
   {
      key    = [MulleThemeEngine keyNameForElementSubtype:subtype];
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


- (UIFont *) generateFontWithThemeDict:(NSDictionary *) info
{
   CGFloat    sizef;
   NSNumber   *size;
   NSString   *name;
   NSString   *type;
   
   size = [info pmElementInThemeDictOfGenericType:MulleThemeFontSizeGenericType];
   name = [info pmElementInThemeDictOfGenericType:MulleThemeFontNameGenericType];
   
   if( ! size)
      return( [self defaultFont]);
   
   NSParameterAssert( [size isKindOfClass:[NSNumber class]]);
   
   sizef = [size floatValue];
   
   if( name)
      return( [UIFont fontWithName:name
                              size:sizef]);
   
   type = [info pmElementInThemeDictOfGenericType:MulleThemeFontTypeGenericType];
   if ([type isEqualToString:@"bold"])
      return( [UIFont boldSystemFontOfSize:sizef]);
   
   return( [UIFont systemFontOfSize:sizef]);
}

@end


@implementation NSDictionary (MulleThemeAddons)

- (id) pmElementInThemeDictOfGenericType:(MulleThemeGenericType) type
{
   NSString  *key;
   
   key = [MulleThemeEngine keyNameForGenericType:type];
   return( [self objectForKey:key]);
}


- (CGSize) pmThemeGenerateSize
{
   NSNumber   *height;
   NSNumber   *width;
   
   width  = [self pmElementInThemeDictOfGenericType:MulleThemeSizeWidthGenericType];
   height = [self pmElementInThemeDictOfGenericType:MulleThemeSizeHeightGenericType];
   
   NSParameterAssert( ! width  || [width isKindOfClass:[NSNumber class]]);
   NSParameterAssert( ! height || [height isKindOfClass:[NSNumber class]]);
   
   return( CGSizeMake( [width floatValue], [height floatValue]));
}


- (UIEdgeInsets) pmThemeGenerateEdgeInsets
{
   NSNumber   *bottom;
   NSNumber   *left;
   NSNumber   *right;
   NSNumber   *top;
   
   top    = [self pmElementInThemeDictOfGenericType:MulleThemeEdgeInsetsTopGenericType];
   left   = [self pmElementInThemeDictOfGenericType:MulleThemeEdgeInsetsLeftGenericType];
   bottom = [self pmElementInThemeDictOfGenericType:MulleThemeEdgeInsetsBottomGenericType];
   right  = [self pmElementInThemeDictOfGenericType:MulleThemeEdgeInsetsRightGenericType];
   
   if( ! top || ! bottom || ! left || ! right)
      return( UIEdgeInsetsZero);
   
   NSParameterAssert( [top isKindOfClass:[NSNumber class]]);
   NSParameterAssert( [left isKindOfClass:[NSNumber class]]);
   NSParameterAssert( [bottom isKindOfClass:[NSNumber class]]);
   NSParameterAssert( [right isKindOfClass:[NSNumber class]]);
   
   return( UIEdgeInsetsMake([top floatValue], [left floatValue], [bottom floatValue], [right floatValue]));
}

@end

