#include-once

#Region Skillbar
;~ Description: Change a skill on the skillbar.
Func SetSkillbarSkill($aSlot, $aSkillID, $aHeroNumber = 0, $aHeroID = GetHeroID($aHeroNumber))
   Return SendPacket(0x14, 0x55, $aHeroID, $aSlot - 1, $aSkillID, 0)
EndFunc   ;==>SetSkillbarSkill

;~ Description: Load all skills onto a skillbar simultaneously.
;~    $aSkillArray[0] -> Skill 1 etc
Func LoadSkillBar(ByRef $aSkillArray, $aHeroNumber = 0, $aHeroID = GetHeroID($aHeroNumber))
   Return SendPacket(0x2C, 0x56, $aHeroID, 8, $aSkillArray[0], $aSkillArray[1], $aSkillArray[2], $aSkillArray[3], $aSkillArray[4], $aSkillArray[5], $aSkillArray[6], $aSkillArray[7])
EndFunc   ;==>LoadSkillBar

;~ Description: Returns the recharge time remaining of an equipped skill in milliseconds. GetSkillTimer() works not while rendering disabled !
Func GetSkillbarSkillRecharge($aSkillSlot, $aHeroNumber = 0, $aPtr = GetSkillbarPtr($aHeroNumber))
   $aSkillSlot -= 1
   Local $lTimestamp = MemoryRead($aPtr + 12 + $aSkillSlot * 20, 'dword')
   If $lTimestamp = 0 Then Return 0
   Return $lTimestamp - GetSkillTimer()
EndFunc   ;==>GetSkillbarSkillRecharge

;~ Description: Returns skillslots amount of adrenaline.
Func GetSkillbarSkillAdrenaline($aSkillSlot, $aHeroNumber = 0, $aPtr = GetSkillbarPtr($aHeroNumber))
   $aSkillSlot -= 1
   Return MemoryRead($aPtr + 4 + $aSkillSlot * 20, 'long')
EndFunc   ;==>GetSkillbarSkillAdrenaline

#Region Ptr
;~ Description: Returns ptr to skillbar by HeroNumber.
Func GetSkillbarPtr($aHeroNumber = 0, $aHeroID = GetHeroID($aHeroNumber))
   If $HeroPtr1 = 0 Then $HeroPtr1 = MemoryRead($mBasePtr184C + 0x54, 'ptr')
   If $SkillbarBasePtr = 0 Then $SkillbarBasePtr = MemoryRead($mBasePtr182C + 0x6F0, 'ptr')
   For $i = 0 To MemoryRead($HeroPtr1 + 0x2C)
	  If MemoryRead($SkillbarBasePtr + $i * 0xBC) = $aHeroID Then Return Ptr($SkillbarBasePtr + $i * 0xBC)
   Next
EndFunc   ;==>GetSkillbarPtr
#EndRegion Ptr
#EndRegion Skillbar

#Region LoadSkilltemplate
;~ Description: Loads skill template code.
; NEW VERSION BY 4D 1 USING SET ATTRIBUTES
Func LoadSkillTemplate($aTemplate, $aHeroNumber = 0, $aHeroID = GetHeroID($aHeroNumber), $aCheckPrimary = True)
   Local $lString = ''
   For $i = 1 To StringLen($aTemplate)
	  $lString &= Base64ToBin64(StringMid($aTemplate, $i, 1))
   Next
   ; Profession
   Local $lTemp = Bin64ToDec(StringMid($lString, 9, 2)) * 2 + 4
   Local $lCount = $lTemp + 11
   Local $lPrimaryProf = Bin64ToDec(StringMid($lString, 11, $lTemp))
   If $aCheckPrimary Then
	  If $aHeroNumber = 0 Then
		 If MemoryRead(GetAgentPtr($aHeroID) + 266, 'byte') <> $lPrimaryProf Then Return False
	  Else
		 If GetHeroProfession($aHeroNumber, False, $aHeroID) <> $lPrimaryProf Then Return False
	  EndIf
   EndIf
   Local $lSecondaryProf = Bin64ToDec(StringMid($lString, $lCount, $lTemp))
   ; Attributes
   $lCount += $lTemp
   Local $lAmount = Bin64ToDec(StringMid($lString, $lCount, 4))
   $lTemp = Bin64ToDec(StringMid($lString, $lCount + 4, 4)) + 4
   $lCount += 8
   Local $lAttributeArray[$lAmount][2]
   For $i = 0 To $lAmount - 1
	  $lAttributeArray[$i][0] = Bin64ToDec(StringMid($lString, $lCount, $lTemp))
	  $lCount += $lTemp
	  $lAttributeArray[$i][1] = Bin64ToDec(StringMid($lString, $lCount, 4))
	  $lCount += 4
   Next
   ; Skills
   $lTemp = Bin64ToDec(StringMid($lString, $lCount, 4)) + 8
   $lCount += 4
   Local $lSkillArray[8]
   For $i = 0 To 7
	  $lSkillArray[$i] = Bin64ToDec(StringMid($lString, $lCount, $lTemp))
	  $lCount += $lTemp
   Next
   ChangeSecondProfession($lSecondaryProf, $aHeroNumber, $aHeroID)
   SetAttributes($lAttributeArray, $aHeroNumber, $aHeroID)
   LoadSkillBar($lSkillArray, $aHeroNumber, $aHeroID)
   Return True
EndFunc   ;==>LoadSkillTemplate

;~ Description: Converts Base64 to Bin64.
Func Base64ToBin64($aCharacter)
   Select
	  Case $aCharacter == "A"
		 Return "000000"
	  Case $aCharacter == "B"
		 Return "100000"
	  Case $aCharacter == "C"
		 Return "010000"
	  Case $aCharacter == "D"
		 Return "110000"
	  Case $aCharacter == "E"
		 Return "001000"
	  Case $aCharacter == "F"
		 Return "101000"
	  Case $aCharacter == "G"
		 Return "011000"
	  Case $aCharacter == "H"
		 Return "111000"
	  Case $aCharacter == "I"
		 Return "000100"
	  Case $aCharacter == "J"
		 Return "100100"
	  Case $aCharacter == "K"
		 Return "010100"
	  Case $aCharacter == "L"
		 Return "110100"
	  Case $aCharacter == "M"
		 Return "001100"
	  Case $aCharacter == "N"
		 Return "101100"
	  Case $aCharacter == "O"
		 Return "011100"
	  Case $aCharacter == "P"
		 Return "111100"
	  Case $aCharacter == "Q"
		 Return "000010"
	  Case $aCharacter == "R"
		 Return "100010"
	  Case $aCharacter == "S"
		 Return "010010"
	  Case $aCharacter == "T"
		 Return "110010"
	  Case $aCharacter == "U"
		 Return "001010"
	  Case $aCharacter == "V"
		 Return "101010"
	  Case $aCharacter == "W"
		 Return "011010"
	  Case $aCharacter == "X"
		 Return "111010"
	  Case $aCharacter == "Y"
		 Return "000110"
	  Case $aCharacter == "Z"
		 Return "100110"
	  Case $aCharacter == "a"
		 Return "010110"
	  Case $aCharacter == "b"
		 Return "110110"
	  Case $aCharacter == "c"
		 Return "001110"
	  Case $aCharacter == "d"
		 Return "101110"
	  Case $aCharacter == "e"
		 Return "011110"
	  Case $aCharacter == "f"
		 Return "111110"
	  Case $aCharacter == "g"
		 Return "000001"
	  Case $aCharacter == "h"
		 Return "100001"
	  Case $aCharacter == "i"
		 Return "010001"
	  Case $aCharacter == "j"
		 Return "110001"
	  Case $aCharacter == "k"
		 Return "001001"
	  Case $aCharacter == "l"
		 Return "101001"
	  Case $aCharacter == "m"
		 Return "011001"
	  Case $aCharacter == "n"
		 Return "111001"
	  Case $aCharacter == "o"
		 Return "000101"
	  Case $aCharacter == "p"
		 Return "100101"
	  Case $aCharacter == "q"
		 Return "010101"
	  Case $aCharacter == "r"
		 Return "110101"
	  Case $aCharacter == "s"
		 Return "001101"
	  Case $aCharacter == "t"
		 Return "101101"
	  Case $aCharacter == "u"
		 Return "011101"
	  Case $aCharacter == "v"
		 Return "111101"
	  Case $aCharacter == "w"
		 Return "000011"
	  Case $aCharacter == "x"
		 Return "100011"
	  Case $aCharacter == "y"
		 Return "010011"
	  Case $aCharacter == "z"
		 Return "110011"
	  Case $aCharacter == "0"
		 Return "001011"
	  Case $aCharacter == "1"
		 Return "101011"
	  Case $aCharacter == "2"
		 Return "011011"
	  Case $aCharacter == "3"
		 Return "111011"
	  Case $aCharacter == "4"
		 Return "000111"
	  Case $aCharacter == "5"
		 Return "100111"
	  Case $aCharacter == "6"
		 Return "010111"
	  Case $aCharacter == "7"
		 Return "110111"
	  Case $aCharacter == "8"
		 Return "001111"
	  Case $aCharacter == "9"
		 Return "101111"
	  Case $aCharacter == "+"
		 Return "011111"
	  Case $aCharacter == "/"
		 Return "111111"
   EndSelect
