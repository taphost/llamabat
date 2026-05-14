# Configurazione di OpenCode

## Prerequisiti

**npm** deve essere installato su Windows 10/11. Se non lo avete:

```powershell
npm install -g npm@latest
```

## Installazione

Installare OpenCode globalmente:

```powershell
npm i -g opencode-ai@latest
```

## Configurazione

1. Aprire la cartella di configurazione:

```
C:\Users\NOMEUTENTE\.config\opencode
```

2. Creare o modificare il file `config.json` con il seguente schema:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "lmstudio-local": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "LM Studio Local / llama.cpp",
      "options": {
        "baseURL": "http://localhost:8000/"
      },
      "models": {
        "Qwen3.6-35B-A3B-UD-IQ3_XXS": {}
      }
    }
  },
  "model": "Qwen3.6-35B-A3B-UD-IQ3_XXS"
}
```

> Modificare `NOMEUTENTE` con il proprio nome utente Windows.

## Utilizzo

1. Aprire PowerShell e posizionarsi in una cartella di progetto:

```powershell
cd C:\Users\NOMEUTENTE\Documents\MIOPROGETTO
```

2. Lanciare OpenCode:

```powershell
opencode
```

Il modello configurato nel `config.json` viene caricato di default. Per cambiare modello: `/model` e scegliere dalla lista.

> **Nota:** OpenCode può essere lanciato da PowerShell standalone o dal terminale integrato di in un IDE come VSCode (`Ctrl+``).
