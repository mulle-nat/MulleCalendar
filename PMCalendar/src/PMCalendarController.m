//
// PMCalendarController.m
// PMCalendar
//
// Created by Pavel Mazurin on 7/13/12.
// Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import "NSDate+Helpers.h"
#import "PMCalendarBackgroundView.h"
#import "PMCalendarConstants.h"
#import "PMCalendarController.h"
#import "PMCalendarHelpers.h"
#import "PMCalendarView.h"
#import "PMDimmingView.h"
#import "PMPeriod.h"
#import "PMTheme.h"

NSString   *PMCalendarRedrawNotification = @"PMCalendarRedrawNotification";

@interface PMCalendarController ()

@property (nonatomic, strong) UIView                    *mainView;
@property (nonatomic, strong) UIView                    *anchorView;
@property (nonatomic, assign) PMCalendarArrowDirection   savedPermittedArrowDirections;
@property (nonatomic, strong) UIView                     *calendarView;
@property (nonatomic, strong) PMCalendarBackgroundView   *backgroundView;
@property (nonatomic, strong) PMCalendarView             *digitsView;
@property (nonatomic, assign) CGPoint                    position;
@property (nonatomic, assign) PMCalendarArrowDirection   calendarArrowDirection;
@property (nonatomic, assign) CGPoint                    savedArrowPosition;
@property (nonatomic, assign) UIDeviceOrientation        currentOrientation;
@property (nonatomic, assign) CGRect                     initialFrame;

@end

@implementation PMCalendarController

@synthesize initialFrame = _initialFrame;
@synthesize position     = _position;
@synthesize delegate     = _delegate;

@dynamic period;
@dynamic allowedPeriod;
@dynamic mondayFirstDayOfWeek;
@dynamic allowsPeriodSelection;
@dynamic allowsLongPressMonthChange;

@synthesize calendarArrowDirection = _calendarArrowDirection;
@synthesize currentOrientation     = _currentOrientation;
@synthesize calendarVisible        = _calendarVisible;

@synthesize mainView   = _mainView;
@synthesize anchorView = _anchorView;
@synthesize savedPermittedArrowDirections = _savedPermittedArrowDirections;
@synthesize calendarView       = _calendarView;
@synthesize backgroundView     = _backgroundView;
@synthesize digitsView         = _digitsView;
@synthesize size               = _size;
@synthesize savedArrowPosition = _savedArrowPosition;

#pragma mark - object initializers -

- (void) _initWithSize:(CGSize) size
{
   CGRect                     backgroundFrame;
   CGRect                     calFrame;
   CGRect                     digitsFrame;
   CGRect                     mainFrame;
   CGSize                     arrowSize;
   CGSize                     innerPadding;
   CGSize                     outerPadding;
   PMCalendarBackgroundView   *backgroundView;
   PMCalendarView             *digitsView;
   UIEdgeInsets               insets;
   UIView                     *calView;
   UIView                     *mainView;
   
   arrowSize    = PMThemeArrowSize();
   outerPadding = PMThemeOuterPadding();

   [self setCalendarArrowDirection:PMCalendarArrowDirectionUnknown];

   insets       = PMThemeShadowInsets();
   calFrame     = CGRectMake( 0, 0,
                          size.width + insets.left + insets.right,
                          size.height + insets.top + insets.bottom);
   
   [self setInitialFrame:calFrame];
   
   calView = [[[UIView alloc] initWithFrame:calFrame] autorelease];
   [self setCalendarView:calView];

   [calView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

   // Make insets from two sides of a calendar to have place for arrow
   mainFrame       = CGRectMake( 0, 0,
                                 calFrame.size.width + arrowSize.height,
                                 calFrame.size.height + arrowSize.height);
   mainView        = [[[UIView alloc] initWithFrame:mainFrame] autorelease];

   backgroundFrame = CGRectInset( mainFrame, outerPadding.width, outerPadding.height);
   backgroundView  = [[[PMCalendarBackgroundView alloc] initWithFrame:backgroundFrame] autorelease];
   [backgroundView setClipsToBounds:NO];

   innerPadding    = PMThemeInnerPadding();
   digitsFrame     = CGRectInset( calFrame, innerPadding.width, innerPadding.height);
   digitsFrame     = UIEdgeInsetsInsetRect( digitsFrame, PMThemeShadowInsets());
   digitsView      = [[[PMCalendarView alloc] initWithFrame:digitsFrame] autorelease];
   
   [digitsView setDelegate:self];

   [calView addSubview:digitsView];
   [mainView addSubview:backgroundView];
   [mainView addSubview:calView];

   [self setBackgroundView:backgroundView];
   [self setMainView:mainView];
   [self setDigitsView:digitsView];
   [self setCalendarView:calView];

   [self setAllowsPeriodSelection:YES];
   [self setAllowsLongPressMonthChange:YES];
}


- (id) init
{
   return( [self initWithThemeName:nil
                           size:CGSizeZero]);
}


- (id) initWithThemeName:(NSString *) themeName
                 size:(CGSize) size
{
   PMThemeEngine   *themer;
   
   if( ! (self = [super init]))
      return( self);
   
   if( ! themeName)
      themeName = @"default";
   
   themer = [PMThemeEngine sharedInstance];
   if( ! [themeName isEqualToString:[themer themeName]])
      [themer setThemeName:themeName];
   
   if( size.width == 0.0 || size.height == 0.0)
      size = [themer defaultSize];
   
   [self _initWithSize:size];
   
   return( self);
}


- (id) initWithThemeName:(NSString *) themeName
{
   return( [self initWithThemeName:themeName
                           size:CGSizeZero]);
}


- (id) initWithSize:(CGSize) size
{
   return( [self initWithThemeName:nil
                           size:size]);
}


- (void) dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   [super dealloc];
}



