# Gatcha! / Māo Fēng 猫疯 🐱🎮

Este proyecto es un videojuego tipo WarioWare, desarrollado en Godot 4.4, donde el jugador debe completar una serie de microjuegos rápidos, aleatorios y divertidos, todo dentro del sueño de un gato. Cada microjuego pone a prueba tus reflejos, ingenio y coordinación bajo presión.

---

## 🎯 Objetivo del juego

El objetivo es completar **30 microjuegos aleatorios** sin perder todas tus vidas. Si lo logras, enfrentarás un **jefe final** que reúne elementos de los microjuegos anteriores. Si fallas todos tus intentos... el gato seguirá soñando.

---

## 🧩 Estructura del juego (versión 3.1)

- `menu_principal.tscn`: pantalla inicial con botones de navegación  
- `cinematica.tscn`: intro animada donde el gato se duerme  
- `micro_inicio.tscn`: pantalla de transición con contador y vidas  
- `minijuegos/`: carpeta donde cada microjuego es una escena independiente  
- `microjuego1.tscn`: microjuego implementado (tecla rápida)  
- `micro_gato_equilibrio.tscn`: microjuego del gato sobre la cuerda  
- `micro_abrelatas.tscn`: microjuego de presionar repetidamente para abrir una lata  
- `plantilla/`: escena base con barra de tiempo e instrucciones para guiar nuevos microjuegos  
- `sistema_vidas.gd`: script de control de vidas  
- `audio/`: sonidos y música por microjuego  
- `sprites/`: recursos visuales como gatos, pescados, fondos y manos  

---

## 🕹️ Cómo jugar

1. Ejecuta `menu_principal.tscn`  
2. Selecciona "Historia"  
3. Mira la intro del gato durmiendo  
4. Supera los microjuegos uno tras otro  
5. Llega al jefe final tras 30 microjuegos  

---

## 🔧 Tecnologías utilizadas

- [Godot Engine 4.4](https://godotengine.org/)  
- GDScript  
- Audacity y gTTS para efectos de voz  
- Piskel y Photoshop para sprites  
- GitHub para control de versiones  

---

## 👨‍💻 Equipo de desarrollo

- Branco Abalos  
- Ramiro Alvarado  
- Benjamin Cuello  
- Andres Toro  
- Matias Vidal  
- Emily Volta  

---

## 🚧 Estado del proyecto (actualizado a v3.1)

✅ Menú principal  
✅ Transición entre microjuegos con contador visible  
✅ Microjuego 1 funcional (reflejos con teclas)  
✅ Microjuego 2: Gato equilibrio  
✅ Microjuego 3: Abrelatas (pendiente agregar sprites finales)  
✅ Sistema de vidas implementado (pierdes si fallas 3 veces)  
✅ Fin de partida por derrota o al completar los 30 microjuegos  
✅ Selección aleatoria de microjuegos  
✅ Botón de salida y tecla ESC funcional en cualquier momento  
✅ Carpeta `plantilla/` con estructura base para nuevos microjuegos  
🔜 Cinemática del gato 
🔜 Música de fondo y efectos  
🔜 Jefe final  
🔜 Botones infinito
🔜 Menu de opciones
🔜 27 microjuegos mas 
🔜 Señales para juego cruzado  

---

## 💬 Contribuciones

Este proyecto es académico. Si quieres dar ideas creativas o mejorar el juego, puedes enviar tus ideas

---

## 📸 Capturas

![image](https://github.com/user-attachments/assets/6a6be39f-9221-4592-8022-45d48e37cfe8)
![image](https://github.com/user-attachments/assets/2c5ffa12-a32e-4ee4-99c2-41926c0e2734)
![image](https://github.com/user-attachments/assets/2dc3a5a0-24bf-42d7-9515-d218766fef86)

---

¡Gracias por apoyar este proyecto y al gato soñador! 🐾✨
