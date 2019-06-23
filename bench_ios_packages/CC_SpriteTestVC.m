//
//  testDrawPlayVC.m
//  bench_ios
//
//  Created by gwh on 2019/5/16.
//  Copyright © 2019 apple. All rights reserved.
//

#import "CC_SpriteTestVC.h"
#import "CC_Sprite.h"
#import "CC_AutoLabelGroup.h"

@interface CC_SpriteTestVC ()<CC_AutoLabelGroupDelegate>{
    CC_Sprite *sp1;
    CC_Sprite *sp2;
    
//    CC_Sprite *sp2_hited;
//    CC_Sprite *sp1_hited;
    
    CC_AutoLabelGroup *group;
    
    UIScrollView *scrollV;
}

@end

@implementation CC_SpriteTestVC

- (void)viewWillDisappear:(BOOL)animated{
    [sp1 remove];
    sp1=nil;
    [sp2 remove];
    sp2=nil;
    group.delegate=nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSArray *list=[ccs getLocalFileListWithDocumentName:@"sprite" withType:@"json"];
    NSString *fileName;
    if (list.count>0) {
        fileName=list[0];
        fileName=[fileName stringByReplacingOccurrencesOfString:@".json" withString:@""];
        fileName=ccstr(@"sprite/%@",fileName);
        
        if ([ccs getDefault:@"defaultSpriteTestName"]) {
            fileName=[ccs getDefault:@"defaultSpriteTestName"];
        }
    }else{
        fileName=@"sprite/man";
    }

    sp1=[[CC_Sprite alloc]initOn:self.view withFilePath:fileName scaleSize:0.4 speedRate:1];
//    sp1=[[CC_Sprite alloc]initOn:self.view withFilePath:fileName scaleSize:0.4 speedRate:1];
    [sp1 updatePosition:CGPointMake(self.view.center.x-100, self.view.center.y)];
    [sp1 updateColors:@{@"arm":[UIColor yellowColor],
                        }];
    [sp1 playAction:@"ready" times:0 block:^(NSString * _Nonnull state, CC_Sprite * _Nonnull sprite) {
        
    }];
    
    [sp1 updateColors:@{@"hair":ccRGBA(222, 222, 222, 1),
                        @"hair2":ccRGBA(235, 235, 235, 1),
                        @"flower":ccRGBA(215, 215, 215, 1),
                        @"body":ccRGBA(255, 255, 255, 0.85),
                        @"left_arm":ccRGBA(255, 255, 255, 0.85),
                        @"right_arm":ccRGBA(255, 255, 255, 0.85),
                        @"left_leg":ccRGBA(255, 255, 255, 0.95),
                        @"right_leg":ccRGBA(255, 255, 255, 0.95),
                        @"dress":ccRGBA(255, 255, 255, 0.8),
                        @"dress_s1":ccRGBA(255, 255, 255, 0.82),
                        @"dress_s2":ccRGBA(255, 255, 255, 0.82),
                        @"dress_b":ccRGBA(255, 255, 255, 0.7),
                        }];
    

    sp2=[[CC_Sprite alloc]initOn:self.view withFilePath:@"sprite/man2" scaleSize:0.4 speedRate:1];
//    sp2=[[CC_Sprite alloc]initOn:self.view withFilePath:fileName scaleSize:0.4 speedRate:1];
    [sp2 updateReverse:YES];
    [sp2 updatePosition:CGPointMake(self.view.center.x+100, self.view.center.y)];
    [sp2 removePart:@"arm"];
    [sp2 playAction:@"ready" times:0 block:^(NSString * _Nonnull state, CC_Sprite * _Nonnull sprite) {
        
    }];
    
    scrollV=[[UIScrollView alloc]initWithFrame:CGRectMake(0, RH(70), [ccui getW], RH(200))];
    [self.view addSubview:scrollV];
    
    group=[[CC_AutoLabelGroup alloc]initWithFrame:CGRectMake(0, 0, 100, 10)];
    group.delegate=self;
    [group updateType:CCAutoLabelAlignmentTypeLeft width:[ccui getW] stepWidth:[ccui getRH:5] sideX:[ccui getRH:10] sideY:[ccui getRH:10] itemHeight:[ccui getRH:30] margin:[ccui getRH:15]];
    [scrollV addSubview:group];
    
    //单元样本创建
    CC_Button *sampleBt=[[CC_Button alloc]init];
    [sampleBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sampleBt setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [sampleBt setBackgroundColor:[UIColor grayColor]];
    [sampleBt setBackgroundColor:[UIColor grayColor] forState:UIControlStateNormal];
    [sampleBt setBackgroundColor:ccRGBA(11, 11, 11, 1) forState:UIControlStateSelected];
    sampleBt.titleLabel.font=[ccui getRFS:16];
    group.sampleBt=sampleBt;
    
    [self updateGroup];
}

- (void)updateGroup{
    NSMutableArray *mutArr=[[NSMutableArray alloc]init];
    [mutArr addObject:@"切换"];
    [mutArr addObject:@"部位"];
    [mutArr addObject:@"基准"];
    [mutArr addObjectsFromArray:[sp1 getActionNames]];
    [group updateLabels:mutArr selected:nil];
}

- (void)dealloc{
    CCLOG(@"dealloc");
}

- (void)autoLabelGroup:(CC_AutoLabelGroup *)group btFinishInit:(UIButton *)bt{
    [CC_Code setRadius:4 view:bt];
    [CC_Code setLineColor:COLOR_WHITE width:1 view:bt];
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
            fileName=[fileName stringByReplacingOccurrencesOfString:@".json" withString:@""];
            fileName=ccstr(@"sprite/%@",fileName);
            
            [ccs saveDefaultKey:@"defaultSpriteTestName" andV:fileName];
            
            [sp1 remove];
            sp1=[[CC_Sprite alloc]initOn:self.view withFilePath:fileName scaleSize:0.4 speedRate:1];
            [sp1 updatePosition:CGPointMake(self.view.center.x-RH(100), self.view.center.y)];
            [sp1 updateColors:@{@"arm":[UIColor yellowColor]}];
            [self updateGroup];
        }];
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"部位"]) {
        NSArray *list=[ccs getLocalFileListWithDocumentName:@"sprite" withType:@"json"];
        CCLOG(@"%@",list);
        NSString *msg=@"";
        for (int i=0; i<list.count; i++) {
            NSString *temp=list[i];
            if ([temp hasPrefix:@"part_"]) {
                msg=[msg stringByAppendingString:[NSString stringWithFormat:@"%d. ",i]];
                msg=[msg stringByAppendingString:temp];
                msg=[msg stringByAppendingString:@"\n"];
            }
        }
        [CC_Alert showTextFieldAltOn:self title:@"" msg:msg placeholder:@"which one" bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name, NSString * _Nonnull text) {
            if (index==0) {
                return;
            }
            int select=[text intValue];
            NSString *fileName=list[select];
            fileName=[fileName stringByReplacingOccurrencesOfString:@".json" withString:@""];
            fileName=ccstr(@"sprite/%@",fileName);
            
            [sp1 updateBasePartWithFilePath:fileName];
        }];
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"基准"]) {
        NSArray *list=[ccs getLocalFileListWithDocumentName:@"sprite" withType:@"json"];
        CCLOG(@"%@",list);
        NSString *msg=@"";
        for (int i=0; i<list.count; i++) {
            NSString *temp=list[i];
            if ([temp hasPrefix:@"base_"]) {
                msg=[msg stringByAppendingString:[NSString stringWithFormat:@"%d. ",i]];
                msg=[msg stringByAppendingString:temp];
                msg=[msg stringByAppendingString:@"\n"];
            }
        }
        [CC_Alert showTextFieldAltOn:self title:@"" msg:msg placeholder:@"which one" bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name, NSString * _Nonnull text) {
            if (index==0) {
                return;
            }
            int select=[text intValue];
            NSString *fileName=list[select];
            fileName=[fileName stringByReplacingOccurrencesOfString:@".json" withString:@""];
            fileName=ccstr(@"sprite/%@",fileName);
            
            [sp1 updateBaseListWithFilePath:fileName];
        }];
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"stop"]) {
        [sp1 stop];
        return;
    }
    if ([bt.titleLabel.text isEqualToString:@"remove"]) {
        [CC_Alert showTextFieldAltOn:self title:@"" msg:@"remove which part?" placeholder:@"part name" bts:@[@"取消",@"确定"] block:^(int index, NSString * _Nonnull name, NSString * _Nonnull text) {
            if (index==0) {
                return ;
            }
            [sp1 removePart:text];
        }];
        return;
    }
    [sp1 playAction:bt.titleLabel.text times:1 block:^(NSString * _Nonnull state, CC_Sprite *sprite) {
        CCLOG(@"state=%@",state);
        if ([state isEqualToString:@"finish"]) {
            
            [sprite playAction:@"ready" times:0 block:^(NSString * _Nonnull state, CC_Sprite *sprite) {
            }];

        }
        if ([state hasSuffix:@"hit"]) {
            CC_Sprite *sp2_hited=[[CC_Sprite alloc]initOn:self.view withFilePath:@"sprite/hit" scaleSize:0.5 speedRate:1];
            [sp2_hited updatePosition:[sp2 getPosition]];
            [sp2_hited updateColors:@{@"hit":[UIColor redColor]}];
            [ccs delay:0.5 block:^{
                [sp2_hited remove];
            }];
        }
        if ([state hasSuffix:@"hit_s"]) {
            CC_Sprite *sp2_hited=[[CC_Sprite alloc]initOn:self.view withFilePath:@"sprite/hit_s" scaleSize:0.5 speedRate:1];
            [sp2_hited updatePosition:[sp2 getPosition]];
            [sp2_hited updateColors:@{@"hit":COLOR_LIGHT_YELLOW}];
            [sp2_hited playAction:@"hit" times:1 block:^(NSString * _Nonnull state, CC_Sprite * _Nonnull sprite) {
                [sprite remove];
                [UIView animateWithDuration:.5f animations:^{
                    
                } completion:^(BOOL finished) {
                    
                }];
            }];
        }
        if ([state hasSuffix:@"hit_right_down"]) {
            CC_Sprite *sp2_hited=[[CC_Sprite alloc]initOn:self.view withFilePath:@"sprite/hit_right_down" scaleSize:0.5 speedRate:1];
            [sp2_hited updatePosition:CGPointMake(self.view.center.x+RH(100), self.view.center.y)];
            [sp2_hited updateColors:@{@"hit":[UIColor redColor]}];
            [ccs delay:0.5 block:^{
                [sp2_hited remove];
            }];
        }
        if ([state isEqualToString:@"remove"]) {
            [sp1 removePart:@"arm"];
        }
    }];
}

- (void)autoLabelGroupUpdateFinish:(CC_AutoLabelGroup *)group{
    if (group.height>scrollV.height) {
        scrollV.contentSize=CGSizeMake(0, group.height);
    }
}

@end
