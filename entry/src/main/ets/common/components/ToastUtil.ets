import promptAction from '@ohos.promptAction';

/**
 * Toast工具类
 */
export class ToastUtil {
  /**
   * 显示Toast提示
   * @param message 提示消息
   * @param duration 显示时长
   */
  static showToast(message: string, duration: number = 1500): void {
    promptAction.showToast({
      message: message,
      duration: duration,
      bottom: '100px'
    });
  }
  
  /**
   * 显示成功提示
   * @param message 提示消息
   */
  static showSuccess(message: string): void {
    this.showToast(message);
  }
  
  /**
   * 显示错误提示
   * @param message 提示消息
   */
  static showError(message: string): void {
    this.showToast(message);
  }
  
  /**
   * 显示警告提示
   * @param message 提示消息
   */
  static showWarning(message: string): void {
    this.showToast(message);
  }
} 