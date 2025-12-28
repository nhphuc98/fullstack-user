# Frontend - User Management

Vue.js 3 application cho quản lý user.

## 🛠️ Công nghệ

- Vue.js 3
- Vue Router
- Axios
- Bootstrap 5

## 📦 Cài đặt

```bash
npm install
```

## 🚀 Chạy Development

```bash
npm run serve
```

Mở http://localhost:8080

## 🏗️ Build Production

```bash
npm run build
```

## 🧹 Lint

```bash
npm run lint
```

## 📁 Cấu trúc thư mục

```
src/
├── components/         # Các component tái sử dụng
├── views/             # Các trang chính
│   ├── UserList.vue   # Danh sách users
│   ├── AddUser.vue    # Thêm user mới
│   └── EditUser.vue   # Sửa user
├── services/          # API services
│   └── UserService.js # User API calls
├── router/            # Vue Router config
│   └── index.js
├── App.vue            # Component root
└── main.js            # Entry point
```

## 🔌 API Configuration

API URL được cấu hình trong `src/services/UserService.js`:

```javascript
const API_URL = 'http://localhost:5000/api/users'
```

Thay đổi URL này nếu backend chạy ở địa chỉ khác.

