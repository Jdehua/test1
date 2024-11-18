import { BreakpointConstants, BreakPointType, CategoryItem, CategoryItemChild, MkNavbar } from 'basic'
import { promptAction } from '@kit.ArkUI'

@Component
export struct CategoryView {
  // 从 AppStorage 获取数据
  @StorageProp("categoryData") categories: CategoryItem[] = []
  @State activeIndex: number = 0
  // 断点
  @StorageProp(BreakpointConstants.BREAK_POINT_KEY) breakpoint: string = "sm"
  // 滚动控制器
  scroller: Scroller = new Scroller()

  // 自定义标题 结构
  @Builder
  testTitleBuilder() {
    Text("商品分类")
      .fontSize(16)
      .fontWeight(500)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .fontColor(Color.Black)
  }

  build() {
    Column() {
      // 导航栏组件
      MkNavbar({
        title: "商品分类",
        showLeftIcon: false,
        showRightIcon: true,
        rightIcon: $r('[basic].media.ic_public_search'),
        rightClickHandler: () => {
          promptAction.showToast({ message: '点击' })
        },
        customTitle: this.testTitleBuilder
      })

      Row() {
        // 左侧栏
        Column() {
          ForEach(this.categories, (item: CategoryItem, i) => {
            Text(item.name)// 文本
              .backgroundColor(this.activeIndex === i ? $r('[basic].color.black') : $r('[basic].color.white'))
              .fontSize(14)
              .fontColor(this.activeIndex === i ? $r('[basic].color.white') : $r('[basic].color.black'))
              .textAlign(TextAlign.Center)
              .width('100%')
              .height(56)
              .onClick(() => {
                // 切换索引
                this.activeIndex = i
                // 滚动到顶部
                this.scroller.scrollTo({ xOffset: 0, yOffset: 0 })
              })

          })
        }
        .width(88)
        .border({ width: { right: 0.5 }, color: $r('[basic].color.under') })

        // 右侧 物品栏
        Scroll(this.scroller) {
          Column() {
            // 顶部图片
            Image(this.categories[this.activeIndex].picture)
              .width('100%')
              .height(new BreakPointType({
                sm: 136,
                md: 200,
                lg: 220
              }).getValue(this.breakpoint))
              .objectFit(ImageFit.Contain)
              .backgroundColor('#f6f6f6')
              .borderRadius(8)
              .margin({ bottom: 8 })
            GridRow({ columns: { sm: 2, md: 3, lg: 4 }, gutter: 8 }) {
              // 子分类
              ForEach(this.categories[this.activeIndex]?.children, (sub: CategoryItemChild) => {
                GridCol() {
                  Column() {
                    // 图片
                    Image(sub.picture)
                      .width(64)
                      .aspectRatio(1)
                    Text(sub.name)// 文本
                      .fontSize(14)
                      .fontColor($r('[basic].color.text'))
                      .margin({ top: 8 })
                  }
                  .height('100%')
                  .justifyContent(FlexAlign.Center)
                }
                .aspectRatio(1)
                .backgroundColor('#f6f6f6')
                .borderRadius(8)
              })
            }
          }
          .padding(8)
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
    .height('100%')
  }
}