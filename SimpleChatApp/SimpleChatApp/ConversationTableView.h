//
//  ConversationTableView.h
//  SimpleChatApp
//
//  Created by Brian Wong on 11/24/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ConversationTableView : UITableViewController

@property (nonatomic, weak)NSManagedObjectContext *context;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end
