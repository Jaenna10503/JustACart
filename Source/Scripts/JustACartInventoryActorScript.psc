Scriptname JustACartInventoryActorScript extends Actor

; Properties

GlobalVariable property WeightLimit auto

; Events

Event OnInit()
    self.SetActorValue("CarryWeight", WeightLimit.GetValueInt())
EndEvent