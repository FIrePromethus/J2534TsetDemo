//
//  ISO14230Channel.m
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "ISO14230Channel.h"
#import "LinkProtocol.h"
#import "TxMwssage.h"
#import "PassThruMsg.h"
#import "NetworkFrame.h"
#import "PassThruConfig.h"
#import "BytesConverter.h"
#import "DataLinker.h"
#import "PhysicalChannel.h"
#import "SystemError.h"
#import "OutObject.h"
@implementation ISO14230Channel

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self resetParams];
        self.protocolId = ISO14230;
        self.pinH = 7;
        self.pinL = 0;
        self.baudtate = 10400;
    }
    return self;
}

- (EpassThruResult)open{
    [self resetParams];
    return [super open];
}

- (void)resetParams{
    _P1_Max = 40;
    _P1_Min = 0;
    _p2_Max = 0;
    _P2_Min = 0;
    _P3_Max = 0;
    _P3_Min = 110;
    _P4_Max = 0;
    _P4_Min = 10;
    _Tidle = 300;
    _Tinil = 25;
    _Twup = 50;
    _W1 = 300;
    _W2 = 20;
    _W3 = 20;
    _W4 = 50;
    _W5 = 300;
    _Parity = 0;
}


- (EpassThruResult)toLinkTxMessage:(PassThruMsg *)pmsg :(NSMutableArray<TxMwssage *> *)outMsgList{
    CmdId Cmid;
    Byte cmid = Cmid.Send_K_Frame;
    if (_isDoFastInit) {
        cmid = Cmid.FastInit_K;
    }
    Byte *byte = (Byte *)[pmsg.Data bytes];
    Byte frmData[pmsg.DataSize];
    int frmCount = pmsg.DataSize;
    for (int i = 0; i < frmCount; ++i) {
        frmData[i] = byte[i];
    }
    
    int maxFrameSize = [[LinkProtocol alloc] init].BigFrameSize;
    TxMwssage *frame = [[TxMwssage alloc] init];
    if (frmCount <= maxFrameSize) {
        frame.CmdId = cmid;
        [frame appendDataWithData:[NSData dataWithBytes:frmData length:sizeof(frmData)]];
        [outMsgList addObject:frame];
    }else {
        int sendSize = maxFrameSize;
        TxMwssage *cmdHeader = [[TxMwssage alloc] init];
        cmdHeader.CmdId = cmid;
        cmdHeader.Dlc = frmCount;
        for (int i = 0; i < sendSize; i++) {
            [cmdHeader appendData:frmData[i]];
        }
        [outMsgList addObject:cmdHeader];
        
        Byte dataSN = 0;
        while (frmCount - sendSize > 0) {
            if (frmCount - sendSize > maxFrameSize) {
                TxMwssage *cmdContent = [[TxMwssage alloc] init];
                cmdContent.HeaderOrContent = [[LinkProtocol alloc] init].CMD_CONTENT;
                cmdContent.CmdId = cmid;
                cmdContent.Dlc = frmCount;
                [cmdContent appendData:dataSN];
                for (int i = 0; i < maxFrameSize; i++) {
                    [cmdContent appendData:frmData[sendSize + i]];
                }
                [outMsgList addObject:cmdContent];
                sendSize += maxFrameSize;
                dataSN++;
            }else{
                TxMwssage *lastCmd = [[TxMwssage alloc] init];
                lastCmd.HeaderOrContent = [[LinkProtocol alloc] init].CMD_CONTENT;
                lastCmd.CmdId = cmid;
                lastCmd.Dlc = frmCount;
                [lastCmd appendData:dataSN];
                for (int i = 0; i < frmCount - sendSize; i++) {
                    [lastCmd appendData:frmData[sendSize + i]];
                }
                [outMsgList addObject:lastCmd];
                sendSize = frmCount;
            }
        }
    }
    return STATUS_NOERROR;
}

