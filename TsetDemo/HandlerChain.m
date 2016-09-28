//
//  HandlerChain.m
//  dd
//
//  Created by chenkai on 16/8/17.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "HandlerChain.h"
#import "ResponseHandlerBase.h"
#import "RunOptions.h"
#import "BytesConverter.h"
#import "RxMessage.h"
@implementation HandlerChain

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.handlerList = [[NSMutableArray alloc] init];
        self.TAG = @"DebugFrame";
    }
    return self;
}

- (void)regist:(ResponseHandlerBase *)handler{
    [_handlerList addObject:handler];
}

- (void)unregist:(ResponseHandlerBase *)handler{
    [_handlerList removeObject:handler];
}

- (void)stop{
    
}


- (void)handle:(RxMessage *)rxMsg{
    BOOL isHandled = false;
    for (ResponseHandlerBase *handler in _handlerList) {
        if ([handler canHandle:rxMsg]) {
            RunOptions *rp = [[RunOptions alloc] init];
            if (rp.IsDebugTrance) {
                NSMutableString *debugMsg = [[NSMutableString alloc] init];
                [debugMsg appendString:@"33333 handle Msg:"];
                BytesConverter *bc = [[BytesConverter alloc] init];
                [debugMsg appendString:[bc bytesToHexStrWithByte:(Byte *)[rxMsg.dataBuf bytes] :0 :(int)rxMsg.dataBuf.length]];
                [debugMsg appendString:@", handler = "];
                [debugMsg appendString:(NSString *)handler];
                NSLog(@"%@%@",self.TAG,debugMsg);
            }
            
            [handler handle:rxMsg];
            isHandled = true;
            break;
        }
    }
    if (!isHandled) {
        Byte b = [rxMsg get:0];
        NSData *data = [NSData dataWithBytes:&b length:sizeof(b)];
        NSLog(@"%@,XXXX Handler skiped msg, type: %d,CmdId = %@",self.TAG,(int)rxMsg.Type,[[[BytesConverter alloc] init] bytesToHexStr:data]);
    }
}



- (void)start{
    
}

@end




























