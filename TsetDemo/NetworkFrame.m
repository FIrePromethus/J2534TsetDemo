//
//  NetworkFrame.m
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "NetworkFrame.h"

@implementation NetworkFrame

- (instancetype)init
{
    self = [super init];
    if (self) {
        _TPFRAMEFLAG = 1 << 5;
        _EMEFLAG = 1 << 4;
        _DIRFLAG = 1 << 2;
        _REMFRAMEFLAG = 1 << 1;
        _EXTFRAMEFLAG = 1;
    }
    return self;
}


@end
