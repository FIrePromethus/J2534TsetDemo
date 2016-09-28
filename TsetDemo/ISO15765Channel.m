//
//  ISO15765Channel.m
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "ISO15765Channel.h"
#import "BytesConverter.h"
#import "PassThruMsg.h"
#import "Filter.h"
#import "LinkProtocol.h"
#import "TxMwssage.h"
#import "Device.h"
#import "ISO15765Filter.h"
#import "SystemError.h"
#import "PhysicalChannel.h"
#import "ISO15765Param.h"
#import "NetworkFrame.h"
#import "RunOptions.h"
#import "OutObject.h"
@implementation ISO15765Channel
int _funRequestId = 0x7DF;

typedef NS_ENUM(int, FRAME){
    FRAME_SF = 0x00,
    FRAME_FF = 0x10,
    FRAME_CF = 0x20,
    FRAME_FC = 0x30
    
};
int MaxFilter = 5;
NSString *TAG = @"DebugFrame";
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.protocolId = ISO15765;
        self.pinH = 6;
        self.pinL = 14;
        self.baudtate = 500000;
    }
    return self;
}

- (instancetype)initWithPinh:(int)pinh :(int)pinl
{
    self = [super init];
    if (self) {
        self.protocolId = ISO15765_PS;
        self.pinH = pinh;
        self.pinL = pinl;
    }
    return self;
}

- (EpassThruResult)toLinkTxMessage:(PassThruMsg *)pmsg :(NSMutableArray<TxMwssage *> *)outMsgList{
    Byte tpIdx = 0x00;
    BOOL isFinded = NO;
    Byte isFunAddress = 0x00;
    BytesConverter *bc = [[BytesConverter alloc] init];
    Byte *fundId = [bc intToBytes:_funRequestId];
    
 
    Byte *byte = (Byte *)[pmsg.Data bytes];

    if (byte[3] == fundId[0] && byte[2] == fundId[1] && byte[1] == fundId[2] && byte[0] == fundId[3]) {
        isFunAddress = 0x01;
        isFinded = true;
    }else{
        Byte ecuId[] = {byte[3],byte[2],byte[1],byte[0]};
        for (Filter *f in self.fillterColl) {
            if ([f matchWithIdBytes:ecuId]) {
                tpIdx = f.Id;
                isFinded = true;
            }
        }
    }
    
    if (!isFinded) {
        return ERR_NO_FLOW_CONTROL;
    }
    Byte frameData[pmsg.DataSize - 4];
    int frameCount = pmsg.DataSize - 4;
    for (int i = 0; i < frameCount; ++i) {
        Byte *byte = (Byte *)[pmsg.Data bytes];
        frameData[i] = byte[i + 4];
    }
    int maxFrameSize = [[LinkProtocol alloc] init].BigFrameSize;
    if (frameCount <= maxFrameSize) {
        TxMwssage *frame = [[TxMwssage alloc] init];
        LinkProtocol *lp = [[LinkProtocol alloc] init];
        frame.CmdId = lp.CmdId.Send_ISO15765_Frame;
        [frame appendData:tpIdx];
        [frame appendData:isFunAddress];
        for (int i = 0; i < frameCount; i++) {
            [frame appendData:frameData[i]];
        }
        [outMsgList addObject:frame];
    }else{
        int sendSize = maxFrameSize;
        int totalLen = frameCount + 2;
        TxMwssage *cmdHeader = [[TxMwssage alloc] init];
        CmdId cmid;
        cmdHeader.CmdId = cmid.Send_ISO15765_Frame;
        cmdHeader.Dlc = totalLen;
        [cmdHeader appendData:tpIdx];
        [cmdHeader appendData:tpIdx];
        for (int i = 0; i < sendSize; i++) {
            [cmdHeader appendData:frameData[i]];
        }
        [outMsgList addObject:cmdHeader];
        Byte dataSN = 0;
        while (frameCount - sendSize > 0) {
            if (frameCount - sendSize > maxFrameSize) {
                TxMwssage *cmdCount = [[TxMwssage alloc] init];
                
                cmdCount.HeaderOrContent = [[LinkProtocol alloc] init].CMD_CONTENT;
                cmdCount.CmdId = cmid.Send_ISO15765_Frame;
                cmdCount.Dlc = totalLen;
                cmdCount.ASK = dataSN;
                for (int i = 0; i < maxFrameSize; i++) {
                    [cmdCount appendData:frameData[i + sendSize]];
                }
                [outMsgList addObject:cmdCount];
                sendSize += maxFrameSize;
                dataSN++;
            }else{
                TxMwssage *lastCmd = [[TxMwssage alloc] init];
                lastCmd.HeaderOrContent = [[LinkProtocol alloc] init].CMD_CONTENT;
                lastCmd.CmdId = cmid.Send_ISO15765_Frame;
                lastCmd.Dlc = totalLen;
                lastCmd.ASK = dataSN;
                for (int i = 0; i < frameCount - sendSize; i++) {
                    [lastCmd appendData:frameData[sendSize + i]];
                }
                [outMsgList addObject:lastCmd];
                sendSize = frameCount;
            }
        }
    }
    return STATUS_NOERROR;
}

