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
#import "Messages+CoreDataProperties.h"
#import "MessageBubbleCell.h"

@interface ViewController ()<TextBoxDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate,PhotoViewDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *messagesArray;
@property (weak, nonatomic) IBOutlet MessageText *msgTxtVC;
@property (strong, nonatomic) UIImage *cellImage;
@property (strong, nonatomic) UIImage *tappedImage;

@end

@implementation ViewController

//Used in order to use "_" notation and so we can create a custom lazy init method.
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.msgTxtVC setDelegate:self];
 
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.messagesArray = [NSMutableArray arrayWithArray:self.retrievedMessages];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    tap.cancelsTouchesInView = NO; //Allows cell selection not to be intercepted
    [self.tableView addGestureRecognizer:tap];
    
    [self addObservers];
    
    [self fetchedResultsController];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"scrollToBottom" object:nil];
}

-(void)addObservers{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:[self.view window]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:[self.view window]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshMessages:) name:@"updateMessages" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(scrollToBottom:) name:@"scrollToBottom" object:nil];
}

-(void)removeObservers{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:[self.view window]];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:[self.view window]];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"updateMessages" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"scrollToBottom" object:nil];
}

-(void)dealloc
{
    [self removeObservers];
    self.messagesArray = nil;
    self.retrievedMessages = nil;
}

//Default cell size
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

//Dynamic resizing for cells
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    Messages *msg = [self.messagesArray objectAtIndex:indexPath.row];
    
    CGSize size;
    if(msg.messageImage)
    {
        //size = [self imageWithImage:message.avatar scaledToSize:CGSizeMake(100, 100)].size;
        NSData *photoData = [[NSData alloc]initWithBase64EncodedString:msg.messageImage options:NSDataBase64DecodingIgnoreUnknownCharacters];
        size = [self imageWithImage:[UIImage imageWithData:photoData] scaledToSize:CGSizeMake(100.0, 100.0)].size;
    }
    else
    {
        size = [msg.messageText boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width - 40.0 - STBubbleWidthOffset, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.0f]}
                                                context:nil].size;
        return size.height + 17.0f;
    }
    return size.height + 25.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messagesArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Bubble Cell";
    MessageBubbleCell *messageCell = (MessageBubbleCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    Messages *msg = [self.messagesArray objectAtIndex:indexPath.row];
    
    //To get date
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"MM/dd"];
//    NSString *dateOfMsg = [dateFormatter stringFromDate:msg.messageDate];
    
    //If the cell doesn't exist, it's not a reused cell and we have to create a new one
    if(messageCell == nil){
        messageCell = [[MessageBubbleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }else{
        //If the cell is a reusable cell, clear it's content to set new properties
        messageCell.textLabel.text = nil;
        messageCell.imageView.image = nil;
    }
    
    if (msg.messageText != nil) {
        messageCell.textLabel.text = msg.messageText;
    }else if (msg.messageImage != nil){
        //FIX URL check and dispatch async here
        if([self validateURL:msg.messageImage] == YES){
            NSURL *imageURL = [NSURL URLWithString:msg.messageImage];
            NSData *photoData = [NSData dataWithContentsOfURL:imageURL];
            self.cellImage = [self imageWithImage:[UIImage imageWithData:photoData] scaledToSize:CGSizeMake(100.0, 100.0)];
            messageCell.imageView.image = self.cellImage;
        }else{
            NSData *photoData = [[NSData alloc]initWithBase64EncodedString:msg.messageImage options:NSDataBase64DecodingIgnoreUnknownCharacters];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.cellImage = [self imageWithImage:[UIImage imageWithData:photoData] scaledToSize:CGSizeMake(100.0, 100.0)];
                messageCell.imageView.image = self.cellImage;
            });
        }
    }else{
        messageCell.textLabel.text = @"ERROR";
    }
    
    messageCell.authorType = STBubbleTableViewCellAuthorTypeSelf;
    messageCell.bubbleColor = STBubbleTableViewCellBubbleColorAqua;

    return messageCell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Messages *msgInfo = [self.messagesArray objectAtIndex:indexPath.row];

    if(msgInfo.messageImage != nil){
        if([self validateURL:msgInfo.messageImage] == YES){
            NSURL *imageURL = [NSURL URLWithString:msgInfo.messageImage];
            NSData *photoData = [NSData dataWithContentsOfURL:imageURL];
            self.tappedImage = [UIImage imageWithData:photoData];
        }else{
            NSData *photoData = [[NSData alloc]initWithBase64EncodedString:msgInfo.messageImage options:NSDataBase64DecodingIgnoreUnknownCharacters];
            UIImage *msgImage = [UIImage imageWithData:photoData];
            self.tappedImage = msgImage;
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:UIKeyboardWillHideNotification object:nil];
        [self performSegueWithIdentifier:@"showPicture" sender:self];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    Messages *messageCell = [self.messagesArray objectAtIndex:indexPath.row];
   
    //Delete from core data here
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.tableView beginUpdates];
        
        [self.messagesArray removeObject:messageCell];//Delete from local array
        [self.context deleteObject:messageCell];//Delete from Core Data
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [self.tableView endUpdates];
    }else{
        NSLog(@"Unable to delete");
    }
    
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Error!, %@", error);
    };
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateMessages" object:nil];
}

