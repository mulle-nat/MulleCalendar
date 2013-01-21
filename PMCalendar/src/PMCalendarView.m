//
// PMCalendarView.m
// PMCalendar
//
// Created by Pavel Mazurin on 7/13/12.
// Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import "NSDate+Helpers.h"
#import "PMCalendarConstants.h"
#import "PMCalendarView.h"
#import "PMPeriod.h"
#import "PMSelectionView.h"
#import "PMTheme.h"

#import "PMThemeEngine.h"

@interface PMDaysView : UIView

@property (nonatomic, strong) UIFont     *font;
@property (nonatomic, strong) NSDate     *currentDate; // month to show
@property (nonatomic, strong) PMPeriod   *selectedPeriod;
@property (nonatomic, strong) NSArray    *rects;
@property (nonatomic, assign) BOOL       mondayFirstDayOfWeek;
@property (nonatomic, assign) CGRect     initialFrame;

- (void) redrawComponent;

@end

@interface PMCalendarView ()

@property (nonatomic, strong) UIFont                         *font;
@property (nonatomic, strong) UITapGestureRecognizer         *tapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer   *longPressGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer         *panGestureRecognizer;
@property (nonatomic, strong) NSTimer                        *longPressTimer;
@property (nonatomic, strong) NSTimer                        *panTimer;
@property (nonatomic, assign) CGPoint                        panPoint;
@property (nonatomic, strong) PMDaysView                     *daysView;
@property (nonatomic, strong) PMSelectionView                *selectionView;
@property (nonatomic, assign) CGRect   initialFrame;

- (NSInteger) indexForDate:(NSDate *) date;
- (NSDate *) dateForPoint:(CGPoint) point;

@end

@implementation PMCalendarView
{
   NSInteger   currentMonth;
   NSInteger   currentYear;
   CGRect      leftArrowRect_;
   CGRect      rightArrowRect_;
   NSInteger   fontSize;
}

@synthesize allowedPeriod              = _allowedPeriod;
@synthesize allowsLongPressMonthChange = _allowsLongPressMonthChange;
@synthesize allowsPeriodSelection      = _allowsPeriodSelection;
@synthesize currentDate                = _currentDate;
@synthesize daysView                   = _daysView;
@synthesize delegate                   = _delegate;
@synthesize font                       = _font;
@synthesize initialFrame               = _initialFrame;
@synthesize longPressGestureRecognizer = _longPressGestureRecognizer;
@synthesize longPressTimer             = _longPressTimer;
@synthesize mondayFirstDayOfWeek       = _mondayFirstDayOfWeek;
@synthesize panGestureRecognizer       = _panGestureRecognizer;
@synthesize panPoint                   = _panPoint;
@synthesize panTimer                   = _panTimer;
@synthesize period                     = _period;
@synthesize selectionView              = _selectionView;
@synthesize tapGestureRecognizer       = _tapGestureRecognizer;


- (id) initWithFrame:(CGRect) frame
{
   UITapGestureRecognizer   *tapRecognizer;
   UIPanGestureRecognizer   *panRecognizer;
   CGSize                   innerPadding;
   PMSelectionView          *selectionView;
   PMDaysView               *daysView;
   
   if( ! (self = [super initWithFrame:frame]))
      return(nil);

   [self setInitialFrame:frame];

   [self setBackgroundColor:[UIColor clearColor]];
   [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
   [self setMondayFirstDayOfWeek:NO];

   tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector( tapHandling: )] autorelease];
   [tapRecognizer setNumberOfTapsRequired:1];
   [tapRecognizer setNumberOfTouchesRequired:1];
   [tapRecognizer setDelegate:self];

   [self setTapGestureRecognizer:tapRecognizer];
   [self addGestureRecognizer:tapRecognizer];

   panRecognizer = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector( panHandling: )] autorelease];
   [panRecognizer setDelegate:self];
   [self setPanGestureRecognizer:panRecognizer];
   [self addGestureRecognizer:panRecognizer];

   [self setAllowsLongPressMonthChange:YES];

   innerPadding = PMThemeInnerPadding();

   selectionView = [[[PMSelectionView alloc] initWithFrame:CGRectInset( [self bounds], -innerPadding.width,
                                                                       -innerPadding.height)] autorelease];
   [self addSubview:selectionView];
   [self setSelectionView:selectionView];
   
   daysView = [[[PMDaysView alloc] initWithFrame:self.bounds] autorelease];
   [daysView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

   [self addSubview:daysView];
   [self setDaysView:daysView];
   
   [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector( redrawComponent )
                                                name:PMCalendarRedrawNotification
                                              object:nil];

   return( self);
}

- (void) dealloc
{
   // [_allowedPeriod release];
   
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   [super dealloc];
}



