<div align="center">

# [![banner|690x215](../images/banner.png)](https://github.com/FarFromLittle/QuestLine)

[[ Demo ]](https://www.roblox.com/games/11817280372/Qtest) [[ Docs ]](https://github.com/FarFromLittle/Questline/tree/main/docs) [[ Source ]](https://github.com/FarFromLittle/Questline/tree/main/src)

</div>

> **Please notice:** Quest<i>line</i> is intended for advanced developers, and __requires__ a decent understanding of the Roblox scripting language.

Quest<i>line</i> is a server-sided Roblox module that aids in the creation and tracking of Quest<i>lines</i>.

Typically, a Quest<i>line</i> is a sequence of objectives the player must accomplish to acheive a goal.

This guide aims to be a quick explaination on how to use Quest<i>line</i>.

## 🚀 Getting Started

Quest<i>line</i> __requires__ a _questId_ to represent each Quest<i>line</i> within the system.

```lua
local Questline = require(game.ServerStorage.Questline)

local myQuest = Questline.new("MyQuest")
```

You can then retrieve a previously created Quest<i>line</i>.

```lua
local myQuest = Questline.getQuestById("MyQuest")
```

## ✅ Adding Objectives

 The `Objective` property of Quest<i>line</i> hosts the various objective types.

```lua
local Objective = Questline.Objective
```

An objective requires it's own set of parameters; according to it's function.

```lua
local touchBase = Objective.touch(workspace.Baseplate)
```

Objectives can be grouped together, allowing you to create branching Quest<i>lines</i>.

```lua
local clickOne = Objective.click(workspace.PartOne)
local clickTwo = Objective.click(workspace.PartTwo)

local chooseOne = Objective.any(clickOne, clickTwo)
```

Finally, objectives are added to a Quest<i>line</i>.

```lua
myQuest:AddObjective(touchBase)
```

### Objective Types

Several objective types exist for use in your experience.

|Objective Type|Params|Description
|-:|:-|:-
| `all`|`(...)`| Requires completion of __all__ given objectives.
| `any`|`(...)`| Requires only __one__ given objective to be complete.
|`none`|`(...)`| Canceled upon completion of __any__ given objective.

|Objective Type|Params|Description
|-:|:-|:-
|`event`|`(event, filter)`        |Generic, event-based objective.
|`score`|`(statName, targetValue)`|Tracks the value of a _leaderstat_.
|`timer`|`(duration)`             |Timed objective.  Measured in seconds.
|`touch`|`(touchPart)`            |Touch-based objective.
|`value`|`(intValue, targetValue)`|Objective based on a [_playerstat_](https://github.com/FarFromLittle/Questline/blob/main/docs/Playerstats.md).

## 🔔 Attaching Events

Quest<i>lines</i> have several events associated with them, allowing developers to attach custom behaviour.

```lua
function myQuest:OnComplete(player)
	print("Yay!,", player)
end

function myQuest:OnCancel(player)
	print(player, "failed!")
end
```

>#### 💡 Note:
> Each event type can only be assigned to once.  Subsequent assignments will overwrite behavior.

### Event Types

The following event types are found on a Quest<i>line</i>.

|BindableEvent|Arguments|Description
|-:|:-:|:-
|`OnAccept`|`(player)`| Fired when _player_ is assigned a Quest<i>line</i> for the first time.
|`OnAssign`|`(player, progress)`| Fired when _player_ is assigned, including subsequent sessions.
|`OnCancel`|`(player)`| Fired with call to `Cancel`; triggered by `Objective.none`.
|`OnComplete`|`(player)`| Fired when _player_ has completed the Quest<i>line</i>.
|`OnProgress`|`(player, progress)`| Fired when _player_ has completed an objective.

## 🧲 Assigning Players

You __must__ register players to assign Quest<i>lines</i>.  Preferably, when a player first joins an experience.

```lua
game.Players.PlayerAdded:Connect(function (player)
	Questline.register(player)
end)
```

Quest<i>lines</i> are assigned, for example, when a player touches a part.

```lua
workspace.QuestGiver.Touch:Connect(function (hitPart)
	local player = game.Players:GetPlayerFromCharacter(hitPart.Parent)

	if player and not myQuest:IsConnected(player) then
		myQuest:Assign(player)
	end
end)
```

## 💩 Cleaning Up

When leaving, the player __must__ unregister.
This removes _player_ and cleans up any loose connections.

``` lua
game.Players.PlayerRemoving:Connect(function (player)
	Questline.unregister(player)
end
```

And that's it!  Now you can start creating your very own Quest<i>lines</i>.  And remember...

### 😎 Keep Cool & Be Kind

Quest<i>line</i> is made out of ❤️, not only for games, but for those that create them.  And that's __you__! 
