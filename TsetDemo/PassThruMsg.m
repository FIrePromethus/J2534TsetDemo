//
//  PassThruMsg.m
//  J2534
//
//  Created by chenkai on 16/8/12.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "PassThruMsg.h"

@implementation PassThruMsg

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.TX_MSG = 0x00000001;
        self.CAN_29BIT_ID = 0x00000100;
        self.TX_INDICATION_DONE = 0x80;
        self.MaxMsgLen = 4128;
        self.ProtocolId = Unknown;
        self.RxStatus = 0;
        self.TxFlags = 0;
        self.Timestamp = 0;
        self.DataSize = 0;
        self.ExtraDataIndex = 0;
        self.Data = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)copyFrom:(PassThruMsg *)other{
    _ProtocolId = other.ProtocolId;
    _RxStatus = other.RxStatus;
    _TxFlags = other.TxFlags;
    _Timestamp = other.Timestamp;
    _DataSize = other.DataSize;
    _ExtraDataIndex = other.ExtraDataIndex;
    _Data = other.Data;
}

- (instancetype)initWithPassThruMsg:(PassThruMsg *)other{
     self = [super init];
    if (self) {
        self.ProtocolId = other.ProtocolId;
        self.RxStatus = other.RxStatus;
        self.TxFlags = other.TxFlags;
        self.Timestamp = other.Timestamp;
        self.DataSize = other.DataSize;
        self.ExtraDataIndex = other.ExtraDataIndex;
        self.Data = [[NSMutableData alloc] init];
        self.Data = other.Data;
    }
    return self;
}

- (instancetype)initWithEprotocolId:(EProtocolId)protocolId :(long)txFlag :(NSMutableData *)data
{
    self = [self init];
    if (self) {
        _ProtocolId = protocolId;
        _TxFlags = txFlag;
        _Data = data;
        _DataSize = (data != nil ? (int)data.length : 0);
    }
    return self;
}

- (BOOL)equal:(id)o{
    if (![o isKindOfClass:[self class]]) {
        NSLog(@"%@%@",[o class],[self class]);
        return NO;
    }
    PassThruMsg *other = o;
    if (self.ProtocolId != other.ProtocolId || self.RxStatus != other.RxStatus || self.Timestamp != other.Timestamp || self.TxFlags != other.TxFlags || self.DataSize != other.DataSize || self.ExtraDataIndex != other.ExtraDataIndex) {
        return NO;
    }
    return [self compareBytes:self.Data :other.Data];
}

- (BOOL)compareBytes:(NSMutableData *)data1 :(NSMutableData *)data2{
    BOOL ok = YES;
    Byte *bytes1 = (Byte *)[data1 bytes];
    Byte *bytes2 = (Byte *)[data2 bytes];
    if (bytes1 == nil || bytes2 == nil) {
        ok = YES;
    }else if(bytes1 == nil || bytes2 == nil || data1.length != data2.length){
        ok = NO;
    }else{
        for (int i = 0; i < data1.length; ++i) {
            if (bytes1[i] != bytes2[i]) {
                ok = NO;
                break;
            }
        }
    }
    return ok;
}

#warning 不会写 hash

//- (int)hashCode{
//    
//}

@end










































