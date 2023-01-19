
Enums
-----

### Event

`readonly` `string:"event"`

> **Example usage:**
```lua
-- Knock on wood
local trigger = workspace.Wood.ClickDetector.MouseClicked
myQuest:AddObjective(QuestLine.Event, trigger, 3)
```

Objective triggered by a roblox signal.

|Parameter|Type             |Default     |Description
|--------:|:---------------:|:----------:|:----------
|  *event*|`RBXScriptSignal`|*[required]*| A roblox signal.
|  *count*|`number`         |1           | Expected trigger count.

### Score

`readonly` `string:"score"`

> **Example usage:**
```lua
    -- Score 10 points on leaderstats
    myQuest:AddObjective(QuestLine.Score, "Points", 10)
```

Objective triggered by a leaderstat value.

|Parameter |Type    |Default     |Description
|---------:|:------:|:----------:|:----------
|*statName*|`string`|*[required]*| The name of the leaderstat to track.
|*amount*  |`number`|*[required]*| Value to consider complete.

### Timer

`readonly` `string:"timer"`

> **Example usage:**
```lua
    -- Wait 5 seconds, counting progress each second
    myQuest:AddObjective(QuestLine.Timer, 5, 5)
```

A time based objective.

|Parameter|Type    |Default     |Description
|--------:|:------:|:----------:|:----------
|*count*  |`number`|*[required]*| Number of seconds to wait.
|*steps*  |`number`|1           | Steps of progress counted.

### Touch

`readonly` `string:"touch"`

> **Example usage:**
```lua
    -- Return to dropoff
    myQuest:AddObjective(QuestLine.Touch, workspace.DropOff)
```

Objective based on a touch event.

|Parameter  |Type      |Default     |Description
|----------:|:--------:|:----------:|:----------
|*touchPart*|`BasePart`|*[required]*| A touchable part within the workspace.

### Value

`readonly` `string:"value"`

> **Example usage:**
```lua
    -- Track kills
    myQuest:AddObjective(QuestLine.Value, player.EnemiesKilled, 5)
```

Objective based on an IntValue.

|Parameter|Type      |Default     |Description
|--------:|:--------:|:----------:|:----------
| *intVal*|`IntValue`|*[required]*| A reference to an IntValue.
|  *count*|`number`  |*[required]*| Value to consider complete.

Static Members
--------------

### interval

`number` `default=1.0`

Transition time between one objective and the next.  Measured in seconds.

Because an objective fires *OnProgress* for both zero and 100%,
this provides a chance to update the player's gui before assigned the next objective.

### new()

`QuestLine.new(questId:string, self:{any}?):QuestLine`

> **Example usage:**
```lua
    local myQuest = QuestLine.new("myQuestId", {...})
```

Creates a new questline.

|Parameter|Type    |Default     |Description
|--------:|:------:|:----------:|:----------
|*questId*|`string`|*[required]*| A unique identifier for the quest.
|   *self*|`{any}` |{}          | A table of properties associated with the quest.

|Return     |Description
|:----------|:----------
|*QuestLine*| A new QuestLine.

### getQuestById()

`QuestLine.getQuestById(questId:string):QuestLine`

> **Example usage:**
```lua
    local myQuest = QuestLine.getQuestById("myQuestId")
```

Returns a quest created with the given *questId*.

|Parameter|Type    |Default     |Description
|--------:|:------:|:----------:|:----------
|*questId*|`string`|*[required]*| A unique identifier for the quest.

|Return     |Description
|----------:|:----------
|`QuestLine`| The quest identified by *questId*.

### register()

`QuestLine.register(player:Player, playerData:{[string]:number})`

> **Example usage:**
```lua
    -- Load data from datastore
    local playerData = {
        myQuestId = 0 -- Assign to zero for auto-accept
    }
    
    QuestLine.register(player, playerData)
```

Registers a player with the quest system and loads the player's progress.

|Parameter   |Type               |Default     |Description
|-----------:|:-----------------:|:----------:|:----------
|*player*    |`Player`           |*[required]*| The player to register.
|*playerData*|`{[string]:number}`|*[required]*| The player's progression table.

### unregister()

`QuestLine.unregister(player:Player):{[string]:number}`

> **Example usage:**
```lua
    local playerData = QuestLine.unregister(player)
```

Unregisters the player from the quest system and returns the player's progress.

|Parameter|Type    |Default     |Description
|--------:|:------:|:----------:|:----------
|*player* |`Player`|*[required]*| The player to add to the quest system.

|Return             |Description
|:------------------|:----------
|`{[string]:number}`| The player's progression table.

Public Methods
--------------

### AddObjective()

`myQuest:AddObjective(objType:string, ...any):number`

> **Example usage:**
```lua
    local index = myQuest:AddObjective(QuestLine.Touch, workspace.TouchPart)
```

Adds a new objective according to the given objective type.  Additional parameters are determined by the type of objective you wish to add.

