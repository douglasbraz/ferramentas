#!/bin/bash  

# Verifica se as variáveis de ambiente estão definidas  
if [ -z "$GIT_USERNAME" ] || [ -z "$GIT_TOKEN" ]; then  
    echo "Por favor, defina as variáveis de ambiente GIT_USERNAME e GIT_TOKEN."  
    exit 1  
fi  

# Obtém a URL atual do repositório remoto  
REPO_URL=$(git config --get remote.origin.url)  

# Verifica se o comando foi bem-sucedido  
if [ $? -ne 0 ]; then  
    echo "Não foi possível obter a URL do repositório. Verifique se está em um repositório Git."  
    exit 1  
fi  

# Verifica se a URL é HTTPS  
if [[ "$REPO_URL" == https://* ]]; then  
    # Remove tudo que existir antes do '@'  
    CLEAN_REPO_URL=${REPO_URL#*@}  
else  
    # Para SSH, mantenha o REPO_URL como está  
    CLEAN_REPO_URL=$REPO_URL  
fi  

# Extrai a parte da URL base (domínio)  
REPO_BASE_URL=$(echo "$CLEAN_REPO_URL" | sed -E 's|/.*||')  

# Extrai o caminho do repositório  
REPO_PATH=$(echo "$CLEAN_REPO_URL" | sed -E "s|$REPO_BASE_URL||")  

# Remove a primeira barra (/) do caminho, se existir  
REPO_PATH=${REPO_PATH#/}  

# Cria a nova URL formatada com username e token  
NEW_URL="https://${GIT_USERNAME}:${GIT_TOKEN}@${REPO_BASE_URL}/${REPO_PATH}"  

# Configura a URL remota para o repositório  
git remote set-url origin "$NEW_URL"  

# Verifica se a alteração foi bem-sucedida  
if [ $? -eq 0 ]; then  
    echo "A URL remota foi atualizada com sucesso para: ${NEW_URL}"  
else  
    echo "Houve um erro ao atualizar a URL remota."  
    exit 1  
fi  
