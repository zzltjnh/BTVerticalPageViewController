//
//  BTChildViewController.m
//  BTVerticalPageViewController
//
//  Created by zhangzhilong on 15/5/16.
//  Copyright (c) 2015年 zhangzhilong. All rights reserved.
//

#import "BTChildViewController.h"
#import "BTVerticalPageViewController.h"
#import <SVPullToRefresh/SVPullToRefresh.h>

@interface BTChildViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation BTChildViewController

+ (instancetype)create {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    id vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(self)];
    return vc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    switch (_index % 3) {
        case 0:
            self.view.backgroundColor = [UIColor redColor];
            break;
        case 1:
            self.view.backgroundColor = [UIColor greenColor];
            break;
        case 2:
            self.view.backgroundColor = [UIColor blueColor];
            break;
            
        default:
            break;
    }
    __weak typeof(self)weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf.tableView.pullToRefreshView stopAnimating];
        
        [weakSelf.bt_verticalPageViewController transitionWithDirection:BTVerticalPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL success) {
            
        }];
    }];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf.tableView.infiniteScrollingView stopAnimating];
        
        [weakSelf.bt_verticalPageViewController transitionWithDirection:BTVerticalPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL success) {
            
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChildViewCell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"第%@页",@(_index)];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
