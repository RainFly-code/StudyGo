import router from '@ohos.router';
import { Routes } from '../../../common/constants/Routes';
import { Constants } from '../../../common/constants/Constants';
import { ToastUtil } from '../../../common/components/ToastUtil';
import { LoadingDialog } from '../../../common/components/LoadingDialog';
import { ConfirmDialog } from '../../../common/components/ConfirmDialog';
import { DatePickerDialog } from '../../../common/components/DatePickerDialog';
import { Reservation } from '../../../model/StudyRoomModel';
import { ReservationService } from '../../../service/ReservationService';

@Entry
@Component
struct AdminReservationListPage {
  @State reservations: Reservation[] = [];
  @State isLoading: boolean = false;
  @State isEmpty: boolean = false;
  @State currentPage: number = 1;
  @State pageSize: number = 10;
  @State total: number = 0;
  
  // 筛选条件
  @State currentStatus: number | undefined = undefined;
  @State userId: number | undefined = undefined;
  @State roomId: number | undefined = undefined;
  @State startDate: string | undefined = undefined;
  @State endDate: string | undefined = undefined;
  
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
  
  private startDatePickerController: CustomDialogController = new CustomDialogController({
    builder: DatePickerDialog({
      selectedDate: this.startDate || '',
      onConfirm: (date: string) => {
        this.startDate = date;
      }
    }),
    autoCancel: true,
    customStyle: true
  });
  
  private endDatePickerController: CustomDialogController = new CustomDialogController({
    builder: DatePickerDialog({
      selectedDate: this.endDate || '',
      onConfirm: (date: string) => {
        this.endDate = date;
      }
    }),
    autoCancel: true,
    customStyle: true
  });
  
  aboutToAppear() {
    this.loadReservations();
  }
  
