//
//  KFrameHandler.m
//  TsetDemo
//
//  Created by chenkai on 16/9/1.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "KFrameHandler.h"
#import "RxMessage.h"
#import "NetworkFrame.h"
#import "BytesConverter.h"
@implementation KFrameHandler

- (instancetype)initWith:(id<IDataPipe>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (BOOL)canHandle:(RxMessage *)rxMsg{
    if (rxMsg.Type == DT_K_FRAME) {
        return true;
    }
    return false;
}

- (void)handle:(RxMessage *)rxMsg{
    NetworkFrame *frm = [[NetworkFrame alloc] init];
    frm.ChannelId = ([rxMsg get:0] & 0xFF) >> 4;
    frm.DataLen = rxMsg.Totallen - 12;
    frm.Option = [rxMsg get:1];
    Byte timeStamp[] = {[rxMsg get:5],[rxMsg get:4],[rxMsg get:3],[rxMsg get:2]};
    BytesConverter *bc = [[BytesConverter alloc] init];
    frm.TimeStamp = [bc bytesToInt:timeStamp];
    
    Byte byte[frm.DataLen];
    int startIdx = 6;
    int idx = 0;
    for(int i = startIdx; i < startIdx + frm.DataLen; ++i){
        byte[idx++] = [rxMsg get:i];
    }
    frm.Data = [NSMutableData dataWithBytes:byte length:frm.DataLen];
    if (self.delegate != nil) {
        [_delegate transferData:frm];
    }
    if (self.process != nil) {
        self.process(frm);
    }
}

@end

























