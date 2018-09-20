//
//  HLDirector.m
//  AsyNotification
//
//  Created by chenqg on 2018/9/20.
//  Copyright © 2018年 helanzhu. All rights reserved.
//

#import "HLDirector.h"
#import "HLWeakRef.h"

#define kHLDefaultFPS 60

@interface HLDirector ()
{
    NSMutableArray *_observers;
    NSTimer *_timer;
    NSTimeInterval _deltaTime;
    NSDate *_lastUpdateTime;
}

@end

@implementation HLDirector

- (instancetype)init{
    self = [super init];
    if(self){
        _observers = [NSMutableArray arrayWithCapacity:10];
        _deltaTime = 0;
        _lastUpdateTime = [NSDate date];
        _fps = kHLDefaultFPS;
    }
    return self;
}

+ (instancetype)defaultDirector
{
    @synchronized(self) {
        static HLDirector *defaultInstance = nil;
        static dispatch_once_t oneToken;
        dispatch_once(&oneToken, ^{
            defaultInstance = [[self alloc] init];
        });
        return defaultInstance;
    }
}


- (void)start:(NSTimeInterval)fps
{
    if(![[NSThread currentThread] isMainThread]){
        NSLog(@"Director必须在主线程start");
        return;
    }
    if(fps <=0){
        fps = kHLDefaultFPS;
    }
    _fps = fps;
    
    if(_timer != nil){
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:1/self.fps target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)stop{
    if(_timer != nil){
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)addObserver:(id<HLUpdateDelegate>)observer
{
    if(observer == nil) return;
    @synchronized(_observers) {
        for (HLWeakRef *object in _observers){
            __weak id<HLUpdateDelegate> obReged = __HLWRO(object);
            if([observer isEqual:obReged]){
                return;
            }
        }
        [_observers addObject:__HLWR(observer)];
    }
}

- (void)removeObserver:(id<HLUpdateDelegate>)observer
{
    if(observer == nil) return;
    @synchronized(_observers) {
        for (HLWeakRef *object in _observers){
            __weak id<HLUpdateDelegate> obReged = __HLWRO(object);
            if([observer isEqual:obReged]){
                [_observers removeObject:object];
                return;
            }
        }
    }
}

//计算变化时间
- (void)calculateDeltaTime
{
    NSDate *nowTime = [NSDate date];
    _deltaTime= [nowTime timeIntervalSinceDate:_lastUpdateTime];
    _deltaTime = MAX(0, _deltaTime);
    _lastUpdateTime = nowTime;
    
}


//清除已经释放的观察者
- (void)cleanNilObserver
{
    @synchronized(_observers) {
        for (long index = _observers.count-1; index >= 0; index--){
            HLWeakRef *object = [_observers objectAtIndex:index];
            __weak id<HLUpdateDelegate> obReged = __HLWRO(object);
            if(obReged == nil){
                [_observers removeObjectAtIndex:index];
            }
        }
    }
}


//定时器回调
- (void)updateTimer:(NSTimer *)timer
{
    [self calculateDeltaTime];
    [self cleanNilObserver];
    
    @synchronized(_observers) {
        for (HLWeakRef *object in _observers){
            __weak id<HLUpdateDelegate> obReged = __HLWRO(object);
            if([obReged respondsToSelector:@selector(update:)]){
                [obReged update:_deltaTime];
            }
        }
    }
}



@end
