; ==================================
; Nome do Script: FoE AIO - Jeizon Farias
; Versão: 9.0 (Aprimorada)
; Data da Versão: 11-08-2025
; ==================================

; Script AutoHotkey v1.1
; Automacao de batalhas FoE com GUI, pausas, log e configuracao externa

#NoEnv
#SingleInstance Force
SendMode Input
SetTitleMatchMode 2
#WinActivateForce
SetControlDelay 1
SetWinDelay 0
SetKeyDelay -1
SetMouseDelay -1
SetBatchLines -1
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

; ========== Incluir a biblioteca Gdip.ahk ==========
#Include %A_ScriptDir%\libs\Gdip.ahk

; ========== Variaveis Globais ==========
global pToken
global gPaused := false
global gStop := true
global gLogFile := A_ScriptDir "\logs\log_execucao.log"
global gConfig := A_ScriptDir "\config\cbg_config.ini"
global gImagensPath := A_ScriptDir "\imagens\cbg"
global StatusLabel
global MoverFixoX, MoverFixoY, Sleep_Tempo, Max_Offset, Tolerancia, LinhasDoLog
global imgAtk, imgDef, imgTropas, imgBat1, imgBat2, imgOk1, imgAlerta, imgFuga, imgRender, imgDimas
global PicAtk, PicOk1, PicBat1, PicBat2, PicDimas, PicDef, PicAlerta, PicFuga, PicRender
global gHotkeyPause, gHotkeyExit, gMaxLogLines, HotkeyPauseEdit, HotkeyExitEdit

; Variáveis para a função de recorte
global gCropImgPath, gCropControlName, gCropPicControl
global gCrop_x1, gCrop_y1, gCrop_x2, gCrop_y2
global gIsDragging := false
global gCropGuiHwnd, gCropBitmap, gCropGraphics, gCropBitmapOriginal, gPicControlId

; #################################################################################
; SEÇÃO DE EXECUÇÃO AUTOMÁTICA (INÍCIO DO SCRIPT)
; #################################################################################

if !pToken := Gdip_Startup()
{
    MsgBox, 16, GDI+ Error!, GDI+ failed to start. Please install GDI+ or check your Gdip.ahk library.
    ExitApp
}
OnExit, Gdip_Shutdown_Handler

LerConfiguracoes()
SetHotkeys()

Menu, Tray, Add, Iniciar / Pausar / Retomar, HotkeyPauseLabel
Menu, Tray, Add, Configurações, AbrirConfiguracoes
Menu, Tray, Add, Sair, SairScript
Menu, Tray, Default, Iniciar / Pausar / Retomar

MostrarGuiPrincipal()
Return ; FIM DA SEÇÃO DE EXECUÇÃO AUTOMÁTICA

; #################################################################################
; GUIs E LÓGICA DE NAVEGAÇÃO
; #################################################################################

MostrarGuiPrincipal() {
    Gui, 1:Destroy
    Gui, 1:New, +Resize , FoE AIO - Jeizon Farias
    Gui, 1:Margin, 20, 20
    Gui, 1:Add, Text,, Selecione o módulo que deseja utilizar:
    Gui, 1:Add, Button, x20 w180 h30 gAbrirCbgGui, CBG (Campo de Batalha)
    Gui, 1:Add, Button, x20 w180 h30, Expedição (Em breve)
    Gui, 1:Add, Button, x20 w180 h30, JxJ (PvP) (Em breve)
    Gui, 1:Add, Button, x20 w180 h30, IQ (Incursão Quântica) (Em breve)
    Gui, 1:Add, Button, x20 w180 h30 gSairScript, Sair
    Gui, 1:Show, w220
}

; =================================================================================
; GUI INTERMEDIÁRIA DO CBG (MENU CBG) - GUI 3
; =================================================================================
MostrarGuiCbgMenu() {
    Gui, 3:Destroy
    Gui, 3:New, +Resize , Menu CBG
    Gui, 3:Margin, 20, 20
    Gui, 3:Add, Button, w250 h30 gHotkeyPauseLabel, Iniciar ou Pausar (Hotkey: %gHotkeyPause%)
    Gui, 3:Add, Button, w250 h30 gAbrirConfiguracoesFromCbgMenu, Configurações do CBG
    Gui, 3:Add, Button, w250 h30 g3GuiClose, Voltar ao Menu Principal
    Gui, 3:Add, Button, x20 w250 h30 gSairScript, Sair
    Gui, 3:Show
}

AbrirConfiguracoesFromCbgMenu:
    Gui, 3:Destroy
    AbrirConfiguracoes()
