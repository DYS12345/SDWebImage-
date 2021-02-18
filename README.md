这个库是根据SDWebImage库进行的重写，根据原作者的提交记录，一步一步的去重新实现，一个学习和记录的过程。

这个库提供了一个UIImageView的替换物，支持从web远程拿图像。

这个库提供了以下功能：
- 异步下载图片
- 可以直接替换原有的UIImageView使用
- 提供内存、磁盘缓存图片
- 使用NSOperation并行下载和缓存图片

使用LRU算法清除内存缓存，也就是在收到内存警告的时候，将文件修改的日期与过去7天作比较，磁盘里的文件大于7天未修改的话就会被清除，而不是在收到内存警告的时候，全部清除。

用法示例：

###BJCAImageView作为UIImageView的替代

最常见的用法是和UITableView的结合使用：

- 在Interface Builder中将UIImageView作为UITableViewCell的子视图；
- 在标识面板中，将类名设置成BJCAWebImageView；
- 从bundle中设置一个图片作为占位图；
- 在tableview:cellForRowAtIndexPath:方法中，把要下载图片的url通过调用setImageWithURL方法传进去，

所有的事情都会被处理，从并行下载到缓存管理。

###异步图像下载器

可以独立的使用继承自NSOperation的图像下载器。只需要创建一个BJCAWebImageDownloader实例，使用它的构造函数：

downloader = [BJCAWebImageDownloader downloaderWithURL:url target:self action:@selector(downloadFinishedWithImage:)];

下载将会被立即排队执行，downloadFinishedWithImage:方法将会在图像下载完成后被调用，需要注意，有可能是在非主线程下。

###异步图像存储

可以单数使用基于NSOperation的图像缓存存储。BJCAImageCache有一个内存缓存和一个可选的磁盘缓存。磁盘缓存写入操作是异步执行的，不会给UI增加不必要的延迟。

BJCAImageCache类为了方便使用，创建了一个单例方法，但是如果你想要有自己的缓存名称空间，可以自己创建该类的实例。

要查找缓存的图像，可以使用imageForKey:方法。如果返回的是nil，意味着缓存当前并不拥有图像。因此，我们需要生成并缓存它。缓存键key是要缓存的图像的应用程序唯一标识。它通常是图像的绝对URL。

UIImage *cachedImage = [[BJCAImageCache sharedImageCache] imageFromKey:[url absoluteString]];

默认情况下，在缓存中找不到图像，会继续在磁盘中查找，也可以直接使用-(UIImage *)imageFromKey:(NSString *)key fromDisk:(BOOL)fromDisk;方法。

将图片存储到缓存中，可以使用-(void)storeImage:(UIImage *)image forKey:(NSString *)key;方法。

默认情况下，图像将存储在内存中和异步存储在磁盘中。如果只想要内存缓存可以使用-(void)storeImage:(UIImage *)image foeKey:(NSString *)key toDisk:(BOOL)toDisk;方法，将toDisk参数设为NO。




