//
//  Filter.m
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "Filter.h"
#import "PassThruMsg.h"
#import "BytesConverter.h"
@implementation Filter

- (instancetype)init
{
    self = [super init];
    if (self) {
        _Id = -1;
        _maskMsg = [[PassThruMsg alloc] init];
        _patterMsg = [[PassThruMsg alloc] init];
        _flowControlMsg = [[PassThruMsg alloc] init];
        _patternId = 0;
        _flowControlId = 0;
        _maskId = 0;
    }
    return self;
}

- (instancetype)initWith:(EFilterType)type
{
    self = [self init];
    if (self) {
        _Id = -1;
        _maskMsg = [[PassThruMsg alloc] init];
        _patterMsg = [[PassThruMsg alloc] init];
        _flowControlMsg = [[PassThruMsg alloc] init];
        _patternId = 0;
        _flowControlId = 0;
        _maskId = 0;
        _type = type;
    }
    return self;
}


- (void)setMaskMsg:(PassThruMsg *)maskMsg{
    _maskMsg = maskMsg;
    
    int len = (int)maskMsg.Data.length;
    Byte *byte = (Byte *)[[self.maskMsg Data] bytes];
    NSMutableData *data = [[NSMutableData alloc] init];
    for (int i = len - 1; i >= 0; --i) {
        [data appendBytes:&byte[i] length:sizeof(byte[i])];
    }
    
    _maskId = [[[BytesConverter alloc] init] bytesToInt:(Byte *)[data bytes]];
}

- (void)setPatterMsg:(PassThruMsg *)patterMsg{
    _patterMsg = patterMsg;
    int len = (int)patterMsg.Data.length;
    Byte *byte = (Byte *)[self.patterMsg.Data bytes];
    NSMutableData *data = [[NSMutableData alloc] init];
    for (int i = len - 1; i >= 0; --i) {
        [data appendBytes:&byte[i] length:sizeof(byte[i])];
    }
    _patternId = [[[BytesConverter alloc] init] bytesToInt:(Byte *)[data bytes]];
    
}

- (void)setFlowControlMsg:(PassThruMsg *)flowControlMsg{
    _flowControlMsg = flowControlMsg;
    int len = (int)flowControlMsg.Data.length;
    Byte *byte = (Byte *)[self.flowControlMsg.Data bytes];
    NSMutableData *data = [[NSMutableData alloc] init];
    for (int i = len - 1; i >= 0; --i) {
        [data appendBytes:&byte[i] length:1];
    }
    _flowControlId = [[[BytesConverter alloc] init] bytesToInt:(Byte *)[data bytes]];
}

- (BOOL)matchWithNet:(NetworkFrame *)canFrame{
    return NO;
}
- (BOOL)matchWithIdBytes:(Byte *)idBytes{
    return NO;
}

@end


















































