//
//  BTSpotEditPreviewViewController.m
//  BTVerticalPageViewController
//
//  Created by zhangzhilong on 15/5/16.
//  Copyright (c) 2015年 zhangzhilong. All rights reserved.
//

#import "BTSpotEditPreviewViewController.h"
#import "BTChildViewController.h"

@interface BTSpotEditPreviewViewController ()<BTVerticalPageViewControllerDataSource, BTVerticalPageViewControllerDelegate>

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation BTSpotEditPreviewViewController

- (void)viewDidLoad {
    // Do any additional setup after loading the view.
    _dataArray = @[@(0),@(1),@(2),@(3),@(4),@(5),@(6),@(7),@(8),@(9),@(10),@(11),@(12),@(13),@(14),@(15)];
    self.dataSource = self;
    self.delegate = self;
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BTChildViewController *)viewControllerAtIndex:(NSInteger)index
{
    BTChildViewController *child = [BTChildViewController create];
    child.index = index;
    return child;
}

- (NSInteger)indexOfViewController:(BTChildViewController *)viewController
{
    return viewController.index;
}

#pragma mark - 
- (UIViewController *)bt_verticalPageViewControllerInitialCurrentViewController {
    return [self viewControllerAtIndex:0];
}


- (UIViewController *)bt_verticalPageViewController:(BTVerticalPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexOfViewController:(BTChildViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
}


- (UIViewController *)bt_verticalPageViewController:(BTVerticalPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexOfViewController:(BTChildViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    
    if (index == self.dataArray.count) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

@end
