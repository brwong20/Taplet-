//
//  TextBox.m
//  SimpleChatApp
//
//  Created by Brian Wong on 11/4/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//

#import "TextBox.h"

@implementation TextBox

-(void)sendClicked{
    NSLog(@"%@", [self text]);
    [self.delegate sendTextToTableView:[self text]];
    self.text = @"";
}


@end
