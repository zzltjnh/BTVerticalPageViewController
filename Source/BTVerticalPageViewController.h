//
//  BTVerticalPageViewController.h
//  BTVerticalPageViewController
//
//  Created by zhangzhilong on 15/5/15.
//  Copyright (c) 2015年 zhangzhilong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BTVerticalPageViewControllerNavigationDirection) {
    BTVerticalPageViewControllerNavigationDirectionForward, //往下翻页
    BTVerticalPageViewControllerNavigationDirectionReverse  //往上翻页
};

@protocol BTVerticalPageViewControllerDataSource, BTVerticalPageViewControllerDelegate;

@interface BTVerticalPageViewController : UIViewController

/** dataSource */
@property (nonatomic, weak) id <BTVerticalPageViewControllerDataSource> dataSource;
/** delegate */
@property (nonatomic, weak) id <BTVerticalPageViewControllerDelegate> delegate;

/** if YES 则只会加载将要显示的页面，不会加载前一页和后一页.  Default YES */
@property (nonatomic, assign) BOOL lazyLoad;

/** currentViewController（当前正在显示的viewController） */
@property (nonatomic, strong, readonly) UIViewController *currentViewController;

/** direction:记录当前是往上翻还是往下翻 */
@property (nonatomic, assign, readonly) BTVerticalPageViewControllerNavigationDirection direction;

/** 当前是否正在进行动画 */
@property (nonatomic, assign, readonly, getter=isTransitioning) BOOL transitioning;

//调用该方法来显示上一页或下一页
- (void)transitionWithDirection:(BTVerticalPageViewControllerNavigationDirection)direction
                       animated:(BOOL)animated
                     completion:(void (^)(BOOL success))completion;

@end

@protocol BTVerticalPageViewControllerDelegate <NSObject>

@optional

//告知使用者将要展示destinationViewController
- (void)bt_verticalPageViewController:(BTVerticalPageViewController *)pageViewController willTransitionToViewController:(UIViewController *)destinationViewController;

//告知使用者正在从previousViewController过度,该方法被调用的前提是切换动作是animated的
- (void)bt_verticalPageViewController:(BTVerticalPageViewController *)pageViewController
      transitioningToViewController:(UIViewController *)destinationViewController;

//告知使用者已经从previousViewController过度完成
- (void)bt_verticalPageViewController:(BTVerticalPageViewController *)pageViewController
      didTransitionFromViewController:(UIViewController *)previousViewController;

@end

@protocol BTVerticalPageViewControllerDataSource <NSObject>

@required

//该代理方法需要使用者提供初始化显示的viewController
//该方法只会在初始化时被调用一次
- (UIViewController *)bt_verticalPageViewControllerInitialCurrentViewController;

//该代理方法需要使用者根据pageViewController.currentViewController的信息提供一个beforeViewController（即上一页）
//if self.lazyLoad == NO时该方法会在初始化和每次翻页完成的时候被调用
//if self.lazyLoad == YES时该方法会在每次触发向上翻页的动作时被调用
- (UIViewController *)bt_verticalPageViewController:(BTVerticalPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController;

//该代理方法需要使用者根据pageViewController.currentViewController的信息提供一个afterViewController（即下一页）
//if self.lazyLoad == NO时该方法会在初始化和每次翻页完成的时候被调用
//if self.lazyLoad == YES时该方法会在每次触发向下翻页的动作时被调用
- (UIViewController *)bt_verticalPageViewController:(BTVerticalPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController;

@end

@interface UIViewController (BTVerticalPageViewController)

@property(nonatomic,readonly,strong)  BTVerticalPageViewController *bt_verticalPageViewController;

@end