Return

VoltarParaMenuPrincipal:
    Gui, 3:Destroy
    MostrarGuiPrincipal()
Return

3GuiClose:
    Gosub, VoltarParaMenuPrincipal
Return

AbrirCbgGui:
    Gui, 1:Hide
    MostrarGuiCbgMenu() 
Return

; ==================================
; LÓGICA DA GUI DE CONFIGURAÇÕES
; ==================================
AbrirConfiguracoes:
    Gui, 1:Hide
    AbrirConfiguracoes()
Return

AbrirConfiguracoes() {
    global MoverFixoX, MoverFixoY, Sleep_Tempo, Max_Offset, Tolerancia, gMaxLogLines, LinhasDoLog
    global imgAtk, imgDef, imgTropas, imgBat1, imgBat2, imgOk1, imgAlerta, imgFuga, imgRender, imgDimas
    global gHotkeyPause, gHotkeyExit, HotkeyPauseEdit, HotkeyExitEdit
    global PicAtk, PicDef, PicTropas, PicBat1, PicBat2, PicOk1, PicAlerta, PicFuga, PicRender, PicDimas

    Gui, 2:Destroy
    Gui, 2:New, +Resize , Configurações do Macro
    Gui, 2:Font, s10, Segoe UI
    
    Gui, 2:Add, Tab2, w930 h500, Gerais|Imagens
    
    ; ABA GERAIS
    Gui, 2:Tab, 1
    Gui, 2:Add, GroupBox, x10 y40 w250 h250, Gerais
    Gui, 2:Add, Text, x20 y70, Tempo de Espera (ms):
    Gui, 2:Add, Edit, x180 y65 w60 vSleep_Tempo, %Sleep_Tempo%
    Gui, 2:Add, Text, x20 y100, Offset Máximo:
    Gui, 2:Add, Edit, x180 y95 w60 vMax_Offset, %Max_Offset%
    Gui, 2:Add, Text, x20 y130, Linhas do Log:
    Gui, 2:Add, Edit, x180 y125 w60 vLinhasDoLog, %gMaxLogLines%

    Gui, 2:Add, GroupBox, x280 y40 w250 h250, Coordenadas
    Gui, 2:Add, Text, x290 y70, Mover Fixo X:
    Gui, 2:Add, Edit, x450 y65 w60 vMoverFixoX, %MoverFixoX%
    Gui, 2:Add, Text, x290 y100, Mover Fixo Y:
    Gui, 2:Add, Edit, x450 y95 w60 vMoverFixoY, %MoverFixoY%

    Gui, 2:Add, GroupBox, x550 y40 w250 h250, Hotkeys
    Gui, 2:Add, Text, x560 y70, Hotkey Pausar:
    Gui, 2:Add, Edit, x720 y65 w60 vHotkeyPauseEdit, %gHotkeyPause%
    Gui, 2:Add, Text, x560 y100, Hotkey Encerrar:
    Gui, 2:Add, Edit, x720 y95 w60 vHotkeyExitEdit, %gHotkeyExit%

    ; ABA IMAGENS
    Gui, 2:Tab, 2
    Gui, 2:Add, Text, x10 y50, Tolerância da imagem:
    Gui, 2:Add, Edit, x150 y45 w60 vTolerancia, %Tolerancia%

    ; --- Imagens Coluna 1
    x:=10, y:=80
    AddImageControl(x, y, "Ataque:", "imgAtk", "PicAtk")
    y += 120
    AddImageControl(x, y, "Defesa:", "imgDef", "PicDef")
    y += 120
    AddImageControl(x, y, "Tropas:", "imgTropas", "PicTropas")

    ; --- Imagens Coluna 2
    x:=240, y:=80
    AddImageControl(x, y, "Batalha 1:", "imgBat1", "PicBat1")
    y += 120
    AddImageControl(x, y, "Batalha 2:", "imgBat2", "PicBat2")
    y += 120
    AddImageControl(x, y, "OK:", "imgOk1", "PicOk1")

    ; --- Imagens Coluna 3
    x:=470, y:=80
    AddImageControl(x, y, "Alerta:", "imgAlerta", "PicAlerta")
    y += 120
    AddImageControl(x, y, "Fuga:", "imgFuga", "PicFuga")

    ; --- Imagens Coluna 4
    x:=700, y:=80
    AddImageControl(x, y, "Render:", "imgRender", "PicRender")
    y += 120
    AddImageControl(x, y, "Diamantes:", "imgDimas", "PicDimas")

    ; Controles Comuns
    Gui, 2:Tab
    Gui, 2:Add, Button, x10 y450 w100 gLimparLog, Limpar Log
    Gui, 2:Add, Button, x590 y450 w100 gSalvarConfiguracoes, Salvar
    Gui, 2:Add, Button, x710 y450 w100 gVoltarInicio, Voltar
    Gui, 2:Add, Button, x820 y450 w100 gSairScript, Sair

    Gui, 2:Show, w950 h500, Configurações do Macro
}