-(void)scrollToBottom:(NSNotification*)notification{
    [self.tableView setContentOffset:CGPointZero];

    NSInteger lastRowNumber = [self.tableView numberOfRowsInSection:0] - 1;
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:lastRowNumber inSection:0];
    
    if(lastRowNumber>0){
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
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
    }else{
        //If user opens up predictive view, add the offset size to the view
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
-(void)sendButtonClicked:(NSString*)text{
    NSDate *today = [NSDate date];
    
    Messages *newMessage = (Messages*)[NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:self.context];
    
    newMessage.messageDate = today;
    
    if ([self validateURL:text] == YES) {
        newMessage.messageImage = text;
    }else{
        newMessage.messageText = text;
    }
    newMessage.convoID = self.convoID;
    
    [self.messagesArray addObject:newMessage];
    
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Error!, %@", error);
    };
    
    //[self hideKeyboard];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateMessages" object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"scrollToBottom" object:nil];
}

-(void)pictureSent:(UIImage *)selectedImage{
    NSDate *today = [NSDate date];
    
    Messages *newMessage = (Messages*)[NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:self.context];
    
    newMessage.messageDate = today;
    
    //NSData representation (Can be stored as Binary Data)
    NSData *photoData = UIImageJPEGRepresentation(selectedImage, 0.0);
    
    //Convert to String(URL) Representation 
    NSString *photoURLString = [photoData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    newMessage.messageImage = photoURLString;
    newMessage.convoID = self.convoID;
    
    [self.messagesArray addObject:newMessage];
    
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Error!, %@", error);
    };
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateMessages" object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"scrollToBottom" object:nil];
}

//When we click the pictures button
-(void)moveToPictures{
    [self hideKeyboard];
    [self performSegueWithIdentifier:@"showPhotoCollection" sender:self];
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

#pragma mark - Core Data Componenets

-(NSFetchedResultsController *)fetchedResultsController{
    if (_fetchedResultsController !=nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Messages" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageDate"
    ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];

    _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

//-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
//    
//    switch (type) {
//        case NSFetchedResultsChangeInsert:
//            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeUpdate://{
//            //To be implemented if neccessary
//            //Messages *editedMessage = [self.fetchedResultsController objectAtIndexPath:indexPath];
//            //MessageCell *msgCell = [self.tableView cellForRowAtIndexPath:indexPath];
//        //}
//            break;
//        case NSFetchedResultsChangeMove:
//            //Do nothing
//            break;
//        default:
//            break;
//    }
//}

//-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type{
//    switch (type) {
//        case NSFetchedResultsChangeInsert:
//            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//        case NSFetchedResultsChangeDelete:
//            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//        default:
//            break;
//    }
//}

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(BOOL)validateURL:(NSString*)urlString{
    NSString *regexURL = @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexURL];
    BOOL isValidURL = [urlPredicate evaluateWithObject:urlString];
    return isValidURL;
}

@end