- (PassThruMsg *)toRxPassThruMsg:(NetworkFrame *)rawMsg{
    PassThruMsg *pmsg = [[PassThruMsg alloc] init];
    pmsg.Timestamp = rawMsg.TimeStamp;
    
    long rxStatus = 0;
    pmsg.ProtocolId = ISO14230;
    if ((rawMsg.Option & rawMsg.DIRFLAG) == rawMsg.DIRFLAG) {
        pmsg.RxStatus = pmsg.TX_MSG | rxStatus;
    }
    pmsg.DataSize = (int)(rawMsg.DataLen+rawMsg.FrameIdButes.length);
    NSMutableData *tempBuf = [[NSMutableData alloc] init];
    [tempBuf appendData:rawMsg.FrameIdButes];
    [tempBuf appendData:rawMsg.Data];
    pmsg.Data = tempBuf;
    pmsg.ExtraDataIndex = pmsg.DataSize;
    return pmsg;
}

- (EpassThruResult)fastInit:(PassThruMsg *)inMsg :(PassThruMsg *)outMsg{
    _isDoFastInit = YES;
    EpassThruResult reault;
    @try {
        reault = [self writeMsg:inMsg :0];
        if (reault != STATUS_NOERROR) {
            return reault;
        }
        NSMutableArray<PassThruMsg *> *outMsgList = [[NSMutableArray alloc] init];
        OutObject *inOutNum = [[OutObject alloc] init];
        inOutNum.obj = [NSNumber numberWithInt:1];
        reault = [self readMsgs:outMsgList :inOutNum :300];
        if (reault != STATUS_NOERROR) {
            return reault;
        }
        [outMsg copyFrom:outMsgList[0]];
    }
    @catch (NSException *exception) {
       
    }
    @finally {
         _isDoFastInit = NO;
    }
    return reault;
}

- (EpassThruResult)validateParm:(PassThruConfig *)cfg{
    EpassThruResult result = [super validateParm:cfg];
    if (result != STATUS_NOERROR) {
        return result;
    }
    EpassThruResult valErr = ERR_INVALLD_IOCTL_VALUE;
    NSNumber *p1Max = cfg.configMap[[NSString stringWithFormat:@"%ld",(long)P1_MAX]];
    if (p1Max != nil && ([p1Max intValue] < 0x01 || [p1Max intValue] > 0xFFFF)) {
        return valErr;
    }
    NSNumber *p3Min = cfg.configMap[[NSString stringWithFormat:@"%ld",(long)P3_MIN]];
    if (p3Min != nil && ([p3Min longValue] < 0x00 || [p3Min longValue]> 0xFFFF)) {
        return valErr;
    }
    NSNumber *p4Min = cfg.configMap[[NSString stringWithFormat:@"%ld",(long)P4_MIN]];
    if (p4Min != nil && ([p4Min longValue]< 0x00 || [p4Min longValue] > 0xFFFF)) {
        return valErr;
    }
    NSNumber *t = cfg.configMap[[NSString stringWithFormat:@"%ld",(long)TIDLE]];
    if (t != nil && ([t longValue] < 0x00 || [t longValue] > 0xFFFF)) {
        return valErr;
    }
    t = cfg.configMap[[NSString stringWithFormat:@"%ld",(long)TWUP]];
    if (t != nil && ([t longValue] < 0x00 || [t longValue] > 0xFFFF)) {
        return valErr;
    }
    t = cfg.configMap[[NSString stringWithFormat:@"%ld",(long)TINIL]];
    if (t != nil && ([t longValue] < 0x00 || [t longValue] > 0xFFFF)) {
        return valErr;
    }
    
    NSNumber *p = cfg.configMap[[NSString stringWithFormat:@"%ld",(long)PARITY]];
    if (p != nil && ([p longValue] < 0x00 || [p longValue] > 0xFFFF)) {
        return valErr;
    }
    return result;
}