AddImageControl(x, y, label, varName, picVarName) {
    global gImagensPath
    imgPath := %varName%
    
    editX := x + 70, editY := y - 5, buttonX := x + 175, picX := x + 70, picY := y + 25

    Gui, 2:Add, Text, x%x% y%y%, %label%
    Gui, 2:Add, Edit, x%editX% y%editY% w100 v%varName%, %imgPath%
    Gui, 2:Add, Button, x%buttonX% y%editY% w20 h20 gCapturarImagem, 🔍
    
    if ResizeImageProportional(imgPath, w, h, 80, 80)
        Gui, 2:Add, Picture, x%picX% y%picY% w%w% h%h% v%picVarName%, % gImagensPath . "\" . imgPath
    else
        Gui, 2:Add, Text, x%picX% y%picY% v%picVarName%, (Não encontrada)
}

SalvarConfiguracoes() {
    global gConfig, gImagensPath, MoverFixoX, MoverFixoY, Sleep_Tempo, Max_Offset, gMaxLogLines, LinhasDoLog, Tolerancia
    global imgAtk, imgDef, imgTropas, imgBat1, imgBat2, imgOk1, imgAlerta, imgFuga, imgRender, imgDimas
    global gHotkeyPause, gHotkeyExit, HotkeyPauseEdit, HotkeyExitEdit
    Gui, 2:Submit, NoHide
    
    IniWrite, %MoverFixoX%, %gConfig%, GERAL, MoverFixoX
    IniWrite, %MoverFixoY%, %gConfig%, GERAL, MoverFixoY
    IniWrite, %Sleep_Tempo%, %gConfig%, GERAL, Sleep_Tempo
    IniWrite, %Max_Offset%, %gConfig%, GERAL, Max_Offset
    IniWrite, %LinhasDoLog%, %gConfig%, GERAL, LinhasDoLog
    IniWrite, %Tolerancia%, %gConfig%, IMAGENS, Tolerancia
    
    IniWrite, %imgAtk%, %gConfig%, IMAGENS, atk
    IniWrite, %imgDef%, %gConfig%, IMAGENS, def
    IniWrite, %imgTropas%, %gConfig%, IMAGENS, tropas
    IniWrite, %imgBat1%, %gConfig%, IMAGENS, bat1
    IniWrite, %imgBat2%, %gConfig%, IMAGENS, bat2
    IniWrite, %imgOk1%, %gConfig%, IMAGENS, ok1
    IniWrite, %imgAlerta%, %gConfig%, IMAGENS, alerta
    IniWrite, %imgFuga%, %gConfig%, IMAGENS, fuga
    IniWrite, %imgRender%, %gConfig%, IMAGENS, render
    IniWrite, %imgDimas%, %gConfig%, IMAGENS, dimas
    
    DesativarHotkeys()
    IniWrite, %HotkeyPauseEdit%, %gConfig%, HOTKEYS, Pause
    IniWrite, %HotkeyExitEdit%, %gConfig%, HOTKEYS, Exit
    gHotkeyPause := HotkeyPauseEdit
    gHotkeyExit := HotkeyExitEdit
    SetHotkeys()

    LerConfiguracoes()
    
    MsgBox, 64, Sucesso, Configurações salvas e aplicadas!
    VoltarInicio()
}

VoltarInicio() {
2GuiClose:
    Gui, 2:Destroy
    MostrarGuiCbgMenu()
    Return ;
}

LimparLog() {
    global gLogFile
    if FileExist(gLogFile) {
        FileDelete, %gLogFile%
        MsgBox, , Limpeza do log, O arquivo de log foi limpo.
    } else {
        MsgBox, , Limpeza do log, O arquivo de log não existe.
    }
}

; #################################################################################
; LÓGICA DE CONTROLE E AUTOMAÇÃO
; #################################################################################

