//
//  ISO15765Param.h
//  TsetDemo
//
//  Created by chenkai on 16/8/26.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISO15765Param : NSObject

@property (nonatomic,assign) Byte TPChannelIndex;
@property (nonatomic,assign) Byte Stmin;
@property(nonatomic,assign) Byte Txmin;
@property(nonatomic,assign) Byte WFTimeout;
@property(nonatomic,assign) short As;
@property(nonatomic,assign) short Ar;
@property(nonatomic,assign) short Bs;
@property(nonatomic,assign) short Br;
@property(nonatomic,assign) short Cs;
@property(nonatomic,assign) short Cr;
@property(nonatomic,assign) short Mod;
@property(nonatomic,assign) short SBS;
@property(nonatomic,assign) int RepId;
@property(nonatomic,assign) int ReqId;
@property(nonatomic,assign) int FunId;

@end






























