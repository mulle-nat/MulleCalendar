//
// PMSelectionView.m
// PMCalendar
//
// Created by Pavel Mazurin on 7/14/12.
// Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import "PMCalendarConstants.h"
#import "PMSelectionView.h"
#import "PMTheme.h"


@implementation PMSelectionView

- (id) initWithFrame:(CGRect) frame
{
   if( ! (self = [super initWithFrame:frame]))
      return( nil);

   [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

   [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector( redrawComponent )
                                                name:PMCalendarRedrawNotification
                                              object:nil];

   [self setBackgroundColor:[UIColor clearColor]];

   initialFrame_ = frame;

   return( self);
}


- (void) dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   [super dealloc];
}


- (void) redrawComponent
{
   [self setNeedsDisplay];
}


- (NSInteger) startIndex
{
   return( startIndex_);
}


- (NSInteger) endIndex
{
   return( endIndex_);
}


- (void) drawRect:(CGRect) dirtyRect
{
   CGContextRef   context;
   CGFloat        headerHeight;
   CGFloat        cornerRadius;
   CGFloat        hDiff;
   CGFloat        height;
   CGFloat        vDiff;
   CGFloat         width;
   CGSize         innerPadding;
   CGRect         rect;
   NSString       *coordinatesRound;
   PMThemeEngine  *themer;
   UIEdgeInsets   rectInset;
   UIEdgeInsets   shadowPadding;
   UIBezierPath   *selectedRectPath;
   int            colEnd;
   int            colStart;
   int            rowEnd;
   int            rowStart;
   int            tempEnd;
   int            tempStart;
   int            thisRowStartCell;
   int            thisRowEndCell;
   
   if( startIndex_ < 0 && endIndex_ < 0)
      return;
   
   context = UIGraphicsGetCurrentContext();
   themer  = [PMThemeEngine sharedInstance];
   
   cornerRadius = [[themer elementOfGenericType:PMThemeCornerRadiusGenericType
                                        subtype:PMThemeBackgroundSubtype
                                           type:PMThemeSelectionElementType]
                   floatValue];
   
   shadowPadding = PMThemeShadowInsets();
   innerPadding  = PMThemeInnerPadding();
   headerHeight  = PMThemeHeaderHeight();
   
   width         = initialFrame_.size.width;
   height        = initialFrame_.size.height;
   hDiff         = (width + shadowPadding.left + shadowPadding.right - innerPadding.width * 2) / 7;
   vDiff         = (height - headerHeight - innerPadding.height * 2) / (PMThemeDayTitlesInHeaderIntOffset() + 6);
   
   
   coordinatesRound = [themer elementOfGenericType:PMThemeCoordinatesRoundGenericType
                                           subtype:PMThemeBackgroundSubtype
                                              type:PMThemeSelectionElementType];
   
   if( coordinatesRound)
   {
      if( [coordinatesRound isEqualToString:@"ceil"])
      {
         hDiff = ceil( hDiff);
         vDiff = ceil( vDiff);
      }
      else if( [coordinatesRound isEqualToString:@"floor"])
      {
         hDiff = floor( hDiff);
         vDiff = floor( vDiff);
      }
   }
   
   tempStart = MAX( MIN( startIndex_, endIndex_), 0);
   tempEnd   = MAX( startIndex_, endIndex_);
   
   rowStart  = tempStart / 7;
   rowEnd    = tempEnd / 7;
   colStart  = tempStart % 7;
   colEnd    = tempEnd % 7;
   rectInset = [[themer elementOfGenericType:PMThemeEdgeInsetsGenericType
                                                             subtype:PMThemeBackgroundSubtype
                                                                type:PMThemeSelectionElementType]
                pmThemeGenerateEdgeInsets];
   
   for( int i = rowStart; i <= rowEnd; i++)
   {
      //// selectedRect Drawing
      thisRowStartCell = 0;
      thisRowEndCell   = 6;
      
      if( rowStart == i)
         thisRowStartCell = colStart;
      
      if( rowEnd == i)
         thisRowEndCell = colEnd;
      
      //// selectedRect Drawing
      rect = CGRectMake(innerPadding.width + floor(thisRowStartCell * hDiff),
                        innerPadding.height + headerHeight + floor((i + PMThemeDayTitlesInHeaderIntOffset()) * vDiff),
                        floor((thisRowEndCell - thisRowStartCell + 1) * hDiff),
                        floor(vDiff));
      rect = UIEdgeInsetsInsetRect(rect, rectInset);
      
      selectedRectPath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                    cornerRadius:cornerRadius];
      [themer drawPath:selectedRectPath
        forElementType:PMThemeSelectionElementType
               subType:PMThemeBackgroundSubtype
             inContext:context];
   }
}


- (void) setStartIndex:(NSInteger) startIndex
{
   if( startIndex_ != startIndex)
   {
      startIndex_ = startIndex;
      [self setNeedsDisplay];
   }
}


- (void) setEndIndex:(NSInteger) endIndex
{
   if( endIndex_ != endIndex)
   {
      endIndex_ = endIndex;
      [self setNeedsDisplay];
   }
}


@end
