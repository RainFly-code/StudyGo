/**
 * 反馈实体类
 */
export class Feedback {
  id?: number;
  userId: number = 0;
  userName?: string = '';
  type: number = 0;
  title: string = '';
  content: string = '';
  status: number = 0;
  reply?: string = '';
  createTime?: string = '';
  updateTime?: string = '';
} 