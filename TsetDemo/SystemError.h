//
//  SystemError.h
//  dd
//
//  Created by chenkai on 16/8/19.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ErrorItem;
@interface SystemError : NSObject

@property (nonatomic,strong) ErrorItem *ErrInvalidPhyChannel;

@property (nonatomic,assign) int LastError;

@property (nonatomic,assign) int errCode;

- (void)setLastError:(int)LastError :(int)code;

- (void)setLastError1:(ErrorItem *)err;


@end
