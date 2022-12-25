# Getting Started

QuestLine is a server-sided module script that aids in the creation, assignment, and tracking of linear quests.

The module itself does not include data storage or visual elements.

Instead, it offers a framework to create customized quest systems that are event-driven and easily maintained.

## Creating QuestLines

To create a new questline, call *new()*, passing in a *questId*.
The *questId* is an unique string that identifies the questline within the system.

```lua
local myQuest = QuestLine.new("myQuestId")
```

## Adding Objectives

Once a questline is created, we can begin adding objectives.  This is done using *AddObjective()*.

The following adds an objective to touch a part named *TouchPart*.

```lua
myQuest:AddObjective(QuestLine.Touch, workspace.TouchPart)
```

There are a total five objective types.  Check out [objectives](https://farfromlittle.github.io/QuestLine/#objectives) for more.

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

Progress is tracked using callbacks related to the various stages.  A typical questline is managed by a global callback.  

The following defines a global callback that fires for every questline completed.

```lua
-- Define a global complete callback
function QuestLine:OnComplete(player)
    print(plr.Name, "completed", player)
end
```

Local callbacks can also be defined on individual questlines, but you may need to make a call to the global one as well.

The global callback will not run when a local one has been assigned.  This makes it necessary to do it manually.

```lua
local myQuest = QuestLine.new("myQuestId")

function myQuest:OnComplete(player)
    -- Call global callback
    QuestLine.OnComplete(self, player)
    
    -- Run custom myQuest code
end
```

Take note that both examples define the method using a colon ( : ), which means *self* is implied and is a *QuestLine*.
However, when calling a global callback, a period ( . ) is used and the questline is passed along with the player.

Events are fired in the following order:
* *OnAccept()* fires when a player is assigned a previously unknown questline.
* *OnAssign()* fires each time a player is assigned the questline.
* *OnProgress()* triggers at each step of progression.
* *OnCancel()* only happens with a call to *Cancel()*.
* *OnComplete()* fires when a player has completed the questline.

Be aware that you can only set a callback once per context (global or local).
Setting it again will overwrite the previous behaviour.

## Removing Players

Upon leaving the game, the player needs to be unregistered too.
This does a bit of cleanup and returns the player's progress to be saved in a datastore.

```lua
local playerData = QuestLine.unregisterPlayer(player)
```
