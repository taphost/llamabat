# Problemi Comuni

## Template Jinja

### Il modello non esce dal blocco `<think>` (thinking looping)
- **Causa:** template ufficiale Qwen3.6 non chiude i tag di reasoning
- **Soluzione:** usare `chat_template-v15.jinja` da [froggeric/Qwen-Fixed-Chat-Templates](https://huggingface.co/froggeric/Qwen-Fixed-Chat-Templates/tree/main)
- **Parametri:** `--repeat-penalty 1.1-1.2` + `--presence-penalty 0.1-0.3` per rompere i loop

### Risposte incomplete o formattazione errata
- **Causa:** template non compatibile con la versione del modello
- **Soluzione:** verificare di usare il template per Qwen3.6, non Qwen3.5

### Il modello si ferma dopo pochi token
- **Causa:** `--reasoning-budget` troppo basso o template incompatibile
- **Soluzione:** impostare `--reasoning-budget -1` (illimitato)

## Reasoning / Thinking

### Il blocco `<think>` non appare
- **Causa:** `--reasoning off` o `--reasoning auto` (il modello decide)
- **Soluzione:** impostare `--reasoning on`

### Thinking troppo lungo (overthinking)
- **Disabilitare:** `--reasoning off` per modalità instruct
- **Limitare:** `--reasoning-budget 2048` o `4096` per troncare il thinking
- **Illimitato:** `--reasoning-budget -1` (default)

## Vision / MMProj

### Errore "mmproj file not found"
- **Causa:** percorso `--mmproj` errato o file non scaricato
- **Soluzione:** verificare `mmproj-F32.gguf` in `C:\Users\NOMEUTENTE\.cache\lm-studio\models\unsloth\Qwen3.6-35B-A3B-GGUF\`

### VRAM insufficiente
- **Causa:** `mmproj-F32.gguf` occupa ~1.66GB
- **Soluzione:** `--no-mmproj` + `--no-mmproj-offload` per disabilitare la visione

## Speculative Decoding

### `ngram-mod` rallenta invece di accelerare
- **Causa:** tasso di accettazione basso (< 0.3)
- **Soluzione:** `--spec-type none` per disabilitare

### Risposte errate con speculative decoding
- **Causa:** draft troppo aggressivi (`--spec-ngram-mod-n-min 48` minimo troppo alto)
- **Soluzione:** abbassare `--spec-ngram-mod-n-min` a 24-32

## Contesto e KV Cache

### Server crasha con contesti lunghi
- **Causa:** KV cache in f16 occupa troppo VRAM
- **Soluzione:** `-ctk q4_0` + `-ctv q4_0` per quantizzare

### Performance calano dopo molte richieste
- **Causa:** KV cache non pulita tra gli slot
- **Soluzione:** `--cache-idle-slots` + `--kv-unified`

### Context size troppo grande per la VRAM
- **Causa:** contesto lungo (es. 131k) consuma molta VRAM per la KV cache
- **Monitoraggio:** usa [GPU-Z](https://www.techpowerup.com/gpuz/) per verificare l'occupazione VRAM
- **Soluzioni:**
  - Ridurre `-c` a 32k-65k per GPU con 16GB o meno
  - Usare `-ctk q4_0` + `-ctv q4_0` per quantizzare la KV cache
  - Abbassare `-b` (batch size logico) se il prefill consuma troppo VRAM

### Prefill lento
- **Sintomo:** tempo di attesa lungo prima della prima risposta (prefill del prompt)
- **Monitoraggio:** nei log di `llama-server.exe`, guardare `prompt X tokens in Ys, Z t/s` — Z è la velocità di prefill
- **Fattori che rallentano:**
  - Contesto lungo (131k) → più token da processare
  - `-t` (thread CPU) troppo basso → prefill più lento
  - `-b` (batch size logico) troppo alto → più memoria, più tempo
  - `-ub` (micro-batch size) troppo alto → più carico sulla GPU
- **Soluzioni:**
  - Aumentare `-t` (thread CPU) se la CPU ha più core disponibili
  - Ridurre `-c` (context size) se non serve tutto
  - Abbassare `-b` e `-ub` se il prefill consuma troppo VRAM
  - Usare `--mlock` per tenere il modello in RAM e evitare swap

## Note generali

- **Testare sempre** ogni configurazione con un task rappresentativo
- **Monitorare i log** del server per identificare problemi prima che diventino critici
- **Aggiornare** llama.cpp con `unsloth studio update`
