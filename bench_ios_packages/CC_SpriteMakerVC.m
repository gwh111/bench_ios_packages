//
//  CC_SpriteMakerVC.m
//  bench_ios
//
//  Created by gwh on 2019/5/20.
//  Copyright © 2019 apple. All rights reserved.
//

#import "CC_SpriteMakerVC.h"
#import "CC_SpriteMaker.h"
#import "CC_AutoLabelGroup.h"

@interface CC_SpriteMakerVC ()<CC_AutoLabelGroupDelegate,CC_SpriteMakerDelegate>{
    UIScrollView *scrollV;
    CC_AutoLabelGroup *group;
    
    NSMutableArray *makers;
    NSMutableArray *pathJSONMutArr;
    NSArray *appendPathJSONArr;
    UIScrollView *makerView;
    
    NSMutableArray *groupMutArr;
    NSMutableArray *groupSelectMutArr;
    
    int currentIndex;
    
    NSString *spriteSaveName;
    UILabel *fileNameL;
    UIViewController *tempVC;
}

@end

@implementation CC_SpriteMakerVC

//static NSString *defaultName=@"man.json";

+ (void)presentOnVC:(UIViewController *)vc{
    [self performSelectorOnMainThread:@selector(presentOnVC2:)withObject:vc waitUntilDone:NO];
}

+ (void)presentOnVC2:(UIViewController *)vc{
    CC_SpriteMakerVC *pop=[[CC_SpriteMakerVC alloc]init];
    pop.fromVC=vc;
    [vc presentViewController:pop animated:YES completion:nil];
}

