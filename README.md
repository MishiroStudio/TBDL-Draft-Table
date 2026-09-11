# Pokémon Draft Board – GitHub Pages + Live Draft

Diese Version kann weiterhin lokal benutzt werden und zusätzlich gemeinsame Live-Drafts über Supabase durchführen.

## Funktionen

- 4–8 Trainer
- 100 Punkte pro Trainer
- maximal 10 Picks pro Trainer
- Draft-Board mit 2 Pokémon-Spalten pro Punktestufe
- Teamlisten mit 2 Spalten
- Trainerbereich dauerhaft unten sichtbar
- lokale Sprites
- lokaler Einzelspieler-Modus
- gemeinsamer Raum mit 6-stelligem Code
- Live-Synchronisierung aller Picks
- Trainer-Namen werden live synchronisiert
- Host kann den gesamten Online-Draft zurücksetzen
- Raum-Link kann direkt kopiert und geteilt werden

## 1. Supabase-Projekt erstellen

1. Auf Supabase ein neues Projekt erstellen.
2. Im Supabase-Dashboard den **SQL Editor** öffnen.
3. Den kompletten Inhalt von `supabase_setup.sql` ausführen.
4. Unter **Authentication → Providers / Sign In** die **Anonymous Sign-Ins** aktivieren.
5. In den Projekteinstellungen die **Project URL** und den **Publishable Key** kopieren.

Wichtig: Nur den Publishable/Public Key verwenden. Niemals den `service_role` Key in die Website eintragen.

## 2. config.js ausfüllen

`config.js`:

```js
window.DRAFT_CONFIG = {
  supabaseUrl: "https://DEIN-PROJEKT.supabase.co",
  supabasePublishableKey: "DEIN_PUBLISHABLE_KEY"
};
```

## 3. Sprites

Deine Cordy's-Lab-Sprites in den Ordner `sprites/` kopieren.

Für GitHub Pages müssen diese Sprite-Dateien mit ins Repository hochgeladen werden.

## 4. GitHub Pages

Repository-Struktur:

```text
index.html
style.css
script.js
config.js
draft-board-points.csv
supabase_setup.sql
sprites/
README.md
```

Dann:

1. GitHub Repository öffnen.
2. `Settings → Pages`.
3. `Deploy from a branch`.
4. Branch `main`.
5. Ordner `/ (root)`.
6. Speichern.

Danach ist die Seite normalerweise unter

`https://DEINNAME.github.io/REPOSITORY-NAME/`

erreichbar.

## Gemeinsamen Draft starten

1. Auf `Online-Draft` klicken.
2. 4–8 Trainer wählen.
3. `Raum erstellen`.
4. Den angezeigten Link kopieren und an die anderen schicken.
5. Andere öffnen den Link oder geben den Raumcode ein.
6. Alle sehen Picks und Änderungen live.

Der Host ist der Browser, in dem der Raum erstellt wurde. Die anonyme Supabase-Sitzung wird im Browser gespeichert. Wenn der Host seine Browserdaten löscht, verliert dieser Browser seine Host-Identität für bereits erstellte Räume.

## Sicherheit

- Der geheime Supabase-Service-Key wird nicht verwendet.
- Besucher melden sich automatisch als anonyme Supabase-Benutzer an.
- Die Datenbank verwendet Row Level Security.
- Nur Mitglieder eines Raums können dessen Picks sehen oder ändern.
- Nur der Host kann die Funktion `Draft zurücksetzen` ausführen.
- Die Datenbank erzwingt 100 Punkte und maximal 10 Picks pro Trainer.

Der normale Drag-and-drop-Betrieb ist absichtlich kollaborativ: jedes Mitglied des Raums kann Picks hinzufügen, verschieben oder einzeln entfernen.