|Parameter|Type    |Default     |Description
|--------:|:------:|:----------:|:----------
|*objType*|`string`|*[required]*| The desired objective type to construct.
|*...*    |`...any`|*[required]*| See [enum section](#enums) for details.

|Return  |Description
|:-------|:----------
|`number`| The index of the created objective within the *Questline*.

### Assign()

`myQuest:Assign(player:Player)`

> **Example usage:**
```lua
myQuest:Assign(player)
```

Assigns a *player* to a quest.  Triggers *OnAccept* if the quest was previously unknown followed by *OnAssign*.  A call to *OnProgress* is also included as a final step.

|Parameter|Type    |Default     |Description
|--------:|:------:|:----------:|:----------
|*player* |`Player`|*[required]*| The player to assign.

### Cancel()

`myQuest:Cancel(player:Player)`

> **Example usage:**
```lua
myQuest:Cancel(player)
```

Causes the *player* to cancel/fail the current quest.  Triggers the *OnCancel* event listener.  A quest can be re-assigned after being canceled, triggering the *OnAccept* event listener once more.

|Parameter|Type    |Default     |Description
|--------:|:------:|:----------:|:----------
|*player* |`Player`|*[required]*| The player to cancel the quest on.

### GetCurrentProgress()

`myQuest:GetCurrentProgress(player:Player):(number, number)`

> **Example usage:**
```lua
    local currentProgress, index = myQuest:GetCurrentProgress(player)
```

Retrieves an objective's progress for a player.

|Parameter|Type    |Default     |Description
|--------:|:------:|:----------:|:----------
|*player* |`Player`|*[required]*| The player to query.

|Return  |Description
|:-------|:----------
|`number`| The current progress of the *player* within the objective.
|`number`| The index of the current objective within the *Questline*.

### GetObjectiveValue()

`myQuest:GetObjectiveValue(index:number):number`

> **Example usage:**
```lua
    local value = myQuest:GetObjectiveValue(index)
```

Retrieves an objective's total progress needed to pass.

|Parameter|Type    |Default     |Description
|--------:|:------:|:----------:|:----------
|*index*  |`number`|*[required]*| The index of the objective within the quest to query.

|Return  |Description
|:-------|:----------
|`number`| The objective's maximum progression.

### GetProgress()

`myQuest:GetProgress(player:Player):number`

> **Example usage:**
```lua
    local progress = myQuest:GetProgress(player)
```

Retrieves a player's progression for the entire quest, not just the current objective.

|Parameter|Type    |Default     |Description
|--------:|:------:|:----------:|:----------
|*player* |`Player`|*[required]*| The player to query.

|Return  |Description
|:-------|:----------
|`number`| The *player*'s progress within the questline.

### IsAccepted()

`myQuest:IsAccepted(player:Player):boolean`

> **Example usage:**
```lua
if myQuest:IsAccepted(player) then
    -- This is no surprise
end
```

Checks if the quest is accepted by the *player*.  A quest is only accepted when assigned for the first time, or after it has been canceled.

|Parameter|Type    |Default     |Description
|--------:|:------:|:----------:|:----------
|*player* |`Player`|*[required]*| The player to query.

|Return   |Description
|:--------|:----------
|`boolean`| Determines if the quest is accepted.

### IsCanceled()

`myQuest:IsCanceled(player:Player):boolean`

> **Example usage:**
```lua
if myQuest:IsCanceled(player) then
    -- Where did I go wrong?
end
```

Checks if the quest is canceled for the *player*.

|Parameter|Type    |Default     |Description
|--------:|:------:|:----------:|:----------
|*player* |`Player`|*[required]*| The player to query.

|Return   |Description
|:--------|:----------
|`boolean`| Determines if the quest is canceled.

### IsComplete()

`myQuest:IsComplete(player:Player):boolean`

> **Example usage:**
```lua
    if myQuest:IsCompete(player) then
        -- Yeah, I did that!
    end
```

Checks if the *player* has completed the quest.

|Parameter|Type    |Default     |Description
|--------:|:------:|:----------:|:----------
|*player* |`Player`|*[required]*| The player to query.

|Return   |Description
|:--------|:----------
|`boolean`| Determines if the quest is complete.

Events
------

### OnAccept()

`myQuest:OnAccept(player:Player)`

> **Example usage:**
```lua
    function myQuest:OnAccept(player)
        -- Run code upon initialization
    end
```

Called at the beginning of a quest and only when it's first initialized.  This can be used to give a player starter items specific to the quest.

|Parameter |Type    |Description
|---------:|:------:|:----------
|*player*  |`Player`| A reference to the player.

### OnAssign()

`myQuest:OnAssign(player:Player)`

> **Example usage:**
```lua
    function myQuest:OnAssign(player)
        -- Run code upon assignment
    end
```

Called each time the player is assigned the quest.  This runs after a quest is first accepted, or when a player loads progress from a previous session.  Useful for creating gui elements needed to display a quest log.

|Parameter |Type    |Description
|---------:|:------:|:----------
|*player*  |`Player`| A reference to the player.

### OnCancel()

`myQuest:OnCancel(player:Player)`

**Example usage:**
```lua
    function myQuest:OnCancel(player)
        -- Run code upon cancelation
    end
```

Called only when a call to *Cancel* has been made.  This can be used to fail a quest.

|Parameter |Type    |Description
|---------:|:------:|:----------
|*player*  |`Player`| A reference to the player.

### OnComplete()

`myQuest:OnComplete(player:Player)`

**Example usage:**
```lua
    function myQuest:OnComplete(player)
        -- Run code upon completion
    end
```

Called when a player has completed a quest.

|Parameter |Type    |Description
|---------:|:------:|:----------
|*player*  |`Player`| A reference to the player.

### OnProgress()

`myQuest:OnProgress(player:Player, progress:number, index:number)`

> **Example usage:**
```lua
    function myQuest:OnProgress(player, progress, index)
        print(player.Name, "has progressed to", progress, "for objective", index)
    end
```

Called when a player has made progress.  For the first time, progress will be zero, and lastly, the progress will be equal to `myQuest:GetObjectiveValue(index)`.

|Parameter |Type    |Description
|---------:|:------:|:----------
|*player*  |`Player`| A reference to the player.
|*progress*|`number`| The objective's progress for the player.
|*index*   |`number`| The objective's index within the quest.
