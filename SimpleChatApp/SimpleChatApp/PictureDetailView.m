//
//  PictureDetailView.m
//  SimpleChatApp
//
//  Created by Brian Wong on 11/10/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//

#import "PictureDetailView.h"
#import "UIView+Toast.h"

@interface PictureDetailView()

@property (strong,nonatomic) UILongPressGestureRecognizer* longPressGesture;

@end

@implementation PictureDetailView

-(void)viewWillAppear:(BOOL)animated{
    self.photoDetailView.image = self.selectedImage;
    
    self.longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(photoOptions:)];
    
    self.photoDetailView.userInteractionEnabled = YES;
    [self.photoDetailView addGestureRecognizer:self.longPressGesture];
}

-(void)photoOptions:(UILongPressGestureRecognizer*)sender{
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Photo Options" message:@"What would you like to do with this photo?" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        //Apply filters?
        
//        UIAlertAction *filterAction = [UIAlertAction actionWithTitle:@"Apply a filter" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            //Apply filters here
//        }];
        
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save photo to album" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIImageWriteToSavedPhotosAlbum(self.selectedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }];
        
        [alertController addAction:cancelAction];
        //[alertController addAction:filterAction];
        [alertController addAction:saveAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo
{
    if(!error){
        [self.view makeToast:@"Photo Saved!" duration:0.7 position:CSToastPositionCenter];
    }else{
        [self.view makeToast:@"Couldn't save the photo... Try again." duration:0.7 position:CSToastPositionCenter];
    }
}

@end
