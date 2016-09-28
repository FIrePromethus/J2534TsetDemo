//
//  DataLinker.m
//  dd
//
//  Created by chenkai on 16/8/15.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "DataLinker.h"
#import "SocketManger.h"
#import "HandlerChain.h"
#import "LinkProtocol.h"
#import "VersionHandler.h"
#import "RunOptions.h"
#import "SecurityAccessHandler.h"
#import "LinkProtocol.h"
#import "BytesConverter.h"
#import "RxMessage.h"
#import "VoltageHandler.h"
#import "TxMwssage.h"
#import "SAICSAHandler.h"
#import "CANFrameHandler.h"
#import "KFrameHandler.h"
#import "BOSCH5_3FrameHamdler.h"
#import "OutObject.h"
@implementation DataLinker
BOOL _isSecurityAccessOK = NO;

BOOL _isWaiting;
NSString * _serialNum;
NSString * _firmwareVer = @"";
NSData * keyArray;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.RxBuffer = [[NSMutableData alloc] init];
        self.commsMgr = [SocketManger sharedInstanceWithDelegate:self];
        
        self.TAG = @"DebugFrame";
        self.txNCountter = 0x00;

        self.chain = [[HandlerChain alloc] init];
        _firmware = @"";
        
        self.lastDataTime = 0;
        _isWaiting = NO;
        _serialNum = @"";
        self.serialNum = @"";
    }
    return self;
}

- (instancetype)initWithDelegate:(id<IDataPipe>)delegate
{
    self = [super init];
    if (self) {
        self.RxBuffer = [[NSMutableData alloc] init];
        self.commsMgr = [SocketManger sharedInstanceWithDelegate:self];
        _commsMgr.datareceive = self;
        self.TAG = @"DebugFrame";
        self.txNCountter = 0x00;
        _firmware = @"";
        self.chain = [[HandlerChain alloc] init];
        
        
        self.lastDataTime = 0;
        _isWaiting = NO;
        _serialNum = @"";
        self.serialNum = @"";
        [_chain regist:[[CANFrameHandler alloc] initWithDelegate:delegate]];
        [_chain regist:[[KFrameHandler alloc] initWith:delegate]];
        [_chain regist:[[BOSCH5_3FrameHamdler alloc] initWithDelegate:delegate]];
    }
    return self;
}

- (void)setVendorId:(long)vendorId{
    [SecurityAccessHandler setVendorId:vendorId];
    
}

- (void)appendRxData:(NSData *)data :(int)count{
    Byte *bytes = (Byte *)[data bytes];
    for (int i = 0; i < count; i++) {
        [self.RxBuffer appendBytes:&bytes[i] length:sizeof(bytes[i])];
    }
}

- (void)startSendHeartFrame{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self run];
    });
}


- (ElinkResult)sendData:(NSData *)data{
    if (!_commsMgr.isConnecte) {
        return SocketNotConnected;
    }
    if (data == nil || data.length == 0) {
        return NullParameter;
    }
    BOOL ok = [self.commsMgr sendData:data];
    self.lastDataTime = [[NSDate date] timeIntervalSince1970]*1000;
    return ok ? NoError :SocketSendFailed;
}

- (ElinkResult)writeToBuffer:(NSData *)data{
    if (![self.commsMgr isConneted]) {
        return SocketNotConnected;
    }
    if (data == nil || data.length == 0) {
        return NullParameter;
    }
    BOOL ok = [self.commsMgr sendData:data];
    self.lastDataTime = [[NSDate date] timeIntervalSince1970]*1000;
    return ok ? NoError : SocketNotConnected;
}


- (ElinkResult)flush{
    if (![self.commsMgr isConneted]) {
        return SocketNotConnected;
    }
    
    BOOL ok = [self.commsMgr flush];
    self.lastDataTime = [[NSDate date] timeIntervalSince1970]*1000;
    return ok ? NoError : SocketNotConnected;
}

- (void)waitForResponse{
    int count = 0;
    _isWaiting = YES;
    while (count <= 5000 && _isWaiting) {
        count += 5;
        @try {
            [NSThread sleepForTimeInterval:0.005];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
        }
        @finally {
            
        }
        
    }
}


- (void)stopWait{
    _isWaiting = false;
}

