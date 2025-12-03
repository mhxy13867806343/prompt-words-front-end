import request from '@/utils/request'
import type { ApiResponse, User, LoginForm, RegisterForm, ResetPasswordForm, BindEmailForm } from '@/types'

export const login = (data: LoginForm) => {
  return request.post<any, ApiResponse<{ token: string; user: User }>>('/auth/login', data)
}

export const register = (data: RegisterForm) => {
  return request.post<any, ApiResponse<{ token: string; user: User }>>('/auth/register', data)
}

export const sendEmailCode = (email: string) => {
  return request.post<any, ApiResponse>('/auth/send-code', { email })
}

export const resetPassword = (data: ResetPasswordForm) => {
  return request.post<any, ApiResponse>('/auth/reset-password', data)
}

export const bindEmail = (data: BindEmailForm) => {
  return request.post<any, ApiResponse>('/auth/bind-email', data)
}

export const getUserInfo = () => {
  return request.get<any, ApiResponse<User>>('/auth/user')
}

export const logout = () => {
  return request.post<any, ApiResponse>('/auth/logout')
}
