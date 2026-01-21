-- Database: fullstack_user
-- Table: users

CREATE DATABASE fullstack_user;

CREATE TABLE IF NOT EXISTS public.users
(
    id           serial primary key,
    email        VARCHAR(40) not null,
    first_name   VARCHAR(40) not null,
    last_name    VARCHAR(40) not null
);

-- Thêm dữ liệu mẫu
INSERT INTO public.users (email, first_name, last_name) VALUES
('john.doe@example.com', 'Doe', 'John'),
('jane.smith@example.com', 'Smith', 'Jane'),
('phucnguyen@example.com', 'Nguyen', 'Phuc'),
('nguyen.van.a@example.com', 'Nguyen', 'Van A'),
('tran.thi.b@example.com', 'Tran', 'Thi B'),
('pham.van.c@example.com', 'Pham', 'Van C');