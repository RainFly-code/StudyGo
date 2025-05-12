import router from '@ohos.router';
import { Routes } from '../../common/constants/Routes';
import { Constants } from '../../common/constants/Constants';
import { ToastUtil } from '../../common/components/ToastUtil';
import { Announcement } from '../../model/AnnouncementModel';
import { StudyRoom } from '../../model/StudyRoomModel';
import { User } from '../../model/UserModel';
import { AnnouncementService } from '../../service/AnnouncementService';
import { PreferenceUtil } from '../../common/utils/PreferenceUtil';
import { StudyRoomService } from '../../service/StudyRoomService';

@Entry
@Component
struct HomePage {
  @State currentIndex: number = 0;
  @State searchText: string = '';
  @State user: User = new User();
  @State announcements: Announcement[] = [];
  @State studyRooms: StudyRoom[] = [];
  @State isRefreshing: boolean = false;
  
  // TabBar图标
  private tabIcons: Resource[] = [
    $r('app.media.ic_home'),
    $r('app.media.ic_reservation'),
    $r('app.media.ic_feedback'),
    $r('app.media.ic_user')
  ];
  
  // TabBar标题
  private tabTitles: string[] = ['首页', '我的预约', '反馈', '我的'];
  
  aboutToAppear() {
    // 加载用户信息
    this.loadUserInfo();
    // 加载首页数据
    this.loadHomeData();
  }
  
  /**
   * 加载用户信息
   */
  async loadUserInfo() {
    try {
      const user = await PreferenceUtil.getUser();
      if (user) {
        this.user = user;
      }
    } catch (error) {
      console.error('加载用户信息失败:', error);
    }
  }
  
  /**
   * 加载首页数据
   */
  async loadHomeData() {
    this.isRefreshing = true;
    try {
      // 加载公告列表
      const announcementResult = await AnnouncementService.getAnnouncementList(1, 5);
      if (announcementResult && announcementResult.records) {
        this.announcements = announcementResult.records;
      }
      
      // 加载自习室列表
      const studyRoomResult = await StudyRoomService.getStudyRoomList(1, 10);
      if (studyRoomResult && studyRoomResult.records) {
        this.studyRooms = studyRoomResult.records;
      }
    } catch (error) {
      console.error('加载首页数据失败:', error);
      ToastUtil.showError('加载首页数据失败');
    } finally {
      this.isRefreshing = false;
    }
  }
  
  /**
   * 首页页面构建
   */
  @Builder
  HomeTabContent() {
    Refresh({ refreshing: $$this.isRefreshing, offset: 120, friction: 100 }) {
      Scroll() {
        Column() {
          // 搜索栏
          Row() {
            Image($r('app.media.ic_search'))
              .width(24)
              .height(24)
              .margin({ right: 8 })
          
            TextInput({ placeholder: '搜索自习室', text: this.searchText })
              .layoutWeight(1)
              .backgroundColor(Color.Transparent)
              .placeholderColor('#999999')
              .fontSize(16)
              .height(40)
              .onChange((value: string) => {
                this.searchText = value;
              })
              .onSubmit(() => {
                if (this.searchText) {
                  router.pushUrl({
                    url: Routes.STUDY_ROOM_LIST,
                    params: {
                      keyword: this.searchText
                    }
                  });
                }
              })
          }
          .width('90%')
          .height(50)
          .borderRadius(25)
          .backgroundColor('#F5F5F5')
          .padding({ left: 16, right: 16 })
          .margin({ top: 16, bottom: 16 })
        
          // 轮播图广告
          Swiper() {
            Image($r('app.media.banner1'))
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)
          
            Image($r('app.media.banner2'))
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)
          
            Image($r('app.media.banner3'))
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)
          }
          .width('90%')
          .height(180)
          .borderRadius(16)
          .autoPlay(true)
          .interval(3000)
          .indicatorStyle({ color: '#FF0000', selectedColor: '#0D9FFB' })
          .margin({ bottom: 20 })
          // 最新公告
          Column() {
            Row() {
              Text('最新公告')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
            
              Text('更多 >')
                .fontSize(14)
                .fontColor('#666666')
                .onClick(() => {
                  router.pushUrl({ url: Routes.ANNOUNCEMENT_LIST });
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 16 })
          
            // 公告列表
            if (this.announcements.length > 0) {
              ForEach(this.announcements, (item: Announcement) => {
                Column() {
                  Text(item.title)
                    .fontSize(16)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#333333')
                    .width('100%')
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .maxLines(1)
                
                  Text(item.content)
                    .fontSize(14)
                    .fontColor('#666666')
                    .width('100%')
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .maxLines(2)
                    .margin({ top: 4 })
                
                  Text(item.createTime ? item.createTime.split(' ')[0] : '')
                    .fontSize(12)
                    .fontColor('#999999')
                    .margin({ top: 8 })
                    .alignSelf(ItemAlign.End)
                }
                .width('100%')
                .padding(16)
                .borderRadius(8)
                .backgroundColor('#F5F5F5')
                .margin({ bottom: 10 })
                .onClick(() => {
                  router.pushUrl({
                    url: Routes.ANNOUNCEMENT_DETAIL,
                    params: { id: item.id }
                  });
                })
              })
            } else {
              Text('暂无公告')
                .fontSize(16)
                .fontColor('#999999')
                .margin({ top: 20, bottom: 20 })
            }
          }
          .width('90%')
          .margin({ bottom: 20 })
        
          // 热门自习室
          Column() {
            Row() {
              Text('热门自习室')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
            
              Text('更多 >')
                .fontSize(14)
                .fontColor('#666666')
                .onClick(() => {
                  router.pushUrl({ url: Routes.STUDY_ROOM_LIST });
                })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            .margin({ bottom: 16 })
          
            // 自习室列表
            if (this.studyRooms.length > 0) {
              ForEach(this.studyRooms, (item: StudyRoom) => {
                Row() {
                  Image(item.imageUrl || $r('app.media.default_room'))
                    .width(80)
                    .height(80)
                    .borderRadius(8)
                    .objectFit(ImageFit.Cover)
                
                  Column() {
                    Text(item.name)
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#333333')
                      .width('100%')
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .maxLines(1)
                  
                    Text(item.location)
                      .fontSize(14)
                      .fontColor('#666666')
                      .width('100%')
                      .margin({ top: 4 })
                  
                    Row() {
                      Text(`开放时间: ${item.openTime}-${item.closeTime}`)
                        .fontSize(12)
                        .fontColor('#999999')
                    
                      Text(`座位数: ${item.capacity}`)
                        .fontSize(12)
                        .fontColor('#999999')
                        .margin({ left: 16 })
                    }
                    .width('100%')
                    .margin({ top: 8 })
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  .margin({ left: 12 })
                
                  Image($r('app.media.ic_arrow_right'))
                    .width(16)
                    .height(16)
                    .margin({ left: 8 })
                }
                .width('100%')
                .padding(16)
                .borderRadius(8)
                .backgroundColor('#F5F5F5')
                .margin({ bottom: 10 })
                .onClick(() => {
                  router.pushUrl({
                    url: Routes.STUDY_ROOM_DETAIL,
                    params: { id: item.id }
                  });
                })
              })
            } else {
              Text('暂无自习室')
                .fontSize(16)
                .fontColor('#999999')
                .margin({ top: 20, bottom: 20 })
            }
          }
          .width('90%')
          .margin({ bottom: 20 })
        }
        .width('100%')
      }
      .width('100%')
      .edgeEffect(EdgeEffect.Spring)
    }
    .onStateChange((refreshStatus: RefreshStatus) => {
      if (refreshStatus === RefreshStatus.Refresh) {
        this.loadHomeData();
      }
    })
  }
  
