//
//  CANFrameHandler.h
//  TsetDemo
//
//  Created by chenkai on 16/9/1.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "ResponseHandlerBase.h"
#import "IDataPipe.h"
@interface CANFrameHandler : ResponseHandlerBase

@property (nonatomic,copy)NSString *TAG;
@property (nonatomic,assign) id<IDataPipe> delegate;

- (instancetype)initWithDelegate:(id<IDataPipe>)delegate;

- (void)handle:(RxMessage *)rxMsg;

- (BOOL)canHandle:(RxMessage *)rxMsg;



@end









































































