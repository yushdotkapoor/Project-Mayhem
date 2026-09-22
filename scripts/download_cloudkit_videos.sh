#!/usr/bin/env bash
# Downloads every asset from the "Videos" record type in the app's public
# CloudKit database. Uses Xcode's cktool for the query and curl for the files.
#
# One-time setup (needs a CloudKit *user* token):
#   1. Open https://icloud.developer.apple.com/dashboard
#   2. Click your account menu (top right) -> "User Token" / "Generate Token"
#      (the token is generated for the cktool client).
#   3. Run:  xcrun cktool save-token --type user
#      and paste the token when prompted.
#
# Usage:
#   scripts/download_cloudkit_videos.sh [output_dir] [environment]
#   environment defaults to "production"; use "development" for the dev container.

set -euo pipefail

TEAM_ID="${TEAM_ID:-BLXDQ5R8AB}"
CONTAINER_ID="${CONTAINER_ID:-iCloud.com.YushRajKapoor.ProjectMayhem}"
OUT_DIR="${1:-$HOME/Downloads/ProjectMayhemVideos}"
ENVIRONMENT="${2:-production}"
RECORD_TYPE="Videos"

mkdir -p "$OUT_DIR"
MANIFEST="$OUT_DIR/records.json"
echo "[]" > "$MANIFEST"

query() {
  local args=(query-records
    --team-id "$TEAM_ID"
    --container-id "$CONTAINER_ID"
    --environment "$ENVIRONMENT"
    --database-type public
    --zone-name _defaultZone
    --record-type "$RECORD_TYPE"
    --limit 200)
  if [[ -n "${1:-}" ]]; then
    args+=(--continuation-token "$1")
  fi
  xcrun cktool "${args[@]}"
}

# Page through every record and collect them into the manifest.
token=""
page=1
while :; do
  echo "Fetching page $page..." >&2
  result="$(query "$token")"
  jq -s '.[0] + (.[1].records // [])' "$MANIFEST" <(printf '%s' "$result") > "$MANIFEST.tmp"
  mv "$MANIFEST.tmp" "$MANIFEST"
  token="$(printf '%s' "$result" | jq -r '.continuationToken // empty')"
  [[ -z "$token" ]] && break
  page=$((page + 1))
done

total="$(jq 'length' "$MANIFEST")"
echo "Found $total $RECORD_TYPE record(s). Saving to $OUT_DIR" >&2

# Emit one line per asset: recordName <TAB> downloadUrl
jq -r '
  .[] | .recordName as $name
  | .fields.video.value.downloadUrl // (.fields | to_entries[] | .value.value.downloadUrl? // empty)
  | select(. != null and . != "")
  | "\($name)\t\(.)"
' "$MANIFEST" | while IFS=$'\t' read -r name url; do
  dest="$OUT_DIR/$name.mov"
  if [[ -s "$dest" ]]; then
    echo "skip   $name.mov (already exists)" >&2
    continue
  fi
  echo "get    $name.mov" >&2
  curl -fSL --retry 3 -o "$dest.part" "$url" && mv "$dest.part" "$dest"
done

echo "Done. Files:" >&2
ls -lh "$OUT_DIR"/*.mov 2>/dev/null >&2 || echo "(no .mov files downloaded)" >&2
