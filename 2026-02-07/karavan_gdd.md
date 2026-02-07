# Design-dokument: Pico-8 Karaktärs- och Animationsmotor

## 1. Översikt

**Projekttitel:** Pico-8 Karaktärsmotor

**Koncept:** En återanvändbar grund för Pico-8-spel som fokuserar på en robust och flexibel hantering av spelentiteter ("Creatures"). Motorn tillhandahåller kärnfunktionalitet för rörelse, animation och visuell anpassning med hjälp av lager-baserade sprites.

**Mål:** Att skapa en datadriven grundstruktur där utvecklare enkelt kan skapa nya karaktärer, animationer och beteenden genom att modifiera datafiler istället för att skriva om kärnlogiken.

**Plattform:** Pico-8

**Språk:** LUA

## 2. Kärnkomponenter

### 2.1 Creature-objektet

Den centrala komponenten i motorn. Alla dynamiska entiteter i ett spel (spelare, fiender, NPCs) ska vara instanser av ett generellt `Creature`-objekt. Detta skapar ett enhetligt sätt att hantera deras tillstånd och logik.

**Kärnegenskaper:**
- **Position och Rörelse:** Hanterar `x`, `y`, `speed` och `dir` (riktning).
- **State:** Håller reda på karaktärens nuvarande tillstånd (t.ex. "idle", "walk", "attack").
- **Animatorer:** En eller flera animator-komponenter som hanterar visuell representation.

### 2.2 Datadrivet Animationssystem med Bibliotek

Systemet är helt datadrivet. Istället för att definiera varje karaktär som en monolitisk enhet, bygger systemet på ett **bibliotek av utbytbara delar**.

- **`gamedata.anim_defs.libraries`**: Detta är den centrala databasen för alla visuella komponenter. Den är organiserad i kategorier (`body`, `head`, `hair`, etc.), där varje kategori innehåller en lista med olika varianter.

**Exempel på biblioteksstruktur:**
```lua
gamedata.anim_defs = {
    libraries = {
        head = {
            [1] = { idle = { frames = {128,129}, speed = 80 }, ... }, -- Huvudtyp 1
            [2] = { idle = { frames = {130,131}, speed = 80 }, ... }  -- Huvudtyp 2
        },
        hair = {
            [1] = { idle = { frames = {144,145}, speed = 80 }, ... }, -- Hårtyp 1
            [2] = { idle = { frames = {146,147}, speed = 80 }, ... }  -- Hårtyp 2
        }
    }
}
```

- **Sammansatta Animationer:** Färdiga karaktärsdefinitioner (som en standard `human_base`) skapas genom att **kombinera** delar från dessa bibliotek. Detta gör det möjligt att definiera en karaktärs utseende genom en enkel referenslista.

### 2.3 Lager-baserade Sprites (Layered Sprites)

För att möjliggöra hög grad av visuell anpassning ritas en varelse ut i flera lager. Detta gör att man kan kombinera olika kroppsdelar för att skapa unika utseenden utan att behöva skapa en helt ny sprite för varje kombination.

**Renderingsordning:**
Renderingsordningen är strikt för att säkerställa korrekt visuellt resultat och styrs av en `draw_config` i varje varelses mall. Denna konfiguration definierar också x/y-offset för varje lager.
1.  **Body:** Kroppen.
2.  **Head:** Huvudets basform.
3.  **Face:** Ansiktsdrag.
4.  **Hair:** Hår/frisyr.
5.  **Arms:** Armar, som kan ritas över eller under kroppen beroende på design.

### 2.4 Karaktärsgenerator

För att dra full nytta av animationsbiblioteket finns en generator-funktion som dynamiskt skapar helt nya karaktärsmallar.

- **Funktion:** `generate_character(name, parts)`
- **Syfte:** Att programmatiskt skapa en unik karaktärsmall genom att kombinera delar från biblioteken.
- **Parametrar:**
    - `name`: En unik sträng som blir namnet på den nya mallen (t.ex. `"hero"` eller `"random_char_5"`).
    - `parts`: En tabell som specificerar vilket index från varje bibliotek som ska användas. Exempel: `{ head=2, hair=1, body=1 }`.
