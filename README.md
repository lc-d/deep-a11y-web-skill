---
name: deep-UI-web-skills
version: 0.2.0
---

# UI-web-skills

Benvenuti su `deep-UI-web-skills`! Una collezione di *[agent skill](https://agentskills.io/home)*, scritte con
lo scopo di migliorare la qualità del codice, in conformità agli standard più elevati (Core Web Vitals, WCAG 2.2, Best
Practices).

Le skill sono pensate per essere eseguite in ambiente di sviluppo testando pagine web locali. Prevedono sempre due
fasi: (1) La produzione di un report con elenco delle criticità e (2) l'eventuale correzione delle criticità
direttamente nel codice, dietro consenso dell'utente.

Le skill sono agnostiche sia rispetto al modello utilizzato che rispetto al linguaggio di programmazione e al framework
adottato.

*Nota:* Le skill sono scritte in lingua inglese per ridurre la quantità di token necessaria ed eventuali ambiguità
dovute alla traduzione (in italiano per es. il costo the token aumenta di ~1.2–1.5x).

## Come si usa

Puoi installare una o più skill copiando il loro contenuto dentro il progetto a cui stai lavorando.

1. Crea una nuova cartella alla radice del tuo progetto:
    - `.agents/skills` se usi Codex o Grok
    - `.github/skills` se usi CoPilot
    - `.claude/skills` se usi Claude
    - `.gemini/skills` se usi Gemini
2. Copia la cartella della skill nella cartella appena creata, es. `.agents/skills/a11y-page-audit/*.*`.
3. Lancia il tuo modello dentro il progetto e scrivi il prompt.

*Nota*: Aggiungi la cartella appena creata nel `.gitignore` se non vuoi che venga tracciata dal tuo repository.

### Skills

| Skill             | Scopo                                                                                                                                                                            | Prompt                                                                                                 | Note                                                                                  |
|-------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|
| **Accessibility** | Esegue test di accessibilità in locale – una pagina alla volta – usando Lighthouse, AXE-core e ispezione live del browser, secondo lo standard WCAG 2.2 e i pattern WAI-ARIA APG | `/a11y-page-audit <URL>`. Richiama la skill di accessibilità e indica l'url della pagina da analizzare | Per favorire l'ispezione del DOM, installa una *Browser Extensions* per il tuo agente |
| **Performance**   | 🚧 Work in progress                                                                                                                                                              | 🚧 Work in progress                                                                                    | 🚧 Work in progress                                                                   |

## Struttura del progetto

Ciascuna skill vive nella propria cartella alla radice del progetto. *Al momento esiste solo la skill di audit di
accessibilità (WCAG 2.2)*.

```
UI-web-skills/
├── a11y-page-audit/          # Web accessibility (WCAG 2.2) audit skill
│   ├── SKILL.md              # Entry point: workflow, tool routing, common fixes
│   ├── references/           # Reference material loaded on demand
│   │   ├── WCAG.md           # WCAG 2.2 success criteria quick reference
│   │   ├── A11Y-PATTERNS.md  # Accessible code patterns
│   │   ├── APG-PATTERNS.md   # WAI-ARIA APG patterns → components (mapping)
│   │   └── AXE-RULES.md      # axe-core/Lighthouse rule ID → WCAG (mapping)
│   └── scripts/              # Executable audit tooling
│       ├── audit.sh          # Orchestrator: single-page audit
│       ├── run-lighthouse.sh # Lighthouse accessibility audit wrapper
│       ├── run-axe.mjs       # axe-core runner (via puppeteer-core)
│       └── package.json      # Script dependencies (installed on first run)
├── performance/              # 🚧 WIP!
└── README.md
```

Ciascuna skill è auto consistente e ha al suo interno tutti gli script e le referenze necessarie:

- **`SKILL.md`** — La definizione della skill (frontmatter + istruzioni).
- **`references/`** — documenti di supporto utilizzati al momento del bisogno.
- **`scripts/`** — script eseguibili che la skill utilizza per il suo lavoro.
