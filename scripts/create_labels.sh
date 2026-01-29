#!/usr/bin/env bash
set -euo pipefail

# Script per creare label su GitHub usando la CLI `gh`.
# Requisiti: `gh` autenticato con accesso al repo.
# Uso: ./scripts/create_labels.sh <owner> <repo>

OWNER=${1:-}
REPO=${2:-}

if [ -z "$OWNER" ] || [ -z "$REPO" ]; then
  echo "Usage: $0 <owner> <repo>"
  exit 2
fi

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
LABELS_FILE="$ROOT_DIR/kraken/labels.json"

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI non trovato. Installare da https://cli.github.com/"
  exit 3
fi

if [ ! -f "$LABELS_FILE" ]; then
  echo "File labels non trovato: $LABELS_FILE"
  exit 4
fi

echo "Creazione label per $OWNER/$REPO usando $LABELS_FILE"

jq -c '.[]' "$LABELS_FILE" | while read -r label; do
  name=$(echo "$label" | jq -r '.name')
  color=$(echo "$label" | jq -r '.color')
  desc=$(echo "$label" | jq -r '.description')

  # Controlla esistenza
  if gh label list -R "$OWNER/$REPO" --limit 1000 | grep -Fiq "^$name"; then
    echo "Label '$name' esistente, aggiornamento..."
    gh label edit "$name" --color "$color" --description "$desc" -R "$OWNER/$REPO" || true
  else
    echo "Creazione label '$name'..."
    gh label create "$name" --color "$color" --description "$desc" -R "$OWNER/$REPO" || true
  fi
done

echo "Operazione completata."
