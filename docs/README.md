# QuestLine API

[**Types**](#types)
* [QuestLine.Event](#questlineevent)
* [QuestLine.Score](#questlinescore)
* [QuestLine.Timer](#questlinetimer)
* [QuestLine.Touch](#questlinetouch)
* [QuestLine.Value](#questlinevalue)

[**Class Members**](#class-members)
* [QuestLine.interval](#questlineinterval)
* [QuestLine.new()](#questlinenew)
* [QuestLine.getQuestById()](#questlinegetquestbyid)
* [QuestLine.register()](#questlineregister)
* [QuestLine.unregister()](#questlineunregister)

[**Public Methods**](#public-methods)
* [AddObjective()](#addobjective)
* [Assign()](#assign)
* [Cancel()](#cancel)
* [IsAccepted()](#isaccepted)
* [IsCanceled()](#iscanceled)
* [IsComplete()](#iscomplete)
* [GetCurrentProgress()](#getcurrentprogress)
* [GetObjectiveValue()](#getobjectivevalue)
* [GetProgress()](#getprogress)

[**Events**](#events)
* [OnAccept()](#onaccept)
* [OnAssign()](#onassign)
* [OnCancel()](#oncancel)
* [OnComplete()](#oncomplete)
* [OnProgress()](#onprogress)

## Types

### QuestLine.Event

`readonly` `string:"event"`

Objective triggered by a roblox signal.

|Parameter|Type             |Default     |Description
|--------:|:---------------:|:----------:|:----------
|  *event*|`RBXScriptSignal`|*[required]*| A roblox signal.
|  *count*|`number`         |1           | Expected trigger count.

<details>
<summary>Example</summary>

```lua
    -- Knock on wood
    local trigger = workspace.Wood.ClickDetector.MouseClicked
    myQuest:AddObjective(QuestLine.Event, trigger, 3)
```

</details>

--------------------------------------------------------------------------------

### QuestLine.Score

`readonly` `string:"score"`

Objective triggered by a leaderstat value.

|Parameter|Type    |Default     |Description
|--------:|:------:|:----------:|:----------
|   *name*|`string`|*[required]*| The name of the leaderstat to track.
| *amount*|`number`|*[required]*| Value to consider complete.

<details>
<summary>Example</summary>

```lua
    -- Score 10 points on leaderstats
    myQuest:AddObjective(QuestLine.Score, "Points", 10)
```
</details>

--------------------------------------------------------------------------------

### QuestLine.Timer

`readonly` `string:"timer"`

A time based objective.

|Parameter|Type     |Default     |Description
|--------:|:-------:|:----------:|:----------
|  *count*|`number` |*[required]*| Number of seconds to wait.
|   *once*|`boolean`|false       | Track each second, or *once* and for all.

<details>
<summary>Example</summary>

```lua
    -- Wait 5 seconds, progressing each step
    myQuest:AddObjective(QuestLine.Timer, 5, true)
```
</details>

--------------------------------------------------------------------------------

### QuestLine.Touch

`readonly` `string:"touch"`

Objective based on a touch event.

|Parameter  |Type      |Default     |Description
|----------:|:--------:|:----------:|:----------
|*touchPart*|`BasePart`|*[required]*| A touchable part within the workspace.

<details>
<summary>Example</summary>

```lua
    -- Return to dropoff
    myQuest:AddObjective(QuestLine.Touch, workspace.DropOff)
```
</details>

--------------------------------------------------------------------------------

### QuestLine.Value

`readonly` `string:"value"`

Objective based on an IntValue.

|Parameter|Type      |Default     |Description
|--------:|:--------:|:----------:|:----------
| *intVal*|`IntValue`|*[required]*| A reference to an IntValue.
|  *count*|`number`  |*[required]*| Value to consider complete.

<details>
<summary>Example</summary>

```lua
    -- Track kills
    myQuest:AddObjective(QuestLine.Value, player.EnemiesKilled, 5)
```
</details>

--------------------------------------------------------------------------------

## Class Members

### QuestLine.interval

`number` `default=1.0`

Transition time between one objective and the next.  Measured in seconds.

--------------------------------------------------------------------------------

### QuestLine.new()

`QuestLine.new(questId:string, self:{any}?):QuestLine`

Creates a new questline.

|Parameter|Type    |Default     |Description
|--------:|:------:|:----------:|:----------
|*questId*|`string`|*[required]*| A unique identifier for the quest.
|   *self*|`{any}` |{}          | A table of properties associated with the quest.

|Return     |Description
|:----------|:----------
|*QuestLine*| A new QuestLine.

<details>
<summary>Example</summary>

```lua
    local myQuest = QuestLine.new("myQuestId", {...})
```
</details>

--------------------------------------------------------------------------------

### QuestLine.getQuestById()

`QuestLine.getQuestById(questId:string):QuestLine`

Returns a quest created with the given *questId*.

|Parameter|Type    |Default     |Description
|--------:|:------:|:----------:|:----------
|*questId*|`string`|*[required]*| A unique identifier for the quest.

|Return     |Description
|----------:|:----------
|`QuestLine`| The quest identified by *questId*.

<details>
<summary>Example</summary>

```lua
    local myQuest = QuestLine.getQuestById("myQuestId")
```
</details>

--------------------------------------------------------------------------------

### QuestLine.register()

`QuestLine.register(player:Player, playerData:{[string]:number})`

Registers a player with the quest system and loads the player's progress.

|Parameter   |Type               |Default     |Description
|-----------:|:-----------------:|:----------:|:----------
|*player*    |`Player`           |*[required]*| The player to register.
|*playerData*|`{[string]:number}`|*[required]*| The player's progression table.

<details>
<summary>Example</summary>

```lua
    -- Load data from datastore
    local playerData = {
        myQuestId = 0 -- Assign to zero for auto-accept
    }
    
    QuestLine.register(player, playerData)
```
</details>

--------------------------------------------------------------------------------

### QuestLine.unregister()

`QuestLine.unregister(player:Player):{[string]:number}`

Unregisters the player from the quest system and returns the player's progress.

|Parameter|Type    |Default     |Description
|--------:|:------:|:----------:|:----------
|*player* |`Player`|*[required]*| The player to add to the quest system.

|Return             |Description
|:------------------|:----------
|`{[string]:number}`| The player's progression table.

<details>
<summary>Example</summary>

```lua
    local playerData = QuestLine.unregister(player)
```
</details>

--------------------------------------------------------------------------------

## Public Methods

### AddObjective()

`myQuest:AddObjective(objType:string, ...any):number`

Adds a new objective according to the given objective type.  Additional parameters are determined by the type of objective you wish to add.

|Parameter|Type    |Default     |Description
|--------:|:------:|:----------:|:----------
|*objType*|`string`|*[required]*| The desired objective type to construct.
|*...*    |`...any`|*[required]*| See [enum section](#enums) for details.

|Return  |Description
|:-------|:----------
|`number`| The index of the created objective within the *Questline*.

<details>
<summary>Example</summary>

```lua
    local index = myQuest:AddObjective(QuestLine.Touch, workspace.TouchPart)
```
</details>

--------------------------------------------------------------------------------

### Assign()

`myQuest:Assign(player:Player)`

Assigns a *player* to a quest.  Triggers *OnAccept* if the quest was previously unknown followed by *OnAssign*.  A call to *OnProgress* is also included as a final step.

|Parameter|Type    |Default     |Description
|--------:|:------:|:----------:|:----------
|*player* |`Player`|*[required]*| The player to assign.

<details>
<summary>Example</summary>

```lua
myQuest:Assign(player)
```
</details>

--------------------------------------------------------------------------------

### Cancel()

`myQuest:Cancel(player:Player)`

Causes the *player* to cancel/fail the current quest.  Triggers the *OnCancel* event listener.  A quest can be re-assigned after being canceled, triggering the *OnAccept* event listener once more.

|Parameter|Type    |Default     |Description
|--------:|:------:|:----------:|:----------
|*player* |`Player`|*[required]*| The player to cancel the quest on.

<details>
<summary>Example</summary>

```lua
myQuest:Cancel(player)
```
</details>

--------------------------------------------------------------------------------

### IsAccepted()

`myQuest:IsAccepted(player:Player):boolean`

Checks if the quest is accepted by the *player*.  A quest is only accepted when assigned for the first time, or after it has been canceled.

|Parameter|Type    |Default     |Description
|--------:|:------:|:----------:|:----------
|*player* |`Player`|*[required]*| The player to query.

|Return   |Description
|:--------|:----------
|`boolean`| Determines if the quest is accepted.

<details>
<summary>Example</summary>

```lua
if myQuest:IsAccepted(player) then
    -- This is no surprise
end
```
</details>

--------------------------------------------------------------------------------

### IsCanceled()

`myQuest:IsCanceled(player:Player):boolean`

Checks if the quest is canceled for the *player*.

|Parameter|Type    |Default     |Description
|--------:|:------:|:----------:|:----------
|*player* |`Player`|*[required]*| The player to query.

|Return   |Description
|:--------|:----------
|`boolean`| Determines if the quest is canceled.

<details>
<summary>Example</summary>

```lua
if myQuest:IsCanceled(player) then
    -- Where did I go wrong?
end
```
</details>

--------------------------------------------------------------------------------

### IsComplete()

`myQuest:IsComplete(player:Player):boolean`

Checks if the *player* has completed the quest.

|Parameter|Type    |Default     |Description
|--------:|:------:|:----------:|:----------
|*player* |`Player`|*[required]*| The player to query.

|Return   |Description
|:--------|:----------
|`boolean`| Determines if the quest is complete.

<details>
<summary>Example</summary>

```lua
    if myQuest:IsCompete(player) then
        -- Yeah, I did that!
    end
```
</details>

--------------------------------------------------------------------------------

### GetCurrentProgress()

`myQuest:GetCurrentProgress(player:Player):(number, number)`

Retrieves an objective's progress for a player.

|Parameter|Type    |Default     |Description
|--------:|:------:|:----------:|:----------
|*player* |`Player`|*[required]*| The player to query.

|Return  |Description
|:-------|:----------
|`number`| The current progress of the *player* within the objective.
|`number`| The index of the current objective within the *Questline*.

<details>
<summary>Example</summary>

```lua
    local currentProgress, index = myQuest:GetCurrentProgress(player)
```
</details>

--------------------------------------------------------------------------------

### GetObjectiveValue()

`myQuest:GetObjectiveValue(index:number):number`

Retrieves an objective's total progress needed to pass.

|Parameter|Type    |Default     |Description
|--------:|:------:|:----------:|:----------
|*index*  |`number`|*[required]*| The index of the objective within the quest to query.

|Return  |Description
|:-------|:----------
|`number`| The objective's maximum progression.

<details>
<summary>Example</summary>

```lua
    local value = myQuest:GetObjectiveValue(index)
```
</details>

--------------------------------------------------------------------------------

### GetProgress()

`myQuest:GetProgress(player:Player):number`

Retrieves a player's progression for the entire quest, not just the current objective.

|Parameter|Type    |Default     |Description
|--------:|:------:|:----------:|:----------
|*player* |`Player`|*[required]*| The player to query.

|Return  |Description
|:-------|:----------
|`number`| The *player*'s progress within the questline.

<details>
<summary>Example</summary>

```lua
    local progress = myQuest:GetProgress(player)
```
</details>

--------------------------------------------------------------------------------

## Events

### OnAccept()

`myQuest:OnAccept(player:Player)`

Called at the beginning of a quest and only when it's first initialized.  This can be used to give a player starter items specific to the quest.

|Parameter |Type    |Description
|---------:|:------:|:----------
|*player*  |`Player`| A reference to the player.

<details>
<summary>Example</summary>

```lua
    function myQuest:OnAccept(player)
        -- Run code upon initialization
    end
```
</details>

--------------------------------------------------------------------------------

### OnAssign()

`myQuest:OnAssign(player:Player)`

Called each time the player is assigned the quest.  This runs after a quest is first accepted, or when a player loads progress from a previous session.  Useful for creating gui elements needed to display a quest log.

|Parameter |Type    |Description
|---------:|:------:|:----------
|*player*  |`Player`| A reference to the player.

<details>
<summary>Example</summary>

```lua
    function myQuest:OnAssign(player)
        -- Run code upon assignment
    end
```
</details>

--------------------------------------------------------------------------------

### OnCancel()

`myQuest:OnCancel(player:Player)`

Called only when a call to *Cancel* has been made.  This can be used to fail a quest.

|Parameter |Type    |Description
|---------:|:------:|:----------
|*player*  |`Player`| A reference to the player.

<details>
<summary>Example</summary>

```lua
    function myQuest:OnCancel(player)
        -- Run code upon cancelation
    end
```
</details>

--------------------------------------------------------------------------------

### OnComplete()

`myQuest:OnComplete(player:Player)`

Called when a player has completed a quest.

|Parameter |Type    |Description
|---------:|:------:|:----------
|*player*  |`Player`| A reference to the player.

<details>
<summary>Example</summary>

```lua
    function myQuest:OnComplete(player)
        -- Run code upon completion
    end
```
</details>

--------------------------------------------------------------------------------

### OnProgress()

`myQuest:OnProgress(player:Player, progress:number, index:number)`

Called when a player has made progress.  For the first time, progress will be zero, and lastly, the progress will be equal to `myQuest:GetObjectiveValue(index)`.

|Parameter |Type    |Description
|---------:|:------:|:----------
|*player*  |`Player`| A reference to the player.
|*progress*|`number`| The objective's progress for the player.
|*index*   |`number`| The objective's index within the quest.

<details>
<summary>Example</summary>

```lua
    function myQuest:OnProgress(player, progress, index)
        print(player.Name, "has progressed to", progress, "for objective", index)
    end
```
</details>
