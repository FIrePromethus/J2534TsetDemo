//
//  SystemError.m
//  dd
//
//  Created by chenkai on 16/8/19.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "SystemError.h"
#import "ErrorItem.h"
@implementation SystemError


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ErrInvalidPhyChannel = [[ErrorItem alloc] initWithDesc:nil];
        
        self.errCode = 0;
    }
    return self;
}

- (void)setLastError:(int)LastError :(int)code{
    _LastError = LastError;
    _errCode = code;
}

- (void)setLastError1:(ErrorItem *)err{
    [self setLastError:err.Desc :err.Code];
}

@end
