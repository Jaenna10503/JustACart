Scriptname JustACartMCM extends SKI_ConfigBase

; Properties
Activator property OldCarriage auto
Activator property NewCarriage auto
Static property XMarker auto
Worldspace property UsableWorldspaces auto
Actor property LimitedInventoryActor auto
Message property DeleteMessage auto
JustACartProperties property PropertyStorage auto

; Variables
int quickUntetherToggleID
int quickUntetherKeyID
int quickUntetherFlags
int limitedInventoryToggleID
int limitedInventorySliderID
int limitedInventoryInt
int limitedInventoryFlags
int cartSpawnerFlags
int cartSpawnerButtonID
int oldCartToggleID
int deleteCartFlags
int deleteCartButtonID
int horseFinderButtonID
int worldSpaceToggleID
string deleteCartString
string cartSpawnerString
bool deleting = false
bool summoning = false
ObjectReference Carriage

; Functions

; (Shamelessly) Copied from UESP's CreationKit Wiki
Function MoveRefToPositionRelativeTo(ObjectReference akSubject, ObjectReference akTarget, Float OffsetDistance = 0.0, \
  Float OffsetAngle = 0.0, bool FaceTarget = False) Global
	float AngleZ = akTarget.GetAngleZ() + OffsetAngle
	float OffsetX = OffsetDistance * Math.Sin(AngleZ)
	float OffsetY = OffsetDistance * Math.Cos(AngleZ)
	akSubject.MoveTo(akTarget, OffsetX, OffsetY, 0.0)
	if (FaceTarget)
		akSubject.SetAngle(akSubject.GetAngleX(), akSubject.GetAngleY(), akSubject.GetAngleZ() + \
		  akSubject.GetHeadingAngle(akTarget))
	endif
EndFunction

; Summons the cart
Function SummonCart()
    if (Game.GetPlayer().GetWorldSpace() == UsableWorldspaces || PropertyStorage.bExpandedWorldSpaces == true) ; We're not allowing summoning anywhere other than main Tamriel worldspace, unless you really want to
        ObjectReference marker = Game.GetPlayer().PlaceAtMe(XMarker as form, 1, false, false)
        MoveRefToPositionRelativeTo(marker, Game.GetPlayer() , 384)
        ObjectReference newCarriageref ; Temporary object reference variable
        if (carriage == none) ; If no carriage, give one
            if (PropertyStorage.bOldCart == 0) ; See old cart toggle
                newCarriageref = marker.PlaceAtMe(NewCarriage)
            else
                newCarriageref = marker.PlaceAtMe(OldCarriage)
            endif
            Utility.Wait(0.1)
            newCarriageref.SetMotionType(4) ; Set cart immobile
            marker.DisableNoWait()
            marker.Delete()
            carriage = newCarriageref ; Set carriage alias to new cart
        elseif (carriage != none)
            carriage.MoveTo(marker)
            carriage.SetMotionType(4)
            marker.DisableNoWait()
            marker.Delete()
        endif
        newCarriageref = none ; Clean up the object reference variable because we no longer need it... Might be unnecessary
    else
        Debug.Notification("You can't summon a cart here.")
    endif
    cartSpawnerFlags = OPTION_FLAG_NONE ; Re-enable summoning option
EndFunction

; Deletes the cart
Function DeleteCart()
    int optionSelected = DeleteMessage.Show()
    if (optionSelected == 0)
        ; return
    elseif (optionSelected == 1)
        ObjectReference deletedCarriage = carriage ; Temporary object reference variable
        Utility.Wait(0.1)
        carriage = none ; Clear alias so we can delete
        Utility.Wait(0.1)
        deletedCarriage.DisableNoWait()
        deletedCarriage.Delete()
    endif
    cartSpawnerFlags = OPTION_FLAG_NONE ; Re-enable deleting option
EndFunction

; Events