- (void) setFrame:(CGRect) frame
{
   [super setFrame:frame];
}


- (void) redrawComponent
{
   [self setNeedsDisplay];
}


- (void) drawRect:(CGRect) dirtyRect
{
   BOOL              showsLeftArrow;
   BOOL              showsRightArrow;
   CGContextRef      context;
   CGFloat           hDiff;
   CGFloat           headerHeight;
   CGFloat           height;
   CGFloat           vDiff;
   CGFloat           width;
   CGRect            dayHeaderFrame;
   CGRect            textFrame;
   CGSize            arrowOffset;
   CGSize            arrowSize;
   CGSize            sz;
   NSArray           *dayTitles;
   NSArray           *monthTitles;
   NSDateFormatter   *dateFormatter;
   NSDictionary      *arrowOffsetDict;
   NSDictionary      *arrowSizeDict;
   NSInteger         index;
   NSString          *dayTitle;
   NSString          *monthTitle;
   UIEdgeInsets      shadowPadding;
   UIFont            *dayFont;
   UIFont            *monthFont;
   int               month;
   int               year;
   UIBezierPath      *forwardArrowPath;
   UIBezierPath      *backArrowPath;
   CGAffineTransform  transform;
   PMThemeEngine     *themer;
   
   dateFormatter = [[NSDateFormatter new] autorelease];
   dayTitles     = [dateFormatter shortStandaloneWeekdaySymbols];
   monthTitles   = [dateFormatter standaloneMonthSymbols];
   
   context       = UIGraphicsGetCurrentContext();
   headerHeight  = PMThemeHeaderHeight();
   shadowPadding = PMThemeShadowInsets();
   
   width         = _initialFrame.size.width + shadowPadding.left + shadowPadding.right;
   height        = _initialFrame.size.height;
   hDiff         = width / 7;
   vDiff         = (height - headerHeight) / (PMThemeDayTitlesInHeaderIntOffset() + 5);
   
   themer        = [PMThemeEngine sharedInstance];
   dayFont       = [[themer elementOfGenericType:PMThemeFontGenericType
                                         subtype:PMThemeMainSubtype
                                            type:PMThemeDayTitlesElementType]
                    pmThemeGenerateFont];
   monthFont     = [[themer elementOfGenericType:PMThemeFontGenericType
                                         subtype:PMThemeMainSubtype
                                            type:PMThemeMonthTitleElementType]
                    pmThemeGenerateFont];
   
   for( int i = 0; i < dayTitles.count; i++)
   {
      index          = i + (_mondayFirstDayOfWeek ? 1 : 0);
      index          = index % 7;
      dayTitle       = [dayTitles objectAtIndex:index];
      //// dayHeader Drawing
      sz             = [dayTitle sizeWithFont:dayFont];
      dayHeaderFrame = CGRectMake( floor(i * hDiff) - 1
                                           , headerHeight + (PMThemeDayTitlesInHeaderIntOffset() * vDiff - sz.height) / 2
                                           , hDiff
                                           , sz.height);

      [[PMThemeEngine sharedInstance] drawString:dayTitle
                                        withFont:dayFont
                                          inRect:dayHeaderFrame
                                  forElementType:PMThemeDayTitlesElementType
                                         subType:PMThemeMainSubtype
                                       inContext:context];
   }

   month      = currentMonth;
   year       = currentYear;

   monthTitle = [NSString stringWithFormat:@"%@ %d", [monthTitles objectAtIndex:(month - 1)], year];
   //// Month Header Drawing
   textFrame  = CGRectMake( 0, (headerHeight - [monthTitle sizeWithFont:monthFont].height) / 2,
                           width, [monthFont pointSize]);

   [themer drawString:monthTitle
                                     withFont:monthFont
                                       inRect:textFrame
                               forElementType:PMThemeMonthTitleElementType
                                      subType:PMThemeMainSubtype
                                    inContext:context];


   arrowSizeDict = [themer elementOfGenericType:PMThemeSizeGenericType
                                                                subtype:PMThemeMainSubtype
                                                                   type:PMThemeMonthArrowsElementType];

   arrowOffsetDict = [themer elementOfGenericType:PMThemeOffsetGenericType
                                                                  subtype:PMThemeMainSubtype
                                                                     type:PMThemeMonthArrowsElementType];

   arrowSize       = [arrowSizeDict pmThemeGenerateSize];
   arrowOffset     = [arrowOffsetDict pmThemeGenerateSize];
   showsLeftArrow  = YES;
   showsRightArrow = YES;

   if( [self  allowedPeriod])
   {
      if( [[_currentDate pmDateByAddingMonths:-1] pmIsBefore:[[[self allowedPeriod] startDate] pmMonthStartDate]])
         showsLeftArrow = NO;
      else if( [[_currentDate pmDateByAddingMonths:1] pmIsAfter:[[self allowedPeriod] endDate]])
         showsRightArrow = NO;
   }

   if( showsLeftArrow)
   {
      //// backArrow Drawing
      backArrowPath = [UIBezierPath bezierPath];
      [backArrowPath moveToPoint:CGPointMake(hDiff / 2
                                             , headerHeight / 2)];    // left-center corner
      [backArrowPath addLineToPoint:CGPointMake(arrowSize.width + hDiff / 2
                                                , headerHeight / 2 + arrowSize.height / 2)];    // right-bottom corner
      [backArrowPath addLineToPoint:CGPointMake(arrowSize.width + hDiff / 2
                                                , headerHeight / 2 - arrowSize.height / 2)];     // right-top corner
      [backArrowPath addLineToPoint:CGPointMake(hDiff / 2
                                                , headerHeight / 2)];      // back to left-center corner
      [backArrowPath closePath];

      transform = CGAffineTransformMakeTranslation(arrowOffset.width - shadowPadding.left
                                                                       , arrowOffset.height);
      [backArrowPath applyTransform:transform];

      [themer drawPath:backArrowPath
                                forElementType:PMThemeMonthArrowsElementType
                                       subType:PMThemeMainSubtype
                                     inContext:context];
      leftArrowRect_ = CGRectInset(backArrowPath.bounds, -20, -20);
   }

   if( showsRightArrow)
   {
      //// forwardArrow Drawing
      forwardArrowPath = [UIBezierPath bezierPath];
      [forwardArrowPath moveToPoint:CGPointMake(width - hDiff / 2
                                                , headerHeight / 2)];     // right-center corner
      [forwardArrowPath addLineToPoint:CGPointMake(-arrowSize.width + width - hDiff / 2
                                                   , headerHeight / 2 + arrowSize.height / 2)];     // left-bottom corner
      [forwardArrowPath addLineToPoint:CGPointMake(-arrowSize.width + width - hDiff / 2
                                                   , headerHeight / 2 - arrowSize.height / 2)];     // left-top corner
      [forwardArrowPath addLineToPoint:CGPointMake(width - hDiff / 2
                                                   , headerHeight / 2)];    // back to right-center corner
      [forwardArrowPath closePath];

      transform = CGAffineTransformMakeTranslation(-arrowOffset.width - shadowPadding.left,
                                                                       arrowOffset.height);
      [forwardArrowPath applyTransform:transform];

      [themer drawPath:forwardArrowPath
                                forElementType:PMThemeMonthArrowsElementType
                                       subType:PMThemeMainSubtype
                                     inContext:context];
      rightArrowRect_ = CGRectInset([forwardArrowPath bounds], -20, -20);
   }
}


