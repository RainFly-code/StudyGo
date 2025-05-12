import router from '@ohos.router';
import { User } from '../../model/UserModel';
import { Constants } from '../../common/constants/Constants';
import { Routes } from '../../common/constants/Routes';
import { UserService } from '../../service/UserService';
import { PreferenceUtil } from '../../common/utils/PreferenceUtil';
import { LoadingDialog } from '../../common/components/LoadingDialog';
import { ConfirmDialog } from '../../common/components/ConfirmDialog';
import { ToastUtil } from '../../common/components/ToastUtil';

@Entry
@Component
struct UserProfilePage {
  @State user: User = new User();
  @State isEditing: boolean = false;
  @State nameInput: string = '';
  @State emailInput: string = '';
  @State phoneInput: string = '';
  @State isLoading: boolean = false;
  
  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({ message: '加载中...' }),
    autoCancel: false,
    alignment: DialogAlignment.Center
  });
  
  private saveConfirmDialogController: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      title: '保存修改',
      message: '确定要保存修改吗？',
      confirmText: '确定',
      cancelText: '取消',
      onConfirm: () => this.saveUserInfo()
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  });
  
  private logoutConfirmDialogController: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      title: '退出登录',
      message: '确定要退出登录吗？',
      confirmText: '确定',
      cancelText: '取消',
      onConfirm: () => this.logout()
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  });
  
  aboutToAppear() {
    // 加载用户信息
    this.loadUserInfo();
  }
  
  /**
   * 加载用户信息
   */
  async loadUserInfo() {
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      // 先从本地获取
      const localUser = await PreferenceUtil.getUser();
      if (localUser) {
        this.user = localUser;
        this.initInputValues();
      }
      
      // 再从服务器获取最新
      const serverUser = await UserService.getUserInfo();
      if (serverUser) {
        this.user = serverUser;
        this.initInputValues();
        // 更新本地存储
        await PreferenceUtil.saveUser(serverUser);
      }
    } catch (error) {
      console.error('【UserProfilePage】加载用户信息失败:', error);
      ToastUtil.showToast('加载用户信息失败');
    } finally {
      this.isLoading = false;
      this.loadingDialogController.close();
    }
  }
  
  /**
   * 初始化输入字段值
   */
  initInputValues() {
    this.nameInput = this.user.username || '';
    this.emailInput = this.user.email || '';
    this.phoneInput = this.user.phone || '';
  }
  
  /**
   * 保存用户信息确认
   */
  confirmSave() {
    this.saveConfirmDialogController.open();
  }
  
  /**
   * 保存用户信息
   */
  async saveUserInfo() {
    if (this.isLoading) return;
    
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      // 验证输入
      if (!this.nameInput.trim()) {
        ToastUtil.showToast('用户名不能为空');
        return;
      }
      
      // 构建更新的用户信息
      const updatedUser: User = {
        name: this.nameInput,
        email: this.emailInput,
        phone: this.phoneInput,
        username: this.nameInput,
        role: this.user.role
      };
      
      const success = await UserService.updateUserInfo(updatedUser);
      
      if (success) {
        ToastUtil.showToast('保存成功');
        
        // 更新本地用户信息
        this.user.name = this.nameInput;
        this.user.username = this.nameInput;
        this.user.email = this.emailInput;
        this.user.phone = this.phoneInput;
        
        // 退出编辑模式
        this.isEditing = false;
      } else {
        ToastUtil.showToast('保存失败');
      }
    } catch (error) {
      console.error('【UserProfilePage】保存用户信息失败:', error);
      ToastUtil.showToast('保存用户信息失败');
    } finally {
      this.isLoading = false;
      this.loadingDialogController.close();
    }
  }
  
  /**
   * 确认退出登录
   */
  confirmLogout() {
    this.logoutConfirmDialogController.open();
  }
  
  /**
   * 退出登录
   */
  async logout() {
    try {
      await UserService.logout();
      ToastUtil.showToast('退出登录成功');
      
      // 返回登录页
      router.replaceUrl({
        url: Routes.LOGIN
      });
    } catch (error) {
      console.error('【UserProfilePage】退出登录失败:', error);
      ToastUtil.showToast('退出登录失败');
    }
  }
  
  /**
   * 修改密码
   */
  navigateToPasswordChange() {
    router.pushUrl({
      url: Routes.PASSWORD_CHANGE
    });
  }
  
  /**
   * 获取角色名称
   */
  getRoleName(role: number): string {
    switch (role) {
      case Constants.ROLE.ADMIN:
        return '管理员';
      case Constants.ROLE.USER:
        return '用户';
      default:
        return '未知';
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
          
          Text('个人中心')
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
      
      // 主内容区
      Scroll() {
        Column() {
          // 头像和用户名
          Column() {
            Image(this.user.avatar || $r('app.media.avatar_default'))
              .width(80)
              .height(80)
              .borderRadius(40)
              .margin({ top: 20, bottom: 16 })
            
            Text(this.user.username)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .margin({ bottom: 8 })
            
            Text(this.getRoleName(this.user.role))
              .fontSize(14)
              .fontColor('#666666')
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .backgroundColor('#F0F0F0')
              .borderRadius(4)
              .margin({ bottom: 20 })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          
          // 个人信息卡片
          Column() {
            Row() {
              Text('个人信息')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
              
              Blank()
              
              if (this.isEditing) {
                Button('保存', { type: ButtonType.Capsule })
                  .height(32)
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#2196F3')
                  .onClick(() => this.confirmSave())
                
                Button('取消', { type: ButtonType.Capsule })
                  .height(32)
                  .fontSize(14)
                  .fontColor('#666666')
                  .backgroundColor('#F5F5F5')
                  .margin({ left: 12 })
                  .onClick(() => {
                    this.isEditing = false;
                    this.initInputValues();
                  })
              } else {
                Button('编辑', { type: ButtonType.Capsule })
                  .height(32)
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#2196F3')
                  .onClick(() => {
                    this.isEditing = true;
                  })
              }
            }
            .width('100%')
            .padding({ bottom: 12 })
            .margin({ bottom: 16 })
            .borderWidth({ bottom: 0.5 })
            .borderColor('#EEEEEE')
            
            // 姓名
            Row() {
              Text('用户名')
                .fontSize(16)
                .fontColor('#666666')
                .width(80)
              
              if (this.isEditing) {
                TextInput({ text: this.nameInput })
                  .width('100%')
                  .height(40)
                  .backgroundColor('#F5F5F5')
                  .fontSize(16)
                  .padding({ left: 8, right: 8 })
                  .borderRadius(4)
                  .onChange((value: string) => {
                    this.nameInput = value;
                  })
              } else {
                Text(this.user.username || '未设置')
                  .fontSize(16)
                  .fontColor('#333333')
                  .layoutWeight(1)
              }
            }
            .width('100%')
            .margin({ bottom: 16 })
            
            // 邮箱
            Row() {
              Text('邮箱')
                .fontSize(16)
                .fontColor('#666666')
                .width(80)
              
              if (this.isEditing) {
                TextInput({ text: this.emailInput })
                  .width('100%')
                  .height(40)
                  .backgroundColor('#F5F5F5')
                  .fontSize(16)
                  .padding({ left: 8, right: 8 })
                  .borderRadius(4)
                  .onChange((value: string) => {
                    this.emailInput = value;
                  })
              } else {
                Text(this.user.email || '未设置')
                  .fontSize(16)
                  .fontColor('#333333')
                  .layoutWeight(1)
              }
            }
            .width('100%')
            .margin({ bottom: 16 })
            
            // 手机号
            Row() {
              Text('手机号')
                .fontSize(16)
                .fontColor('#666666')
                .width(80)
              
              if (this.isEditing) {
                TextInput({ text: this.phoneInput })
                  .width('100%')
                  .height(40)
                  .backgroundColor('#F5F5F5')
                  .fontSize(16)
                  .padding({ left: 8, right: 8 })
                  .borderRadius(4)
                  .onChange((value: string) => {
                    this.phoneInput = value;
                  })
              } else {
                Text(this.user.phone || '未设置')
                  .fontSize(16)
                  .fontColor('#333333')
                  .layoutWeight(1)
              }
            }
            .width('100%')
            .margin({ bottom: 16 })
            
            // 注册时间
            Row() {
              Text('注册时间')
                .fontSize(16)
                .fontColor('#666666')
                .width(80)
              
              Text(this.user.createTime || '未知')
                .fontSize(16)
                .fontColor('#333333')
                .layoutWeight(1)
            }
            .width('100%')
            .margin({ bottom: 16 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .margin({ bottom: 16 })
          
          // 账号安全
          Column() {
            Text('账号安全')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .width('100%')
              .margin({ bottom: 16 })
            
            // 修改密码
            Row() {
              Text('修改密码')
                .fontSize(16)
                .fontColor('#333333')
              
              Blank()
              
              Image($r('app.media.ic_arrow_right'))
                .width(16)
                .height(16)
            }
            .width('100%')
            .height(50)
            .onClick(() => this.navigateToPasswordChange())
            
            // 退出登录
            Row() {
              Text('退出登录')
                .fontSize(16)
                .fontColor('#F44336')
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .height(50)
            .justifyContent(FlexAlign.Center)
            .margin({ top: 32 })
            .onClick(() => this.confirmLogout())
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
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