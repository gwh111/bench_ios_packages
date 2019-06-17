
## **CC_Sprite** Major user groups
**CC_Sprite** can offer people who is：
1. Without PS and art foundation, but want to do iOS development of small animations and games.
2. You don't want to learn PS or other animation software, and you don't want to install other software, you just want to do a simple, naive iOS development.
3. You can accept Matchman animation, which is not as powerful as commercial animation, but can perform some routine actions. (If you're patient enough, you can also make delicate vector animation by disassembling and assigning the details of each module to different colours.)
Then you can try **CC_Sprite**

## Example
Take a brief look at the action of the elves through examples，you can share your sprite later:  
<img src="https://github.com/gwh111/bench_ios_packages/blob/master/test1.gif" width="240">

The code used for the above effect is:
```
CC_Sprite *sp1=[[CC_Sprite alloc]initOn:self.view withFilePath:fileName scaleSize:0.4 speedRate:1];//init
[sp1 updatePosition:CGPointMake(self.view.center.x-100, self.view.center.y)];//adjust position
[sp1 updateColors:@{@"arm":[UIColor yellowColor]}];//update part color
[sp1 playAction:@"atk" times:1 block:^(NSString * _Nonnull state, CC_Sprite * _Nonnull sprite) {

}];//play action
```

## Use
### Installation Tool Library
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
You can copy the following files into the directory:
### for use **CC_Sprite** ：
1. CC_Sprite.h、CC_Sprite.m
2. CC_SpriteItem.h、CC_SpriteItem.m
### for make **CC_Sprite** models：
1. CC_SpriteMakerVC.h、CC_SpriteMakerVC.m
2. CC_SpriteMaker.h、CC_SpriteMaker.m
3. CC_SpriteBaseView.h、CC_SpriteBaseView.m
### for test **CC_Sprite** effect：
1. CC_SpriteTestVC.h、CC_SpriteTestVC.m

## Advantage
Compared with traditional frame-by-frame animation and native animation API, it has the following advantages:
1. Minimum volume: Traditional animation needs to provide every frame of picture. The **CC_Sprite** animation only saves the animation data of the skeleton, which occupies very little space, *only needs a JSON file* , and does not need any image resources.
2. Art Requirements: **CC_Sprite** does not require any image resources, so any programmer can complete the entire animation independently, without ps, art software foundation.
3. Fluency: **CC_Sprite** Animation uses the difference algorithm to calculate the intermediate frame, which can make your animation always keep fluent effect.
4. Reuse: A set of actions can be reused and placed by another wizard. Each module of a wizard can be replaced (e.g. weapon replacement).
5. Visualization: iOS native animations such as SpriteKit can only be seen after compilation. Development is entirely imaginary and **CC_Sprite** can preview every key frame in real time.
6. Software Cost: Almost 0, no need to install and learn any other software, directly create a sprite in the native iOS simulator, which shows the real effect, eliminating the steps of debugging the API.

## Operating Principle
The sprite produced by **CC_SpriteMaker** generates a JSON file containing the key points of each joint, and calculates the intermediate state by using the difference when playing **CC_Sprite**.

## Function
1. Location: The elves are decomposed into different parts, and the parts are adjusted separately.
2. Action: Each part of the action is decomposed and each action is independent.
3. Combination: You can insert callbacks in any key frame and combine multiple animations or changes freely.

## Operating environment
IOS simulator or real machine, because all of them are encapsulated by iOS own library, there is basically no compatibility problem.

## Support
You can leave message on [https://github.com/gwh111/bench_ios](https://github.com/gwh111/bench_ios_packages)

## Problems and Improvements
1. It does not support the import of pictures (without any other libraries, there is no solution for free deformation of pictures, also need to consider the amount of calculation)
2. The simulator may drop frames and fail to keep up with the refresh. The real machine will not appear.

## Call method
### use sprite 🧚‍
Detailed description of the attributes and methods of **CC_Sprite** and what functions can be achieved.
<img src="https://github.com/gwh111/bench_ios_packages/blob/master/test2.gif" width="240">
#### *create sprite*
有两种方法：
1. Read files from project catalog
```
CC_Sprite *sp1=[[CC_Sprite alloc]initOn:self.view withFilePath:@"sprite/man" scaleSize:0.4 speedRate:1];
```
2. The other is to read files from sandboxes (usually only for debugging purposes)
```
CC_Sprite *sp1=[[CC_Sprite alloÂc]initOn:self.view withLocalFilePath:@"sprite/man" scaleSize:0.4 speedRate:1];
```
#### *configure sprite*
*Property*
```
@property(nonatomic,retain) NSMutableArray *items;
```
Items are every part of the genie. The component class CC_SpriteItem will be mentioned later.

*Methods*
Updating the location of the sprite is based on the location of the center at the time of production:
```
- (void)updatePosition:(CGPoint)position;
```

Update the part color of the sprite:
```
- (void)updateColors:(NSDictionary *)colorDic;
```
Set in the form of location name-color, such as:
```
[sp1 updateColors:@{@"arm":[UIColor yellowColor]}];
```

update the sprite scaleSize:
```
- (void)updateScale:(float)scale;
```

Update sprite Play Speed:
```
- (void)updateSpeed:(float)speed;
```

Make sprite reverse:
```
- (void)updateReverse:(BOOL)reverse;
```

Noun Interpretation:
**sprite=the whole of multiple components + the action of each component**  
**Component = Component shape + individual actions**  
**Base = the shape of each part of sprite**
So when the components are updated, the shape and action of the parts will change. Updated the base, the shape of the elf changed, while the action remained unchanged.

Update all component base data of the sprite to use:
```
- (void)updateBaseListWithFilePath:(NSString *)fileName;
```
Use scenarios such as making an ordinary hero *man.JSON*, including walking, attacking and other actions, but also want to make a fatter hero, but do not want to do the action again, just:
1. adjust *man.json* each part, like make arm stronger,neck slim.
2. delete all the actions, create a file called *fatman.json*
3. init *man.json*，use **updateBaseListWithFilePath:@"fatman"** to update base。
4. then you get a new sprite with all the *man.json* 's actions。

Update wizard parts to use:
```
- (void)updateBasePart:(NSString *)name withFilePath:(NSString *)fileName;
```
使用场景如制作了一个普通英雄 *man.json*，它有个名为 *arm* 的部件作为武器，你想更换他的武器，只需：
1. 新建一个精灵，绘制一把新的武器，保存为 *sword.json*
2. 使用 **updateBasePart:@"arm" withFilePath:@"sword"** 来替换 *arm* 部件的武器。

Remove parts and use:
```
- (void)removePart:(NSString *)name;
```
比如把英雄的武器拿掉 **removePart:@"arm"**

Play sprite Animation using:
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

### Make sprite🧚‍
<img src="https://github.com/gwh111/bench_ios_packages/blob/master/test3.png" width="240">

It's very simple to call the method of making. First, start with your test project and modulate it as a controller. 

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
