//
//  TextBox.h
//  SimpleChatApp
//
//  Created by Brian Wong on 11/4/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TextBoxDelegate <NSObject>

@required

-(void)sendTextToTableView:(NSString*)text;

@end

@interface TextBox : UITextField

-(void)sendClicked;

@end
