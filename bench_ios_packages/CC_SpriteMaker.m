//
//  CC_SpriteMaker.m
//  bench_ios
//
//  Created by gwh on 2019/5/19.
//  Copyright © 2019 apple. All rights reserved.
//

#import "CC_SpriteMaker.h"
#import "CC_AutoLabelGroup.h"

@interface CC_SpriteMaker()<CC_AutoLabelGroupDelegate,CC_SpriteBaseViewDelegate>{
    
    
    NSMutableArray *basePointMutList;
    
    //    NSArray *actionList;
    NSMutableArray *actionPointMutList;
    int actionStepIndex;
    NSDate *lastDate;
    NSDate *lastPathDate;
    
    UIScrollView *scrollV;
    
    NSString *currentActionName;
    int currentActionIndex;
    int currentIndex;
    
    CC_View *move_an;
    CC_View *move_to;
    
    CALayer *move_now;
    int move_index;
    NSMutableArray *moveMutArr;
    
    int actionRepeat;
    
    CADisplayLink *displayLink;
    
    UILabel *timeL;
    UITextView *moveTextV;
}

@end

@implementation CC_SpriteMaker
@synthesize baseView,layer,pathJSON;

- (instancetype)initOn:(UIView *)view withFile:(NSDictionary *)fileDic{
    if (self = [super init]) {
        
        [self initBaseViewOn:view];
        [self initPathWithName:fileDic];
        [self initLayer];
    }
    return self;
}

- (void)initBaseViewOn:(UIView *)view{
    baseView=[[CC_SpriteBaseView alloc]initWithFrame:view.frame];
    baseView.top=0;
    baseView.left=0;
    baseView.delegate=self;
    baseView.backgroundColor=ccRGBA(0, 0, 0, .3);
    [view addSubview:baseView];
}

- (void)updateBaseViewOn:(UIView *)view{
    baseView.frame=view.frame;
    baseView.top=0;
    baseView.left=0;
    layer.position=CGPointMake(baseView.center.x, baseView.height/2+RH(50));
    
    timeL.top=baseView.height-RH(50);
    moveTextV.top=baseView.height-RH(50);
}

- (void)initPathWithName:(NSDictionary *)fileDic{
    
    pathJSON=[NSMutableDictionary dictionaryWithDictionary:fileDic];
    
}

- (void)preview{
    baseView.backgroundColor=ccRGBA(0, 0, 0, 0);
    layer.fillColor      = COLOR_WHITE.CGColor;
}

- (void)edit{
    baseView.backgroundColor=ccRGBA(0, 0, 0, .3);
    layer.fillColor      = [UIColor clearColor].CGColor;
}

- (void)play{
    actionStepIndex=0;
    [displayLink invalidate];
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(changeEnd)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)stop{
    [displayLink invalidate];
}

- (void)step:(int)index{
    
    currentIndex=index;
    CC_AutoLabelGroup *group=[scrollV viewWithName:@"list"];
    [group clearSelect];
    [group updateSelect:YES atIndex:index];
    
    [self updateTimeL];
    
    [self updateActionPointListWithIndex:index];
    if (layer.sublayers.count>0) {
        [self updatePoint];
    }
    [self updateDraw];
}

- (void)updateTimeL{
    float currentTime=[[self getActionListWithName:currentActionName][currentIndex-1][@"time"]floatValue];
    float totalTime=0;
    for (int i=0; i<currentIndex; i++) {
        totalTime=totalTime+[[self getActionListWithName:currentActionName][i][@"time"]floatValue];
    }
    timeL.text=[NSString stringWithFormat:@"%.2f / %.2f",currentTime,totalTime];
}

- (void)addLastStep{
    [self addLastActionStep];
    [self updateActionPointListWithIndex:currentIndex];
    [self updatePoint];
    [self updateDraw];
}

- (void)addStep:(int)step mirror:(int)mirror{
    [self addActionStep:step mirror:mirror];
    [self updateActionPointListWithIndex:currentIndex];
    [self updatePoint];
    [self updateDraw];
}

- (void)addFirtStep{
    [self addBaseActionStep];
    [self updateActionPointListWithIndex:currentIndex];
    [self updatePoint];
    [self updateDraw];
}

- (void)copyStepTo:(int)step{
    [self copyActionStepTo:step];
}

- (void)addActionWithName:(NSString *)name{
    currentActionName=name;
    NSMutableArray *actions=[NSMutableArray arrayWithArray:pathJSON[@"actions"]];
    [actions addObject:@{@"name":name,@"delta":@[]}];
    [pathJSON setObject:actions forKey:@"actions"];
    [self updateActionStepListWithSelectIndex:0];
    [self updateActionNamesWithActionName:name];
}

- (void)copyAction{
    NSMutableArray *actions=[NSMutableArray arrayWithArray:pathJSON[@"actions"]];
    NSDictionary *copyDic=[[NSDictionary alloc]initWithDictionary:actions[currentActionIndex]];
    [actions addObject:copyDic];
    [pathJSON setObject:actions forKey:@"actions"];
    [self updateActionStepListWithSelectIndex:0];
    [self updateActionNamesWithActionName:currentActionName];
}

- (void)renameActionWithName:(NSString *)name{
    NSMutableArray *actions=[NSMutableArray arrayWithArray:pathJSON[@"actions"]];
    for (int i=0; i<actions.count; i++) {
        NSMutableDictionary *action=[NSMutableDictionary dictionaryWithDictionary:actions[i]];
        if ([action[@"name"]isEqualToString:currentActionName]) {
            [action setObject:name forKey:@"name"];
            [actions replaceObjectAtIndex:i withObject:action];
            [pathJSON setObject:actions forKey:@"actions"];
            [self updateActionNamesWithActionName:name];
            return;
        }
    }
}

- (void)deleteActionWithName:(NSString *)name{
    NSMutableArray *actions=[NSMutableArray arrayWithArray:pathJSON[@"actions"]];
    for (int i=0; i<actions.count; i++) {
        NSDictionary *action=actions[i];
        if ([action[@"name"]isEqualToString:name]) {
            [actions removeObjectAtIndex:i];
            [pathJSON setObject:actions forKey:@"actions"];
            [self updateActionStepListWithSelectIndex:0];
            [self updateActionNamesWithActionName:name];
            return;
        }
    }
}

