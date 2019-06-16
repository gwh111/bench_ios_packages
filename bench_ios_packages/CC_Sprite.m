//
//  CC_Sprite.m
//  bench_ios
//
//  Created by gwh on 2019/5/16.
//  Copyright © 2019 apple. All rights reserved.
//

#import "CC_Sprite.h"
#import "CC_SpriteItem.h"

@interface CC_Sprite(){
    NSMutableArray *pathList;
    CADisplayLink *displayLink;//timer
    
    UIView *deskV;
    float scaleSize;
    float speedRate;
    
    CGPoint tempPoint;
    NSDictionary *tempColor;
    
    void (^finishBlock)(NSString *state, CC_Sprite *sprite);
}

@end

@implementation CC_Sprite
@synthesize items;

- (instancetype)initOn:(UIView *)view withFilePath:(NSString *)fileName scaleSize:(float)size speedRate:(float)rate{
    if (self = [super init]) {
        
        deskV=view;
        scaleSize=size;
        speedRate=rate;
        items=[[NSMutableArray alloc]init];
        NSString *file=[ccs getFileWithPath:fileName andType:@"json"];
        if (!file) {
            file=[ccs getLocalFileWithPath:fileName andType:@"json"];
        }
        pathList=[NSMutableArray arrayWithArray:[CC_Convert dictionaryWithJsonString:file]];
        for (int i=0; i<pathList.count; i++) {
            CC_SpriteItem *item=[[CC_SpriteItem alloc]initOn:deskV withDic:pathList[i]scaleSize:scaleSize speedRate:speedRate];
            [items addObject:item];
        }
        file=nil;
    }
    return self;
}

- (void)playAction:(NSString *)name block:(void(^)(NSString *state, CC_Sprite *sprite))block{
    [self playAction:name times:0 block:block];
}

- (void)playAction:(NSString *)name times:(int)times block:(nullable void(^)(NSString *state, CC_Sprite *sprite))block{
    
    finishBlock=block;
    
    for (int i=0; i<items.count; i++) {
        CC_SpriteItem *item=items[i];
        [item prepareAction:name times:times];
    }
    
    [self stop];
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(changeEnd)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)updateSpeed:(float)speed{
    speedRate=speed;
    for (int i=0; i<items.count; i++) {
        CC_SpriteItem *item=items[i];
        item.speedRate=speed;
    }
}

- (void)updateScale:(float)scale{
    scaleSize=scale;
    for (int i=0; i<items.count; i++) {
        CC_SpriteItem *item=items[i];
        item.scaleSize=scale;
    }
}

- (void)updateReverse:(BOOL)reverse{
    for (int i=0; i<items.count; i++) {
        CC_SpriteItem *item=items[i];
        item.reverse=reverse;
    }
}

- (void)updatePosition:(CGPoint)position{
    tempPoint=position;
    for (int i=0; i<items.count; i++) {
        CC_SpriteItem *item=items[i];
        item.layer.position=position;
        item.origPoint=position;
    }
}

- (void)updateColors:(NSDictionary *)colorDic{
    tempColor=colorDic;
    for (int i=0; i<items.count; i++) {
        CC_SpriteItem *item=items[i];
        if (colorDic[item.partName]) {
            UIColor *color=colorDic[item.partName];
            item.layer.strokeColor=color.CGColor;
            item.layer.fillColor=color.CGColor;
        }
    }
}

- (CGPoint)getPosition{
    return tempPoint;
}

- (NSArray *)getActionNames{
    if (pathList.count==0) {
        return nil;
    }
    NSDictionary *partDic=pathList[0];
    NSArray *actions=partDic[@"actions"];
    NSMutableArray *actionNames=[[NSMutableArray alloc]init];
    for (int i=0; i<actions.count; i++) {
        [actionNames addObject:actions[i][@"name"]];
    }
    return actionNames;
}

