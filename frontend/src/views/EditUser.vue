<template>
  <div class="edit-user">
    <h2 class="mb-4">Update User</h2>

    <!-- Loading spinner -->
    <div v-if="loadingUser" class="text-center">
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Loading...</span>
      </div>
    </div>

    <div v-else class="card">
      <div class="card-body">
        <form @submit.prevent="submitForm">
          <div class="mb-3">
            <label for="email" class="form-label">Email <span class="text-danger">*</span></label>
            <input
              type="email"
              class="form-control"
              id="email"
              v-model="user.email"
              :class="{ 'is-invalid': errors.email }"
              placeholder="user@example.com"
              required
            />
            <div v-if="errors.email" class="invalid-feedback">
              {{ errors.email }}
            </div>
          </div>

          <div class="mb-3">
            <label for="firstName" class="form-label">First Name <span class="text-danger">*</span></label>
            <input
              type="text"
              class="form-control"
              id="firstName"
              v-model="user.firstName"
              :class="{ 'is-invalid': errors.firstName }"
              placeholder="Enter first name"
              required
            />
            <div v-if="errors.firstName" class="invalid-feedback">
              {{ errors.firstName }}
            </div>
          </div>

          <div class="mb-3">
            <label for="lastName" class="form-label">Last Name <span class="text-danger">*</span></label>
            <input
              type="text"
              class="form-control"
              id="lastName"
              v-model="user.lastName"
              :class="{ 'is-invalid': errors.lastName }"
              placeholder="Enter last name"
              required
            />
            <div v-if="errors.lastName" class="invalid-feedback">
              {{ errors.lastName }}
            </div>
          </div>

          <div v-if="error" class="alert alert-danger">
            {{ error }}
          </div>

          <div class="d-flex gap-2">
            <button type="submit" class="btn btn-primary" :disabled="loading">
              <span v-if="loading" class="spinner-border spinner-border-sm me-2"></span>
              {{ loading ? 'Updating...' : 'Update' }}
            </button>
            <router-link to="/" class="btn btn-secondary">
              Back
            </router-link>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import UserService from '../services/UserService'

export default {
  name: 'EditUser',
  data() {
    return {
      user: {
        id: 0,
        email: '',
        firstName: '',
        lastName: ''
      },
      errors: {},
      error: '',
      loading: false,
      loadingUser: false
    }
  },
  methods: {
    async loadUser() {
      this.loadingUser = true
      this.error = ''
      
      try {
        const response = await UserService.getUserById(this.$route.params.id)
        this.user = response.data
      } catch (err) {
        this.error = 'Unable to load user information. Please try again.'
        console.error('Error loading user:', err)
      } finally {
        this.loadingUser = false
      }
    },
    
    validateForm() {
      this.errors = {}
      
      if (!this.user.email) {
        this.errors.email = 'Email is required'
      } else if (!/\S+@\S+\.\S+/.test(this.user.email)) {
        this.errors.email = 'Invalid email format'
      } else if (this.user.email.length > 40) {
        this.errors.email = 'Email must not exceed 40 characters'
      }
      
      if (!this.user.firstName) {
        this.errors.firstName = 'First name is required'
      } else if (this.user.firstName.length > 40) {
        this.errors.firstName = 'First name must not exceed 40 characters'
      }
      
      if (!this.user.lastName) {
        this.errors.lastName = 'Last name is required'
      } else if (this.user.lastName.length > 40) {
        this.errors.lastName = 'Last name must not exceed 40 characters'
      }
      
      return Object.keys(this.errors).length === 0
    },
    
    async submitForm() {
      if (!this.validateForm()) {
        return
      }
      
      this.loading = true
      this.error = ''
      
      try {
        await UserService.updateUser(this.user.id, this.user)
        this.$router.push('/')
      } catch (err) {
        this.error = 'Unable to update user. Please try again.'
        console.error('Error updating user:', err)
      } finally {
        this.loading = false
      }
    }
  },
  mounted() {
    this.loadUser()
  }
}
</script>

<style scoped>
.edit-user {
  max-width: 600px;
  margin: 0 auto;
}

.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

h2 {
  color: #333;
  font-weight: bold;
}

.form-label {
  font-weight: 500;
}

.gap-2 {
  gap: 0.5rem;
}
</style>

