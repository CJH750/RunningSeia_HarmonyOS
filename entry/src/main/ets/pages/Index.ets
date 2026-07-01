import { webview } from '@kit.ArkWeb';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  controller: webview.WebviewController = new webview.WebviewController();
  private bgmIndex: number = 0;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params && params['bgmIndex'] !== undefined) {
      this.bgmIndex = params['bgmIndex'] as number;
    }
  }

  build() {
    Column() {
      Web({ src: 'https://game.xcnahida.cn/seia-runner/', controller: this.controller })
        .javaScriptAccess(true)
        .domStorageAccess(true)
        .fileAccess(true)
        .mixedMode(MixedMode.All)
        .zoomAccess(false)
        .userAgent('Mozilla/5.0 (HarmonyOS 5.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.6099.210 Mobile Safari/537.36')
        .width('100%')
        .height('100%')
        .onPageEnd(() => {
          this.controller.runJavaScript(`
            localStorage.setItem("seia-runner-bgm-index", "${this.bgmIndex}");
          `);
        })
        .onLoadIntercept((event) => {
          if (event) {
            const url: string = event.data.getRequestUrl();
            if (url.indexOf('runningseia://home') === 0) {
              router.back();
              return true;
            }
          }
          return false;
        })
    }
    .width('100%')
    .height('100%')
  }
}
