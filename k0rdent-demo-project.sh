#!/usr/bin/env bash
set -euo pipefail

# ========= EDIT THESE VALUES (safe for public repos) =========
# Use "AUTO" to auto-pick if exactly one ACTIVE billing account is visible.
# Or set a real ID before committing privately (e.g., "000000-000000-000000").
BILLING_ACCOUNT_ID="AUTO"

# Optional org/folder scoping (leave empty if none)
ORG_ID=""
FOLDER_ID=""
# =============================================================

# Local override file (gitignore this!)—if present, its content wins.
LOCAL_BILLING_FILE=".k0rdent-demo.billing"

# k0rdent-demo project lifecycle helper (self-contained, public-safe)
NAME="k0rdent-demo"
LABEL_KEY="app"
LABEL_VAL="k0rdent-demo"
CLEANUP="no"
YES="no"
PROJECT_ID_ARG=""
BILLING_ARG=""

usage() {
  cat <<EOF
Usage:
  $0                    Create (or reuse) the "${NAME}" project, print project ID
  $0 --cleanup          Delete the "${NAME}" project
Options:
  --project-id ID       Target this specific project ID for cleanup/output
  --billing ID          Override billing account id at runtime
  --yes                 Don't ask for confirmation on cleanup
  -h, --help            Show this help

Notes:
- Public-safe defaults:
    * BILLING_ACCOUNT_ID="AUTO": if exactly one ACTIVE billing account exists, it is used.
      If multiple are found, you'll be prompted to choose.
    * You can create a local file "${LOCAL_BILLING_FILE}" containing your billing ID;
      it overrides the hardcoded value and is intended to be in .gitignore.
- Cleanup:
    * If --project-id is given, only that project is deleted.
    * Otherwise, deletes ACTIVE projects with name="${NAME}" AND label "${LABEL_KEY}=${LABEL_VAL}".
EOF
}

# ---- arg parsing ----
while [[ $# -gt 0 ]]; do
  case "$1" in
    --cleanup) CLEANUP="yes"; shift ;;
    --project-id) PROJECT_ID_ARG="${2:-}"; shift 2 ;;
    --billing) BILLING_ARG="${2:-}"; shift 2 ;;
    --yes) YES="yes"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1 ;;
  esac
done

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1" >&2; exit 1; }; }
need gcloud

confirm() {
  [[ "$YES" == "yes" ]] && return 0
  read -r -p "$1 [y/N]: " ans || true
  [[ "${ans,,}" == "y" || "${ans,,}" == "yes" ]]
}

