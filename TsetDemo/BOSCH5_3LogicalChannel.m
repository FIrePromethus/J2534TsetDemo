//
//  BOSCH5_3LogicalChannel.m
//  TsetDemo
//
//  Created by chenkai on 16/8/29.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "BOSCH5_3LogicalChannel.h"
#import "LinkProtocol.h"
#import "PassThruMsg.h"
#import "TxMwssage.h"
#import "NetworkFrame.h"
#import "BOSCH5_3PhyChannel.h"
@implementation BOSCH5_3LogicalChannel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.protocolId = BOSCH5_3;
        self.baudtate = 9600;
    }
    return self;
}

- (EpassThruResult)toLinkTxMessage:(PassThruMsg *)pmsg :(NSMutableArray<TxMwssage *> *)outMsgList{
    CmdId Cmdid;
    Byte cmdId = Cmdid.Send_BOSCH5_3;
    Byte frmData[pmsg.DataSize];
    int frmCount = pmsg.DataSize;
    Byte *bytes = (Byte *)[pmsg.Data bytes];
    for (int i = 0; i < frmCount; ++i) {
        frmData[i] = bytes[i];
    }
    TxMwssage *frame = [[TxMwssage alloc] init];
    frame.CmdId = cmdId;
    [frame appendDataWithData:[NSData dataWithBytes:frmData length:sizeof(frmData)]];
    [outMsgList addObject:frame];
    return STATUS_NOERROR;
}

- (PassThruMsg *)toRxPassThruMsg:(NetworkFrame *)rawMsg{
    PassThruMsg *pmsg = [[PassThruMsg alloc] init];
    pmsg.Timestamp = rawMsg.TimeStamp;
    long rxStatus = 0;
    pmsg.ProtocolId = BOSCH5_3;
    if ((rawMsg.Option & rawMsg.DIRFLAG) == rawMsg.DIRFLAG) {
        pmsg.RxStatus = pmsg.TX_MSG | rxStatus;
    }
    pmsg.DataSize = rawMsg.DataLen;
    NSMutableData *tempBuf = [[NSMutableData alloc] init];
    [tempBuf appendData:rawMsg.Data];
    pmsg.Data = tempBuf;
    pmsg.ExtraDataIndex = pmsg.DataSize;
    return pmsg;
}

- (EpassThruResult)fiveBaudInit{
    return STATUS_NOERROR;
}

- (EpassThruResult)open{
    BOSCH5_3PhyChannel *ch = (BOSCH5_3PhyChannel *)self.phyChannel;
    ch.Target = self.target;
    return [super open];
}

@end




























