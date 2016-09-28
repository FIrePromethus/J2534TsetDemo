//
//  BOSCH5_3PhyChannel.h
//  dd
//
//  Created by chenkai on 16/8/22.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "PhysicalChannel.h"

@interface BOSCH5_3PhyChannel : PhysicalChannel

@property (nonatomic,assign) Byte Target;

- (instancetype)initWithId:(int)Id andDelegate:(id<Linker>)delegate;

- (ElinkResult)open:(EProtocolId)protocolId;

- (ElinkResult)close;

@end
