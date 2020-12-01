# 测试 UIButton 时间间隔的 Demo

####  [iOS 高效开发之 - 全局避免 UIButton 频繁点击](https://juejin.cn/post/6899057632716750855?utm_source=gold_browser_extension)

![ UIButton ](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9ea85c0c13da45b8a66a0f656cfdf606~tplv-k3u1fbpfcp-watermark.image)

### 友情关联
**[1、iOS 高效开发之 - 3分钟实现自定义 Xcode 初始化的模板](https://juejin.cn/post/6882678008415518734)**

**[2、iOS 高效开发之 - 从 0 开始手把手教你制作自己的 Pod 库](https://juejin.cn/post/6868910104620728333)**

### 测试 Demo 的GitHub 链接
[欢迎各位大佬 Star 和 提出意见](https://github.com/GavinKangDeveloper/ClickInterval)

在项目中，为了避免按钮被频繁点击，我们一般会操作 UIButton 的可点击状态：`enabled`，但是如果需要处理的多了，会增加我们开发的工作量，也会增加逻辑不够清晰下的遗漏处理导致按钮无法点击的重大问题，所以我们需要一个可以全局处理 UIButton 时间间隔点击事件的方法，同时可以根据具体的需求，调整时间间隔的时间。

### 1、需求思考
- 为了解决这个需求，我们需要考虑以下几点：
1. `UIButton` 使用的点击方法，是 `UIButton` 独有的，还是继承于父类？
2. 如果继承于父类，处理父类的点击方法，是否对父类的其他子类有影响？
3. `UIButton` 有多种 `Event`，处理的时候是否会同时有多种 `Event` 有影响？
4. 怎么实现点击的时间间隔？
5. 为了可扩展性，要可以单独设置某个 `Button` 的时间间隔，以及是否使用增加的时间间隔方法

### 2、解决办法
- 针对以上面的思考，我们一一进行解决
1. 通过查看 ` - (void)addTarget:(nullable id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents; ` 方法，我们可知：UIButton 使用到的方法，是来自其父类 ` UIControl `

![UICotrol](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0ce44081d4e1431ea4b09813f75c3631~tplv-k3u1fbpfcp-watermark.image)

2.  ` UIControl ` 的子类有：`UIButton、UITextField、UISlider、UIDatePicker、UISegmentedControl`，也就是说，除了 `UIButton` ,这些类也是可以使用 ` Event ` 方法，所以在处理的时候，要过滤当前处理的类
3.  为了兼容多个 `Event` 的场景，要增加一个属性，用来记录当前触发的方法名
4.  增加时间间隔的属性，用于控制响应事件的响应间隔
5.  暴露属性，让 `Button` 通过修改默认时间间隔和是否使用当前类，实现单独设置的需求

### 3、解决技术
- 解决这个需求主要用到 `Runtime` 的 2 个地方：
1. 使用 `Runtime` 的 `objc_setAssociatedObject` 和 `objc_getAssociatedObject` 重写分类中成员变量的 `setter` 和 `getter` 方法
2. 使用 `Runtime` 的 `Method-Swizzing` 交换原方法和自定义方法

- 注意：
- 里面涉及到 3 个坑：
1. 在交换方法的时候，要使用单例，让方法只交换一次，避免交换多次，没有达到方法实际交互的效果。
2. 要判断当前响应的类是否是 `UIButton`：`[self isKindOfClass:[UIButton class]]`，避免 `UIControl` 的其他子类受到影响 


### 4、代码实现解析

#### Runtime 交换方法图解

![Runtime 交换方法](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/abd0e088330b466f8b9d82b9c156145d~tplv-k3u1fbpfcp-watermark.image)

比如说在现有类中有两个方法，方法 1 和 方法 2，当经过 `Method - Swizzing` 操作后，实际上就是修改方法选择器 对应实际的方法实现，比如经过 `Method - Swizzing` 操作后，相当于方法 1 和方法 2 对应的实现方法发生交换。

#### 分类中属性效果的实现
在分类定义实现的时候，不能直接添加属性，但是可以通过 `Runtime` 手动添加 `setter/getter` 方法，达到分类可以添加属性的效果。

#### isKindOfClass & isSubclassOfClass & isMemberOfClass 的区别

- `isKindOfClass`：判断对象是否为某类或者其派生类的实例（对象方法）
- `isSubclassOfClass`：判断对象是否为某类或者其派生类的实例（类方法）
- `isMemberOfClass`：判断对象是否为某个特定类的实例（对象方法）

#### 使用到的 Runtime 中的方法

- 获得给定类的指定实例方法；

注意：如果给定的类或者父类没有对应的方法，会返回 `nil` 。

```
/** 
 cls:获得哪个类中的方法
 SEL name:获得方法的对象
*/

class_getInstanceMethod(Class  _Nullable __unsafe_unretained cls , SEL  _Nonnull name)
```
- 重写 `getter` 方法

```
/** 
 object:关联的源对象
 key:关联的 key
*/

objc_getAssociatedObject(<#id  _Nonnull object#>, <#const void * _Nonnull key#>);
```
- 重写 `setter` 方法

```
 /**
 object:关联的源对象
 key:关联的 key
 value:关联对象的值，可以通过将此值置成 nil 来清除关联
 policy:关联的策略
*/
objc_setAssociatedObject(<#id  _Nonnull object#>, <#const void * _Nonnull key#>, <#id  _Nullable value#>, <#objc_AssociationPolicy policy#>)
```


### 具体代码
#### 注意：

这里我是使用自定义的方法，没有像网上很多人使用系统的 `+load` 方法，这两个区别是：系统的 `+load` 方法会自动调用，自定义方法需要自己调用；我认为自定义方法可以控制是否把功能加入项目，更灵活，这里根据个人爱好决定是否在 `+load` 方法中实现。

有同学说为什么交换的是 `sendAction: to: forEvent:` 方法，而不是 `addTarget: action: forControlEvents:`，探究这个原因，我们要区分一下这两个方法的作用：

-  `sendAction: to: forEvent:` ：

当用户点击了按钮，`UIControl` 会调用 `sendAction:to:forEvent:` 方法来将行为消息发送到 `UIApplication` 对象 ，再由 `UIApplication`对象调用 `sendAction:to:fromSender:forEvent:` 将消息分发到指定的 `target` 上，从而达到监听某个特定的对象 `object`, 对于特定的事件`event`做了什么特定的处理`selector`。这里涉及到的具体响应链，就不详说了，要不然就跑题了，可以自行 `Google`。

- `addTarget: action: forControlEvents:`

这个方法只是把`action/target`的映射加载到 `UIControl` 上面，并不会马上执行 `selector`。

综上所述可知：实际控制响应间隔的时机需要在  `sendAction: to: forEvent:` 方法中，而不是在 `addTarget: action: forControlEvents:` 方法里。

```

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIControl (KKClickInterval)
/// 点击事件响应的时间间隔，不设置或者大于 0 时为默认时间间隔
@property (nonatomic, assign) NSTimeInterval clickInterval;
/// 是否忽略响应的时间间隔
@property (nonatomic, assign) BOOL ignoreClickInterval;
+ (void)kk_exchangeClickMethod;

@end

NS_ASSUME_NONNULL_END



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


```
