# SportConnect - Makefile
# Uso: make <comando>

.PHONY: dev dev-web dev-usb get gen clean lint test

## Roda o app em modo dev (Windows desktop, com mocks)
dev:
	flutter run -t lib/main_dev.dart -d windows

## Roda o app em modo dev no browser
dev-web:
	flutter run -t lib/main_dev.dart -d edge

## Roda no device/emulator Android — rode `flutter devices` pra ver o ID e passe: make dev-android DEVICE=emulator-5554
dev-android:
# 	flutter run -t lib/main_dev.dart -d $(DEVICE)
	flutter run -t lib/main_dev.dart -d emulator-5554

## Roda no celular físico via USB (Flutter detecta automaticamente; se houver mais de um device, ele pergunta)
dev-usb:
	flutter run -t lib/main_dev.dart

## Instala dependências
get:
	flutter pub get

## Gera código (freezed, riverpod, json_serializable)
gen:
	dart run build_runner build --delete-conflicting-outputs

## Gera código em modo watch
gen-watch:
	dart run build_runner watch --delete-conflicting-outputs

## Limpa build cache
clean:
	flutter clean && flutter pub get

## Roda o analisador
lint:
	flutter analyze

## Roda os testes
test:
	flutter test
