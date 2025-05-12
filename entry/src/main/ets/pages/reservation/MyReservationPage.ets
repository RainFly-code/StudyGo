import router from '@ohos.router';
import { Routes } from '../../common/constants/Routes';
import { Constants } from '../../common/constants/Constants';
import { ToastUtil } from '../../common/components/ToastUtil';
import { LoadingDialog } from '../../common/components/LoadingDialog';
import { ConfirmDialog } from '../../common/components/ConfirmDialog';
import { Reservation } from '../../model/StudyRoomModel';
import { ReservationService } from '../../service/ReservationService';

@Entry
@Component
struct MyReservationPage {
  @State reservations: Reservation[] = [];
  @State isLoading: boolean = false;
  @State isEmpty: boolean = false;
  filterStatus: number | undefined = undefined;
  private currentStatus: number | undefined = undefined;
  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({ message: '加载中...' }),
    alignment: DialogAlignment.Center,
    autoCancel: false,
    customStyle: true
  });
  
  private confirmDialogController: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      title: '取消预约',
      message: '确定要取消该预约吗？',
      onConfirm: () => {}
    }),
    autoCancel: true,
    customStyle: true
  });
  
  aboutToAppear() {
    console.info('【MyReservationPage】页面即将显示，当前筛选状态:', this.filterStatus !== undefined ? this.filterStatus : '全部');
    this.loadReservations();
  }
  
  /**
   * 加载预约列表
   */
  async loadReservations() {
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      console.info('【MyReservationPage】loadReservations - 当前筛选状态值:', this.filterStatus, 
                   '类型:', typeof this.filterStatus, 
                   '显示:', this.filterStatus !== undefined ? this.filterStatus : '全部');
      
      const result = await ReservationService.getUserReservations(1, 100, this.filterStatus);
      
      this.reservations = result.records || [];
      
      // 处理后端可能返回date字段的情况
      this.reservations.forEach(reservation => {
        if (reservation.date && (!reservation.startDate || !reservation.endDate)) {
          reservation.startDate = reservation.date;
          
          // 计算结束日期
          if (reservation.days > 1) {
            try {
              const startDate = new Date(reservation.date);
              const endDate = new Date(startDate);
              endDate.setDate(startDate.getDate() + reservation.days - 1);
              
              const year = endDate.getFullYear();
              const month = String(endDate.getMonth() + 1).padStart(2, '0');
              const day = String(endDate.getDate()).padStart(2, '0');
              reservation.endDate = `${year}-${month}-${day}`;
            } catch (error) {
              console.error('计算结束日期失败:', error);
              reservation.endDate = reservation.date;
            }
          } else {
            reservation.endDate = reservation.date;
          }
        }
      });
      
      this.isEmpty = this.reservations.length === 0;
      
      // 调试日期信息和筛选结果
      console.info('筛选状态:', this.filterStatus !== undefined ? this.filterStatus : '全部', 
                   '返回记录数:', this.reservations.length);
      
      if (this.reservations.length > 0) {
        console.info('第一条预约日期:', 
          '原始日期字段:', this.reservations[0].date,
          '开始日期:', this.reservations[0].startDate,
          '格式化后:', this.formatDate(this.reservations[0].startDate),
          '结束日期:', this.reservations[0].endDate,
          '格式化后:', this.formatDate(this.reservations[0].endDate),
          '预约状态:', this.reservations[0].status
        );
      }
      
      console.info('预约列表:', JSON.stringify(this.reservations));
    } catch (error) {
      console.error('获取预约列表失败:', error);
      ToastUtil.showError('获取预约列表失败: ' + error.message);
    } finally {
      this.isLoading = false;
      this.loadingDialogController.close();
    }
  }
  
  /**
   * 设置筛选状态并重新加载
   */
  setStatus(status: number | undefined) {
    console.info('【MyReservationPage】开始设置筛选状态, 原状态:', this.filterStatus !== undefined ? this.filterStatus : '全部', 
                 '新状态:', status !== undefined ? status : '全部');
    
    this.filterStatus = status;
    
    console.info('【MyReservationPage】状态已设置, 当前状态:', this.filterStatus !== undefined ? this.filterStatus : '全部');
    
    // 检查status是否为0的特殊情况
    if (status === 0) {
      console.info('【MyReservationPage】检测到状态为0（待审核），特别处理');
    }
    
    this.loadReservations();
  }
  
  /**
   * 确认取消预约
   */
  showCancelConfirm(reservation: Reservation) {
    this.confirmDialogController = new CustomDialogController({
      builder: ConfirmDialog({
        title: '取消预约',
        message: '确定要取消该预约吗？',
        onConfirm: async () => {
          await this.cancelReservation(reservation.id);
        }
      }),
      autoCancel: true,
      customStyle: true
    });
    
    this.confirmDialogController.open();
  }
  
  /**
   * 取消预约
   */
  async cancelReservation(id: number) {
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      const result = await ReservationService.cancelReservation(id);
      
      if (result) {
        ToastUtil.showSuccess('预约已取消');
        // 重新加载预约列表
        this.loadReservations();
      } else {
        ToastUtil.showError('取消预约失败');
      }
    } catch (error) {
      console.error('取消预约失败:', error);
      ToastUtil.showError('取消预约失败: ' + error.message);
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
   * 跳转到预约详情
   */
  navigateToDetail(reservation: Reservation) {
    router.pushUrl({
      url: Routes.RESERVATION_DETAIL,
      params: {
        id: reservation.id
      }
    });
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
        
        Text('我的预约')
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
      
      // 状态筛选栏
      Row() {
        Row() {
          Text('全部')
            .fontSize(14)
            .fontColor(this.filterStatus === undefined ? '#007DFF' : '#666666')
            .fontWeight(this.filterStatus === undefined ? FontWeight.Medium : FontWeight.Normal)
            .onClick(() => {
              this.setStatus(undefined);
            })
        }
        .backgroundColor(this.filterStatus === undefined ? '#E6F1FF' : '#F5F5F5')
        .borderRadius(16)
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .margin({ right: 8 })
        
        Row() {
          Text('待审核')
            .fontSize(14)
            .fontColor(this.filterStatus === Constants.RESERVATION_STATUS.PENDING ? '#007DFF' : '#666666')
            .fontWeight(this.filterStatus === Constants.RESERVATION_STATUS.PENDING ? FontWeight.Medium : FontWeight.Normal)
            .onClick(() => {
              this.setStatus(Constants.RESERVATION_STATUS.PENDING);
            })
        }
        .backgroundColor(this.filterStatus === Constants.RESERVATION_STATUS.PENDING ? '#E6F1FF' : '#F5F5F5')
        .borderRadius(16)
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .margin({ right: 8 })
        
        Row() {
          Text('已通过')
            .fontSize(14)
            .fontColor(this.filterStatus === Constants.RESERVATION_STATUS.APPROVED ? '#007DFF' : '#666666')
            .fontWeight(this.filterStatus === Constants.RESERVATION_STATUS.APPROVED ? FontWeight.Medium : FontWeight.Normal)
            .onClick(() => {
              this.setStatus(Constants.RESERVATION_STATUS.APPROVED);
            })
        }
        .backgroundColor(this.filterStatus === Constants.RESERVATION_STATUS.APPROVED ? '#E6F1FF' : '#F5F5F5')
        .borderRadius(16)
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .margin({ right: 8 })
        
        Row() {
          Text('已拒绝')
            .fontSize(14)
            .fontColor(this.filterStatus === Constants.RESERVATION_STATUS.REJECTED ? '#007DFF' : '#666666')
            .fontWeight(this.filterStatus === Constants.RESERVATION_STATUS.REJECTED ? FontWeight.Medium : FontWeight.Normal)
            .onClick(() => {
              this.setStatus(Constants.RESERVATION_STATUS.REJECTED);
            })
        }
        .backgroundColor(this.filterStatus === Constants.RESERVATION_STATUS.REJECTED ? '#E6F1FF' : '#F5F5F5')
        .borderRadius(16)
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF')
      .margin({ top: 1 })
      
      // 预约列表
      if (this.isEmpty) {
        Column() {
          Image($r('app.media.empty_data'))
            .width(120)
            .height(120)
            .margin({ top: 80 })
          
          Text('暂无预约记录')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
      } else {
        List() {
          ForEach(this.reservations, (reservation: Reservation) => {
            ListItem() {
              Column() {
                // 自习室和座位信息
                Row() {
                  Text(reservation.roomName)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#333333')
                  
                  Text(`座位号: ${reservation.seatNumber}`)
                    .fontSize(14)
                    .fontColor('#666666')
                    .margin({ left: 12 })
                  
                  Blank()
                    .layoutWeight(1)
                  
                  Text(this.getStatusInfo(reservation.status).text)
                    .fontSize(14)
                    .fontColor(this.getStatusInfo(reservation.status).color)
                }
                .width('100%')
                
                // 预约时间信息
                Row() {
                  Text(`预约日期: ${this.formatDate(reservation.startDate)} - ${this.formatDate(reservation.endDate)}`)
                    .fontSize(14)
                    .fontColor('#666666')
                  
                  Text(`共${reservation.days}天`)
                    .fontSize(14)
                    .fontColor('#666666')
                    .margin({ left: 8 })
                }
                .width('100%')
                .margin({ top: 8 })
                
                // 申请时间
                Row() {
                  Text(`申请时间: ${reservation.createTime}`)
                    .fontSize(12)
                    .fontColor('#999999')
                }
                .width('100%')
                .margin({ top: 8 })
                
                // 操作按钮
                if (reservation.status === Constants.RESERVATION_STATUS.PENDING) {
                  Row() {
                    // 取消预约按钮
                    Button('取消预约')
                      .height(36)
                      .fontSize(14)
                      .fontColor('#F44336')
                      .backgroundColor(Color.Transparent)
                      .fontWeight(FontWeight.Medium)
                      .borderWidth(1)
                      .borderColor('#F44336')
                      .borderRadius(18)
                      .onClick(() => {
                        this.showCancelConfirm(reservation);
                      })
                    
                    // 查看详情按钮
                    Button('查看详情')
                      .height(36)
                      .fontSize(14)
                      .fontColor('#007DFF')
                      .backgroundColor(Color.Transparent)
                      .fontWeight(FontWeight.Medium)
                      .borderWidth(1)
                      .borderColor('#007DFF')
                      .borderRadius(18)
                      .margin({ left: 16 })
                      .onClick(() => {
                        this.navigateToDetail(reservation);
                      })
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.End)
                  .margin({ top: 12 })
                } else {
                  // 只有查看详情按钮
                  Row() {
                    Button('查看详情')
                      .height(36)
                      .fontSize(14)
                      .fontColor('#007DFF')
                      .backgroundColor(Color.Transparent)
                      .fontWeight(FontWeight.Medium)
                      .borderWidth(1)
                      .borderColor('#007DFF')
                      .borderRadius(18)
                      .onClick(() => {
                        this.navigateToDetail(reservation);
                      })
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.End)
                  .margin({ top: 12 })
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(8)
              .onClick(() => {
                this.navigateToDetail(reservation);
              })
            }
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          }, reservation => reservation.id?.toString())
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 