import router from '@ohos.router';
import { PasswordParams } from '../../model/UserModel';
import { UserService } from '../../service/UserService';
import { LoadingDialog } from '../../common/components/LoadingDialog';
import { ConfirmDialog } from '../../common/components/ConfirmDialog';
import { ToastUtil } from '../../common/components/ToastUtil';

@Entry
@Component
struct PasswordChangePage {
  @State oldPassword: string = '';
  @State newPassword: string = '';
  @State confirmPassword: string = '';
  @State isLoading: boolean = false;
  @State oldPasswordVisible: boolean = false;
  @State newPasswordVisible: boolean = false;
  @State confirmPasswordVisible: boolean = false;
  @State oldPasswordError: string = '';
  @State newPasswordError: string = '';
  @State confirmPasswordError: string = '';
  
  private loadingDialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({ message: '保存中...' }),
    autoCancel: false,
    alignment: DialogAlignment.Center
  });
  
  private confirmDialogController: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      title: '修改密码',
      message: '确定要修改密码吗？',
      confirmText: '确定',
      cancelText: '取消',
      onConfirm: () => this.changePassword()
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  });
  
  /**
   * 验证表单
   */
  validateForm(): boolean {
    let isValid = true;
    
    // 验证旧密码
    if (!this.oldPassword) {
      this.oldPasswordError = '请输入旧密码';
      isValid = false;
    } else {
      this.oldPasswordError = '';
    }
    
    // 验证新密码
    if (!this.newPassword) {
      this.newPasswordError = '请输入新密码';
      isValid = false;
    } else if (this.newPassword.length < 6) {
      this.newPasswordError = '新密码长度不能小于6位';
      isValid = false;
    } else {
      this.newPasswordError = '';
    }
    
    // 验证确认密码
    if (!this.confirmPassword) {
      this.confirmPasswordError = '请确认新密码';
      isValid = false;
    } else if (this.confirmPassword !== this.newPassword) {
      this.confirmPasswordError = '两次输入的密码不一致';
      isValid = false;
    } else {
      this.confirmPasswordError = '';
    }
    
    return isValid;
  }
  
  /**
   * 确认修改密码
   */
  confirmChange() {
    if (!this.validateForm()) {
      return;
    }
    
    this.confirmDialogController.open();
  }
  
  /**
   * 修改密码
   */
  async changePassword() {
    if (this.isLoading) return;
    
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      const params: PasswordParams = {
        oldPassword: this.oldPassword,
        newPassword: this.newPassword
      };
      
      const success = await UserService.updatePassword(params);
      
      if (success) {
        ToastUtil.showToast('密码修改成功');
        setTimeout(() => {
          router.back();
        }, 1000);
      } else {
        ToastUtil.showToast('密码修改失败');
      }
    } catch (error) {
      console.error('【PasswordChangePage】修改密码失败:', error);
      ToastUtil.showToast('修改密码失败，旧密码可能不正确');
    } finally {
      this.isLoading = false;
      this.loadingDialogController.close();
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
          
          Text('修改密码')
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
      Column() {
        // 旧密码
        Column() {
          Text('旧密码')
            .fontSize(16)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })
          
          Row() {
            TextInput({ placeholder: '请输入旧密码' })
              .width('100%')
              .height(50)
              .fontSize(16)
              .placeholderColor('#999999')
              .placeholderFont({ size: 16 })
              .backgroundColor('#F5F5F5')
              .padding({ left: 16, right: 16 })
              .borderRadius(8)
              .type(this.oldPasswordVisible ? InputType.Normal : InputType.Password)
              .maxLength(20)
              .onChange((value) => {
                this.oldPassword = value;
                if (this.oldPasswordError && value) {
                  this.oldPasswordError = '';
                }
              })
          }
          .width('100%')
          
          if (this.oldPasswordError) {
            Text(this.oldPasswordError)
              .fontSize(14)
              .fontColor('#F44336')
              .alignSelf(ItemAlign.Start)
              .margin({ top: 4 })
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 20 })
        
        // 新密码
        Column() {
          Text('新密码')
            .fontSize(16)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })
          
          Row() {
            TextInput({ placeholder: '请输入新密码（不少于6位）' })
              .width('100%')
              .height(50)
              .fontSize(16)
              .placeholderColor('#999999')
              .placeholderFont({ size: 16 })
              .backgroundColor('#F5F5F5')
              .padding({ left: 16, right: 16 })
              .borderRadius(8)
              .type(this.newPasswordVisible ? InputType.Normal : InputType.Password)
              .maxLength(20)
              .onChange((value) => {
                this.newPassword = value;
                if (this.newPasswordError && value && value.length >= 6) {
                  this.newPasswordError = '';
                }
                // 同时检查确认密码
                if (this.confirmPassword && this.confirmPassword === value) {
                  this.confirmPasswordError = '';
                }
              })
          }
          .width('100%')
          
          if (this.newPasswordError) {
            Text(this.newPasswordError)
              .fontSize(14)
              .fontColor('#F44336')
              .alignSelf(ItemAlign.Start)
              .margin({ top: 4 })
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 20 })
        
        // 确认新密码
        Column() {
          Text('确认新密码')
            .fontSize(16)
            .fontColor('#333333')
            .fontWeight(FontWeight.Medium)
            .alignSelf(ItemAlign.Start)
            .margin({ bottom: 8 })
          
          Row() {
            TextInput({ placeholder: '请再次输入新密码' })
              .width('100%')
              .height(50)
              .fontSize(16)
              .placeholderColor('#999999')
              .placeholderFont({ size: 16 })
              .backgroundColor('#F5F5F5')
              .padding({ left: 16, right: 16 })
              .borderRadius(8)
              .type(this.confirmPasswordVisible ? InputType.Normal : InputType.Password)
              .maxLength(20)
              .onChange((value) => {
                this.confirmPassword = value;
                if (this.confirmPasswordError && value && value === this.newPassword) {
                  this.confirmPasswordError = '';
                }
              })
          }
          .width('100%')
          
          if (this.confirmPasswordError) {
            Text(this.confirmPasswordError)
              .fontSize(14)
              .fontColor('#F44336')
              .alignSelf(ItemAlign.Start)
              .margin({ top: 4 })
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .margin({ bottom: 20 })
        
        // 提示信息
        Text('密码修改成功后，下次登录需要使用新密码')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 16, bottom: 32 })
        
        // 提交按钮
        Button('保存修改', { type: ButtonType.Capsule })
          .width('100%')
          .height(50)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#2196F3')
          .onClick(() => this.confirmChange())
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius({ topLeft: 16, topRight: 16 })
      .margin({ top: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 