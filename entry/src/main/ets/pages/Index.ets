import { webview } from '@kit.ArkWeb';
import { router } from '@kit.ArkUI';
import { util } from '@kit.ArkTS';
import { resourceManager } from '@kit.LocalizationKit';

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
        .onInterceptRequest((event) => {
          if (!event) {
            return null;
          }
          const url: string = event.request.getRequestUrl();
          const lastSlash: number = url.lastIndexOf('/');
          const path: string = lastSlash >= 0 ? url.substring(lastSlash + 1).split('?')[0] : '';
          const isMainPage: boolean = url.indexOf('seia-runner') >= 0 &&
            (path === 'index.html' || path === '' || url.endsWith('seia-runner/') || url.endsWith('seia-runner'));

          if (isMainPage) {
            return this.serveRaw('index.html', 'text/html');
          }
          if (path === 'index.js' && url.indexOf('seia-runner') >= 0) {
            return this.serveRaw('index.js', 'application/javascript');
          }
          if (path === 'gt4.js') {
            return this.serveRaw('gt4.js', 'application/javascript');
          }
          if (path === 'index.css' || path === 'leaderboard.css') {
            return this.serveRaw(path, 'text/css');
          }
          if (path === 'leaderboard.html') {
            return this.serveRaw('leaderboard.html', 'text/html');
          }
          if (path === 'leaderboard.js') {
            return this.serveRaw('leaderboard.js', 'application/javascript');
          }
          if (path === 'favicon.ico') {
            return this.serveRaw('favicon.ico', 'image/x-icon');
          }
          if (path === 'Blueaka.css' || path === 'Blueaka_Bold.css') {
            return this.serveEmpty('text/css');
          }
          if (url.indexOf('/seia-runner/assets/') >= 0) {
            const assetIdx: number = url.indexOf('/assets/');
            if (assetIdx >= 0) {
              const assetPath: string = decodeURIComponent(url.substring(assetIdx + 1));
              return this.serveRaw(assetPath, '');
            }
          }
          return null;
        })
    }
    .width('100%')
    .height('100%')
  }

  serveEmpty(mime: string): WebResourceResponse {
    const response: WebResourceResponse = new WebResourceResponse();
    response.setResponseData('');
    response.setResponseMimeType(mime);
    response.setResponseCode(200);
    response.setReasonMessage('OK');
    return response;
  }

  serveRaw(path: string, mime: string): WebResourceResponse {
    const response: WebResourceResponse = new WebResourceResponse();
    response.setResponseIsReady(false);
    const resMgr: resourceManager.ResourceManager =
      getContext(this).resourceManager as resourceManager.ResourceManager;
    const isBinary: boolean = /\.(png|jpg|jpeg|gif|ico|mp3|wav|ogg|webp)$/i.test(path);
    try {
      resMgr.getRawFileContent(path, (err: Error | null, data: Uint8Array) => {
        if (err) {
          response.setResponseData('');
          response.setResponseCode(404);
          response.setResponseIsReady(true);
        } else {
          if (isBinary) {
            response.setResponseData(data.buffer as ArrayBuffer);
            response.setResponseEncoding('');
          } else {
            const text: string = new util.TextDecoder('utf-8').decodeWithStream(data);
            response.setResponseData(text);
            response.setResponseEncoding('utf-8');
          }
          if (mime.length > 0) {
            response.setResponseMimeType(mime);
          }
          response.setResponseCode(200);
          response.setReasonMessage('OK');
          response.setResponseIsReady(true);
        }
      });
    } catch (e) {
      response.setResponseData('');
      response.setResponseCode(500);
      response.setResponseIsReady(true);
    }
    return response;
  }
}
