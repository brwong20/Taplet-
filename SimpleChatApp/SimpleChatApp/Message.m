//
//  Message.m
//  SimpleChatApp
//
//  Created by Brian Wong on 11/3/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//

#import "Message.h"

@interface Message()


@end

@implementation Message

-(instancetype)initWith:(NSString*)date message:(NSString*)message image:(UIImage *)image{
    self = [super init];
    if(self){
        self.date = date;
        self.message = message;
        self.image = image;
    }
    return self;
}

@end

