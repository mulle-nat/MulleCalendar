//
//  MulleDaysView.h
//  MulleCalendarDemo
//
//  Created by Nat! on 21.01.13.
//
//

#import <UIKit/UIKit.h>



@class MullePeriod;

@interface MulleDaysView : UIView
{
   NSDate     *currentDate_; // month to show
   MullePeriod   *selectedPeriod_;
   UIFont     *font_;

   BOOL       mondayFirstDayOfWeek_;

@private
   NSArray    *rects_;
   CGRect     initialFrame_;
}

- (void) redrawComponent;
- (void) setSelectedPeriod:(MullePeriod *) period;
- (void) setMondayFirstDayOfWeek:(BOOL) flag;
- (void) setCurrentDate:(NSDate *) date;
- (void) setFont:(UIFont *) font;

@end
