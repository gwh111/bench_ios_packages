//
//  CC_SpriteItem.m
//  bench_ios
//
//  Created by gwh on 2019/5/23.
//  Copyright © 2019 apple. All rights reserved.
//

#import "CC_SpriteItem.h"

@interface CC_SpriteItem(){
    NSDictionary *pathJSON;//json data
    NSMutableArray *basePointMutList;//base PointList
    
    NSArray *actionList;
    NSMutableArray *actionPointMutList;
    int actionStepIndex;
    
    NSDate *lastStepDate;//last action finish time
    NSDate *lastDate;//last displayLink finish time 1/60
    
    int actionRepeat;
    int actionRepeatTimes;
    
    BOOL canPlay;
}

@end

@implementation CC_SpriteItem

@synthesize layer,scaleSize,speedRate,reverse,partName,origPoint;

- (instancetype)initOn:(UIView *)view withDic:(NSDictionary *)dic{
    if (self = [super init]) {
        
        [self initLayerOn:view];
        [self initPathWithDic:dic];
    }
    return self;
}

- (instancetype)initOn:(UIView *)view withDic:(NSDictionary *)dic scaleSize:(float)size speedRate:(float)rate{
    if (self = [super init]) {
        
        scaleSize=size;
        speedRate=rate;
        [self initLayerOn:view];
        [self initPathWithDic:dic];
    }
    return self;
}

- (void)initLayerOn:(UIView *)view{
    
    layer=[CAShapeLayer layer];
    layer.bounds=CGRectMake(0, 0, 100, 100);
    layer.position=CGPointMake(view.center.x, view.center.y-view.top);
    layer.strokeColor=[UIColor whiteColor].CGColor;
    layer.fillColor=[UIColor whiteColor].CGColor;
    layer.fillRule=kCAFillRuleEvenOdd;
    layer.lineJoin=kCALineCapRound;
    layer.lineCap=kCALineCapRound;
    layer.anchorPoint=CGPointMake(0, 0);
    [view.layer addSublayer:layer];
    
    origPoint=layer.position;
}

- (void)initPathWithDic:(NSDictionary *)dic{
    pathJSON=dic;
    
    partName=pathJSON[@"name"];
    NSArray *list=pathJSON[@"base"];
    basePointMutList=[[NSMutableArray alloc]init];
    for (int i=0; i<list.count/2; i++) {
        CGPoint p=CGPointMake([list[i*2]floatValue]*scaleSize, [list[i*2+1]floatValue]*scaleSize);
        [basePointMutList addObject:@(p)];
    }
    
    if (pathJSON[@"move"]) {
        float x=[pathJSON[@"move"][0]floatValue];
        float y=[pathJSON[@"move"][1]floatValue];
        for (int i=0; i<basePointMutList.count; i++) {
            if (i%2==0) {
                float v=[basePointMutList[i]floatValue];
                [basePointMutList replaceObjectAtIndex:i withObject:@(x+v)];
            }else{
                float v=[basePointMutList[i]floatValue];
                [basePointMutList replaceObjectAtIndex:i withObject:@(y+v)];
            }
        }
    }
    
    UIBezierPath *circleP = [UIBezierPath bezierPath];
    CGPoint p1=[basePointMutList[0]CGPointValue];
    [circleP moveToPoint:p1];
    for (int i=0; i<basePointMutList.count/2; i++) {
        CGPoint p_=[basePointMutList[i*2+1]CGPointValue];
        CGPoint p=[basePointMutList[i*2+2]CGPointValue];
        [circleP addQuadCurveToPoint:p controlPoint:p_];
    }
    CGPoint p_=[[basePointMutList lastObject]CGPointValue];
    CGPoint p=[basePointMutList[0]CGPointValue];
    [circleP addQuadCurveToPoint:p controlPoint:p_];
    
    layer.path = circleP.CGPath;
    
    [circleP removeAllPoints];
    circleP=nil;
}

