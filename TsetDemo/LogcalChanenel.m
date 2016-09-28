//
//  LogcalChanenel.m
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "LogcalChanenel.h"
#import "DataHub.h"
#import "PhysicalChannel.h"
#import "SystemError.h"
#import "ErrorItem.h"
#import "PassThruMsg.h"
#import "RunOptions.h"
#import "BytesConverter.h"
#import "NetworkFrame.h"
#import "PassThruConfig.h"
#import "OutObject.h"
static int IDCounter = 0;
static DataHub *dataHub;

@implementation LogcalChanenel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.protocolId = Unknown;
        self.Id = -1;
        self.receiveBuffer = [[NSMutableArray alloc] init];
        self.phyChannel = nil;
        self.pinH = 6;
        self.pinL = 14;
        self.baudtate = 500000;
        self.fillterColl = [[NSMutableArray alloc] init];
        self.isLoopback = NO;
        self.dataHub = nil;
        self.isTransmitOnly = NO;
        self.TAG = @"DebugFrame";
        self.txMsg = nil;
        self.syncTxobj = [[NSObject alloc] init];
        _Id = ++IDCounter;
    }
    return self;
}



+ (DataHub *)getDataHub{
    return dataHub;
}

+ (void)setDataHun:(DataHub *)dataHu{
    dataHub = dataHu;
}

- (EpassThruResult)open{
    EpassThruResult result = STATUS_NOERROR;
    if (_phyChannel == nil || _phyChannel.pinH != self.pinH || _phyChannel.pinL != self.pinL) {
        
        SystemError *err = [[SystemError alloc] init];
        [err setLastError1:err.ErrInvalidPhyChannel];
        return ERR_FALLED;
    }
    if (![_phyChannel isOpened]) {
        _phyChannel.Baudrate = self.baudtate;
        ElinkResult ret = [_phyChannel open:self.protocolId];
        if (ret != NoError) {
            [[[SystemError alloc] init] setLastError:ret :ret];
            return ERR_FALLED;
        }
    }else if (_phyChannel.Baudrate != self.baudtate){
        return ERR_CHANNEL_IN_USE;
    }
    [self.receiveBuffer removeAllObjects];
    [self.fillterColl removeAllObjects];
    [self.phyChannel registe:self];
    @try {
        [NSThread sleepForTimeInterval:0.2];
    }
    @catch (NSException *exception) {
        @throw exception;
    }
    @finally {
        
    }
    return result;
}

- (EpassThruResult)close{
    EpassThruResult result = STATUS_NOERROR;
    if ((_pinH <= 0 && _pinL <= 0) || _phyChannel == nil) {
        return result;
    }
    
    [self clearFilter];
    [self clearPeriodicMsg];
    PhysicalChannel *phyCh = _phyChannel;
    [_phyChannel unreigister:self];
    _Id = -1;
    ElinkResult ret = [phyCh close];
    [self clearRxBuffer];
    if (ret != NoError && ret != ChannelInUse) {
        [[[SystemError alloc] init] setLastError:ret :ret];
        result = ERR_FALLED;
        if (ret == SocketSendFailed) {
            result = ERR_TLMEOUT;
        }
    }
    @try {
        [NSThread sleepForTimeInterval:0.2];
    }
    @catch (NSException *exception) {
        @throw exception;
    }
    @finally {
        
    }
    return result;
}

- (void)receiveMsg:(NetworkFrame *)msg{
    PassThruMsg *reMsg = [self toRxPassThruMsg:msg];
    [self addToBuffer:reMsg];
}

- (void)addToBuffer:(PassThruMsg *)rxMsg{
    BOOL isTxMsg = (rxMsg.RxStatus & rxMsg.TX_MSG) == rxMsg.TX_MSG;
    @try {
        if (self.txMsg != nil && isTxMsg && [[[PassThruMsg alloc] init] compareBytes:_txMsg.Data :rxMsg.Data]) {
            _txMsg.RxStatus |= _txMsg.TX_INDICATION_DONE;
        }
    }
    @catch (NSException *exception) {
        @throw exception;
    }
    if (!self.isLoopback && isTxMsg) {
        return;
    }

   
    if (!_isTransmitOnly) {
    @synchronized(_receiveBuffer) {
        [_receiveBuffer addObject:rxMsg];
    }
    RunOptions *rop = [[RunOptions alloc] init];
    if (rop.IsDebugTrance) {
        NSLog(@"%@5555->Channel Received frame:%@", self.TAG,[[[BytesConverter alloc] init] bytesToHexStr:rxMsg.Data]);
    }
    if (_dataHub != nil && rxMsg != nil) {
        [_dataHub transmit:rxMsg :self];
    }
    }
}

