import { HttpUtil } from '../utils/HttpUtil';
import { Feedback } from '../model/FeedbackModel';

/**
 * 反馈服务类 - 封装反馈相关的API调用
 */
export class FeedbackService {
  /**
   * 提交反馈
   * @param feedback 反馈信息
   * @returns Promise<反馈ID>
   */
  static async addFeedback(feedback: Feedback): Promise<number> {
    // 将反馈对象转换为表单参数格式，确保包含所有必要字段
    const params = {
      type: feedback.type,
      title: feedback.title,
      content: feedback.content,
      status: 0  // 设置初始状态为待处理
    };
    
    console.info('【FeedbackService】提交反馈参数:', JSON.stringify(params));
    
    const response = await HttpUtil.postForm<any>('/api/feedback/add', params);
    if (response && response.code === 200 && response.data && response.data.id) {
      return response.data.id;
    }
    throw new Error('提交反馈失败');
  }
  
  /**
   * 获取个人反馈列表
   * @param page 页码
   * @param size 每页数量
   * @param status 状态
   * @returns Promise<分页反馈列表>
   */
  static async getUserFeedbacks(page: number = 1, size: number = 10, status?: number): Promise<any> {
    // 构建参数对象，只有当status有值时才包含它
    const params: any = { page, size };
    
    // 只有当status不是undefined时才添加到参数中
    if (status !== undefined) {
      params.status = status;
      console.info('【FeedbackService】getUserFeedbacks - 添加状态筛选:', status);
    } else {
      console.info('【FeedbackService】getUserFeedbacks - 无状态筛选');
    }
    
    const response = await HttpUtil.get<any>('/api/feedback/list', params);
    if (response && response.code === 200 && response.data) {
      return response.data;
    }
    throw new Error('获取反馈列表失败');
  }
  
  /**
   * 获取反馈详情
   * @param id 反馈ID
   * @returns Promise<反馈详情>
   */
  static async getFeedbackDetail(id: number): Promise<Feedback> {
    const response = await HttpUtil.get<any>(`/api/feedback/${id}`);
    if (response && response.code === 200 && response.data) {
      return response.data;
    }
    throw new Error('获取反馈详情失败');
  }
  
  /**
   * 获取反馈列表（管理员）
   * @param page 页码
   * @param size 每页数量
   * @param type 类型
   * @param status 状态
   * @returns Promise<分页反馈列表>
   */
  static async getFeedbackList(page: number = 1, size: number = 10, type?: number, status?: number): Promise<any> {
    const params = { page, size, type, status };
    const response = await HttpUtil.get<any>('/api/admin/feedback/list', params);
    if (response && response.code === 200 && response.data) {
      return response.data;
    }
    throw new Error('获取反馈列表失败');
  }
  
  /**
   * 处理反馈（管理员）
   * @param id 反馈ID
   * @param status 状态
   * @param reply 回复
   * @returns Promise<boolean>
   */
  static async handleFeedback(id: number, status: number, reply?: string): Promise<boolean> {
    // 构造URL查询参数
    const params = { status, reply };
    console.info('【FeedbackService】处理反馈参数:', JSON.stringify(params));
    const response = await HttpUtil.put<any>(`/api/admin/feedback/${id}`, {}, params);
    if (response && response.code === 200) {
      return true;
    } else if (response) {
      console.error('处理反馈失败:', response.message || '未知错误');
      throw new Error(response.message || '处理反馈失败');
    }
    throw new Error('处理反馈失败');
  }
} 