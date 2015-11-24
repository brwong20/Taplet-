//
//  PhotoViewController.h
//  SimpleChatApp
//
//  Created by Brian Wong on 11/7/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <CoreData/CoreData.h>

@protocol PhotoViewDelegate <NSObject>

@required

-(void)pictureSent:(UIImage*)selectedImage;

@end

@interface PhotoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;

@property (strong,nonatomic) UIImage *photoImage;
@property (strong,nonatomic) PHAsset *imageAsset;
@property (assign, nonatomic)id<PhotoViewDelegate>delegate;

@end
