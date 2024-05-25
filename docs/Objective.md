# Objective

This serves as a base class for all objectives within the system.

## Summary

### Properties

No properties.

### Objective Types

[`all`](#all) ( `...Objective` ) `:` `Objective`

Player is required to complete all objectives; in any order.

[`any`](#any) ( `...Objective` ) `:` `Objective`

Player only needs to complete one objective.

[`none`](#none) ( `...Objective` ) `:` `Objective`

Completion of any objective will cause failure.

[`event`](#event) ( `event` `:` `RBXScriptSignal` ) `:` `Objective`

A generic, event-based objective.  Connected to a roblox event.

[`score`](#score) ( `statName` `:` `string` , `targetValue` `:` `number` ) `:` `Objective`

Tracks the value of a leaderstat.

[`timer`](#timer) ( `duration` `:` `number` ) `:` `Objective`

Timed objective that completes after a set number of seconds.

[`touch`](#touch) ( `touchPart` `:` `BasePart` ) `:` `Objective`

Triggered when the player's character comes in contact with _touchPart_.

[`value`](#value) ( `intValue` `:` `IntValue` , `targetValue` `:` `number` ) `:` `Objective`

Tracks the value of an `IntValue`.  Triggered when `Value` reaches _targetValue_.

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

## Objective Types

### all

Player is required to complete all objectives; in any order.

|param|type|-
|-:|:-:|:-
|_..._|`...Objective`|List of objectives.

|return|-
|-:|:-
|`Objective`|A new objective.

```lua
local touchBase = Objective.touch(workspace.Baseplate)
```

### any

Player only needs to complete one objective.

|param|type|-
|-:|:-:|:-
|_..._|`...Objective`|List of objectives.

|return|-
|-:|:-
|`Objective`|A new objective.

```lua
local touchBase = Objective.touch(workspace.Baseplate)
```

### none

Completion of any objective will cause failure.

|param|type|-
|-:|:-:|:-
|_..._|`...Objective`|List of objectives.

|return|-
|-:|:-
|`Objective`|A new objective.

```lua
local touchBase = Objective.touch(workspace.Baseplate)
```

### touch

Triggered when the player's character comes in contact with _touchPart_.

|param|type|-
|-:|:-:|:-
|_touchPart_|`BasePart`|List of objectives.

|return|-
|-:|:-
|`Objective`|A new touch objective.

```lua
local touchBase = Objective.touch(workspace.Baseplate)
```


## Class Methods

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
