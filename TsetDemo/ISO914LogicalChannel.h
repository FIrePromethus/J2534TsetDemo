//
//  ISO914LogicalChannel.h
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "LogcalChanenel.h"

@interface ISO914LogicalChannel : LogcalChanenel


- (EpassThruResult)fastInit:(PassThruMsg *)inMsg :(PassThruMsg *)outMsg;

- (EpassThruResult)fiveBaudInit;

@end
