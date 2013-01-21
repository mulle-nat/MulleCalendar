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
#import "PMDaysView.h"
#import "PMPeriod.h"
#import "PMSelectionView.h"
#import "PMTheme.h"

#import "PMThemeEngine.h"


@implementation PMCalendarView

- (id <PMCalendarViewDelegate>)   delegate
{
   return( delegate_);
}

- (void) setDelegate:(id <PMCalendarViewDelegate>) delegate
{
   delegate_  = delegate;
}

- (PMPeriod *) period               { return( period_); }
- (PMPeriod *) allowedPeriod        { return( allowedPeriod_); }
- (NSDate *) currentDate            { return( currentDate_); }

- (BOOL) mondayFirstDayOfWeek       { return( mondayFirstDayOfWeek_); }
- (BOOL) allowsPeriodSelection      { return( allowsPeriodSelection_); }
- (BOOL) allowsLongPressMonthChange { return( allowsLongPressMonthChange_); }


- (void) _setAllowedPeriod:(PMPeriod *) period
{
   [allowedPeriod_ autorelease];
   allowedPeriod_ = [period copy];
}


- (void) _setPeriod:(PMPeriod *) period
{
   [period_ autorelease];
   period_ = [period copy];
}


- (void) _setCurrentDate:(NSDate *) date
{
   [currentDate_ autorelease];
   currentDate_ = [date copy];
}


- (void) setAllowsPeriodSelection:(BOOL) flag
{
   allowsPeriodSelection_ = flag;
}


- (id) initWithFrame:(CGRect) frame
{
   CGSize   innerPadding;
   
   if( ! (self = [super initWithFrame:frame]))
      return(nil);

   initialFrame_ = frame;

   [self setBackgroundColor:[UIColor clearColor]];
   [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
   [self setMondayFirstDayOfWeek:NO];

   tapRecognizer_ = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector( tapHandling: )] autorelease];
   [tapRecognizer_ setNumberOfTapsRequired:1];
   [tapRecognizer_ setNumberOfTouchesRequired:1];
   [tapRecognizer_ setDelegate:self];

   [self addGestureRecognizer:tapRecognizer_];

   panRecognizer_ = [[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector( panHandling: )] autorelease];
   [panRecognizer_ setDelegate:self];
   [self addGestureRecognizer:panRecognizer_];

   [self setAllowsLongPressMonthChange:YES];

   innerPadding = PMThemeInnerPadding();

   selectionView_ = [[[PMSelectionView alloc] initWithFrame:CGRectInset( [self bounds], -innerPadding.width,
                                                                       -innerPadding.height)] autorelease];
   [self addSubview:selectionView_];
   
   daysView_ = [[[PMDaysView alloc] initWithFrame:[self bounds]] autorelease];
   [daysView_ setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

   [self addSubview:daysView_];
   
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
   
   width         = initialFrame_.size.width + shadowPadding.left + shadowPadding.right;
   height        = initialFrame_.size.height;
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
      index          = i + (mondayFirstDayOfWeek_ ? 1 : 0);
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

   month      = currentMonth_;
   year       = currentYear_;

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
      if( [[currentDate_ pmDateByAddingMonths:-1] pmIsBefore:[[allowedPeriod_ startDate] pmMonthStartDate]])
         showsLeftArrow = NO;
      else if( [[currentDate_ pmDateByAddingMonths:1] pmIsAfter:[allowedPeriod_ endDate]])
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
   NSCalendar         *gregorian;
   NSDateComponents   *eComponents;
   BOOL               needsRedraw;

   if( allowedPeriod_)
   {
      if(([currentDate pmIsBefore:[[allowedPeriod_ startDate] pmMonthStartDate]])
         || ([currentDate pmIsAfter:[allowedPeriod_ endDate]]))
         return;
   }

   [currentDate_ autorelease];
   currentDate_ = [[currentDate pmMonthStartDate] retain];

#warning (nat) why not local ?
   gregorian    = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
   eComponents  = [gregorian components:NSDayCalendarUnit
                  | NSMonthCalendarUnit
                  | NSYearCalendarUnit
                              fromDate:currentDate_];

   needsRedraw = NO;

   if( [eComponents month] != currentMonth_)
   {
      currentMonth_ = [eComponents month];
      needsRedraw  = YES;
   }

   if( [eComponents year] != currentYear_)
   {
      currentYear_ = [eComponents year];
      needsRedraw = YES;
   }

   if( needsRedraw)
   {
      [daysView_ setCurrentDate:currentDate];
      [self setNeedsDisplay];
      [self periodUpdated];

      if( [delegate_ respondsToSelector:@selector( currentDateChanged: )])
         [delegate_ currentDateChanged:currentDate];
   }
}


