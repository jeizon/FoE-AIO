# FoE-AIO
**Automatização para o jogo Forge of Empires**

Este projeto é um script de automação para o jogo Forge of Empires (FoE), desenvolvido em AutoHotkey (AHK). O objetivo é automatizar várias tarefas repetitivas do jogo para facilitar a jogabilidade, com foco inicial nas Batalhas do Campo de Batalha da Guilda (CBG).

## Funcionalidades
A versão atual do script, nomeada "FoE AIO - Jeizon Farias", versão 9.0 (Aprimorada), oferece as seguintes funcionalidades principais:

* **Automação de Batalhas do CBG**: O módulo principal executa as batalhas do Campo de Batalha da Guilda de forma automatizada.
    * **Identificação de Ações**: Utiliza reconhecimento de imagem para identificar botões de ação como "Atacar", "Defender", "Batalha automática" e pop-ups como "Alerta!", "Retirar", "Render-se" e "diamantes".
    * **Estratégia de Combate**: Envia as teclas 'R' e 'B' para iniciar e controlar as batalhas automáticas quando as imagens correspondentes são encontradas.
    * **Gerenciamento de Pop-ups**: Fecha automaticamente pop-ups de alerta e de compra com diamantes, enviando a tecla 'Escape'.
    * **Opção de Fuga/Rendição**: Se um alerta de combate for detectado, o script busca e clica nos botões "Retirar" e "Render-se" para encerrar a batalha.
* **Interface Gráfica do Usuário (GUI)**: O script possui uma GUI que permite ao usuário:
    * Selecionar o módulo de automação desejado (atualmente apenas "CBG" está ativo).
    * Configurar parâmetros gerais e específicos das imagens através de uma janela de configurações.
    * Pausar, retomar ou sair do script usando botões ou hotkeys.
    * Visualizar as imagens configuradas e capturar novas imagens da tela para o reconhecimento.
* **Configuração Externa**: As configurações são lidas de um arquivo `cbg_config.ini`, incluindo coordenadas de cliques fixos, tempos de espera, tolerância de imagem e hotkeys.

## Como Usar
1.  **Requisitos**: Certifique-se de ter o AutoHotkey v1.1 e a biblioteca GDI+ instalados e configurados corretamente. O script requer que o GDI+ esteja funcionando para o processamento de imagens.
2.  **Configuração**: Edite o arquivo `config/cbg_config.ini` para ajustar as configurações de acordo com a sua resolução de tela e preferências, ou use a GUI de configurações para isso.
3.  **Execução**: Execute o arquivo `FoE_AIO_Enhanced.ahk`. A GUI principal será exibida.
4.  **Iniciar**: Selecione o módulo desejado e inicie a automação. As hotkeys padrão são `F8` para pausar/retomar e `F9` para sair do script.

## Estrutura do Projeto
* `FoE_AIO_Enhanced.ahk`: O arquivo principal do script.
* `libs/Gdip.ahk`: Biblioteca para manipulação de imagens e gráficos (GDI+), essencial para o reconhecimento visual.
* `config/cbg_config.ini`: Arquivo de configuração que armazena todas as preferências do usuário.
* `imagens/cbg/`: Pasta que contém as imagens de referência para o reconhecimento de botões e pop-ups.

## Aviso
Este é um script de automação e seu uso é por sua conta e risco. O comportamento do jogo pode mudar com atualizações, o que pode afetar a funcionalidade do script.

---
_Desenvolvido por Jeizon Farias_
