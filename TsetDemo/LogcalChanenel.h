//
//  LogcalChanenel.h
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "J2534.h"
@class PassThruMsg,PhysicalChannel,DataHub,Filter,NetworkFrame,TxMwssage,PassThruConfig
;
@interface LogcalChanenel : NSObject

@property(nonatomic,assign) int Id;
@property(nonatomic,assign) int IdCounter;
@property(nonatomic,strong) NSMutableArray<PassThruMsg *> * receiveBuffer;
@property(nonatomic,strong) PhysicalChannel *phyChannel;
@property(nonatomic,assign) EProtocolId protocolId;
@property(nonatomic,assign) int pinH;
@property(nonatomic,assign) int pinL;
@property(nonatomic,assign) long baudtate;
@property(nonatomic,strong) NSMutableArray<Filter *> *fillterColl;
@property(nonatomic,assign) BOOL isLoopback;
@property(nonatomic,strong) DataHub *dataHub;
@property(nonatomic,assign) BOOL isTransmitOnly;
@property(nonatomic,copy) NSString *TAG;
@property(nonatomic,strong) PassThruMsg *txMsg;
@property(nonatomic,strong) NSObject *syncTxobj;



- (EpassThruResult)open;

- (EpassThruResult)close;

- (void)receiveMsg:(NetworkFrame *)msg;

- (void)addToBuffer:(PassThruMsg *)rxMsg;

- (EpassThruResult)readMsgs:(OutObject *)outMsgList :(OutObject *)inOutNum :(int)timeOut;

- (PassThruMsg *)toRxPassThruMsg:(NetworkFrame *)rawMsg;

- (EpassThruResult)validateMsg:(PassThruMsg *)pmg;

- (EpassThruResult)writeMsg:(PassThruMsg *)msg :(int)timeout;

- (EpassThruResult)toLinkTxMessage:(PassThruMsg *)pmsg :(NSMutableArray<TxMwssage *> *)outMsgList;

- (EpassThruResult)setParameter;

- (EpassThruResult)clearRxBuffer;

- (EpassThruResult)clearFilter;

- (EpassThruResult)clearPeriodicMsg;

- (EpassThruResult)startMsgFilter:(EFilterType)type :(PassThruMsg *)maskMsg :(PassThruMsg *)patternMsg :(PassThruMsg *)flowControlMsg :(OutObject *)outFilterID;

- (EpassThruResult)voidateFilter:(EFilterType)type :(PassThruMsg *)maskMsg :(PassThruMsg *)patternMsg :(PassThruMsg *)flowControlMsg;

- (EpassThruResult)stopMsgFilter:(int)Id;

- (EpassThruResult)stopMsgFilterWithFilter:(Filter *)filter;

- (EpassThruResult)startPeriodicMsg:(PassThruMsg *)pmsg :(long)timeInterval :(OutObject *)outPeriodicId;

- (EpassThruResult)stopPeriodicMsg:(int)Id;

- (EpassThruResult)validateParm:(PassThruConfig *)cfg;


- (EpassThruResult)setParam:(PassThruConfig *)inCfg;

- (EpassThruResult)getParam:(PassThruConfig *)outCfg;

- (BOOL)isOpend;

+ (DataHub *)getDataHub;

+ (void)setDataHun:(DataHub *)dataHub;



@end
