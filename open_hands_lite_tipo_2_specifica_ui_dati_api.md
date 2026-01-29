OPENHANDS-LITE “TIPO 2”: WIREFRAME (UI)

Layout a 3 colonne + topbar (una pagina SPA)

TOP BAR (altezza 56px)
- Project/Repo selector (path locale)
- Engine selector: Copilot SDK | Copilot CLI | OpenHands (opzionale)
- Model selector (se engine lo supporta)
- Pulsanti: New Task, Settings
- Stato: “Idle / Running (N)”

COLONNA SINISTRA (Tasks) 25%
- Search box + filtri (status, repo, label)
- Lista task (titolo, repo, status badge, last run)
- Quick actions per riga: Run, Open, Archive

COLONNA CENTRALE (Run Console) 50%
- Header: Task title + Run status + timer + branch/workdir
- Tabs:
  1) Conversation (prompt + risposte agent)
  2) Tool log (comandi, file edit, web, ecc)
  3) Diff summary (stat: file changed, +/−)
- Composer (in basso):
  - campo “Follow-up” per continuare la run
  - pulsanti: Continue, Stop, Mark needs review

COLONNA DESTRA (Review & Output) 25%
- Tabs:
  1) Artifacts
     - Patch/diff (download/applica)
     - File generati (preview)
     - Report (markdown/html)
  2) Validation
     - Test, lint, build
     - esito + log + duration
  3) Files changed
     - elenco file con pulsante “Open in VS Code”

MODAL / DRAWER “New Task”
- Title
- Repo path (picker)
- Description (prompt principale)
- Context files (checkbox lista o path glob)
- Validation plan (test cmd, lint cmd, build cmd)
- Engine overrides (tools allowed, budget, ecc)

DATI MINIMI (STRUTTURA)

Tieni 4 entità. SQLite va benissimo per partire.

Task
{
  "id": "tsk_01J...",
  "title": "Fix build su Linux",
  "repoPath": "/home/mario/projects/xyz",
  "description": "Sistema l'errore ...",
  "context": {
    "files": ["package.json", "src/**"],
    "notes": "usa pnpm"
  },
  "validationPlan": {
    "lint": "pnpm lint",
    "test": "pnpm test",
    "build": "pnpm build"
  },
  "status": "ready",
  "createdAt": "2026-01-29T10:12:00+01:00",
  "updatedAt": "2026-01-29T10:12:00+01:00"
}

Run
{
  "id": "run_01J...",
  "taskId": "tsk_01J...",
  "engine": "copilot-sdk",
  "model": "auto",
  "status": "running",
  "repoPath": "/home/mario/projects/xyz",
  "workBranch": "agent/tsk_01J.../run_01J...",
  "startedAt": "...",
  "endedAt": null,
  "stats": { "tokens": null, "premiumRequests": null }
}

Artifact
{
  "id": "art_01J...",
  "runId": "run_01J...",
  "type": "patch | file | report | link",
  "name": "diff.patch",
  "path": "artifacts/run_01J.../diff.patch",
  "mime": "text/x-diff",
  "createdAt": "..."
}

Validation
{
  "id": "val_01J...",
  "runId": "run_01J...",
  "kind": "lint | test | build | custom",
  "command": "pnpm test",
  "status": "pass | fail | skipped",
  "exitCode": 0,
  "logPath": "artifacts/run_01J.../test.log",
  "durationMs": 123456
}

Stati consigliati (semplici)
- Task.status: draft, ready, archived
- Run.status: queued, running, needs_review, done, failed, stopped

API EXPRESS (MINIMA MA COMPLETA)

CRUD Task
- GET /api/tasks?status=&q=&repo=
- POST /api/tasks
- GET /api/tasks/:id
- PATCH /api/tasks/:id
- POST /api/tasks/:id/archive

Run
- POST /api/tasks/:id/run  (crea run + avvia engine)
- GET /api/runs/:id
- POST /api/runs/:id/continue  (follow-up)
- POST /api/runs/:id/stop

Streaming eventi (fondamentale per UX)
- GET /api/runs/:id/stream  (SSE: text/event-stream)

Artifacts
- GET /api/runs/:id/artifacts
- GET /api/artifacts/:id/download

Validation
- POST /api/runs/:id/validate  (esegue lint/test/build)
- GET /api/runs/:id/validations

VS Code integration (locale)
- POST /api/vscode/open  body: { "path": "...", "line": 1, "col": 1 }
  - implementazione: code --reuse-window --goto path:line:col

Sicurezza minima (importantissima)
- Allowlist repoPath: solo dentro una lista di root consentite
- Comandi validation: solo quelli del task.validationPlan (niente input libero)
- Engine tools: restringibili (vedi sotto)

EVENT MODEL (SSE) PER UI “TIPO 2”

Unifica tutto in un flusso di eventi. La UI non deve “capire” Copilot/OpenHands: ascolta eventi.

Esempio eventi:
{
  "type": "run.started",
  "runId": "run_...",
  "ts": "..."
}
{
  "type": "assistant.message",
  "role": "assistant",
  "content": "..."
}
{
  "type": "tool.call",
  "tool": "shell",
  "input": "git status"
}
{
  "type": "tool.result",
  "tool": "shell",
  "output": "..."
}
{
  "type": "artifact.created",
  "artifactId": "art_...",
  "name": "diff.patch"
}
{
  "type": "validation.done",
  "kind": "test",
  "status": "pass"
}
{
  "type": "run.needs_review",
  "summary": "..."
}
{
  "type": "run.finished",
  "status": "done"
}

ENGINE LAYER: COME AGGANCIARE COPILOT SDK (E FALLBACK CLI)

Interfaccia unica
interface AgentEngine {
  startRun(input: { taskId: string; repoPath: string; prompt: string; contextFiles?: string[] }): Promise<{ runId: string }>;
  continueRun(input: { runId: string; prompt: string }): Promise<void>;
  stopRun(input: { runId: string }): Promise<void>;
}

Workflow raccomandato per ogni Run (indipendente dall’engine)
1) crea branch: agent/<taskId>/<runId>
2) engine lavora solo su quella branch
3) a fine run, genera:
   - diff.patch (git diff)
   - summary.md (cosa ha fatto + come validare)
4) esegui validationPlan (lint/test/build)
5) set status a needs_review o done

STRUTTURA CARTELLE (MONOREPO SEMPLICE)

openhands-lite/
  apps/
    web/        (Next.js)
    server/     (Express)
  storage/
    db.sqlite
  artifacts/
    run_.../
      diff.patch
      summary.md
      test.log
  config/
    repos.allowlist.json

IMPLEMENTAZIONE LINEARE (SENZA FRIZIONI)

Step A: Backend Express
- SQLite schema + repository layer
- SSE endpoint (stream)
- Engine adapter (inizialmente “copilot-cli spawn”, poi “copilot-sdk”)

Step B: Frontend Next
- Pagina unica con layout 3 colonne
- Task list + Task drawer
- Run page/section con stream SSE
- Artifacts/Validation tabs

Step C: Integrazione VS Code
- “Open in VS Code” su file changed
- Bottone “Checkout run branch” (comando git suggerito a schermo o endpoint dedicato)

