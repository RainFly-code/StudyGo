import { Constants } from '../../common/constants/Constants';
import { Routes } from '../../common/constants/Routes';
import { LoadingDialog } from '../../common/components/LoadingDialog';
import { ToastUtil } from '../../common/components/ToastUtil';
import { LoginParams, User } from '../../model/UserModel';
import { UserService } from '../../service/UserService';
import { PreferenceUtil } from '../../common/utils/PreferenceUtil';
import router from '@ohos.router';

@Entry
@Component
struct LoginPage {
  @State loginParams: LoginParams = new LoginParams();
  @State isLoading: boolean = false;
  @State passwordVisible: boolean = false;
  
  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({ message: '登录中...' }),
    alignment: DialogAlignment.Center,
    autoCancel: false,
    customStyle: true
  });

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('StudyGo')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
      }
      .width('100%')
      .height(56)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      
      // 应用图标
      Image($r('app.media.logo'))
        .width(120)
        .height(120)
        .margin({ top: 60, bottom: 40 })
      
      // 登录标题  
      Text('欢迎登录')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 40 })
      
      // 用户名输入框
      TextInput({ placeholder: '请输入用户名' })
        .width('90%')
        .height(50)
        .backgroundColor('#F5F5F5')
        .placeholderColor('#AAAAAA')
        .fontSize(16)
        .padding({ left: 16, right: 16 })
        .borderRadius(25)
        .margin({ bottom: 16 })
        .onChange((value: string) => {
          this.loginParams.username = value;
        })
      
      // 密码输入框
      Row() {
        TextInput({ placeholder: '请输入密码' })
          .width('100%')
          .height(50)
          .backgroundColor('#F5F5F5')
          .placeholderColor('#AAAAAA')
          .fontSize(16)
          .padding({ left: 16, right: 50 })
          .borderRadius(25)
          .type(this.passwordVisible ? InputType.Normal : InputType.Password)
          .onChange((value: string) => {
            this.loginParams.password = value;
          })
      }
      .width('90%')
      .height(50)
      .margin({ bottom: 30 })
      .alignItems(VerticalAlign.Center)
      
      // 登录按钮
      Button('登 录')
        .width('90%')
        .height(50)
        .borderRadius(25)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#007DFF')
        .onClick(() => {
          this.login();
        })
      
      // 注册/忘记密码
      Row() {
        Text('没有账号？')
          .fontSize(14)
          .fontColor('#666666')
        
        Text('立即注册')
          .fontSize(14)
          .fontColor('#007DFF')
          .onClick(() => {
            router.pushUrl({ url: Routes.REGISTER });
          })
      }
      .width('90%')
      .margin({ top: 20 })
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
  
  /**
   * 登录
   */
  async login() {
    // 验证输入
    if (!this.loginParams.username || !this.loginParams.password) {
      ToastUtil.showWarning('请输入用户名和密码');
      return;
    }
    
    // 显示加载
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      // 调用登录接口
      const user = await UserService.login(this.loginParams);
      
      // 根据用户角色跳转到不同页面
      if (user.role === Constants.ROLE.ADMIN) {
        // 管理员跳转到管理员首页
        router.replaceUrl({ url: Routes.ADMIN_HOME });
      } else {
        // 普通用户跳转到首页
        router.replaceUrl({ url: Routes.HOME });
      }
    } catch (error) {
      console.error('登录失败:', error);
      ToastUtil.showError('登录失败: ' + error.message);
    } finally {
      // 隐藏加载
      this.isLoading = false;
      this.loadingDialogController.close();
    }
  }
  
  aboutToAppear() {
    // 检查是否已登录
    this.checkLoginStatus();
  }
  
  /**
   * 检查登录状态
   */
  async checkLoginStatus() {
    const user = await PreferenceUtil.getUser();
    if (user) {
      // 已登录，根据角色跳转
      if (user.role === Constants.ROLE.ADMIN) {
        router.replaceUrl({ url: Routes.ADMIN_HOME });
      } else {
        router.replaceUrl({ url: Routes.HOME });
      }
    }
  }
} 