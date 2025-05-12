import router from '@ohos.router';
import { Routes } from '../../../common/constants/Routes';
import { Constants } from '../../../common/constants/Constants';
import { ToastUtil } from '../../../common/components/ToastUtil';
import { LoadingDialog } from '../../../common/components/LoadingDialog';
import { ConfirmDialog } from '../../../common/components/ConfirmDialog';
import { User } from '../../../model/UserModel';
import { UserService } from '../../../service/UserService';

@Entry
@Component
struct UserDetailPage {
  @State user: User = new User();
  @State isLoading: boolean = false;
  
  private userId: number = router.getParams()?.['id'] || 0;
  
  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({ message: '加载中...' }),
    alignment: DialogAlignment.Center,
    autoCancel: false,
    customStyle: true
  });
  
  private confirmDialogController: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      title: '删除用户',
      message: '确定要删除此用户吗？',
      onConfirm: () => {
        this.deleteUser();
      }
    }),
    autoCancel: true,
    customStyle: true
  });
  
  aboutToAppear() {
    this.loadUserDetail();
  }
  
  /**
   * 加载用户详情
   */
  async loadUserDetail() {
    if (!this.userId) {
      ToastUtil.showError('用户ID不能为空');
      router.back();
      return;
    }
    
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      this.user = await UserService.getUserDetail(this.userId);
      console.info('用户详情:', JSON.stringify(this.user));
    } catch (error) {
      console.error('获取用户详情失败:', error);
      ToastUtil.showError('获取用户详情失败: ' + error.message);
      router.back();
    } finally {
      this.isLoading = false;
      this.loadingDialogController.close();
    }
  }
  
  /**
   * 删除用户
   */
  async deleteUser() {
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      const success = await UserService.deleteUser(this.userId);
      if (success) {
        ToastUtil.showSuccess('删除用户成功');
        router.back();
      } else {
        ToastUtil.showError('删除用户失败');
      }
    } catch (error) {
      console.error('删除用户失败:', error);
      ToastUtil.showError('删除用户失败: ' + error.message);
    } finally {
      this.isLoading = false;
      this.loadingDialogController.close();
    }
  }
  
  /**
   * 获取角色名称
   */
  getRoleName(role: number): string {
    switch (role) {
      case Constants.ROLE.ADMIN:
        return '管理员';
      case Constants.ROLE.USER:
        return '普通用户';
      default:
        return '未知';
    }
  }
  
  /**
   * 获取角色样式
   */
  getRoleStyle(role: number): { color: string, bgColor: string } {
    switch (role) {
      case Constants.ROLE.ADMIN:
        return { color: '#FFFFFF', bgColor: '#F44336' };
      case Constants.ROLE.USER:
        return { color: '#FFFFFF', bgColor: '#4CAF50' };
      default:
        return { color: '#666666', bgColor: '#EEEEEE' };
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
        
        Text('用户详情')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
        
        Button() {
          Image($r('app.media.ic_delete'))
            .width(24)
            .height(24)
        }
        .type(ButtonType.Normal)
        .backgroundColor(Color.Transparent)
        .width(40)
        .height(40)
        .margin({ right: 16 })
        .onClick(() => {
          this.confirmDialogController.open();
        })
      }
      .width('100%')
      .height(56)
      .alignItems(VerticalAlign.Center)
      .backgroundColor('#FFFFFF')
      
      // 用户基本信息卡片
      Column() {
        // 头像和用户名
        Row() {
          Image(this.user.avatar || $r('app.media.avatar_default'))
            .width(80)
            .height(80)
            .borderRadius(40)
            .margin({ right: 20 })
          
          Column() {
            Text(this.user.name)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
            
            Text(this.user.username)
              .fontSize(16)
              .fontColor('#666666')
              .margin({ top: 4 })
            
            Row() {
              Text(this.getRoleName(this.user.role))
                .fontSize(14)
                .fontColor(this.getRoleStyle(this.user.role).color)
                .backgroundColor(this.getRoleStyle(this.user.role).bgColor)
                .borderRadius(12)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .margin({ top: 8 })
            }
          }
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ top: 20, bottom: 20 })
        
        // 详细信息
        Column() {
          Text('详细信息')
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .margin({ bottom: 16 })
            .alignSelf(ItemAlign.Start)
          
          // 用户ID
          Row() {
            Text('用户ID:')
              .fontSize(16)
              .fontColor('#666666')
              .width(100)
            
            Text(this.user.id?.toString() || '')
              .fontSize(16)
              .fontColor('#333333')
          }
          .margin({ bottom: 12 })
          
          // 用户名
          Row() {
            Text('用户名:')
              .fontSize(16)
              .fontColor('#666666')
              .width(100)
            
            Text(this.user.username)
              .fontSize(16)
              .fontColor('#333333')
          }
          .margin({ bottom: 12 })
          
          // 姓名
          Row() {
            Text('姓名:')
              .fontSize(16)
              .fontColor('#666666')
              .width(100)
            
            Text(this.user.name)
              .fontSize(16)
              .fontColor('#333333')
          }
          .margin({ bottom: 12 })
          
          // 邮箱
          if (this.user.email) {
            Row() {
              Text('邮箱:')
                .fontSize(16)
                .fontColor('#666666')
                .width(100)
              
              Text(this.user.email)
                .fontSize(16)
                .fontColor('#333333')
            }
            .margin({ bottom: 12 })
          }
          
          // 手机
          if (this.user.phone) {
            Row() {
              Text('手机:')
                .fontSize(16)
                .fontColor('#666666')
                .width(100)
              
              Text(this.user.phone)
                .fontSize(16)
                .fontColor('#333333')
            }
            .margin({ bottom: 12 })
          }
          
          // 学号
          if (this.user.studentId) {
            Row() {
              Text('学号:')
                .fontSize(16)
                .fontColor('#666666')
                .width(100)
              
              Text(this.user.studentId)
                .fontSize(16)
                .fontColor('#333333')
            }
            .margin({ bottom: 12 })
          }
          
          // 角色
          Row() {
            Text('角色:')
              .fontSize(16)
              .fontColor('#666666')
              .width(100)
            
            Text(this.getRoleName(this.user.role))
              .fontSize(16)
              .fontColor('#333333')
          }
          .margin({ bottom: 12 })
          
          // 创建时间
          Row() {
            Text('创建时间:')
              .fontSize(16)
              .fontColor('#666666')
              .width(100)
            
            Text(this.user.createTime || '')
              .fontSize(16)
              .fontColor('#333333')
          }
          .margin({ bottom: 12 })
          
          // 更新时间
          Row() {
            Text('更新时间:')
              .fontSize(16)
              .fontColor('#666666')
              .width(100)
            
            Text(this.user.updateTime || '')
              .fontSize(16)
              .fontColor('#333333')
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .width('90%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ top: 16 })
      
      // 操作按钮
      Row() {
        Button('编辑信息')
          .width('45%')
          .height(50)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .backgroundColor('#007DFF')
          .borderRadius(25)
          .onClick(() => {

          })
        
        Button('删除用户')
          .width('45%')
          .height(50)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .backgroundColor('#F44336')
          .borderRadius(25)
          .margin({ left: 16 })
          .onClick(() => {
            this.confirmDialogController.open();
          })
      }
      .width('90%')
      .justifyContent(FlexAlign.Center)
      .margin({ top: 24, bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 