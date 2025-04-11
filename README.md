# Gatcha! / Māo Fēng 猫疯 🐱🎮

Este proyecto es un videojuego tipo WarioWare, desarrollado en Godot 4.4, donde el jugador deberá completar una serie de microjuegos aleatorios, rápidos y entretenidos dentro del sueño de un gato. Cada microjuego desafía reflejos, ingenio y coordinación bajo presión.

---

## 🎯 Objetivo del juego

El jugador debe completar **30 microjuegos aleatorios** antes de quedarse sin vidas. Cada microjuego presenta un desafío distinto en solo unos segundos. Si completas todos, enfrentarás un jefe final para despertar al gato. Si pierdes todas tus vidas... ¡el gato seguirá soñando!

---

## 🧩 Estructura del juego

- `menu_principal.tscn`: pantalla inicial con botones para jugar el modo historia, opciones, etc.
- `cinematica.tscn`: pequeña intro donde el gato se queda dormido
- `transicion_microjuego.tscn`: escena de transición con animaciones y contador de vidas
- `minijuegos/`: carpeta que contiene cada microjuego como una escena independiente (`Node2D`)
- `micro_inicio.tscn`: primer microjuego ya implementado (reacción con teclas)
- `audio/`: sonidos y música rápida para cada microjuego
- `sprites/`: recursos gráficos como gatos, pescados, botones y fondos

---

## 🕹️ Cómo jugar

1. Inicia el juego desde `menu_principal.tscn`
2. Elige "Historia"
3. Observa la cinemática donde el gato se duerme
4. Supera los microjuegos que aparecen uno tras otro
5. Si completas 30 microjuegos con tus vidas, ¡enfrentas al jefe final!

---

## 🔧 Tecnologías utilizadas

- [Godot Engine 4.4](https://godotengine.org/)
- GDScript
- Audacity / gTTS para efectos de voz
- Piskel / Illustrator para gráficos
- OBS Studio para grabaciones de gameplay (opcional)

---

## 👨‍💻 Equipo de desarrollo

- Branco Abalos
- Ramiro Alvarado
- Benjamin Cuello
- Andres Toro
- Matias Vidal
- Emily Volta

---

## 🚧 Estado del proyecto

✅ Menú y navegación  
✅ Primer microjuego (gato y pescado)  
✅ Sistema de vidas  
✅ Música y efectos  
🔜 Más microjuegos en desarrollo  
🔜 Jefe final y modo infinito

---

## 💬 Contribuciones

Este proyecto es académico, pero se aceptan ideas creativas o sugerencias para mejorar la experiencia de juego. Puedes abrir un issue o mandar un pull request.

---

## 📸 Capturas


---

¡Gracias por jugar y apoyar al gato soñador! 🐾✨
