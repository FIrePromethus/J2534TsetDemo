//
//  LinkMessage.h
//  dd
//
//  Created by chenkai on 16/8/15.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LinkProtocol;
@interface LinkMessage : NSObject

@property(nonatomic,assign) Byte FrameStart;

@property(nonatomic,assign) Byte FrameEnd;

@property(nonatomic,strong) NSMutableData * dataBuf;

@property(nonatomic,assign) Byte CmdId;

@property(nonatomic,assign) Byte ASK;

@property(nonatomic,assign) Byte Totallen;

@property(nonatomic,assign) Byte Checksum;

@property(nonatomic,assign) Byte SequenceNum;

- (void)appendDataWithData:(NSData *)data;

- (void)appendData:(Byte)data;
- (Byte)get:(int)idx;


@end
