//
//  BJCAWebImageView.m
//  test
//
//  Created by Chenfy on 2021/2/17.
//

#import "BJCAWebImageView.h"
#import "BJCAImageCache.h"

static NSOperationQueue *downloadQueue;
static NSOperationQueue *cacheInQueue;

@implementation BJCAWebImageView

#pragma mark RemoteImageView
-(void)setImageWithURL:(NSURL *)url
{
    if (currentOperation != nil)
    {
        [currentOperation cancel];//从队列中删除
        currentOperation = nil;
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
        if (downloadQueue == nil)
        {
            downloadQueue = [[NSOperationQueue alloc] init];
            [downloadQueue setMaxConcurrentOperationCount:8];
        }
        currentOperation = [[BJCAWebImageDownloadOperation alloc] initWithURL:url delegate:self];
        [downloadQueue addOperation:currentOperation];
    }
}

-(void)downloadFinishedWithImage:(UIImage *)image
{
    self.image = image;
    currentOperation = nil;
}

@end

@implementation BJCAWebImageDownloadOperation

@synthesize url, delegate;

-(id)initWithURL:(NSURL *)url delegate:(BJCAWebImageView *)delegate
{
    if (self = [super init])
    {
        self.url = url;
        self.delegate = delegate;
    }
    return self;
}

/**
 NSOperation有两个方法，main()和start()。如果想使用同步，就把逻辑写在main方法中，
 如果想使用异步，就写在start方法中。
 */
-(void)main
{
    if (self.isCancelled)
    {
        return;
    }
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    UIImage *image = [[UIImage alloc] initWithData:data];
    
    if (!self.isCancelled)
    {
        [delegate performSelectorOnMainThread:@selector(downloadFinishedWithImage:) withObject:image waitUntilDone:YES];
    }
    
    if (cacheInQueue == nil)
    {
        cacheInQueue = [[NSOperationQueue alloc] init];
        [cacheInQueue setMaxConcurrentOperationCount:2];
    }
    
    NSString *cacheKey = [url absoluteString];
    BJCAImageCache *imageCache = [BJCAImageCache sharedImageCache];
    //现在将图片写入缓存中，不需要等待缓存写入操作队列完成
    [imageCache storeImage:image foeKey:cacheKey toDisk:NO];
    //将下一个缓存操作设置成命令对象，以避免影响下一个下载错误
    NSInvocation *cacheInINvocation = [NSInvocation invocationWithMethodSignature:[[imageCache class] instanceMethodSignatureForSelector:@selector(storeImage:forKey:)]];
    [cacheInINvocation setTarget:imageCache];
    [cacheInINvocation setSelector:@selector(storeImage:forKey:)];
    [cacheInINvocation setArgument:&image atIndex:2];
    [cacheInINvocation setArgument:&cacheKey atIndex:3];
    [cacheInINvocation retainArguments];
    NSInvocationOperation *cacheInOperation = [[NSInvocationOperation alloc] initWithInvocation:cacheInINvocation];
    
    [cacheInQueue addOperation:cacheInOperation];
}

@end
