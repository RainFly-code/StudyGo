import { HttpUtil } from '../utils/HttpUtil';
import { Reservation, Seat, StudyRoom } from '../model/StudyRoomModel';

/**
 * 自习室服务类 - 封装自习室相关的API调用
 */
export class StudyRoomService {
  /**
   * 获取自习室列表
   * @param page 页码
   * @param size 每页数量
   * @param status 状态
   * @returns Promise<分页自习室列表>
   */
  static async getStudyRoomList(page: number = 1, size: number = 10, status?: number): Promise<any> {
    const params = { page, size, status };
    const response = await HttpUtil.get<any>('/api/studyroom/list', params);
    if (response && response.code === 200 && response.data) {
      return response.data;
    }
    throw new Error('获取自习室列表失败');
  }
  
  /**
   * 获取自习室详情
   * @param id 自习室ID
   * @returns Promise<自习室详情>
   */
  static async getStudyRoomDetail(id: number): Promise<StudyRoom> {
    const response = await HttpUtil.get<any>(`/api/studyroom/${id}`);
    if (response && response.code === 200 && response.data) {
      return response.data;
    }
    throw new Error('获取自习室详情失败');
  }
  
  /**
   * 搜索自习室
   * @param keyword 关键词
   * @param page 页码
   * @param size 每页数量
   * @returns Promise<分页自习室列表>
   */
  static async searchStudyRoom(keyword: string, page: number = 1, size: number = 10): Promise<any> {
    const params = { keyword, page, size };
    const response = await HttpUtil.get<any>('/api/studyroom/search', params);
    if (response && response.code === 200 && response.data) {
      return response.data;
    }
    throw new Error('搜索自习室失败');
  }
  
  /**
   * 获取自习室座位列表
   * @param roomId 自习室ID
   * @param date 日期
   * @param status 状态
   * @returns Promise<座位列表>
   */
  static async getStudyRoomSeats(roomId: number, date?: string, status?: number): Promise<Seat[]> {
    console.log('StudyRoomService.getStudyRoomSeats 请求参数:', { roomId, date, status });
    const params = { date, status };
    const url = `/api/studyroom/${roomId}/seats`;
    console.log('请求URL:', url, '参数:', params);
    
    const response = await HttpUtil.get<any>(url, params);
    console.log('StudyRoomService.getStudyRoomSeats 响应结果:', response);
    
    if (response && response.code === 200) {
      // 确保返回数组
      if (response.data && Array.isArray(response.data)) {
        // 创建Seat对象数组
        const seats: Seat[] = response.data.map((item: any) => {
          const seat = new Seat();
          seat.id = item.id || 0;
          seat.roomId = item.roomId || 0;
          seat.seatNumber = item.seatNumber || '';
          seat.row = item.row || 0;
          seat.column = item.column || 0;
          seat.status = item.status || 0;
          seat.description = item.description || '';
          seat.createTime = item.createTime || '';
          seat.updateTime = item.updateTime || '';
          return seat;
        });
        return seats;
      } else {
        console.error('座位数据不是数组:', response.data);
        return [];
      }
    }
    throw new Error('获取自习室座位列表失败');
  }

  // 管理员服务
  
  /**
   * 添加自习室（管理员）
   * @param studyRoom 自习室信息
   * @returns Promise<boolean>
   */
  static async addStudyRoom(studyRoom: StudyRoom): Promise<boolean> {
    const response = await HttpUtil.post<any>('/api/admin/studyroom/add', studyRoom);
    return response && response.code === 200;
  }
  
  /**
   * 更新自习室（管理员）
   * @param id 自习室ID
   * @param studyRoom 自习室信息
   * @returns Promise<boolean>
   */
  static async updateStudyRoom(id: number, studyRoom: StudyRoom): Promise<boolean> {
    const response = await HttpUtil.put<any>(`/api/admin/studyroom/${id}`, studyRoom);
    return response && response.code === 200;
  }
  
  /**
   * 删除自习室（管理员）
   * @param id 自习室ID
   * @returns Promise<boolean>
   */
  static async deleteStudyRoom(id: number): Promise<boolean> {
    const response = await HttpUtil.delete<any>(`/api/admin/studyroom/${id}`);
    return response && response.code === 200;
  }
  
