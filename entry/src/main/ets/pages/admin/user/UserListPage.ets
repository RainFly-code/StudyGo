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
struct UserListPage {
  @State users: User[] = [];
  @State isLoading: boolean = false;
  @State isEmpty: boolean = false;
  @State currentPage: number = 1;
  @State pageSize: number = 10;
  @State total: number = 0;
  @State keyword: string = '';
  
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
      onConfirm: () => {}
    }),
    autoCancel: true,
    customStyle: true
  });
  
  aboutToAppear() {
    this.loadUsers();
  }
  
  /**
   * 加载用户列表
   */
  async loadUsers() {
    this.isLoading = true;
    this.loadingDialogController.open();
    
    try {
      const result = await UserService.getUserList(
        this.currentPage,
        this.pageSize,
        this.keyword || undefined
      );
      
      this.users = result.records || [];
      this.total = result.total || 0;
      this.isEmpty = this.users.length === 0;
      
      console.info('用户列表:', JSON.stringify(this.users));
    } catch (error) {
      console.error('获取用户列表失败:', error);
      ToastUtil.showError('获取用户列表失败: ' + error.message);
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
        
        Text('用户管理')
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
      
      // 搜索栏
      Row() {
        TextInput({ placeholder: '搜索用户...', text: this.keyword })
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
            this.loadUsers();
          })
      }
      .width('90%')
      .margin({ top: 16, bottom: 16 })
      
      // 用户列表
      if (this.isEmpty) {
        Column() {
          Image($r('app.media.empty_data'))
            .width(120)
            .height(120)
            .margin({ top: 80 })
          
          Text('暂无用户')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 16 })
        }
        .width('100%')
        .layoutWeight(1)
      } else {
        List() {
          ForEach(this.users, (user: User) => {
            ListItem() {
              Column() {
                // 用户基本信息
                Row() {
                  // 头像
                  Image(user.avatar || $r('app.media.avatar_default'))
                    .width(50)
                    .height(50)
                    .borderRadius(25)
                    .margin({ right: 16 })
                  
                  // 用户名和角色
                  Column() {
                    Text(user.name)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#333333')
                    
                    Text(user.username)
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ top: 4 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  
                  // 角色标签
                  Text(this.getRoleName(user.role))
                    .fontSize(12)
                    .fontColor(this.getRoleStyle(user.role).color)
                    .backgroundColor(this.getRoleStyle(user.role).bgColor)
                    .borderRadius(12)
                    .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                }
                .width('100%')
                
                // 联系信息
                Row() {
                  if (user.phone) {
                    Row() {
                      Image($r('app.media.ic_phone'))
                        .width(16)
                        .height(16)
                        .margin({ right: 4 })
                      
                      Text(user.phone)
                        .fontSize(14)
                        .fontColor('#666666')
                    }
                    .margin({ right: 16 })
                  }
                  
                  if (user.email) {
                    Row() {
                      Image($r('app.media.ic_email'))
                        .width(16)
                        .height(16)
                        .margin({ right: 4 })
                      
                      Text(user.email)
                        .fontSize(14)
                        .fontColor('#666666')
                    }
                  }
                }
                .width('100%')
                .margin({ top: 8 })
                
                // 底部信息和操作按钮
                Row() {
                  Text(`ID: ${user.id} | 创建时间: ${user.createTime}`)
                    .fontSize(12)
                    .fontColor('#999999')
                  
                  Blank()
                    .layoutWeight(1)
                  
                  Button('详情')
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
                        url: Routes.ADMIN_USER_DETAIL,
                        params: { id: user.id }
                      });
                    })
                }
                .width('100%')
                .margin({ top: 8 })
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(8)
            }
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          }, user => user.id?.toString())
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
                this.loadUsers();
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
                this.loadUsers();
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