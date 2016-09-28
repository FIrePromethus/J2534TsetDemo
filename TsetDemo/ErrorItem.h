//
//  ErrorItem.h
//  dd
//
//  Created by chenkai on 16/8/19.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ErrorItem : NSObject



@property (nonatomic,assign) int Desc;

@property (nonatomic,assign) int Code;

- (ErrorItem *)initWithDesc:(int)desc andCode:(int)code;

- (ErrorItem *)initWithDesc:(int)desc;

@end
