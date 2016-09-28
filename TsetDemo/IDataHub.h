//
//  IDataHub.h
//  TsetDemo
//
//  Created by chenkai on 16/9/6.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IListenner.h"

@protocol IDataHub <NSObject>

- (void)addListner:(id<IListenner>)listner;

- (void)removeListnner:(id<IListenner>)listner;

- (BOOL)isDispatching;

- (BOOL)startDispatch;

- (void)stopDispatch;

@end
