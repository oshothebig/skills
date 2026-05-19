set shell := ["bash", "-uc"]
std-skill-dir := "~/.agents/skills"
claude-skill-dir := "~/.claude/skills"

default:
    just --list

install: install-std install-claude

install-std:
    mkdir -p {{ std-skill-dir }}
    stow -v --no-folding --dir {{ justfile_directory() }} --target {{ std-skill-dir }} skills

install-claude:
    mkdir -p {{ claude-skill-dir }}
    stow -v --no-folding --dir {{ justfile_directory() }} --target {{ claude-skill-dir }} skills

uninstall: uninstall-std uninstall-claude

uninstall-std:
    stow -v --no-folding --delete --dir {{ justfile_directory() }} --target {{ std-skill-dir }} skills

uninstall-claude:
    stow -v --no-folding --delete --dir {{ justfile_directory() }} --target {{ claude-skill-dir }} skills

check: check-std check-claude

check-std:
    stow -v --no-folding --simulate --dir {{ justfile_directory() }} --target {{ std-skill-dir }} skills

check-claude:
    stow -v --no-folding --simulate --dir {{ justfile_directory() }} --target {{ claude-skill-dir }} skills

format:
    just --fmt
