# Getting Started

QuestLine is a server-sided module script that aids in the creation, assignment, and tracking of quests.
The module itself does not include data storage or visual elements.
However, you can find an example of a quest tracking system [here](https://github.com/FarFromLittle/QuestLine/).

## Creating QuestLines

To create a new questline, call `QuestLine.new()`, passing in a *questId*.
The *questId* is an unique string that identifies the questline within the system.

```lua
local myQuest = QuestLine.new("myQuestId")
```

## Adding Objectives

Once a questline is created, we can begin adding objectives.  This is done using the *AddObjective()* method.

The following adds an objective to touch a part in the workspace named *TouchPart*.

```lua
myQuest:AddObjective(QuestLine.Touch, workspace.TouchPart)
```

There are a total five objective types and can be found [here](https://farfromlittle.github.io/QuestLine/docs/#enums).

## Player Set-Up

Players must first register with the system before being assigned a questline.

```lua
QuestLine.registerPlayer(player, playerData)
```

Player progression is stored in a table where progress is stored under the key supplied by *questId*.
This would normaly be loaded from a datastore.

Additionaly, this table can be populated with starter quests by assigned zero to an entry.

```lua
local playerData = {
	myQuestId = 0 -- Assign zero for auto-accept
}
```

## Assigning QuestLines

The player is now ready to start accepting quests.

```lua
myQuest:Assign(player)
```

## Handling Progression

To track player progression, you must override the appropriate event listeners.

```lua
function myQuest:OnComplete(plr)
	print(plr.Name, "completed", self)
end
```

Event listeners can be assigned per questline or on the class itself to globally track progress.

The available events are listed [here](https://farfromlittle.github.io/QuestLine/docs/#onaccept).

## Removing Players

Upon leaving the game, the player needs to be unregistered too.
This does a bit of cleanup and returns the player's progress to be saved in a datastore.

```lua
local playerData = QuestLine.unregisterPlayer(player)
```
