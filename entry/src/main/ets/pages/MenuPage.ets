import { router } from '@kit.ArkUI';
import { preferences } from '@kit.ArkData';

interface BgmItem {
  name: string;
  file: string;
}

const BGM_LIST: BgmItem[] = [
  { name: "Peaceful_Day", file: "assets/music/bgm_Peaceful_Day.mp3" },
  { name: "张雪峰老师我还记得你😭", file: "assets/music/bgm.mp3" },
  { name: "熊大快跑BGM 1", file: "assets/music/bgm_xdkp.mp3" },
  { name: "你说你有点难追", file: "assets/music/%E9%87%91%E7%94%9F%20-%20%E5%91%8A%E7%99%BD%E6%B0%94%E7%90%83%20%28%E5%8F%98%E9%80%9F%29.mp3" },
  { name: "熊大快跑BGM 2", file: "assets/music/%E9%BA%A6%E4%B9%90%E8%BF%AAShop%20-%20%E7%86%8A%E5%A4%A7%E5%BF%AB%E8%B7%91BGM.mp3" },
  { name: "静音", file: "" }
];

const PREF_STORE_NAME: string = 'seia_runner_prefs';
const PREF_KEY_BGM_INDEX: string = 'bgm_index';

@CustomDialog
struct HelpDialog {
  controller: CustomDialogController;

  build() {
    Column() {
      Scroll() {
        Column() {
          Text('圣娅快跑是一款《蔚蓝档案》横版跑酷同人小游戏。')
            .fontSize(14)
            .fontColor('#3a403a')
            .margin({ bottom: 6 });

          Text('😎穷玩车，富玩表，顶富得玩圣娅快跑。')
            .fontSize(14)
            .fontColor('#3a403a')
            .margin({ bottom: 12 });

          Text('操作方式')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1b2f25')
            .margin({ bottom: 4 });

          Text('跳跃跳跃（长按跳更高），下蹲下蹲，右上角暂停/继续游戏')
            .fontSize(14)
            .fontColor('#3a403a')
            .margin({ bottom: 2 });

          Text('障碍物')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1b2f25')
            .margin({ bottom: 4 });

          Text('地面上的是 巧乐兹，需要跳跃躲避；')
            .fontSize(14)
            .fontColor('#3a403a')
            .margin({ bottom: 2 });

          Text('空中飞行的是 雪碧瓶，需要下蹲或精准跳跃躲避。')
            .fontSize(14)
            .fontColor('#3a403a')
            .margin({ bottom: 12 });

          Text('提示')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1b2f25')
            .margin({ bottom: 4 });

          Text('1. 在跳跃过程中按下蹲按钮，可以提前落地。')
            .fontSize(14)
            .fontColor('#3a403a')
            .margin({ bottom: 2 });

          Text('2. 游戏速度会越来越快，坚持得越久分数越高！')
            .fontSize(14)
            .fontColor('#3a403a')
            .margin({ bottom: 2 });

          Text('3. 游戏结束后，别忘了点击上传成绩按钮上传你的成绩。')
            .fontSize(14)
            .fontColor('#3a403a')
            .margin({ bottom: 12 });

          Text('关于网页版')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1b2f25')
            .margin({ bottom: 4 });

          Text('本项目已经开源在 GitHub 上，\nGitHub地址：https://github.com/VanillaNahida/seia-runner/')
            .fontSize(14)
            .fontColor('#3a403a')
            .margin({ bottom: 4 });

          Text('感谢Ottomate的张雪峰跑酷提供灵感。')
            .fontSize(14)
            .fontColor('#3a403a')
            .margin({ bottom: 4 });

          Text('加入我的QQ群：https://xcnahida.cn/contact')
            .fontSize(14)
            .fontColor('#3a403a')
            .margin({ bottom: 8 });

          Text('关于鸿蒙版')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1b2f25')
            .margin({ bottom: 4 });

          Text('本项目已经开源在 GitHub 上，\nGitHub地址：https://github.com/CJH750/RunningSeia_HarmonyOS/')
            .fontSize(14)
            .fontColor('#3a403a')
            .margin({ bottom: 4 });

          Text('感谢B站@香草味的纳西妲喵 开源✋😭🤚')
            .fontSize(14)
            .fontColor('#3a403a')
            .margin({ bottom: 4 });

          Text('有问题发邮件：1156855761@qq.com')
            .fontSize(14)
            .fontColor('#3a403a')
            .margin({ bottom: 8 });
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .layoutWeight(1)

      Button('关闭')
        .fontSize(16)
        .fontColor('#ffffff')
        .backgroundColor('#8c9890')
        .borderRadius(8)
        .width('100%')
        .height(40)
        .margin({ top: 8 })
        .onClick(() => {
          this.controller.close();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#fffdf6')
    .padding({ top: 16, bottom: 16 })
  }
}

@Entry
@Component
struct MenuPage {
  @State bgmIndex: number = 0;
  private dataPreferences: preferences.Preferences | null = null;
  private helpDialogController: CustomDialogController = new CustomDialogController({
    builder: HelpDialog({}),
    autoCancel: true,
    alignment: DialogAlignment.Center,
    customStyle: true
  });

  aboutToAppear(): void {
    const context = getContext(this);
    preferences.getPreferences(context, PREF_STORE_NAME)
      .then((pref: preferences.Preferences) => {
        this.dataPreferences = pref;
        return pref.get(PREF_KEY_BGM_INDEX, 0);
      })
      .then((value: preferences.ValueType) => {
        this.bgmIndex = value as number;
      });
  }

  switchBgm(): void {
    this.bgmIndex = (this.bgmIndex + 1) % BGM_LIST.length;
    if (this.dataPreferences) {
      this.dataPreferences.put(PREF_KEY_BGM_INDEX, this.bgmIndex);
      this.dataPreferences.flush();
    }
  }

  onStartGame(): void {
    const params: Record<string, Object> = { 'bgmIndex': this.bgmIndex };
    router.pushUrl({ url: 'pages/Index', params: params });
  }

  build() {
    Column() {
      Column() {
        Text('圣娅快跑')
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1b2f25')
          .margin({ bottom: 16 });

        Text('圣娅：你跑不过我你信吗！跳跃跳跃（长按跳更高），下蹲下蹲，右上角暂停/继续。')
          .fontSize(16)
          .fontColor('#4d554d')
          .textAlign(TextAlign.Center)
          .lineHeight(24)
          .maxLines(4)
          .margin({ bottom: 36 });

        Button('开始游戏')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#ffffff')
          .backgroundColor('#1f6f4a')
          .borderRadius(8)
          .width('50%')
          .height(56)
          .margin({ bottom: 36 })
          .onClick(() => {
            this.onStartGame();
          });

        Row() {
          Button('BGM: ' + BGM_LIST[this.bgmIndex].name)
            .fontSize(14)
            .fontColor('#ffffff')
            .backgroundColor('#5a4a7a')
            .borderRadius(8)
            .layoutWeight(1)
            .height(44)
            .margin({ right: 8 })
            .onClick(() => {
              this.switchBgm();
            });

          Button('玩法说明')
            .fontSize(14)
            .fontColor('#ffffff')
            .backgroundColor('#4a7a6a')
            .borderRadius(8)
            .layoutWeight(1)
            .height(44)
            .margin({ left: 8 })
            .onClick(() => {
              this.helpDialogController.open();
            });
        }
        .width('60%')
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#f4f6f1')
    .padding({ left: 24, right: 24 })
  }
}
