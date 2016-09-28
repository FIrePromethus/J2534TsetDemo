//
//  IDataPipe.h
//  TsetDemo
//
//  Created by chenkai on 16/9/1.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NetworkFrame;
@protocol IDataPipe <NSObject>

- (void)transferData:(NetworkFrame *)frm;

@end