+ (void)presentVC{
    CC_SpriteMakerVC *pop=[[CC_SpriteMakerVC alloc]init];
    [[CC_Code getRootNav] presentViewController:pop animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=COLOR_WHITE;
    
    [self initUI];
}

- (void)initUI{
    
    [CC_Notice getInstance].yOffset=[ccui getH]/2-RH(100);
    
    NSArray *list=[ccs getLocalFileListWithDocumentName:@"sprite" withType:@"json"];
    NSString *fileName;
    if (list.count==0) {
        fileName=@"man";
    }else{
        fileName=list[0];
    }
    fileName=ccstr(@"sprite/%@",fileName);
    spriteSaveName=fileName;
    if ([ccs getDefault:@"defaultSpriteMakerName"]) {
        spriteSaveName=[ccs getDefault:@"defaultSpriteMakerName"];
    }
    
    scrollV=[[UIScrollView alloc]init];
    scrollV.frame=CGRectMake(0, [ccui getSY], [ccui getW], RH(110));
    [self.view addSubview:scrollV];
    
    makerView=[[UIScrollView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:makerView];
    makerView.backgroundColor=COLOR_BLACK;
    
    group=[[CC_AutoLabelGroup alloc]initWithFrame:CGRectMake(0, RH(10), 100, 10)];
    group.delegate=self;
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
    
    fileNameL=[[UILabel alloc]initWithFrame:CGRectMake([ccui getW]-RH(120), [ccui getH]-RH(50), RH(120), RH(50))];
    fileNameL.textColor=[UIColor grayColor];
    fileNameL.font=RF(12);
    [self.view addSubview:fileNameL];
    
    [self updateGroupWithName:spriteSaveName];
    
    [self updateFileNameL];
}

- (void)updateFileNameL{
    fileNameL.text=spriteSaveName;
}

- (void)addGroupWithName:(NSString *)name{
    NSString *file=[ccs getLocalFileWithPath:name andType:nil];
    appendPathJSONArr=[CC_Convert dictionaryWithJsonString:file];
}

- (void)updateGroupWithName:(NSString *)name{
    pathJSONMutArr=[[NSMutableArray alloc]init];
    makers=[[NSMutableArray alloc]init];
    groupMutArr=[[NSMutableArray alloc]init];
    NSString *file=[ccs getLocalFileWithPath:name andType:nil];
    if (!file) {
        file=[ccs getFileWithPath:name andType:@"json"];
    }
    if (file) {
        pathJSONMutArr=[CC_Convert dictionaryWithJsonString:file];
    }
    if (appendPathJSONArr.count>0) {//add extra part
        [pathJSONMutArr addObjectsFromArray:appendPathJSONArr];
    }
    for (int i=0; i<pathJSONMutArr.count; i++) {
        NSDictionary *newMaker=pathJSONMutArr[i];
        CC_SpriteMaker *maker=[[CC_SpriteMaker alloc]initOn:makerView withFile:newMaker];
        maker.delegate=self;
        [makers addObject:maker];
        [groupMutArr addObject:pathJSONMutArr[i][@"name"]];
    }
    [groupMutArr addObject:@"新"];
    [groupMutArr addObject:@"切换"];
    [groupMutArr addObject:@"复制"];
    [groupMutArr addObject:@"+"];
    [groupMutArr addObject:@"++"];
    [groupMutArr addObject:@"-"];
//    [groupMutArr addObject:@"帧"];
//    [groupMutArr addObject:@"+首帧"];
//    [groupMutArr addObject:@"+末帧"];
    [groupMutArr addObject:@"+帧"];
    [groupMutArr addObject:@"换"];
    [groupMutArr addObject:@"-帧"];
    [groupMutArr addObject:@"+b"];
    [groupMutArr addObject:@"-b"];
//    [groupMutArr addObject:@"+动作"];
    [groupMutArr addObject:@"秒"];
    [groupMutArr addObject:@"整移"];
    [groupMutArr addObject:@"移"];
//    [groupMutArr addObject:@"旋"];
    [groupMutArr addObject:@"留"];
    [groupMutArr addObject:@"反"];
    [groupMutArr addObject:@"隐"];
    [groupMutArr addObject:@"预览"];
    [groupMutArr addObject:@"编辑"];
    [groupMutArr addObject:@"播放"];
    [groupMutArr addObject:@"生成"];
    [groupMutArr addObject:@"收起"];
    [groupMutArr addObject:@"X"];
    
    groupSelectMutArr=[[NSMutableArray alloc]init];
    for (int i=0; i<groupMutArr.count; i++) {
        if (i==0) {
            [groupSelectMutArr addObject:@"1"];
        }else{
            [groupSelectMutArr addObject:@"0"];
        }
    }
    
    [group updateLabels:groupMutArr selected:groupSelectMutArr];
}

- (void)autoLabelGroup:(CC_AutoLabelGroup *)group btFinishInit:(UIButton *)bt{
    [CC_Code setRadius:4 view:bt];
    [CC_Code setLineColor:COLOR_WHITE width:1 view:bt];
}

- (void)autoLabelGroupUpdateFinish:(CC_AutoLabelGroup *)group{
    scrollV.height=group.bottom;
    scrollV.contentSize=CGSizeMake([ccui getW], group.bottom);
    
    makerView.top=scrollV.bottom;
    makerView.height=self.view.height-scrollV.bottom;
    
    for (int i=0; i<makers.count; i++) {
        CC_SpriteMaker *maker=makers[i];
        [maker updateBaseViewOn:makerView];
    }
}

- (void)clear{
    for (int i=0; i<makers.count; i++) {
        CC_SpriteMaker *maker=makers[i];
        [maker.baseView removeFromSuperview];
        [maker.layer removeFromSuperlayer];
    }
    pathJSONMutArr=[[NSMutableArray alloc]init];
}

- (void)autoLabelGroup:(CC_AutoLabelGroup *)group btTappedAtIndex:(int)index withBt:(UIButton *)bt{
    if ([bt.titleLabel.text isEqualToString:@"切换"]) {
        NSArray *list=[ccs getLocalFileListWithDocumentName:@"sprite" withType:@"json"];
        CCLOG(@"%@",list);
        NSString *msg=@"";
        for (int i=0; i<list.count; i++) {
            msg=[msg stringByAppendingString:[NSString stringWithFormat:@"%d. ",i]];
            msg=[msg stringByAppendingString:list[i]];
            msg=[msg stringByAppendingString:@"\n"];
        }
        [CC_Alert showTextFieldAltOn:self title:@"" msg:msg placeholder:@"which one" bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name, NSString * _Nonnull text) {
            if (index==0) {
                return;
            }
            int select=[text intValue];
            NSString *fileName=list[select];
            
            spriteSaveName=fileName;
            spriteSaveName=ccstr(@"sprite/%@",spriteSaveName);
            
            [ccs saveDefaultKey:@"defaultSpriteMakerName" andV:spriteSaveName];
            
            currentIndex=0;
            [self clear];
            [self updateGroupWithName:spriteSaveName];
            [self updateFileNameL];
        }];
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"复制"]) {
        NSArray *list=[ccs getLocalFileListWithDocumentName:@"sprite" withType:@"json"];
        CCLOG(@"%@",list);
        NSString *msg=@"";
        for (int i=0; i<list.count; i++) {
            msg=[msg stringByAppendingString:[NSString stringWithFormat:@"%d. ",i]];
            msg=[msg stringByAppendingString:list[i]];
            msg=[msg stringByAppendingString:@"\n"];
        }
        [CC_Alert showTextFieldsAltOn:self title:@"" msg:msg placeholders:@[@"copy which one?",@"action name?",@"to which one?"] bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name, NSArray * _Nonnull texts) {
            
            if (index==0) {
                return;
            }
            
            NSString *copyName=list[[texts[0] intValue]];
            NSString *copyFile=[ccs getLocalFileWithPath:ccstr(@"sprite/%@",copyName) andType:nil];
            NSArray *copyList=[CC_Convert dictionaryWithJsonString:copyFile];
            
            NSString *copyActionName=texts[1];
            
            NSString *toName=list[[texts[2] intValue]];
            NSString *toFile=[ccs getLocalFileWithPath:ccstr(@"sprite/%@",toName) andType:nil];
            NSMutableArray *toList=[NSMutableArray arrayWithArray:[CC_Convert dictionaryWithJsonString:toFile]];
            for (int i=0; i<toList.count; i++) {
                NSMutableDictionary *part=[NSMutableDictionary dictionaryWithDictionary:toList[i]];
                if (!part[@"actions"]) {
                    [part setObject:@[] forKey:@"actions"];
                }
                NSMutableArray *toActions=[NSMutableArray arrayWithArray:part[@"actions"]];
                NSArray *copyActions=copyList[i][@"actions"];
                for (int m=0; m<copyActions.count; m++) {
                    NSDictionary *copyAction=copyActions[m];
                    if ([copyAction[@"name"]isEqualToString:copyActionName]) {
                        [toActions addObject:copyAction];
                        break;
                    }
                }
                [part setObject:toActions forKey:@"actions"];
                [toList replaceObjectAtIndex:i withObject:part];
            }
            NSString *newFile=[CC_Convert convertToJSONData:toList];
            
            [ccs saveLocalFile:newFile withPath:ccstr(@"sprite/%@",toName) andType:nil];
            [CC_Notice show:@"复制成功"];
        }];
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"新"]) {
        [self clear];
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"+"]) {
        [CC_Alert showTextFieldAltOn:self title:@"" msg:@"add part" placeholder:@"part name" bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name, NSString * _Nonnull text) {
            if (index==0) {
                return;
            }
            [self addMaker:group name:text];
        }];
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"++"]) {
        NSArray *list=[ccs getLocalFileListWithDocumentName:@"sprite" withType:@"json"];
        CCLOG(@"%@",list);
        NSString *msg=@"";
        for (int i=0; i<list.count; i++) {
            NSString *tempName=list[i];
            if ([tempName hasPrefix:@"part_"]) {
                msg=[msg stringByAppendingString:[NSString stringWithFormat:@"%d. ",i]];
                msg=[msg stringByAppendingString:list[i]];
                msg=[msg stringByAppendingString:@"\n"];
            }
        }
        [CC_Alert showTextFieldAltOn:self title:@"" msg:msg placeholder:@"which one" bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name, NSString * _Nonnull text) {
            if (index==0) {
                return;
            }
            int select=[text intValue];
            NSString *fileName=list[select];
            
            [self clear];
            [self addGroupWithName:ccstr(@"sprite/%@",fileName)];
            [self updateGroupWithName:spriteSaveName];
            [self updateFileNameL];
        }];
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"-"]) {
        [self cutMaker:group atIndex:currentIndex];
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"帧"]) {
        [CC_Alert showTextFieldAltOn:self title:@"" msg:@"全部跳到第几帧" placeholder:@"0" bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name, NSString * _Nonnull text) {
            if (index==0) {
                return;
            }
            int value=[text intValue];
            if (value==0) {
                [CC_Notice show:@"大于1"];
                return;
            }
            for (int i=0; i<makers.count; i++) {
                CC_SpriteMaker *maker=makers[i];
                [maker step:value];
            }
        }];
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"+首帧"]) {
        for (int i=0; i<makers.count; i++) {
            CC_SpriteMaker *maker=makers[i];
            [maker addFirtStep];
        }
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"+末帧"]) {
        for (int i=0; i<makers.count; i++) {
            CC_SpriteMaker *maker=makers[i];
            [maker addLastStep];
        }
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"+帧"]) {
        [CC_Alert showTextFieldAltOn:self title:@"" msg:@"" placeholder:@"copy step of index?" bts:@[@"取消",@"确定",@"反转"] block:^(int index, NSString * _Nonnull name, NSString * _Nonnull text) {
            if (index==0) {
                return ;
            }
            int step=[text intValue];
            if ([name isEqualToString:@"确定"]) {
                for (int i=0; i<makers.count; i++) {
                    CC_SpriteMaker *maker=makers[i];
                    [maker addStep:step mirror:NO];
                }
            }
            if ([name isEqualToString:@"反转"]) {
                for (int i=0; i<makers.count; i++) {
                    CC_SpriteMaker *maker=makers[i];
                    [maker addStep:step mirror:YES];
                }
            }
        }];
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"-帧"]) {
        for (int i=0; i<makers.count; i++) {
            CC_SpriteMaker *maker=makers[i];
            [maker cutStep];
        }
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"换"]) {
        [CC_Alert showTextFieldAltOn:self title:@"" msg:@"copy current step to?" placeholder:@"step index" bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name, NSString * _Nonnull text) {
            
            if ([name isEqualToString:@"确定"]) {
                int step=[text intValue];
                for (int i=0; i<makers.count; i++) {
                    CC_SpriteMaker *maker=makers[i];
                    [maker copyStepTo:step];
                }
            }
        }];
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"+b"]) {
        [CC_Alert showTextFieldAltOn:self title:@"" msg:@"add block" placeholder:@"state name" bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name, NSString * _Nonnull text) {
            if ([name isEqualToString:@"确定"]) {
                for (int i=0; i<makers.count; i++) {
                    CC_SpriteMaker *maker=makers[i];
                    [maker addBlock:text];
                }
            }
        }];
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"-b"]) {
        for (int i=0; i<makers.count; i++) {
            CC_SpriteMaker *maker=makers[i];
            [maker removeBlock];
        }
        return;
    }