- (void)moveStep:(NSArray *)texts{
    float x=[texts[0]floatValue];
    float y=[texts[1]floatValue];
    if (currentIndex==0) {
        NSMutableArray *deltaMutArr=[NSMutableArray arrayWithArray:pathJSON[@"base"]];
        for (int i=0; i<deltaMutArr.count; i++) {
            float pos=[deltaMutArr[i]floatValue];
            if (i%2==0) {
                pos=pos+x;
            }else{
                pos=pos+y;
            }
            [deltaMutArr replaceObjectAtIndex:i withObject:@(pos)];
        }
        [pathJSON setObject:deltaMutArr forKey:@"base"];
    }else{
        NSMutableArray *actionMutList=[NSMutableArray arrayWithArray:[self getActionListWithName:currentActionName]];
        NSMutableDictionary *actionDic=[NSMutableDictionary dictionaryWithDictionary:actionMutList[currentIndex-1]];
        NSMutableArray *deltaMutArr=[NSMutableArray arrayWithArray:actionDic[@"delta"]];
        for (int i=0; i<deltaMutArr.count; i++) {
            float pos=[deltaMutArr[i]floatValue];
            if (i%2==0) {
                pos=pos+x;
            }else{
                pos=pos+y;
            }
            [deltaMutArr replaceObjectAtIndex:i withObject:@(pos)];
        }
        [actionDic setObject:deltaMutArr forKey:@"delta"];
        [actionMutList replaceObjectAtIndex:currentIndex-1 withObject:actionDic];
        [self setActionListWithName:currentActionName actionList:actionMutList];
    }
    if (currentIndex>0) {
        [self step:currentIndex];
    }else{
        [self updateBasePointList];
        [self base];
    }
}

- (void)moveSteps:(NSArray *)texts{
    float x=[texts[0]floatValue];
    float y=[texts[1]floatValue];
    if (currentIndex==0) {
        [pathJSON setObject:@[@(x),@(y)] forKey:@"move"];
    }else{
        NSMutableArray *actionMutList=[NSMutableArray arrayWithArray:[self getActionListWithName:currentActionName]];
        NSMutableDictionary *actionDic=[NSMutableDictionary dictionaryWithDictionary:actionMutList[currentIndex-1]];
        [actionDic setObject:@[@(x),@(y)] forKey:@"move"];
        [actionMutList replaceObjectAtIndex:currentIndex-1 withObject:actionDic];
        [self setActionListWithName:currentActionName actionList:actionMutList];
    }
    if (currentIndex>0) {
        [self step:currentIndex];
    }else{
        [self updateBasePointList];
        [self base];
    }
}

- (void)delay:(NSString *)text{
    if (currentIndex==0) {
        [CC_Notice show:@"在动作设置"];
        return;
    }
    float time=text.floatValue;
    
    NSMutableArray *actionMutList=[NSMutableArray arrayWithArray:[self getActionListWithName:currentActionName]];
    NSMutableDictionary *newActionMutDic=[NSMutableDictionary dictionaryWithDictionary:actionMutList[currentIndex-1]];
    [newActionMutDic setObject:[NSString stringWithFormat:@"%.3f",time] forKey:@"time"];
    [actionMutList replaceObjectAtIndex:currentIndex-1 withObject:newActionMutDic];
    [self setActionListWithName:currentActionName actionList:actionMutList];
    [self save];
    [self updateTimeL];
    [CC_Notice show:ccstr(@"动作设置成%fs（有过渡）",time)];
}

- (void)stay:(BOOL)isStay{
    if (currentIndex==0) {
        [CC_Notice show:@"在动作设置"];
        return;
    }
    NSMutableArray *actionMutList=[NSMutableArray arrayWithArray:[self getActionListWithName:currentActionName]];
    NSMutableDictionary *newActionMutDic=[NSMutableDictionary dictionaryWithDictionary:actionMutList[currentIndex-1]];
    if (isStay) {
        [newActionMutDic setObject:@"stay" forKey:@"type"];
        [CC_Notice show:@"动作停留到下一帧"];
    }else{
        [newActionMutDic removeObjectForKey:@"type"];
        [CC_Notice show:@"取消停留"];
    }
    [actionMutList replaceObjectAtIndex:currentIndex-1 withObject:newActionMutDic];
    [self setActionListWithName:currentActionName actionList:actionMutList];
}

- (void)reverse:(BOOL)isReverse{
    if (currentIndex==0) {
        [CC_Notice show:@"在动作设置"];
        return;
    }
    NSMutableArray *actionMutList=[NSMutableArray arrayWithArray:[self getActionListWithName:currentActionName]];
    NSMutableDictionary *newActionMutDic=[NSMutableDictionary dictionaryWithDictionary:actionMutList[currentIndex-1]];
    if (isReverse) {
        [newActionMutDic setObject:@"1" forKey:@"reverse"];
        
        NSMutableArray *delta=[NSMutableArray arrayWithArray:newActionMutDic[@"delta"]];
        NSArray *base=pathJSON[@"base"];
        for (int i=0; i<delta.count; i++) {
            if (i%2==0) {
                float v=[delta[i]floatValue];
                float bv=[base[i]floatValue];
                [delta replaceObjectAtIndex:i withObject:@(-v-bv-bv)];
            }
        }
        
        NSMutableDictionary *mutDic=[NSMutableDictionary dictionaryWithDictionary:newActionMutDic];
        [mutDic setObject:delta forKey:@"delta"];
        [mutDic setObject:@"1" forKey:@"reverse"];
        newActionMutDic=mutDic;
        [CC_Notice show:@"动作反转"];
    }else{
        [newActionMutDic removeObjectForKey:@"reverse"];
        [CC_Notice show:@"取消反转"];
    }
    [actionMutList replaceObjectAtIndex:currentIndex-1 withObject:newActionMutDic];
    [self setActionListWithName:currentActionName actionList:actionMutList];
}

- (void)addBlock:(NSString *)name{
    if (currentIndex==0) {
        [CC_Notice show:@"在动作设置"];
        return;
    }
    NSMutableArray *actionMutList=[NSMutableArray arrayWithArray:[self getActionListWithName:currentActionName]];
    NSMutableDictionary *newActionMutDic=[NSMutableDictionary dictionaryWithDictionary:actionMutList[currentIndex-1]];
    [newActionMutDic setObject:name forKey:@"block"];
    [actionMutList replaceObjectAtIndex:currentIndex-1 withObject:newActionMutDic];
    [self setActionListWithName:currentActionName actionList:actionMutList];
    [CC_Notice show:@"添加动作回调"];
}

