---
name: model-routing
description: Pick the right AI model per task on this repo. Default MiniMax-M3 (Token Plan, marginal 0). Delegate subtasks to DeepSeek V4-Pro / V4-Flash / V4-Flash-Vision-Exp when justified. Never enable MoA fan-out. Use when picking a model, deciding to delegate, or auditing cost.
---

# Model Routing

Default in-session model is `MiniMax-M3`. Delegate a subtask to DeepSeek when the task fits the subtask model better and the cost is justified. MoA fan-out is **off** — never enable it.

Full per-task table, costs, sources, and benchmarks:
**[`docs/reference/models.md`](../../docs/reference/models.md)** — load this for the table.

This file is the executable cheat sheet. The doc is the reference.

## When to load

- Starting a session and picking the default model
- A subtask might be cheaper or better on a different model
- Auditing token spend / cost on a call
- A user asks "which model should I use for X"

Skip for trivial one-liner edits where M3 obviously fits.

## Rules (the whole skill in 6 lines)

1. **Default = `MiniMax-M3`.** Token Plan. Marginal cost 0. Use unless a rule below says delegate.
2. **Delegate when the per-task table says so.** See `docs/reference/models.md`.
3. **Never enable MoA fan-out.** `moa.active_preset` must stay `""`.
4. **Never use legacy DeepSeek aliases.** `deepseek-chat` / `deepseek-reasoner` are retired 2026-07-24.
5. **Cache repeats.** Reuse identical system prompts across calls — DeepSeek cache-hit input is 50× cheaper.
6. **Reasoning off unless you need it.** `--reasoning off` saves 5–10× output tokens on Flash/Pro.

## Patterns

### One-shot inference from any session (most common)

```bash
# M3 default — free
hermes -m MiniMax-M3 --provider minimax -z '<prompt>' --reasoning off

# Cheaper M3 alternative (Token Plan, different latency profile)
hermes -m MiniMax-M2.7 --provider minimax -z '<prompt>' --reasoning off
hermes -m MiniMax-M2.7-highspeed --provider minimax -z '<prompt>' --reasoning off

# DeepSeek cheap (~$0.0013 per 5K-in/2K-out call)
hermes -m deepseek-v4-flash --provider deepseek -z '<prompt>' --reasoning off

# DeepSeek strong (~$0.0039 per 5K-in/2K-out call)
hermes -m deepseek-v4-pro --provider deepseek -z '<prompt>' --reasoning off

# DeepSeek multimodal (image input required)
hermes -m deepseek-v4-flash-vision-exp --provider deepseek -z '<prompt>' --reasoning off
```

### Pipe input from a file

```bash
cat spec.md | hermes -m deepseek-v4-pro --provider deepseek -z -
```

### Long-running subtask in foreground

```bash
# Limit toolset to save tokens; load one skill
hermes -t file --skills todo-discipline -m MiniMax-M3 \
  --provider minimax -z '<subtask prompt>'
```

### Verify every model still works after a config change

```bash
for m in MiniMax-M3 MiniMax-M2.7 MiniMax-M2.7-highspeed \
         deepseek-v4-flash deepseek-v4-pro deepseek-v4-flash-vision-exp; do
  echo -n "$m: "
  case $m in
    MiniMax-*) p=minimax ;;
    *)         p=deepseek ;;
  esac
  hermes -m "$m" --provider "$p" -z 'di OK' --reasoning off
done

hermes config get moa.active_preset   # must be ""
```

## Anti-patterns

| Don't | Why |
|---|---|
| `moa.active_preset` non-empty | Fan-out every turn, no control |
| `delegate_task(... model=X)` | The kwarg does not exist. Use `terminal` + `hermes -m X` |
| `-m deepseek-chat` / `-m deepseek-reasoner` | Retired 2026-07-24. API rejects |
| `--provider openrouter` | Not configured. 401s |
| Reasoning on for short subtasks | 5–10× output tokens wasted |
| Reorder `@HiveField(N)` via agent | Breaks user data. Human-only |
| `flutter build apk` inside a subtask | Side-effectful, slow. Do in main session |

## Pitfalls

- **Provider slug is direct.** `minimax` and `deepseek` only. Not `openrouter/minimax` etc.
- **`hermes config set moa.active_preset ""`** is the only reliable way to fully disable MoA execution. `enabled: false` on the preset does not hide it from the picker.
- **Cache hits need an identical prefix.** If you change the system prompt between calls, you pay full input.
- **Vision-Exp caps images at 800×800.** Small text gets garbled. Tile before sending for dense text (legal pages, schematics, dense screenshots).
- **Peak hours double DeepSeek cost.** 01:00–04:00 and 06:00–10:00 UTC. From Europe, 06:00–10:00 hits the morning.
- **M3 SWE-bench Pro 59.0% is vendor-reported.** Treat as a manufacturer spec, not a referee's ruling.

## Verification

```bash
# After any config change
hermes config get moa.active_preset              # must be ""
hermes -m MiniMax-M3 --provider minimax -z 'di OK' --reasoning off
hermes -m deepseek-v4-flash --provider deepseek -z 'di OK' --reasoning off
```

## See also

- `docs/reference/models.md` — full table, costs, sources, benchmarks
- `AGENTS.md` — router (load first)
- `autonomous-ai-agents:hermes-provider-stack` — MoA + provider config deep-dive
