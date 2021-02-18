//
//  BJCAWebImageDownloader.m
//  test
//
//  Created by Chenfy on 2021/2/18.
//

#import "BJCAWebImageDownloader.h"
#import <UIKit/UIKit.h>
#import "BJCAImageCache.h"

static NSOperationQueue *queue;

@implementation BJCAWebImageDownloader

@synthesize url, target, action;

+(id)downloaderWithURL:(NSURL *)url target:(id)target action:(SEL)action
{
    BJCAWebImageDownloader *downloader = [[BJCAWebImageDownloader alloc] init];
    downloader.url = url;
    downloader.target = target;
    downloader.action = action;
    
    if (queue == nil)
    {
        queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = 8;
    }
    [queue addOperation:downloader];
    return downloader;
}

+(void)setMaxConcurrentDownloads:(NSUInteger)max
{
    if (queue == nil)
    {
        queue = [[NSOperationQueue alloc] init];
    }
    queue.maxConcurrentOperationCount = max;
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
        [[BJCAImageCache sharedImageCache] storeImage:image forKey:[url absoluteString]];
    }
}

@end
