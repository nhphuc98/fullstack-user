<template>
  <div class="user-list">
    <h2 class="mb-4">User List</h2>

    <!-- Alert messages -->
    <div v-if="message" class="alert alert-success alert-dismissible fade show" role="alert">
      {{ message }}
      <button type="button" class="btn-close" @click="message = ''"></button>
    </div>

    <div v-if="error" class="alert alert-danger alert-dismissible fade show" role="alert">
      {{ error }}
      <button type="button" class="btn-close" @click="error = ''"></button>
    </div>

    <!-- Search box -->
    <div class="row mb-3">
      <div class="col-md-6">
        <input
          type="text"
          class="form-control"
          placeholder="Search by name or email..."
          v-model="searchQuery"
        />
      </div>
      <div class="col-md-6 text-end">
        <router-link to="/add" class="btn btn-primary">
          Add New User
        </router-link>
      </div>
    </div>

    <!-- Loading spinner -->
    <div v-if="loading" class="text-center">
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Loading...</span>
      </div>
    </div>

    <!-- User table -->
    <div v-else>
      <div v-if="filteredUsers.length === 0" class="alert alert-info">
        No users in the system.
      </div>

      <div v-else class="table-responsive">
        <table class="table table-striped table-hover">
          <thead class="table-dark">
            <tr>
              <th>ID</th>
              <th>Email</th>
              <th>First Name</th>
              <th>Last Name</th>
              <th class="text-center">Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="user in filteredUsers" :key="user.id">
              <td>{{ user.id }}</td>
              <td>{{ user.email }}</td>
              <td>{{ user.firstName }}</td>
              <td>{{ user.lastName }}</td>
              <td class="text-center">
                <router-link 
                  :to="`/edit/${user.id}`" 
                  class="btn btn-sm btn-warning me-2"
                >
                  Edit
                </router-link>
                <button 
                  @click="deleteUserConfirm(user.id)" 
                  class="btn btn-sm btn-danger"
                >
                  Delete
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
import UserService from '../services/UserService'

export default {
  name: 'UserList',
  data() {
    return {
      users: [],
      searchQuery: '',
      loading: false,
      message: '',
      error: ''
    }
  },
  computed: {
    filteredUsers() {
      if (!this.searchQuery) {
        return this.users
      }
      
      const query = this.searchQuery.toLowerCase()
      return this.users.filter(user => 
        user.email.toLowerCase().includes(query) ||
        user.firstName.toLowerCase().includes(query) ||
        user.lastName.toLowerCase().includes(query)
      )
    }
  },
  methods: {
    async loadUsers() {
      this.loading = true
      this.error = ''
      
      try {
        const response = await UserService.getAllUsers()
        this.users = response.data
      } catch (err) {
        this.error = 'Unable to load users. Please check API connection.'
        console.error('Error loading users:', err)
      } finally {
        this.loading = false
      }
    },
    
    async deleteUserConfirm(id) {
      if (confirm('Are you sure you want to delete this user?')) {
        await this.deleteUser(id)
      }
    },
    
    async deleteUser(id) {
      try {
        await UserService.deleteUser(id)
        this.message = 'User deleted successfully!'
        this.loadUsers()
        
        // Auto hide message after 3 seconds
        setTimeout(() => {
          this.message = ''
        }, 3000)
      } catch (err) {
        this.error = 'Unable to delete user. Please try again.'
        console.error('Error deleting user:', err)
      }
    }
  },
  mounted() {
    this.loadUsers()
  }
}
</script>

<style scoped>
.user-list {
  max-width: 1200px;
  margin: 0 auto;
}

h2 {
  color: #333;
  font-weight: bold;
}

.table {
  background-color: white;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.btn {
  font-size: 0.875rem;
}
</style>

