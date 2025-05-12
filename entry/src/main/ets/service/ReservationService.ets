import { HttpUtil } from '../utils/HttpUtil';

/**
 * HTTP响应接口
 */
interface HttpResponse {
  code: number;
  data: any;
  message: string;
}

/**
 * 预约服务
 */
export class ReservationService {
  /**
   * 添加预约
   * @param seatId 座位ID
   * @param date 开始日期
   * @param days 预约天数
   */
  static async addReservation(seatId: number, date: string, days: number): Promise<boolean> {
    try {
      // 使用formUrl方式提交，而不是JSON
      const url = `/api/reservation/add?seatId=${seatId}&date=${date}&days=${days}`;
      const response = await HttpUtil.post(url) as HttpResponse;
      
      return response.code === 200;
    } catch (error) {
      console.error('添加预约失败:', error);
      throw error;
    }
  }
  
  /**
   * 获取用户预约列表
   * @param page 页码
   * @param size 每页大小
   * @param status 预约状态
   */
  static async getUserReservations(page: number = 1, size: number = 10, status?: number): Promise<any> {
    try {
      console.info('【ReservationService】getUserReservations - 收到参数 status:', status, '类型:', typeof status);
      
      const params: any = { page, size };
      if (status !== undefined && status !== null) {
        params.status = status;
        console.info('【ReservationService】获取预约列表，筛选状态:', status);
      } else {
        console.info('【ReservationService】获取预约列表，无筛选状态');
      }
      
      console.info('【ReservationService】请求参数:', JSON.stringify(params), '，包含status字段:', 'status' in params);
      const response = await HttpUtil.get('/api/reservation/list', params) as HttpResponse;
      
      console.info('【ReservationService】获取到预约列表，记录数:', 
        response.data?.records?.length || 0, 
        '总数:', response.data?.total || 0);
      
      return response.data;
    } catch (error) {
      console.error('获取预约列表失败:', error);
      throw error;
    }
  }
  
  /**
   * 获取预约详情
   * @param id 预约ID
   */
  static async getReservationDetail(id: number): Promise<any> {
    try {
      const response = await HttpUtil.get(`/api/reservation/${id}`) as HttpResponse;
      return response.data;
    } catch (error) {
      console.error('获取预约详情失败:', error);
      throw error;
    }
  }
  
  /**
   * 取消预约
   * @param id 预约ID
   */
  static async cancelReservation(id: number): Promise<boolean> {
    try {
      const response = await HttpUtil.put(`/api/reservation/${id}/cancel`) as HttpResponse;
      return response.code === 200;
    } catch (error) {
      console.error('取消预约失败:', error);
      throw error;
    }
  }
  
  /**
   * 获取预约列表（管理员）
   * @param page 页码
   * @param size 每页大小
   * @param userId 用户ID
   * @param roomId 自习室ID
   * @param status 状态
   * @param startDate 开始日期
   * @param endDate 结束日期
   * @returns Promise<分页预约列表>
   */
  static async getReservationList(
    page: number = 1,
    size: number = 10,
    userId?: number,
    roomId?: number,
    status?: number,
    startDate?: string,
    endDate?: string
  ): Promise<any> {
    try {
      const params: any = { page, size };
      if (userId !== undefined) params.userId = userId;
      if (roomId !== undefined) params.roomId = roomId;
      if (status !== undefined) params.status = status;
      if (startDate) params.startDate = startDate;
      if (endDate) params.endDate = endDate;
      
      const response = await HttpUtil.get('/api/admin/reservation/list', params) as HttpResponse;
      return response.data;
    } catch (error) {
      console.error('获取预约列表失败:', error);
      throw error;
    }
  }
  
  /**
   * 处理预约（管理员）
   * @param id 预约ID
   * @param status 状态
   * @returns Promise<boolean>
   */
  static async handleReservation(id: number, status: number): Promise<boolean> {
    try {
      // 将状态作为URL查询参数发送，而不是JSON主体
      const url = `/api/admin/reservation/${id}?status=${status}`;
      const response = await HttpUtil.put<any>(url) as HttpResponse;
      return response.code === 200;
    } catch (error) {
      console.error('处理预约失败:', error);
      throw error;
    }
  }
  
  /**
   * 导出预约记录（管理员）
   * @param startDate 开始日期
   * @param endDate 结束日期
   * @param roomId 自习室ID
   * @param status 状态
   * @returns Promise<预约列表>
   */
  static async exportReservations(
    startDate?: string,
    endDate?: string,
    roomId?: number,
    status?: number
  ): Promise<any[]> {
    try {
      const params: any = {};
      if (startDate) params.startDate = startDate;
      if (endDate) params.endDate = endDate;
      if (roomId !== undefined) params.roomId = roomId;
      if (status !== undefined) params.status = status;
      
      const response = await HttpUtil.get('/api/admin/reservation/export', params) as HttpResponse;
      return response.data || [];
    } catch (error) {
      console.error('导出预约记录失败:', error);
      throw error;
    }
  }
} 