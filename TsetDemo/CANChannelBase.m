//
//  CANChannelBase.m
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "CANChannelBase.h"
#import "PassThruMsg.h"
#import "Message.h"
#import "PhysicalChannel.h"
#import "TxMwssage.h"
#import "LinkProtocol.h"
#import "BytesConverter.h"
#import "SystemError.h"
#import "OutObject.h"
@implementation CANChannelBase

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.periodicMsgList = [[NSMutableArray alloc] init];
        self.MaxPeriodicMsg = 8;
    }
    return self;
}

- (EpassThruResult)voidateFilter:(EFilterType)type :(PassThruMsg *)maskMsg :(PassThruMsg *)patternMsg :(PassThruMsg *)flowControlMsg;{
    int maxDataLen = 12;
    if (self.protocolId == ISO15765 || self.protocolId == ISO15765_PS) {
        if (type == Block || Pass == type) {
            return ERR_INVALID_FLLTER_ID;
        }
        EProtocolId protocol = self.protocolId;
        if (protocol == ISO15765_PS) {
            protocol = ISO15765;
        }
        if (protocol == CAN_PS) {
            protocol = CAN;
        }
        if (maskMsg.ProtocolId != protocol || patternMsg.ProtocolId != protocol || flowControlMsg.ProtocolId != protocol) {
            return ERR_MSG_PROTOCOL_ID;
        }
        if (maskMsg.DataSize > maxDataLen || patternMsg.DataSize > maxDataLen || flowControlMsg.DataSize > maxDataLen) {
            return ERR_INVALID_MSG;
        }
        if (maskMsg.DataSize != patternMsg.DataSize || maskMsg.DataSize != flowControlMsg.DataSize || patternMsg.DataSize != flowControlMsg.DataSize || maskMsg.TxFlags != patternMsg.TxFlags || maskMsg.TxFlags != flowControlMsg.TxFlags || patternMsg.TxFlags != flowControlMsg.TxFlags) {
            return ERR_INVALID_MSG;
        }
    }else {
        if (type == FlowControl) {
            return ERR_INVALID_FLLTER_ID;
        }
        if (maskMsg.ProtocolId != self.protocolId || patternMsg.ProtocolId != self.protocolId) {
            return ERR_MSG_PROTOCOL_ID;
        }
        if (maskMsg.DataSize > maxDataLen || patternMsg.DataSize > maxDataLen) {
            return ERR_INVALID_MSG;
        }
        if (maskMsg.DataSize != patternMsg.DataSize || maskMsg.TxFlags != patternMsg.TxFlags) {
            return ERR_INVALID_MSG;
        }
    }
    return STATUS_NOERROR;
}

- (EpassThruResult)open{
    EpassThruResult ret = [super open];
    if (ret == STATUS_NOERROR) {
        [self.periodicMsgList removeAllObjects];
    }
    return ret;
}

- (EpassThruResult)clearPeriodicMsg{
    EpassThruResult result = STATUS_NOERROR;
    while (self.periodicMsgList.count > 0) {
        Message *msg = self.periodicMsgList[0];
        [self.periodicMsgList removeObjectAtIndex:0];
        if (msg != nil) {
            EpassThruResult result2 = [self stopPeriodicMsgWithMessage:msg];
            if (result2 != STATUS_NOERROR) {
                result = result2;
            }
        }
    }
    return result;
}

