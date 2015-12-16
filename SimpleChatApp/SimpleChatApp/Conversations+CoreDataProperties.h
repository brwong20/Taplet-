//
//  Conversations+CoreDataProperties.h
//  SimpleChatApp
//
//  Created by Brian Wong on 11/24/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Conversations.h"

NS_ASSUME_NONNULL_BEGIN

@interface Conversations (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *convoName;
@property (nullable, nonatomic, retain) NSString *userIds;
@property (nullable, nonatomic, retain) NSString *convoID;
@property (nullable, nonatomic, retain) NSSet<Messages *> *messageWithin;

@end

@interface Conversations (CoreDataGeneratedAccessors)

- (void)addMessageWithinObject:(Messages *)value;
- (void)removeMessageWithinObject:(Messages *)value;
- (void)addMessageWithin:(NSSet<Messages *> *)values;
- (void)removeMessageWithin:(NSSet<Messages *> *)values;

@end

NS_ASSUME_NONNULL_END
