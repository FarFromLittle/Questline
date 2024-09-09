# Quest<i>line</i> Reference

Quest<i>line</i> `>` Quest `>` Objective

### ⚡ [Static](#static)

[`Objective`](#objective):`ObjectiveType`

Objective hosts the various objective types within Quest<i>line</i>.

[`getQuestById`](#getquestbyid)(_questId_:`string`)➡️`Questline`

Returns a quest found with the given _questId_.

[`getStat`](#getstat)(_player_:`Player`, _statName_:`string`)➡️`number`

Retrieves a _playerstat_ from the datastore.

[`register`](#register)(_player_:`Player`)➡️`nil`

Prepares player to receive questlines.  Loads player data from previous session.

[`setStat`](#setstat)(_player_:`Player`, _statName_:`string`, _value_:`number`)➡️`nil`

Saves a _playerstat_ to the datastore.

[`unregister`](#unregister)(_player_:`Player`)➡️`nil`

Removes the player from the system, disconnecting any lingering questlines.

### ✨ [Constructor](#constructor)

[`new`](#new)(_questId_:`string`)➡️`Questline`

Creates a new questline that requires players to advance from one objective to the next, until the questline is finished.

### 📦 [Methods](#methods)

[`Abort`](#abort)(_player_:`Player`)➡️`nil`

Adds an objective to the questline.

[`AddObjective`](#addobjective)(_obj_:`Objective`)➡️`nil`

Adds an objective to the questline.

[`Assign`](#assign)(_player_:`Player`)➡️`nil`

Connects the player to current objective.

[`Cancel`](#cancel)(_player_:`Player`)➡️`nil`

Cancels/fails the current objective for the player.

[`Complete`](#complete)(_player_:`Player`)➡️`nil`

Immediately completes the current objective for the player.

[`Connect`](#connect)(_player_:`Player`, _event_:`RBXScriptSignal`, _callback_:`Response`)➡️`nil`

Immediately completes the current objective for the player.

[`Disconnect`](#disconnect)(_player_:`Player`)➡️`nil`

Disconnects the player from the objective.

[`IsConnected`](#isconnected)(_player_:`Player`)➡️`boolean`

Returns a boolean value indicating if the player is connected to the objective.

### 🎉 [Events](#events)

[`OnAccept`](#onaccept)(_player_:`Player`)➡️`nil`

Only fired once when _player_ is assigned a Quest<i>line</i>.

[`OnAssign`](#onassign)(_player_:`Player`, _progress_:`number`)➡️`nil`

Callback handler that fires when a player is assigned this objective.

[`OnCancel`](#oncancel)(_player_:`Player`)➡️`nil`

Callback handler that fires when an objective is canceled/failed.

[`OnComplete`](#oncomplete)(_player_:`Player`)➡️`nil`

Callback handler that fires when a player has completed the objective.

[`OnProgress`](#onprogress)(_player_:`Player`, _progress_:`number`)➡️`nil`

Callback handler that fires when a player has completed the objective.

## Static

### getQuestById

Returns the questline represented by the supplied _questId_.

>|param|type|description
>|-:|:-:|:-
>|_questId_|`string`|Unique identifier of the questline within the system.

>|return|description
>|-:|:-
>|`Questline`|The questline matching the given _questId_.

```lua
local myQuest = Questline.getQuestById("myQuestId")
```

### register

`Yields`

Prepares the player to start receiving Quest<i>lines</i>.  Adding the necessary data to track player progression.

This function also attempts to load player progression and assign any previously incomplete Quest<i>lines</i>.

>|param|type|description
>|-:|:-:|:-
>|_player_|`Player`|Player to register with the system.
>|_playerData_|`{[string]:number}`|Table containing the player's quest data, including progression and playerstats.

```lua
game.Players.PlayerAdded:Connect(function (player)
    Questline.register(player)
end)
```

### unregister

`Yields`

Remove player from the system.

>|param|type|description
>|-:|:-:|:-
>|_player_|`Player`|Player to remove from the system.

```lua
game.Players.PlayerRemoving:Connect(function (player)
    Questline.unregister(player)
end)
```

```lua
local myQuest = Questline.getQuestById("myQuestId")
```

>## Constructor

### new

Creates a new questline represented by _questId_.

>|param|type|description
>|-:|:-:|:-
>|_questId_|`string`|Unique string to identify the questline.

>|return|description
>|-:|:-
>|`Questline`|A new questline.

>## Methods

### Abort

Removes _player from the Quest<i>line</i> without triggering a `Cancel` or `Complete` event.

### AddObjective

Adds the objective to the questline.

>|param|type|description
>|-:|:-:|:-
>|_obj_|`string`|Objective to add.

>|return|description
>|-:|:-
>|`Objective`|The objective added.

```lua
myQuest:AddObjective(Objective.touch(workspace.Baseplate))
```

### Assign

Connects the player to current objective.

>|param|type|description
>|-:|:-:|:-
>|_player_|`Player`|Reference to the player.

```lua
myQuest:Assign(player)
```

### Cancel

Cancels/fails the current objective for the player.

>|param|type|description
>|-:|:-:|:-
>|_player_|`Player`|Reference to the player.

```lua
myQuest:Cancel(player)
```

### Complete

Immediately completes the current objective for the player.

>|param|type|description
>|-:|:-:|:-
>|_player_|`Player`|Reference to the player.

```lua
myQuest:Complete(player)
```

### Disconnect

Disconnects the player from the objective.

>|param|type|description
>|-:|:-:|:-
>|_player_|`Player`|Reference to the player.

```lua
myQuest:Disconnect(player)
```

### IsConnected

Returns a boolean value indicating if the player is connected to the objective.

>|param|type|description
>|-:|:-:|:-
>|_player_|`Player`|Reference to the player.

>|return|description
>|-:|:-
>|`boolean`|Boolean indicating connection.

```lua
if myQuest:IsConnected(player) then
    print(player.Name, "is connected")
end
```

>## Events

### OnAssign

Callback handler that fires when a player is assigned this objective.

>|param|type|description
>|-:|:-:|:-
>|_player_|`Player`|Reference to the player.

```lua
function myQuest:OnAssign(player)
    print("The journey begins for", Player.Name)
end
```

### OnCancel

Callback handler that fires when the quest is canceled/failed.

>|param|type|description
>|-:|:-:|:-
>|_player_|`Player`|Reference to the player.

```lua
function myQuest:OnCancel(player)
    print(Player.Name, "has failed!")
end
```

### OnComplete

Callback handler that fires when a player has completed the quest.

>|param|type|description
>|-:|:-:|:-
>|_player_|`Player`|Reference to the player.

```lua
function myQuest:OnComplete(player)
    print("Yay!,", Player.Name)
end
```

### OnProgress

Callback handler that fires when a player has completed an objective.

>|param|type|description
>|-:|:-:|:-
>|_player_|`Player`|Reference to the player.

```lua
function myQuest:OnComplete(player, progress)
    print(Player.Name, "completed objective #", progress)
end
```

