//
//  RunOptions.h
//  dd
//
//  Created by chenkai on 16/8/16.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RunOptions : NSObject

@property(nonatomic,assign) BOOL IsDebugTrance;
@property(nonatomic,assign) BOOL IsDebugWriteSocket;
@property(nonatomic,assign) BOOL IsDebugReadSocket;

@property(nonatomic,assign) int CANChannelCount;
@property(nonatomic,assign) NSString * JarVersion;
@property(nonatomic,assign) NSString * ApiVersion;

+ (void)setOEM:(int)a;

+ (int)getOEM;

@end
