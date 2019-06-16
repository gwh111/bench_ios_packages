//
//  CC_SpriteBaseView.m
//  bench_ios
//
//  Created by gwh on 2019/5/20.
//  Copyright © 2019 apple. All rights reserved.
//

#import "CC_SpriteBaseView.h"

@implementation CC_SpriteBaseView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if ([self.delegate respondsToSelector:@selector(spriteBaseView:touchesBegan:withEvent:)]) {
        [self.delegate spriteBaseView:self touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if ([self.delegate respondsToSelector:@selector(spriteBaseView:touchesMoved:withEvent:)]) {
        [self.delegate spriteBaseView:self touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if ([self.delegate respondsToSelector:@selector(spriteBaseView:touchesEnded:withEvent:)]) {
        [self.delegate spriteBaseView:self touchesEnded:touches withEvent:event];
    }
}

@end
