# Pomodoro - Domain-Driven Design

## Lenguaje Ubicuo

| Termino | Definicion |
|---------|-----------|
| **Pomodoro** | Periodo de trabajo enfocado (defecto 25 min) |
| **Descanso Corto** | Pausa entre pomodoros (defecto 5 min) |
| **Descanso Largo** | Pausa extendida tras N pomodoros (defecto 15 min) |
| **Ronda** | Numero de pomodoros completados en el ciclo actual |
| **Ciclo** | Secuencia: 4 pomodoros + 1 descanso largo |
| **Sesion** | Registro de un pomodoro o descanso completado |
| **Etiqueta** | Categoria para organizar sesiones (ej: "Trabajo", "Estudio") |
| **Fase** | Estado actual del timer: trabajo / descanso corto / descanso largo |

## Contextos Delimitados

### 1. Timer Context
Gestionar la cuenta regresiva y transiciones de fase.

**Agregado raiz:** `TimerState`
- `remainingSeconds: Int`
- `totalSeconds: Int`
- `phase: PomodoroPhase`
- `isRunning: Bool`
- `currentRound: Int`

**Comportamiento:** `start()`, `pause()`, `reset()`, `skip()`, `tick()`

### 2. Session Context
Registrar y consultar sesiones de pomodoro.

**Agregado raiz:** `PomodoroSession`
- `id: UUID`
- `startTime: Date`
- `endTime: Date?`
- `phase: PomodoroPhase`
- `duration: TimeInterval`
- `completed: Bool`
- `tagID: UUID?`

**Repositorio:** `SessionRepository` (SwiftData)

### 3. Settings Context
Gestionar preferencias del usuario.

**Agregado raiz:** `TimerConfig`
- `workDuration: Int` (minutos)
- `shortBreakDuration: Int`
- `longBreakDuration: Int`
- `roundsBeforeLongBreak: Int`
- `autoStartBreaks: Bool`
- `autoStartPomodoros: Bool`
- `soundEnabled: Bool`
- `notificationsEnabled: Bool`

### 4. Statistics Context
Calcular metricas y tendencias.

**Servicio:** `StatisticsService`
- `todayStats() -> DayStatistics`
- `weekStats() -> [DayStatistics]`
- `currentStreak() -> Int`

### 5. Notification Context
Gestionar notificaciones locales.

**Servicio:** `NotificationService`
- `requestPermission()`
- `scheduleCompletionNotification(phase:)`

### 6. Tag Context
Gestionar etiquetas/categorias.

**Agregado raiz:** `Tag`
- `id: UUID`
- `name: String`
- `colorHex: String`

## Arquitectura

```
┌─────────────────────────────────────────┐
│           Presentation (MVVM)           │
│  TimerView · HistoryView · StatsView    │
│  SettingsView · TagsView                │
├─────────────────────────────────────────┤
│         Application Layer               │
│  TimerService · NotificationService     │
├─────────────────────────────────────────┤
│             Domain                      │
│  PomodoroPhase · PomodoroSession · Tag  │
├─────────────────────────────────────────┤
│         Infrastructure                  │
│  SwiftData (sesiones, tags)             │
│  @AppStorage (configuracion)            │
│  UserNotifications (alertas)            │
└─────────────────────────────────────────┘
```

## Modelo de Datos (SwiftData)

```
PomodoroSession
├── id: UUID (unique)
├── startTime: Date
├── endTime: Date?
├── phase: String ("work" | "shortBreak" | "longBreak")
├── duration: TimeInterval
├── completed: Bool
└── tagID: UUID?

Tag
├── id: UUID (unique)
├── name: String
└── colorHex: String
```

## Flujo Principal

```
[Seleccionar etiqueta] → [Iniciar timer]
        ↓
  Fase: Trabajo (25 min)
        ↓
  Timer → 0 → Registra sesion + Notifica
        ↓
  Fase: Descanso Corto (5 min)
        ↓
  Timer → 0 → Transicion
        ↓
  Repite hasta ronda 4
        ↓
  Fase: Descanso Largo (15 min)
        ↓
  Reinicia ciclo
```

## Decisiones

| Decision | Razon |
|----------|-------|
| SwiftData vs Core Data | API moderna, mas simple, nativa SwiftUI |
| @AppStorage para settings | Preferencias simples, sin necesidad de queries |
| Timer basado en Date | Preciso aun con app en background |
| Sin relaciones SwiftData | `tagID: UUID?` para evitar bugs de relaciones opcionales |
| @Observable en TimerService | Tracking granular de propiedades para UI reactiva |
