import router from '@ohos.router';
import { Constants } from '../../../common/constants/Constants';
import { ToastUtil } from '../../../common/components/ToastUtil';
import { Seat } from '../../../model/StudyRoomModel';
import { StudyRoomService } from '../../../service/StudyRoomService';
import { LoadingDialog } from '../../../common/components/LoadingDialog';
import { ConfirmDialog } from '../../../common/components/ConfirmDialog';

@Entry
@Component
struct SeatManagePage {
  @State seats: Seat[] = [];
  @State isLoading: boolean = false;
  @State roomId: number = 0;
  @State newSeatNumber: string = '';
  @State newRoomId: string = '';
  @State selectedSeatId: number = 0;
  
  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({ message: '加载中...' }),
    autoCancel: false,
    alignment: DialogAlignment.Center
  });
  
  private confirmDeleteDialogController: CustomDialogController = null;
  
  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams();
    if (params && params['roomId']) {
      this.roomId = params['roomId'];
    }
    // 无论是否有roomId参数，都加载座位信息
    this.loadSeats();
  }
  
  /**
   * 加载座位信息
   */
  async loadSeats() {
    if (this.isLoading) return;
    
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      let seats;
      if (this.roomId > 0) {
        // 如果有特定自习室ID，则加载该自习室的座位
        seats = await StudyRoomService.getStudyRoomSeats(this.roomId);
      } else {
        // 否则加载所有座位
        seats = await StudyRoomService.getAllSeats();
      }
      this.seats = seats || [];
    } catch (error) {
      console.error('加载座位信息失败:', error);
      ToastUtil.showError('加载座位信息失败: ' + error.message);
    } finally {
      this.isLoading = false;
      this.loadingDialogController.close();
    }
  }
  
  /**
   * 添加座位
   */
  async addSeat() {
    // 验证输入
    if (!this.newSeatNumber || this.newSeatNumber.trim() === '') {
      ToastUtil.showError('请输入座位号');
      return;
    }
    
    if (!this.newRoomId || this.newRoomId.trim() === '') {
      ToastUtil.showError('请输入自习室ID');
      return;
    }
    
    // 验证自习室ID是否为有效数字
    const roomId = parseInt(this.newRoomId.trim());
    if (isNaN(roomId) || roomId <= 0) {
      ToastUtil.showError('请输入有效的自习室ID');
      return;
    }
    
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      const seat = new Seat();
      seat.roomId = roomId;
      seat.seatNumber = this.newSeatNumber.trim();
      seat.status = Constants.SEAT_STATUS.AVAILABLE;  // 默认状态为可用
      
      const success = await StudyRoomService.addSeat(seat);
      if (success) {
        ToastUtil.showSuccess('添加座位成功');
        this.newSeatNumber = '';  // 清空输入框
        this.loadSeats();  // 重新加载座位列表
      } else {
        ToastUtil.showError('添加座位失败');
      }
    } catch (error) {
      console.error('添加座位失败:', error);
      ToastUtil.showError('添加座位失败: ' + error.message);
    } finally {
      this.isLoading = false;
      this.loadingDialogController.close();
    }
  }
  
  /**
   * 确认删除座位
   * @param seat 座位
   */
  confirmDeleteSeat(seat: Seat) {
    this.selectedSeatId = seat.id;
    
    // 创建确认对话框
    this.confirmDeleteDialogController = new CustomDialogController({
      builder: ConfirmDialog({
        title: '删除座位',
        message: `确定要删除座位 ${seat.seatNumber} 吗？`,
        confirmText: '删除',
        cancelText: '取消',
        onConfirm: () => this.deleteSeat()
      }),
      autoCancel: true,
      alignment: DialogAlignment.Center
    });
    
    this.confirmDeleteDialogController.open();
  }
  
  /**
   * 删除座位
   */
  async deleteSeat() {
    if (!this.selectedSeatId) return;
    
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      const success = await StudyRoomService.deleteSeat(this.selectedSeatId);
      if (success) {
        ToastUtil.showSuccess('删除座位成功');
        this.loadSeats();  // 重新加载座位列表
      } else {
        ToastUtil.showError('删除座位失败');
      }
    } catch (error) {
      console.error('删除座位失败:', error);
      ToastUtil.showError('删除座位失败: ' + error.message);
    } finally {
      this.isLoading = false;
      this.loadingDialogController.close();
      this.selectedSeatId = 0;
    }
  }
  
  /**
   * 获取座位状态文本
   * @param status 状态
   * @returns 状态文本
   */
  getSeatStatusText(status: number): string {
    switch (status) {
      case Constants.SEAT_STATUS.AVAILABLE:
        return '可用';
      case Constants.SEAT_STATUS.RESERVED:
        return '已预约';
      case Constants.SEAT_STATUS.MAINTENANCE:
        return '维护中';
      default:
        return '未知';
    }
  }
  
  /**
   * 获取座位状态颜色
   * @param status 状态
   * @returns 状态颜色
   */
  getSeatStatusColor(status: number): string {
    switch (status) {
      case Constants.SEAT_STATUS.AVAILABLE:
        return '#4CAF50';
      case Constants.SEAT_STATUS.RESERVED:
        return '#FF9800';
      case Constants.SEAT_STATUS.MAINTENANCE:
        return '#F44336';
      default:
        return '#999999';
    }
  }
  
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .margin({ right: 16 })
          .onClick(() => {
            router.back();
          })
        
        Text('座位管理')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        
        Blank()
          .layoutWeight(1)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      
      // 内容区域
      Scroll() {
        Column() {
          // 添加座位区域
          Column() {
            Text('添加座位')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 16 })
            
            Row() {
              TextInput({ placeholder: '请输入自习室ID' })
                .width('48%')
                .height(40)
                .margin({ right: 8 })
                .onChange((value: string) => {
                  this.newRoomId = value;
                })
              
              TextInput({ placeholder: '请输入座位号' })
                .width('48%')
                .height(40)
                .onChange((value: string) => {
                  this.newSeatNumber = value;
                })
            }
            .width('100%')
            .margin({ bottom: 12 })
            
            Button('添加座位')
              .width('100%')
              .height(40)
              .backgroundColor('#007DFF')
              .fontColor('#FFFFFF')
              .onClick(() => {
                this.addSeat();
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .margin({ bottom: 16 })
          
          // 座位列表区域
          Column() {
            Text('座位列表')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 16 })
            
            if (this.isLoading) {
              // 显示加载状态
              Column() {
                LoadingProgress()
                  .width(50)
                  .height(50)
                  .margin({ bottom: 16 })
                
                Text('加载座位信息中...')
                  .fontSize(16)
                  .fontColor('#999999')
              }
              .width('100%')
              .height(200)
              .justifyContent(FlexAlign.Center)
            } else if (this.seats.length > 0) {
              List() {
                ForEach(this.seats, (seat: Seat) => {
                  ListItem() {
                    Row() {
                      Column() {
                        Text(seat?.seatNumber || '未知')
                          .fontSize(16)
                          .fontWeight(FontWeight.Bold)
                        
                        if (!this.roomId && seat?.roomId) {
                          Text(`自习室ID: ${seat.roomId}`)
                            .fontSize(12)
                            .fontColor('#666666')
                            .margin({ top: 4 })
                        }
                      }
                      .alignItems(HorizontalAlign.Start)
                      .margin({ right: 12 })
                      
                      Text(this.getSeatStatusText(seat?.status || 0))
                        .fontSize(14)
                        .fontColor('#FFFFFF')
                        .backgroundColor(this.getSeatStatusColor(seat?.status || 0))
                        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                        .borderRadius(12)
                      
                      Blank()
                        .layoutWeight(1)
                      
                      Button('删除', { type: ButtonType.Capsule })
                        .height(32)
                        .fontSize(14)
                        .fontColor('#FFFFFF')
                        .backgroundColor('#F44336')
                        .onClick(() => {
                          this.confirmDeleteSeat(seat);
                        })
                    }
                    .width('100%')
                    .padding(12)
                    .borderRadius(8)
                    .backgroundColor('#F5F5F5')
                  }
                  .margin({ bottom: 8 })
                }, (seat: Seat) => seat?.id?.toString() || Math.random().toString())
              }
              .width('100%')
            } else {
              Column() {
                Image($r('app.media.empty_data'))
                  .width(80)
                  .height(80)
                  .margin({ bottom: 16 })
                
                Text('暂无座位信息')
                  .fontSize(16)
                  .fontColor('#999999')
              }
              .width('100%')
              .height(200)
              .justifyContent(FlexAlign.Center)
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
        }
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
  }
} 