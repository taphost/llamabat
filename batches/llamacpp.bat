@echo off
setlocal

:: ==============================================================================================================================
:: Percorsi
:: ==============================================================================================================================
set LLAMA_SERVER=C:\Users\NOMEUTENTE\.unsloth\llama.cpp\build\bin\Release\llama-server.exe
set MODEL=C:\Users\NOMEUTENTE\.cache\lm-studio\models\unsloth\Qwen3.6-35B-A3B-GGUF\Qwen3.6-35B-A3B-UD-IQ3_XXS.gguf
set TEMPLATE=C:\Users\NOMEUTENTE\Documents\template\chat_template-v15.jinja
set MMPROJ=C:\Users\NOMEUTENTE\.cache\lm-studio\models\unsloth\Qwen3.6-35B-A3B-GGUF\mmproj-F32.gguf

echo ====================================================================================
echo   llama-server - Qwen3.6 35B A3B
echo ====================================================================================
echo.
echo  Model : %MODEL%
echo  Port  : 8000
echo  CTX   : 131072
echo.
echo Premere un tasto per avviare... (CTRL+C per annullare)
pause >nul
echo.
echo Avvio llama-server...
echo.

"%LLAMA_SERVER%" ^
  -m "%MODEL%" ^
  --no-mmproj ^
  --no-mmproj-offload ^
  -ngl 9999 ^
  -ncmoe 0 ^
  --fit on ^
  -fitt 512 ^
  --no-mmap ^
  --mlock ^
  --prio 3 ^
  -np 1 ^
  -b 2048 ^
  -ub 512 ^
  -tb 2 ^
  -t 6 ^
  -c 131072 ^
  --cache-ram 512 ^
  -ctxcp 1 ^
  --kv-unified ^
  --cache-idle-slots ^
  --cache-reuse 64 ^
  --kv-offload ^
  -ctk q4_0 ^
  -ctv q4_0 ^
  -fa on ^
  --jinja ^
  --chat-template-file "%TEMPLATE%" ^
  --temp 0.6 ^
  --top-p 0.95 ^
  --top-k 20 ^
  --min-p 0.0 ^
  --presence-penalty 0.0 ^
  --repeat-penalty 1.0 ^
  --reasoning on ^
  --reasoning-budget -1 ^
  --chat-template-kwargs "{\"preserve_thinking\": true}" ^
  --spec-type ngram-mod ^
  --spec-ngram-mod-n-match 24 ^
  --spec-ngram-mod-n-min 48 ^
  --spec-ngram-mod-n-max 64 ^
  --metrics ^
  --log-colors auto ^
  --warmup ^
  --port 8000

echo.
echo ====================================================================================
echo  Server terminato con codice: %ERRORLEVEL%
echo ====================================================================================
pause