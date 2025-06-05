Scriptname JustACartCarriageScript extends ObjectReference


;/ TO DO LIST: 

Necessities:

Possible future features:
-Cargo weight limit? Doable, but might cost a bit too much processing when calculating the weight. I'll have to look into that more
-Also, might take another look at the OnKeyUp
-Place to get the cart. Bandit cave just North of Whiterun is prime option, secondary options are the carts strewn around as unmarked locations.
...Actually, the unmarked location cart between Dawnstar and Morthal could be even better, it's right by the road as well
/;

; Properties
Message property JustACartMessage auto
Static property XMarker auto
ObjectReference property Inventory auto
GlobalVariable property Riding auto
GlobalVariable property Tethered auto
GlobalVariable property Keymap auto
GlobalVariable property QuickUntetherEnabled auto
GlobalVariable property LimitedInventoryEnabled auto
Faction property HorseFaction auto
Actor property LimitedInventory auto

; Variables
int tempKeyMap

; Funtions

; Disables and then enables both horse and carriage CarriageAlias.GetRef()
Function RefreshCartAndHorse(ObjectReference akObjectReference)
    akObjectReference.DisableNoWait()
    self.DisableNoWait()
    Utility.Wait(0.1)
    akObjectReference.Enable()
    self.Enable()
    self.SetMotionType(Motion_Keyframed)
endFunction

; Does what is says on the tin
Function BringHorseToCart(ObjectReference akObjectReference)
    ObjectReference marker = self.PlaceAtMe(XMarker as form, 1, false, false)
    MoveRefToPositionRelativeTo(marker, self, 256)
    akObjectReference.MoveTo(marker)
    marker.DisableNoWait()
    marker.Delete()
    Utility.Wait(0.1)
EndFunction

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

Event OnActivate(ObjectReference akActionRef)
    Actor[] horseList = MiscUtil.ScanCellNPCsByFaction(HorseFaction, self, 2048.0, 0, 127, true) ; PapyrusUtil SE to the rescue!
    Actor horse = horseList[0]
    if (Game.GetPlayer().IsOnMount())
        Riding.SetValueInt(1)
    else
        Riding.SetValueInt(0)
    endif
    int optionSelected = JustACartMessage.Show()
    if (optionSelected == 0) ; Tether/untether
        if (horse == none) ; Test if specific horse exists
            Debug.Notification("Couldn't find a horse.")
        elseif (horse.isDead()) ; Also test if she's alive
            Debug.Notification("Your horse is dead. Better get a new one.")
        elseif (Riding.GetValueInt() == 1) ; Test if riding but NOT tethered
            Debug.MessageBox("Better dismount before fiddling with the tethers...")
        elseif (Riding.GetValueInt() == 0 && Tethered.GetValueInt() == 1) ; Test if NOT riding AND tethered (Regular Untether)
            RefreshCartAndHorse(horse) ; Could just "inline" this, but eh, I already made the function
            Tethered.SetValueInt(0)
        elseif (Riding.GetValueInt() == 0 && Tethered.GetValueInt() == 0) ; Test if NOT riding NOR tethered (Tether)
            RefreshCartAndHorse(horse)
            Utility.Wait(0.1)
            BringHorseToCart(horse)
            Utility.Wait(0.1)
            self.SetMotionType(Motion_Dynamic)
            self.TetherToHorse(horse)
            if (QuickUntetherEnabled.GetValueInt() == 1)
                UnregisterForAllKeys()
                Utility.Wait(0.1)
                RegisterForKey(Keymap.GetValueInt())
                tempKeyMap = Keymap.GetValueInt() ; We've already registered for a key, switching Keymap value doesn't switch the key we're listening for
            endif
            Tethered.SetValueInt(1)
        endif
    elseif (optionSelected == 1) ; Access inventory
        if (LimitedInventoryEnabled.GetValueInt() == 0)
            Inventory.Activate(Game.GetPlayer(), true)
        elseif (LimitedInventoryEnabled.GetValueInt() == 1)
            LimitedInventory.OpenInventory(true)
        endif
    elseif (optionSelected == 2) ; Summon Horse
        if ((Riding.GetValueInt() == 1 || Tethered.GetValueInt() == 1) && !horse.IsDead())
            Debug.Notification("Your horse is fine where she is.")
        elseif (horse == none) ; If no horse
            Debug.Notification("Couldn't find a horse.")
        elseif (horse.isDead()) ; If no ALIVE horse
            Debug.Notification("Your horse is dead. Better get a new one.")
        else
            BringHorseToCart(horse)
        endif
    elseif (optionSelected == 3) ; Cancel
        return
    endif
    horse = none
EndEvent

Event OnKeyUp(int keyCode, Float holdTime) ; Implementing the quick untether
    if (QuickUntetherEnabled.GetValueInt() == 1 && !Utility.IsInMenuMode() && !UI.IsMenuOpen("Crafting Menu")) ; Make sure the quick untether option is enabled, and the player is NOT in a menu
        if (keyCode == Keymap.GetValueInt() || (keyCode != Keymap.GetValueInt() && keyCode == tempKeyMap)) ; Use currently set hotkey normally, or the old (temp) one if the key was changed while registered for the old one
            if (Tethered.GetValueInt() == 1)
                self.DisableNoWait()
                Utility.Wait(0.1)
                self.Enable()
                self.SetMotionType(Motion_Keyframed)
                Tethered.SetValueInt(0)
                Utility.Wait(0.1)
                UnregisterForAllKeys()
            endif
        endif
    endif
EndEvent

Event OnLoad() ; There's no situation where you'd load the cart in and not want it untethered and fixed
    Tethered.SetValueInt(0) 
    self.SetMotionType(Motion_Keyframed)
EndEvent