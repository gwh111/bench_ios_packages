//
//  CC_SpriteItem.h
//  bench_ios
//
//  Created by gwh on 2019/5/23.
//  Copyright © 2019 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CC_SpriteItem : NSObject

@property(nonatomic,retain) CAShapeLayer *layer;
@property(nonatomic,assign) float speedRate;
@property(nonatomic,assign) float scaleSize;
@property(nonatomic,assign) BOOL reverse;
@property(nonatomic,retain) NSString *partName;//part name
@property(nonatomic,assign) CGPoint origPoint;

- (instancetype)initOn:(UIView *)view withDic:(NSDictionary *)dic;
- (instancetype)initOn:(UIView *)view withDic:(NSDictionary *)dic scaleSize:(float)size speedRate:(float)rate;

- (BOOL)prepareAction:(NSString *)name;
- (BOOL)prepareAction:(NSString *)name times:(int)times;

- (nullable NSString *)changeEnd:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
