//
//  VoltageHandler.m
//  TsetDemo
//
//  Created by chenkai on 16/9/1.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "VoltageHandler.h"
#import "RxMessage.h"
#import "LinkProtocol.h"
@implementation VoltageHandler

- (BOOL)canHandle:(RxMessage *)rxMsg{
    LinkProtocol *lp = [[LinkProtocol alloc] init];
    if (rxMsg.Type == DT_CMDACK && [rxMsg get:0] == lp.CmdId.ReadVoltage) {
        return true;
    }
    return false;
}

- (void)handle:(RxMessage *)rxMsg{
    int startidx = [rxMsg StartDataIdx];
    if ([rxMsg get:startidx - 1] != 0x00) {
        return;
    }
    if (self.process != nil) {
        int hbyte = [rxMsg get:startidx] & 0xFF;
        int lbyte = [rxMsg get:startidx + 1] & 0xFF;
        double vol = ((hbyte << 8) | lbyte) / 1000.0;
        
#warning BigDecimal bg
    }
}


@end






































