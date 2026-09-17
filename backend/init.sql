CREATE DATABASE IF NOT EXISTS farmayopin;
USE farmayopin;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin','client') NOT NULL DEFAULT 'client',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS sales (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS sale_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sale_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (sale_id) REFERENCES sales(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

INSERT INTO products (id, name, description, price, stock, image_url) VALUES
(1, 'Ibuprofeno 400mg', 'Analgésico y antiinflamatorio de uso común. Alivia el dolor leve a moderado y la fiebre.', 450.00, 120, ''),
(2, 'Amoxicilina 500mg', 'Antibiótico de amplio espectro indicado para infecciones bacterianas.', 1200.00, 120, ''),
(3, 'Paracetamol 1g', 'Analgésico y antipirético para el alivio del dolor y la fiebre.', 350.00, 120, ''),
(4, 'Loratadina 10mg', 'Antihistamínico para el alivio de los síntomas de la alergia.', 600.00, 120, '');

-- Cuenta admin predeterminada: admin@farmayopin.com / admin123
INSERT INTO users (name, email, password, role) VALUES
('Admin', 'admin@farmayopin.com', '$2a$10$1EEj3/H0winX2.67EM3NH.JXzLffNHyBvy.qdguBQjVaYWS7WngUG', 'admin');
