import { createRouter, createWebHistory } from 'vue-router'
import UserList from '../views/UserList.vue'
import AddUser from '../views/AddUser.vue'
import EditUser from '../views/EditUser.vue'

const routes = [
  {
    path: '/',
    name: 'UserList',
    component: UserList
  },
  {
    path: '/add',
    name: 'AddUser',
    component: AddUser
  },
  {
    path: '/edit/:id',
    name: 'EditUser',
    component: EditUser
  }
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

export default router

