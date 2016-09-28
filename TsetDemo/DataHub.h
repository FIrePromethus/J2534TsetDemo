//
//  DataHub.h
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IListenner.h"
#import "IDataHub.h"
@class PassThruMsg,LogcalChanenel,Device;

@interface FramePair : NSObject

@property (nonatomic,strong) PassThruMsg *Msg;
@property (nonatomic,strong) LogcalChanenel *Chanel;

- (instancetype)initWith:(PassThruMsg *)msg :(LogcalChanenel *)ch;

@end

@interface DataHub : NSObject<IDataHub>

@property (nonatomic,strong) NSMutableArray<id<IListenner>> *listenerColl;

@property (nonatomic,strong) Device *device;

@property (nonatomic,copy) NSString *TAG;

@property (nonatomic,strong) NSMutableArray<FramePair *> *buffer;

@property (nonatomic,assign) BOOL isDispatching;

- (instancetype)initWith:(Device *)device;



- (void)transmit:(PassThruMsg *)msg :(LogcalChanenel *)channel;

@end
























