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


@implementation PMCalendarController

- (id <PMCalendarControllerDelegate>) delegate
{
   return( delegate_);
}


- (void) setDelegate:(id <PMCalendarControllerDelegate>) delegate
{
   delegate_ = delegate;
}


- (BOOL) isCalendarVisible
{
   return( calendarVisible_);
}


- (PMCalendarArrowDirection) calendarArrowDirection
{
   return( calendarArrowDirection_);
}


#pragma mark - object initializers -

- (void) _initWithSize:(CGSize) size
{
   CGRect         backgroundFrame;
   CGRect         calFrame;
   CGRect         digitsFrame;
   CGRect         mainFrame;
   CGSize         arrowSize;
   CGSize         innerPadding;
   CGSize         outerPadding;
   UIEdgeInsets   insets;
   
   arrowSize    = PMThemeArrowSize();
   outerPadding = PMThemeOuterPadding();

   [self setCalendarArrowDirection:PMCalendarArrowDirectionUnknown];

   insets       = PMThemeShadowInsets();
   calFrame     = CGRectMake( 0, 0,
                          size.width + insets.left + insets.right,
                          size.height + insets.top + insets.bottom);
   
   initialFrame_ = calFrame;
   
   calendarView_ = [[[UIView alloc] initWithFrame:calFrame] autorelease];

   [calendarView_ setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

   // Make insets from two sides of a calendar to have place for arrow
   mainFrame       = CGRectMake( 0, 0,
                                 calFrame.size.width + arrowSize.height,
                                 calFrame.size.height + arrowSize.height);
   mainView_       = [[[UIView alloc] initWithFrame:mainFrame] autorelease];

   backgroundFrame = CGRectInset( mainFrame, outerPadding.width, outerPadding.height);
   backgroundView_  = [[[PMCalendarBackgroundView alloc] initWithFrame:backgroundFrame] autorelease];
   [backgroundView_ setClipsToBounds:NO];

   innerPadding    = PMThemeInnerPadding();
   digitsFrame     = CGRectInset( calFrame, innerPadding.width, innerPadding.height);
   digitsFrame     = UIEdgeInsetsInsetRect( digitsFrame, PMThemeShadowInsets());
   digitsView_     = [[[PMCalendarView alloc] initWithFrame:digitsFrame] autorelease];
   
   [digitsView_ setDelegate:self];

   [calendarView_ addSubview:digitsView_];
   [mainView_ addSubview:backgroundView_];
   [mainView_ addSubview:calendarView_];

   [self setAllowsPeriodSelection:YES];
   [self setAllowsLongPressMonthChange:YES];
}


- (id) init
{
   return( [self initWithThemeName:nil
                              size:CGSizeZero]);
}


- (id) initWithThemeName:(NSString *) name
                    size:(CGSize) size
{
   PMThemeEngine   *themer;
   
   if( ! (self = [super init]))
      return( self);
   
   if( ! name)
      name = @"default";
   
   themer = [PMThemeEngine sharedInstance];
   if( ! [name isEqualToString:[themer themeName]])
      [themer setThemeName:name];
   
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

   [allowedPeriod_ release];
   [period_ release];
   
   [super dealloc];
}



#pragma mark - rotation handling -

- (void) didRotate:(NSNotification *) notice
{
   CGRect   rect;
   UIView   *view;
   
   view = anchorView_;
   if( ! view)
      return;
   
   rect = [view convertRect:[view frame]
                   fromView:[view superview]];
   
   [UIView animateWithDuration:0.3
                    animations:^{
                       [self adjustCalendarPositionForPermittedArrowDirections:savedPermittedArrowDirections_
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
   CGSize         size;
   UIEdgeInsets   shadowInsets;
   
   shadowInsets = PMThemeShadowInsets();
   cornerRadius = PMThemeCornerRadius();
   arrowSize    = PMThemeArrowSize();

   bounds       = [[self view] bounds];
   size         = [self size];
   
   if( arrowDirections & PMCalendarArrowDirectionUp)
   {
      if((CGRectGetMaxY(rect) + size.height + arrowSize.height <= bounds.size.height)
         && (CGRectGetMidX(rect) >= (arrowSize.width / 2 + cornerRadius + shadowInsets.left))
         && (CGRectGetMidX(rect) <=
             (bounds.size.width - arrowSize.width / 2 - cornerRadius - shadowInsets.right)))
      {
         [self setCalendarArrowDirection:PMCalendarArrowDirectionUp];
         goto found;
      }
   }

   if( arrowDirections & PMCalendarArrowDirectionLeft)
   {
      if((CGRectGetMidX(rect) + size.width + arrowSize.height <= bounds.size.width)
         && (CGRectGetMidY(rect) >= (arrowSize.width / 2 + cornerRadius + shadowInsets.top))
         && (CGRectGetMidY(rect) <=
             (bounds.size.height - arrowSize.width / 2 - cornerRadius -
              shadowInsets.bottom)))
      {
         [self setCalendarArrowDirection:PMCalendarArrowDirectionLeft];
         goto found;
      }
   }

   if( arrowDirections & PMCalendarArrowDirectionDown)
   {
      if((CGRectGetMidY(rect) - size.height - arrowSize.height >= 0)
         && (CGRectGetMidX(rect) >= (arrowSize.width / 2 + cornerRadius + shadowInsets.left))
         && (CGRectGetMidX(rect) <=
             (bounds.size.width - arrowSize.width / 2 - cornerRadius - shadowInsets.right)))
      {
         [self setCalendarArrowDirection:PMCalendarArrowDirectionDown];
         goto found;
      }
   }

   if( arrowDirections & PMCalendarArrowDirectionRight)
   {
      if( (CGRectGetMidX(rect) - size.width - arrowSize.height >= 0)
         && (CGRectGetMidY(rect) >= (arrowSize.width / 2 + cornerRadius + shadowInsets.top))
         && (CGRectGetMidY(rect) <=
             (bounds.size.height - arrowSize.width / 2 - cornerRadius -
              shadowInsets.bottom)))
      {
         [self setCalendarArrowDirection:PMCalendarArrowDirectionRight];
         goto found;
      }
   }

   // TODO: check rect's quad and pick direction automatically
   [self setCalendarArrowDirection:PMCalendarArrowDirectionUp];

found:
   calendarFrame = [mainView_ frame];
   frame         = CGRectMake( 0, 0,
                              calendarFrame.size.width - arrowSize.height,
                              calendarFrame.size.height - arrowSize.height);
   arrowPosition = CGPointZero;
   arrowOffset   = CGPointZero;
   
   switch( calendarArrowDirection_)
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

      if( calendarArrowDirection_ == PMCalendarArrowDirectionUp)
      {
         arrowOffset.y          = arrowSize.height;
         calendarFrame.origin.y = CGRectGetMaxY( rect) - shadowInsets.top;
      }
      else
         calendarFrame.origin.y = CGRectGetMinY( rect) - [backgroundView_ frame].size.height +
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

      if( calendarArrowDirection_ == PMCalendarArrowDirectionLeft)
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

   [mainView_ setFrame:calendarFrame];
    
   frame.origin = pmOffsetPointByPoint( frame.origin, arrowOffset);
   [calendarView_ setFrame:frame];

   arrowPosition = [[self view] convertPoint:arrowPosition
                                      toView:mainView_];

   if((calendarArrowDirection_ == PMCalendarArrowDirectionUp)
      || (calendarArrowDirection_ == PMCalendarArrowDirectionDown))
   {
      arrowPosition.x = MIN( arrowPosition.x, frame.size.width - arrowSize.width / 2 - cornerRadius);
      arrowPosition.x = MAX (arrowPosition.x, arrowSize.width / 2 + cornerRadius);
   }
   else
      if( (calendarArrowDirection_ == PMCalendarArrowDirectionRight)
           || (calendarArrowDirection_ == PMCalendarArrowDirectionLeft))
      {
         arrowPosition.y = MIN( arrowPosition.y, frame.size.height - arrowSize.width / 2 - cornerRadius);
         arrowPosition.y = MAX( arrowPosition.y, arrowSize.width / 2 + cornerRadius);
      }

   [backgroundView_ setArrowPosition:arrowPosition];
   savedArrowPosition_ = arrowPosition;
}


- (void) _presentCalendarFromRect:(CGRect) rect
                           inView:(UIView *) parentView
         permittedArrowDirections:(PMCalendarArrowDirection) arrowDirections
                        isPopover:(BOOL) isPopover
                         animated:(BOOL) animated
{
   CGRect     frame;
   UIView     *view;
   PMPeriod   *period;
   
   view = mainView_;
   
   if( isPopover)
   {
      view = [[[PMDimmingView alloc] initWithFrame:[parentView bounds]
                                        controller:self] autorelease];
      [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
      [view addSubview:mainView_];
   }
   [self setView:view];
   [parentView addSubview:view];

   frame = [view convertRect:rect
                    fromView:parentView];
   [self adjustCalendarPositionForPermittedArrowDirections:arrowDirections
                                         arrowPointsToRect:frame];

#warning (nat) initial frame is supicious
   initialFrame_ = [mainView_ frame];
   [self fullRedraw];

   [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector( didRotate: )
                                                name:UIDeviceOrientationDidChangeNotification
                                              object:nil];

   if( animated)
   {
      [mainView_ setAlpha:0];

      [UIView animateWithDuration:0.2
                       animations:^{
                          [mainView_ setAlpha:1];
       }];
   }

   if( ! [digitsView_ period])
   {
      period = [PMPeriod oneDayPeriodWithDate:[NSDate date]];
      [self setPeriod:period];
   }
   
   calendarVisible_ = YES;
}


- (void) presentCalendarFromRect:(CGRect) rect
                          inView:(UIView *) parentView
        permittedArrowDirections:(PMCalendarArrowDirection) arrowDirections
                       isPopover:(BOOL) isPopover
                        animated:(BOOL) animated
{
   anchorView_                    = nil;
   savedPermittedArrowDirections_ = 0;
   
   [self _presentCalendarFromRect:rect
                           inView:parentView
         permittedArrowDirections:arrowDirections
                        isPopover:isPopover
                         animated:animated];
   
}

- (void) presentCalendarFromView:(UIView *) anchorView
        permittedArrowDirections:(PMCalendarArrowDirection) arrowDirections
                       isPopover:(BOOL) isPopover
                        animated:(BOOL) animated
{
   // weird, weird code, why is anchorView not set in the other method, which
   // is public too ?
   anchorView_                    = anchorView;
   savedPermittedArrowDirections_ = arrowDirections;

   [self _presentCalendarFromRect:[anchorView frame]
                           inView:[anchorView superview]
         permittedArrowDirections:arrowDirections
                        isPopover:isPopover
                         animated:animated];
}


- (void) dismissCalendar
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   [[self view] removeFromSuperview];
   calendarVisible_ = NO;
   
   if( [delegate_ respondsToSelector:@selector( calendarControllerDidDismissCalendar: )])
      [delegate_ calendarControllerDidDismissCalendar:self];
}


- (void) dismissCalendarAnimated:(BOOL) animated
{
   [[self view] setAlpha:1];

   if( ! animated)
   {
      [self dismissCalendar];
      return;
   }

   void   (^animationBlock)(void) = ^{
      [self dismissCalendar];
   };
   void   (^completionBlock)(BOOL) = ^(BOOL finished) {
      [[self view] setAlpha:0];
      [mainView_ setTransform:CGAffineTransformMakeScale( 0.1, 0.1)];
   };
   

   [UIView animateWithDuration:0.2
                       animations:animationBlock
                       completion:completionBlock];
}


- (void) fullRedraw
{
   [[NSNotificationCenter defaultCenter] postNotificationName:PMCalendarRedrawNotification
                                                       object:nil];
}


- (void) setCalendarArrowDirection:(PMCalendarArrowDirection) direction
{
   [backgroundView_ setArrowDirection:direction];
   
   calendarArrowDirection_ = direction;
}


#pragma mark - date/period management -

- (BOOL) isMondayFirstDayOfWeek
{
   return( [digitsView_ isMondayFirstDayOfWeek]);
}


- (void) setMondayFirstDayOfWeek:(BOOL) mondayFirstDayOfWeek
{
   [digitsView_ setMondayFirstDayOfWeek:mondayFirstDayOfWeek];
}


- (BOOL) allowsPeriodSelection
{
   return( digitsView_.allowsPeriodSelection);
}


- (void) setAllowsPeriodSelection:(BOOL) allowsPeriodSelection
{
   [digitsView_ setAllowsPeriodSelection:allowsPeriodSelection];
}


- (BOOL) allowsLongPressMonthChange
{
   return( [digitsView_ allowsLongPressMonthChange]);
}


- (void) setAllowsLongPressMonthChange:(BOOL) allowsLongPressMonthChange
{
   [digitsView_ setAllowsLongPressMonthChange:allowsLongPressMonthChange];
}


- (PMPeriod *) period
{
   return( [digitsView_ period]);
}


- (void) setPeriod:(PMPeriod *) period
{
   [digitsView_ setPeriod:period];
   [digitsView_ setCurrentDate:[period startDate]];
}


- (PMPeriod *) allowedPeriod
{
   return([digitsView_ allowedPeriod]);
}


- (void) setAllowedPeriod:(PMPeriod *) allowedPeriod
{
   [digitsView_ setAllowedPeriod:allowedPeriod];
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

   numDaysInMonth += (monthStartDay + ([digitsView_ isMondayFirstDayOfWeek] ? 5 : 6)) % 7;
   height          = initialFrame_.size.height - outerPadding.height * 2 - arrowSize.height;
   vDiff           = (height - headerHeight - innerPadding.height * 2 - shadowInsets.bottom -
       shadowInsets.top) / ((PMThemeDayTitlesInHeader()) ? 6 : 7);

   frame             = CGRectInset( initialFrame_, outerPadding.width, outerPadding.height);
   numberOfRows      = ceil( (CGFloat) numDaysInMonth / 7);
   frame.size.height = ceil( ((numberOfRows +
        ((PMThemeDayTitlesInHeader()) ? 0 : 1)) *
       vDiff) + headerHeight + innerPadding.height * 2 +
      arrowSize.height) + shadowInsets.bottom + shadowInsets.top;

   if( [self calendarArrowDirection] == PMCalendarArrowDirectionDown)
      frame.origin.y += initialFrame_.size.height - frame.size.height;

   // TODO: recalculate arrow position for left & right
   // else if ((self.calendarArrowDirection == PMCalendarArrowDirectionLeft)
   // || (self.calendarArrowDirection == PMCalendarArrowDirectionRight))
   // {
   // frm.origin.y = (self.mainView.bounds.size.height - frm.size.height) / 2;
   // self.backgroundView.arrowPosition =
   // }

   [mainView_ setFrame:frame];
   [self fullRedraw];
}


- (void) setSize:(CGSize) size
{
   CGRect   frame;
   
   frame      = [mainView_ frame];
   frame.size = size;
   [mainView_ setFrame:frame];
   
   [self fullRedraw];
}


- (CGSize) size
{
   return( [mainView_ frame].size);
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
