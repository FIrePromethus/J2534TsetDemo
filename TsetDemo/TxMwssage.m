//
//  TxMwssage.m
//  dd
//
//  Created by chenkai on 16/8/16.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "TxMwssage.h"

#import "RunOptions.h"
#import "LinkProtocol.h"

@implementation TxMwssage

- (instancetype)init
{
    self = [super init];
    if (self) {
        LinkProtocol *lp = [[LinkProtocol alloc] init];
        
        self.HeaderOrContent = lp.CMD_HEADER;
        self.TxPackageLen = 10;
        self.Dlc = 0;
    }
    return self;
}

- (NSMutableData *)toBytes{
    if (self.Dlc == 0) {
        
        self.Dlc = [self.dataBuf length];
    }
    
    int len = _TxPackageLen + (int)self.dataBuf.length;
    self.Totallen = (Byte)len;
    NSMutableData *data = [[NSMutableData alloc] init];
    
//    data.length = len;
    
    Byte i = self.FrameStart;
    
    
    [data appendData:[NSData dataWithBytes:&i length:sizeof(i)]];
    Byte t = self.Totallen;
    [data appendData:[NSData dataWithBytes:&t length:sizeof(t)]];
//    RunOptions *runOptions = [[RunOptions alloc] init];
    if ([RunOptions getOEM]== 3) {
        Byte h = self.HeaderOrContent;
        [data appendBytes:&h length:sizeof(h)];
    }else {
        Byte s = self.HeaderOrContent | ((self.FrameStart & 0xFF) + (self.Totallen & 0xFF) & 0xFC);
        [data appendBytes:&s length:sizeof(s)];
    }
    Byte c = self.CmdId;
    [data appendData:[NSData dataWithBytes:&c length:sizeof(c)]];
    Byte dlcH = (Byte)((self.Dlc & 0xFF00) >> 8);
    [data appendData:[NSData dataWithBytes:&dlcH length:sizeof(dlcH)]];
    Byte dlcL = (Byte)(self.Dlc & 0xFF);
    [data appendData:[NSData dataWithBytes:&dlcL length:sizeof(dlcL)]];
    Byte a = self.ASK;
    [data appendData:[NSData dataWithBytes:&a length:sizeof(a)]];
    Byte f = self.FrameEnd;
    [data appendData:self.dataBuf];
    Byte s = self.SequenceNum;
    [data appendBytes:&s length:1];
    Byte ch = self.Checksum;
    [data appendBytes:&ch length:1];
    [data appendData:[NSData dataWithBytes:&f length:1]];
    
    return data;
}

- (BOOL)isValid{
    return false;
}






































@end
