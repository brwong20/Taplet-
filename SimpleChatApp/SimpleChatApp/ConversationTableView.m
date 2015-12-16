//
//  ConversationTableView.m
//  SimpleChatApp
//
//  Created by Brian Wong on 11/24/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ConversationTableView.h"
#import "Conversations+CoreDataProperties.h"
#import "ConversationCell.h"
#import "ViewController.h"
#import "Messages.h"

@interface ConversationTableView()<UITableViewDataSource, UITabBarDelegate, NSFetchedResultsControllerDelegate>

@property(nonatomic,strong) NSMutableArray *conversationArray;
@property(nonatomic,strong) UIAlertController *convoAlert;
@property(nonatomic,strong) NSString *selectedConvoID;
@property(nonatomic,strong) NSString *selectedConvoName;

@end

@implementation ConversationTableView

@synthesize fetchedResultsController = _fetchedResultsController;

-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:21]}];

    //Store all Core Data objects into local array
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Conversations" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"convoID"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    NSArray* conversations = [self.context executeFetchRequest:fetchRequest error:nil];
    self.conversationArray = [NSMutableArray arrayWithArray:conversations];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ConversationCell *convoCell = (ConversationCell*)[self.tableView dequeueReusableCellWithIdentifier:@"convoCell"];
    
    Conversations *conversation = [self.conversationArray objectAtIndex:indexPath.row];
    
    convoCell.conversationName.text = conversation.convoName;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Messages" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    // Only retrieve Messages with the the selected convoID
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"convoID = %@", conversation.convoID];
    [fetchRequest setPredicate:predicate];
    
    //RETRIEVE LAST MESSAGE
    NSSortDescriptor *sortDescriptior = [[NSSortDescriptor alloc]initWithKey:@"messageDate" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptior]];
    
    fetchRequest.fetchLimit = 1;
    NSArray *fetchedMessage = [self.context executeFetchRequest:fetchRequest error:nil];
    
    if(fetchedMessage.count != 0){
        Messages *lastMessage = [fetchedMessage objectAtIndex:0];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd"];
        NSString *dateOfMsg = [dateFormatter stringFromDate:lastMessage.messageDate];
        convoCell.lastDate.hidden = NO;
        convoCell.lastDate.text = dateOfMsg;
        if(lastMessage.messageText != nil){
            convoCell.lastMessage.hidden = NO;
            convoCell.lastImage.hidden = YES;
            convoCell.lastMessage.text = lastMessage.messageText;
        }else if(lastMessage.messageImage != nil){
            
            //ADD URL CHECK HERE
            
            
            convoCell.lastMessage.hidden = YES;
            convoCell.lastImage.hidden = NO;
            NSData *photoData = [[NSData alloc]initWithBase64EncodedString:lastMessage.messageImage options:NSDataBase64DecodingIgnoreUnknownCharacters];
            UIImage *msgImage = [UIImage imageWithData:photoData];
            convoCell.lastImage.layer.cornerRadius = convoCell.lastImage.frame.size.width / 2;
            convoCell.lastImage.clipsToBounds = YES;
            convoCell.lastImage.image = msgImage;
        }else{
            convoCell.lastMessage.text = @"Couldn't retrieve last message";
        }
    }else{
        convoCell.lastMessage.hidden = YES;
        convoCell.lastImage.hidden = YES;
        convoCell.lastDate.hidden = YES;
    }
    
    return convoCell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.conversationArray.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Conversations *selectedConversation = [self.conversationArray objectAtIndex:indexPath.row];
    
    self.selectedConvoName = selectedConversation.convoName;
    self.selectedConvoID = selectedConversation.convoID;
    
    [self performSegueWithIdentifier:@"showConversation" sender:self];
}

- (IBAction)addConversationButton:(id)sender {
    
    self.convoAlert = [UIAlertController alertControllerWithTitle:@"New Conversation" message:@"Give a name to your new conversation!" preferredStyle:UIAlertControllerStyleAlert];
    
    [self.convoAlert addTextFieldWithConfigurationHandler:nil];
    
    UIAlertAction *createConvo = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self createNewConversation];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil];
    
    [self.convoAlert addAction:cancel];
    [self.convoAlert addAction:createConvo];
    
    [self presentViewController:self.convoAlert animated:YES completion:nil];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"showConversation"]){
        ViewController *messagesVC = (ViewController*)segue.destinationViewController;
        
        //Retrieve messages with convo ID
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Messages" inManagedObjectContext:self.context];
        [fetchRequest setEntity:entity];
        
        // Sort based on message date
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageDate"
                                                                       ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
        
        // Only retrieve Messages with the the selected convoID
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"convoID = %@", self.selectedConvoID];
        [fetchRequest setPredicate:predicate];
        
        NSArray* messages = [self.context executeFetchRequest:fetchRequest error:nil];
        
        messagesVC.retrievedMessages = messages;
        messagesVC.navigationItem.title = self.selectedConvoName;
        messagesVC.convoID = self.selectedConvoID;
        messagesVC.context = self.context;
    }
    
}

-(void)createNewConversation{
    Conversations *newConversation = [NSEntityDescription insertNewObjectForEntityForName:@"Conversations" inManagedObjectContext:self.context];
    
    [self.conversationArray addObject:newConversation];
    
    //Just use the index of the row as convo ID for now
    NSString *convoID = [NSString stringWithFormat: @"%lu", (unsigned long)self.conversationArray.count];
    newConversation.convoID = convoID;
    newConversation.convoName = [self.convoAlert.textFields.firstObject text];
    self.selectedConvoName = [self.convoAlert.textFields.firstObject text];
    self.selectedConvoID = convoID;
    
    NSError *error;
    if (![self.context save:&error]) {
        NSLog(@"Error!, %@", error);
    };

    [self performSegueWithIdentifier:@"showConversation" sender:self];
}

#pragma mark - Core Data Componenets

-(NSFetchedResultsController *)fetchedResultsController{
    if (_fetchedResultsController !=nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Conversations" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"convoID"
                                                                   ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

@end