- (void)removeBlock{
    if (currentIndex==0) {
        [CC_Notice show:@"在动作设置"];
        return;
    }
    NSMutableArray *actionMutList=[NSMutableArray arrayWithArray:[self getActionListWithName:currentActionName]];
    NSMutableDictionary *newActionMutDic=[NSMutableDictionary dictionaryWithDictionary:actionMutList[currentIndex-1]];
    [newActionMutDic removeObjectForKey:@"block"];
    [actionMutList replaceObjectAtIndex:currentIndex-1 withObject:newActionMutDic];
    [self setActionListWithName:currentActionName actionList:actionMutList];
    [CC_Notice show:@"取消动作回调"];
}

- (void)hiddenPoints{
    if (layer.sublayers) {
        layer.sublayers=nil;
        return;
    }else{
        [self updatePoint];
    }
}

- (void)action:(NSString *)name{
    NSArray *actions=pathJSON[@"actions"];
    for (int i=0; i<actions.count; i++) {
        NSDictionary *action=actions[i];
        if ([action[@"name"] isEqualToString:name]) {
            
            currentActionName=name;
            currentActionIndex=0;
            [self updateActionStepListWithSelectIndex:0];
            [self updateActionNamesWithActionName:name];
            [self updateActionPointListWithIndex:0];
            return;
        }
    }
    CCLOG(@"error:no such action(%@)",pathJSON[@"name"]);
}

- (void)base{
    
    actionPointMutList=[NSMutableArray arrayWithArray:basePointMutList];
    [self updatePoint];
    [self updateDraw];
    [self updateActionStepListWithSelectIndex:0];
}

- (void)cutStep{
    if (currentIndex==0) {
        [CC_Notice show:@"不能删除基准"];
        return;
    }
    [self deleteActionWithName:currentActionName atIndex:currentIndex-1];
    [self updateActionPointListWithIndex:currentIndex];
    [self updatePoint];
    [self updateDraw];
}

- (void)scaleRate:(float)rate{
    
    NSMutableArray *base=[NSMutableArray arrayWithArray:pathJSON[@"base"]];
    for (int i=0; i<base.count; i++) {
        float v=[base[i]floatValue]*rate;
        [base replaceObjectAtIndex:i withObject:@(v)];
    }
    NSMutableArray *actions=[NSMutableArray arrayWithArray:pathJSON[@"actions"]];
    for (int i=0; i<actions.count; i++) {
        NSMutableDictionary *action=[NSMutableDictionary dictionaryWithDictionary:actions[i]];
        NSMutableArray *events=[NSMutableArray arrayWithArray:actions[i][@"events"]];
        for (int m=0; m<events.count; m++) {
            NSMutableDictionary *event=[NSMutableDictionary dictionaryWithDictionary:events[m]];
            NSMutableArray *delta=[NSMutableArray arrayWithArray:event[@"delta"]];
            for (int n=0; n<delta.count; n++) {
                float v=[delta[n]floatValue]*rate;
                [delta replaceObjectAtIndex:n withObject:@(v)];
            }
            [event setObject:delta forKey:@"delta"];
            [events replaceObjectAtIndex:m withObject:event];
        }
        [action setObject:events forKey:@"events"];
        [actions replaceObjectAtIndex:i withObject:action];
    }
    [pathJSON setObject:base forKey:@"base"];
    [pathJSON setObject:actions forKey:@"actions"];
    
}

- (void)save{
    if (currentIndex==0) {
        [self saveBase];
        [CC_Notice show:@"已保存动作"];
        return;
    }
    NSArray *baseList=pathJSON[@"base"];
    NSMutableArray *actionMutList=[NSMutableArray arrayWithArray:[self getActionListWithName:currentActionName]];
    NSMutableDictionary *newActionMutDic=[NSMutableDictionary dictionaryWithDictionary:actionMutList[currentIndex-1]];
    NSMutableArray *listMutArr=[[NSMutableArray alloc]init];
    for (int i=0; i<actionPointMutList.count; i++) {
        CGPoint p=[actionPointMutList[i]CGPointValue];
        float bx=[baseList[i*2]floatValue];
        float by=[baseList[i*2+1]floatValue];
        [listMutArr addObject:@(p.x-bx)];
        [listMutArr addObject:@(p.y-by)];
    }
    [newActionMutDic setObject:listMutArr forKey:@"delta"];
    [actionMutList replaceObjectAtIndex:currentIndex-1 withObject:newActionMutDic];
    [self setActionListWithName:currentActionName actionList:actionMutList];
}

- (NSDictionary *)getInfo{
    return @{@"action":currentActionName,@"actionIndex":@(currentIndex-1)};
}

- (void)removeAllActions{
    [pathJSON removeObjectForKey:@"actions"];
}


