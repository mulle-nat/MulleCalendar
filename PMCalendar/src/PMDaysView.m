//
//  PMDaysView.m
//  PMCalendarDemo
//
//  Created by Nat! on 21.01.13.
//
//

#import "PMDaysView.h"

#import "PMCalendarController.h"
#import "PMPeriod.h"
#import "PMTheme.h"
#import "PMThemeEngine.h"


@implementation PMDaysView

- (UIFont *) font               { return( font_); }
- (NSDate *) currentDate        { return( currentDate_); }
- (PMPeriod *) selectedPeriod   { return( selectedPeriod_); }
- (BOOL) mondayFirstDayOfWeek   { return( mondayFirstDayOfWeek_); }
- (NSArray *) rects             { return( rects_); }

- (void) _setMondayFirstDayOfWeek:(BOOL) flag
{
   mondayFirstDayOfWeek_ = flag;
}


- (void) _setCurrentDate:(NSDate *) date
{
   [currentDate_ autorelease];
   currentDate_ = [date retain];
}


- (void) setSelectedPeriod:(PMPeriod *) period
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
                                                name:PMCalendarRedrawNotification
                                              object:nil];
   
   tmpRects      = [NSMutableArray arrayWithCapacity:42];
   shadowPadding = PMThemeShadowInsets();
   headerHeight  = PMThemeHeaderHeight();
   calendarFont  = PMThemeDefaultFont();
   
   width         = initialFrame_.size.width + shadowPadding.left + shadowPadding.right;
   hDiff         = width / 7;
   height        = initialFrame_.size.height;
   vDiff         = (height - headerHeight) / (PMThemeDayTitlesInHeaderIntOffset() + 6);
   shadow2Offset = CGSizeMake(1, 1); // TODO: remove!
   
   for( NSInteger i = 0; i < 42; i++)
   {
      rect = CGRectMake( ceil((i % 7) * hDiff),
                        headerHeight + ((int) (i / 7) + PMThemeDayTitlesInHeaderIntOffset()) * vDiff
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
   
   dateOnFirst          = [currentDate_ pmMonthStartDate];
   weekdayOfFirst       = ([dateOnFirst pmGregorianWeekday] + (mondayFirstDayOfWeek_ ? 5 : 6)) % 7 + 1;
   numDaysInMonth       = [dateOnFirst pmNumberOfDaysInMonth];
   monthStartDate       = [currentDate_ pmMonthStartDate];
   todayIndex           = [[[NSDate date] pmDateWithoutTime] pmDaysSinceDate:monthStartDate] + weekdayOfFirst - 1;
   
   // Find number of days in previous month
   prevDateOnFirst      = [[currentDate_ pmDateByAddingMonths:-1] pmMonthStartDate];
   numDaysInPrevMonth   = [prevDateOnFirst pmNumberOfDaysInMonth];
   firstDateInCal       = [monthStartDate pmDateByAddingDays:(-weekdayOfFirst + 2)];
   
   selectionStartIndex  = [[selectedPeriod_ startDate] pmDaysSinceDate:firstDateInCal] + 1;
   selectionEndIndex    = [[selectedPeriod_ endDate] pmDaysSinceDate:firstDateInCal] + 1;
   
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
                  width    = initialFrame_.size.width + shadowPadding.left + shadowPadding.right;
                  height   = initialFrame_.size.height;
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