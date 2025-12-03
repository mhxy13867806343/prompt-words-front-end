// API 响应结构
export interface ApiResponse<T = any> {
  code: number
  data: T
  msg: string
}

// 分页数据
export interface PageData<T> {
  list: T[]
  total: number
  page: number
  pageSize: number
}

// 用户信息
export interface User {
  id: number
  username: string
  email?: string
  state: number // 0: 未绑定邮箱, >0: 已绑定
  createdAt: string
}

// 登录表单
export interface LoginForm {
  username: string
  password: string
}

// 注册表单
export interface RegisterForm {
  username: string
  password: string
  confirmPassword: string
}

// 找回密码表单
export interface ResetPasswordForm {
  email: string
  code: string
  newPassword: string
  confirmPassword: string
}

// 绑定邮箱表单
export interface BindEmailForm {
  email: string
  code: string
}

// 提示词
export interface Prompt {
  id: number
  title: string
  content: string
  userId: number
  username: string
  state: number // 0: 已删除, 1: 正常
  viewCount: number
  likeCount: number
  collectCount: number
  isLiked?: boolean
  isCollected?: boolean
  createdAt: string
  updatedAt: string
}

// 提示词表单
export interface PromptForm {
  title: string
  content: string
}

// 统计数据
export interface Statistics {
  totalPrompts: number
  totalViews: number
}