; ==================================
; FUNÇÕES DE APOIO
; ==================================
LerConfiguracoes() {
    global gConfig, MoverFixoX, MoverFixoY, Sleep_Tempo, Max_Offset, Tolerancia
    global imgAtk, imgDef, imgTropas, imgBat1, imgBat2, imgOk1, imgAlerta, imgFuga, imgRender, imgDimas
    global gHotkeyPause, gHotkeyExit, gMaxLogLines
    IniRead, MoverFixoX, %gConfig%, GERAL, MoverFixoX, 769
    IniRead, MoverFixoY, %gConfig%, GERAL, MoverFixoY, 155
    IniRead, Sleep_Tempo, %gConfig%, GERAL, Sleep_Tempo, 30
    IniRead, Max_Offset, %gConfig%, GERAL, Max_Offset, 42
    IniRead, gMaxLogLines, %gConfig%, GERAL, LinhasDoLog, 20
    
    IniRead, imgAtk, %gConfig%, IMAGENS, atk, Atk.png
    IniRead, imgDef, %gConfig%, IMAGENS, def, Def.png
    IniRead, imgTropas, %gConfig%, IMAGENS, tropas, Tropas.png
    IniRead, imgBat1, %gConfig%, IMAGENS, bat1, Bat1.png
    IniRead, imgBat2, %gConfig%, IMAGENS, bat2, Bat2.png
    IniRead, imgOk1, %gConfig%, IMAGENS, ok1, Ok1.png
    IniRead, imgAlerta, %gConfig%, IMAGENS, alerta, Alerta.png
    IniRead, imgFuga, %gConfig%, IMAGENS, fuga, Fuga.png
    IniRead, imgRender, %gConfig%, IMAGENS, render, Render.png
    IniRead, imgDimas, %gConfig%, IMAGENS, dimas, Dimas.png
    IniRead, Tolerancia, %gConfig%, IMAGENS, Tolerancia, 20

    IniRead, gHotkeyPause, %gConfig%, HOTKEYS, Pause, F8
    IniRead, gHotkeyExit, %gConfig%, HOTKEYS, Exit, F9
}

SetHotkeys() {
    global gHotkeyPause, gHotkeyExit
    if (gHotkeyPause)
        Hotkey, %gHotkeyPause%, HotkeyPauseLabel, On
    if (gHotkeyExit)
        Hotkey, %gHotkeyExit%, SairScriptFunc, On ; Aponta para a função
}

DesativarHotkeys() {
    global gHotkeyPause, gHotkeyExit
    if (gHotkeyPause)
        Hotkey, %gHotkeyPause%, HotkeyPauseLabel, Off
    if (gHotkeyExit)
        Hotkey, %gHotkeyExit%, SairScriptFunc, Off
}

