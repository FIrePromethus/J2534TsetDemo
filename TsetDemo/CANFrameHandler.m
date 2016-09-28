//
//  CANFrameHandler.m
//  TsetDemo
//
//  Created by chenkai on 16/9/1.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "CANFrameHandler.h"
#import "RxMessage.h"
#import "NetworkFrame.h"
#import "BytesConverter.h"
@implementation CANFrameHandler

- (instancetype)initWithDelegate:(id<IDataPipe>)delegate
{
    self = [super init];
    if (self) {
        self.TAG = @"DebugFrame";
        self.delegate = delegate;
    }
    return self;
}

- (BOOL)canHandle:(RxMessage *)rxMsg{
    if (rxMsg.Type == DT_CAN_FRAME) {
        return true;
    }
    return false;
}

- (void)handle:(RxMessage *)rxMsg{
    NetworkFrame *frm = [[NetworkFrame alloc] init];
    BytesConverter *bc = [[BytesConverter alloc] init];
    frm.ChannelId = ([rxMsg get:0] & 0xFF) >> 4;
    frm.DataLen = ([rxMsg get:0] & 0xFF) & 0x0F;
    frm.Option = [rxMsg get:1];
    Byte byte1[] = {[rxMsg get:5],[rxMsg get:4],[rxMsg get:3],[rxMsg get:2]};
    Byte *b1 = byte1;
    frm.FrameId = [bc bytesToInt:b1];
    Byte byte2[] = {[rxMsg get:2],[rxMsg get:3],[rxMsg get:4],[rxMsg get:5]};
    
    frm.FrameIdButes = [NSMutableData dataWithBytes:byte2 length:sizeof(byte2)];
    Byte byte3[] = {[rxMsg get:7],[rxMsg get:6],0x00,0x00};
    frm.TimeStampCycle = [bc bytesToInt:byte3];
    Byte byte4[frm.DataLen];
    
    int starIdx = 10;
    int idx = 0;
    for (int i = starIdx; i < starIdx + frm.DataLen; ++i) {
        byte4[idx++] = [rxMsg get:i];
    }
    frm.Data = [NSMutableData dataWithBytes:byte4 length:frm.DataLen];
    if (self.delegate != nil) {
        [_delegate transferData:frm];
    }
    if (self.process != nil) {
        self.process(frm);
    }
}



@end












