Event OnPageReset(string page)
    SetCursorFillMode(LEFT_TO_RIGHT)

    LimitedInventoryActor.SetActorValue("CarryWeight", PropertyStorage.iInventoryLimit)

    int cartSpawnerHeaderID = AddHeaderOption("Cart Control")
    AddEmptyOption()

    cartSpawnerString = "Bring Cart to Player"
    if (summoning) ; If we're already summoning, change text.
        cartSpawnerString = "Return to game to finish the process"
    endif
    cartSpawnerButtonID = AddTextOption("", cartSpawnerString, cartSpawnerFlags) ; Option always enabled, unless we're either summoning or deleting

    deleteCartString = "Delete Cart"
    if (carriage == none) ; If no carriage, option is disabled
        deleteCartFlags = OPTION_FLAG_DISABLED
    elseif (carriage != none)
        if (deleting) ; If carriage and we're already deleting, change text. In this case, option is already disabled because we're currently deleting
            deleteCartString = "Return to game to finish the process"
        elseif (!summoning) ; If carriage and we're not doing anything, enable option
            deleteCartFlags = OPTION_FLAG_NONE
        endif
    endif
    deleteCartButtonID = AddTextOption("", deleteCartString, deleteCartFlags)

    int optionalID = AddHeaderOption("Optional Features")
    AddEmptyOption()

    if (PropertyStorage.bQuickUntether == 0)
        SetOptionFlags(quickUntetherKeyID, OPTION_FLAG_DISABLED)
    elseif (PropertyStorage.bQuickUntether == 1)
        SetOptionFlags(quickUntetherKeyID, OPTION_FLAG_NONE)
    endif
    quickUntetherToggleID = AddToggleOption("Quick Untether", PropertyStorage.bQuickUntether) ; Whether quick untether is on or not
    quickUntetherKeyID = AddKeyMapOption("Quick Untether Hotkey", PropertyStorage.keyQuickUntether, quickUntetherFlags) ; Which button quick untethers

    if (PropertyStorage.bLimitedInventory == 0)
        limitedInventoryFlags = OPTION_FLAG_DISABLED
    elseif (PropertyStorage.bLimitedInventory == 1)
        limitedInventoryFlags = OPTION_FLAG_NONE
    endif
    limitedInventoryToggleID = AddToggleOption("Limited Inventory", PropertyStorage.bLimitedInventory) ; Whether limited inventory is on or not
    limitedInventorySliderID = AddSliderOption("Max Inventory Weight", PropertyStorage.iInventoryLimit, "{0}", limitedInventoryFlags) ; Change inventory weight limit

    oldCartToggleID = AddToggleOption("Use base game cart", PropertyStorage.bOldCart) ; What it says on the tin
    AddEmptyOption()

    int experimentalID = AddHeaderOption("Experimental Features")
    AddEmptyOption()

    horseFinderButtonID = AddToggleOption("Use Expanded Compatibility Horse Finder", PropertyStorage.bUseExperimentalHorseFinder)
    worldSpaceToggleID = AddToggleOption("Allow Other World Spaces", PropertyStorage.bExpandedWorldSpaces)
EndEvent

Event OnOptionSelect(int option)
    if (option == quickUntetherToggleID) ; Implementing quick untether toggle
        if (PropertyStorage.bQuickUntether == 0)
            PropertyStorage.bQuickUntether = 1
        else
            PropertyStorage.bQuickUntether = 0
        endif
    elseif (option == cartSpawnerButtonID) ; Implementing cart spawner button. We're doing something, so cart controls go off, and we're specifying that we're summoning
        cartSpawnerFlags = OPTION_FLAG_DISABLED
        deleteCartFlags = OPTION_FLAG_DISABLED
        summoning = true
        RegisterForSingleUpdateGameTime(0.0) ; Putting the thing in a during game time event so that the player is more likely to see the error notification
    elseif (option == deleteCartButtonID) ; Implementing cart delete button. We're doing something, so cart controls go off, and we're specifying that we're deleting
        deleteCartFlags = OPTION_FLAG_DISABLED
        cartSpawnerFlags = OPTION_FLAG_DISABLED
        deleting = true
        RegisterForSingleUpdateGameTime(0.0) ; This is more for symmetry and usefulness
    elseif (option == limitedInventoryToggleID) ; Implementing limited inventory toggle
        if (PropertyStorage.bLimitedInventory == 0)
            PropertyStorage.bLimitedInventory = 1
        else
            PropertyStorage.bLimitedInventory = 0
        endif
    elseif (option == oldCartToggleID) ; Implementing old cart toggle
        if (PropertyStorage.bOldCart == 0)
            PropertyStorage.bOldCart = 1
        else
            PropertyStorage.bOldCart = 0
        endif
    elseif (option == horseFinderButtonID)
        if (PropertyStorage.bUseExperimentalHorseFinder == 0)
            PropertyStorage.bUseExperimentalHorseFinder = 1
        else
            PropertyStorage.bUseExperimentalHorseFinder = 0
        endif
    elseif (option == worldSpaceToggleID)
        if (PropertyStorage.bExpandedWorldSpaces == 0)
            PropertyStorage.bExpandedWorldSpaces = 1
        else
            PropertyStorage.bExpandedWorldSpaces = 0
        endif
    endif
    ForcePageReset() ; Make changes visible
