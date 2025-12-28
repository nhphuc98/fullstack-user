import axios from 'axios'

// Use relative URL - Nginx will proxy to backend container
const API_URL = '/api/users'

class UserService {
  // Lấy tất cả users
  getAllUsers() {
    return axios.get(API_URL)
  }

  // Lấy user theo ID
  getUserById(id) {
    return axios.get(`${API_URL}/${id}`)
  }

  // Tạo user mới
  createUser(user) {
    return axios.post(API_URL, user)
  }

  // Cập nhật user
  updateUser(id, user) {
    return axios.put(`${API_URL}/${id}`, user)
  }

  // Xóa user
  deleteUser(id) {
    return axios.delete(`${API_URL}/${id}`)
  }
}

export default new UserService()

