# Create Linear Quests with QuestLine

QuestLine is an open-source, stand-a-lone, module script aimed at advanced developers to minimize the complexity of building a robust quest system.

## Creating A QuestLine

A quest is first created by passing in two arguments.  The first being an unique identifier for the questline within the player's progression table.  The second parameter is a table to store data related to the quest (referenced by *self* in an event listener).

```lua
local myQuest = QuestLine.new("myQuest", { Title = "My First Quest" })
```

## Adding Objectives

Now you need to construct the questline by adding a series of objectives using *AddObjective*.

```lua
local obj, val = QuestLine.Score("Coins", 10)
myQuest:AddObjective(obj, val)

-- or more simply
myQuest:AddObjective(QuestLine.Score("Coins", 10))
```

Notice how *AddObjective* accepts two arguments.  A *thread* and an integer representing the value of the objective.  Both are returned from a call to one of the following objectives.

```lua
-- A generic, signal-based objective
QuestLine.Event(event:RBXScriptSignal, count:number?)

-- An objective based on the value of a leaderstat
QuestLine.Score(name:string, amount:number)

-- A time-based objective, measured in seconds
QuestLine.Timer(sec:number, one:boolean?)

-- A simple touch-based objective
QuestLine.Touch(touchPart:Basepart)

-- An objective linked to an *IntValue*
QuestLine.Value(intValue:IntValue, amount:number)
```

## Assigning Quests

Players must first be registered with the system before being assigned any quests.

```lua
QuestLine.registerPlayer(player:Player, playerData:{[string]:number})
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
function QuestLine:Accepted(player)
	-- Player has accepted a previously unknown quest
end

function QuestLine:Assigned(player, progress, index)
	-- Player has accepted or resumed an incomplete quest
end

function QuestLine:Canceled(player)
	-- Only triggered after calling Cancel on a quest
end

function QuestLine:Completed(player)
	-- All objectives have been passed
end

function QuestLine:Progressed(player, progress, index)
	-- Called upon each step of progression
end
```
Additionally, these events can also be overridden on the quest itself to track progress per questline.
