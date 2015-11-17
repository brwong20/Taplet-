//
//  MessageText.h
//  SimpleChatApp
//
//  Created by Brian Wong on 11/4/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@protocol TextBoxDelegate <NSObject>

-(void)sendButtonClicked:(NSString*)text;
-(void)moveToPictures;

@end

@interface MessageText : UIView

@property (assign, nonatomic) id<TextBoxDelegate>delegate;

-(void)sendClicked;

@end
