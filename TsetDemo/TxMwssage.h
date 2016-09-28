//
//  TxMwssage.h
//  dd
//
//  Created by chenkai on 16/8/16.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "LinkMessage.h"

@interface TxMwssage : LinkMessage

@property (nonatomic,assign) Byte HeaderOrContent;
@property (nonatomic,assign) int TxPackageLen;
@property (nonatomic,assign) NSUInteger Dlc;

- (NSData *)toBytes;

@end
