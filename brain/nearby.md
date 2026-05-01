---
tags: [feature, nearby, core]
---

# Nearby

Descoberta de usuários e academias próximas com privacidade opt-in. Usa Mapbox para renderização do mapa.

## Mapa
- Pins de usuários e academias
- Tap no pin → bottom sheet com mini-perfil
- Botão "Treinar junto" no mini-perfil → envia friend request

## Lista alternativa
- Abaixo do mapa para acessibilidade
- Mesmos filtros do mapa

## Filtros
- Raio: 500m / 1km / 5km
- Esporte
- Nível (Iniciante / Intermediário / Avançado)

## Privacidade (opt-in no [[auth]] — Onboarding step 4)

| Modo | Comportamento |
|---|---|
| Exato | Coordenada real |
| Bairro | Coordenada aproximada (não expõe endereço exato) |
| Desativado | Não aparece no mapa |

## Academias
- Nome, horário, foto
- Link para maps externo

## Backend
```
GET /nearby/users?lat=&lng=&radius=
GET /nearby/gyms?lat=&lng=&radius=
```

## Código
- `lib/features/nearby/`
- `lib/core/config/mapbox_config.dart`

## Dependências
- `mapbox_maps_flutter`
- `geolocator`

## Relacionado
- [[SportConnect]]
- [[auth]] (permissão de localização)
- [[events]] (eventos próximos — futuro)
- [[profile]]
- [[backend-api]]
