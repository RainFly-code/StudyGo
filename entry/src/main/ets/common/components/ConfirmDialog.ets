/**
 * 确认对话框组件
 */
@CustomDialog
export struct ConfirmDialog {
  controller: CustomDialogController;
  title: string = '提示';
  message: string = '';
  confirmText: string = '确认';
  cancelText: string = '取消';
  onConfirm?: () => void;
  onCancel?: () => void;
  
  build() {
    Column() {
      Text(this.title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })
      
      Text(this.message)
        .fontSize(16)
        .margin({ bottom: 20 })
      
      Row() {
        Button(this.cancelText)
          .fontSize(16)
          .backgroundColor('#F5F5F5')
          .fontColor('#333333')
          .onClick(() => {
            this.controller.close();
            this.onCancel?.();
          })
          .flexGrow(1)
          .height(40)
          .borderRadius(20)
          .margin({ right: 8 })
        
        Button(this.confirmText)
          .fontSize(16)
          .fontColor(Color.White)
          .onClick(() => {
            this.controller.close();
            this.onConfirm?.();
          })
          .flexGrow(1)
          .height(40)
          .borderRadius(20)
          .margin({ left: 8 })
      }
      .width('100%')
    }
    .width('90%')
    .padding(24)
    .borderRadius(24)
    .backgroundColor(Color.White)
  }
} 