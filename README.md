# Swift 2026 — Tome 1 : Maîtriser le langage

Ebook éducatif pour apprendre **Swift** de zéro jusqu'à un niveau avancé/expert — **sans SwiftUI, sans iOS, sans frameworks Apple**. Premier tome d'une collection en 3 parties construite autour d'une application fil rouge :

1. **Tome 1 (ce repo)** — Le langage Swift
2. **Tome 2** — SwiftUI : l'interface du fil rouge
3. **Tome 3** — Le backend : Vapor / Supabase

## Structure du repo

```
book/               Sources Markdown du livre + pipeline de génération PDF
  parts/            Un fichier par section (couverture, TOC, chapitres...)
  style.css         Mise en page du PDF (pandoc + weasyprint)
  build.sh          Génère Swift-2026-Tome1.pdf à partir de parts/*.md
projects/            Les 8 projets du livre (Swift Package Manager), code complet et testé
```

## Générer le PDF

```bash
cd book
./build.sh
```

Nécessite `pandoc` et `weasyprint` (`brew install pandoc weasyprint`).

## Projets du livre

| # | Projet | Chapitres associés |
|---|--------|---------------------|
| 1 | 🎯 Jeu de devinettes | Fondamentaux, boucles, conditions |
| 2 | 🧮 Calculatrice | Collections |
| 3 | ✅ Todo CLI | Optionnels |
| 4 | 💰 Expense Tracker | Structs / Enums / Classes |
| 5 | 🌐 API Client | Protocoles, generics |
| 6 | 📦 Swift Package | Swift avancé |
| 7 | ⚡ Concurrent Data Engine | Concurrence moderne |
| 8 | 🚀 Swift Task Manager (projet final) | Tout le livre |

## Statut

✅ Tome 1 complet — 20 parties, 70 chapitres, 8 projets, 4 annexes (215 pages). Voir [book/TABLE_DES_MATIERES.md](book/TABLE_DES_MATIERES.md) pour le plan détaillé.

Chaque exemple de code du livre a été compilé et exécuté avant intégration, et chaque projet a été testé manuellement sur ses cas limites (persistance, entrées invalides, fin d'entrée standard, vraies requêtes réseau).
