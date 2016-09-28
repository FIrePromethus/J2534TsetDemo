//
//  CANLogalChannel.m
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "CANLogalChannel.h"
#import "PhysicalChannel.h"
#import "TxMwssage.h"
#import "LinkProtocol.h"
#import "PassThruMsg.h"
@implementation CANLogalChannel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.protocolId = CAN;
        self.pinH = 6;
        self.pinL = 14;
        self.baudtate = 500000;
    }
    return self;
}

- (instancetype)initWithPin:(int)pinH :(int)pinL
{
    self = [super init];
    if (self) {
        self.protocolId = CAN_PS;
        self.pinH = pinH;
        self.pinL = pinL;
        self.baudtate = 500000;
    }
    return self;
}

- (EpassThruResult)toLinkTxMessage:(PassThruMsg *)pmsg :(NSMutableArray<TxMwssage *> *)outMsgList{
    int idLen = 4;
    int msgDataLen = 8;
    int phyCh = [self.phyChannel Id];
    TxMwssage *frame = [[TxMwssage alloc] init];
    
    frame.CmdId = [[LinkProtocol alloc] init].CmdId.Send_CAN_Frame;
    Byte opt1 = (Byte)((phyCh << 4) | (pmsg.DataSize - idLen));
    [frame appendData:opt1];
    Byte opt2 = 0x00;
    if ((pmsg.TxFlags & pmsg.CAN_29BIT_ID) == pmsg.CAN_29BIT_ID) {
        opt2 = (Byte)pmsg.CAN_29BIT_ID;
    }
    [frame appendData:opt2];
    [frame appendDataWithData:pmsg.Data];
    
    int padount = msgDataLen - (pmsg.DataSize - idLen);
    int count = 0;
    while (count++ < padount) {
        [frame appendData:(Byte)0x00];
    }
    [outMsgList addObject:frame];
    
    NSLog(@"%@",frame.dataBuf);
    return STATUS_NOERROR;
}

- (EpassThruResult)startMsgFilter:(EFilterType)type :(PassThruMsg *)maskMsg :(PassThruMsg *)patternMsg :(PassThruMsg *)flowControlMsg :(OutObject *)outFilterID{
    return ERR_NOTIMPLEMENTED;
}

- (EpassThruResult)stopMsgFilterWithFilter:(Filter *)filter{
    return ERR_NOTIMPLEMENTED;
}

@end


















































