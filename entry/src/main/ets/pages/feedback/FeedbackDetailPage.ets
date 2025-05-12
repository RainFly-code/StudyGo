import router from '@ohos.router';
import { Feedback } from '../../model/AnnouncementModel';
import { Constants } from '../../common/constants/Constants';
import { FeedbackService } from '../../service/FeedbackService';
import { LoadingDialog } from '../../common/components/LoadingDialog';
import { ToastUtil } from '../../common/components/ToastUtil';

@Entry
@Component
struct FeedbackDetailPage {
  @State isLoading: boolean = false;
  @State feedback: Feedback = new Feedback();
  
  private feedbackId: number = 0;
  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({ message: '加载中...' }),
    autoCancel: false,
    alignment: DialogAlignment.Center
  });
  
  aboutToAppear() {
    const params = router.getParams();
    if (params && params['id']) {
      this.feedbackId = Number(params['id']);
      console.info('【FeedbackDetailPage】页面即将显示, 反馈ID:', this.feedbackId);
      this.loadFeedbackDetail();
    } else {
      ToastUtil.showToast('未找到反馈信息');
      router.back();
    }
  }
  
  /**
   * 加载反馈详情
   */
  async loadFeedbackDetail() {
    if (this.isLoading || this.feedbackId <= 0) return;
    
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      const feedback = await FeedbackService.getFeedbackDetail(this.feedbackId);
      
      this.feedback = feedback;
      console.info('【FeedbackDetailPage】反馈详情加载完成:', feedback);
    } catch (error) {
      console.error('【FeedbackDetailPage】加载反馈详情失败:', error);
      ToastUtil.showToast('加载反馈详情失败');
    } finally {
      this.isLoading = false;
      this.loadingDialogController.close();
    }
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
          
          Text('反馈详情')
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
      
      // 反馈详情
      Scroll() {
        Column() {
          // 基本信息卡片
          Column() {
            Row() {
              Text('反馈信息')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            .padding({ bottom: 12 })
            .borderWidth({ bottom: 0.5 })
            .borderColor('#EEEEEE')
            
            // 标题和类型
            Row() {
              Text(this.feedback.title)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .layoutWeight(1)
              
              Text(this.getFeedbackTypeName(this.feedback.type))
                .fontSize(14)
                .fontColor('#FFFFFF')
                .backgroundColor('#2196F3')
                .borderRadius(16)
                .padding({ left: 12, right: 12, top: 4, bottom: 4 })
            }
            .width('100%')
            .margin({ top: 16 })
            
            // 状态和时间
            Row() {
              Text('状态:')
                .fontSize(14)
                .fontColor('#666666')
              
              Text(this.getFeedbackStatusName(this.feedback.status))
                .fontSize(14)
                .fontColor(this.getFeedbackStatusColor(this.feedback.status))
                .fontWeight(FontWeight.Bold)
                .margin({ left: 8 })
              
              Blank()
              
              Text('提交时间: ' + (this.feedback.createTime || ''))
                .fontSize(14)
                .fontColor('#999999')
            }
            .width('100%')
            .margin({ top: 16 })
            
            // 内容
            Column() {
              Text('反馈内容:')
                .fontSize(14)
                .fontColor('#666666')
                .alignSelf(ItemAlign.Start)
              
              Text(this.feedback.content)
                .fontSize(16)
                .fontColor('#333333')
                .lineHeight(24)
                .alignSelf(ItemAlign.Start)
                .margin({ top: 8 })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .margin({ top: 16 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          
          // 回复信息卡片(仅在有回复时显示)
          if (this.feedback.status !== Constants.FEEDBACK_STATUS.PENDING && this.feedback.reply) {
            Column() {
              Row() {
                Text('管理员回复')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
              }
              .width('100%')
              .justifyContent(FlexAlign.Start)
              .padding({ bottom: 12 })
              .borderWidth({ bottom: 0.5 })
              .borderColor('#EEEEEE')
              
              // 回复内容
              Column() {
                Text('回复内容:')
                  .fontSize(14)
                  .fontColor('#666666')
                  .alignSelf(ItemAlign.Start)
                
                Text(this.feedback.reply)
                  .fontSize(16)
                  .fontColor('#333333')
                  .lineHeight(24)
                  .alignSelf(ItemAlign.Start)
                  .margin({ top: 8 })
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .margin({ top: 16 })
              
              // 回复时间
              Row() {
                Text('回复时间: ' + (this.feedback.updateTime || ''))
                  .fontSize(14)
                  .fontColor('#999999')
              }
              .width('100%')
              .justifyContent(FlexAlign.End)
              .margin({ top: 16 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .margin({ top: 16 })
          }
        }
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
  }
} 