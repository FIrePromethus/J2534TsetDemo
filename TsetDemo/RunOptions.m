//
//  RunOptions.m
//  dd
//
//  Created by chenkai on 16/8/16.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "RunOptions.h"
static int OEM = 1;
@implementation RunOptions

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.IsDebugTrance = NO;
        self.IsDebugWriteSocket = NO;
        self.IsDebugReadSocket = NO;
        self.CANChannelCount = 2;
        self.JarVersion = @"1.0.160127";
        self.ApiVersion = @"2.0.0";
    }
    return self;
}

+ (void)setOEM:(int)a{
    OEM = a;
}

+ (int)getOEM{
    return OEM;
}

@end
