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

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *picturesButton;
@property (weak, nonatomic) UIImage *imageToSend;
@property (weak, nonatomic) NSManagedObjectContext *context;

@end

@implementation MessageText

-(void)awakeFromNib{
    [self.sendButton addTarget:self action:@selector(sendClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.picturesButton addTarget:self action:@selector(showPictures) forControlEvents:UIControlEventTouchUpInside];
    
    AppDelegate *myApp = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    self.context = myApp.managedObjectContext;
}

//Get textfield info here and implement save function and update in table view with NSFetchResultscontroller
-(void)sendClicked{
    
    //If any class is listening, run their implemented delegate method
    if ([self.delegate respondsToSelector:@selector(sendButtonClicked:)]) {
        [self.delegate sendButtonClicked:[self.textField text]];
    }
    
    [self.textField setText:@""];
}

-(void)showPictures{
    if ([self.delegate respondsToSelector:@selector(moveToPictures)]) {
        [self.delegate moveToPictures];
    }
}

@end