#pragma mark init
- (void)initLayer{
    
    [self updateBasePointList];
    [self updateActionPointListWithIndex:0];
    
    scrollV=[[UIScrollView alloc]init];
    scrollV.frame=CGRectMake(0, RH(10), [ccui getW], RH(180));
    [baseView addSubview:scrollV];
    
    timeL=[[UILabel alloc]initWithFrame:CGRectMake(RH(10), baseView.height-RH(50), RH(80), RH(50))];
    timeL.font=RF(13);
    timeL.textColor=[UIColor grayColor];
    timeL.backgroundColor=COLOR_BLACK;
    [baseView addSubview:timeL];
    
    moveTextV=[[UITextView alloc]initWithFrame:CGRectMake(timeL.right, baseView.height-RH(50), RH(150), RH(50))];
    moveTextV.font=RF(13);
    moveTextV.textColor=[UIColor grayColor];
    moveTextV.backgroundColor=COLOR_BLACK;
    moveTextV.editable=NO;
    moveTextV.textContainer.lineBreakMode=NSLineBreakByCharWrapping;
    [baseView addSubview:moveTextV];
    
    NSArray *groupNames=@[@"action",@"list"];
    for (int i=0; i<groupNames.count; i++) {
        CC_AutoLabelGroup *group=[[CC_AutoLabelGroup alloc]initWithFrame:CGRectMake(0, RH(10)+RH(40)*i, 100, 10)];
        group.backgroundColor=COLOR_BLACK;
        if (i>0) {
            CC_AutoLabelGroup *tempGroup=[scrollV viewWithTag:10+i-1];
            group.top=tempGroup.bottom;
        }
        group.name=groupNames[i];
        group.delegate=self;
        group.tag=i+10;
        [group updateType:CCAutoLabelAlignmentTypeLeft width:[ccui getW] stepWidth:[ccui getRH:5] sideX:[ccui getRH:10] sideY:[ccui getRH:10] itemHeight:[ccui getRH:30] margin:[ccui getRH:10]];
        [scrollV addSubview:group];
        
        //单元样本创建
        CC_Button *sampleBt=[[CC_Button alloc]init];
        [sampleBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sampleBt setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [sampleBt setBackgroundColor:[UIColor grayColor]];
        [sampleBt setBackgroundColor:[UIColor grayColor] forState:UIControlStateNormal];
        [sampleBt setBackgroundColor:ccRGBA(11, 11, 11, 1) forState:UIControlStateSelected];
        sampleBt.titleLabel.font=RF(16);
        group.sampleBt=sampleBt;
        
        if (i==0) {
            [self updateActionNamesWithActionName:@"ready"];
        }else if (i==1){
            [self updateActionStepListWithSelectIndex:0];
        }
    }
    
    layer = [CAShapeLayer layer];
    layer.bounds         = CGRectMake(0, 0, [ccui getW], [ccui getW]);
    layer.position       = CGPointMake(baseView.center.x, scrollV.bottom+RH(100));
    layer.strokeColor    = [UIColor whiteColor].CGColor;
    layer.fillColor      = [UIColor clearColor].CGColor;
//    layer.fillColor      = [UIColor colorWithPatternImage:[UIImage imageNamed:@"test3"]].CGColor;//需要调整point为负数的值
    layer.fillRule       = kCAFillRuleNonZero;
    
    layer.lineJoin = kCALineCapRound;
    layer.lineCap = kCALineCapRound;
    
    layer.anchorPoint=CGPointMake(0, 0);
    [baseView.layer addSublayer:layer];
    [self updateDraw];
    
}

- (void)spriteBaseView:(CC_SpriteBaseView *)baseView touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    for (int i=0; i<moveMutArr.count; i++) {
        CALayer *layer=moveMutArr[i];
        CGPoint point = [[touches anyObject] locationInView:baseView];
        point = [layer convertPoint:point fromLayer:baseView.layer];
        point = [layer convertPoint:point fromLayer:layer];
        if ([layer containsPoint:point]) {
            move_now=layer;
            move_now.backgroundColor=[UIColor brownColor].CGColor;
            move_now.bounds=CGRectMake(move_now.bounds.origin.x, move_now.bounds.origin.y, 10, 10);
            move_index=i;
            CCLOG(@"i=%d",i);
            return;
        }
    }
    move_now=nil;
}
- (void)spriteBaseView:(CC_SpriteBaseView *)baseView touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!move_now) {
        return;
    }
    CGPoint point = [[touches anyObject] locationInView:baseView];
    point = [layer convertPoint:point fromLayer:baseView.layer];
    move_now.position=point;
    [self updatePoint:@[@(point.x),@(point.y)] atIndex:move_index];
}
- (void)spriteBaseView:(CC_SpriteBaseView *)baseView touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (!move_now) {
        return;
    }
    move_now.backgroundColor=[UIColor redColor].CGColor;
    move_now.bounds=CGRectMake(move_now.bounds.origin.x-2.5, move_now.bounds.origin.y-2.5, 5, 5);
}

- (UIView *)getPoint{
    UIView *move_point=[[UIView alloc]init];
    move_point.backgroundColor=[UIColor redColor];
    move_point.size=CGSizeMake(5, 5);
    [CC_Code setRadius:2.5 view:move_point];
    return move_point;
}

- (void)clearDrawDemo{
    NSString *newBaseStr=@"{\"actions\":[{\"name\":\"ready\",\"delta\":[]}],\"base\":[0,0],}";
    pathJSON=[NSMutableDictionary dictionaryWithDictionary:[CC_Convert dictionaryWithJsonString:newBaseStr]];
    [self updateActionNamesWithActionName:@"ready"];
    [self updateActionStepListWithSelectIndex:0];
    [self updateBasePointList];
    [self updateActionPointListWithIndex:0];
    [self updateDraw];
    [CC_Notice show:@"重置完成"];
}

- (void)autoLabelGroup:(CC_AutoLabelGroup *)group btFinishInit:(UIButton *)bt{
    [CC_Code setRadius:4 view:bt];
    [CC_Code setLineColor:COLOR_WHITE width:1 view:bt];
}

- (void)autoLabelGroupUpdateFinish:(CC_AutoLabelGroup *)group{
    if ([group.name isEqualToString:@"action"]) {
        CC_AutoLabelGroup *list=[scrollV viewWithName:@"list"];
        list.top=group.bottom;
    }
    CC_AutoLabelGroup *list=[scrollV viewWithName:@"list"];
    CC_AutoLabelGroup *action=[scrollV viewWithName:@"action"];
    float height=list.height+action.height+RH(10);
    scrollV.height=height;
    scrollV.contentSize=CGSizeMake([ccui getW], height);
}

