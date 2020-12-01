//
//  UIControl+KKClickInterval.h
//  KKClickInterval
//
//  Created by ZhuKangKang on 2020/12/1.
//

#import <UIKit/UIKit.h>

@interface UIControl (KKClickInterval)
/// 点击事件响应的时间间隔，不设置或者大于 0 时为默认时间间隔
@property (nonatomic, assign) NSTimeInterval clickInterval;
/// 是否忽略响应的时间间隔
@property (nonatomic, assign) BOOL ignoreClickInterval;
+ (void)kk_exchangeClickMethod;

@end
