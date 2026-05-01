---
tags: [feature, profile, core]
---

# Profile

Perfil público do usuário com stats, conquistas e histórico.

## Perfil próprio
- Header: foto, nome, username, bio, esportes (badges)
- Stats bar: posts / seguidores / seguindo
- Tabs: Posts | PRs | Conquistas
- Editar perfil (inline)
- Trocar foto: galeria + câmera + crop circular
- Grid de badges com nome e como desbloquear

## Perfil de outro usuário
- Botão Seguir / Seguindo / Solicitar (perfil privado)
- Botão "Mensagem" → abre DM no [[chat]]
- Botão "Treinar junto" (se próximo — integra com [[nearby]])
- Posts e PRs públicos visíveis
- Bloquear usuário

## Badges / Conquistas
- Geradas automaticamente ao bater [[prs]]
- Exibidas em grid no perfil
- Cada badge tem nome, ícone e cor

## QR Code
- Compartilhamento de perfil via QR

## Código
- `lib/features/profile/`
- `lib/shared/widgets/app_badge.dart`

## Relacionado
- [[auth]]
- [[prs]]
- [[goals]]
- [[chat]]
- [[nearby]]
- [[notifications]]