- (void)autoLabelGroup:(CC_AutoLabelGroup *)group btTappedAtIndex:(int)index withBt:(UIButton *)bt{
    if ([group.name isEqualToString:@"action"]){
        if ([bt.titleLabel.text isEqualToString:@"+"]) {
            [CC_Alert showTextFieldAltOn:[baseView viewController] title:@"" msg:@"give an action name" placeholder:@"" bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name, NSString * _Nonnull text) {
                if (index==0) {
                    return;
                }
                if ([self.delegate respondsToSelector:@selector(spriteMaker:addActionWithName:)]) {
                    [self.delegate spriteMaker:self addActionWithName:text];
                }else{
                    [self addActionWithName:text];
                }
            }];
            return;
        }
        if ([bt.titleLabel.text isEqualToString:@"复制"]) {
            [CC_Alert showAltOn:[baseView viewController] title:@"" msg:@"copy current action?" bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name) {
                if (index==0) {
                    return;
                }
                if ([self.delegate respondsToSelector:@selector(spriteMakerCopyAction:)]) {
                    [self.delegate spriteMakerCopyAction:self];
                }else{
                    [self copyAction];
                }
                [CC_Notice show:@"复制成功！"];
            }];
            return;
        }
        if ([bt.titleLabel.text isEqualToString:@"-"]) {
            [CC_Alert showAltOn:[baseView viewController] title:@"" msg:@"delete current action?" bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name) {
                if (index==0) {
                    return;
                }
                if ([self.delegate respondsToSelector:@selector(spriteMaker:deleteActionWithName:)]) {
                    [self.delegate spriteMaker:self deleteActionWithName:currentActionName];
                }else{
                    [self deleteActionWithName:currentActionName];
                }
                [CC_Notice show:@"删除成功！"];
            }];
            return;
        }
        if ([bt.titleLabel.text isEqualToString:@"名"]) {
            [CC_Alert showTextFieldAltOn:[baseView viewController] title:@"" msg:ccstr(@"change %@",currentActionName) placeholder:@"new name" bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name, NSString * _Nonnull text) {
                if (index==0) {
                    return;
                }
                if ([self.delegate respondsToSelector:@selector(spriteMaker:renameActionWithName:)]) {
                    [self.delegate spriteMaker:self renameActionWithName:text];
                }else{
                    [self renameActionWithName:text];
                }
            }];
            return;
        }
        
        if ([bt.titleLabel.text isEqualToString:@"存"]){
            [self save];
            return;
        }else if ([bt.titleLabel.text isEqualToString:@"生成"]){
//            [self saveDemo];
            return;
        }else if ([bt.titleLabel.text isEqualToString:@"播放"]){
            NSArray *listArr=[self getActionListWithName:currentActionName];
            if (listArr.count<=0) {
                [CC_Notice show:@"还没有设置帧"];
                return;
            }
            [bt setTitle:@"停止" forState:UIControlStateNormal];
            [self play];
            return;
        }else if ([bt.titleLabel.text isEqualToString:@"停止"]){
            [bt setTitle:@"播放" forState:UIControlStateNormal];
            [self stop];
            return;
        }else if ([bt.titleLabel.text isEqualToString:@"重置"]){
            [CC_Alert showAltOn:[baseView viewController] title:@"确定重置吗" msg:@"" bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name) {
                if ([name isEqualToString:@"确定"]) {
                    [self clearDrawDemo];
                }
            }];
            return;
        }else if ([bt.titleLabel.text isEqualToString:@"收"]){
            [group updateLabels:@[@"展开"] selected:@[@"1"]];
            return;
        }else if ([bt.titleLabel.text isEqualToString:@"动作"]){
            NSArray *actions=pathJSON[@"actions"];
            NSMutableArray *names=[[NSMutableArray alloc]init];
            [names addObject:@"取消"];
            for (int i=0; i<actions.count; i++) {
                [names addObject:actions[i][@"name"]];
            }
            [CC_Alert showAltOn:[baseView viewController] title:@"" msg:@"which one?" bts:names block:^(int index, NSString * _Nonnull name) {
                if ([name isEqualToString:@"取消"]) {
                    return;
                }
                [self updateActionNamesWithActionName:names[index]];
                
                if ([self.delegate respondsToSelector:@selector(spriteMaker:didSelectActionAtIndex:name:)]) {
                    [self.delegate spriteMaker:self didSelectActionAtIndex:index name:names[index]];
                }else{
                    [self action:names[index]];
                }
            }];
            return;
        }
        
    }else if ([group.name isEqualToString:@"list"]){
        if ([bt.titleLabel.text isEqualToString:@"左"]){
//            if (currentIndex>0) {
//                [CC_Notice show:@"在基准添加"];
//                return;
//            }
            CGPoint last=[[actionPointMutList lastObject]CGPointValue];
            CGPoint cp=CGPointMake(last.x-10, last.y);
            [actionPointMutList addObject:@(cp)];
            CGPoint tp=CGPointMake(last.x-20, last.y);
            [actionPointMutList addObject:@(tp)];
            [self updatePoint];
            [self updateDraw];
            [self saveBase];
            return;
        }
        if ([bt.titleLabel.text isEqualToString:@"右"]){
//            if (currentIndex>0) {
//                [CC_Notice show:@"在基准添加"];
//                return;
//            }
            CGPoint last=[[actionPointMutList lastObject]CGPointValue];
            CGPoint cp=CGPointMake(last.x+10, last.y);
            [actionPointMutList addObject:@(cp)];
            CGPoint tp=CGPointMake(last.x+20, last.y);
            [actionPointMutList addObject:@(tp)];
            [self updatePoint];
            [self updateDraw];
            [self saveBase];
            return;
        }
        if ([bt.titleLabel.text isEqualToString:@"删"]){
            [CC_Alert showAltOn:[baseView viewController] title:@"" msg:@"delete?" bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name) {
                if (index==0) {
                    return;
                }
                //            if (currentIndex>0) {
                //                [CC_Notice show:@"在基准删除"];
                //                return;
                //            }
                [actionPointMutList removeLastObject];
                [actionPointMutList removeLastObject];
                [self updatePoint];
                [self updateDraw];
                [self saveBase];
            }];
            return;
        }
        if ([bt.titleLabel.text isEqualToString:@"存"]){
            [self save];
            return;
        }
        if ([bt.titleLabel.text isEqualToString:@"秒"]){
            [CC_Alert showTextFieldAltOn:[baseView viewController] title:@"" msg:@"设置延时时间" placeholder:@"" bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name, NSString * _Nonnull text) {
                if (index==0) {
                    return;
                }
                [self delay:text];
            }];
            return;
        }
        if ([bt.titleLabel.text isEqualToString:@"留"]){
            [CC_Alert showAltOn:[baseView viewController] title:@"" msg:@"stay?" bts:@[@"取消停留",@"停留",] block:^(int index, NSString * _Nonnull name) {
                [self stay:index];
            }];
            return;
        }
        if ([bt.titleLabel.text isEqualToString:@"移"]){
            [CC_Alert showTextFieldsAltOn:[baseView viewController] title:@"" msg:@"输入位移的xy坐标" placeholders:@[@"x",@"y"] bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name, NSArray * _Nonnull texts) {
                if (index==0) {
                    return;
                }
                [self moveStep:texts];
            }];
            return;
        }
        if ([bt.titleLabel.text isEqualToString:@"旋"]){
            if (currentIndex==0) {
                [CC_Notice show:@"error:add in step"];
            }else{
                [CC_Alert showTextFieldsAltOn:[baseView viewController] title:@"" msg:@"set rotate" placeholders:@[@"rotation duration",@"rotation times"] bts:@[@"取消旋转",@"确定"] block:^(int index, NSString * _Nonnull name, NSArray * _Nonnull texts) {
                    
                    NSMutableArray *actionMutList=[NSMutableArray arrayWithArray:[self getActionListWithName:currentActionName]];
                    NSMutableDictionary *actionDic=[NSMutableDictionary dictionaryWithDictionary:actionMutList[currentIndex-1]];
                    if (index==0) {
                        [actionDic removeObjectForKey:@"rotate"];
                        [CC_Notice show:@"rotate cancel"];
                    }else{
                        float duration=[texts[0]floatValue];
                        float times=[texts[1]floatValue];
                        [actionDic setObject:@[@(duration),@(times)] forKey:@"rotate"];
                        [CC_Notice show:@"rotate"];
                    }
                    [actionMutList replaceObjectAtIndex:currentIndex-1 withObject:actionDic];
                    [self setActionListWithName:currentActionName actionList:actionMutList];
                    [self step:currentIndex];
                    
                }];
            }
            return;
        }
        if ([bt.titleLabel.text isEqualToString:@"隐"]){
            [self hiddenPoints];
            return;
        }
        if ([bt.titleLabel.text isEqualToString:@"藏"]){
            if (currentIndex==0) {
                [CC_Notice show:@"error:add in step"];
            }else{
                [CC_Alert showAltOn:[baseView viewController] title:@"" msg:@"set hidden" bts:@[@"取消隐藏",@"确定"] block:^(int index, NSString * _Nonnull name) {
                    NSMutableArray *actionMutList=[NSMutableArray arrayWithArray:[self getActionListWithName:currentActionName]];
                    NSMutableDictionary *actionDic=[NSMutableDictionary dictionaryWithDictionary:actionMutList[currentIndex-1]];
                    if (index==0) {
                        [actionDic removeObjectForKey:@"hidden"];
                        [CC_Notice show:@"hidden cancel"];
                    }else{
                        [actionDic setObject:@"1" forKey:@"hidden"];
                        [CC_Notice show:@"hidden"];
                    }
                    [actionMutList replaceObjectAtIndex:currentIndex-1 withObject:actionDic];
                    [self setActionListWithName:currentActionName actionList:actionMutList];
                    [self step:currentIndex];
                }];
                
            }
            return;
        }
        if ([bt.titleLabel.text isEqualToString:@"基准"]) {
            currentIndex=index;
            [self base];
            return;
        }
        if ([bt.titleLabel.text isEqualToString:@"+帧"]) {
            [CC_Alert showTextFieldAltOn:[baseView viewController] title:@"" msg:@"" placeholder:@"copy step of index?" bts:@[@"取消",@"确定",@"反转",@"基准"] block:^(int index, NSString * _Nonnull name, NSString * _Nonnull text) {
                if (index==0) {
                    return ;
                }
                int step=[text intValue];
                if ([name isEqualToString:@"确定"]) {
                    [self addStep:step mirror:NO];
                }
                if ([name isEqualToString:@"反转"]) {
                    [self addStep:step mirror:YES];
                }
                if ([name isEqualToString:@"基准"]) {
                    [self addFirtStep];
                }
            }];
            return;
        }
        if ([bt.titleLabel.text isEqualToString:@"-帧"]) {
            [self cutStep];
            return;
        }
        if ([bt.titleLabel.text isEqualToString:@"换"]) {
            [CC_Alert showTextFieldAltOn:[baseView viewController] title:@"" msg:@"copy current step to?" placeholder:@"step index" bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name, NSString * _Nonnull text) {
                
                if ([name isEqualToString:@"确定"]) {
                    int step=[text intValue];
                    [self copyStepTo:step];
                }
            }];
            return;
        }
        if ([self.delegate respondsToSelector:@selector(spriteMaker:didSelectStepAtIndex:)]) {
            [self.delegate spriteMaker:self didSelectStepAtIndex:index];
        }else{
            [self step:index];
        }
    }
}

