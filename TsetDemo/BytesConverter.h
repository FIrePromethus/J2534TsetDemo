//
//  BytesConverter.h
//  dd
//
//  Created by chenkai on 16/8/16.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BytesConverter : NSObject

@property(nonatomic,copy) NSString *UTF_8;

- (NSString *)bytesToHexStr:(NSData *)src;
- (NSString *)bytesToHexStrWithByte:(Byte *)src;

- (NSString *)bytesToHexStrWithByte:(Byte *)src :(int)startIdx :(int)count;

- (NSData *)hexStrToBytes:(NSString *)hexString;

- (int)bytesToInt:(Byte *)source;

- (Byte *)intToBytes:(int)n;
- (Byte *)longToBytes:(long)n;
- (Byte *)shortToBytes:(short)n;

@end
























