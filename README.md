# GenshinCelShaderURP

# What's This?
这是一个基于Unity引擎URP管线的卡通渲染项目，经过一段时间修改后基本做成这样的集合式使用了，技术难度整体不大，主要是整合了各位大佬们的工程，取其精华并整合封装到一套shader当中，本着分享的开源精神还是决定将本项目分享给大家，也希望通过开源的方式提高代码质量，我们的目的是创建一套能还原原神角色卡通渲染方式的渲染库，在保证易用性的同时保持扩展性 ，同时兼顾PC端、移动端、主机端的兼容性、性能和效果。

# Installation & Usage
只需将/Shaders/GenshinCelShaderURP/路径下解压对应版本的文件夹到你的Assets即可在材质球中看到添加的shader。
在开始之前，你至少需要准备如下的贴图，如果不知道如何获取他们，可以参考B站 @小二今天吃啥啊 的这个教程，[链接](https://www.bilibili.com/video/BV1t34y1H7jt/)

![图片](https://github.com/Gaolingx/GenshinCelShaderURP/Pictures/v2-ddd69ef9b770627bb601ebe380ce19ec_r.jpg)
> (1)RGBA通道的身体Base Map (2)RGBA通道的身体Light Map(ILM Map) (3)身体Shadow Ramp (4)面部Base Map (5)面部阴影SDF阈值图 (6)头发Base Map (7)RGBA通道的头发LightMap(ILM Map) (8)头发ShadowRamp (9)面部阴影Mask (10)金属光泽Map

## 贴图示例：
> 一般
![图片](https://github.com/Gaolingx/GenshinCelShaderURP/Pictures/Example01)
![图片](https://github.com/Gaolingx/GenshinCelShaderURP/Pictures/Example02)
![图片](https://github.com/Gaolingx/GenshinCelShaderURP/Pictures/Example03)
> 脸部
![图片](https://github.com/Gaolingx/GenshinCelShaderURP/Pictures/Example04)
![图片](https://github.com/Gaolingx/GenshinCelShaderURP/Pictures/Example05)

# For Sample Models
示例用的模型和贴图附在/Model路径下，模型来源：模之屋，[链接](https://www.aplaybox.com/details/model/xuBcQCqsVWfC)可以用于结合我的shader进行测试，模型最终解释权归mihoyo所有，切勿商用。

# For Generate Ramp Texture Tool
该配套工具是用于在Unity Editor中创建适用于该shader的ramp texture，即可根据自己需求定制ramp color，具体食用方法可参考[此处](https://www.bilibili.com/video/BV17h411b73u?spm_id_from=333.999.0.0)

# Thanks
鸣谢以下大佬们提交的代码（排名不分先后）：
1、[Zzzzohar](https://github.com/Zzzzohar)（Generate Ramp Texture Tool）
[https://github.com/Zzzzohar/Ramp-Tools](https://github.com/Zzzzohar/Ramp-Tools)
2、[ashyukiha](https://github.com/ashyukiha)（shader菲涅尔边缘光、sdf面部阴影、Emission、Bloom、AlphaClipping)
[https://github.com/ashyukiha/GenshinCharacterShaderZhihuVer](https://github.com/ashyukiha/GenshinCharacterShaderZhihuVer)
3、[ColinLeung-NiloCat](https://github.com/ColinLeung-NiloCat)（shader卡通描边outline）
[https://github.com/ColinLeung-NiloCat/UnityURPToonLitShaderExample](https://github.com/ColinLeung-NiloCat/UnityURPToonLitShaderExample)
4、[YuiLu](https://github.com/YuiLu)（shader ramp漫反射及tex采样、头发裁边视角高光、金属高光、屏幕空间深度等宽边缘光）
[https://github.com/YuiLu/GenshinCharacterShading](https://github.com/YuiLu/GenshinCharacterShading)

# Future
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
11、优化二分阴影平滑度，减少锯齿。
12、延迟渲染适配。
13、SRP批次优化。

# Rules
为了规范项目的使用，你可以将其用于...
卡通渲染相关知识学习、了解HLSL基本语法结构、个人独立游戏开发（相关代码需要开源）、根据自己需求定制修改源码、MMD等影视制作（借物表必须注明Thanks名单中的名字（可以不写我的名字））
请不要用于...
二次贩售、二次发布等具有商业目的以及违反GPL开源许可证的行为

# End
最后，希望大家玩得开心，这个项目任将持续进行更新，如果对我们的项目感兴趣记得给一个star，这便是对我们最好的鼓励与支持，由于本人仅仅是高三的学牲，敲代码水平有限qwq，如有不足之处希望谅解，如果你针对shader部分有任何好的想法，意见或建议欢迎在Issues中讨论或者提交你的PR哟。也可以通过邮箱联系我（gaolingxiang123@163.com），If you feel that my works are worthwhile, I would greatly appreciate it if you could sponsor me.

