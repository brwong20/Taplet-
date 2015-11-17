//
//  PhotosCollectionView.m
//  SimpleChatApp
//
//  Created by Brian Wong on 11/7/15.
//  Copyright © 2015 Brian Wong. All rights reserved.
//

#import <Photos/Photos.h>
#import "PhotosCollectionView.h"
#import "ViewController.h"
#import "PhotoCell.h"
#import "PhotoViewController.h"

//Gets all our cells' indexes for a given section(index paths)
@implementation NSIndexSet (Convenience)
- (NSArray *)aapl_indexPathsFromIndexesWithSection:(NSUInteger)section {
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:section]];
    }];
    return indexPaths;
}
@end

//Gets the layout of a cell for future modification (inserting,deleting,etc)
@implementation UICollectionView (Convenience)
- (NSArray *)aapl_indexPathsForElementsInRect:(CGRect)rect {
    NSArray *allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) { return nil; }
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}

@end

@interface PhotosCollectionView() <PHPhotoLibraryChangeObserver>

@property (strong) PHFetchResult *photoCollection;
@property (strong) PHCachingImageManager *imageManager;
@property (strong) NSMutableArray *photoArray;
@property (strong) PHAsset *imageAsset;
@property (strong) UIImage *selectedImage;
@property CGRect previousPreheatRect;

@end

//Static vars that we will only need within this class
static NSString * const reuseIdentifier = @"photoCell";
static CGSize ImageViewSize;

@implementation PhotosCollectionView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(photoDeleted:) name:@"photoDeleted" object:nil];
    
    //Notifies protocol if any changes are made to Photo Library
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    self.photoArray = [[NSMutableArray alloc]init];
    self.imageManager = [[PHCachingImageManager alloc]init];
    self.imageManager.allowsCachingHighQualityImages = YES;
    
    
    //Size of our collection view's cells
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = ((UICollectionViewFlowLayout *)self.collectionViewLayout).itemSize;
    ImageViewSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    PHFetchOptions *options = [PHFetchOptions new];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    self.photoCollection = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
    
    //Loop through the fetched results, then cache all the video thumbnail images.
    [self.photoCollection enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[PHAsset class]]) {
            [self.photoArray addObject:obj];
        }
    }];
    
    [self.imageManager startCachingImagesForAssets:self.photoArray targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self updateCachedAssets];
}

//Where should I clear the photo data?
-(void)dealloc{
    self.photoArray = nil;
    self.photoCollection = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

//-(void)viewDidDisappear:(BOOL)animated{
//    [super viewDidDisappear:animated];
//    
//    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
//    
//}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = self.photoCollection.count;
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    //Smoother scrolling
    cell.layer.shouldRasterize = YES;
    cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    // Increment the cell's tag - simply used to compute which new cells are being shown so we can re-use them. This in turn updates the tags of the cells we scrolled away.
    NSInteger currentTag = cell.tag + 1;
    cell.tag = currentTag;
    
    PHAsset *asset = self.photoCollection[indexPath.item];
    
    [self.imageManager requestImageForAsset:asset
                                 targetSize:ImageViewSize
                                contentMode:PHImageContentModeAspectFill
                                    options:nil
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  
                                  // Only update the thumbnail if the cell tag hasn't changed. Otherwise, the cell has been re-used.
                                  if (cell.tag == currentTag) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          cell.photoImageView.image = result;
                                      });
                                  }
                                  
                              }];
    
    return cell;
}

#pragma mark - PHPhotoLibraryChangeObserver

//Stock code to update collection view after changes to photo album
- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // check if there are changes to the assets (insertions, deletions, updates)
        PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:self.photoCollection];
        if (collectionChanges) {
            
            // get the new fetch result
            self.photoCollection = [collectionChanges fetchResultAfterChanges];
            
            UICollectionView *collectionView = self.collectionView;
            
            if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]) {
                // we need to reload all if the incremental diffs are not available
                [collectionView reloadData];
                
            } else {
                // if we have incremental diffs, tell the collection view to animate insertions and deletions
                [collectionView performBatchUpdates:^{
                    NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                    if ([removedIndexes count]) {
                        [collectionView deleteItemsAtIndexPaths:[removedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                    }
                    NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                    if ([insertedIndexes count]) {
                        [collectionView insertItemsAtIndexPaths:[insertedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                    }
                    NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                    if ([changedIndexes count]) {
                        [collectionView reloadItemsAtIndexPaths:[changedIndexes aapl_indexPathsFromIndexesWithSection:0]];
                    }
                } completion:NULL];
            }
            
            [self resetCachedAssets];
        }
    });
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateCachedAssets];
}

#pragma mark - Asset Caching

- (void)resetCachedAssets
{
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

//Stock code that updates caches for any type of assets
- (void)updateCachedAssets
{
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0f, -0.5f * CGRectGetHeight(preheatRect));
    
    // If scrolled by a "reasonable" amount...
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0f) {
        
        // Compute the assets to start caching and to stop caching.
        //Self note: I'm guessing this code calculates all the indexes that are scrolled in/out of view to cache/uncache their respective assets?
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self.collectionView aapl_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:ImageViewSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:ImageViewSize
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler
{
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths
{
    if (indexPaths.count == 0) { return nil; }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        PHAsset *asset = self.photoCollection[indexPath.item];
        [assets addObject:asset];
    }
    return assets;
}

-(void)photoDeleted:(NSNotification*)sender{
    NSLog(@"Collection view reset because of photo delete.");
    [self.collectionView reloadData];
    [self resetCachedAssets];
}

#pragma mark - Navigation

//PASS ONTO FULL SIZE IMAGE VIEW AND LET USER SEND , WHEN SEND IS CLICKED, SEND NOTIFICATION TO MESSAGETEXT, SET ITS IMAGE PROPERTY TO SELECTED IMAGE, THEN CALL DELEGATE METHOD


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier]isEqualToString:@"showPhotoVC"]) {
        PhotoViewController *photoVC = (PhotoViewController*)segue.destinationViewController;
        photoVC.photoImage = self.selectedImage;
        photoVC.imageAsset = self.imageAsset;
        photoVC.delegate = self.delegate;
    }
}

#pragma mark <UICollectionViewDelegate>


//GET PHOTO IMAGE HERE
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    self.imageAsset = self.photoCollection[indexPath.row];
    
    //Get full quality image instead of thumbnail
    [self.imageManager requestImageForAsset:self.imageAsset
                                 targetSize:PHImageManagerMaximumSize
                                contentMode:PHImageContentModeDefault
                                    options:nil
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      self.selectedImage = result;
                                      [self performSegueWithIdentifier:@"showPhotoVC" sender:self];
                                  });
                              }];
}

@end