EndEvent

Event OnOptionKeyMapChange(int option, int keyCode, string conflictControl, string conflictName) ; Implementing quick untether key changing option.
    if (option == quickUntetherKeyID)
        bool continue = true
        if (conflictControl != "")
			string msg

			if (conflictName != "")
				msg = "This key is already mapped to:\n'" + conflictControl + "'\n(" + conflictName + ")\n\nAre you sure you want to continue?"
			else
				msg = "This key is already mapped to:\n'" + conflictControl + "'\n\nAre you sure you want to continue?"
			endIf

			continue = ShowMessage(msg, true, "$Yes", "$No")
		endIf
        if (continue)
            PropertyStorage.keyQuickUntether = keyCode
            SetKeyMapOptionValue(option, keyCode)
            PropertyStorage.keyQuickUntether = keyCode
        endif
    endif
    ForcePageReset() ; Make changes visible
EndEvent

Event OnOptionSliderOpen(int option) ; Implementing limited inventory slider
    if (option == limitedInventorySliderID)
        SetSliderDialogStartValue(PropertyStorage.iInventoryLimit as float)
        SetSliderDialogDefaultValue(2000.0)
        SetSliderDialogRange(0.0, 10000.0)
        SetSliderDialogInterval(50.0)
    endif
EndEvent

Event OnOptionSliderAccept (int option, float value) ; Ditto
    if (option == limitedInventorySliderID)
        PropertyStorage.iInventoryLimit = value as int
        SetSliderOptionValue(limitedInventorySliderID, PropertyStorage.iInventoryLimit as float)
    endif
    LimitedInventoryActor.SetActorValue("CarryWeight", PropertyStorage.iInventoryLimit)
EndEvent

Event OnOptionHighlight (int option) ; Quick explanation of what different options do
    if (option == quickUntetherToggleID)
        SetInfoText("Quickly untether your horse from the cart without dismounting.")
    elseif (option == cartSpawnerButtonID)
        SetInfoText("If cart exists, moves it in front of player. If cart doesn't exist, spawns one instead. Best used on an empty stretch of road.")
    elseif (option == limitedInventoryToggleID)
        SetInfoText("Set a limit for how much weight the cart can carry.")
    elseif (option == oldCartToggleID)
        SetInfoText("Use a model from the base game for the cart. Warning: Once you have spawned a cart, you won't be able to change its model.")
    elseif (option == deleteCartButtonID)
        SetInfoText("Deletes the cart so you can get a new one.")
    elseif (option == horseFinderButtonID)
        SetInfoText("Using this option makes the carriage consider any horse nearby, not just ones you own. Take care not to use this with an unowned horse nearby.")
    elseif (option == worldSpaceToggleID)
        SetInfoText("Allow carriage to be summoned anywhere. Take care not to summon it in enclosed spaces, or where there's not enough room.")
    endif
EndEvent

Event OnUpdateGameTime() ; Final implementation of summoning and deleting
    if (summoning)
        SummonCart()
    elseif (deleting)
        DeleteCart()
    endif
    deleting = false
    summoning = false ; We're no longer doing either of these, so switch both false so we can do them again. Note the lack of flag setting here, because we want to keep those two separate
EndEvent