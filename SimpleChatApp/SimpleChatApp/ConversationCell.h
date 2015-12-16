//
//  ConversationCell.h
//  SimpleChatApp
//
//  Created by Brian Wong on 11/24/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConversationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *lastImage;
@property (weak, nonatomic) IBOutlet UILabel *lastMessage;
@property (weak, nonatomic) IBOutlet UILabel *lastDate;
@property (weak, nonatomic) IBOutlet UILabel *conversationName;

@end
