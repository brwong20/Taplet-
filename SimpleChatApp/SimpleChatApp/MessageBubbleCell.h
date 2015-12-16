//
//  MessageBubbleCell.h
//  SimpleChatApp
//
//  Created by Brian Wong on 12/2/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageBubbleCell : UITableViewCell

extern const CGFloat STBubbleWidthOffset; // Extra width added to bubble

typedef NS_ENUM(NSUInteger, AuthorType) {
    STBubbleTableViewCellAuthorTypeSelf = 0,
    STBubbleTableViewCellAuthorTypeOther
};

typedef NS_ENUM(NSUInteger, BubbleColor) {
    STBubbleTableViewCellBubbleColorGreen = 0,
    STBubbleTableViewCellBubbleColorGray = 1,
    STBubbleTableViewCellBubbleColorAqua = 2, // Default value of selectedBubbleColor
    STBubbleTableViewCellBubbleColorBrown = 3,
    STBubbleTableViewCellBubbleColorGraphite = 4,
    STBubbleTableViewCellBubbleColorOrange = 5,
    STBubbleTableViewCellBubbleColorPink = 6,
    STBubbleTableViewCellBubbleColorPurple = 7,
    STBubbleTableViewCellBubbleColorRed = 8,
    STBubbleTableViewCellBubbleColorYellow = 9
};

@property (nonatomic, strong, readonly) UIImageView *bubbleView;
@property (nonatomic, assign) AuthorType authorType;
@property (nonatomic, assign) BubbleColor bubbleColor;
@property (nonatomic, assign) BubbleColor selectedBubbleColor;
@property (nonatomic, assign) BOOL canCopyContents; // Defaults to YES
@property (nonatomic, assign) BOOL selectionAdjustsColor; // Defaults to YES


@end
