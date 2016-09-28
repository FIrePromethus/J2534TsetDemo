//
//  FirwareProgram.h
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "ResponseHandlerBase.h"
#import "IProgress.h"
#import "Device.h"

typedef struct CmdMessage{
    Byte *Request;
    Byte *Response;
    int ResponseState;
}CmdMessage;
@interface FirwareProgram : ResponseHandlerBase

@property (nonatomic,assign) int ErrParseFileFailed;
@property (nonatomic,assign) int ErrDeviceNotOpened;
@property (nonatomic,assign) int ErrRequestDownloadFailed;
@property (nonatomic,assign) int ErrEraseBlockFailed;
@property (nonatomic,assign) int ErrDownLoadBlockFailed;
@property (nonatomic,assign) int ErrValidataFailed;
@property (nonatomic,assign) NSString *TAG;

@property (nonatomic,assign) int dataSize;
@property (nonatomic,assign) int currentProcess;
@property (nonatomic,assign) id<IProgress> delegate;
@property (nonatomic,assign) id<Linker> linker;
@property (nonatomic,assign) int p2;
@property (nonatomic,assign) int p2Star;
@property (nonatomic,assign) int NegtiveResponse;
@property (nonatomic,assign) int Pending;
@property (nonatomic,assign) int SidIndex;
@property(nonatomic,assign) CmdMessage currentCmd;
@property(nonatomic,assign) NSMutableData *requestData;
#warning 。。。 少一个BinCoder

-(instancetype)initWithLinker:(id<Linker>)linker;

- (int)doProgram:(NSString *)filePath :(id<IProgress>)progress;

- (BOOL)preProgram:(NSString *)filePath;

- (int)programInternal;

- (NSMutableData *)toBytes:(NSMutableArray<NSData *> *)list;

- (CmdMessage)requst:(NSMutableData *)data;

- (BOOL)writeMsg:(NSMutableData *)data;

- (BOOL)postProgram;

- (void)setCurrentProcess:(int)currentProcess;

- (void)handle:(RxMessage *)rxMsg;

@end









