- (void) setCurrentDate:(NSDate *) currentDate
{
   if( [self allowedPeriod])
   {
      if(([currentDate pmIsBefore:[[[self allowedPeriod] startDate] pmMonthStartDate]])
         || ([currentDate pmIsAfter:[[self allowedPeriod] endDate]]))
         return;
   }

   _currentDate = [currentDate pmMonthStartDate];

   NSCalendar         *gregorian   = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
   NSDateComponents   *eComponents = [gregorian components:NSDayCalendarUnit
                                      | NSMonthCalendarUnit
                                      | NSYearCalendarUnit
                                                  fromDate:_currentDate];

   BOOL   needsRedraw = NO;

   if( [eComponents month] != currentMonth)
   {
      currentMonth = [eComponents month];
      needsRedraw  = YES;
   }

   if( [eComponents year] != currentYear)
   {
      currentYear = [eComponents year];
      needsRedraw = YES;
   }

   if( needsRedraw)
   {
      [[self daysView] setCurrentDate:currentDate];
      [self setNeedsDisplay];
      [self periodUpdated];

      if( [_delegate respondsToSelector:@selector( currentDateChanged: )])
         [_delegate currentDateChanged:currentDate];
   }
}


- (void) setMondayFirstDayOfWeek:(BOOL) mondayFirstDayOfWeek
{
   if( _mondayFirstDayOfWeek != mondayFirstDayOfWeek)
   {
      _mondayFirstDayOfWeek = mondayFirstDayOfWeek;
      [[self daysView] setMondayFirstDayOfWeek:mondayFirstDayOfWeek];
      [self setNeedsDisplay];
      [self periodUpdated];

      // Ugh... TODO: make other components redraw in more acceptable way
      if( [_delegate respondsToSelector:@selector( currentDateChanged: )])
         [_delegate currentDateChanged:_currentDate];
   }
}


- (UIFont *) font
{
   NSInteger   newFontSize = _initialFrame.size.width / 20;

   if( ! _font || (fontSize == 0) || (fontSize != newFontSize))
   {
      _font    = [UIFont fontWithName:@"Helvetica" size:newFontSize];
      [[self daysView] setFont:_font];
      fontSize = newFontSize;
   }

   return(_font);
}


