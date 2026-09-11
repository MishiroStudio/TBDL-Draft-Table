# Pokémon Draft Board

Lokales Draft-Board für 4–8 Trainer mit 100 Draftpunkten pro Trainer.

Diese Version wurde aus der aktuellen Datei `draft-board-points.csv`
erstellt und enthält 339 Pokémon/Formen.

## Start

1. ZIP entpacken.
2. Deine vorhandenen Sprites in den Ordner `sprites` kopieren.
3. `index.html` doppelklicken.
4. Das Draft-Board läuft direkt lokal im Browser.

Kein Python, Flask, npm oder lokaler Server erforderlich.

## Funktionen

- Punktespalten 20 bis 1
- 4–8 Trainer
- 100 Punkte pro Trainer
- Drag-and-drop vom Board zu Trainern
- Verschieben zwischen Trainern
- Zurückziehen aufs Board
- automatische Budgetprüfung
- editierbare Trainernamen
- Pokémon-Suche
- automatische Speicherung im Browser
- kompletter Reset

## Sprites

Die Seite sucht die Bilddateien ausschließlich lokal im Ordner `sprites`.

Beispiel:
- `Gholdengo` → `sprites/gholdengo.png`
- `Mega Salamence` → `sprites/mega-salamence.png`
- alternativ auch `sprites/salamence-mega.png`

PNG und WebP werden unterstützt. Für Mega- und Regionalformen werden mehrere
übliche Dateinamen automatisch ausprobiert. Wenn ein Sprite nicht gefunden
wird, bleibt die Karte trotzdem voll funktionsfähig und zeigt `Sprite fehlt`.

## Dateien

- `index.html`
- `style.css`
- `script.js`
- `draft-board-points.csv` – deine aktuelle Punkteverteilung
- `sprites/` – hier deine Sprites einfügen


## Sprite-Aliase

Diese Version enthält zusätzliche Zuordnungen für Cordy’s-Lab-Dateinamen,
u. a. Indeedee-F/M, Maushold, Aegislash, Palafin, Mimikyu, die drei
Paldea-Tauros, Meowstic/Mega-Meowstic, Squawkabilly, Gourgeist, Pyroar
und Morpeko. Die Dateien können weiterhin unverändert aus Cordy’s Lab in
den Ordner `sprites` kopiert werden.

## Layout

Jede Punktestufe zeigt die Pokémon in zwei Spalten. Die Einträge werden zeilenweise von links nach rechts und anschließend von oben nach unten angeordnet.


## Trainerbereich

- Der Trainerbereich bleibt dauerhaft am unteren Fensterrand sichtbar.
- Die Pokémon jedes Trainers werden in zwei Spalten angeordnet.
- Bei vielen Picks scrollt nur die jeweilige Teamliste vertikal.
- Bei vielen Trainern kann der feste Trainerbereich horizontal gescrollt werden.
