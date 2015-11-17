//
//  Message.h
//  SimpleChatApp
//
//  Created by Brian Wong on 11/3/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Message : NSObject

@property (nonatomic,strong)NSString* date;
@property (nonatomic,strong)NSString* message;
@property (nonatomic,strong)UIImage* image;
-(instancetype)initWith:(NSString*)date message:(NSString*)message image:(UIImage*)image;

@end
