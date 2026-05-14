# Avvio di llama-server su Windows 10/11 con llama.cpp

> Batch di avvio per `llama-server.exe` pensato per utenti Windows 10/11 che usano **Unsloth Studio** e **LM Studio**.

---

## 📦 LM Studio + Perché Unsloth Studio 

### LM Studio

LM Studio è una delle app più semplici per iniziare:

**Vantaggi**
- Scarica rapidamente i modelli in formato standard `.gguf` dal Model Search
- Imposti subito i parametri da interfaccia grafica senza smanettamenti
- La modalità Developer permette di avviare il server con un click su `http://127.0.0.1:1234`

**Svantaggi**
- Basata su una versione stabile di `llama.cpp`, spesso indietro sulle ultime funzionalità

### Unsloth Studio

Ideal per passare allo step successivo con i modelli locali:

**Vantaggi**
- In modalità Chat carica i migliori parametri per i modelli in automatico
- Include tool come il web search direttamente nella Chat senza plugin da installare, e può usare i `.gguf` già scaricati da LM Studio
- Aggiorna `llama.cpp` all'ultima versione ad ogni `unsloth studio update`
- Ideale per sfruttare le novità più recenti e i workflow di finetuning

**Svantaggi**
- I modelli scaricati direttamente sono blob grezzi, non `.gguf` standard

**Questo batch unisce il meglio di entrambi:** usa il `llama-server.exe` più recente da Unsloth Studio con un modello scaricato da LM Studio.

---

## 🚀 Quick Start

1. Apri il file batch: `batches/llamacpp.bat`
2. Modifica `NOMEUTENTE` nei percorsi se necessario
3. Doppio click per avviare
4. Accedi a `http://localhost:8000` per interagire con il modello

---

## 📁 Struttura del progetto

```
llamabat/
├── README.md                                                           ← questo file
├── docs/
│   ├── guida-parametri-batch.md                                        ← documentazione parametri batch
│   ├── opencode-config.md                                              ← configurazione OpenCode
│   ├── system-prompt-lmstudio.md                                       ← esempi system prompt per LM Studio
│   └── problemi-comuni.md                                              ← troubleshooting e soluzioni
└── batches/
    └── llamacpp.bat                                                    ← file batch pronto all'uso
```

---

## 🖥️ Configurazione hardware

Il batch è ottimizzato per:

- **GPU:** 16GB VRAM
- **CPU:** 8 core
- **Modello:** Qwen3.6-35B-A3B-UD-IQ3_XXS (~12.3 GiB, 3.05 BPW)

### Caratteristiche

- ✅ **Reasoning/thinking sempre attivo** — `--reasoning on` con budget illimitato (`--reasoning-budget -1`)
- ✅ **Modello non in modalità instruct** — pensa liberamente prima di rispondere
- ✅ **Tutti i layer in VRAM** — `-ngl 9999`, zero offload sulla CPU
- ✅ **Vision disabilitata** — `--no-mmproj` + `--no-mmproj-offload` risparmia ~1.66 GB (percorso mmproj già configurato)
- ✅ **Speculative decoding** — `--spec-type ngram-mod` per accelerare la generazione

### File mmproj

Il file `mmproj-F32.gguf` scaricato insieme al modello pesa **1.66 GB**.

**Per abilitare la visione** (richiede mmproj): nel batch `llamacpp.bat`, aggiungi `--mmproj "%MMPROJ%" ^` e rimuovi `--no-mmproj` + `--no-mmproj-offload`. Il percorso è già definito nella variabile `MMPROJ`.

---

## 🔧 Percorsi configurati

Nel batch usiamo variabili `%NOMEVARIABLE%` in cima per evitare di incollare i percorsi completi sparsi nel comando. Tutte le definizioni sono riunite qui:

