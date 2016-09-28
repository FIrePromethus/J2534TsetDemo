//
//  RxMessage.m
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "RxMessage.h"
#import "LinkProtocol.h"
@implementation RxMessage

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.MsgFrame = nil;
        self.Type = X_DT;
        self.ResponseIdx = 4;
        self.StartDataIdx = 5;
        self.FrameStart = 0x00;
        self.FrameEnd = 0x00;
    }
    return self;
}

- (int)getDataSize{
    return (self.Totallen & 0xFF) - 6 - self.StartDataIdx;
}

- (BOOL)isValid{
    LinkProtocol *linkProtocol = [[LinkProtocol alloc] init];
    if (self.FrameStart != linkProtocol.FrameStart || self.FrameEnd != linkProtocol.FrameEnd) {
        return NO;
    }
    return YES;
}


@end
