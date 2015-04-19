---
layout: post
title: 破解Revealapp的试用时间限制
---

# 破解Revealapp的试用时间限制 #

[Revealapp](http://revealapp.com)作为分析iOS app UI结构的利器，还是非常称手的，89刀的价格也是物有所值。本文分析其试用版时间限制，只是用于学习，如果一直用，还是买个licence支持一下吧。

试用版有30天的时间限制，既然是30天时间限制，肯定每次启动是要读当前时间的啰。所以最简单的hack方法就是修改系统时间。如果这种方法可以接受，就不用往下看了。

如果你的工作严重依赖于Calendar，那么修改系统时间的方法就是不可以接受的。下面的追踪过程包含了对双精度浮点数在内存中的表示、ObjC对象模型等问题的讨论，如果不感兴趣可直接跳到文末查看最终的解决方案。

## 开始的尝试 ##
用dtruss看了下启动时调用的syscall，是没有网络通讯的，说明app的安装时间不可能是从网络读下来的，那么这个时间肯定是写在本地的文件系统。

用opensnoop看了下启动时Reveal读过的所有文件，没有值得注意的地方。最后的发现证实这个思路忽略了一个问题，一个app读的文件并不一定是它自己打开的，可以是进程间通信。

这些简单的尝试失败后，就只能老老实实的分析代码了。

## 从关键字开始 ##
试用版的Reveal有提醒试用剩余时间的信息在窗口的右上角”Free trial ends in xx days”（我觉得这不是一个好的设计，这句话似乎时刻挑衅着使用者：“来呀，你来hack我呀”）。“trial”是我感兴趣的关键字，除了在数据段肯定能找到这个关键字以外，说不定在ObjC的运行时类型系统中还能有意外的收获。果真，Reveal没有对类型信息进行模糊处理，在class-dump生成的头文件中发现了：<br/>
-[IBARegistrationPreferencesViewController messageForTrialDaysRemaining:(long long)arg1]    <br/>
从函数名来看它应该就是生成试用剩余时间字符串的。

上GDB，单步跟踪，

0x000000010008bd34         push       rbp                <br/>
0x000000010008bd3f         move       rbx, rdx           ; rdx 就是还剩下的试用天数，也就是函数的参数arg1

以此为突破口，发现下面的小段代码。

0x00000001000872cd         call       0x100086ec2                                                     <br/>
0x00000001000872d2         mov        rcx, rax           ; rax中是上面函数返回的已过去的天数               <br/>
0x00000001000872d7         mov        eax, 0x1e          ; 0x1e=30 30天的限制                          <br/>
0x00000001000872dc         sub        rax, rcx           ; 30减去已经过去的天数的，减出来就是还剩下的天数

再往下走，需要分析的数据不再像是“天数”这样的整数，而是像软件安装日期NSDate这样的对象，特征不明显。所以就有必要清楚NSDate这个对象中日期的表示方法。

## 内存中的NSDate对象 ##
NSDate对象应该有两个域，第一个“isA”是所有ObjC对象都有的类型指针，指向NSDate类型对象。第二个是个双精度浮点数，表示从2001年1月1日到现在的时间间隔，单位是秒。

<table class="tg">
  <tr>
    <td class="tg-031e">pointer: isA </td>
  </tr>
  <tr>
    <td class="tg-031e">double: _timeIntervalSinceReferenceDate</td>
  </tr>
</table>

其实isA指针就是NSDate对象的特征，所有的NSDate对象都是以相同的8个字节开始。第二个域是一个浮点数，分两步把它转换为一个日期。

第一步，十六进制浮点数转换为十进制

双精度浮点数由8个字节构成，1个bit表示符号，11个bit表示指数，剩下的52位用来表示底数。<br/>
使用python可以方便的把8字节的十六进制浮点数转换为十进制数：<br/>
struct.unpack('<d','c3b72c7a9ebfb841'.decode('hex'))[0]

在gdb中，可以直接使用命令 <br/>
p \*(double\*)(NSDate指针地址+8)

第二步，秒数转换为日期

NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:415285808.20822901]; <br/>
NSLog(@"\n%@", date);

使用上面的方法，可以在跟踪汇编代码的时候检查内存中的NSDate对象，以及它所表示的日期。（这需要点耐心）

最终，安装Reveal的时间第一次出现在内存中的位置被找到，这个位置所在的函数显然负责把存在文件某处的一个magic number转换为软件安装日期。

但是意料之外的是，这个想像中的magic number并不magic，它仅仅是存在user default的plist文件中的一项，而且就是安装日期的双精度浮点数的十六进制表示。

## 结论 ##
所以，要想永久试用Reveal，只需要打开

~/Library/Preferences/com.ittybittyapps.Reveal.plist

把IBAApplicationPersistenceData这一项删除就是了。

## 后记 ##
有同学留言说上面的方法不起作用(问题的原因请参考另一篇blog[谁动了我的plist](/2015/04/19/plist.html))，于是叽歪刘写了个[补丁](/images/reveal_crack.app.zip)。

补丁是用10.9的SDK编译的，在Reveal1.0.3（2287）上测试通过。

下载解压后，用右键的“打开”菜单运行程序。亲，叽歪刘只能帮你到这里了。


