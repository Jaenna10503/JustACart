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
int cartSpawnerButtonID
int oldCartToggleID
int deleteCartButtonID

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

; Events

Event OnPageReset(string page)
    SetCursorFillMode(LEFT_TO_RIGHT)

    int cartSpawnerHeaderID = AddHeaderOption("Cart Control")
    AddEmptyOption()
    cartSpawnerButtonID = AddTextOption("", "Bring Cart to Player")
    deleteCartButtonID = AddTextOption("", "Delete Cart")
    int experimentalID = AddHeaderOption("Experimental Features")
    AddEmptyOption()

    if (bQuickUntether.GetValueInt() == 0)
        quickUntetherFlags = OPTION_FLAG_DISABLED
    elseif (bQuickUntether.GetValueInt() == 1)
        quickUntetherFlags = OPTION_FLAG_NONE
    endif
    quickUntetherToggleID = AddToggleOption("Quick Untether", bQuickUntether.GetValueInt())
    quickUntetherKeyID = AddKeyMapOption("Quick Untether Hotkey", keyQuickUntether.GetValueInt(), quickUntetherFlags)
    if (bLimitedInventory.GetValueInt() == 0)
        limitedInventoryFlags = OPTION_FLAG_DISABLED
    elseif (bLimitedInventory.GetValueInt() == 1)
        limitedInventoryFlags = OPTION_FLAG_NONE
    endif
    limitedInventoryToggleID = AddToggleOption("Limited Inventory", bLimitedInventory.GetValueInt())
    limitedInventorySliderID = AddSliderOption("Max Inventory Weight", iLimitedInventory.GetValueInt() as float, "", limitedInventoryFlags)
    oldCartToggleID = AddToggleOption("Use base game cart", bOldCart.GetValueInt())
EndEvent

Event OnOptionSelect(int option)
    if (option == quickUntetherToggleID)
        if (bQuickUntether.GetValueInt() == 0)
            bQuickUntether.SetValueInt(1)
        else
            bQuickUntether.SetValueInt(0)
        endif
    elseif (option == cartSpawnerButtonID)
        RegisterForSingleUpdateGameTime(0.0) ; Putting the thing in a during game time event so that the player is more likely to see the error notification
    elseif (option == deleteCartButtonID)
        int optionSelected = DeleteMessage.Show()
        if (optionSelected == 0)
            ; return
        elseif (optionSelected == 1)
            ObjectReference deletedCarriage = CarriageAlias.GetRef()
            CarriageAlias.Clear()
            Utility.Wait(0.1)
            deletedCarriage.DisableNoWait()
            deletedCarriage.Delete()
        endif
    ElseIf (option == limitedInventoryToggleID)
        if (bLimitedInventory.GetValueInt() == 0)
            bLimitedInventory.SetValueInt(1)
        else
            bLimitedInventory.SetValueInt(0)
        endif
    ElseIf (option == oldCartToggleID)
        if (bOldCart.GetValueInt() == 0)
            bOldCart.SetValueInt(1)
        else
            bOldCart.SetValueInt(0)
        endif
    endif
    ForcePageReset()
EndEvent

Event OnOptionKeyMapChange(int option, int keyCode, string conflictControl, string conflictName)
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
    ForcePageReset()
EndEvent

Event OnOptionSliderOpen(int option)
    if (option == limitedInventorySliderID)
        SetSliderDialogStartValue(iLimitedInventory.GetValueInt() as float)
        SetSliderDialogDefaultValue(2000.0)
        SetSliderDialogRange(0.0, 10000.0)
        SetSliderDialogInterval(50.0)
    endif
EndEvent

Event OnOptionSliderAccept (int option, float value)
    if (option == limitedInventorySliderID)
        iLimitedInventory.SetValueInt(value as int)
        SetSliderOptionValue(limitedInventorySliderID, iLimitedInventory.GetValueInt() as float)
        LimitedInventoryActor.SetActorValue("CarryWeight", iLimitedInventory.GetValueInt())
    endif
EndEvent

Event OnOptionHighlight (int option)
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

Event OnUpdateGameTime()
    if (Game.GetPlayer().GetWorldSpace() == UsableWorldspaces)
        ObjectReference marker = PlayerAlias.GetActorRef().PlaceAtMe(XMarker as form, 1, false, false)
        MoveRefToPositionRelativeTo(marker, PlayerAlias.GetActorRef() , 384)
        ObjectReference newCarriageref
        if (CarriageAlias.GetRef() == none)
            if (bOldCart.GetValueInt() == 0)
                newCarriageref = marker.PlaceAtMe(NewCarriage)
            elseif (bOldCart.GetValueInt() == 1)
                newCarriageref = marker.PlaceAtMe(OldCarriage)
            endif
            Utility.Wait(0.1)
            newCarriageref.SetMotionType(4)
            marker.DisableNoWait()
            marker.Delete()
            CarriageAlias.ForceRefTo(newCarriageref)
        elseif (CarriageAlias.GetRef() != none)
            CarriageAlias.GetRef().MoveTo(marker)
            CarriageAlias.GetRef().SetMotionType(4)
            marker.DisableNoWait()
            marker.Delete()
        endif
        newCarriage = none
    else
        Debug.Notification("You can't summon a cart here.")
    endif
EndEvent