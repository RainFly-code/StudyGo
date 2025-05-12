import http from '@ohos.net.http';
import { Constants } from '../common/constants/Constants';
import { PreferenceUtil } from '../common/utils/PreferenceUtil';

/**
 * HTTP请求工具类
 */
export class HttpUtil {
  private static readonly BASE_URL: string = Constants.BASE_URL;
  private static readonly TIMEOUT: number = 10000;
  private static readonly CONTENT_TYPE: string = 'application/json';
  // 保存JSESSIONID
  private static sessionId: string = '';

  /**
   * GET请求
   * @param url 请求路径
   * @param params 请求参数
   * @returns 返回Promise
   */
  static get<T>(url: string, params?: Object): Promise<T> {
    return this.request<T>(http.RequestMethod.GET, url, params);
  }

  /**
   * POST请求
   * @param url 请求路径
   * @param data 请求数据
   * @returns 返回Promise
   */
  static post<T>(url: string, data?: Object): Promise<T> {
    return this.request<T>(http.RequestMethod.POST, url, data);
  }

  /**
   * PUT请求
   * @param url 请求路径
   * @param data 请求数据
   * @param params URL查询参数
   * @returns 返回Promise
   */
  static put<T>(url: string, data?: Object, params?: Object): Promise<T> {
    return this.request<T>(http.RequestMethod.PUT, url, data, params);
  }

  /**
   * DELETE请求
   * @param url 请求路径
   * @param params 请求参数
   * @returns 返回Promise
   */
  static delete<T>(url: string, params?: Object): Promise<T> {
    return this.request<T>(http.RequestMethod.DELETE, url, params);
  }

  /**
   * 以表单方式提交POST请求
   * @param url 请求路径
   * @param data 请求数据
   * @returns 返回Promise
   */
  static postForm<T>(url: string, data?: Object): Promise<T> {
    return this.requestForm<T>(http.RequestMethod.POST, url, data);
  }

