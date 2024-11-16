@Component
export struct MKloading {

  // 宽度自主传入
  loadinWidth: number = 80

  build() {
    ImageAnimator()
      .images([
        { src: $r("app.media.loading_01")},
        { src: $r("app.media.loading_02")},
        { src: $r("app.media.loading_03")},
        { src: $r("app.media.loading_04")}
      ])
      .state(AnimationStatus.Running) // 动画状态
      .duration(380) // 播放时长
      .iterations(-1) // 循环
      .width(this.loadinWidth) // 宽度
      .aspectRatio(225 / 75) // 宽高比
  }
}