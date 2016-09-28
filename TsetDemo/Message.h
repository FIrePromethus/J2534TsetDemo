//
//  Message.h
//  TsetDemo
//
//  Created by chenkai on 16/9/2.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(int,EMessageId){
    Bit11 = 0,
    Bit29 = 1
};
typedef NS_ENUM(int,EDirection){
    Tx = 0,
    Rx = 1
};
typedef NS_ENUM(int,EMessageType){
    D = 0,
    R = 1
};
@class LogcalChanenel,PassThruMsg;
@interface Message : NSObject
@property (nonatomic,assign) int _Id;
@property (nonatomic,strong) NSMutableArray<NSData *> *data;
@property (nonatomic,assign) int PeriodId;
@property (nonatomic,assign) long PeriodTime;
@property (nonatomic,assign) EMessageId IdType;
@property (nonatomic,strong) LogcalChanenel *Channel;
@property (nonatomic,assign) double Timespan;
@property (nonatomic,assign) EDirection Direction;
@property (nonatomic,assign) EMessageType frameType;

- (instancetype)initWith:(PassThruMsg *)j2534Msg;

- (NSString *)convertToStr:(NSMutableArray<NSData *> *)data;

- (BOOL)equals:(id)obj;

- (Byte)getByte:(int)index;

- (int)getLength;

- (PassThruMsg *)GetData;

- (NSString *)toString;

@end
























































