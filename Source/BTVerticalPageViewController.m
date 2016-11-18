//
//  BTVerticalPageViewController.m
//  BTVerticalPageViewController
//
//  Created by zhangzhilong on 15/5/15.
//  Copyright (c) 2015年 zhangzhilong. All rights reserved.
//

#import "BTVerticalPageViewController.h"
#import <objc/runtime.h>

#define kVerticalPageViewControllerSize [UIScreen mainScreen].bounds.size

//容器容量大小
static NSInteger const BTVerticalPageViewControllerCapacity = 3;
//给每个childViewController绑定属性时用到的key
static const void *BTVerticalPageViewControllerKey = "BTVerticalPageViewControllerKey";

@interface UIViewController (BTVerticalPageViewControllerSet)

//类别方法用于给UIViewController实例绑定bt_verticalPageViewController属性
- (void)bt_setVerticalPageViewController:(BTVerticalPageViewController *)pageViewController;

@end

@interface BTVerticalPageViewController ()

/** 对外只读，对内读写 */
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, assign) BTVerticalPageViewControllerNavigationDirection direction;

/** 该数组按正确顺序保存childViewController */
@property (nonatomic, strong) NSMutableArray *viewControllers;

/** 内容容器view */
@property (nonatomic, strong) UIView *contentView;

/** 当前是否正在进行动画 */
@property (nonatomic, assign, readwrite, getter=isTransitioning) BOOL transitioning;

@end

@implementation BTVerticalPageViewController
#pragma mark - Initial Related
- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    _lazyLoad = YES;
    _viewControllers = [[NSMutableArray alloc] initWithCapacity:BTVerticalPageViewControllerCapacity];
    //添加三个null对象为占位符
    for (int i = 0; i < BTVerticalPageViewControllerCapacity; i++) {
        [_viewControllers addObject:[NSNull null]];
    }
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Layout Related
- (void)configUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.contentView];
    
    [self loadInitialChildViewControllers];
    
    [self layoutChildViewControllersWithAnimated:NO completion:nil];
}

- (void)layoutChildViewControllersWithAnimated:(BOOL)animated
                                    completion:(void (^)())completion {
    if (animated) {
        [UIView animateWithDuration:0.3f animations:^{
            [self layoutChildViewControllers];
            [self transioningToViewController:_viewControllers[1]];
        } completion:^(BOOL finished) {
            !completion ?: completion();
        }];
    } else {
        [self layoutChildViewControllers];
        [self transioningToViewController:_viewControllers[1]];
        !completion ?: completion();
    }
}

- (void)layoutChildViewControllers {
    //将childViewController拜访到正确的frame
    for (int i = 0; i < _viewControllers.count; i++) {
        id obj = _viewControllers[i];
        if ([obj isKindOfClass:[NSNull class]]) {
            continue;
        }
        UIViewController *childViewController = obj;
        CGRect frame = childViewController.view.frame;
        frame.origin.y = kVerticalPageViewControllerSize.height * i;
        childViewController.view.frame = frame;
    }
}

#pragma mark - Getter and Setter
- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, - kVerticalPageViewControllerSize.height, kVerticalPageViewControllerSize.width, kVerticalPageViewControllerSize.height * BTVerticalPageViewControllerCapacity)];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView;
}

- (void)setCurrentViewController:(UIViewController *)currentViewController {
    _currentViewController = currentViewController;
}

- (void)setDirection:(BTVerticalPageViewControllerNavigationDirection)direction {
    _direction = direction;
}