- (EpassThruResult)setParam:(PassThruConfig *)inCfg{
    EpassThruResult result = [super setParam:inCfg];
    if (result != STATUS_NOERROR) {
        return result;
    }
    NSNumber *temp = inCfg.configMap[[NSString stringWithFormat:@"%ld",(long)P1_MAX]];
    long p1Max = self.P1_Max;
    if (temp != nil) {
        p1Max = (long)temp;
    }
    temp = inCfg.configMap[[NSString stringWithFormat:@"%ld",(long)P3_MIN]];
    long p3Min = self.P3_Min;
    if (temp != nil) {
        p3Min = (long)temp;
    }
    temp = inCfg.configMap[[NSString stringWithFormat:@"%ld",(long)P4_MIN]];
    long p4Min = self.P4_Min;
    if (temp != nil) {
        p4Min = (long)temp;
    }
    temp = inCfg.configMap[[NSString stringWithFormat:@"%ld",(long)TIDLE]];
    long tidle = self.Tidle;
    if (temp != nil) {
        tidle = (long)temp;
    }
    temp = inCfg.configMap[[NSString stringWithFormat:@"%ld",(long)TINIL]];
    long tinil = self.Tinil;
    if (temp != nil) {
        tinil = (long)temp;
    }
    temp = inCfg.configMap[[NSString stringWithFormat:@"%ld",(long)TWUP]];
    long twup = self.Twup;
    if (temp != nil) {
        twup = (long)temp;
    }
    TxMwssage *frame = [[TxMwssage alloc] init];
    CmdId cmdid;
    frame.CmdId = cmdid.Set_K_Param;
    NSMutableArray *coll = [[NSMutableArray alloc] init];
    [coll addObject:[NSNumber numberWithLong:p1Max]];
    [coll addObject:[NSNumber numberWithLong:p3Min]];
    [coll addObject:[NSNumber numberWithLong:p4Min]];
    [coll addObject:[NSNumber numberWithLong:tidle]];
    [coll addObject:[NSNumber numberWithLong:tinil]];
    [coll addObject:[NSNumber numberWithLong:twup]];
    BytesConverter *bc = [[BytesConverter alloc] init];
    for (NSNumber *val in coll) {
        
        Byte *bytes = [bc longToBytes:[val longValue]];
        [frame appendDataWithData:[NSData dataWithBytes:&bytes[1] length:sizeof(bytes[1])]];
        [frame appendDataWithData:[NSData dataWithBytes:&bytes[0] length:sizeof(bytes[0])]];
    }
    long parity = self.Parity;
    temp = inCfg.configMap[[NSString stringWithFormat:@"%ld",(long)PARITY]];
    if (temp != nil) {
        parity = [temp longValue];
    }
    Byte *bytes = [bc longToBytes:parity];
    [frame appendData:bytes[0]];
    ElinkResult linkRet = [self.phyChannel sendMsg:frame];
    if (linkRet == NoError) {
        self.P1_Max = p1Max;
        self.P3_Min = p3Min;
        self.P4_Min = p4Min;
        self.Tidle = tidle;
        self.Tinil = tinil;
        self.Twup = twup;
        self.Parity = parity;
        result = STATUS_NOERROR;
    }else{
        result = ERR_FALLED;
        [[[SystemError alloc]init] setLastError:linkRet :linkRet];
    }
    return result;
}

- (EpassThruResult)getParam:(PassThruConfig *)outCfg{
    EpassThruResult result = [super getParam:outCfg];
    if (result != STATUS_NOERROR) {
        return result;
    }
    [outCfg setValue:[NSNumber numberWithLong:self.P1_Max] forKey:[NSString stringWithFormat:@"%ld",(long)P1_MAX]];
    [outCfg setValue:[NSNumber numberWithLong:self.P3_Min] forKey:[NSString stringWithFormat:@"%ld",(long)P3_MIN]];
    [outCfg setValue:[NSNumber numberWithLong:self.P4_Min] forKey:[NSString stringWithFormat:@"%ld",(long)P4_MIN]];
    [outCfg setValue:[NSNumber numberWithLong:self.Tidle] forKey:[NSString stringWithFormat:@"%ld",(long)TIDLE]];
    [outCfg setValue:[NSNumber numberWithLong:self.Tinil] forKey:[NSString stringWithFormat:@"%ld",(long)TINIL]];
    [outCfg setValue:[NSNumber numberWithLong:self.Twup] forKey:[NSString stringWithFormat:@"%ld",(long)TWUP]];
    [outCfg setValue:[NSNumber numberWithLong:self.Parity] forKey:[NSString stringWithFormat:@"%ld",(long)PARITY]];
    return result;
}

- (EpassThruResult)startMsgFilter:(EFilterType)type :(PassThruMsg *)maskMsg :(PassThruMsg *)patternMsg :(PassThruMsg *)flowControlMsg :(OutObject *)outFilterID{
    return ERR_NOTIMPLEMENTED;
}

- (EpassThruResult)stopMsgFilter:(int)Id{
    return ERR_NOTIMPLEMENTED;
}

@end
