EndFunc   ;==>Base64ToBin64

 ;~ Description: Converts Bin64 to decimal.
Func Bin64ToDec($aBinary)
   Local $lReturn = 0
   For $i = 1 To StringLen($aBinary)
	  If StringMid($aBinary, $i, 1) == 1 Then $lReturn += 2 ^ ($i - 1)
   Next
   Return $lReturn
EndFunc   ;==>Bin64ToDec
#EndRegion LoadSkilltemplate

#Region Attributes
;~ Description: Set attributes to values in array.
;~ 		 $aAttrArray[0][0] = AttributeID
;~ 		 $aAttrArray[0][1] = AttributeLevel
Func SetAttributes(ByRef $aAttrArray, $aHeronumber = 0, $aHeroID = GetHeroID($aHeroNumber))
   Local $lCount = UBound($aAttrArray)
   For $i = 0 To $lCount -1
	  DllStructSetData($mSetAttributes, 6, $aAttrArray[$i][0], $i + 1)
	  DllStructSetData($mSetAttributes, 8, $aAttrArray[$i][1], $i + 1)
   Next
   DllStructSetData($mSetAttributes, 4, $aHeroID)
   DllStructSetData($mSetAttributes, 5, $lCount) ;# of attributes
   DllStructSetData($mSetAttributes, 7, $lCount) ;# of attributes
   Return Enqueue($mSetAttributesPtr, 152)
EndFunc

;~ Description: Set attributes to the given values
;~ by ddarek
;~ Usage: Call like this:
;~ 		SetAttributes("34|36", "12|12")		; to set to 12 both spawning power(=36) and channeling magic(=34)
;~ 		SetAttributes($ATTR_DIVINE_FAVOR&"|"&$ATTR_HEALING_PRAYERS&"|"&$ATTR_CURSES, "9|12|9")		; to set 3 attributes
Func SetAttributes_($fAttsID, $fAttsLevel, $aHeroNumber = 0, $aHeroID = GetHeroID($aHeroNumber))
   Local $lAttsID = StringSplit(String($fAttsID), "|")
   Local $lAttsLevel = StringSplit(String($fAttsLevel), "|")
   DllStructSetData($mSetAttributes, 4, $aHeroID)
   DllStructSetData($mSetAttributes, 5, $lAttsID[0]) ;# of attributes
   DllStructSetData($mSetAttributes, 7, $lAttsID[0]) ;# of attributes
   For $i = 1 To $lAttsID[0]
	  DllStructSetData($mSetAttributes, 6, $lAttsID[$i], $i)
	  DllStructSetData($mSetAttributes, 8, $lAttsLevel[$i], $i)
   Next
   Return Enqueue($mSetAttributesPtr, 152)
EndFunc   ;==>SetAttributes

;~ Description: Set the two given Attributes to 12
;~ Similar to SetAttributes but much faster since this is reusing stuff
Func MaxAttributes($aAtt1ID, $aAtt2ID = 0xFF, $aHeroNumber = 0, $aHeroID = GetHeroID($aHeroNumber)) ; ATTR_NONE = 0xFF
   DllStructSetData($mSetAttributes, 4, $aHeroID)
   DllStructSetData($mSetAttributes, 5, 3) ;# of attributes
   DllStructSetData($mSetAttributes, 6, $aAtt1ID, 1) ;ID ofAttributes
   DllStructSetData($mSetAttributes, 6, $aAtt2ID, 2) ;ID ofAttributes
   DllStructSetData($mSetAttributes, 7, 3) ;# of attributes
   DllStructSetData($mSetAttributes, 8, 13, 1) ;Attribute Levels
   DllStructSetData($mSetAttributes, 8, 13, 2) ;Attribute Levels
   Return Enqueue($mSetAttributesPtr, 152)
EndFunc   ;==>MaxAttributes

;~ Description: Sets all attributes to 0.
Func ClearAttributes($aHeroNumber = 0, $aHeroID = GetHeroID($aHeroNumber), $aPrimary = 0, $aSecondary = 0)
   If $aPrimary = 0 Then
	  If $aHeroNumber = 0 Then
		 $aPrimary = MemoryRead(GetAgentPtr($aHeroID) + 266, 'byte')
	  Else
		 $aPrimary = GetHeroProfession($aHeroNumber, True, $aHeroID)
		 $aSecondary = @extended
	  EndIf
   EndIf
   If $aSecondary = 0 Then
	  If $aHeroNumber = 0 Then
		 $aSecondary = MemoryRead(GetAgentPtr($aHeroID) + 267, 'byte')
	  Else
		 $aPrimary = GetHeroProfession($aHeroNumber, True, $aHeroID)
		 $aSecondary = @extended
	  EndIf
   EndIf
   If $aPrimary <> 1 And $aSecondary <> 1 Then
	  Local $lAtt1 = 17
	  Local $lAtt2 = 18
   ElseIf $aPrimary <> 2 And $aSecondary <> 2 Then
	  Local $lAtt1 = 23
	  Local $lAtt2 = 24
   Else
	  Local $lAtt1 = 13
	  Local $lAtt2 = 14
   EndIf
   Return MaxAttributes($lAtt1, $lAtt2, $aHeroNumber, $aHeroID)
EndFunc

;~ Description: Returns profession number.
Func GetProfessionByAttribute($aAttr)
   Switch $aAttr
	  Case 0,1,2,3 ; $ATTRIB_FastCasting, $ATTRIB_IllusionMagic, $ATTRIB_DominationMagic, $ATTRIB_InspirationMagic
		 Return 5 ; $PROFESSION_Mesmer
	  Case 4,5,6,7 ; $ATTRIB_BloodMagic, $ATTRIB_DeathMagic, $ATTRIB_SoulReaping, $ATTRIB_Curses
		 Return 4 ; $PROFESSION_Necromancer
	  Case 8,9,10,11,12 ; $ATTRIB_AirMagic, $ATTRIB_EarthMagic, $ATTRIB_FireMagic, $ATTRIB_WaterMagic, $ATTRIB_EnergyStorage
		 Return 6 ; $PROFESSION_Elementalist
	  Case 13,14,15,16 ; $ATTRIB_HealingPrayers, $ATTRIB_SmitingPrayers, $ATTRIB_ProtectionPrayers, $ATTRIB_DivineFavor
		 Return 3 ; $PROFESSION_Monk
	  Case 17,18,19,20,21 ; $ATTRIB_Strength, $ATTRIB_AxeMastery, $ATTRIB_HammerMastery, $ATTRIB_Swordsmanship, $ATTRIB_Tactics
		 Return 1 ; $PROFESSION_Warrior
	  Case 22,23,24,25 ; $ATTRIB_BeastMastery, $ATTRIB_Expertise, $ATTRIB_WildernessSurvival, $ATTRIB_Marksmanship
		 Return 2 ; $PROFESSION_Ranger
	  Case 29,30,31,35 ; $ATTRIB_DaggerMastery, $ATTRIB_DeadlyArts, $ATTRIB_ShadowArts, $ATTRIB_CriticalStrikes
		 Return 7 ; $PROFESSION_Assassin
	  Case 32,33,36,36 ; $ATTRIB_Communing, $ATTRIB_RestorationMagic, $ATTRIB_ChannelingMagic, $ATTRIB_SpawningPower
		 Return 8 ; $PROFESSION_Ritualist
	  Case 37,38,39,40 ; $ATTRIB_SpearMastery, $ATTRIB_Command, $ATTRIB_Motivation, $ATTRIB_Leadership
		 Return 9 ; $PROFESSION_Paragon
	  Case 41,42,43,44 ; $ATTRIB_ScytheMastery, $ATTRIB_WindPrayers, $ATTRIB_EarthPrayers, $ATTRIB_Mysticism
		 Return 10 ; $PROFESSION_Dervish
	  Case Else
		 Return 0 ; $PROFESSION_None
   EndSwitch
