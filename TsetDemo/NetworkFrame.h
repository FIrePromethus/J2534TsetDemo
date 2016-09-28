//
//  NetworkFrame.h
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkFrame : NSObject
//TP帧标记为
@property(nonatomic,assign) int TPFRAMEFLAG;
//紧急帧标记位
@property(nonatomic,assign) int EMEFLAG;
//小标记位
@property(nonatomic,assign) int ENDFLAG;
//发送帧标记位
@property(nonatomic,assign) int DIRFLAG;
//远程帧标记位
@property(nonatomic,assign) int REMFRAMEFLAG;
//扩展帧标记位
@property(nonatomic,assign) int EXTFRAMEFLAG;
//时间戳需要与CAN总线波特率进行位时间运算（可能会溢出 循环使用）
@property(nonatomic,assign) int TimeStamp;
@property(nonatomic,assign) int TimeStampCycle;
//物理通道号
@property(nonatomic,assign) int ChannelId;
//数据长度
@property(nonatomic,assign) int DataLen;
//功能关键字| * * TP Eme| End Dir RTR IDE|
@property(nonatomic,assign) int Option;
//帧ID
@property(nonatomic,assign) int FrameId;
@property(nonatomic,strong) NSMutableData *FrameIdButes;
//帧数据 数据大小依据于DataLength，如果DataLength = 0则该数据无效
@property(nonatomic,strong) NSMutableData  *Data;



@end