- (void)updateBaseListWithFilePath:(NSString *)fileName{
    NSString *file=[ccs getFileWithPath:fileName andType:@"json"];
    if (!file) {
        file=[ccs getLocalFileWithPath:fileName andType:@"json"];
    }
    NSArray *list=[CC_Convert dictionaryWithJsonString:file];
    
    if (list.count<=0) {
        CCLOG(@"error:empty part");
        return;
    }
    
    [self remove];
    for (int i=0; i<pathList.count; i++) {
        if (i>=list.count) {
            break;
        }
        NSDictionary *tempDic=list[i];
        NSMutableDictionary *pathMutDic=[NSMutableDictionary dictionaryWithDictionary:pathList[i]];
        NSArray *baseList=pathMutDic[@"base"];
        //存储原始模型副本
        if (pathMutDic[@"baseOri"]) {
            baseList=pathMutDic[@"baseOri"];
        }else{
            [pathMutDic setObject:baseList forKey:@"baseOri"];
        }
        NSArray *tempBase=tempDic[@"base"];
        NSMutableArray *baseDelta=[[NSMutableArray alloc]init];
        for (int i=0; i<baseList.count; i++) {
            float delta=[tempBase[i]floatValue]-[baseList[i]floatValue];
            [baseDelta addObject:ccstr(@"%.1f",delta)];
        }
        [pathMutDic setObject:baseDelta forKey:@"baseDelta"];
        [pathMutDic setObject:tempDic[@"base"] forKey:@"base"];
        [pathList replaceObjectAtIndex:i withObject:pathMutDic];
    }
    
    items=[[NSMutableArray alloc]init];
    for (int i=0; i<pathList.count; i++) {
        CC_SpriteItem *item=[[CC_SpriteItem alloc]initOn:deskV withDic:pathList[i]scaleSize:scaleSize speedRate:speedRate];
        [items addObject:item];
    }
    
    [self updatePosition:tempPoint];
    [self updateColors:tempColor];
}

- (void)updateBasePartWithFilePath:(NSString *)fileName{
    
    NSString *file=[ccs getFileWithPath:fileName andType:@"json"];
    if (!file) {
        file=[ccs getLocalFileWithPath:fileName andType:@"json"];
    }
    NSArray *list=[CC_Convert dictionaryWithJsonString:file];
    
    if (list.count<=0) {
        CCLOG(@"error:empty part");
        return;
    }
    NSString *name=list[0][@"name"];
    for (int i=0; i<pathList.count; i++) {
        NSDictionary *part=pathList[i];
        if ([part[@"name"]isEqualToString:name]) {
            [pathList removeObjectAtIndex:i];
            CC_SpriteItem *item=items[i];
            [item.layer removeFromSuperlayer];
            [items removeObjectAtIndex:i];
        }
    }
    [pathList addObject:list[0]];
    
    CC_SpriteItem *item=[[CC_SpriteItem alloc]initOn:deskV withDic:list[0] scaleSize:scaleSize speedRate:speedRate];
    [items addObject:item];
    
    [self updatePosition:tempPoint];
    [self updateColors:tempColor];
}

- (void)removePart:(NSString *)name{
    for (int i=0; i<pathList.count; i++) {
        NSDictionary *part=pathList[i];
        if ([part[@"name"]isEqualToString:name]) {
            [pathList removeObjectAtIndex:i];
            CC_SpriteItem *item=items[i];
            [item.layer removeFromSuperlayer];
            [items removeObjectAtIndex:i];
            return;
        }
    }
}

- (void)stop{
    [displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [displayLink invalidate];
    displayLink=nil;
}

- (void)remove{
    [self stop];
    for (int i=0; i<items.count; i++) {
        CC_SpriteItem *item=items[i];
        [item.layer removeFromSuperlayer];
    }
    items=nil;
}

- (void)changeEnd{
    
    NSDate *date=[NSDate date];
    for (int i=0; i<items.count; i++) {
        CC_SpriteItem *item=items[i];
        NSString *state=[item changeEnd:date];
        if (!state||i>0) {
            continue;
        }
        if ([state isEqualToString:@"finish"]) {
            [self stop];
            if (finishBlock) {
                finishBlock(state,self);
                finishBlock=nil;
            }
        }else{
            if (finishBlock) {
                finishBlock(state,self);
            }
        }
    }
    
}

@end
