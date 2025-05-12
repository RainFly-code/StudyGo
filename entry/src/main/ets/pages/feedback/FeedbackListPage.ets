import router from '@ohos.router';
import { Feedback } from '../../model/AnnouncementModel';
import { Constants } from '../../common/constants/Constants';
import { Routes } from '../../common/constants/Routes';
import { FeedbackService } from '../../service/FeedbackService';
import { LoadingDialog } from '../../common/components/LoadingDialog';
import { ToastUtil } from '../../common/components/ToastUtil';

@Entry
@Component
struct FeedbackListPage {
  @State isLoading: boolean = false;
  @State isEmpty: boolean = false;
  @State feedbacks: Feedback[] = [];
  @State totalCount: number = 0;
  @State filterStatus: number | undefined = undefined;
  
  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({ message: '加载中...' }),
    autoCancel: false,
    alignment: DialogAlignment.Center
  });
  
  aboutToAppear() {
    console.info('【FeedbackListPage】页面即将显示');
    this.loadFeedbacks();
  }
  
  /**
   * 加载反馈列表
   */
  async loadFeedbacks() {
    if (this.isLoading) return;
    
    this.isLoading = true;
    this.loadingDialogController.open();
    
    // 保存筛选状态到局部变量
    const statusFilter = this.filterStatus;
    
    try {
      console.info('【FeedbackListPage】loadFeedbacks - 当前筛选状态值:', statusFilter, 
                   '类型:', typeof statusFilter, 
                   '显示:', statusFilter !== undefined ? statusFilter : '全部');
      
      const result = await FeedbackService.getUserFeedbacks(1, 100, statusFilter);
      
      this.feedbacks = result.records || [];
      this.totalCount = result.total || 0;
      this.isEmpty = this.feedbacks.length === 0;
      
      console.info('【FeedbackListPage】反馈列表加载完成, 数量:', this.feedbacks.length, 
                  '筛选状态:', statusFilter !== undefined ? statusFilter : '全部');
    } catch (error) {
      console.error('【FeedbackListPage】加载反馈列表失败:', error);
      ToastUtil.showToast('加载反馈列表失败');
      this.isEmpty = true;
    } finally {
      this.isLoading = false;
      this.loadingDialogController.close();
    }
  }
  
  /**
   * 设置筛选状态
   */
  setStatus(status: number | undefined) {
    console.info('【FeedbackListPage】开始设置筛选状态, 原状态:', this.filterStatus !== undefined ? this.filterStatus : '全部', 
                 '新状态:', status !== undefined ? status : '全部');
    
    // 如果状态相同，不需要重新加载
    if (this.filterStatus === status) {
      console.info('【FeedbackListPage】状态没有变化，跳过加载');
      return;
    }
    
    // 使用状态变量记录，而不是直接修改this.filterStatus
    const newStatus = status;
    this.filterStatus = newStatus;
    
    console.info('【FeedbackListPage】状态已设置, 当前状态:', this.filterStatus !== undefined ? this.filterStatus : '全部');
    
    // 使用setTimeOut确保状态已经更新
    setTimeout(() => {
      console.info('【FeedbackListPage】延迟加载, 确保状态已更新, 当前状态:', this.filterStatus !== undefined ? this.filterStatus : '全部');
      this.loadFeedbacks();
    }, 50);
  }
  
  /**
   * 跳转到反馈详情页
   */
  navigateToDetail(id: number) {
    router.pushUrl({
      url: Routes.FEEDBACK_DETAIL,
      params: { id }
    });
  }
  
  /**
   * 跳转到新增反馈页
   */
  navigateToAdd() {
    router.pushUrl({
      url: Routes.FEEDBACK_ADD
    });
  }
  
  /**
   * 获取反馈类型名称
   */
  getFeedbackTypeName(type: number): string {
    switch (type) {
      case Constants.FEEDBACK_TYPE.SUGGESTION:
        return '建议';
      case Constants.FEEDBACK_TYPE.BUG:
        return '问题';
      case Constants.FEEDBACK_TYPE.QUESTION:
        return '咨询';
      default:
        return '未知';
    }
  }
  
  /**
   * 获取反馈状态名称
   */
  getFeedbackStatusName(status: number): string {
    switch (status) {
      case Constants.FEEDBACK_STATUS.PENDING:
        return '待处理';
      case Constants.FEEDBACK_STATUS.HANDLING:
        return '处理中';
      case Constants.FEEDBACK_STATUS.COMPLETED:
        return '已完成';
      default:
        return '未知';
    }
  }
  
  /**
   * 获取反馈状态颜色
   */
  getFeedbackStatusColor(status: number): Color {
    switch (status) {
      case Constants.FEEDBACK_STATUS.PENDING:
        return Color.Orange;
      case Constants.FEEDBACK_STATUS.HANDLING:
        return Color.Blue;
      case Constants.FEEDBACK_STATUS.COMPLETED:
        return Color.Green;
      default:
        return Color.Gray;
    }
  }
  
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Row() {
          Image($r('app.media.ic_back'))
            .width(24)
            .height(24)
            .margin({ right: 16 })
            .onClick(() => {
              router.back();
            })
          
          Text('我的反馈')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      
      // 筛选条件
      Row() {
        Row() {
          Text('全部')
            .fontSize(14)
            .fontColor(this.filterStatus === undefined ? '#2196F3' : '#333333')
            .fontWeight(this.filterStatus === undefined ? FontWeight.Bold : FontWeight.Normal)
            .padding(8)
            .borderRadius(16)
            .backgroundColor(this.filterStatus === undefined ? '#E3F2FD' : '#00000000')
            .onClick(() => this.setStatus(undefined))
          
          Text('待处理')
            .fontSize(14)
            .fontColor(this.filterStatus === Constants.FEEDBACK_STATUS.PENDING ? '#2196F3' : '#333333')
            .fontWeight(this.filterStatus === Constants.FEEDBACK_STATUS.PENDING ? FontWeight.Bold : FontWeight.Normal)
            .padding(8)
            .margin({ left: 8 })
            .borderRadius(16)
            .backgroundColor(this.filterStatus === Constants.FEEDBACK_STATUS.PENDING ? '#E3F2FD' : '#00000000')
            .onClick(() => this.setStatus(Constants.FEEDBACK_STATUS.PENDING))
          
          Text('处理中')
            .fontSize(14)
            .fontColor(this.filterStatus === Constants.FEEDBACK_STATUS.HANDLING ? '#2196F3' : '#333333')
            .fontWeight(this.filterStatus === Constants.FEEDBACK_STATUS.HANDLING ? FontWeight.Bold : FontWeight.Normal)
            .padding(8)
            .margin({ left: 8 })
            .borderRadius(16)
            .backgroundColor(this.filterStatus === Constants.FEEDBACK_STATUS.HANDLING ? '#E3F2FD' : '#00000000')
            .onClick(() => this.setStatus(Constants.FEEDBACK_STATUS.HANDLING))
          
          Text('已完成')
            .fontSize(14)
            .fontColor(this.filterStatus === Constants.FEEDBACK_STATUS.COMPLETED ? '#2196F3' : '#333333')
            .fontWeight(this.filterStatus === Constants.FEEDBACK_STATUS.COMPLETED ? FontWeight.Bold : FontWeight.Normal)
            .padding(8)
            .margin({ left: 8 })
            .borderRadius(16)
            .backgroundColor(this.filterStatus === Constants.FEEDBACK_STATUS.COMPLETED ? '#E3F2FD' : '#00000000')
            .onClick(() => this.setStatus(Constants.FEEDBACK_STATUS.COMPLETED))
        }
        .width('100%')
        .justifyContent(FlexAlign.Start)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      .backgroundColor('#FFFFFF')
      
      // 反馈列表
      if (this.isEmpty) {
        Column() {
          Image($r('app.media.empty_data'))
            .width(120)
            .height(120)
            .margin({ top: 80, bottom: 16 })
          
          Text('暂无反馈记录')
            .fontSize(16)
            .fontColor('#999999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List() {
          ForEach(this.feedbacks, (feedback: Feedback) => {
            ListItem() {
              Column() {
                Row() {
                  Column() {
                    Row() {
                      Text(feedback.title)
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                      
                      Text(this.getFeedbackTypeName(feedback.type))
                        .fontSize(12)
                        .fontColor('#FFFFFF')
                        .backgroundColor('#2196F3')
                        .borderRadius(8)
                        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                        .margin({ left: 8 })
                    }
                    .width('100%')
                    
                    Text(feedback.content)
                      .fontSize(14)
                      .fontColor('#666666')
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .margin({ top: 8 })
                    
                    Row() {
                      Text(feedback.createTime || '')
                        .fontSize(12)
                        .fontColor('#999999')
                      
                      Text(this.getFeedbackStatusName(feedback.status))
                        .fontSize(12)
                        .fontColor(this.getFeedbackStatusColor(feedback.status))
                        .fontWeight(FontWeight.Bold)
                        .margin({ left: 16 })
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.SpaceBetween)
                    .margin({ top: 8 })
                  }
                  .layoutWeight(1)
                  
                  Image($r('app.media.ic_arrow_right'))
                    .width(16)
                    .height(16)
                    .margin({ left: 8 })
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#FFFFFF')
                .borderRadius(8)
                .onClick(() => this.navigateToDetail(feedback.id))
              }
              .width('100%')
            }
            .width('100%')
          }, (feedback) => feedback.id ? feedback.id.toString() : '')
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 8 })
        .divider({ strokeWidth: 0.5, color: '#EEEEEE', startMargin: 16, endMargin: 16 })
      }
      
      // 添加反馈按钮
      Button('添加反馈', { type: ButtonType.Capsule })
        .width('90%')
        .height(50)
        .backgroundColor('#2196F3')
        .margin({ bottom: 20 })
        .onClick(() => this.navigateToAdd())
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 