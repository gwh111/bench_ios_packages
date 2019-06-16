//
//  CC_SpriteBaseView.h
//  bench_ios
//
//  Created by gwh on 2019/5/20.
//  Copyright © 2019 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CC_SpriteBaseView;
@protocol CC_SpriteBaseViewDelegate <NSObject>
- (void)spriteBaseView:(CC_SpriteBaseView *)baseView touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)spriteBaseView:(CC_SpriteBaseView *)baseView touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
- (void)spriteBaseView:(CC_SpriteBaseView *)baseView touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;
@end

@interface CC_SpriteBaseView : UIView

@property(nonatomic,strong) id <CC_SpriteBaseViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