- (void) periodUpdated
{
   NSDate      *monthStartDate;
   NSInteger   endIndex;
   NSInteger   index;
   NSInteger   length;
   NSInteger   monthStartDay;
   NSInteger   startIndex;
   int         maxNumberOfCells;
   int         numDaysInMonth;
   
   index            = [self indexForDate:_period.startDate];
   length           = [_period lengthInDays];

   numDaysInMonth   = [_currentDate pmNumberOfDaysInMonth];
   monthStartDate   = [_currentDate pmMonthStartDate];
   monthStartDay    = [monthStartDate pmGregorianWeekday];

   monthStartDay    = (monthStartDay + ([self mondayFirstDayOfWeek] ? 5 : 6)) % 7;
   numDaysInMonth  += monthStartDay;
   maxNumberOfCells = ceil((CGFloat) numDaysInMonth / 7) * 7 - 1;

   endIndex         = -1;
   startIndex       = -1;

   if( (index <= maxNumberOfCells) || (index + length <= maxNumberOfCells))
   {
      endIndex   = MIN( maxNumberOfCells, index + length);
      startIndex = MIN( maxNumberOfCells, index);
   }

   [[self selectionView] setStartIndex:startIndex];
   [[self selectionView] setEndIndex:endIndex];
   [[self daysView] setSelectedPeriod:_period];
   [[self daysView] redrawComponent];
}


- (void) setAllowedPeriod:(PMPeriod *) allowedPeriod
{
   NSDate   *startDate;
   NSDate   *endDate;
   
   startDate = [[allowedPeriod startDate] pmMidnightDate];
   endDate   = [[allowedPeriod endDate] pmMidnightDate];
   
   [_allowedPeriod release];
   _allowedPeriod = [[PMPeriod alloc] initWithStartDate:startDate
                                                endDate:endDate];
}


- (void) setPeriod:(PMPeriod *) period
{
   PMPeriod   *allowedPeriod;
   NSDate     *startDate;
   NSDate     *endDate;
   NSDate     *date;

   allowedPeriod = [self allowedPeriod];
   
   startDate     = [period startDate];

   // move this to PMPeriod
   if( allowedPeriod)
   {
      endDate    = [period startDate];
      date       = [allowedPeriod startDate];
      
      if( [startDate pmIsBefore:date])
         startDate    = date;
      if( [endDate pmIsBefore:date])
         endDate = date;

      date = [allowedPeriod endDate];
      if( [startDate pmIsAfter:date])
         startDate    = date;
      
      if( [endDate pmIsAfter:date])
         endDate = date;
      
      period = [[[PMPeriod alloc] initWithStartDate:startDate
                                            endDate:date] autorelease];
   }
   
   if( [_period isEqual:period])
      return;
   
   [_period autorelease];
   _period = [period retain];  // already copied
   
   if( ! _currentDate)
      [self setCurrentDate:startDate];
   
#warning (nat) expand delegate method
   if( [[self delegate] respondsToSelector:@selector( periodChanged:)])
      [[self delegate] periodChanged:_period];
   
   [self periodUpdated];
}


#pragma mark - Touches handling -

- (NSInteger) indexForDate:(NSDate *) date
{
   NSDate      *monthStartDate;
   NSInteger   monthStartDay;
   NSInteger   daysSinceMonthStart;

   monthStartDate      = [_currentDate pmMonthStartDate];
   monthStartDay       = [monthStartDate pmGregorianWeekday];

   monthStartDay       = (monthStartDay + (self.mondayFirstDayOfWeek ? 5 : 6)) % 7;

   daysSinceMonthStart = [date timeIntervalSinceDate:monthStartDate] / (60 * 60 * 24);
   
   return(daysSinceMonthStart + monthStartDay);
}


