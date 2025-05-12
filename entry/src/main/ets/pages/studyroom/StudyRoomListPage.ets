import router from '@ohos.router';
import { Routes } from '../../common/constants/Routes';
import { Constants } from '../../common/constants/Constants';
import { ToastUtil } from '../../common/components/ToastUtil';
import { StudyRoom } from '../../model/StudyRoomModel';
import { StudyRoomService } from '../../service/StudyRoomService';

@Entry
@Component
struct StudyRoomListPage {
  @State studyRooms: StudyRoom[] = [];
  @State isRefreshing: boolean = false;
  @State isLoading: boolean = false;
  @State currentPage: number = 1;
  @State pageSize: number = 10;
  @State hasMore: boolean = true;
  @State searchText: string = '';
  @State selectedStatus: number = -1; // -1表示全部
  
  private keyword: string = router.getParams()?.['keyword'] || '';
  private statusOptions: any[] = [
    { label: '全部', value: -1 },
    { label: '开放中', value: Constants.STUDY_ROOM_STATUS.OPEN },
    { label: '已关闭', value: Constants.STUDY_ROOM_STATUS.CLOSED },
    { label: '维护中', value: Constants.STUDY_ROOM_STATUS.MAINTENANCE }
  ];
  
  aboutToAppear() {
    // 如果有搜索关键词，则进行搜索
    if (this.keyword) {
      this.searchText = this.keyword;
      this.searchStudyRooms();
    } else {
      this.loadStudyRooms();
    }
  }
  
  /**
   * 加载自习室列表
   */
  async loadStudyRooms() {
    if (this.isLoading) return;
    this.isLoading = true;
    
    try {
      // 调用获取自习室列表接口
      const result = await StudyRoomService.getStudyRoomList(
        this.currentPage,
        this.pageSize,
        this.selectedStatus === -1 ? undefined : this.selectedStatus
      );
      
      if (result && result.records) {
        // 如果是刷新或者第一页，则直接替换数据
        if (this.currentPage === 1) {
          this.studyRooms = result.records;
        } else {
          // 否则追加数据
          this.studyRooms = [...this.studyRooms, ...result.records];
        }
        
        // 判断是否还有更多数据
        this.hasMore = this.currentPage < result.pages;
      } else {
        this.hasMore = false;
      }
    } catch (error) {
      console.error('加载自习室列表失败:', error);
      ToastUtil.showError('加载自习室列表失败');
    } finally {
      this.isLoading = false;
      this.isRefreshing = false;
    }
  }
  
  /**
   * 搜索自习室
   */
  async searchStudyRooms() {
    this.currentPage = 1;
    this.isLoading = true;
    
    try {
      // 调用搜索自习室接口
      const result = await StudyRoomService.searchStudyRoom(
        this.searchText,
        this.currentPage,
        this.pageSize
      );
      
      if (result && result.records) {
        this.studyRooms = result.records;
        this.hasMore = this.currentPage < result.pages;
      } else {
        this.studyRooms = [];
        this.hasMore = false;
      }
    } catch (error) {
      console.error('搜索自习室失败:', error);
      ToastUtil.showError('搜索自习室失败');
    } finally {
      this.isLoading = false;
      this.isRefreshing = false;
    }
  }
  
  /**
   * 刷新数据
   */
  refreshData() {
    this.currentPage = 1;
    this.hasMore = true;
    if (this.searchText) {
      this.searchStudyRooms();
    } else {
      this.loadStudyRooms();
    }
  }
  
  /**
   * 加载更多
   */
  loadMoreData() {
    if (this.hasMore && !this.isLoading) {
      this.currentPage++;
      if (this.searchText) {
        this.searchStudyRooms();
      } else {
        this.loadStudyRooms();
      }
    }
  }
  
  /**
   * 状态筛选变化
   */
  onStatusChange(status: number) {
    this.selectedStatus = status;
    this.refreshData();
  }
  
