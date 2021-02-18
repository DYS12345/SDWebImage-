//
//  BJCAImageCache.m
//  test
//
//  Created by Chenfy on 2021/2/17.
//

#import "BJCAImageCache.h"
/**
 常用的摘要算法，比如MD5，SHA1等。
 摘要算法就是，一种能产生特殊输出格式的算法，无论内容长度是多少，最后输出的都是同样的长度。
 */
#import <CommonCrypto/CommonDigest.h>
/**
 定义一个星期的时间；
 用static定义局部变量为静态变量，在函数调用结束之后不释放继续保留值。
 */
static NSInteger cacheMaxCacheAge = 60 * 60 * 24 * 7;
static BJCAImageCache *instance;

@implementation BJCAImageCache

#pragma mark NSObject
-(instancetype)init
{
    if (self = [super init])
    {
        memCache = [[NSMutableDictionary alloc] init];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        diskCachePath = [paths[0] stringByAppendingPathComponent:@"ImageCache"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:diskCachePath])
        {
            //创建目录
            [[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath attributes:nil];
        }
        
        cacheInQueue = [[NSOperationQueue alloc] init];
        cacheInQueue.maxConcurrentOperationCount = 2;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReciveMemoryWaring) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willTerminate) name:UIApplicationWillTerminateNotification object:nil];
    }
    
    return self;
}

-(void)dealloc
{
    //不要写超类的方法
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}

/**
 程序将要终止的时候,将磁盘清空
 */
-(void)willTerminate
{
    [self cleanDisk];
}

/**
 收到了内存警告*/
-(void)didReciveMemoryWaring
{
    [self clearMemory];
}

#pragma mark ImageCache (private)
-(NSString *)cachePathForKey:(NSString *)key
{
    //const char 是表示常量型的字符
    const char *str = [key UTF8String];
    //表示无符号的字符类型
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    //MD5加密
    CC_MD5(str, strlen(str), r);
    //x表示以十六进制形式输出，02表示不足两位前面补0，超过两位不影响。
    NSString *fileName = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", r[0],r[1],r[2],r[3],r[4],r[5],r[6],r[7],r[8],r[9],r[10],r[11],r[12],r[13],r[14],r[15]];
    return [diskCachePath stringByAppendingPathComponent:fileName];
}

#pragma mark ImageCache
+(BJCAImageCache *)sharedImageCache
{
    if (instance == nil)
    {
        instance = [[BJCAImageCache alloc] init];
    }
    return instance;
}

-(void)storeKeyToDisk:(NSString *)key
{
    UIImage *image = [self imageFromKey:key fromDisk:YES];
    if (image != nil)
    {
        /**
         iOS中有两种转化图片的简单方法：
         1、UIImageJPEGRepresentation 图片、压缩系数。
         压缩后图片较小，图片质量也无较大差异，日常中主要用这个方法
         2、UIImagePNGRepresentation 图片
         压缩图片的图片较大
         */
        [[NSFileManager defaultManager] createFileAtPath:[self cachePathForKey:key] contents:UIImageJPEGRepresentation(image, 1.0) attributes:nil];
    }
}

-(void)storeImage:(UIImage *)image forKey:(NSString *)key
{
    [self storeImage:image foeKey:key toDisk:YES];
}

-(void)storeImage:(UIImage *)image foeKey:(NSString *)key toDisk:(BOOL)toDisk
{
    if (image == nil)
    {
        return;
    }
    [memCache setObject:image forKey:key];
    
    if (toDisk)
    {
        NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(storeKeyToDisk:) object:key];
        [cacheInQueue addOperation:invocationOperation];
    }
}

-(UIImage *)imageFromKey:(NSString *)key
{
    return [self imageFromKey:key fromDisk:YES];
}

-(UIImage *)imageFromKey:(NSString *)key fromDisk:(BOOL)fromDisk
{
    UIImage *image = [memCache objectForKey:key];
    if (!image && fromDisk)
    {
        image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:[self cachePathForKey:key]]];
        if (image != nil)
        {
            [memCache setObject:image forKey:key];
        }
    }
    return image;
}

-(void)removeImageFrokey:(NSString *)key
{
    [memCache removeObjectForKey:key];
    [[NSFileManager defaultManager] removeItemAtPath:[self cachePathForKey:key] error:nil];
}

-(void)clearMemory
{
    [cacheInQueue cancelAllOperations];
    [memCache removeAllObjects];
}

-(void)clearDisk
{
    [cacheInQueue cancelAllOperations];
    [[NSFileManager defaultManager] removeItemAtPath:diskCachePath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath attributes:nil];
}

-(void)cleanDisk
{
    //从现在开始的-7天
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-cacheMaxCacheAge];
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:diskCachePath];
    //可以枚举指定目录中的每个文件
    for (NSString *fileName in fileEnumerator)
    {
        NSString *filePath = [diskCachePath stringByAppendingFormat:fileName];
        //获取文件的大小。创建时间等属性。
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        /**
         获取文件的修改时间；
         获取两个时间中较晚的那个时间；
         */
        if ([[[attrs fileModificationDate] laterDate:expirationDate] isEqualToDate:expirationDate])
        {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
    }
}

@end
