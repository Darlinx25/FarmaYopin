# FarmaYopin

Aplicación móvil de gestión de artículos de farmacia. Taller de Aplicaciones Móviles - UTEC Maldonado - Edición 2026.

## Arquitectura

```
┌─────────────────────────┐         HTTPS/JSON         ┌──────────────────────────┐
│   App Flutter (móvil)   │  ───────────────────────►  │   Backend Go + Gin       │
│                         │                            │   (contenedor Docker)    │
│  - SQLite local         │                            │                          │
│   (carrito, caché)      │ ◄───────────────────────   │  - REST API              │
│                         │         JWT Bearer         │  - JWT auth              │
└─────────────────────────┘                            └──────────┬───────────────┘
                                                                  │ SQL
                                                                  ▼
                                                  ┌──────────────────────────┐
                                                  │   MySQL 8 (Docker)       │
                                                  │  users/products/sales    │
                                                  └──────────────────────────┘
```

### Justificación de la solución

- **Backend Go + MySQL en Docker**: separación clara entre persistencia y presentación. El servidor expone una API REST con JSON, la base de datos queda aislada en su propia red Docker y persiste con un volumen (`mysql_data`).
- **REST + JSON**: el formato estándar para apps móviles, fácil de consumir desde Flutter con el paquete `http`.
- **JWT**: autenticación stateless, sin manejo de sesiones en servidor. Un token incluye `user_id`, `email` y `role` (admin/client).
- **Flutter + setState**: para el alcance del proyecto no se justifica un state manager complejo (Bloc/Riverpod). `setState` + Futures cubren todas las pantallas.
- **SQLite local**: la app guarda el token de sesión con `shared_preferences` (no sensible). El carrito se mantiene en el backend; SQLite queda disponible para características offline (se puede extender a caché de productos).

## Estructura

```
FarmaYopin/
├── backend/              # Go + Gin + MySQL
│   ├── main.go           # Entry point: DB, rutas, middleware
│   ├── init.sql          # Schema + admin inicial
│   ├── Dockerfile
│   ├── db/               # Conexión MySQL
│   ├── models/           # Structs (User, Product, Purchase...)
│   ├── middleware/       # JWT + AdminRequired
│   └── handlers/         # auth, products, cart, purchases
├── app/                  # Flutter
│   ├── lib/
│   │   ├── main.dart
│   │   ├── theme.dart
│   │   ├── api/          # ApiClient + AuthStorage
│   │   ├── models/       # User, Product, CartItem, Purchase...
│   │   └── screens/      # Login, Registro, Home, Productos, Carrito,
│   │                     # Historial + admin (lista/form/historial)
└── docker-compose.yml
```

## API REST

| Método | Ruta | Acceso | Descripción |
|--------|------|--------|-------------|
| POST | `/register` | Público | Registrar cliente |
| POST | `/login` | Público | Login, devuelve JWT + user |
| GET | `/api/products` | Auth | Listar productos |
| GET | `/api/products/:id` | Auth | Ver producto (precio, detalle, foto, stock) |
| POST | `/api/products` | Admin | Crear producto |
| PUT | `/api/products/:id` | Admin | Editar producto |
| GET | `/api/products/:id/history` | Admin | Histórico de compras del producto |
| GET | `/api/cart` | Auth | Ver carrito |
| POST | `/api/cart` | Auth | Agregar al carrito |
| PUT | `/api/cart/:product_id` | Auth | Editar cantidad (0 elimina) |
| DELETE | `/api/cart/:product_id` | Auth | Eliminar del carrito |
| POST | `/api/cart/checkout` | Auth | Pagar carrito (descuenta stock) |
| GET | `/api/purchases` | Auth | Histórico de compras del cliente |

Todas las rutas autenticadas requieren header `Authorization: Bearer <token>`.

## Puesta en marcha

### Backend (`docker compose`)

```bash
docker compose up --build
```

- API en `http://localhost:8080`
- Health check: `curl http://localhost:8080/health`
- Base de datos MySQL persiste en el volumen `mysql_data` (borrar con `docker compose down -v`)

### App Flutter

Requisito: tener Flutter instalado.

```bash
cd app
flutter create --platforms=android,ios .   # genera android/, ios/ (no pisa lib/)
flutter pub get
flutter run
```

La app apunta por defecto a `http://10.0.2.2:8080` (host de la máquina desde el emulador Android). Para otro destino:

```bash
flutter run --dart-define=API_URL=http://TU_IP:8080
```

> Nota: en emulador Android la base URL por defecto ya funciona (`10.0.2.2` = localhost del host). Para Android físico, usar la IP local de la máquina.

## Credenciales por defecto

| Rol | Email | Contraseña |
|-----|-------|------------|
| Admin | `admin@farmayopin.com` | `admin123` |

Los clientes se registran desde la app.