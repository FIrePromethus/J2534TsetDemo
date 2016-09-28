//
//  BOSCH5_3FrameHamdler.h
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "ResponseHandlerBase.h"
#import "IDataPipe.h"
@interface BOSCH5_3FrameHamdler : ResponseHandlerBase

@property (nonatomic,copy) NSString *TAG;
@property (nonatomic,assign) id<IDataPipe> delegate;

- (instancetype)initWithDelegate:(id<IDataPipe>)delegate;

- (BOOL)canHandle:(RxMessage *)rxMsg;

-(void)handle:(RxMessage *)rxMsg;

@end
