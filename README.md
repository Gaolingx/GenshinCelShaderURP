# GenshinCelShaderURP

## What's This?
这是一个基于Unity引擎URP管线的卡通渲染项目，经过一段时间修改后基本做成这样的集合式使用了，技术难度整体不大，主要是整合了各位大佬们的工程，取其精华并整合封装到一套shader当中，本着分享的开源精神还是决定将本项目分享给大家，也希望通过开源的方式提高代码质量，我们的目的是创建一套能还原原神角色卡通渲染方式的渲染库，在保证易用性的同时保持扩展性 ，同时兼顾PC端、移动端、主机端的兼容性、性能和效果。

## Installation & Usage
只需将/Shaders/GenshinCelShaderURP/路径下解压对应版本的文件夹到你的Assets即可在材质球中看到添加的shader。
在开始之前，你至少需要准备如下的贴图，如果不知道如何获取他们，可以参考B站 @小二今天吃啥啊 的这个教程，[链接](https://www.bilibili.com/video/BV1t34y1H7jt/)

![图片](https://github.com/Gaolingx/GenshinCelShaderURP/raw/main/Pictures/v2-ddd69ef9b770627bb601ebe380ce19ec_r.jpg)
> (1)RGBA通道的身体Base Map (2)RGBA通道的身体Light Map(ILM Map) (3)身体Shadow Ramp (4)面部Base Map (5)面部阴影SDF阈值图 (6)头发Base Map (7)RGBA通道的头发LightMap(ILM Map) (8)头发ShadowRamp (9)面部阴影Mask (10)金属光泽Map

### 贴图示例：
> 一般  
![图片](https://github.com/Gaolingx/GenshinCelShaderURP/raw/main/Pictures/Example01.PNG)  
![图片](https://github.com/Gaolingx/GenshinCelShaderURP/raw/main/Pictures/Example02.PNG)  
![图片](https://github.com/Gaolingx/GenshinCelShaderURP/raw/main/Pictures/Example03.PNG)  
  
> 脸部  
![图片](https://github.com/Gaolingx/GenshinCelShaderURP/raw/main/Pictures/Example04.PNG)  
![图片](https://github.com/Gaolingx/GenshinCelShaderURP/raw/main/Pictures/Example05.PNG)  

## Support
关于shader兼容性（通用性），目前仅限于工作在URP管线中，可以使用的游戏如下：  
  
《原神》（推荐）、《崩坏3》（推荐）、《崩坏：星穹铁道》、《绝区零》（待测）、《罪恶装备》、《地下城与勇士：决斗》、《战双帕米什》等，
  
  不同游戏开发商的贴图处理方式稍有不同，可以根据自己需要修改与定制，理论上只要有ilm（表现物体阴影、高光及反射面）和脸部sdf阴影阈值图的都可以使用该shader，这里值得说明的是，《崩坏3》旧角色ilm贴图做法和新角色稍有不同，没有alpha通道控制ramp采样区域，效果会稍差点，这可能需要各位手动调色了。

## For Sample Models
示例用的模型和贴图附在/Model路径下，模型来源：模之屋，[链接](https://www.aplaybox.com/details/model/xuBcQCqsVWfC)可以用于结合我的shader进行测试，模型最终解释权归mihoyo所有，切勿商用。

## For Generate Ramp Texture Tool
该配套工具是用于在Unity Editor中创建适用于该shader的ramp texture，即可根据自己需求定制ramp color，具体食用方法可参考[此处](https://www.bilibili.com/video/BV17h411b73u?spm_id_from=333.999.0.0)

## Thanks
鸣谢以下大佬们提交的代码（排名不分先后）：
  
1、[Zzzzohar](https://github.com/Zzzzohar)（Generate Ramp Texture Tool）  
[https://github.com/Zzzzohar/Ramp-Tools](https://github.com/Zzzzohar/Ramp-Tools)  
  
2、[ashyukiha](https://github.com/ashyukiha)（shader菲涅尔边缘光、sdf面部阴影、Emission、Bloom、AlphaClipping)  
[https://github.com/ashyukiha/GenshinCharacterShaderZhihuVer](https://github.com/ashyukiha/GenshinCharacterShaderZhihuVer)  
  
3、[ColinLeung-NiloCat](https://github.com/ColinLeung-NiloCat)（shader卡通描边outline）  
[https://github.com/ColinLeung-NiloCat/UnityURPToonLitShaderExample](https://github.com/ColinLeung-NiloCat/UnityURPToonLitShaderExample)  
  
4、[YuiLu](https://github.com/YuiLu)（shader ramp漫反射及tex采样、头发裁边视角高光、金属高光、屏幕空间深度等宽边缘光）  
[https://github.com/YuiLu/GenshinCharacterShading](https://github.com/YuiLu/GenshinCharacterShading)
  

## Future
我们未来预计将在现有版本的基础上加入以下新特性：  
1、使用LightMap的Alpha通道（也有可能是顶点色）制作了彩色的描边，仅限皮肤区域。  
2、新增基于崩坏三lightmap的双层阴影方案，并保留原有的漫反射计算方案。  
3、基于后处理的头发刘海投影。  
4、面部和身体的法线贴图。  
5、AutoColor自动着色（简单理解就是通过不断采样环境光和间接光源的颜色叠加到basecolor上面，这样角色的亮部和暗部做到与环境统一的效果，并设置阈值防止过曝或欠曝，而且支持多光源并可以随环境实时变化（依靠C#脚本实现））。  
6、改进基于PBR并适用于卡通渲染的光照模型。（重点）  
7、彩色描边。  
8、改进边缘光，新增屏幕空间深度等宽边缘光的特性（用于处理屏幕空间的边缘光）。  
9、使用顶点色及输入的纹理调节阴影显示。  
10、随视角变化的头发高光。  
11、优化二分阴影平滑度，减少锯齿。（halfLambert卡通光照模型优化相关）。  
12、延迟渲染适配。  
13、SRP批次优化。  
14、眼球材质优化（基于pbr，模拟ior折射，环境反射、焦散等效果，打算新建一个项目）  
15、增加sss材质支持  
  

## Rules
为了规范项目的使用，你可以将其用于...  
卡通渲染相关知识学习、了解HLSL基本语法结构、个人独立游戏开发（相关代码需要开源）、根据自己需求定制修改源码、MMD等影视制作（如要使用此shader时请在片尾或简介中署名Thanks名单中的名字（可以不写我的名字））  
  
请不要用于...  
1 禁止用此模型参与任何商业性质活动和内容制作  
2 禁止用此模型参与18禁作品，极端宗教宣传，血腥恐怖猎奇作品，人身攻击视频、暴力、色情、反社会、政治的内容制作  
3 禁止对此模型进行侮辱性或猎奇的改造  
5 允许对shader的全部代码进行改造，但须始终保持署名（Thanks名单当中，使用哪些作者们代码请把他们署名）  
2.禁止个人之间以任何形式的二次配布（即二次传播项目文件）  
3.未获得原作者许可，禁止用于商业用途（交易售卖/商业广告类宣传视频等）  
5.仅允许使用本场景制作MMD视频，禁止用于其他领域（VRCHAT/游戏MOD等）  
6、其他违反GPL开源许可证的行为  
  
在遵守第五则的前提下，允许对此模型二次配布，同须始终保持署名为Github/Gaolingx
=========================================  
他人使用本场景所造成的一切不良后果，不由场景提取者与miHoYo承担，请向使用者追究全部责任  
=========================================  
  
※请遵守动作&模型的规约。
  

## End
最后，希望大家玩得开心，这个项目任将持续进行更新，如果对我们的项目感兴趣记得给一个star，这便是对我们最好的鼓励与支持，由于本人仅仅是高三的学牲，敲代码水平有限qwq，如有不足之处希望谅解，如果你针对shader部分有任何好的想法，意见或建议欢迎在Issues中讨论或者提交你的PR哟。也可以通过邮箱联系我（gaolingxiang123@163.com），If you feel that my works are worthwhile, I would greatly appreciate it if you could sponsor me.

