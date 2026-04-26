# Parametri llama-server · Qwen3.6-35B-A3B

Documentazione dettagliata di ogni parametro usato nel batch, nell'ordine in cui appaiono.

**Riferimenti ufficiali:**
- [llama-server README](https://github.com/ggml-org/llama.cpp/blob/master/tools/server/README.md)
- [Speculative Decoding](https://github.com/ggml-org/llama.cpp/blob/master/docs/speculative.md)

---

## 1 · Modello

| Parametro | Valore | Descrizione |
|---|---|---|
| `-m` | `%MODEL%` | Path al file GGUF del modello |
| `--no-mmproj` | — | Disabilita il proiettore multimodale (visione). Il modello è vision ma non serve per uso testuale, risparmia ~600MB VRAM |
| `--no-mmproj-offload` | — | Impedisce l'offload del proiettore multimodale sulla GPU. Va sempre usato insieme a `--no-mmproj` — senza di esso llama.cpp può allocare residui del proiettore in VRAM anche se la visione è disabilitata |

---

## 2 · GPU / CPU offload

| Parametro | Valore | Descrizione |
|---|---|---|
| `-ngl` / `--n-gpu-layers` | `9999` | Offloada il massimo numero di layer sulla GPU. 9999 = "tutto sulla GPU". Con `--fit on` i layer che non entrano vengono automaticamente spostati in RAM |
| `-ncmoe` | `0` | Layer MoE (Mixture of Experts) tenuti in CPU. `0` = tutti in GPU. **Alzare** se la VRAM è insufficiente |
| `--fit on` | — | Adatta automaticamente i parametri alla VRAM disponibile. Se qualcosa non entra, scala contesto o sposta layer su RAM invece di crashare |
| `-fitt` | `512` | Margine VRAM (MiB) che `--fit` lascia libero. Abbassato dal default (1024) per mettere più roba in GPU |

**Guida per fascia VRAM:**
| VRAM | Consiglio |
|---|---|
| 8–12 GB | `-ngl 20-30` + `-ncmoe 8` + contesto ridotto (32k) |
| 16–20 GB | `-ngl 9999` + `-ncmoe 0` + `--fit on` — tutto in GPU su Q4/IQ3. Contesto fino a 131k con KV q4_0 |
| 24–32 GB | `-ngl 9999` senza `--fit`, contesto pieno 262k, KV q8_0, `-np 2` fattibile |
| 48+ GB | Modelli 70B Q4, `-np 4`, KV f16, contesto massimo |

---

## 3 · Caricamento modello

| Parametro | Valore | Descrizione |
|---|---|---|
| `--no-mmap` | — | Disabilita il memory-mapping del file. Più lento al caricamento ma migliori performance runtime, necessario quando ci sono tensor override su CPU |
| `--mlock` | — | Forza il sistema operativo a tenere il modello in RAM fisica, impedendo lo swap da parte di Windows |

---

## 4 · Priorità e parallelismo

| Parametro | Valore | Descrizione |
|---|---|---|
| `--prio` | `3` | Priorità del processo: 0=normale, 1=media, 2=alta, 3=realtime. Realtime garantisce massima CPU durante prefill e generazione |
| `-np` / `--parallel` | `1` | Numero di slot paralleli (richieste simultanee). `--parallel` è l'alias esteso. Con 1 si ottimizza per uso singolo |
| `--cont-batching` | — | Continuous batching: permette di aggiungere nuove richieste mentre la generazione è in corso, senza attendere il completamento dello slot corrente. **Con `-np 1` è praticamente inutile** — non ci sono mai richieste concorrenti da gestire. Utile solo con `-np 2+` |

---

## 5 · Batch e thread

| Parametro | Valore | Descrizione |
|---|---|---|
| `-b` | `2048` | Batch size logico: numero massimo di token processati insieme nel prefill del prompt |
| `-ub` | `512` | Micro-batch size fisico: quanti token processa la GPU in un singolo kernel. Valore più basso = meno VRAM per il compute buffer |
| `-tb` | `2` | Thread CPU dedicati al batch/prompt processing |
| `-t` | `6` | Thread CPU dedicati alla generazione token per token. Separato da `-tb` |

---

## 6 · Contesto e prompt cache

| Parametro | Valore | Descrizione |
|---|---|---|
| `-c` | `131072` | Context window massima: 131k token. Il modello supporta fino a 262144 ma raddoppiare userebbe ~2.7GB di VRAM in più per il KV cache |
| `--cache-ram` | `512` | Riserva RAM (MiB) per il prompt cache. Con KV q4_0 e auto-compattazione a ~100k, 512 MiB è sufficiente per cachare il system prompt + prefill iniziale. Valori più alti (2048+) non portano benefici concreti con un solo utente |
| `-ctxcp` | `1` | Checkpoint del KV cache. Con auto-compattazione frequente i checkpoint vengono invalidati spesso — `1` è sufficiente, `0` per disabilitare completamente |
| `n_keep` | `-1` | Token del prompt iniziale da preservare durante la compattazione del contesto. `-1` = mantiene intero il system prompt (es. AGENTS.md) scartando i messaggi più vecchi. È il comportamento corretto per un assistant |

**Guida contesto per fascia VRAM** (con KV q4_0, modello ~12GB):
| VRAM | Contesto consigliato | `--cache-ram` consigliato |
|---|---|---|
| 8–12 GB | 8k–32k | 256 MiB |
| 16–20 GB | 65k–131k | 512 MiB |
| 24–32 GB | 131k–262k | 1024 MiB |
| 48+ GB | 262k + KV f16 | 2048 MiB |

---

## 7 · KV Cache

| Parametro | Valore | Descrizione |
|---|---|---|
| `--kv-unified` | — | Pool KV cache unico e dinamico. Abilita `--cache-idle-slots` e spreca meno VRAM quando il contesto usato è inferiore al massimo |
| `--kv-offload` | — | KV cache in VRAM (default, esplicitato per chiarezza) |
| `-ctk` | `q4_0` | Quantizzazione KV cache chiavi (K) a 4-bit. Massima compressione, necessaria con 16GB e contesto 131k |
| `-ctv` | `q4_0` | Quantizzazione KV cache valori (V) a 4-bit. Stesso effetto di `-ctk` |
| `-fa on` | — | Flash Attention: riduce VRAM e aumenta velocità del calcolo attenzione, specialmente con contesti lunghi |

**Guida quantizzazione per fascia VRAM:**
| VRAM | Quantizzazione consigliata |
|---|---|
| 8–12 GB | `q4_0` — unico modo per contesti >16k |
| 16–20 GB | `q4_0` con ctx 131k, oppure `q8_0` con ctx 65k |
| 24–32 GB | `q8_0` — ottimo compromesso qualità/spazio |
| 48+ GB | `f16` — massima qualità |

---

## 8 · Template

| Parametro | Valore | Descrizione |
|---|---|---|
| `--jinja` | — | Abilita il rendering del chat template Jinja2 embedded nel GGUF. Usa automaticamente il template ufficiale del modello per i token speciali di Qwen3 |

---

## 9 · Sampling

Parametri raccomandati ufficialmente da Qwen per la modalità thinking:

| Parametro | Valore | Descrizione |
|---|---|---|
| `--temp` | `0.6` | Temperatura: bilancia creatività e determinismo. 0.6 raccomandato da Qwen per il reasoning |
| `--top-p` | `0.95` | Nucleus sampling: considera i token che coprono il 95% della probabilità cumulativa |
| `--top-k` | `20` | Limita la selezione ai 20 token più probabili |
| `--min-p` | `0.0` | Soglia minima di probabilità per un token (0 = disabilitato) |
| `--presence-penalty` | `0.0` | Penalità per token già presenti nel testo (0 = nessuna) |
| `--repeat-penalty` | `1.0` | Penalità per sequenze ripetute (1.0 = nessuna) |

---

## 10 · Reasoning / Thinking

| Parametro | Valore | Descrizione |
|---|---|---|
| `--reasoning` | `on` / `off` / `auto` | Modalità thinking di Qwen3. `on` = sempre attivo, `off` = disabilitato, `auto` = il modello decide in base alla complessità della richiesta |
| `--reasoning-budget` | `-1` | Limite di token per il blocco `<think>`. `-1` = illimitato. Valori positivi (es. `2048`) troncano il thinking |
| `--chat-template-kwargs` | `{"preserve_thinking": true}` | Mantiene i blocchi `<think>` visibili nell'output invece di stripparli |

---

## 11 · Speculative Decoding

> Documentazione ufficiale: [docs/speculative.md](https://github.com/ggml-org/llama.cpp/blob/master/docs/speculative.md)

Tecnica che accelera la generazione proponendo token candidati in anticipo, verificati dal modello principale in un singolo batch. llama.cpp supporta due categorie: **con draft model** (modello separato più piccolo) e **senza draft model** (basato su pattern nel contesto — zero VRAM aggiuntiva). Il batch usa la seconda categoria.

**Tutti i `--spec-type` disponibili senza draft model:**

| Tipo | Descrizione |
|---|---|
| `none` | Disabilitato (default) |
| `ngram-cache` | Cache di statistiche su sequenze n-gram. Può caricare statistiche esterne da file |
| `ngram-simple` | Cerca nel contesto l'ultimo n-gram corrispondente e usa i m token successivi come draft. Overhead minimo. **Usato nel batch attuale** |
| `ngram-map-k` | Come ngram-simple ma usa una hash-map interna. Richiede minimo di occorrenze (`--spec-ngram-min-hits`) prima di generare draft |
| `ngram-map-k4v` | Sperimentale. Tiene traccia di fino a 4 m-gram per ogni chiave, sceglie il più frequente. Utile con molte ripetizioni lunghe |
| `ngram-mod` | Hash LCG con pool condiviso tra tutti gli slot (~16MB costanti), draft di lunghezza variabile. Consigliato per MoE con `--draft-min` alto |

**Differenza chiave:**
- `ngram-simple` / `ngram-map-k` → inseriscono una sequenza fissa di m token (m-gram)
- `ngram-mod` → mappa ogni hash al singolo token successivo, draft di lunghezza variabile

**Parametri nel batch:**

| Parametro | Valore | Descrizione |
|---|---|---|
| `--spec-type` | `ngram-simple` | Tipo senza draft model |
| `--spec-ngram-size-n` | `24` | Lunghezza n-gram di lookup (quanti token guardare indietro). Valori piccoli sconsigliati. **Nota:** il JSON di `/slots` può mostrare `speculative.ngram_size_n: 1024` — è un valore interno normalizzato dal server, non indica che il parametro venga ignorato |
| `--spec-ngram-min-hits` | `1` | Minimo occorrenze n-gram prima di usarlo come draft (rilevante per ngram-map-k) |
| `--draft-min` | `12` | Minimo token speculativi per round. Valore ridotto perché ngram-simple è più preciso di ngram-mod |
| `--draft-max` | `48` | Massimo token speculativi per round |

**Statistiche nel log:**
```
draft acceptance rate = 0.57576 (171 accepted / 297 generated)
statistics ngram_simple: #calls = 15, #gen drafts = 5, #acc drafts = 5, #gen tokens = 187, #acc tokens = 73
```
- `#gen tokens` / `#acc tokens` = token proposti / accettati dal modello principale
- `dur(b,g,a)` = durata ms di begin, generation, accumulation

Tasso >0.5 → guadagno in t/s. Tasso <0.3 → disabilitare o provare `ngram-mod`.

---

## 12 · Rete

| Parametro | Valore | Descrizione |
|---|---|---|
| `--metrics` | — | Abilita endpoint Prometheus su `http://127.0.0.1:8000/metrics` |
| `--port` | `8000` | Porta del server HTTP. API compatibile OpenAI su `http://127.0.0.1:8000` |
