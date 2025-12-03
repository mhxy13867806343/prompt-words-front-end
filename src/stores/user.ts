import { defineStore } from 'pinia'
import { ref } from 'vue'
import type { User } from '@/types'
import { getToken, setToken as saveToken, removeToken } from '@/utils/auth'
import { getUserInfo } from '@/api/auth'

export const useUserStore = defineStore('user', () => {
  const token = ref<string | undefined>(getToken())
  const userInfo = ref<User | null>(null)

  const setToken = (newToken: string) => {
    token.value = newToken
    saveToken(newToken)
  }

  const fetchUserInfo = async () => {
    try {
      const res = await getUserInfo()
      userInfo.value = res.data
      return res.data
    } catch (error) {
      return null
    }
  }

  const clearUser = () => {
    token.value = undefined
    userInfo.value = null
    removeToken()
  }

  const needBindEmail = computed(() => {
    return userInfo.value?.state === 0
  })

  return {
    token,
    userInfo,
    setToken,
    fetchUserInfo,
    clearUser,
    needBindEmail
  }
})
