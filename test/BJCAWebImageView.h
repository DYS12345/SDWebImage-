//
//  BJCAWebImageView.h
//  test
//
//  Created by Chenfy on 2021/2/17.
//

#import <UIKit/UIKit.h>

@class BJCAWebImageDownloader;

NS_ASSUME_NONNULL_BEGIN

@interface BJCAWebImageView : UIImageView

{
    UIImage *placeHolderImage;
    BJCAWebImageDownloader *currentOperation;
}

-(void)setImageWithURL:(NSURL *)url;
-(void)downloadFinishedWithImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
