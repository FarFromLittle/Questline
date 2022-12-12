# QuestLine API Documentation

## Static Members

### Properties

`QuestLine.timeout:number` [default=1]

Determines the transition time between one objective and the next; in seconds.

---

### Methods

```lua
QuestLine.new(questId:string, questData:{[string]:number}):QuestLine
```

Creates a new questline.  If *questData* is provided, it's metatable will be set to QuestLine and returned.

|Parameter|Type|Description
|:-|:-|:-
|*questId*|string| A unique identifier for the quest in the form of a string.
|*questData*|{any}| [optional] A table of custom properties for the quest.
|||
|Returns|`QuestLine`| Returns a new questline.

---

```lua
QuestLine.getQuestById(questId):QuestLine
```

Returns a quest associated with the given *questId*.

|Parameter|Type|Description
|:-|:-|:-
|*questId*|`string`| A unique identifier for the quest in the form of a string.
|||
|Returns|`QuestLine`| The quest identified by *questId*.

---

```lua
QuestLine.register(player:Player, playerData:{[string]:number})
```

Registers a player with the quest system and loads the player's progression data.

|Parameter|Type|Description
|:-|:-|:-
|*player*|`Player`| The player to add to the quest system.
|*playerData*|`{[string]:number}`| The player's progression table.

---

```lua
QuestLine.unregister(player:Player):{[string]:number}
```

Unregisters the player from the quest system and returns the player's progression table.

|Parameter|Type|Description
|:-|:-|:-
|*player*|`Player`| The player to add to the quest system.
|||
|Returns|`{[string]:number}`| The player's progression table.

|Returns|Description
|:-|:-
|`{[string]:number}`| The player's progression table.

---

```lua
QuestLine.Event(event, count)
```

Creates and returns an objective that waits for an event to be fired.  The first argument of the dispatched event must be a *Player* for it to be considered.

| Parameters | Type             | Default    | Description
| ---------: | :----------------| :--------: | :----------
|    *event* | `RBXScriptSignal`| *required* | The event to listen for.
|    *count* | `number`         | 1          | The number of times the *player* is expected to fire the event.

|     Returns | Description
| ----------: | :----------
| `Objective` | A *thread* used by the system to track progression.
|    `number` | The objective's value.

---

