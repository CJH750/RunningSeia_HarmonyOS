import { webview } from '@kit.ArkWeb';
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
  @State showGame: boolean = false;
  @State showLoading: boolean = false;
  private loadCount: number = 0;
  private loadTimer: number = 0;
  private dataPreferences: preferences.Preferences | null = null;
  private gameController: webview.WebviewController = new webview.WebviewController();
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
    this.showGame = true;
    this.showLoading = true;
    this.loadCount = 0;
    this.loadTimer = setTimeout(() => {
      if (this.showLoading) {
        this.showLoading = false;
      }
    }, 15000);
  }

  onBackPress(): boolean {
    if (this.showGame) {
      this.showGame = false;
      return true;
    }
    return false;
  }

  build() {
    if (this.showGame) {
      Stack() {
        Column() {
          Web({ src: 'https://game.xcnahida.cn/seia-runner/', controller: this.gameController })
          .javaScriptAccess(true)
          .domStorageAccess(true)
          .fileAccess(true)
          .mixedMode(MixedMode.All)
          .zoomAccess(false)
          .userAgent('Mozilla/5.0 (HarmonyOS 5.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.210 Mobile Safari/537.36')
          .width('100%')
          .height('100%')
          .onPageEnd((event) => {
            let j = 'localStorage.setItem("seia-runner-bgm-index","'+this.bgmIndex+'");';
            j += 'if(!document.getElementById("bt-info")){';
            j += 'var x=document.createElement("style");x.id="__gc";x.innerHTML=';
            j += '"html,body{margin:0;padding:0;width:100vw;height:100vh;overflow:hidden;background:#233129}';
            j += '.page-shell{width:100%;height:100%}';
            j += '.game-shell{display:flex!important;align-items:center!important;justify-content:center!important;width:100%;height:100%}';
            j += '#score,#best{position:fixed;top:4px;left:8px;z-index:200;font-size:13px;color:#fff;text-shadow:0 1px 2px rgba(0,0,0,0.5)}';
            j += '#best{left:160px}';
            j += '#rankBtn{position:fixed;top:4px;right:56px;z-index:200;font-size:12px;padding:2px 10px;background:rgba(0,0,0,0.4);color:#fff;border-radius:4px;text-decoration:none}';
            j += '#pauseBtn{position:fixed;top:4px;right:8px;z-index:200;width:36px;height:36px;min-width:36px;padding:0;background:rgba(0,0,0,0.4);border:none;border-radius:4px;display:flex;align-items:center;justify-content:center}';
            j += '#pauseBtn svg{fill:#fff!important}#pauseBtn.hidden{display:none!important}';
            j += '#game{max-width:100%!important;max-height:100%!important;z-index:10}';
            j += '#jumpButton,#duckButton{position:fixed!important;bottom:10px!important;width:120px!important;height:84px!important;border-radius:12px!important;font-size:18px!important;font-weight:bold!important;border:none!important;z-index:200!important;display:flex!important;align-items:center!important;justify-content:center!important;pointer-events:auto!important}';
            j += '#jumpButton{left:12px!important;background:rgba(31,111,74,0.65)!important;color:#fff!important}';
            j += '#duckButton{right:12px!important;background:rgba(90,74,122,0.65)!important;color:#fff!important}';
            j += '#bgmButton,#helpButton{display:none!important}';
            j += '.hud{position:fixed;top:0;left:0;right:0;z-index:100}.hud strong{display:none}.hud span:last-child{display:none}';
            j += '#overlay{padding-top:50px!important;z-index:300!important;max-width:95vw!important;margin:0 auto!important}#overlay h1{font-size:24px!important;margin:8px 0!important}#overlay p{font-size:13px!important;white-space:nowrap!important}';
            j += '.overlay-buttons{display:flex!important;flex-direction:row!important;gap:8px!important;justify-content:center!important;flex-wrap:wrap!important}';
            j += '.overlay-buttons button{width:auto!important;min-width:80px!important;padding:8px 16px!important;font-size:14px!important}';
            j += '#serverErrorModal{z-index:500!important}#submitModal{z-index:400!important}#cheatModal{z-index:400!important}#toast{z-index:500!important;top:40px!important}';
            j += '";document.head.appendChild(x);';
            j += 'var r=document.getElementById("rankBtn");if(r)r.addEventListener("click",function(e){';
            j += 'e.preventDefault();var f=document.getElementById("__lb");';
            j += 'if(!f){f=document.createElement("iframe");f.id="__lb";f.src="leaderboard.html";f.style.cssText="position:fixed;top:0;left:0;width:100%;height:100%;border:none;z-index:999";';
            j += 'f.addEventListener("load",function(){';
            j += 'var pt=function(){';
            j += 'var d=f.contentDocument;if(!d){setTimeout(pt,200);return}';
            j += 'var m=d.querySelector(".nav-menu");if(!m){setTimeout(pt,200);return}';
            j += 'm.addEventListener("click",function(ev){';
            j += 'var a=ev.target.closest("a.nav-item");if(!a)return;';
            j += 'if(a.classList.contains("nav-back")){ev.preventDefault();f.style.display="none";return}';
            j += 'ev.preventDefault();';
            j += 'var u=new URL(a.href,d.location.origin);var t=u.searchParams.get("type")||"day";var sz=u.searchParams.get("pageSize")||"10";';
            j += 'if(typeof d.defaultView.loadData==="function")d.defaultView.loadData(t,1,sz,"","");';
            j += 'if(typeof d.defaultView.updateURL==="function")d.defaultView.updateURL(t,1,"",sz,"");';
            j += 'if(typeof d.defaultView.updateNavActive==="function")setTimeout(d.defaultView.updateNavActive,50)';
            j += '})};pt()';
            j += '})}else{f.style.display="block"}document.body.appendChild(f)';
            j += '});';
            j += 'setInterval(function(){var o=document.querySelector(".overlay-buttons");if(o&&!document.getElementById("homeButton")){var hb=document.createElement("button");hb.id="homeButton";hb.type="button";hb.textContent="\\u8fd4\\u56de\\u9996\\u9875";hb.addEventListener("click",function(){window.location.href="runningseia://home"});o.appendChild(hb)}},200);';
            j += 'var t="\\u5723\\u5a05\\uff1a\\u4f60\\u8dd1\\u4e0d\\u8fc7\\u6211\\u4f60\\u4fe1\\u5417\\uff01\\u8df3\\u8dc3\\u8df3\\u8dc3\\uff08\\u957f\\u6309\\u8df3\\u66f4\\u9ad8\\uff09\\uff0c\\u4e0b\\u8e72\\u4e0b\\u8e72\\uff0c\\u53f3\\u4e0a\\u89d2\\u6682\\u505c/\\u7ee7\\u7eed\\u3002";';
            j += 'var el=document.getElementById("overlayText");if(el){el.textContent=t;new MutationObserver(function(ms){ms.forEach(function(m){if(m.target===el)el.textContent=t})}).observe(el,{characterData:true,childList:true,subtree:true})}';
            j += '(new Image).src="runningseia://ready"}';
            this.gameController.runJavaScript(j);
          })
          .onLoadIntercept((event) => {
            if (event) {
              const url: string = event.data.getRequestUrl();
              if (url.indexOf('runningseia://home') === 0) {
                this.showGame = false;
                return true;
              }
              if (url.indexOf('runningseia://ready') === 0) {
                this.showLoading = false;
                return true;
              }
            }
            return false;
          })
          .onInterceptRequest((event) => {
            if (event && event.request) {
              let url: string = event.request.getRequestUrl();
              if (url.indexOf('runningseia://ready') >= 0) {
                setTimeout(() => { this.showLoading = false; }, 100);
              }
            }
            return null;
          })
      }
      .width('100%')
      .height('100%')

      if (this.showLoading) {
        Column() {
          Text('加载中...')
            .fontSize(20)
            .fontColor('#8c9890')
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#f4f6f1')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  } else {
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
}