  /**
   * 加载预约列表
   */
  async loadReservations() {
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      const result = await ReservationService.getReservationList(
        this.currentPage,
        this.pageSize,
        this.userId,
        this.roomId,
        this.currentStatus,
        this.startDate,
        this.endDate
      );
      
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
      
      this.total = result.total || 0;
      this.isEmpty = this.reservations.length === 0;
      
      // 调试日期信息
      if (this.reservations.length > 0) {
        console.info('第一条预约日期:', 
          '原始日期字段:', this.reservations[0].date,
          '开始日期:', this.reservations[0].startDate,
          '格式化后:', this.formatDate(this.reservations[0].startDate),
          '结束日期:', this.reservations[0].endDate,
          '格式化后:', this.formatDate(this.reservations[0].endDate)
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
   * 重置筛选条件
   */
  resetFilters() {
    this.currentStatus = undefined;
    this.userId = undefined;
    this.roomId = undefined;
    this.startDate = undefined;
    this.endDate = undefined;
    this.currentPage = 1;
    this.loadReservations();
  }
  
  /**
   * 确认处理预约
   */
  showHandleConfirm(reservation: Reservation, status: number) {
    let title = '';
    let content = '';
    
    switch (status) {
      case Constants.RESERVATION_STATUS.APPROVED:
        title = '通过预约';
        content = `确定要通过 用户ID: ${reservation.userId} 的预约申请吗？`;
        break;
      case Constants.RESERVATION_STATUS.REJECTED:
        title = '拒绝预约';
        content = `确定要拒绝 用户ID: ${reservation.userId} 的预约申请吗？`;
        break;
      case Constants.RESERVATION_STATUS.CANCELLED:
        title = '取消预约';
        content = `确定要取消 用户ID: ${reservation.userId} 的预约吗？`;
        break;
    }
    
    this.confirmDialogController = new CustomDialogController({
      builder: ConfirmDialog({
        title: title,
        message: content,
        onConfirm: async () => {
          await this.handleReservation(reservation.id, status);
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
  async handleReservation(id: number, status: number) {
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      const result = await ReservationService.handleReservation(id, status);
      
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
        // 重新加载预约列表
        this.loadReservations();
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
   * 显示开始日期选择器
   */
  showStartDatePicker() {
    this.startDatePickerController = new CustomDialogController({
      builder: DatePickerDialog({
        selectedDate: this.startDate || '',
        onConfirm: (date: string) => {
          this.startDate = date;
        }
      }),
      autoCancel: true,
      customStyle: true
    });
    
    this.startDatePickerController.open();
  }
  
  /**
   * 显示结束日期选择器
   */
  showEndDatePicker() {
    this.endDatePickerController = new CustomDialogController({
      builder: DatePickerDialog({
        selectedDate: this.endDate || '',
        onConfirm: (date: string) => {
          this.endDate = date;
        }
      }),
      autoCancel: true,
      customStyle: true
    });
    
    this.endDatePickerController.open();
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
      url: Routes.ADMIN_RESERVATION_DETAIL,
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
        
        Text('预约管理')
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
      
      // 筛选条件
      Column() {
        // 状态筛选
        Row() {
          Text('状态:')
            .fontSize(14)
            .fontColor('#666666')
            .width(50)
          
          Row() {
            Text('全部')
              .fontSize(14)
              .fontColor(this.currentStatus === undefined ? '#007DFF' : '#666666')
              .fontWeight(this.currentStatus === undefined ? FontWeight.Medium : FontWeight.Normal)
              .onClick(() => {
                this.currentStatus = undefined;
              })
          }
          .backgroundColor(this.currentStatus === undefined ? '#E6F1FF' : '#F5F5F5')
          .borderRadius(16)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .margin({ right: 8 })
          
          Row() {
            Text('待审核')
              .fontSize(14)
              .fontColor(this.currentStatus === Constants.RESERVATION_STATUS.PENDING ? '#007DFF' : '#666666')
              .fontWeight(this.currentStatus === Constants.RESERVATION_STATUS.PENDING ? FontWeight.Medium : FontWeight.Normal)
              .onClick(() => {
                this.currentStatus = Constants.RESERVATION_STATUS.PENDING;
              })
          }
          .backgroundColor(this.currentStatus === Constants.RESERVATION_STATUS.PENDING ? '#E6F1FF' : '#F5F5F5')
          .borderRadius(16)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .margin({ right: 8 })
          
          Row() {
            Text('已通过')
              .fontSize(14)
              .fontColor(this.currentStatus === Constants.RESERVATION_STATUS.APPROVED ? '#007DFF' : '#666666')
              .fontWeight(this.currentStatus === Constants.RESERVATION_STATUS.APPROVED ? FontWeight.Medium : FontWeight.Normal)
              .onClick(() => {
                this.currentStatus = Constants.RESERVATION_STATUS.APPROVED;
              })
          }
          .backgroundColor(this.currentStatus === Constants.RESERVATION_STATUS.APPROVED ? '#E6F1FF' : '#F5F5F5')
          .borderRadius(16)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .margin({ right: 8 })
          
          Row() {
            Text('已拒绝')
              .fontSize(14)
              .fontColor(this.currentStatus === Constants.RESERVATION_STATUS.REJECTED ? '#007DFF' : '#666666')
              .fontWeight(this.currentStatus === Constants.RESERVATION_STATUS.REJECTED ? FontWeight.Medium : FontWeight.Normal)
              .onClick(() => {
                this.currentStatus = Constants.RESERVATION_STATUS.REJECTED;
              })
          }
          .backgroundColor(this.currentStatus === Constants.RESERVATION_STATUS.REJECTED ? '#E6F1FF' : '#F5F5F5')
          .borderRadius(16)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .margin({ right: 8 })
          
          Row() {
            Text('已取消')
              .fontSize(14)
              .fontColor(this.currentStatus === Constants.RESERVATION_STATUS.CANCELLED ? '#007DFF' : '#666666')
              .fontWeight(this.currentStatus === Constants.RESERVATION_STATUS.CANCELLED ? FontWeight.Medium : FontWeight.Normal)
              .onClick(() => {
                this.currentStatus = Constants.RESERVATION_STATUS.CANCELLED;
              })
          }
          .backgroundColor(this.currentStatus === Constants.RESERVATION_STATUS.CANCELLED ? '#E6F1FF' : '#F5F5F5')
          .borderRadius(16)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        }
        .width('100%')
        .margin({ top: 8 })
        
        // 日期筛选
        Row() {
          Text('日期:')
            .fontSize(14)
            .fontColor('#666666')
            .width(50)
          
          // 开始日期
          Row() {
            Text(this.startDate || '开始日期')
              .fontSize(14)
              .fontColor(this.startDate ? '#333333' : '#999999')
            
            Image($r('app.media.ic_calendar'))
              .width(16)
              .height(16)
              .margin({ left: 4 })
          }
          .height(32)
          .backgroundColor('#F5F5F5')
          .borderRadius(16)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.showStartDatePicker();
          })
          
          Text('至')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ left: 8, right: 8 })
          
          // 结束日期
          Row() {
            Text(this.endDate || '结束日期')
              .fontSize(14)
              .fontColor(this.endDate ? '#333333' : '#999999')
            
            Image($r('app.media.ic_calendar'))
              .width(16)
              .height(16)
              .margin({ left: 4 })
          }
          .height(32)
          .backgroundColor('#F5F5F5')
          .borderRadius(16)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.showEndDatePicker();
          })
        }
        .width('100%')
        .margin({ top: 12 })
        
        // 操作按钮
        Row() {
          Button('重置')
            .height(36)
            .fontSize(14)
            .fontColor('#666666')
            .backgroundColor('#F5F5F5')
            .fontWeight(FontWeight.Medium)
            .borderRadius(18)
            .margin({ right: 16 })
            .onClick(() => {
              this.resetFilters();
            })
          
          Button('搜索')
            .height(36)
            .fontSize(14)
            .fontColor(Color.White)
            .backgroundColor('#007DFF')
            .fontWeight(FontWeight.Medium)
            .borderRadius(18)
            .onClick(() => {
              this.currentPage = 1;
              this.loadReservations();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
        .margin({ top: 16 })
      }
      .width('100%')
      .padding(16)
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
                // 用户信息
                Row() {
                  Text(`用户ID: ${reservation.userId}`)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#333333')
                  
                  Blank()
                    .layoutWeight(1)
                  
                  Text(this.getStatusInfo(reservation.status).text)
                    .fontSize(14)
                    .fontColor(this.getStatusInfo(reservation.status).color)
                }
                .width('100%')
                
                // 自习室和座位信息
                Row() {
                  Text(`自习室: ${reservation.roomName}`)
                    .fontSize(14)
                    .fontColor('#666666')
                  
                  Text(`座位号: ${reservation.seatNumber}`)
                    .fontSize(14)
                    .fontColor('#666666')
                    .margin({ left: 12 })
                }
                .width('100%')
                .margin({ top: 8 })
                
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
                    // 拒绝按钮
                    Button('拒绝')
                      .height(36)
                      .fontSize(14)
                      .fontColor('#F44336')
                      .backgroundColor(Color.Transparent)
                      .fontWeight(FontWeight.Medium)
                      .borderWidth(1)
                      .borderColor('#F44336')
                      .borderRadius(18)
                      .onClick(() => {
                        this.showHandleConfirm(reservation, Constants.RESERVATION_STATUS.REJECTED);
                      })
                    
                    // 通过按钮
                    Button('通过')
                      .height(36)
                      .fontSize(14)
                      .fontColor('#4CAF50')
                      .backgroundColor(Color.Transparent)
                      .fontWeight(FontWeight.Medium)
                      .borderWidth(1)
                      .borderColor('#4CAF50')
                      .borderRadius(18)
                      .margin({ left: 12 })
                      .onClick(() => {
                        this.showHandleConfirm(reservation, Constants.RESERVATION_STATUS.APPROVED);
                      })
                    
                    // 查看详情按钮
                    Button('详情')
                      .height(36)
                      .fontSize(14)
                      .fontColor('#007DFF')
                      .backgroundColor(Color.Transparent)
                      .fontWeight(FontWeight.Medium)
                      .borderWidth(1)
                      .borderColor('#007DFF')
                      .borderRadius(18)
                      .margin({ left: 12 })
                      .onClick(() => {
                        this.navigateToDetail(reservation);
                      })
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.End)
                  .margin({ top: 12 })
                } else if (reservation.status === Constants.RESERVATION_STATUS.APPROVED) {
                  Row() {
                    // 取消按钮
                    Button('取消')
                      .height(36)
                      .fontSize(14)
                      .fontColor('#F44336')
                      .backgroundColor(Color.Transparent)
                      .fontWeight(FontWeight.Medium)
                      .borderWidth(1)
                      .borderColor('#F44336')
                      .borderRadius(18)
                      .onClick(() => {
                        this.showHandleConfirm(reservation, Constants.RESERVATION_STATUS.CANCELLED);
                      })
                    
                    // 查看详情按钮
                    Button('详情')
                      .height(36)
                      .fontSize(14)
                      .fontColor('#007DFF')
                      .backgroundColor(Color.Transparent)
                      .fontWeight(FontWeight.Medium)
                      .borderWidth(1)
                      .borderColor('#007DFF')
                      .borderRadius(18)
                      .margin({ left: 12 })
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
                    Button('详情')
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
            }
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          }, reservation => reservation.id?.toString())
        }
        .width('100%')
        .layoutWeight(1)
        
        // 分页控制
        Row() {
          Button('上一页')
            .fontSize(14)
            .fontColor(this.currentPage > 1 ? '#007DFF' : '#999999')
            .backgroundColor(Color.Transparent)
            .enabled(this.currentPage > 1)
            .onClick(() => {
              if (this.currentPage > 1) {
                this.currentPage--;
                this.loadReservations();
              }
            })
          
          Text(`${this.currentPage}/${Math.ceil(this.total / this.pageSize) || 1}`)
            .fontSize(14)
            .fontColor('#666666')
            .margin({ left: 16, right: 16 })
          
          Button('下一页')
            .fontSize(14)
            .fontColor(this.currentPage < Math.ceil(this.total / this.pageSize) ? '#007DFF' : '#999999')
            .backgroundColor(Color.Transparent)
            .enabled(this.currentPage < Math.ceil(this.total / this.pageSize))
            .onClick(() => {
              if (this.currentPage < Math.ceil(this.total / this.pageSize)) {
                this.currentPage++;
                this.loadReservations();
              }
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ top: 16, bottom: 16 })
        .backgroundColor('#FFFFFF')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 