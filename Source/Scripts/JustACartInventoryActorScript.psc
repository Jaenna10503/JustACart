Scriptname JustACartInventoryActorScript extends Actor ; This script might be redundant tbh

; Properties

GlobalVariable property WeightLimit auto

; Events

Event OnInit()
    self.SetActorValue("CarryWeight", WeightLimit.GetValueInt())
EndEvent