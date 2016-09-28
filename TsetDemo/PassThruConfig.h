//
//  PassThruConfig.h
//  dd
//
//  Created by chenkai on 16/8/19.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "J2534.h"
@interface PassThruConfig : NSObject

@property(nonatomic,strong) NSMutableDictionary *configMap;

- (void)add:(EPassThruParams)paramName :(long)val;

- (NSNumber *)getConfig:(EPassThruParams)paramName;

@end
