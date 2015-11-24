//
//  Conversations+CoreDataProperties.h
//  SimpleChatApp
//
//  Created by Brian Wong on 11/17/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Conversations.h"

NS_ASSUME_NONNULL_BEGIN

@interface Conversations (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString* userIds;
@property (nullable, nonatomic, retain) NSSet<NSManagedObject *> *messageWithin;

@end

@interface Conversations (CoreDataGeneratedAccessors)

- (void)addMessageWithinObject:(NSManagedObject *)value;
- (void)removeMessageWithinObject:(NSManagedObject *)value;
- (void)addMessageWithin:(NSSet<NSManagedObject *> *)values;
- (void)removeMessageWithin:(NSSet<NSManagedObject *> *)values;

@end

NS_ASSUME_NONNULL_END
