import { BreakpointConstants, BreakPointType, MKloading } from 'basic'
import {
  getBannerApi,
  getCategoryApi,
  getHotInVogueApi,
  getHotOneStopApi,
  getHotPreferenceApi,
  getNewApi,
  getRecommendApi
} from '../api'
import { DiscountGoodsComp, DiscountType } from '../components/DiscountGoodsComp'
import { MkGoods } from '../components/MkGoods'
import { Banner, CategoryItem, GoodsItemsDataSource, HotResult, MkGoodsItem, Params } from '../viewmodel'
import { promptAction } from '@kit.ArkUI'

@Component
export struct HomeView {
  // 轮播图
  @State banners: Banner[] = []
  // 分类
  @State categories: CategoryItem[] = []
  // 特惠推荐
  @State saleGoods: MkGoodsItem[] = []
  // 爆款推荐
  @State hotGoods: MkGoodsItem[] = []
  // 一站买全
  @State oneGoods: MkGoodsItem[] = []
  // 新鲜好物
  @State newGoods: MkGoodsItem[] = []
  // 推荐商品
  @State recommendGoods: MkGoodsItem[] = []
  // 推荐商品（懒加载 - LazyForEach 对象）
  @State recommendGoodsLazy: GoodsItemsDataSource = new GoodsItemsDataSource()
  // 断点
  @StorageProp(BreakpointConstants.BREAK_POINT_KEY) breakpoint: string = ""
  // 顶部避让区域
  @StorageProp("safeTop") safeTop: number = 0
  // 分页参数
  page: number = 1
  // 加载中...
  @State isLoading: boolean = true
  // 下拉刷新
  @State isRefreshing: boolean = false

  async aboutToAppear() {
    // 显示加载中
    this.isLoading = true
    // 获取数据
    this.getData()
    // 隐藏加载中
    this.isLoading = false
  }

  // 根据断点获取间距
  getSpace(): number | undefined {
    return new BreakPointType({
      sm: 16,
      md: 32,
      lg: 76,
    }).getValue(this.breakpoint)
  }

  // 1 轮播图数据   2 获取推荐商品数据   3 获取爆款推荐数   4 获取一站买全数据    5 获取新鲜好物数据    6 推荐商品列表
  async getData() {

    const proArr =
      [getBannerApi(), getCategoryApi(), getHotPreferenceApi(), getHotInVogueApi(), getHotOneStopApi(), getNewApi(),
        getRecommendApi()]
    // allSettled 可以获取到每个请求状态成功或失败
    const resArr = await Promise.allSettled(proArr)

    if (resArr[0].status == 'fulfilled') {
      this.banners = resArr[0].value.data.result as Banner[]
    }
    if (resArr[1].status == 'fulfilled') {
      this.categories = resArr[1].value.data.result as CategoryItem[]
    }
    if (resArr[2].status == 'fulfilled') {
      this.saleGoods = (resArr[2].value.data.result as HotResult).subTypes[0].goodsItems.items
    }
    if (resArr[3].status == 'fulfilled') {
      this.hotGoods = (resArr[3].value.data.result as HotResult).subTypes[0].goodsItems.items
    }
    if (resArr[4].status == 'fulfilled') {
      this.oneGoods = (resArr[4].value.data.result as HotResult).subTypes[0].goodsItems.items
    }
    if (resArr[5].status == 'fulfilled') {
      this.newGoods = resArr[5].value.data.result as MkGoodsItem[]
    }
    if (resArr[6].status == 'fulfilled') {
      // this.recommendGoods = resArr[6].value.data.result as MkGoodsItem[]
      this.recommendGoodsLazy.reloadData(resArr[6].value.data.result as MkGoodsItem[])
    }
  }

  // 滚动触底
  async loadMore() {
    this.page++
    if (this.recommendGoodsLazy.totalCount() <= 30) {
      const res = await getRecommendApi(this.page * 8)
      // this.recommendGoods = res.data.result as MkGoodsItem[]
      this.recommendGoodsLazy.reloadData(res.data.result as MkGoodsItem[])
    } else {
      promptAction.showToast({
        message: '没有更多数据了',
        duration: 2000
      })
    }
  }

  @Builder
  DiscountBuilder(params: Params) {

    Column() {
      Row({ space: 10 }) {
        Text(params.title)
          .fontColor($r('[basic].color.black'))
          .fontSize(14)
        Text(params.subTitle)
          .fontColor($r('[basic].color.text'))
          .fontSize(11)
      }
      .width('100%')
      .margin({ bottom: 10 })

      List({ space: 10 }) {
        ForEach(params.list, (item: MkGoodsItem) => {
          ListItem() {
            DiscountGoodsComp({ type: DiscountType.DISCOUNT, goods: item })
          }
        })
      }
      .width('100%')
      .height(116)
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
    }
    .height(160)
    .layoutWeight(1)
    .padding(10)
    .backgroundColor(params.bg)
    .borderRadius(8)
  }

