<template>
  <div class="page-container">
    <el-container>
      <el-header class="header">
        <div class="header-content">
          <el-button @click="handleBack" text>
            <el-icon><ArrowLeft /></el-icon>
            返回
          </el-button>
          <h2>编辑提示词</h2>
          <div></div>
        </div>
      </el-header>
      
      <el-main v-loading="pageLoading">
        <div class="form-container">
          <el-form :model="form" :rules="rules" ref="formRef" label-width="80px">
            <el-form-item label="标题" prop="title">
              <el-input
                v-model="form.title"
                placeholder="请输入标题（最多200字）"
                maxlength="200"
                show-word-limit
              />
            </el-form-item>
            
            <el-form-item label="内容" prop="content">
              <el-input
                v-model="form.content"
                type="textarea"
                placeholder="请输入提示词内容（最多30000字）"
                :rows="20"
                maxlength="30000"
                show-word-limit
              />
            </el-form-item>
            
            <el-form-item>
              <el-button type="primary" :loading="loading" @click="handleSubmit">
                保存
              </el-button>
              <el-button @click="handleBack">取消</el-button>
            </el-form-item>
          </el-form>
        </div>
      </el-main>
    </el-container>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { getPromptDetail, updatePrompt } from '@/api/prompt'
import type { PromptForm } from '@/types'

const router = useRouter()
const route = useRoute()
const formRef = ref<FormInstance>()
const loading = ref(false)
const pageLoading = ref(false)

const form = reactive<PromptForm>({
  title: '',
  content: ''
})

const rules: FormRules = {
  title: [
    { required: true, message: '请输入标题', trigger: 'blur' },
    { max: 200, message: '标题最多200字', trigger: 'blur' }
  ],
  content: [
    { required: true, message: '请输入内容', trigger: 'blur' },
    { max: 30000, message: '内容最多30000字', trigger: 'blur' }
  ]
}

const fetchPrompt = async () => {
  const id = Number(route.params.id)
  if (!id) {
    ElMessage.error('参数错误')
    router.back()
    return
  }
  
  pageLoading.value = true
  try {
    const res = await getPromptDetail(id)
    form.title = res.data.title
    form.content = res.data.content
  } catch (error) {
    router.back()
  } finally {
    pageLoading.value = false
  }
}

const handleSubmit = async () => {
  if (!formRef.value) return
  
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    
    const id = Number(route.params.id)
    loading.value = true
    try {
      await updatePrompt(id, form)
      ElMessage.success('保存成功')
      router.back()
    } catch (error) {
      // 错误已在拦截器处理
    } finally {
      loading.value = false
    }
  })
}

const handleBack = () => {
  router.back()
}

onMounted(() => {
  fetchPrompt()
})
</script>

<style scoped>
.page-container {
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
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
}

.header h2 {
  margin: 0;
  font-size: 20px;
  color: #303133;
}

.form-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
  background: #fff;
  border-radius: 4px;
}

@media (max-width: 768px) {
  .form-container {
    padding: 15px;
  }
}
</style>
