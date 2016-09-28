//
//  SecurityAccessHandler.h
//  TsetDemo
//
//  Created by chenkai on 16/8/25.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "ResponseHandlerBase.h"

@interface SecurityAccessHandler : ResponseHandlerBase


+ (void)setVendorId:(long)venId;

- (void)handle:(RxMessage *)rxMsg;

- (BOOL)canHandle:(RxMessage *)rxMsg;

- (NSMutableData *)getKey;

- (instancetype)initWithBlock:(IResultProcessor)process;

@end
