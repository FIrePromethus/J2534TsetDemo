//
//  J2534.m
//  J2534
//
//  Created by chenkai on 16/8/11.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "J2534.h"
#import "Device.h"
#import "LogcalChanenel.h"
#import "RunOptions.h"
#import "SystemError.h"
#import "SecurityAccessHandler.h"
#import "PassThruConfig.h"
#import "ISO914LogicalChannel.h"
#import "BOSCH5_3LogicalChannel.h"
#import "FirwareProgram.h"
#import "OutObject.h"
@implementation J2534

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.vendorId = 0x2ECDB585;
        self.TAG = @"PassThruApi";
        self.isEnableTrace = false;
        
    }
    return self;
}

- (EpassThruResult)PassThruOpen:(NSString *)name :(OutObject *)outDeviceId{
    
    if (_device != nil) {
        return ERR_DEIVICE_IN_USE;
    }
    if (outDeviceId == nil) {
        return ERR_NULL_PARAMETER;
    }
    outDeviceId.obj = @1;
    self.device = [[Device alloc] init];

    [self.device setVendorId:_vendorId];
    EpassThruResult result = [self.device open];
    if (result == STATUS_NOERROR) {
        
        outDeviceId.obj = [NSNumber numberWithInt:_device.Id];
    }else{
        _device = nil;
    }
    
    return result;
    
}

- (EpassThruResult)PassThruClose:(int)deviceId{
    if (_device == nil) {
        return ERR_DEVICE_NOT_CONNECTED;
    }
    if (_device.Id != deviceId) {
        return ERR_INVALLD_DEVICE_ID;
    }
    [self trance:[NSString stringWithFormat:@"--->PassThruClose(deviceId=%d)",deviceId]];
    EpassThruResult result = [_device close];
    if (result == STATUS_NOERROR || result == ERR_TLMEOUT) {
        _device = nil;
    }
    return result;
}

- (void)trance:(NSString *)msg{
    
        NSLog(@"%@%@",self.TAG,msg);
    
}

- (EpassThruResult)PassThruConnect:(int)deviceId :(EProtocolId)protocolId :(unsigned long)flags :(unsigned long)bauRate :(OutObject *)outChannelId{
    if (_device == nil) {
        return ERR_DEVICE_NOT_CONNECTED;
    }
    if (_device.Id != deviceId) {
        return ERR_INVALLD_DEVICE_ID;
    }
    if (outChannelId == nil) {
        return ERR_NULL_PARAMETER;
    }
    outChannelId.obj = [NSNumber numberWithInt:-1];
    [self trance:[NSString stringWithFormat:@"--->PassThruConnect(deviceId=%d,protocolId=%ld,flags=%ld,baudRate=%ld,outChannelId=%d)", deviceId,(long)protocolId,flags,bauRate,[outChannelId.obj intValue]]];
    OutObject *outCh = [[OutObject alloc] init];
    EpassThruResult result = [_device openChannel:protocolId :bauRate :flags :outCh];
    if (result == STATUS_NOERROR) {
        LogcalChanenel *ch = outCh.obj;
        outChannelId.obj = [NSNumber numberWithInt:ch.Id];
        
    }
    return result;
}


- (EpassThruResult)PassThruDisconnect:(int)channelId{
    
    if (_device == nil) {
        return ERR_DEVICE_NOT_CONNECTED;
    }
    [self trance:[NSString stringWithFormat:@"--->PassThruDisconnect(channelId=%d)",channelId]];
    return [_device closeChannel:channelId];
}

- (EpassThruResult)PassThruReadMsgs:(int)channelId :(OutObject *)outMsgArray :(OutObject *)inOutNum :(int)timeOut{
    if (_device == nil) {
        return ERR_DEVICE_NOT_CONNECTED;
    }
    if (outMsgArray == nil || inOutNum == nil) {
        return ERR_NULL_PARAMETER;
    }
    [self trance:[NSString stringWithFormat:@"--->PassThruReadMsgs(channelId=%d,outMsgList.count=%lu,inOutNum=%d,timeout=%d)",channelId,(unsigned long)[outMsgArray.obj count],[inOutNum.obj intValue],timeOut]];
    return [_device readMsgs:channelId :outMsgArray :inOutNum :timeOut];
    
}

- (EpassThruResult)PassThruWriteMsgs:(int)channelId :(NSMutableArray<PassThruMsg *> *)inMsgArray :(OutObject *)outNum :(int)timeOut{
    if (_device == nil) {
        return ERR_DEVICE_NOT_CONNECTED;
    }
    if (inMsgArray == nil || outNum == nil) {
        return ERR_NULL_PARAMETER;
    }
    [self trance:[NSString stringWithFormat:@"--->PassThruWriteMsgs(channelId = %d,inMsgList.count=%lu,outNum=%d,timeout=%d)",channelId,(unsigned long)inMsgArray.count,[outNum.obj intValue],timeOut]];
    return [_device writeMsgs:channelId :inMsgArray :outNum :timeOut];
    
}

