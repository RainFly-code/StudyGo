/**
 * 加载对话框组件
 */
@CustomDialog
export struct LoadingDialog {
  controller: CustomDialogController;
  message: string = '加载中...';
  
  build() {
    Column() {
      LoadingProgress()
        .width(50)
        .height(50)
        .color('#007DFF')
      
      Text(this.message)
        .fontSize(16)
        .margin({ top: 10 })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding(20)
  }
} 