- (EpassThruResult)readMsgs:(OutObject *)outMsgList :(OutObject *)inOutNum :(int)timeOut{
    if (self.pinH <= 0 && self.pinL <= 0) {
        return ERR_PIN_INVALLD;
    }
    int realCount = (int)[_receiveBuffer count];
    int timeout = timeOut > 0 ? timeOut + 20 : 0;
    int readCount = [inOutNum.obj intValue];
    if (realCount < readCount) {
        while (timeout > 0) {
            realCount = (int)[_receiveBuffer count];
            if (realCount >= readCount) {
                break;
            }
            @try {
                [NSThread sleepForTimeInterval:5/1000];
            }
            @catch (NSException *exception) {
                @throw exception;
            }
            @finally {
                
            }
            timeout = 5;
        }
    }
    @synchronized(_receiveBuffer) {
        realCount = (int)[_receiveBuffer count];
        int count = 0;
        while (count < realCount && count < readCount) {
            PassThruMsg *pMsg = _receiveBuffer[0];
            [_receiveBuffer removeObjectAtIndex:0];
            RunOptions *rop = [[RunOptions alloc] init];
            if (rop.IsDebugTrance) {
                NSLog(@"%@66666->Channel Read frame:%@", self.TAG,[[[BytesConverter alloc] init] bytesToHexStr:pMsg.Data]);
            }
            
            [outMsgList.obj addObject:pMsg];
            count++;
        }
        inOutNum.obj = [NSNumber numberWithInt:count];
    }
    EpassThruResult reault = STATUS_NOERROR;
    if (realCount == 0) {
        reault = ERR_BUFFER_EMPTY;
    }else if (readCount > [inOutNum.obj intValue]){
        reault = ERR_TLMEOUT;
    }
    return reault;
}

- (PassThruMsg *)toRxPassThruMsg:(NetworkFrame *)rawMsg{
    PassThruMsg *pmsg = [[PassThruMsg alloc] init];
    pmsg.Timestamp = 1000000 * (rawMsg.TimeStamp + rawMsg.TimeStampCycle *65535) / self.phyChannel.Baudrate;
    long rxStatus = 0;
    if ((rawMsg.Option & rawMsg.EXTFRAMEFLAG) == rawMsg.EXTFRAMEFLAG) {
        rxStatus = pmsg.CAN_29BIT_ID;
    }
    pmsg.ProtocolId = self.protocolId;
    if (self.protocolId == ISO15765_PS) {
        pmsg.ProtocolId = ISO15765;
    }else if (self.protocolId == CAN_PS){
        pmsg.ProtocolId = CAN;
    }
    if ((rawMsg.Option & rawMsg.DIRFLAG) == rawMsg.DIRFLAG) {
        pmsg.RxStatus = pmsg.TX_MSG | rxStatus;
    }
    
    pmsg.DataSize = (int)rawMsg.DataLen + (int)rawMsg.FrameIdButes.length;
    NSMutableData *data = [[NSMutableData alloc] init];
//    Byte *franeIdBytes = (Byte *)[rawMsg.FrameIdButes bytes];
    [data appendData:rawMsg.FrameIdButes];
    [data appendData:rawMsg.Data];
    pmsg.Data = data;
    pmsg.ExtraDataIndex = pmsg.DataSize;
    return pmsg;
}

- (EpassThruResult)validateMsg:(PassThruMsg *)pmg{
    if (pmg.ProtocolId != self.protocolId && pmg.ProtocolId != (self.protocolId + 1 - 0x8000)) {
        return ERR_MSG_PROTOCOL_ID;
    }
    EpassThruResult result = ERR_INVALID_MSG;
    if (pmg.DataSize != pmg.Data.length) {
        return result;
    }
    switch (self.protocolId) {
        case CAN:
        case CAN_PS:
        {
            if (pmg.DataSize >=4 && pmg.DataSize <= 12) {
                result = STATUS_NOERROR;
            }
        }
            break;
        case ISO15765:
        case ISO15765_PS:
        {
            BOOL isExtendAddress = (pmg.TxFlags & 0x00000040) == 0x00000040 ? YES : NO;
            if (!isExtendAddress) {
                if (pmg.DataSize >=4 && pmg.DataSize <= 4099) {
                    result = STATUS_NOERROR;
                }
            }else {
                if (pmg.DataSize >= 5 && pmg.DataSize <= 4100) {
                    result = STATUS_NOERROR;
                }
            }
        }
            break;
        case ISO14230:
        {
            if (pmg.DataSize >= 1 && pmg.DataSize <= 259) {
                result = STATUS_NOERROR;
            }
        }
            break;
        default:
            assert(self.protocolId);
            break;
    }
    return result;
}

