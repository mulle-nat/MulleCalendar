//
//  MulleDaysView.m
//  MulleCalendarDemo
//
//  Created by Nat! on 21.01.13.
//
//

#import "MulleDaysView.h"

#import "MulleCalendarController.h"
#import "MullePeriod.h"
#import "MulleTheme.h"
#import "MulleThemeEngine.h"


@implementation MulleDaysView

- (UIFont *) font               { return( font_); }
- (NSDate *) currentDate        { return( currentDate_); }
- (MullePeriod *) selectedPeriod   { return( selectedPeriod_); }
- (BOOL) mondayFirstDayOfWeek   { return( mondayFirstDayOfWeek_); }
//- (NSArray *) rects             { return( rects_); }

- (void) _setMondayFirstDayOfWeek:(BOOL) flag
{
   mondayFirstDayOfWeek_ = flag;
}


- (void) _setCurrentDate:(NSDate *) date
{
   [currentDate_ autorelease];
   currentDate_ = [date retain];
}


- (void) setSelectedPeriod:(MullePeriod *) period
{
   [selectedPeriod_ autorelease];
   selectedPeriod_ = [[period normalizedPeriod] retain];
}


- (void) setFont:(UIFont *) font
{
   [font_ autorelease];
   font_ = [font retain];
}


- (void) dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];

   [rects_ release];
   [currentDate_ release];
   [selectedPeriod_ release];
   [font_ release];
   
   [super dealloc];
}


- (void) redrawComponent
{
   [self setNeedsDisplay];
}


