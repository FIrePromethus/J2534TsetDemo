//
//  PassThruMsg.h
//  J2534
//
//  Created by chenkai on 16/8/12.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "J2534.h"
@class J2534;
@interface PassThruMsg : NSObject

@property (nonatomic,assign) int TX_MSG;
@property (nonatomic,assign) int CAN_29BIT_ID;
@property (nonatomic,assign) int TX_INDICATION_DONE;
@property (nonatomic,assign) int MaxMsgLen;
@property (nonatomic,assign) EProtocolId ProtocolId;
@property (nonatomic) long RxStatus;
@property (nonatomic) long TxFlags;
@property (nonatomic) long Timestamp;
@property (nonatomic) int DataSize;
@property (nonatomic) long ExtraDataIndex;
@property (nonatomic, strong) NSMutableData *Data;

- (instancetype)initWithPassThruMsg:(PassThruMsg *)other;

- (instancetype)initWithEprotocolId:(EProtocolId)protocolId :(long)txFlag :(NSMutableData *)data;
- (void)copyFrom:(PassThruMsg *)other;

- (BOOL)equal:(id)o;

- (BOOL)compareBytes:(NSMutableData *)data1 :(NSMutableData *)data2;

- (int)hashCode;



@end









































