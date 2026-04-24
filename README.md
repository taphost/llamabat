# llamacpp.bat ottimizzato


Batch di avvio per `llama-server` (llama.cpp embedded in Unsloth Studio) ottimizzato per schede con 16GB di VRAM, 
lo scopo è di tenere il modello **Qwen3.6-35B-A3B-UD-IQ3_XXS** (scaricato in LM Studio) per intero nella VRAM senza alcun offload dei layer 
sulla CPU per ottenere il massimo delle prestazioni e al contempo mantenere il sistema utilizzabile senza troppi rallentamenti.


Per la documentazione completa dei parametri vedere [PARAMETRI.md](./PARAMETRI.md).

---

## Percorsi

```batch
set LLAMA_SERVER=C:\Users\TUONOMEUTENTE\.unsloth\llama.cpp\build\bin\Release\llama-server.exe
```
Binario llama-server incluso nell'installazione di Unsloth Studio.

```batch
set MODEL=C:\Users\TUONOMEUTENTE\.cache\lm-studio\models\unsloth\Qwen3.6-35B-A3B-GGUF\Qwen3.6-35B-A3B-UD-IQ3_XXS.gguf
```
Modello GGUF. Quantizzazione IQ3_XXS (3.05 BPW, ~12.3 GiB).

---

## Monitoraggio Token/Sec

**1. Log del server** — ad ogni richiesta completata:
```
slot release: id 0 | prompt 512 tokens in 2.34s, 218.8 t/s | generation 128 tokens in 4.12s, 31.1 t/s
```
Il valore rilevante è **generation** (t/s dopo il prefill).

**2. UI web integrata** — disponibile su:
```
http://127.0.0.1:8000
```

**3. Endpoint metrics** — con `--metrics` abilitato:
```
http://127.0.0.1:8000/metrics
```


