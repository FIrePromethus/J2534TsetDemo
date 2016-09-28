//
//  PhysicalChannel.m
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "PhysicalChannel.h"
#import "LogcalChanenel.h"
#import "PassThruMsg.h"
#import "NetworkFrame.h"
@implementation PhysicalChannel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _pinH = 0;
        _pinL = 0;
        _Baudrate=0;
        _isOpened = false;
        _delegate = nil;
        _Id = 0;
    }
    return self;
}

- (instancetype)initWithPinH:(int)pinh andPinL:(int)pinl andBaud:(int)baud andId:(int)Id andDelegate:(id)delegate{
    self = [super init];
    if (self) {
        _pinH = pinh;
        _pinL = pinl;
        _Baudrate = baud;
        _Id = Id;
        _isOpened = NO;
        _logicChannelList = [[NSMutableArray alloc] init];
        _delegate = delegate;

    }
    return self;
}

- (ElinkResult)open:(EProtocolId)protocolId{
    return 0;
}

- (ElinkResult)close{
    return 0;
}

- (void)registe:(LogcalChanenel *)ch{
    [_logicChannelList addObject:ch];
    ch.phyChannel = self;
}

- (void)unreigister:(LogcalChanenel *)ck{
    [_logicChannelList removeObject:ck];
    ck.phyChannel = nil;
}

- (NSArray<LogcalChanenel *> *)logicalChannels{
    return _logicChannelList;
}

- (BOOL)receiveMsg:(NetworkFrame *)msg{
    if (!_isOpened || msg.ChannelId != _Id) {
        return NO;
    }
    for (LogcalChanenel *ch in _logicChannelList) {
        [ch receiveMsg:msg];
    }
    return YES;
}

- (ElinkResult)sendMsg:(TxMwssage *)txMsg{
    if (_isOpened) {
        return [self.delegate sendTxMwssage:txMsg];
    }else{
        return ChannelNotOpen;
    }
}

- (ElinkResult)sendMsgList:(NSArray<TxMwssage *> *)txMsgList{
    if (_isOpened) {
        return [self.delegate sendDataList:txMsgList];
    }else{
        return ChannelNotOpen;
    }
}

@end






























