- (id) initWithFrame:(CGRect) frame
{
   CGFloat          headerHeight;
   CGFloat          hDiff;
   CGFloat          height;
   CGFloat          vDiff;
   CGFloat          width;
   CGSize           shadow2Offset;
   CGRect           rect;
   NSMutableArray   *tmpRects;
   UIEdgeInsets     shadowPadding;
   UIFont           *calendarFont;
   
   if( ! (self = [super initWithFrame:frame]))
      return( nil);
   
   initialFrame_ = frame;
   
   [self setBackgroundColor:[UIColor clearColor]];
   [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
   
   [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector( redrawComponent )
                                                name:MulleCalendarRedrawNotification
                                              object:nil];
   
   tmpRects      = [NSMutableArray arrayWithCapacity:42];
   shadowPadding = MulleThemeShadowInsets();
   headerHeight  = MulleThemeHeaderHeight();
   calendarFont  = MulleThemeDefaultFont();
   
   width         = initialFrame_.size.width + shadowPadding.left + shadowPadding.right;
   hDiff         = width / 7;
   height        = initialFrame_.size.height;
   vDiff         = (height - headerHeight) / (MulleThemeDayTitlesInHeaderIntOffset() + 6);
   shadow2Offset = CGSizeMake(1, 1); // TODO: remove!
   
   for( NSInteger i = 0; i < 42; i++)
   {
      rect = CGRectMake( ceil((i % 7) * hDiff),
                        headerHeight + ((int) (i / 7) + MulleThemeDayTitlesInHeaderIntOffset()) * vDiff
                        + (vDiff - calendarFont.pointSize) / 2 - shadow2Offset.height,
                        hDiff,
                        calendarFont.pointSize);
      [tmpRects addObject:NSStringFromCGRect( rect)];
   }
   
   rects_ = [tmpRects copy];
   
   return( self);
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
   MulleThemeElementType   type;
   MulleThemeEngine        *themer;
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
   
   dateOnFirst          = [currentDate_ pmMonthStartDate];
   weekdayOfFirst       = ([dateOnFirst pmGregorianWeekday] + (mondayFirstDayOfWeek_ ? 5 : 6)) % 7 + 1;
   numDaysInMonth       = [dateOnFirst pmNumberOfDaysInMonth];
   monthStartDate       = [currentDate_ pmMonthStartDate];
   todayIndex           = [[[NSDate date] pmDateWithoutTime] pmDaysSinceDate:monthStartDate] + weekdayOfFirst - 1;
   
   // Find number of days in previous month
   prevDateOnFirst      = [[currentDate_ pmDateByAddingMonths:-1] pmMonthStartDate];
   numDaysInPrevMonth   = [prevDateOnFirst pmNumberOfDaysInMonth];
   firstDateInCal       = [monthStartDate pmDateByAddingDays:(-weekdayOfFirst + 1)];
   
   selectionStartIndex  = [[selectedPeriod_ startDate] pmDaysSinceDate:firstDateInCal];
   selectionEndIndex    = [[selectedPeriod_ endDate] pmDaysSinceDate:firstDateInCal];
   
   themer               = [MulleThemeEngine sharedInstance];
   
   calendarFont         = MulleThemeDefaultFont();
   shadowPadding        = MulleThemeShadowInsets();
   headerHeight         = MulleThemeHeaderHeight();
   
   // digits drawing
   todayBGDict          = [themer themeDictForType:MulleThemeCalendarDigitsTodayElementType
                                           subtype:MulleThemeBackgroundSubtype];
   todaySelectedBGDict  = [themer themeDictForType:MulleThemeCalendarDigitsTodaySelectedElementType
                                           subtype:MulleThemeBackgroundSubtype];
   inactiveSelectedDict = [themer themeDictForType:MulleThemeCalendarDigitsInactiveSelectedElementType
                                           subtype:MulleThemeMainSubtype];
   todaySelectedDict    = [themer themeDictForType:MulleThemeCalendarDigitsTodaySelectedElementType
                                           subtype:MulleThemeMainSubtype];
   activeSelectedDict   = [themer themeDictForType:MulleThemeCalendarDigitsActiveSelectedElementType
                                           subtype:MulleThemeMainSubtype];
   
   // Draw the text for each of those days.
   for( int i = 0; i <= weekdayOfFirst - 2; i++)
   {
      day      = numDaysInPrevMonth - weekdayOfFirst + 2 + i;
      selected = (i >= selectionStartIndex) && (i <= selectionEndIndex);
      isToday  = (i == todayIndex);
      
#warning (nat) ooooooh CGRectFromString day nrs could be cached
      string          = [NSString stringWithFormat:@"%d", day];
      dayHeader2Frame = CGRectFromString( [rects_ objectAtIndex:i]);
      type            = MulleThemeCalendarDigitsInactiveElementType;
      
      if( isToday)
      {
         type = MulleThemeCalendarDigitsTodayElementType;
         
         if( selected && todaySelectedDict)
            type = MulleThemeCalendarDigitsTodaySelectedElementType;
      }
      else
         if( selected && inactiveSelectedDict)
            type = MulleThemeCalendarDigitsInactiveSelectedElementType;
      
      [themer drawString:string
                withFont:calendarFont
                  inRect:dayHeader2Frame
          forElementType:type
                 subType:MulleThemeMainSubtype
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
#warning (nat) oooooh CGRectFromString
            dayHeader2Frame = CGRectFromString( [rects_ objectAtIndex:dayNumber]);
            selected        = (dayNumber >= selectionStartIndex) && (dayNumber <= selectionEndIndex);
            isToday         = (dayNumber == todayIndex);
            
            if( isToday)
            {
               if( todayBGDict)
               {
                  width    = initialFrame_.size.width + shadowPadding.left + shadowPadding.right;
                  height   = initialFrame_.size.height;
                  hDiff    = (width + shadowPadding.left + shadowPadding.right - MulleThemeInnerPadding().width * 2) / 7;
                  vDiff    = (height - MulleThemeHeaderHeight() - MulleThemeInnerPadding().height *
                              2) / ((MulleThemeDayTitlesInHeader()) ? 6 : 7);
                  
                  bgOffset         = [[todayBGDict pmElementInThemeDictOfGenericType:MulleThemeOffsetGenericType] pmThemeGenerateSize];
                  coordinatesRound = [todayBGDict pmElementInThemeDictOfGenericType:MulleThemeCoordinatesRoundGenericType];
                  
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
                                    headerHeight + (i + MulleThemeDayTitlesInHeaderIntOffset()) * vDiff + bgOffset.height,
                                    floor( hDiff),
                                    vDiff);
                  type = MulleThemeCalendarDigitsTodayElementType;
                  
                  if( selected && todaySelectedBGDict)
                     type = MulleThemeCalendarDigitsTodaySelectedElementType;
                  
                  rectInset = [[themer elementOfGenericType:MulleThemeEdgeInsetsGenericType
                                                    subtype:MulleThemeBackgroundSubtype
                                                       type:type]
                               pmThemeGenerateEdgeInsets];
                  
                  selectedRectPath = [UIBezierPath bezierPathWithRoundedRect:UIEdgeInsetsInsetRect(rect,
                                                                                                   rectInset)
                                                                cornerRadius:0];
                  
                  
                  [themer drawPath:selectedRectPath
                    forElementType:type
                           subType:MulleThemeBackgroundSubtype
                         inContext:context];
               }
            }
            
            type = MulleThemeCalendarDigitsActiveElementType;
            if( isToday)
            {
               type = MulleThemeCalendarDigitsTodayElementType;
               
               if( selected && todaySelectedDict)
                  type = MulleThemeCalendarDigitsTodaySelectedElementType;
            }
            else
               if( selected && activeSelectedDict)
                  type = MulleThemeCalendarDigitsActiveSelectedElementType;
            
            [themer drawString:string
                      withFont:calendarFont
                        inRect:dayHeader2Frame
                forElementType:type
                       subType:MulleThemeMainSubtype
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
         isToday         = (day == todayIndex);
         selected        = (index >= selectionStartIndex) && (index <= selectionEndIndex);
         string         = [NSString stringWithFormat:@"%d", day];
#warning (nat) ooooooh CGRectFromString
         dayHeader2Frame = CGRectFromString([rects_ objectAtIndex:index]);
         
         type = MulleThemeCalendarDigitsInactiveElementType;
         
         if( isToday)
         {
            type = MulleThemeCalendarDigitsTodayElementType;
            
            if( selected && todaySelectedDict)
               type = MulleThemeCalendarDigitsTodaySelectedElementType;
         }
         else
            if( selected && inactiveSelectedDict)
               type = MulleThemeCalendarDigitsInactiveSelectedElementType;
         
         [themer drawString:string
                   withFont:calendarFont
                     inRect:dayHeader2Frame
             forElementType:type
                    subType:MulleThemeMainSubtype
                  inContext:context];
      }
   }
}


- (void) setCurrentDate:(NSDate *) date
{
   if( ! [currentDate_ isEqualToDate:date])
   {
      [self _setCurrentDate:date];
      [self setNeedsDisplay];
   }
}


- (void) setMondayFirstDayOfWeek:(BOOL) mondayFirstDayOfWeek
{
   if( mondayFirstDayOfWeek_ != mondayFirstDayOfWeek)
   {
      [self setMondayFirstDayOfWeek:mondayFirstDayOfWeek];
      [self setNeedsDisplay];
   }
}

@end