Log(msg) {
    global gLogFile
    FormatTime, t,, yyyy-MM-dd HH:mm:ss
    FileAppend, [%t%] %msg%`n, %gLogFile%
    ToolTip, %msg%
    SetTimer, RemoveToolTip, -2000
}

RemoveToolTip() {
    ToolTip
}

; Função original para encontrar e clicar na imagem
FindAndClick(imgPath, ByRef outX, ByRef outY, clickType="center") {
    global Tolerancia, Max_Offset, gImagensPath
    
    ImageSearch, outX, outY, 0, 0, A_ScreenWidth, A_ScreenHeight, *%Tolerancia% %gImagensPath%\%imgPath%
    
    if (ErrorLevel = 0) {
        Log("[ENCONTRADA] Imagem '" . imgPath . "' em X: " . outX . ", Y: " . outY)
        
        ; Obter as dimensões da imagem encontrada
        pBitmap := Gdip_CreateBitmapFromFile(gImagensPath . "\" . imgPath)
        if (!pBitmap)
            return false
        Gdip_GetImageDimensions(pBitmap, w, h)
        Gdip_DisposeImage(pBitmap)
        
        if (clickType = "center") {
            outX += w // 2
            outY += h // 2
            Click, %outX%, %outY%
            Log("[CLICK CENTER] Clicado em X: " . outX . ", Y: " . outY)
        } else if (clickType = "random") {
            max_offset_x := w < Max_Offset ? w : Max_Offset
            max_offset_y := h < Max_Offset ? h : Max_Offset
            Random, randX_offset, 0, max_offset_x
            Random, randY_offset, 0, max_offset_y
            randX := outX + randX_offset
            randY := outY + randY_offset
            Click, %randX%, %randY%
            Log("[CLICK RANDOM] " . imgPath . " detectado e clicado aleatoriamente em X: " . randX . ", Y: " . randY)
        }
        return true
    }
    return false
}

ResizeImageProportional(imgPath, ByRef w, ByRef h, maxWidth=100, maxHeight=100) {
    global gImagensPath
    fullImgPath := gImagensPath . "\" . imgPath
    if !FileExist(fullImgPath)
        return false
    pBitmap := Gdip_CreateBitmapFromFile(fullImgPath)
    if (!pBitmap)
        return false
    Gdip_GetImageDimensions(pBitmap, originalW, originalH)
    if (originalW > originalH) {
        w := maxWidth
        h := (originalH * maxWidth) // originalW
    } else {
        h := maxHeight
        w := (originalW * maxHeight) // originalH
    }
    Gdip_DisposeImage(pBitmap)
    return true
}

; ==================================
; AÇÕES DA AUTOMAÇÃO (Lógica da versão secundária)
; ==================================
CheckForAttacks() {
    global imgAtk, imgDef, Sleep_Tempo
    if FindAndClick(imgAtk, AtkX, AtkY, "random") {
        Sleep, %Sleep_Tempo%
    }
    if FindAndClick(imgDef, DefX, DefY, "random") {
        Sleep, %Sleep_Tempo%
    }
}

HandleCombatActions() {
    global imgBat1, imgBat2, Sleep_Tempo, Tolerancia, gImagensPath
    
    Send, {r}
    Log("[SEND] Tecla R enviada.")

    ; Busca a imagem Bat1 sem clicar, e envia 'b' se encontrada.
    ImageSearch, Bat1X, Bat1Y, 0, 0, A_ScreenWidth, A_ScreenHeight, *%Tolerancia% %gImagensPath%\%imgBat1%
    if (ErrorLevel = 0) {
        Log("[ENCONTRADA] Imagem '" . imgBat1 . "'. Enviando tecla B.")
        Send, {b}
        Sleep, %Sleep_Tempo%
    }
    
    ; Busca a imagem Bat2 sem clicar, e envia 'b' se encontrada.
    ImageSearch, Bat2X, Bat2Y, 0, 0, A_ScreenWidth, A_ScreenHeight, *%Tolerancia% %gImagensPath%\%imgBat2%
    if (ErrorLevel = 0) {
        Log("[ENCONTRADA] Imagem '" . imgBat2 . "'. Enviando tecla B.")
        Send, {b}
        Sleep, %Sleep_Tempo%
    }
}

HandlePopups() {
    global imgOk1, imgDimas, gImagensPath
    
    ; Busca a imagem Ok1.png. Se encontrar, envia o Escape.
    ImageSearch, Ok1X, Ok1Y, 0, 0, A_ScreenWidth, A_ScreenHeight, *20 %gImagensPath%\%imgOk1%
    if (ErrorLevel = 0)
    {
        Send, {Escape}
        Log("[SEND] Escape enviado para Ok1.")
    }

    ; Busca a imagem Dimas.png. Se encontrar, envia o Escape.
    ImageSearch, DimasX, DimasY, 0, 0, A_ScreenWidth, A_ScreenHeight, *20 %gImagensPath%\%imgDimas%
    if (ErrorLevel = 0)
    {
        Send, {Escape}
        Log("[SEND] Escape enviado para Dimas.")
    }
}

HandleFleeOption() {
    global imgAlerta, imgFuga, imgRender
    
    ; Busca a imagem Alerta.png sem clicar nela
    if FindAndClick(imgAlerta, AlertaX, AlertaY, "noclick") {
        Log("[ENCONTRADA] Alerta.png. Buscando Fuga.png...")
        if FindAndClick(imgFuga, FugaX, FugaY, "center") {
            Log("[CLICK] Fuga.png detectado e clicado. Aguardando 100ms...")
            Sleep, 100
            Loop {
                if FindAndClick(imgRender, RenderX, RenderY, "center") {
                    Log("[CLICK] Render.png detectado e clicado.")
                    break
                }
                Sleep, 100
            }
        }
    }
}

; ==================================
; LOOP PRINCIPAL DA AUTOMAÇÃO (Lógica da versão secundária)
; ==================================
LoopPrincipal:
Loop {
    while (gPaused) {
        Sleep, 100
        if (gStop)
            break
    }
    
    if (gStop) {
        break
    }

    MouseMove, %MoverFixoX%, %MoverFixoY%
    
    CheckForAttacks()
    HandleCombatActions()
    HandlePopups()
    HandleFleeOption()
    
    Sleep, %Sleep_Tempo%
}
gStop := true
gPaused := false
Gui, 1:Show
Log("[INFO] Macro encerrado.")
Return

; ==================================
; G-LABELS E HOTKEYS
; ==================================
IniciarMacro:
    if (gStop) {
        gStop := false
        gPaused := false
        Gui, 1:Hide
        Log("[INFO] Macro iniciado via botão 'Iniciar'.")
        Gosub, LoopPrincipal
    }
Return

HotkeyPauseLabel:
    if (gStop) {
        gStop := false
        gPaused := false
        Gui, 3:Destroy
        Gui, 1:Hide
        Log("[INFO] Macro iniciado via Hotkey/Botão.")
        ToolTip, Macro Iniciada!
        SetTimer, RemoveToolTip, -1500
        Gosub, LoopPrincipal
        Return
    }

    gPaused := !gPaused
    if (gPaused) {
        Log("[INFO] Script PAUSADO via Hotkey.")
        ToolTip, Macro Pausada
        MostrarGuiCbgMenu() ; Adicione esta linha para mostrar o menu do CBG
    } else {
        Log("[INFO] Script RETOMADO via Hotkey.")
        ToolTip, Macro em Execução
        Gui, 3:Hide ; Esta linha é opcional, mas esconde o menu ao retomar a execução
    }
    SetTimer, RemoveToolTip, -1500
Return

SairScriptFunc() {
    SairScript()
}

1GuiClose:
    SairScript()
Return

SairScript() {
    global pToken, gStop
    gStop := true
    Log("[INFO] Macro encerrada.")
    Gdip_Shutdown(pToken)
    ExitApp
}

SairScript:
Gdip_Shutdown_Handler:
    SairScript()
Return

; =========================================================================
; FUNÇÕES DE RECORTE (VERSÃO 4.0 - OTIMIZADA)
; =========================================================================

; A função agora passa o manipulador do bitmap diretamente para a GUI de recorte.
CapturarImagem(controlName, picControl) {
    global pToken, gCropControlName, gCropPicControl, gCropImgPath
    Gui, 2:Hide
    
    ToolTip, Clique e arraste para selecionar a área da imagem. Pressione ESC para cancelar.
    
    ; Usa um loop para detectar o arraste de forma confiável
    KeyWait, LButton, D
    MouseGetPos, x1, y1
    
    Loop {
        GetKeyState, LButtonState, LButton, P
        if (LButtonState = "U")
            break
        Sleep, 10
    }
    
    MouseGetPos, x2, y2
    
    ToolTip
    
    if (x2 < x1)
        temp := x1, x1 := x2, x2 := temp
    if (y2 < y1)
        temp := y1, y1 := y2, y2 := temp
        
    w := x2 - x1
    h := y2 - y1
    
    if (w < 1 or h < 1) {
        MsgBox, 48, Erro, A seleção é inválida. Por favor, tente novamente.
        Gui, 2:Show
        return
    }

    ; NOVA LÓGICA: Cria o bitmap da tela e o passa diretamente.
    pBitmap := Gdip_BitmapFromScreen(x1 . "|" . y1 . "|" . w . "|" . h)
    
    if (!pBitmap) {
        MsgBox, 48, Erro, A captura de tela falhou.
        Gui, 2:Show
        return
    }
    
    ; Salva os nomes dos controles para uso posterior
    gCropControlName := controlName
    gCropPicControl := picControl
    
    ; Reseta as coordenadas de recorte
    gCrop_x1 := gCrop_y1 := gCrop_x2 := gCrop_y2 := ""

    ; Agora passa o bitmap handle para a função da GUI de recorte
    AbrirGuiRecorte(pBitmap)
}

AbrirGuiRecorte(pBitmapOriginal) {
    global gCropImgPath, gCropGuiHwnd, gCropBitmapOriginal, gCropBitmap, gCropGraphics, gPicControlId, pToken
    
    ; Salva o bitmap original na variável global para uso no loop de desenho
    gCropBitmapOriginal := pBitmapOriginal
    
    Gui, 3:Destroy
    Gui, 3:New, +Resize , Recortar Imagem
    
    Gdip_GetImageDimensions(gCropBitmapOriginal, w, h)
    
    Log("DEBUG: Dimensões da imagem carregada para recorte: W=" . w . ", H=" . h)

    y_button := 30 + h + 10
    
    ; Salva a imagem original em um arquivo temporário apenas para a GUI exibir.
    ; O trabalho de recorte será feito com o bitmap na memória.
    gCropImgPath := A_ScriptDir "\_temp_capture.png"
    Gdip_SaveBitmapToFile(gCropBitmapOriginal, gCropImgPath, 100)
    
    Gui, 3:Add, Text, x10 y10, Clique e arraste para selecionar a área a ser recortada.
    Gui, 3:Add, Picture, x10 y30 w%w% h%h% gRecorteSel, %gCropImgPath%
    
    Gui, 3:Add, Button, x10 y%y_button% w150 h30 gEditarRecorte, Editar Recorte
    Gui, 3:Add, Button, x170 y%y_button% w150 h30 gSalvarRecorte, Salvar Recorte
    Gui, 3:Add, Button, x330 y%y_button% w150 h30 gCancelarRecorte, Cancelar
    
    Gui, 3:+LastFound
    gCropGuiHwnd := WinExist()
    
    ; Prepara GDI+ para desenhar o retângulo de seleção.
    gCropGraphics := Gdip_GraphicsFromHwnd(gCropGuiHwnd)
    gCropBitmap := Gdip_CreateBitmap(w, h)
    
    ControlGet, gPicControlId, Hwnd,, Static1, Recortar Imagem

    Gui, 3:Show, , Recortar Imagem
}

RecorteSel:
    global gCrop_x1, gCrop_y1, gCrop_x2, gCrop_y2, gPicControlId, gIsDragging
    
    ; Inicia o arraste quando o botão é pressionado
    if (A_GuiEvent = "Normal")
    {
        Log("DEBUG: Início do arraste. Capturando coordenadas de início.")
        MouseGetPos, gCrop_x1, gCrop_y1, , %gPicControlId%
        gIsDragging := true
        SetTimer, RecorteDrawingLoop, 10
    }
Return

RecorteDrawingLoop:
    global gCrop_x1, gCrop_y1, gCrop_x2, gCrop_y2, gPicControlId, gCropGraphics, gCropBitmap, gCropBitmapOriginal, gIsDragging
    
    if (!gIsDragging)
        return
        
    ; Verifica se o botão do mouse foi solto para finalizar o arraste
    if (!GetKeyState("LButton", "P"))
    {
        Log("DEBUG: Botão do mouse solto. Finalizando o arraste.")
        MouseGetPos, gCrop_x2, gCrop_y2, , %gPicControlId%
        gIsDragging := false
        SetTimer, RecorteDrawingLoop, Off
        
        x := (gCrop_x1 < gCrop_x2) ? gCrop_x1 : gCrop_x2
        y := (gCrop_y1 < gCrop_y2) ? gCrop_y1 : gCrop_y2
        w := Abs(gCrop_x1 - gCrop_x2)
        h := Abs(gCrop_y1 - gCrop_y2)
        ToolTip, Recorte: x%x%, y%y%, w%w%, h%h%
        SetTimer, RemoveToolTip, -2000
        
        ; Redesenha a imagem final com o retângulo para visualização
        Gdip_GraphicsFromImage(gCropBitmap, gCropGraphics)
        Gdip_DrawImage(gCropGraphics, gCropBitmapOriginal, 0, 0)
        Gdip_DrawImage(gCropGraphics, gCropBitmap, 0, 0)
        return
    }

    MouseGetPos, x_atual, y_atual, , %gPicControlId%
    
    ; Desenha a imagem original para limpar o que foi desenhado antes
    Gdip_GraphicsFromImage(gCropBitmap, gCropGraphics)
    Gdip_DrawImage(gCropGraphics, gCropBitmapOriginal, 0, 0, 9999, 9999)
    
    ; Desenha o retângulo de seleção em tempo real
    Gdip_SetSmoothingMode(gCropGraphics, 4)
    Gdip_SetCompositingMode(gCropGraphics, 1)
    
    pBrush := Gdip_BrushCreateSolid(0x32000000)
    
    x := (gCrop_x1 < x_atual) ? gCrop_x1 : x_atual
    y := (gCrop_y1 < y_atual) ? gCrop_y1 : y_atual
    w := Abs(gCrop_x1 - x_atual)
    h := Abs(gCrop_y1 - y_atual)
    
    Gdip_FillRectangle(gCropGraphics, pBrush, x, y, w, h)
    Gdip_DeleteBrush(pBrush)
    
    Gdip_DrawImage(gCropGraphics, gCropBitmap, 0, 0)
Return


EditarRecorte:
    global gCropImgPath
    MsgBox, 64, Editar Imagem, A imagem foi aberta no seu editor padrão. Por favor, faça as edições e salve a imagem (Ctrl+S) no mesmo local. Depois, volte para esta janela e clique em "Salvar Recorte".
    Run, %gCropImgPath%
Return

SalvarRecorte:
    global gCropImgPath, gCropControlName, gCropPicControl, pToken
    global gCrop_x1, gCrop_y1, gCrop_x2, gCrop_y2, gCropBitmapOriginal, gCropBitmap, gCropGraphics
    
    GuiControlGet, defaultFileName, 2:, %gCropControlName%
    
    defaultPath := A_ScriptDir "\imagens\" . defaultFileName
    
    FileSelectFile, fullPath, S16, %defaultPath%, Salvar Imagem Recortada, Imagens (*.png)
    
    if (ErrorLevel) {
        ; Se o usuário cancelar, limpa os recursos e fecha a GUI
        Gosub, CancelarRecorte
        return
    }

    pBitmapToSave := ""
    
    Log("DEBUG: Verificando se as coordenadas de recorte estão preenchidas. gCrop_x1='" . gCrop_x1 . "'")
    if (gCrop_x1 != "" and gCrop_y1 != "" and gCrop_x2 != "" and gCrop_y2 != "")
    {
        Log("DEBUG: Recorte interno detectado.")
        
        x := (gCrop_x1 < gCrop_x2) ? gCrop_x1 : gCrop_x2
        y := (gCrop_y1 < gCrop_y2) ? gCrop_y1 : gCrop_y2
        w := Abs(gCrop_x1 - gCrop_x2)
        h := Abs(gCrop_y1 - gCrop_y2)
        
        if (w < 1 or h < 1) {
            MsgBox, 48, Erro, A seleção de recorte é inválida. Por favor, tente novamente.
            return
        }
        
        Gdip_GetImageDimensions(gCropBitmapOriginal, bmpW, bmpH)
        
        x := (x < 0) ? 0 : x
        y := (y < 0) ? 0 : y
        if (x + w > bmpW)
            w := bmpW - x
        if (y + h > bmpH)
            h := bmpH - y

        Log("DEBUG: Clonando área do bitmap. Coordenadas corrigidas: x=" . x . ", y=" . y . ", w=" . w . ", h=" . h)
        
        ; AQUI ESTÁ A CORREÇÃO DE `Gdip_CloneBitmapArea`
        pBitmapToSave := Gdip_CloneBitmapArea(gCropBitmapOriginal, x, y, w, h)
        
        if (!pBitmapToSave) {
            MsgBox, 48, Erro, A clonagem da área do bitmap falhou.
            return
        }
    }
    else
    {
        Log("DEBUG: Sem recorte interno. Verificando o arquivo temporário para edição externa.")
        
        ; AQUI ESTÁ A CORREÇÃO DE SALVAMENTO DE IMAGEM EXTERNA (COM LOOP DE TENTATIVAS)
        Loop, 10
        {
            pBitmapToSave := Gdip_CreateBitmapFromFile(gCropImgPath)
            if (pBitmapToSave)
                break
            Sleep, 200
        }
        
        if (!pBitmapToSave) {
            MsgBox, 48, Erro, Não foi possível carregar a imagem do arquivo temporário. Certifique-se de que o editor externo está fechado.
            return
        }
    }
    
    if (pBitmapToSave) {
        Log("DEBUG: Tentando salvar a imagem no caminho: " . fullPath)
        Gdip_SaveBitmapToFile(pBitmapToSave, fullPath, 100)
        Gdip_DisposeImage(pBitmapToSave)
    } else {
        MsgBox, 48, Erro, Não foi possível salvar a imagem.
        return
    }

    FileDelete, %gCropImgPath%
    
    gCrop_x1 := gCrop_y1 := gCrop_x2 := gCrop_y2 := ""
    
    SplitPath, fullPath, imgFileName
    GuiControl, 2:, %gCropControlName%, %imgFileName%

    if !ResizeImageProportional(fullPath, newW, newH) {
        GuiControl, 2:, %gCropPicControl%, *w100 *h100
    } else {
        GuiControl, 2:, %gCropPicControl%, *w%newW% *h%newH% %fullPath%
    }
    
    Gdip_DeleteGraphics(gCropGraphics)
    Gdip_DisposeImage(gCropBitmapOriginal)
    Gdip_DisposeImage(gCropBitmap)
    
    Gui, 3:Destroy
    Gui, 2:Show
    MsgBox, 64, Sucesso, Imagem "%imgFileName%" salva com sucesso!
Return

CancelarRecorte:
    global gCropImgPath, gCropBitmapOriginal, gCropBitmap, gCropGraphics
    
    FileDelete, %gCropImgPath%
    
    ; Libera os recursos GDI+
    Gdip_DeleteGraphics(gCropGraphics)
    Gdip_DisposeImage(gCropBitmapOriginal)
    Gdip_DisposeImage(gCropBitmap)
    
    Gui, 3:Destroy
    Gui, 2:Show
Return

#if