//
//  Children.h
//  KVCODemo
//
//  Created by Brian Wong on 11/3/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Children : NSObject

@property(nonatomic,strong) NSString *name;
@property(nonatomic) NSUInteger age;
@property(nonatomic,strong) Children *child;

@end
