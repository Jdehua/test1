import { MkGoodsItem, MKPullToRefresh } from 'basic'
import { searchGoodsApi } from '../api'
import { MkGoods } from '../components/MkGoods'
import { GoodsItems, GoodsItemsDataSource } from '../viewmodel'
import { promptAction } from '@kit.ArkUI'

// 联合类型
export type SortField = 'publishTime' | 'orderNum' | 'price'

export type SortMethod = 'desc' | 'asc'

// 提交给服务器的参数
export interface SearchParams {
  keyword: string
  sortField: SortField
  sortMethod: SortMethod
  page: number
  pageSize: number
}

// 搜索结果
export interface SearchResult {
  pageData: GoodsItems;
}

// 筛选条件
export interface SortCompAttr {
  field: SortField
  label: string
}


// 路由参数
interface RouterParam {
  keyword: string
}

// 1 入口函数，必须以 @Builder 修饰
@Builder
function SearchResultViewBuilder() {
  // 2 必须以 NavDestination 组件包裹
  NavDestination() {
    SearchResultView()
  }
  .hideTitleBar(true) // 隐藏默认标题(返回图案)
}


@Component
export struct SearchResultView {
  // 顶部安全区域
  @StorageProp('safeTop') safeTop: number = 0
  // mock 数据
  // @State data: MkGoodsItem[] = []
  // 懒加载
  @State dataLazy: GoodsItemsDataSource = new GoodsItemsDataSource()
  //   new Array(8).fill({
  //   "id": "4033959",
  //   "name": "3秒快速拆琴轻松保养odin奥丁12半音阶口琴",
  //   "price": 329,
  //   "picture": "https://yanxuan-item.nosdn.127.net/937a8e46a9284e8f7e00e13911ecfbe7.png",
  //   "payCount": 0
  // })

  // 查询参数
  @State
  @Watch('paramsChange')
  params: SearchParams =
    {
      keyword: '',
      sortField: 'publishTime',
      sortMethod: 'desc',
      page: 1,
      pageSize: 10
    }
  // 筛选条件
  sortList: SortCompAttr[] = [
    { label: '时间', field: 'publishTime' },
    { label: '销量', field: 'orderNum' },
    { label: '价格', field: 'price' }
  ]
  // 控制器
  scroller = new Scroller()
  // 路由栈控制器
  @Consume pageStack: NavPathStack
  // 总页数
  totalPage: number = 0

  aboutToAppear(): void {
    // 解析参数 getParamByName 获取的是数组 注意通过 [0] 获取字符串
    this.params.keyword = this.pageStack.getParamByName('SearchResultView')[0] as string
    // 查询数据
    this.queryData()
  }

  paramsChange() {

  }

  // 搜索商品
  async queryData() {
    // 重置页码
    this.params.page = 1
    // 重置数据
    this.dataLazy.reloadData([])
    // 获取数据
    const res = await searchGoodsApi(this.params)
    // this.data = res.data.result.pageData.items
    this.dataLazy.reloadData(res.data.result.pageData.items as MkGoodsItem[])
    // 保存总页数 (当前筛选条件)
    this.totalPage = res.data.result.pageData.pages
  }

  // 加载更多数据
  async loadMore() {
    // 如果当前页码小于总页数
    if (this.params.page < this.totalPage) {
      // 页码增加
      this.params.page++
      // 发送请求
      const res = await searchGoodsApi(this.params)
      // 追加数据
      // this.data.push(...res.data.result.pageData.items as MkGoodsItem[])
      res.data.result.pageData.items.forEach((item) => {
        this.dataLazy.pushData(item) // 每次只能追加一个，循环添加
      })
    } else {
      promptAction.showToast({ message: '没有更多数据啦～' })
    }
  }

