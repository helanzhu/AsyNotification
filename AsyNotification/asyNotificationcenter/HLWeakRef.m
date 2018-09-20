//
//  HLWeakRef.m
//  AsyNotification
//
//  Created by chenqg on 2018/9/20.
//  Copyright © 2018年 helanzhu. All rights reserved.
//

#import "HLWeakRef.h"

@implementation HLWeakRef

+ (instancetype)weakRefForObject:(id)obj
{
    if(obj == nil) return nil;
    
    HLWeakRef *weakRef = [[HLWeakRef alloc] init];
    weakRef.object = obj;
    return weakRef;
}

@end
