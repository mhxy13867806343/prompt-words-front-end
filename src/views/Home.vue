<template>
  <div class="home-container">
    <el-container>
      <el-header class="header">
        <div class="header-content">
          <h1>提示词管理系统</h1>
          <div class="header-right">
            <el-statistic title="总提示词数" :value="statistics.totalPrompts" />
            <el-statistic title="总浏览量" :value="statistics.totalViews" style="margin-left: 30px" />
            <el-dropdown @command="handleCommand" style="margin-left: 30px">
              <span class="user-info">
                <el-icon><User /></el-icon>
                {{ userStore.userInfo?.username }}
              </span>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="profile">个人中心</el-dropdown-item>
                  <el-dropdown-item command="bind-email" v-if="userStore.needBindEmail">绑定邮箱</el-dropdown-item>
                  <el-dropdown-item command="logout" divided>退出登录</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </div>
        </div>
      </el-header>
      
      <el-main>
        <div class="main-content">
          <div class="toolbar">
            <el-input
              v-model="keyword"
              placeholder="搜索提示词"
              clearable
              @clear="handleSearch"
              @keyup.enter="handleSearch"
              style="width: 300px"
            >
              <template #prefix><el-icon><Search /></el-icon></template>
            </el-input>
            <el-button type="primary" @click="handleCreate">
              <el-icon><Plus /></el-icon>
              创建提示词
            </el-button>
          </div>
          
          <el-empty v-if="!loading && prompts.length === 0" description="暂无提示词" />
          
          <div v-loading="loading" class="prompt-grid">
            <el-card
              v-for="prompt in prompts"
              :key="prompt.id"
              class="prompt-card"
              shadow="hover"
              @click="handleView(prompt.id)"
            >
              <div class="prompt-header">
                <h3>{{ prompt.title }}</h3>
                <el-tag v-if="prompt.userId === userStore.userInfo?.id" type="success" size="small">我的</el-tag>
              </div>
              <div class="prompt-content">{{ truncateContent(prompt.content) }}</div>
              <div class="prompt-footer">
                <div class="prompt-meta">
                  <span><el-icon><View /></el-icon> {{ prompt.viewCount }}</span>
                  <span><el-icon><Star /></el-icon> {{ prompt.likeCount }}</span>
                  <span><el-icon><Collection /></el-icon> {{ prompt.collectCount }}</span>
                </div>
                <div class="prompt-author">@{{ prompt.username }}</div>
              </div>
            </el-card>
          </div>
          
          <el-pagination
            v-if="total > 0"
            v-model:current-page="page"
            v-model:page-size="pageSize"
            :total="total"
            :page-sizes="[12, 24, 48]"
            layout="total, sizes, prev, pager, next, jumper"
            @current-change="fetchPrompts"
            @size-change="fetchPrompts"
            style="margin-top: 20px; justify-content: center"
          />
        </div>
      </el-main>
    </el-container>
    
    <BindEmailDialog v-model="showBindDialog" @success="handleBindSuccess" />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useUserStore } from '@/stores/user'
import { getPrompts, getStatistics } from '@/api/prompt'
import { logout } from '@/api/auth'
import type { Prompt } from '@/types'
import BindEmailDialog from '@/components/BindEmailDialog.vue'

const router = useRouter()
const userStore = useUserStore()

const loading = ref(false)
const prompts = ref<Prompt[]>([])
const page = ref(1)
const pageSize = ref(12)
const total = ref(0)
const keyword = ref('')
const statistics = ref({ totalPrompts: 0, totalViews: 0 })
const showBindDialog = ref(false)

const fetchPrompts = async () => {
  loading.value = true
  try {
    const res = await getPrompts({
      page: page.value,
      pageSize: pageSize.value,
      keyword: keyword.value || undefined
    })
    prompts.value = res.data.list
    total.value = res.data.total
  } catch (error) {
    // 错误已在拦截器处理
  } finally {
    loading.value = false
  }
}

const fetchStatistics = async () => {
  try {
    const res = await getStatistics()
    statistics.value = res.data
  } catch (error) {
    // 错误已在拦截器处理
  }
}

const handleSearch = () => {
  page.value = 1
  fetchPrompts()
}

const handleCreate = () => {
  router.push('/create')
}

const handleView = (id: number) => {
  router.push(`/prompt/${id}`)
}

const handleCommand = async (command: string) => {
  if (command === 'profile') {
    router.push('/profile')
  } else if (command === 'bind-email') {
    showBindDialog.value = true
  } else if (command === 'logout') {
    try {
      await ElMessageBox.confirm('确定要退出登录吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })
      
      await logout()
      userStore.clearUser()
      ElMessage.success('已退出登录')
      router.push('/login')
    } catch (error) {
      // 用户取消
    }
  }
}

const handleBindSuccess = () => {
  showBindDialog.value = false
  userStore.fetchUserInfo()
}

const truncateContent = (content: string) => {
  return content.length > 100 ? content.substring(0, 100) + '...' : content
}

onMounted(() => {
  fetchPrompts()
  fetchStatistics()
})
</script>

<style scoped>
.home-container {
  height: 100vh;
  background: #f5f7fa;
}

.header {
  background: #fff;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.header-content {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 20px;
}

.header h1 {
  margin: 0;
  font-size: 24px;
  color: #303133;
}

.header-right {
  display: flex;
  align-items: center;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  color: #606266;
}

.user-info:hover {
  color: #409eff;
}

.main-content {
  max-width: 1400px;
  margin: 0 auto;
  padding: 20px;
}

.toolbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.prompt-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 20px;
  min-height: 400px;
}

.prompt-card {
  cursor: pointer;
  transition: transform 0.2s;
}

.prompt-card:hover {
  transform: translateY(-4px);
}

.prompt-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.prompt-header h3 {
  margin: 0;
  font-size: 16px;
  color: #303133;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  flex: 1;
}

.prompt-content {
  color: #606266;
  font-size: 14px;
  line-height: 1.6;
  margin-bottom: 12px;
  min-height: 60px;
}

.prompt-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 12px;
  border-top: 1px solid #ebeef5;
}

.prompt-meta {
  display: flex;
  gap: 16px;
  font-size: 14px;
  color: #909399;
}

.prompt-meta span {
  display: flex;
  align-items: center;
  gap: 4px;
}

.prompt-author {
  font-size: 14px;
  color: #909399;
}

@media (max-width: 768px) {
  .header h1 {
    font-size: 18px;
  }
  
  .header-right {
    flex-direction: column;
    align-items: flex-end;
    gap: 10px;
  }
  
  .toolbar {
    flex-direction: column;
    gap: 12px;
  }
  
  .toolbar .el-input {
    width: 100% !important;
  }
  
  .prompt-grid {
    grid-template-columns: 1fr;
  }
}
</style>