#pragma mark - Transition Related
- (void)transitionWithDirection:(BTVerticalPageViewControllerNavigationDirection)direction
                       animated:(BOOL)animated
                     completion:(void (^)(BOOL success))completion {
    if (self.isTransitioning) {
        return;
    }
    self.direction = direction;
    UIViewController *previousViewController = self.currentViewController;
    if (self.lazyLoad) {
        if (direction == BTVerticalPageViewControllerNavigationDirectionForward) {
            if ([_viewControllers[2] isKindOfClass:[NSNull class]]) {
                if (![self loadAfterViewController]) {
                    !completion ?: completion(NO);
                    return;
                }
            }
            [self removeChildViewControllerFromContainer:_viewControllers[0]];
            [_viewControllers removeObjectAtIndex:0];
            [_viewControllers addObject:[NSNull null]];
            
            [self willTransitionToViewController:_viewControllers[1]];
            
            [self layoutChildViewControllersWithAnimated:animated completion:^{
                self.currentViewController = _viewControllers[1];
        
                [self didTransitionFromViewController:previousViewController];
            }];
        } else {
            if ([_viewControllers[0] isKindOfClass:[NSNull class]]) {
                if (![self loadBeforeViewController]) {
                    !completion ?: completion(NO);
                    return;
                }
            }
            [self removeChildViewControllerFromContainer:[_viewControllers lastObject]];
            [_viewControllers removeLastObject];
            [_viewControllers insertObject:[NSNull null] atIndex:0];
            
            [self willTransitionToViewController:_viewControllers[1]];
            
            [self layoutChildViewControllersWithAnimated:animated completion:^{
                self.currentViewController = _viewControllers[1];
                
                [self didTransitionFromViewController:previousViewController];
            }];
        }
    } else {
        if (direction == BTVerticalPageViewControllerNavigationDirectionForward) {
            if ([[_viewControllers lastObject] isKindOfClass:[NSNull class]]) {
                //下面没有页面无法向下翻页
                return;
            }
            [self removeChildViewControllerFromContainer:_viewControllers[0]];
            [_viewControllers removeObjectAtIndex:0];
            [_viewControllers addObject:[NSNull null]];
            
            [self willTransitionToViewController:_viewControllers[1]];
            
            [self layoutChildViewControllersWithAnimated:animated completion:^{
                self.currentViewController = _viewControllers[1];
                [self loadAfterViewController];
                
                [self didTransitionFromViewController:previousViewController];
            }];
        } else {
            if ([_viewControllers[0] isKindOfClass:[NSNull class]]) {
                //上面没有页面无法向上翻页
                return;
            }
            [self removeChildViewControllerFromContainer:[_viewControllers lastObject]];

            [_viewControllers removeLastObject];
            [_viewControllers insertObject:[NSNull null] atIndex:0];
            
            [self willTransitionToViewController:_viewControllers[1]];
            
            [self layoutChildViewControllersWithAnimated:YES completion:^{
                self.currentViewController = _viewControllers[1];
                [self loadBeforeViewController];
                [self didTransitionFromViewController:previousViewController];
            }];
        }
    }
}

- (void)willTransitionToViewController:(UIViewController *)viewController {
    self.transitioning = YES;
    if ([self.delegate respondsToSelector:@selector(bt_verticalPageViewController:willTransitionToViewController:)]) {
        [self.delegate bt_verticalPageViewController:self willTransitionToViewController:viewController];
    }
}

- (void)transioningToViewController:(UIViewController *)viewController {
    if ([self.delegate respondsToSelector:@selector(bt_verticalPageViewController:transitioningToViewController:)]) {
        [self.delegate bt_verticalPageViewController:self transitioningToViewController:viewController];
    }
}

- (void)didTransitionFromViewController:(UIViewController *)viewController {
    self.transitioning = NO;
    if ([self.delegate respondsToSelector:@selector(bt_verticalPageViewController:didTransitionFromViewController:)]) {
        [self.delegate bt_verticalPageViewController:self didTransitionFromViewController:viewController];
    }
}

#pragma mark - Child ViewController Related
- (void)loadInitialChildViewControllers {
    [self loadCurrentViewController];
    if (!self.lazyLoad) {
        [self loadBeforeViewController];
        [self loadAfterViewController];
    }
}

