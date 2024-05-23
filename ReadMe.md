<div align="center">

# Quest<i>line</i>

[View Source](https://github.com/FarFromLittle/QuestLine/blob/main/QuestLine.lua)

</div>

Questline is a server-sided module script that aids in the creation and tracking of quests wtihin your game.  It offers a framework to create customized questlines that are event-driven and easily maintained.

It has no dependencies, and need only be required from a server script.

``` lua
local Questline = require(game.ServerStorage.Questline)
```

## Creating Questlines

Questlines are created with a call to `new()`.  This requires a unique string used to store the questline within the system.

``` lua
local myQuest = Questline.new("myQuestId")
```

After a questline is created, it can later be retrieved with a call to `getQuestById()`.

``` lua
local myQuest = Questline.getQuestById("myQuestId")
```

## Adding Objectives

A questline consists of one or more objectives.  Progress moves from one objective to the next until it is complete.

Objectives are accessable from `Questline.Objective`.  It may be useful to store the object in a local variable.

``` lua
local Objective = Questline.Objective
```

Making the creation of objectives easier to read.

``` lua
local touchBase = Objective.touch(workspace.Baseplate)
```

It can now be added to the questline.

``` lua
myQuest:AddObjective(touchBase)
```
Or add it directly.
``` lua
myQuest:AddObjective(Objective.touch(workspace.Baseplate))
```

The `Objective` property of `Questline` contains several objective types to add to your questline.

| Objective Type | Description
|-:|:-
| `event(event, filter)` | Generic, event-based objective.
| `score(statName, targetValue)` | Leaderstat objective.
| `timer(duration)` | Timed objective.  Measured in seconds.
| `touch(touchPart)` | Touch-based objective.
| `value(intValue, targetValue)` | Based on the `Value` of an *IntValue*.

Combinations can also be made, adding variety to your questlines.

| Combination Type | Description
|-:|:-
| `all(...)` | Requires all objectives be complete.
| `any(...)` | Only one required to be complete.
| `none(...)` | Completed when all objectives are canceled.

## Assigning Questlines

Players must be registered with the system in order to track progress across sessions.

This should be done when a player joins the game.

``` lua
game.Players.PlayerAdded:Connect(function (player)
	QuestLine.registerPlayer(player)
end)
```

When a player is registered, previously incomplete questlines  will automatically be re-assigned.

The optional second parameter is used as the player's progression table.  This allows you to auto-assign starter quests.

``` lua
QuestLine.registerPlayer(player, {
	StarterQuest = 0
})
```

The _key_ in the table coincides with the `questId`, while the _value_ contains the index of the last objective complete.

Once a player is registered, they are ready to be assigned a questline.

``` lua
myQuest:Assign(player)
```

## Tracking Progress

Each objective has a variety of methods to attach custom behavior.  The following table describes each method.

| Callback | Description
|-:|:-
| `OnAssign(player)` | Triggered anytime the player is assigned the objective.
| `OnCancel(player)` | Triggered when an objective is canceled/failed.
| `OnComplete(player)` | Player has completed all requirements for the objective.

``` lua
function myQuest:OnComplete(player)
	print("Yay!,", player.Name)
end
```

These methods can be safely overridden for any objective; including questlines.


## Saving Player Data

When a player leaves the game, they need to be unregistered from the system.

``` lua
game.Players.PlayerRemoving:Connect(function (player)
	QuestLine.unregisterPlayer(player)
end
```

This saves player progress for each questline they have been assigned.

When a player is registered in a new session, progress will automatically be loaded from the datastore.

## In Conclusion

This module is intended for advanced developers, and requires a good understanding of lua scripting.

As always, feel free to post your questions, creations, and feedback below.
