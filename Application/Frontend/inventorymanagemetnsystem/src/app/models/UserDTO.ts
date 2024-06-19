export interface UserDTO {
  userId: number;
  firstName: string;
  lastName: string;
  userName: string;
  email: string;
  roleId: number;
  roleName: string;
  profileImagePath: string;
  lastAction: string;
  totalLogs: number;
  lastActivity: Date;
}
