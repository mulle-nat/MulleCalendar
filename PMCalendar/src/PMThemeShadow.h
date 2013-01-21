//
//  PMThemeShadow.h
//  PMCalendar
//
//  Created by Pavel Mazurin on 7/23/12.
//  Copyright (c) 2012 Pavel Mazurin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PMThemeShadow : NSObject
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
