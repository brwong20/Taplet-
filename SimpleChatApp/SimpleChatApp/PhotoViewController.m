//
//  PhotoViewController.m
//  SimpleChatApp
//
//  Created by Brian Wong on 11/7/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//

#import "PhotoViewController.h"
#import "ViewController.h"
#import "Messages.h"
#import "AppDelegate.h"


@interface PhotoViewController()

@property (strong,nonatomic)UIGestureRecognizer *longPressReconigzer;
@property (weak,nonatomic) NSManagedObjectContext* context;

@end

@implementation PhotoViewController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.mainImageView.image = self.photoImage;
    
    self.mainImageView.userInteractionEnabled = YES;
    self.longPressReconigzer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(photoOptions:)];
    [self.mainImageView addGestureRecognizer:self.longPressReconigzer];
    
    AppDelegate *myApp = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    self.context = myApp.managedObjectContext;
}

- (IBAction)sendButtonPressed:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(pictureSent:)]) {
        [self.delegate pictureSent:self.photoImage];
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)photoOptions:(UILongPressGestureRecognizer*)sender{
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Photo Options" message:@"What would you like to do with this photo?" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        UIAlertAction *sendAction = [UIAlertAction actionWithTitle:@"Send" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([self.delegate respondsToSelector:@selector(pictureSent:)]) {
                [self.delegate pictureSent:self.photoImage];
            }
            [self.navigationController popToRootViewControllerAnimated:YES];
        }];
        
        UIAlertAction *deleteFromLibrary = [UIAlertAction actionWithTitle:@"Delete from photos" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetChangeRequest deleteAssets:@[self.imageAsset]];
            } completionHandler:^(BOOL success, NSError *error) {
                if (success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"photoDeleted" object:nil];
                        [self.navigationController popViewControllerAnimated:NO];
                    });
                }
            }];
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:sendAction];
        [alertController addAction:deleteFromLibrary];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

@end
