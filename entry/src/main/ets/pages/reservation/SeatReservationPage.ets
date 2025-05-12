import router from '@ohos.router';
import { Routes } from '../../common/constants/Routes';
import { ToastUtil } from '../../common/components/ToastUtil';
import { LoadingDialog } from '../../common/components/LoadingDialog';
import { DatePickerDialog } from '../../common/components/DatePickerDialog';
import { ReservationService } from '../../service/ReservationService';

@Entry
@Component
struct SeatReservationPage {
  @State isLoading: boolean = false;
  @State startDate: string = '';
  @State days: number = 1;
  
  private roomId: number = router.getParams()?.['roomId'] || 0;
  private roomName: string = router.getParams()?.['roomName'] || '';
  private seatId: number = router.getParams()?.['seatId'] || 0;
  private seatNumber: string = router.getParams()?.['seatNumber'] || '';
  
  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({ message: '提交中...' }),
    alignment: DialogAlignment.Center,
    autoCancel: false,
    customStyle: true
  });
  
  private datePickerDialogController: CustomDialogController = new CustomDialogController({
    builder: DatePickerDialog({
      selectedDate: this.startDate,
      onConfirm: (date: string) => {
        this.startDate = date;
      }
    }),
    autoCancel: true,
    customStyle: true
  });
  
  aboutToAppear() {
    // 设置默认开始日期为明天
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    const year = tomorrow.getFullYear();
    const month = String(tomorrow.getMonth() + 1).padStart(2, '0');
    const day = String(tomorrow.getDate()).padStart(2, '0');
    this.startDate = `${year}-${month}-${day}`;
  }
  
  /**
   * 显示日期选择器
   */
  showDatePicker() {
    this.datePickerDialogController = new CustomDialogController({
      builder: DatePickerDialog({
        selectedDate: this.startDate,
        onConfirm: (date: string) => {
          this.startDate = date;
        }
      }),
      autoCancel: true,
      customStyle: true
    });
    
    this.datePickerDialogController.open();
  }
  
  /**
   * 提交预约
   */
  async submitReservation() {
    if (!this.startDate) {
      ToastUtil.showWarning('请选择开始日期');
      return;
    }
    
    if (this.days < 1 || this.days > 30) {
      ToastUtil.showWarning('预约天数必须在1-30天之间');
      return;
    }
    
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      const result = await ReservationService.addReservation(
        this.seatId,
        this.startDate,
        this.days
      );
      
      if (result) {
        ToastUtil.showSuccess('预约提交成功，等待审核');
        router.back();
      } else {
        ToastUtil.showError('预约提交失败');
      }
    } catch (error) {
      console.error('预约提交失败:', error);
      ToastUtil.showError('预约提交失败: ' + error.message);
    } finally {
      this.isLoading = false;
      this.loadingDialogController.close();
    }
  }
  
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .margin({ left: 16 })
          .onClick(() => {
            router.back();
          })
        
        Text('预约座位')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
        
        Blank()
          .width(40)
      }
      .width('100%')
      .height(56)
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#FFFFFF')
      
      // 预约信息
      Column() {
        // 自习室信息
        Row() {
          Text('自习室:')
            .fontSize(16)
            .fontColor('#666666')
          
          Text(this.roomName)
            .fontSize(16)
            .fontColor('#333333')
            .margin({ left: 8 })
        }
        .width('90%')
        .margin({ top: 16 })
        
        // 座位信息
        Row() {
          Text('座位号:')
            .fontSize(16)
            .fontColor('#666666')
          
          Text(this.seatNumber)
            .fontSize(16)
            .fontColor('#333333')
            .margin({ left: 8 })
        }
        .width('90%')
        .margin({ top: 12 })
        
        // 开始日期
        Row() {
          Text('开始日期:')
            .fontSize(16)
            .fontColor('#666666')
          
          Text(this.startDate)
            .fontSize(16)
            .fontColor('#007DFF')
            .margin({ left: 8 })
          
          Blank()
            .layoutWeight(1)
          
          Button('选择日期')
            .fontSize(14)
            .fontColor('#007DFF')
            .backgroundColor(Color.Transparent)
            .height(32)
            .onClick(() => {
              this.showDatePicker();
            })
        }
        .width('90%')
        .margin({ top: 12 })
        
        // 预约天数
        Row() {
          Text('预约天数:')
            .fontSize(16)
            .fontColor('#666666')
          
          TextInput({ placeholder: '请输入预约天数', text: this.days.toString() })
            .width(100)
            .height(40)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .margin({ left: 8 })
            .type(InputType.Number)
            .onChange((value: string) => {
              const num = parseInt(value);
              if (!isNaN(num)) {
                this.days = num;
              }
            })
          
          Text('天')
            .fontSize(16)
            .fontColor('#666666')
            .margin({ left: 8 })
        }
        .width('90%')
        .margin({ top: 12 })
        
        // 提交按钮
        Button('提交预约')
          .width('90%')
          .height(50)
          .borderRadius(25)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#007DFF')
          .margin({ top: 40 })
          .onClick(() => {
            this.submitReservation();
          })
      }
      .width('100%')
      .margin({ top: 16 })
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 