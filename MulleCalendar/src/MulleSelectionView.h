//
//  MulleSelectionView.h
//  MulleCalendar
//
//  Created by Pavel Mazurin on 7/14/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//
//
// Usurped by Nat! on 1/22/13.
// Copyright (c) 2012 Nat! All rights reserved.
//
// This is still MIT licensed
//

#import <UIKit/UIKit.h>

/**
 * MulleSelectionView is an internal class.
 *
 * MulleSelectionView is a view which renders selection. 
 */
@interface MulleSelectionView : UIView
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
