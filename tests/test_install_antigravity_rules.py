# TASK-9: Antigravity 전역 규칙: 저장소별 담당 — 원본과 설치 스크립트(~/.gemini/config/rules/)
#
# 원본(agents/antigravity-repo-ownership.md)의 프론트매터 · 규칙 문구를 확인하고, 설치 스크립트를
# 가짜 HOME 에서 실행해 새로 설치 · 같음 · 다름 · --force · 다른 전역 규칙 파일 불변을 검사한다.
# 진짜 ~/.gemini 는 건드리지 않는다.
import os
import subprocess

import pytest

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOURCE = os.path.join(REPO, "agents", "antigravity-repo-ownership.md")
SCRIPT = os.path.join(REPO, "scripts", "install-antigravity-rules.sh")
README = os.path.join(REPO, "README.md")
DEST_REL = os.path.join(".gemini", "config", "rules", "coralstay-repo-ownership.md")
# Antigravity 의 파일당 규칙 크기 상한(공식 문서)
MAX_RULE_BYTES = 24 * 1024
# 담당 표가 복사됐는지 보는 표본: 각 담당의 저장소 이름
REPO_NAMES = (
    "coralstay-software-factory",
    "claude-code-agile-hooks",
    "source-header",
    "central-docs-collector",
    "omnivim",
    "handcrafted-python",
    "ebpf-wire-to-code-tracer",
    "toy-project",
)


def read(path):
    with open(path, encoding="utf-8") as f:
        return f.read()


def frontmatter(text):
    assert text.startswith("---\n")
    head, _, body = text[4:].partition("\n---\n")
    fields = dict(line.split(": ", 1) for line in head.splitlines() if ": " in line)
    return fields, body


def install(home, *args):
    return subprocess.run(
        ["sh", SCRIPT, *args],
        env={"HOME": str(home), "PATH": os.environ["PATH"]},
        capture_output=True,
        text=True,
    )


def dest(home):
    return home / DEST_REL


@pytest.fixture
def home(tmp_path):
    h = tmp_path / "home"
    h.mkdir()
    return h


# == AC/DoD ==


def test_source_is_an_always_on_rule():
    """TASK-9#1: Antigravity modular rules need YAML frontmatter with a trigger;
    this one applies to every session."""
    fields, body = frontmatter(read(SOURCE))
    assert fields["trigger"] == "always_on"
    assert fields.get("description")
    assert body.strip()
    assert len(read(SOURCE).encode("utf-8")) <= MAX_RULE_BYTES


def test_source_states_the_owner_rule():
    """TASK-9#1: look the owner up, only read and report on repos not owned by
    antigravity, ask when unknown, sign with the ai-antigravity key."""
    _, body = frontmatter(read(SOURCE))
    for phrase in (
        "`dev-toolchain workspace owner <경로>`",
        "`antigravity`",
        "편집 · 커밋하지 않",
        "읽기 · 보고만",
        "`unknown`",
        "유저에게 묻",
        "ai-antigravity",
    ):
        assert phrase in body, phrase


def test_source_points_at_the_command_not_the_table():
    """TASK-9#1 TASK-9#B1: no repository name from the owner table is copied -
    workspace/repos.tsv stays the single source."""
    _, body = frontmatter(read(SOURCE))
    for name in REPO_NAMES:
        assert name not in body, name
    assert "repos.tsv" in body


def test_fresh_install_creates_only_the_rule_file(home):
    """TASK-9#2 TASK-9#3: with no ~/.gemini the script creates the folders and
    the one rule file, identical to the source."""
    result = install(home)
    assert result.returncode == 0, result.stderr
    assert dest(home).read_text(encoding="utf-8") == read(SOURCE)
    assert sorted(os.listdir(dest(home).parent)) == ["coralstay-repo-ownership.md"]


def test_same_content_is_a_no_op(home):
    """TASK-9#2 TASK-9#3: a second run finds the same file and changes nothing."""
    assert install(home).returncode == 0
    mtime = dest(home).stat().st_mtime_ns
    result = install(home)
    assert result.returncode == 0
    assert "같" in result.stdout
    assert dest(home).stat().st_mtime_ns == mtime


def test_different_content_is_not_overwritten(home):
    """TASK-9#2 TASK-9#3 TASK-9#B2: an edited installed file is kept, the diff
    is shown and the script exits 1 pointing at --force."""
    dest(home).parent.mkdir(parents=True)
    dest(home).write_text("---\ntrigger: manual\n---\n내가 고친 규칙\n", encoding="utf-8")
    result = install(home)
    assert result.returncode == 1
    assert "내가 고친 규칙" in result.stdout
    assert "--force" in result.stdout + result.stderr
    assert dest(home).read_text(encoding="utf-8") == "---\ntrigger: manual\n---\n내가 고친 규칙\n"


def test_force_replaces_the_rule_file(home):
    """TASK-9#2 TASK-9#3: --force is the only way to replace a different file."""
    dest(home).parent.mkdir(parents=True)
    dest(home).write_text("old\n", encoding="utf-8")
    result = install(home, "--force")
    assert result.returncode == 0, result.stderr
    assert dest(home).read_text(encoding="utf-8") == read(SOURCE)


def test_other_global_rule_files_are_untouched(home):
    """TASK-9#2 TASK-9#3 TASK-9#B3: GEMINI.md, AGENTS.md and other rule files
    keep their content through install, no-op and --force."""
    gemini = home / ".gemini"
    rules = gemini / "config" / "rules"
    rules.mkdir(parents=True)
    others = {
        gemini / "GEMINI.md": "gemini\n",
        gemini / "AGENTS.md": "agents\n",
        rules / "mine.md": "---\ntrigger: manual\n---\nmine\n",
    }
    for path, text in others.items():
        path.write_text(text, encoding="utf-8")
    for args in ((), (), ("--force",)):
        assert install(home, *args).returncode == 0
    for path, text in others.items():
        assert path.read_text(encoding="utf-8") == text


def test_unknown_option_is_rejected(home):
    """TASK-9#2: anything but --force is a usage error and installs nothing."""
    result = install(home, "--forse")
    assert result.returncode == 2
    assert not dest(home).exists()


def test_readme_lists_the_source_and_the_script():
    """TASK-9#4: README's layout names agents/ and the install script (run by
    the user, never overwrites)."""
    readme = read(README)
    assert "`agents/`" in readme
    assert "install-antigravity-rules.sh" in readme
    assert "덮지 않" in readme


def test_notes_carry_the_check_outputs_and_manual_evidence():
    """TASK-9#D1 TASK-9#D2: the card notes hold the pytest and shellcheck
    results, and the manual install check carries a `- 증거:` line."""
    tasks = os.path.join(REPO, "backlog", "tasks")
    name = next(n for n in os.listdir(tasks) if n.startswith("task-9 - "))
    text = read(os.path.join(tasks, name))
    assert "passed" in text
    assert "shellcheck" in text
    assert "- 증거: TASK-9#D2" in text


# == Coverage ==


def test_frontmatter_splits_fields_and_body():
    fields, body = frontmatter("---\ntrigger: always_on\n---\nbody\n")
    assert fields == {"trigger": "always_on"}
    assert body == "body\n"
