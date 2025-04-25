#!/bin/bash

# Caminho do SDK
SDK_PATH="$HOME/Library/Android/sdk"
EMULATOR="$SDK_PATH/emulator/emulator"

# Verifica se o executável do emulator existe
if [ ! -f "$EMULATOR" ]; then
  echo "❌ Emulator não encontrado no caminho esperado: $EMULATOR"
  exit 1
fi

# Captura apenas os AVDs válidos com sublinhado no nome
AVDS=($($EMULATOR -list-avds 2>/dev/null))
AVDS=($(printf "%s\n" "${AVDS[@]}" | grep -E '^[a-zA-Z0-9-]*_[a-zA-Z0-9_-]*$'))

if [ ${#AVDS[@]} -eq 0 ]; then
  echo "⚠️ Nenhum AVD encontrado. Crie um AVD pelo Android Studio primeiro."
  exit 1
fi

# Função para iniciar emulador, se ainda não estiver rodando
start_emulator() {
  local AVD_NAME="$1"
  if pgrep -f "emulator.*-avd $AVD_NAME" > /dev/null; then
    echo "🟡 O emulador '$AVD_NAME' já está em execução."
  else
    echo "🚀 Iniciando emulador: $AVD_NAME..."
    nohup "$EMULATOR" -avd "$AVD_NAME" > /dev/null 2>&1 &
    echo "✅ Emulador $AVD_NAME iniciado em background."
  fi
}

# Se só tiver um AVD, tenta iniciar direto
if [ ${#AVDS[@]} -eq 1 ]; then
  start_emulator "${AVDS[0]}"
  exit 0
fi

# Caso haja mais de um AVD, mostrar o menu
echo "📱 Emuladores disponíveis:"
select AVD in "${AVDS[@]}"; do
  if [[ -n "$AVD" ]]; then
    start_emulator "$AVD"
    break
  else
    echo "❌ Opção inválida. Tente novamente."
  fi
done

