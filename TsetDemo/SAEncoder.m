//
//  SAEncoder.m
//  TsetDemo
//
//  Created by chenkai on 16/9/1.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "SAEncoder.h"
#import "OutObject.h"
@implementation SAEncoder

- (void)encode:(NSMutableData *)src :(OutObject *)dest{
    Byte temp = 0xFF;
   
    if (src == nil || src.length == 0) {
        return;
    }
    
    int srcLen = (int)src.length;
    Byte des[srcLen];
    Byte *sr = (Byte *)[src bytes];
    for (int i = 0; i < srcLen; i++) {
        des[srcLen - 1 - i] = sr[srcLen - 1 - i] ^ temp;
        temp = des[srcLen - 1 - i];
    }
    dest.obj = [NSMutableData dataWithBytes:des length:sizeof(des)];
}

- (void)decode:(NSMutableData *)src :(OutObject *)dest{
    Byte temp = 0xFF;
    int srclen = (int)src.length;
    if (src == nil || srclen == 0) {
        return;
    }
    int i = 0;
    Byte *sr = (Byte *)[src bytes];
    Byte des[srclen];
    for (i = 0; i < srclen - 1; i++) {
        des[i] = sr[i] ^ sr[i + 1];
    }
    des[i] = sr[i] ^ temp;
    dest.obj = [NSMutableData dataWithBytes:des length:srclen];
}

@end


































