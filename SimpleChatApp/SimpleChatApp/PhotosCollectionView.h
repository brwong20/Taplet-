//
//  PhotosCollectionView.h
//  SimpleChatApp
//
//  Created by Brian Wong on 11/7/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "PhotoViewController.h"

@interface PhotosCollectionView : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak) id<PhotoViewDelegate>delegate;

@end
