#!/bin/bash
# Script para lanzar el emulador Pixel con DNS de Google
# Esto permite que el emulador resuelva devtunnels.ms

~/Library/Android/sdk/emulator/emulator -avd Pixel_9_Pro_XL -dns-server 8.8.8.8,8.8.4.4 &
echo "✅ Emulador Pixel_9_Pro_XL iniciado con DNS de Google"
