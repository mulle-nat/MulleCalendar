//
//  MulleThemeShadow.h
//  MulleCalendar
//
//  Created by Pavel Mazurin on 7/23/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//
//
// Usurped by Nat! on 1/22/13.
// Copyright (c) 2012 Nat! All rights reserved.
//
// This is still MIT licensed
//

#import <UIKit/UIKit.h>


@interface MulleThemeShadow : NSObject
{
   UIColor   *color_;
   CGSize    offset_;
   CGFloat   blurRadius_;
}

- (id) initWithDictionary:(NSDictionary *) dict;

- (UIColor *) color;
- (CGSize) offset;
- (CGFloat) blurRadius;

@end
