//
//  ViewController.m
//  KVCODemo
//
//  Created by Brian Wong on 11/3/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//

#import "ViewController.h"
#import "Children.h"

@interface ViewController ()

@property (nonatomic,strong) Children *child1;
@property (nonatomic,strong) Children *child2;
@property (nonatomic,strong) Children *child3;


@end

@implementation ViewController

static void *child1Context = &child1Context;
static void *child2Context = &child2Context;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.child1 = [[Children alloc]init];
    [self.child1 setValue:@"George" forKey:@"name"];
    [self.child1 setValue:[NSNumber numberWithInt:15] forKey:@"age"];
    
    NSString *childName = [self.child1 valueForKey:@"name"];
    NSUInteger childAge = [[self.child1 valueForKey:@"age"] integerValue];
    
    NSLog(@"%@, %lu", childName, (unsigned long)childAge);
    
    self.child2 = [[Children alloc]init];
    [self.child2 setValue:@"Mary" forKey:@"name"];
    [self.child2 setValue:[NSNumber numberWithInteger:35] forKey:@"age"];
    self.child2.child = [[Children alloc] init];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.child1 addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:child1Context];
    [self.child1 addObserver:self forKeyPath:@"age" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:child1Context];
    
    [self.child1 setValue:@"Michael" forKey:@"name"];
    [self.child1 setValue:[NSNumber numberWithInteger:20] forKey:@"age"];
    
    [self.child2 addObserver:self forKeyPath:@"age" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:child2Context];
    
    [self.child2 setValue:[NSNumber numberWithInteger:45] forKey:@"age"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.child1 removeObserver:self forKeyPath:@"name"];
    [self.child1 removeObserver:self forKeyPath:@"age"];
    [self.child2 removeObserver:self forKeyPath:@"age"];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if (context == child1Context) {
        if ([keyPath isEqualToString:@"name"]) {
            NSLog(@"The name of the FIRST child was changed.");
            NSLog(@"%@", change);
        }
        
        if ([keyPath isEqualToString:@"age"]) {
            NSLog(@"The age of the FIRST child was changed.");
            NSLog(@"%@", change);
        }
    }
    else if (context == child2Context){
        if ([keyPath isEqualToString:@"age"]) {
            NSLog(@"The age of the SECOND child was changed.");
            NSLog(@"%@", change);
        }
    }
    
}

@end
