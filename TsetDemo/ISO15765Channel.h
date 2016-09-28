//
//  ISO15765Channel.h
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "CANChannelBase.h"

@interface ISO15765Channel : CANChannelBase


- (instancetype)initWithPinh:(int)pinh :(int)pinl;

- (EpassThruResult)toLinkTxMessage:(PassThruMsg *)pmsg :(NSMutableArray<TxMwssage *> *)outMsgList;

- (EpassThruResult)startMsgFilter:(EFilterType)type :(PassThruMsg *)maskMsg :(PassThruMsg *)patternMsg :(PassThruMsg *)flowControlMsg :(OutObject *)outFilterID;
- (EpassThruResult)stopMsgFilterWithFilter:(Filter *)filter;

- (EpassThruResult)stopMsgFilter:(int)Id;

- (void)receiveMsg:(NetworkFrame *)msg;

//- (EpassThruResult)writeMsg:(PassThruMsg *)msg :(int)timeout;

- (EpassThruResult)readMsgs:(OutObject *)outMsgList :(OutObject *)inOutNum :(int)timeOut;


@end
