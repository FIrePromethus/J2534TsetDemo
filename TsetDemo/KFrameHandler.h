//
//  KFrameHandler.h
//  TsetDemo
//
//  Created by chenkai on 16/9/1.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "ResponseHandlerBase.h"
#import "IDataPipe.h"
@interface KFrameHandler : ResponseHandlerBase

@property (nonatomic,assign) id<IDataPipe> delegate;

- (instancetype)initWith:(id<IDataPipe>)delegate;

- (BOOL)canHandle:(RxMessage *)rxMsg;

-(void)handle:(RxMessage *)rxMsg;

@end
