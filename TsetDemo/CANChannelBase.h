//
//  CANChannelBase.h
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "LogcalChanenel.h"
@class Message;
@interface CANChannelBase : LogcalChanenel

@property (nonatomic,strong) NSMutableArray<Message *> *periodicMsgList;

@property (nonatomic,assign) int MaxPeriodicMsg;

- (EpassThruResult)voidateFilter:(EFilterType)type :(PassThruMsg *)maskMsg :(PassThruMsg *)patternMsg :(PassThruMsg *)flowControlMsg;
- (EpassThruResult)open;
- (EpassThruResult)clearPeriodicMsg;
- (EpassThruResult)startPeriodicMsg:(PassThruMsg *)pmsg :(long)timeInterval :(OutObject *)outPeriodicId;
- (EpassThruResult)stopPeriodicMsg:(int)Id;
- (EpassThruResult)stopPeriodicMsgWithMessage:(Message *)msg;
- (int)getNextPeriodicMsgId;


@end






















