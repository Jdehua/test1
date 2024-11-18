import { window } from '@kit.ArkUI'

// 1.1 子页的入口函数，必须以 @Builder 修饰
@Builder
function SearchViewBuilder() {
  // 1.2 子页结构，必须以 NavDestination 组件包裹
  NavDestination() {
    SearchView()
  }
  .hideTitleBar(true) // 隐藏默认标题栏
}

// 路由参数格式
interface PageParams {
  id: string
}


@Component
export struct SearchView {
  @StorageProp('safeTop') safeTop: number = 0
  @State keyword: string = ''
  @Consume pageStack: NavPathStack

  aboutToAppear(): void {
    window.getLastWindow(getContext())
      .then((win) => {
        win.setWindowSystemBarProperties({ statusBarContentColor: '#FFFFFF' })
      })
  }

  aboutToDisappear(): void {
    window.getLastWindow(getContext())
      .then((win) => {
        win.setWindowSystemBarProperties({ statusBarContentColor: '#000000' })
      })
  }

  build() {
    Column() {
      // search
      Row() {
        // 返回按钮
        Image($r('[basic].media.ic_public_left'))
          .width(24)
          .aspectRatio(1)
          .fillColor($r('[basic].color.white'))
          .margin(13)
          .onClick(() => {
            // 返回上一页
            this.pageStack.pop()
          })

        // 搜索框
        Search({ placeholder: '商品关键字...', value: this.keyword })
          .searchIcon({ src: $r('[basic].media.ic_public_search'), color: $r('[basic].color.gray') })
          .placeholderColor($r('[basic].color.gray'))
          .placeholderFont({ size: 14 })
          .searchButton('搜索', { fontSize: 14, fontColor: $r('[basic].color.red') })
          .backgroundColor($r('[basic].color.white'))
          .textFont({ size: 14 })
          .layoutWeight(1)
          .padding(0)
          .margin(0)
          .height(36)
          .caretStyle({ color: $r('[basic].color.red') })
          .defaultFocus(true)
          .onSubmit((value) => {
            // 搜索
            this.pageStack.pushPath({ name: 'SearchResultView', param: value })
          })
      }
      .padding({ top: this.safeTop, right: 16 })
      .linearGradient({
        angle: 135,
        colors: [[$r('[basic].color.linear_begin'), 0], [$r('[basic].color.linear_end'), 1]]
      })

    }
  }
}