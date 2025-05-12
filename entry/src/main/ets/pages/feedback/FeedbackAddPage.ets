import router from '@ohos.router';
import { Feedback } from '../../model/AnnouncementModel';
import { Constants } from '../../common/constants/Constants';
import { Routes } from '../../common/constants/Routes';
import { FeedbackService } from '../../service/FeedbackService';
import { LoadingDialog } from '../../common/components/LoadingDialog';
import { ToastUtil } from '../../common/components/ToastUtil';
import { ConfirmDialog } from '../../common/components/ConfirmDialog';

@Entry
@Component
struct FeedbackAddPage {
  @State isLoading: boolean = false;
  @State feedback: Feedback = new Feedback();
  @State titleError: string = '';
  @State contentError: string = '';
  
  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({ message: '提交中...' }),
    autoCancel: false,
    alignment: DialogAlignment.Center
  });
  
  private confirmDialogController: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      title: '确认提交',
      message: '是否确认提交反馈？',
      confirmText: '确认',
      cancelText: '取消',
      onConfirm: () => this.submitFeedback()
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  });
  
  aboutToAppear() {
    console.info('【FeedbackAddPage】页面即将显示');
    // 默认设置反馈类型为建议
    this.feedback.type = Constants.FEEDBACK_TYPE.SUGGESTION;
  }
  
  /**
   * 验证表单
   */
  validateForm(): boolean {
    let isValid = true;
    
    // 验证标题
    if (!this.feedback.title || this.feedback.title.trim() === '') {
      this.titleError = '请输入反馈标题';
      isValid = false;
    } else if (this.feedback.title.length > 50) {
      this.titleError = '标题不能超过50个字符';
      isValid = false;
    } else {
      this.titleError = '';
    }
    
    // 验证内容
    if (!this.feedback.content || this.feedback.content.trim() === '') {
      this.contentError = '请输入反馈内容';
      isValid = false;
    } else if (this.feedback.content.length > 500) {
      this.contentError = '内容不能超过500个字符';
      isValid = false;
    } else {
      this.contentError = '';
    }
    
    return isValid;
  }
  
  /**
   * 确认提交
   */
  confirmSubmit() {
    if (!this.validateForm()) {
      return;
    }
    
    this.confirmDialogController.open();
  }
  
  /**
   * 提交反馈
   */
  async submitFeedback() {
    if (this.isLoading) return;
    
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      // 提交反馈
      const feedbackId = await FeedbackService.addFeedback(this.feedback);
      
      console.info('【FeedbackAddPage】反馈提交成功, ID:', feedbackId);
      ToastUtil.showToast('反馈提交成功');
      
      // 返回反馈列表页面
      setTimeout(() => {
        router.pushUrl({
          url: Routes.FEEDBACK_LIST
        });
      }, 500);
    } catch (error) {
      console.error('【FeedbackAddPage】提交反馈失败:', error);
      ToastUtil.showToast('提交反馈失败');
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
        return '建议';
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
          
          Text('提交反馈')
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
      
      // 表单内容
      Scroll() {
        Column() {
          // 反馈类型选择
          Column() {
            Text('反馈类型')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
            
            Row() {
              // 建议
              Column() {
                Row() {
                  Radio({ value: 'suggestion', group: 'feedbackType' })
                    .checked(this.feedback.type === Constants.FEEDBACK_TYPE.SUGGESTION)
                    .onChange((isChecked) => {
                      if (isChecked) {
                        this.feedback.type = Constants.FEEDBACK_TYPE.SUGGESTION;
                      }
                    })
                  
                  Text('建议')
                    .fontSize(14)
                    .margin({ left: 8 })
                }
                .width('100%')
                .onClick(() => {
                  this.feedback.type = Constants.FEEDBACK_TYPE.SUGGESTION;
                })
              }
              .layoutWeight(1)
              
              // 问题
              Column() {
                Row() {
                  Radio({ value: 'bug', group: 'feedbackType' })
                    .checked(this.feedback.type === Constants.FEEDBACK_TYPE.BUG)
                    .onChange((isChecked) => {
                      if (isChecked) {
                        this.feedback.type = Constants.FEEDBACK_TYPE.BUG;
                      }
                    })
                  
                  Text('问题')
                    .fontSize(14)
                    .margin({ left: 8 })
                }
                .width('100%')
                .onClick(() => {
                  this.feedback.type = Constants.FEEDBACK_TYPE.BUG;
                })
              }
              .layoutWeight(1)
              
              // 咨询
              Column() {
                Row() {
                  Radio({ value: 'question', group: 'feedbackType' })
                    .checked(this.feedback.type === Constants.FEEDBACK_TYPE.QUESTION)
                    .onChange((isChecked) => {
                      if (isChecked) {
                        this.feedback.type = Constants.FEEDBACK_TYPE.QUESTION;
                      }
                    })
                  
                  Text('咨询')
                    .fontSize(14)
                    .margin({ left: 8 })
                }
                .width('100%')
                .onClick(() => {
                  this.feedback.type = Constants.FEEDBACK_TYPE.QUESTION;
                })
              }
              .layoutWeight(1)
            }
            .width('100%')
            .margin({ top: 16 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .margin({ top: 16 })
          
          // 标题输入
          Column() {
            Text('反馈标题')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
            
            TextInput({ placeholder: '请输入反馈标题（不超过50个字符）' })
              .width('100%')
              .height(50)
              .fontSize(16)
              .placeholderColor('#999999')
              .placeholderFont({ size: 16 })
              .margin({ top: 16 })
              .onChange((value) => {
                this.feedback.title = value;
                // 实时验证
                if (this.titleError && value.trim() !== '') {
                  this.titleError = '';
                }
              })
            
            if (this.titleError) {
              Text(this.titleError)
                .fontSize(14)
                .fontColor(Color.Red)
                .alignSelf(ItemAlign.Start)
                .margin({ top: 4 })
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .margin({ top: 16 })
          
          // 内容输入
          Column() {
            Text('反馈内容')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
            
            TextArea({ placeholder: '请详细描述您的反馈内容（不超过500个字符）' })
              .width('100%')
              .height(200)
              .fontSize(16)
              .placeholderColor('#999999')
              .placeholderFont({ size: 16 })
              .margin({ top: 16 })
              .onChange((value) => {
                this.feedback.content = value;
                // 实时验证
                if (this.contentError && value.trim() !== '') {
                  this.contentError = '';
                }
              })
            
            if (this.contentError) {
              Text(this.contentError)
                .fontSize(14)
                .fontColor(Color.Red)
                .alignSelf(ItemAlign.Start)
                .margin({ top: 4 })
            }
            
            Text(`${this.feedback.content ? this.feedback.content.length : 0}/500`)
              .fontSize(14)
              .fontColor('#999999')
              .alignSelf(ItemAlign.End)
              .margin({ top: 8 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .margin({ top: 16 })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
      .backgroundColor('#F5F5F5')
      
      // 提交按钮
      Button('提交反馈', { type: ButtonType.Capsule })
        .width('90%')
        .height(50)
        .backgroundColor('#2196F3')
        .margin({ bottom: 20, top: 20 })
        .onClick(() => this.confirmSubmit())
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 