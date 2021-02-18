//
//  BJCAWebImageView.h
//  test
//
//  Created by Chenfy on 2021/2/17.
//

#import <UIKit/UIKit.h>

@class BJCAWebImageDownloadOperation;

NS_ASSUME_NONNULL_BEGIN

@interface BJCAWebImageView : UIImageView

{
    UIImage *placeHolderImage;
    BJCAWebImageDownloadOperation *currentOperation;
}

-(void)setImageWithURL:(NSURL *)url;
-(void)downloadFinishedWithImage:(UIImage *)image;

@end

@interface BJCAWebImageDownloadOperation : NSOperation

{
    NSURL *url;
    BJCAWebImageView *delegate;
}

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, weak) BJCAWebImageView *delegate;

-(id)initWithURL:(NSURL *)url delegate:(BJCAWebImageView *)delegate;

@end

NS_ASSUME_NONNULL_END