//    if ([bt.titleLabel.text isEqualToString:@"旋"]) {
//        for (int i=0; i<makers.count; i++) {
//            CC_SpriteMaker *maker=makers[i];
//            [maker removeBlock];
//        }
//        return;
//    }
    if ([bt.titleLabel.text isEqualToString:@"+动作"]) {
        [CC_Alert showTextFieldAltOn:self title:@"" msg:@"give an action name" placeholder:@"" bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name, NSString * _Nonnull text) {
            
            if (index==0) {
                return;
            }
            for (int i=0; i<makers.count; i++) {
                CC_SpriteMaker *maker=makers[i];
                [maker addActionWithName:text];
            }
        }];
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"秒"]) {
        [CC_Alert showTextFieldAltOn:self title:@"" msg:@"设置延时时间" placeholder:@"" bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name, NSString * _Nonnull text) {
            if (index==0) {
                return ;
            }
            for (int i=0; i<makers.count; i++) {
                CC_SpriteMaker *maker=makers[i];
                [maker delay:text];
            }
        }];
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"整移"]) {
        [CC_Alert showTextFieldsAltOn:self title:@"" msg:@"输入位移的xy坐标" placeholders:@[@"x",@"y"] bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name, NSArray * _Nonnull texts) {
            if (index==0) {
                return;
            }
            for (int i=0; i<makers.count; i++) {
                CC_SpriteMaker *maker=makers[i];
                [maker moveSteps:texts];
            }
        }];
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"移"]) {
        [CC_Alert showTextFieldsAltOn:self title:@"" msg:@"输入位移的xy坐标" placeholders:@[@"x",@"y"] bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name, NSArray * _Nonnull texts) {
            if (index==0) {
                return;
            }
            for (int i=0; i<makers.count; i++) {
                CC_SpriteMaker *maker=makers[i];
                [maker moveStep:texts];
            }
        }];
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"留"]) {
        [CC_Alert showAltOn:self title:@"" msg:@"stay?" bts:@[@"取消停留",@"停留",] block:^(int index, NSString * _Nonnull name) {
            
            for (int i=0; i<makers.count; i++) {
                CC_SpriteMaker *maker=makers[i];
                [maker stay:index];
            }
        }];
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"反"]) {
        [CC_Alert showAltOn:self title:@"" msg:@"stay?" bts:@[@"取消反转",@"反转",] block:^(int index, NSString * _Nonnull name) {
            
            for (int i=0; i<makers.count; i++) {
                CC_SpriteMaker *maker=makers[i];
                [maker reverse:index];
            }
        }];
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"隐"]) {
        for (int i=0; i<makers.count; i++) {
            CC_SpriteMaker *maker=makers[i];
            [maker hiddenPoints];
        }
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"大小"]) {
        [CC_Alert showTextFieldAltOn:self title:@"" msg:@"" placeholder:@"scale size" bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name, NSString * _Nonnull text) {
            if (index==0) {
                return ;
            }
            float rate=[text floatValue];
            for (int i=0; i<makers.count; i++) {
                CC_SpriteMaker *maker=makers[i];
                [maker scaleRate:rate];
            }
        }];
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"预览"]) {
        for (int i=0; i<makers.count; i++) {
            CC_SpriteMaker *maker=makers[i];
            [maker preview];
        }
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"编辑"]) {
        for (int i=0; i<makers.count; i++) {
            CC_SpriteMaker *maker=makers[i];
            [maker edit];
        }
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"播放"]) {
        [bt setTitle:@"停止" forState:UIControlStateNormal];
        for (int i=0; i<makers.count; i++) {
            CC_SpriteMaker *maker=makers[i];
            [maker play];
        }
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"停止"]) {
        [bt setTitle:@"播放" forState:UIControlStateNormal];
        for (int i=0; i<makers.count; i++) {
            CC_SpriteMaker *maker=makers[i];
            [maker stop];
        }
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"生成"]) {
        [CC_Alert showAltOn:self title:@"" msg:@"create sprite or part?" bts:@[@"取消",@"精灵",@"部位",@"基准"] block:^(int index, NSString * _Nonnull name) {
            if (index==0) {
                return;
            }
            if (index==1) {
                [self saveDemo];
                return;
            }
            if (index==2) {
                [self savePart];
            }
            if (index==3) {
                [self saveBase];
            }
        }];
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"X"]) {
        if (_fromVC) {
            [_fromVC dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        [[CC_Code getRootNav] dismissViewControllerAnimated:YES completion:nil];
        return;
    }else if ([bt.titleLabel.text isEqualToString:@"收起"]){
        [group updateLabels:@[@"展开"] selected:@[@"1"]];
        return;
    }else if ([bt.titleLabel.text isEqualToString:@"展开"]){
        [group updateLabels:groupMutArr selected:groupSelectMutArr];
        return;
    }
    
    currentIndex=index;
    
    [group clearSelect];
    [group updateSelect:YES atIndex:index];
    CC_SpriteMaker *maker=makers[index];
    [makerView bringSubviewToFront:maker.baseView];
    
}

- (void)spriteMaker:(CC_SpriteMaker *)maker didSelectActionAtIndex:(int)index name:(NSString *)name{
    for (int i=0; i<makers.count; i++) {
        CC_SpriteMaker *maker=makers[i];
        [maker action:name];
    }
}

- (void)spriteMaker:(CC_SpriteMaker *)maker didSelectStepAtIndex:(int)index{
    for (int i=0; i<makers.count; i++) {
        CC_SpriteMaker *maker=makers[i];
        [maker step:index];
    }
}

- (void)spriteMaker:(CC_SpriteMaker *)maker addActionWithName:(NSString *)name{
    for (int i=0; i<makers.count; i++) {
        CC_SpriteMaker *maker=makers[i];
        [maker addActionWithName:name];
    }
}

- (void)spriteMaker:(CC_SpriteMaker *)maker deleteActionWithName:(NSString *)name{
    for (int i=0; i<makers.count; i++) {
        CC_SpriteMaker *maker=makers[i];
        [maker deleteActionWithName:name];
    }
}

- (void)spriteMaker:(CC_SpriteMaker *)maker renameActionWithName:(NSString *)name{
    for (int i=0; i<makers.count; i++) {
        CC_SpriteMaker *maker=makers[i];
        [maker renameActionWithName:name];
    }
}

- (void)spriteMakerCopyAction:(CC_SpriteMaker *)maker{
    for (int i=0; i<makers.count; i++) {
        CC_SpriteMaker *maker=makers[i];
        [maker copyAction];
    }
}

- (void)cutMaker:(CC_AutoLabelGroup *)group atIndex:(int)index{
    if (pathJSONMutArr.count<=1) {
        [CC_Notice show:@"至少有一组"];
        return;
    }
    [pathJSONMutArr removeObjectAtIndex:index];
    
    CC_SpriteMaker *maker=makers[index];
    [maker.baseView removeFromSuperview];
    [makers removeObjectAtIndex:index];
    
    [groupMutArr removeObjectAtIndex:pathJSONMutArr.count];
    groupSelectMutArr=[[NSMutableArray alloc]init];
    for (int i=0; i<groupMutArr.count; i++) {
        if (i==pathJSONMutArr.count-1) {
            [groupSelectMutArr addObject:@"1"];
        }else{
            [groupSelectMutArr addObject:@"0"];
        }
    }
    [group updateLabels:groupMutArr selected:groupSelectMutArr];
}

- (void)addMaker:(CC_AutoLabelGroup *)group name:(NSString *)name{
    NSString *newBaseStr=[NSString stringWithFormat:@"{\"actions\":[],\"base\":[0,0],\"name\":\"%@\"}",name];
    NSDictionary *newMaker=[CC_Convert dictionaryWithJsonString:newBaseStr];
    [pathJSONMutArr addObject:newMaker];
    
    CC_SpriteMaker *maker=[[CC_SpriteMaker alloc]initOn:makerView withFile:newMaker];
    [makers addObject:maker];
    
    [groupMutArr insertObject:name atIndex:pathJSONMutArr.count-1];
    groupSelectMutArr=[[NSMutableArray alloc]init];
    for (int i=0; i<groupMutArr.count; i++) {
        if (i==pathJSONMutArr.count-1) {
            [groupSelectMutArr addObject:@"1"];
        }else{
            [groupSelectMutArr addObject:@"0"];
        }
    }
    [group updateLabels:groupMutArr selected:groupSelectMutArr];
}

- (void)saveBase{
    [CC_Alert showTextFieldAltOn:self title:@"" msg:@"save as?" placeholder:@"base name" bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name, NSString * _Nonnull text) {
        if (index==0) {
            return ;
        }
        
        [self updatePathJson];
        
        NSMutableArray *baseMutArr=[[NSMutableArray alloc]init];
        for (int i=0; i<pathJSONMutArr.count; i++) {
            NSDictionary *tempDic=pathJSONMutArr[i];
            NSMutableDictionary *mutDic=[[NSMutableDictionary alloc]init];
            [mutDic setObject:tempDic[@"base"] forKey:@"base"];
            [mutDic setObject:tempDic[@"name"] forKey:@"name"];
            [baseMutArr addObject:mutDic];
        }
        id file=[CC_Convert convertToJSONData:baseMutArr];
        NSString *saveName=ccstr(@"sprite/base_%@",text);
        [ccs saveLocalFile:file withPath:saveName andType:@"json"];
        [CC_Notice show:ccstr(@"已生成%@到沙盒",saveName)];
        CCLOG(@"path=%@",[NSString stringWithFormat:@"%@", NSHomeDirectory()]);
    }];
}

