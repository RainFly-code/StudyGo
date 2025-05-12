/**
 * 应用常量定义
 */
export class Constants {
  /**
   * 基础URL
   */
  static readonly BASE_URL: string = 'http://10.0.2.2:8000';
  
  /**
   * 用户角色
   */
  static readonly ROLE = {
    USER: 0,     // 普通用户
    ADMIN: 1     // 管理员
  };
  
  /**
   * 公告状态
   */
  static readonly ANNOUNCEMENT_STATUS = {
    DRAFT: 0,    // 草稿
    PUBLISHED: 1 // 已发布 
  };
  
  /**
   * 反馈状态
   */
  static readonly FEEDBACK_STATUS = {
    PENDING: 0,  // 待处理
    HANDLING: 1, // 处理中
    COMPLETED: 2 // 已完成
  };
  
  /**
   * 反馈类型
   */
  static readonly FEEDBACK_TYPE = {
    SUGGESTION: 0, // 建议
    BUG: 1,        // 投诉
    QUESTION: 2    // 故障报修
  };
  
  /**
   * 预约状态
   */
  static readonly RESERVATION_STATUS = {
    PENDING: 0,   // 待审核
    APPROVED: 1,  // 已通过
    REJECTED: 2,  // 已拒绝
    CANCELLED: 3  // 已取消
  };
  
  /**
   * 座位状态
   */
  static readonly SEAT_STATUS = {
    AVAILABLE: 0,  // 可用
    RESERVED: 1,   // 已预约
    MAINTENANCE: 2 // 维护中
  };
  
  /**
   * 自习室状态
   */
  static readonly STUDY_ROOM_STATUS = {
    OPEN: 0,       // 开放中
    CLOSED: 1,     // 已关闭
    MAINTENANCE: 2 // 维护中
  };
} 