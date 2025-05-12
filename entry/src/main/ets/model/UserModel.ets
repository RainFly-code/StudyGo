/**
 * 用户实体类
 */
export class User {
  id?: number;
  username: string = '';
  password?: string = '';
  name: string = '';
  studentId?: string = '';
  email?: string = '';
  phone?: string = '';
  role: number = 0;
  avatar?: string = '';
  createTime?: string = '';
  updateTime?: string = '';
}

/**
 * 登录请求参数
 */
export class LoginParams {
  username: string = '';
  password: string = '';
}

/**
 * 注册请求参数
 */
export class RegisterParams {
  username: string = '';
  password: string = '';
  name: string = '';
  studentId?: string = '';
  email: string = '';
  phone: string = '';
}

/**
 * 修改密码请求参数
 */
export class PasswordParams {
  oldPassword: string = '';
  newPassword: string = '';
} 