//
//  SocketManger.h
//  dd
//
//  Created by chenkai on 16/8/17.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "GCDAsyncSocket.h"
@class DataLinker;
@protocol IDataReciver <NSObject>

- (void)processRxData:(NSData *)data :(int)dataLen;

@end

typedef BOOL(^BLOCK)(BOOL);

@interface SocketManger : NSObject <GCDAsyncSocketDelegate>
@property (nonatomic,strong) GCDAsyncSocket *socket;
@property (nonatomic,copy)NSString *TAG;
@property (nonatomic,assign) BOOL isConnecte;
@property (nonatomic,copy) NSString *Ip;
@property (nonatomic,assign)UInt16 Port;
@property (nonatomic,assign) int scketTimeOut;
@property (nonatomic,copy) BLOCK blck;

@property (nonatomic,assign) id<IDataReciver> datareceive;
@property (nonatomic,strong) NSData *finishData;


+(SocketManger *)sharedInstanceWithDelegate:(id<IDataReciver>)delegate;

- (BOOL)sendHeartbeatData:(NSData *)data;

- (BOOL)sendData:(NSData *)data;

- (BOOL)isConneted;

- (BOOL)connect;

- (BOOL)disConnect;

- (BOOL)writeToBuffer:(NSData *)data;

- (BOOL)flush;

@end

























