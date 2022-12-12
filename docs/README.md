# QuestLine API Documentation

## Static Members

### Properties

`QuestLine.timeout:number` [default=1]

Determines the transition time between one objective and the next; in seconds.

### Methods

```lua
QuestLine.new(questId:string, questData:{[string]:number})
```

Creates a new quest.

|Parameter|Type|Description
|:-|:-|:-
|*questId*|string| A unique identifier for the quest in the form of a string.
|*questData*|{any}| [optional] A table of custom properties for the quest.

```lua
QuestLine.getQuestById(questId)
```

Returns a quest associated with the given *questId*.

|Parameter|Type|Description
|:-|:-|:-
|*questId*|`string`| A unique identifier for the quest in the form of a string.

```lua
QuestLine.register(player:Player, playerData:{[string]:number})
```

Registers a player with the quest system and loads the player's progression data.

|Parameter|Type|Description
|:-|:-|:-
|*player*|`Player`| The player to add to the quest system.
|*playerData*|`{[string]:number}`| The player's progression table.

```lua
QuestLine.unregister(player:Player)
```

Unregisters the player from the quest system and returns the player's progression table.

|Parameter|Type|Description
|:-|:-|:-
|*player*|`Player`| The player to add to the quest system.
|||
|Returns|`{[string]:number}`| The player's progression table.


