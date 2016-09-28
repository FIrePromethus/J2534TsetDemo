//
//  ISO15765Filter.m
//  TsetDemo
//
//  Created by chenkai on 16/8/26.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "ISO15765Filter.h"
#import "NetworkFrame.h"
#import "BytesConverter.h"
@implementation ISO15765Filter




- (BOOL)matchWithNet:(NetworkFrame *)canFrame{
    BOOL ok = NO;
    if (self.patternId == canFrame.FrameId || self.flowControlId == canFrame.FrameId) {
        ok = true;
    }
    return ok;
}

- (BOOL)matchWithIdBytes:(Byte *)idBytes{
    BOOL ok = NO;
    int frmId = [[[BytesConverter alloc] init] bytesToInt:idBytes];
    if (self.patternId == frmId || self.flowControlId == frmId) {
        ok = YES;
    }
    return ok;
}

@end

















































