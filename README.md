# PROYECTO_FINAL_DeliGo
Aplicacion de comida DeliGo Sergio, Antonio,Paula
# FoodRush — App de Comida a Domicilio

Aplicación de escritorio hecha con Electron para pedir comida a domicilio.
Este proyecto está hecho como práctica para el ciclo de DAM.

## Estructura del proyecto

```
foodrush/
├── main/
│   ├── main.js        → Controla la ventana de la app
│   └── preload.js     → Comunicación entre backend y frontend
├── renderer/
│   ├── index.html     → Interfaz principal
│   ├── styles/        → Archivos CSS
│   └── js/            → Lógica de la app
│       ├── app.js
│       ├── auth.js
│       ├── menu.js
│       ├── cart.js
│       ├── tracking.js
│       └── admin.js
└── package.json
```



## Cómo ejecutar el proyecto

### Requisitos

* Node.js instalado

### Pasos

```bash
cd foodrush
npm install
npm start
```

Se abrirá la aplicación automáticamente.

---

## Crear el .exe

```bash
npm run build
```

El archivo se genera en la carpeta `dist/`.

## Usuarios de prueba

 Rol       Email                                                 Contraseña 
 Cliente   cliente@foodrush.com                                  1234       
 Admin     admin@foodrush.com                                    admin      

## Funcionalidades

### Usuario

* Registro e inicio de sesión
* Ver menú de comida
* Buscar platos
* Ver información nutricional
* Añadir productos al carrito
* Hacer pedidos
* Ver estado del pedido
* Chat con repartidor

### Administrador

* Ver pedidos
* Cambiar estado de pedidos
* Gestionar platos
* Ver usuarios

## Datos

Los datos se guardan en local en:

```
%APPDATA%/foodrush/foodrush_data.json
```

## Objetivo del proyecto

El objetivo es simular una aplicación real de pedidos de comida aplicando:

* Programación
* Interfaces
* Gestión de datos
