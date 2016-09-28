//
//  KPhyChannel.h
//  dd
//
//  Created by chenkai on 16/8/22.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "PhysicalChannel.h"

@interface KPhyChannel : PhysicalChannel

- (ElinkResult)open:(EProtocolId)protocolId;

- (ElinkResult)close;




@end





























