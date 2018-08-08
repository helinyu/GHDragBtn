//
//  YDDragBtn.m
//  test_drag
//
//  Created by Aka on 2018/8/7.
//  Copyright © 2018年 Aka. All rights reserved.
//

#import "GHDragBtn.h"

#define YD_DRAG_BTN_VERSION @"0.2"

#define YD_WAITING_KEYWINDOW_AVAILABLE 0.f
#define YD_AUTODOCKING_ANIMATE_DURATION 0.2f
#define YD_DOUBLE_TAP_TIME_INTERVAL 0.36f

@interface GHDragBtn ()

typedef void (^YDDragBtnBlock)(GHDragBtn *btn);

@property (nonatomic, assign) BOOL draggable;
@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, assign) BOOL autoDocking;
@property (nonatomic, assign) BOOL singleTapBeCanceled;

@property (nonatomic, assign) CGPoint beginLocation;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGR;

@property (nonatomic, copy) YDDragBtnBlock longPressGRBlock;
@property (nonatomic, copy) YDDragBtnBlock tapBlock;
@property (nonatomic, copy) YDDragBtnBlock doubleTapGRBlock;
@property (nonatomic, copy) YDDragBtnBlock draggingBlock;
@property (nonatomic, copy) YDDragBtnBlock dragDoneBlock;
@property (nonatomic, copy) YDDragBtnBlock autoDockingBlock;
@property (nonatomic, copy) YDDragBtnBlock autoDockingDoneBlock;

@end

@implementation GHDragBtn

+ (NSString *)version {
    return YD_DRAG_BTN_VERSION;
}

- (id)initInKeyWindowWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        [self defaultSetting];
    }
    return self;
}

- (id)initInView:(id)view WithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [view addSubview:self];
        [self defaultSetting];
    }
    return self;
}

- (void)defaultSetting {
    [self.layer setCornerRadius:self.frame.size.height / 2];
    [self.layer setBorderColor:[UIColor clearColor].CGColor];
    [self.layer setBorderWidth:0.5];
    [self.layer setMasksToBounds:YES];
    
    _draggable = YES;
    _autoDocking = YES;
    _singleTapBeCanceled = NO;
    
    _longPressGR = [UILongPressGestureRecognizer new];
    [_longPressGR addTarget:self action:@selector(onGRAction:)];
    [_longPressGR setAllowableMovement:0];
    [self addGestureRecognizer:_longPressGR];
}

- (void)onGRAction:(UILongPressGestureRecognizer *)gr {
    switch ([gr state]) {
        case UIGestureRecognizerStateBegan: {
            if (_longPressGRBlock) {
                _longPressGRBlock(self);
            }
        }
            break;
        default:
            break;
    }
}

- (void)setTapBlock:(void (^)(GHDragBtn *))tapBlock {
    _tapBlock = tapBlock;
    
    if (_tapBlock) {
        [self addTarget:self action:@selector(buttonTouched) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - Touch
- (void)buttonTouched {
    [self performSelector:@selector(executeButtonTouchedBlock) withObject:nil afterDelay:(_doubleTapGRBlock ? YD_DOUBLE_TAP_TIME_INTERVAL : 0)];
}

- (void)executeButtonTouchedBlock {
    if (!_singleTapBeCanceled && _tapBlock && !_isDragging) {
        _tapBlock(self);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    _isDragging = NO;
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    if (touch.tapCount == 2) {
        if (_doubleTapGRBlock) {
            _singleTapBeCanceled = YES;
            _doubleTapGRBlock(self);
        }
    } else {
        _singleTapBeCanceled = NO;
    }
    _beginLocation = [[touches anyObject] locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_draggable) {
        UITouch *touch = [touches anyObject];
        CGPoint currentLocation = [touch locationInView:self];
        float offsetX = currentLocation.x - _beginLocation.x;
        float offsetY = currentLocation.y - _beginLocation.y;
        if (offsetX == 0 && offsetY == 0) {
            _isDragging = NO;
        }
        else {
            _isDragging = YES;
            self.center = CGPointMake(self.center.x + offsetX, self.center.y + offsetY);
            CGRect superviewFrame = self.superview.frame;
            CGRect frame = self.frame;
            CGFloat leftLimitX = frame.size.width / 2;
            CGFloat rightLimitX = superviewFrame.size.width - leftLimitX;
            CGFloat topLimitY = frame.size.height / 2;
            CGFloat bottomLimitY = superviewFrame.size.height - topLimitY;
            
            if (self.center.x > rightLimitX) {
                self.center = CGPointMake(rightLimitX, self.center.y);
            }else if (self.center.x <= leftLimitX) {
                self.center = CGPointMake(leftLimitX, self.center.y);
            }
            
            if (self.center.y > bottomLimitY) {
                self.center = CGPointMake(self.center.x, bottomLimitY);
            }else if (self.center.y <= topLimitY){
                self.center = CGPointMake(self.center.x, topLimitY);
            }
            
            if (_draggingBlock) {
                _draggingBlock(self);
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded: touches withEvent: event];
    
    if (_isDragging && _dragDoneBlock) {
        _dragDoneBlock(self);
        _singleTapBeCanceled = YES;
    }
    
    if (_isDragging && _autoDocking) {
        CGRect superviewFrame = self.superview.frame;
        CGRect frame = self.frame;
        CGFloat middleX = superviewFrame.size.width / 2;
        
        __weak typeof (self) wSelf = self;
        if (self.center.x >= middleX) {
            [UIView animateWithDuration:YD_AUTODOCKING_ANIMATE_DURATION animations:^{
                wSelf.center = CGPointMake(superviewFrame.size.width - frame.size.width / 2, wSelf.center.y);
                !wSelf.autoDockingBlock? :wSelf.autoDockingBlock(wSelf);
            } completion:^(BOOL finished) {
                !wSelf.autoDockingDoneBlock? :wSelf.autoDockingDoneBlock(wSelf);
            }];
        } else {
            [UIView animateWithDuration:YD_AUTODOCKING_ANIMATE_DURATION animations:^{
                wSelf.center = CGPointMake(frame.size.width / 2, wSelf.center.y);
                !wSelf.autoDockingBlock? :wSelf.autoDockingBlock(wSelf);
            } completion:^(BOOL finished) {
                !wSelf.autoDockingDoneBlock? :wSelf.autoDockingDoneBlock(wSelf);
            }];
        }
    }
    
    _isDragging = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _isDragging = NO;
    [super touchesCancelled:touches withEvent:event];
}

- (BOOL)isDragging {
    return _isDragging;
}

#pragma mark - remove
+ (void)removeAllFromKeyWindow {
    for (id view in [[UIApplication sharedApplication].keyWindow subviews]) {
        if ([view isKindOfClass:[GHDragBtn class]]) {
            [view removeFromSuperview];
        }
    }
}

+ (void)removeAllFromView:(id)superView {
    for (id view in [superView subviews]) {
        if ([view isKindOfClass:[GHDragBtn class]]) {
            [view removeFromSuperview];
        }
    }
}

@end
