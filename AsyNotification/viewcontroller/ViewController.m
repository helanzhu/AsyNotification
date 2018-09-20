//
//  ViewController.m
//  AsyNotification
//
//  Created by chenqg on 2018/9/20.
//  Copyright © 2018年 helanzhu. All rights reserved.
//

#import "ViewController.h"
#import "HLNotificationCenter.h"
#import "InforViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor blueColor];
    btn.frame = CGRectMake(0, 0, 100, 40);
    btn.center = self.view.center;
    [btn setTitle:@"点击" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)click
{
    [[HLDirector defaultDirector] start:0];
    InforViewController *VC = [InforViewController new];
    [self presentViewController:VC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