- (EpassThruResult)PassThruStartPeriodicMsg:(int)channelId :(PassThruMsg *)inMsg :(OutObject *)outPeriodicId :(int)timeInterval{
    if (_device == nil) {
        return ERR_DEVICE_NOT_CONNECTED;
    }
    if (inMsg == nil || outPeriodicId == nil) {
        return ERR_NULL_PARAMETER;
    }
    if (timeInterval < 5 || timeInterval > 65535) {
        return ERR_INVALID_TIME_INTERVAL;
    }
    outPeriodicId.obj = [NSNumber numberWithInt:-1];
    [self trance:[NSString stringWithFormat:@"--->PassThruStartPeriodicMsg(channdelId=%d,inMsg=%@,outPeriodicId=%d,timeInterval=%d)",channelId,inMsg,[outPeriodicId.obj intValue], timeInterval]];
    LogcalChanenel *lc = [_device findChannel:channelId];
    if (lc == nil) {
        return ERR_INVALLD_CHANNEL_ID;
    }
    return [lc startPeriodicMsg:inMsg :timeInterval :outPeriodicId];
}

- (EpassThruResult)PassThruStopPeriodicMsg:(int)channelId :(int)periodicId{
    if (_device == nil) {
        return ERR_DEVICE_NOT_CONNECTED;
    }
    [self trance:[NSString stringWithFormat:@"--->PassThruStopPeriodicMsg(channelId=%d,periodicId=%d)", channelId, periodicId]];
    LogcalChanenel *lc = [_device findChannel:channelId];
    if (lc == nil) {
        return ERR_INVALLD_CHANNEL_ID;
    }
    return [lc stopPeriodicMsg:periodicId];
}

- (EpassThruResult)PassThruStartMsgFilter:(int)channelId :(EFilterType)filterType :(PassThruMsg *)maskMsg :(PassThruMsg *)paterrMsg :(PassThruMsg *)flowControlMsg :(OutObject *)outFilterId{
    if (_device == nil) {
        return ERR_DEVICE_NOT_CONNECTED;
    }
    if (maskMsg == nil || paterrMsg == nil || flowControlMsg == nil || outFilterId == nil) {
        return ERR_NULL_PARAMETER;
    }
    [self trance:[NSString stringWithFormat:@"--->PassThruStarMsgFilter(channelId=%d,filterType=%ld,maskMsg=%@,patternMsg=%@,flowControlMsg=%@,outFilterId=%d)",channelId,(long)filterType,maskMsg,paterrMsg,flowControlMsg,[outFilterId.obj intValue]]];
    outFilterId.obj = [NSNumber numberWithInt:-1];
    LogcalChanenel *lc = [_device findChannel:channelId];
    if (lc == nil) {
        return ERR_INVALLD_CHANNEL_ID;
    }
    return [lc startMsgFilter:filterType :maskMsg :paterrMsg :flowControlMsg :outFilterId];
    
}

- (EpassThruResult)PassThruStopMsgFilter:(int)channelId :(int)filterId{
    if (_device ==  nil) {
        return ERR_DEVICE_NOT_CONNECTED;
    }
    [self trance:[NSString stringWithFormat:@"--->PassThruStopMsgFilter(channelId=%d,filterId=%d)",channelId,filterId]];
    LogcalChanenel *lc = [_device findChannel:channelId];
    if (lc == nil) {
        return ERR_INVALLD_CHANNEL_ID;
    }
    return [lc stopMsgFilter:filterId];
}

- (EpassThruResult)PassThruGetLastError:(OutObject *)errorDesc{
    if (errorDesc == nil) {
        return ERR_NULL_PARAMETER;
    }
    [self trance:[NSString stringWithFormat:@"--->PassThruGetLastError(errorDesc=%@)",errorDesc.obj]];
    int a = [[[SystemError alloc] init] LastError];
    errorDesc.obj = [[NSNumber alloc] initWithInt:a];
    return STATUS_NOERROR;
}