- (void)processRxData:(NSData *)data :(int)dataLen{
    [self appendRxData:data :dataLen];
    while (YES) {
        @try {
            if (self.RxBuffer.length == 0) {
                return;
            }
            Byte *byte = (Byte *)[_RxBuffer bytes];
            Byte firstByte = byte[0];
            LinkProtocol *lp = [[LinkProtocol alloc] init];
            if (firstByte != lp.FrameStart) {
                NSMutableString *debugMsg = [NSMutableString stringWithString:@"XXXXX Invalid messges removed: \n"];
                Byte start = 0;
                do{
                    byte = (Byte *)[_RxBuffer bytes];
                    start = byte[0];
                    if (start != lp.FrameStart) {
                        [_RxBuffer replaceBytesInRange:NSMakeRange(0, 1) withBytes:NULL length:0];
                    }else{
                        break;
                    }
                    [debugMsg appendString:[[[BytesConverter alloc] init] bytesToHexStr:[NSData dataWithBytes:&start length:sizeof(start)]]];
                    [debugMsg appendString:@" "];
                }while (true);
                
                NSLog(@"%@%@",self.TAG, debugMsg);
            }
            RxMessage *rxmsg = [[RxMessage alloc] init];
            int idx = 0;
            int len = 0;
            Boolean isFinish = false;
            for ( ; idx < _RxBuffer.length; idx++) {
                Byte b = byte[idx];
                if (len == 0 || (len > 0 && idx < len)) {
                    if (idx == 0) {
                        rxmsg.FrameStart = b;
                    }else if(idx == 1){
                        rxmsg.Totallen = b;
                        len = b & 0xFF;
                        if (len > _RxBuffer.length) {
                            break;
                        }
                    }else if(idx == 2){
                        rxmsg.Type = b & 0xFF;
                    }else if(idx == len - 3){
                        rxmsg.SequenceNum = b;
                    }else if(idx == len - 2){
                        rxmsg.Checksum = b;
                    }else if (idx == len - 1){
                        rxmsg.FrameEnd = b;
                        isFinish = true;
                    }else {
                        [rxmsg appendData:b];
                    }
                }
            }
            NSLog(@"rxmsgdata=======%@", rxmsg.dataBuf);
            if (!isFinish) {
                return;
            }
            if ([rxmsg isValid]) {
                RunOptions *rp = [[RunOptions alloc] init];
                if (rp.IsDebugTrance) {
                    NSMutableString *debugMsg = [[NSMutableString alloc] init];
                    [debugMsg appendString:@"22222 dataLink Msg:"];
                    [debugMsg appendString:[[[BytesConverter alloc]init] bytesToHexStrWithByte:(Byte *)[rxmsg.dataBuf bytes] :0 :(int)rxmsg.dataBuf.length]];
                    NSLog(@"%@%@",self.TAG,debugMsg);
                }
                [self.chain handle:rxmsg];
                idx = 0;
                while (idx++ < len) {
                    
                    [_RxBuffer replaceBytesInRange:NSMakeRange(0, 1) withBytes:NULL length:0];
                }
                
            }else{
                Byte *byte1 = (Byte *)[_RxBuffer bytes];
                Byte b = byte1[0];
              
                [_RxBuffer replaceBytesInRange:NSMakeRange(0, 1) withBytes:NULL length:0];
                NSLog(@"%@,XXXXX RemoveFirstByte: %@", self.TAG, [[[BytesConverter alloc] init] bytesToHexStr:[NSData dataWithBytes:&b length:sizeof(b)]]);
            }
        }
        
        @catch (NSException *exception) {
            NSLog(@"%@,DataLinker process data error: %@", self.TAG, exception);
        }
        @finally {
            
        }
    
    }
}



- (ElinkResult)readSN:(NSString *)outsn{
    if (![_serialNum isEqualToString:@""]) {
        outsn = _serialNum;
        return NoError;
    }
    
    NSData *cmd = [[[LinkProtocol alloc] init] getReadSNMsg:[self getSN]];
    VersionHandler *snHandler = [[VersionHandler alloc] init];
#warning Block ？;
    snHandler.process = ^(NSString *result){
        _serialNum = result;
        __block outsn = _serialNum;
        [self stopWait];
    };
    [_chain regist:snHandler];
    ElinkResult result = [self sendData:cmd];
    if (result == NoError) {
        [self waitForResponse];
        [_chain unregist:snHandler];
    }else{
        [_chain unregist:snHandler];
        return result;
    }
    return outsn == nil || [outsn isEqualToString:@""] ? Timeout : result;
}

