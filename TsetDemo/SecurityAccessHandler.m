//
//  SecurityAccessHandler.m
//  TsetDemo
//
//  Created by chenkai on 16/8/25.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "SecurityAccessHandler.h"
#import "RxMessage.h"
#import "LinkProtocol.h"
#import "BytesConverter.h"

@implementation SecurityAccessHandler
{
    BOOL _isSeedOk;
    BOOL _isKeyOk;
    Byte *_seedBytes;
    NSMutableData *_keyBytes;
    
}
static long venDorId;
- (instancetype)init
{
    self = [super init];
    if (self) {
        _isSeedOk = NO;
        _isKeyOk = NO;
        Byte byte[8];
        _seedBytes = byte;
        _keyBytes = nil;
        
    }
    return self;
}

- (instancetype)initWithBlock:(IResultProcessor)process{
    self = [super init];
    if (self) {
        _isSeedOk = NO;
        _isKeyOk = NO;
        Byte byte[8];
        _seedBytes = byte;
        _keyBytes = [[NSMutableData alloc] init];
        self.process = process;
    }
    return self;
}

+ (void)setVendorId:(long)venId{
    venDorId = venId;
    
}

- (BOOL)canHandle:(RxMessage *)rxMsg{
    LinkProtocol *lp = [[LinkProtocol alloc] init];
    if (rxMsg.Type == DT_CMDACK && [rxMsg get:0] == lp.CmdId.VCI_SA) {
        return YES;
    }
    
    return NO;
}

- (void)handle:(RxMessage *)rxMsg{
    int startIdx = [rxMsg StartDataIdx];
    Byte subCmd = [rxMsg get:startIdx];
    Byte responserCode = [rxMsg get:rxMsg.ResponseIdx];
    if (responserCode != 0x00) {
        [self process:NO];
        return;
    }
    LinkProtocol *lp = [[LinkProtocol alloc] init];
    if (subCmd == lp.CmdId.SubCmd_VCI_SA_GetSeed) {
        _isSeedOk = YES;
        _seedBytes[3] = [rxMsg get:startIdx + 1];
        _seedBytes[2] = [rxMsg get:startIdx + 2];
        _seedBytes[1] = [rxMsg get:startIdx + 3];
        _seedBytes[0] = [rxMsg get:startIdx + 4];
        
        BytesConverter *bc = [[BytesConverter alloc] init];
        long seed = [bc bytesToInt:_seedBytes];
        long key = [self calcKey:seed :venDorId];
        Byte *keys = [[[BytesConverter alloc] init] longToBytes:key];
        Byte by[4] = {keys[3],keys[2],keys[1],keys[0]};
        NSLog(@"key的值 =-= %d,%d,%d,%d",keys[0],keys[1],keys[2],keys[3]);
        _keyBytes = [NSMutableData dataWithBytes:by length:4];
        NSLog(@"%@",_keyBytes);
        [self process:_isSeedOk];
    }else if(subCmd == lp.CmdId.SubCmd_VCT_SA_ValidateKey){
        _isKeyOk = _isSeedOk;
        [self process:_isKeyOk];
    }
}

- (void)process:(BOOL)result{
    if (self.process != nil) {
        
        self.process([NSNumber numberWithBool:result]);
    }
}

- (NSMutableData *)getKey{
    return _keyBytes;
}


- (long)calcKey:(long)seed :(long)security_constant{
    long wLastSeed;
    long wTemp = 0;
    long wLSBit;
    long wTop31Bits;
    Byte SB1,SB2,SB3;
    int temp;
    wLastSeed = seed;
    temp = (int)((long)(((security_constant & 0x00000800L >> 10) | (security_constant & 0x00200000L) >> 21)));
    switch (temp) {
        case 0:
            wTemp = (Byte)((seed & 0xff000000L) >> 24);
            break;
        case 1:
            wTemp = (Byte)((seed & 0x00ff0000L) >> 16);
            break;
        case 2:
            wTemp = (Byte)((seed & 0x0000ff00L) >> 8);
            break;
        case 3:
            wTemp = (Byte)seed & 0x000000ffL;
            break;
        default:
            break;
    }
    SB1 = (Byte)((security_constant & 0x000001FEL) >> 2);
    SB2 = (Byte)(((security_constant & 0x3FC00000L) >> 23) ^ 0xA5);
    SB3 = (Byte)(((security_constant & 0x007F8000L) >> 13) ^ 0x5A);
    int iterations = (int)((((wTemp ^ SB1) & SB2) + SB3) & 0xFF);
    for (int jj = 0; jj < iterations; jj++) {
        wTemp = ((wLastSeed & 0x40000000L) / 0x40000000L)
                ^ ((wLastSeed & 0x01000000L) / 0x01000000L)
                ^ ((wLastSeed & 0x1000L) / 0x1000L)
                ^ ((wLastSeed & 0x04L) / 0x04L);
        wLSBit = (wTemp & 0x00000001L);
        wLastSeed = (long)(wLastSeed << 1);
        wTop31Bits = (long)(wLastSeed & 0xFFFFFFFEL);
        wLastSeed = (long)(wTop31Bits | wLSBit);
    }
    if (0x00000001L == (security_constant & 0x00000001L)) {
        wTop31Bits = ((wLastSeed & 0x00FF0000L) >> 16)
        | ((wLastSeed & 0xFF000000L) >> 8)
        | ((wLastSeed & 0x000000FFL) << 8)
        | ((wLastSeed & 0x0000FF00L) << 16);
    }else {
        wTop31Bits = wLastSeed;
    }
    wTop31Bits = wTop31Bits ^ security_constant;
    return (wTop31Bits);
}

@end



















































