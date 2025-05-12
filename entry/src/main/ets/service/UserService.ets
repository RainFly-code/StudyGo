import { HttpUtil } from '../utils/HttpUtil';
import { LoginParams, PasswordParams, RegisterParams, User } from '../model/UserModel';
import { PreferenceUtil } from '../common/utils/PreferenceUtil';

/**
 * 用户服务类 - 封装用户相关的API调用
 */
export class UserService {
  /**
   * 用户登录
   * @param params 登录参数
   * @returns Promise<用户信息>
   */
  static async login(params: LoginParams): Promise<User> {
    const response = await HttpUtil.post<any>('/api/user/login', params);
    
    // 检查响应状态码
    if (response && response.code === 200 && response.data && response.data.user) {
      // 保存用户信息到本地
      await PreferenceUtil.saveUser(response.data.user);
      // 保存token到本地
      if (response.data.token) {
        await PreferenceUtil.saveToken(response.data.token);
      }
      return response.data.user;
    }
    
    throw new Error('登录失败');
  }
  
  /**
   * 用户注册
   * @param params 注册参数
   * @returns Promise<boolean>
   */
  static async register(params: RegisterParams): Promise<boolean> {
    console.info('【UserService】register - 原始参数:', JSON.stringify(params));
    
    // 确保用户名不为空
    if (!params.username) {
      console.error('【UserService】register - 用户名为空');
      throw new Error('用户名不能为空');
    }
    
    // 确保密码不为空
    if (!params.password) {
      console.error('【UserService】register - 密码为空');
      throw new Error('密码不能为空');
    }
    
    // 如果用户没有设置name，则使用username作为name
    if (!params.name) {
      params.name = params.username;
      console.info('【UserService】register - 设置name为username:', params.name);
    }
    
    // 创建一个新对象，避免引用问题
    const registerData = {
      username: params.username,
      password: params.password,
      name: params.name,
      email: params.email,
      phone: params.phone
    };
    
    console.info('【UserService】register - 最终参数:', JSON.stringify(registerData));
    
    const response = await HttpUtil.post<any>('/api/user/register', registerData);
    console.info('【UserService】register - 响应:', JSON.stringify(response));
    return response && response.code === 200;
  }
  
  /**
   * 获取用户信息
   * @returns Promise<用户信息>
   */
  static async getUserInfo(): Promise<User> {
    const response = await HttpUtil.get<any>('/api/user/info');
    if (response && response.code === 200 && response.data) {
      return response.data;
    }
    throw new Error('获取用户信息失败');
  }
  
  /**
   * 更新用户信息
   * @param user 用户信息
   * @returns Promise<boolean>
   */
  static async updateUserInfo(user: User): Promise<boolean> {
    const response = await HttpUtil.put<any>('/api/user/update', user);
    if (response && response.code === 200) {
      // 更新本地存储的用户信息
      const currentUser = await PreferenceUtil.getUser();
      if (currentUser) {
        // 合并更新的字段
        const updatedUser = { ...currentUser, ...user };
        await PreferenceUtil.saveUser(updatedUser);
      }
      return true;
    }
    return false;
  }
  
  /**
   * 修改密码
   * @param params 密码参数
   * @returns Promise<boolean>
   */
  static async updatePassword(params: PasswordParams): Promise<boolean> {
    const response = await HttpUtil.put<any>('/api/user/password', params);
    return response && response.code === 200;
  }
  
  /**
   * 退出登录
   */
  static async logout(): Promise<void> {
    await PreferenceUtil.clear();
  }
  
  /**
   * 获取用户列表（管理员）
   * @param page 页码
   * @param size 每页数量
   * @param keyword 关键词
   * @returns Promise<分页用户列表>
   */
  static async getUserList(page: number = 1, size: number = 10, keyword?: string): Promise<any> {
    const params = { page, size, keyword };
    const response = await HttpUtil.get<any>('/api/admin/user/list', params);
    if (response && response.code === 200 && response.data) {
      return response.data;
    }
    throw new Error('获取用户列表失败');
  }
  
  /**
   * 获取用户详情（管理员）
   * @param id 用户ID
   * @returns Promise<用户信息>
   */
  static async getUserDetail(id: number): Promise<User> {
    const response = await HttpUtil.get<any>(`/api/admin/user/${id}`);
    if (response && response.code === 200 && response.data) {
      return response.data;
    }
    throw new Error('获取用户详情失败');
  }
  
  /**
   * 更新用户（管理员）
   * @param id 用户ID
   * @param user 用户信息
   * @returns Promise<boolean>
   */
  static async updateUser(id: number, user: User): Promise<boolean> {
    const response = await HttpUtil.put<any>(`/api/admin/user/${id}`, user);
    return response && response.code === 200;
  }
  
  /**
   * 删除用户（管理员）
   * @param id 用户ID
   * @returns Promise<boolean>
   */
  static async deleteUser(id: number): Promise<boolean> {
    const response = await HttpUtil.delete<any>(`/api/admin/user/${id}`);
    return response && response.code === 200;
  }
  
  /**
   * 添加用户（管理员）
   * @param user 用户信息
   * @returns Promise<boolean>
   */
  static async addUser(user: User): Promise<boolean> {
    const response = await HttpUtil.post<any>('/api/admin/user/add', user);
    return response && response.code === 200;
  }
} 