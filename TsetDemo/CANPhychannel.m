//
//  CANPhychannel.m
//  dd
//
//  Created by chenkai on 16/8/22.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "CANPhychannel.h"
#import "RunOptions.h"
#import "LinkProtocol.h"

@implementation CANPhychannel
- (instancetype)initWithPinH:(int)pinh andPinL:(int)pinl andBaud:(int)baud andId:(int)Id andDelegate:(id)delegate
{
    self = [super initWithPinH:pinh andPinL:pinl andBaud:baud andId:Id andDelegate:delegate];
    if (self) {
        _PR = 0x03;
        _PS1 = 0x06;
        _PS2 = 0x03;
        _RJ = 0x00;
        _DIV = 0x00;
    }
    return self;
}

- (ElinkResult)open:(EProtocolId)protocolId{
    if (self.isOpened) {
        return NoError;
    }
    
    ElinkResult result = [self calcBaudrateParam];
    if (result != NoError) {
        return result;
    }
    Byte by[5];
    
    NSMutableData *ch = [[NSMutableData alloc] initWithBytes:by length:5];
//    RunOptions *rop = [[RunOptions alloc] init];
    if ([RunOptions getOEM] == 1) {
        if (protocolId == CAN || protocolId == CAN_PS) {
            Byte bytes[6] = {0x80, _PR, _PS1, _PS2, _RJ, _DIV};
            ch = [[NSMutableData alloc] init];
            [ch appendBytes:bytes length:6];
            
        }else if (protocolId == ISO15765 || protocolId == ISO15765_PS){
            Byte bytes[6] = {0x01,_PR,_PS1,_PS2,_RJ,_DIV};
            ch = [NSMutableData dataWithBytes:bytes length:6];
        }
    }else if ([RunOptions getOEM] == 3){
        Byte bytes[6] = {0x01, _PR, _PS1, _PS2, _RJ, _DIV};
        ch = [[NSMutableData alloc]initWithBytes:bytes length:6];
    }
    LinkProtocol *lp = [[LinkProtocol alloc] init];
    
    Byte empty[lp.CANParamCount];
        
    NSMutableData *data = [NSMutableData dataWithBytes:empty length:lp.CANParamCount];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < lp.MaxCANPhyChannel; ++i) {
        if (i == self.Id) {
            [array addObject:ch];
        }else{
            [array addObject:data];
        }
    }
    result = [self.delegate openCANChannel:array];
    if (result == NoError) {
        self.isOpened = YES;
    }
    return result;
}

- (ElinkResult)close{
    if (!self.isOpened) {
        return NoError;
    }
    if ([self.logicChannelList count] > 0) {
        return ChannelInUse;
    }
    LinkProtocol *lp = [[LinkProtocol alloc] init];
    Byte bytes[lp.MaxCANPhyChannel];
    for (int i = 0; i < lp.MaxCANPhyChannel; ++i) {
        if (i == self.Id) {
            bytes[i] = 0x01;
        }else{
            bytes[i] = 0x00;
        }
    }
    ElinkResult result = [self.delegate closeCANChannel:[NSData dataWithBytes:bytes length:lp.MaxCANPhyChannel]];
    if (result == NoError) {
        self.isOpened = NO;
    }
    return result;
}

- (ElinkResult)calcBaudrateParam{
    switch (self.Baudrate) {
        case 500000:
            _PR = 0x03;
            _PS1 = 0x06;
            _PS2 = 0x03;
            _RJ = 0x00;
            _DIV = 0x00;
            break;
        case 250000:
            _PR = 0x03;
            _PS1 = 0x06;
            _PS2 = 0x03;
            _RJ = 0x00;
            _DIV = 0x01;
            break;
        case 125000:
            _PR = 0x03;
            _PS1 = 0x06;
            _PS2 = 0x03;
            _RJ = 0x00;
            _DIV = 0x03;
            break;
        default:
            return NotSupport;
            break;
    }
    return NoError;
}


@end
