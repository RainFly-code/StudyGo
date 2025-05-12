import router from '@ohos.router';
import { Routes } from '../../common/constants/Routes';
import { LoadingDialog } from '../../common/components/LoadingDialog';
import { ToastUtil } from '../../common/components/ToastUtil';
import { RegisterParams } from '../../model/UserModel';
import { UserService } from '../../service/UserService';

@Entry
@Component
struct RegisterPage {
  @State registerParams: RegisterParams = new RegisterParams();
  @State confirmPassword: string = '';
  @State isLoading: boolean = false;
  @State passwordVisible: boolean = false;
  @State confirmPasswordVisible: boolean = false;
  
  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({ message: '注册中...' }),
    alignment: DialogAlignment.Center,
    autoCancel: false,
    customStyle: true
  });
  
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
        
        Text('用户注册')
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
      
      // 注册表单
      Scroll() {
        Column() {
          // 用户名
          Column() {
            Text('用户名')
              .fontSize(16)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 8 })
            
            TextInput({ placeholder: '请输入用户名' })
              .width('100%')
              .height(50)
              .backgroundColor('#F5F5F5')
              .placeholderColor('#AAAAAA')
              .fontSize(16)
              .padding({ left: 16, right: 16 })
              .borderRadius(8)
              .onChange((value: string) => {
                this.registerParams.username = value;
              })
          }
          .width('90%')
          .margin({ top: 20 })
          
          // 密码
          Column() {
            Text('密码')
              .fontSize(16)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 8 })
            
            Row() {
              TextInput({ placeholder: '请输入密码' })
                .width('100%')
                .height(50)
                .backgroundColor('#F5F5F5')
                .placeholderColor('#AAAAAA')
                .fontSize(16)
                .padding({ left: 16, right: 50 })
                .borderRadius(8)
                .type(this.passwordVisible ? InputType.Normal : InputType.Password)
                .onChange((value: string) => {
                  this.registerParams.password = value;
                })
            }
            .width('100%')
            .height(50)
          }
          .width('90%')
          .margin({ top: 16 })
          
          // 确认密码
          Column() {
            Text('确认密码')
              .fontSize(16)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 8 })
            
            Row() {
              TextInput({ placeholder: '请再次输入密码' })
                .width('100%')
                .height(50)
                .backgroundColor('#F5F5F5')
                .placeholderColor('#AAAAAA')
                .fontSize(16)
                .padding({ left: 16, right: 50 })
                .borderRadius(8)
                .type(this.confirmPasswordVisible ? InputType.Normal : InputType.Password)
                .onChange((value: string) => {
                  this.confirmPassword = value;
                })
            }
            .width('100%')
            .height(50)
          }
          .width('90%')
          .margin({ top: 16 })
          
          // 邮箱
          Column() {
            Text('邮箱')
              .fontSize(16)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 8 })
            
            TextInput({ placeholder: '请输入邮箱' })
              .width('100%')
              .height(50)
              .backgroundColor('#F5F5F5')
              .placeholderColor('#AAAAAA')
              .fontSize(16)
              .padding({ left: 16, right: 16 })
              .borderRadius(8)
              .onChange((value: string) => {
                this.registerParams.email = value;
              })
          }
          .width('90%')
          .margin({ top: 16 })
          
          // 手机号
          Column() {
            Text('手机号')
              .fontSize(16)
              .fontColor('#333333')
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 8 })
            
            TextInput({ placeholder: '请输入手机号' })
              .width('100%')
              .height(50)
              .backgroundColor('#F5F5F5')
              .placeholderColor('#AAAAAA')
              .fontSize(16)
              .padding({ left: 16, right: 16 })
              .borderRadius(8)
              .onChange((value: string) => {
                this.registerParams.phone = value;
              })
          }
          .width('90%')
          .margin({ top: 16 })
          
          // 注册按钮
          Button('注 册')
            .width('90%')
            .height(50)
            .borderRadius(25)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .backgroundColor('#007DFF')
            .margin({ top: 40, bottom: 20 })
            .onClick(() => {
              this.register();
            })
          
          // 返回登录
          Row() {
            Text('已有账号？')
              .fontSize(14)
              .fontColor('#666666')
            
            Text('返回登录')
              .fontSize(14)
              .fontColor('#007DFF')
              .onClick(() => {
                router.back();
              })
          }
          .width('90%')
          .margin({ bottom: 30 })
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
  
  /**
   * 注册
   */
  async register() {
    // 验证输入
    if (!this.registerParams.username || !this.registerParams.password || !this.confirmPassword || !this.registerParams.email || !this.registerParams.phone) {
      ToastUtil.showWarning('请填写必要信息');
      return;
    }
    
    // 验证密码是否一致
    if (this.registerParams.password !== this.confirmPassword) {
      ToastUtil.showWarning('两次输入的密码不一致');
      return;
    }
    
    // 显示加载
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      // 调试输出注册参数
      console.info('【RegisterPage】注册参数:', JSON.stringify(this.registerParams));
      
      // 显式设置name为username
      this.registerParams.name = this.registerParams.username;
      
      // 调用注册接口
      const result = await UserService.register(this.registerParams);
      if (result) {
        ToastUtil.showSuccess('注册成功');
        // 跳转到登录页
        router.back();
      } else {
        ToastUtil.showError('注册失败');
      }
    } catch (error) {
      console.error('注册失败:', error);
      ToastUtil.showError('注册失败: ' + error.message);
    } finally {
      // 隐藏加载
      this.isLoading = false;
      this.loadingDialogController.close();
    }
  }
} 