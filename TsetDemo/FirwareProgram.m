//
//  FirwareProgram.m
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "FirwareProgram.h"
#import "HandlerChain.h"
#import "TxMwssage.h"
#import "LinkProtocol.h"
#import "RxMessage.h"
@implementation FirwareProgram

- (instancetype)initWithLinker:(id<Linker>)linker
{
    self = [super init];
    if (self) {
        CmdMessage cmdMsg = {nil,nil,0};
        self.currentCmd = cmdMsg;
        self.ErrParseFileFailed = 1;
        self.ErrDeviceNotOpened = 2;
        self.ErrRequestDownloadFailed = 3;
        self.ErrEraseBlockFailed = 4;
        self.ErrDownLoadBlockFailed = 5;
        self.ErrValidataFailed = 6;
        self.TAG = @"DebugFrame";
        self.dataSize = 0;
        self.currentProcess = 0;
        self.process = nil;
        self.linker = linker;
        self.p2 = 5000;
        self.p2Star = 15000;
        self.NegtiveResponse = 0x7F;
        self.Pending = 0x78;
        self.SidIndex = 1;
       
        self.requestData = nil;
        
    }
    return self;
}

- (int)doProgram:(NSString *)filePath :(id<IProgress>)progress{
    if (_linker == nil || ![_linker isConnected]) {
        return self.ErrDeviceNotOpened;
    }
    _delegate = progress;
    if (![self preProgram:filePath]) {
        return self.ErrParseFileFailed;
    }
    int i = [self programInternal];
    [self postProgram];
    return i;
}

- (BOOL)preProgram:(NSString *)filePath{
    _currentProcess = 0;
    _dataSize = 0;
    [[_linker getChain] regist:self];
    NSLog(@"%@%@",self.TAG,[NSString stringWithFormat:@"Start parse file:  %@",filePath]);
#warning ... 少东西
    
    
    return true;
}

- (int)programInternal{
    Byte s1002[] = {0x10,0x02};
    
    CmdMessage cmd = [self requst:[NSMutableData dataWithBytes:s1002 length:sizeof(s1002)]];
    if (cmd.ResponseState != 1) {
        return self.ErrRequestDownloadFailed;
    }
#warning .. 少东西没写完
    int packageSize = 200;
    int sendedCount = 0;
    
    return 0;
}

- (NSMutableData *)toBytes:(NSMutableArray<NSData *> *)list{
    NSMutableData *buffer = [[NSMutableData alloc] init];
    for (NSData *data in list) {
        [buffer appendData:data];
    }
    return buffer;
}

- (CmdMessage)requst:(NSMutableData *)data{
    CmdMessage cmdMsg = {nil,nil,0};
    _currentCmd = cmdMsg;
    Byte byte[data.length + 1];
    byte[0] = 0x01;
    int sid = 0;
    int postiveResponse = 0;
    Byte *byte1 = (Byte *)[data bytes];
    int idx = _SidIndex;
    for (int i = 0; i < data.length; i++) {
        byte[idx++] = byte1[i];
    }
    _requestData = [NSMutableData dataWithBytes:byte length:sizeof(byte)];
    BOOL ok = [self writeMsg:_requestData];
    if (!ok) {
        return _currentCmd;
    }
    int timeCouter = 0;
    int timeOut = _p2;
    
    BOOL isTxDone = false;
    do {
        long firstTime = (long)[NSDate date];
        @try {
            [NSThread sleepForTimeInterval:5/1000];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
        }
        if (!isTxDone && _currentCmd.Request != nil) {
            timeCouter = 0;
            isTxDone = true;
        }
        int resId = 0;
        if (isTxDone && _currentCmd.Response != nil && _currentCmd.Response[0] == 0x09) {
            resId = _currentCmd.Response[_SidIndex] & 0xFF;
        }
        if (isTxDone && resId == postiveResponse) {
            _currentCmd.ResponseState = 1;
            break;
        }else if(isTxDone && resId == _NegtiveResponse && sid == (_currentCmd.Response[_SidIndex + 1] & 0xFF)){
            if ((_currentCmd.Response[_SidIndex + 2] & 0xFF) == _Pending) {
                _currentCmd.Response = nil;
                timeOut = _p2Star;
                timeCouter = 0;
            }else{
                _currentCmd.ResponseState = 2;
                break;
            }
        }else if (isTxDone){
            _currentCmd.Response = nil;
        }
#warning ... 获取系统时间 
        long elaspeTime;
        timeCouter += elaspeTime;
    } while (timeOut > timeCouter && _currentCmd.Response == nil);
    return _currentCmd;
}

- (BOOL)writeMsg:(NSMutableData *)data{
    TxMwssage *frame = [[TxMwssage alloc] init];
    frame.CmdId = [[LinkProtocol alloc] init].CmdId.ProgramCmd;
    frame.ASK = ASK_NEED;
    [frame appendDataWithData:data];
    return [_linker sendTxMwssage:frame] == NoError;
}

- (BOOL)postProgram{
    [[_linker getChain] unregist:self];
    _dataSize = 0;
    _delegate = nil;
#warning ... 没写完
    
    return true;
}

- (void)setCurrentProcess:(int)currentProcess{
    int val = ((double)currentProcess / (double)_dataSize*100);
    NSLog(@"%@,CurrentProcess = %d",self.TAG, val);
    if (val != _currentProcess) {
        _currentProcess = val;
        if (self.process != nil) {
            self.process([NSNumber numberWithInt:_currentProcess]);
        }
    }
}

- (BOOL)canHandle:(RxMessage *)rxMsg{
    if (rxMsg.Type == DT_CMDACK && [rxMsg get:0] == [[LinkProtocol alloc] init].CmdId.ProgramCmd) {
        return true;
    }
    return false;
}

- (void)handle:(RxMessage *)rxMsg{
    Byte responseCode = [rxMsg get:rxMsg.ResponseIdx];
    if (responseCode == 0x00) {
        _currentCmd.Request = (Byte *)[self.requestData bytes];
    }
    int len = [rxMsg getDataSize];
    if (len > 1) {
        Byte byte[len];
        _currentCmd.Response = byte;
        for (int i = 0, dataIdx = rxMsg.StartDataIdx; i < len; i++,dataIdx++) {
            _currentCmd.Response[i] = [rxMsg get:dataIdx];
        }
    }
}

@end













































