//
//  MessageCell.h
//  SimpleChatApp
//
//  Created by Brian Wong on 11/5/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Message.h"


@interface MessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *messageImageView;

@end
