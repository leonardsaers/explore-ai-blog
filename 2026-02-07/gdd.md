# Speldesigndokument: Karavan - Mästarnas Prövning

## 1. Översikt

**Koncept:** Ett kampanj-baserat arkadspel för Pico-8. Spelaren antar rollen som en utmanare i den legendariska "Mästarnas Prövning", en serie av fem allt svårare utmaningar för att kröna den ultimata Slime-Mästaren. Varje prövning testar en unik färdighet: snabbhet, strid, navigation, uthållighet och slutligen överlevnad mot överväldigande odds.

**Mål:** Att bli Slime-Mästare genom att klara alla fem prövningar.

**Genre:** Action, Snake-liknande

**Plattform:** Pico-8

## 2. Spelupplägg: Mästarnas Prövning

Spelet är uppdelat i fem nivåer, eller "prövningar". Spelaren måste klara en prövning för att låsa upp nästa.

### Prövning 1: Insamlingens Prövning
*   **Mål:** Bevisa din förmåga att växa. Samla 20 slimes inom 60 sekunder.
*   **Arena:** Ingen motståndare. Arenan ska ha kanvasbakgrund som har kordinat 0 0. Arenan har då en fyrkant uppritad som hinder. I fyrkanten på possition y=2 , x={5,6,7} ska en tidsräknare finnas som visar antalet sekunder som är kvar. 
*   **Utmaning:** Tiden är knapp. Spelaren måste strategiskt använda de sju hattarna för att öka sin hastighet och hinna samla alla slimes innan tiden rinner ut.

### Prövning 2: Rivalens Prövning
*   **Mål:** Bevisa din styrka i strid. Besegra en AI-motståndare i en klassisk duell.
*   **Arena:** En öppen arena med en AI-motståndare. Rita upp bakgrundskanvas från possition x=16, y=0. Enbart en slime ska spawnas åt gången, syftet är att det ska vara en tävling mellan deltagarna att få tag i den slime som spawnas. Det finns 7 unika hattar, så max 7 hattar kan spawnas. 
*   **Utmaning:** Den klassiska spel-loopen. Använd ditt växande tåg för att blockera och överlista din rival.

### Prövning 3: Navigeringens Prövning
*   **Mål:** Bevisa din precision. Samla 20 slimes inom 60 sekunder.
*   **Arena:** En arena fylld med statiska hinder. Arenan har då en fyrkant uppritad som hinder. I fyrkanten på possition y=2 , x={38,39,40} ska en tidsräknare finnas som visar antalet sekunder som är kvar.
*   **Utmaning:** Tiden är återigen en faktor, men nu måste spelaren navigera genom trånga passager. Att hantera ett långt tåg i en rörig miljö är nyckeln. Rita upp bakgrundskanvas från possition x=32, y=0.

### Prövning 4: Uthållighetens Prövning
*   **Mål:** Bevisa din anpassningsförmåga. Samla 25 följare och överlev i 90 sekunder.
*   **Arena:** En initialt öppen arena.
*   **Utmaning:** Arenan förändras ständigt. Med jämna mellanrum spawnar nya hinder på slumpmässiga platser, vilket gör utrymmet mindre och mindre. Detta testar spelarens förmåga att anpassa sig och överleva på en ständigt krympande yta. Ett hinder ska inte skapas precise framför, eller precis brevid ledarslimen. Rita upp bakgrundskanvas från possition x=0, y=0. I fyrkanten på possition y=2 , x={5,6,7} ska en tidsräknare finnas som visar antalet sekunder som är kvar.

### Prövning 5: Mästarnas Prövning
*   **Mål:** Segra över den tidigare mästaren. Du möter en AI, och den som först samlar 10 följare vinner.
*   **Arena:** En arena fylld med statiska hinder. Rita upp arenan från från possition x=0, y=16.
*   **Utmaning:** Den som först samlar på sig 10 följare vinner.

## 2.1 Game Flow & Presentation
Spelet inleds med en startskärm som utmanar spelaren. Inför varje prövning visas sedan en skärm med en kort, tematisk text som förklarar målet.

*   **Start Screen (Before Trial 1):** "The Trial of Masters awaits. Do you have what it takes to claim the title: SLIME MASTER?"
*   **Trial 1: The Trial of Gathering:** "A Master commands a grand train. Prove your speed. **Gather 20 followers before the sands run dry.**"
*   **Trial 2: The Trial of the Rival:** "Growth is nothing without strength. You are not alone on this path. **Defeat your rival in a duel.**"
*   **Trial 3: The Trial of Navigation:** "The path of a Master is not always clear. Finesse is key. **Navigate the maze and gather 20 followers.**"
*   **Trial 4: The Trial of Endurance:** "The world is ever-changing. A true Master adapts or perishes. **Endure the shifting arena for 90 seconds.**"
*   **Trial 5: The Trial of Masters:** "Your final challenge. Only the ultimate Master can bring order to chaos. **Survive the gauntlet. Be the last slime standing.**"

## 3. Kärnmekanik
(De underliggande systemen förblir desamma)

### 3.1 Rörelsemekanik: Spår-baserad Logik
Spelet använder ett **spår-baserat rörelsesystem** där varje tåg hanterar sin egen rörelsecykel **asynkront**, vilket tillåter olika hastigheter att fungera korrekt. Systemet använder en tvåfascykel (Viloläge och Animationsläge) och input-buffring för en responsiv spelkänsla.

### 3.2 AI Design: Prioriterad Girigbuk
AI-motståndarna styrs av en modell som utvärderar alla tillgängliga mål (slimes, hattar) och väljer det mest värdefulla baserat på avstånd och värde. Den prioriterar att bibehålla momentum och säkerhetskollar alla drag för att undvika enkla misstag.

### 3.3 Spelelement
*   **Tåg, Slimes, Hattar:** Fungerar som tidigare beskrivet (dynamisk hastighet baserat på antal hattar, risk att tappa hattar, etc.).
*   **Statiska Hinder:** Oförstörbara block (sprites 49 och 50) som fungerar som väggar.

## 4. Teknisk Implementation
*   **Game State Machine:** För att hantera de olika delarna av spelet (startskärm, de olika prövningarna, game over-skärmar) används en "Game State Machine". Detta är en variabel (`game_state`) som håller reda på vilket tillstånd spelet befinner sig i. Huvudfunktionerna `_update()` och `_draw()` agerar som växlar och anropar specifika funktioner beroende på det nuvarande tillståndet. De primära tillstånden är:
    *   `start_screen`: Visar startskärmen.
    *   `level_intro`: Visar den tematiska texten inför en prövning.
    *   `gameplay`: Själva spelandet av en prövning.
    *   `level_complete`: Visas när en prövning har klarats.
    *   `game_over_screen`: Visas när en prövning har misslyckats.
*   **Filstruktur:** Befintlig struktur med `karavan.lua`, `gamedata.lua`, `ai_controller.lua`, etc. är en bra grund.
*   **Dynamisk Nivå-laddning:** En funktion, `setup_level(level_num)`, kommer att ansvara för att konfigurera arenan korrekt för varje prövning (placera ut hinder, spawna rätt antal AI-motståndare, starta timers, etc.).
