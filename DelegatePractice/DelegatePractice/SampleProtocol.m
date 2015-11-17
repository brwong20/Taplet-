//
//  SampleProtocol.m
//  DelegatePractice
//
//  Created by Brian Wong on 11/3/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//

#import "SampleProtocol.h"
#import <Foundation/Foundation.h>

@implementation SampleProtocol

-(void)startSampleProcess{
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self.delegate selector:@selector(processCompleted) userInfo:nil repeats:NO];
}

@end
