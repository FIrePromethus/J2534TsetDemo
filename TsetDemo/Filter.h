//
//  Filter.h
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "J2534.h"
@class PassThruMsg,NetworkFrame;
@interface Filter : NSObject

@property (nonatomic,assign) int Id;
@property (nonatomic,strong) PassThruMsg *maskMsg;
@property (nonatomic,strong) PassThruMsg *patterMsg;
@property (nonatomic,strong) PassThruMsg *flowControlMsg;
@property (nonatomic, assign) EFilterType type;
@property (nonatomic,assign) int patternId;
@property(nonatomic,assign) int flowControlId;
@property(nonatomic,assign) int maskId;


- (instancetype)initWith:(EFilterType)type;

- (BOOL)matchWithNet:(NetworkFrame *)canFrame;

- (BOOL)matchWithIdBytes:(Byte *)idBytes;


@end










