  /**
   * HTTP请求
   * @param method 请求方法
   * @param url 请求路径
   * @param data 请求数据
   * @param params URL查询参数
   * @returns 返回Promise
   */
  private static async request<T>(method: http.RequestMethod, url: string, data?: Object, params?: Object): Promise<T> {
    const httpRequest = http.createHttp();
    
    // 监听响应头，获取并保存会话ID
    httpRequest.on('headersReceive', (header) => {
      console.info('【HttpUtil】接收到响应头: ' + JSON.stringify(header));
      
      // 从响应头中提取JSESSIONID
      if (header['set-cookie'] || header['Set-Cookie']) {
        const cookies = header['set-cookie'] || header['Set-Cookie'];
        console.info('【HttpUtil】收到cookies: ' + JSON.stringify(cookies));
        
        if (Array.isArray(cookies)) {
          for (const cookie of cookies) {
            if (cookie.includes('JSESSIONID')) {
              const match = cookie.match(/JSESSIONID=([^;]+)/);
              if (match && match[1]) {
                this.sessionId = match[1];
                console.info('【HttpUtil】保存JSESSIONID: ' + this.sessionId);
                // 保存到本地存储
                PreferenceUtil.saveSessionId(this.sessionId);
              }
            }
          }
        } else if (typeof cookies === 'string' && cookies.includes('JSESSIONID')) {
          const match = cookies.match(/JSESSIONID=([^;]+)/);
          if (match && match[1]) {
            this.sessionId = match[1];
            console.info('【HttpUtil】保存JSESSIONID: ' + this.sessionId);
            // 保存到本地存储
            PreferenceUtil.saveSessionId(this.sessionId);
          }
        }
      }
    });
    
    let fullUrl = this.BASE_URL + url;
    
    // 如果没有sessionId，从本地存储读取
    if (!this.sessionId) {
      this.sessionId = await PreferenceUtil.getSessionId();
      console.info('【HttpUtil】从本地存储读取JSESSIONID: ' + this.sessionId);
    }
    
    // 将会话ID添加到URL中（URL重写模式，用于不支持Cookie的情况）
    if (this.sessionId && !url.includes('jsessionid=')) {
      const separator = url.includes('?') ? '&' : '?';
      fullUrl = `${fullUrl}${separator}jsessionid=${this.sessionId}`;
      console.info('【HttpUtil】URL添加会话参数: ' + fullUrl);
    }
    
    // 处理URL查询参数
    if (method === http.RequestMethod.GET && data) {
      // GET请求，data作为查询参数
      const queryParams = this.formatParams(data);
      if (queryParams) {
        fullUrl += (fullUrl.includes('?') ? '&' : '?') + queryParams;
      }
    } else if (params) {
      // 其他请求，使用params作为查询参数
      const queryParams = this.formatParams(params);
      if (queryParams) {
        fullUrl += (fullUrl.includes('?') ? '&' : '?') + queryParams;
      }
    }
    
    console.info(`【HttpUtil】准备发送${method}请求: ${fullUrl}`);
    
    const headers = {};
    
    // 如果有会话ID，添加到请求头Cookie中
    if (this.sessionId) {
      headers['Cookie'] = `JSESSIONID=${this.sessionId}`;
      console.info('【HttpUtil】请求头添加Cookie: ' + headers['Cookie']);
    }
    
    // 只有当有数据需要提交且不是GET请求时，才设置Content-Type
    if (method !== http.RequestMethod.GET && data) {
      headers['Content-Type'] = this.CONTENT_TYPE;
    }
    
    const options: http.HttpRequestOptions = {
      method: method,
      header: headers,
      readTimeout: this.TIMEOUT,
      connectTimeout: this.TIMEOUT
    };

    // 非GET请求添加body
    if (method !== http.RequestMethod.GET && data) {
      options.extraData = JSON.stringify(data);
      console.info('【HttpUtil】请求数据(原始): ' + JSON.stringify(data));
      console.info('【HttpUtil】请求数据(序列化): ' + options.extraData);
    }

    return new Promise<T>((resolve, reject) => {
      httpRequest.request(fullUrl, options)
        .then((response) => {
          console.info('【HttpUtil】响应码: ' + response.responseCode);
          console.info('【HttpUtil】响应头: ' + JSON.stringify(response.header));
          
          if (response.responseCode === 200) {
            try {
              const result = JSON.parse(response.result as string);
              console.info('【HttpUtil】响应结果: ' + JSON.stringify(result));
              
              // 检查是否是标准响应格式
              if (result.code !== undefined) {
                if (result.code === 200) {
                  // 返回完整的响应对象，而不仅仅是data部分
                  resolve(result as T);
                } else {
                  console.error('【HttpUtil】业务错误: ' + result.message);
                  reject(new Error(result.message || '请求失败'));
                }
              } else {
                // 直接返回数据
                resolve(result as T);
              }
            } catch (error) {
              console.error('【HttpUtil】解析响应数据失败: ' + error);
              reject(new Error('解析响应数据失败'));
            }
          } else {
            console.error('【HttpUtil】HTTP错误: ' + response.responseCode);
            reject(new Error(`HTTP错误: ${response.responseCode}`));
          }
        })
        .catch((error) => {
          console.error('【HttpUtil】请求异常: ' + error);
          reject(error);
        })
        .finally(() => {
          httpRequest.destroy();
        });
    });
  }

