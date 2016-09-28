//
//  CANLogalChannel.h
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "CANChannelBase.h"

@interface CANLogalChannel :CANChannelBase

- (instancetype)init;

- (instancetype)initWithPin:(int)pinH :(int)pinL;
- (EpassThruResult)toLinkTxMessage:(PassThruMsg *)pmsg :(NSMutableArray<TxMwssage *> *)outMsgList;
- (EpassThruResult)startMsgFilter:(EFilterType)type :(PassThruMsg *)maskMsg :(PassThruMsg *)patternMsg :(PassThruMsg *)flowControlMsg :(OutObject *)outFilterID;

- (EpassThruResult)stopMsgFilterWithFilter:(Filter *)filter;

@end





































