//
//  MessageCell.m
//  SimpleChatApp
//
//  Created by Brian Wong on 11/5/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//

#import "MessageCell.h"
#import "MessageText.h"
#import "Message.h"

@interface MessageCell()

@end

@implementation MessageCell 

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)prepareForReuse{
    [super prepareForReuse];
    self.messageLabel.text = nil;
    self.messageImageView.image = nil;
}


@end
