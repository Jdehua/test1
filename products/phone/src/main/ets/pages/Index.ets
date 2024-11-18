import { BreakpointConstants, BreakPointType, Logger } from 'basic'
import { CategoryView } from 'categroy/src/main/ets/views/CategroyView'
import { HomeView, SearchView } from 'home'

interface TabItem {
  text: string
  normal: ResourceStr
  active: ResourceStr
}

@Entry
@Component
struct Index {
  // 底部规避区域
  @StorageProp("safeBottom") safeBottom: number = 0
  @State activeIndex: number = 0
  @StorageProp(BreakpointConstants.BREAK_POINT_KEY) currentBreakpoint: string = ""
  list: TabItem[] = [
    { text: '首页', normal: $r('app.media.ic_public_home_normal'), active: $r('app.media.ic_public_home_active') },
    { text: '分类', normal: $r('app.media.ic_public_pro_normal'), active: $r('app.media.ic_public_pro_active') },
    { text: '购物袋', normal: $r('app.media.ic_public_cart_normal'), active: $r('app.media.ic_public_cart_active') },
    { text: '我的', normal: $r('app.media.ic_public_my_normal'), active: $r('app.media.ic_public_my_active') },
  ]
  // 路由栈对象，添加 @Provide 提供给后代使用
  @Provide pageStack: NavPathStack = new NavPathStack()

  aboutToAppear(): void {
    Logger.log({ a: 1, b: 2 })
  }

  build() {
    // 根路由
    Navigation(this.pageStack) {
      Tabs({ barPosition: BarPosition.End }) {
        ForEach(this.list, (item: TabItem, index: number) => {
          TabContent() {
            if (index == 0) {
              HomeView()
            } else if (index == 1) {
              CategoryView()
            } else if (index == 2) {
              Text("2")
            } else {
              Button("Navigation")
                .onClick(() => {
                  this.pageStack.pushPath({ name: "SearchView", param: new Object({ id: "123" }) })
                })
            }
          }
          .tabBar(this.TabItemBuilder(item, index))
        })
      }
      .barPosition(new BreakPointType({
        sm: BarPosition.End,
        md: BarPosition.Start,
        lg: BarPosition.Start
      }).getValue(this.currentBreakpoint))
      .vertical(new BreakPointType<boolean>({
        sm: false,
        md: true,
        lg: true
      }).getValue(this.currentBreakpoint))
      .scrollable(false)
      .onTabBarClick(index => {
        this.activeIndex = index
      })
      .padding({
        bottom: this.safeBottom
      })
    }
    .hideTitleBar(true) // 隐藏默认的标题栏
    .mode(NavigationMode.Stack) // 设置单栏 默认自动分栏

  }

  @Builder
  TabItemBuilder(item: TabItem, index: number) {
    Column() {
      Image(this.activeIndex === index ? item.active : item.normal)
        .width(24)
        .aspectRatio(1)
      Text(item.text)// 跨 HSP 访问资源，需要在 oh-package.json5中导入
        .fontColor($r('[basic].color.black'))
        .fontSize(12)
    }
    .justifyContent(FlexAlign.SpaceEvenly)
    .height(50)
  }
}