  /**
   * 更新自习室状态（管理员）
   * @param id 自习室ID
   * @param status 状态
   * @returns Promise<boolean>
   */
  static async updateStudyRoomStatus(id: number, status: number): Promise<boolean> {
    const url = `/api/admin/studyroom/${id}/status?status=${status}`;
    const response = await HttpUtil.put<any>(url, null);
    return response && response.code === 200;
  }
  
  /**
   * 添加座位（管理员）
   * @param seat 座位信息
   * @returns Promise<boolean>
   */
  static async addSeat(seat: Seat): Promise<boolean> {
    const response = await HttpUtil.post<any>('/api/admin/seat/add', seat);
    // 处理返回值：检查直接返回的success字段或嵌套在data中的success字段
    if (response && response.success !== undefined) {
      return response.success;
    } else if (response && response.code === 200 && response.data && response.data.success !== undefined) {
      return response.data.success;
    }
    return response && response.code === 200;
  }
  
  /**
   * 更新座位（管理员）
   * @param id 座位ID
   * @param seat 座位信息
   * @returns Promise<boolean>
   */
  static async updateSeat(id: number, seat: Seat): Promise<boolean> {
    const response = await HttpUtil.put<any>(`/api/admin/seat/${id}`, seat);
    if (response && response.code === 200 && response.data && response.data.success !== undefined) {
      return response.data.success;
    }
    return response && response.code === 200;
  }
  
  /**
   * 更新座位状态（管理员）
   * @param id 座位ID
   * @param status 状态
   * @returns Promise<boolean>
   */
  static async updateSeatStatus(id: number, status: number): Promise<boolean> {
    const params = { status };
    const response = await HttpUtil.put<any>(`/api/admin/seat/${id}/status`, params);
    if (response && response.code === 200 && response.data && response.data.success !== undefined) {
      return response.data.success;
    }
    return response && response.code === 200;
  }
  
  /**
   * 批量设置座位（管理员）
   * @param roomId 自习室ID
   * @param startNumber 起始编号
   * @param endNumber 结束编号
   * @param status 状态
   * @returns Promise<boolean>
   */
  static async batchSetSeats(roomId: number, startNumber: number, endNumber: number, status: number): Promise<boolean> {
    const params = { roomId, startNumber, endNumber, status };
    const response = await HttpUtil.post<any>('/api/admin/seat/batch', params);
    if (response && response.code === 200 && response.data && response.data.success !== undefined) {
      return response.data.success;
    }
    return response && response.code === 200;
  }
  
  /**
   * 获取所有座位（管理员）
   * @returns Promise<座位列表>
   */
  static async getAllSeats(): Promise<Seat[]> {
    const response = await HttpUtil.get<any>('/api/admin/seat/all');
    
    if (response && response.code === 200) {
      // 确保返回数组
      if (response.data && Array.isArray(response.data)) {
        // 创建Seat对象数组
        const seats: Seat[] = response.data.map((item: any) => {
          const seat = new Seat();
          seat.id = item.id || 0;
          seat.roomId = item.roomId || 0;
          seat.seatNumber = item.seatNumber || '';
          seat.row = item.row || 0;
          seat.column = item.column || 0;
          seat.status = item.status || 0;
          seat.description = item.description || '';
          seat.createTime = item.createTime || '';
          seat.updateTime = item.updateTime || '';
          return seat;
        });
        return seats;
      } else {
        console.error('座位数据不是数组:', response.data);
        return [];
      }
    }
    throw new Error('获取所有座位失败');
  }
  
  /**
   * 删除座位（管理员）
   * @param id 座位ID
   * @returns Promise<boolean>
   */
  static async deleteSeat(id: number): Promise<boolean> {
    // 使用POST方法代替DELETE方法
    const response = await HttpUtil.post<any>(`/api/admin/seat/delete/${id}`, null);
    
    // 处理多种可能的返回格式
    if (response && response.success !== undefined) {
      return response.success;
    } else if (response && response.code === 200 && response.data && response.data.success !== undefined) {
      return response.data.success;
    }
    return response && response.code === 200;
  }
  
} 