//
//  Messages+CoreDataProperties.h
//  SimpleChatApp
//
//  Created by Brian Wong on 11/17/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Messages.h"

NS_ASSUME_NONNULL_BEGIN

@interface Messages (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *userName;
@property (nullable, nonatomic, retain) NSString *userId;
@property (nullable, nonatomic, retain) NSString *messageText;
@property (nullable, nonatomic, retain) NSString *messageImage;
@property (nullable, nonatomic, retain) NSDate *messageDate;
@property (nullable, nonatomic, retain) NSManagedObject *whoSent;
@property (nullable, nonatomic, retain) Conversations *messageForConvo;

@end

NS_ASSUME_NONNULL_END
