//
//  Device.m
//  J2534
//
//  Created by chenkai on 16/8/11.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "Device.h"
#import "CANLogalChannel.h"
#import "ISO14230Channel.h"
#import "ISO15765Channel.h"
#import "BOSCH5_3LogicalChannel.h"
#import "ResponseHandlerBase.h"
#import "PhysicalChannel.h"
#import "LogcalChanenel.h"
#import "RunOptions.h"
#import "CANPhychannel.h"
#import "PassThruMsg.h"
#import "KPhyChannel.h"
#import "BOSCH5_3PhyChannel.h"
#import "DataHub.h"
#import "FirwareProgram.h"
#import "DataLinker.h"
#import "OutObject.h"
@implementation Device

static int _IdCounter = 1;
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.phyChannelList = [[NSMutableArray alloc] init];
        
        self.Id = 0;
        self.ISOCANChannel = [[CANLogalChannel alloc] init];
        self.ISO14230Channel = [[ISO14230Channel alloc] init];
        self.ISO15765Channel = [[ISO15765Channel alloc] init];
        self.BOSCH5_3LogicalChannel = [[BOSCH5_3LogicalChannel alloc] init];
        _logicChannelColl = [[NSMutableArray alloc] init];
        _validJ1962Pins = [[NSMutableArray alloc] init];
        _delege = [[DataLinker alloc] initWithDelegate:self];
        _dataHub = nil;
        _program = nil;
        CANPhychannel *phyISOCANChannel = [[CANPhychannel alloc] initWithPinH:6 andPinL:14 andBaud:500000 andId:0 andDelegate:self.delege];
        PhysicalChannel *ch2 = [[CANPhychannel alloc] initWithPinH:3 andPinL:11 andBaud:500000 andId:1 andDelegate:self.delege];
        PhysicalChannel *ch3 = [[CANPhychannel alloc] initWithPinH:1 andPinL:9 andBaud:500000 andId:2 andDelegate:self.delege];
        PhysicalChannel *ch4 = [[CANPhychannel alloc] initWithPinH:12 andPinL:13 andBaud:500000 andId:3 andDelegate:self.delege];
        PhysicalChannel *ch5 = [[KPhyChannel alloc] initWithPinH:7 andPinL:0 andBaud:10400 andId:4 andDelegate:self.delege];
        PhysicalChannel *ch6 = [[BOSCH5_3PhyChannel alloc] initWithId:5 andDelegate:self.delege];
        [_phyChannelList addObject:phyISOCANChannel];
        [_phyChannelList addObject:ch2];
        [_phyChannelList addObject:ch3];
        [_phyChannelList addObject:ch4];
        [_phyChannelList addObject:ch5];
        [_phyChannelList addObject:ch6];
        for (PhysicalChannel *pc in _phyChannelList) {
            long pin = pc.pinH << 8 | pc.pinL;
            [_validJ1962Pins addObject:[NSNumber numberWithLong:pin]];
        }

        _dataHub = [[DataHub alloc] initWith:self];
        
        _program = [[FirwareProgram alloc] initWithLinker:self.delege];
        
    }
    return self;
}

- (EpassThruResult)open{
    [LogcalChanenel setDataHun:nil];
    [self setTaansmitOnly:false];
    ElinkResult result = [self.delege connet];
    EpassThruResult ret = ERR_DEVICE_NOT_CONNECTED;
    if (result == NoError) {
        self.Id = _IdCounter++;
        
        [LogcalChanenel setDataHun:self.dataHub];
        ret = STATUS_NOERROR;
    }
    @try {
        [NSThread sleepForTimeInterval:0.2];
    }
    @catch (NSException *exception) {
        @throw exception;
    }
    @finally {
        
    }
    return ret;
}

- (EpassThruResult)close{
    NSMutableArray<LogcalChanenel *> *tempArray = [[NSMutableArray alloc] init];
    for (PhysicalChannel *pc in self.phyChannelList) {
        if ([pc isOpened]) {
            for (LogcalChanenel *ch in [pc logicalChannels]) {
                [tempArray addObject:ch];
            }
        }
    }
    
    for (LogcalChanenel *lc in tempArray) {
        EpassThruResult reuslt = [lc close];
        if (reuslt != STATUS_NOERROR) {
            return reuslt;
        }
    }
    
    ElinkResult result = [self.delege disconnect];
    //修改：hz1
    if (result == NoError || result == SocketSendFailed) {
        @try {
            [NSThread sleepForTimeInterval:0.2];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
        }
        @finally {
            
        }
        _Id = -1;
        [LogcalChanenel setDataHun:nil];
        [self setTaansmitOnly:false];
        return STATUS_NOERROR;
    }else {
        [[[SystemError alloc]init] setLastError:(int)result :result];
        return ERR_FALLED;
    }
    
}

