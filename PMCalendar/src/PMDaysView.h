//
//  PMDaysView.h
//  PMCalendarDemo
//
//  Created by Nat! on 21.01.13.
//
//

#import <UIKit/UIKit.h>



@class PMPeriod;

@interface PMDaysView : UIView
{
   NSDate     *currentDate_; // month to show
   PMPeriod   *selectedPeriod_;
   UIFont     *font_;

   BOOL       mondayFirstDayOfWeek_;

@private
   NSArray    *rects_;
   CGRect     initialFrame_;
}

- (void) redrawComponent;
- (void) setSelectedPeriod:(PMPeriod *) period;
- (void) setMondayFirstDayOfWeek:(BOOL) flag;
- (void) setCurrentDate:(NSDate *) date;
- (void) setFont:(UIFont *) font;

@end
