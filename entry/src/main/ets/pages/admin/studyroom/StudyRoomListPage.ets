import router from '@ohos.router';
import { Routes } from '../../../common/constants/Routes';
import { Constants } from '../../../common/constants/Constants';
import { ToastUtil } from '../../../common/components/ToastUtil';
import { StudyRoom } from '../../../model/StudyRoomModel';
import { StudyRoomService } from '../../../service/StudyRoomService';
import { LoadingDialog } from '../../../common/components/LoadingDialog';
import { ConfirmDialog } from '../../../common/components/ConfirmDialog';

@Entry
@Component
struct StudyRoomListPage {
  @State studyRooms: StudyRoom[] = [];
  @State isLoading: boolean = false;
  @State isRefreshing: boolean = false;
  @State currentPage: number = 1;
  @State pageSize: number = 10;
  @State keyword: string = '';
  @State hasMore: boolean = true;
  @State totalCount: number = 0;
  
  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({ message: '加载中...' }),
    autoCancel: false,
    alignment: DialogAlignment.Center
  });
  
  private confirmDialogController: CustomDialogController = null;
  
  aboutToAppear() {
    // 加载数据
    this.loadStudyRooms(true);
  }
  
  /**
   * 加载自习室列表
   * @param refresh 是否刷新
   */
  async loadStudyRooms(refresh: boolean = false) {
    if (this.isLoading) return;
    
    this.isLoading = true;
    if (refresh) {
      this.loadingDialogController.open();
      this.currentPage = 1;
      this.studyRooms = [];
    }
    
    try {
      const result = await StudyRoomService.getStudyRoomList(this.currentPage, this.pageSize);
      
      // 处理数据
      if (result && result.records) {
        this.totalCount = result.total || 0;
        
        if (refresh) {
          this.studyRooms = result.records;
        } else {
          this.studyRooms = [...this.studyRooms, ...result.records];
        }
        
        // 判断是否还有更多
        this.hasMore = this.studyRooms.length < this.totalCount;
      } else {
        if (refresh) {
          this.studyRooms = [];
        }
        this.hasMore = false;
      }
    } catch (error) {
      console.error('加载自习室列表失败:', error);
      ToastUtil.showError('加载失败: ' + error.message);
    } finally {
      this.isLoading = false;
      this.isRefreshing = false;
      this.loadingDialogController.close();
    }
  }
  
  /**
   * 搜索自习室
   */
  async searchStudyRooms() {
    if (!this.keyword.trim()) {
      this.loadStudyRooms(true);
      return;
    }
    
    this.isLoading = true;
    this.loadingDialogController.open();
    this.currentPage = 1;
    
    try {
      const result = await StudyRoomService.searchStudyRoom(this.keyword, this.currentPage, this.pageSize);
      
      // 处理数据
      if (result && result.records) {
        this.totalCount = result.total || 0;
        this.studyRooms = result.records;
        this.hasMore = this.studyRooms.length < this.totalCount;
      } else {
        this.studyRooms = [];
        this.hasMore = false;
      }
    } catch (error) {
      console.error('搜索自习室失败:', error);
      ToastUtil.showError('搜索失败: ' + error.message);
    } finally {
      this.isLoading = false;
      this.loadingDialogController.close();
    }
  }
  
  /**
   * 加载更多自习室
   */
  loadMoreStudyRooms() {
    if (this.isLoading || !this.hasMore) return;
    
    this.currentPage++;
    this.loadStudyRooms(false);
  }
  
  /**
   * 编辑自习室
   * @param id 自习室ID
   */
  navigateToEdit(id?: number) {
    router.pushUrl({
      url: Routes.ADMIN_STUDY_ROOM_EDIT,
      params: {
        id: id
      }
    });
  }
  
  /**
   * 查看自习室详情
   * @param id 自习室ID
   */
  navigateToDetail(id: number) {
    router.pushUrl({
      url: Routes.ADMIN_STUDY_ROOM_DETAIL,
      params: {
        id: id
      }
    });
  }
  
  /**
   * 确认删除自习室
   * @param id 自习室ID
   * @param name 自习室名称
   */
  confirmDeleteStudyRoom(id: number, name: string) {
    // 创建确认对话框
    this.confirmDialogController = new CustomDialogController({
      builder: ConfirmDialog({
        title: '删除自习室',
        message: `确定要删除自习室"${name}"吗？删除后将无法恢复。`,
        confirmText: '删除',
        cancelText: '取消',
        onConfirm: () => this.deleteStudyRoom(id)
      }),
      autoCancel: true,
      alignment: DialogAlignment.Center
    });
    
    this.confirmDialogController.open();
  }
  
  /**
   * 删除自习室
   * @param id 自习室ID
   */
  async deleteStudyRoom(id: number) {
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      const success = await StudyRoomService.deleteStudyRoom(id);
      if (success) {
        ToastUtil.showSuccess('删除成功');
        // 刷新列表
        this.loadStudyRooms(true);
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
   * @param id 自习室ID
   * @param status 状态
   */
  async updateStudyRoomStatus(id: number, status: number) {
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      const success = await StudyRoomService.updateStudyRoomStatus(id, status);
      if (success) {
        ToastUtil.showSuccess('更新状态成功');
        // 刷新列表
        this.loadStudyRooms(true);
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
        
        Text('自习室管理')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        
        Blank()
          .layoutWeight(1)
        
        Button('添加', { type: ButtonType.Capsule })
          .height(32)
          .fontSize(14)
          .onClick(() => {
            this.navigateToEdit();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      
      // 搜索栏
      Row() {
        TextInput({ placeholder: '搜索自习室', text: this.keyword })
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#F5F5F5')
          .placeholderColor('#999999')
          .padding({ left: 16, right: 16 })
          .borderRadius(20)
          .onChange((value: string) => {
            this.keyword = value;
          })
          .onSubmit(() => {
            this.searchStudyRooms();
          })
        
        Button('搜索', { type: ButtonType.Capsule })
          .height(40)
          .width(80)
          .fontSize(14)
          .margin({ left: 8 })
          .onClick(() => {
            this.searchStudyRooms();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .backgroundColor('#FFFFFF')
      
      // 自习室列表
      Refresh({ refreshing: $$this.isRefreshing, offset: 120, friction: 100 }) {
        List() {
          if (this.studyRooms.length > 0) {
            ForEach(this.studyRooms, (item: StudyRoom, index: number) => {
              ListItem() {
                Column() {
                  // 基本信息
                  Row() {
                    Column() {
                      Row() {
                        Text(item.name)
                          .fontSize(16)
                          .margin({left:10})
                          .fontWeight(FontWeight.Bold)
                          .fontColor('#333333')
                          .layoutWeight(1)
                        
                        Text(this.getStatusText(item.status))
                          .fontSize(12)
                          .fontColor(this.getStatusColor(item.status))
                          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                          .borderRadius(10)
                          .backgroundColor(this.getStatusColor(item.status) + '15')
                      }
                      .width('100%')
                      
                      Text(item.location)
                        .fontSize(14)
                        .fontColor('#666666')
                        .margin({ top: 4 })
                      
                      Row() {
                        Text(`开放时间: ${item.openTime || '--'}-${item.closeTime || '--'}`)
                          .fontSize(12)
                          .fontColor('#999999')
                          .margin({ right: 16 })
                        
                        Text(`座位数: ${item.capacity || 0}`)
                          .fontSize(12)
                          .fontColor('#999999')
                      }
                      .width('100%')
                      .margin({ top: 4 })
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                    
                    Column() {
                      Image($r('app.media.ic_arrow_right'))
                        .width(24)
                        .height(24)
                    }
                    .width(40)
                    .height('100%')
                    .justifyContent(FlexAlign.Center)
                  }
                  .width('100%')
                  .height('20%')
                  .onClick(() => {
                    this.navigateToDetail(item.id);
                  })
                  
                  // 操作按钮组
                  Row() {
                    // 座位管理
                    Button('座位管理')
                      .height(32)
                      .fontSize(12)
                      .fontColor('#333333')
                      .backgroundColor('#F5F5F5')
                      .margin({ right: 8 })
                      .onClick(() => {
                        router.pushUrl({
                          url: Routes.ADMIN_SEAT_MANAGE,
                          params: { roomId: item.id }
                        });
                      })
                    
                    // 修改状态
                    if (item.status !== Constants.STUDY_ROOM_STATUS.OPEN) {
                      Button('开放')
                        .height(32)
                        .fontSize(12)
                        .fontColor('#FFFFFF')
                        .backgroundColor('#4CAF50')
                        .margin({ right: 8 })
                        .onClick((event: ClickEvent) => {
                          this.updateStudyRoomStatus(item.id, Constants.STUDY_ROOM_STATUS.OPEN);
                        })
                    }
                    
                    if (item.status !== Constants.STUDY_ROOM_STATUS.CLOSED) {
                      Button('关闭')
                        .height(32)
                        .fontSize(12)
                        .fontColor('#FFFFFF')
                        .backgroundColor('#F44336')
                        .margin({ right: 8 })
                        .onClick((event: ClickEvent) => {
                          this.updateStudyRoomStatus(item.id, Constants.STUDY_ROOM_STATUS.CLOSED);
                        })
                    }
                    
                    if (item.status !== Constants.STUDY_ROOM_STATUS.MAINTENANCE) {
                      Button('维护')
                        .height(32)
                        .fontSize(12)
                        .fontColor('#FFFFFF')
                        .backgroundColor('#FF9800')
                        .margin({ right: 8 })
                        .onClick((event: ClickEvent) => {
                          this.updateStudyRoomStatus(item.id, Constants.STUDY_ROOM_STATUS.MAINTENANCE);
                        })
                    }
                    
                    Blank()
                      .layoutWeight(1)
                    
                    // 编辑
                    Button('编辑')
                      .height(32)
                      .fontSize(12)
                      .fontColor('#FFFFFF')
                      .backgroundColor('#2196F3')
                      .margin({ right: 8 })
                      .onClick((event: ClickEvent) => {
                        this.navigateToEdit(item.id);
                      })
                    
                    // 删除
                    Button('删除')
                      .height(32)
                      .fontSize(12)
                      .fontColor('#FFFFFF')
                      .backgroundColor('#F44336')
                      .onClick((event: ClickEvent) => {
                        this.confirmDeleteStudyRoom(item.id, item.name);
                      })
                  }
                  .width('100%')
                  .padding({ left: 35, bottom: 16 })
                  .justifyContent(FlexAlign.End)
                }
                .backgroundColor('#ffffffff')
                .borderRadius(8)
                .borderWidth(2)
                .margin({ bottom: 8 })
              }
            })
            
            if (this.hasMore) {
              ListItem() {
                Row() {
                  Text('加载更多')
                    .fontSize(14)
                    .fontColor('#999999')
                }
                .width('100%')
                .height(50)
                .justifyContent(FlexAlign.Center)
                .onClick(() => {
                  this.loadMoreStudyRooms();
                })
              }
            }
          } else {
            ListItem() {
              Column() {
                Image($r('app.media.empty_data'))
                  .width(100)
                  .height(100)
                  .margin({ bottom: 16 })
                
                Text('暂无自习室')
                  .fontSize(16)
                  .fontColor('#999999')
              }
              .width('100%')
              .height('60%')
              .justifyContent(FlexAlign.Center)
            }
          }
        }
        .width('100%')
        .layoutWeight(1)
        .padding(16)
        .backgroundColor('#F5F5F5')
        .divider({ strokeWidth: 0 })
      }
      .onStateChange((refreshStatus: RefreshStatus) => {
        if (refreshStatus === RefreshStatus.Refresh) {
          this.isRefreshing = true;
          this.loadStudyRooms(true);
        }
      })
    }
    .width('100%')
    .height('100%')
  }
} 