//
//  ViewController.m
//  Example
//
//  Created by zhangzhilong on 2016/11/18.
//  Copyright © 2016年 zhangzhilong. All rights reserved.
//

#import "ViewController.h"
#import "BTSpotEditPreviewViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBtn:(id)sender {
    BTSpotEditPreviewViewController *controller = [[BTSpotEditPreviewViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