```batch
set LLAMA_SERVER=C:\Users\NOMEUTENTE\.unsloth\llama.cpp\build\bin\Release\llama-server.exe
set MODEL=C:\Users\NOMEUTENTE\.cache\lm-studio\models\unsloth\Qwen3.6-35B-A3B-GGUF\Qwen3.6-35B-A3B-UD-IQ3_XXS.gguf
set TEMPLATE=C:\Users\NOMEUTENTE\Documents\template\chat_template-v15.jinja
set MMPROJ=C:\Users\NOMEUTENTE\.cache\lm-studio\models\unsloth\Qwen3.6-35B-A3B-GGUF\mmproj-F32.gguf
```

Modifica `NOMEUTENTE` con il tuo nome utente Windows.

---

## 🎭 Template Jinja

I template Jinja definiscono come i messaggi della chat vengono formattati prima di essere inviati al modello.
Contengono le istruzioni di sistema, i separatori tra user/assistant, e i markup per il reasoning (`<think>`).

Con **Qwen3.5** e **Qwen3.6** i template ufficiali sono stati problematici: problemi di parsing,
tags di reasoning che non vengono chiusi correttamente, o template che non rispettano il formato atteso.

Senza un template corretto possono verificarsi:
- Errori nella chiamata del tooling agentico
- Thinking looping (il modello non esce dal blocco `<think>`)
- Stop improvvisi della generazione
- Formattazione errata dei messaggi

Il modello Qwen3.6 richiede un template di chat Jinja personalizzato per funzionare correttamente.

- **Template usato:** `chat_template-v15.jinja` (versione per Qwen3.6)
- **Template ottimizzati:** [froggeric/Qwen-Fixed-Chat-Templates](https://huggingface.co/froggeric/Qwen-Fixed-Chat-Templates/tree/main) — template testati per Qwen3.x
- **Posizione:** scarica il template in una cartella a piacere, poi indica il percorso in `set TEMPLATE=` nel batch

Usare sempre un template verificato e compatibile con la propria versione del modello.

---

## 📊 Monitoraggio

**Log del server** — ad ogni richiesta:
```
slot release: id 0 | prompt 512 tokens in 2.34s, 218.8 t/s | generation 128 tokens in 4.12s, 31.1 t/s
```
Il valore rilevante è **generation** (t/s dopo il prefill).

**UI web integrata** — disponibile su: `http://localhost:8000`

**Endpoint metrics** — con `--metrics` abilitato: `http://localhost:8000/metrics`

---

## 📖 Documentazione

Per la documentazione completa di ogni parametro: [guida-parametri-batch.md](./docs/guida-parametri-batch.md)

> Prossimamente: guide dedicate alla configurazione per altre configurazioni hardware.

---

## 🤖 Agenti CLI

Se vuoi usare il modello con agenti CLI che supportano l'elaborazione di immagini:

- **[OpenCode](https://github.com/anomalyco/opencode)** — Consigliato. Il più semplice per un beginner, carica un system prompt già pronto. Svantaggio: consuma subito più di 10k di contesto ([config](./docs/opencode-config.md))
- **[pi.dev](https://pi.dev)** — Essenziale, dedicato agli utenti avanzati. Permette configurabilità totale ma se non usato bene può fare danni (cancellare file, ecc.)
- **[Little-Coder](https://github.com/itayinbarr/little-coder)** — Basato su pi.dev, ha guardrail per maggiore sicurezza e ottimizzazioni specifiche per Qwen3.5/3.6

---

## 🔗 Riferimenti

| Progetto | Link |
|---|---|
| [llama.cpp](https://github.com/ggml-org/llama.cpp) | `ggml-org/llama.cpp` — il motore di inferenza |
| [Unsloth Studio](https://unsloth.ai/docs/new/studio) | Aggiorna llama.cpp all'ultima versione, ideale per finetuning |
| [LM Studio](https://lmstudio.ai) | App semplice per scaricare e testare modelli `.gguf` |
| [GPU-Z](https://www.techpowerup.com/gpuz/) | Monitoraggio VRAM su Windows 10/11 — utile per verificare l'occupazione dei modelli |
