//
//  IListenner.h
//  TsetDemo
//
//  Created by chenkai on 16/9/6.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"
@protocol IListenner <NSObject>

- (void)listen:(Message *)msg;

@end
