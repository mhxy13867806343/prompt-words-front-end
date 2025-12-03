<template>
  <div class="page-container">
    <el-container>
      <el-header class="header">
        <div class="header-content">
          <el-button @click="handleBack" text>
            <el-icon><ArrowLeft /></el-icon>
            返回
          </el-button>
          <h2>个人中心</h2>
          <div></div>
        </div>
      </el-header>
      
      <el-main>
        <div class="profile-container">
          <el-card class="user-card">
            <div class="user-info">
              <el-avatar :size="80" :icon="UserFilled" />
              <div class="user-details">
                <h3>{{ userStore.userInfo?.username }}</h3>
                <p v-if="userStore.userInfo?.email">
                  <el-icon><Message /></el-icon>
                  {{ userStore.userInfo.email }}
                </p>
                <el-tag v-if="userStore.needBindEmail" type="warning" size="small">
                  未绑定邮箱
                </el-tag>
                <el-tag v-else type="success" size="small">
                  已绑定邮箱
                </el-tag>
              </div>
              <el-button v-if="userStore.needBindEmail" type="primary" @click="showBindDialog = true">
                绑定邮箱
              </el-button>
            </div>
          </el-card>
          
          <el-tabs v-model="activeTab" @tab-change="handleTabChange">
            <el-tab-pane label="我的提示词" name="my">
              <div v-loading="loading" class="prompt-list">
                <el-empty v-if="!loading && prompts.length === 0" description="暂无数据" />
                
                <el-card
                  v-for="prompt in prompts"
                  :key="prompt.id"
                  class="prompt-item"
                  shadow="hover"
                  @click="handleView(prompt.id)"
                >
                  <div class="prompt-header">
                    <h3>{{ prompt.title }}</h3>
                  </div>
                  <div class="prompt-content">{{ truncateContent(prompt.content) }}</div>
                  <div class="prompt-footer">
                    <div class="prompt-meta">
                      <span><el-icon><View /></el-icon> {{ prompt.viewCount }}</span>
                      <span><el-icon><Star /></el-icon> {{ prompt.likeCount }}</span>
                      <span><el-icon><Collection /></el-icon> {{ prompt.collectCount }}</span>
                    </div>
                    <span class="prompt-date">{{ formatDate(prompt.createdAt) }}</span>
                  </div>
                </el-card>
                
                <el-pagination
                  v-if="total > 0"
                  v-model:current-page="page"
                  v-model:page-size="pageSize"
                  :total="total"
                  :page-sizes="[10, 20, 50]"
                  layout="total, sizes, prev, pager, next"
                  @current-change="fetchData"
                  @size-change="fetchData"
                  style="margin-top: 20px; justify-content: center"
                />
              </div>
            </el-tab-pane>
            
            <el-tab-pane label="我的点赞" name="likes">
              <div v-loading="loading" class="prompt-list">
                <el-empty v-if="!loading && prompts.length === 0" description="暂无数据" />
                
                <el-card
                  v-for="prompt in prompts"
                  :key="prompt.id"
                  class="prompt-item"
                  shadow="hover"
                  @click="handleView(prompt.id)"
                >
                  <div class="prompt-header">
                    <h3>{{ prompt.title }}</h3>
                  </div>
                  <div class="prompt-content">{{ truncateContent(prompt.content) }}</div>
                  <div class="prompt-footer">
                    <div class="prompt-meta">
                      <span><el-icon><View /></el-icon> {{ prompt.viewCount }}</span>
                      <span><el-icon><Star /></el-icon> {{ prompt.likeCount }}</span>
                      <span><el-icon><Collection /></el-icon> {{ prompt.collectCount }}</span>
                    </div>
                    <span class="prompt-author">@{{ prompt.username }}</span>
                  </div>
                </el-card>
                
                <el-pagination
                  v-if="total > 0"
                  v-model:current-page="page"
                  v-model:page-size="pageSize"
                  :total="total"
                  :page-sizes="[10, 20, 50]"
                  layout="total, sizes, prev, pager, next"
                  @current-change="fetchData"
                  @size-change="fetchData"
                  style="margin-top: 20px; justify-content: center"
                />
              </div>
            </el-tab-pane>
            
            <el-tab-pane label="我的收藏" name="collects">
              <div v-loading="loading" class="prompt-list">
                <el-empty v-if="!loading && prompts.length === 0" description="暂无数据" />
                
                <el-card
                  v-for="prompt in prompts"
                  :key="prompt.id"
                  class="prompt-item"
                  shadow="hover"
                  @click="handleView(prompt.id)"
                >
                  <div class="prompt-header">
                    <h3>{{ prompt.title }}</h3>
                  </div>
                  <div class="prompt-content">{{ truncateContent(prompt.content) }}</div>
                  <div class="prompt-footer">
                    <div class="prompt-meta">
                      <span><el-icon><View /></el-icon> {{ prompt.viewCount }}</span>
                      <span><el-icon><Star /></el-icon> {{ prompt.likeCount }}</span>
                      <span><el-icon><Collection /></el-icon> {{ prompt.collectCount }}</span>
                    </div>
                    <span class="prompt-author">@{{ prompt.username }}</span>
                  </div>
                </el-card>
                
                <el-pagination
                  v-if="total > 0"
                  v-model:current-page="page"
                  v-model:page-size="pageSize"
                  :total="total"
                  :page-sizes="[10, 20, 50]"
                  layout="total, sizes, prev, pager, next"
                  @current-change="fetchData"
                  @size-change="fetchData"
                  style="margin-top: 20px; justify-content: center"
                />
              </div>
            </el-tab-pane>
          </el-tabs>
        </div>
      </el-main>
    </el-container>
    
    <BindEmailDialog v-model="showBindDialog" @success="handleBindSuccess" />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { UserFilled } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import { getMyPrompts, getMyLikes, getMyCollects } from '@/api/prompt'