- (EpassThruResult)startPeriodicMsg:(PassThruMsg *)pmsg :(long)timeInterval :(OutObject *)outPeriodicId{
    outPeriodicId.obj = [NSNumber numberWithInt:-1];
    int idLen = 4;
    int megDataLen = 8;
    if (timeInterval < 5 || timeInterval > 65535) {
        return ERR_INVALID_TIME_INTERVAL;
    }
    if (pmsg.DataSize > idLen + megDataLen) {
        return ERR_INVALID_MSG;
    }
    EProtocolId protocol = self.protocolId;
    if (protocol == ISO15765_PS) {
        protocol = ISO15765;
    }
    if (protocol == CAN_PS) {
        protocol = CAN;
    }
    if (pmsg.ProtocolId != protocol) {
        return ERR_MSG_PROTOCOL_ID;
    }
    int Id = [self getNextPeriodicMsgId];
    if (Id < 0 || Id > self.MaxPeriodicMsg - 1) {
        return ERR_EXCEEDED_LIMIT;
    }
    Message *msg = [[Message alloc] initWith:pmsg];
    msg.PeriodId = Id;
    msg.PeriodTime = timeInterval;
    outPeriodicId.obj = [NSNumber numberWithInt:Id + 1];
    int phyCh = self.phyChannel.Id;
    TxMwssage *frame = [[TxMwssage alloc] init];
    frame.CmdId = [[LinkProtocol alloc] init].CmdId.Enable_Cycle_Frame;
    [frame appendData:(Byte)Id];
    [frame appendData:(Byte)0x01];
    Byte *bytes = (Byte *)pmsg.Data.bytes;
    Byte opt1 = (Byte)((phyCh << 4) | pmsg.DataSize - idLen);
    [frame appendData:opt1];
    Byte opt2 = 0x00;
    if ((pmsg.TxFlags & pmsg.CAN_29BIT_ID) == pmsg.CAN_29BIT_ID) {
        opt2 = pmsg.CAN_29BIT_ID;
    }
    [frame appendData:opt2];
    
    for (int i = 0; i < idLen; ++i) {
        [frame appendData:bytes[i]];
    }

    short time = timeInterval;
    BytesConverter *bc = [[BytesConverter alloc] init];
    Byte *timpTime = [bc shortToBytes:time];
    [frame appendData:timpTime[1]];
    [frame appendData:timpTime[0]];
    
    for (int i = idLen; i < pmsg.DataSize; ++i) {
        [frame appendData:bytes[i]];
    }
    ElinkResult linkresult = [self.phyChannel sendMsg:frame];
    EpassThruResult result = ERR_FALLED;
    if (linkresult == NoError) {

        result = STATUS_NOERROR;
        [self.periodicMsgList addObject:msg];
    }else if(linkresult == ChannelNotOpen){
        result = ERR_INVALID_FLLTER_ID;
    }else{
        [[[SystemError alloc] init] setLastError:linkresult :linkresult];
    }
    return result;
}

- (EpassThruResult)stopPeriodicMsg:(int)Id{
    Message *msg = nil;
    Id--;
    for (Message *m in self.periodicMsgList) {
        if (m.PeriodId == Id) {
            msg = m;
            break;
        }
    }
    if (msg == nil) {
        return ERR_INVALLD_MSG_ID;
    }
    return [self stopPeriodicMsgWithMessage:msg];
}

- (EpassThruResult)stopPeriodicMsgWithMessage:(Message *)msg{
    LinkProtocol *lp = [[LinkProtocol alloc] init];
    TxMwssage *frame = [[TxMwssage alloc] init];
    frame.CmdId = lp.CmdId.Enable_Cycle_Frame;
    [frame appendData:msg.PeriodId];
    [frame appendData:0x00];
    for (int i = 0; i < 16; ++i) {
        [frame appendData:lp.CmdId.UNKNOWN];
    }
    ElinkResult linkresult = [self.phyChannel sendMsg:frame];
    EpassThruResult result = ERR_FALLED;
    if (linkresult == NoError) {
        result = STATUS_NOERROR;
        [self.periodicMsgList removeObject:msg];
    }else if (linkresult == ChannelNotOpen){
        result = ERR_INVALLD_CHANNEL_ID;
    }else{
        [[[SystemError alloc] init] setLastError:linkresult :linkresult];
    }
    return result;
}

- (int)getNextPeriodicMsgId{
    NSMutableArray *usedId = [[NSMutableArray alloc] init];
    for (Message *m in self.periodicMsgList) {
        [usedId addObject:[NSNumber numberWithInt:m.PeriodId]];
    }
    int idx = 0;
    int flag = 0;
    while (idx <= self.MaxPeriodicMsg) {
        if (usedId.count == 0) {
            flag = 1;
        }
        for (NSNumber *n in usedId) {
            if ([n intValue] == idx++) {
                flag = 1;
            }
        }
        if (flag == 1) {
            break;
        }
        
    }
    if (idx > self.MaxPeriodicMsg - 1) {
        idx = -1;
    }
    return idx;
}

@end






































