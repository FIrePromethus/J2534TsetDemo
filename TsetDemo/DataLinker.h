//
//  DataLinker.h
//  dd
//
//  Created by chenkai on 16/8/15.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Device.h"
#import "IDataPipe.h"
#import "SocketManger.h"
@class SocketManger,HandlerChain;


//BOOL isWaiting = false;

@interface DataLinker : NSObject<Linker,IDataReciver>
@property (nonatomic,copy) NSString *flagStr;
@property (nonatomic,strong) NSNumber *volStr;
@property (nonatomic,strong) NSMutableData *RxBuffer;

@property (nonatomic,strong) SocketManger *commsMgr;

@property (nonatomic,assign) short txNCountter;

@property (nonatomic,copy) NSString *TAG;

@property (nonatomic,strong) HandlerChain *chain;

@property (nonatomic,assign) long lastDataTime;

@property (nonatomic,copy) NSString *serialNum; 

@property (nonatomic,copy) NSString *firmware;

- (instancetype)initWithDelegate:(id<IDataPipe>)delegate;

- (void)appendRxData:(NSData *)data :(int)count;

- (void)startSendHeartFrame;

- (ElinkResult)sendData:(NSData *)data;

- (ElinkResult)writeToBuffer:(NSData *)data;

- (ElinkResult)flush;

- (void)waitForResponse;

- (void)stopWait;





- (ElinkResult)writeSN;














@end