- (ElinkResult)readFirmwareVersion:(OutObject *)outVersion{
    NSLog(@"%@",_firmware);
    if (![_firmware isEqualToString:@""]) {
        outVersion.obj = [NSString stringWithString:_firmware];
        return NoError;
    }
    NSData *cmd = [[[LinkProtocol alloc] init] getreadFirmwareMsg:[self getSN]];
    VersionHandler *handler = [[VersionHandler alloc] init];
    handler.process = ^(NSString *result){
        _firmwareVer = result;
        _flagStr = _firmwareVer;
        [self stopWait];
    };
    [_chain regist:handler];
    ElinkResult result = [self sendData:cmd];
    if (result == NoError) {
        [self waitForResponse];
        outVersion.obj = _flagStr;
        [_chain unregist:handler];
    }else{
        [_chain unregist:handler];
        return result;
    }
    return outVersion == nil || [outVersion.obj isEqualToString:@""]?Timeout : result;
}

- (ElinkResult)writeSN{
    return NotSupport;
}

- (BOOL)securityAccess{
    if (![_commsMgr isConneted]) {
        return NO;
    }
    LinkProtocol *lp = [[LinkProtocol alloc] init];
    NSData *cmd = [lp getVCISeed:[self getSN]];
    SecurityAccessHandler *saHandler = [[SecurityAccessHandler alloc] init];
    saHandler.process = ^(NSNumber *isOK){
        _isSecurityAccessOK = [isOK boolValue];
        [self stopWait];
        
    };
    [_chain regist:saHandler];
    ElinkResult linkRet = [self sendData:cmd];
    if (linkRet == NoError) {
        [self waitForResponse];
        if (_isSecurityAccessOK) {
          
            
            NSMutableData *data = [saHandler getKey];
            int a = (int)data.length;
            cmd = [lp getVCIKey:[self getSN] :data];
            Byte *cm = (Byte *)[cmd bytes];
            for (int i = 0; i < cmd.length; i++) {
                NSLog(@"%d",cm[i]);
            }
            linkRet = [self sendData:cmd];
            if (linkRet == NoError) {
                _isSecurityAccessOK = NO;
                [self waitForResponse];
            }else{
                _isSecurityAccessOK = NO;
            }
        }
    }else{
        _isSecurityAccessOK = NO;
    }
    [_chain unregist:saHandler];
//    _isSecurityAccessOK = YES;
    return _isSecurityAccessOK;
}

- (ElinkResult)connet{
    if (_commsMgr.isConnecte) {
        return NoError;
    }
    [_RxBuffer setLength:0];
    BOOL ok = [_commsMgr connect];
    if (ok) {
        [self.chain start];
        ok = [self securityAccess];
        if (!ok) {
            [self disconnect];
        }else {
            
            if ([RunOptions getOEM] != 3) {
                [self startSendHeartFrame];
            }
        }
    }
    return ok ? NoError : SocketNotConnected;
}

- (ElinkResult)disconnect{
    if (!_commsMgr.isConnecte) {
        return NoError;
    }
    LinkProtocol *lp = [[LinkProtocol alloc] init];
    NSData *stopCmd = [lp getStopMsg:[self getSN]];
    [self sendData:stopCmd];
    BOOL ok = [_commsMgr disConnect];
    [self.chain stop];
    _serialNum = @"";
    _firmware = @"";
    _isSecurityAccessOK = NO;
    return ok ? NoError : SocketSendFailed;
}

- (void)run{
    while ([self isConnected]) {
        
        @try {
            NSTimeInterval time = [[NSDate date] timeIntervalSince1970]*1000;
            if ((time - self.lastDataTime) >= 5000) {
                LinkProtocol *protocol = [[LinkProtocol alloc] init];
                NSData *data = [protocol getHeartFrame:[self getSN]];
                [self.commsMgr sendHeartbeatData:data];

            }
            [NSThread sleepForTimeInterval:1];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
        }
        @finally {
            
        }
    }
}

- (ElinkResult)openCANChannel:(NSMutableArray<NSData *> *)chOptionList{
    LinkProtocol *lp = [[LinkProtocol alloc] init];
    if (chOptionList == nil || chOptionList.count != lp.MaxCANPhyChannel) {
        return NullParameter;
    }
    for (NSData *arr in chOptionList) {
        if (arr == nil || arr.length != lp.CANParamCount) {
            return NullParameter;
        }
    }
    NSData *cmd = [lp getOpenCanChannelMsg:[self getSN] :chOptionList];
    return [self sendData:cmd];
}

