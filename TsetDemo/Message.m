//
//  Message.m
//  TsetDemo
//
//  Created by chenkai on 16/9/2.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "Message.h"
#import "PassThruMsg.h"
@implementation Message


- (instancetype)init
{
    self = [super init];
    if (self) {
        _PeriodId = -1;
        _PeriodTime = 0;
        _IdType = Bit11;
        _Direction = Tx;
        _frameType = D;
    }
    return self;
}

- (instancetype)initWith:(PassThruMsg *)j2534Msg
{
    self = [super init];
    if (self) {
        _PeriodId = -1;
        _PeriodTime = 0;
        self.Direction = ((j2534Msg.RxStatus & 1) == 1 ? Tx : Rx);
        self.IdType = (j2534Msg.Timestamp / 1000.0);
        Byte *byte = (Byte *)[j2534Msg.Data bytes];
        self.Timespan = ((byte[0] & 0xFF) * 0x1000000 + (byte[1] & 0xFF) * 0x10000 + (byte[2] & 0xFF) * 0x100 +(byte[3] & 0xFF));
        int dataLen = j2534Msg.DataSize - 4;
        int dataIdx = 4;
        self.frameType = (dataLen > 0 ? D : R);
        for (int i = dataIdx; i < dataIdx + dataLen; ++i) {
            
            [_data addObject:[NSData dataWithBytes:&byte[i] length:sizeof(byte[i])]];
        }
    }
    return self;
}

- (NSString *)convertToStr:(NSMutableArray<NSData *> *)data{
    int length = (int)data.count;
    if (length == 0) {
        return nil;
    }
    NSMutableString *builder = [[NSMutableString alloc] init];
    [builder appendString:[NSString stringWithFormat:@"hv %@",data]];
//    for (NSData *d in data) {
//        Byte *b = (Byte *)[d bytes];
#warning ... 有问题
//
//        
//    }
    return builder;
}
#warning ... 没写完
- (BOOL)equals:(id)obj{
    Message *other = (Message *)([obj isKindOfClass:NSClassFromString(@"Message")] ? obj :nil);
    if (other == nil) {
        return NO;
    }
    if (self._Id != other._Id || [self getLength] != [other getLength]) {
        return NO;
    }
    return true;
}

- (NSString *)toString{
    return [self convertToStr:_data];
}

- (Byte)getByte:(int)index{
    if ([self.data count] > index) {
        Byte *byte = (Byte *)[self.data[index] bytes];
        return byte[0];
    }
    return 0;
}



@end




































