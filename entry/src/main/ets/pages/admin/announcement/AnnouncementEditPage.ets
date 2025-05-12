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
struct AnnouncementEditPage {
  @State announcement: Announcement = new Announcement();
  @State isLoading: boolean = false;
  @State isEdit: boolean = false;
  @State title: string = '';
  @State content: string = '';
  @State status: number = 0;
  
  private announcementId: number = router.getParams()?.['id'] || 0;
  
  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({ message: '加载中...' }),
    alignment: DialogAlignment.Center,
    autoCancel: false,
    customStyle: true
  });
  
  private confirmDialogController: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      title: '提示',
      message: '确定要放弃编辑吗？',
      onConfirm: () => {
        router.back();
      }
    }),
    autoCancel: true,
    customStyle: true
  });
  
  aboutToAppear() {
    this.isEdit = this.announcementId > 0;
    if (this.isEdit) {
      this.loadAnnouncementDetail();
    }
  }
  
  /**
   * 加载公告详情
   */
  async loadAnnouncementDetail() {
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      const announcement = await AnnouncementService.getAnnouncementDetail(this.announcementId);
      this.announcement = announcement;
      this.title = announcement.title;
      this.content = announcement.content;
      this.status = announcement.status;
      
      console.info('公告详情:', JSON.stringify(this.announcement));
    } catch (error) {
      console.error('获取公告详情失败:', error);
      ToastUtil.showError('获取公告详情失败: ' + error.message);
      router.back();
    } finally {
      this.isLoading = false;
      this.loadingDialogController.close();
    }
  }
  
  /**
   * 保存公告
   */
  async saveAnnouncement(isPublish: boolean = false) {
    // 验证输入
    if (!this.title.trim()) {
      ToastUtil.showWarning('请输入公告标题');
      return;
    }
    
    if (!this.content.trim()) {
      ToastUtil.showWarning('请输入公告内容');
      return;
    }
    
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      // 设置公告状态
      const status = isPublish ? Constants.ANNOUNCEMENT_STATUS.PUBLISHED : Constants.ANNOUNCEMENT_STATUS.DRAFT;
      
      // 更新公告对象，保留原有属性
      if (this.isEdit) {
        // 更新现有对象的属性
        this.announcement.title = this.title.trim();
        this.announcement.content = this.content.trim();
        this.announcement.status = status;
      } else {
        // 创建新公告对象
        this.announcement = new Announcement();
        this.announcement.title = this.title.trim();
        this.announcement.content = this.content.trim();
        this.announcement.status = status;
      }
      
      let success = false;
      
      if (this.isEdit) {
        // 编辑已有公告
        console.info('更新公告内容:', JSON.stringify(this.announcement));
        success = await AnnouncementService.updateAnnouncement(this.announcementId, this.announcement);
      } else {
        // 创建新公告
        success = await AnnouncementService.addAnnouncement(this.announcement);
      }
      
      if (success) {
        ToastUtil.showSuccess(isPublish ? '发布公告成功' : '保存草稿成功');
        router.back();
      } else {
        ToastUtil.showError(isPublish ? '发布公告失败' : '保存草稿失败');
      }
    } catch (error) {
      console.error('保存公告失败:', error);
      ToastUtil.showError('保存公告失败: ' + error.message);
    } finally {
      this.isLoading = false;
      this.loadingDialogController.close();
    }
  }
  
  /**
   * 返回前确认
   */
  confirmBack() {
    if (this.title.trim() || this.content.trim()) {
      this.confirmDialogController.open();
    } else {
      router.back();
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
            this.confirmBack();
          })
        
        Text(this.isEdit ? '编辑公告' : '新增公告')
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
      
      // 编辑区域
      Column() {
        // 标题输入
        Text('标题')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)
          .margin({ top: 16, bottom: 8 })
        
        TextInput({ placeholder: '请输入公告标题', text: this.title })
          .width('100%')
          .height(50)
          .fontSize(16)
          .padding(10)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.title = value;
          })
        
        // 内容输入
        Text('内容')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .alignSelf(ItemAlign.Start)
          .margin({ top: 16, bottom: 8 })
        
        TextArea({ placeholder: '请输入公告内容', text: this.content })
          .width('100%')
          .height(240)
          .fontSize(16)
          .padding(10)
          .backgroundColor('#F5F5F5')
          .borderRadius(8)
          .onChange((value: string) => {
            this.content = value;
          })
        
        // 操作按钮
        Row() {
          Button('保存草稿')
            .width('45%')
            .height(50)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .backgroundColor('#FF9800')
            .borderRadius(25)
            .onClick(() => {
              this.saveAnnouncement(false);
            })
          
          Button('发布公告')
            .width('45%')
            .height(50)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .backgroundColor('#4CAF50')
            .borderRadius(25)
            .margin({ left: 16 })
            .onClick(() => {
              this.saveAnnouncement(true);
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 24, bottom: 24 })
      }
      .width('90%')
      .padding(16)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 