//
//  BJCAWebImageView.m
//  test
//
//  Created by Chenfy on 2021/2/17.
//

#import "BJCAWebImageView.h"
#import "BJCAImageCache.h"
#import "BJCAWebImageDownloader.h"

@implementation BJCAWebImageView

#pragma mark RemoteImageView
-(void)setImageWithURL:(NSURL *)url
{
    if (downloader != nil)
    {
        [downloader cancel];//从队列中删除
        downloader = nil;
    }
    //保存占位图图像，以便在视图被重用的时候重新应用占位图
    if (placeHolderImage == nil)
    {
        placeHolderImage = self.image;
    }
    else
    {
        self.image = placeHolderImage;
    }
    //完整的url字符串当做key
    UIImage *cachedImage = [[BJCAImageCache sharedImageCache] imageFromKey:[url absoluteString]];
    if (cachedImage)
    {
        self.image = cachedImage;
    }
    else
    {
        downloader = [BJCAWebImageDownloader downloaderWithURL:url target:self action:@selector(downloadFinishedWithImage:)];
    }
}

-(void)downloadFinishedWithImage:(UIImage *)image
{
    self.image = image;
    downloader = nil;
    
    [[BJCAImageCache sharedImageCache] storeImage:image forKey:[downloader.url absoluteString]];
}

@end