  /**
   * 获取状态文本
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
        
        Text('自习室列表')
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
      
      // 搜索栏
      Row() {
        Image($r('app.media.ic_search'))
          .width(24)
          .height(24)
          .margin({ right: 8 })
        
        TextInput({ placeholder: '搜索自习室', text: this.searchText })
          .layoutWeight(1)
          .backgroundColor(Color.Transparent)
          .placeholderColor('#999999')
          .fontSize(16)
          .height(40)
          .onChange((value: string) => {
            this.searchText = value;
          })
          .onSubmit(() => {
            this.searchStudyRooms();
          })
        
        if (this.searchText.length > 0) {
          Image($r('app.media.ic_clear'))
            .width(20)
            .height(20)
            .margin({ left: 8 })
            .onClick(() => {
              this.searchText = '';
              this.refreshData();
            })
        }
      }
      .width('90%')
      .height(50)
      .borderRadius(25)
      .backgroundColor('#F5F5F5')
      .padding({ left: 16, right: 16 })
      .margin({ top: 16, bottom: 16 })
      
      // 筛选条件
      Scroll() {
        Row() {
          ForEach(this.statusOptions, (item) => {
            Text(item.label)
              .fontSize(14)
              .fontColor(this.selectedStatus === item.value ? '#007DFF' : '#333333')
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .borderRadius(16)
              .backgroundColor(this.selectedStatus === item.value ? '#E6F2FF' : Color.Transparent)
              .margin({ right: 12 })
              .onClick(() => {
                this.onStatusChange(item.value);
              })
          })
        }
        .width('100%')
      }
      .width('90%')
      .margin({ bottom: 16 })
      .scrollBar(BarState.Off)
      
      // 自习室列表
      Refresh({ refreshing: $$this.isRefreshing, offset: 120, friction: 100 }) {
        List() {
          if (this.studyRooms.length > 0) {
            ForEach(this.studyRooms, (item: StudyRoom) => {
              ListItem() {
                Column() {
                  Row() {
                    Image(item.imageUrl || $r('app.media.default_room'))
                      .width(80)
                      .height(80)
                      .borderRadius(8)
                      .objectFit(ImageFit.Cover)
                    
                    Column() {
                      Row() {
                        Text(item.name)
                          .fontSize(16)
                          .fontWeight(FontWeight.Medium)
                          .fontColor('#333333')
                          .maxLines(1)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                        
                        Text(this.getStatusText(item.status))
                          .fontSize(12)
                          .fontColor(this.getStatusColor(item.status))
                          .backgroundColor(this.getStatusBgColor(item.status))
                          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                          .borderRadius(4)
                          .margin({ left: 8 })
                      }
                      .width('100%')
                      
                      Text(item.location)
                        .fontSize(14)
                        .fontColor('#666666')
                        .width('100%')
                        .margin({ top: 4 })
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                      
                      Text(`开放时间: ${item.openTime}-${item.closeTime}`)
                        .fontSize(12)
                        .fontColor('#999999')
                        .margin({ top: 4 })
                      
                      Text(`座位数: ${item.capacity}`)
                        .fontSize(12)
                        .fontColor('#999999')
                        .margin({ top: 4 })
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                    .margin({ left: 12 })
                    
                    Image($r('app.media.ic_arrow_right'))
                      .width(16)
                      .height(16)
                      .margin({ left: 8 })
                  }
                  .width('100%')
                }
                .width('100%')
                .padding(16)
                .borderRadius(8)
                .backgroundColor('#FFFFFF')
                .margin({ bottom: 12 })
                .onClick(() => {
                  router.pushUrl({
                    url: Routes.STUDY_ROOM_DETAIL,
                    params: { id: item.id }
                  });
                })
              }
            })
            
            // 加载更多
            if (this.isLoading) {
              ListItem() {
                Row() {
                  LoadingProgress()
                    .width(24)
                    .height(24)
                    .color('#999999')
                  
                  Text('加载中...')
                    .fontSize(14)
                    .fontColor('#999999')
                    .margin({ left: 8 })
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
                .padding({ top: 12, bottom: 12 })
              }
            }
            
            // 没有更多数据
            if (!this.hasMore && !this.isLoading && this.studyRooms.length > 0) {
              ListItem() {
                Text('没有更多数据了')
                  .fontSize(14)
                  .fontColor('#999999')
                  .width('100%')
                  .textAlign(TextAlign.Center)
                  .padding({ top: 12, bottom: 12 })
              }
            }
          } else {
            // 空状态
            if (!this.isLoading) {
              ListItem() {
                Column() {
                  Image($r('app.media.empty_data'))
                    .width(120)
                    .height(120)
                    .margin({ top: 60, bottom: 16 })
                  
                  Text('暂无自习室数据')
                    .fontSize(16)
                    .fontColor('#999999')
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
              }
            }
          }
        }
        .width('90%')
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
        .onReachEnd(() => {
          this.loadMoreData();
        })
      }
      .onStateChange((refreshStatus: RefreshStatus) => {
        if (refreshStatus === RefreshStatus.Refresh) {
          this.refreshData();
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 