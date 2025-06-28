Scriptname JustACartProperties extends Quest  

; Properties
int property bQuickUntether auto
int property keyQuickUntether auto
int property bLimitedInventory auto
int property bOldCart auto
int property bUseExperimentalHorseFinder auto
int property iInventoryLimit auto
bool property bRiding auto
bool property bTethered auto
int property bExpandedWorldSpaces auto

; Variables

; Functions

; Events

Event OnInit()
    bQuickUntether = 0
    keyQuickUntether = 34
    bLimitedInventory = 0
    bOldCart = 0
    bUseExperimentalHorseFinder = 0
    iInventoryLimit = 2000
    bRiding = false
    bTethered = false
    bExpandedWorldSpaces = 0
EndEvent