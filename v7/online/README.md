# Sistema Online - Gatcha Cat Microgames

## Descripción

Este directorio contiene toda la funcionalidad online del juego Gatcha Cat Microgames, organizada de forma modular para permitir partidas multijugador en tiempo real.

## Estructura del Sistema

### 📁 core/
Contiene la funcionalidad principal del sistema multijugador:

- **`NetworkManager.gd`**: Gestiona la conexión WebSocket con el servidor, maneja eventos de red y coordina la comunicación entre jugadores.
- **`OnlineController.gd`**: Controlador principal que conecta todos los sistemas online y gestiona el flujo de la partida.
- **`MultiplayerGame.gd`**: Lógica central del juego multijugador, gestiona estados de partida y microjuegos.
- **`multiplayer_scene.gd`**: Controlador de escenas multijugador, maneja la selección y ejecución de microjuegos.
- **`Multiplayer_Scene.tscn`**: Escena principal del modo multijugador.

### 📁 ui/
Contiene los componentes de interfaz de usuario:

- **`ChatManager.gd`**: Sistema de chat con soporte para mensajes públicos y privados.
- **`chat-window.tscn`**: Ventana de chat con interfaz gráfica.
- **`ContadorOnline.gd`**: Contador de vidas especializado para partidas online.
- **`ContadorVidasOnline.tscn`**: Interfaz del contador de vidas online.
- **`escena_resultado.gd`**: Pantalla de resultados post-partida con opciones de revancha.
- **`escena_resultado.tscn`**: Interfaz de la pantalla de resultados.

## Funcionalidades Principales

### 🎮 Multijugador
- Partidas en tiempo real entre dos jugadores
- Sincronización de microjuegos y resultados
- Sistema de matchmaking básico
- Manejo de desconexiones y reconexiones

### 💬 Chat
- Chat público para lobby
- Mensajes privados entre jugadores
- Mensajes del sistema para notificaciones
- Interfaz redimensionable y ocultable

### 🏆 Sistema de Vidas
- Contador de vidas independiente para cada jugador
- Visualización en tiempo real del estado del oponente
- Temporizador para cada microjuego
- Progreso visual con barras de progreso

### 📊 Resultados
- Pantalla de resultados detallada
- Estadísticas de la partida
- Opción de revancha
- Historial de microjuegos jugados

## Señales del Sistema

### Señales de Microjuegos
Todos los microjuegos deben emitir estas señales para compatibilidad:

```gdscript
# Señales nuevas para online
signal microjuego_superado  # Cuando el jugador gana
signal microjuego_fallado   # Cuando el jugador pierde

# Señal original mantenida para retrocompatibilidad
signal finished(success: bool)
```

### Señales de Red
- `player_connected(data)`: Jugador conectado al servidor
- `match_request_received(player_name, player_id, match_id)`: Solicitud de partida
- `match_started(data)`: Partida iniciada
- `game_ended(data)`: Partida terminada
- `rematch_requested()`: Solicitud de revancha

## Configuración del Servidor

El sistema se conecta al servidor WebSocket ubicado en:
```
ws://ucn-game-server.martux.cl:4010/?gameId=E&playerName=gATO
```

### Eventos del Servidor
- `login`: Autenticación del jugador
- `match-request`: Solicitud de partida
- `match-accepted`: Partida aceptada
- `players-ready`: Jugadores listos
- `match-start`: Inicio de partida
- `send-game-data`: Envío de datos de juego
- `finish-game`: Fin de partida
- `rematch-request`: Solicitud de revancha

## Integración con el Juego Base

### Inicialización
El sistema se inicializa automáticamente cuando se cargan los componentes online. Los sistemas principales se registran como nodos singleton para acceso global.

### Compatibilidad
- ✅ Mantiene compatibilidad total con el modo offline
- ✅ Los microjuegos existentes funcionan sin modificaciones
- ✅ Sistema modular que no afecta el funcionamiento base

### Rutas de Archivos
Todas las rutas han sido actualizadas para referenciar la nueva estructura:
- `res://online/core/` para componentes principales
- `res://online/ui/` para interfaz de usuario

## Uso del Sistema

### 1. Iniciar Partida Online
```gdscript
# Cargar escena multijugador
var multiplayer_scene = load("res://online/core/Multiplayer_Scene.tscn")
get_tree().change_scene_to_packed(multiplayer_scene)
```

### 2. Conectar Microjuego
```gdscript
# En el script del microjuego
func _ready():
    # Conectar señales online
    connect("microjuego_superado", _on_microjuego_superado)
    connect("microjuego_fallado", _on_microjuego_fallado)
    
    # Mantener compatibilidad
    connect("finished", _on_finished)

func ganar_microjuego():
    emit_signal("microjuego_superado")
    emit_signal("finished", true)

func perder_microjuego():
    emit_signal("microjuego_fallado")
    emit_signal("finished", false)
```

### 3. Acceder al Chat
```gdscript
# Obtener referencia al chat
var chat_manager = get_node("/root/ChatManager")
if chat_manager:
    chat_manager.add_system_message("Mensaje del sistema")
```

## Notas Técnicas

### Rendimiento
- El sistema está optimizado para conexiones de latencia media
- Maneja automáticamente la pérdida de paquetes
- Implementa reconexión automática

### Seguridad
- Validación de datos del servidor
- Sanitización de mensajes de chat
- Protección contra spam

### Escalabilidad
- Arquitectura modular permite agregar nuevas funcionalidades
- Soporte para extensiones futuras
- Compatibilidad con diferentes tipos de microjuegos

## Resolución de Problemas

### Conexión Fallida
1. Verificar conectividad a internet
2. Comprobar URL del servidor
3. Revisar logs de NetworkManager

### Desincronización
1. Reiniciar partida
2. Verificar señales de microjuegos
3. Comprobar temporizadores

### Chat No Funciona
1. Verificar conexión de red
2. Comprobar permisos del chat
3. Revisar configuración de UI

## Contribuciones

Para agregar nuevas funcionalidades:

1. Seguir la estructura de carpetas existente
2. Documentar nuevas señales y eventos
3. Mantener compatibilidad con versiones anteriores
4. Probar en entorno multijugador

## Changelog

### v7.0
- Implementación inicial del sistema online
- Soporte para partidas multijugador
- Sistema de chat integrado
- Pantalla de resultados
- Contador de vidas online

---

*Documentación actualizada para la versión 7.0 del sistema online.*