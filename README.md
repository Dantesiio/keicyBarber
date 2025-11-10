# Keicy Barber App

Aplicación móvil para la gestión de citas en la Peluquería Keicy.

### ⚙️ Configuración del Entorno (.env)

El archivo `.env` debe incluir las claves de conexión a Supabase:

```env
SUPABASE_URL=https://sjczmvfxzaajruyxgrhy.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNqY3ptdmZ4emFhanJ1eXhncmh5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkxNzE1MzQsImV4cCI6MjA3NDc0NzUzNH0.gjRo2Jd2ielDgZJ60B2m0AzzOlJpi0MAsc_7AtVtARs
```

### 🔐 Credenciales de Prueba

Para navegar y probar los flujos, se pueden utilizar las siguientes credenciales de ejemplo (según los datos cargados en Supabase):

| Tipo de Usuario | Email | Contraseña |
|------------------|------------------------|-------------|
| Cliente de prueba | test2@test.com | test1234 |

>  *Las credenciales de prueba son únicamente para fines de desarrollo y validación del flujo.*

## 🚀 Flujos de la Aplicación

A continuación se describen las instrucciones básicas para navegar a través de los flujos principales implementados en la aplicación.

### 1. Flujo de Autenticación de Usuarios

#### Registro de una Nueva Cuenta

Este flujo permite a un nuevo usuario crear una cuenta en la aplicación para acceder a sus funcionalidades.

1.  **Iniciar desde la Pantalla de Bienvenida:** Al abrir la aplicación por primera vez, se presenta una pantalla de bienvenida.
2.  **Acceder al Registro:** Desde la pantalla de bienvenida, presiona el botón que te dirige a la pantalla de **"Login"**. En la pantalla de Login, haz clic en el texto **"¿No tienes cuenta? Regístrate"**.
3.  **Completar el Formulario:** Rellena todos los campos del formulario de registro:
    *   Nombre
    *   Apellido
    *   Correo electrónico (debe ser único)
    *   Teléfono
    *   Fecha de nacimiento (al tocarlo se abrirá un selector de calendario)
    *   Contraseña (debe tener al menos 8 caracteres)
    *   Confirmar contraseña
4.  **Crear la Cuenta:** Presiona el botón **"Crear cuenta"**.
5.  **Resultado:** Si los datos son válidos, la cuenta se creará y serás redirigido automáticamente a la pantalla de **"Inicio"** de la aplicación, ya con la sesión iniciada.

#### Inicio de Sesión (Login)

Este flujo permite a un usuario ya registrado acceder a su cuenta.

1.  **Acceder al Login:** Desde la pantalla de bienvenida, presiona el botón que te dirige a la pantalla de **"Inicia sesión"**.
2.  **Ingresar Credenciales:** Introduce el **correo electrónico** y la **contraseña** asociados a tu cuenta.
3.  **Iniciar Sesión:** Presiona el botón **"Iniciar sesión"**.
4.  **Resultado:** Si las credenciales son correctas, serás redirigido a la pantalla de **"Inicio"** de la aplicación. En caso de error (ej. contraseña incorrecta), se mostrará una notificación y permanecerás en la pantalla de login.

### 2. Flujo Principal (Usuario con Sesión Iniciada)

Una vez que el usuario ha iniciado sesión, puede navegar por las secciones principales de la aplicación utilizando la **barra de navegación inferior**.

#### Ver Perfil de Usuario

Permite al usuario consultar la información personal asociada a su cuenta.

1.  **Navegar a Perfil:** En la barra de navegación inferior, haz clic en el ícono de **"Perfil"** (el último a la derecha).
2.  **Visualizar Datos:** La pantalla mostrará los datos con los que el usuario se registró:
    *   Nombre y Apellido
    *   Correo electrónico
    *   Teléfono
    *   Fecha de nacimiento

#### Navegación entre Secciones

La barra de navegación inferior permite un acceso rápido a las demás funcionalidades principales:

*   **Inicio:** Pantalla principal de la aplicación.
*   **Agendar:** Flujo para crear una nueva cita (funcionalidad futura).
*   **Citas:** Listado de citas agendadas por el usuario (funcionalidad futura).

### 3. Flujo de Agendamiento de Citas (Integrado con Supabase)

Este flujo permite a los usuarios agendar una cita completa en la peluquería, seleccionando la sede, servicios, barbero, fecha y hora disponibles.

#### Instrucciones:

1. **Acceder al flujo de agendamiento**  
   Desde la barra inferior, toca el ícono de **“Agendar”**.

2. **Seleccionar Servicios**  
   Elige uno o varios servicios (p. ej.: *Corte*, *Barba*, *Tinte*).  
   → La **duración total** y el **costo estimado** se calculan automáticamente según los servicios seleccionados.

3. **Seleccionar Sede**  
   Elige la sede donde quieres atenderte (p. ej.: *Sede Norte*, *Sede Sur*).  
   → Con base en la sede, se cargan los **barberos disponibles** en esa ubicación.

4. **Seleccionar Barbero**  
   Verás una lista de barberos con sus **especialidades** y **calificación**.  
   → Selecciona uno para continuar.

5. **Seleccionar Fecha**  
   Se muestran los próximos **7 días** disponibles para ese barbero y sede.

6. **Seleccionar Hora**  
   Solo se listan horas **disponibles y válidas**, calculadas dinámicamente según:  
   - La **duración total** de los servicios elegidos.  
   - Las **citas ya registradas** en Supabase (evita traslapes).  
   - Los **horarios de trabajo**: mañana **9:00–13:00** (1 p. m. reservado para almuerzo) y tarde **14:00–19:00**.  
   → Ejemplo: si el servicio dura **120 min**, los últimos horarios válidos serían **11:00 a. m.** (mañana) y **5:00 p. m.** (tarde).

7. **Confirmar Cita**  
   Presiona **“Continuar”** para ver el **resumen** (servicios, sede, barbero, fecha/hora, precio estimado y duración).  
   → Confirma para **guardar la reserva** en **Supabase**.

---

### 4. Flujo de Visualización de Citas (Pendiente para Sprint Futuro)

En la pestaña **“Citas”**, se mostrarán todas las reservas creadas por el usuario, con su fecha, hora, barbero asignado y estado.

---
