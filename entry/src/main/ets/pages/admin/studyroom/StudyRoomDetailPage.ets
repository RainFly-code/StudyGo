import router from '@ohos.router';
import { Routes } from '../../../common/constants/Routes';
import { Constants } from '../../../common/constants/Constants';
import { ToastUtil } from '../../../common/components/ToastUtil';
import { Seat, StudyRoom } from '../../../model/StudyRoomModel';
import { StudyRoomService } from '../../../service/StudyRoomService';
import { LoadingDialog } from '../../../common/components/LoadingDialog';
import { ConfirmDialog } from '../../../common/components/ConfirmDialog';

@Entry
@Component
struct StudyRoomDetailPage {
  @State studyRoom: StudyRoom = new StudyRoom();
  @State seats: Seat[] = [];
  @State seatsMap: Map<string, Seat> = new Map();
  @State isLoading: boolean = false;
  @State isLoadingSeats: boolean = false;
  @State seatSelectedId: number = 0;
  @State roomId: number = 0;
  
  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({ message: '加载中...' }),
    autoCancel: false,
    alignment: DialogAlignment.Center
  });
  
  private confirmDeleteDialogController: CustomDialogController = null;
  
  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams();
    if (params && params['id']) {
      this.roomId = params['id'];
      // 先加载自习室详情，然后再加载座位信息
      this.loadStudyRoomDetail()
        .then(() => {
          // 自习室详情加载完成后再加载座位信息
          this.loadStudyRoomSeats();
        })
        .catch(err => {
          console.error('自习室详情加载失败:', err);
        });
    } else {
      ToastUtil.showError('参数错误');
      router.back();
    }
  }
  
  /**
   * 加载自习室详情
   */
  async loadStudyRoomDetail() {
    if (this.isLoading) return;
    
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      const studyRoom = await StudyRoomService.getStudyRoomDetail(this.roomId);
      this.studyRoom = studyRoom;
    } catch (error) {
      console.error('加载自习室详情失败:', error);
      ToastUtil.showError('加载失败: ' + error.message);
      throw error; // 向上层抛出错误，让调用者知道加载失败了
    } finally {
      this.isLoading = false;
      this.loadingDialogController.close();
    }
  }
  
  /**
   * 加载自习室座位信息
   */
  async loadStudyRoomSeats() {
    if (this.isLoadingSeats) return;
    
    this.isLoadingSeats = true;
    
    try {
      console.log('开始加载自习室座位信息，房间ID:', this.roomId);
      const seats = await StudyRoomService.getStudyRoomSeats(this.roomId);
      console.log('获取到座位信息:', seats);
      
      if (seats && Array.isArray(seats)) {
        this.seats = seats;
        
        // 使用新的Map实例而不是清空现有实例
        const newMap = new Map<string, Seat>();
        seats.forEach(seat => {
          try {
            const key = `${seat.row}_${seat.column}`;
            newMap.set(key, seat);
          } catch (e) {
            console.error('处理座位数据时出错:', e, seat);
          }
        });
        
        // 替换原有的Map
        this.seatsMap = newMap;
        
        console.log('座位信息处理完成，数量:', this.seats.length);
      } else {
        console.error('座位数据格式不正确:', seats);
        this.seats = [];
        this.seatsMap = new Map<string, Seat>();
      }
    } catch (error) {
      console.error('加载座位信息失败:', error);
      ToastUtil.showToast('加载座位信息失败');
      this.seats = [];
      this.seatsMap = new Map<string, Seat>();
    } finally {
      this.isLoadingSeats = false;
    }
  }
  
  /**
   * 编辑自习室
   */
  navigateToEdit() {
    router.pushUrl({
      url: Routes.ADMIN_STUDY_ROOM_EDIT,
      params: {
        id: this.roomId
      }
    });
  }
  
  /**
   * 确认删除自习室
   */
  confirmDeleteStudyRoom() {
    // 创建确认对话框
    this.confirmDeleteDialogController = new CustomDialogController({
      builder: ConfirmDialog({
        title: '删除自习室',
        message: `确定要删除自习室"${this.studyRoom.name}"吗？删除后将无法恢复。`,
        confirmText: '删除',
        cancelText: '取消',
        onConfirm: () => this.deleteStudyRoom()
      }),
      autoCancel: true,
      alignment: DialogAlignment.Center
    });
    
    this.confirmDeleteDialogController.open();
  }
  
  /**
   * 删除自习室
   */
  async deleteStudyRoom() {
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      const success = await StudyRoomService.deleteStudyRoom(this.roomId);
      if (success) {
        ToastUtil.showSuccess('删除成功');
        // 返回列表页
        router.back();
      } else {
        ToastUtil.showError('删除失败');
      }
    } catch (error) {
      console.error('删除自习室失败:', error);
      ToastUtil.showError('删除失败: ' + error.message);
    } finally {
      this.isLoading = false;
      this.loadingDialogController.close();
    }
  }
  
  /**
   * 更新自习室状态
   * @param status 状态
   */
  async updateStudyRoomStatus(status: number) {
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      const success = await StudyRoomService.updateStudyRoomStatus(this.roomId, status);
      if (success) {
        ToastUtil.showSuccess('更新状态成功');
        // 刷新页面
        this.loadStudyRoomDetail();
      } else {
        ToastUtil.showError('更新状态失败');
      }
    } catch (error) {
      console.error('更新自习室状态失败:', error);
      ToastUtil.showError('更新状态失败: ' + error.message);
    } finally {
      this.isLoading = false;
      this.loadingDialogController.close();
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
  
  /**
   * 获取状态文本
   * @param status 状态
   * @returns 状态文本
   */
  getStatusText(status: number): string {
    switch (status) {
      case Constants.STUDY_ROOM_STATUS.OPEN:
        return '开放中';
      case Constants.STUDY_ROOM_STATUS.CLOSED:
        return '已关闭';
      case Constants.STUDY_ROOM_STATUS.MAINTENANCE:
        return '维护中';
      default:
        return '未知';
    }
  }
  
  /**
   * 获取状态颜色
   * @param status 状态
   * @returns 状态颜色
   */
  getStatusColor(status: number): string {
    switch (status) {
      case Constants.STUDY_ROOM_STATUS.OPEN:
        return '#4CAF50';
      case Constants.STUDY_ROOM_STATUS.CLOSED:
        return '#F44336';
      case Constants.STUDY_ROOM_STATUS.MAINTENANCE:
        return '#FF9800';
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
        
        Text('自习室详情')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        
        Blank()
          .layoutWeight(1)
        
        Button('编辑', { type: ButtonType.Capsule })
          .height(32)
          .fontSize(14)
          .margin({ right: 8 })
          .onClick(() => {
            this.navigateToEdit();
          })
        
        Button('删除', { type: ButtonType.Capsule })
          .height(32)
          .fontSize(14)
          .onClick(() => {
            this.confirmDeleteStudyRoom();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      
      // 内容区域
      Scroll() {
        Column() {
          // 基本信息区域
          Column() {
            // 顶部信息
            Row() {
              Column() {
                Text(this.studyRoom.name)
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#333333')
                
                Text(this.studyRoom.location)
                  .fontSize(16)
                  .fontColor('#666666')
                  .margin({ top: 8 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              
              Text(this.getStatusText(this.studyRoom.status))
                .fontSize(14)
                .fontColor(this.getStatusColor(this.studyRoom.status))
                .backgroundColor(this.getStatusColor(this.studyRoom.status) + '15')
                .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                .borderRadius(16)
            }
            .width('100%')
            .padding({ top: 16, bottom: 16 })
            
            // 详细信息
            Column() {
              Row() {
                Text('开放时间')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(80)
                
                Text(`${this.studyRoom.openTime || '--'} - ${this.studyRoom.closeTime || '--'}`)
                  .fontSize(14)
                  .fontColor('#333333')
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 12 })
              
              Row() {
                Text('座位数量')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(80)
                
                Text(`${this.studyRoom.capacity || 0}`)
                  .fontSize(14)
                  .fontColor('#333333')
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 12 })
              
              Row() {
                Text('创建时间')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(80)
                
                Text(`${this.studyRoom.createTime || '--'}`)
                  .fontSize(14)
                  .fontColor('#333333')
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 12 })
              
              Row() {
                Text('更新时间')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(80)
                
                Text(`${this.studyRoom.updateTime || '--'}`)
                  .fontSize(14)
                  .fontColor('#333333')
                  .layoutWeight(1)
              }
              .width('100%')
              .margin({ bottom: 12 })
              
              Row() {
                Text('详细描述')
                  .fontSize(14)
                  .fontColor('#666666')
                  .width(80)
                
                Text(`${this.studyRoom.description || '暂无描述'}`)
                  .fontSize(14)
                  .fontColor('#333333')
                  .layoutWeight(1)
              }
              .width('100%')
              .alignItems(VerticalAlign.Top)
              .margin({ bottom: 12 })
            }
            .width('100%')
            .padding({ top: 16, bottom: 16 })
            .borderWidth({ top: 0.5, bottom: 0.5 })
            .borderColor('#EEEEEE')
            
            // 操作按钮
            Row() {
              Text('管理操作')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
              
              Blank()
                .layoutWeight(1)
              
              if (this.studyRoom.status !== Constants.STUDY_ROOM_STATUS.OPEN) {
                Button('开放', { type: ButtonType.Capsule })
                  .height(32)
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#4CAF50')
                  .margin({ left: 8 })
                  .onClick(() => {
                    this.updateStudyRoomStatus(Constants.STUDY_ROOM_STATUS.OPEN);
                  })
              }
              
              if (this.studyRoom.status !== Constants.STUDY_ROOM_STATUS.CLOSED) {
                Button('关闭', { type: ButtonType.Capsule })
                  .height(32)
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#F44336')
                  .margin({ left: 8 })
                  .onClick(() => {
                    this.updateStudyRoomStatus(Constants.STUDY_ROOM_STATUS.CLOSED);
                  })
              }
              
              if (this.studyRoom.status !== Constants.STUDY_ROOM_STATUS.MAINTENANCE) {
                Button('维护', { type: ButtonType.Capsule })
                  .height(32)
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#FF9800')
                  .margin({ left: 8 })
                  .onClick(() => {
                    this.updateStudyRoomStatus(Constants.STUDY_ROOM_STATUS.MAINTENANCE);
                  })
              }
            }
            .width('100%')
            .padding({ top: 16, bottom: 16 })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .margin({ bottom: 16 })
          
          // 座位管理区域
          Column() {
            Row() {
              Text('座位展示')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
              
              Blank()
                .layoutWeight(1)
            }
            .width('100%')
            .padding({ top: 16, bottom: 16 })
            
            if (this.isLoadingSeats) {
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
              Grid() {
                ForEach(this.seats, (seat: Seat) => {
                  GridItem() {
                    Column() {
                      Text(seat?.seatNumber || '未知')
                        .fontSize(14)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#FFFFFF')
                      
                      Text(this.getSeatStatusText(seat?.status || 0))
                        .fontSize(12)
                        .fontColor('#FFFFFF')
                        .margin({ top: 4 })
                    }
                    .width('100%')
                    .height('30%')
                    .justifyContent(FlexAlign.Center)
                    .backgroundColor(this.getSeatStatusColor(seat?.status || 0))
                    .borderRadius(8)
                  }
                }, (seat: Seat) => seat?.id?.toString() || Math.random().toString())
              }
              .columnsTemplate('1fr 1fr 1fr 1fr')
              .columnsGap(10)
              .rowsGap(10)
              .width('100%')
              .height(300)
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