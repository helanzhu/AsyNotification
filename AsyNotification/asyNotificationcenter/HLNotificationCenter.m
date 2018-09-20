//
//  HLNotificationCenter.m
//  AsyNotification
//
//  Created by chenqg on 2018/9/20.
//  Copyright © 2018年 helanzhu. All rights reserved.
//

#import "HLNotificationCenter.h"
#import "HLWeakRef.h"
#import "HLDirector.h"

@interface HLNotificationCenter (){
    NSMutableArray *_observers;
    NSMutableArray *_nextQueue;
    NSMutableArray *_notifyQueue;
}
@end

@implementation HLNotificationCenter

- (instancetype)init{
    self = [super init];
    if(self){
        _observers = [NSMutableArray arrayWithCapacity:64];
        _nextQueue = [NSMutableArray arrayWithCapacity:10];
        _notifyQueue = [NSMutableArray arrayWithCapacity:10];
        
    }
    return self;
}

+ (instancetype)defaultCenter
{
    @synchronized(self) {
        static HLNotificationCenter *defaultCenterInstance = nil;
        static dispatch_once_t oneToken;
        dispatch_once(&oneToken, ^{
            defaultCenterInstance = [[self alloc] init];
            //注册到director
            [[HLDirector defaultDirector] addObserver:defaultCenterInstance];
        });
        return defaultCenterInstance;
    }
}


#pragma mark publick method

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)name object:(id)anObject
{
    if(observer == nil || aSelector == nil) {
        NSLog(@"ERROR: %s observer and selector must not be nil", __FUNCTION__);
        return;
    }
    
    if(![observer respondsToSelector:aSelector]){
        NSLog(@"WARNING: %s The method selector is not found!", __FUNCTION__);
    }
    
    if(name == nil && anObject == nil){
        NSLog(@"WARNING: %s you added a observer which will receive all notifications!!!", __FUNCTION__);
    }
    
    NSMutableDictionary *obsInfos = [NSMutableDictionary dictionaryWithCapacity:4];
    [obsInfos setValue:__HLWR(observer) forKey:@"observer"];
    [obsInfos setValue:NSStringFromSelector(aSelector) forKey:@"selector"];
    [obsInfos setValue:name forKey:@"name"];
    [obsInfos setValue:__HLWR(anObject) forKey:@"object"];
    
    @synchronized(_observers) {
        //查重
        for (NSMutableDictionary *obsInfo in _observers){
            __weak id obReged = __HLWRO([obsInfo valueForKey:@"observer"]);
            NSString *nameReged = [obsInfo valueForKey:@"name"];
            __weak id senderReged = __HLWRO([obsInfo valueForKey:@"object"]);
            if(![observer isEqual:obReged]){
                continue;
            }
            if(name == nil || [name isEqualToString:nameReged]){
                //名字无关或相同
                if(anObject == nil || [anObject isEqual:senderReged]){
                    //发送者无关或相同
                    return;
                }
            }
        }
        
        [_observers addObject:obsInfos];
    }
}

- (void)postNotification:(NSNotification *)notification{
    @synchronized(_nextQueue){
        [_nextQueue addObject:notification];
    }
}

- (void)postNotificationName:(NSString *)name object:(id)anObject{
    [self postNotificationName:name object:anObject userInfo:nil];
}

- (void)postNotificationName:(NSString *)name object:(id)anObject userInfo:(NSDictionary *)anUserInfo{
    if(name == nil){
        return;
    }
    
    NSNotification *notification = [NSNotification notificationWithName:name object:anObject userInfo:anUserInfo];
    [self postNotification:notification];
}

- (void)removeObserver:(id)observer{
    if(observer == nil){
        //观察者不能为空
        return;
    }
    @synchronized(_observers) {
        for (NSMutableDictionary *obsInfo in _observers){
            __weak id obReged = __HLWRO([obsInfo valueForKey:@"observer"]);
            if([observer isEqual:obReged]){
                [_observers removeObject:obsInfo];
            }
        }
    }
}

- (void)removeObserver:(id)observer name:(NSString *)name object:(id)anObject{
    if(observer == nil){
        //观察者不能为空
        return;
    }
    @synchronized(_observers) {
        for (NSMutableDictionary *obsInfo in _observers){
            __weak id obReged = __HLWRO([obsInfo valueForKey:@"observer"]);
            NSString *nameReged = [obsInfo valueForKey:@"name"];
            __weak id senderReged = __HLWRO([obsInfo valueForKey:@"object"]);
            if(![observer isEqual:obReged]){
                continue;
            }
            if(name == nil || [name isEqualToString:nameReged]){
                //名字无关 或相同
                if(anObject == nil || [anObject isEqual:senderReged]){
                    //发送者无关或相同
                    [_observers removeObject:obsInfo];
                }
            }
        }
    }
}


#pragma mark private method

//清除已经释放的观察者
- (void)cleanNilObserver{
    @synchronized(_observers) {
        for (long index = _observers.count - 1; index >= 0; index--){
            NSMutableDictionary *obsInfo = [_observers objectAtIndex:index];
            __weak id obReged = __HLWRO([obsInfo valueForKey:@"observer"]);
            if(obReged == nil){
                [_observers removeObjectAtIndex:index];
            }
        }
    }
}

#pragma mark - HLUpdateDelegate

//director定时器回调
- (void)update:(NSTimeInterval)time
{
    [self cleanNilObserver];
    
    for (NSNotification *notification in _notifyQueue) {
        NSString *name = notification.name;
        id sender = notification.object;
        
        @synchronized(_observers) {
            for (NSMutableDictionary *obsInfo in _observers){
                __weak id obReged = __HLWRO([obsInfo valueForKey:@"observer"]);
                SEL selectorReged = NSSelectorFromString([obsInfo valueForKey:@"selector"]);
                NSString *nameReged = [obsInfo valueForKey:@"name"];
                __weak id senderReged = __HLWRO([obsInfo valueForKey:@"object"]);
                //名字无关或相同
                if(nameReged == nil || [nameReged isEqualToString:name]){
                    //发送者无关或相同
                    if(senderReged == nil || [senderReged isEqual:sender]){
                        if([obReged respondsToSelector:selectorReged]){
                            [obReged performSelector:selectorReged withObject:notification afterDelay:0];
                        }
                    }
                }
            }
        }
    }
    
    [_notifyQueue removeAllObjects];
    
    //处理下一批
    @synchronized(_nextQueue){
        for(NSNotification *notification in _nextQueue){
            [_notifyQueue addObject:notification];
        }
        [_nextQueue removeAllObjects];
    }
}
@end

