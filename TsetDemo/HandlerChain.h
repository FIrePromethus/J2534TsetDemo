//
//  HandlerChain.h
//  dd
//
//  Created by chenkai on 16/8/17.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ResponseHandlerBase,RxMessage;

@interface HandlerChain : NSObject
@property(nonatomic,strong) NSMutableArray<ResponseHandlerBase *> *handlerList;
@property(nonatomic,copy) NSString *TAG;
- (void)stop;
- (void)start;
- (void)regist:(ResponseHandlerBase *)handler;
- (void)unregist:(ResponseHandlerBase *)handler;



- (void)handle:(RxMessage *)rxMsg;

@end
