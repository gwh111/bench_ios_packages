//
//  ViewController.m
//  bench_ios_packages
//
//  Created by gwh on 2019/6/12.
//  Copyright © 2019 gwh. All rights reserved.
//

#import "ViewController.h"
#import "CC_SpriteMakerVC.h"

@interface ViewController (){
    NSArray *testList;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor=COLOR_WHITE;
    
    testList=@[@{@"title":@"制作精灵"},@{@"title":@"预览精灵",@"className":@"CC_SpriteTestVC"}];
    
    UITableView *tab=[[UITableView alloc]initWithFrame:CGRectMake(0, [ccui getY]+RH(50), self.view.width, self.view.height-[ccui getY]-RH(50))];
    [self.view addSubview:tab];
    tab.delegate=self;
    tab.dataSource=self;
    tab.backgroundColor=[UIColor whiteColor];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [testList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier: CellIdentifier];
    }else{
        while ([cell.contentView.subviews lastObject] != nil) {
            [(UIView *)[cell.contentView.subviews lastObject] removeFromSuperview];
        }
    }
    cell.textLabel.text=[testList objectAtIndex:indexPath.section][@"title"];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    if (indexPath.section==0) {
        
        [CC_SpriteMakerVC presentOnVC:self];
        return;
    }
    
    NSDictionary *dic = testList[indexPath.section];
    NSString *name = dic[@"className"];
    Class cls = NSClassFromString(name);
    if (!cls) {
        [CC_Notice show:@"找不到class"];
        return;
    }
    UIViewController *vc = [[cls alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
    
}

@end
