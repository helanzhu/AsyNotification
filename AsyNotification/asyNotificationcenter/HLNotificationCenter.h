//
//  HLNotificationCenter.h
//  AsyNotification
//
//  Created by chenqg on 2018/9/20.
//  Copyright © 2018年 helanzhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLDirector.h"

//使用异步调度机制的通知中心，所有接口仿NotificationCenter 且postNotification会在下一个时钟周期回调

@interface HLNotificationCenter : NSObject<HLUpdateDelegate>

+ (instancetype)defaultCenter;

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)name object:(id)anObject;

- (void)postNotification:(NSNotification *)notification;
- (void)postNotificationName:(NSString *)name object:(id)anObject;
- (void)postNotificationName:(NSString *)name object:(id)anObject userInfo:(NSDictionary *)anUserInfo;

- (void)removeObserver:(id)observer;
- (void)removeObserver:(id)observer name:(NSString *)name object:(id)anObject;

@end
