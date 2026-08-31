---
title: dashboarrcheky — LunaSea fork
description: Self-hosted media controller. Flutter. Caveman docs. AI-friendly.
hide:
  - navigation
  - toc
---

<a href="https://github.com/carcheky/dashboarrcheky" class="home-github" aria-label="Fork me on GitHub">
  <svg width="80" height="80" viewBox="0 0 250 250" style="fill:#06b6d4; color:#fff; border:0;" aria-hidden="true">
    <path d="M0,0 L115,115 L130,115 L142,142 L250,250 L250,0 Z"></path>
    <path d="M128.3,109.0 C113.8,99.7 119.0,89.6 119.0,89.6 C122.0,82.7 120.5,78.6 120.5,78.6 C119.2,72.0 123.4,76.3 123.4,76.3 C127.3,80.9 125.5,87.3 125.5,87.3 C122.9,97.6 130.6,101.9 134.4,103.2" fill="currentColor" style="transform-origin: 130px 106px;" class="octo-arm"></path>
    <path d="M115.0,115.0 C114.9,115.1 118.7,116.5 119.8,115.4 L133.7,101.6 C136.9,99.2 139.9,98.4 142.2,98.6 C133.8,88.0 127.5,74.4 143.8,58.0 C148.5,53.4 154.0,51.2 159.7,51.0 C160.3,49.4 163.2,43.6 171.4,40.1 C171.4,40.1 176.1,42.5 178.8,56.2 C183.1,58.6 187.2,61.8 190.9,65.4 C194.5,69.0 197.7,73.2 200.1,77.6 C213.8,80.2 216.3,84.9 216.3,84.9 C212.7,93.1 206.9,96.0 205.4,96.6 C205.1,102.4 203.0,107.8 198.3,112.5 C181.9,128.9 168.3,122.5 157.7,114.1 C157.9,116.9 156.7,120.9 152.7,124.9 L141.0,136.5 C139.8,137.7 141.6,141.9 141.8,141.8 Z" fill="currentColor" class="octo-body"></path>
  </svg>
</a>

<div class="home-hero">
  <h1>dashboarrcheky</h1>
  <p class="home-tagline">
    Self-hosted media controller. One Flutter app to rule Sonarr, Radarr, Lidarr, SABnzbd, NZBGet, Tautulli.
    <br>
    Docs that humans and AI agents both read — caveman-mode, llms.txt-ready, token-efficient.
  </p>
  <div class="home-cta">
    <a class="primary" href="build/">Get started →</a>
    <a class="secondary" href="https://github.com/carcheky/dashboarrcheky">View on GitHub</a>
    <a class="secondary" href="llms.txt">llms.txt</a>
    <a class="secondary" href="llms-full.txt">llms-full.txt</a>
  </div>

  <div class="stat-row">
    <div class="stat"><span class="num">6</span><span class="lbl">services</span></div>
    <div class="stat"><span class="num">9</span><span class="lbl">modules</span></div>
    <div class="stat"><span class="num">11.0</span><span class="lbl">version</span></div>
    <div class="stat"><span class="num">100%</span><span class="lbl">caveman</span></div>
  </div>
</div>

## What's inside

<div class="feature-grid">
  <a class="feature-card" href="modules/">
    <div class="icon">M</div>
    <h3>Modules</h3>
    <p>Sonarr, Radarr, Lidarr, SABnzbd, NZBGet, Tautulli, Search, Settings, Dashboard.</p>
  </a>
  <a class="feature-card" href="api/">
    <div class="icon">A</div>
    <h3>API & Data</h3>
    <p>Dio + Retrofit for HTTP. Hive for local. go_router for nav.</p>
  </a>
  <a class="feature-card" href="build/">
    <div class="icon">B</div>
    <h3>Build & Install</h3>
    <p>Docker build → APK → adb-wifi install to your phone.</p>
  </a>
  <a class="feature-card" href="workflow/">
    <div class="icon">W</div>
    <h3>Workflow</h3>
    <p>master + beta + feature/*. SemVer tags. Conventional Commits.</p>
  </a>
  <a class="feature-card" href="conventions/">
    <div class="icon">C</div>
    <h3>Conventions</h3>
    <p>Luna-prefixed classes. Hive fields at end. No codegen skip.</p>
  </a>
  <a class="feature-card" href="troubleshooting/">
    <div class="icon">?</div>
    <h3>Troubleshooting</h3>
    <p>Symptom → fix. Build, adb-wifi, Hive, go_router, APIs.</p>
  </a>
  <a class="feature-card" href="reference/models/">
    <div class="icon">M</div>
    <h3>AI Model Routing</h3>
    <p>Pick MiniMax-M3, V4-Flash, V4-Pro per task. Cost + benchmarks.</p>
  </a>
  <a class="feature-card" href="features/TEMPLATE/">
    <div class="icon">F</div>
    <h3>New feature</h3>
    <p>Template + sub-agent. Code, tests, doc, same PR.</p>
  </a>
  <a class="feature-card" href="fixes/TEMPLATE/">
    <div class="icon">X</div>
    <h3>Bug fix</h3>
    <p>Template + sub-agent. Repro, root cause, fix, regression test.</p>
  </a>
  <a class="feature-card" href="adr/">
    <div class="icon">!</div>
    <h3>Decisions (ADR)</h3>
    <p>Why we picked Docker build. Why master + beta. Why this doc system.</p>
  </a>
</div>

## Status

- **Version:** 11.0.0+1 (baseline from upstream)
- **Active branch:** `beta`
- **Build system:** Docker
- **Stack:** Dart 3.7+ / Flutter 3.27+ / Android minSdk 24

## For AI agents

This site is dual-mode. Humans browse the UI. Agents read the files directly:

- `AGENTS.md` at repo root = router (load only what matches your task)
- `/llms.txt` = sectioned index for crawlers
- `/llms-full.txt` = full corpus in one fetch
- `docs/features/<slug>.md` = one per shipped feature
- `docs/fixes/<slug>.md` = one per shipped fix
- `.agents/sessions/<date>-<slug>.md` = session handoffs (latest first)
- `.agents/skills/<slug>/SKILL.md` = procedural skills (cross-tool)
