//
// PMCalendarBackgroundView.m
// PMCalendar
//
// Created by Pavel Mazurin on 7/13/12.
// Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import "PMCalendarBackgroundView.h"
#import "PMCalendarConstants.h"
#import "PMCalendarHelpers.h"
#import "PMTheme.h"
#import "PMThemeShadow.h"

@interface PMCalendarBackgroundView ()

@property (nonatomic, assign) CGRect   initialFrame;
- (void) redrawComponent;

@end

@implementation PMCalendarBackgroundView

@synthesize arrowDirection = _arrowDirection;
@synthesize arrowPosition  = _arrowPosition;
@synthesize initialFrame   = _initialFrame;

#pragma mark - UIView overridden methods -


- (id) initWithFrame:(CGRect) frame
{
   if( ! (self = [super initWithFrame:frame]))
      return( self);

   [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

   [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector( redrawComponent )
                                                name:PMCalendarRedrawNotification
                                              object:nil];
   
   [self setBackgroundColor:[UIColor clearColor]];
   [self setInitialFrame:frame];

   return( self);
}


- (void) dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   [super dealloc];
}


#pragma mark - component drawing management -

- (void) redrawComponent
{
   [self setNeedsDisplay];
}


// Returns background bezier path with arrow pointing to a given
// arrowDirection and arrowPosition (top corner of a triangle).
+ (UIBezierPath *) createBezierPathForSize:(CGSize) size
                            arrowDirection:(PMCalendarArrowDirection) direction
                             arrowPosition:(CGPoint) arrowPosition
{
   CGFloat        cornerRadius;
   CGFloat        height;
   CGFloat        width;
   CGPoint        endArrowPoint;
   CGPoint        offset;
   CGPoint        startArrowPoint;
   CGPoint        tl;
   CGPoint        topArrowPoint;
   CGRect         pathRect;
   CGSize         arrowSize;
   UIBezierPath   *result;
   UIEdgeInsets   shadowPadding;
   
   arrowSize     = PMThemeArrowSize();
   result        = nil;
   width         = size.width;
   height        = size.height;
   shadowPadding = PMThemeShadowInsets();
   cornerRadius  = PMThemeCornerRadius();
   
   width        -= shadowPadding.left + shadowPadding.right;
   height       -= shadowPadding.top + shadowPadding.bottom;
   
   if( arrowSize.height == 0)
   {
      pathRect = CGRectMake(shadowPadding.top
                            , shadowPadding.left
                            , width
                            , height);
      
      if( cornerRadius > 0)
         return([UIBezierPath bezierPathWithRoundedRect:pathRect
                                           cornerRadius:cornerRadius]);
      return( [UIBezierPath bezierPathWithRect:pathRect]);
   }

   result           = [UIBezierPath bezierPath];
   startArrowPoint = CGPointZero;
   endArrowPoint   = CGPointZero;
   topArrowPoint   = CGPointZero;
   offset          = CGPointMake(shadowPadding.top, shadowPadding.left);
   tl              = CGPointZero;

   switch( direction)
   {
   case PMCalendarArrowDirectionUp :      // going from right side to the left
                                         // so start point is a bottom RIGHT point of a triangle ^. this one :)
      startArrowPoint = CGPointMake( arrowSize.width / 2, arrowSize.height);
      endArrowPoint   = CGPointMake( -arrowSize.width / 2, arrowSize.height);
      offset          = CGPointOffset( offset, arrowPosition.x, 0);
      tl.y            = arrowSize.height;
      break;

   case PMCalendarArrowDirectionDown :      // going from left to right
                                           // so start point is a top LEFT point of a triangle - 'V
      startArrowPoint = CGPointMake( -arrowSize.width / 2, -arrowSize.height);
      endArrowPoint   = CGPointMake( arrowSize.width / 2, -arrowSize.height);
      offset          = CGPointOffset( offset, arrowPosition.x, height + arrowSize.height);
      break;

   case PMCalendarArrowDirectionLeft :      // going from top to bottom
                                           // so start point is a top RIGHT point of a triangle - <'
      startArrowPoint = CGPointMake( arrowSize.height, -arrowSize.width / 2);
      endArrowPoint   = CGPointMake( arrowSize.height, arrowSize.width / 2);
      offset          = CGPointOffset( offset, 0, arrowPosition.y);
      tl.x            = arrowSize.height;
      break;

   case PMCalendarArrowDirectionRight :      // going from bottom to top
                                            // so start point is a bottom RIGHT point of a triangle - .>
      startArrowPoint = CGPointMake( -arrowSize.height, arrowSize.width / 2);
      endArrowPoint   = CGPointMake( -arrowSize.height, -arrowSize.width / 2);
      offset          = CGPointOffset( offset, width + arrowSize.height, arrowPosition.y);
      break;

   default:
      break;
   }

   startArrowPoint = CGPointOffsetByPoint(startArrowPoint, offset);
   endArrowPoint   = CGPointOffsetByPoint(endArrowPoint, offset);
   topArrowPoint   = CGPointOffsetByPoint(topArrowPoint, offset);

   void   (^createBezierArrow)(void) = ^{
      [result addLineToPoint:startArrowPoint];
      [result addLineToPoint:topArrowPoint];
      [result addLineToPoint:endArrowPoint];
   };

   // starting from bottom-left corner
   [result moveToPoint:CGPointMake(tl.x + shadowPadding.left
                                   , tl.y + shadowPadding.top + height - cornerRadius)];
   // creating arc to a bottom line
   [result addArcWithCenter:CGPointMake(tl.x + shadowPadding.left + cornerRadius
                                        , tl.y + shadowPadding.top + height - cornerRadius)
                     radius:cornerRadius
                 startAngle:radians(180)
                   endAngle:radians(90)
                  clockwise:NO];

   // checking if we have an arrow on a bottom of the background
   if( direction == PMCalendarArrowDirectionDown)
   {
      // draw it if yes
      createBezierArrow();
   }

   // same steps for bottom-right corner
   [result addLineToPoint:CGPointMake(tl.x + shadowPadding.left + width - cornerRadius
                                      , tl.y + shadowPadding.top + height)];
   [result addArcWithCenter:CGPointMake(tl.x + shadowPadding.left + width - cornerRadius
                                        , tl.y + shadowPadding.top + height - cornerRadius)
                     radius:cornerRadius
                 startAngle:radians(90)
                   endAngle:radians(0)
                  clockwise:NO];

   if( direction == PMCalendarArrowDirectionRight)
      createBezierArrow();

   // same steps for top-right corner
   [result addLineToPoint:CGPointMake(tl.x + shadowPadding.left + width
                                      , tl.y + shadowPadding.top + cornerRadius)];
   [result addArcWithCenter:CGPointMake(tl.x + shadowPadding.left + width - cornerRadius
                                        , tl.y + shadowPadding.top + cornerRadius)
                     radius:cornerRadius
                 startAngle:radians(0)
                   endAngle:radians(-90)
                  clockwise:NO];

   if( direction == PMCalendarArrowDirectionUp)
      createBezierArrow();

   // same steps for top-left corner
   [result addLineToPoint:CGPointMake(tl.x + shadowPadding.left + cornerRadius
                                      , tl.y + shadowPadding.top)];
   [result addArcWithCenter:CGPointMake(tl.x + shadowPadding.left + cornerRadius
                                        , tl.y + shadowPadding.top + cornerRadius)
                     radius:cornerRadius
                 startAngle:radians(-90)
                   endAngle:radians(-180)
                  clockwise:NO];

   if( direction == PMCalendarArrowDirectionLeft)
      createBezierArrow();

   // return back to the starting point
   [result addLineToPoint:CGPointMake(tl.x + shadowPadding.left
                                      , tl.y + shadowPadding.top + height - cornerRadius)];

   [result closePath];

   return( result);
}