- (EpassThruResult)openChannel:(EProtocolId)protocolId :(long)baudrate :(long)flags :(OutObject *)outChannel{
    switch (protocolId) {
        case CAN:{
            EpassThruResult ret2 =  [self checkCANChannelIsValid:CAN :CAN_PS];
            if (ret2 != STATUS_NOERROR) {
                return ret2;
            }
            outChannel.obj  = _ISOCANChannel;
            
            return [self openChannelInternal:_ISOCANChannel :baudrate];
        }
            break;
        case CAN_PS:{
            EpassThruResult ret0 =  [self checkCANChannelIsValid:CAN :CAN_PS];
            if (ret0 != STATUS_NOERROR) {
                return ret0;
            }
            CANLogalChannel *canCh = [[CANLogalChannel alloc] initWithPin:0 :0];
            [canCh setBaudtate:baudrate];
            [_logicChannelColl addObject:canCh];
            outChannel.obj = canCh;
            return STATUS_NOERROR;
        }
            break;
        case ISO15765:{
            EpassThruResult ret1 =  [self checkCANChannelIsValid:CAN :ISO15765_PS];
            if (ret1 != STATUS_NOERROR) {
                return ret1;
            }
            outChannel.obj = self.ISO15765Channel;
            
            return [self openChannelInternal:self.ISO15765Channel :baudrate];
        }
            break;
        case ISO15765_PS:
        {
            EpassThruResult ret = [self checkCANChannelIsValid:ISO15765 :ISO15765_PS];
            if (ret != STATUS_NOERROR) {
                return ret;
            }
            ISO15765Channel *ch = [[ISO15765Channel alloc] initWithPinh:0 :0];
            outChannel.obj = ch;
            [ch setBaudtate:baudrate];
            [_logicChannelColl addObject:ch];
            return STATUS_NOERROR;
        }
            
            break;
            case ISO14230:
        {
            outChannel.obj = self.ISO14230Channel;
            return [self openChannelInternal:self.ISO14230Channel :baudrate];
        }
            break;
        case BOSCH5_3:
        {
            outChannel.obj = self.BOSCH5_3LogicalChannel;
            return [self openChannelInternal:self.BOSCH5_3LogicalChannel :baudrate];
        }
            break;
        default:
            
            break;
    }
    return ERR_NOT_SUPPORTED;
}

- (EpassThruResult)checkCANChannelIsValid:(EProtocolId)protocolId :(EProtocolId)protocolId_PS{
    int cout = 0;
    for (LogcalChanenel *lc in self.logicChannelColl) {
        if (lc.protocolId == protocolId || lc.protocolId == protocolId_PS) {
            cout++;
        }
    }
    EpassThruResult result = STATUS_NOERROR;
    RunOptions *runOptions = [[RunOptions alloc] init];
    if (cout >= runOptions.CANChannelCount) {
        result = ERR_CHANNEL_IN_USE;
    }
    return result;
}

- (EpassThruResult)openChannelInternal:(LogcalChanenel *)logicChannel :(long)baudrate{
    if ([logicChannel isOpend]) {
        return ERR_CHANNEL_IN_USE;
    }
    PhysicalChannel *phyCh = [self getPhysicalChannel:logicChannel];
    if (phyCh == nil) {
        return ERR_CHANNEL_IN_USE;
    }
    logicChannel.baudtate = baudrate;
    logicChannel.phyChannel = phyCh;
    EpassThruResult result = [logicChannel open];
    if (result == STATUS_NOERROR) {
        [_logicChannelColl addObject:logicChannel];
    }
    return result;
}

- (LogcalChanenel *)findChannel:(int)Id{
    LogcalChanenel *channel = nil;
    int i = 0;
    for (LogcalChanenel *lc in self.logicChannelColl) {
        if (lc.Id == Id) {
            channel = lc;
        }
        i++;
    }
    return channel;
}

- (EpassThruResult)closeChannel:(int)channelId{
    EpassThruResult result = ERR_INVALLD_CHANNEL_ID;
    LogcalChanenel *channel = [self findChannel:channelId];
    if (channel != nil) {
        result = [channel close];
        if (result == STATUS_NOERROR) {
            [_logicChannelColl removeObject:channel];
        }
    }
    return result;
}

- (PhysicalChannel *)getPhysicalChannel:(LogcalChanenel *)logicChannel{
    PhysicalChannel *phyCh = nil;
    int canChCout = 0;
    for (PhysicalChannel *pc in _phyChannelList) {
        if ([pc isKindOfClass:[CANPhychannel class]] && [pc isOpened]) {
            canChCout++;
        }
    }
    for (PhysicalChannel *pc in _phyChannelList) {
        if (pc.pinH == logicChannel.pinH && logicChannel.pinL == pc.pinL) {
            phyCh = pc;
            break;
        }
    }
    RunOptions *rop = [[RunOptions alloc] init];
    if (canChCout >= rop.CANChannelCount && phyCh != nil && ![phyCh isOpened]) {
        phyCh = nil;
    }
    return phyCh;
}

