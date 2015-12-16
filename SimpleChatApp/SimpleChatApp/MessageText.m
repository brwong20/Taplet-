//
//  MessageText.m
//  SimpleChatApp
//
//  Created by Brian Wong on 11/4/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//

#import "MessageText.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "Messages+CoreDataProperties.h"

@import CoreData;

@interface MessageText ()

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIButton *picturesButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textViewHeight;

@property (weak, nonatomic) UIImage *imageToSend;
@property (strong, nonatomic) NSLayoutConstraint *maxTextHeight;
@property (strong, nonatomic) NSLayoutConstraint *minTextHeight;
@property (weak, nonatomic) NSManagedObjectContext *context;

@end

@implementation MessageText

-(void)awakeFromNib{
    [self.picturesButton addTarget:self action:@selector(showPictures) forControlEvents:UIControlEventTouchUpInside];
    
    AppDelegate *myApp = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    self.context = myApp.managedObjectContext;

    [self.messageTextView setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17.0]];
    self.messageTextView.enablesReturnKeyAutomatically = YES;
    self.messageTextView.delegate = self;
    
    [self.messageTextView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.messageTextView.layer setBorderWidth:2.0];
    self.messageTextView.layer.cornerRadius = 5;
    self.messageTextView.clipsToBounds = YES;
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
}

//If we ever want to implement an actual send button instead of using the return key.
//-(void)sendClicked{
//    //If any class is listening, run their implemented delegate method
//    if ([self.delegate respondsToSelector:@selector(sendButtonClicked:)]) {
//        [self.delegate sendButtonClicked:[self.messageTextField text]];
//    }
//    
//    [self.messageTextField setText:@""];
//}

-(void)showPictures{
    if ([self.delegate respondsToSelector:@selector(moveToPictures)]) {
        [self.delegate moveToPictures];
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(sendButtonClicked:)]) {
            [self.delegate sendButtonClicked:[self.messageTextView text]];
        }
        [self.messageTextView setText:nil];
        //self.messageTextView.textContainerInset = UIEdgeInsetsZero;
    }
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView{
    
    CGSize resizedTextView = [self.messageTextView sizeThatFits:self.messageTextView.frame.size];
    self.textViewHeight.constant = resizedTextView.height;
    
}

@end