- (EpassThruResult)startMsgFilter:(EFilterType)type :(PassThruMsg *)maskMsg :(PassThruMsg *)patternMsg :(PassThruMsg *)flowControlMsg :(OutObject *)outFilterID{
    EpassThruResult result = [super startMsgFilter:type :maskMsg :patternMsg :flowControlMsg :outFilterID.obj];
    if (result != STATUS_NOERROR) {
        return result;
    }
    if (self.fillterColl.count >= MaxFilter) {
        return ERR_EXCEEDED_LIMIT;
    }
    for (Filter *f in self.fillterColl) {
        if ([f.patterMsg equal:patternMsg] || [f.flowControlMsg equal:flowControlMsg]) {
            return ERR_INVALID_MSG;
        }
    }
    int tpIdx = [self getValidTPIndex];
    ElinkResult linkRet = [self setTPParm:patternMsg :flowControlMsg :tpIdx];
    if (linkRet == NoError) {
        ISO15765Filter *f = [[ISO15765Filter alloc] initWith:FlowControl];
        f.Id = tpIdx;
        [f setMaskMsg:maskMsg];
        [f setPatterMsg:patternMsg];
        [f setFlowControlMsg:flowControlMsg];
        [self.fillterColl addObject:f];
        outFilterID.obj = [NSNumber numberWithInt:f.Id];
    }
    if (linkRet == NoError) {
        @try {
            [NSThread sleepForTimeInterval:0.1];
        }
        @catch (NSException *exception) {
            @throw exception;
        }
        @finally {
            
        }
        return STATUS_NOERROR;
    }else{
        [[[SystemError alloc] init] setLastError:linkRet :linkRet];
        return ERR_FALLED;
    }
}