- (void)saveBase{
    basePointMutList=[NSMutableArray arrayWithArray:actionPointMutList];
    NSMutableArray *mutList=[[NSMutableArray alloc]init];
    for (int i=0; i<basePointMutList.count; i++) {
        CGPoint point=[basePointMutList[i]CGPointValue];
        [mutList addObject:@(point.x)];
        [mutList addObject:@(point.y)];
    }
    [pathJSON setObject:mutList forKey:@"base"];
}

//- (void)saveDemo{
//    [ccs saveLocalFile:[CC_Convert convertToJSONData:pathJSON] withPath:@"drawDemo" andType:@"json"];
//    [CC_Notice show:@"已生成到沙盒"];
//    CCLOG(@"path=%@",[NSString stringWithFormat:@"%@", NSHomeDirectory()]);
//}

- (void)addBaseActionStep{
    NSMutableArray *deltaMutArr=[[NSMutableArray alloc]init];
    NSArray *list=pathJSON[@"base"];
    for (int i=0; i<list.count; i++) {
        [deltaMutArr addObject:@(0)];
    }
    NSDictionary *newDic=@{@"delta":deltaMutArr,@"time":@(1.0)};
    NSMutableArray *mutActionList=[NSMutableArray arrayWithArray:[self getActionListWithName:currentActionName]];
    [mutActionList addObject:newDic];
    currentIndex=(int)mutActionList.count;
    [self setActionListWithName:currentActionName actionList:mutActionList];
    [self updateActionStepListWithSelectIndex:currentIndex];
}

- (void)addLastActionStep{
    NSArray *list=[self getActionListWithName:currentActionName];
    NSDictionary *newDic=[NSDictionary dictionaryWithDictionary:list[list.count-1]];
    NSMutableArray *mutActionList=[NSMutableArray arrayWithArray:[self getActionListWithName:currentActionName]];
    [mutActionList addObject:newDic];
    currentIndex=(int)mutActionList.count;
    [self setActionListWithName:currentActionName actionList:mutActionList];
    [self updateActionStepListWithSelectIndex:currentIndex];
}

