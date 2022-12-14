## Table of Contents

* [Class Members](#class-members)
  * [timeout](#timeout)
  * [new](#new)
  * [getQuestById](#getquestbyid)
  * [register](#register)
  * [unregister](#unregister)

* [Public Members](#public-methods)
  * [AddObjective](#addobjective)
  * [Assign](#assign)
  * [Cancel](#cancel)
  * [IsAccepted](#isaccepted)
  * [IsCanceled](#iscanceled)
  * [IsComplete](#iscomplete)
  * [GetCurrentProgress](#getcurrentprogress)
  * [GetObjectiveValue](#getobjectivevalue)
  * [GetProgress](#getprogress)

* [Objective Types](#objective-types)
  * [Event](#event)
  * [Score](#score)
  * [Timer](#timer)
  * [Touch](#touch)
  * [Value](#value)

## Class Members

### timeout

|Type|Default|Description
|-:|:-:|:-
|number|1.0|Determines the transition time between one objective and the next.  Measured in seconds.

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

## Objectives Types

### Event

|Type|Default|Description
|-:|:-:|:-
|string|"event"|`readonly` Enum for the *event* objective type.

### Score

|Type|Default|Description
|-:|:-:|:-
|string|"score"|`readonly` Enum for the *score* objective type.

### Timer

|Type|Default|Description
|-:|:-:|:-
|string|"timer"|`readonly` Enum for the *timer* objective type.

### Touch

|Type|Default|Description
|-:|:-:|:-
|string|"touch"|`readonly` Enum for the *touch* objective type.

### Value

|Type|Default|Description
|-:|:-:|:-
|string|"value"|`readonly` Enum for the *value* objective type.

