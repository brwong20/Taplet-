//
//  ViewController.h
//  SimpleChatApp
//
//  Created by Brian Wong on 11/3/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "MessageText.h"

@interface ViewController : UIViewController

@property (nonatomic, weak)NSManagedObjectContext *context;
@property (strong, nonatomic)NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic)NSString *convoID;
@property (strong, nonatomic)NSArray *retrievedMessages;

@end