- (void)savePart{
    NSMutableDictionary *partDic=[NSMutableDictionary dictionaryWithDictionary:pathJSONMutArr[currentIndex]];
    [CC_Alert showTextFieldsAltOn:self title:@"" msg:@"" placeholders:@[partDic[@"name"],@"save name?"] bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name, NSArray * _Nonnull texts) {
        if (index==0) {
            return ;
        }
        
        [self updatePathJson];
        
        NSString *partName=texts[0];
        if (partName.length>0) {
            [partDic setObject:texts[0] forKey:@"name"];
        }
        
        id file=[CC_Convert convertToJSONData:@[partDic]];
        NSString *saveName=ccstr(@"sprite/part_%@",texts[1]);
        [ccs saveLocalFile:file withPath:saveName andType:@"json"];
        [CC_Notice show:ccstr(@"已生成%@到沙盒",saveName)];
        CCLOG(@"path=%@",[NSString stringWithFormat:@"%@", NSHomeDirectory()]);
    }];
    [CC_Alert showTextFieldAltOn:self title:@"" msg:@"save as?" placeholder:@"part name" bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name, NSString * _Nonnull text) {
        if (index==0) {
            return ;
        }
        
        [self updatePathJson];
        
        NSMutableDictionary *partDic=[NSMutableDictionary dictionaryWithDictionary:pathJSONMutArr[currentIndex]];
        [partDic setObject:text forKey:@"name"];
        
        id file=[CC_Convert convertToJSONData:@[partDic]];
        NSString *saveName=ccstr(@"sprite/part_%@",text);
        [ccs saveLocalFile:file withPath:saveName andType:@"json"];
        [CC_Notice show:ccstr(@"已生成%@到沙盒",saveName)];
        CCLOG(@"path=%@",[NSString stringWithFormat:@"%@", NSHomeDirectory()]);
    }];
}