- (NSDate *) dateForPoint:(CGPoint) point
{
   CGFloat     xInCalendar;
   CGFloat     yInCalendar;
   CGFloat     hDiff;
   CGFloat     height;
   CGFloat     vDiff;
   CGFloat     width;
   NSDate      *monthStartDate;
   NSDate      *selectedDate;
   NSInteger   col;
   NSInteger   days;
   NSInteger   monthStartDay;
   NSInteger   row;
   int         maxNumberOfRows;
   int         numDaysInMonth;
   
   width           = _initialFrame.size.width;
   height          = _initialFrame.size.height;
   hDiff           = width / 7;
   vDiff           = (height - PMThemeHeaderHeight()) / ((PMThemeDayTitlesInHeader()) ? 6 : 7);

   yInCalendar     = point.y - (PMThemeHeaderHeight() + ((PMThemeDayTitlesInHeader()) ? 0 : vDiff));
   row             = yInCalendar / vDiff;

   numDaysInMonth  = [_currentDate pmNumberOfDaysInMonth];
   monthStartDate  = [_currentDate pmMonthStartDate];
   monthStartDay   = [monthStartDate pmGregorianWeekday];

   monthStartDay   = (monthStartDay + (self.mondayFirstDayOfWeek ? 5 : 6)) % 7;
   numDaysInMonth += monthStartDay;
   maxNumberOfRows = ceil((CGFloat) numDaysInMonth / 7) - 1;

   row             = MAX( 0, MIN( row, maxNumberOfRows));
   xInCalendar     = point.x - 2;
   col             = xInCalendar / hDiff;
   col             = MAX(0, MIN(col, 6));
   days            = row * 7 + col - monthStartDay;
   
   selectedDate   = [monthStartDate pmDateByAddingDays:days];

   return( selectedDate);
}


- (void) periodSelectionStarted:(CGPoint) point
{
   [self setPeriod:[PMPeriod oneDayPeriodWithDate:[self dateForPoint:point]]];
}


- (void) periodSelectionChanged:(CGPoint) point
{
   PMPeriod   *period;
   NSDate     *newDate;
   
   newDate = [self dateForPoint:point];

   if( _allowsPeriodSelection)
      period = [PMPeriod periodWithStartDate:[[self period] startDate]
                                     endDate:newDate];
   else
      period = [PMPeriod oneDayPeriodWithDate:newDate];
   
   [self setPeriod:period];
}


- (void) panTimerCallback:(NSTimer *) timer
{
   NSNumber   *increment;
   
   increment = [timer userInfo];

   [self setCurrentDate:[self.currentDate pmDateByAddingMonths:[increment intValue]]];
   [self periodSelectionChanged:_panPoint];
}


- (void) panHandling:(UIGestureRecognizer *) recognizer
{
   CGPoint    point;
   CGFloat    height;
   CGFloat    vDiff;
   NSNumber   *increment;
   
   point = [recognizer locationInView:self];

   height = _initialFrame.size.height;
   vDiff  = (height - PMThemeHeaderHeight()) / ((PMThemeDayTitlesInHeader()) ? 6 : 7);

   if( point.y > PMThemeHeaderHeight() + ((PMThemeDayTitlesInHeader()) ? 0 : vDiff)) // select date in calendar
   {
      if(([recognizer state] == UIGestureRecognizerStateBegan) && (recognizer.numberOfTouches == 1))
         [self periodSelectionStarted:point];
      
      else
         if(([recognizer state] == UIGestureRecognizerStateChanged) && (recognizer.numberOfTouches == 1))
      {
         if((point.x < 20) || (point.x > _initialFrame.size.width - 20))
         {
            self.panPoint = point;

            if( self.panTimer)
               return;

            increment = [NSNumber numberWithInt:point.x < 20 ? -1 : 1];

            self.panTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                             target:self
                                                           selector:@selector( panTimerCallback: )
                                                           userInfo:increment
                                                            repeats:YES];
         }
         else
         {
            [self.panTimer invalidate];
            self.panTimer = nil;
         }

         [self periodSelectionChanged:point];
      }
   }

   if(([recognizer state] == UIGestureRecognizerStateEnded)
      || ([recognizer state] == UIGestureRecognizerStateCancelled)
      || ([recognizer state] == UIGestureRecognizerStateFailed))
   {
      [self.panTimer invalidate];
      self.panTimer = nil;
   }
}


- (void) tapHandling:(UIGestureRecognizer *) recognizer
{
   CGPoint   point = [recognizer locationInView:self];

   CGFloat   height = _initialFrame.size.height;
   CGFloat   vDiff  = (height - PMThemeHeaderHeight()) / ((PMThemeDayTitlesInHeader()) ? 6 : 7);

   if( point.y > PMThemeHeaderHeight() + ((PMThemeDayTitlesInHeader()) ? 0 : vDiff)) // select date in calendar
   {
      [self periodSelectionStarted:point];
      return;
   }

   if( CGRectContainsPoint(leftArrowRect_, point))
   {
      // User tapped the prevMonth button
      [self setCurrentDate:[self.currentDate pmDateByAddingMonths:-1]];
   }
   else if( CGRectContainsPoint(rightArrowRect_, point))
   {
      // User tapped the nextMonth button
      [self setCurrentDate:[self.currentDate pmDateByAddingMonths:1]];
   }
}


- (void) longPressTimerCallback:(NSTimer *) timer
{
   NSNumber   *increment = timer.userInfo;

   [self setCurrentDate:[self.currentDate pmDateByAddingMonths:[increment intValue]]];
}