- **Output:** Funktionen skapar och registrerar en ny `anim_def` och en `creature_template` i `gamedata`, redo att användas för att skapa nya `Creature`-instanser.

#### 2.4.1 Procedurell Variation (Brus)

För att göra genererade karaktärer mer levande, applicerar generatorn ett slumpmässigt **"brus" (noise)**.
- **Mekanism:** För varje ny karaktär som genereras, skapas ett slumpmässigt värde (t.ex. mellan -10 och +20).
- **Effekt:** Detta värde adderas till `speed`-parametern på alla karaktärens `idle`-animationer. Detta resulterar i att olika karaktärer blinkar eller rör sig subtilt i olika hastigheter, vilket ger en mer organisk och mindre repetitiv känsla.

## 3. Rörelse och Världsinteraktion

### 3.1 Tile-baserad Rörelse

Motorn använder ett **tile-baserat rörelsesystem** för att säkerställa exakt och förutsägbar positionering. Alla spelentiteter ("Creatures") existerar på ett logiskt rutnät (grid) där varje ruta är 8x8 pixlar.

- **Logisk vs. Visuell Position:**
  - En varelses **logiska position** (`tile_x`, `tile_y`) representerar vilken ruta den står på.
  - En varelses **visuella position** (`x`, `y`) representerar var den ritas på skärmen.
- **Rörelsemekanik:**
  - När en varelse initierar en rörelse från en tile till en annan, låses den i ett `is_moving`-tillstånd.
  - Under detta tillstånd animeras den visuella positionen mjukt från start-tilen till mål-tilen under en fördefinierad tid (`move_duration`).
  - Ny input för rörelse ignoreras tills den nuvarande rörelsen är helt avslutad och varelsen har "landat" på sin nya tile.
- **`move_duration`:** En datadriven parameter i `creature_templates` som specificerar hur många frames (uppdateringar) en förflyttning på 8 pixlar ska ta. Detta gör det enkelt att justera hastigheten för olika typer av varelser.

### 3.2 Animationstillstånd vid Rörelse

För att undvika att gånganimationen "hackar" mellan varje tile är ansvaret för `idle`-tillståndet frikopplat från själva rörelsemotorn.
-   **Avslutad rörelse:** När en varelse landar på en ny tile, avslutas dess rörelse (`is_moving` blir `false`), men dess animationstillstånd förblir `walk`.
-   **Idle-tillstånd:** En varelse övergår till `idle`-tillståndet först när den står stilla **och** ingen ny rörelse-input ges. Detta säkerställer en mjuk och kontinuerlig gånganimation när spelaren håller en tangent nedtryckt.

### 3.3 Kollisionshantering

Kollisionshanteringen är anpassad för tile-systemet. `world:is_passable(x, y)`-funktionen kontrollerar om en **mål-tile** är framkomlig innan en rörelse initieras.
-   Funktionen tar emot pixel-koordinater som internt räknas om till tile-koordinater.
-   Kontrollen sker mot:
    1.  **Världens gränser:** För att förhindra att varelser går utanför kartan.
    2.  **Terräng:** Baserat på flaggor i kartans tile-data.

## 4. Teknisk Design och Filstruktur

### 4.1 Filstruktur

Koden är uppdelad för att separera logik från data, vilket underlättar underhåll och expansion.
- **`main.lua`**: Huvudfilen som initierar motorn och innehåller spellogiken (t.ex. `_init`, `_update`, `_draw`). För denna motor kommer den agera som ett exempel på hur komponenterna används.
- **`creature.lua`**: Innehåller `Creature`-klassen och all logik för varelser, inklusive rörelse, tillståndshantering och animation.
- **`gamedata.lua`**: En central databas med Lua-tabeller för all konfigurationsdata, såsom `anim_defs`, mallar för varelser, terrängdefinitioner etc.

### 4.2 Data-driven Design

Principen är att så mycket som möjligt av motorns beteende och innehåll ska definieras i `gamedata.lua`. Detta inkluderar:
- **`creature_templates`**: En tabell med grundmallar för olika typer av varelser, som specificerar deras standardhälsa, hastighet, `anim_ref`, etc.
- **`anim_defs`**: Animationer för alla varelser och deras komponenter.



