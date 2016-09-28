//
//  RxMessage.h
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "LinkMessage.h"
@class NetworkFrame;

typedef NS_ENUM(NSInteger,ERxMessageType){
    DT_CAN_FRAME = 1,//CAN总线数据
    DT_ERRFRAME,//错误帧数据
    DT_FCFRAME,//Flow Control帧数据
    DT_ERRFNOTIE,//错误通知数据
    DT_CMDACK,//命令应答数据
    DT_REQDATA,//重传数据
    DT_K_FRAME,//K总线数据
    DT_BOSH5_3_FRAME,//BOSCH5.3总线数据
    X_DT
};

@interface RxMessage : LinkMessage

@property(nonatomic,strong) NetworkFrame *MsgFrame;
@property(nonatomic,assign) ERxMessageType Type;
@property(nonatomic,assign) int ResponseIdx;
@property(nonatomic,assign) int StartDataIdx;

-(int)getDataSize;

- (BOOL)isValid;



@end
