//
//  Messages+CoreDataProperties.m
//  SimpleChatApp
//
//  Created by Brian Wong on 11/17/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Messages+CoreDataProperties.h"

@implementation Messages (CoreDataProperties)

@dynamic userName;
@dynamic userId;
@dynamic messageText;
@dynamic messageImage;
@dynamic messageDate;
@dynamic whoSent;
@dynamic convoID;
@dynamic messageForConvo;

@end
