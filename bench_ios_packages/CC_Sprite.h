//
//  CC_Sprite.h
//  bench_ios
//
//  Created by gwh on 2019/5/16.
//  Copyright © 2019 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CC_Sprite : NSObject

@property(nonatomic,retain) NSMutableArray *items;

- (instancetype)initOn:(UIView *)view withFilePath:(NSString *)fileName scaleSize:(float)size speedRate:(float)rate;

- (void)updatePosition:(CGPoint)position;
- (void)updateColors:(NSDictionary *)colorDic;
- (void)updateScale:(float)scale;
- (void)updateSpeed:(float)speed;
- (void)updateReverse:(BOOL)reverse;

- (CGPoint)getPosition;

//update all parts' base point
- (void)updateBaseListWithFilePath:(NSString *)fileName;
//update one part's base point, like weapon, clothes
- (void)updateBasePartWithFilePath:(NSString *)fileName;
- (void)removePart:(NSString *)name;
- (NSArray *)getActionNames;

//repeat=0 infinity replay
- (void)playAction:(NSString *)name times:(int)times block:(nullable void(^)(NSString *state, CC_Sprite *sprite))block;

- (void)stop;
- (void)remove;

@end

NS_ASSUME_NONNULL_END
