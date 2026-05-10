#!/usr/bin/env bash
set -euo pipefail

CODEX_HOME="${CODEX_HOME:-/root/.codex}"
export CODEX_HOME
mkdir -p "${CODEX_HOME}"

# Install/refresh all non-secret OMX surfaces: hooks, MCP config, prompts,
# native agents, skills, and AGENTS.md. Use legacy delivery explicitly because
# this mirrors the known-good environment where ~/.codex/skills and prompts are
# directly present. This intentionally does not include auth.json, logs,
# sessions, or other machine-local state.
omx setup --scope user --legacy --force

python3 - <<'PY'
import os
from pathlib import Path

config_path = Path(os.environ.get('CODEX_HOME', '/root/.codex')) / 'config.toml'
text = config_path.read_text() if config_path.exists() else ''

# Keep these settings aligned with the known-good interactive environment:
# - no Codex unstable-feature warning
# - OMX HUD/status line enabled
# - native agents/goals/hooks enabled
# - explore routing enabled for simple repo lookups
# - sane current-model defaults, without copying any credentials or state
TOP_LEVEL = {
    'model': '"gpt-5.5"',
    'model_reasoning_effort': '"medium"',
    'model_context_window': '250000',
    'model_auto_compact_token_limit': '200000',
    'service_tier': '"fast"',
    'suppress_unstable_features_warning': 'true',
}
TABLE_VALUES = {
    'agents': {
        'max_threads': '6',
        'max_depth': '2',
    },
    'features': {
        'hooks': 'true',
        'goals': 'true',
        'multi_agent': 'true',
        'child_agents_md': 'true',
    },
    'shell_environment_policy.set': {
        'USE_OMX_EXPLORE_CMD': '"1"',
    },
    'tui': {
        'status_line': '["model-with-reasoning", "git-branch", "context-remaining", "total-input-tokens", "total-output-tokens", "five-hour-limit", "weekly-limit"]',
    },
    'tui.model_availability_nux': {
        '"gpt-5.5"': '4',
    },
}

def split_lines(s: str) -> list[str]:
    return s.splitlines()

def table_header(line: str) -> str | None:
    stripped = line.strip()
    if stripped.startswith('[') and stripped.endswith(']') and not stripped.startswith('[['):
        return stripped[1:-1].strip()
    return None

def ensure_top_level(lines: list[str], key: str, value: str) -> None:
    first_table = next((i for i, line in enumerate(lines) if table_header(line) is not None), len(lines))
    prefix = f'{key} ='
    for i in range(first_table):
        if lines[i].lstrip().startswith(prefix):
            lines[i] = f'{key} = {value}'
            return
    insert_at = first_table
    while insert_at > 0 and lines[insert_at - 1].strip() == '':
        insert_at -= 1
    lines.insert(insert_at, f'{key} = {value}')

def find_table(lines: list[str], table: str) -> tuple[int, int] | None:
    start = None
    for i, line in enumerate(lines):
        if table_header(line) == table:
            start = i
            break
    if start is None:
        return None
    end = len(lines)
    for j in range(start + 1, len(lines)):
        if table_header(lines[j]) is not None:
            end = j
            break
    return start, end

def ensure_table_value(lines: list[str], table: str, key: str, value: str) -> None:
    found = find_table(lines, table)
    if found is None:
        if lines and lines[-1].strip() != '':
            lines.append('')
        lines.extend([f'[{table}]', f'{key} = {value}'])
        return
    start, end = found
    prefix = f'{key} ='
    for i in range(start + 1, end):
        if lines[i].lstrip().startswith(prefix):
            lines[i] = f'{key} = {value}'
            return
    lines.insert(end, f'{key} = {value}')

lines = split_lines(text)
if not lines:
    lines = ['# Codex / OMX non-secret defaults']

for key, value in TOP_LEVEL.items():
    ensure_top_level(lines, key, value)
for table, values in TABLE_VALUES.items():
    for key, value in values.items():
        ensure_table_value(lines, table, key, value)

config_path.write_text('\n'.join(lines).rstrip() + '\n')
PY

omx doctor
