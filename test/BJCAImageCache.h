//
//  BJCAImageCache.h
//  test
//
//  Created by Chenfy on 2021/2/17.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BJCAImageCache : NSObject

{
    NSMutableDictionary *memCache;
    NSString *diskCachePath;
    NSOperationQueue *cacheInQueue;
}

+(BJCAImageCache *)sharedImageCache;
//存储图片
-(void)storeImage:(UIImage *)image forKey:(NSString *)key;
-(void)storeImage:(UIImage *)image foeKey:(NSString *)key toDisk:(BOOL)toDisk;
//获取图片的方法
-(UIImage *)imageFromKey:(NSString *)key;
-(UIImage *)imageFromKey:(NSString *)key fromDisk:(BOOL)fromDisk;
//删除图片的方法
-(void)removeImageFrokey:(NSString *)key;

-(void)clearMemory;
-(void)clearDisk;
-(void)cleanDisk;

@end

NS_ASSUME_NONNULL_END
