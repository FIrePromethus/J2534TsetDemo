//
//  BOSCH5_3FrameHamdler.m
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "BOSCH5_3FrameHamdler.h"
#import "RxMessage.h"
#import "NetworkFrame.h"
#import "BytesConverter.h"
#import "Device.h"
@implementation BOSCH5_3FrameHamdler

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
    if (rxMsg.Type == DT_BOSH5_3_FRAME) {
        return true;
    }
    return false;
}

- (void)handle:(RxMessage *)rxMsg{
    NetworkFrame *fram= [[NetworkFrame alloc] init];
    fram.DataLen = [rxMsg get:0] & 0xFF;
    fram.ChannelId = ([rxMsg get:1] & 0xFF) >> 4;
    fram.Option = [rxMsg get:1];
    Byte timeStamp[] = {[rxMsg get:3],[rxMsg get:2],0x00,0x00};
    BytesConverter *conver = [[BytesConverter alloc] init];
    fram.TimeStamp = [conver bytesToInt:timeStamp];
    Byte cycle[] = {[rxMsg get:5],[rxMsg get:4],0x00,0x00};
    fram.TimeStampCycle = [conver bytesToInt:cycle];
    Byte byte[fram.DataLen];
    
    int idx = 0;
    for (int i = 6; i < 6 + fram.DataLen; ++i) {
        byte[idx++] = [rxMsg get:i];
    }
    fram.Data = [NSMutableData dataWithBytes:byte length:fram.DataLen];
    Device *device = [[Device alloc] init];
    [device transferData:fram];
    self.process(fram);
}



@end






















