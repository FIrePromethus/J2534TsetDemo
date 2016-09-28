//
//  ISO14230Channel.h
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "ISO914LogicalChannel.h"

@interface ISO14230Channel : ISO914LogicalChannel

@property(nonatomic,assign) long P1_Max;
@property(nonatomic,assign) long P1_Min;
@property(nonatomic,assign) long p2_Max;
@property(nonatomic,assign) long P2_Min;
@property(nonatomic,assign) long P3_Max;
@property(nonatomic,assign) long P3_Min;
@property(nonatomic,assign) long P4_Max;
@property(nonatomic,assign) long P4_Min;
@property(nonatomic,assign) long Tidle;
@property(nonatomic,assign) long Tinil;
@property(nonatomic,assign) long Twup;
@property(nonatomic,assign) long W1;
@property(nonatomic,assign) long W2;
@property(nonatomic,assign) long W3;
@property(nonatomic,assign) long W4;
@property(nonatomic,assign) long W5;
@property(nonatomic,assign) long Parity;
@property(nonatomic,assign) BOOL isDoFastInit;

- (EpassThruResult)open;

@end
