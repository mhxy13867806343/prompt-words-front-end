<template>
  <div class="page-container">
    <el-container>
      <el-header class="header">
        <div class="header-content">
          <el-button @click="handleBack" text>
            <el-icon><ArrowLeft /></el-icon>
            返回
          </el-button>
          <h2>提示词详情</h2>
          <div></div>
        </div>
      </el-header>
      
      <el-main v-loading="loading">
        <div class="detail-container" v-if="prompt">
          <div class="detail-header">
            <h1>{{ prompt.title }}</h1>
            <div class="detail-actions" v-if="!isOwner">
              <el-button
                :type="prompt.isLiked ? 'primary' : 'default'"
                :icon="prompt.isLiked ? StarFilled : Star"
                @click="handleLike"
              >
                {{ prompt.isLiked ? '已点赞' : '点赞' }} ({{ prompt.likeCount }})
              </el-button>
              <el-button
                :type="prompt.isCollected ? 'warning' : 'default'"
                :icon="prompt.isCollected ? CollectionTag : Collection"
                @click="handleCollect"
              >
                {{ prompt.isCollected ? '已收藏' : '收藏' }} ({{ prompt.collectCount }})
              </el-button>
              <el-button :icon="Share" @click="handleShare">分享</el-button>
              <el-button :icon="DocumentCopy" @click="handleCopy">复制</el-button>
            </div>
            <div class="detail-actions" v-else>
              <el-button type="primary" :icon="Edit" @click="handleEdit">编辑</el-button>
              <el-button type="danger" :icon="Delete" @click="handleDelete">删除</el-button>
              <el-button :icon="Share" @click="handleShare">分享</el-button>
              <el-button :icon="DocumentCopy" @click="handleCopy">复制</el-button>
            </div>
          </div>
          
          <div class="detail-meta">
            <span>作者：@{{ prompt.username }}</span>
            <span>浏览：{{ prompt.viewCount }}</span>
            <span>创建时间：{{ formatDate(prompt.createdAt) }}</span>
          </div>
          
          <el-divider />
          
          <div class="detail-content">
            <pre>{{ prompt.content }}</pre>
          </div>
        </div>
      </el-main>
    </el-container>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Star, StarFilled, Collection, CollectionTag, Share, DocumentCopy, Edit, Delete } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import { getPromptDetail, likePrompt, unlikePrompt, collectPrompt, uncollectPrompt, deletePrompt } from '@/api/prompt'
import type { Prompt } from '@/types'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const loading = ref(false)
const prompt = ref<Prompt | null>(null)

const isOwner = computed(() => {
  return prompt.value?.userId === userStore.userInfo?.id
})

const fetchPrompt = async () => {
  const id = Number(route.params.id)
  if (!id) {
    ElMessage.error('参数错误')
    router.back()
    return
  }
  
  loading.value = true
  try {
    const res = await getPromptDetail(id)
    prompt.value = res.data
  } catch (error) {
    router.back()
  } finally {
    loading.value = false
  }
}

const handleLike = async () => {
  if (!prompt.value) return
  
  try {
    if (prompt.value.isLiked) {
      await unlikePrompt(prompt.value.id)
      prompt.value.isLiked = false
      prompt.value.likeCount--
      ElMessage.success('已取消点赞')
    } else {
      await likePrompt(prompt.value.id)
      prompt.value.isLiked = true
      prompt.value.likeCount++
      ElMessage.success('点赞成功')
    }
  } catch (error) {
    // 错误已在拦截器处理
  }
}

const handleCollect = async () => {
  if (!prompt.value) return
  
  try {
    if (prompt.value.isCollected) {
      await uncollectPrompt(prompt.value.id)
      prompt.value.isCollected = false
      prompt.value.collectCount--
      ElMessage.success('已取消收藏')
    } else {
      await collectPrompt(prompt.value.id)
      prompt.value.isCollected = true
      prompt.value.collectCount++
      ElMessage.success('收藏成功')
    }
  } catch (error) {
    // 错误已在拦截器处理
  }
}

const handleShare = () => {
  const url = window.location.href
  navigator.clipboard.writeText(url)
  ElMessage.success('分享链接已复制到剪贴板')
}

const handleCopy = () => {
  if (!prompt.value) return
  navigator.clipboard.writeText(prompt.value.content)
  ElMessage.success('内容已复制到剪贴板')
}

const handleEdit = () => {
  if (!prompt.value) return
  router.push(`/edit/${prompt.value.id}`)
}

const handleDelete = async () => {
  if (!prompt.value) return
  
  try {
    await ElMessageBox.confirm('确定要删除这个提示词吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
    
    await deletePrompt(prompt.value.id)
    ElMessage.success('删除成功')
    router.push('/home')
  } catch (error) {
    // 用户取消或错误
  }
}

const handleBack = () => {
  router.back()
}

const formatDate = (date: string) => {
  return new Date(date).toLocaleString('zh-CN')
}

onMounted(() => {
  fetchPrompt()
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

.detail-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
  background: #fff;
  border-radius: 4px;
}

.detail-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 20px;
  margin-bottom: 16px;
}

.detail-header h1 {
  margin: 0;
  font-size: 28px;
  color: #303133;
  flex: 1;
}

.detail-actions {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.detail-meta {
  display: flex;
  gap: 24px;
  color: #909399;
  font-size: 14px;
}

.detail-content {
  margin-top: 20px;
}

.detail-content pre {
  white-space: pre-wrap;
  word-wrap: break-word;
  font-family: inherit;
  font-size: 15px;
  line-height: 1.8;
  color: #303133;
}

@media (max-width: 768px) {
  .detail-header {
    flex-direction: column;
  }
  
  .detail-header h1 {
    font-size: 22px;
  }
  
  .detail-actions {
    width: 100%;
  }
  
  .detail-actions .el-button {
    flex: 1;
  }
  
  .detail-meta {
    flex-direction: column;
    gap: 8px;
  }
}
</style>
