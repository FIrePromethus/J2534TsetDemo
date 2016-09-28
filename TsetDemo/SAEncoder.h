//
//  SAEncoder.h
//  TsetDemo
//
//  Created by chenkai on 16/9/1.
//  Copyright © 2016年 陈凯. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OutObject;

@interface SAEncoder : NSObject

- (void)encode:(NSMutableData *)src :(OutObject *)dest;
- (void)decode:(NSMutableData *)src :(OutObject *)dest;

@end
