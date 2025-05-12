import preferencesModule from '@ohos.data.preferences';
import { User } from '../../model/UserModel';

/**
 * 偏好存储工具类
 */
export class PreferenceUtil {
  private static readonly PREFERENCES_NAME: string = 'study_go';
  private static readonly KEY_USER: string = 'user';
  private static readonly KEY_TOKEN: string = 'token';
  private static readonly KEY_SESSION_ID: string = 'session_id';
  
  /**
   * 保存用户信息
   * @param user 用户信息
   */
  static async saveUser(user: User): Promise<void> {
    const context = getContext(this);
    const preferences = await preferencesModule.getPreferences(context, this.PREFERENCES_NAME);
    await preferences.put(this.KEY_USER, JSON.stringify(user));
    await preferences.flush();
  }
  
  /**
   * 获取用户信息
   * @returns 用户信息
   */
  static async getUser(): Promise<User | null> {
    try {
      const context = getContext(this);
      const preferences = await preferencesModule.getPreferences(context, this.PREFERENCES_NAME);
      const userStr = await preferences.get(this.KEY_USER, '');
      if (userStr && typeof userStr === 'string') {
        return JSON.parse(userStr) as User;
      }
      return null;
    } catch (error) {
      console.error('获取用户信息失败:', error);
      return null;
    }
  }
  
  /**
   * 保存token
   * @param token token
   */
  static async saveToken(token: string): Promise<void> {
    const context = getContext(this);
    const preferences = await preferencesModule.getPreferences(context, this.PREFERENCES_NAME);
    await preferences.put(this.KEY_TOKEN, token);
    await preferences.flush();
  }
  
  /**
   * 获取token
   * @returns token
   */
  static async getToken(): Promise<string> {
    try {
      const context = getContext(this);
      const preferences = await preferencesModule.getPreferences(context, this.PREFERENCES_NAME);
      return await preferences.get(this.KEY_TOKEN, '') as string;
    } catch (error) {
      console.error('获取token失败:', error);
      return '';
    }
  }
  
  /**
   * 保存会话ID
   * @param sessionId 会话ID
   */
  static async saveSessionId(sessionId: string): Promise<void> {
    const context = getContext(this);
    const preferences = await preferencesModule.getPreferences(context, this.PREFERENCES_NAME);
    await preferences.put(this.KEY_SESSION_ID, sessionId);
    await preferences.flush();
    console.info('【PreferenceUtil】已保存sessionId: ' + sessionId);
  }
  
  /**
   * 获取会话ID
   * @returns 会话ID
   */
  static async getSessionId(): Promise<string> {
    try {
      const context = getContext(this);
      const preferences = await preferencesModule.getPreferences(context, this.PREFERENCES_NAME);
      const sessionId = await preferences.get(this.KEY_SESSION_ID, '') as string;
      console.info('【PreferenceUtil】获取到sessionId: ' + sessionId);
      return sessionId;
    } catch (error) {
      console.error('【PreferenceUtil】获取sessionId失败:', error);
      return '';
    }
  }
  
  /**
   * 清除所有存储的数据
   */
  static async clear(): Promise<void> {
    const context = getContext(this);
    const preferences = await preferencesModule.getPreferences(context, this.PREFERENCES_NAME);
    await preferences.clear();
    await preferences.flush();
  }
} 