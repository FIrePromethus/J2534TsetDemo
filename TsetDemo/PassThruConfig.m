//
//  PassThruConfig.m
//  dd
//
//  Created by chenkai on 16/8/19.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "PassThruConfig.h"

@implementation PassThruConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        _configMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)add:(EPassThruParams)paramName :(long)val{
    NSString *str = [NSString stringWithFormat:@"%ld",(long)paramName];
    [_configMap setObject:[NSNumber numberWithLong:val] forKey:str];
}

- (NSNumber *)getConfig:(EPassThruParams)paramName{
    NSString *str = [NSString stringWithFormat:@"%ld",(long)paramName];
    NSNumber *num = _configMap[str];
    return num;
}

@end