- (void)addActionStep:(int)step mirror:(int)mirror{
    if (step==0) {
        [self addBaseActionStep];
        return;
    }
    NSArray *list=[self getActionListWithName:currentActionName];
    NSDictionary *newDic=[NSDictionary dictionaryWithDictionary:list[step-1]];
    if (mirror) {
        NSMutableArray *delta=[NSMutableArray arrayWithArray:newDic[@"delta"]];
        NSArray *base=pathJSON[@"base"];
        for (int i=0; i<delta.count; i++) {
            if (i%2==0) {
                float v=[delta[i]floatValue];
                float bv=[base[i]floatValue];
                [delta replaceObjectAtIndex:i withObject:@(-v-bv-bv)];
            }
        }

        NSMutableDictionary *mutDic=[NSMutableDictionary dictionaryWithDictionary:newDic];
        [mutDic setObject:delta forKey:@"delta"];
        [mutDic setObject:@"1" forKey:@"reverse"];
        newDic=mutDic;
    }
    NSMutableArray *mutActionList=[NSMutableArray arrayWithArray:[self getActionListWithName:currentActionName]];
    if (currentIndex>=mutActionList.count) {
        [mutActionList addObject:newDic];
    }else{
        [mutActionList insertObject:newDic atIndex:currentIndex];
    }
    currentIndex=(int)mutActionList.count;
    [self setActionListWithName:currentActionName actionList:mutActionList];
    [self updateActionStepListWithSelectIndex:currentIndex];
}

- (void)copyActionStepTo:(int)step{
    NSArray *list=[self getActionListWithName:currentActionName];
    NSDictionary *newDic=[NSDictionary dictionaryWithDictionary:list[currentIndex-1]];
    NSMutableArray *mutActionList=[NSMutableArray arrayWithArray:[self getActionListWithName:currentActionName]];
    [mutActionList replaceObjectAtIndex:step-1 withObject:newDic];
    [self setActionListWithName:currentActionName actionList:mutActionList];
    [self updateActionStepListWithSelectIndex:currentIndex];
}

- (void)deleteActionWithName:(NSString *)name atIndex:(int)index{
    NSMutableArray *mutActionList=[NSMutableArray arrayWithArray:[self getActionListWithName:name]];
    [mutActionList removeObjectAtIndex:index];
    currentIndex=0;
    [self setActionListWithName:name actionList:mutActionList];
    [self updateActionStepListWithSelectIndex:0];
}

- (NSArray *)getActionListWithName:(NSString *)name{
    NSArray *actions=pathJSON[@"actions"];
    for (int i=0; i<actions.count; i++) {
        NSDictionary *action=actions[i];
        if ([action[@"name"]isEqualToString:name]) {
            currentActionIndex=i;
            return action[@"events"];
        }
    }
    return nil;
}

- (void)setActionListWithName:(NSString *)name actionList:(NSArray *)actionList{
    NSMutableArray *actions=[NSMutableArray arrayWithArray:pathJSON[@"actions"]];
    int index=-1;
    NSDictionary *action;
    for (int i=0; i<actions.count; i++) {
        action=actions[i];
        if ([action[@"name"]isEqualToString:name]) {
            index=i;
            break;
        }
    }
    if (index==-1) {
        return;
    }
    NSMutableDictionary *newAction=[[NSMutableDictionary alloc]initWithDictionary:action];
    [newAction setObject:actionList forKey:@"events"];
    [actions replaceObjectAtIndex:index withObject:newAction];
    [pathJSON setObject:actions forKey:@"actions"];
    [CC_Notice show:@"已保存动作"];
}

