//
//  BJCAWebImageDownloader.h
//  test
//
//  Created by Chenfy on 2021/2/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJCAWebImageDownloader : NSOperation

{
    NSURL *url;
    id target;
    SEL action;
}

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;

+(id)downloaderWithURL:(NSURL *)url target:(id)target action:(SEL)action;
+(void)setMaxConcurrentDownloads:(NSUInteger)max;

@end

NS_ASSUME_NONNULL_END
