/**
 * 自习室实体类
 */
export class StudyRoom {
  id?: number;
  name: string = '';
  location: string = '';
  capacity: number = 0;
  description: string = '';
  openTime: string = '';
  closeTime: string = '';
  status: number = 0;
  imageUrl?: string = '';
  createTime?: string = '';
  updateTime?: string = '';
}

/**
 * 座位实体类
 */
export class Seat {
  id?: number;
  roomId: number = 0;
  seatNumber: string = '';
  row: number = 0;
  column: number = 0;
  status: number = 0;
  description?: string = '';
  createTime?: string = '';
  updateTime?: string = '';
}

/**
 * 预约实体类
 */
export class Reservation {
  id?: number;
  userId: number = 0;
  userName?: string = '';
  roomId: number = 0;
  roomName?: string = '';
  seatId: number = 0;
  seatNumber?: string = '';
  date?: string = '';      // 单日预约日期
  startDate: string = '';
  endDate: string = '';
  days: number = 1;
  status: number = 0;
  createTime?: string = '';
  updateTime?: string = '';
} 