//
//  LinkMessage.m
//  dd
//
//  Created by chenkai on 16/8/15.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "LinkMessage.h"
#import "LinkProtocol.h"
@implementation LinkMessage


- (instancetype)init
{
    self = [super init];
    if (self) {
        LinkProtocol *linkProtocol = [[LinkProtocol alloc] init];
        self.FrameStart = linkProtocol.FrameStart;
        self.FrameEnd = linkProtocol.FrameEnd;
        self.CmdId = linkProtocol.CmdId.UNKNOWN;
        self.ASK = ASK_NO;
        self.Totallen = 0x00;
        self.Checksum = 0x00;
        self.SequenceNum = 0x00;
        self.dataBuf = [[NSMutableData alloc] init];
//        self.dataBuf.length = 64;
    }
    return self;
}

- (void)appendDataWithData:(NSData *)data{
    [self.dataBuf appendData:data];
}

- (void)appendData:(Byte)data{

    [self.dataBuf appendData:[NSMutableData dataWithBytes:&data length:1]];
    
}

- (Byte)get:(int)idx{
    Byte *bytes = (Byte *)[self.dataBuf bytes];
    return bytes[idx];
}

@end






