import type { Prompt } from '@/types'
import BindEmailDialog from '@/components/BindEmailDialog.vue'

const router = useRouter()
const userStore = useUserStore()

const loading = ref(false)
const activeTab = ref('my')
const prompts = ref<Prompt[]>([])
const page = ref(1)
const pageSize = ref(10)
const total = ref(0)
const showBindDialog = ref(false)

const fetchData = async () => {
  loading.value = true
  try {
    let res
    const params = { page: page.value, pageSize: pageSize.value }
    
    if (activeTab.value === 'my') {
      res = await getMyPrompts(params)
    } else if (activeTab.value === 'likes') {
      res = await getMyLikes(params)
    } else {
      res = await getMyCollects(params)
    }
    
    prompts.value = res.data.list
    total.value = res.data.total
  } catch (error) {
    // 错误已在拦截器处理
  } finally {
    loading.value = false
  }
}

const handleTabChange = () => {
  page.value = 1
  fetchData()
}

const handleView = (id: number) => {
  router.push(`/prompt/${id}`)
}

const handleBack = () => {
  router.push('/home')
}

const handleBindSuccess = () => {
  showBindDialog.value = false
  userStore.fetchUserInfo()
}

const truncateContent = (content: string) => {
  return content.length > 100 ? content.substring(0, 100) + '...' : content
}

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('zh-CN')
}

onMounted(() => {
  fetchData()
})
</script>

<style scoped>
.page-container {
  min-height: 100vh;
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
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

.header h2 {
  margin: 0;
  font-size: 20px;
  color: #303133;
}

.profile-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.user-card {
  margin-bottom: 20px;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 20px;
}

.user-details {
  flex: 1;
}

.user-details h3 {
  margin: 0 0 8px 0;
  font-size: 20px;
  color: #303133;
}

.user-details p {
  margin: 8px 0;
  color: #606266;
  display: flex;
  align-items: center;
  gap: 4px;
}

.prompt-list {
  min-height: 400px;
}

.prompt-item {
  margin-bottom: 16px;
  cursor: pointer;
  transition: transform 0.2s;
}

.prompt-item:hover {
  transform: translateX(4px);
}

.prompt-header {
  margin-bottom: 12px;
}

.prompt-header h3 {
  margin: 0;
  font-size: 16px;
  color: #303133;
}

.prompt-content {
  color: #606266;
  font-size: 14px;
  line-height: 1.6;
  margin-bottom: 12px;
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

.prompt-author,
.prompt-date {
  font-size: 14px;
  color: #909399;
}

@media (max-width: 768px) {
  .user-info {
    flex-direction: column;
    text-align: center;
  }
  
  .user-details {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
}
</style>