- (ElinkResult)setTPParm:(PassThruMsg *)patternMsg :(PassThruMsg *)flowControlMsg :(int)tpIdx{
    int channelId = self.phyChannel.Id;
    ISO15765Param *tpParam = [[ISO15765Param alloc] init];
    tpParam.Txmin = 0x01;
    tpParam.Stmin = 0x0A;
    tpParam.WFTimeout = 0x02;
    tpParam.ReqId = [self getCANId:(Byte *)[flowControlMsg.Data bytes]];
    tpParam.FunId = _funRequestId;
    if ((flowControlMsg.TxFlags & flowControlMsg.CAN_29BIT_ID) == flowControlMsg.CAN_29BIT_ID) {
        tpParam.ReqId = tpParam.ReqId | 0x80000000;
        tpParam.FunId = _funRequestId | 0x80000000;
    }
    tpParam.RepId = [self getCANId:(Byte *)[patternMsg.Data bytes]];
    if ((patternMsg.TxFlags & patternMsg.CAN_29BIT_ID) == patternMsg.CAN_29BIT_ID) {
        tpParam.RepId = tpParam.RepId | 0x80000000;
    }
    tpParam.Mod = 0x03;
    tpParam.SBS = 0x06;
    tpParam.Ar = 0x03E8;
    tpParam.As = 0x03E8;
    tpParam.Br = 0x07D0;
    tpParam.Bs = 0x07D0;
    tpParam.Cr = 0x07D0;
    tpParam.Cs = 0x07D0;
    tpParam.TPChannelIndex = (Byte)tpIdx;
    
    TxMwssage *cmd = [[TxMwssage alloc] init];
    LinkProtocol *lp = [[LinkProtocol alloc] init];
    
    
    cmd.CmdId = lp.CmdId.Set_ISO15765_Param;
    [cmd appendData:tpParam.TPChannelIndex];
    [cmd appendData:tpParam.Stmin];
    [cmd appendData:tpParam.Txmin];
    [cmd appendData:tpParam.WFTimeout];
    [cmd appendData:tpParam.As >> 8];
    [cmd appendData:tpParam.As & 0xFF];
    [cmd appendData:tpParam.Ar >> 8];
    [cmd appendData:tpParam.Ar & 0xFF];
    [cmd appendData:tpParam.Bs >> 8];
    [cmd appendData:tpParam.Bs & 0xFF];
    [cmd appendData:tpParam.Br >> 8];
    [cmd appendData:tpParam.Br & 0xFF];
    [cmd appendData:tpParam.Cs >> 8];
    [cmd appendData:tpParam.Cs & 0xFF];
    [cmd appendData:tpParam.Cr >> 8];
    [cmd appendData:tpParam.Cr & 0xFF];
    [cmd appendData:tpParam.Mod];
    [cmd appendData:tpParam.SBS];
    
    [cmd appendData:(channelId << 5) | (tpParam.RepId >> 24)];
    [cmd appendData:(tpParam.RepId & 0x00ff0000) >> 16];
    [cmd appendData:(tpParam.RepId & 0x0000ff00) >> 8];
    [cmd appendData:tpParam.RepId & 0x000000ff];
    
    [cmd appendData:((channelId << 5) | tpParam.ReqId >> 24)];
    [cmd appendData:(tpParam.ReqId & 0x00ff0000) >> 16];
    [cmd appendData:(tpParam.ReqId & 0x0000ff00) >> 8];
    [cmd appendData:tpParam.ReqId & 0x000000ff];
    
    [cmd appendData:(channelId << 5) | tpParam.FunId >> 24];
    [cmd appendData:(tpParam.FunId & 0x00ff0000) >> 16];
    [cmd appendData:(tpParam.FunId & 0x0000ff00) >> 8];
    [cmd appendData:tpParam.FunId & 0x000000ff];
    ElinkResult linkRet = [self.phyChannel sendMsg:cmd];
    return linkRet;
}

- (int)getCANId:(Byte *)data{
    Byte byte[] = {data[3],data[2],data[1],data[0]};
    return [[[BytesConverter alloc] init] bytesToInt:byte];
}

- (int)getValidTPIndex{
    NSMutableArray *useId = [[NSMutableArray alloc] init];
    for (Filter *f in self.fillterColl) {
        [useId addObject:[NSNumber numberWithInt:f.Id]];
    }
    int idx = -1;
    int mark = 0;
    while (idx < MaxFilter) {
         idx++;
        for (NSNumber *num in useId) {
            if ([num intValue] == idx) {
                mark = 1;
                break;
            }
        }
        if (mark != 1) {
            break;
        }
    }
    if (idx > MaxFilter - 1) {
        idx = -1;
    }
    return idx;
}

- (EpassThruResult)stopMsgFilter:(int)Id{
    Filter *filter = nil;
    for (Filter *f in self.fillterColl) {
        if (f.Id == Id) {
            filter = f;
            break;
        }
    }
    if (filter == nil) {
        return ERR_INVALID_FLLTER_ID;
    }
    return [self stopMsgFilterWithFilter:filter];
}