  /**
   * 以表单方式提交HTTP请求
   * @param method 请求方法
   * @param url 请求路径
   * @param data 请求数据
   * @returns 返回Promise
   */
  private static async requestForm<T>(method: http.RequestMethod, url: string, data?: Object): Promise<T> {
    const httpRequest = http.createHttp();
    
    // 监听响应头，获取并保存会话ID
    httpRequest.on('headersReceive', (header) => {
      console.info('【HttpUtil】接收到响应头: ' + JSON.stringify(header));
      
      // 从响应头中提取JSESSIONID
      if (header['set-cookie'] || header['Set-Cookie']) {
        const cookies = header['set-cookie'] || header['Set-Cookie'];
        console.info('【HttpUtil】收到cookies: ' + JSON.stringify(cookies));
        
        if (Array.isArray(cookies)) {
          for (const cookie of cookies) {
            if (cookie.includes('JSESSIONID')) {
              const match = cookie.match(/JSESSIONID=([^;]+)/);
              if (match && match[1]) {
                this.sessionId = match[1];
                console.info('【HttpUtil】保存JSESSIONID: ' + this.sessionId);
                // 保存到本地存储
                PreferenceUtil.saveSessionId(this.sessionId);
              }
            }
          }
        } else if (typeof cookies === 'string' && cookies.includes('JSESSIONID')) {
          const match = cookies.match(/JSESSIONID=([^;]+)/);
          if (match && match[1]) {
            this.sessionId = match[1];
            console.info('【HttpUtil】保存JSESSIONID: ' + this.sessionId);
            // 保存到本地存储
            PreferenceUtil.saveSessionId(this.sessionId);
          }
        }
      }
    });
    
    let fullUrl = this.BASE_URL + url;
    
    // 如果没有sessionId，从本地存储读取
    if (!this.sessionId) {
      this.sessionId = await PreferenceUtil.getSessionId();
      console.info('【HttpUtil】从本地存储读取JSESSIONID: ' + this.sessionId);
    }
    
    // 将会话ID添加到URL中
    if (this.sessionId && !url.includes('jsessionid=')) {
      const separator = url.includes('?') ? '&' : '?';
      fullUrl = `${fullUrl}${separator}jsessionid=${this.sessionId}`;
      console.info('【HttpUtil】URL添加会话参数: ' + fullUrl);
    }
    
    console.info(`【HttpUtil】准备发送表单${method}请求: ${fullUrl}`);
    
    const headers = {};
    
    // 如果有会话ID，添加到请求头Cookie中
    if (this.sessionId) {
      headers['Cookie'] = `JSESSIONID=${this.sessionId}`;
      console.info('【HttpUtil】请求头添加Cookie: ' + headers['Cookie']);
    }
    
    // 表单请求设置Content-Type为application/x-www-form-urlencoded
    if (data) {
      headers['Content-Type'] = 'application/x-www-form-urlencoded';
    }
    
    const options: http.HttpRequestOptions = {
      method: method,
      header: headers,
      readTimeout: this.TIMEOUT,
      connectTimeout: this.TIMEOUT
    };

    // 处理表单数据
    if (data) {
      const formData = this.formatParams(data);
      if (formData) {
        options.extraData = formData;
        console.info('【HttpUtil】表单数据: ' + options.extraData);
      }
    }

    return new Promise<T>((resolve, reject) => {
      httpRequest.request(fullUrl, options)
        .then((response) => {
          console.info('【HttpUtil】响应码: ' + response.responseCode);
          console.info('【HttpUtil】响应头: ' + JSON.stringify(response.header));
          
          if (response.responseCode === 200) {
            try {
              const result = JSON.parse(response.result as string);
              console.info('【HttpUtil】响应结果: ' + JSON.stringify(result));
              
              // 检查是否是标准响应格式
              if (result.code !== undefined) {
                if (result.code === 200) {
                  // 返回完整的响应对象，而不仅仅是data部分
                  resolve(result as T);
                } else {
                  console.error('【HttpUtil】业务错误: ' + result.message);
                  reject(new Error(result.message || '请求失败'));
                }
              } else {
                // 直接返回数据
                resolve(result as T);
              }
            } catch (error) {
              console.error('【HttpUtil】解析响应数据失败: ' + error);
              reject(new Error('解析响应数据失败'));
            }
          } else {
            console.error('【HttpUtil】HTTP错误: ' + response.responseCode);
            reject(new Error(`HTTP错误: ${response.responseCode}`));
          }
        })
        .catch((error) => {
          console.error('【HttpUtil】请求异常: ' + error);
          reject(error);
        })
        .finally(() => {
          httpRequest.destroy();
        });
    });
  }

  /**
   * 格式化参数
   * @param params 参数对象
   * @returns 格式化后的字符串
   */
  private static formatParams(params: Object): string {
    if (!params) {
      console.info('【HttpUtil】formatParams - 参数为空');
      return '';
    }
    
    console.info('【HttpUtil】formatParams - 原始参数类型:', Object.prototype.toString.call(params));
    console.info('【HttpUtil】formatParams - 原始参数:', JSON.stringify(params));
    
    try {
      const formattedParams = Object.entries(params)
        .filter(([key, value]) => {
          const keep = value !== undefined && value !== null && value !== '';
          console.info(`【HttpUtil】formatParams - 参数 ${key}=${value}, 类型: ${typeof value}, 保留: ${keep}`);
          return keep;
        })
        .map(([key, value]) => `${encodeURIComponent(key)}=${encodeURIComponent(value)}`)
        .join('&');
      
      console.info('【HttpUtil】formatParams - 格式化后:', formattedParams);
      return formattedParams;
    } catch (error) {
      console.error('【HttpUtil】formatParams - 格式化参数异常:', error);
      return '';
    }
  }
} 