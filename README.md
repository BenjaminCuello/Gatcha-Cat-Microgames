# Gatcha! / Māo Fēng 猫疯 🐱🎮

Este proyecto es un videojuego tipo WarioWare, desarrollado en Godot 4.4, donde el jugador debe completar una serie de microjuegos rápidos, aleatorios y divertidos, todo dentro del sueño de un gato. Cada microjuego pone a prueba tus reflejos, ingenio y coordinación bajo presión.

---

## 🎯 Objetivo del juego

El objetivo es completar **30 microjuegos aleatorios** sin perder todas tus vidas. Si lo logras, enfrentarás un **jefe final** que reúne elementos de los microjuegos anteriores. Si fallas todos tus intentos... el gato seguirá soñando.

---

## 🧩 Estructura del juego (versión 2.0)

- `menu_principal.tscn`: pantalla inicial con botones de navegación
- `cinematica.tscn`: intro animada donde el gato se duerme
- `micro_inicio.tscn`: pantalla de transición con contador y vidas
- `minijuegos/`: carpeta donde cada microjuego es una escena independiente
- `microjuego1.tscn`: microjuego implementado (tecla rápida)
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

## 🚧 Estado del proyecto (actualizado a v2.0)

✅ Menú principal  
✅ Cinemática del gato  
✅ Transición entre microjuegos  
✅ Microjuego 1 funcional (reflejos con teclas)  
✅ Sistema de vidas implementado  
🔜 Segundo microjuego  
🔜 Música de fondo y efectos  
🔜 Jefe final  
🔜 Señales para juego cruzado

---

## 💬 Contribuciones

Este proyecto es académico. Si quieres dar ideas creativas o mejorar el juego, ¡puedes abrir un issue o enviar un pull request!

---

## 📸 Capturas

*(Próximamente se agregarán imágenes de gameplay)*

---

¡Gracias por apoyar este proyecto y al gato soñador! 🐾✨