- (EpassThruResult)readMsgs:(int)channelId :(OutObject *)outMsgList :(OutObject *)inOutNum :(int)timeout{
    EpassThruResult result = ERR_INVALLD_CHANNEL_ID;
    LogcalChanenel *channel = [self findChannel:channelId];
    if (channel != nil) {
        result = [channel readMsgs:outMsgList :inOutNum :timeout];
    }
    return result;
}

- (EpassThruResult)writeMsgs:(int)channelId :(NSMutableArray<PassThruMsg *> *)inMsgList :(OutObject *)outNum :(int)timeout{
    EpassThruResult result = ERR_INVALLD_CHANNEL_ID;
    LogcalChanenel *channel = [self findChannel:channelId];
    if (channel != nil) {
        for (PassThruMsg *pmsg in inMsgList) {
            
            if (pmsg.ProtocolId == channel.protocolId || (pmsg.ProtocolId - 1 + 0x8000) == channel.protocolId) {
                continue;
            }else {
                return ERR_MSG_PROTOCOL_ID;
            }
        }
    }
    int count = 0;
    for (PassThruMsg *pmsg in inMsgList) {
        result = [channel writeMsg:pmsg :timeout];
        if (result != STATUS_NOERROR) {
            return  result;
        }
        count++;
        outNum.obj = [NSNumber numberWithInt:count];
    }
    return result;
}

- (EpassThruResult)switchPin:(LogcalChanenel *)ch :(NSNumber *)j1962Pins{
    if (ch.protocolId != ISO15765_PS && ch.protocolId != CAN_PS) {
        return ERR_NOT_SUPPORTED;
    }
    if (![_validJ1962Pins containsObject:j1962Pins]) {
        return ERR_PIN_INVALLD;
    }
    if ([ch isOpend]) {
        return ERR_INVALLD_IOCTL_VALUE;
    }
    int pinH = [j1962Pins intValue] >> 8;
    int pinL = [j1962Pins intValue] & 0xFF;
    ch.pinH = pinH;
    ch.pinL = pinL;
    return [self openChannelInternal:ch :ch.baudtate];
}


- (EpassThruResult)getSN:(NSString *)outSn{
    EpassThruResult reault = ERR_FALLED;
    outSn = @"";
    if (![self.delege isConnected]) {
        reault = ERR_DEVICE_NOT_CONNECTED;
    }
    ElinkResult ret = [self.delege readSN:outSn];
    if (ret == NoError) {
        reault = STATUS_NOERROR;
    }else{
        [[[SystemError alloc]init] setLastError:ret :ret];
    }
    return reault;
}

- (EpassThruResult)getFirmwareVersion:(OutObject *)outVersion{
    EpassThruResult result = ERR_FALLED;
    outVersion.obj = @"";
    if (![self.delege isConnected]) {
        result = ERR_DEVICE_NOT_CONNECTED;
    }
    ElinkResult ret = [_delege readFirmwareVersion:outVersion];
    if (ret == NoError) {
        result = STATUS_NOERROR;
    }else{
        [[[SystemError alloc]init] setLastError:ret :ret];
    }
    return result;
}

- (double)readVoltage{
    if (![self.delege isConnected]) {
        return 0.0;
    }
    NSNumber *outVol = [[NSNumber alloc] init];
    ElinkResult result = [self.delege readVoltage:outVol];
    return result == NoError ? [outVol doubleValue ]: 0.0;
}

- (void)transferData:(NetworkFrame *)msg{
    for (PhysicalChannel *pc in _phyChannelList) {
        if ([pc receiveMsg:msg]) {
            break;
        }
    }
}

- (void)setVendorId:(long)vensorId{
    
    [self.delege setVendorId:vensorId];
    
}

- (EpassThruResult)computeSA:(long)vendorCode :(short)alg :(NSData *)seeds :(OutObject *)outKeys{
    if (![self.delege isConnected]) {
        return ERR_DEVICE_NOT_CONNECTED;
    }
    ElinkResult ret = [self.delege computeSA:vendorCode :alg :(NSMutableData *)seeds :outKeys];
    if (ret == NoError) {
        return STATUS_NOERROR;
    }else{
#warning 不完整 ---
        [[[SystemError alloc] init] setLastError:ret];
        return ERR_FALLED;
    }
    
}

- (void)setTaansmitOnly:(BOOL)isTransmitOnly{
    
}


- (int)restoreFirmware{
    ElinkResult ret = [self.delege restoreFirmware];
    return ret;
}

- (BOOL)changeMode:(int)mode{
    if ([self.delege changeMode:mode] == NoError) {
        return YES;
    }
    return NO;
}


@end













































