# Models — AI routing reference

> Which AI model to use for which task in this repo. One page, one source.
> For commands + anti-patterns see `.agents/skills/model-routing/SKILL.md`
> at the repo root (this `docs/` site can't follow links outside its tree).

## TL;DR

| Rule | Why |
|---|---|
| Default in-session model: `MiniMax-M3` | Token Plan prepaid. Marginal cost 0 |
| Delegate a subtask to DeepSeek when it fits V4-Pro/Flash better | V4-Pro leads on multi-file refactor, code review, long agent loops |
| Never enable MoA fan-out | Burns quota every turn, no per-task control |
| Never use `delegate_task` with per-child `--provider`/`--model` | The kwarg does not exist — children inherit the global pair |
| Never use `deepseek-chat` or `deepseek-reasoner` | Retired 2026-07-24. API rejects |

## Inventory (verified this session)

```
Provider   Model                          Status   Cost shape
─────────  ─────────────────────────────  ───────  ──────────────
minimax    MiniMax-M3                     ✅  OK    Token Plan $0
minimax    MiniMax-M2.7                   ✅  OK    Token Plan $0
minimax    MiniMax-M2.7-highspeed         ✅  OK    Token Plan $0
deepseek   deepseek-v4-flash              ✅  OK    API  $0.14 / $0.28 per M
deepseek   deepseek-v4-pro                ✅  OK    API  $0.435 / $0.87 per M
deepseek   deepseek-v4-flash-vision-exp   ✅  OK    API  $0.14 / $0.28 per M
                                                        (images billed ≤384 tok)
```

Verified by one-shot inference from this session (`hermes -m X --provider Y -z 'di OK' --reasoning off`). Vision-Exp vision path not tested with real images.

## Per-task routing

| Task in this repo | Default | Delegate when | Delegate to |
|---|---|---|---|
| Read a Dart file, understand a widget | M3 | — | — |
| Patch a single file / rename / small refactor | M3 | — | — |
| Multi-file refactor across `lib/modules/<X>/` | M3 | >5 files | `deepseek-v4-pro` |
| PR code review | M3 | >500 LOC, security-sensitive | `deepseek-v4-pro` |
| Run `dart analyze lib/`, fix lints | M3 | — | — |
| Generate unit tests for a class | M3 | — | — |
| Hive schema migration plan | M3 | — | — |
| Reorder Hive fields | human-only | — | NEVER delegate |
| Debug crash from logcat | M3 | log >2 MB, multi-file trace | `deepseek-v4-flash` |
| Release notes / changelog | M3 | — | — |
| Summarize long issue thread | M3 | >50 KB input | `deepseek-v4-flash` |
| Translate UI strings | M3 | — | — |
| Generate `docs/features/<slug>.md` | M3 | >5 pages | `deepseek-v4-pro` |
| Classify bulk images (UI tests, logcat) | vision-exp | always when images present | `deepseek-v4-flash-vision-exp` |
| Read screenshot with small/dense text | vision-exp + tile | — | — |
| Research: web_search + summarize | M3 | — | — |
| Math/algorithmic reasoning | M3 | competition-level | `deepseek-v4-pro` |
| Long agent loop >20 tool calls | M3 | >40 tool calls | `deepseek-v4-pro` |

## Cost table (off-peak DeepSeek)

```
Model                         In $/M   Out $/M   5K-in/2K-out   50K-in/20K-out
────────────────────────────  ───────  ───────   ─────────────   ───────────────
MiniMax-M3 (Token Plan)         0        0         $0             $0
MiniMax-M2.7 (Token Plan)       0        0         $0             $0
deepseek-v4-flash               0.14     0.28      ~$0.0013       ~$0.013
deepseek-v4-flash-vision-exp    0.14     0.28      ~$0.0013       ~$0.013
deepseek-v4-pro                 0.435    0.87      ~$0.0039       ~$0.039
```

## Peak hours (DeepSeek)

```
Window (UTC)            Multiplier
─────────────────────   ──────────
00:00 – 00:59           1×
01:00 – 04:59           2×  peak
05:00 – 05:59           1×
06:00 – 10:59           2×  peak  ← European morning
11:00 – 23:59           1×
```

Budget heavy DeepSeek work for off-peak if cost matters.

## Cache discount (DeepSeek)

```
Model                  Cache hit input $/M   vs cache miss
─────────────────────  ────────────────────   ────────────
deepseek-v4-flash      $0.0028               50× cheaper
deepseek-v4-pro        $0.003625             ~120× cheaper
```

Hermes does not enable DeepSeek prompt cache automatically. For repeated calls with identical prefix (system prompt, schema), the second call onwards is essentially free on input.

## Strengths per model (vendor-reported unless noted)

| Model | Strong at | Weak at |
|---|---|---|
| MiniMax-M3 | SWE-bench Pro 59.0%, Terminal-Bench 2.1 66.0%, MCP Atlas 74.2%, 1M context, multimodal | Vendor-reported. Long agent loops need supervision (per user reports) |
| MiniMax-M2.7 | SWE-Pro 56.2%, Terminal-Bench 2 57.0%, ~2× faster than M3 | Same context window gap (205K vs 1M) |
| deepseek-v4-pro | SWE-bench Verified 80.6%, LiveCodeBench 93.5%, Terminal-Bench 2.0 67.9%, Codeforces 3206 | No multimodal. SimpleQA-Verified 57.9% (vs Gemini 75.6%) |
| deepseek-v4-flash | Within 1.6 pts of Pro on coding, $0.28/M out | Terminal-Bench 2.0 56.9%, SimpleQA-Verified 34.1% |
| deepseek-v4-flash-vision-exp | Multimodal agents "close to Opus 4.8" (vendor claim) | Experimental. 800×800 resize. Small text illegible without tiling |

## What NEVER to do

| Anti-pattern | Why |
|---|---|
| `moa.active_preset` non-empty | Fan-out fires every reference every turn |
| `--provider openrouter` | Not configured. 401s every call |
| `-m deepseek-chat` / `-m deepseek-reasoner` | Retired 2026-07-24 |
| `--reasoning on` on Flash/Pro when not needed | Reasoning output is paid tokens, often 5–10× more than the answer |
| Reorder `@HiveField(N)` via agent | Breaks user data. Human-only |
| `flutter build apk` inside a subtask | Long, side-effectful. Do in main session |

## Update cadence

```
When                                         Action
─────────────────────────────────────────    ─────────────────────────────
New model on MiniMax or DeepSeek             Re-run verification, update inventory
Provider pricing changes                     Update cost table, re-check sources
Benchmark contradicts routing rule           Swap row in per-task table, link source
Routing rule proves wrong in practice        Edit table, add reason in commit
```

## Verification checklist

```bash
# 1. Every model responds to a one-token probe
hermes -m MiniMax-M3 --provider minimax -z 'di OK' --reasoning off
hermes -m MiniMax-M2.7 --provider minimax -z 'di OK' --reasoning off
hermes -m MiniMax-M2.7-highspeed --provider minimax -z 'di OK' --reasoning off
hermes -m deepseek-v4-flash --provider deepseek -z 'di OK' --reasoning off
hermes -m deepseek-v4-pro --provider deepseek -z 'di OK' --reasoning off
hermes -m deepseek-v4-flash-vision-exp --provider deepseek -z 'di OK' --reasoning off

# 2. MoA still disabled
hermes config get moa.active_preset   # must be ""
```

## Sources (last checked 2026-08-31)

```
MiniMax Token Plan     platform.minimax.io/subscribe/token-plan
MiniMax pricing        platform.minimax.io/subscribe/token-plan?tab=api-enterprise
M3 benchmarks          benchlm.ai/models/minimax-m3
                       llmreference.com/model/minimax-m3
                       tech-insider.org/ca/minimax-m3-open-weight-llm-2026/
M2.7 vs M3             benchlm.ai/compare/minimax-m2-7-vs-minimax-m3
V4-Pro review          codersera.com/blog/deepseek-v4-pro-review-benchmarks-pricing-2026
                       buildfastwithai.com/blogs/deepseek-v4-pro-review-2026
V4-Flash review        codersera.com/blog/deepseek-v4-flash-deep-dive
                       buildfastwithai.com/blogs/deepseek-v4-flash-review-2026
V4-Flash-Vision-Exp    api-docs.deepseek.com/news/news260821/
                       kie.ai/blog/deepseek-v4-flash-vision-pricing
                       rohitraj.tech/en/notes/deepseek-v4-flash-vision-exp-api-guide-2026
DeepSeek pricing       api-docs.deepseek.com/quick_start/pricing/
Hermes skill           autonomous-ai-agents:hermes-provider-stack
```

## See also

- `.agents/skills/model-routing/SKILL.md` — commands + anti-patterns (load from session)
- `AGENTS.md` — router (load first)
- `docs/reference/codegen.md` — same pattern, different topic