- (void) setMondayFirstDayOfWeek:(BOOL) mondayFirstDayOfWeek
{
   if( mondayFirstDayOfWeek_ != mondayFirstDayOfWeek)
   {
      mondayFirstDayOfWeek_ = mondayFirstDayOfWeek;
      
      [daysView_ setMondayFirstDayOfWeek:mondayFirstDayOfWeek];
      [self setNeedsDisplay];
      [self periodUpdated];

      // Ugh... TODO: make other components redraw in more acceptable way
      if( [delegate_ respondsToSelector:@selector( currentDateChanged: )])
         [delegate_ currentDateChanged:currentDate_];
   }
}


- (UIFont *) font
{
   NSInteger   newFontSize;

   if( font_ && fontSize_ != 0)
      return( font_);

   newFontSize = initialFrame_.size.width / 20;
      
   if( fontSize_ != newFontSize)
   {
      [font_ autorelease];
      font_    = [[UIFont fontWithName:@"Helvetica" size:newFontSize] retain];

      [daysView_ setFont:font_];
      fontSize_ = newFontSize;
   }
   return( font_);
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
   
   index            = [self indexForDate:period_.startDate];
   length           = [period_ lengthInDays];

   numDaysInMonth   = [currentDate_ pmNumberOfDaysInMonth];
   monthStartDate   = [currentDate_ pmMonthStartDate];
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

   [selectionView_ setStartIndex:startIndex];
   [selectionView_ setEndIndex:endIndex];
   
   [daysView_ setSelectedPeriod:period_];
   [daysView_ redrawComponent];
}


- (void) setAllowedPeriod:(PMPeriod *) allowedPeriod
{
   NSDate   *startDate;
   NSDate   *endDate;
   
   startDate = [[allowedPeriod startDate] pmMidnightDate];
   endDate   = [[allowedPeriod endDate] pmMidnightDate];
   
   [self _setAllowedPeriod:[PMPeriod periodWithStartDate:startDate
                                                 endDate:endDate]];
}


- (void) setPeriod:(PMPeriod *) period
{
   PMPeriod   *allowedPeriod;
   NSDate     *startDate;
   NSDate     *endDate;
   NSDate     *date;

   allowedPeriod = allowedPeriod_;
   
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
                                            endDate:endDate] autorelease];
   }
   
   if( [period_ isEqual:period])
      return;
   
   [self _setPeriod:period];
   if( ! currentDate_)
      [self _setCurrentDate:startDate];
   
#warning (nat) expand delegate method
   if( [[self delegate] respondsToSelector:@selector( periodChanged:)])
      [[self delegate] periodChanged:period_];
   
   [self periodUpdated];
}


#pragma mark - Touches handling -

- (NSInteger) indexForDate:(NSDate *) date
{
   NSDate      *monthStartDate;
   NSInteger   monthStartDay;
   NSInteger   daysSinceMonthStart;

   monthStartDate      = [currentDate_ pmMonthStartDate];
   monthStartDay       = [monthStartDate pmGregorianWeekday];

   monthStartDay       = (monthStartDay + ([self mondayFirstDayOfWeek] ? 5 : 6)) % 7;

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
   
   width           = initialFrame_.size.width;
   height          = initialFrame_.size.height;
   hDiff           = width / 7;
   vDiff           = (height - PMThemeHeaderHeight()) / ((PMThemeDayTitlesInHeader()) ? 6 : 7);

   yInCalendar     = point.y - (PMThemeHeaderHeight() + ((PMThemeDayTitlesInHeader()) ? 0 : vDiff));
   row             = yInCalendar / vDiff;

   numDaysInMonth  = [currentDate_ pmNumberOfDaysInMonth];
   monthStartDate  = [currentDate_ pmMonthStartDate];
   monthStartDay   = [monthStartDate pmGregorianWeekday];

   monthStartDay   = (monthStartDay + ([self mondayFirstDayOfWeek] ? 5 : 6)) % 7;
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

   if( allowsPeriodSelection_)
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

   [self setCurrentDate:[currentDate_ pmDateByAddingMonths:[increment intValue]]];
   [self periodSelectionChanged:panPoint_];  
}


