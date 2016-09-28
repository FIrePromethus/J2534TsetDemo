//
//  SocketManger.m
//  dd
//
//  Created by chenkai on 16/8/17.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "SocketManger.h"
#import "J2534.h"
#import "AsyncSocket.h"
#import "BytesConverter.h"
#import "GCDAsyncSocket.h"
@implementation SocketManger
{
    BOOL _isWrited;

}

+ (SocketManger *)sharedInstanceWithDelegate:(id<IDataReciver>)delegate{
    static SocketManger *manger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manger = [[self alloc] init];
        manger.isConnecte = NO;
        manger.Ip = @"192.168.5.1";
        manger.Port = 6666;
        Byte b = 0xAA;
        manger.finishData = [NSData dataWithBytes:&b length:1];
        manger.datareceive = delegate;
    });
    return manger;
}

- (BOOL)writeToBuffer:(NSData *)data{
    [self.socket writeData:data withTimeout:-1 tag:0];
    
    
    return YES;
}

- (BOOL)flush{
    return YES;
}

- (BOOL)connect{
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    
    
        NSError *error = nil;
    
        [self.socket connectToHost:self.Ip onPort:self.Port error:&error];
  
    
    

    NSDate *startData = [NSDate date];
    NSTimeInterval start = [startData timeIntervalSince1970];
    
    while (_isConnecte != YES) {
        NSDate *endData = [NSDate date];
        NSTimeInterval end = [endData timeIntervalSince1970];
        if ((end - start) >= 4.8) {
            _isConnecte = NO;
            [self.socket disconnect];
            break;
        }
    }
    
    
    
   
    return _isConnecte;
}



- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"连接成功");
    _isConnecte = YES;
    
    

}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"读取完成");

    NSLog(@"%@",data);

    [self.datareceive processRxData:data :(int)data.length];
    

    
}



- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"写入完成");
    if (tag != 0) {
        [self.socket readDataWithTimeout:-1 tag:tag];
    }
    
    _isWrited = YES;
}


- (BOOL)isConneted{
    return _isConnecte;
}


- (BOOL)disConnect{
    [self.socket disconnect];
    _isConnecte = NO;
    NSLog(@"socket已经断开");
    return YES;
}


- (BOOL)sendHeartbeatData:(NSData *)data{
    BOOL result = NO;
    BytesConverter *BC =  [[BytesConverter alloc]init];
    
    [BC bytesToHexStr:data];
    
    static int tag = 0;
    tag++;
    NSLog(@"%@",[BC bytesToHexStr:data]);
    [self.socket writeData:data withTimeout:4.8 tag:0];
    while (!_isWrited) {
        
    }
    _isWrited = NO;
    result = YES;
    return result;
}


- (BOOL)sendData:(NSData *)data{
    BOOL result = NO;

    BytesConverter *BC =  [[BytesConverter alloc]init];
    
    [BC bytesToHexStr:data];
    
    static int tag = 0;
    tag++;
    NSLog(@"%@",[BC bytesToHexStr:data]);
    [self.socket writeData:data withTimeout:4.8 tag:tag];
    while (!_isWrited) {
        
    }
    _isWrited = NO;
    result = YES;
    return result;
}

@end




