- (EpassThruResult)writeMsg:(PassThruMsg *)msg :(int)timeout{
    
    if (self.pinH <= 0 && self.pinL <= 0) {
        return ERR_PIN_INVALLD;
    }
    EpassThruResult passRet = [self validateMsg:msg];
    if (passRet != STATUS_NOERROR) {
        return passRet;
    }
    NSMutableArray<TxMwssage *> *msgList = [[NSMutableArray alloc] init];
    passRet = [self toLinkTxMessage:msg :msgList];
    if (passRet != STATUS_NOERROR) {
        return passRet;
    }
    if (timeout > 0) {
        [self setTxMsg:msg];
    }
    ElinkResult result = [_phyChannel sendMsgList:msgList];
    if (result == NoError) {
        EpassThruResult ret = STATUS_NOERROR;
        if (timeout > 0) {
            [self setTxMsg:nil];
        }
        return ret;
    }else if (result == ChannelNotOpen){
        [self setTxMsg:nil];
        return ERR_INVALLD_CHANNEL_ID;
    }
    [self setTxMsg:nil];
    [[[SystemError alloc] init] setLastError:result :result];
    return ERR_FALLED;
    
}

- (EpassThruResult)setParameter{
    return ERR_NOTIMPLEMENTED;
}

- (EpassThruResult)clearRxBuffer{
    @synchronized(_receiveBuffer) {
        [_receiveBuffer removeAllObjects];
    }
    return STATUS_NOERROR;
}

- (EpassThruResult)clearFilter{
    EpassThruResult result = STATUS_NOERROR;
    while ([_fillterColl count] > 0) {
        Filter *f;
        if (_fillterColl == nil) {
            f = nil;
        }else{
            f = _fillterColl[0];
            [_fillterColl removeObjectAtIndex:0];
        }
        if (f != nil) {
            EpassThruResult result2 = [self stopMsgFilterWithFilter:f];
            result = result2;
        }
    }
    return result;
}

- (EpassThruResult)clearPeriodicMsg{
    return ERR_NOTIMPLEMENTED;
}

- (EpassThruResult)startMsgFilter:(EFilterType)type :(PassThruMsg *)maskMsg :(PassThruMsg *)patternMsg :(PassThruMsg *)flowControlMsg :(OutObject *)outFilterID{
    if (self.pinH <= 0 && self.pinL <= 0) {
        return  ERR_PIN_INVALLD;
    }
    return [self  voidateFilter:type :maskMsg :patternMsg :flowControlMsg];
}

- (EpassThruResult)voidateFilter:(EFilterType)type :(PassThruMsg *)maskMsg :(PassThruMsg *)patternMsg :(PassThruMsg *)flowControlMsg{
    return ERR_NOTIMPLEMENTED;
}

- (EpassThruResult)stopMsgFilter:(int)Id{
    return ERR_NOTIMPLEMENTED;
}

- (EpassThruResult)stopMsgFilterWithFilter:(Filter *)filter{
    return ERR_NOTIMPLEMENTED;
}

- (EpassThruResult)startPeriodicMsg:(PassThruMsg *)pmsg :(long)timeInterval :(OutObject *)outPeriodicId{
    if (self.pinH <= 0 && self.pinL <= 0) {
        return ERR_PIN_INVALLD;
    }
    return STATUS_NOERROR;
}

- (EpassThruResult)stopPeriodicMsg:(int)Id{
    return ERR_NOTIMPLEMENTED;
}

- (EpassThruResult)validateParm:(PassThruConfig *)cfg{
    return STATUS_NOERROR;
}

- (EpassThruResult)setParam:(PassThruConfig *)inCfg{
    EpassThruResult result = [self validateParm:inCfg];
    if (result != STATUS_NOERROR) {
        return result;
    }
    NSNumber *looback = [inCfg getConfig:LOOPBACK];
    self.isLoopback = (looback == nil || [looback longValue] == 0) ? NO : YES;
    return result;
}


- (EpassThruResult)getParam:(PassThruConfig *)outCfg{
    EpassThruResult result = STATUS_NOERROR;
    [outCfg add:DATA_RATE :self.baudtate];
    [outCfg add:LOOPBACK :self.isLoopback ? 1L : 0];
    [outCfg add:J1962_PINS :(long)self.pinH << 8 | self.pinL];
    return result;
}

- (BOOL)isOpend{
    return self.phyChannel != nil && [self.phyChannel isOpened];
}


- (EpassThruResult)toLinkTxMessage:(PassThruMsg *)pmsg :(NSMutableArray<TxMwssage *> *)outMsgList{
    return 0;
}


@end







































