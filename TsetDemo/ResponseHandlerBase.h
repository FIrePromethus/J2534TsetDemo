//
//  ResponseHandlerBase.h
//  dd
//
//  Created by chenkai on 16/8/18.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^IResultProcessor)(id);

@class RxMessage,NetworkFrame;

@interface ResponseHandlerBase : NSObject;

@property(nonatomic,copy) IResultProcessor process;

- (BOOL)canHandle:(RxMessage *)rxMsg;

- (void)handle:(RxMessage *)rxMsg;



@end




































