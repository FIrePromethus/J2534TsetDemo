//
//  KPhyChannel.m
//  dd
//
//  Created by chenkai on 16/8/22.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "KPhyChannel.h"

@implementation KPhyChannel

- (ElinkResult)open:(EProtocolId)protocolId{
    if (self.isOpened) {
        return NoError;
    }
    ElinkResult result = [self.delegate openKChennel:(int)self.Baudrate];
    if (result == NoError) {
        self.isOpened = YES;
    }
    return result;
}

- (ElinkResult)close{
    if (self.isOpened) {
        return NoError;
    }
    ElinkResult result = [self.delegate closeKChannel];
    if (result == NoError) {
        self.isOpened = NO;
    }
    return result;
}

@end














