#pragma mark - rotation handling -

- (void) didRotate:(NSNotification *) notice
{
   CGRect   rect;
   UIView   *view;
   
   view = [self anchorView];
   if( ! view)
      return;
   
   rect = [view convertRect:[view frame]
                   fromView:[view superview]];
   
   [UIView animateWithDuration:0.3
                    animations:^{
                       [self adjustCalendarPositionForPermittedArrowDirections:_savedPermittedArrowDirections
                                                             arrowPointsToRect:rect];
                    }];
}


#pragma mark - controller presenting methods -

- (void) adjustCalendarPositionForPermittedArrowDirections:(PMCalendarArrowDirection) arrowDirections
                                         arrowPointsToRect:(CGRect) rect
{
   CGFloat        cornerRadius;
   CGPoint        arrowOffset;
   CGPoint        arrowPosition;
   CGRect         calendarFrame;
   CGRect         frame;
   CGRect         bounds;
   CGSize         arrowSize;
   UIEdgeInsets   shadowInsets;
   
   shadowInsets = PMThemeShadowInsets();
   cornerRadius = PMThemeCornerRadius();
   arrowSize    = PMThemeArrowSize();

   if( arrowDirections & PMCalendarArrowDirectionUp)
   {
      if((CGRectGetMaxY(rect) + [self size].height + arrowSize.height <= [[self view] bounds].size.height)
         && (CGRectGetMidX(rect) >= (arrowSize.width / 2 + cornerRadius + shadowInsets.left))
         && (CGRectGetMidX(rect) <=
             ([[self view] bounds].size.width - arrowSize.width / 2 - cornerRadius - shadowInsets.right)))
      {
         [self setCalendarArrowDirection:PMCalendarArrowDirectionUp];
      }
   }

   if( (_calendarArrowDirection == PMCalendarArrowDirectionUnknown)
      && (arrowDirections & PMCalendarArrowDirectionLeft))
   {
      if((CGRectGetMidX(rect) + [self size].width + arrowSize.height <= [[self view] bounds].size.width)
         && (CGRectGetMidY(rect) >= (arrowSize.width / 2 + cornerRadius + shadowInsets.top))
         && (CGRectGetMidY(rect) <=
             ([[self view] bounds].size.height - arrowSize.width / 2 - cornerRadius -
              shadowInsets.bottom)))
      {
         [self setCalendarArrowDirection:PMCalendarArrowDirectionLeft];
      }
   }

   if( (_calendarArrowDirection == PMCalendarArrowDirectionUnknown)
      && (arrowDirections & PMCalendarArrowDirectionDown))
   {
      if((CGRectGetMidY(rect) - [self size].height - arrowSize.height >= 0)
         && (CGRectGetMidX(rect) >= (arrowSize.width / 2 + cornerRadius + shadowInsets.left))
         && (CGRectGetMidX(rect) <=
             ([[self view] bounds].size.width - arrowSize.width / 2 - cornerRadius - shadowInsets.right)))
      {
         [self setCalendarArrowDirection:PMCalendarArrowDirectionDown];
      }
   }

   if( (_calendarArrowDirection == PMCalendarArrowDirectionUnknown)
      && (arrowDirections & PMCalendarArrowDirectionRight))
   {
      if((CGRectGetMidX(rect) - [self size].width - arrowSize.height >= 0)
         && (CGRectGetMidY(rect) >= (arrowSize.width / 2 + cornerRadius + shadowInsets.top))
         && (CGRectGetMidY(rect) <=
             ([[self view] bounds].size.height - arrowSize.width / 2 - cornerRadius -
              shadowInsets.bottom)))
      {
         [self setCalendarArrowDirection:PMCalendarArrowDirectionRight];
      }
   }

   if( _calendarArrowDirection == PMCalendarArrowDirectionUnknown)  // nothing suits
   {
      // TODO: check rect's quad and pick direction automatically
         [self setCalendarArrowDirection:PMCalendarArrowDirectionUp];
   }

   calendarFrame = [[self mainView] frame];
   frame         = CGRectMake( 0, 0,
                              calendarFrame.size.width - arrowSize.height,
                              calendarFrame.size.height - arrowSize.height);
   arrowPosition = CGPointZero;
   arrowOffset   = CGPointZero;
   bounds        = [[self view] bounds];
   
   switch( _calendarArrowDirection)
   {
   case PMCalendarArrowDirectionUp   :
   case PMCalendarArrowDirectionDown :
      arrowPosition.x = CGRectGetMidX(rect) - shadowInsets.right;

      if( arrowPosition.x < frame.size.width / 2)
         calendarFrame.origin.x = 0;
      else
         if( arrowPosition.x > bounds.size.width - frame.size.width / 2)
            calendarFrame.origin.x = bounds.size.width - frame.size.width - shadowInsets.right;
         else
            calendarFrame.origin.x = arrowPosition.x - frame.size.width / 2 + shadowInsets.left;

      if( _calendarArrowDirection == PMCalendarArrowDirectionUp)
      {
         arrowOffset.y          = arrowSize.height;
         calendarFrame.origin.y = CGRectGetMaxY(rect) - shadowInsets.top;
      }
      else
         calendarFrame.origin.y = CGRectGetMinY(rect) - [[self backgroundView] frame].size.height +
                                  shadowInsets.bottom;

      break;

   case PMCalendarArrowDirectionLeft  :
   case PMCalendarArrowDirectionRight :
      arrowPosition.y = CGRectGetMidY( rect) - shadowInsets.top;

      if( arrowPosition.y < frame.size.height / 2)
         calendarFrame.origin.y = 0;
      else
         if( arrowPosition.y > bounds.size.height - frame.size.height / 2)
            calendarFrame.origin.y = bounds.size.height - frame.size.height;
         else
            calendarFrame.origin.y = arrowPosition.y - calendarFrame.size.height / 2 + arrowSize.height;

      if( _calendarArrowDirection == PMCalendarArrowDirectionLeft)
      {
         arrowOffset.x          = arrowSize.height;
         calendarFrame.origin.x = CGRectGetMaxX(rect) - shadowInsets.left;
      }
      else
         calendarFrame.origin.x = CGRectGetMinX(rect) - calendarFrame.size.width + shadowInsets.right;

      break;

   default:
      NSAssert(NO, @"arrow direction is not set! JACKPOT!! :)");
      break;
   }

   [[self mainView] setFrame:calendarFrame];
    
   frame.origin = CGPointOffsetByPoint( frame.origin, arrowOffset);
   [[self calendarView] setFrame:frame];

   arrowPosition = [[self view] convertPoint:arrowPosition
                                      toView:[self mainView]];

   if((_calendarArrowDirection == PMCalendarArrowDirectionUp)
      || (_calendarArrowDirection == PMCalendarArrowDirectionDown))
   {
      arrowPosition.x = MIN( arrowPosition.x, frame.size.width - arrowSize.width / 2 - cornerRadius);
      arrowPosition.x = MAX (arrowPosition.x, arrowSize.width / 2 + cornerRadius);
   }
   else
      if( (_calendarArrowDirection == PMCalendarArrowDirectionRight)
           || (_calendarArrowDirection == PMCalendarArrowDirectionLeft))
      {
         arrowPosition.y = MIN( arrowPosition.y, frame.size.height - arrowSize.width / 2 - cornerRadius);
         arrowPosition.y = MAX( arrowPosition.y, arrowSize.width / 2 + cornerRadius);
      }

   [[self backgroundView] setArrowPosition:arrowPosition];
   [self setSavedArrowPosition:arrowPosition];
}


