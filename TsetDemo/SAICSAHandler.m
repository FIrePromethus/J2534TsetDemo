//
//  SAICSAHandler.m
//  TsetDemo
//
//  Created by chenkai on 16/9/1.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "SAICSAHandler.h"
#import "RxMessage.h"
#import "LinkProtocol.h"
#import "SAEncoder.h"
#import "OutObject.h"
@implementation SAICSAHandler

- (BOOL)canHandle:(RxMessage *)rxMsg{
    LinkProtocol *lp = [[LinkProtocol alloc] init];
    if (rxMsg.Type == DT_CMDACK && [rxMsg get:0] == lp.CmdId.Compute_SAIC_SA) {
        return true;
    }
    return false;
}

- (void)handle:(RxMessage *)rxMsg{
    int len = (int)rxMsg.dataBuf.length;
    Byte responseCode = [rxMsg get:rxMsg.ResponseIdx];
    if (responseCode != 0x00) {
        if (self.process != nil) {
            self.process(nil);
        }
        return;
    }
    NSMutableArray *keyArray = [[NSMutableArray alloc] init];
    for (int i = rxMsg.StartDataIdx; i < len; ++i) {
        Byte b = [rxMsg get:i];
        NSData *data = [NSData dataWithBytes:&b length:sizeof(b)];
        [keyArray addObject:data];
    }
    NSMutableData *decodeKey = [[NSMutableData alloc] init];
    int idx = 0;
    for (NSData *b in keyArray) {
        idx++;
        [decodeKey appendData:b];
    }
    int n = (int)decodeKey.length;
    
    SAEncoder *sa = [[SAEncoder alloc] init];
    OutObject *obj = [[OutObject alloc] init];
    [sa decode:decodeKey :obj];
    Byte *temKeys = (Byte *)[obj.obj bytes];
    Byte outKeys[decodeKey.length];
    idx = 0;
    for (int i = n - 1; i >= 0; --i) {
        outKeys[idx++] = temKeys[i];
    }
    if (self.process != nil) {
        NSData *data = [NSData dataWithBytes:outKeys length:sizeof(outKeys)];
        self.process(data);
    }
}

@end



































