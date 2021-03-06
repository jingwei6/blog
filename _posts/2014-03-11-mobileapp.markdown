---
layout: post
title: 即时通讯类移动APP开发要点
---

# 即时通讯类移动APP开发要点 #



即时通讯（IM）软件作为满足人们沟通需求的工具，十几年来一直长盛不衰，并随着移动时代的到来迎来了新的增长。如在国内广泛使用的微信，在北美广泛使用的Whatsapp、Kik，在亚洲广泛使用的Line、KakaoTalk。另外还有其他一些以独特视角切入移动IM市场的APP，主打阅后即焚、私密消息等。

叽歪刘试着从技术的角度来总结这一类应用的开发要点，或者说是相比桌面版的IM软件，移动IM应用开发需要注意的地方，欢迎指正和补充。


   * 网络

    移动APP经常随着移动设备在不同的网络之间切换，所以处理好网络切换、断网、重连就至关重要。

    解决这个问题的办法，就是要求移动APP能以尽量少的通讯量、尽快的速度重新注册服务器。

    比如不再从服务器获取配置信息、联系人信息和联系人状态等。

    但是如果这段时间服务器端有变化发生，就需要服务器有推送变化信息的能力。

    同时，服务器对客户端重连间隔要保持宽容态度，不要因为客户端在给定的较短时间内没有重连上就移除这个会话。要知道，在移动环境下，客户端断掉连接只是不得已，一有机会，它就会努力重连上来的。

    另外，由于网络的不稳定性，消息的发送方和接受方一定要有确认机制，不管这种确认机制是端对端的的还是通过服务器中转，以避免客户端突然掉线，而服务器还未及时知晓的情况。


   * 电池

    移动APP必须尽量减少电池的消耗。

    以iOS为例，它以三个规则来强制APP最小化电池消耗：

    一是APP在后台是不能主动运行的，特定功能的APP可以设置timer唤醒，但最频繁也只能每10分钟运行若干秒。

    二是APP在后台被唤醒的次数有严格限制，不能在300秒内被唤醒超过15次，否则被系统终止。

    三是APP即使申请后台任务，最多也只有60秒的运行时间。

    满足这些要求的最好办法，就是不要试图让移动IM应用在后台运行。而把网络监听这样的任务，在APP进入后台的时候转交给iOS系统来完成。

    而服务器则要有灵活的过滤机制，不管是主动还是被动的，过滤掉绝大多数试图发给客户端的网络通讯，以保持客户端睡眠的状态。而仅仅把必要的信息，如即时消息，推送给客户端。


   * 内存

    移动APP要尽量减少内存消耗。

    以iOS为例，系统会保持尽可能多的APP在内存中，但是内存不足时它就会终止已被挂起的APP来回收内存。这种情况下，首先被回收的就是占内存多的后台APP。

    解决这个问题的一个办法，就是在内存消耗较多的模块，通常是模型层的组件，提供持久化机制。当APP切换到后台的时候保存大多数暂时不会用到的数据到文件系统，等回到前台的时候再重建这些数据结构。

    比如所有联系人的详细信息就适合这么做。


   * 系统资源

    移动APP要尽量减少对系统资源的占有。

    应该以最少使用时间为原则来使用系统资源，以iOS为例，在APP切换到后台之前就要放弃对地址簿的访问。


   * 后台运行

    以上几点都跟APP在后台运行有关，其实这也是移动IM应用的一大特点。所谓养兵千日、用兵一时，移动IM应用绝大多数时间都躺在后台，所以处理好后台运行就处理好了移动IM应用的大部分。