- (UIViewController *)loadCurrentViewController {
    if (![self.dataSource respondsToSelector:@selector(bt_verticalPageViewControllerInitialCurrentViewController)]) {
        return nil;
    }
    UIViewController *currentViewController = [self.dataSource bt_verticalPageViewControllerInitialCurrentViewController];
    if (!currentViewController || ![currentViewController isKindOfClass:[UIViewController class]]) {
        return nil;
    }
    
    [self addChildViewControllerToContainer:currentViewController];
    CGRect frame = currentViewController.view.frame;
    frame.origin.y = kVerticalPageViewControllerSize.height;
    currentViewController.view.frame = frame;
    
    self.currentViewController = currentViewController;
    [_viewControllers replaceObjectAtIndex:1 withObject:currentViewController];
    
    return currentViewController;
}

- (UIViewController *)loadBeforeViewController {
    if (![self.dataSource respondsToSelector:@selector(bt_verticalPageViewController:viewControllerBeforeViewController:)]) {
        return nil;
    }
    UIViewController *beforeViewController = [self.dataSource bt_verticalPageViewController:self viewControllerBeforeViewController:self.currentViewController];
    if (!beforeViewController || ![beforeViewController isKindOfClass:[UIViewController class]]) {
        return nil;
    }
    
    [self addChildViewControllerToContainer:beforeViewController];
    CGRect frame = beforeViewController.view.frame;
    frame.origin.y = 0;
    beforeViewController.view.frame = frame;
    
    [_viewControllers replaceObjectAtIndex:0 withObject:beforeViewController];
    
    return beforeViewController;
}

- (UIViewController *)loadAfterViewController {
    if (![self.dataSource respondsToSelector:@selector(bt_verticalPageViewController:viewControllerAfterViewController:)]) {
        return nil;
    }
    UIViewController *afterViewController = [self.dataSource bt_verticalPageViewController:self viewControllerAfterViewController:self.currentViewController];
    if (!afterViewController || ![afterViewController isKindOfClass:[UIViewController class]]) {
        return nil;
    }
    
    [self addChildViewControllerToContainer:afterViewController];
    CGRect frame = afterViewController.view.frame;
    frame.origin.y = kVerticalPageViewControllerSize.height * 2;
    afterViewController.view.frame = frame;
    
    [_viewControllers replaceObjectAtIndex:2 withObject:afterViewController];
    
    return afterViewController;
}

- (void)addChildViewControllerToContainer:(UIViewController *)childViewController {
    if (!childViewController || ![childViewController isKindOfClass:[UIViewController class]]) {
        return;
    }
    
    [self addChildViewController:childViewController];
    [self.contentView addSubview:childViewController.view];
    childViewController.view.frame = CGRectMake(0, 0, kVerticalPageViewControllerSize.width, kVerticalPageViewControllerSize.height);
    [childViewController didMoveToParentViewController:self];
    
    //给每个childViewController添加bt_verticalPageViewController引用
    [childViewController bt_setVerticalPageViewController:self];
}

- (void)removeChildViewControllerFromContainer:(UIViewController *)childViewController {
    if (!childViewController || ![childViewController isKindOfClass:[UIViewController class]]) {
        return;
    }
    [childViewController willMoveToParentViewController:nil];
    [childViewController.view removeFromSuperview];
    [childViewController removeFromParentViewController];
    
}

@end

@implementation UIViewController (BTVerticalPageViewController)

- (void)bt_setVerticalPageViewController:(BTVerticalPageViewController *)pageViewController {
    objc_setAssociatedObject(self, BTVerticalPageViewControllerKey, pageViewController, OBJC_ASSOCIATION_ASSIGN);
}

- (BTVerticalPageViewController *)bt_verticalPageViewController {
    BTVerticalPageViewController *pageViewController = objc_getAssociatedObject(self, BTVerticalPageViewControllerKey);
    
    //此时如果未能取到pageViewController，则一直向上寻找parentViewController的pageViewController，直到找到为止
    if (!pageViewController && self.parentViewController) {
        pageViewController = self.parentViewController.bt_verticalPageViewController;
    }
    
    return pageViewController;
}

@end