- (void)saveDemo{
    [CC_Alert showTextFieldAltOn:self title:@"" msg:@"save as?" placeholder:@"sprite name" bts:@[@"取消",@"默认",@"确定"] block:^(int index, NSString * _Nonnull name, NSString * _Nonnull text) {
        if (index==0) {
            return ;
        }
        if (spriteSaveName.length<=0) {
            spriteSaveName=@"sprite/drawDemo";
        }
        if ([name isEqualToString:@"确定"]&&text.length>0){
            spriteSaveName=ccstr(@"sprite/%@",text);
        }
        
        [self updatePathJson];
        
        if (![spriteSaveName hasSuffix:@".json"]) {
            spriteSaveName=[spriteSaveName stringByAppendingString:@".json"];
        }
        
        id file=[CC_Convert convertToJSONData:pathJSONMutArr];
        [ccs saveLocalFile:file withPath:spriteSaveName andType:nil];
        [CC_Notice show:ccstr(@"已生成%@到沙盒",spriteSaveName)];
        CCLOG(@"path=%@",[NSString stringWithFormat:@"%@", NSHomeDirectory()]);
    }];
    
//    //矫正
//    NSMutableArray *newMutArr=[[NSMutableArray alloc]init];
//    for (int i=0; i<pathJSONMutArr.count; i++) {
//        NSArray *baseList=pathJSONMutArr[i][@"list"];
//        NSMutableArray *actions=[NSMutableArray arrayWithArray:pathJSONMutArr[i][@"actions"]];
//        for (int m=0; m<actions.count; m++) {
//            NSMutableArray *actionList=[NSMutableArray arrayWithArray:actions[m][@"list"]];
//            for (int n=0; n<actionList.count; n++) {
//                NSMutableArray *stepList=[NSMutableArray arrayWithArray:actionList[n][@"list"]];
////                for (int l=0; l<stepList.count; l++) {
////                    NSArray *point=stepList[l];
////
////                    [stepList replaceObjectAtIndex:l withObject:@[@([point[0] floatValue]-[baseList[l][0]floatValue]),@([point[1] floatValue]-[baseList[l][1]floatValue])]];
////                }
//
//                NSMutableDictionary *newStepMutDic=[[NSMutableDictionary alloc]initWithDictionary:actionList[n]];
//
//                NSMutableArray *newStep=[[NSMutableArray alloc]init];
//                for (int xx=0; xx<stepList.count; xx++) {
//                    [newStep addObject:@([stepList[xx][0]floatValue])];
//                    [newStep addObject:@([stepList[xx][1]floatValue])];
//                }
//                [newStepMutDic setObject:newStep forKey:@"delta"];
//                [newStepMutDic removeObjectForKey:@"list"];
//                [actionList replaceObjectAtIndex:n withObject:newStepMutDic];
//            }
//
//            NSMutableDictionary *newActionMutDic=[[NSMutableDictionary alloc]initWithDictionary:actions[m]];
//
//            [newActionMutDic setObject:actionList forKey:@"events"];
//            [newActionMutDic removeObjectForKey:@"list"];
//            [actions replaceObjectAtIndex:m withObject:newActionMutDic];
//        }
//
//        NSMutableDictionary *newMutDic=[[NSMutableDictionary alloc]init];
//        NSArray *temn=@[@"head",@"left_arm",@"right_arm",@"body",@"left_leg",@"right_leg",@"arm"];
//        [newMutDic setObject:temn[i] forKey:@"name"];
//        [newMutDic setObject:actions forKey:@"actions"];
//
//        NSMutableArray *newBaseList=[[NSMutableArray alloc]init];
//        for (int xx=0; xx<baseList.count; xx++) {
//            [newBaseList addObject:@([baseList[xx][0]floatValue])];
//            [newBaseList addObject:@([baseList[xx][1]floatValue])];
//        }
//        [newMutDic setObject:newBaseList forKey:@"base"];
//
//        [newMutArr addObject:newMutDic];
//    }
    
}

- (void)updatePathJson{
    for (int i=0; i<makers.count; i++) {
        CC_SpriteMaker *maker=makers[i];
        [pathJSONMutArr replaceObjectAtIndex:i withObject:maker.pathJSON];
    }
}

@end
