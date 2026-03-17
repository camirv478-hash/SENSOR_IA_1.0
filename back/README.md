# SensorIA — Backend API

API REST construida con Django + DRF + JWT.

## Stack

- Python 3.12
- Django 6.0
- Django REST Framework
- SimpleJWT
- PostgreSQL / SQLite
- drf-spectacular (Swagger)

## Instalación
```bash
git clone <repo>
cd back
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
python manage.py migrate
python manage.py runserver
```

## Variables de entorno

Copia `.env.example` y completa los valores:
```env
SECRET_KEY=
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1
DB_ENGINE=sqlite
CORS_ALLOW_ALL=True
USE_S3=False
EMAIL_HOST_USER=
EMAIL_HOST_PASSWORD=
FRONTEND_URL=http://localhost:3000
```

## Endpoints principales

| Método | Endpoint | Auth | Descripción |
|--------|----------|:----:|-------------|
| POST | `/api/users/auth/login/` | ❌ | Login |
| POST | `/api/users/auth/logout/` | ✅ | Logout |
| POST | `/api/users/auth/refresh/` | ❌ | Refresh token |
| POST | `/api/users/register/` | ❌ | Registro |
| POST | `/api/users/verify-email/` | ✅ | Verificar email |
| GET | `/api/users/me/` | ✅ | Ver perfil |
| PATCH | `/api/users/me/` | ✅ | Editar perfil |
| PATCH | `/api/users/me/username/` | ✅ | Cambiar username |
| POST | `/api/users/me/email/change/` | ✅ | Solicitar cambio email |
| POST | `/api/users/me/email/confirm/` | ✅ | Confirmar cambio email |
| POST | `/api/users/password/reset/` | ❌ | Solicitar reset |
| POST | `/api/users/password/reset/confirm/` | ❌ | Confirmar reset |
| GET | `/api/users/` | ✅ ADMIN | Listar usuarios |
| GET | `/api/users/<pk>/` | ✅ ADMIN | Detalle usuario |
| PATCH | `/api/users/<pk>/` | ✅ ADMIN | Editar rol/estado |
| DELETE | `/api/users/<pk>/` | ✅ ADMIN | Eliminar usuario |

## Documentación

Con el servidor corriendo: [http://localhost:8000/api/docs/](http://localhost:8000/api/docs/)

## Tests
```bash
python manage.py test user.tests
coverage run manage.py test user.tests && coverage report -m
```