EndFunc   ;==>GetProfessionByAttribute

;~ Description: Returns secondary attributes.
Func GetSecondaryAttributesByProfession($aProf)
   Switch $aProf
	  Case 0 ; $PROFESSION_None
		 Local $ret[1] = [0]
	  Case 5 ; $PROFESSION_Mesmer
		 Local $ret[4] = [3,2,1,3] ; $ATTRIB_DominationMagic, $ATTRIB_IllusionMagic, $ATTRIB_InspirationMagic]
	  Case 4 ; $PROFESSION_Necromancer
		 Local $ret[4] = [3,4,5,7] ; $ATTRIB_BloodMagic, $ATTRIB_DeathMagic, $ATTRIB_Curses]
	  Case 6 ; $PROFESSION_Elementalist
		 Local $ret[5] = [4,8,9,10,11] ; $ATTRIB_AirMagic, $ATTRIB_EarthMagic, $ATTRIB_FireMagic, $ATTRIB_WaterMagic]
	  Case 3 ; $PROFESSION_Monk
		 Local $ret[4] = [3,13,14,15] ; $ATTRIB_HealingPrayers, $ATTRIB_ProtectionPrayers, $ATTRIB_SmitingPrayers]
	  Case 1 ; $PROFESSION_Warrior
		 Local $ret[5] = [4,18,19,20,21] ; $ATTRIB_AxeMastery, $ATTRIB_HammerMastery, $ATTRIB_Swordsmanship, $ATTRIB_Tactics]
	  Case 2 ; $PROFESSION_Ranger
		 Local $ret[4] = [3,22,24,25] ; $ATTRIB_BeastMastery, $ATTRIB_WildernessSurvival, $ATTRIB_Marksmanship]
	  Case 7 ; $PROFESSION_Assassin
		 Local $ret[4] = [3,29,30,31] ; $ATTRIB_DaggerMastery, $ATTRIB_DeadlyArts, $ATTRIB_ShadowArts]
	  Case 8 ; $PROFESSION_Ritualist
		 Local $ret[4] = [3,32,33,34] ; $ATTRIB_Communing, $ATTRIB_RestorationMagic, $ATTRIB_ChannelingMagic]
	  Case 9 ; $PROFESSION_Paragon
		 Local $ret[4] = [3,37,38,39] ; $ATTRIB_SpearMastery, $ATTRIB_Command, $ATTRIB_Motivation]
	  Case 10 ; $PROFESSION_Dervish
		 Local $ret[4] = [3,41,42,43] ; $ATTRIB_ScytheMastery, $ATTRIB_WindPrayers, $ATTRIB_EarthPrayers]
   EndSwitch
   Return $ret
EndFunc   ;==>GetSecondaryAttributesByProfession

;~ Description: Returns main attribute by profession number.
Func GetProfPrimaryAttribute($aProfession)
   Switch $aProfession
	  Case 1
		 Return 17
	  Case 2
		 Return 23
	  Case 3
		 Return 16
	  Case 4
		 Return 6
	  Case 5
		 Return 0
	  Case 6
		 Return 12
	  Case 7
		 Return 35
	  Case 8
		 Return 36
	  Case 9
		 Return 40
	  Case 10
		 Return 44
   EndSwitch
EndFunc   ;==>GetProfPrimaryAttribute
#EndRegion

#Region Single Skills
;~ Description: Checks if skill given (by number in bar) is recharged. Returns True if recharged, otherwise False.
Func IsRecharged($aSkillSlot, $aHeroNumber = 0, $aPtr = GetSkillbarPtr($aHeroNumber))
   Return GetSkillbarSkillRecharge($aSkillSlot, $aHeroNumber, $aPtr) = 0
EndFunc   ;==>IsRecharged

;~ Description: Returns the skill ID of an equipped skill.
Func GetSkillbarSkillID($aSkillSlot, $aHeroNumber = 0, $aPtr = GetSkillbarPtr($aHeroNumber))
   $aSkillSlot -= 1
   Return MemoryRead($aPtr + 16 + $aSkillSlot * 20, 'dword')
EndFunc   ;==>GetSkillbarSkillID

;~ Description: Returns the timestamp used for effects and skills (milliseconds). Only works when rendering enabled.
Func GetSkillTimer()
   Return MemoryRead($mSkillTimer, "long")
EndFunc   ;==>GetSkillTimer

