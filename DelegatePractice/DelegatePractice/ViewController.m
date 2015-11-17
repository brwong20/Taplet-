//
//  ViewController.m
//  DelegatePractice
//
//  Created by Brian Wong on 11/3/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//

#import "ViewController.h"
#import "SampleProtocol.h"

@interface ViewController ()<SampleProtocol>
@property (weak, nonatomic) IBOutlet UILabel *basicLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SampleProtocol *sampleProtocol = [[SampleProtocol alloc]init];
    sampleProtocol.delegate = self;
    [self.basicLabel setText:@"Processing..."];
    [sampleProtocol startSampleProcess];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)processCompleted{
    [self.basicLabel setText:@"Process completed!"];
}

@end
