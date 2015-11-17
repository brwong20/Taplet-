//
//  SampleProtocol.h
//  DelegatePractice
//
//  Created by Brian Wong on 11/3/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SampleProtocol <NSObject>

@required

-(void)processCompleted;

@end

@interface SampleProtocol : NSObject

@property(nonatomic, weak) id <SampleProtocol> delegate;

-(void)startSampleProcess;


@end
