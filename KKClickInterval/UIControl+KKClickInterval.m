//
//  UIControl+KKClickInterval.m
//  KKClickInterval
//
//  Created by ZhuKangKang on 2020/12/1.
//

#import "UIControl+KKClickInterval.h"
#import <objc/runtime.h>

static double kDefaultInterval = 0.5;

@interface UIControl ()
/// 是否可以点击
@property (nonatomic, assign) BOOL isIgnoreClick;
/// 上次按钮响应的方法名
@property (nonatomic, strong) NSString *oldSELName;
@end

@implementation UIControl (KKClickInterval)

+ (void)kk_exchangeClickMethod {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //  获得方法选择器
        SEL originalSel = @selector(sendAction:to:forEvent:);
        SEL newSel = @selector(kk_sendClickIntervalAction:to:forEvent:);
        //获得方法
        Method originalMethod = class_getInstanceMethod(self , originalSel);
        Method newMethod = class_getInstanceMethod(self , newSel);
        
        //   如果发现方法已经存在，返回NO；也可以用来做检查用,这里是为了避免源方法没有存在的情况;如果方法没有存在,我们则先尝试添加被替换的方法的实现
        BOOL isAddNewMethod = class_addMethod(self, originalSel, method_getImplementation(newMethod), "v@:");
        if (isAddNewMethod) {
            class_replaceMethod(self, newSel, method_getImplementation(originalMethod), "v@:");
        } else {
            method_exchangeImplementations(originalMethod, newMethod);
        }
    });
}

- (void)kk_sendClickIntervalAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    if ([self isKindOfClass:[UIButton class]] && !self.ignoreClickInterval) {
        NSLog(@"+++++++%s",__FUNCTION__);
        if (self.clickInterval <= 0) {
            self.clickInterval = kDefaultInterval;
        };
        
        NSString *currentSELName = NSStringFromSelector(action);
        if (self.isIgnoreClick && [self.oldSELName isEqualToString:currentSELName]) {
            return;
        }
        
        if (self.clickInterval > 0) {
            self.isIgnoreClick = YES;
            self.oldSELName = currentSELName;
            [self performSelector:@selector(kk_ignoreClickState:)
                       withObject:@(NO)
                       afterDelay:self.clickInterval];
        }
    }
    [self kk_sendClickIntervalAction:action to:target forEvent:event];
}

- (void)kk_ignoreClickState:(NSNumber *)ignoreClickState {
    self.isIgnoreClick = ignoreClickState.boolValue;
    self.oldSELName = @"";
}

- (NSTimeInterval)clickInterval {

    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}

- (void)setClickInterval:(NSTimeInterval)clickInterval {
    objc_setAssociatedObject(self, @selector(clickInterval), @(clickInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isIgnoreClick {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setIsIgnoreClick:(BOOL)isIgnoreClick {
    objc_setAssociatedObject(self, @selector(isIgnoreClick), @(isIgnoreClick), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ignoreClickInterval {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setIgnoreClickInterval:(BOOL)ignoreClickInterval {
    objc_setAssociatedObject(self, @selector(ignoreClickInterval), @(ignoreClickInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)oldSELName {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setOldSELName:(NSString *)oldSELName {
    objc_setAssociatedObject(self, @selector(oldSELName), oldSELName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