- (void) presentCalendarFromRect:(CGRect) rect
                          inView:(UIView *) parentView
        permittedArrowDirections:(PMCalendarArrowDirection) arrowDirections
                       isPopover:(BOOL) isPopover
                        animated:(BOOL) animated
{
   CGRect   frame;
   UIView   *view;
   UIView   *mainView;
   
   mainView = [self mainView];
   view     = mainView;
   
   if( isPopover)
   {
      view = [[[PMDimmingView alloc] initWithFrame:[parentView bounds]
                                               controller:self] autorelease];
      [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
      [view addSubview:mainView];
   }
   [self setView:view];
   [parentView addSubview:view];

   frame = [view convertRect:rect
                    fromView:parentView];
   [self adjustCalendarPositionForPermittedArrowDirections:arrowDirections
                                         arrowPointsToRect:frame];

#warning (nat) initial frame is supicious
   [self setInitialFrame:[mainView frame]];
   [self fullRedraw];

   [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector( didRotate: )
                                                name:UIDeviceOrientationDidChangeNotification
                                              object:nil];

   if( animated)
   {
      [mainView setAlpha:0];

      [UIView animateWithDuration:0.2
                       animations:^{
                          [mainView setAlpha:1];
       }];
   }

   if( ! [[self digitsView] period])
      [self setPeriod:[PMPeriod oneDayPeriodWithDate:[NSDate date]]];

   _calendarVisible = YES;
}


- (void) presentCalendarFromView:(UIView *) anchorView
        permittedArrowDirections:(PMCalendarArrowDirection) arrowDirections
                       isPopover:(BOOL) isPopover
                        animated:(BOOL) animated
{
   [self setAnchorView:anchorView];
   [self setSavedPermittedArrowDirections:arrowDirections];

   [self presentCalendarFromRect:[anchorView frame]
                          inView:[anchorView superview]
        permittedArrowDirections:arrowDirections
                       isPopover:isPopover
                        animated:animated];
}


- (void) dismissCalendarAnimated:(BOOL) animated
{
   void   (^completionBlock)(BOOL) = ^(BOOL finished) {
      [[NSNotificationCenter defaultCenter] removeObserver:self];
      [[self view] removeFromSuperview];
      _calendarVisible = NO;

      if( [[self delegate] respondsToSelector:@selector( calendarControllerDidDismissCalendar: )])
         [[self delegate] calendarControllerDidDismissCalendar:self];
   };

   [[self view] setAlpha:1];
   if( animated)
   {
      [UIView animateWithDuration:0.2
                       animations:^{
          [[self view] setAlpha:0];
          [[self mainView] setTransform:CGAffineTransformMakeScale( 0.1, 0.1)];
       }
                       completion:completionBlock];
   }
   else
      completionBlock( YES);
}


- (void) fullRedraw
{
   [[NSNotificationCenter defaultCenter] postNotificationName:PMCalendarRedrawNotification
                                                       object:nil];
}


- (void) setCalendarArrowDirection:(PMCalendarArrowDirection) direction
{
   [[self backgroundView] setArrowDirection:direction];
   
   _calendarArrowDirection = direction;
}


#pragma mark - date/period management -

- (BOOL) mondayFirstDayOfWeek
{
   return( [[self digitsView] mondayFirstDayOfWeek]);
}


- (void) setMondayFirstDayOfWeek:(BOOL) mondayFirstDayOfWeek
{
   [[self digitsView] setMondayFirstDayOfWeek:mondayFirstDayOfWeek];
}


- (BOOL) allowsPeriodSelection
{
   return( [self digitsView].allowsPeriodSelection);
}


- (void) setAllowsPeriodSelection:(BOOL) allowsPeriodSelection
{
   [[self digitsView] setAllowsPeriodSelection:allowsPeriodSelection];
}


- (BOOL) allowsLongPressMonthChange
{
   return( [[self digitsView] allowsLongPressMonthChange]);
}


- (void) setAllowsLongPressMonthChange:(BOOL) allowsLongPressMonthChange
{
   [[self digitsView] setAllowsLongPressMonthChange:allowsLongPressMonthChange];
}


- (PMPeriod *) period
{
   return( [[self digitsView] period]);
}


- (void) setPeriod:(PMPeriod *) period
{
   [[self digitsView] setPeriod:period];
   [[self digitsView] setCurrentDate:[period startDate]];
}


- (PMPeriod *) allowedPeriod
{
   return([self digitsView].allowedPeriod);
}


- (void) setAllowedPeriod:(PMPeriod *) allowedPeriod
{
   [[self digitsView] setAllowedPeriod:allowedPeriod];
}


#pragma mark - PMdigitsViewDelegate methods -

- (void) periodChanged:(PMPeriod *) newPeriod
{
   id   delegate;
   
   delegate = [self delegate];
   if( [delegate respondsToSelector:@selector( calendarController:didChangePeriod:)])
      [delegate calendarController:self
                   didChangePeriod:[newPeriod normalizedPeriod]];
}


- (void) currentDateChanged:(NSDate *) currentDate
{
   CGFloat        height;
   CGFloat        vDiff;
   CGFloat        headerHeight;
   CGRect         frame;
   CGSize         arrowSize;
   CGSize         innerPadding;
   CGSize         outerPadding;
   NSInteger      monthStartDay;
   UIEdgeInsets   shadowInsets;
   int            numDaysInMonth;
   int            numberOfRows;
   
   arrowSize       = PMThemeArrowSize();
   innerPadding    = PMThemeInnerPadding();
   outerPadding    = PMThemeOuterPadding();
   shadowInsets    = PMThemeShadowInsets();
   headerHeight    = PMThemeHeaderHeight();
   
   numDaysInMonth  = [currentDate pmNumberOfDaysInMonth];
   monthStartDay   = [[currentDate pmMonthStartDate] pmGregorianWeekday];

   numDaysInMonth += (monthStartDay + ([self digitsView].mondayFirstDayOfWeek ? 5 : 6)) % 7;
   height          = _initialFrame.size.height - outerPadding.height * 2 - arrowSize.height;
   vDiff           = (height - headerHeight - innerPadding.height * 2 - shadowInsets.bottom -
       shadowInsets.top) / ((PMThemeDayTitlesInHeader()) ? 6 : 7);

   frame             = CGRectInset( _initialFrame, outerPadding.width, outerPadding.height);
   numberOfRows      = ceil( (CGFloat) numDaysInMonth / 7);
   frame.size.height = ceil( ((numberOfRows +
        ((PMThemeDayTitlesInHeader()) ? 0 : 1)) *
       vDiff) + headerHeight + innerPadding.height * 2 +
      arrowSize.height) + shadowInsets.bottom + shadowInsets.top;

   if( [self calendarArrowDirection] == PMCalendarArrowDirectionDown)
      frame.origin.y += _initialFrame.size.height - frame.size.height;

   // TODO: recalculate arrow position for left & right
   // else if ((self.calendarArrowDirection == PMCalendarArrowDirectionLeft)
   // || (self.calendarArrowDirection == PMCalendarArrowDirectionRight))
   // {
   // frm.origin.y = (self.mainView.bounds.size.height - frm.size.height) / 2;
   // self.backgroundView.arrowPosition =
   // }

   [[self mainView] setFrame:frame];
   [self fullRedraw];
}


- (void) setSize:(CGSize) size
{
   CGRect   frame;
   
   frame      = [self mainView].frame;
   frame.size = size;
   [[self mainView] setFrame:frame];
   
   [self fullRedraw];
}


- (CGSize) size
{
   return( [[self mainView] frame].size);
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation) interfaceOrientation
{
   return( YES);
}


#pragma mark - Deprecated methods -

- (void) presentCalendarFromRect:(CGRect) rect
                          inView:(UIView *) view
        permittedArrowDirections:(PMCalendarArrowDirection) arrowDirections
                        animated:(BOOL) animated
{
   [self presentCalendarFromRect:rect
                          inView:view
        permittedArrowDirections:arrowDirections
                       isPopover:YES
                        animated:animated];
}


- (void) presentCalendarFromView:(UIView *) anchorView
        permittedArrowDirections:(PMCalendarArrowDirection) arrowDirections
                        animated:(BOOL) animated
{
   [self presentCalendarFromView:anchorView
        permittedArrowDirections:arrowDirections
                       isPopover:YES
                        animated:animated];
}


@end