- (BOOL)prepareAction:(NSString *)name times:(int)times{
    lastStepDate=nil;
    lastDate=nil;
    actionStepIndex=0;
    actionRepeat=0;
    actionRepeatTimes=times;
    actionList=[self getActionListWithName:name];
    CCLOG(@"actionList c=%lu",(unsigned long)actionList.count);
    if (!actionList) {
        CCLOG(@"error:no such action (%@)",name);
        canPlay=NO;
    }else{
        canPlay=YES;
    }
    return canPlay;
}

- (BOOL)prepareAction:(NSString *)name{
    return [self prepareAction:name times:0];
}

- (NSArray *)getActionListWithName:(NSString *)name{
    NSArray *actions=pathJSON[@"actions"];
    for (int i=0; i<actions.count; i++) {
        NSDictionary *action=actions[i];
        if ([action[@"name"]isEqualToString:name]) {
            return action[@"events"];
        }
    }
    return nil;
}

- (NSArray *)convertDeltaToAbsolute:(NSArray *)position{
    NSArray *baseArr=pathJSON[@"base"];
    NSMutableArray *absoluteMutArr=[[NSMutableArray alloc]init];
    for (int i=0; i<position.count/2; i++) {
        [absoluteMutArr addObject:@([baseArr[i*2]floatValue]+[position[i*2]floatValue])];
        [absoluteMutArr addObject:@([baseArr[i*2+1]floatValue]+[position[i*2+1]floatValue])];
    }
    return absoluteMutArr;
}

- (NSArray *)convertDeltaToReverse:(NSArray *)position{
    NSArray *baseArr=pathJSON[@"base"];
    NSArray *baseDeltaList=pathJSON[@"baseDelta"];
    NSMutableArray *absoluteMutArr=[[NSMutableArray alloc]init];
    for (int i=0; i<position.count/2; i++) {
        float plusx=0;
        if (baseDeltaList.count==baseArr.count) {
            plusx=[baseDeltaList[i*2]floatValue];
        }
        [absoluteMutArr addObject:@([baseArr[i*2]floatValue]+[position[i*2]floatValue]-plusx*2)];
        [absoluteMutArr addObject:@([baseArr[i*2+1]floatValue]+[position[i*2+1]floatValue])];
    }
    
    return absoluteMutArr;
}

