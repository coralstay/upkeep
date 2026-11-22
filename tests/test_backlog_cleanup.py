# TASK-8: 미병합 브랜치 task/TASK-1(운영 카드 TASK-1~6·runbooks·draft 18장) 병합과 카드 상태 정리
#
# 정리 결과는 git 이력과 백로그 파일에 남는다. 두 브랜치 끝(task/TASK-1, origin/main)이 HEAD 의 조상이고,
# 양쪽 내용(운영 카드·runbooks·draft 와 TASK-7·claude-config)이 모두 있으며, 수동 검증 대기 카드는
# Done 으로 옮기지 않았는지 확인한다.
import glob
import os
import re
import subprocess

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TIPS = {
    "task/TASK-1": "6f535a75a4958d3b6b44d9a7de7f9971e6eaf77e",
    "origin/main": "e4fb72833591f05a0a6a583577fda9c1ac38f755",
}


def git(*args):
    return subprocess.run(["git", "-C", REPO, *args], capture_output=True, text=True, check=False)


def card(n, folder="backlog/tasks"):
    paths = glob.glob(os.path.join(REPO, folder, f"task-{n} - *.md"))
    assert len(paths) == 1, (n, paths)
    with open(paths[0], encoding="utf-8") as f:
        return f.read()


def status(text):
    return re.search(r"^status: (.+)$", text, re.MULTILINE).group(1).strip()


# == AC/DoD ==


def test_both_tips_are_merged():
    """TASK-8#1 TASK-8#B2: task/TASK-1 and origin/main were merged, not rebased - both tips are in HEAD's history."""
    for tip in TIPS.values():
        assert git("merge-base", "--is-ancestor", tip, "HEAD").returncode == 0


def test_both_sides_content_is_present():
    """TASK-8#1: ops cards TASK-1~6, runbooks and drafts from the branch, TASK-7 and claude-config/ from main."""
    for n in range(1, 8):
        card(n)
    assert os.path.isdir(os.path.join(REPO, "runbooks", "secretive-short-read"))
    assert os.path.isdir(os.path.join(REPO, "claude-config"))
    assert len(glob.glob(os.path.join(REPO, "backlog/drafts/draft-*.md"))) >= 17


def test_manual_verification_cards_keep_their_status():
    """TASK-8#2 TASK-8#B1 TASK-8#B3: TASK-2·3·4 wait for the Manual-Verified gate - none was moved to Done here."""
    for n in (2, 3, 4):
        assert status(card(n)) != "Done", n


def test_every_ops_card_has_a_classification_note():
    """TASK-8#2: each of TASK-1~6 carries a note from this cleanup."""
    for n in range(1, 7):
        assert "TASK-8" in card(n), n


def test_draft_and_task_ids_are_unique():
    """TASK-8#3: no duplicate DRAFT/TASK ids after the merge (the cleanup draft was made on the branch to avoid a clash)."""
    ids = []
    for path in glob.glob(os.path.join(REPO, "backlog/**/*.md"), recursive=True):
        with open(path, encoding="utf-8") as f:
            m = re.search(r"^id: (\S+)$", f.read(), re.MULTILINE)
        if m and "/archive/" not in path:
            ids.append(m.group(1).upper())
    assert len(ids) == len(set(ids)), sorted(i for i in ids if ids.count(i) > 1)


def test_notes_carry_table_outputs_and_pr():
    """TASK-8#D1 TASK-8#D2 TASK-8#D3: the card notes hold the table, the test output and the PR source branch."""
    text = card(8)
    assert "분류표" in text
    assert "passed" in text
    assert "PR" in text
    assert "task/TASK-8" in text


# == Coverage ==


def test_status_reads_frontmatter():
    assert status("---\nstatus: To Do\n---\n") == "To Do"
