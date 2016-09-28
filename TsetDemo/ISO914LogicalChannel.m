//
//  ISO914LogicalChannel.m
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "ISO914LogicalChannel.h"

@implementation ISO914LogicalChannel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pinH = 7;
        self.pinL = 0;
    }
    return self;
}

- (EpassThruResult)toLinkTxMessage:(PassThruMsg *)pmsg :(NSMutableArray<TxMwssage *> *)outMsgList{
    return 1000;
}

- (EpassThruResult)fastInit:(PassThruMsg *)inMsg :(PassThruMsg *)outMsg{
    return ERR_NOTIMPLEMENTED;
}

- (EpassThruResult)fiveBaudInit{
    return ERR_NOTIMPLEMENTED;
}

@end



























