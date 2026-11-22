# TASK-7: ~/.claude/CLAUDE.md 를 claude-config/ 에 기록으로 남기고 지운다
#
# claude-config/ 의 기록이 원본과 같고, README 가 상태 · 재적용 방법을 담는지 확인한다.
# 원본 백업(~/githubs-backup/...)은 이 머신에만 있으므로 내용 대조는 그 백업의 SHA-256 으로 고정한다.
# ~/.claude/CLAUDE.md 삭제 자체는 머신 상태라 [수동 검증]이고, 증거는 카드 Notes 에 있다.
import hashlib
import os
import re
import subprocess

import pytest

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RECORD = os.path.join(REPO, "claude-config", "CLAUDE.md-2026-11-21.md")
CONFIG_README = os.path.join(REPO, "claude-config", "README.md")
ROOT_README = os.path.join(REPO, "README.md")
TASK_FILE_GLOB = "task-7 - "
# ~/githubs-backup/2026-11-21-CLAUDE.md.bak 의 SHA-256 (2026-11-22 측정)
BACKUP_SHA256 = "0fd383d61db666e80d302826db7a4fc748da7eae5de8be80a52612ba9890c5e3"


def read(path):
    with open(path, encoding="utf-8") as f:
        return f.read()


def task_text():
    tasks = os.path.join(REPO, "backlog", "tasks")
    name = next(n for n in os.listdir(tasks) if n.startswith(TASK_FILE_GLOB))
    return read(os.path.join(tasks, name))


def git(*args):
    return subprocess.run(["git", "-C", REPO, *args], capture_output=True, text=True, check=True).stdout


# == AC/DoD ==


def test_record_is_byte_identical_to_the_backup():
    """TASK-7#1 TASK-7#B1: the record is the 2026-11-21 ~/.claude/CLAUDE.md as-is -
    no header comment, no path rewrite, nothing dropped."""
    with open(RECORD, "rb") as f:
        assert hashlib.sha256(f.read()).hexdigest() == BACKUP_SHA256


def test_record_keeps_all_three_sections():
    """TASK-7#1 TASK-7#B1: workflow block plus both user principles survive."""
    text = read(RECORD)
    for heading in ("## Backlog.md 워크플로", "## 서브에이전트 사용 원칙", "## 다이어그램 표기 원칙"):
        assert heading in text


def test_config_readme_states_not_applied_and_how_to_restore():
    """TASK-7#1 TASK-7#B3: README says the record is no longer applied, which
    section went where, and how to bring principles back."""
    text = read(CONFIG_README)
    assert "지금은 적용되지 않는다" in text
    assert "TASK-76" in text
    assert "다시 적용하려면" in text
    assert "~/.claude/CLAUDE.md" in text


def test_restore_command_range_matches_the_principle_sections():
    """TASK-7#1 TASK-7#B3: the documented sed range is exactly the two user
    principle sections, so restoring never brings back the workflow block."""
    lines = read(RECORD).splitlines()
    m = re.search(r"sed -n '(\d+),(\d+)p'", read(CONFIG_README))
    start, end = int(m.group(1)), int(m.group(2))
    assert lines[start - 1] == "## 서브에이전트 사용 원칙"
    assert end == len(lines)
    assert not any("CLAUDE-CODE-AGILE-HOOKS" in line for line in lines[start - 1 : end])


def test_record_was_committed_before_the_delete_evidence():
    """TASK-7#2 TASK-7#B2: [수동 검증] the deletion itself is machine state; here
    the record is in git history and the card holds the pre-delete comparison
    and the 'No such file' evidence."""
    assert git("log", "--format=%h", "--", "claude-config/CLAUDE.md-2026-11-21.md").strip()
    notes = task_text()
    assert "git cat-file -e HEAD" in notes
    assert "diff -q" in notes
    assert "No such file or directory" in notes


def test_root_readme_lists_claude_config():
    """TASK-7#3: the repo README's contents list has the new directory."""
    assert "`claude-config/`" in read(ROOT_README)


@pytest.mark.parametrize("needle", ["/Users/", "BEGIN OPENSSH", "PRIVATE KEY"])
def test_public_repo_record_has_no_personal_path_or_key(needle):
    """TASK-7#3: upkeep is public - the record and README carry no home path or key material."""
    assert needle not in read(RECORD) + read(CONFIG_README)


def test_notes_attach_the_diff_and_delete_evidence():
    """TASK-7#D1 TASK-7#D2: Notes carry the record-vs-backup comparison and the
    pre-delete check with the ls result."""
    notes = task_text()
    assert "cmp 바이트 동일" in notes
    assert "rm ~/.claude/CLAUDE.md" in notes


def test_pr_is_recorded_on_the_card():
    """TASK-7#D3: the card names the PR that carries this work."""
    assert re.search(r"PR #\d+|/pull/\d+", task_text())


# == Coverage ==
