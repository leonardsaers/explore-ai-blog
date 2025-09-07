# Game Design Document: Chromatic Serpent

*Version: Final*

*Speltyp: Arkad, Action*

*Plattform: PICO-8*

## 1. Översikt & Vision
### Koncept

Chromatic Serpent är en modern tolkning av det klassiska spelet Snake. Spelaren styr en orm som ändrar färg och egenskaper baserat på de frukter den äter. Målet är inte bara att överleva, utan att strategiskt balansera risk och belöning för att uppnå högsta möjliga poäng.
Bakgrundshistoria

I en digital, neonfärgad värld lever en liten Kromatisk Orm. Denna varelse är unik då den saknar egen färg och livskraft. För att växa och bli starkare måste den konsumera magiska frukter som pulserar med energi. Varje frukt ger ormen näring och lånar ut sin färg och essens till dess ständigt växande kropp. Resan är en jakt på energi och överlevnad i en värld full av fällor – inte minst ormens egen, oförutsägbara svans.

## 2. Gameplay & Mekanik
### Mål

Att uppnå högsta möjliga poäng. Den slutgiltiga poängen beräknas genom att multiplicera totalt antal ätna frukter med antalet ätna hastighetsfrukter.
Kärnloop
```
    Spelaren styr ormens huvud för att äta en av flera frukter på skärmen.

    Att äta en frukt ger olika effekter: ormen växer, blir snabbare, eller får tillfälligt inverterade kontroller.

    För varje äten frukt dyker en ny upp på en slumpmässig plats.

    Spelet blir gradvis svårare då ormen blir längre och snabbare.

    Omgången avslutas om ormen krockar med en vägg eller sin egen kropp.

    Den slutgiltiga poängen visas, och spelaren kan starta om.
```

**Ormens Mekanik**

```
    Start: Ormen börjar som ett enda segment (ett huvud) utan svans.

    Rörelse: Rör sig automatiskt i ett rutnät. Spelaren kan byta riktning (men inte vända 180 grader).

    Tillväxt: När ormen äter en frukt växer den med ett segment. Det nya segmentet läggs till visuellt längst bak i svansen och antar samma färg/sprite som den frukt som just åts.
```

**Hastighetsmekanik**

    Accelererande ökning: Hastigheten ökar snabbare i början när spelaren äter hastighetsfrukter, och långsammare när man närmar sig maxhastigheten.

    Maxhastighet: Det finns en inbyggd maxhastighet som inte kan överskridas för att hålla spelet spelbart.

**Frukttyper**

Det finns alltid tre frukter på skärmen samtidigt.
```
    🍎 Röd (Livsfrukt): Den vanligaste frukten. Får ormen att växa med ett rött segment.

    🍇 Lila (Energifrukt): Ökar ormens hastighet. När maxhastigheten har uppnåtts slutar denna frukt att dyka upp, och sannolikheten för de andra frukterna justeras. Får ormen att växa med ett lila segment.

    🍊 Orange (Kaosfrukt): Inverterar spelarens kontroller (upp blir ner, vänster blir höger) i 5 sekunder. Får ormen att växa med ett orange segment.
```

**Poängsystem**

    Under spelets gång: Istället för en löpande poäng visas två värden:
```
        FRUITS: Totalt antal ätna frukter.

        SPEED FRUITS: Antal ätna lila (hastighets-) frukter.

    Slutgiltig poäng: Visas endast på "Game Over"-skärmen och beräknas enligt formeln:
    TOTAL SCORE = (FRUITS) x (SPEED FRUITS)
```
## 3. Användargränssnitt (UI) & Användarupplevelse (UX)
### Spelskärmar
```
    Startskärm: Visar spelets titel och instruktioner på en svart bakgrund, omgiven av en animerad orm. En blinkande text ("PRESS X TO START") uppmanar spelaren att starta.

    Spelskärm (HUD): Visar antalet ätna frukter och antal ätna "speed frukter" i skärmens överkant.

    Game Over-skärm: Spelet pausas och den totala poängen med dess beräkningsformel visas på en svart bakgrund. En blinkande text ("PRESS X TO RESTART") uppmanar spelaren att starta om.
```

**Feedback**

    Visuell feedback:
```
        Ormens svans får färg efter den frukt som åts.

        När "Kaosfrukten" är aktiv, ändras hela skärmens bakgrundsfärg till orange.

        En kort skärmskakning sker vid "Game Over".

        En partikeleffekt visas när en frukt äts.
```
    Ljudfeedback:
```
        En positiv ljudeffekt spelas när en frukt äts.

        En negativ ljudeffekt spelas vid "Game Over".
```
## 4. Grafik & Ljud
### Grafisk Stil

Minimalistisk och tydlig 8x8 pixelgrafik som passar PICO-8:s estetik. Fokus ligger på starka, klara färger för att skilja på de olika frukterna och ormens segment.
Sprites
```
    Sprite 1: Röd frukt

    Sprite 2: Lila frukt

    Sprite 3: Orange frukt

    Sprite 4: Ormens huvud
```
**Ljud**

    Ljudeffekter (SFX): Korta, distinkta ljud för viktiga händelser (äta frukt, game over) för att förstärka spelarens handlingar.

    Musik: (Valfritt) En enkel, loopande melodi kan läggas till för att skapa stämning.
