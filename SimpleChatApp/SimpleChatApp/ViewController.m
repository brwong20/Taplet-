//
//  ViewController.m
//  SimpleChatApp
//
//  Created by Brian Wong on 11/3/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "Message.h"
#import "MessageCell.h"
#import "PhotoViewController.h"
#import "PhotosCollectionView.h"
#import "PictureDetailView.h"

@interface ViewController ()<TextBoxDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate,PhotoViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *messagesArray;
@property (weak, nonatomic) IBOutlet MessageText *msgTxtVC;
@property (strong, nonatomic) UIImage *tappedImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.messagesArray = [[NSMutableArray alloc]init];
    
    [self.msgTxtVC setDelegate:self];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    tap.cancelsTouchesInView = NO; //Allows cell selection not to be intercepted
    [self.view addGestureRecognizer:tap];
    
    [self addObservers];
}

-(void)addObservers{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:[self.view window]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:[self.view window]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshMessages:) name:@"updateMessages" object:nil];
}

-(void)removeObservers{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:[self.view window]];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:[self.view window]];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"updateMessages" object:nil];
}


-(void)dealloc
{
    [self removeObservers];
    self.messagesArray = nil;
}

//Default cell size
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

//Dynamic resizing for cells
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Message *messageData = self.messagesArray[indexPath.row];
    
    //If we have a message, size the cell dynamically. If we have an image, use a constant size of 200 and scale the image accordingly.
    if (messageData.message != nil) {
        return UITableViewAutomaticDimension;
    }else if(messageData.image != nil){
        return 200;
    }else{
        return UITableViewAutomaticDimension;
    }
}


//SHOULD I CONFIG THE ENTIRE CELL IN THE CLASS OR HERE?
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"messageCell"];
    Message *messageData = self.messagesArray[indexPath.row];
    cell.dateLabel.text = messageData.date;
    if(cell != nil){
        if(messageData.message != nil){
            cell.messageLabel.hidden = NO;
            cell.messageImageView.hidden = YES;
            cell.messageLabel.text = messageData.message;
        }else if(messageData.image != nil){
            cell.messageImageView.hidden = NO;
            cell.messageLabel.hidden = YES;
            cell.messageImageView.image = messageData.image;
        }else{
            cell.messageLabel.hidden = NO;
            cell.imageView.hidden = YES;
            cell.messageLabel.text = @"Error sending message";
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageCell *msgCell = (MessageCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    msgCell.selectionStyle = UITableViewCellSelectionStyleNone;
    Message *msgData = self.messagesArray[indexPath.row];
    if(msgData.image){
        self.tappedImage = msgData.image;
        [[NSNotificationCenter defaultCenter]postNotificationName:UIKeyboardWillHideNotification object:nil];
        [self performSegueWithIdentifier:@"showPicture" sender:self];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    //IF indexpath has an image
    MessageCell *msgCell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (msgCell.messageImageView.image != nil) {
        return YES;
    }else{
        return NO;
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.messagesArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"updateMessages" object:nil];
    }else{
        NSLog(@"Unable to delete");
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messagesArray.count;
}

-(void)refreshMessages:(NSNotification*)notification{
    [self.tableView reloadData];
}

-(void)hideKeyboard{
    [self.view endEditing:YES];
}

-(void)keyboardWillShow:(NSNotification*)sender{
    NSDictionary *userInfo = [sender userInfo];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey]CGRectValue].size;
    CGSize offsetSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size;
    if (keyboardSize.height == offsetSize.height) {
        [UIView animateWithDuration:0.1 animations:^{
            CGRect viewFrame = self.view.frame;
            viewFrame.origin.y -= keyboardSize.height;
            self.view.frame = viewFrame;
        }];
    }else{//If user opens up predictive view, add the offset size to the view
        [UIView animateWithDuration:0.1 animations:^{
            CGRect viewFrame = self.view.frame;
            //Add offset to view to account for dismissing and showing the predictive view1
            viewFrame.origin.y += keyboardSize.height - offsetSize.height;
            self.view.frame = viewFrame;
        }];
    }
}

-(void)keyboardWillHide:(NSNotification*)sender{
    NSDictionary *userInfo = [sender userInfo];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey]CGRectValue].size;
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += keyboardSize.height;
    self.view.frame = viewFrame;
}

//WHEN WE CLICK THE SEND BUTTON
-(void)sendButtonClicked:(NSString *)text{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd"];
    NSString *dateString = [dateFormatter stringFromDate:today];

    Message *msg = [[Message alloc]initWith:dateString message:text image:nil];
    [self.messagesArray addObject:msg];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateMessages" object:nil];
    
}

//When we click the pictures button
-(void)moveToPictures{
    [self performSegueWithIdentifier:@"showPhotoCollection" sender:self];
}

-(void)pictureSent:(UIImage *)selectedImage{
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd"];
    NSString *dateString = [dateFormatter stringFromDate:today];
    
    Message *msg = [[Message alloc]initWith:dateString message:nil image:selectedImage];
    [self.messagesArray addObject:msg];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateMessages" object:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showPhotoCollection"]) {
        PhotosCollectionView *collectionView = (PhotosCollectionView*)segue.destinationViewController;
        collectionView.delegate = self;
    }else if ([segue.identifier isEqualToString:@"showPicture"]){
        PictureDetailView *picDetailView = (PictureDetailView*)segue.destinationViewController;
        picDetailView.selectedImage = self.tappedImage;
    }
}

@end
