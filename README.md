# Pomodoro (iOS)

> App de Pomodoro para iOS/SwiftUI.

Timer Pomodoro nativo para iPhone con arquitectura limpia separada en capas de dominio, presentación y servicios.

## Stack

- Swift + SwiftUI
- Arquitectura MVVM con capas separadas (Domain, Presentation, Services)

## Estructura

```
pomodoro/
├── Domain/          # Lógica de negocio
├── Presentation/    # Vistas y ViewModels
├── Services/        # Servicios (timer, notificaciones)
├── Assets.xcassets/ # Recursos visuales
├── ContentView.swift
└── pomodoroApp.swift
```

## Requisitos

- Xcode 15+
- iOS 17+

## Abrir

```bash
open pomodoro.xcodeproj
```
