//
//  ErrorItem.m
//  dd
//
//  Created by chenkai on 16/8/19.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "ErrorItem.h"

static int codeCount = 100;

@implementation ErrorItem

- (ErrorItem *)initWithDesc:(int)desc andCode:(int)code
{
    self = [super init];
    if (self) {
        _Desc = desc;
        _Code = code;
    }
    return self;
}

- (ErrorItem *)initWithDesc:(int)desc
{
    self = [super init];
    if (self) {
        _Desc = desc;
        ++codeCount;
    }
    return self;
}

@end
