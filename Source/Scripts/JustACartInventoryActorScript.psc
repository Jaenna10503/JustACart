Scriptname JustACartInventoryActorScript extends Actor ; This script might be redundant tbh

; Properties
JustACartProperties property PropertyStorage auto
; Events

Event OnInit()
    self.SetActorValue("CarryWeight", 2000)
EndEvent

Event OnLoad()
    self.SetActorValue("CarryWeight", PropertyStorage.iInventoryLimit)
EndEvent