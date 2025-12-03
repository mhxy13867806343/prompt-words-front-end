import request from '@/utils/request'
import type { ApiResponse, PageData, Prompt, PromptForm } from '@/types'

// 创建提示词
export const createPrompt = (data: PromptForm) => {
  return request.post<any, ApiResponse<Prompt>>('/prompts', data)
}

// 获取提示词列表
export const getPrompts = (params: { page: number; pageSize: number; keyword?: string }) => {
  return request.get<any, ApiResponse<PageData<Prompt>>>('/prompts', { params })
}

// 获取提示词详情
export const getPromptDetail = (id: number) => {
  return request.get<any, ApiResponse<Prompt>>(`/prompts/${id}`)
}

// 更新提示词
export const updatePrompt = (id: number, data: PromptForm) => {
  return request.put<any, ApiResponse<Prompt>>(`/prompts/${id}`, data)
}

// 删除提示词
export const deletePrompt = (id: number) => {
  return request.delete<any, ApiResponse>(`/prompts/${id}`)
}

// 点赞
export const likePrompt = (id: number) => {
  return request.post<any, ApiResponse>(`/prompts/${id}/like`)
}

// 取消点赞
export const unlikePrompt = (id: number) => {
  return request.delete<any, ApiResponse>(`/prompts/${id}/like`)
}

// 收藏
export const collectPrompt = (id: number) => {
  return request.post<any, ApiResponse>(`/prompts/${id}/collect`)
}

// 取消收藏
export const uncollectPrompt = (id: number) => {
  return request.delete<any, ApiResponse>(`/prompts/${id}/collect`)
}

// 获取我的提示词
export const getMyPrompts = (params: { page: number; pageSize: number }) => {
  return request.get<any, ApiResponse<PageData<Prompt>>>('/prompts/my', { params })
}

// 获取我点赞的
export const getMyLikes = (params: { page: number; pageSize: number }) => {
  return request.get<any, ApiResponse<PageData<Prompt>>>('/prompts/my/likes', { params })
}

// 获取我收藏的
export const getMyCollects = (params: { page: number; pageSize: number }) => {
  return request.get<any, ApiResponse<PageData<Prompt>>>('/prompts/my/collects', { params })
}

// 获取统计数据
export const getStatistics = () => {
  return request.get<any, ApiResponse<{ totalPrompts: number; totalViews: number }>>('/prompts/statistics')
}
