//
//  YDDragBtn.h
//  test_drag
//
//  Created by Aka on 2018/8/7.
//  Copyright © 2018年 Aka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GHDragBtn : UIButton

+ (NSString *)version;

- (id)initInKeyWindowWithFrame:(CGRect)frame;
- (id)initInView:(id)view WithFrame:(CGRect)frame;
- (BOOL)isDragging;

+ (void)removeAllFromKeyWindow;
+ (void)removeAllFromView:(id)superView;

@end
