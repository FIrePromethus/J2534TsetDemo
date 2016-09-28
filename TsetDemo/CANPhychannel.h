//
//  CANPhychannel.h
//  dd
//
//  Created by chenkai on 16/8/22.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "PhysicalChannel.h"

@interface CANPhychannel : PhysicalChannel
@property (nonatomic,assign) Byte PR;
@property(nonatomic,assign) Byte PS1;
@property(nonatomic,assign) Byte PS2;
@property(nonatomic,assign) Byte RJ;
@property(nonatomic,assign) Byte DIV;

- (instancetype)initWithPinH:(int)pinh andPinL:(int)pinl andBaud:(int)baud andId:(int)Id andDelegate:(id)delegate;

- (ElinkResult)open:(EProtocolId)protocolId;
@end