# Resolve billing account id (priority: --billing > local file > hardcoded)
resolve_billing_id() {
  local id=""
  if [[ -n "$BILLING_ARG" ]]; then
    id="$BILLING_ARG"
  elif [[ -f "$LOCAL_BILLING_FILE" ]]; then
    id="$(tr -d ' \t\r\n' < "$LOCAL_BILLING_FILE")"
  else
    id="$BILLING_ACCOUNT_ID"
  fi

  if [[ "$id" == "AUTO" ]]; then
    # List ACTIVE billing accounts you can use
    mapfile -t accounts < <(gcloud billing accounts list \
      --filter="open=true" \
      --format="value(ACCOUNT_ID)")
    if (( ${#accounts[@]} == 0 )); then
      echo "ERROR: No ACTIVE billing accounts visible to this gcloud identity." >&2
      exit 1
    elif (( ${#accounts[@]} == 1 )); then
      echo "${accounts[0]}"
      return 0
    else
      echo "Multiple ACTIVE billing accounts detected:" >&2
      local i=1
      for a in "${accounts[@]}"; do echo "  [$i] $a" >&2; ((i++)); done
      local choice
      read -r -p "Select billing account [1-${#accounts[@]}]: " choice
      if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#accounts[@]} )); then
        echo "Invalid choice." >&2; exit 1
      fi
      echo "${accounts[choice-1]}"
      return 0
    fi
  fi

  # Basic sanity check (best-effort)
  if ! [[ "$id" =~ ^[0-9A-Za-z]{6}-[0-9A-Za-z]{6}-[0-9A-Za-z]{6}$ ]]; then
    echo "WARNING: Billing account id '$id' has an unusual format. Continuing..." >&2
  fi

  echo "$id"
}

# Find ACTIVE projects by display name (and optionally our label)
find_projects() {
  local mode="${1:-}"
  local filter="name=${NAME} AND lifecycleState=ACTIVE"
  if [[ "$mode" == "with_label" ]]; then
    filter="${filter} AND labels.${LABEL_KEY}=${LABEL_VAL}"
  fi
  gcloud projects list --filter="${filter}" --format="value(projectId)"
}

# ------------------ CLEANUP ------------------
if [[ "$CLEANUP" == "yes" ]]; then
  if [[ -n "$PROJECT_ID_ARG" ]]; then
    echo "About to delete project: ${PROJECT_ID_ARG}"
    confirm "Proceed?" || { echo "Aborted."; exit 0; }
    gcloud projects delete "$PROJECT_ID_ARG" --quiet || true
    echo "Deleted (or did not exist): ${PROJECT_ID_ARG}"
    exit 0
  fi

  PROJECTS_TO_DELETE="$(find_projects with_label || true)"
  if [[ -z "${PROJECTS_TO_DELETE}" ]]; then
    echo "No ACTIVE '${NAME}' projects with label ${LABEL_KEY}=${LABEL_VAL} found; nothing to delete."
    exit 0
  fi

  echo "Projects to delete:"
  echo "${PROJECTS_TO_DELETE}" | sed 's/^/  - /'
  confirm "Delete all listed projects?" || { echo "Aborted."; exit 0; }

  while IFS= read -r pid; do
    [[ -z "$pid" ]] && continue
    echo "Deleting ${pid} ..."
    gcloud projects delete "$pid" --quiet || true
  done <<< "${PROJECTS_TO_DELETE}"
  echo "Cleanup complete."
  exit 0
fi

# ------------------ CREATE / REUSE ------------------
# Reuse if any ACTIVE project has this *display name*
EXISTING_PIDS="$(find_projects || true)"
if [[ -n "${EXISTING_PIDS}" ]]; then
  # Prefer one with our label; else first match
  LABELED_PID="$(find_projects with_label || true | head -n1 || true)"
  PID="${LABELED_PID:-$(echo "${EXISTING_PIDS}" | head -n1)}"
  echo "${PID}"
  exit 0
fi

# Generate unique, DNS-compliant project_id
BASE_ID="$(echo "$NAME" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9-' '-')"
BASE_ID="${BASE_ID%-}"
SUFFIX="$(date +%y%m%d)-$RANDOM"
PROJECT_ID="${BASE_ID}-${SUFFIX}"

CREATE_ARGS=(projects create "$PROJECT_ID" --labels "${LABEL_KEY}=${LABEL_VAL}" --name "$NAME")
if [[ -n "$FOLDER_ID" && -n "$ORG_ID" ]]; then
  echo "ERROR: Set only one of ORG_ID or FOLDER_ID (not both)." >&2; exit 1
elif [[ -n "$FOLDER_ID" ]]; then
  CREATE_ARGS+=(--folder "$FOLDER_ID")
elif [[ -n "$ORG_ID" ]]; then
  CREATE_ARGS+=(--organization "$ORG_ID")
fi

echo "Creating project: name='${NAME}' id='${PROJECT_ID}'" >&2
gcloud "${CREATE_ARGS[@]}" 1>/dev/null

# Resolve and link billing (no env vars)
RESOLVED_BILLING_ID="$(resolve_billing_id)"
echo "Linking billing account: ${RESOLVED_BILLING_ID}" >&2
gcloud billing projects link "${PROJECT_ID}" --billing-account "${RESOLVED_BILLING_ID}" 1>/dev/null

# Output the project ID only
echo "${PROJECT_ID}"
