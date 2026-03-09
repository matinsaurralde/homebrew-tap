# homebrew-tap

Homebrew formulae for [mem](https://github.com/matinsaurralde/mem) — a privacy-first CLI that turns shell history into searchable memory.

## Install

```bash
brew tap matinsaurralde/tap
brew install mem
```

## After install

Add the shell hook to your `~/.zshrc`:

```bash
eval "$(mem init zsh)"
```

Then reload:

```bash
source ~/.zshrc
```
