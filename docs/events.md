# Event Listeners

The system fires a number of events to help track player progress.  This section outlines those events.


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

