## Table of Contents

* [Objectives](#objectives)
  * [Event](#event)
  * [Score](#score)
  * [Timer](#timer)
  * [Touch](#touch)
  * [Value](#value)

* [Class Members](#class-members)
  * [timeout](#timeout)
  * [new](#new)
  * [getQuestById](#getquestbyid)
  * [register](#register)
  * [unregister](#unregister)

* [Public Methods](#public-methods)
  * [AddObjective](#addobjective)
  * [Assign](#assign)
  * [Cancel](#cancel)
  * [IsAccepted](#isaccepted)
  * [IsCanceled](#iscanceled)
  * [IsComplete](#iscomplete)
  * [GetCurrentProgress](#getcurrentprogress)
  * [GetObjectiveValue](#getobjectivevalue)
  * [GetProgress](#getprogress)

## Objectives

### Event

`string` `default="event"` `readonly` Objective attached to a Roblox event.

```lua
myQuest:AddObjective(QuestLine.Event, workspace.Door.Knock.MouseClicked, 3)
```

Parameters include:

|Parameter|Type|Default|Description
|-:|:-:|:-:|:-
|event|RBXScriptSignal|*required*| Progresses when the event is fired for the player.
|count|number|1| Number of times the event should be triggered.

### Score

`string` `default="score"` `readonly` Objective based on a leaderstat.

```lua
-- Score 10 "Points"
myQuest:AddObjective(QuestLine.Score, "Points", 10)
```

Parameters include:

|Parameter|Type|Default|Description
|-:|:-:|:-:|:-
|name|string|*required*| The name of the leaderstat to track.
|amount|number|*required*| Value to consider complete.

### Timer

`string` `default="timer"` `readonly` Objective run on a timer.

```lua
-- Wait 3 seconds, progress in steps
myQuest:AddObjective(QuestLine.Timer, 3, true)
```

Parameters include:

|Parameter|Type|Default|Description
|-:|:-:|:-:|:-
|count|number|*required*| Number of seconds to wait.
|once|boolean|false| Controls whether progress is tracked for each second, or *once* for all.

### Touch

`string` `default="touch"` `readonly` Objective based on a touch event.

```lua
-- Return to dropoff
myQuest:AddObjective(QuestLine.Touch, workspace.DropOff)
```

Parameters include:

|Parameter|Type|Default|Description
|-:|:-:|:-:|:-
|touchPart|BasePart|*required*| A touchable part within the workspace.

### Value

`string` `default="value"` `readonly` Objective based on an IntValue.

```lua
-- Track kills
myQuest:AddObjective(QuestLine.Value, player.EnemiesKilled, 5)
```

Parameters include:

|Parameter|Type|Default|Description
|-:|:-:|:-:|:-
|intVal|IntValue|*required*| A reference to an IntValue.
|count|number|*required*| Value to consider complete.

## Class Members

### timeout

`number` `default=1.0` Determines the transition time between one objective and the next.  Measured in seconds.

### new

```lua
local myQuest = QuestLine.new("myQuestId", {...})
```

Creates a new questline.  Returns *self* (if provided) with it's metatable set to QuestLine.

|Parameter|Type|Description
|:-|:-|:-
|*questId*|string| A unique identifier for the quest in the form of a string.
|*self*|{any}| [optional] A table of properties associated with the quest.

|Returns|Description
|-:|:-
|*QuestLine*| A new *QuestLine* object.

### getQuestById

```lua
local myQuest = QuestLine.getQuestById("myQuestId")
```

Returns a quest created with the given *questId*.

|Parameter|Type|Description
|:-|:-|:-
|*questId*|string| A unique identifier for the quest in the form of a string.

|Returns|Description
|-:|:-
|*QuestLine*| The quest identified by *questId*.

### register

```lua
-- Load data from datastore
local playerData = {
    myQuestId = 0 -- Assign to zero for auto-accept
}

QuestLine.register(player, playerData)
```

Registers a player with the quest system and loads the player's progression data.

|Parameter|Type|Description
|:-|:-|:-
|*player*|Player| The player to add to the quest system.
|*playerData*|{[string]:number}| The player's progression table.

### unregister

```lua
local playerData = QuestLine.unregister(player)
```

Unregisters the player from the quest system and returns the player's progression table.

|Parameter|Type|Description
|:-|:-|:-
|*player*|Player| The player to add to the quest system.

|Returns|Description
|:-|:-
|{[string]:number}| The player's progression table.

## Public Methods

### AddObjective

```lua
local index = myQuest:AddObjective(objType, ...)
```

Adds a new objective according to the supplied *Objective* type.  Additional parameters are determined by the objective you wish to add.  See the objectives section [here](#objective-types).

|Parameter|Type|Description
|:-|:-|:-
|*objType*|Objective| The desired objective type to construct.

|Returns|Description
|:-|:-
|number| The index of the created objective within the *Questline*.

### Assign

```lua
myQuest:Assign(player)
```

Assigns a *player* to a quest.  Triggers *OnAccept* if the quest was previously unknown followed by *OnAssign*.  A call to *OnProgress* is also included as a final step.

|Parameter|Type|Description
|:-|:-|:-
|*player*|Player| The player to assign to the quest.

### Cancel

```lua
myQuest:Cancel(player)
```

Causes the *player* to cancel/fail the current quest.  Triggers the *OnCancel* event listener.  A quest can be re-assigned after being canceled, triggering the *OnAccept* event listener once more.

|Parameter|Type|Description
|:-|:-|:-
|*player*|Player| The player to cancel the quest on.

### IsAccepted

```lua
if myQuest:IsAccepted(player) then
    -- This is no surprise
end
```

Checks if the quest is accepted by the *player*.  A quest is only accepted when assigned for the first time, or after it has been canceled.

|Parameter|Type|Description
|:-|:-|:-
|*player*|Player| The player to query.

### IsCanceled

```lua
if myQuest:IsCanceled(player) then
    -- Where did I go wrong?
end
```

Checks if the quest is canceled for the *player*.

|Parameter|Type|Description
|:-|:-|:-
|*player*|Player| The player to query.

### IsComplete

```lua
if myQuest:IsCompete(player) then
    -- Yeah, I did that!
end
```

Checks if the *player* has completed the quest.

|Parameter|Type|Description
|:-|:-|:-
|*player*|Player| The player to query.

### GetCurrentProgress

```lua
local currentProgress, index = myQuest:GetCurrentProgress(player)
```

Retrieves an objective's progress for a player.  Reference [*GetObjectiveValue*](#GetObjectiveValue) to get the total progress needed to continue.

|Parameter|Type|Description
|:-|:-|:-
|*player*|Player| The player to query.

|Returns|Description
|:-|:-
|number| The current progress of the *player* within the objective.
|number| The index of the current objective within the *Questline*.

### GetObjectiveValue

```lua
local value = myQuest:GetObjectiveValue(index)
```

Retrieves an objective's total progress needed to pass.

|Parameter|Type|Description
|:-|:-|:-
|*index*|number| The index of the objective within the quest to query.

|Returns|Description
|:-|:-
|number| The objective's maximum progression.

### GetProgress

```lua
local progress = myQuest:GetProgress(player)
```

Retrieves a player's progression for the entire quest, not just the current objective.

|Parameter|Type|Description
|:-|:-|:-
|*player*|Player| The player to query.

|Returns|Description
|:-|:-
|number| The progress of the *player* within the quest.