- (void) drawRect:(CGRect) rect
{
   CGAffineTransform   transform;
   CGContextRef   context;
   CGFloat        hDiff;
   CGFloat        headerHeight;
   CGFloat        height;
   CGFloat        separatorWidth;
   CGFloat        width;
   CGFloat        xOffset;
   CGFloat        yOffset;
   CGPoint        tl;
   CGRect         boxBounds;
   CGRect         dividerRect;
   CGRect         roundedRectangleBorderRect;
   CGSize         arrowSize;
   CGSize         innerPadding;
   NSDictionary   *shadowDict;
   NSNumber       *separatorWidthNumber;
   PMThemeShadow  *innerShadow;
   UIBezierPath   *dividerPath;
   UIBezierPath   *roundedRectangleNegativePath;
   UIBezierPath   *roundedRectanglePath;
   UIEdgeInsets   shadowPadding;
   
   context       = UIGraphicsGetCurrentContext();
   
   arrowSize     = PMThemeArrowSize();
   shadowPadding = PMThemeShadowInsets();
   innerPadding  = PMThemeInnerPadding();
   headerHeight  = PMThemeHeaderHeight();
   
   // backgound box. doesn't include arrow:
   boxBounds     = CGRectMake( 0, 0
                              , self.frame.size.width - arrowSize.height
                              , self.frame.size.height - arrowSize.height);
   
   width         = boxBounds.size.width - (shadowPadding.left + shadowPadding.right);
   height        = boxBounds.size.height - (shadowPadding.top + shadowPadding.bottom);
   
   shadowDict    = [[PMThemeEngine sharedInstance] elementOfGenericType:PMThemeShadowGenericType
                                                                subtype:PMThemeMainSubtype
                                                                   type:PMThemeBackgroundElementType];
   innerShadow   = [[PMThemeShadow alloc] initWithDictionary:shadowDict];
   
   tl            = CGPointZero;

   
   switch( self.arrowDirection)
   {
   case PMCalendarArrowDirectionUp:
      tl.y               = arrowSize.height;
      boxBounds.origin.y = arrowSize.height;
      break;

   case PMCalendarArrowDirectionLeft:
      tl.x               = arrowSize.height;
      boxBounds.origin.x = arrowSize.height;
   default:
      break;
   }

   // draws background of popover
   roundedRectanglePath = [PMCalendarBackgroundView createBezierPathForSize:boxBounds.size
                                                                             arrowDirection:self.arrowDirection
                                                                              arrowPosition:self.arrowPosition];

   [[PMThemeEngine sharedInstance] drawPath:roundedRectanglePath
                             forElementType:PMThemeBackgroundElementType
                                    subType:PMThemeBackgroundSubtype
                                  inContext:context];

   // background inner shadow
   roundedRectangleBorderRect = CGRectInset([roundedRectanglePath bounds]
                                                     , -innerShadow.blurRadius
                                                     , -innerShadow.blurRadius);
   roundedRectangleBorderRect = CGRectOffset(roundedRectangleBorderRect
                                             , -innerShadow.offset.width
                                             , -innerShadow.offset.height);
   roundedRectangleBorderRect = CGRectInset(CGRectUnion(roundedRectangleBorderRect
                                                        , [roundedRectanglePath bounds]), -1, -1);

   roundedRectangleNegativePath = [UIBezierPath bezierPathWithRect:roundedRectangleBorderRect];
   [roundedRectangleNegativePath appendPath:roundedRectanglePath];
   roundedRectangleNegativePath.usesEvenOddFillRule = YES;

   CGContextSaveGState(context);
   {
      xOffset = innerShadow.offset.width + round( roundedRectangleBorderRect.size.width);
      yOffset = innerShadow.offset.height;

      CGContextSetShadowWithColor(context,
                                  CGSizeMake(xOffset + copysign(0.1, xOffset)
                                             , yOffset + copysign(0.1, yOffset)),
                                  innerShadow.blurRadius,
                                  innerShadow.color.CGColor);

      [roundedRectanglePath addClip];
      transform = CGAffineTransformMakeTranslation(-round(roundedRectangleBorderRect.size.width)
                                                                       , 0);
      [roundedRectangleNegativePath applyTransform:transform];
      [[UIColor grayColor] setFill];
      [roundedRectangleNegativePath fill];
   }
   CGContextRestoreGState(context);

   separatorWidthNumber = [[PMThemeEngine sharedInstance] elementOfGenericType:PMThemeSizeWidthGenericType
                                                                                   subtype:PMThemeMainSubtype
                                                                                      type:PMThemeSeparatorsElementType];

   if( separatorWidthNumber)
   {
      // dividers
      hDiff          = (width + shadowPadding.left + shadowPadding.right - innerPadding.width * 2) / 7;
      separatorWidth = [separatorWidthNumber floatValue];
      
      for( int i = 0; i < 6; i++)
      {
         dividerRect = CGRectMake( tl.x + innerPadding.width + floor((i + 1) * hDiff) - 1 + shadowPadding.left
                                  , tl.y + innerPadding.height + headerHeight + shadowPadding.top
                                  , separatorWidth
                                  , height - innerPadding.height * 2 - headerHeight);
         dividerPath = [UIBezierPath bezierPathWithRect:dividerRect];
         
         [[PMThemeEngine sharedInstance] drawPath:dividerPath
                                   forElementType:PMThemeSeparatorsElementType
                                          subType:PMThemeMainSubtype
                                        inContext:context];
      }
   }

   [[PMThemeEngine sharedInstance] drawPath:roundedRectanglePath
                             forElementType:PMThemeBackgroundElementType
                                    subType:PMThemeOverlaySubtype
                                  inContext:context];
}


- (void) setFrame:(CGRect) frame
{
   BOOL   needsRedraw;
   
   needsRedraw = ! CGSizeEqualToSize( self.frame.size, frame.size);

   [super setFrame:frame];

   if( needsRedraw)
      [self redrawComponent];
}


@end