;~ Description: Returns skill dmg.
Func SkillDamageAmount($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return MemoryRead($aSkill + 96, 'long')
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return DllStructGetData($aSkill, 'Scale15')
   Else
	  Return MemoryRead(GetSkillPtr($aSkill) + 96, 'long')
   EndIf
EndFunc   ;==>SkillDamageAmount

;~ Description: Returns skill aoe range.
Func SkillAOERange($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return MemoryRead($aSkill + 108, 'float')
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return DllStructGetData($aSkill, 'AoERange')
   Else
	  Return MemoryRead(GetSkillPtr($aSkill) + 108, 'float')
   EndIf
EndFunc   ;==>SkillAOERange

;~ Description: Returns skill recharge.
Func SkillRecharge($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return MemoryRead($aSkill + 76, 'long')
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return DllStructGetData($aSkill, 'Recharge')
   Else
	  Return MemoryRead(GetSkillPtr($aSkill) + 76, 'long')
   EndIf
EndFunc   ;==>SkillRecharge

;~ Description: Returns skill activationtime.
Func SkillActivation($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return MemoryRead($aSkill + 60, 'float')
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return DllStructGetData($aSkill, 'Activation')
   Else
	  Return MemoryRead(GetSkillPtr($aSkill) + 60, 'float')
   EndIf
EndFunc   ;==>SkillActivation

;~ Description: Returns skill attribute.
Func SkillAttribute($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return MemoryRead($aSkill + 41, 'byte')
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return DllStructGetData($aSkill, 'Attribute')
   Else
	  Return MemoryRead(GetSkillPtr($aSkill) + 41, 'byte')
   EndIf
EndFunc   ;==>SkillAttribute

#Region Type
;~ Description: Returns true if skill is hex spell, false if not.
Func IsHexSpell($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return MemoryRead($aSkill + 12, 'long') = 4
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return DllStructGetData($aSkill, 'Type') = 4
   Else
	  Return MemoryRead(GetSkillPtr($aSkill) + 12, 'long') = 4
   EndIf
EndFunc   ;==>IsHexSpell

;~ Description: Returns true if skill is condition spell, false if not.
Func IsConditionSpell($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return MemoryRead($aSkill + 12, 'long') = 8
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return DllStructGetData($aSkill, 'Type') = 8
   Else
	  Return MemoryRead(GetSkillPtr($aSkill) + 12, 'long') = 8
   EndIf
EndFunc   ;==>IsConditionSpell

;~ Description: Returns true if skill is enchantment spell, false if not.
Func IsEnchantmentSkill($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return MemoryRead($aSkill + 12, 'long') = 6
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return DllStructGetData($aSkill, 'Type') = 6
   Else
	  Return MemoryRead(GetSkillPtr($aSkill) + 12, 'long') = 6
   EndIf
EndFunc   ;==>IsEnchantmentSkill

;~ Description: Returns true if skill is attack skill, false if not.
Func IsAttackSkill($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return MemoryRead($aSkill + 12, 'long') = 14
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return DllStructGetData($aSkill, 'Type') = 14
   Else
	  Return MemoryRead(GetSkillPtr($aSkill) + 12, 'long') = 14
   EndIf
EndFunc   ;==>IsAttackSkill
#EndRegion

#Region Requirements
;~ Description: Returns true if skill requires bleeding.
Func SkillRequiresBleeding($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return BitAND(MemoryRead($aSkill + 28, 'long'), 1)
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return BitAND(DllStructGetData($aSkill, 'Condition'), 1)
   Else
	  Return BitAND(MemoryRead(GetSkillPtr($aSkill) + 28, 'long'), 1)
   EndIf
EndFunc   ;==>SkillRequiresBleeding

;~ Description: Returns true if skill requires burning.
Func SkillRequiresBurning($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return BitAND(MemoryRead($aSkill + 28, 'long'), 4)
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return BitAND(DllStructGetData($aSkill, 'Condition'), 4)
   Else
	  Return BitAND(MemoryRead(GetSkillPtr($aSkill) + 28, 'long'), 4)
   EndIf
EndFunc   ;==>SkillRequiresBurning

;~ Description: Returns true if skill requires cripple.
Func SkillRequiresCripple($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return BitAND(MemoryRead($aSkill + 28, 'long'), 8)
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return BitAND(DllStructGetData($aSkill, 'Condition'), 8)
   Else
	  Return BitAND(MemoryRead(GetSkillPtr($aSkill) + 28, 'long'), 8)
   EndIf
EndFunc   ;==>SkillRequiresCripple

;~ Description: Returns true if skill requires deep wound.
Func SkillRequiresDeepWound($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return BitAND(MemoryRead($aSkill + 28, 'long'), 16)
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return BitAND(DllStructGetData($aSkill, 'Condition'), 16)
   Else
	  Return BitAND(MemoryRead(GetSkillPtr($aSkill) + 28, 'long'), 16)
   EndIf
EndFunc   ;==>SkillRequiresDeepWound

;~ Description: Returns true if skill requires earth hex.
Func SkillRequiresEarthHex($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return BitAND(MemoryRead($aSkill + 28, 'long'), 64)
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return BitAND(DllStructGetData($aSkill, 'Condition'), 64)
   Else
	  Return BitAND(MemoryRead(GetSkillPtr($aSkill) + 28, 'long'), 64)
   EndIf
EndFunc   ;==>SkillRequiresEarthHex

;~ Description: Returns true if skill requires target knocked down.
Func SkillRequiresKnockDown($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return BitAND(MemoryRead($aSkill + 28, 'long'), 128)
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return BitAND(DllStructGetData($aSkill, 'Condition'), 128)
   Else
	  Return BitAND(MemoryRead(GetSkillPtr($aSkill) + 28, 'long'), 128)
   EndIf
EndFunc   ;==>SkillRequiresKnockDown

;~ Description: Returns true if skill requires weakness.
Func SkillRequiresWeakness($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return BitAND(MemoryRead($aSkill + 28, 'long'), 1024)
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return BitAND(DllStructGetData($aSkill, 'Condition'), 1024)
   Else
	  Return BitAND(MemoryRead(GetSkillPtr($aSkill) + 28, 'long'), 1024)
   EndIf
EndFunc   ;==>SkillRequiresWeakness

;~ Description: Returns true if skill requires water hex.
Func SkillRequiresWaterHex($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return BitAND(MemoryRead($aSkill + 28, 'long'), 2048)
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return BitAND(DllStructGetData($aSkill, 'Condition'), 2048)
   Else
	  Return BitAND(MemoryRead(GetSkillPtr($aSkill) + 28, 'long'), 2048)
   EndIf
EndFunc   ;==>SkillRequiresWaterHex

;~ Description: Returns true if skill interrupts target.
Func IsInterruptSkill($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Local $lSkillID = MemoryRead($aSkill, 'long')
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Local $lSkillID = DllStructGetData($aSkill, 'ID')
   Else
	  Local $lSkillID = $aSkill
   EndIf
   Switch $lSkillID
	  Case 2358; $SKILLID_You_Move_Like_a_Dwarf
		 Return True
	  Case 2066; $SKILLID_Disarm
		 Return True
	  Case 340; $SKILLID_Disrupting_Chop
		 Return True
	  Case 325; $SKILLID_Distracting_Blow
		 Return True
	  Case 399; $SKILLID_Distracting_Shot
		 Return True
	  Case 2194; $SKILLID_Distracting_Strike
		 Return True
	  Case 390; $SKILLID_Savage_Slash
		 Return True
	  Case 329; $SKILLID_Skull_Crack
		 Return True
	  Case 2143; $SKILLID_Disrupting_Shot
		 Return True
	  Case 1726; $SKILLID_Magebane_Shot
		 Return True
	  Case 409; $SKILLID_Punishing_Shot
		 Return True
	  Case 426; $SKILLID_Savage_Shot
		 Return True
	  Case 61; $SKILLID_Leech_Signet
		 Return True
	  Case 1057; $SKILLID_Psychic_Instability
		 Return True
	  Case 1350; $SKILLID_Simple_Thievery
		 Return True
	  Case 228; $SKILLID_Thunderclap
		 Return True
	  Case 1025; $SKILLID_Disrupting_Stab
		 Return True
	  Case 975; $SKILLID_Exhausting_Assault
		 Return True
	  Case 1538; $SKILLID_Lyssas_Assault
		 Return True
	  Case 1512; $SKILLID_Lyssas_Haste
		 Return True
	  Case 445; $SKILLID_Disrupting_Lunge
		 Return True
	  Case 932; $SKILLID_Complicate
		 Return True
	  Case 57; $SKILLID_Cry_of_Frustration
		 Return True
	  Case 1053; $SKILLID_Psychic_Distraction
		 Return True
	  Case 1342; $SKILLID_Tease
		 Return True
	  Case 1344; $SKILLID_Web_of_Disruption
		 Return True
	  Case 571; $SKILLID_Disrupting_Dagger
		 Return True
	  Case 860; $SKILLID_Signet_of_Disruption
		 Return True
	  Case 1992; $SKILLID_Signet_of_Distraction
		 Return True
	  Case 988; $SKILLID_Temple_Strike
		 Return True
	  Case 5; $SKILLID_Power_Block
		 Return True
	  Case 25; $SKILLID_Power_Drain
		 Return True
	  Case 953; $SKILLID_Power_Flux
		 Return True
	  Case 24; $SKILLID_Power_Leak
		 Return True
	  Case 803; $SKILLID_Power_Leech
		 Return True
	  Case 1994; $SKILLID_Power_Lock
		 Return True
	  Case 931; $SKILLID_Power_Return
		 Return True
	  Case 23; $SKILLID_Power_Spike
		 Return True
	  Case Else
		 Return False
   EndSwitch
EndFunc   ;==>IsInterruptSkill

;~ Description: Returns true if skill is a weapon spell.
Func IsWeaponSpell($aSkill)
If IsPtr($aSkill) <> 0 Then
	  Return MemoryRead($aSkill + 12, 'long') = 25
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return DllStructGetData($aSkill, 'Type') = 25
   Else
	  Return MemoryRead(GetSkillPtr($aSkill) + 12, 'long') = 25
   EndIf
EndFunc   ;==>IsWeaponSpell

;~ Description: Returns true if skill requires a condition.
Func SkillRequiresCondition($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Local $lSkillID = MemoryRead($aSkill, 'long')
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Local $lSkillID = DllStructGetData($aSkill, 'ID')
   Else
	  Local $lSkillID = $aSkill
   EndIf
   Switch $lSkillID
	  Case 365; $SKILLID_Victory_is_Mine
		 Return True
	  Case 1137; $SKILLID_Yeti_Smash
		 Return True
	  Case 870; $SKILLID_Pestilence
		 Return True
	  Case 440; $SKILLID_Scavenger_Strike
		 Return True
	  Case 1471; $SKILLID_Scavengers_Focus
		 Return True
	  Case 817; $SKILLID_Discord
		 Return True
;~ 	  Case 2103; $SKILLID_Necrosis
;~ 		 Return True
	  Case 864; $SKILLID_Oppressive_Gaze
		 Return True
	  Case 1950; $SKILLID_Signet_of_Corruption
		 Return True
	  Case 828; $SKILLID_Vile_Miasma
		 Return True
	  Case 107; $SKILLID_Virulence
		 Return True
	  Case 78; $SKILLID_Epidemic
		 Return True
	  Case 1333; $SKILLID_Extend_Conditions
		 Return True
	  Case 55; $SKILLID_Fevered_Dreams
		 Return True
	  Case 19; $SKILLID_Fragility
		 Return True
	  Case 1334; $SKILLID_Hypochondria
		 Return True
	  Case 217; $SKILLID_Crystal_Wave
		 Return True
	  Case 786; $SKILLID_Iron_Palm
		 Return True
	  Case 1633; $SKILLID_Malicious_Strike
		 Return True
	  Case 1991; $SKILLID_Sadists_Signet
		 Return True
	  Case 1034; $SKILLID_Seeping_Wound
		 Return True
	  Case 2186; $SKILLID_Signet_of_Deadly_Corruption
		 Return True
	  Case 1036; $SKILLID_Signet_of_Malice
		 Return True
	  Case 1604; $SKILLID_Disrupting_Throw
		 Return True
	  Case 1957; $SKILLID_Spear_of_Fury
		 Return True
	  Case 1602; $SKILLID_Stunning_Strike
		 Return True
	  Case 1515; $SKILLID_Armor_of_Sanctity
		 Return True
	  Case 1486; $SKILLID_Reap_Impurities
		 Return True
	  Case Else
		 Return False
   EndSwitch
EndFunc   ;==>SkillRequiresCondition

;~ Description: Returns true if skill requires hexed target.
Func SkillRequiresHex($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Local $lSkillID = MemoryRead($aSkill, 'long')
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Local $lSkillID = DllStructGetData($aSkill, 'ID')
   Else
	  Local $lSkillID = $aSkill
   EndIf
   Switch $lSkillID
	  Case 303; $SKILLID_Convert_Hexes
		 Return True
	  Case 2003; $SKILLID_Cure_Hex
		 Return True
	  Case 1692; $SKILLID_Divert_Hexes
		 Return True
	  Case 848; $SKILLID_Reverse_Hex
		 Return True
	  Case 302; $SKILLID_Smite_Hex
		 Return True
	  Case 1337; $SKILLID_Drain_Delusions
		 Return True
	  Case 1059; $SKILLID_Hex_Eater_Signet
		 Return True
	  Case 1348; $SKILLID_Hex_Eater_Vortex
		 Return True
	  Case 22; $SKILLID_Inspired_Hex
		 Return True
	  Case 1049; $SKILLID_Revealed_Hex
		 Return True
	  Case 27; $SKILLID_Shatter_Delusions
		 Return True
	  Case 67; $SKILLID_Shatter_Hex
		 Return True
	  Case Else
		 Return False
   EndSwitch
EndFunc   ;==>SkillRequiresHex

;~ Description: Returns true if skill is a summoning skill.
Func IsSummonSkill($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Local $lSkillID = MemoryRead($aSkill, 'long')
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Local $lSkillID = DllStructGetData($aSkill, 'ID')
   Else
	  Local $lSkillID = $aSkill
   EndIf
   Switch $lSkillID
	  Case 2226; $SKILLID_Summon_Ice_Imp
		 Return True
	  Case 2224; $SKILLID_Summon_Mursaat
		 Return True
	  Case 2227; $SKILLID_Summon_Naga_Shaman
		 Return True
	  Case 2225; $SKILLID_Summon_Ruby_Djinn
		 Return True
	  Case Else
		 Return False
   EndSwitch
EndFunc   ;==>IsSummonSkill

;~ Description: Returns true if skill is an anti melee skill.
Func IsAntiMeleeSkill($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Local $lSkillID = MemoryRead($aSkill, 'long')
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Local $lSkillID = DllStructGetData($aSkill, 'ID')
   Else
	  Local $lSkillID = $aSkill
   EndIf
   Switch $lSkillID
	  Case 1130; $SKILLID_Spear_of_Light
		 Return True
	  Case 240; $SKILLID_Smite
		 Return True
	  Case 2006; $SKILLID_Castigation_Signet
		 Return True
	  Case 296; $SKILLID_Bane_Signet
		 Return True
	  Case 1657; $SKILLID_Signet_of_Clumsiness
		 Return True
	  Case 294; $SKILLID_Signet_of_Judgment
		 Return True
	  Case 47; $SKILLID_Ineptitude
		 Return True
	  Case 43; $SKILLID_Clumsiness
		 Return True
	  Case 2056; $SKILLID_Wandering_Eye
		 Return True
	  Case Else
		 Return False
   EndSwitch
EndFunc   ;==>IsAntiMeleeSkill
#EndRegion

#Region Special
;~ Description: Returns true if skill is elite skill.
Func IsEliteSkill($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return MemoryRead($aSkill + 16, 'long') = 4
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return DllStructGetData($aSkill, 'Special') = 4
   Else
	  Return MemoryRead(GetSkillPtr($aSkill) + 16, 'long') = 4
   EndIf
EndFunc   ;==>IsEliteSkill

;~ Description: Returns true if skill is pve skill.
Func IsPvESkill($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return BitAND(MemoryRead($aSkill + 16, 'long'), 524288)
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return BitAND(DllStructGetData($aSkill, 'Special'), 524288)
   Else
	  Return BitAND(MemoryRead(GetSkillPtr($aSkill) + 16, 'long'), 524288)
   EndIf
EndFunc   ;==>IsPvESkill
#EndRegion

#Region Skilltypes
;~ Description: Returns true if skillid uses skills that affect or summon ritualist spirits.
Func IsSpiritSkill($aSkill) ; Spirits (Binding Rituals)
   If IsPtr($aSkill) <> 0 Then
	  Local $lSkillID = MemoryRead($aSkill, 'long')
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Local $lSkillID = DllStructGetData($aSkill, 'ID')
   Else
	  Local $lSkillID = $aSkill
   EndIf
   Switch $lSkillID
	  Case 1239; $SKILLID_Signet_of_Spirits
		 Return True
	  Case 2205; $SKILLID_Agony
		 Return True
	  Case 1745; $SKILLID_Anguish
		 Return True
	  Case 1253; $SKILLID_Bloodsong
		 Return True
	  Case 2656; $SKILLID_Call_to_the_Spirit_Realm
		 Return True
	  Case 920; $SKILLID_Destruction
		 Return True
	  Case 923; $SKILLID_Disenchantment
		 Return True
	  Case 1249; $SKILLID_Displacement
		 Return True
	  Case 921; $SKILLID_Dissonance
		 Return True
	  Case 1252; $SKILLID_Earthbind
		 Return True
	  Case 1747; $SKILLID_Empowerment
		 Return True
	  Case 1734; $SKILLID_Gaze_of_Fury
		 Return True
	  Case 1251; $SKILLID_Life
		 Return True
	  Case 1901; $SKILLID_Jack_Frost
		 Return True
	  Case 1247; $SKILLID_Pain
		 Return True
	  Case 1250; $SKILLID_Preservation
		 Return True
	  Case 1748; $SKILLID_Recovery
		 Return True
	  Case 981; $SKILLID_Recuperation
		 Return True
	  Case 2204; $SKILLID_Rejuvenation
		 Return True
	  Case 963; $SKILLID_Restoration
		 Return True
	  Case 871; $SKILLID_Shadowsong
		 Return True
	  Case 982; $SKILLID_Shelter
		 Return True
	  Case 1266; $SKILLID_Soothing
		 Return True
	  Case 911; $SKILLID_Union
		 Return True
	  Case 2110; $SKILLID_Vampirism
		 Return True
	  Case 1255; $SKILLID_Wanderlust
		 Return True
	  Case Else
		 Return False
   EndSwitch
EndFunc   ;==>IsSpiritSkill

;~ Description: Returns true if skillid is skill that strips enchantment.
Func IsEnchantmentStrip($aSkill) ;
   If IsPtr($aSkill) <> 0 Then
	  Local $lSkillID = MemoryRead($aSkill, 'long')
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Local $lSkillID = DllStructGetData($aSkill, 'ID')
   Else
	  Local $lSkillID = $aSkill
   EndIf
   Switch $lSkillID
;~ Necro Skills
	  Case 144 ; $SKILLID_Chillblains
		 Return True
	  Case 1362 ; $SKILLID_Corrupt_Enchantment ; Elite
		 Return True
	  Case 936 ; $SKILLID_Envenom_Enchantments
		 Return True
	  Case 763 ; $SKILLID_Jaundiced_Gaze
		 Return True
	  Case 1359 ; $SKILLID_Pain_of_Disenchantment ; Elite
		 Return True
	  Case 141 ; $SKILLID_Rend_Enchantments
		 Return True
	  Case 955 ; $SKILLID_Rip_Enchantment
		 Return True
	  Case 143 ; $SKILLID_Strip_Enchantment
		 Return True
;~ Mesmer Skills
	  Case 1656 ; $SKILLID_Air_of_Disenchantment ; Elite
		 Return True
	  Case 1347 ; $SKILLID_Discharge_Enchantment
		 Return True
	  Case 68 ; $SKILLID_Drain_Enchantment
		 Return True
	  Case 1061 ; $SKILLID_Feedback
		 Return True
	  Case 21 ; $SKILLID_Inspired_Enchantment
		 Return True
	  Case 877 ; $SKILLID_Lyssas_Balance
		 Return True
	  Case 1349 ; $SKILLID_Mirror_of_Disenchantment
		 Return True
	  Case 1048 ; $SKILLID_Revealed_Enchantment
		 Return True
	  Case 69 ; $SKILLID_Shatter_Enchantment
		 Return True
	  Case 933 ; $SKILLID_Shatter_Storm ; Elite
		 Return True
	  Case 882 ; $SKILLID_Signet_of_Disenchantment
		 Return True
;~ Assassin Skills
	  Case 1643 ; $SKILLID_Assault_Enchantments ; Elite
		 Return True
	  Case 990 ; $SKILLID_Expunge_Enchantments
		 Return True
	  Case 1645 ; $SKILLID_Lift_Enchantment
		 Return True
	  Case 1634 ; $SKILLID_Shattering_Assault ; Elite
		 Return True
	  Case 1648 ; $SKILLID_Signet_of_Twilight ; I would not use this, requires a hexed target
		 Return True
;~ Dervish Skills I left out the ones that enchant the derv and its hits take away an enchantment.
	  Case 1534 ; $SKILLID_Rending_Touch
		 Return True
	  Case 1545 ; $SKILLID_Test_of_Faith
		 Return True
	  Case Else
		 Return False
   EndSwitch
EndFunc   ;==>IsEnchantmentStrip

;~ Description: Returns true if skill can be considered a healing skill.
Func IsHealSkill($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  If BitAND(MemoryRead($aSkill + 24, 'long'), 4096) Then Return True
	  Local $lSkillEffect2 = MemoryRead($aSkill + 32, 'long')
	  If BitAnd($lSkillEffect2, 2) Or BitAnd($lSkillEffect2, 4) Then Return True
	  Local $lSkillAttribute = MemoryRead($aSkill + 41, 'byte')
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  If BitAND(DllStructGetData($aSkill, 'Effect1'), 4096) Then Return True
	  Local $lSkillEffect2 = DllStructGetData($aSkill, 'Effect2')
	  If BitAnd($lSkillEffect2, 2) Or BitAnd($lSkillEffect2, 4) Then Return True
	  Local $lSkillAttribute = DllStructGetData($aSkill, 'Attribute')
   Else
	  Local $lPtr = GetAgentPtr($aSkill)
	  If BitAND(MemoryRead($lPtr + 24, 'long'), 4096) Then Return True
	  Local $lSkillEffect2 = MemoryRead($lPtr + 32, 'long')
	  If BitAnd($lSkillEffect2, 2) Or BitAnd($lSkillEffect2, 4) Then Return True
	  Local $lSkillAttribute = MemoryRead($lPtr + 41, 'byte')
   EndIf
   Switch $lSkillAttribute
	  Case 13,15,16 ; $ATTRIB_HealingPrayers, $ATTRIB_ProtectionPrayers, $ATTRIB_DivineFavor
		 Return True
	  Case Else
		 Return False
   EndSwitch
EndFunc   ;==>IsHealSkill

;~ Description: Returns true if skill is a rez skill.
Func IsResSkill($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Local $lSkillID = MemoryRead($aSkill, 'long')
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Local $lSkillID = DllStructGetData($aSkill, 'ID')
   Else
	  Local $lSkillID = $aSkill
   EndIf
   Switch $lSkillID
	  Case 2217 ; $SKILLID_By_Urals_Hammer
		 Return True
	  Case 1592 ; $SKILLID_We_Shall_Return
		 Return True
	  Case 2872 ; $SKILLID_Death_Pact_Signet
		 Return True
	  Case 2109 ; $SKILLID_Eternal_Aura
		 Return True
	  Case 791 ; $SKILLID_Flesh_of_my_Flesh
		 Return True
	  Case 1865 ; $SKILLID_Junundu_Wail
		 Return True
	  Case 304 ; $SKILLID_Light_of_Dwayna
		 Return True
	  Case 1222 ; $SKILLID_Lively_Was_Naomei
		 Return True
	  Case 306 ; $SKILLID_Rebirth
		 Return True
	  Case 1263 ; $SKILLID_Renew_Life
		 Return True
	  Case 963 ; $SKILLID_Restoration
		 Return True
	  Case 314 ; $SKILLID_Restore_Life
		 Return True
	  Case 305 ; $SKILLID_Resurrect
		 Return True
	  Case 1128 ; $SKILLID_Resurrection_Chant
		 Return True
	  Case 2 ; $SKILLID_Resurrection_Signet
		 Return True
	  Case 1778 ; $SKILLID_Signet_of_Return
		 Return True
	  Case 1816 ; $SKILLID_Sunspear_Rebirth_Signet
		 Return True
	  Case 268 ; $SKILLID_Unyielding_Aura
		 Return True
	  Case 315 ; $SKILLID_Vengeance
		 Return True
	  Case Else
		 Return False
   EndSwitch
EndFunc   ;==>IsResSkill

;~ Description: Returns true if skill requires target to be below 50%.
Func IsBelow50PercentEnemySkill($aSkill) ;
   If IsPtr($aSkill) <> 0 Then
	  Local $lSkillID = MemoryRead($aSkill, 'long')
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Local $lSkillID = DllStructGetData($aSkill, 'ID')
   Else
	  Local $lSkillID = $aSkill
   EndIf
   Switch $lSkillID
;~ PvE only skills
	  Case 2353 ; $SKILLID_Finish_Him
		 Return True
;~ Warrior Skills
	  Case 385 ; $SKILLID_Final_Thrust ; Bonus damage triggers below 50%
		 Return True
;~ Ranger Skills
	  Case 444 ; $SKILLID_Burtal_Strike ; Bonus damage triggers below 50%
		 Return True
	  Case 1197 ; $SKILLID_Needling_Shot
		 Return True
;~ Monk Skills
	  Case 282 ; $SKILLID_Word_of_Healing ; Elite Healing skill
		 Return True
	  Case 1687 ; $SKILLID_Zealous_Benediction ; Elite Protection Skill
		 Return True
;~ Necro Skills
	  Case 1365 ; $SKILLID_Signet_of_Lost_Souls
		 Return True
	  Case 1069 ; $SKILLID_Taste_of_Pain
		 Return True
;~ Assassin Skills (ignoring self target skills like Shadow Shroud and Moebius Strike)
	  Case 1646 ; $SKILLID_Augury_of_Death ; shadow steps to them when <50% health
		 Return True
;~ignored all self targetting skills that trigger on <50%
	  Case Else
		 Return False
   EndSwitch
EndFunc   ;==>IsBelow50PercentEnemySkill

;~ Description: Returns true if skill is a hex removal skill.
Func IsHexRemovalSkill($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return BitAND(MemoryRead($aSkill + 32, 'long'), 2048)
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return BitAND(DllStructGetData($aSkill, 'Effect2'), 2048)
   Else
	  Return BitAND(MemoryRead(GetSkillPtr($aSkill) + 32, 'long'), 2048)
   EndIf
EndFunc   ;==>IsHexRemovalSkill

;~ Description: Returns true if skill is a condition removal skill.
Func IsConditionRemovalSkill($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return BitAND(MemoryRead($aSkill + 32, 'long'), 4096)
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return BitAND(DllStructGetData($aSkill, 'Effect2'), 4096)
   Else
	  Return BitAND(MemoryRead(GetSkillPtr($aSkill) + 32, 'long'), 4096)
   EndIf
EndFunc   ;==>IsConditionRemovalSkill
#EndRegion

#Region Target
;~ Description: Returns true if skill is a self-target skill.
Func TargetSelfSkill($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return MemoryRead($aSkill + 49, 'byte') = 0
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return DllStructGetData($aSkill, 'Target') = 0
   Else
	  Return MemoryRead(GetSkillPtr($aSkill) + 49, 'byte') = 0
   EndIf
EndFunc   ;==>TargetSelfSkill

;~ Description: Returns true if skill is a spirit-target skill.
Func TargetSpiritSkill($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return MemoryRead($aSkill + 49, 'byte') = 1
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return DllStructGetData($aSkill, 'Target') = 1
   Else
	  Return MemoryRead(GetSkillPtr($aSkill) + 49, 'byte') = 1
   EndIf
EndFunc   ;==>TargetSpiritSkill

;~ Description: Returns true if skill works on allies.
Func TargetAllySkill($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return MemoryRead($aSkill + 49, 'byte') = 3
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return DllStructGetData($aSkill, 'Target') = 3
   Else
	  Return MemoryRead(GetSkillPtr($aSkill) + 49, 'byte') = 3
   EndIf
EndFunc   ;==>TargetAllySkill

;~ Description: Returns true if skill works on other allies only.
Func TargetOtherAllySkill($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return MemoryRead($aSkill + 49, 'byte') = 4
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return DllStructGetData($aSkill, 'Target') = 4
   Else
	  Return MemoryRead(GetSkillPtr($aSkill) + 49, 'byte') = 4
   EndIf
EndFunc   ;==>TargetOtherAllySkill

;~ Description: Returns true if skill works on targetted enemies.
Func TargetEnemySkill($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return MemoryRead($aSkill + 49, 'byte') = 5
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return DllStructGetData($aSkill, 'Target') = 5
   Else
	  Return MemoryRead(GetSkillPtr($aSkill) + 49, 'byte') = 5
   EndIf
EndFunc   ;==>TargetEnemySkill

;~ Description: Returns true if skill works on dead allies.
Func TargetDeadAllySkill($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return MemoryRead($aSkill + 49, 'byte') = 6
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return DllStructGetData($aSkill, 'Target') = 6
   Else
	  Return MemoryRead(GetSkillPtr($aSkill) + 49, 'byte') = 6
   EndIf
EndFunc   ;==>TargetDeadAllySkill

;~ Description: Returns true if skill works on minions.
Func TargetMinionSkill($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return MemoryRead($aSkill + 49, 'byte') = 14
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return DllStructGetData($aSkill, 'Target') = 14
   Else
	  Return MemoryRead(GetSkillPtr($aSkill) + 49, 'byte') = 14
   EndIf
EndFunc   ;==>TargetMinionSkill

;~ Description: Returns true if skill has a ground AOE target.
Func TargetGroundSkill($aSkill)
   If IsPtr($aSkill) <> 0 Then
	  Return MemoryRead($aSkill + 49, 'byte') = 16
   ElseIf IsDllStruct($aSkill) <> 0 Then
	  Return DllStructGetData($aSkill, 'Target') = 16
   Else
	  Return MemoryRead(GetSkillPtr($aSkill) + 49, 'byte') = 16
   EndIf
EndFunc   ;==>TargetGroundSkill
#EndRegion

#Region Ptr
;~ Description: Returns skillptr by SkillID.
Func GetSkillPtr($aSkillID)
   Return Ptr($mSkillBase + 160 * $aSkillID)
EndFunc   ;==>GetSkillPtr
#EndRegion Ptr
#EndRegion

#Region UseSkill
;~ Description: Use a skill via asm call.
Func UseSkill($aSkillSlot, $aTarget, $aCallTarget = False)
   If IsPtr($aTarget) <> 0 Then
	  Local $lTargetID = MemoryRead($aTarget + 44, 'long')
   ElseIf IsDllStruct($aTarget) <> 0 Then
	  Local $lTargetID = DllStructGetData($aTarget, 'ID')
   Else
	  Local $lTargetID = ConvertID($aTarget)
   EndIf
   DllStructSetData($mUseSkill, 2, $aSkillSlot)
   DllStructSetData($mUseSkill, 3, $lTargetID)
   DllStructSetData($mUseSkill, 4, $aCallTarget)
   Return Enqueue($mUseSkillPtr, 16)
EndFunc   ;==>UseSkill

;~ Description: Use skill with death check, energy check.
Func UseSkillEx($aSkillSlot, $aTarget = -2, $aTimeout = 3000, $aSkillbarPtr = GetSkillbarPtr(0), $aMe = GetAgentPtr(-2))
   If IsPtr($aTarget) <> 0 Then
	  Local $lTargetPtr = $aTarget
   Else
	  Local $lTargetPtr = GetAgentPtr($aTarget)
   EndIf
   If $lTargetPtr = 0 Then Return ; no target found
   If GetSkillbarSkillRecharge($aSkillSlot, 0, $aSkillbarPtr) <> 0 Then Return
   Local $lDeadlock = TimerInit()
   ChangeTarget($aTarget)
   Local $lSkillPtr = GetSkillPtr(GetSkillbarSkillID($aSkillSlot, 0, $aSkillbarPtr))
   If GetEnergy($aMe) < MemoryRead($lSkillPtr + 53, 'byte') Then Return ; not enough energy
   If Not UseSkill($aSkillSlot, $aTarget) Then Return
   Update("Using skill " & $aSkillSlot & ".")
   Do
	  Sleep(50)
	  If GetIsDead($aMe) Then Return ; only me died
	  If GetIsDead($lTargetPtr) Then Return ; target died
	  If TimerDiff($lDeadlock) > $aTimeout Then Return
   Until GetSkillbarSkillRecharge($aSkillSlot, 0, $aSkillbarPtr) <> 0
   Return True
EndFunc   ;==>UseSkillEx

;~ Description: Finds skillslot via skillID and uses that skill if found.
Func UseSkillByID($aSkillID, $aAgentID = 0, $aSkillbarPtr = GetSkillbarPtr(0), $aMe = GetAgentPtr(-2))
   For $i = 0 to 7
	  If GetSkillbarSkillID($i, 0, $aSkillbarPtr) = $aSkillID Then
		 Return UseSkillEx($i+1, $aAgentID, Default, $aSkillbarPtr, $aMe)
	  EndIf
   Next
EndFunc   ;==>UseSkillByID

;~ Description: Uses packetsend instead of asm call to use skill.
;~ TargetType -> 0 = friendly (self, ally, npc), everything else = enemy
Func UseSkillBySkillID($aSkillID, $aTargetType = 0, $aAgentID = -2)
   If $aTargetType = 0 Then
	  Return SendPacket(0x14, 0x40, $aSkillID, 0, ConvertID($aAgentID), 0)
   Else
	  Return SendPacket(0x14, 0x21, $aSkillID, 0, ConvertID($aAgentID), 0)
   EndIf
EndFunc   ;==>UseSkillBySkillID
#EndRegion

#Region Buffs
#Region Ptr
;~ Description: Returns ptr to maintained buff.
Func GetBuffPtr($aBuffNumber, $aHeroNumber = 0, $aHeroID = GetHeroID($aHeroNumber))
   If $BuffBasePtr = 0 Then $BuffBasePtr = MemoryRead($mBasePtr182C + 0x508, 'ptr')
   For $i = 0 To MemoryRead($mBasePtr182C + 0x510) - 1
	  If MemoryRead($BuffBasePtr + 0x24 * $i) = $aHeroID Then
		 Return Ptr(MemoryRead($BuffBasePtr + 0x4 + 0x24 * $i, 'ptr') + 0x10 * ($aBuffNumber - 1))
	  EndIf
   Next
EndFunc   ;==>GetBuffPtr

;~ Description: Returns array with pointers to buffs maintained by heronumber/heroid.
Func GetBuffPtrArray($aHeroNumber = 0, $aHeroID = GetHeroID($aHeroNumber))
   If $BuffBasePtr = 0 Then $BuffBasePtr = MemoryRead($mBasePtr182C + 0x508, 'ptr')
   Local $lHeroTempPtr = 0
   Local $lBuffcount = 0
   For $i = 0 To MemoryRead($mBasePtr182C + 0x510) - 1
	  If MemoryRead($BuffBasePtr + 0x24 * $i) = $aHeroID Then
		 $lHeroTempPtr = Ptr(MemoryRead($BuffBasePtr + 0x4 + 0x24 * $i, 'ptr'))
		 $lBuffcount = MemoryRead($BuffBasePtr + 0x24 * $i + 0xC)
		 ExitLoop
	  EndIf
   Next
   If $lHeroTempPtr = 0 Then Return 0
   Local $lBuffArray[$lBuffcount + 1]
   $lBuffArray[0] = $lBuffcount
   For $i = 1 To $lBuffcount
	  $lBuffArray[$i] = Ptr($lHeroTempPtr + 0x10 * ($i-1))
   Next
   Return $lBuffArray
EndFunc   ;==>GetBuffPtrArray
#EndRegion Ptr

;~ Description: Returns current number of buffs being maintained.
Func GetBuffCount($aHeroNumber = 0, $aHeroID = GetHeroID($aHeroNumber))
   If $BuffBasePtr = 0 Then $BuffBasePtr = MemoryRead($mBasePtr182C + 0x508, 'ptr')
   Local $lBuffer
   For $i = 0 To MemoryRead($mBasePtr182C + 0x510) - 1
	  If MemoryRead($BuffBasePtr + 0x24 * $i) = $aHeroID Then Return MemoryRead($BuffBasePtr + 0x24 * $i + 0xC)
   Next
EndFunc   ;==>GetBuffCount

;~ Description: Tests if you are currently maintaining buff on Agent.
;~ Returns 0 if not, buffnumber if buff is being maintained on Agent.
Func GetIsTargetBuffed($aSkillID, $aAgentID, $aHeroNumber = 0, $aHeroID = GetHeroID($aHeroNumber))
   Local $lBuffCount = GetBuffCount($aHeroNumber)
   Local $lPtr
   For $i = 1 To $lBuffCount
	  $lPtr = GetBuffPtr($i, $aHeroNumber, $aHeroID)
	  If MemoryRead($lPtr, 'long') = $aSkillID And MemoryRead($lPtr + 12, 'long') = ConvertID($aAgentID) Then
		 Return $i
	  EndIf
   Next
EndFunc   ;==>GetIsTargetBuffed

;~ Description: Stop maintaining enchantment on target.
Func DropBuff($aSkillID, $aAgentID, $aHeroNumber = 0, $aHeroID = GetHeroID($aHeroNumber))
   Local $lBuffs = GetBuffPtrArray($aHeroNumber, $aHeroID)
   If $lBuffs = 0 Then Return -1 ; no buffs being maintained
   $aAgentID = ConvertID($aAgentID)
   For $i = 1 To $lBuffs[0]
	  If MemoryRead($lBuffs[$i], 'long') = $aSkillID And MemoryRead($lBuffs[$i] + 12, 'long') = $aAgentID Then
		 Return SendPacket(0x8, 0x23, MemoryRead($lBuffs[$i] + 8, 'long'))
	  EndIf
   Next
EndFunc   ;==>DropBuff

;~ Description: Drops all bonds.
Func DropAllBonds($aHeroNumber = 0, $aHeroID = GetHeroID($aHeroNumber))
   Local $lBuffs = GetBuffPtrArray($aHeroNumber, $aHeroID)
   If $lBuffs = 0 Then Return -1 ; no buffs being maintained
   Local $lSkillID = 0
   For $i = 1 To $lBuffs[0]
	  $lSkillID = MemoryRead($lBuffs[$i], 'long')
	  If $lSkillID = 263 Or $lSkillID = 244 Or $lSkillID = 242 Then ; $SKILLID_Protective_Bond, $SKILLID_Life_Attunement, $SKILLID_Balthazars_Spirit
		 SendPacket(0x8, 0x23, MemoryRead($lBuffs[$i] + 8, 'long'))
		 Sleep(50)
	  EndIf
   Next
EndFunc   ;==>DropAllBonds

;~ Description: Drops all buffs $aHeroNumber maintains.
Func DropAllBuffs($aHeroNumber = 0, $aHeroID = GetHeroID($aHeroNumber))
   Local $lBuffs = GetBuffPtrArray($aHeroNumber, $aHeroID)
   If $lBuffs = 0 Then Return -1 ; no buffs being maintained
   Local $lDroppedBuff = False
   For $i = 1 To $lBuffs[0]
	  SendPacket(0x8, 0x23, MemoryRead($lBuffs[$i] + 8, 'long'))
	  Sleep(50)
	  $lDroppedBuff = True
   Next
   Return $lDroppedBuff
EndFunc   ;==>DropAllBuffs
#EndRegion

#Region SkillEffects and co.
#Region Ptr
;~ Description: Returns ptr to effect by SkillID.
Func GetSkillEffectPtr($aSkillID, $aHeroNumber = 0, $aHeroID = GetHeroID($aHeroNumber))
   If $BuffBasePtr = 0 Then $BuffBasePtr = MemoryRead($mBasePtr182C + 0x508, 'ptr')
   Local $lEffectCount = 0
   Local $lTemp = 0
   Local $lEffectBasePtr = 0
   For $i = 0 To MemoryRead($mBasePtr182C + 0x510) - 1
	  $lTemp = 0x24 * $i
	  If MemoryRead($BuffBasePtr + $lTemp) = $aHeroID Then
		 $lEffectCount = MemoryRead($BuffBasePtr + $lTemp + 0x1C)
		 $lEffectBasePtr = MemoryRead($BuffBasePtr + $lTemp + 0x14, 'ptr')
		 For $j = 0 To $lEffectCount - 1
			If MemoryRead($lEffectBasePtr + 24 * $j, 'long') = $aSkillID Then Return Ptr($lEffectBasePtr + 24 * $j)
		 Next
	  EndIf
   Next
EndFunc   ;==>GetSkillEffectPtr

;~ Description: Returns ptr to effect by EffectNumber.
Func GetSkillEffectPtrByEffectnumber($aEffectNumber, $aHeroNumber = 0, $aHeroID = GetHeroID($aHeroNumber))
   If $BuffBasePtr = 0 Then $BuffBasePtr = MemoryRead($mBasePtr182C + 0x508, 'ptr')
   Local $lEffectCount = 0
   Local $lTemp = 0
   Local $lEffectBasePtr = 0
   For $i = 0 To MemoryRead($mBasePtr182C + 0x510) - 1
	  $lTemp = 0x24 * $i
	  If MemoryRead($BuffBasePtr + $lTemp) = $aHeroID Then
		 $lEffectBasePtr = MemoryRead($BuffBasePtr + $lTemp + 0x14, 'ptr')
		 Return Ptr($lEffectBasePtr + 24 * ($aEffectNumber))
	  EndIf
   Next
EndFunc   ;==>GetSkillEffectPtrByEffectnumber

;~ Description: Returns array of effectptr on agent.
Func GetEffectsPtr($aSkillID = 0, $aHeroNumber = 0, $aHeroID = GetHeroID($aHeroNumber))
   If $BuffBasePtr = 0 Then $BuffBasePtr = MemoryRead($mBasePtr182C + 0x508, 'ptr')
   Local $lEffectCount = 0
   Local $lTemp = 0
   Local $lEffectBasePtr = 0
   For $i = 0 To MemoryRead($mBasePtr182C + 0x510) - 1
	  $lTemp = 0x24 * $i
	  If MemoryRead($BuffBasePtr + $lTemp) = $aHeroID Then
		 $lEffectCount = MemoryRead($BuffBasePtr + $lTemp + 0x1C)
		 $lEffectBasePtr = MemoryRead($BuffBasePtr + $lTemp + 0x14, 'ptr')
		 If $aSkillID = 0 Then
			Local $lReturnArray[$lEffectCount + 1]
			$lReturnArray[0] = $lEffectCount
			For $j = 1 To $lEffectCount
			   $lReturnArray[$j] = Ptr($lEffectBasePtr + 24 * ($j - 1))
			Next
			Return $lReturnArray
		 Else
			Local $lReturnArray[2] = [0, 0]
			For $j = 0 To $lEffectCount - 1
			   If MemoryRead($lEffectBasePtr + 24 * $j, 'long') = $aSkillID Then
				  $lReturnArray[0] = 1
				  $lReturnArray[1] = Ptr($lEffectBasePtr + 24 * $j)
				  Return $lReturnArray
			   EndIf
			Next
		 EndIf
	  EndIf
   Next
EndFunc   ;==>GetEffectsPtr
#EndRegion Ptr

;~ Description: Returns True if you're under the effect of $aEffectSkillID.
Func HasEffect($aEffectSkillID, $aHeroNumber = 0, $aHeroID = GetHeroID($aHeroNumber))
   Return GetSkillEffectPtr($aEffectSkillID, $aHeroNumber, $aHeroID) <> 0
EndFunc   ;==>HasEffect

;~ Description: Returns time remaining before an effect expires, in milliseconds. SkillTimer does NOT work when rendering disabled.
Func GetEffectTimeRemaining($aEffect)
   If IsArray($aEffect) Then Return 0
   If $aEffect = 0 Then Return 0
   If IsPtr($aEffect) <> 0 Then
	  Local $lTimeStamp = MemoryRead($aEffect + 20, 'long')
	  Local $lDuration = MemoryRead($aEffect + 16, 'float')
   ElseIf IsDllStruct($aEffect) <> 0 Then
	  Local $lTimeStamp =  DllStructGetData($aEffect, 'TimeStamp')
	  Local $lDuration = DllStructGetData($aEffect, 'Duration')
   Else
	  Local $lPtr = GetSkillEffectPtr($aEffect)
	  If $lPtr = 0 Then Return 0
	  Local $lTimeStamp = MemoryRead($lPtr + 20, 'long')
	  Local $lDuration = MemoryRead($lPtr + 16, 'float')
   EndIf
   Local $lReturn = $lDuration * 1000 - (GetSkillTimer() - $lTimeStamp)
   If $lReturn < 0 Then Return 0
   Return $lReturn
EndFunc   ;==>GetEffectTimeRemaining
#EndRegion

#Region Misc
;~ Description: Change your secondary profession.
Func ChangeSecondProfession($aProfession, $aHeroNumber = 0, $aHeroID = GetHeroID($aHeroNumber))
   Return SendPacket(0xC, 0x3B, $aHeroID, $aProfession)
EndFunc   ;==>ChangeSecondProfession
#EndRegion