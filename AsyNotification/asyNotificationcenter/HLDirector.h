//
//  HLDirector.h
//  AsyNotification
//
//  Created by chenqg on 2018/9/20.
//  Copyright © 2018年 helanzhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HLUpdateDelegate <NSObject>

- (void)update:(NSTimeInterval)time;

@end

/**
 *  定时触发器，用于异步操作，观察者实现 HLUpdateDelegate
 *  因为使用了weakRef机制，director会自动清除已经释放的观察者对象
 *  所有的update都会在主线程回调
 */
@interface HLDirector : NSObject

+ (instancetype)defaultDirector;

- (void)start:(NSTimeInterval)fps;
- (void)stop;

/**
 *  添加观察者
 *  @param observer 必须是实现了HLUpdateDelegate代理方法的实例
 */
- (void)addObserver:(id<HLUpdateDelegate>)observer;

//因为使用了weakRef机制，不需要一定执行remove，director会自动清除已经释放的观察者对象
/**
 *  移除观察者
 *  @param observer 观察者
 */
- (void)removeObserver:(id<HLUpdateDelegate>)observer;

@property (readonly, assign)  NSTimeInterval fps;

@end