- (void) longPressHandling:(UIGestureRecognizer *) recognizer
{
   if(([recognizer state] == UIGestureRecognizerStateBegan) && (recognizer.numberOfTouches == 1))
   {
      if( self.longPressTimer)
         return;

      CGPoint   point  = [recognizer locationInView:self];
      CGFloat   height = _initialFrame.size.height;
      CGFloat   vDiff  = (height - PMThemeHeaderHeight()) / ((PMThemeDayTitlesInHeader()) ? 6 : 7);

      if( point.y > PMThemeHeaderHeight() + ((PMThemeDayTitlesInHeader()) ? 0 : vDiff)) // select date in calendar
      {
         [self periodSelectionChanged:point];
         return;
      }

      NSNumber   *increment = nil;

      if( CGRectContainsPoint(leftArrowRect_, point))
      {
         // User tapped the prevMonth button
         increment = [NSNumber numberWithInt:-1];
      }
      else if( CGRectContainsPoint(rightArrowRect_, point))
      {
         // User tapped the nextMonth button
         increment = [NSNumber numberWithInt:1];
      }

      if( increment)
      {
         self.longPressTimer = [NSTimer scheduledTimerWithTimeInterval:0.15f
                                                                target:self
                                                              selector:@selector( longPressTimerCallback: )
                                                              userInfo:increment
                                                               repeats:YES];
      }
   }
   else if( [recognizer state] == UIGestureRecognizerStateChanged)
   {
      if( self.longPressTimer)
         return;

      CGPoint   point = [recognizer locationInView:self];
      [self periodSelectionChanged:point];
   }
   else if(([recognizer state] == UIGestureRecognizerStateCancelled)
           || ([recognizer state] == UIGestureRecognizerStateEnded))
   {
      if( self.longPressTimer)
      {
         [self.longPressTimer invalidate];
         self.longPressTimer = nil;
      }
   }
}


- (void) setAllowsLongPressMonthChange:(BOOL) allowsLongPressMonthChange
{
   if( ! allowsLongPressMonthChange)
   {
      if( self.longPressGestureRecognizer)
      {
         [self removeGestureRecognizer:self.longPressGestureRecognizer];
         self.longPressGestureRecognizer = nil;
      }
   }
   else if( ! self.longPressGestureRecognizer)
   {
      self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(longPressHandling: )];
      self.longPressGestureRecognizer.numberOfTouchesRequired = 1;
      self.longPressGestureRecognizer.delegate             = self;
      self.longPressGestureRecognizer.minimumPressDuration = 0.5;
      [self addGestureRecognizer:self.longPressGestureRecognizer];
   }
}


@end

@implementation PMDaysView

@synthesize font;
@synthesize currentDate          = _currentDate;
@synthesize selectedPeriod       = _selectedPeriod;
@synthesize mondayFirstDayOfWeek = _mondayFirstDayOfWeek;
@synthesize rects;
@synthesize initialFrame = _initialFrame;

- (void) dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   [super dealloc];
}


- (void) redrawComponent
{
   [self setNeedsDisplay];
}


- (id) initWithFrame:(CGRect) frame
{
   if( ! (self = [super initWithFrame:frame]))
      return(nil);

   self.initialFrame = frame;

   self.backgroundColor  = [UIColor clearColor];
   self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

   [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector( redrawComponent )
                                                name:PMCalendarRedrawNotification
                                              object:nil];

   NSMutableArray   *tmpRects     = [NSMutableArray arrayWithCapacity:42];
   UIEdgeInsets     shadowPadding = PMThemeShadowInsets();
   CGFloat          headerHeight  = PMThemeHeaderHeight();
   UIFont           *calendarFont = PMThemeDefaultFont();

   CGFloat   width         = _initialFrame.size.width + shadowPadding.left + shadowPadding.right;
   CGFloat   hDiff         = width / 7;
   CGFloat   height        = _initialFrame.size.height;
   CGFloat   vDiff         = (height - headerHeight) / (PMThemeDayTitlesInHeaderIntOffset() + 6);
   CGSize    shadow2Offset = CGSizeMake(1, 1); // TODO: remove!

   for( NSInteger i = 0; i < 42; i++)
   {
      CGRect   rect = CGRectMake(ceil((i % 7) * hDiff)
                                 , headerHeight + ((int) (i / 7) + PMThemeDayTitlesInHeaderIntOffset()) * vDiff
                                 + (vDiff - calendarFont.pointSize) / 2 - shadow2Offset.height
                                 , hDiff
                                 , calendarFont.pointSize);
      [tmpRects addObject:NSStringFromCGRect(rect)];
   }

   self.rects = [NSArray arrayWithArray:tmpRects];

   return(self);
}


