//
//  TimeViewController.m
//  AsyNotification
//
//  Created by chenqg on 2018/9/20.
//  Copyright © 2018年 helanzhu. All rights reserved.
//

#import "InforViewController.h"
#import "HLNotificationCenter.h"

NSString *const kNotificationName = @"kNotificationName";

@interface InforViewController ()

@property (nonatomic, strong) UILabel *inforLabel;


@end

@implementation InforViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor orangeColor];
    
    [[HLNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInfo:) name:kNotificationName object:nil];
    
    [[HLNotificationCenter defaultCenter] postNotificationName:kNotificationName object:nil userInfo:@{@"cityName":@"NewYork"}];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor blueColor];
    btn.frame = CGRectMake(0, 0, 100, 40);
    btn.center = self.view.center;
    [btn setTitle:@"返回" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    self.inforLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 200, [UIScreen mainScreen].bounds.size.width, 40)];
    self.inforLabel.backgroundColor = [UIColor whiteColor];
    self.inforLabel.textAlignment = NSTextAlignmentCenter;
    self.inforLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:self.inforLabel];
    
}

- (void)goBack
{
    [[HLDirector defaultDirector] stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)updateInfo:(NSNotification*)noti
{
    NSLog(@"cityName = %@\n",noti.userInfo[@"cityName"]);
    if ([[NSThread currentThread] isMainThread]) {
        self.inforLabel.text = [NSString stringWithFormat:@"子线程发通知 主线程接收: %@",noti.userInfo[@"cityName"]];
    }
}

@end