  // 下拉刷新
  @Builder
  RefreshBuilder() {
    Row() {
      // 自定义刷新组件
      if (this.isRefreshing) {
        MKloading()
      }
    }
    .width('100%')
    .padding(10)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    if (this.isLoading) {
      MKloading()
    } else {
      Refresh({ refreshing: $$this.isRefreshing, builder: this.RefreshBuilder }) {
        Scroll() {
          Column() {
            // 轮播图 + 搜索
            Stack({ alignContent: Alignment.Top }) {
              Swiper() {
                ForEach(this.banners, (item: Banner) => {
                  Image(item.imgUrl)
                })
              }
              // 轮播图数量
              .displayCount(new BreakPointType({
                sm: 1,
                md: 2,
                lg: 3,
              }).getValue(this.breakpoint))
              // 轮播图间隔
              .itemSpace(new BreakPointType({
                sm: 0,
                md: 10,
                lg: 20,
              }).getValue(this.breakpoint))
              // 导航点
              .indicator(
                this.breakpoint == BreakpointConstants.SM ?
                DotIndicator.dot()
                  .itemWidth(8)
                  .itemHeight(4)
                  .color('#33191919')
                  .selectedItemWidth(24)
                  .selectedItemHeight(4)
                  .selectedColor('#191919')
                  : false
              )

              Row() {
                Row({ space: 4 }) {
                  Image($r('[basic].media.ic_public_search'))
                    .width(16)
                    .height(16)
                    .fillColor($r('[basic].color.white'))
                  Text('搜索...')
                    .fontSize(14)
                    .fontColor($r('[basic].color.white'))
                }
                .backgroundColor('#33191919')
                .width('100%')
                .height(40)
                .borderRadius(20)
                .padding({ left: 12 })
              }
              .padding({ left: 16, right: 16, top: this.safeTop })
            }
            .width('100%')


            // 分类
            Column({ space: 10 }) {
              // 分类
              List({ space: this.getSpace() }) {
                ForEach(this.categories, (item: CategoryItem) => {
                  ListItem() {
                    Column() {
                      Image(item.picture)
                        .width(56)
                        .aspectRatio(1)
                      Text(item.name)
                        .fontSize(10)
                        .fontColor('#CC191919')
                    }
                    .width(60)
                    .height(80)
                    .borderRadius(30)

                    .clip(true)
                    .backgroundImage(item.picture)
                    .backgroundImageSize(ImageSize.Contain)
                    .backgroundImagePosition(Alignment.Center)
                    .backgroundBlurStyle(
                      BlurStyle.BACKGROUND_ULTRA_THICK,
                      { scale: 0.25 }
                    )
                  }
                })
              }
              .width('100%')
              .height(92)
              .scrollBar(BarState.Off)
              .listDirection(Axis.Horizontal)
              .alignListItem(ListItemAlign.Center)

              // 特惠推荐
              Column({ space: this.getSpace() }) {
                Image($r('app.media.home_cmd_title'))
                  .width(150)
                  .height(20)
                Row() {
                  Image($r('app.media.home_cmd_inner'))
                    .width(86)
                    .height(116)
                  List({ space: 10 }) {
                    ForEach(this.saleGoods, (item: MkGoodsItem) => {
                      ListItem() {
                        DiscountGoodsComp({ goods: item })
                      }
                    })
                  }
                  .layoutWeight(1)
                  .width('100%')
                  .height(116)
                  .backgroundColor($r('[basic].color.white'))
                  .borderRadius({
                    topRight: 8,
                    bottomRight: 8
                  })
                  .padding({ right: 10, left: 10 })
                  .scrollBar(BarState.Off)
                  .listDirection(Axis.Horizontal)
                }
              }
              .width('100%')
              .height(166)
              .backgroundImage($r('app.media.home_cmd_sm'))
              .backgroundImageSize(ImageSize.Cover)
              .borderRadius(8)
              .padding(10)
              .alignItems(HorizontalAlign.Start)

              // 爆款推荐+一站买全
              Row({ space: this.getSpace() }) {
                this.DiscountBuilder({
                  title: '爆款推荐',
                  subTitle: '最受欢迎',
                  bg: '#EDF1FB',
                  list: this.hotGoods
                })
                this.DiscountBuilder({
                  title: '一站买全',
                  subTitle: '精心优选',
                  bg: '#FCF6EA',
                  list: this.oneGoods
                })
              }

              // 新鲜好物
              Column({ space: 10 }) {
                Image($r('app.media.home_new'))
                  .width(146)
                  .height(19)
                List({ space: 10 }) {
                  ForEach(this.newGoods, (item: MkGoodsItem) => {
                    ListItem() {
                      DiscountGoodsComp({ type: DiscountType.NEW, goods: item })
                    }
                  })
                }
                .width('100%')
                .height(116)
                .scrollBar(BarState.Off)
                .listDirection(Axis.Horizontal)
              }
              .width('100%')
              .height(156)
              .padding(10)
              .backgroundColor('#F7EFF5')
              .borderRadius(8)
              .alignItems(HorizontalAlign.Start)

              // 推荐商品
              WaterFlow() {
                LazyForEach(this.recommendGoodsLazy, (item: MkGoodsItem) => {
                  FlowItem() {
                    MkGoods({ goods: item })
                  }
                })
              }
              .columnsTemplate(new BreakPointType({
                sm: "1fr ".repeat(2),
                md: "1fr ".repeat(3),
                lg: "1fr ".repeat(4)
              }).getValue(this.breakpoint))
              .columnsGap(8)
              .rowsGap(10)
              // 有高度，不会被一直撑开，启动懒加载
              .height("100%")
              // 内层嵌套滚动
              .nestedScroll({
                // 向前 父级优先
                scrollForward: NestedScrollMode.PARENT_FIRST,
                // 向后 自己优先
                scrollBackward: NestedScrollMode.SELF_FIRST
              })
              .onReachEnd(() => {
                // 加载更多数据
                this.loadMore()
              })

            }
            .padding({
              left: 8,
              right: 8,
              bottom: 10
            })
          }
        }
        .scrollBar(BarState.Off)
      }
      // 显示的淡入效果 放入根组件
      .transition(TransitionEffect.OPACITY.animation({ duration: 500 }))
      // 下拉刷新
      .onRefreshing(async () => {
        // 等待 获取新数据
        await this.getData()
        // 关闭刷新
        this.isRefreshing = false
        // 重置页码
        this.page = 1
      })
    }
  }
}