  /**
   * 我的预约页面构建
   */
  @Builder
  ReservationTabContent() {
    Column() {
      Text('我的预约')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ top: 16, bottom: 16 })
      
      Button('查看我的预约')
        .width('80%')
        .height(50)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#007DFF')
        .borderRadius(25)
        .margin({ top: 100 })
        .onClick(() => {
          router.pushUrl({ url: Routes.MY_RESERVATION });
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }
  
  /**
   * 反馈页面构建
   */
  @Builder
  FeedbackTabContent() {
    Column() {
      Text('我的反馈')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ top: 16, bottom: 16 })
      
      Button('查看我的反馈')
        .width('80%')
        .height(50)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#007DFF')
        .borderRadius(25)
        .margin({ top: 100 })
        .onClick(() => {
          router.pushUrl({ url: Routes.FEEDBACK_LIST });
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
  }
  
  /**
   * 我的页面构建
   */
  @Builder
  ProfileTabContent() {
    Stack() {
      Column() {
        // 用户头像和基本信息
        Column() {
          Image(this.user.avatar || $r('app.media.avatar_default'))
            .width(80)
            .height(80)
            .borderRadius(40)
            .margin({ top: 20, bottom: 16 })
          
          Text(this.user.username || '未登录')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 8 })
          
          Text(this.user.role === Constants.ROLE.ADMIN ? '管理员' : '用户')
            .fontSize(14)
            .fontColor('#666666')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor('#F0F0F0')
            .borderRadius(4)
            .margin({ bottom: 20 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        
        // 标题提示
        Text('点击"我的"图标可查看个人信息')
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 16 })
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
  
  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
        TabContent() {
          this.HomeTabContent()
        }
        .tabBar(this.TabBarBuilder(0))
        
        TabContent() {
          this.ReservationTabContent()
        }
        .tabBar(this.TabBarBuilder(1))
        
        TabContent() {
          this.FeedbackTabContent()
        }
        .tabBar(this.TabBarBuilder(2))
        
        TabContent() {
          this.ProfileTabContent()
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
        // 当切换到"我的预约"选项卡时，自动跳转到预约列表页面
        if (index === 1) {
          router.pushUrl({ url: Routes.MY_RESERVATION });
        }
        // 当切换到"反馈"选项卡时，自动跳转到反馈列表页面
        if (index === 2) {
          router.pushUrl({ url: Routes.FEEDBACK_LIST });
        }
        // 当切换到"我的"选项卡时，自动跳转到个人中心页面
        if (index === 3) {
          router.pushUrl({ url: Routes.USER_PROFILE });
        }
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