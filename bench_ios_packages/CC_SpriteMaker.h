//
//  CC_SpriteMaker.h
//  bench_ios
//
//  Created by gwh on 2019/5/19.
//  Copyright © 2019 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CC_SpriteBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@class CC_SpriteMaker;
@protocol CC_SpriteMakerDelegate <NSObject>
- (void)spriteMaker:(CC_SpriteMaker *)maker didSelectActionAtIndex:(int)index name:(NSString *)name;
- (void)spriteMaker:(CC_SpriteMaker *)maker didSelectStepAtIndex:(int)index;
- (void)spriteMaker:(CC_SpriteMaker *)maker addActionWithName:(NSString *)name;
- (void)spriteMakerCopyAction:(CC_SpriteMaker *)maker;
- (void)spriteMaker:(CC_SpriteMaker *)maker deleteActionWithName:(NSString *)name;
- (void)spriteMaker:(CC_SpriteMaker *)maker renameActionWithName:(NSString *)name;
@end

@interface CC_SpriteMaker : NSObject

@property(nonatomic,retain) CC_SpriteBaseView *baseView;
@property(nonatomic,retain) CAShapeLayer *layer;

@property(nonatomic,retain) NSMutableDictionary *pathJSON;
@property(nonatomic,strong) id <CC_SpriteMakerDelegate>delegate;

- (instancetype)initOn:(UIView *)view withFile:(NSDictionary *)fileDic;
- (void)updateBaseViewOn:(UIView *)view;
- (void)preview;
- (void)edit;
- (void)play;
- (void)stop;
- (void)step:(int)index;
- (void)addLastStep;
- (void)addStep:(int)step mirror:(int)mirror;
- (void)copyStepTo:(int)step;
- (void)addFirtStep;
- (void)addActionWithName:(NSString *)name;
- (void)deleteActionWithName:(NSString *)name;
- (void)renameActionWithName:(NSString *)name;
- (void)moveStep:(NSArray *)texts;
- (void)moveSteps:(NSArray *)texts;
- (void)delay:(NSString *)text;
- (void)stay:(BOOL)isStay;
- (void)reverse:(BOOL)isReverse;
- (void)addBlock:(NSString *)name;
- (void)removeBlock;
- (void)hiddenPoints;
- (void)action:(NSString *)name;
- (void)cutStep;
- (void)scaleRate:(float)rate;
- (void)copyAction;
- (NSDictionary *)getInfo;

@end

NS_ASSUME_NONNULL_END