- (EpassThruResult)PassThruIoctl:(int)channelId :(EIoctlId)ioctlId :(id)inputConfig :(id)outoutCongig{
    if (_device == nil) {
        return ERR_DEVICE_NOT_CONNECTED;
    }
    [self trance:[NSString stringWithFormat:@"--->PassThruIoctl(channelId=%d,ioctlId=%ld,inputConfig=%@,outputConfig=%@)",channelId,(long)ioctlId,inputConfig,outoutCongig]];
    LogcalChanenel *lc = [_device findChannel:channelId];
    EpassThruResult result = ERR_NOTIMPLEMENTED;
    switch (ioctlId) {
        case GET_CONFIG:{
            if (lc == nil) {
                return ERR_INVALLD_CHANNEL_ID;
            }
            PassThruConfig *getCfg = inputConfig;
            if (getCfg == nil) {
                return ERR_NULL_PARAMETER;
            }
            result = [lc getParam:getCfg];
        }
            break;
        case SET_CONFIG:
        {
            if (lc == nil) {
                return ERR_INVALLD_CHANNEL_ID;
            }
            PassThruConfig *setCfg = inputConfig;
            if (setCfg == nil) {
                return ERR_NULL_PARAMETER;
            }

            NSNumber *pins = [setCfg getConfig:J1962_PINS];
            if (pins != nil) {
                result = [_device switchPin:lc :pins];
                if (result != STATUS_NOERROR) {
                    return result;
                }
            }
            result = [lc setParam:setCfg];
        }
            break;
        case READ_VBATT:
        {
            NSNumber *volRef = outoutCongig;
            if (volRef == nil) {
                return ERR_NULL_PARAMETER;
            }
            double vol = [_device readVoltage];
            volRef = [NSNumber numberWithDouble:vol];
            result = STATUS_NOERROR;
        }
            break;
        case FIVE_BAUD_INIT:
        {
            ISO914LogicalChannel *tempCh1 = (ISO914LogicalChannel *)lc;
            result = ERR_INVALLD_CHANNEL_ID;
            if (tempCh1 != nil) {
                result = [tempCh1 fiveBaudInit];
                BOSCH5_3LogicalChannel *boschCh = (BOSCH5_3LogicalChannel *)lc;
                if (boschCh != nil) {
                    
                    NSData *target = [NSData dataWithBytes:&inputConfig length:sizeof(inputConfig)];
                    if (target != nil) {
                        boschCh.target = (Byte)inputConfig;
                    }
                }
            }
        }
            break;
        case FAST_INIT:
        {
            ISO914LogicalChannel *tempCh2 = (ISO914LogicalChannel *)lc;
            result = ERR_INVALLD_CHANNEL_ID;
            if (tempCh2 != nil) {
                result = [tempCh2 fastInit:(PassThruMsg *)inputConfig :(PassThruMsg *)outoutCongig];
            }
        }
            break;
        case CLEAR_RX_BUFFER:
        {
            if (lc == nil) {
                return ERR_INVALLD_CHANNEL_ID;
            }
            result = [lc clearRxBuffer];
        }
            break;
        case CLEAR_PERLOPDIC_MSGS:
        {
            if (lc == nil) {
                return ERR_INVALLD_CHANNEL_ID;
            }
            result = [lc clearPeriodicMsg];
        }
            break;
        case CLEAR_MSG_FILTERS:
        {
            if (lc == nil) {
                return ERR_INVALLD_CHANNEL_ID;
            }
            result = [lc clearFilter];
        }
            break;
        case GET_DEVIGE_SN:
        {
            NSString *outSn = outoutCongig;
            if (outSn == nil) {
                return ERR_NULL_PARAMETER;
            }
            result = [_device getSN:outSn];
        }
            break;
        default:
            break;
    }
    return result;
}

- (EpassThruResult)PassThruReadVersion:(int)deviceId :(OutObject *)firmwareVersion :(OutObject *)jarVersion :(OutObject *)apiVersion{
    if (_device == nil) {
        return ERR_DEVICE_NOT_CONNECTED;
    }
    if (firmwareVersion == nil || jarVersion == nil || apiVersion == nil) {
        return ERR_NULL_PARAMETER;
    }
    [self trance:[NSString stringWithFormat:@"--->PassThruReadVersion(deviceId=%d),firmwareVersion=%@,jarVersion=%@,apiVersion=%@", deviceId,firmwareVersion,jarVersion,apiVersion]];
    OutObject *firmwareVer = [[OutObject alloc] init];
    EpassThruResult result = [_device getFirmwareVersion:firmwareVer];
    firmwareVersion.obj = firmwareVer.obj;
    RunOptions *rop = [[RunOptions alloc] init];
    jarVersion.obj = rop.JarVersion;
    apiVersion.obj = rop.ApiVersion;
    return result;
}

- (void)setVendorId:(long)vendorId{
    [self trance:[NSString stringWithFormat:@"--->setVenorId(errorDesc=%ld)",vendorId]];
    _vendorId = vendorId;
}

- (EpassThruResult)computeSA:(long)vendorCode :(short)alg :(NSMutableData *)seeds :(OutObject *)outKeys{
    if ([RunOptions getOEM] == 3) {
        return ERR_NOT_SUPPORTED;
    }
    if (_device == nil) {
        return ERR_DEVICE_NOT_CONNECTED;
    }
    [self trance:[NSString stringWithFormat:@"--->computeSA(vendorCode=%ld,alg=%d,seeds=%@,outKeys=%@)",vendorCode,alg,seeds,outKeys]];
    return [_device computeSA:vendorCode :alg :seeds :outKeys];
    
}


- (int)getFirmwareUpdateProgress{
    if ([RunOptions getOEM] == 3) {
        return -1;
    }
    [self trance:@"--->getFimwareUpdateProgress"];
    if (_device == nil) {
        
        return [[FirwareProgram alloc] init].ErrDeviceNotOpened;
    }
    return _device.program.currentProcess;
}

- (int)restoreFirmware{
    if ([RunOptions getOEM] == 3) {
        return -1;
    }
    [self trance:@"--->restoreFirmware"];
    if (_device == nil) {
        return [[FirwareProgram alloc] init].ErrDeviceNotOpened;
    }
    return [_device restoreFirmware];
}

- (void)initDevice{
    _device = nil;
}

- (Device *)getDevice{
    if ([RunOptions getOEM] == 2) {
        return nil;
    }
    return self.device;
}

@end




















