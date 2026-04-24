@echo off
setlocal

set LLAMA_SERVER=C:\Users\TUONOMEUTENTE\.unsloth\llama.cpp\build\bin\Release\llama-server.exe
set MODEL=C:\Users\TUONOMEUTENTE\.cache\lm-studio\models\unsloth\Qwen3.6-35B-A3B-GGUF\Qwen3.6-35B-A3B-UD-IQ3_XXS.gguf

echo ==========================================
echo   llama-server - Qwen3.6 35B A3B
echo ==========================================
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
  --cont-batching ^
  -b 2048 ^
  -ub 512 ^
  -tb 2 ^
  -t 6 ^
  -c 131072 ^
  --cache-ram 2048 ^
  -ctxcp 2 ^
  --kv-unified ^
  --kv-offload ^
  -ctk q4_0 ^
  -ctv q4_0 ^
  -fa on ^
  --jinja ^
  --temp 0.6 ^
  --top-p 0.95 ^
  --top-k 20 ^
  --min-p 0.0 ^
  --presence-penalty 0.0 ^
  --repeat-penalty 1.0 ^
  --reasoning on ^
  --chat-template-kwargs "{\"preserve_thinking\": true}" ^
  --spec-type ngram-simple ^
  --spec-ngram-size-n 24 ^
  --spec-ngram-min-hits 1 ^
  --draft-min 12 ^
  --draft-max 48 ^
  --metrics ^
  --port 8000

echo.
echo ==========================================
echo  Server terminato con codice: %ERRORLEVEL%
echo ==========================================
pause
