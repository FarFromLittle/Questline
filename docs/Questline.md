# Questline

Questline is a server-sided module script that aids in the creation and tracking of quests wtihin your game.  It offers a framework to create customized questlines that are event-driven and easily maintained.

This module is intended for advanced developers, and requires a good understanding of lua scripting.

## Summary

### Static Properties

[`Objective`](#objective) `:` `{[string]:Objective}`

Object containing the different objective types.

### Static Methods

[`getQuestById`](#getquestbyid) ( `questId` `:` `string` ) `:` `Questline`

Returns the quest found with the supplied id.

[`register`](#register) ( `player` `:` `Player`, `playerData` `:` `{[string]:number}` ) `:` `nil`

Prepares player to receive questlines.  Loads player data from previous session.

[`unregister`](#unregister) ( `player` `:` `Player` ) `:` `nil`

Removes the player from the system, disconnecting any lingering questlines.

[`new`](#new) ( `questId` `:` `string` ) `:` `Questline`

Creates a new questline.  Requires unique string to identify questline.

### Class Methods

[`AddObjective`](#addobjective) ( `obj` `:` `Objective` ) `:` `nil`

Adds an objective to the questline.

[`Assign`](#assign) ( `player` `:` `Player` ) `:` `nil`

Connects the player to current objective.

[`Cancel`](#cancel) ( `player` `:` `Player` ) `:` `nil`

Cancels/fails the current objective for the player.

[`Complete`](#complete) ( `player` `:` `Player` ) `:` `nil`

Immediately completes the current objective for the player.

[`Disconnect`](#disconnect) ( `player` `:` `Player` ) `:` `nil`

Disconnects the player from the objective.

[`IsConnected`](#isconnected) ( `player` `:` `Player` ) `:` `boolean`

Returns a boolean value indicating if the player is connected to the objective.

### Event Handlers

[`OnAssign`](#onassign) ( `player` `:` `Player` ) `:` `nil`

Callback handler that fires when a player is assigned this objective.

[`OnCancel`](#oncancel) ( `player` `:` `Player` ) `:` `nil`

Callback handler that fires when an objective is canceled/failed.

[`OnComplete`](#oncomplete) ( `player` `:` `Player` ) `:` `nil`

Callback handler that fires when a player has completed the objective.

## Static Properties

### Objective

`{[string]:Objective}`

Property of `Questline` containing the different objective types.

## Static Methods

### getQuestById

Returns the questline represented by the supplied _questId_.

|param|type|-
|-:|:-:|:-
|_questId_|`string`|Unique identifier of the questline within the system.

|return|-
|-:|:-
|`Questline`|The questline matching the given _questId_.

```lua
local myQuest = Questline.getQuestById("myQuestId")
```

### register

`[Yields]`

Prepares the player to start receiving questlines.  Adding the necessary data to track player progression.

This function also attempts to load player progression from a datastore.  It will then assign any previously incomplete questlines.

|param|type|-
|-:|:-:|:-
|_player_|`Player`|Player to register with the system.
|_playerData_|`{[string]:number}`|Table containing the player's quest data, including progression and playerstats.

```lua
game.Players.PlayerAdded:Connect(function (player)
    Questline.register(player, {
        -- Auto-assign starter quest
        StarterQuest = 0,

        -- Define some playerstats
        Captures = 0,
        Escapes = 0
    })
end)
```

### unregister

`[Yields]`

Remove player from the system.

|param|type|-
|-:|:-:|:-
|_player_|`Player`|Player to remove from the system.

```lua
game.Players.PlayerRemoving:Connect(function (player)
    Questline.unregister(player)
end)
```

### new

Creates a new questline represented by _questId_.

|param|type|-
|-:|:-:|:-
|_questId_|`string`|Unique identifier that represents the questline.

|return|-
|-:|:-
|`Questline`|A new questline.

```lua
local myQuest = Questline.getQuestById("myQuestId")
```

## Class Methods

### AddObjective

Adds the objective to the questline.

|param|type|-
|-:|:-:|:-
|_obj_|`string`|Objective to add.

|return|-
|-:|:-
|`Objective`|The objective added.

```lua
myQuest:AddObjective(Objective.touch(workspace.Baseplate))
```

### Assign

Connects the player to current objective.

|param|type|-
|-:|:-:|:-
|_player_|`Player`|Reference to the player.

```lua
myQuest:Assign(player)
```

### Cancel

Cancels/fails the current objective for the player.

|param|type|-
|-:|:-:|:-
|_player_|`Player`|Reference to the player.

```lua
myQuest:Cancel(player)
```

### Complete

Immediately completes the current objective for the player.

|param|type|-
|-:|:-:|:-
|_player_|`Player`|Reference to the player.

```lua
myQuest:Complete(player)
```

### Disconnect

Disconnects the player from the objective.

|param|type|-
|-:|:-:|:-
|_player_|`Player`|Reference to the player.

```lua
myQuest:Disconnect(player)
```

### IsConnected

Returns a boolean value indicating if the player is connected to the objective.

|param|type|-
|-:|:-:|:-
|_player_|`Player`|Reference to the player.

|return|-
|-:|:-
|`boolean`|Boolean indicating connection.

```lua
if myQuest:IsConnected(player) then
    print(player.Name, "is connected")
end
```

## Event Handlers

### OnAssign

Callback handler that fires when a player is assigned this objective.

|param|type|-
|-:|:-:|:-
|_player_|`Player`|Reference to the player.

```lua
function myQuest:OnAssign(player)
    print("The journey begins for", Player.Name)
end
```

### OnCancel

Callback handler that fires when an objective is canceled/failed.

|param|type|-
|-:|:-:|:-
|_player_|`Player`|Reference to the player.

```lua
function myQuest:OnCancel(player)
    print(Player.Name, "oof'd up.")
end
```

### OnComplete

Callback handler that fires when a player has completed the objective.

|param|type|-
|-:|:-:|:-
|_player_|`Player`|Reference to the player.

```lua
function myQuest:OnComplete(player)
    print("Yay!,", Player.Name)
end
```

