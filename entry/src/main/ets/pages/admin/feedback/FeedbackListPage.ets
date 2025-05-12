import router from '@ohos.router';
import { Routes } from '../../../common/constants/Routes';
import { Constants } from '../../../common/constants/Constants';
import { ToastUtil } from '../../../common/components/ToastUtil';
import { LoadingDialog } from '../../../common/components/LoadingDialog';
import { Feedback } from '../../../model/FeedbackModel';
import { FeedbackService } from '../../../service/FeedbackService';

@Entry
@Component
struct FeedbackListPage {
  @State feedbacks: Feedback[] = [];
  @State isLoading: boolean = false;
  @State isEmpty: boolean = false;
  @State currentPage: number = 1;
  @State pageSize: number = 10;
  @State total: number = 0;
  @State currentStatus: number | undefined = undefined;
  @State currentType: number | undefined = undefined;
  
  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({ message: '加载中...' }),
    alignment: DialogAlignment.Center,
    autoCancel: false,
    customStyle: true
  });
  
  aboutToAppear() {
    this.loadFeedbacks();
  }
  
  /**
   * 加载反馈列表
   */
  async loadFeedbacks() {
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      const result = await FeedbackService.getFeedbackList(
        this.currentPage,
        this.pageSize,
        this.currentStatus,
        this.currentType
      );
      
      this.feedbacks = result.records || [];
      this.total = result.total || 0;
      this.isEmpty = this.feedbacks.length === 0;
      
      console.info('反馈列表:', JSON.stringify(this.feedbacks));
    } catch (error) {
      console.error('获取反馈列表失败:', error);
      ToastUtil.showError('获取反馈列表失败: ' + error.message);
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
    this.currentType = undefined;
    this.currentPage = 1;
    this.loadFeedbacks();
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
   * 获取类型文本
   */
  getTypeText(type: number): string {
    switch (type) {
      case Constants.FEEDBACK_TYPE.SUGGESTION:
        return '建议';
      case Constants.FEEDBACK_TYPE.BUG:
        return '投诉';
      case Constants.FEEDBACK_TYPE.QUESTION:
        return '故障报修';
      default:
        return '未知';
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
        
        Text('反馈管理')
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
                this.currentPage = 1;
                this.loadFeedbacks();
              })
          }
          .backgroundColor(this.currentStatus === undefined ? '#E6F1FF' : '#F5F5F5')
          .borderRadius(16)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .margin({ right: 8 })
          
          Row() {
            Text('待处理')
              .fontSize(14)
              .fontColor(this.currentStatus === Constants.FEEDBACK_STATUS.PENDING ? '#007DFF' : '#666666')
              .fontWeight(this.currentStatus === Constants.FEEDBACK_STATUS.PENDING ? FontWeight.Medium : FontWeight.Normal)
              .onClick(() => {
                this.currentStatus = Constants.FEEDBACK_STATUS.PENDING;
                this.currentPage = 1;
                this.loadFeedbacks();
              })
          }
          .backgroundColor(this.currentStatus === Constants.FEEDBACK_STATUS.PENDING ? '#E6F1FF' : '#F5F5F5')
          .borderRadius(16)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .margin({ right: 8 })
          
          Row() {
            Text('处理中')
              .fontSize(14)
              .fontColor(this.currentStatus === Constants.FEEDBACK_STATUS.HANDLING ? '#007DFF' : '#666666')
              .fontWeight(this.currentStatus === Constants.FEEDBACK_STATUS.HANDLING ? FontWeight.Medium : FontWeight.Normal)
              .onClick(() => {
                this.currentStatus = Constants.FEEDBACK_STATUS.HANDLING;
                this.currentPage = 1;
                this.loadFeedbacks();
              })
          }
          .backgroundColor(this.currentStatus === Constants.FEEDBACK_STATUS.HANDLING ? '#E6F1FF' : '#F5F5F5')
          .borderRadius(16)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .margin({ right: 8 })
          
          Row() {
            Text('已完成')
              .fontSize(14)
              .fontColor(this.currentStatus === Constants.FEEDBACK_STATUS.COMPLETED ? '#007DFF' : '#666666')
              .fontWeight(this.currentStatus === Constants.FEEDBACK_STATUS.COMPLETED ? FontWeight.Medium : FontWeight.Normal)
              .onClick(() => {
                this.currentStatus = Constants.FEEDBACK_STATUS.COMPLETED;
                this.currentPage = 1;
                this.loadFeedbacks();
              })
          }
          .backgroundColor(this.currentStatus === Constants.FEEDBACK_STATUS.COMPLETED ? '#E6F1FF' : '#F5F5F5')
          .borderRadius(16)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        }
        .width('100%')
        .margin({ top: 8 })
        
        // 类型筛选
        Row() {
          Text('类型:')
            .fontSize(14)
            .fontColor('#666666')
            .width(50)
          
          Row() {
            Text('全部')
              .fontSize(14)
              .fontColor(this.currentType === undefined ? '#007DFF' : '#666666')
              .fontWeight(this.currentType === undefined ? FontWeight.Medium : FontWeight.Normal)
              .onClick(() => {
                this.currentType = undefined;
                this.currentPage = 1;
                this.loadFeedbacks();
              })
          }
          .backgroundColor(this.currentType === undefined ? '#E6F1FF' : '#F5F5F5')
          .borderRadius(16)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .margin({ right: 8 })
          
          Row() {
            Text('建议')
              .fontSize(14)
              .fontColor(this.currentType === Constants.FEEDBACK_TYPE.SUGGESTION ? '#007DFF' : '#666666')
              .fontWeight(this.currentType === Constants.FEEDBACK_TYPE.SUGGESTION ? FontWeight.Medium : FontWeight.Normal)
              .onClick(() => {
                this.currentType = Constants.FEEDBACK_TYPE.SUGGESTION;
                this.currentPage = 1;
                this.loadFeedbacks();
              })
          }
          .backgroundColor(this.currentType === Constants.FEEDBACK_TYPE.SUGGESTION ? '#E6F1FF' : '#F5F5F5')
          .borderRadius(16)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .margin({ right: 8 })
          
          Row() {
            Text('错误')
              .fontSize(14)
              .fontColor(this.currentType === Constants.FEEDBACK_TYPE.BUG ? '#007DFF' : '#666666')
              .fontWeight(this.currentType === Constants.FEEDBACK_TYPE.BUG ? FontWeight.Medium : FontWeight.Normal)
              .onClick(() => {
                this.currentType = Constants.FEEDBACK_TYPE.BUG;
                this.currentPage = 1;
                this.loadFeedbacks();
              })
          }
          .backgroundColor(this.currentType === Constants.FEEDBACK_TYPE.BUG ? '#E6F1FF' : '#F5F5F5')
          .borderRadius(16)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .margin({ right: 8 })
          
          Row() {
            Text('问题')
              .fontSize(14)
              .fontColor(this.currentType === Constants.FEEDBACK_TYPE.QUESTION ? '#007DFF' : '#666666')
              .fontWeight(this.currentType === Constants.FEEDBACK_TYPE.QUESTION ? FontWeight.Medium : FontWeight.Normal)
              .onClick(() => {
                this.currentType = Constants.FEEDBACK_TYPE.QUESTION;
                this.currentPage = 1;
                this.loadFeedbacks();
              })
          }
          .backgroundColor(this.currentType === Constants.FEEDBACK_TYPE.QUESTION ? '#E6F1FF' : '#F5F5F5')
          .borderRadius(16)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        }
        .width('100%')
        .margin({ top: 12 })
        
        // 重置按钮
        Button('重置筛选')
          .height(36)
          .fontSize(14)
          .fontColor('#666666')
          .backgroundColor('#F5F5F5')
          .fontWeight(FontWeight.Medium)
          .borderRadius(18)
          .margin({ top: 16 })
          .onClick(() => {
            this.resetFilters();
          })
      }
      .width('90%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .margin({ top: 1 })
      
      // 反馈列表
      if (this.isEmpty) {
        Column() {
          Image($r('app.media.empty_data'))
            .width(120)
            .height(120)
            .margin({ top: 80 })
          
          Text('暂无反馈')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
      } else {
        List() {
          ForEach(this.feedbacks, (feedback: Feedback) => {
            ListItem() {
              Column() {
                // 反馈标题和状态
                Row() {
                  Text(`[${this.getTypeText(feedback.type)}] ${feedback.title}`)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#333333')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  
                  Blank()
                    .layoutWeight(1)
                  
                  Text(this.getStatusInfo(feedback.status).text)
                    .fontSize(12)
                    .fontColor(this.getStatusInfo(feedback.status).color)
                    .backgroundColor(this.getStatusInfo(feedback.status).color + '15')
                    .borderRadius(10)
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                }
                .width('100%')
                
                // 反馈内容预览
                Text(feedback.content)
                  .fontSize(14)
                  .fontColor('#666666')
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ top: 8 })
                  .width('100%')
                
                // 用户信息
                Text(`用户ID: ${feedback.userId}  |  提交时间: ${feedback.createTime}`)
                  .fontSize(12)
                  .fontColor('#999999')
                  .margin({ top: 8 })
                  .width('100%')
                
                // 操作按钮
                Row() {
                  Button('详情')
                    .height(32)
                    .fontSize(14)
                    .fontColor('#007DFF')
                    .backgroundColor(Color.Transparent)
                    .borderRadius(16)
                    .borderWidth(1)
                    .borderColor('#007DFF')
                    .onClick(() => {
                      router.pushUrl({
                        url: Routes.ADMIN_FEEDBACK_DETAIL,
                        params: { id: feedback.id }
                      });
                    })
                }
                .width('100%')
                .justifyContent(FlexAlign.End)
                .margin({ top: 8 })
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(8)
            }
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          }, feedback => feedback.id?.toString())
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
                this.loadFeedbacks();
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
                this.loadFeedbacks();
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