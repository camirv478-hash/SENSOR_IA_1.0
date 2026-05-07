#  SensorIA

##  Descripción

**SensorIA** es una plataforma digital para la gestión inteligente de residuos con Inteligencia Artificial. 
La aplicación permite a los usuarios identificar residuos mediante cámara o texto, recibir indicación de 
la caneca correcta donde depositarlos, y registrar su historial de reciclaje.

### Problema que resuelve

La comunidad educativa del SENA CBA Mosquera presenta dificultades para clasificar correctamente los residuos 
debido a la falta de orientación clara e inmediata en los puntos ecológicos, lo que provoca contaminación 
de materiales reciclables y un manejo ineficiente de los residuos.

### Solución

- Identificación de residuos por imagen (IA con Google ML Kit) o por texto
- Indicación visual del color de caneca correspondiente
- Historial personal de reciclaje
- Panel de administración para gestión de usuarios y canecas
- Verificación de email con código de 6 dígitos
- Recuperación de contraseña

---

##  Integrantes

| Nombre | Rol |
|--------|-----|
| Daniel Muñoz | Desarrollador Backend |
| Camila Rivera | Desarrolladora Full Stack & Desarrollador Frontend & Diseñadora UI/UX|

---

##  Tecnologías utilizadas

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| **Flutter** | 3.41.x | Frontend móvil y web |
| **Dart** | 3.11.x | Lenguaje de programación |
| **Django** | 6.0.x | Backend API REST |
| **Python** | 3.14.x | Lenguaje del backend |
| **PostgreSQL** | 17.x | Base de datos relacional |
| **Django REST Framework** | 3.16.x | API REST |
| **Google ML Kit** | 0.19.x | IA para clasificación de imágenes |
| **JWT** | SimpleJWT | Autenticación |
| **pgAdmin** | - | Administración de BD |

### Librerías principales (Flutter)

| Librería | Uso |
|----------|-----|
| `provider` | Manejo de estado |
| `http` | Peticiones HTTP |
| `image_picker` | Cámara y galería |
| `google_ml_kit` | IA para clasificación |
| `shared_preferences` | Almacenamiento local |
| `connectivity_plus` | Detección de conexión |
| `fl_chart` | Gráficos de estadísticas |

---

##  Requisitos previos

| Requisito | Versión |
|-----------|---------|
| Flutter SDK | 3.22.x o superior |
| Dart SDK | 3.4.x o superior |
| Python | 3.10 o superior |
| PostgreSQL | 16 o superior |
| Git | Cualquier versión |
| Android Studio / VS Code | Cualquier versión |

### Opcional
- Dispositivo Android con depuración USB activada
- Emulador Android

---

##  Instalación

### 1. Clonar el repositorio

bash

git clone https://github.com/camirv478-hash/SENSOR_IA_1.0.git
cd SENSOR_IA_1.0
2. Configurar el Backend (Django)
bash
cd back
python -m venv venv

# Activar entorno virtual (Windows)
.\venv\Scripts\Activate.ps1

# Activar entorno virtual (Linux/Mac)
source venv/bin/activate

# Instalar dependencias
pip install -r requirements.txt

# Configurar variables de entorno (crear archivo .env)
# Ver sección "Variables de entorno"
3. Configurar el Frontend (Flutter)
bash
cd frontend/mobile_app
flutter pub get

 # Ejecución local
1. Levantar PostgreSQL
Asegúrate que el servicio de PostgreSQL esté corriendo:

bash
# Windows
net start postgresql-x64-17

# Linux
sudo systemctl start postgresql
2. Levantar el Backend
bash
cd back
.\venv\Scripts\Activate.ps1  # Windows
# source venv/bin/activate   # Linux/Mac

python manage.py migrate
python manage.py runserver 0.0.0.0:8000
El backend estará disponible en http://127.0.0.1:8000

3. Levantar el Frontend
bash
cd frontend/mobile_app

# Para ejecutar en navegador
flutter run -d edge

# Para ejecutar en dispositivo Android
flutter run

 Base de datos
