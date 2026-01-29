# Lavoro — coding-dashboard

Data: 2026-01-29

Scopo
- Documento di lavoro e checklist per il progetto `coding-dashboard`.

Attività principali
- [ ] Definire struttura della dashboard
- [ ] Configurare ambiente di sviluppo (venv / dipendenze)
- [ ] Implementare backend minimo (API)
- [ ] Implementare frontend (visualizzazione metriche)
- [ ] Aggiungere test e CI
- [ ] Documentare utilizzo nel README

Note tecniche
- Repository: AstroMarius/coding-dashboard (branch: main)
- OS di sviluppo corrente: Linux

Istruzioni rapide
- Apri il progetto e crea un ambiente virtuale.
- Aggiorna questa lista man mano che completi le attività.

Prossimi passi suggeriti
- Decidere stack (framework frontend/backend)
- Creare issue per ogni attività sopra elencata
 - Importare le `labels` con lo script `scripts/create_labels.sh`
 - Usare i template in `.github/ISSUE_TEMPLATE/` per aprire nuove issue

Lavoro svolto (sintesi)
- Creati i file iniziali di lavoro: `lavoro.md` e `coding-dashboard.code-workspace`.
- Aggiunte impostazioni VS Code e task utili in `.vscode/` (`launch.json`, `tasks.json`).
- Aggiunti template issue in `.github/ISSUE_TEMPLATE/` e script `scripts/create_labels.sh` più `kraken/labels.json`.
- Creati esempi di issue in `kraken/issues/`.
- Organizzata struttura cartelle: `apps/web`, `apps/server`, `server`, `storage`, `artifacts`, `config`, `infra` e aggiunti `README.md`/`.gitkeep` placeholder.
- Bozze di documentazione: `doc/ux-ui.md` e `doc/architettura.md`.
- Creata cartella `daily/` con `daily/2026-01-29/today.md` per tracciare attività giornaliere.
- Clonato repository di riferimento OpenHands in `/tmp/OpenHands` per ispezione UI/Storybook.

