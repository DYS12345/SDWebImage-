//
//  BJCAWebImageDownloader.m
//  test
//
//  Created by Chenfy on 2021/2/18.
//

#import "BJCAWebImageDownloader.h"
#import <UIKit/UIKit.h>

static NSOperationQueue *downloadQueue;

@implementation BJCAWebImageDownloader

@synthesize url, target, action;

+(id)downloaderWithURL:(NSURL *)url target:(id)target action:(SEL)action
{
    BJCAWebImageDownloader *downloader = [[BJCAWebImageDownloader alloc] init];
    downloader.url = url;
    downloader.target = target;
    downloader.action = action;
    
    if (downloadQueue == nil)
    {
        downloadQueue = [[NSOperationQueue alloc] init];
        downloadQueue.maxConcurrentOperationCount = 8;
    }
    [downloadQueue addOperation:downloader];
    return downloader;
}

+(void)setMaxConcurrentDownloads:(NSUInteger)max
{
    if (downloadQueue == nil)
    {
        downloadQueue = [[NSOperationQueue alloc] init];
    }
    downloadQueue.maxConcurrentOperationCount = max;
}

-(void)main
{
    @autoreleasepool
    {
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        if (!self.isCancelled)
        {
            [target performSelector:@selector(action) withObject:image];
        }
    }
}

@end
