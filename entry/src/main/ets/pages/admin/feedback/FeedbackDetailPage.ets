import router from '@ohos.router';
import { Routes } from '../../../common/constants/Routes';
import { Constants } from '../../../common/constants/Constants';
import { ToastUtil } from '../../../common/components/ToastUtil';
import { LoadingDialog } from '../../../common/components/LoadingDialog';
import { ConfirmDialog } from '../../../common/components/ConfirmDialog';
import { Feedback } from '../../../model/FeedbackModel';
import { FeedbackService } from '../../../service/FeedbackService';

@Entry
@Component
struct FeedbackDetailPage {
  @State feedback: Feedback = new Feedback();
  @State isLoading: boolean = false;
  @State reply: string = '';
  @State newStatus: number = 0;
  
  private feedbackId: number = router.getParams()?.['id'] || 0;
  
  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({ message: '加载中...' }),
    alignment: DialogAlignment.Center,
    autoCancel: false,
    customStyle: true
  });
  
  private confirmDialogController: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      title: '确认操作',
      message: '确定要更新反馈状态吗？',
      onConfirm: () => {}
    }),
    autoCancel: true,
    customStyle: true
  });
  
  aboutToAppear() {
    if (this.feedbackId > 0) {
      this.loadFeedbackDetail();
    } else {
      ToastUtil.showError('参数错误');
      router.back();
    }
  }
  
  /**
   * 加载反馈详情
   */
  async loadFeedbackDetail() {
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      const feedback = await FeedbackService.getFeedbackDetail(this.feedbackId);
      this.feedback = feedback;
      this.newStatus = feedback.status;
      this.reply = feedback.reply || '';
      
      console.info('反馈详情:', JSON.stringify(this.feedback));
    } catch (error) {
      console.error('获取反馈详情失败:', error);
      ToastUtil.showError('获取反馈详情失败: ' + error.message);
      router.back();
    } finally {
      this.isLoading = false;
      this.loadingDialogController.close();
    }
  }
  
  /**
   * 处理反馈
   */
  async handleFeedback() {
    // 验证输入
    if (this.newStatus === Constants.FEEDBACK_STATUS.COMPLETED && !this.reply.trim()) {
      ToastUtil.showWarning('请输入回复内容');
      return;
    }
    
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      const success = await FeedbackService.handleFeedback(
        this.feedbackId, 
        this.newStatus, 
        this.reply.trim()
      );
      
      if (success) {
        ToastUtil.showSuccess('处理反馈成功');
        this.loadFeedbackDetail(); // 重新加载反馈详情
      } else {
        ToastUtil.showError('处理反馈失败');
      }
    } catch (error) {
      console.error('处理反馈失败:', error);
      ToastUtil.showError('处理反馈失败: ' + error.message);
    } finally {
      this.isLoading = false;
      this.loadingDialogController.close();
    }
  }
  
  /**
   * 确认处理反馈
   */
  confirmHandleFeedback() {
    if (this.newStatus === this.feedback.status && this.reply === this.feedback.reply) {
      ToastUtil.showToast('未做任何修改');
      return;
    }
    
    let statusText = '';
    switch (this.newStatus) {
      case Constants.FEEDBACK_STATUS.PENDING:
        statusText = '待处理';
        break;
      case Constants.FEEDBACK_STATUS.HANDLING:
        statusText = '处理中';
        break;
      case Constants.FEEDBACK_STATUS.COMPLETED:
        statusText = '已完成';
        break;
    }
    
    this.confirmDialogController = new CustomDialogController({
      builder: ConfirmDialog({
        title: '确认操作',
        message: `确定要将反馈状态修改为"${statusText}"吗？`,
        onConfirm: () => {
          this.handleFeedback();
        }
      }),
      autoCancel: true,
      customStyle: true
    });
    
    this.confirmDialogController.open();
  }
  
  /**
   * 获取状态文本及颜色
   */
  getStatusInfo(status: number): { text: string, color: string } {
    switch (status) {
      case Constants.FEEDBACK_STATUS.PENDING:
        return { text: '待处理', color: '#FF9800' };
      case Constants.FEEDBACK_STATUS.HANDLING:
        return { text: '处理中', color: '#2196F3' };
      case Constants.FEEDBACK_STATUS.COMPLETED:
        return { text: '已完成', color: '#4CAF50' };
      default:
        return { text: '未知', color: '#9E9E9E' };
    }
  }
  
  /**
   * 获取类型文本及图标
   */
  getTypeInfo(type: number): { text: string, color: string } {
    switch (type) {
      case Constants.FEEDBACK_TYPE.SUGGESTION:
        return { text: '建议', color: '#4CAF50' };
      case Constants.FEEDBACK_TYPE.BUG:
        return { text: '错误', color: '#F44336' };
      case Constants.FEEDBACK_TYPE.QUESTION:
        return { text: '问题', color: '#2196F3' };
      default:
        return { text: '未知', color: '#9E9E9E' };
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
        
        Text('反馈详情')
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
      
      // 主内容区域
      Scroll() {
        Column() {
          // 反馈基本信息
          Column() {
            // 标题与状态
            Row() {
              Text(`[${this.getTypeInfo(this.feedback.type).text}] ${this.feedback.title}`)
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .layoutWeight(1)
              
              Text(this.getStatusInfo(this.feedback.status).text)
                .fontSize(14)
                .fontColor(this.getStatusInfo(this.feedback.status).color)
                .backgroundColor(this.getStatusInfo(this.feedback.status).color + '15')
                .borderRadius(12)
                .padding({ left: 12, right: 12, top: 4, bottom: 4 })
            }
            .width('100%')
            
            // 提交信息
            Row() {
              Text(`用户ID: ${this.feedback.userId}`)
                .fontSize(14)
                .fontColor('#666666')
              
              Text(`提交时间: ${this.feedback.createTime}`)
                .fontSize(14)
                .fontColor('#666666')
                .margin({ left: 16 })
            }
            .width('100%')
            .margin({ top: 8 })
            
            // 反馈内容
            Text('反馈内容:')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .width('100%')
              .margin({ top: 16, bottom: 8 })
            
            Text(this.feedback.content)
              .fontSize(16)
              .fontColor('#333333')
              .width('100%')
              .padding(16)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
            
            // 回复内容（如果有）
            if (this.feedback.reply) {
              Text('管理员回复:')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333')
                .width('100%')
                .margin({ top: 16, bottom: 8 })
              
              Text(this.feedback.reply)
                .fontSize(16)
                .fontColor('#333333')
                .width('100%')
                .padding(16)
                .backgroundColor('#E1F5FE')
                .borderRadius(8)
                
              Text(`回复时间: ${this.feedback.updateTime}`)
                .fontSize(14)
                .fontColor('#666666')
                .alignSelf(ItemAlign.End)
                .margin({ top: 8 })
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)
          
          // 处理反馈区域
          Column() {
            Text('处理反馈')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
            
            // 状态选择
            Text('状态:')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ top: 16, bottom: 8 })
            
            Row() {
              Row() {
                Radio({ value: 'pending', group: 'status' })
                  .checked(this.newStatus === Constants.FEEDBACK_STATUS.PENDING)
                  .onChange((isChecked) => {
                    if (isChecked) {
                      this.newStatus = Constants.FEEDBACK_STATUS.PENDING;
                    }
                  })
                
                Text('待处理')
                  .fontSize(16)
                  .fontColor('#333333')
                  .margin({ left: 8 })
              }
              .margin({ right: 24 })
              
              Row() {
                Radio({ value: 'handling', group: 'status' })
                  .checked(this.newStatus === Constants.FEEDBACK_STATUS.HANDLING)
                  .onChange((isChecked) => {
                    if (isChecked) {
                      this.newStatus = Constants.FEEDBACK_STATUS.HANDLING;
                    }
                  })
                
                Text('处理中')
                  .fontSize(16)
                  .fontColor('#333333')
                  .margin({ left: 8 })
              }
              .margin({ right: 24 })
              
              Row() {
                Radio({ value: 'completed', group: 'status' })
                  .checked(this.newStatus === Constants.FEEDBACK_STATUS.COMPLETED)
                  .onChange((isChecked) => {
                    if (isChecked) {
                      this.newStatus = Constants.FEEDBACK_STATUS.COMPLETED;
                    }
                  })
                
                Text('已完成')
                  .fontSize(16)
                  .fontColor('#333333')
                  .margin({ left: 8 })
              }
            }
            .width('100%')
            
            // 回复区域
            Text('回复内容:')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ top: 16, bottom: 8 })
            
            TextArea({ placeholder: '请输入回复内容', text: this.reply })
              .width('100%')
              .height(150)
              .fontSize(16)
              .padding(16)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .onChange((value: string) => {
                this.reply = value;
              })
            
            Button('提交处理')
              .width('100%')
              .height(50)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
              .backgroundColor('#007DFF')
              .borderRadius(25)
              .margin({ top: 24 })
              .onClick(() => {
                this.confirmHandleFeedback();
              })
          }
          .width('100%')
          .padding(16)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .margin({ top: 16, bottom: 16 })
        }
        .width('90%')
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 