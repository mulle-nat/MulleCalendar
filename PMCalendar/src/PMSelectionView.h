//
//  PMSelectionView.h
//  PMCalendar
//
//  Created by Pavel Mazurin on 7/14/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * PMSelectionView is an internal class.
 *
 * PMSelectionView is a view which renders selection. 
 */
@interface PMSelectionView : UIView
{
   NSInteger   startIndex_;
   NSInteger   endIndex_;

@private
   CGRect      initialFrame_;
}


- (void) setStartIndex:(NSInteger) value;
- (void) setEndIndex:(NSInteger) value;

- (NSInteger) startIndex;
- (NSInteger) endIndex;

@end