  build() {
    Column() {
      // 搜索区域
      Row() {
        Image($r('[basic].media.ic_public_left'))
          .width(24)
          .aspectRatio(1)
          .fillColor($r('[basic].color.white'))
          .margin(13)
          .onClick(() => {
            // 返回上一页
            this.pageStack.pop()
          })
        Search({ placeholder: '商品关键字...', value: this.params.keyword })
          .searchIcon({ src: $r('[basic].media.ic_public_search'), color: $r('[basic].color.gray') })
          .placeholderColor($r('[basic].color.gray'))
          .placeholderFont({ size: 14 })
          .backgroundColor($r('[basic].color.white'))
          .textFont({ size: 14 })
          .layoutWeight(1)
          .padding(0)
          .margin(0)
          .height(36)
          .caretStyle({ color: $r('[basic].color.red') })
          .onSubmit((value) => {
            this.params.keyword = value
            // 查询数据
            this.queryData()
          })
      }
      .padding({ top: this.safeTop, right: 16 })
      .linearGradient({
        angle: 135,
        colors: [[$r('[basic].color.linear_begin'), 0], [$r('[basic].color.linear_end'), 1]]
      })

      // list
      Row() {
        ForEach(this.sortList, (item: SortCompAttr) => {
          // 筛选组件
          SortItemComp({
            label: item.label,
            field: item.field,
            sortField: this.params.sortField,
            sortMethod: this.params.sortMethod,
            onCLickItem: (sortField: SortField, sortMethod: SortMethod) => {
              this.params.sortField = sortField
              this.params.sortMethod = sortMethod
              this.queryData()
            }
          })
        })
        Text('筛选')
          .fontSize(14)
          .fontColor($r('[basic].color.gray'))
      }
      .padding({ left: 16, right: 16 })
      .height(50)
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .border({ width: { bottom: 0.5 }, color: $r('[basic].color.border') })

      MKPullToRefresh({
        data: $dataLazy,
        scroller: this.scroller,
        customList: () => {
          this.getWaterFlowView()
        },
        // 可选项，下拉刷新回
        //
        //
        //
        //
        // 调
        onRefresh: async () => {
          // 清空数据
          // this.data = []
          this.dataLazy.reloadData([])
          this.params.page = 1
          await this.queryData()
          return '刷新成功'
        },
        // 上拉加载更多回调
        onLoadMore: async () => {
          this.loadMore()
          return '上拉加载'
        }
      })
        .layoutWeight(1)

    }
  }

  // 重构 WaterFlow 变成 view
  @Builder
  getWaterFlowView() {
    WaterFlow({ scroller: this.scroller }) {
      LazyForEach(this.dataLazy, (item: MkGoodsItem) => {
        FlowItem() {
          MkGoods({ goods: item, smallImage: true })
        }
      })
    }
    .columnsTemplate("1fr 1fr")
    .columnsGap(0.5)
    .rowsGap(0.5)
  }
}

@Component
struct SortItemComp {
  // 筛选字段
  field: SortField = 'publishTime'
  // 显示的文本
  label: string = ''
  // 状态变量，接收父组件的状态属性
  // 父组件的筛选字段
  @Prop sortField: SortField = 'publishTime'
  // 父组件的排序方法
  @Prop sortMethod: SortMethod = 'desc'
  // 点击筛选条件，回传  sortField 和 sortMethod 给父组件（回调函数）
  onCLickItem: (sortField: SortField, sortMethod: SortMethod) => void = () => {
  }

  build() {
    Row() {
      Text(this.label)
        .fontWeight(500)
        .fontSize(14)
        .fontColor(this.sortField === this.field ? $r('[basic].color.black') : $r('[basic].color.gray'))
      Column() {
        Image($r('[basic].media.ic_public_up'))
          .width(15)
          .height(6)
          .fillColor(this.sortField === this.field && this.sortMethod === 'asc' ? $r('[basic].color.black') :
          $r('[basic].color.gray'))
        Image($r('[basic].media.ic_public_down'))
          .width(15)
          .height(6)
          .fillColor(this.sortField === this.field && this.sortMethod === 'desc' ? $r('[basic].color.black') :
          $r('[basic].color.gray'))
      }
      .justifyContent(FlexAlign.Center)
    }
    .onClick(() => {
      // 筛选字段 和 排序方法（升降）
      if (this.field === this.sortField) {
        // 子筛选没变(同) 升降改变
        this.onCLickItem(this.field, this.sortMethod === 'desc' ? 'asc' : 'desc')
      } else {
        // 子筛选字段改变，升降置为默认值
        this.onCLickItem(this.field, 'desc')
      }
    })
  }
}