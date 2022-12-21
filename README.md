# Getting Started

QuestLine is a server-sided module script that aids in the creation, assignment, and tracking of quests.

The module itself does not include data storage or visual elements.

However, you can download the example above which includes a simple quest tracking system.

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

There are a total five objective types and are outlined [here](https://farfromlittle.github.io/QuestLine/#types).

## Adding Players

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

Once a player is registered, they are ready to be assigned quests.

```lua
myQuest:Assign(player)
```

This enables the system to fire the appropriate events as the player progresses.

## Handling Progression

Events are fired in the following order:
* *OnAccept()* will only fire if a player is assigned a previously unknown questline.  This would be useful for giving out quest items.
* *OnAssign()* fires each time a player is assigned a questline.  This could be when a player resumes progress from a previous session.
* *OnProgress()* happens at each step of progression.  This includes a progress of zero when initialized.  Useful for updating gui elements.
* *OnCancel()* only happens with a call to *Cancel()*.  A questline can be restarted after being canceled.  Can be used to fail a questline.
* *OnComplete()*, as expected, fires when a player has completed the questline.

See the section on [events](https://farfromlittle.github.io/QuestLine/#events) for more details.

To track player progression, you must override the appropriate event listeners.

```lua
function myQuest:OnComplete(plr)
	print(plr.Name, "completed", self)
end
```

Event listeners can be assigned per questline or on the class itself to globally track progress.

## Removing Players

Upon leaving the game, the player needs to be unregistered too.
This does a bit of cleanup and returns the player's progress to be saved in a datastore.

```lua
local playerData = QuestLine.unregisterPlayer(player)
```
