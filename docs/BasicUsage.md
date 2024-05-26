# Quest<i>line</i>

## Basic Usage

Questline aims to aid in the creation and tracking of quest across multiple sessions.

Workflow consists of creating questlines, adding objectives, and assigning players.

## Creating Questlines

Questlines are created with a call to `new()`.  This takes a unique string used to store the quest within the system.  The module uses this _questId_ as the key when storing progress in the datastore.

``` lua
local myQuest = Questline.new("myQuestId")
```

After a questline is created, it can be retrieved with a call to `getQuestById()`.

``` lua
local myQuest = Questline.getQuestById("myQuestId")
```


## Adding Objectives

A questline consists of one or more objectives.  Progress moves from one objective to the next until the quest is complete.

Objectives are accessable from `Questline.Objective`, and may be stored in a local variable.

``` lua
local Objective = Questline.Objective

local touchBase = Objective.touch(workspace.Baseplate)

myQuest:AddObjective(touchBase)
```

_Questline_ provides  several objective types to add to your quests.  Details of each can be found [here]().

Every objective, including questlines, provide a set of event handlers. This allows developers to attach customized behavior.

``` lua
function myQuest:OnComplete(player)
	print("Yay!,", player.Name)
end
```


## Assigning Questlines

Players must first register with the system.  This should be done when a player joins the game.

``` lua
game.Players.PlayerAdded:Connect(function (player)
	QuestLine.register(player)
end)
```

When a player is registered, any previously incomplete quest will automatically be re-assigned.

Once a player is registered, they are ready to be assigned a questline.

``` lua
myQuest:Assign(player)
```


## Cleaning Up

When a player leaves the game, they need to be unregistered from the system.

``` lua
game.Players.PlayerRemoving:Connect(function (player)
	QuestLine.unregisterPlayer(player)
end
```

This saves player progress for each questline they have been assigned.

When a player is registered in a new session, progress will automatically be loaded from the datastore.
