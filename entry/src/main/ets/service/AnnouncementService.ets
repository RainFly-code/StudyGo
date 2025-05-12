import { HttpUtil } from '../utils/HttpUtil';
import { Announcement } from '../model/AnnouncementModel';

/**
 * 公告服务类 - 封装公告相关的API调用
 */
export class AnnouncementService {
  /**
   * 获取公告列表
   * @param page 页码
   * @param size 每页数量
   * @param keyword 关键词搜索
   * @param status 状态筛选
   * @returns Promise<分页公告列表>
   */
  static async getAnnouncementList(page: number = 1, size: number = 10, keyword?: string, status?: number): Promise<any> {
    const params: any = { page, size };
    
    // 只有当keyword不是undefined时才添加到参数中
    if (keyword !== undefined) {
      params.keyword = keyword;
    }
    
    // 只有当status不是undefined时才添加到参数中
    if (status !== undefined) {
      params.status = status;
    }
    
    const response = await HttpUtil.get<any>('/api/announcement/list', params);
    if (response && response.code === 200 && response.data) {
      return response.data;
    }
    throw new Error('获取公告列表失败');
  }
  
  /**
   * 获取公告详情
   * @param id 公告ID
   * @returns Promise<公告详情>
   */
  static async getAnnouncementDetail(id: number): Promise<Announcement> {
    const response = await HttpUtil.get<any>(`/api/announcement/${id}`);
    if (response && response.code === 200 && response.data) {
      return response.data;
    }
    throw new Error('获取公告详情失败');
  }
  
  /**
   * 添加公告（管理员）
   * @param announcement 公告信息
   * @returns Promise<boolean>
   */
  static async addAnnouncement(announcement: Announcement): Promise<boolean> {
    const response = await HttpUtil.post<any>('/api/admin/announcement/add', announcement);
    return response && response.code === 200;
  }
  
  /**
   * 更新公告（管理员）
   * @param id 公告ID
   * @param announcement 公告信息
   * @returns Promise<boolean>
   */
  static async updateAnnouncement(id: number, announcement: Announcement): Promise<boolean> {
    console.info('【AnnouncementService】更新公告参数:', JSON.stringify(announcement));
    // 确保包含所有需要的字段
    const updateData = {
      title: announcement.title,
      content: announcement.content,
      status: announcement.status
    };
    const response = await HttpUtil.put<any>(`/api/admin/announcement/${id}`, updateData);
    if (response && response.code === 200) {
      return true;
    } else if (response) {
      console.error('更新公告失败:', response.message || '未知错误');
      throw new Error(response.message || '更新公告失败');
    }
    throw new Error('更新公告失败');
  }
  
  /**
   * 删除公告（管理员）
   * @param id 公告ID
   * @returns Promise<boolean>
   */
  static async deleteAnnouncement(id: number): Promise<boolean> {
    const response = await HttpUtil.delete<any>(`/api/admin/announcement/${id}`);
    return response && response.code === 200;
  }
  
  /**
   * 更新公告状态（管理员）
   * @param id 公告ID
   * @param status 状态
   * @returns Promise<boolean>
   */
  static async updateAnnouncementStatus(id: number, status: number): Promise<boolean> {
    const params = { status };
    const response = await HttpUtil.put<any>(`/api/admin/announcement/${id}/status`, params);
    return response && response.code === 200;
  }
} 