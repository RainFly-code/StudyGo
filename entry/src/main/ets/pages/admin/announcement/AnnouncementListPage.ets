import router from '@ohos.router';
import { Routes } from '../../../common/constants/Routes';
import { Constants } from '../../../common/constants/Constants';
import { ToastUtil } from '../../../common/components/ToastUtil';
import { LoadingDialog } from '../../../common/components/LoadingDialog';
import { ConfirmDialog } from '../../../common/components/ConfirmDialog';
import { Announcement } from '../../../model/AnnouncementModel';
import { AnnouncementService } from '../../../service/AnnouncementService';

@Entry
@Component
struct AnnouncementListPage {
  @State announcements: Announcement[] = [];
  @State isLoading: boolean = false;
  @State isEmpty: boolean = false;
  @State currentPage: number = 1;
  @State pageSize: number = 10;
  @State total: number = 0;
  @State keyword: string = '';
  @State currentStatus: number | undefined = undefined;
  
  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({ message: '加载中...' }),
    alignment: DialogAlignment.Center,
    autoCancel: false,
    customStyle: true
  });
  
  private confirmDialogController: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      title: '删除公告',
      message: '确定要删除此公告吗？',
      onConfirm: () => {}
    }),
    autoCancel: true,
    customStyle: true
  });
  
  aboutToAppear() {
    this.loadAnnouncements();
  }
  
  /**
   * 加载公告列表
   */
  async loadAnnouncements() {
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      const result = await AnnouncementService.getAnnouncementList(
        this.currentPage,
        this.pageSize,
        this.keyword || undefined,
        this.currentStatus
      );
      
      this.announcements = result.records || [];
      this.total = result.total || 0;
      this.isEmpty = this.announcements.length === 0;
      
      console.info('公告列表:', JSON.stringify(this.announcements));
    } catch (error) {
      console.error('获取公告列表失败:', error);
      ToastUtil.showError('获取公告列表失败: ' + error.message);
    } finally {
      this.isLoading = false;
      this.loadingDialogController.close();
    }
  }
  
  /**
   * 确认删除公告
   */
  showDeleteConfirm(id: number) {
    this.confirmDialogController = new CustomDialogController({
      builder: ConfirmDialog({
        title: '删除公告',
        message: '确定要删除此公告吗？',
        onConfirm: async () => {
          await this.deleteAnnouncement(id);
        }
      }),
      autoCancel: true,
      customStyle: true
    });
    
    this.confirmDialogController.open();
  }
  
  /**
   * 删除公告
   */
  async deleteAnnouncement(id: number) {
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      const result = await AnnouncementService.deleteAnnouncement(id);
      if (result) {
        ToastUtil.showSuccess('删除公告成功');
        this.loadAnnouncements();
      } else {
        ToastUtil.showError('删除公告失败');
      }
    } catch (error) {
      console.error('删除公告失败:', error);
      ToastUtil.showError('删除公告失败: ' + error.message);
    } finally {
      this.isLoading = false;
      this.loadingDialogController.close();
    }
  }
  
  /**
   * 获取状态文本及颜色
   */
  getStatusInfo(status: number): { text: string, color: string } {
    switch (status) {
      case Constants.ANNOUNCEMENT_STATUS.DRAFT:
        return { text: '草稿', color: '#FF9800' };
      case Constants.ANNOUNCEMENT_STATUS.PUBLISHED:
        return { text: '已发布', color: '#4CAF50' };
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
        
        Text('公告管理')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          
        Button() {
          Image($r('app.media.ic_add'))
            .width(24)
            .height(24)
        }
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .width(40)
        .height(40)
        .margin({ right: 16 })
        .onClick(() => {
          router.pushUrl({
            url: Routes.ADMIN_ANNOUNCEMENT_EDIT
          });
        })
      }
      .width('100%')
      .height(56)
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#FFFFFF')
      
      // 搜索和筛选
      Column() {
        // 搜索栏
        Row() {
          TextInput({ placeholder: '搜索公告...', text: this.keyword })
            .height(40)
            .borderRadius(20)
            .backgroundColor('#F5F5F5')
            .padding({ left: 16, right: 16 })
            .layoutWeight(1)
            .onChange((value: string) => {
              this.keyword = value;
            })
          
          Button('搜索')
            .height(40)
            .borderRadius(20)
            .margin({ left: 16 })
            .onClick(() => {
              this.currentPage = 1;
              this.loadAnnouncements();
            })
        }
        .width('100%')
        
        // 状态筛选
        Row() {
          Text('状态:')
            .fontSize(14)
            .fontColor('#666666')
            .width(40)
          
          Row() {
            Text('全部')
              .fontSize(14)
              .fontColor(this.currentStatus === undefined ? '#007DFF' : '#666666')
              .fontWeight(this.currentStatus === undefined ? FontWeight.Medium : FontWeight.Normal)
              .onClick(() => {
                this.currentStatus = undefined;
                this.currentPage = 1;
                this.loadAnnouncements();
              })
          }
          .backgroundColor(this.currentStatus === undefined ? '#E6F1FF' : '#F5F5F5')
          .borderRadius(16)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .margin({ right: 8 })
          
          Row() {
            Text('草稿')
              .fontSize(14)
              .fontColor(this.currentStatus === Constants.ANNOUNCEMENT_STATUS.DRAFT ? '#007DFF' : '#666666')
              .fontWeight(this.currentStatus === Constants.ANNOUNCEMENT_STATUS.DRAFT ? FontWeight.Medium : FontWeight.Normal)
              .onClick(() => {
                this.currentStatus = Constants.ANNOUNCEMENT_STATUS.DRAFT;
                this.currentPage = 1;
                this.loadAnnouncements();
              })
          }
          .backgroundColor(this.currentStatus === Constants.ANNOUNCEMENT_STATUS.DRAFT ? '#E6F1FF' : '#F5F5F5')
          .borderRadius(16)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .margin({ right: 8 })
          
          Row() {
            Text('已发布')
              .fontSize(14)
              .fontColor(this.currentStatus === Constants.ANNOUNCEMENT_STATUS.PUBLISHED ? '#007DFF' : '#666666')
              .fontWeight(this.currentStatus === Constants.ANNOUNCEMENT_STATUS.PUBLISHED ? FontWeight.Medium : FontWeight.Normal)
              .onClick(() => {
                this.currentStatus = Constants.ANNOUNCEMENT_STATUS.PUBLISHED;
                this.currentPage = 1;
                this.loadAnnouncements();
              })
          }
          .backgroundColor(this.currentStatus === Constants.ANNOUNCEMENT_STATUS.PUBLISHED ? '#E6F1FF' : '#F5F5F5')
          .borderRadius(16)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        }
        .width('100%')
        .margin({ top: 12 })
      }
      .width('90%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .margin({ top: 1 })
      
      // 公告列表
      if (this.isEmpty) {
        Column() {
          Image($r('app.media.empty_data'))
            .width(120)
            .height(120)
            .margin({ top: 80 })
          
          Text('暂无公告')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
      } else {
        List() {
          ForEach(this.announcements, (announcement: Announcement) => {
            ListItem() {
              Column() {
                // 公告标题和状态
                Row() {
                  Text(announcement.title)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#333333')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  
                  Blank()
                    .layoutWeight(1)
                  
                  Text(this.getStatusInfo(announcement.status).text)
                    .fontSize(12)
                    .fontColor(this.getStatusInfo(announcement.status).color)
                    .backgroundColor(this.getStatusInfo(announcement.status).color + '15')
                    .borderRadius(10)
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                }
                .width('100%')
                
                // 公告内容预览
                Text(announcement.content)
                  .fontSize(14)
                  .fontColor('#666666')
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ top: 8 })
                  .width('100%')
                
                // 底部信息和操作按钮
                Row() {
                  Text(`发布时间: ${announcement.createTime || '未发布'}`)
                    .fontSize(12)
                    .fontColor('#999999')
                  
                  Blank()
                    .layoutWeight(1)
                  
                  Button('编辑')
                    .height(32)
                    .fontSize(14)
                    .fontColor('#007DFF')
                    .backgroundColor(Color.Transparent)
                    .borderRadius(16)
                    .borderWidth(1)
                    .borderColor('#007DFF')
                    .margin({ right: 8 })
                    .onClick(() => {
                      router.pushUrl({
                        url: Routes.ADMIN_ANNOUNCEMENT_EDIT,
                        params: { id: announcement.id }
                      });
                    })
                  
                  Button('删除')
                    .height(32)
                    .fontSize(14)
                    .fontColor('#F44336')
                    .backgroundColor(Color.Transparent)
                    .borderRadius(16)
                    .borderWidth(1)
                    .borderColor('#F44336')
                    .onClick(() => {
                      this.showDeleteConfirm(announcement.id);
                    })
                }
                .width('100%')
                .margin({ top: 12 })
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(8)
            }
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          }, announcement => announcement.id?.toString())
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
                this.loadAnnouncements();
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
                this.loadAnnouncements();
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