- (EpassThruResult)stopMsgFilterWithFilter:(Filter *)filter{
    EpassThruResult passRet = STATUS_NOERROR;
    TxMwssage *frame = [[TxMwssage alloc] init];
    CmdId cmid;
    frame.CmdId = cmid.Del_ISO15765_Channel;
    [frame appendData:filter.Id];
    ElinkResult result = [self.phyChannel sendMsg:frame];
    if (result == NoError) {
        [self.fillterColl removeObject:filter];
    }else{
        [[[SystemError alloc]init] setLastError:result :result];
        passRet = ERR_FALLED;
    }
    return passRet;
}

- (void)receiveMsg:(NetworkFrame *)msg{
    if (self.fillterColl.count == 0) {
        return;
    }
    ISO15765Filter *isoFilter = nil;
    if (msg.FrameId == _funRequestId) {
        
    }else{
        BOOL isMatch = NO;
        for (Filter *f in self.fillterColl) {
            isoFilter = (ISO15765Filter *)f;
            if ([isoFilter matchWithNet:msg]) {
                isMatch = YES;
            }
        }
        if (!isMatch) {
            return;
        }
    }
    Byte *byte = (Byte *)[msg.Data bytes];
    int frmType = byte[0] & 0xF0;
    switch (frmType) {
        case FRAME_SF:
        {
            int len = byte[0] & 0xFF;
            Byte tempBuf[len];
            for (int i = 1; i <= len; ++i) {
                tempBuf[i - 1] = byte[i];
            }
            msg.DataLen = len;
            msg.Data = [NSMutableData dataWithBytes:tempBuf length:len];
            [super receiveMsg:msg];
        }
            break;
        case FRAME_FF:
        {
            [isoFilter.DiagFrameBuf removeAllObjects];
            int canIdLen = 4;
            isoFilter.DiagFrameBuilder = [self toRxPassThruMsg:msg];
            isoFilter.DiagFrameBuilder.DataSize = ((byte[0] & 0x0F) << 8) | (byte[1] & 0xFF) + canIdLen;
            Byte *b = (Byte *)[msg.FrameIdButes bytes];;
            for (int i = 0; i < msg.FrameIdButes.length; i++) {
                [isoFilter.DiagFrameBuf addObject:[NSData dataWithBytes:&b[i] length:sizeof(b[i])]];
            }
            int dataLen = 6;
            for (int i = 0; i < dataLen; i++) {
                [isoFilter.DiagFrameBuf addObject:[NSData dataWithBytes:&byte[i + 2] length:sizeof(byte[i + 2])]];
            }
            isoFilter.DiagFrameBuilder.ExtraDataIndex = isoFilter.DiagFrameBuf.count;
        }
            break;
        case FRAME_CF:
        {
            PassThruMsg *tempMsg2 = [self toRxPassThruMsg:msg];
            isoFilter.DiagFrameBuilder.Timestamp = tempMsg2.Timestamp;
            int idx = 0;
            for (int i = 0; i < msg.Data.length; i++) {
                if (idx++ > 0) {
                    [isoFilter.DiagFrameBuf addObject:[NSData dataWithBytes:&byte[i] length:sizeof(byte[i])]];
                }
            }
            RunOptions *rp = [[RunOptions alloc] init];
            if (rp.IsDebugTrance) {
                NSLog(@"%@44444 CF Msg:%@", TAG,[[[BytesConverter alloc] init] bytesToHexStrWithByte:byte :0 :(int)msg.Data.length]);
            }
            isoFilter.DiagFrameBuilder.ExtraDataIndex = isoFilter.DiagFrameBuf.count;
            if (isoFilter.DiagFrameBuf.count >= isoFilter.DiagFrameBuilder.DataSize) {
                idx = 0;
                for (NSData *d in isoFilter.DiagFrameBuf) {
                    [isoFilter.DiagFrameBuilder.Data appendData:d];
                    idx++;
                    if (idx >= isoFilter.DiagFrameBuilder.DataSize) {
                        break;
                    }
                }
                [self addToBuffer:isoFilter.DiagFrameBuilder];
            }
        }
            break;
        case FRAME_FC:
        
            break;
        default:
            NSLog(@"%@+++++Skiped unkown frame: %@",TAG ,[[[BytesConverter alloc] init] bytesToHexStr:msg.Data]);
            break;
            
    }
}

@end








































