//
//  BytesConverter.m
//  dd
//
//  Created by chenkai on 16/8/16.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "BytesConverter.h"
#import <math.h>
@implementation BytesConverter


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.UTF_8 = @"UTF_8";
    }
    return self;
}

- (NSString *)bytesToHexStr:(NSData *)src{
    if (src == nil || src.length <= 0) {
        return nil;
    }
    Byte *bytes = (Byte *)[src bytes];
    NSString *hexStr = @"";
    for(int i=0;i<[src length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr]; 
    }
    return hexStr;
}


- (NSString *)bytesToHexStrWithByte:(Byte *)src{
    NSString *hexStr = @"";
    NSData *data = [[NSData alloc] initWithBytes:src length:sizeof(src)];
    for(int i=0;i<[data length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",src[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;

}

- (NSString *)bytesToHexStrWithByte:(Byte *)src :(int)startIdx :(int)count{
    NSMutableString *str = [[NSMutableString alloc] init];
    if (src == nil || sizeof(src) <= 0) {
        return nil;
    }
    for (int i = startIdx; i < count; i++) {
        NSString *hv = [self bytesToHexStrWithByte:&src[i]];
        [str appendString:hv];
        [str appendString:@" "];
    }
    return (NSString *)str;
}

- (NSData *)hexStrToBytes:(NSString *)hexString{
    if (!hexString || [hexString length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([hexString length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [hexString length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [hexString substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    
    NSLog(@"hexdata: %@", hexData);
    return hexData;
}

- (Byte *)intToBytes:(int)n{
    Byte byte[4];
    for (int i = 0; i < 4; i++) {
        byte[i] = (0xff & ((n >> (i * 8)) & ((int)(pow(2, 32- i * 8) - 1))));
        
    };
    NSData *data = [NSData dataWithBytes:byte length:4];
    Byte *b = (Byte *)[data bytes];
    return b;
}

- (Byte *)longToBytes:(long)n{
    Byte byte[8];
    for (int i = 0; i < 8; i++) {
        byte[i] = (0xff & ((n >> (i * 8)) & ((long)(pow(2, 32- i * 8) - 1))));
        
    }
     NSData *data = [NSData dataWithBytes:byte length:8];
    NSLog(@"%@",data);
    Byte *b = (Byte *)[data bytes];
    return b;
}

- (int)bytesToInt:(Byte *)source{
    NSLog(@"%d %d %d %d",source[0], source[1], source[2], source[3]);
    int tagets = ((int)source[0] & 0xff) | (((int)source[1] << 8) & 0xff00) | ((((source[2]) << 24) >> 8) & ((int)pow(2, 32-8) - 1)) | (source[3] << 24);
    return tagets;
}

- (Byte *)shortToBytes:(short)n{
    Byte b[2];
    for (int i = 0; i < 2; i++) {
        b[i] = (0xff & ((n >> (i * 8)) & ((short)(pow(2, 32- i * 8) - 1))));
    }
    NSData *data = [NSData dataWithBytes:b length:2];
//    NSLog(@"%ld",data.length);
    Byte *byte = (Byte *)[data bytes];
    return byte;
}

@end


















