- (void) panHandling:(UIGestureRecognizer *) recognizer
{
   CGPoint    point;
   CGFloat    height;
   CGFloat    vDiff;
   NSNumber   *increment;
   
   point = [recognizer locationInView:self];

   height = initialFrame_.size.height;
   vDiff  = (height - PMThemeHeaderHeight()) / ((PMThemeDayTitlesInHeader()) ? 6 : 7);

   if( point.y > PMThemeHeaderHeight() + ((PMThemeDayTitlesInHeader()) ? 0 : vDiff)) // select date in calendar
   {
      if(([recognizer state] == UIGestureRecognizerStateBegan) && (recognizer.numberOfTouches == 1))
         [self periodSelectionStarted:point];
      
      else
         if(([recognizer state] == UIGestureRecognizerStateChanged) && (recognizer.numberOfTouches == 1))
      {
         if((point.x < 20) || (point.x > initialFrame_.size.width - 20))
         {
            panPoint_ = point;

            if( panTimer_)
               return;

            increment = [NSNumber numberWithInt:point.x < 20 ? -1 : 1];

            panTimer_ = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                             target:self
                                                           selector:@selector( panTimerCallback: )
                                                           userInfo:increment
                                                            repeats:YES];
         }
         else
         {
            [panTimer_ invalidate];
            panTimer_ = nil;
         }

         [self periodSelectionChanged:point];
      }
   }

   if( ([recognizer state] == UIGestureRecognizerStateEnded)
      || ([recognizer state] == UIGestureRecognizerStateCancelled)
      || ([recognizer state] == UIGestureRecognizerStateFailed))
   {
      [panTimer_ invalidate];
      panTimer_ = nil;
   }
}


- (void) tapHandling:(UIGestureRecognizer *) recognizer
{
   CGPoint   point;
   CGFloat   height;
   CGFloat   vDiff;

   point  = [recognizer locationInView:self];
   height = initialFrame_.size.height;
   vDiff  = (height - PMThemeHeaderHeight()) / ((PMThemeDayTitlesInHeader()) ? 6 : 7);

   if( point.y > PMThemeHeaderHeight() + ((PMThemeDayTitlesInHeader()) ? 0 : vDiff)) // select date in calendar
   {
      [self periodSelectionStarted:point];
      return;
   }

   if( CGRectContainsPoint(leftArrowRect_, point))
   {
      // User tapped the prevMonth button
      [self setCurrentDate:[currentDate_ pmDateByAddingMonths:-1]];
   }
   else
      if( CGRectContainsPoint(rightArrowRect_, point))
      {
         // User tapped the nextMonth button
         [self setCurrentDate:[currentDate_ pmDateByAddingMonths:1]];
      }
}


- (void) longPressTimerCallback:(NSTimer *) timer
{
   NSNumber   *increment;
   
   increment = [timer userInfo];
   [self setCurrentDate:[currentDate_ pmDateByAddingMonths:[increment intValue]]];
}


- (void) longPressHandling:(UIGestureRecognizer *) recognizer
{
   CGPoint   point;
   CGFloat   height;
   CGFloat   vDiff;
   
   if(([recognizer state] == UIGestureRecognizerStateBegan) && (recognizer.numberOfTouches == 1))
   {
      if( longPressTimer_)
         return;
      
      point  = [recognizer locationInView:self];
      height = initialFrame_.size.height;
      vDiff  = (height - PMThemeHeaderHeight()) / ((PMThemeDayTitlesInHeader()) ? 6 : 7);
      
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
      else
         if( CGRectContainsPoint(rightArrowRect_, point))
         {
            // User tapped the nextMonth button
            increment = [NSNumber numberWithInt:1];
         }
      
      if( increment)
      {
         longPressTimer_ = [NSTimer scheduledTimerWithTimeInterval:0.15f
                                                            target:self
                                                          selector:@selector( longPressTimerCallback: )
                                                          userInfo:increment
                                                           repeats:YES];
      }
   }
   else
      if( [recognizer state] == UIGestureRecognizerStateChanged)
      {
         if( longPressTimer_)
            return;
         
         CGPoint   point = [recognizer locationInView:self];
         [self periodSelectionChanged:point];
      }
      else
         if(([recognizer state] == UIGestureRecognizerStateCancelled)
            || ([recognizer state] == UIGestureRecognizerStateEnded))
         {
            if( longPressTimer_)
            {
               [longPressTimer_ invalidate];
               longPressTimer_ = nil;
            }
         }
}


- (void) setAllowsLongPressMonthChange:(BOOL) allowsLongPressMonthChange
{
   if( ! allowsLongPressMonthChange)
   {
      if( longPressRecognizer_)
      {
         [self removeGestureRecognizer:longPressRecognizer_];
         longPressRecognizer_ = nil;
      }
      return;
   }

   if( ! longPressRecognizer_)
   {
      longPressRecognizer_ = [[[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(longPressHandling: )] autorelease];
      [longPressRecognizer_ setNumberOfTouchesRequired:1];
      [longPressRecognizer_ setMinimumPressDuration:0.5];
      [longPressRecognizer_ setDelegate:self];
      
      [self addGestureRecognizer:longPressRecognizer_];
   }
}


@end


