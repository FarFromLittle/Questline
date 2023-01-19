QuestLine
=========

QuestLine is a server-sided module script that aids in the creation, assignment, and tracking of linear quests.

The module itself does not include data storage or visual elements.

Instead, it offers a framework to create customized quest systems that are event-driven and easily maintained.

Getting Started
---------------

QuestLines are created and stored within the system with a call to *new()*.

```lua
local myQuest = QuestLine.new("myQuestId")
```

The *questId* is a unique string that identifies the questline.

The questline can later be referenced as follows:

```lua
local myQuest = QuestLine.getQuestById("myQuestId")
```

Adding Objectives
-----------------

A *QuestLine* consists of one or more objectives in a linear fashion.
Progress moves from one objective to the next until the questline is complete.

> Implementing branching, side, or multi-task quests requires the use of multiple questlines and the appropriate callback functions.

Adding an objective takes the following form:

```lua
myQuest:AddObjective(objType, ...any)
```

The *objType* parameter refers to one of the objective types.
The *...any* parameters are dependant on the type of objective.

There are a total five objective types.  Each having their own set of parameters.

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
  * `touchPart:BasePart` - part to be touched.

* **QuestLine.Value** - an objective based on an *IntValue*.
  * `intVal:IntValue` - *IntValue* to monitor.
  * `amount:number` - amount needed to complete.

As an example, the following adds an objective to *score* three apples.
Then, another to return the apples to a drop off point.

```lua
myQuest:AddObjective(QuestLine.Score, "Apples", 3)
myQuest:AddObjective(QuestLine.Touch, workspace.DropOff)
```

Adding Players
--------------

Players must first register with the system before being assigned a questline.
This takes an instance of *player* and their progress table loaded from a datastore.

```lua
QuestLine.registerPlayer(player, playerData)
```

Player progression is stored in a table under the key supplied by *questId*.

Additionally, this table can be pre-populated with starter quests by assigning zero to an entry.

```lua
local playerData = {
	myQuestId = 0 -- Assign zero for auto-accept
}
```

Assigning QuestLines
--------------------

Once a player is registered, they are ready to be assigned quests.

```lua
myQuest:Assign(player)
```

This will fire the *OnAccept()* callback and add an entry of `myQuestId = 0` to the player's progress table.

When a player is registered, all questlines not found to be complete will automatically be assigned.

Handling Progression
--------------------

Events are triggered using callbacks related to the various stages of progression.

Events are fired in the following order:

* `OnAccept(player:Player)`
  * Fires when a player is assigned a previously unknown questline.
  
* `OnAssign(player:Player)`
  * Fires each time a player is assigned the questline.
  * This includes when a player resumes progress from a previous session.
  
* `OnProgress(player:Player, progress:number, objIndex:number)`
  * Triggers at each step of progression.
  * The first event fires with `progress = 0`
  * Lastly with `progress = myQuest:GetObjectiveValue(objIndex)`.
  
* `OnComplete(player:Player)`
  * Fires when a player has completed the questline.
  
* `OnCancel(player:Player)`
  * Only triggered by a call to `myQuest:Cancel(player)`.
  * Can be used to fail a questline.
  * A canceled questline can be re-accepted.

A typical questline is managed by a global callback function.  

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

Be aware that you can only set a callback once per context (global or local).
Setting it again will overwrite the previous behavior.

Removing Players
----------------

Upon leaving the game, the player needs to be unregistered too.

```lua
local playerData = QuestLine.unregisterPlayer(player)
```

This does some cleanup and returns the player's progress to be saved in a datastore.

