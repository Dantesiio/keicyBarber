# Keicy Barber App

Aplicación móvil para la gestión de citas en la Peluquería Keicy.

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

---