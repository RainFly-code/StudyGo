import router from '@ohos.router';
import { Routes } from '../../common/constants/Routes';
import { Constants } from '../../common/constants/Constants';
import { ToastUtil } from '../../common/components/ToastUtil';
import { Seat, StudyRoom } from '../../model/StudyRoomModel';
import { StudyRoomService } from '../../service/StudyRoomService';
import { LoadingDialog } from '../../common/components/LoadingDialog';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct StudyRoomDetailPage {
  @State studyRoom: StudyRoom = new StudyRoom();
  @State seats: Seat[] = [];
  @State isLoading: boolean = false;
  @State maxRow: number = 0;
  @State maxCol: number = 0;
  @State selectedSeat: Seat | null = null;
  
  private roomId: number = router.getParams()?.['id'] || 0;
  private gridSize: number = 60; // 增大座位格子大小
  private gridGap: number = 15; // 增大座位间距
  private seatCache: Map<string, Seat> = new Map(); // 座位缓存
  
  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({ message: '加载中...' }),
    alignment: DialogAlignment.Center,
    autoCancel: false,
    customStyle: true
  });
  
  aboutToAppear() {
    console.log('StudyRoomDetailPage aboutToAppear, roomId:', this.roomId);
    // 加载自习室详情
    this.loadStudyRoomDetail().then(() => {
      // 加载座位信息
      console.log('开始加载座位信息');
      this.loadSeats();
    }).catch(error => {
      console.error('加载自习室详情失败:', error);
    });
  }
  
  /**
   * 加载自习室详情
   */
  async loadStudyRoomDetail() {
    if (this.isLoading) return;
    
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      console.log('开始加载自习室详情，roomId:', this.roomId);
      const studyRoom = await StudyRoomService.getStudyRoomDetail(this.roomId);
      console.log('自习室详情响应:', studyRoom);
      
      if (studyRoom) {
        this.studyRoom = studyRoom;
      } else {
        ToastUtil.showError('获取自习室详情失败');
        setTimeout(() => {
          router.back();
        }, 1500);
      }
    } catch (error) {
      console.error('加载自习室详情失败:', error);
      ToastUtil.showError('加载自习室详情失败');
      throw error; // 抛出错误以便在aboutToAppear中捕获
    } finally {
      this.isLoading = false;
      this.loadingDialogController.close();
    }
  }
  
  /**
   * 加载座位信息
   */
  async loadSeats() {
    if (this.isLoading) return;
    
    this.isLoading = true;
    this.loadingDialogController.open();
    this.seatCache.clear(); // 清空缓存
    
    try {
      console.log('开始加载座位信息，roomId:', this.roomId);
      const seats = await StudyRoomService.getStudyRoomSeats(this.roomId);
      console.log('座位信息响应:', seats);
      
      if (seats && Array.isArray(seats)) {
        // 计算合适的行列数
        const totalSeats = seats.length;
        // 每排6个座位
        const seatsPerRow = 6;
        const rows = Math.ceil(totalSeats / seatsPerRow);
        
        console.log('座位总数:', totalSeats, '每排座位数:', seatsPerRow, '总排数:', rows);
        
        // 为每个座位分配位置
        const validSeats = seats.map((seat, index) => {
          const row = Math.floor(index / seatsPerRow) + 1;
          const column = (index % seatsPerRow) + 1;
          console.log('分配位置:', { seatNumber: seat.seatNumber, row, column });
          return {
            ...seat,
            row,
            column
          };
        });
        
        this.seats = validSeats;
        this.maxRow = rows;
        this.maxCol = seatsPerRow;
        
        console.log('最大行:', this.maxRow, '最大列:', this.maxCol);
        
        // 打印座位布局
        const layout = new Array(this.maxRow).fill(0).map(() => new Array(this.maxCol).fill(0));
        validSeats.forEach(seat => {
          layout[seat.row - 1][seat.column - 1] = seat.seatNumber;
        });
        console.log('座位布局:', layout);
      } else {
        console.error('座位信息格式错误:', seats);
        ToastUtil.showError('座位信息格式错误');
      }
    } catch (error) {
      console.error('加载座位信息失败:', error);
      if (error.message.includes('Network')) {
        ToastUtil.showError('网络连接失败，请检查网络设置');
      } else if (error.message.includes('404')) {
        ToastUtil.showError('自习室不存在');
      } else if (error.message.includes('500')) {
        ToastUtil.showError('服务器错误，请稍后重试');
      } else if (error.message.includes('座位布局数据无效')) {
        ToastUtil.showError('座位布局数据无效，请联系管理员');
      } else {
        ToastUtil.showError('加载座位信息失败: ' + error.message);
      }
    } finally {
      this.isLoading = false;
      this.loadingDialogController.close();
    }
  }
  
  /**
   * 获取座位状态颜色
   */
  getSeatColor(status: number): string {
    switch (status) {
      case Constants.SEAT_STATUS.AVAILABLE:
        return '#4CAF50';
      case Constants.SEAT_STATUS.RESERVED:
        return '#FF5722';
      case Constants.SEAT_STATUS.MAINTENANCE:
        return '#9E9E9E';
      default:
        return '#CCCCCC';
    }
  }
  
  /**
   * 获取座位状态文本
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
        return '未知状态';
    }
  }
  
  /**
   * 选择座位
   */
  selectSeat(seat: Seat) {
    if (seat.status !== Constants.SEAT_STATUS.AVAILABLE) {
      ToastUtil.showWarning('该座位不可用');
      return;
    }
    
    this.selectedSeat = seat;
    
    // 询问是否预约该座位
    promptAction.showDialog({
      title: '预约座位',
      message: `确认预约${this.studyRoom.name} ${seat.seatNumber}号座位吗？`,
      buttons: [
        {
          text: '取消',
          color: '#666666'
        },
        {
          text: '去预约',
          color: '#007DFF'
        }
      ]
    }).then(result => {
      if (result.index === 1) {
        // 跳转到预约页面
        router.pushUrl({
          url: Routes.SEAT_RESERVATION,
          params: {
            roomId: this.roomId,
            roomName: this.studyRoom.name,
            seatId: seat.id,
            seatNumber: seat.seatNumber
          }
        });
      }
    }).catch(err => {
      console.error('对话框显示失败', err);
    });
  }
  
  /**
   * 查找指定位置的座位
   */
  findSeat(row: number, col: number): Seat | null {
    const key = `${row}-${col}`;
    if (this.seatCache.has(key)) {
      return this.seatCache.get(key);
    }
    
    const seat = this.seats.find(seat => seat.row === row && seat.column === col);
    if (seat) {
      this.seatCache.set(key, seat);
    }
    return seat || null;
  }
  
  /**
   * 获取自习室状态文本
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
        return '未知状态';
    }
  }
  
  /**
   * 获取状态颜色
   */
  getStatusColor(status: number): string {
    switch (status) {
      case Constants.STUDY_ROOM_STATUS.OPEN:
        return '#1A7F4B';
      case Constants.STUDY_ROOM_STATUS.CLOSED:
        return '#CC3131';
      case Constants.STUDY_ROOM_STATUS.MAINTENANCE:
        return '#B25000';
      default:
        return '#666666';
    }
  }
  
  /**
   * 获取状态背景颜色
   */
  getStatusBgColor(status: number): string {
    switch (status) {
      case Constants.STUDY_ROOM_STATUS.OPEN:
        return '#E7F7EE';
      case Constants.STUDY_ROOM_STATUS.CLOSED:
        return '#FFEAEA';
      case Constants.STUDY_ROOM_STATUS.MAINTENANCE:
        return '#FFF0E0';
      default:
        return '#F5F5F5';
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
        
        Text('自习室详情')
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
      
      // 自习室基本信息
      Column() {
        // 封面图
        Image(this.studyRoom.imageUrl || $r('app.media.default_room'))
          .width('100%')
          .height(180)
          .objectFit(ImageFit.Cover)
        
        // 自习室信息
        Column() {
          Row() {
            Text(this.studyRoom.name)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
            
            Text(this.getStatusText(this.studyRoom.status))
              .fontSize(14)
              .fontColor(this.getStatusColor(this.studyRoom.status))
              .backgroundColor(this.getStatusBgColor(this.studyRoom.status))
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(4)
              .margin({ left: 12 })
          }
          .width('100%')
          .margin({ top: 16 })
          
          // 地址
          Row() {
            Image($r('app.media.ic_location'))
              .width(16)
              .height(16)
              .margin({ right: 8 })
            
            Text(this.studyRoom.location)
              .fontSize(14)
              .fontColor('#666666')
          }
          .width('100%')
          .margin({ top: 12 })
          
          // 营业时间
          Row() {
            Image($r('app.media.ic_time'))
              .width(16)
              .height(16)
              .margin({ right: 8 })
            
            Text(`开放时间: ${this.studyRoom.openTime}-${this.studyRoom.closeTime}`)
              .fontSize(14)
              .fontColor('#666666')
          }
          .width('100%')
          .margin({ top: 8 })
          
          // 座位数
          Row() {
            Image($r('app.media.ic_seat'))
              .width(16)
              .height(16)
              .margin({ right: 8 })
            
            Text(`座位数: ${this.studyRoom.capacity}`)
              .fontSize(14)
              .fontColor('#666666')
          }
          .width('100%')
          .margin({ top: 8 })
          
          // 简介
          if (this.studyRoom.description) {
            Column() {
              Text('简介')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .alignSelf(ItemAlign.Start)
                .margin({ top: 16, bottom: 8 })
              
              Text(this.studyRoom.description)
                .fontSize(14)
                .fontColor('#666666')
                .width('100%')
            }
            .width('100%')
          }
          
          Divider()
            .width('100%')
            .color('#EEEEEE')
            .margin({ top: 16, bottom: 16 })
          
          // 座位状态图例
          Row() {
            // 可用
            Row() {
              Circle()
                .width(16)
                .height(16)
                .fill(this.getSeatColor(Constants.SEAT_STATUS.AVAILABLE))
                .margin({ right: 4 })
              
              Text('可用')
                .fontSize(14)
                .fontColor('#333333')
            }
            .margin({ right: 16 })
            
            // 已预约
            Row() {
              Circle()
                .width(16)
                .height(16)
                .fill(this.getSeatColor(Constants.SEAT_STATUS.RESERVED))
                .margin({ right: 4 })
              
              Text('已预约')
                .fontSize(14)
                .fontColor('#333333')
            }
            .margin({ right: 16 })
            
            // 维护中
            Row() {
              Circle()
                .width(16)
                .height(16)
                .fill(this.getSeatColor(Constants.SEAT_STATUS.MAINTENANCE))
                .margin({ right: 4 })
              
              Text('维护中')
                .fontSize(14)
                .fontColor('#333333')
            }
          }
          .width('100%')
          .margin({ bottom: 16 })
        }
        .width('90%')
        .padding({ top: 16 })
      }
      .backgroundColor(Color.White)
      
      // 座位布局容器
      Column() {
        Text('座位布局')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .width('90%')
          .margin({ top: 16, bottom: 16 })
        
        if (this.seats.length > 0) {
          // 座位布局
          Scroll() {
            Column() {
              // 教室前方区域
              Row() {
                Text('入口区域')
                  .fontSize(14)
                  .fontColor('#666666')
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .padding(16)
              .backgroundColor('#F0F0F0')
              .borderRadius(8)
              .margin({ bottom: 24 })
              
              // 座位网格
              Column() {
                ForEach(new Array(this.maxRow).fill(0).map((_, i) => i + 1), (row) => {
                  Row() {
                    ForEach(new Array(this.maxCol).fill(0).map((_, i) => i + 1), (col) => {
                      // 查找该位置是否有座位
                      if (this.findSeat(row, col)) {
                        // 有座位
                        Column() {
                          Text(this.findSeat(row, col).seatNumber)
                            .fontSize(16)
                            .fontWeight(FontWeight.Medium)
                            .fontColor(Color.White)
                            .textAlign(TextAlign.Center)
                            .margin({ bottom: 4 })
                          
                          Text(this.getSeatStatusText(this.findSeat(row, col).status))
                            .fontSize(12)
                            .fontColor(Color.White)
                            .opacity(0.8)
                            .textAlign(TextAlign.Center)
                        }
                        .width(this.gridSize)
                        .height(this.gridSize)
                        .borderRadius(12)
                        .backgroundColor(this.getSeatColor(this.findSeat(row, col).status))
                        .justifyContent(FlexAlign.Center)
                        .onClick(() => {
                          this.selectSeat(this.findSeat(row, col));
                        })
                        .shadow({
                          radius: 4,
                          color: '#000000',
                          offsetX: 0,
                          offsetY: 2
                        })
                      } else {
                        // 无座位，显示空白
                        Blank()
                          .width(this.gridSize)
                          .height(this.gridSize)
                      }
                    })
                  }
                  .width('100%')
                  .margin({ bottom: this.gridGap })
                  .justifyContent(FlexAlign.Center)
                })
              }
              .width('100%')
              .margin({ bottom: 20 })
              .padding({ left: 16, right: 16 })
              
              // 通道区域
              Row() {
                Text('出口区域')
                  .fontSize(14)
                  .fontColor('#666666')
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .padding(16)
              .backgroundColor('#F0F0F0')
              .borderRadius(8)
            }
            .width('100%')
          }
          .layoutWeight(1)
          .margin({ bottom: 16 })
        } else {
          if (!this.isLoading) {
            // 无座位数据
            Column() {
              Image($r('app.media.empty_data'))
                .width(120)
                .height(120)
                .margin({ top: 40 })
              
              Text('暂无座位数据')
                .fontSize(16)
                .fontColor('#999999')
                .margin({ top: 16 })
            }
            .width('100%')
          }
        }
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor(Color.White)
      .padding({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 