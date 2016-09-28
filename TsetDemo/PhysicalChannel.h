//
//  PhysicalChannel.h
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "ResponseHandlerBase.h"
#import "Device.h"
#import "J2534.h"
@class LogcalChanenel, DataLinker;
@interface PhysicalChannel : NSObject

@property (nonatomic,assign) int pinH;

@property (nonatomic,assign) int pinL;

@property (nonatomic,assign) long Baudrate;

@property (nonatomic,assign) BOOL isOpened;

@property (nonatomic,assign) id<Linker>delegate;

@property (nonatomic,strong) NSMutableArray<LogcalChanenel *> *logicChannelList;

@property (nonatomic,assign) int Id;

- (instancetype)initWithPinH:(int)pinh andPinL:(int)pinl andBaud:(int)baud andId:(int)Id andDelegate:(id)delegate;

- (ElinkResult)close;

- (ElinkResult)open:(EProtocolId)protocolId;

- (void)registe:(LogcalChanenel *)ch;

- (void)unreigister:(LogcalChanenel *)ck;

- (NSArray<LogcalChanenel *> *)logicalChannels;

- (BOOL)receiveMsg:(NetworkFrame *)msg;

- (ElinkResult)sendMsg:(TxMwssage*)txMsg;

- (ElinkResult)sendMsgList:(NSArray<TxMwssage *> *)txMsgList;




@end









































