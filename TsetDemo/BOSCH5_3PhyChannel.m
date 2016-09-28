//
//  BOSCH5_3PhyChannel.m
//  dd
//
//  Created by chenkai on 16/8/22.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "BOSCH5_3PhyChannel.h"

@implementation BOSCH5_3PhyChannel

- (instancetype)initWithId:(int)Id andDelegate:(id<Linker>)delegate{
    
    self = [super initWithPinH:7 andPinL:0 andBaud:9600 andId:Id andDelegate:delegate];
    if (self) {
        _Target = 0x20;
    }
    return self;
    
}

- (ElinkResult)open:(EProtocolId)protocolId{
    if (self.isOpened) {
        return NoError;
    }
    ElinkResult result = [self.delegate openBOSCH5_3Channel:self.Target];
    if (result == NoError) {
        self.isOpened = YES;
    }
    return result;
}

- (ElinkResult)close{
    if (!self.isOpened) {
        return NoError;
    }
    ElinkResult result = [self.delegate closeBOSCH5_3Channel];
    if (result == NoError) {
        self.isOpened = NO;
    }
    return result;
}

@end






































