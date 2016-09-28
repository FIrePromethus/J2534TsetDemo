//
//  VoltageHandler.h
//  TsetDemo
//
//  Created by chenkai on 16/9/1.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "ResponseHandlerBase.h"

@interface VoltageHandler : ResponseHandlerBase

- (BOOL)canHandle:(RxMessage *)rxMsg;

- (void)handle:(RxMessage *)rxMsg;

@end
