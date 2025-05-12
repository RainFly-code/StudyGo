import promptAction from '@ohos.promptAction';

/**
 * 日期选择对话框组件
 */
@CustomDialog
export struct DatePickerDialog {
  controller: CustomDialogController;
  selectedDate: string;
  onConfirm?: (date: string) => void;
  @State currentDate: Date = new Date();
  
  aboutToAppear() {
    // 解析传入的日期字符串
    if (this.selectedDate) {
      const [year, month, day] = this.selectedDate.split('-').map(Number);
      this.currentDate = new Date(year, month - 1, day);
    }
  }
  
  build() {
    Column() {
      Text('选择日期')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 16 })
      
      DatePicker({
        start: new Date(),
        end: new Date(new Date().getFullYear() + 1, 11, 31),
        selected: this.currentDate
      })
        .onChange((value: DatePickerResult) => {
          this.currentDate = new Date(value.year, value.month - 1, value.day);
        })
      
      Row() {
        Button('取消')
          .fontSize(16)
          .backgroundColor('#F5F5F5')
          .fontColor('#333333')
          .onClick(() => {
            this.controller.close();
          })
          .flexGrow(1)
          .height(40)
          .borderRadius(20)
          .margin({ right: 8 })
        
        Button('确定')
          .fontSize(16)
          .fontColor(Color.White)
          .onClick(() => {
            // 格式化日期为 YYYY-MM-DD
            const year = this.currentDate.getFullYear();
            const month = String(this.currentDate.getMonth() + 1).padStart(2, '0');
            const day = String(this.currentDate.getDate()).padStart(2, '0');
            
            const formattedDate = `${year}-${month}-${day}`;
            
            this.controller.close();
            this.onConfirm?.(formattedDate);
          })
          .flexGrow(1)
          .height(40)
          .borderRadius(20)
          .margin({ left: 8 })
      }
      .width('100%')
      .margin({ top: 24 })
    }
    .width('90%')
    .padding(24)
    .borderRadius(24)
    .backgroundColor(Color.White)
  }
} 