- (ElinkResult)closeCANChannel:(NSData *)options{
    LinkProtocol *lp = [[LinkProtocol alloc] init];
    if (options == nil || options.length != lp.MaxCANPhyChannel) {
        return NullParameter;
    }
    NSData *cmd = [lp getCloseCANChannelMsg:[self getSN] :options];
    return [self sendData:cmd];
}



- (BOOL)isConnected{
    return _commsMgr.isConnecte;
}

- (Byte)getSN{
    self.txNCountter++;
    
    return (Byte)self.txNCountter;
}
#warning 没写完 没写完
- (ElinkResult)readVoltage:(NSNumber *)outVol{
    LinkProtocol *lp = [[LinkProtocol alloc] init];
    NSData *cmd = [lp getVoltageMsg:[self getSN]];
    VoltageHandler *handler = [[VoltageHandler alloc] init];
    handler.process = ^(NSNumber *result){
        __block outVol = result ;
        [self stopWait];
    };
    [_chain regist:handler];
    ElinkResult result = [self sendData:cmd];
    if (result == NoError) {
        [self waitForResponse];
        [_chain unregist:handler];
    }else{
        [_chain unregist:handler];
        return result;
    }
    return outVol == nil || [outVol doubleValue] == 0.0 ? Timeout : result;
}

- (ElinkResult)sendTxMwssage:(TxMwssage *)data{
    data.SequenceNum = [self getSN];
    return [self sendData:[data toBytes]];
}

- (ElinkResult)computeSA:(long)vendorCode :(short)alg :(NSMutableData *)seeds :(OutObject *)outKeys{
    LinkProtocol *lp = [[LinkProtocol alloc] init];
    NSData *cmd = [lp getSAICSARequest:[self getSN] :vendorCode :alg :seeds];
    SAICSAHandler *handler = [[SAICSAHandler alloc] init];
    handler.process = ^(NSData *result){
        keyArray = result;
        [self stopWait];
    };
    [_chain regist:handler];
    ElinkResult result = [self sendData:cmd];
    outKeys.obj = [[NSMutableData alloc] init];
    if (result == NoError) {
        [self waitForResponse];
        [_chain unregist:handler];
        if (keyArray == nil) {
            return Timeout;
        }
        [(NSMutableData *)outKeys.obj appendData:keyArray];
        keyArray = nil;
        return NoError;
    }else{
        [_chain unregist:handler];
        keyArray = nil;
        return result;
    }
}

- (ElinkResult)openKChennel:(int)baud{
    NSData *data = [[[LinkProtocol alloc] init] getStartKline:[self getSN] :baud];
    return [self sendData:data];
}

- (ElinkResult)closeKChannel{
    LinkProtocol *lp = [[LinkProtocol alloc] init];
    NSData *data = [lp getStopKLine:[self getSN]];
    return [self sendData:data];
}

- (ElinkResult)openBOSCH5_3Channel:(Byte)target{
    NSData *cmd = [[[LinkProtocol alloc] init] getStartBOSCH5_3Channel:[self getSN] :target];
    return [self sendData:cmd];
}

- (ElinkResult)closeBOSCH5_3Channel{
    NSData *data = [[[LinkProtocol alloc] init] getStopBOSCH5_3Channel:[self getSN]];
    return [self sendData:data];
}

- (ElinkResult)sendDataList:(NSArray<TxMwssage *> *)dataColl{
    ElinkResult result = NullParameter;
    if (dataColl == nil) {
        return result;
    }
    for (TxMwssage *msg in dataColl) {
        msg.SequenceNum = [self getSN];
        result = [self writeToBuffer:[msg toBytes]];
        if (result != NoError) {
            break;
        }
    }
    if (result == NoError) {
        result = [self flush];
    }
    return  result;
}

- (HandlerChain *)getChain{
    return _chain;
}

- (ElinkResult)restoreFirmware{
    NSData *cmd = [[[LinkProtocol alloc] init] getRestoreFirmwareFrame:[self getSN]];
    return [self sendData:cmd];
}

- (ElinkResult)changeMode:(int)mode{
    NSData *data = [[[LinkProtocol alloc] init] getModeMsg:[self getSN] :mode];
    return [self sendData:data];
}

@end







































