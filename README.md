# Create Linear Quests with QuestLine

QuestLine is an open-source, server-sided, module script aimed to minimize the complexity of building a robust quest system.

The module itself doesn't include any gui elements or a reward system.  Instead, it offers a framework to create customized quest systems that are event-driven and easily maintained.

## Creating A QuestLine

A quest is first created by passing in two arguments.  The first being an unique identifier for the questline within the player's progression table.  Then, a table to store data related to the quest (referenced by *self* in an event listener).

```lua
local myQuest = QuestLine.new("myQuest", { Title = "My First Quest" })
```

## Adding Objectives

Now you need to construct the questline by adding a series of objectives using *AddObjective*.

```lua
myQuest:AddObjective(QuestLine.Score, "Coins", 10)
```

A current list of objectives are:

```lua
-- A generic, signal-based objective
myQuest:AddObjective(QuestLine.Event, event, count)

-- An objective based on the value of a leaderstat
myQuest:AddObjective(QuestLine.Score, name, amount)

-- A time-based objective, measured in seconds
myQuest:AddObjective(QuestLine.Timer, sec, one)

-- A simple touch-based objective
myQuest:AddObjective(QuestLine.Touch, touchPart)

-- An objective linked to an *IntValue*
myQuest:AddObjective(QuestLine.Value, intValue, amount)
```

## Assigning Quests

Players must first be registered with the system before being assigned any quests.

```lua
QuestLine.registerPlayer(player, playerData)
```

Here, *playerData* refers to the player's progression table loaded from a datastore.

After the player is registered, you can begin assigning them to your questlines:

```lua
myQuest:Assign(player)
```

It's possible to populate *playerData* with starter quests by assigning *0* to a quest's id.

```lua
local playerData = { myQuest = 0 }
```

Upon leaving the game, the player needs to be unregistered too.  This does some cleanup and returns the player's progression table to be saved in a datastore.

```lua
local playerData = QuestLine.unregisterPlayer(player)
```

Player progress is stored in a table where the _key_ is a string (which is supplied by _questId_) and the _value_ is an integer representing progression.

## Handling Progression

One way to track progression is to reassign the event listeners on the class itself.  This allows you to listen for changes on a global level.  The quest itself will still be available via *self*.

```lua
function QuestLine:OnAccept(player)
	-- Player has accepted a previously unknown quest
end

function QuestLine:OnAssign(player, progress, index)
	-- Player has accepted or resumed an incomplete quest
end

function QuestLine:OnCancel(player)
	-- Only triggered after calling Cancel on a quest
end

function QuestLine:OnComplet(player)
	-- All objectives have been passed
end

function QuestLine:OnProgress(player, progress, index)
	-- Called upon each step of progression
end
```

Additionally, these events can also be overridden on the quest itself to track progress per questline.