- (nullable NSString *)changeEnd:(NSDate *)currentDate{
    if (canPlay==NO) {
        return nil;
    }
    
    if (!lastStepDate) {
        lastStepDate=currentDate;
    }
    if (!lastDate) {
        lastDate=currentDate;
        return nil;
    }
    
    NSTimeInterval lastInter=[CC_Date compareDate:currentDate cut:lastStepDate];
    
    NSDictionary *actionStep=actionList[actionStepIndex];
    NSDictionary *lastActionStep;
    if (actionStepIndex>0) {
        lastActionStep=actionList[actionStepIndex-1];
    }
    NSDictionary *nextActionStep;
    if (actionList.count>actionStepIndex+1) {
        nextActionStep=actionList[actionStepIndex+1];
    }
    
    float time=[actionStep[@"time"]floatValue]*speedRate+0.01;
    NSTimeInterval inter=[CC_Date compareDate:currentDate cut:lastStepDate];
    float percent;
    if (currentDate==lastStepDate) {
        percent=1;
    }else{
        percent=inter/time;
    }
    
    NSArray *listArr=actionStep[@"delta"];
    
    if (actionStep[@"reverse"]) {
        listArr=[self convertDeltaToReverse:listArr];
    }else{
        listArr=[self convertDeltaToAbsolute:listArr];
    }
    NSArray *lastListArr=lastActionStep[@"delta"];
    if (lastActionStep[@"reverse"]) {
        lastListArr=[self convertDeltaToReverse:lastListArr];
    }else{
        lastListArr=[self convertDeltaToAbsolute:lastListArr];
    }

    
    float moveX=0;
    float moveY=0;
    if (actionStep[@"move"]) {
        moveX=[actionStep[@"move"][0] floatValue];
        moveY=[actionStep[@"move"][1] floatValue];
    }
    
    float lastMoveX=0;
    float lastMoveY=0;
    if (lastActionStep[@"move"]) {
        lastMoveX=[lastActionStep[@"move"][0] floatValue];
        lastMoveY=[lastActionStep[@"move"][1] floatValue];
    }
    int test=0;
    if (actionStep[@"rotate"]||lastActionStep[@"rotate"]||test==1) {
        
        float deltax=(lastMoveX*(1-percent)+moveX*percent)*scaleSize;
        float deltay=(lastMoveY*(1-percent)+moveY*percent)*scaleSize;
        deltax=lastMoveX*scaleSize;
        deltay=lastMoveY*scaleSize;
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        layer.position=CGPointMake(origPoint.x+deltax, origPoint.y+deltay);
        [CATransaction commit];
        
        moveX=0;
        moveY=0;
        lastMoveX=0;
        lastMoveY=0;
    }else{
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        layer.position=CGPointMake(origPoint.x, origPoint.y);
        [CATransaction commit];
    }
    
    actionPointMutList=[[NSMutableArray alloc]init];
    for (int i=0; i<listArr.count/2; i++) {
        float x=([listArr[i*2]floatValue]
                 +moveX)*scaleSize;
        float y=([listArr[i*2+1]floatValue]+moveY)*scaleSize;
        float lastX=0;
        float lastY=0;
        if (lastListArr.count>0) {
            lastX=([lastListArr[i*2]floatValue]+lastMoveX)*scaleSize;
            lastY=([lastListArr[i*2+1]floatValue]+lastMoveY)*scaleSize;
        }else{
            percent=1;
        }
        if (reverse) {
            x=-x;
            lastX=-lastX;
        }
        CGPoint p;
        if ([lastActionStep[@"type"]isEqualToString:@"stay"]) {
            p=CGPointMake(lastX, lastY);
        }else{
            p=CGPointMake(lastX*(1-percent)+x*percent, lastY*(1-percent)+y*percent);
        }
        [actionPointMutList addObject:@(p)];
    }
    
    //draw
    UIBezierPath *circleP=[UIBezierPath bezierPath];
    CGPoint p1=[actionPointMutList[0]CGPointValue];
    [circleP moveToPoint:p1];
    for (int i=0; i<actionPointMutList.count/2; i++) {
        CGPoint p_=[actionPointMutList[i*2+1]CGPointValue];
        CGPoint p=[actionPointMutList[i*2+2]CGPointValue];
        [circleP addQuadCurveToPoint:p controlPoint:p_];
    }
    CGPoint p_=[[actionPointMutList lastObject]CGPointValue];
    CGPoint p=[actionPointMutList[0]CGPointValue];
    [circleP addQuadCurveToPoint:p controlPoint:p_];
    
    layer.path = circleP.CGPath;
    
    [circleP removeAllPoints];
    
    if (lastActionStep[@"hidden"]) {
        self.layer.path=nil;
    }
    
    lastDate=currentDate;
    
    if (lastInter>=time) {
        actionStepIndex++;
        if (actionStepIndex>=actionList.count) {
            actionStepIndex=1;
            if (actionRepeatTimes==0) {
                //infinity replay
            }else{
                actionRepeat++;
                if (actionRepeat==actionRepeatTimes) {
                    return @"finish";
                }
            }
        }else{
            
            if (nextActionStep[@"rotate"]) {
                
                CABasicAnimation *positionAnima = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
                positionAnima.toValue=@(M_PI*2);
                positionAnima.duration=[nextActionStep[@"rotate"][0]floatValue];
                positionAnima.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                positionAnima.repeatCount=[nextActionStep[@"rotate"][1]floatValue];
                positionAnima.removedOnCompletion = YES;
                positionAnima.fillMode=kCAFillModeForwards;
                
                [layer addAnimation:positionAnima forKey:@"rotate"];
            }
            
            if (actionStep[@"block"]) {
                lastDate=currentDate;
                lastStepDate=currentDate;
                CCLOG(@"pathJSONName=%@ actionStepIndex%d",pathJSON[@"name"],actionStepIndex);
                return actionStep[@"block"];
            }
        }
        lastStepDate=currentDate;
        
    }
    
    return nil;
}

@end
