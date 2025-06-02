Scriptname JustACartMCM extends SKI_ConfigBase

; Properties
GlobalVariable property bQuickUntether auto
GlobalVariable property keyQuickUntether auto
Activator property Carriage auto
ReferenceAlias property PlayerAlias auto
Static property XMarker auto
Worldspace property UsableWorldspaces auto

; Variables
int quickUntetherToggleID
int quickUntetherKeyID
int quickUntetherFlags
int cartSpawnerButtonID
ObjectReference newCarriage

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
    cartSpawnerButtonID = AddTextOption("", "Bring Cart to Player")
    int experimentalID = AddHeaderOption("Experimental Features")
    AddEmptyOption()

    if (bQuickUntether.GetValueInt() == 0)
        quickUntetherFlags = OPTION_FLAG_DISABLED
    elseif (bQuickUntether.GetValueInt() == 1)
        quickUntetherFlags = OPTION_FLAG_NONE
    endif
    quickUntetherToggleID = AddToggleOption("Quick Untether", bQuickUntether.GetValueInt())
    quickUntetherKeyID = AddKeyMapOption("Quick Untether Hotkey", keyQuickUntether.GetValueInt(), quickUntetherFlags)
    
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

Event OnOptionHighlight (int option)
    if (option == quickUntetherToggleID)
        SetInfoText("Quickly untether your horse from the cart without dismounting.")
    elseif (option == quickUntetherKeyID)
        SetInfoText("NB: The cart will still listen for the old hotkey until you untether and re-tether the horse.")
    elseif (option == cartSpawnerButtonID)
        SetInfoText("If cart exists, moves it in front of player. If cart doesn't exist, spawns one instead. Best used on an empty stretch of road.")
    endif
EndEvent

Event OnUpdateGameTime()
    if (Game.GetPlayer().GetWorldSpace() == UsableWorldspaces)
        ObjectReference marker = PlayerAlias.GetActorRef().PlaceAtMe(XMarker as form, 1, false, false)
        MoveRefToPositionRelativeTo(marker, PlayerAlias.GetActorRef() , 384)
        if (newCarriage == none)
            newCarriage = marker.PlaceAtMe(Carriage)
            Utility.Wait(0.1)
            newCarriage.SetMotionType(4)
            marker.DisableNoWait()
            marker.Delete()
        elseif (newCarriage != none)
            newCarriage.MoveTo(marker)
            newCarriage.SetMotionType(4)
            marker.DisableNoWait()
            marker.Delete()
        endif
    else
        Debug.Notification("You can't summon a cart here.")
    endif
EndEvent