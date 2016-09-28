//
//  VersionHandler.m
//  dd
//
//  Created by chenkai on 16/8/22.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "VersionHandler.h"
#import "RxMessage.h"
#import "LinkProtocol.h"
#import "RunOptions.h"
@implementation VersionHandler

- (BOOL)canHandle:(RxMessage *)rxMsg{
    LinkProtocol *lp = [[LinkProtocol alloc] init];
    if (rxMsg.Type == DT_CMDACK && [rxMsg get:0] == lp.CmdId.Get_Version) {
        return true;
    }
    return false;
}

- (void)handle:(RxMessage *)rxMsg{
    Byte subCmd = [rxMsg get:rxMsg.StartDataIdx];
    LinkProtocol *lp = [[LinkProtocol alloc] init];
    NSMutableString *buf = [[NSMutableString alloc] init];
    int startidx = rxMsg.StartDataIdx + 1;
    if (subCmd == lp.CmdId.SubCmd_Version_SN || subCmd == lp.CmdId.SubCmd_Version_SSID) {
        int len = 10;
        if (subCmd == lp.CmdId.SubCmd_Version_SN && [RunOptions getOEM] == 2) {
            len = 8;
            startidx += 2;
            [buf appendString:@"SAICMVCI"];
        }
        for (int i = startidx; i < len + startidx; ++i) {
            [buf appendFormat:@"%c",(char)[rxMsg get:i]];
        }
    }else if (subCmd == lp.CmdId.SubCmd_Version_SW){
        int len = 8;
        int count = 0;
        for (int i = startidx; i < len + startidx; ++i) {
            [buf appendFormat:@"%c",(char)[rxMsg get:i]];
            count++;
            switch (count) {
                case 2:
                case 4:
                    [buf appendString:@"."];
                    break;
                    
                default:
                    break;
            }
        }
    }else if(subCmd == lp.CmdId.SubCmd_Version_HW){
        int len = 2;
        int count = 0;
        for (int i = startidx; i < len + startidx; ++i) {
            [buf appendFormat:@"%c",(char)[rxMsg get:i]];
            if (count++ == 0) {
                [buf appendString:@"."];
            }
        }
    }else{
        return;
    }
    if (self.process != nil) {
        self.process(buf);
    }
}

@end
























































