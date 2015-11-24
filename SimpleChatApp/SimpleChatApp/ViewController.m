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

@interface ViewController ()<TextBoxDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate,PhotoViewDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *messagesArray;
@property (weak, nonatomic) IBOutlet MessageText *msgTxtVC;
@property (strong, nonatomic) UIImage *tappedImage;

@end

@implementation ViewController

//Used in order to use "_" notation and so we can create a custom lazy init method.
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.msgTxtVC setDelegate:self];
    
    //Store all Core Data objects into local array
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Messages" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageDate"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSArray* messageArray = [self.context executeFetchRequest:fetchRequest error:nil];
    self.messagesArray = [NSMutableArray arrayWithArray:messageArray];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    tap.cancelsTouchesInView = NO; //Allows cell selection not to be intercepted
    [self.tableView addGestureRecognizer:tap];
    
    [self addObservers];
    
    [self fetchedResultsController];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateMessages" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //Gets rid of the selection highlight after selecting a picture
    NSIndexPath* selection = [self.tableView indexPathForSelectedRow];
    if (selection) {
        [self.tableView deselectRowAtIndexPath:selection animated:YES];
    }
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
    
    Messages *msg = [self.messagesArray objectAtIndex:indexPath.row];
    
    //Messages *msg = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    //If we have a message, size the cell dynamically. If we have an image, use a constant size of 200 and scale the image accordingly.
    if (msg.messageText != nil) {
        return UITableViewAutomaticDimension;
    }else if(msg.messageImage != nil){
        return 200;
    }else{
        return UITableViewAutomaticDimension;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.messagesArray count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"messageCell"];

    Messages *msg = [self.messagesArray objectAtIndex:indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd"];
    NSString *dateOfMsg = [dateFormatter stringFromDate:msg.messageDate];
    
    cell.dateLabel.text = dateOfMsg;
    
    if(cell != nil){
        if(msg.messageText != nil){
            cell.messageLabel.hidden = NO;
            cell.messageImageView.hidden = YES;
            cell.messageLabel.text = msg.messageText;
        }else if(msg.messageImage != nil){
            NSData *photoData = [[NSData alloc]initWithBase64EncodedString:msg.messageImage options:NSDataBase64DecodingIgnoreUnknownCharacters];
            UIImage *msgImage = [UIImage imageWithData:photoData];
            cell.messageImageView.hidden = NO;
            cell.messageLabel.hidden = YES;
            cell.messageImageView.image = msgImage;
        }else{
            cell.messageLabel.hidden = NO;
            cell.messageImageView.hidden = YES;
            cell.messageLabel.text = @"Error sending message";
        }
    }else{
        NSLog(@"Hey!!!");
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //Messages *msgInfo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    Messages *msgInfo = [self.messagesArray objectAtIndex:indexPath.row];
    
    if(msgInfo.messageImage != nil){
        NSData *photoData = [[NSData alloc]initWithBase64EncodedString:msgInfo.messageImage options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *msgImage = [UIImage imageWithData:photoData];
        self.tappedImage = msgImage;
        [[NSNotificationCenter defaultCenter]postNotificationName:UIKeyboardWillHideNotification object:nil];
        [self performSegueWithIdentifier:@"showPicture" sender:self];
    }else{
        MessageCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.userInteractionEnabled = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    //IF indexpath has an image
    //Messages *msgCell = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    Messages *msgCell = [self.messagesArray objectAtIndex:indexPath.row];
    
    if (msgCell.messageImage != nil) {
        return YES;
    }else{
        return NO;
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //Messages *imageData = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    Messages *imageCell = [self.messagesArray objectAtIndex:indexPath.row];
    
    //Delete from core data here
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.tableView beginUpdates];
        [self.messagesArray removeObject:imageCell];//Delete from local array
        [self.context deleteObject:imageCell];//Delete from Core Data
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        NSError *error;
        if (![self.context save:&error]) {
            NSLog(@"Error!, %@", error);
        };
    }else{
        NSLog(@"Unable to delete");
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateMessages" object:nil];
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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd"];
    NSString *dateString = [dateFormatter stringFromDate:today];
    NSDate *formattedDate = [dateFormatter dateFromString:dateString];
    
    Messages *newMessage = (Messages*)[NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:self.context];
    
    newMessage.messageDate = formattedDate;
    newMessage.messageText = text;
    
    [self.messagesArray addObject:newMessage];
    
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Error!, %@", error);
    };
    
    [self hideKeyboard];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateMessages" object:nil];
}

-(void)pictureSent:(UIImage *)selectedImage{
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd"];
    NSString *dateString = [dateFormatter stringFromDate:today];
    NSDate *formattedDate = [dateFormatter dateFromString:dateString];
    
    Messages *newMessage = (Messages*)[NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:self.context];
    
    newMessage.messageDate = formattedDate;
    
    //NSData representation (Can be stored as Binary Data)
    NSData *photoData = UIImageJPEGRepresentation(selectedImage, 0.0);
    
    //Convert to String(URL) Representation 
    NSString *photoURLString = [photoData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    newMessage.messageImage = photoURLString;
    
    [self.messagesArray addObject:newMessage];
    
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Error!, %@", error);
    };
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateMessages" object:nil];
}

//When we click the pictures button
-(void)moveToPictures{
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
    
    // Specify criteria for filtering which objects to fetch
    // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"<#format string#>", <#arguments#>];
    // [fetchRequest setPredicate:predicate];
    
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageDate"
    ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];

    _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView beginUpdates];
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView endUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath{
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate://{
            //To be implemented if neccessary
            //Messages *editedMessage = [self.fetchedResultsController objectAtIndexPath:indexPath];
            //MessageCell *msgCell = [self.tableView cellForRowAtIndexPath:indexPath];
        //}
            break;
        case NSFetchedResultsChangeMove:
            //Do nothing
            break;
        default:
            break;
    }
}

-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            break;
    }
}

@end
