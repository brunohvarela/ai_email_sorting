#!/usr/bin/env bash
# render-build.sh
# Script de build para apps Phoenix no Render.com

# Interrompe o script se ocorrer algum erro
set -o errexit

echo "🔧 Instalando dependências Elixir..."
mix deps.get --only prod

echo "📦 Compilando dependências..."
mix deps.compile

echo "💅 Compilando assets..."
npm install --prefix ./assets
npm run deploy --prefix ./assets

echo "🧩 Gerando digest dos arquivos estáticos..."
mix phx.digest

echo "🏗️ Compilando código Elixir..."
mix compile

echo "🚀 Criando release..."
mix release