- (void)updateBasePointList{
    NSArray *list=pathJSON[@"base"];
    basePointMutList=[[NSMutableArray alloc]init];
    for (int i=0; i<list.count/2; i++) {
        CGPoint p=CGPointMake([list[i*2]floatValue], [list[i*2+1]floatValue]);
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
}

- (void)updateActionPointListWithIndex:(int)index{
    if (index==0) {
        actionPointMutList=[NSMutableArray arrayWithArray:basePointMutList];
        return;
    }
    NSDictionary *action=[self getActionListWithName:currentActionName][index-1];
    NSArray *listArr=action[@"delta"];
    listArr=[self convertDeltaToAbsolute:listArr];
    actionPointMutList=[[NSMutableArray alloc]init];
    for (int i=0; i<listArr.count/2; i++) {
        float px=[listArr[i*2]floatValue];
        float py=[listArr[i*2+1]floatValue];
        CGPoint newPoint=CGPointMake(px, py);
        [actionPointMutList addObject:@(newPoint)];
    }
    
    NSString *moveLStr=@"";
    if (action[@"move"]) {
        moveLStr=ccstr(@"move:[%@,%@]",action[@"move"][0],action[@"move"][1]);
    }
    if (action[@"rotate"]) {
        moveLStr=ccstr(@"%@rota:[%@,%@]",moveLStr,action[@"rotate"][0],action[@"rotate"][1]);
    }
    if (action[@"block"]) {
        moveLStr=ccstr(@"%@block:%@",moveLStr,action[@"block"]);
    }
    if (action[@"type"]) {
        moveLStr=ccstr(@"%@%@",moveLStr,action[@"type"]);
    }
    if (action[@"hidden"]) {
        moveLStr=ccstr(@"%@hidden",moveLStr);
    }
    if (action[@"reverse"]) {
        moveLStr=ccstr(@"%@reverse",moveLStr);
    }
    moveTextV.text=moveLStr;
}

- (void)updatePoint:(NSArray *)point atIndex:(int)index{
    actionPointMutList[index]=@(CGPointMake([point[0]floatValue], [point[1]floatValue]));
    [self updateDraw];
}

- (void)updateActionNamesWithActionName:(NSString *)name{
    NSArray *actions=pathJSON[@"actions"];

    currentActionName=name;
    NSMutableArray *actionsNameArr=[[NSMutableArray alloc]init];
    for (int i=0; i<actions.count; i++) {
        if ([actions[i][@"name"] isEqualToString:name]) {
            currentActionIndex=i;
            [actionsNameArr addObject:name];
            break;
        }
    }
    [actionsNameArr addObject:@"动作"];
    [actionsNameArr addObject:@"+"];
    if (actions.count>0) {
        [actionsNameArr addObject:@"复制"];
        [actionsNameArr addObject:@"-"];
        [actionsNameArr addObject:@"名"];
    }
//    [actionsNameArr addObject:@"收"];
//    [actionsNameArr addObject:@"播放"];
//    [actionsNameArr addObject:@"重置"];
//    [actionsNameArr addObject:@"名"];
    NSMutableArray *actionsSelectArr=[[NSMutableArray alloc]init];
    for (int i=0; i<actionsNameArr.count; i++) {
        if (i==0) {
            [actionsSelectArr addObject:@"1"];
        }else{
            [actionsSelectArr addObject:@"0"];
        }
    }
    CC_AutoLabelGroup *group=[scrollV viewWithName:@"action"];
    [group updateLabels:actionsNameArr selected:actionsSelectArr];
}

- (void)updateActionStepListWithSelectIndex:(int)index{
    NSMutableArray *actionList=[[NSMutableArray alloc]init];
    [actionList addObject:@"基准"];
    NSArray *actionArr=[self getActionListWithName:currentActionName];
    for (int i=0; i<actionArr.count; i++) {
        [actionList addObject:@(i+1)];
    }
    [actionList addObject:@"+帧"];
//    [actionList addObject:@"++"];
    [actionList addObject:@"-帧"];
//    [actionList addObject:@"秒"];
    [actionList addObject:@"换"];
    [actionList addObject:@"移"];
    [actionList addObject:@"旋"];
    [actionList addObject:@"藏"];
    [actionList addObject:@"隐"];
    [actionList addObject:@"左"];
    [actionList addObject:@"右"];
    [actionList addObject:@"删"];
    [actionList addObject:@"存"];
    NSMutableArray *actionListSelectArr=[[NSMutableArray alloc]init];
    for (int i=0; i<actionList.count; i++) {
        if (i==index) {
            [actionListSelectArr addObject:@"1"];
        }else{
            [actionListSelectArr addObject:@"0"];
        }
    }
    
    CC_AutoLabelGroup *group=[scrollV viewWithName:@"list"];
    [group updateLabels:actionList selected:actionListSelectArr];
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

- (void)updatePoint{
    layer.sublayers=nil;
    
    moveMutArr=[[NSMutableArray alloc]init];
    for (int i=0; i<actionPointMutList.count; i++) {
        CGPoint actionPoint=[actionPointMutList[i]CGPointValue];
        UIView *point=[self getPoint];
        point.center=CGPointMake(actionPoint.x, actionPoint.y);
        [layer addSublayer:point.layer];
        [moveMutArr addObject:point.layer];
    }
}

- (void)updateDraw{
    
    if (actionPointMutList.count==0) {
        return;
    }
    
    UIBezierPath *circleP = [UIBezierPath bezierPath];
    CGPoint p1=[actionPointMutList[0]CGPointValue];
    p1.x=p1.x;p1.y=p1.y;
    [circleP moveToPoint:p1];
    for (int i=0; i<actionPointMutList.count/2; i++) {
        CGPoint p_=[actionPointMutList[i*2+1]CGPointValue];
        p_.x=p_.x;p_.y=p_.y;
        CGPoint p=[actionPointMutList[i*2+2]CGPointValue];
        p.x=p.x;p.y=p.y;
        [circleP addQuadCurveToPoint:p controlPoint:p_];
    }
    CGPoint p_=[[actionPointMutList lastObject]CGPointValue];
    p_.x=p_.x;p_.y=p_.y;
    CGPoint p=[actionPointMutList[0]CGPointValue];
    p.x=p.x;p.y=p.y;
    [circleP addQuadCurveToPoint:p controlPoint:p_];
    
    layer.path=circleP.CGPath;
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    
}

- (void)changeEnd {
//    int play=0;
    NSDate *currentDate=[NSDate date];
    if (!lastPathDate) {
        lastPathDate=currentDate;
    }
    if (lastDate) {
        NSTimeInterval lastinter=[CC_Date compareDate:currentDate cut:lastPathDate];
        
        NSArray *actionList=[self getActionListWithName:currentActionName];
        NSDictionary *actionStep=actionList[actionStepIndex];
        NSDictionary *lastActionStep;
        if (actionStepIndex>0) {
            lastActionStep=actionList[actionStepIndex-1];
        }
        float time=[actionStep[@"time"]floatValue];
        if (lastinter>=time) {
            actionStepIndex++;
            if (actionStepIndex>=actionList.count) {
                CCLOG(@"finish");
                [displayLink invalidate];
                return;
            }else{
            }
//            play=1;
            lastPathDate=currentDate;
            
            if (actionStep[@"rotate"]) {
                
                CABasicAnimation *positionAnima = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
                positionAnima.toValue=@(M_PI*2);
                positionAnima.duration=[actionStep[@"rotate"][0]floatValue];
                positionAnima.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                positionAnima.repeatCount=[actionStep[@"rotate"][1]floatValue];
                positionAnima.removedOnCompletion = YES;
                positionAnima.fillMode=kCAFillModeForwards;
                
                [self.layer addAnimation:positionAnima forKey:@"rotate"];
            }
            
        }
        
        if (lastActionStep[@"hidden"]) {
            self.layer.path=nil;
            return;
        }
        
        NSTimeInterval inter=[CC_Date compareDate:currentDate cut:lastPathDate];
        float percent;
        if (currentDate==lastPathDate) {
            percent=1;
        }else{
            percent=inter/time;
        }
        
        NSArray *listArr=actionStep[@"delta"];
        listArr=[self convertDeltaToAbsolute:listArr];
        NSArray *lastListArr=lastActionStep[@"delta"];
        lastListArr=[self convertDeltaToAbsolute:lastListArr];
        
        actionPointMutList=[[NSMutableArray alloc]init];
        for (int i=0; i<listArr.count/2; i++) {
            float x=[listArr[i*2]floatValue];
            float y=[listArr[i*2+1]floatValue];
            float lastX=0;
            float lastY=0;
            if (lastListArr.count>0) {
                lastX=[lastListArr[i*2]floatValue];
                lastY=[lastListArr[i*2+1]floatValue];
            }else{
                percent=1;
            }
            CGPoint p;
            if ([lastActionStep[@"type"]isEqualToString:@"stay"]) {
                p=CGPointMake(lastX, lastY);
            }else{
                p=CGPointMake(lastX*(1-percent)+x*percent, lastY*(1-percent)+y*percent);
            }
            [actionPointMutList addObject:@(p)];
        }
    }
    
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
    
    layer.path=circleP.CGPath;
//    if (play==1) {
//
//        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
//        animation.duration = 1;
//        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//        animation.fromValue = (__bridge id)(layer.path);
//        animation.toValue = (__bridge id)(circleP).CGPath;
//        layer.path = circleP.CGPath;
//        [layer addAnimation:animation forKey:@"animatePath"];
//    }
    lastDate=currentDate;
    
}

@end
