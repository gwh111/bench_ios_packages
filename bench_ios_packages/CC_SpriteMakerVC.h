//
//  CC_SpriteMakerVC.h
//  bench_ios
//
//  Created by gwh on 2019/5/20.
//  Copyright © 2019 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CC_SpriteMakerVC : UIViewController

@property (nonatomic,retain) UIViewController *fromVC;

+ (void)presentOnVC:(UIViewController *)vc;
+ (void)presentVC;

@end

NS_ASSUME_NONNULL_END
