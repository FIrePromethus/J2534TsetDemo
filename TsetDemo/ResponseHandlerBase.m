//
//  ResponseHandlerBase.m
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import "ResponseHandlerBase.h"

@implementation ResponseHandlerBase

- (BOOL)canHandle:(RxMessage *)rxMsg{
    return 0;
}

- (void)handle:(RxMessage *)rxMsg{
    
}

@end
