/**
 * 路由常量
 */
export class Routes {
  // 登录注册相关
  static readonly LOGIN: string = 'pages/login/LoginPage';
  static readonly REGISTER: string = 'pages/login/RegisterPage';
  
  // 用户端页面
  static readonly HOME: string = 'pages/home/HomePage';
  static readonly STUDY_ROOM_LIST: string = 'pages/studyroom/StudyRoomListPage';
  static readonly STUDY_ROOM_DETAIL: string = 'pages/studyroom/StudyRoomDetailPage';
  static readonly SEAT_RESERVATION: string = 'pages/reservation/SeatReservationPage';
  static readonly MY_RESERVATION: string = 'pages/reservation/MyReservationPage';
  static readonly RESERVATION_DETAIL: string = 'pages/reservation/ReservationDetailPage';
  static readonly ANNOUNCEMENT_LIST: string = 'pages/announcement/AnnouncementListPage';
  static readonly ANNOUNCEMENT_DETAIL: string = 'pages/announcement/AnnouncementDetailPage';
  static readonly FEEDBACK_LIST: string = 'pages/feedback/FeedbackListPage';
  static readonly FEEDBACK_DETAIL: string = 'pages/feedback/FeedbackDetailPage';
  static readonly FEEDBACK_ADD: string = 'pages/feedback/FeedbackAddPage';
  static readonly USER_PROFILE: string = 'pages/user/UserProfilePage';
  static readonly PASSWORD_CHANGE: string = 'pages/user/PasswordChangePage';
  
  // 管理员页面
  static readonly ADMIN_HOME: string = 'pages/admin/AdminHomePage';
  static readonly ADMIN_STUDY_ROOM_LIST: string = 'pages/admin/studyroom/StudyRoomListPage';
  static readonly ADMIN_STUDY_ROOM_DETAIL: string = 'pages/admin/studyroom/StudyRoomDetailPage';
  static readonly ADMIN_STUDY_ROOM_EDIT: string = 'pages/admin/studyroom/StudyRoomEditPage';
  static readonly ADMIN_SEAT_MANAGE: string = 'pages/admin/seat/SeatManagePage';
  static readonly ADMIN_RESERVATION_LIST: string = 'pages/admin/reservation/ReservationListPage';
  static readonly ADMIN_RESERVATION_DETAIL: string = 'pages/admin/reservation/ReservationDetailPage';
  static readonly ADMIN_ANNOUNCEMENT_LIST: string = 'pages/admin/announcement/AnnouncementListPage';
  static readonly ADMIN_ANNOUNCEMENT_EDIT: string = 'pages/admin/announcement/AnnouncementEditPage';
  static readonly ADMIN_FEEDBACK_LIST: string = 'pages/admin/feedback/FeedbackListPage';
  static readonly ADMIN_FEEDBACK_DETAIL: string = 'pages/admin/feedback/FeedbackDetailPage';
  static readonly ADMIN_USER_LIST: string = 'pages/admin/user/UserListPage';
  static readonly ADMIN_USER_DETAIL: string = 'pages/admin/user/UserDetailPage';
} 