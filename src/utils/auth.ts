import Cookies from 'js-cookie'

const TOKEN_KEY = 'token'

export const getToken = (): string | undefined => {
  return Cookies.get(TOKEN_KEY)
}

export const setToken = (token: string): void => {
  Cookies.set(TOKEN_KEY, token, { expires: 30 }) // 30天有效期
}

export const removeToken = (): void => {
  Cookies.remove(TOKEN_KEY)
}
