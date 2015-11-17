//
//  PictureDetailView.h
//  SimpleChatApp
//
//  Created by Brian Wong on 11/10/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureDetailView : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *photoDetailView;
@property (strong, nonatomic)UIImage *selectedImage;

@end
