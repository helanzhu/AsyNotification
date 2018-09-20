//
//  HLWeakRef.h
//  AsyNotification
//
//  Created by chenqg on 2018/9/20.
//  Copyright © 2018年 helanzhu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define __HLWR(object) [HLWeakRef weakRefForObject:object]
#define __HLWRO(weakRef) (((HLWeakRef *)weakRef).object)

@interface HLWeakRef : NSObject

@property (nonatomic, weak) id object;

+ (instancetype)weakRefForObject:(id)obj;

@end

