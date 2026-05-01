---
tags: [arch, design]
---

# Design System

Referência visual: Telegram + nuances de apps fitness (Strava, Whoop). Material 3.

## Tokens

| Token | Valor |
|---|---|
| Primary | `#5C6BC0` (índigo) |
| Secondary | `#FF7043` (laranja) |
| Background dark | `#1A1A2E` |
| Background light | `#F5F5F5` |
| Success (PR badge) | `#00C853` |

## Arquivos

| Arquivo | Conteúdo |
|---|---|
| `AppColors` | Paleta completa light + dark |
| `AppTypography` | Inter (display) + Roboto (body) |
| `AppSpacing` | 4 / 8 / 12 / 16 / 24 / 32 / 48 |
| `AppRadius` | button, card, bottom sheet, textfield |
| `AppTheme` | ThemeData light + dark (Material 3) |

Todos em `lib/core/theme/`.

## Dark mode
Suportado desde o dia 1. Detecção automática pelo sistema. Text scale clamped a 1.3x.

## Shared widgets
Ver [[architecture]] — `lib/shared/widgets/`.

## Relacionado
- [[architecture]]
- [[SportConnect]]
