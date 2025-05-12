import router from '@ohos.router';
import { Routes } from '../../common/constants/Routes';
import { Constants } from '../../common/constants/Constants';
import { ToastUtil } from '../../common/components/ToastUtil';
import { User } from '../../model/UserModel';
import { PreferenceUtil } from '../../common/utils/PreferenceUtil';
import { UserService } from '../../service/UserService';
import { ConfirmDialog } from '../../common/components/ConfirmDialog';

@Entry
@Component
struct AdminHomePage {
  @State currentIndex: number = 0;
  @State user: User = new User();
  
  private tabTitles: string[] = ['首页', '自习室', '预约', '用户'];
  private tabIcons: Resource[] = [
    $r('app.media.ic_home'),
    $r('app.media.ic_study_room'),
    $r('app.media.ic_reservation'),
    $r('app.media.ic_users')
  ];
  
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: ConfirmDialog({
      title: '退出登录',
      message: '确定要退出登录吗？',
      onConfirm: () => this.logout()
    })
  });
  
  aboutToAppear() {
    // 加载用户信息
    this.loadUserInfo();
  }
  
  /**
   * 加载用户信息
   */
  async loadUserInfo() {
    try {
      const user = await PreferenceUtil.getUser();
      if (user) {
        this.user = user;
        // 验证是否为管理员
        if (user.role !== Constants.ROLE.ADMIN) {
          ToastUtil.showWarning('您不是管理员，即将跳转到用户首页');
          setTimeout(() => {
            router.replaceUrl({ url: Routes.HOME });
          }, 1500);
        }
      } else {
        // 未登录则跳转到登录页
        router.replaceUrl({ url: Routes.LOGIN });
      }
    } catch (error) {
      console.error('加载用户信息失败:', error);
    }
  }
  
  /**
   * 退出登录
   */
  async logout() {
    try {
      await UserService.logout();
      router.replaceUrl({ url: Routes.LOGIN });
    } catch (error) {
      console.error('退出登录失败:', error);
      ToastUtil.showError('退出登录失败');
    }
  }
  
  /**
   * 首页内容构建
   */
  @Builder
  HomeTabContent() {
    Column() {
      // 顶部区域
      Row() {
        Column() {
          Text('欢迎回来')
            .fontSize(14)
            .fontColor('#666666')
          
          Text(this.user.name || '管理员')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        
        Blank()
          .layoutWeight(1)
        
        Image(this.user.avatar || $r('app.media.avatar_default'))
          .width(50)
          .height(50)
          .borderRadius(25)
      }
      .width('90%')
      .padding({ top: 20, bottom: 20 })
      
      // 数据统计区域
      Grid() {
        // 自习室数量
        GridItem() {
          Column() {
            Text('总自习室')
              .fontSize(14)
              .fontColor('#666666')
            
            Text('7')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#ffa24f4f')
              .margin({ top: 8 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#F5F5F5')
          .borderRadius(12)
        }
        
        // 座位数量
        GridItem() {
          Column() {
            Text('总座位数')
              .fontSize(14)
              .fontColor('#666666')
            
            Text('72')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#ff50963e')
              .margin({ top: 8 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#F5F5F5')
          .borderRadius(12)
        }
        
        // 用户数量
        GridItem() {
          Column() {
            Text('用户数')
              .fontSize(14)
              .fontColor('#666666')
            
            Text('10')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#ff4d6a8c')
              .margin({ top: 8 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#F5F5F5')
          .borderRadius(12)
        }
        
        // 今日预约
        GridItem() {
          Column() {
            Text('今日预约')
              .fontSize(14)
              .fontColor('#666666')
            
            Text('25')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#ff925353')
              .margin({ top: 8 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#F5F5F5')
          .borderRadius(12)
        }
      }
      .width('90%')
      .height(200)
      .columnsTemplate('1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .columnsGap(16)
      .rowsGap(16)
      .margin({ top: 16, bottom: 24 })
      
      // 管理功能区域
      Text('常用功能')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .alignSelf(ItemAlign.Start)
        .width('90%')
        .margin({ bottom: 16,left:20 })
      
      Grid() {
        // 自习室管理
        GridItem() {
          Column() {
            Image($r('app.media.ic_study_room'))
              .width(40)
              .height(40)
            
            Text('自习室管理')
              .fontSize(14)
              .fontColor('#333333')
              .margin({ top: 8 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            router.pushUrl({ url: Routes.ADMIN_STUDY_ROOM_LIST });
          })
        }
        
        // 座位管理
        GridItem() {
          Column() {
            Image($r('app.media.ic_seat'))
              .width(40)
              .height(40)
            
            Text('座位管理')
              .fontSize(14)
              .fontColor('#333333')
              .margin({ top: 8 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            router.pushUrl({
              url: Routes.ADMIN_SEAT_MANAGE
            });
          })
        }
        
        // 预约管理
        GridItem() {
          Column() {
            Image($r('app.media.ic_reservation'))
              .width(40)
              .height(40)
            
            Text('预约管理')
              .fontSize(14)
              .fontColor('#333333')
              .margin({ top: 8 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            router.pushUrl({ url: Routes.ADMIN_RESERVATION_LIST });
          })
        }
        
        // 用户管理
        GridItem() {
          Column() {
            Image($r('app.media.ic_users'))
              .width(40)
              .height(40)
            
            Text('用户管理')
              .fontSize(14)
              .fontColor('#333333')
              .margin({ top: 8 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            router.pushUrl({ url: Routes.ADMIN_USER_LIST });
          })
        }
        
        // 公告管理
        GridItem() {
          Column() {
            Image($r('app.media.ic_notification'))
              .width(40)
              .height(40)
            
            Text('公告管理')
              .fontSize(14)
              .fontColor('#333333')
              .margin({ top: 8 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            router.pushUrl({ url: Routes.ADMIN_ANNOUNCEMENT_LIST });
          })
        }
        
        // 反馈管理
        GridItem() {
          Column() {
            Image($r('app.media.ic_feedback'))
              .width(40)
              .height(40)
            
            Text('反馈管理')
              .fontSize(14)
              .fontColor('#333333')
              .margin({ top: 8 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            router.pushUrl({ url: Routes.ADMIN_FEEDBACK_LIST });
          })
        }
        
        // 退出登录
        GridItem() {
          Column() {
            Image($r('app.media.ic_logout'))
              .width(40)
              .height(40)
            
            Text('退出登录')
              .fontSize(14)
              .fontColor('#333333')
              .margin({ top: 8 })
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.dialogController.open();
          })
        }
      }
      .width('90%')
      .columnsTemplate('1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr 1fr')
      .columnsGap(16)
      .rowsGap(16)
      .height(300)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
  
  /**
   * 自习室管理页面
   */
  @Builder
  StudyRoomTabContent() {
    Stack() {
      Text('自习室管理')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .onClick(() => {
      router.pushUrl({ url: Routes.ADMIN_STUDY_ROOM_LIST });
    })
  }
  
  /**
   * 预约管理页面
   */
  @Builder
  ReservationTabContent() {
    Stack() {
      Text('预约管理')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .onClick(() => {
      router.pushUrl({ url: Routes.ADMIN_RESERVATION_LIST });
    })
  }
  
  /**
   * 用户管理页面
   */
  @Builder
  UserTabContent() {
    Stack() {
      Text('用户管理')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .onClick(() => {
      router.pushUrl({ url: Routes.ADMIN_USER_LIST });
    })
  }
  
  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
        TabContent() {
          this.HomeTabContent()
        }
        .tabBar(this.TabBarBuilder(0))
        
        TabContent() {
          this.StudyRoomTabContent()
        }
        .tabBar(this.TabBarBuilder(1))
        
        TabContent() {
          this.ReservationTabContent()
        }
        .tabBar(this.TabBarBuilder(2))
        
        TabContent() {
          this.UserTabContent()
        }
        .tabBar(this.TabBarBuilder(3))
      }
      .barHeight(60)
      .width('100%')
      .layoutWeight(1)
      .vertical(false)
      .backgroundColor('#F5F5F5')
      .onChange((index: number) => {
        this.currentIndex = index;
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
  
  @Builder
  TabBarBuilder(index: number) {
    Column() {
      Image(this.tabIcons[index])
        .width(24)
        .height(24)
        .fillColor(this.currentIndex === index ? '#007DFF' : '#999999')
      
      Text(this.tabTitles[index])
        .fontSize(12)
        .fontColor(this.currentIndex === index ? '#007DFF' : '#999999')
        .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
} 