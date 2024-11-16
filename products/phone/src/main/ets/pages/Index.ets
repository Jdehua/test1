import { BreakpointConstants, BreakPointType, Logger } from 'basic'
import { CartView } from 'cart'
import { CategroyView } from 'categroy'
import { HomeView } from 'home'

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
  @StorageProp(BreakpointConstants.BREAK_POINT_KEY) currentBreakpoint:string = ""

  list: TabItem[] = [
    { text: '首页', normal: $r('app.media.ic_public_home_normal'), active: $r('app.media.ic_public_home_active') },
    { text: '分类', normal: $r('app.media.ic_public_pro_normal'), active: $r('app.media.ic_public_pro_active') },
    { text: '购物袋', normal: $r('app.media.ic_public_cart_normal'), active: $r('app.media.ic_public_cart_active') },
    { text: '我的', normal: $r('app.media.ic_public_my_normal'), active: $r('app.media.ic_public_my_active') },
  ]

  aboutToAppear(): void {
    Logger.log( {a:1,b:2} )
  }

  build() {
    Tabs({ barPosition: BarPosition.End }) {
      ForEach(this.list, (item: TabItem, index: number) => {
        TabContent() {
          if (index == 0) {
            Text("currentBreakpoint: " + this.currentBreakpoint)
              .backgroundColor(new BreakPointType({
                sm: Color.Pink,
                md: Color.Blue,
                lg: Color.Green
              }).getValue(this.currentBreakpoint))
          } else if (index == 1) {
            CategroyView()
          } else if (index == 2) {
            HomeView()
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

  @Builder
  TabItemBuilder(item: TabItem, index: number) {
    Column() {
      Image(this.activeIndex === index ? item.active : item.normal)
        .width(24)
        .aspectRatio(1)
      Text(item.text)
        // 跨 HSP 访问资源，需要在 oh-package.json5中导入
        .fontColor($r('[basic].color.black'))
        .fontSize(12)
    }
    .justifyContent(FlexAlign.SpaceEvenly)
    .height(50)
  }
}