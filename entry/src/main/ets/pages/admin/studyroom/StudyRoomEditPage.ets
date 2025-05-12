import router from '@ohos.router';
import { Routes } from '../../../common/constants/Routes';
import { Constants } from '../../../common/constants/Constants';
import { ToastUtil } from '../../../common/components/ToastUtil';
import { StudyRoom } from '../../../model/StudyRoomModel';
import { StudyRoomService } from '../../../service/StudyRoomService';
import { LoadingDialog } from '../../../common/components/LoadingDialog';
import { ConfirmDialog } from '../../../common/components/ConfirmDialog';

@Entry
@Component
struct StudyRoomEditPage {
  @State studyRoom: StudyRoom = new StudyRoom();
  @State isLoadingData: boolean = false;
  @State currentMode: number = 0; // 0=添加模式, 1=编辑模式
  @State currentId: number = 0;
  @State hasUserChanges: boolean = false;
  @State errorMessages: {
    name: string;
    capacity: string;
    openTime: string;
    closeTime: string;
  } = {
    name: '',
    capacity: '',
    openTime: '',
    closeTime: ''
  };
  
  private loadingController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({ message: '处理中...' }),
    autoCancel: false,
    alignment: DialogAlignment.Center
  });
  
  private confirmController: CustomDialogController = null;
  
  aboutToAppear() {
    // 初始化自习室默认值
    this.studyRoom.status = Constants.STUDY_ROOM_STATUS.OPEN;
    this.studyRoom.openTime = '08:00';
    this.studyRoom.closeTime = '22:00';
    
    // 获取路由参数
    try {
      const params = router.getParams();
      if (params && params.hasOwnProperty('id') && params['id']) {
        this.currentId = Number(params['id']);
        this.currentMode = 1; // 编辑模式
        this.fetchRoomDetail();
      } else {
        this.currentMode = 0; // 添加模式
      }
    } catch (err) {
      console.error('路由参数处理错误:', err);
      ToastUtil.showError('页面初始化失败');
    }
  }
  
  fetchRoomDetail() {
    this.isLoadingData = true;
    this.loadingController.open();
    
    StudyRoomService.getStudyRoomDetail(this.currentId)
      .then(roomData => {
        this.studyRoom = roomData;
      })
      .catch(err => {
        console.error('获取自习室详情失败:', err);
        ToastUtil.showError('加载数据失败');
      })
      .finally(() => {
        this.isLoadingData = false;
        this.loadingController.close();
      });
  }
  
  validateForm() {
    let isValid = true;
    const errors = {
      name: '',
      capacity: '',
      openTime: '',
      closeTime: ''
    };
    
    // 验证名称
    if (!this.studyRoom.name) {
      errors.name = '请输入自习室名称';
      isValid = false;
    } else if (this.studyRoom.name.length > 50) {
      errors.name = '名称不能超过50个字符';
      isValid = false;
    }
    
    // 验证容量
    if (!this.studyRoom.capacity) {
      errors.capacity = '请输入座位数量';
      isValid = false;
    } else if (this.studyRoom.capacity <= 0 || this.studyRoom.capacity > 1000) {
      errors.capacity = '座位数量必须在1-1000之间';
      isValid = false;
    }
    
    // 验证开放时间
    if (!this.studyRoom.openTime) {
      errors.openTime = '请输入开放时间';
      isValid = false;
    }
    
    // 验证关闭时间
    if (!this.studyRoom.closeTime) {
      errors.closeTime = '请输入关闭时间';
      isValid = false;
    }
    
    this.errorMessages = errors;
    return isValid;
  }
  
  saveForm() {
    if (!this.validateForm()) {
      ToastUtil.showWarning('请完善表单信息');
      return;
    }
    
    this.isLoadingData = true;
    this.loadingController.open();
    
    // 根据模式决定操作类型
    let saveOperation;
    if (this.currentMode === 1) {
      saveOperation = StudyRoomService.updateStudyRoom(this.currentId, this.studyRoom);
    } else {
      saveOperation = StudyRoomService.addStudyRoom(this.studyRoom);
    }
    
    saveOperation
      .then(success => {
        if (success) {
          ToastUtil.showSuccess(this.currentMode === 1 ? '更新成功' : '添加成功');
          router.back();
        } else {
          ToastUtil.showError(this.currentMode === 1 ? '更新失败' : '添加失败');
        }
      })
      .catch(err => {
        console.error(this.currentMode === 1 ? '更新自习室失败:' : '添加自习室失败:', err);
        ToastUtil.showError(this.currentMode === 1 ? '更新失败' : '添加失败');
      })
      .finally(() => {
        this.isLoadingData = false;
        this.loadingController.close();
      });
  }
  
  confirmCancel() {
    if (!this.hasUserChanges) {
      router.back();
      return;
    }
    
    this.confirmController = new CustomDialogController({
      builder: ConfirmDialog({
        title: '放弃修改',
        message: '您有未保存的修改，确定要放弃吗？',
        confirmText: '放弃',
        cancelText: '继续编辑',
        onConfirm: () => router.back()
      }),
      autoCancel: true,
      alignment: DialogAlignment.Center
    });
    
    this.confirmController.open();
  }
  
  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .margin({ right: 16 })
          .onClick(() => {
            this.confirmCancel();
          })
        
        Text(this.currentMode === 1 ? '编辑自习室' : '添加自习室')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        
        Blank()
          .layoutWeight(1)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      
      // 表单内容
      Scroll() {
        Column() {
          // 基本信息卡片
          Column() {
            Text('基本信息')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 16 })
            
            // 名称
            Column() {
              Text('自习室名称')
                .fontSize(14)
                .fontColor('#333333')
                .alignSelf(ItemAlign.Start)
              
              TextInput({ placeholder: '请输入自习室名称', text: this.studyRoom.name })
                .width('100%')
                .height(50)
                .backgroundColor('#F5F5F5')
                .placeholderColor('#999999')
                .fontSize(16)
                .padding({ left: 16, right: 16 })
                .borderRadius(8)
                .margin({ top: 8 })
                .onChange((value: string) => {
                  this.studyRoom.name = value;
                  this.hasUserChanges = true;
                  this.errorMessages.name = '';
                })
              
              if (this.errorMessages.name) {
                Text(this.errorMessages.name)
                  .fontSize(12)
                  .fontColor('#F44336')
                  .alignSelf(ItemAlign.Start)
                  .margin({ top: 4 })
              }
            }
            .width('100%')
            .margin({ bottom: 16 })
            
            // 座位数
            Column() {
              Text('座位数量')
                .fontSize(14)
                .fontColor('#333333')
                .alignSelf(ItemAlign.Start)
              
              TextInput({ placeholder: '请输入座位数量', text: this.studyRoom.capacity.toString() })
                .width('100%')
                .height(50)
                .backgroundColor('#F5F5F5')
                .placeholderColor('#999999')
                .fontSize(16)
                .padding({ left: 16, right: 16 })
                .borderRadius(8)
                .margin({ top: 8 })
                .type(InputType.Number)
                .onChange((value: string) => {
                  this.studyRoom.capacity = parseInt(value) || 0;
                  this.hasUserChanges = true;
                  this.errorMessages.capacity = '';
                })
              
              if (this.errorMessages.capacity) {
                Text(this.errorMessages.capacity)
                  .fontSize(12)
                  .fontColor('#F44336')
                  .alignSelf(ItemAlign.Start)
                  .margin({ top: 4 })
              }
            }
            .width('100%')
            .margin({ bottom: 16 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .margin({ bottom: 16 })
          
          // 详细信息卡片
          Column() {
            Text('详细信息')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Start)
              .margin({ bottom: 16 })
            
            // 开放时间
            Column() {
              Text('开放时间')
                .fontSize(14)
                .fontColor('#333333')
                .alignSelf(ItemAlign.Start)
              
              TextInput({ placeholder: '请输入开放时间', text: this.studyRoom.openTime })
                .width('100%')
                .height(50)
                .backgroundColor('#F5F5F5')
                .placeholderColor('#999999')
                .fontSize(16)
                .padding({ left: 16, right: 16 })
                .borderRadius(8)
                .margin({ top: 8 })
                .onChange((value: string) => {
                  this.studyRoom.openTime = value;
                  this.hasUserChanges = true;
                  this.errorMessages.openTime = '';
                })
              
              if (this.errorMessages.openTime) {
                Text(this.errorMessages.openTime)
                  .fontSize(12)
                  .fontColor('#F44336')
                  .alignSelf(ItemAlign.Start)
                  .margin({ top: 4 })
              }
              
              Text('格式：HH:MM，例如：08:00')
                .fontSize(12)
                .fontColor('#999999')
                .alignSelf(ItemAlign.Start)
                .margin({ top: 4 })
            }
            .width('100%')
            .margin({ bottom: 16 })
            
            // 关闭时间
            Column() {
              Text('关闭时间')
                .fontSize(14)
                .fontColor('#333333')
                .alignSelf(ItemAlign.Start)
              
              TextInput({ placeholder: '请输入关闭时间', text: this.studyRoom.closeTime })
                .width('100%')
                .height(50)
                .backgroundColor('#F5F5F5')
                .placeholderColor('#999999')
                .fontSize(16)
                .padding({ left: 16, right: 16 })
                .borderRadius(8)
                .margin({ top: 8 })
                .onChange((value: string) => {
                  this.studyRoom.closeTime = value;
                  this.hasUserChanges = true;
                  this.errorMessages.closeTime = '';
                })
              
              if (this.errorMessages.closeTime) {
                Text(this.errorMessages.closeTime)
                  .fontSize(12)
                  .fontColor('#F44336')
                  .alignSelf(ItemAlign.Start)
                  .margin({ top: 4 })
              }
              
              Text('格式：HH:MM，例如：22:00')
                .fontSize(12)
                .fontColor('#999999')
                .alignSelf(ItemAlign.Start)
                .margin({ top: 4 })
            }
            .width('100%')
            .margin({ bottom: 16 })
            
            // 状态
            Column() {
              Text('状态')
                .fontSize(14)
                .fontColor('#333333')
                .alignSelf(ItemAlign.Start)
                .margin({ bottom: 8 })
              
              Row() {
                // 开放中
                Row() {
                  Radio({ value: Constants.STUDY_ROOM_STATUS.OPEN.toString(), group: 'status' })
                    .checked(this.studyRoom.status === Constants.STUDY_ROOM_STATUS.OPEN)
                    .onChange((isChecked: boolean) => {
                      if (isChecked) {
                        this.studyRoom.status = Constants.STUDY_ROOM_STATUS.OPEN;
                        this.hasUserChanges = true;
                      }
                    })
                    .margin({ right: 8 })
                  
                  Text('开放中')
                    .fontSize(14)
                    .fontColor('#333333')
                }
                .layoutWeight(1)
                
                // 已关闭
                Row() {
                  Radio({ value: Constants.STUDY_ROOM_STATUS.CLOSED.toString(), group: 'status' })
                    .checked(this.studyRoom.status === Constants.STUDY_ROOM_STATUS.CLOSED)
                    .onChange((isChecked: boolean) => {
                      if (isChecked) {
                        this.studyRoom.status = Constants.STUDY_ROOM_STATUS.CLOSED;
                        this.hasUserChanges = true;
                      }
                    })
                    .margin({ right: 8 })
                  
                  Text('已关闭')
                    .fontSize(14)
                    .fontColor('#333333')
                }
                .layoutWeight(1)
                
                // 维护中
                Row() {
                  Radio({ value: Constants.STUDY_ROOM_STATUS.MAINTENANCE.toString(), group: 'status' })
                    .checked(this.studyRoom.status === Constants.STUDY_ROOM_STATUS.MAINTENANCE)
                    .onChange((isChecked: boolean) => {
                      if (isChecked) {
                        this.studyRoom.status = Constants.STUDY_ROOM_STATUS.MAINTENANCE;
                        this.hasUserChanges = true;
                      }
                    })
                    .margin({ right: 8 })
                  
                  Text('维护中')
                    .fontSize(14)
                    .fontColor('#333333')
                }
                .layoutWeight(1)
              }
              .width('100%')
            }
            .width('100%')
            .margin({ bottom: 16 })
            
            // 详细描述
            Column() {
              Text('详细描述')
                .fontSize(14)
                .fontColor('#333333')
                .alignSelf(ItemAlign.Start)
              
              TextArea({ placeholder: '请输入自习室详细描述', text: this.studyRoom.description })
                .width('100%')
                .height(150)
                .backgroundColor('#F5F5F5')
                .placeholderColor('#999999')
                .fontSize(16)
                .padding(16)
                .borderRadius(8)
                .margin({ top: 8 })
                .onChange((value: string) => {
                  this.studyRoom.description = value;
                  this.hasUserChanges = true;
                })
            }
            .width('100%')
            .margin({ bottom: 16 })
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .margin({ bottom: 16 })
          
          // 提交按钮
          Row() {
            Button('取消')
              .width('45%')
              .height(50)
              .backgroundColor('#F5F5F5')
              .fontColor('#333333')
              .fontSize(16)
              .borderRadius(8)
              .onClick(() => {
                this.confirmCancel();
              })
            
            Button('保存')
              .width('45%')
              .height(50)
              .backgroundColor('#2196F3')
              .fontColor('#FFFFFF')
              .fontSize(16)
              .borderRadius(8)
              .onClick(() => {
                this.saveForm();
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ bottom: 32 })
        }
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
  }
} 