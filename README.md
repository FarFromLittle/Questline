# QuestLine

QuestLine is a server-sided module script that aids in the creation, assignment, and tracking of linear quests.

The module itself does not include data storage or visual elements.

Instead, it offers a framework to create customized quest systems that are event-driven and easily maintained.

---

## Creating QuestLines

QuestLines are created and stored within the system with a call to *new()*.

```lua
local myQuest = QuestLine.new("myQuestId")
```

The *questId* is a unique string that identifies the questline.

The questline can later be referenced as follows:

```lua
local myQuest = QuestLine.getQuestById("myQuestId")
```

---

## Adding Objectives

A *QuestLine* consists of one or more objectives in linear order.
Progression moves from objective to the next until the questline is complete.

Adding an objective takes the following form:

```lua
myQuest:AddObjective(obj:QuestLine.Objective, ...any):number
```

The *obj* parameter refers to one of the objective types.
The *...any* parameters are dependant on the type of objective.

There are a total five objective types.  Each have their own set of extra parameters.

* **QuestLine.Event** - a generic, event-based objective.
  * `event:RBXScriptSignal` - the event to listen for.
  * `count:number = 1` - number of times the event needs to fire.

* **QuestLine.Score** - a leaderstat objective.
  * `statName:string` - the name of a leaderstat.
  * `amount:number` - the amount needed to complete.

* **QuestLine.Timer** - a time-based objective.
  * `seconds:number` - number of seconds to wait.
  * `steps:number = 1` - steps of progress counted.

* **QuestLine.Touch** - a touch-based objective.
  * `touchPart:BasePart` The part to be touched.

* **QuestLine.Value** - an *IntValue* objective.
  * `intVal:IntValue` The *IntValue* to monitor.
  * `amount:number` The amount needed to complete.

As an example, the following adds an objective to touch a part named *TouchPart*.

```lua
myQuest:AddObjective(QuestLine.Touch, workspace.TouchPart)
```

---

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

---

## Assigning QuestLines

Once a player is registered, they are ready to be assigned quests.

```lua
myQuest:Assign(player)
```

This enables the system to fire the appropriate events as the player progresses.

---

## Handling Progression

Progress is tracked using callbacks related to the various stages.  A typical questline is managed by a global callback.  

The following defines a global callback that fires for every questline completed.

```lua
-- Define a global complete callback
function QuestLine:OnComplete(player)
    print(player.Name, "completed", self)
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

> Take note that both examples use a colon `:` when defining the method, which means *self* is implied.
However, when calling the global callback, a period `.` is used and *self* is passed along with the player.

Events are fired in the following order:
* *OnAccept()* fires when a player is assigned a previously unknown questline.
* *OnAssign()* fires each time a player is assigned the questline.
* *OnProgress()* triggers at each step of progression.
* *OnCancel()* only happens with a call to *Cancel()*.
* *OnComplete()* fires when a player has completed the questline.

Be aware that you can only set a callback once per context (global or local).
Setting it again will overwrite the previous behaviour.

---

## Removing Players

Upon leaving the game, the player needs to be unregistered too.

```lua
local playerData = QuestLine.unregisterPlayer(player)
```

This does a bit of cleanup and returns the player's progress to be saved into a datastore.
