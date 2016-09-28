//
//  DataHub.m
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "DataHub.h"

@implementation FramePair

- (instancetype)initWith:(PassThruMsg *)msg :(LogcalChanenel *)ch
{
    self = [super init];
    if (self) {
        _Msg = msg;
        _Chanel = ch;
    }
    return self;
}

@end

@implementation DataHub

- (instancetype)initWith:(Device *)device
{
    self = [super init];
    if (self) {
        _listenerColl = [[NSMutableArray alloc] init];
        _device = device;
        _TAG = @"DataHub";
        _buffer = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void)addListner:(id<IListenner>)listner{
    [_listenerColl addObject:listner];
}

- (void)removeListnner:(id<IListenner>)listner{
    [_listenerColl removeObject:listner];
}

- (BOOL)isDispatching{
    return _isDispatching;
}

- (void)transmit:(PassThruMsg *)msg :(LogcalChanenel *)channel{
    if (_isDispatching) {
        @synchronized(_buffer) {
            FramePair *frm = [[FramePair alloc] initWith:msg :channel];
            [_buffer addObject:frm];
        }
    }
}

- (BOOL)startDispatch{
    if (_isDispatching) {
        return YES;
    }
    _isDispatching = YES;
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        while (_isDispatching) {
            @try {
                while (_buffer.count > 0) {
                    @synchronized(_buffer) {
                        FramePair *frm = _buffer[0];
                        [_buffer removeObjectAtIndex:0];
                        if (_listenerColl.count <= 0) {
                            continue;
                        }
                        for (id<IListenner> l in _listenerColl) {
                            if (!_isDispatching) {
                                break;
                            }
                            @try {
                                Message *msg = [[Message alloc] initWith:frm.Msg];
                                [msg setChannel:frm.Chanel];
                                [l listen:msg];
                            }
                            @catch (NSException *exception) {
                                NSLog(@"%@%@.listen()error:%@", _TAG, l, exception);
                            }
                        }
                    }
                }
                [NSThread sleepForTimeInterval:10/1000];
            }
            @catch (NSException *exception) {
                _isDispatching = NO;
                NSLog(@"%@StartDispatch error: %@", _TAG, exception);
            }
        }
       
    });
    return true;
}

- (void)stopDispatch{
    _isDispatching = NO;
}

@end














