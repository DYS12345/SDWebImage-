//
//  ViewController.h
//  test
//
//  Created by Chenfy on 2021/1/14.
//

#import <UIKit/UIKit.h>

@protocol ViewControllerDelegate <NSObject>

-(void)setVideo:(NSArray *)ary;

@end

@interface ViewController : UIViewController

@property (nonatomic, weak) id <ViewControllerDelegate> delegate;

@end