- (void) drawRect:(CGRect) rect
{
   BOOL                 isToday;
   BOOL                 selected;
   CGContextRef         context;
   CGFloat              hDiff;
   CGFloat              headerHeight;
   CGFloat              height;
   CGFloat              vDiff;
   CGFloat              width;
   CGRect               dayHeader2Frame;
   CGSize               bgOffset;
   NSDate               *dateOnFirst;
   NSDate               *firstDateInCal;
   NSDate               *monthStartDate;
   NSDate               *prevDateOnFirst;
   NSDictionary         *activeSelectedDict;
   NSDictionary         *inactiveSelectedDict;
   NSDictionary         *todayBGDict;
   NSDictionary         *todaySelectedBGDict;
   NSDictionary         *todaySelectedDict;
   NSString             *string;
   PMThemeElementType   type;
   PMThemeEngine        *themer;
   UIEdgeInsets         shadowPadding;
   UIEdgeInsets         rectInset;
   UIFont               *calendarFont;
   int                  day;
   int                  dayNumber;
   int                  index;
   int                  numDaysInMonth;
   int                  numDaysInPrevMonth;
   int                  selectionEndIndex;
   int                  selectionStartIndex;
   int                  todayIndex;
   int                  weekdayOfFirst;
   int                  weekdayOfNextFirst;
   UIBezierPath         *selectedRectPath;
   NSString             *coordinatesRound;
   
   context              = UIGraphicsGetCurrentContext();

   dateOnFirst          = [_currentDate pmMonthStartDate];
   weekdayOfFirst       = ([dateOnFirst pmGregorianWeekday] + (_mondayFirstDayOfWeek ? 5 : 6)) % 7 + 1;
   numDaysInMonth       = [dateOnFirst pmNumberOfDaysInMonth];
   monthStartDate       = [_currentDate pmMonthStartDate];
   todayIndex           = [[[NSDate date] pmDateWithoutTime] pmDaysSinceDate:monthStartDate] + weekdayOfFirst - 1;

   // Find number of days in previous month
   prevDateOnFirst      = [[_currentDate pmDateByAddingMonths:-1] pmMonthStartDate];
   numDaysInPrevMonth   = [prevDateOnFirst pmNumberOfDaysInMonth];
   firstDateInCal       = [monthStartDate pmDateByAddingDays:(-weekdayOfFirst + 2)];

   selectionStartIndex  = [[[self selectedPeriod] normalizedPeriod].startDate pmDaysSinceDate:firstDateInCal] + 1;
   selectionEndIndex    = [[[self selectedPeriod] normalizedPeriod].endDate pmDaysSinceDate:firstDateInCal] + 1;
   
   themer               = [PMThemeEngine sharedInstance];

   calendarFont         = PMThemeDefaultFont();
   shadowPadding        = PMThemeShadowInsets();
   headerHeight         = PMThemeHeaderHeight();
   
   // digits drawing
   todayBGDict          = [themer themeDictForType:PMThemeCalendarDigitsTodayElementType
                                          subtype:PMThemeBackgroundSubtype];
   todaySelectedBGDict  = [themer themeDictForType:PMThemeCalendarDigitsTodaySelectedElementType
                                          subtype:PMThemeBackgroundSubtype];
   inactiveSelectedDict = [themer themeDictForType:PMThemeCalendarDigitsInactiveSelectedElementType
                                           subtype:PMThemeMainSubtype];
   todaySelectedDict    = [themer themeDictForType:PMThemeCalendarDigitsTodaySelectedElementType
                                        subtype:PMThemeMainSubtype];
   activeSelectedDict   = [themer themeDictForType:PMThemeCalendarDigitsActiveSelectedElementType
                                         subtype:PMThemeMainSubtype];

   // Draw the text for each of those days.
   for( int i = 0; i <= weekdayOfFirst - 2; i++)
   {
      day      = numDaysInPrevMonth - weekdayOfFirst + 2 + i;
      selected = (i >= selectionStartIndex) && (i <= selectionEndIndex);
      isToday  = (i == todayIndex);

      string          = [NSString stringWithFormat:@"%d", day];
      dayHeader2Frame = CGRectFromString([[self rects] objectAtIndex:i]);
      type            = PMThemeCalendarDigitsInactiveElementType;

      if( isToday)
      {
         type = PMThemeCalendarDigitsTodayElementType;

         if( selected && todaySelectedDict)
            type = PMThemeCalendarDigitsTodaySelectedElementType;
      }
      else if( selected && inactiveSelectedDict)
         type = PMThemeCalendarDigitsInactiveSelectedElementType;

      [themer drawString:string
                withFont:calendarFont
                  inRect:dayHeader2Frame
          forElementType:type
                 subType:PMThemeMainSubtype
               inContext:context];
   }

   day = 1;

   for( int i = 0; i < 6; i++)
   {
      for( int j = 0; j < 7; j++)
      {
         dayNumber = i * 7 + j;

         if((dayNumber >= (weekdayOfFirst - 1)) && (day <= numDaysInMonth))
         {
            string          = [NSString stringWithFormat:@"%d", day];
            dayHeader2Frame = CGRectFromString([[self rects] objectAtIndex:dayNumber]);
            selected        = (dayNumber >= selectionStartIndex) && (dayNumber <= selectionEndIndex);
            isToday         = (dayNumber == (todayIndex + weekdayOfFirst - 1));

            if( isToday)
            {
               if( todayBGDict)
               {
                  width    = _initialFrame.size.width + shadowPadding.left + shadowPadding.right;
                  height   = _initialFrame.size.height;
                  hDiff    = (width + shadowPadding.left + shadowPadding.right - PMThemeInnerPadding().width * 2) / 7;
                  vDiff    = (height - PMThemeHeaderHeight() - PMThemeInnerPadding().height *
                      2) / ((PMThemeDayTitlesInHeader()) ? 6 : 7);
                  bgOffset = [[todayBGDict pmElementInThemeDictOfGenericType:PMThemeOffsetGenericType] pmThemeGenerateSize];

                  coordinatesRound = [todayBGDict pmElementInThemeDictOfGenericType:PMThemeCoordinatesRoundGenericType];

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

                  rect = CGRectMake( floor(j * hDiff) + bgOffset.width,
                                     headerHeight + (i + PMThemeDayTitlesInHeaderIntOffset()) * vDiff + bgOffset.height,
                                     floor( hDiff),
                                     vDiff);
                  type = PMThemeCalendarDigitsTodayElementType;

                  if( selected && todaySelectedBGDict)
                     type = PMThemeCalendarDigitsTodaySelectedElementType;

                  rectInset = [[themer elementOfGenericType:PMThemeEdgeInsetsGenericType
                                                    subtype:PMThemeBackgroundSubtype
                                                       type:type]
                               pmThemeGenerateEdgeInsets];

                  selectedRectPath = [UIBezierPath bezierPathWithRoundedRect:UIEdgeInsetsInsetRect(rect,
                                                                                   rectInset)
                                                cornerRadius:0];

                  
                  [themer drawPath:selectedRectPath
                    forElementType:type
                           subType:PMThemeBackgroundSubtype
                         inContext:context];
               }
            }

            type = PMThemeCalendarDigitsActiveElementType;
            if( isToday)
            {
               type = PMThemeCalendarDigitsTodayElementType;

               if( selected && todaySelectedDict)
                  type = PMThemeCalendarDigitsTodaySelectedElementType;
            }
            else
               if( selected && activeSelectedDict)
                  type = PMThemeCalendarDigitsActiveSelectedElementType;

            [themer drawString:string
                      withFont:calendarFont
                        inRect:dayHeader2Frame
                forElementType:type
                       subType:PMThemeMainSubtype
                     inContext:context];

            ++day;
         }
      }
   }

   weekdayOfNextFirst = (weekdayOfFirst - 1 + numDaysInMonth) % 7;
   if( weekdayOfNextFirst > 0)
   {
      // Draw the text for each of those days.
      for( int i = weekdayOfNextFirst; i < 7; i++)
      {
         index           = numDaysInMonth + weekdayOfFirst + i - weekdayOfNextFirst - 1;
         day             = i - weekdayOfNextFirst + 1;
         isToday         = (numDaysInMonth + day - 1 == todayIndex);
         selected        = (index >= selectionStartIndex) && (index <= selectionEndIndex);
         string         = [NSString stringWithFormat:@"%d", day];
         dayHeader2Frame = CGRectFromString([[self rects] objectAtIndex:index]);

         type = PMThemeCalendarDigitsInactiveElementType;

         if( isToday)
         {
            type = PMThemeCalendarDigitsTodayElementType;

            if( selected && todaySelectedDict)
               type = PMThemeCalendarDigitsTodaySelectedElementType;
         }
         else
            if( selected && inactiveSelectedDict)
               type = PMThemeCalendarDigitsInactiveSelectedElementType;

         [themer drawString:string
                   withFont:calendarFont
                     inRect:dayHeader2Frame
             forElementType:type
                    subType:PMThemeMainSubtype
                  inContext:context];
      }
   }
}


- (void) setCurrentDate:(NSDate *) date
{
   if( ! [_currentDate isEqualToDate:date])
   {
      [_currentDate autorelease];
      _currentDate = [date copy];
      [self setNeedsDisplay];
   }
}


- (void) setMondayFirstDayOfWeek:(BOOL) mondayFirstDayOfWeek
{
   if( _mondayFirstDayOfWeek != mondayFirstDayOfWeek)
   {
      _mondayFirstDayOfWeek = mondayFirstDayOfWeek;
      [self setNeedsDisplay];
   }
}

@end
