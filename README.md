
[English](https://github.com/gwh111/bench_ios_packages/blob/master/README_EN.md)
## **CC_Sprite** 面向的主要用户群体
**CC_Sprite** 主要面向：
1. 没有ps、美术基础又想做小动画、小游戏的iOS开发。
2. 你不想学习ps或其他动画软件，也不想安装其他软件，你只想做一个单纯的、天真的iOS开发。
3. 你能接受虽然没有商业级的动画那么强大，但能表现一些常规动作的火柴人动画。（如果你足够耐心，将各个模块细节拆分配上不同配色，也是可以做出精致的矢量动画的）
那么你可以尝试使用一下简单的 **CC_Sprite**

## 示例
通过示例简单看一下精灵的动作效果：  
我们可以看下一些我做的精灵模型（等后面有空，我会自己设计一个比较细节的英雄模型来看它能达到的效果），这些开放出来可以随意使用，也可以在此基础上修改。一起共享你制作的精灵吧：  
<img src="https://github.com/gwh111/bench_ios_packages/blob/master/test1.gif" width="240">

以上效果用到的代码为：
```
CC_Sprite *sp1=[[CC_Sprite alloc]initOn:self.view withFilePath:fileName scaleSize:0.4 speedRate:1];//初始化
[sp1 updatePosition:CGPointMake(self.view.center.x-100, self.view.center.y)];//调整位置
[sp1 updateColors:@{@"arm":[UIColor yellowColor]}];//更新部位颜色
[sp1 playAction:@"atk" times:1 block:^(NSString * _Nonnull state, CC_Sprite * _Nonnull sprite) {

}];//播放动作
```

## 使用
### 安装工具库
#### Podfile

To integrate bench_ios into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

target 'TargetName' do
pod 'bench_ios'
end
```

Then, run the following command:

```bash
$ pod install
```
========  
精灵文件还没有制作库，可以拷贝以下文件到目录中：
### 如果使用 **CC_Sprite** 需要文件：
1. CC_Sprite.h、CC_Sprite.m
2. CC_SpriteItem.h、CC_SpriteItem.m
### 如果制作 **CC_Sprite** 模型，需要文件：
1. CC_SpriteMakerVC.h、CC_SpriteMakerVC.m
2. CC_SpriteMaker.h、CC_SpriteMaker.m
3. CC_SpriteBaseView.h、CC_SpriteBaseView.m
### 如果测试 **CC_Sprite** 模型完整效果，可以使用：
1. CC_SpriteTestVC.h、CC_SpriteTestVC.m

## 优势
相比于传统逐帧动画、原生动画API有以下优势：  
1. 最小的体积：传统的动画需要提供每一帧图片。而 **CC_Sprite** 动画只保存骨骼的动画数据，它所占用的空间非常小，*只需一个json文件*，无需任何图片资源。
2. 美术需求：**CC_Sprite** 无需任何图片资源所以任何程序员可以独立完成整个动画，无需ps、美术软件基础。
3. 流畅性：**CC_Sprite** 动画使用差值算法计算中间帧，这能让你的动画总是保持流畅的效果。
4. 复用：一套动作可以复用置另一个精灵，一个精灵每个模块都可替换（如武器的替换）。
5. 可视化：SpriteKit等iOS原生动画只有编译后才可看到效果，开发完全凭空想象，**CC_Sprite** 对每一关键帧可以即时预览。
6. 软件成本：几乎为0，无需安装和学习任何其他软件，直接在原生iOS模拟器创建精灵🧚‍♂️，展示的即是真实效果，省去调试API的步骤。

## 运行原理
使用 **CC_SpriteMaker** 制作的精灵🧚‍♂️生成json文件，包含每个关节的关键点，使用 **CC_Sprite** 播放时利用差值计算中间状态。

## 功能
1. 部位：将精灵分解成各个部位，单独对部位进行调整。
2. 动作：将每个部位动作分解，各个动作独立。
3. 组合：可以在任何关键帧插入回调，自由组合多个动画或变化。

## 运行环境
iOS模拟器或真机，因为全部使用iOS自带库封装，基本没有兼容问题。

## 支持
可以在[https://github.com/gwh111/bench_ios](https://github.com/gwh111/bench_ios_packages)留言交流问题或建议。

## 问题和完善
1. 还不支持图片的导入（不用其他库的前提下没有找到图片自由变形的方案，还需要考虑计算量）
2. 模拟器可能会掉帧出现部位跟不上刷新问题，真机不会出现

## 调用方法
### 使用精灵🧚‍♂️
详细介绍 **CC_Sprite** 有哪些属性和方法，可以实现哪些功能。  
<img src="https://github.com/gwh111/bench_ios_packages/blob/master/test2.gif" width="240">
#### *创建精灵*
有两种方法：
1. 从工程目录读取文件
```
CC_Sprite *sp1=[[CC_Sprite alloc]initOn:self.view withFilePath:@"sprite/man" scaleSize:0.4 speedRate:1];
```
2. 另一种是从沙盒读取文件（一般只在调试时使用）
```
CC_Sprite *sp1=[[CC_Sprite alloÂc]initOn:self.view withLocalFilePath:@"sprite/man" scaleSize:0.4 speedRate:1];
```
#### *配置精灵*
*属性*
```
@property(nonatomic,retain) NSMutableArray *items;
```
items是精灵的每个部件。后面会讲到部件类CC_SpriteItem。  

*方法*
更新精灵的位置，是以制作时的中心所在的位置为基准：
```
- (void)updatePosition:(CGPoint)position;
```

更新精灵的部位颜色：
```
- (void)updateColors:(NSDictionary *)colorDic;
```
以部位名-颜色的方式设置，如：
```
[sp1 updateColors:@{@"arm":[UIColor yellowColor]}];
```

更新精灵的尺寸：
```
- (void)updateScale:(float)scale;
```

更新精灵的播放速度：
```
- (void)updateSpeed:(float)speed;
```

更新精灵的反转情况，通过反转形成左右对立需求：
```
- (void)updateReverse:(BOOL)reverse;
```

名词解释：在这里
**精灵=多个部件组成的整体+各个部件动作**  
**部件=部件形状+各个动作**  
**基准=一个精灵各个部件的形状**
所以更新了部件，那么这个部位的形状和这个部位的动作会发生改变。更新了基准，这个精灵的形状发生改变，而动作不变。
更新精灵所有基础部件使用：
```
- (void)updateBaseListWithFilePath:(NSString *)fileName;
```
使用场景如制作了一个普通英雄 *man.json*，包含了走路、攻击等动作，又想制作一个比较胖的英雄但不想重新做一遍动作，只需：
1. 调整 *man.json* 每个部件的形状，手臂拉拉粗，身体拉圆一点
2. 删除其余动作，然后生成一个没有动作的 *fatman.json*
3. 初始化 *man.json*，使用 **updateBaseListWithFilePath:@"fatman"** 来替换模型。
4. 这样你就得到了一个包含 *man.json* 全部动作的fatman精灵。

更新精灵部分部件使用：
```
- (void)updateBasePart:(NSString *)name withFilePath:(NSString *)fileName;
```
使用场景如制作了一个普通英雄 *man.json*，它有个名为 *arm* 的部件作为武器，你想更换他的武器，只需：
1. 新建一个精灵，绘制一把新的武器，保存为 *sword.json*
2. 使用 **updateBasePart:@"arm" withFilePath:@"sword"** 来替换 *arm* 部件的武器。

拿掉精灵部件使用：
```
- (void)removePart:(NSString *)name;
```
比如把英雄的武器拿掉 **removePart:@"arm"**

播放精灵动画使用：
```
- (void)playAction:(NSString *)name repeat:(int)repeat block:(nullable void(^)(NSString *state, CC_Sprite *sprite))block;
```
@name 动画的名字  
@repeat 动画播放重复次数  


停止精灵当前进行的动画使用：
```
- (void)stop;
```
把精灵移除会自动先调用stop方法，使用：
```
- (void)remove;
```

### 制作精灵🧚‍♂️
<img src="https://github.com/gwh111/bench_ios_packages/blob/master/test3.png" width="240">

调用制作的方法很简单，首先从你的测试工程起调制作控制器：  

```
[CC_SpriteMakerVC presentOnVC:self];
```

#### 精灵结构分析
和Spine结构略有不同，Spine是使用动作+节点的方式生成json文件，节点和动作平铺在外，而CC_Sptire使用节点+动作的形式。起先在这两种方式上考虑了很久，最终选择现在的模式，这样分的好处是：
1. 更换某个部位如：武器时只需替换武器的整个包结构，如果是用动作+节点就需要对每个动作做出调整，因为不同武器不仅形状不一样，动作也不一样。
2. 制作精灵和运行精灵可以共用一套逻辑，节点+动作的结构因为每个部位独立比较利于修改和调整。

#### 精灵功能模块
这里的操作会对精灵每个部位同步设置，可以理解为所有部位模块在这里是一个整体。  
##### *新*
清空当前精灵和画布，构建一个空的新精灵。
##### *切换*
从沙盒选择精灵模型或部位模型。
##### *复制*
可以复制一个部位，包括它的所有动作。
##### *+*
增加一个空白的部位。
##### *++*
从沙盒选择一个部位，如选择不同的武器来添加到当前精灵，使用后从精灵移除这个部位，也可以保留。
##### *-*
删除这个部位。
##### *+帧*
拷贝指定帧到新帧。
##### *换*
把当前帧拷贝到指定帧。
##### *-帧*
删除当前帧。
##### *+b*
添加一个block，可以自定义block名，添加后播放到这帧会有block回调。
##### *-b*
移除当前block。
##### *秒*
设定从上一个动作到当前动作执行的时间。
##### *整移*
整体移动，在画布保持不动，在实际播放时会移动响应的值。
##### *移*
移动所有部位，是实际的点的移动。
##### *留*
当前帧保持不动停留到下一帧，中间不会有过渡。

**以下是编辑时的功能**
##### *隐*
隐藏所有编辑点。
##### *预览*
查看填充颜色的效果。
##### *编辑*
回归编辑的模式。
##### *播放*
整体播放一遍动作。
##### *生成*
生成文件到沙盒。包括精灵、部位和基准。这三者差别请看上面名词解释。
##### *收起*
为了使画布更大，收起上面的功能。

#### 动作功能模块
##### *动作*
弹出所有动作选择列表，选择对应动作。
##### *+*
增加一个动作。
##### *复制*
复制一个动作。
##### *-*
删除一个动作。
##### *名*
修改当前动作的名称。

#### 动作关键帧模块
**以下操作都是对当前选中部位，其他部位不影响**
##### *基准*
是当前部位的核心，是一切动作的基础，是一个形状。
##### *+帧*
拷贝指定帧到新帧。
##### *换*
把当前帧拷贝到指定帧。
##### *-帧*
删除当前帧。
##### *移*
移动当前部位的位置。
##### *隐*
隐藏当前部位编辑点。
##### *左/右*
向左/右添加关键点，在创建基准时使用。
##### *删*
删除最后一个编辑点。
##### *存*
**添加点或移动后，认为确定了，存一下，要撤销就重新点下当前帧**
修改点后只是修改了缓存的点位置坐标，存可以把位置坐标转换成json文件，而生成是把json文件存到沙盒。

### 如何制作精灵🧚的建议‍
整个精灵的运作使用了苹果的 **<QuartzCore>** 库，使用了 **CADisplayLink** 作为帧刷新的定时器。这样的好处是GPU绘制，并且帧率稳定，因为据说 **CADisplayLink** 是以屏幕刷新周期作为回调的，这样最大限度使用了手机的帧数刷新速率。  

理解贝塞尔曲线。精灵的每个部位都使用 **CAShapeLayer** 绘制，并在每个刷新周期调整 *path* 属性进行绘制。贝塞尔曲线通过三个点控制一段曲线，拥有足够多的贝塞尔线段就可以绘制任意图形，并且方便地进行变形。  

绘制精灵的要点是把握关键点，是了解结构。人体共有206块骨，我们并不需要每个关节都能变形，使用多少贝塞尔线段取决于你对模型的精细程度。将目标点放在关节处，就是两根骨头的连接点，来控制关节的移动。将控制点放在两个关节之间，来控制胖瘦。这样做出的精灵和动作符合正常物理规律。  

如何做一个动作，就是将整个动作拆分成关键帧，绘制关键帧后，计算机会自动计算中间帧。将它们连起来播放，你会惊喜地发现虽然只是一个轮廓，你的大脑🧠可以脑补出整个画面，既充满神秘又能理解动作。这让我想起小时候外公教我中国画，总是说在意不在形，小时候理解不了，总觉得要画的像，但中国画（写意不是工笔）的内涵就在于意，在像与不像之间。你仔细看，不像，但忽的一看，又能脑补整个场景。**CC_Sprite** 的精髓就在这里。当然，你也可以添加更多部位，比如拆分眼睛，嘴巴等细节来细化精灵，但这样相对比较耗时。

不知大家有没有玩过《火焰纹章》掌机游戏，其实很多动作我都是参考这个游戏内的英雄，他们的战斗运动方式。刚开始制作到一半时才去看Spine的json文件，发现和它结构完全反了，担心后面会有问题，做了一半又不想重新开始就硬着头皮做了下去，最后发现意外的好用，这种结构利于拆分，至少适应了我的需求。后面再完善制作的功能……
