# info-index.md

## Cos'è index.html

`index.html` è la pagina di navigazione principale della documentazione llamabat. Offre un'interfaccia single-page per accedere a tutti i file del progetto: batch, guide e documentazione.

## Struttura

La pagina è divisa in 3 sezioni di navigazione nella sidebar:

### Esecuzione
- **Home** — README principale del progetto
- **Avvia Server** — File batch llamacpp.bat per lanciare il server
- **Lista Parametri** — Guida ai parametri disponibili

### Configurazione
- **Configurazione OpenCode** — Setup di opencode
- **System Prompt LM Studio** — Configurazione system prompt per LM Studio

### Supporto
- **Problemi Comuni** — Risoluzione problemi frequenti
- **Info Pagina** — Documentazione sul navigatore

## Funzionalità

### Navigazione
- Caricamento file tramite `fetch()` (richiede server HTTP per CORS)
- Rendering markdown con `marked.js`
- Rendering file di codice con evidenziazione basica
- Pulsanti "Copia" su ogni blocco di codice

### Navigazione tastiera
- **Frecce Su/Giù** — Navigano tra i link della sidebar
- **Enter/Space** — Attivano il link selezionato
- **`:focus-visible`** — Outline visibile solo per navigazione da tastiera

### Tema
- Tema chiaro (Solarized) e scuro (GitHub-style)
- Preferenza salvata in `localStorage`
- Tema scuro come default
- Bottone tema nella topbar (visibile su tutte le dimensioni)
- Icone SVG inline (Lucide-style) per tema toggle

### Topbar
- **Desktop**: bottone tema sempre visibile
- **Mobile**: hamburger + tema + fullscreen con auto-hide (svanisce dopo 3s)
- Click nella zona superiore (80px) per riapparire su mobile

### Accessibilità
- `role="navigation"` sulla sidebar con `aria-label="Navigazione"`
- `role="menu"` sui contenitori di navigazione
- `aria-current="page"` sul link attivo
- `aria-label` su tutti i pulsanti della topbar
- Link GitHub con `<title>` e `aria-label`
- Navigazione completa da tastiera

### Sicurezza
- Sanitizzazione HTML con DOMPurify
- Escape HTML per file di codice
- Sostituzione emoji con SVG inline per rendering coerente

### Responsive
- Sidebar collassabile su mobile con hamburger menu
- Overlay scuro per chiudere la sidebar
- Layout flex con contenuto sidebar scrollabile
- Tabelle scrollabili orizzontalmente su mobile
- Scrollbar personalizzato globale (desktop + mobile)

### Fullscreen
- Toggle schermo intero da topbar (solo mobile)
- Icona dinamica (espandi/riduci)

## Dipendenze esterne

- `marked.js` — Parsing markdown da CDN
- `DOMPurify` — Sanitizzazione HTML da CDN

## Avvio in locale

Apri `index.html` con un server HTTP locale:

```powershell
# PowerShell — cartella llamabat/
cd llamabat
python -m http.server 8000
```

Poi apri: `http://localhost:8000`

oppure usa estensioni VS Code come "Live Server".

## Note tecniche

  - I percorsi dei file sono relativi a `index.html`
- Su file system puro (file://) alcuni file potrebbero non caricarsi per CORS
- Font-size base: 16px per compatibilità mobile
