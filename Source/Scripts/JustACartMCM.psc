Scriptname JustACartMCM extends SKI_ConfigBase

; Properties
GlobalVariable property bQuickUntether auto
GlobalVariable property keyQuickUntether auto
GlobalVariable property bLimitedInventory auto
GlobalVariable property iLimitedInventory auto
GlobalVariable property bOldCart auto
Activator property OldCarriage auto
Activator property NewCarriage auto
ReferenceAlias property PlayerAlias auto
Static property XMarker auto
Worldspace property UsableWorldspaces auto
Actor property LimitedInventoryActor auto
ReferenceAlias property CarriageAlias auto
Message property DeleteMessage auto

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
string deleteCartString
string cartSpawnerString
bool deleting = false
bool summoning = false

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
    if (Game.GetPlayer().GetWorldSpace() == UsableWorldspaces) ; We're not allowing summoning anywhere other than main Tamriel worldspace
        ObjectReference marker = PlayerAlias.GetActorRef().PlaceAtMe(XMarker as form, 1, false, false)
        MoveRefToPositionRelativeTo(marker, PlayerAlias.GetActorRef() , 384)
        ObjectReference newCarriageref ; Temporary object reference variable
        if (CarriageAlias.GetRef() == none) ; If no carriage, give one
            if (bOldCart.GetValueInt() == 0) ; See old cart toggle
                newCarriageref = marker.PlaceAtMe(NewCarriage)
            else
                newCarriageref = marker.PlaceAtMe(OldCarriage)
            endif
            Utility.Wait(0.1)
            newCarriageref.SetMotionType(4) ; Set cart immobile
            marker.DisableNoWait()
            marker.Delete()
            CarriageAlias.ForceRefTo(newCarriageref) ; Set carriage alias to new cart
        elseif (CarriageAlias.GetRef() != none)
            CarriageAlias.GetRef().MoveTo(marker)
            CarriageAlias.GetRef().SetMotionType(4)
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
        ObjectReference deletedCarriage = CarriageAlias.GetRef() ; Temporary object reference variable
        Utility.Wait(0.1)
        CarriageAlias.Clear() ; Clear alias so we can delete
        Utility.Wait(0.1)
        deletedCarriage.DisableNoWait()
        deletedCarriage.Delete()
    endif
    cartSpawnerFlags = OPTION_FLAG_NONE ; Re-enable deleting option
EndFunction

; Events

Event OnPageReset(string page)
    SetCursorFillMode(LEFT_TO_RIGHT)

    int cartSpawnerHeaderID = AddHeaderOption("Cart Control")
    AddEmptyOption()

    cartSpawnerString = "Bring Cart to Player"
    if (summoning) ; If we're already summoning, change text.
        cartSpawnerString = "Return to game to finish the process"
    endif
    cartSpawnerButtonID = AddTextOption("", cartSpawnerString, cartSpawnerFlags) ; Option always enabled, unless we're either summoning or deleting

    deleteCartString = "Delete Cart"
    if (CarriageAlias.GetRef() == none) ; If no carriage, option is disabled
        deleteCartFlags = OPTION_FLAG_DISABLED
    elseif (CarriageAlias.GetRef() != none)
        if (deleting) ; If carriage and we're already deleting, change text. In this case, option is already disabled because we're currently deleting
            deleteCartString = "Return to game to finish the process"
        elseif (!summoning) ; If carriage and we're not doing anything, enable option
            deleteCartFlags = OPTION_FLAG_NONE
        endif
    endif
    deleteCartButtonID = AddTextOption("", deleteCartString, deleteCartFlags)

    int experimentalID = AddHeaderOption("Experimental Features")
    AddEmptyOption()

    if (bQuickUntether.GetValueInt() == 0)
        SetOptionFlags(quickUntetherKeyID, OPTION_FLAG_DISABLED)
    elseif (bQuickUntether.GetValueInt() == 1)
        SetOptionFlags(quickUntetherKeyID, OPTION_FLAG_NONE)
    endif
    quickUntetherToggleID = AddToggleOption("Quick Untether", bQuickUntether.GetValueInt()) ; Whether quick untether is on or not
    quickUntetherKeyID = AddKeyMapOption("Quick Untether Hotkey", keyQuickUntether.GetValueInt(), quickUntetherFlags) ; Which button quick untethers

    if (bLimitedInventory.GetValueInt() == 0)
        limitedInventoryFlags = OPTION_FLAG_DISABLED
    elseif (bLimitedInventory.GetValueInt() == 1)
        limitedInventoryFlags = OPTION_FLAG_NONE
    endif
    limitedInventoryToggleID = AddToggleOption("Limited Inventory", bLimitedInventory.GetValueInt()) ; Whether limited inventory is on or not
    limitedInventorySliderID = AddSliderOption("Max Inventory Weight", iLimitedInventory.GetValueInt() as float, "", limitedInventoryFlags) ; Change inventory weight limit

    oldCartToggleID = AddToggleOption("Use base game cart", bOldCart.GetValueInt()) ; What it says on the tin
EndEvent

Event OnOptionSelect(int option)
    if (option == quickUntetherToggleID) ; Implementing quick untether toggle
        if (bQuickUntether.GetValueInt() == 0)
            bQuickUntether.SetValueInt(1)
        else
            bQuickUntether.SetValueInt(0)
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
    ElseIf (option == limitedInventoryToggleID) ; Implementing limited inventory toggle
        if (bLimitedInventory.GetValueInt() == 0)
            bLimitedInventory.SetValueInt(1)
        else
            bLimitedInventory.SetValueInt(0)
        endif
    ElseIf (option == oldCartToggleID) ; Implementing old cart toggle
        if (bOldCart.GetValueInt() == 0)
            bOldCart.SetValueInt(1)
        else
            bOldCart.SetValueInt(0)
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
            keyQuickUntether.SetValueInt(keyCode)
            SetKeyMapOptionValue(option, keyCode)
            keyQuickUntether.SetValueInt(keyCode)
        endif
    endif
    ForcePageReset() ; Make changes visible
EndEvent

Event OnOptionSliderOpen(int option) ; Implementing limited inventory slider
    if (option == limitedInventorySliderID)
        SetSliderDialogStartValue(iLimitedInventory.GetValueInt() as float)
        SetSliderDialogDefaultValue(2000.0)
        SetSliderDialogRange(0.0, 10000.0)
        SetSliderDialogInterval(50.0)
    endif
EndEvent

Event OnOptionSliderAccept (int option, float value) ; Ditto
    if (option == limitedInventorySliderID)
        iLimitedInventory.SetValueInt(value as int)
        SetSliderOptionValue(limitedInventorySliderID, iLimitedInventory.GetValueInt() as float)
        LimitedInventoryActor.SetActorValue("CarryWeight", iLimitedInventory.GetValueInt())
    endif
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
        SetInfoText("Delete the cart so you can get a new one.")
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