Crear la base de datos
sql
CREATE DATABASE sensoria;
Migraciones
bash
cd back
python manage.py makemigrations
python manage.py migrate
Modelos principales
Tabla	Descripción
user_user	Usuarios del sistema
residuos	Tipos de residuos
bin_bin	Canecas inteligentes
recycling_records	Historial de reciclaje
email_verifications	Códigos de verificación
 Variables de entorno
Archivo .env (crear en la carpeta back)
env
# ============================
# DJANGO CONFIG
# ============================
DEBUG=True
SECRET_KEY=tu_clave_secreta_aqui
ALLOWED_HOSTS=*
CORS_ALLOW_ALL=True

# ============================
# BASE DE DATOS
# ============================
DB_ENGINE=postgres
DB_NAME=sensoria
DB_USER=postgres
DB_PASSWORD=tu_contraseña
DB_HOST=localhost
DB_PORT=5432

# ============================
# EMAIL
# ============================
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=tu_correo@gmail.com
EMAIL_HOST_PASSWORD=tu_contraseña_app

# ============================
# FRONTEND URL
# ============================
FRONTEND_URL=http://localhost:8080
Variables en Flutter
Editar lib/core/constants/api_constants.dart:

dart
static const String baseUrl = 'http://192.168.x.x:8000';  // Tu IP local
 Usuario de prueba
Campo	Valor
Email	admin@admin.com
Contraseña	admin123
Crear superusuario
bash
cd back
python manage.py createsuperuser
 Endpoints principales
Método	Endpoint	Descripción
POST	/user/auth/login/	Inicio de sesión
POST	/user/register/	Registro de usuario
POST	/user/verify-email/	Verificar email
POST	/user/password/reset/	Solicitar recuperación
POST	/residue/identify/	Identificar residuo
GET	/recycling/history/	Historial de reciclaje
GET	/bin/	Listar canecas

 Evidencias
Login
https://screenshots/login.png

Dashboard
https://screenshots/dashboard.png

Escaneo con IA
https://screenshots/scan.png

Historial
https://screenshots/history.png

Panel Admin
https://screenshots/admin.png

Las capturas se encuentran en la carpeta screenshots/ del repositorio.

 Estructura del proyecto
text
SENSOR_IA_1.0/
├── back/                          # Backend Django
│   ├── back/                      # Configuración del proyecto
│   ├── user/                      # App de usuarios
│   ├── bin/                       # App de canecas
│   ├── residuos/                  # App de residuos
│   ├── records/                   # App de historial
│   ├── manage.py
│   ├── requirements.txt
│   └── .env
│
├── frontend/
│   └── mobile_app/                # Frontend Flutter
│       ├── lib/
│       │   ├── screens/           # Pantallas
│       │   ├── services/          # Servicios API
│       │   ├── models/            # Modelos de datos
│       │   ├── providers/         # Estado (Provider)
│       │   └── core/              # Constantes y temas
│       ├── assets/                # Imágenes y modelos IA
│       ├── pubspec.yaml
│       └── update_ip.dart         # Script actualizar IP
│
└── README.md
 Contribución
Crear una rama con git checkout -b feature/nueva-funcionalidad

Hacer commits descriptivos

Hacer push a la rama

Crear un Pull Request

 Licencia
Proyecto académico desarrollado para el SENA - Centro de Biotecnología Agropecuaria (CBA) Mosquera.

 Agradecimientos
Instructora Stefy Velandia

Instructora Carolina Torres

Todos los compañeros del equipo SensorIA

 Contacto
Integrante	Email
Daniel Muñoz	hosedanieru15@gmail.com
Camila Rivera	camirv478@gmail.com
SensorIA - Una herramienta para un futuro más limpio y sostenible 

text

---

## **Instrucciones para completar el README**

| Sección | Acción |
|---------|--------|
| Capturas de pantalla | Crear carpeta `screenshots/` y agregar imágenes |
| Emails de integrantes | Completar los que faltan |
| IP en ejemplo | Cambiar por la IP que uses |

---
