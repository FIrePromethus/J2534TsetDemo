//
//  ISO15765Filter.h
//  TsetDemo
//
//  Created by chenkai on 16/8/26.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "Filter.h"
@class ISO15765Param;
@interface ISO15765Filter : Filter

@property (nonatomic,strong) PassThruMsg *DiagFrameBuilder;
@property (nonatomic,strong) NSMutableArray<NSData *> *DiagFrameBuf;
@property (nonatomic,strong) ISO15765Param *TPParam;



@end
