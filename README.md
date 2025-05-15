# Gatcha! / Māo Fēng 猫疯 🐱🎮

Este proyecto es un videojuego tipo WarioWare, desarrollado en Godot 4.4, donde el jugador debe completar una serie de microjuegos rápidos, aleatorios y divertidos, todo dentro del sueño de un gato. Cada microjuego pone a prueba tus reflejos, ingenio y coordinación bajo presión.

---

## 🎯 Objetivo del juego

El objetivo es completar **30 microjuegos aleatorios** sin perder todas tus vidas. Si lo logras, enfrentarás un **jefe final** que reúne elementos de los microjuegos anteriores. Si fallas todos tus intentos... el gato seguirá soñando.

---

## 🧩 Estructura del juego (versión 4.0)

- `menu_principal.tscn`: pantalla inicial con botones de navegación  
- `cinematica.tscn`: intro animada donde el gato se duerme  
- `micro_inicio.tscn`: pantalla de transición con contador y vidas  
- `minijuegos/`: carpeta donde cada microjuego es una escena independiente  
- `plantilla/`: escena base con barra de tiempo e instrucciones para guiar nuevos microjuegos  
- `sistema_vidas.gd`: script de control de vidas  
- `audio/`: sonidos y música por microjuego  
- `sprites/`: recursos visuales como gatos, pescados, fondos y manos  

### 🎮 Microjuegos disponibles (6 en total):

- `microjuego1.tscn`: reacción con tecla aleatoria  
- `micro_gato_equilibrio.tscn`: mantener el equilibrio con flechas  
- `micro_abrelatas.tscn`: presionar rápido para abrir la lata (falta sprites finales)  
- *Otros 3 microjuegos más funcionales ya agregados al sistema*

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

## 🚧 Estado del proyecto (actualizado a v4.0)

✅ Menú principal  
✅ Transición entre microjuegos con contador visible  
✅ 6 microjuegos funcionales y conectados al sistema de vidas  
✅ Sistema de vidas corregido y funcionando (pierdes si fallas 3 veces)  
✅ Fin de partida por derrota o al completar los 30 microjuegos  
✅ Selección aleatoria de microjuegos  
✅ Botón de salida y tecla ESC funcional en cualquier momento  
✅ Carpeta `plantilla/` con estructura base para nuevos microjuegos  
✅ Reorganización completa de carpetas y archivos del proyecto  

🔜 Cinemática del gato  
🔜 Música de fondo y efectos  
🔜 Jefe final  
🔜 Botones para modo infinito  
🔜 Menú de opciones  
🔜 24 microjuegos más para completar los 30  
🔜 Señales para juego cruzado  

---

## 💬 Contribuciones

Este proyecto es académico. Si quieres dar ideas creativas o mejorar el juego, puedes enviar tus ideas o colaborar con nuevos microjuegos siguiendo la estructura base.

---


## 📸 Capturas

![image](https://github.com/user-attachments/assets/6a6be39f-9221-4592-8022-45d48e37cfe8)
![image](https://github.com/user-attachments/assets/2c5ffa12-a32e-4ee4-99c2-41926c0e2734)
![image](https://github.com/user-attachments/assets/2dc3a5a0-24bf-42d7-9515-d218766fef86)
![image](https://github.com/user-attachments/assets/5a8d963a-bda2-4f3a-a1e9-1b8c25651b35)
![image](https://github.com/user-attachments/assets/5f9e7627-5b3e-4694-ad6f-f6559964f4e1)
![image](https://github.com/user-attachments/assets/93eef93d-0432-4d4a-8444-4edc769368ca)
![image](https://github.com/user-attachments/assets/d7f875fb-e51a-4378-b6dc-41edd2caf36f)

---

¡Gracias por apoyar este proyecto y al gato soñador! 🐾✨
