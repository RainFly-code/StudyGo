import router from '@ohos.router';
import { Routes } from '../../../common/constants/Routes';
import { Constants } from '../../../common/constants/Constants';
import { ToastUtil } from '../../../common/components/ToastUtil';
import { LoadingDialog } from '../../../common/components/LoadingDialog';
import { ConfirmDialog } from '../../../common/components/ConfirmDialog';
import { Reservation } from '../../../model/StudyRoomModel';
import { ReservationService } from '../../../service/ReservationService';

@Entry
@Component
struct AdminReservationDetailPage {
  @State reservation: Reservation = new Reservation();
  @State isLoading: boolean = false;
  
  private reservationId: number = router.getParams()?.['id'] || 0;
  
  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({ message: '加载中...' }),
    alignment: DialogAlignment.Center,
    autoCancel: false,
    customStyle: true
  });
  
  private confirmDialogController: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      title: '处理预约',
      message: '确定要执行此操作吗？',
      onConfirm: () => {}
    }),
    autoCancel: true,
    customStyle: true
  });
  
  aboutToAppear() {
    this.loadReservationDetail();
  }
  
  /**
   * 加载预约详情
   */
  async loadReservationDetail() {
    if (!this.reservationId) {
      ToastUtil.showError('预约ID不能为空');
      router.back();
      return;
    }
    
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      this.reservation = await ReservationService.getReservationDetail(this.reservationId);
      
      // 处理后端可能返回date字段的情况
      if (this.reservation.date && (!this.reservation.startDate || !this.reservation.endDate)) {
        this.reservation.startDate = this.reservation.date;
        
        // 计算结束日期
        if (this.reservation.days > 1) {
          try {
            const startDate = new Date(this.reservation.date);
            const endDate = new Date(startDate);
            endDate.setDate(startDate.getDate() + this.reservation.days - 1);
            
            const year = endDate.getFullYear();
            const month = String(endDate.getMonth() + 1).padStart(2, '0');
            const day = String(endDate.getDate()).padStart(2, '0');
            this.reservation.endDate = `${year}-${month}-${day}`;
          } catch (error) {
            console.error('计算结束日期失败:', error);
            this.reservation.endDate = this.reservation.date;
          }
        } else {
          this.reservation.endDate = this.reservation.date;
        }
      }
      
      console.info('预约详情:', JSON.stringify(this.reservation));
    } catch (error) {
      console.error('获取预约详情失败:', error);
      ToastUtil.showError('获取预约详情失败: ' + error.message);
      router.back();
    } finally {
      this.isLoading = false;
      this.loadingDialogController.close();
    }
  }
  
  /**
   * 确认处理预约
   */
  showHandleConfirm(status: number) {
    let title = '';
    let content = '';
    
    switch (status) {
      case Constants.RESERVATION_STATUS.APPROVED:
        title = '通过预约';
        content = `确定要通过 用户ID: ${this.reservation.userId} 的预约申请吗？`;
        break;
      case Constants.RESERVATION_STATUS.REJECTED:
        title = '拒绝预约';
        content = `确定要拒绝 用户ID: ${this.reservation.userId} 的预约申请吗？`;
        break;
      case Constants.RESERVATION_STATUS.CANCELLED:
        title = '取消预约';
        content = `确定要取消 用户ID: ${this.reservation.userId} 的预约吗？`;
        break;
    }
    
    this.confirmDialogController = new CustomDialogController({
      builder: ConfirmDialog({
        title: title,
        message: content,
        onConfirm: async () => {
          await this.handleReservation(status);
        }
      }),
      autoCancel: true,
      customStyle: true
    });
    
    this.confirmDialogController.open();
  }
  
  /**
   * 处理预约
   */
  async handleReservation(status: number) {
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      const result = await ReservationService.handleReservation(this.reservationId, status);
      
      if (result) {
        let message = '';
        switch (status) {
          case Constants.RESERVATION_STATUS.APPROVED:
            message = '预约已通过';
            break;
          case Constants.RESERVATION_STATUS.REJECTED:
            message = '预约已拒绝';
            break;
          case Constants.RESERVATION_STATUS.CANCELLED:
            message = '预约已取消';
            break;
        }
        
        ToastUtil.showSuccess(message);
        // 重新加载预约详情
        this.loadReservationDetail();
      } else {
        ToastUtil.showError('处理预约失败');
      }
    } catch (error) {
      console.error('处理预约失败:', error);
      ToastUtil.showError('处理预约失败: ' + error.message);
    } finally {
      this.isLoading = false;
      this.loadingDialogController.close();
    }
  }
  
  /**
   * 获取状态文本及颜色
   */
  getStatusInfo(status: number): { text: string, color: string } {
    switch (status) {
      case Constants.RESERVATION_STATUS.PENDING:
        return { text: '待审核', color: '#FF9800' };
      case Constants.RESERVATION_STATUS.APPROVED:
        return { text: '已通过', color: '#4CAF50' };
      case Constants.RESERVATION_STATUS.REJECTED:
        return { text: '已拒绝', color: '#F44336' };
      case Constants.RESERVATION_STATUS.CANCELLED:
        return { text: '已取消', color: '#9E9E9E' };
      default:
        return { text: '未知', color: '#9E9E9E' };
    }
  }
  
  /**
   * 格式化日期显示
   */
  formatDate(dateStr: string): string {
    if (!dateStr) return '';
    
    try {
      // 首先处理可能包含时间的日期字符串
      let datePart = dateStr;
      if (dateStr.includes(' ')) {
        datePart = dateStr.split(' ')[0];
      }
      
      // 检查日期格式是否为yyyy-MM-dd
      if (/^\d{4}-\d{2}-\d{2}$/.test(datePart)) {
        return datePart;
      }
      
      // 尝试解析为Date对象并格式化
      const date = new Date(dateStr);
      if (!isNaN(date.getTime())) {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
      }
      
      return datePart; // 返回原始日期部分
    } catch (error) {
      console.error('日期格式化失败:', dateStr, error);
      return dateStr || '';
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
        
        Text('预约详情')
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
      
      // 预约状态
      Row() {
        Text('预约状态:')
          .fontSize(16)
          .fontColor('#666666')
        
        Text(this.getStatusInfo(this.reservation.status).text)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.getStatusInfo(this.reservation.status).color)
          .margin({ left: 8 })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 20 })
      .backgroundColor('#FFFFFF')
      .margin({ top: 12 })
      
      // 用户信息
      Column() {
        Text('用户信息')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)
        
        // 用户名
        Row() {
          Text('用户ID:')
            .fontSize(16)
            .fontColor('#666666')
            .width(80)
          
          Text(this.reservation.userId?.toString())
            .fontSize(16)
            .fontColor('#333333')
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 16 })
        
        // 用户ID (保留，但修改文本)
        Row() {
          Text('备注:')
            .fontSize(16)
            .fontColor('#666666')
            .width(80)
          
          Text('无')
            .fontSize(16)
            .fontColor('#333333')
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 12 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .margin({ top: 12 })
      
      // 预约信息
      Column() {
        Text('预约信息')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)
        
        // 自习室信息
        Row() {
          Text('自习室:')
            .fontSize(16)
            .fontColor('#666666')
            .width(80)
          
          Text(this.reservation.roomName)
            .fontSize(16)
            .fontColor('#333333')
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 16 })
        
        // 自习室ID
        Row() {
          Text('自习室ID:')
            .fontSize(16)
            .fontColor('#666666')
            .width(80)
          
          Text(this.reservation.roomId?.toString())
            .fontSize(16)
            .fontColor('#333333')
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 12 })
        
        // 座位信息
        Row() {
          Text('座位号:')
            .fontSize(16)
            .fontColor('#666666')
            .width(80)
          
          Text(this.reservation.seatNumber)
            .fontSize(16)
            .fontColor('#333333')
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 12 })
        
        // 座位ID
        Row() {
          Text('座位ID:')
            .fontSize(16)
            .fontColor('#666666')
            .width(80)
          
          Text(this.reservation.seatId?.toString())
            .fontSize(16)
            .fontColor('#333333')
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 12 })
        
        // 预约时间
        Row() {
          Text('预约日期:')
            .fontSize(16)
            .fontColor('#666666')
            .width(80)
          
          Text(`${this.formatDate(this.reservation.startDate)} - ${this.formatDate(this.reservation.endDate)}`)
            .fontSize(16)
            .fontColor('#333333')
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 12 })
        
        // 预约天数
        Row() {
          Text('预约天数:')
            .fontSize(16)
            .fontColor('#666666')
            .width(80)
          
          Text(`${this.reservation.days}天`)
            .fontSize(16)
            .fontColor('#333333')
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 12 })
        
        // 申请时间
        Row() {
          Text('申请时间:')
            .fontSize(16)
            .fontColor('#666666')
            .width(80)
          
          Text(this.reservation.createTime)
            .fontSize(16)
            .fontColor('#333333')
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 12 })
        
        // 更新时间
        Row() {
          Text('更新时间:')
            .fontSize(16)
            .fontColor('#666666')
            .width(80)
          
          Text(this.reservation.updateTime)
            .fontSize(16)
            .fontColor('#333333')
            .layoutWeight(1)
        }
        .width('100%')
        .margin({ top: 12 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .margin({ top: 12 })
      
      // 底部操作按钮
      if (this.reservation.status === Constants.RESERVATION_STATUS.PENDING) {
        Row() {
          // 拒绝按钮
          Button('拒绝')
            .width('45%')
            .height(50)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .backgroundColor('#F44336')
            .borderRadius(25)
            .onClick(() => {
              this.showHandleConfirm(Constants.RESERVATION_STATUS.REJECTED);
            })
          
          // 通过按钮
          Button('通过')
            .width('45%')
            .height(50)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .backgroundColor('#4CAF50')
            .borderRadius(25)
            .margin({ left: 16 })
            .onClick(() => {
              this.showHandleConfirm(Constants.RESERVATION_STATUS.APPROVED);
            })
        }
        .width('90%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 24, bottom: 24 })
      } else if (this.reservation.status === Constants.RESERVATION_STATUS.APPROVED) {
        Button('取消预约')
          .width('90%')
          .height(50)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .backgroundColor('#F44336')
          .borderRadius(25)
          .margin({ top: 24, bottom: 24 })
          .onClick(() => {
            this.showHandleConfirm(Constants.RESERVATION_STATUS.CANCELLED);
          })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 