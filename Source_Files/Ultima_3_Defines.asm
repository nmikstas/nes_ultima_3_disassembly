;-------------------------------------[General Purpose Variables]------------------------------------

.alias GenByte26        $26     ;General use byte.
.alias GenByte27        $27     ;General use byte.

.alias GenByte29        $29     ;General use byte.
.alias GenByte2A        $2A     ;General use byte.
.alias GenPtr29         $29     ;General use pointer.
.alias GenPtr29LB       $29     ;General use pointer, lower byte.
.alias GenPtr29UB       $2A     ;General use pointer, upper byte.

.alias GenByte2B        $2B     ;General use byte.
.alias GenByte2C        $2C     ;General use byte.
.alias GenPtr2B         $2B     ;General use pointer.
.alias GenPtr2BLB       $2B     ;General use pointer, lower byte.
.alias GenPtr2BUB       $2C     ;General use pointer, upper byte.

.alias GenByte2D        $2D     ;General use byte.
.alias GenByte2E        $2E     ;General use byte.
.alias GenWord2DLB      $2D     ;General use word, lower byte.
.alias GenWord2DUB      $2E     ;General use word, upper byte.
.alias GenPtr2D         $2D     ;General use pointer.
.alias GenPtr2DLB       $2D     ;General use pointer, lower byte.
.alias GenPtr2DUB       $2E     ;General use pointer, upper byte.

.alias GenByte2F        $2F     ;General use byte.

.alias GenByte4E        $4E     ;General use byte.

.alias GenPtrF0         $F0     ;General use pointer.
.alias GenPtrF0LB       $F0     ;General use pointer, lower byte.
.alias GenPtrF0UB       $F1     ;General use pointer, upper byte.

.alias GenByteF4        $F4     ;General use byte.
.alias GenByteF5        $F5     ;General use byte.
.alias GenPtrF4         $F4     ;General use pointer.
.alias GenPtrF4LB       $F4     ;General use pointer, lower byte.
.alias GenPtrF4UB       $F5     ;General use pointer, upper byte.

.alias GenByteF8        $F8     ;General use byte.

.alias GenByteFD        $FD     ;General use byte.

;-----------------------------------------[Variable Defines]-----------------------------------------

.alias Increment0       $00     ;Increments every frame. Rolls over at #$FF.
.alias Increment1       $01     ;Increments every frame. Resets on any button release.
.alias WorldUpdating    $02     ;1=Updates being performed on PPU, player movement, etc.
.alias CurPPUConfig0    $03     ;Current PPU configuration(register $2000).
.alias CurPPUConfig1    $04     ;Current PPU configuration(register $2001).

.alias CurPRGBank       $08     ;Current MMC1 bank active in the lower position.
.alias Pad1Input        $09     ;The input by the player on controller 1.
.alias InputChange      $0A     ;1=button has changed status since last check.

.alias ScrollDirAmt     $0B     ;Scroll screen by amount and direction given.
                                ;The upper nibble is the 1s compliment of the amount to scroll.
                                ;This means 0 scrolls the most while $F scrolls the least.
                                ;Lower nibble is the direction to scroll(referenced to background):
                                ;1=left, 2=right, 4=up, 8=down.

.alias UpdatePPU        $0E     ;#$01=PPU data waiting in PPU buffer
.alias NTXPosLB         $0F     ;Name table pixel X position, lower byte(Scroll X).
.alias NTXPosUB         $10     ;Name table pixel X position, upper byte.
.alias NTYPosLB         $11     ;Name table pixel Y position, lower byte(Scroll Y).
.alias NTYPosUB         $12     ;Name table pixel Y position, upper byte.
.alias NTXPosLB16       $13     ;Name table pixel X position, lower byte, block aligned.
.alias NTXPosUB16       $14     ;Name table pixel X position, upper byte, block aligned.
.alias NTYPosLB16       $15     ;Name table pixel Y position, lower byte, block aligned.
.alias NTYPosUB16       $16     ;Name table pixel Y position, upper byte, block aligned.

;Name entry variables.
.alias NameLength       $17     ;The current length of the name being entered.
.alias NameSelRow       $18     ;The current row of the selector is on.
.alias NameCharIndex    $19     ;The index of the character the selector is on.

.alias PPUPyLdPtr       $29     ;PPU buffer payload pointer.
.alias PPUPyLdPtrLB     $29     ;PPU buffer payload pointer, lower byte.
.alias PPUPyLdPtrUB     $2A     ;PPU buffer payload pointer, upper byte.

;Text buffer registers.
.alias TXTYPos          $29     ;Text string, Y position on screen in tiles.
.alias TXTXPos          $2A     ;Text string, X position on screen in tiles.
.alias TXTSrcPtr        $2B     ;Text string, data source pointer.
.alias TXTSrcPtrLB      $2B     ;Text string, data source pointer, lower byte.
.alias TXTSrcPtrUB      $2C     ;Text string, data source pointer, upper byte.
.alias TXTClrRows       $2D     ;Number of tile rows to clear when showing text.
.alias TXTClrCols       $2E     ;Number of tile columns to clear when showing text.

;PPU buffer registers.
.alias PPUSrcPtr        $29     ;PPU write, data source pointer.
.alias PPUSrcPtrLB      $29     ;PPU write, data source pointer, lower byte.
.alias PPUSrcPtrUB      $2A     ;PPU write, data source pointer, upper byte.
.alias PPUDstPtr        $2B     ;PPU write, data destination pointer.
.alias PPUDstPtrLB      $2B     ;PPU write, data destination pointer, lower byte.
.alias PPUDstPtrUB      $2C     ;PPU write, data destination pointer, upper byte.
.alias PPUByteCnt       $2D     ;PPU write, 16-bit counter.
.alias PPUByteCntLB     $2D     ;PPU write, 16-bit counter, lower byte.
.alias PPUByteCntUB     $2E     ;PPU write, 16-bit counter, upper byte.

;Window drawing.
.alias WndYPos          $29     ;Y position of window to draw.
.alias WndXPos          $2A     ;X position of window to draw.
.alias WndHeight        $2D     ;Height of window to draw.
.alias WndWidth         $2E     ;Width of window to draw.

.alias TextIndex        $30     ;Index to text message. $FE, $FF=Buffer already filled.

.alias MapDatPtr        $41     ;Map data pointer.
.alias MapDatPtrLB      $41     ;Map data pointer, lower byte.
.alias MapDatPtrUB      $42     ;Map data pointer, upper byte.

.alias NPCSrcPtr        $45     ;Base address of NPC data for current map.
.alias NPCSrcPtrLB      $45     ;Base address of NPC data for current map, lower byte.
.alias NPCSrcPtrUB      $46     ;Base address of NPC data for current map, upper byte.

.alias MapYPos          $49     ;Player's Y position on the current map.
.alias MapXPos          $4A     ;Player's X position on the current map.
.alias ReturnYPos       $4B     ;Return Y coordinates on world map when leaving town/dungeon.
.alias ReturnXPos       $4C     ;Return X coordinates on world map when leaving town/dungeon.

.alias PPUStringLen     $4D     ;Length of the current PPU sting to process.
.alias WorkPPUBufLen    $4E     ;Working PPU buffer length. Changes when strings are processed.

.alias MapBank          $6F     ;Contains the bank number the current map data can be found on.
.alias ThisMap          $70     ;Current map.

.alias EndCreditPtr     $75     ;Pointer to end credits data.
.alias EndCreditPtrLB   $75     ;Pointer to end credits data, lower byte.
.alias EndCreditPtrUB   $76     ;Pointer to end credits data, upper byte.

.alias Ch1Dir           $7E     ;Character 1 direction. $00,$04=down, $01=right, $02=left, $08=up.
.alias Ch2Dir           $7F     ;Character 2 direction. $00,$04=down, $01=right, $02=left, $08=up.
.alias Ch3Dir           $80     ;Character 3 direction. $00,$04=down, $01=right, $02=left, $08=up.
.alias Ch4Dir           $81     ;Character 4 direction. $00,$04=down, $01=right, $02=left, $08=up.

.alias Ch1Class         $7E     ;Char 1 class while making pre-made characters. $FF=Not chosen yet.
.alias Ch2Class         $7F     ;Char 2 class while making pre-made characters. $FF=Not chosen yet.
.alias Ch3Class         $80     ;Char 3 class while making pre-made characters. $FF=Not chosen yet.
.alias Ch4Class         $81     ;Char 4 class while making pre-made characters. $FF=Not chosen yet.

.alias TextBasePtr      $8B     ;Pointer to dialog pointer table($8000 or $9D80).
.alias TextBasePtrLB    $8B     ;Pointer to dialog pointer table lower byte.
.alias TextBasePtrUB    $8C     ;Pointer to dialog pointer table upper byte.
.alias TextCharPtr      $8D     ;Pointer to text character.
.alias TextCharPtrLB    $8D     ;Pointer to text character, lower byte.
.alias TextCharPtrUB    $8E     ;Pointer to text character, upper byte.
.alias NewLineCount     $8D     ;Counts the number of new lines for formatting text.

.alias ChrPtrBaseLB     $91     ;Base address for character pointer data, lower byte.
.alias ChrPtrBaseUB     $92     ;Base address for character pointer data, upper byte.
.alias Pos1ChrPtr       $91     ;Position 1 character data pointer.
.alias Pos1ChrPtrLB     $91     ;Position 1 character data pointer, lower byte.
.alias Pos1ChrPtrUB     $92     ;Position 1 character data pointer, upper byte.
.alias Pos2ChrPtr       $93     ;Position 2 character data pointer.
.alias Pos2ChrPtrLB     $93     ;Position 2 character data pointer, lower byte.
.alias Pos2ChrPtrUB     $94     ;Position 2 character data pointer, upper byte.
.alias Pos3ChrPtr       $95     ;Position 3 character data pointer.
.alias Pos3ChrPtrLB     $95     ;Position 3 character data pointer, lower byte.
.alias Pos3ChrPtrUB     $96     ;Position 3 character data pointer, upper byte.
.alias Pos4ChrPtr       $97     ;Position 4 character data pointer.
.alias Pos4ChrPtrLB     $97     ;Position 4 character data pointer, lower byte.
.alias Pos4ChrPtrUB     $98     ;Position 4 character data pointer, upper byte.
.alias CrntChrPtr       $99     ;And $9A. Pointer to current character data to change.
.alias CrntChrPtrLB     $99     ;And $9A. Pointer to current character data to change, lower byte.
.alias CrntChrPtrUB     $9A     ;And $9A. Pointer to current character data to change, upper byte.

.alias DisSpriteAnim    $9E     ;Non-zero value disables sprite animations.
.alias DisNPCMovement   $9F     ;Non-zero value stops NPCs from moving and disables water animation.

.alias NotUsedA6        $A6     ;Written to but never read.

.alias MapProperties    $A8     ;Properties of current map:
                                ;Bit 0 - 1=Player/NPCs invisible(dungeons).
                                ;Bit 1 - 1=Turn based map(fight maps).
                                ;Bit 2 - 1=Show moon phases(overworld).
                                ;Bit 3 - 1=NPCs present(all maps except overworld).
.alias IgnoreInput      $A9     ;1=Ignore game pad input.

.alias HideUprSprites   $AF     ;Multiple of 4. sprites higher than valule are hidden off screen.

.alias DungeonLevel     $B2     ;The current dungeon level minus 1.
.alias FightTurnIndex   $B3     ;Index to player/enemy that moves next. 0-3 are player characters.
                                ;4 through 11 are enemies. 12 max.
.alias ValidGamesFlags  $B3     ;The 3LSBs contain flag showing wich spots have valid saved games.
                                ;This is for Bank0C only.
.alias CurPieceYVis     $B4     ;Current piece active on battefield. Upper nibble is their Y
                                ;position on the battlefiled. 1=top row. LSB 0=invisible, 1=visible.

.alias OnBoat           $B9     ;$01=On boat, $00=Not on boat.

.alias ConstPPUBufLen   $BC     ;Initial PPU buffer length. Does not change during processing.

.alias InitNewMusic     $C1     ;MSB start new music, lower nibble is music to be started.

.alias SGDatPtr         $C5     ;Save game data pointer.
.alias SGDatPtrLB       $C5     ;Save game data pointer, lower byte.
.alias SGDatPtrUB       $C6     ;Save game data pointer, upper byte.

.alias LastDirMoved     $CB     ;Last direction player moved. $00=none, $01=r, $02=l, $04=d, $08=u.
.alias LastTalkedNPC0   $CC     ;Last NPC player talked to. Keeps track of one time messages.
.alias LastTalkedNPC1   $CD     ;Second to last NPC player talked to.
.alias TimeStopTimer    $CE     ;Time stops if > 0. Decrements every step.

.alias _MapDatPtr       $CF     ;Map data pointer.
.alias _MapDatPtrLB     $CF     ;Map data pointer, lower byte.
.alias _MapDatPtrUB     $D0     ;Map data pointer, upper byte. 

.alias FirstMoonPhase   $D3     ;Upper nibble: Phase of the left moon $0-$7.
                                ;lower nibble: counter for current phase $0-$B.
.alias SecondMoonPhase  $D4     ;Upper nibble: Phase of the left moon $0-$7.
                                ;lower nibble: counter for current phase $0-$3.

.alias ThisSFX          $D6     ;Current SFX to play. MSB set=initialize SFX.

.alias BribePray        $DA     ;LSB set=party can pray, 2nd bit set=party can bribe.
.alias PrevMapProp      $DB     ;Properties of the previous map before a fight was started.

.alias OnHorse          $DE     ;LSB set=Has horses, MSB set=Riding horses.

.alias ExodusDead       $E0     ;$01=Exodus dead, $02=Game won, $FF=Time expired, everyone dies.

.alias EnemyNum         $E5     ;Enemy number. Also $FF=enemy remains after fight.
                                ;Numbers are the same as those found on Bank 3.

.alias NewGmCreated     $E7     ;$01=A new game greated. Bank0C only.
.alias EndGmTimerLB     $E7     ;Escape Exodus castle timer, lower byte. updates every frame.
.alias EndGmTimerUB     $E8     ;Escape Exodus castle timer, upper byte. $0F=Times up.


.alias DoAnimations     $EA     ;1=Do animation, 0=skip animations.

.alias ActiveMessage    $EF     ;$01=Message not completed. Used when message is multi part.

.alias DivLBF4          $F4     ;Lower byte of result of integer division.
.alias DivUBF5          $F5     ;Upper byte of result of integer division.
.alias DivisorF8        $F8     ;Byte to divide by.

.alias SpriteRAM        $0200   ;Through $02FF. 4 bytes per sprite.

;----------------------------------------------------------------------------------------------------

;The PPU buffer has the following format:
;
;   +---------------------------Total PPU buffer length. Address $0300.
;   | +-------------------------String 1 length.
;   | | +-----------------------String 1 PPU address, upper byte.
;   | | | +---------------------String 1 PPU address, lower byte.
;   | | | |             +-------String 1 payload.
;   | | | |             |
;   | | | | |-----------+-----------|
;   X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X X ... Up to 128 bytes.
;                                     | | | |----------+----------|
;                                     | | |            |
;  String 2 length--------------------+ | |            |
;  String 2 PPU address, upper byte-----+ |            |
;  String 2 PPU address, lower byte-------+            |
;  String 2 payload------------------------------------+

.alias PPUBufLength     $0300   ;Length of data in bytes to write to PPU.
.alias PPUBufBase       $0300   ;Base address of PPU buffer.
.alias PPUBuffer        $0300   ;Contains strings of data to write to the PPU.

;----------------------------------------------------------------------------------------------------

.alias BoatXPos         $03D5   ;X position of player's boat on the overworld map.
.alias BoatYPos         $03D6   ;Y position of player's boat on the overworld map.

.alias Ch1Index         $03D9   ;Character 1 index in character pool.
.alias Ch2Index         $03DA   ;Character 2 index in character pool.
.alias Ch3Index         $03DB   ;Character 3 index in character pool.
.alias Ch4Index         $03DC   ;Character 4 index in character pool.

;The following RAM is used to load the NPC sprites on the current map. There are 4 bytes per sprite.
;They do not Keep track of current direction, or movement on screen. They are used as a referecne to 
;load sprite data when a sprite moves from off screen to on screen. A total of 32 NPCs per map.

.alias NPCSprIndex      $0400   ;Through $047C. Index to tile patterns used for sprite and color.
.alias NPCOnscreen      $0401   ;Through $047D. #$00 indicates NPC is not on the screen.
.alias NPCXPos          $0402   ;Through $047E. NPC X position on current map.
.alias NPCYPOS          $0403   ;Through $044F. NPC Y position on current map.

.alias PaletteBuffer    $0540   ;Through $055F. Buffer for palette data.

.alias TextBufferBase   $0580   ;The base address of the text buffer.
.alias TextBuffer       $0580   ;Buffer for text to be displayed on the screen.

.alias ScreenBlocks     $0700   ;Through $07FF. The blocks currently on the screen.

;---------- Save Game 1 Data ----------
.alias SG1Base          $6000   ;Base address of save game 1 data.
.alias SG1Valid1        $6000   ;Should always be $41 if save game 1 is valid.
.alias SG1Valid2        $6001   ;Should always be $42 if save game 1 is valid.
.alias SG1Name          $6002   ;Through $6006. Save game 1 name.
.alias SG1P1CharIdx     $6010   ;Index in character list of player's first character.
.alias SG1P2CharIdx     $6011   ;Index in character list of player's second character.
.alias SG1P3CharIdx     $6012   ;Index in character list of player's third character.
.alias SG1P4CharIdx     $6013   ;Index in character list of player's fourth character.

;---------- Save Game 2 Data ----------
.alias SG2Base          $6600   ;Base address of save game 2 data.
.alias SG2Valid1        $6600   ;Should always be $41 if save game 2 is valid.
.alias SG2Valid2        $6601   ;Should always be $42 if save game 2 is valid.
.alias SG2Name          $6602   ;Through $6606. Save game 2 name.

;---------- Save Game 3 Data ----------
.alias SG3Base          $6C00   ;Base address of save game 3 data.
.alias SG3Valid1        $6C00   ;Should always be $41 if save game 3 is valid.
.alias SG3Valid2        $6C01   ;Should always be $42 if save game 3 is valid.
.alias SG3Name          $6C02   ;Through $C006. Save game 3 name.

.alias SpriteBufferBase $7300   ;Base address of sprite buffer.
.alias SpriteBuffer     $7300   ;Through $73FF. Sprite data buffered here before RAM.
.alias BlocksBuffer     $7400   ;Through $74FF. Blocks to be put on the screen.

.alias MapRAM           $7800   ;Through $7FFF. The current map is loaded into this area. 64 X 64.
                                ;Each byte is 2 tiles. There is no compression.

;---------- Player 1 Data ----------
;This data repeats for the additional 3 other characters every 64 bytes.

.alias Ch1Data          $7200   ;Base address of character 1's data.
.alias ChName           $7200   ;Through $7204. Character name, pattern table indexes.
.alias ChRace           $7205   ;Character race. Unlisted values are invalid:
                                ;#$00=Human, #$01=Elf, #$02=Dwarf, #$03=Bobit, #$04=Fuzzy.
.alias ChClass          $7206   ;Character class. Unlisted values are invalid:
                                ;#$00=Fighter, #$01=Cleric,    #$02=Wizard, #$03=Thief,
                                ;#$04=Paladin, #$05=Barbarian, #$06=Lark,   #$07=Illusionist,
								;#$08=Druid,   #$09=Alchemist, #$0A=Ranger.
.alias ChStr            $7207   ;Character Strength stat.
.alias ChDex            $7208   ;Character Dexterity stat.
.alias ChInt            $7209   ;Character Intelligence stat.
.alias ChWis            $720A   ;Character Wisdom stat.
.alias ChCond           $720B   ;Character condition. Unlisted values are invalid:
                                ;#$00=Good, #$01=Poisoned, #$02=Cold, #$03=Dead, #$04=Ash.
.alias ChDagger         $720C   ;Number of daggers in the character's inventory.
.alias ChMace           $720D   ;Number of Maces in the character's inventory.
.alias ChSling          $720E   ;Number of slings in the Character's inventory.
.alias ChAxe            $720F   ;Number of axes in the Character's inventory.
.alias ChBlowgun        $7210   ;Number of blow guns in the Character's inventory.
.alias ChSword          $7211   ;Number of swords in the Character's inventory.
.alias ChSpear          $7212   ;Number of spears in the Character's inventory.
.alias ChBroadAx        $7213   ;Number of broad axes in the Character's inventory.
.alias ChBow            $7214   ;Number of bows in the Character's inventory.
.alias ChIronSwrd       $7215   ;Number of iron swords in the Character's inventory.
.alias ChGloves         $7216   ;Number of gloves in the Character's inventory.
.alias ChFtrsAx         $7217   ;Number of fighter's axes in the Character's inventory.
.alias ChSlvBow         $7218   ;Number of silver bows in the Character's inventory.
.alias ChSunSwrd        $7219   ;Number of sun swords in the Character's inventory.
.alias ChMysticw        $721A   ;Number of mystic weapons in the Character's inventory.
.alias ChCloth          $721B   ;Number of cloth armors in the character's inventory.
.alias ChLeather        $721C   ;Number of leather armors in the character's inventory.
.alias ChBronze         $721D   ;Number of bronze armors in the character's inventory.
.alias ChIron           $721E   ;Number of iron armors in the character's inventory.
.alias ChSteel          $721F   ;Number of steel armors in the character's inventory.
.alias ChDrgnarm        $7220   ;Number of dragon armors in the character's inventory.
.alias ChMysticA        $7221   ;Number of mystic armors in the character's inventory.
.alias ChTorches        $7222   ;Number of torches in the character's inventory.
.alias ChKey            $7223   ;Number of keys in the character's inventory.
.alias ChGem            $7224   ;Number of gems in the character's inventory.
.alias ChPowder         $7225   ;Number of powders in the character's inventory.
.alias ChTent           $7226   ;Number of tents in the character's inventory.
.alias ChGoldpick       $7227   ;Non zero number indicates character has the gold pick.
.alias ChSlvrPick       $7228   ;Non zero number indicates character has the silver pick.
.alias ChSlvrhorn       $7229   ;Non zero number indicates character has the silver horn.
.alias ChCmpshrt        $722A   ;Non zero number indicates character has the compass heart.
.alias ChFoodLB         $722B   ;Character's food, lower byte.
.alias ChFoodUB         $722C   ;Character's food, upper byte.
.alias ChHPLB           $722D   ;Character's hit points, lower byte.
.alias ChHPUB           $722E   ;Character's hit points, upper byte.
.alias ChMP             $722F   ;Character's magic points.
.alias ChGoldLB         $7230   ;Character's gold, lower byte.
.alias ChGoldUB         $7231   ;Character's gold, upper byte.

.alias ChLevel          $7233   ;Character's level.
.alias ChEqWeapon       $7234   ;Character's currently equipped weapon. Same numbers as above.
.alias ChEqArmor        $7235   ;Character's currently equipped armor. Same nubers as above.
.alias ChMaxHPLB        $7236   ;Character's max hit points, lower byte.
.alias ChMaxHPUB        $7237   ;Character's max hit points, upper byte.
.alias ChMaxMP          $7238   ;Character's max magic points.
.alias ChExpLB          $7239   ;Character's experience points, lower byte.
.alias ChExpUB          $723A   ;Character's experience points, upper byte.
.alias ChMarks          $723B   ;Marks the character has aquired:
                                ;%00000001=Force, %00000010=Fire, %00000100=Snake, %00001000=King.
.alias ChCards          $723C   ;Cards the character has aquired:
                                ;%00000001=Death, %00000010=Sol, %00000100=Love, %00001000=Moons.
.alias ChFlower         $723D   ;Non zero number indicates character has a flower.

;---------- Player 2, 3 and 4 Data ----------
.alias Ch2Data          $7240   ;Base address of character 2's data.
.alias Ch3Data          $7280   ;Base address of character 3's data.
.alias Ch4Data          $72C0   ;Base address of character 4's data.

;--------------------------------------[Sound Engine Variables]--------------------------------------

.alias ChnDatPtr        $F2     ;Base address for the channel data pointers below.
.alias ChnDatPtrLB      $F2     ;Base address for the channel data pointers below, lower byte.
.alias ChnDatPtrUB      $F3     ;Base address for the channel data pointers below, upper byte.
.alias SQ1DatPtrLB      $F2     ;Data pointer for SQ1 channel data, lower byte.
.alias SQ1DatPtrUB      $F3     ;Data pointer for SQ1 channel data, lower byte.
.alias SQ2DatPtrLB      $F6     ;Data pointer for SQ2 channel data, lower byte.
.alias SQ2DatPtrUB      $F7     ;Data pointer for SQ2 channel data, lower byte.
.alias TriDatPtrLB      $FA     ;Data pointer for triangle channel data, lower byte.
.alias TriDatPtrUB      $FB     ;Data pointer for triangle channel data, lower byte.
.alias NseDatPtrLB      $FE     ;Data pointer for noise channel data, lower byte.
.alias NseDatPtrUB      $FF     ;Data pointer for noise channel data, lower byte.

.alias ChnCtrl0         $7600   ;Base address for channel control bit 0.
.alias ChnCtrl1         $7601   ;Base address for channel control bit 1.
.alias ChnCtrl2         $7602   ;Base address for channel control bit 2.
.alias ChnCtrl3         $7603   ;Base address for channel control bit 3.

.alias NextSQ1Ctrl0     $7600   ;Next data to load into SQ1 control byte 0.
.alias NextSQ1Ctrl1     $7601   ;Next data to load into SQ1 control byte 1.
.alias NextSQ1Ctrl2     $7602   ;Next data to load into SQ1 control byte 2.
.alias NextSQ1Ctrl3     $7603   ;Next data to load into SQ1 control byte 3.
.alias NextSQ2Ctrl0     $7604   ;Next data to load into SQ2 control byte 0.
.alias NextSQ2Ctrl1     $7605   ;Next data to load into SQ2 control byte 1.
.alias NextSQ2Ctrl2     $7606   ;Next data to load into SQ2 control byte 2.
.alias NextSQ2Ctrl3     $7607   ;Next data to load into SQ2 control byte 3.
.alias NextTriCtrl0     $7608   ;Next data to load into Triangle control byte 0.
.alias NextTriCtrl1     $7609   ;Next data to load into Triangle control byte 1.
.alias NextTriCtrl2     $760A   ;Next data to load into Triangle control byte 2.
.alias NextTriCtrl3     $760B   ;Next data to load into Triangle control byte 3.
.alias NextNseCtrl0     $760C   ;Next data to load into Noise control byte 0.
.alias NextNseCtrl1     $760D   ;Next data to load into Noise control byte 1.
.alias NextNseCtrl2     $760E   ;Next data to load into Noise control byte 2.
.alias NextNseCtrl3     $760F   ;Next data to load into Noise control byte 3.
.alias AttackDatPtrLB   $7610   ;Pointer to note attack data, lower byte.
.alias AttackDatPtrUB   $7611   ;Pointer to note attack data, upper byte.
.alias SustainDatPtrLB  $7612   ;Pointer to note sustain data, lower byte.
.alias SustainDatPtrUB  $7613   ;Pointer to note sustain data, upper byte.
.alias ReleaseDatPtrLB  $7620   ;Pointer to note release data, lower byte.
.alias ReleaseDatPtrUB  $7621   ;Pointer to note release data, upper byte.

.alias Volume1sComp     $7622   ;Temp storage for channel volume, 1's complimented and shifted.
.alias ChnLenCounter    $7623   ;Base address for the four counters below.
.alias SQ1LenCounter    $7623   ;Remaining time in frames of current SQ1 musical note.
.alias SQ2LenCounter    $7627   ;Remaining time in frames of current SQ2 musical note.
.alias TriLenCounter    $762B   ;Remaining time in frames of current triangle musical note.

.alias NseUnused762E    $762E   ;Not used.
.alias NseLenCounter    $762F   ;Remaining time in frames of current noise musical note.
.alias ChnAttackDatLen  $7630   ;Length of attack data table.
.alias ChnSustainDatLen $7631   ;Length of sustain data table.
.alias ChnReleaseDatLen $7632   ;Length of release data table.

.alias NseAttackDatLen  $763C   ;Length of noise attack data table.
.alias NseSustainDatLen $763D   ;Length of noise sustain data table.
.alias NseReleaseDatLen $763E   ;Length of noise release data table.

.alias ChnNoteLength    $7640   ;Total length of current note.
.alias ChnSustainTime   $7641   ;Note time remaining when note switches to sustain phase.
.alias ChnReleaseTime   $7642   ;Note time remaining when note switches to release phase.
.alias ChnVibUnused     $7643   ;Unused vibrato data. Always 0.

.alias NseNoteLength    $764C   ;Total length of current noise.
.alias NseSustainTime   $764D   ;Time remaining when noise switches to sustain phase.
.alias NseReleaseTime   $764E   ;Time remaining when noise switches to release phase.

.alias TriCompensate    $764B   ;#$FF=Adjust Triangle note index to keep same frequency
                                ;as the SQ channels. This is because the triangle channel
                                ;plays at a frequency half that as the SQ channels by default.

.alias ChnVibSpeedLB    $7650   ;Speed control of vibrato, lower byte.
.alias ChnVibSpeedUB    $7651   ;Speed control of vibrato, upper byte.
.alias ChnVibCntLB      $7652   ;Carrys over into the upper byte for vibrato speed control.
.alias ChnVibCntUB      $7653   ;Lower 3 bits used to calculate vibrato note offset in $7660.

.alias ChnVibBase       $7660   ;Base address of vibrato notes.
.alias MusSQ1VibNotes   $7660   ;8 bytes each. Contain the vibrato values to play for the channel.
.alias MusSQ2VibNotes   $7668   ;A pointer cycles through the bytes and places them in the lower
.alias MusTriVibNotes   $7670   ;byte of the frequency control(control byte 2).
.alias ChnVibIntensity  $7678   ;Lower numbers add more vibrato to the note. The higher the
                                ;note, the more extreme the vibrato. SQ2 usually plays lower
								;notes than SQ1 so it usually has a higher vibrato value.
.alias ChnVibratoDF     $7679   ;Adds and subtracts from the base note to calculate the change
                                ;in frequency(DF) every frame. Used to calculate the values in
                                ;the 8 byte vibrato table($7660-$7667 for SQ1).

.alias MusCurrent       $7684   ;Stores number of current song being played.

.alias Volume1sComp_    $768A   ;Temp storage for channel volume, 1's complimented and shifted.

;Below is the registers associated with the SFX control functions. The data is
;divided into 4 segments. This means that the SFX player can handle up to
;4 SFX at a time, one for each audio channel (SQ1, SQ2, Tri and Noise).

.alias SFXFinished      $768B   ;#$01=SFX currently playing just finished.
.alias SFXSQ1Finished   $768B   ;#$01=SFX currently playing on SQ1 just finished.
.alias SFXSQ2Finished   $768F   ;#$01=SFX currently playing on SQ2 just finished.
.alias SFXTriFinished   $7693   ;#$01=SFX currently playing on Triangle just finished.

.alias SFXNseUnused7696 $7696   ;Not used.
.alias SFXNseFinished   $7697   ;#$01=SFX currently playing on noise just finished.
.alias SFXPtrLB         $7698   ;Base address, lower byte of SFX data being read.
.alias SFXPtrUB         $7699   ;Base address, upper byte of SFX data being read.
.alias SFXIndex         $769A   ;index for currenty playing SFX.
.alias SFXLeft          $769B   ;Number of frames left to play in current SFX.
.alias SFXChannel       $76A8   ;SFX channel being used.

.alias SFXSQ1PtrLB      $7698   ;Base address, lower byte of SFX SQ1 data being read.
.alias SFXSQ1PtrUB      $7699   ;Base address, upper byte of SFX SQ1 data being read.
.alias SFXSQ1Index      $769A   ;Index of SFX SQ1 data currently being read.
.alias SFXSQ1Left       $769B   ;Number of frames left to play in SQ1 SFX.
.alias SFXSQ2PtrLB      $769C   ;Base address, lower byte of SFX SQ2 data being read.
.alias SFXSQ2PtrUB      $769D   ;Base address, upper byte of SFX SQ2 data being read.
.alias SFXSQ2Index      $769E   ;Index of SFX SQ2 data currently being read.
.alias SFXSQ2Left       $769F   ;Number of frames left to play in SQ2 SFX.
.alias SFXTriPtrLB      $76A0   ;Base address, lower byte of SFX Triangle data being read.
.alias SFXTriPtrUB      $76A1   ;Base address, upper byte of SFX Triangle data being read.
.alias SFXTriIndex      $76A2   ;Index of SFX Triangle data currently being read.
.alias SFXTriLeft       $76A3   ;Number of frames left to play in Triangle SFX.
.alias SFXNsePtrLB      $76A4   ;Base address, lower byte of SFX Noise data being read.
.alias SFXNsePtrUB      $76A5   ;Base address, upper byte of SFX Noise data being read.
.alias SFXNseIndex      $76A6   ;Index of SFX Noise data currently being read.
.alias SFXNseLeft       $76A7   ;Number of frames left to play in Noise SFX.
.alias SFXSQ1Channel    $76A8   ;If bit 4 set, only update control register 0 for SFX.
.alias SFXSQ1Unused1    $76A9   ;Not used.
.alias SFXSQ1Unused2    $76AA   ;Not used.
.alias SFXSQ1Unused3    $76AB   ;Not used.
.alias SFXSQ2Channel    $76AC   ;If bit 4 set, only update control register 0 for SFX.
.alias SFXSQ2Unused1    $76AD   ;Not used.
.alias SFXSQ2Unused2    $76AE   ;Not used.
.alias SFXSQ2Unused3    $76AF   ;Not used.
.alias SFXTriChannel    $76B0   ;If bit 4 set, only update control register 0 for SFX.
.alias SFXTriUnused1    $76B1   ;Not used.
.alias SFXTriUnused2    $76B2   ;Not used.
.alias SFXTriUnused3    $76B3   ;Not used.
.alias SFXNseChannel    $76B4   ;If bit 4 set, only update control register 0 for SFX.
.alias SFXNseUnused1    $76B5   ;Not used.
.alias SFXNseUnused2    $76B6   ;Not used.
.alias SFXNseUnused3    $76B7   ;Not used.

;--------------------------------------[Hardware Defines]--------------------------------------------

.alias PPUControl0      $2000   ;
.alias PPUControl1      $2001   ;
.alias PPUStatus        $2002   ;
.alias SPRAddress       $2003   ;PPU hardware control registers.
.alias SPRIOReg         $2004   ;
.alias PPUScroll        $2005   ;
.alias PPUAddress       $2006   ;
.alias PPUIOReg         $2007   ;

.alias ChnCntrl0        $4000   ;
.alias ChnCntrl1        $4001   ;Base addresses for channel control registers.
.alias ChnCntrl2        $4002   ;
.alias ChnCntrl3        $4003   ;

.alias SQ1Cntrl0        $4000   ;
.alias SQ1Cntrl1        $4001   ;SQ1 hardware control registers.
.alias SQ1Cntrl2        $4002   ;
.alias SQ1Cntrl3        $4003   ;

.alias SQ2Cntrl0        $4004   ;
.alias SQ2Cntrl1        $4005   ;SQ2 hardware control registers.
.alias SQ2Cntrl2        $4006   ;
.alias SQ2Cntrl3        $4007   ;

.alias TriangleCntrl0   $4008   ;
.alias TriangleCntrl1   $4009   ;Triangle hardware control registers.
.alias TriangleCntrl2   $400A   ;
.alias TriangleCntrl3   $400B   ;

.alias NoiseCntrl0      $400C   ;
.alias NoiseCntrl1      $400D   ;Noise hardware control registers.
.alias NoiseCntrl2      $400E   ;
.alias NoiseCntrl3      $400F   ;

.alias DMCCntrl0        $4010   ;
.alias DMCCntrl1        $4011   ;DMC hardware control registers.
.alias DMCCntrl2        $4012   ;
.alias DMCCntrl3        $4013   ;

.alias SPRDMAReg        $4014   ;Sprite RAM DMA register.
.alias APUCommonCntrl0  $4015   ;APU common control 1 register.
.alias CPUJoyPad1       $4016   ;Joypad1 register.
.alias APUCommonCntrl1  $4017   ;Joypad2/APU common control 2 register.

;------------------------------------------[MMC Registers]-------------------------------------------

.alias MMCCfg           $9FFF   ;MMC1 configuration.
.alias MMCPRG           $FFFF   ;MMC1 PRG ROM, lower bank.
.alias MMCCHR           $BFFF   ;MMC1 CHR ROM.

;--------------------------------------------[Constants]---------------------------------------------

;Dungeon map constants. Designed to make the dungeon data more readable.
.alias  XXX             $00     ;Wall.
.alias  _I_             $01     ;Door.
.alias  _H_             $02     ;Fake wall.
.alias  _U_             $03     ;Stairs up.
.alias  _D_             $04     ;Stairs down.
.alias  _B_             $05     ;Stairs up and down.
.alias  _M_             $06     ;Mark.
.alias  _F_             $07     ;Fountain.
.alias  _S_             $08     ;Sign.
.alias  _K_             $09     ;Darkness.
.alias  _G_             $0A     ;Gremlins.
.alias  _C_             $0B     ;Chest.
.alias  _T_             $0C     ;Trap.
.alias  ___             $0D     ;Floor.
.alias  _L_             $0E     ;Time lord.

.alias D_PAD            $0F     ;All bits for D-pad input.
.alias BTN_RIGHT        $01     ;Controller D-pad right.
.alias BTN_LEFT         $02     ;Controller D-pad left.
.alias BTN_DOWN         $04     ;Controller D-pad down.
.alias BTN_UP           $08     ;Controller D-pad up.
.alias BTN_START        $10     ;Controller button start.
.alias BTN_SELECT       $20     ;Controller button select.
.alias BTN_B            $40     ;Controller button B.
.alias BTN_A            $80     ;Controller button A.

.alias PPU_PT0_UB       $00     ;Base address of pattern table 0, upper byte.
.alias PPU_PT0_LB       $00     ;Base address of pattern table 0, lower byte.
.alias PPU_PT1_UB       $10     ;Base address of pattern table 1, upper byte.
.alias PPU_PT1_LB       $00     ;Base address of pattern table 1, lower byte.
.alias PPU_NT0_UB       $20     ;Base address of name table 0, upper byte.
.alias PPU_NT0_LB       $00     ;Base address of name table 0, lower byte.
.alias PPU_AT0_UB       $23     ;Base address of attribute table 0, upper byte.
.alias PPU_AT0_LB       $C0     ;Base address of attribute table 0, lower byte.
.alias PPU_NT1_UB       $24     ;Base address of name table 1, upper byte.
.alias PPU_NT1_LB       $00     ;Base address of name table 1, lower byte.
.alias PPU_PAL_UB       $3F     ;Base address of palettes, upper byte.
.alias PPU_PAL_LB       $00     ;Base address of palettes, lower byte.

.alias NPC_LB           $00     ;Lord British.
.alias NPC_WIZARD       $01     ;Wizard.
.alias NPC_BLU_GRD      $02     ;Blue guard.
.alias NPC_SHKPR_1      $03     ;White shirt, blue pants shopkeeper.
.alias NPC_SHKPR_2      $04     ;Red overalls shopkeeper.
.alias NPC_PLR_BOAT     $05     ;Player's boat.
.alias NPC_SHKPR_3      $06     ;Blue shirt, white pants shopkeeper.
.alias NPC_SHKPR_4      $07     ;Red shirt, white pants shopkeeper.
.alias NPC_WZD_AP       $08     ;Wizard apprentice.
.alias NPC_M_VILLAGER   $09     ;Male villager.
.alias NPC_BOY          $0A     ;Little boy.
.alias NPC_JESTER       $0B     ;Jester.
.alias NPC_F_VILLAGER   $0C     ;Female villager.
.alias NPC_GIRL         $0D     ;Little girl.
.alias NPC_RED_GRD      $0E     ;Red guard.
.alias NPC_OLD_WOMAN    $0F     ;Old woman.
.alias NPC_OLD_MAN      $10     ;Old man.
.alias NPC_M_BRTNDR     $11     ;Male bartender.
.alias NPC_F_BRTNDR     $12     ;Female bartender.
.alias NPC_HORSE        $13     ;Unmounted horse.
.alias NPC_DOCTOR       $14     ;Doctor.
.alias NPC_LND_EN_1     $15     ;Level 1 land monster.
.alias NPC_LND_EN_3     $16     ;Level 3 land monster.
.alias NPC_LND_EN_5     $17     ;Level 5 land monster.
.alias NPC_WTR_EN_5     $18     ;Level 5 water monster.
.alias NPC_LND_EN_7     $19     ;Level 7 land monster.
.alias NPC_LND_EN_9     $1A     ;Level 9 land monster.
.alias NPC_WTR_EN_7     $1B     ;Level 7 water monster.
.alias NPC_EN_SHIP      $1C     ;Enemy pirate ship.
.alias NPC_SHERRY       $1D     ;Sherry.
.alias NPC_WHIRLPOOL    $1E     ;Whirlpool.

.alias BANK_MAPS0       $00     ;MMC1 bank $00. Overhead maps.
.alias BANK_MAPS1       $01     ;MMC1 bank $01. Overhead maps.
.alias BANK_DUNGEONS    $02     ;MMC1 bank $02. Dungeon maps.
.alias BANK_NPCS        $03     ;MMC1 bank $03. NPC tile patterns.
.alias BANK_ENEMIES     $04     ;MMC1 bank $04. Enemy tile patterns.
.alias BANK_TEXT        $05     ;MMC1 bank $05. Game text.
.alias BANK_GEM         $06     ;MMC1 bank $06. Overwolrg gem maps/Shrines map.
.alias BANK07           $07     ;MMC1 bank $07.
.alias BANK_MUSIC       $08     ;MMC1 bank $08. Music routines
.alias BANK_SFX         $09     ;MMC1 bank $09. Music/SFX routines.
.alias BANK0A           $0A     ;MMC1 bank $0A.
.alias BANK_HELPERS1    $0B     ;MMC1 bank $0B.
.alias BANK_CREATE      $0C     ;MMC1 bank $0C. Load save game/character creation.
.alias BANK_HELPERS2    $0D     ;MMC1 bank $0D.
.alias BANK_INTRO       $0E     ;MMC1 bank $0E. Intro and end game routines.
.alias BANK_GAME_ENG    $0F     ;MMC1 bank $0F. Main game engine.

.alias MUS_CHANS_EN     $0F     ;Enable counters for SQ1, SQ2, Tri and noise, disable DMC.
.alias SFX_RESET        $00     ;SFX is done and reset.
.alias SFX_FINISHED     $01     ;Indicates an SFX just finished.
.alias SFX_UNUSED       $02     ;Not used.

;$00
;$01
;$02
.alias SFX_OPEN_DOOR    $03     ;Open door.
;$04
;$05
;$06
.alias SFX_MN_GATE_B    $07     ;Player travels through moon gate.
;$08
;$09
;$0A
.alias SFX_SPELL_B      $0B     ;Spell SFX variant B.
;$0C
;$0D
.alias SFX_CHST_OPEN    $0E     ;Chest opened/card placed.
;$0F
;$10
.alias SFX_TIME_STOP    $11     ;Time stopped.
.alias SFX_EN_MISS      $12     ;Enemy miss physical attack.
;$13
.alias SFX_MARK_DMG     $14     ;Player suffers fire/force damage.
;$15
.alias SFX_EN_HIT       $16     ;Player hit enemy.
.alias SFX_PLYR_HIT     $17     ;Enemy hit player.
.alias SFX_PLYR_ILL     $18     ;Player is poisoned/has cold.
.alias SFX_FOREST       $19     ;Walking through forest/shrubs.
;$1A
.alias SFX_BLOCKED      $1B     ;Player bumping into object.
;$1C
.alias SFX_SWING        $1D     ;Player physical attack.
;$1E
.alias SFX_PLYR_MISS    $1F     ;Player miss physical attack/Light torch.
;$20
;$21
;$22
.alias SFX_GEM          $23     ;Use gem SFX.
.alias SFX_SPELL_A      $24     ;Spell SFX variant A.
.alias SFX_EN_MJ_SPL    $25     ;Enemy casts major spell.
.alias SFX_EX_FALL      $26     ;Castle Exodus falling apart.
;$27
;$28
;$29
;$2A
;$2B
.alias SFX_MN_GATE_A    $2C     ;Player enters/exits moongate.
.alias SFX_DNGN_MOVE    $2D     ;Player move in dungeon.
;$2E
;$2F
;$30
;$31
;$32
;$33

.alias MUS_DUNGEON      $00     ;Starts dungeon music.
.alias MUS_TOWN         $01     ;Starts town music.
.alias MUS_BOAT         $02     ;Starts boat music.
.alias MUS_END          $03     ;Starts end music.
.alias MUS_AMBROSIA     $04     ;Starts Ambrosia music.
.alias MUS_FIGHT        $05     ;Starts fight music.
.alias MUS_EXODUS       $06     ;Starts Exodus castle music.
.alias MUS_UNUSED       $07     ;Starts unused theme music.
.alias MUS_WORLD        $08     ;Starts overworld music.
.alias MUS_CASTLE       $09     ;Starts Lord British castle music.
.alias MUS_INTRO        $0A     ;Intro music.
.alias MUS_NONE         $0B     ;Silences music.
.alias MUS_EXODUS_HB    $0C     ;Exodus heartbeat.
.alias MUS_HORN         $0D     ;Silver horn music.
.alias INIT             $80     ;Initilize new music/SFX.

.alias MAP_OVERWORLD    $00     ;Overworld.
.alias MAP_FAWN         $01     ;Town of Fawn.
.alias MAP_CV_GOLD      $02     ;Cave of Gold.
.alias MAP_CV_DEATH     $03     ;Cave of Death.
.alias MAP_MOON         $04     ;Town of Moon.
.alias MAP_YEW          $05     ;Town of Yew.
.alias MAP_LB_CSTL      $06     ;Lord British castle.
.alias MAP_RYL_CTY      $07     ;Royal city.
.alias MAP_CV_MADNESS   $08     ;Cave of Madness.
.alias MAP_CV_MOON      $09     ;Cave of Moon.
.alias MAP_DVL_GRD      $0A     ;Town of Devil Guard.
.alias MAP_DTH_GLCH     $0B     ;Town of Death Gulch.
.alias MAP_CV_FIRE      $0C     ;Cave of Fire.
.alias MAP_GRAY         $0D     ;Town of Gray
.alias MAP_CV_SOL       $0E     ;Cave of Sol.
.alias MAP_AMBROSIA     $0F     ;Ambrosia.
.alias MAP_CV_FOOL      $10     ;Cave of Fool.
.alias MAP_MONTOR_W     $11     ;Town of Montor West.
.alias MAP_MONTOR_E     $12     ;Town of Montor East.
.alias MAP_DAWN         $13     ;Town of Dawn.
.alias MAP_EXODUS       $14     ;Castle of Exodus.
.alias MAP_SH_INT       $15     ;Shrine of intelligence.
.alias MAP_SH_WIS       $16     ;Shrine of Wisdom.
.alias MAP_SH_STR       $17     ;Shrine of Strength.
.alias MAP_SH_DEX       $18     ;Shrine of Dexterity.

.alias CHN_CONTROL      $F0     ;Any value >= than this is a music control byte.
.alias CHN_VOLUME       $FB     ;Control byte to set channel base volume.
.alias CHN_ASR          $FC     ;Control byte to set ASR (attack, sustain, release) profile.
.alias CHN_VIBRATO      $FD     ;Control byte to set channel vibrato data.
.alias CHN_SILENCE      $FE     ;Control byte to silence a channel temporarily.
.alias CHN_JUMP         $FF     ;Control byte to jump to another point in the music data.
.alias TRI_CHN_COMP     $FF     ;Set triangle notes to same frequency as SQ channels.

.alias SQ1_DAT_OFFSET   $00     ;Offset for SQ1 data pointer registers. Base is ChnDatPtr.
.alias SQ2_DAT_OFFSET   $04     ;Offset for SQ2 data pointer registers. Base is ChnDatPtr.
.alias TRI_DAT_OFFSET   $08     ;Offset for Triangle data pointer registers. Base is ChnDatPtr.
.alias NSE_DAT_OFFSET   $0C     ;Offset for Noise data pointer registers. Base is ChnDatPtr.

.alias ENABLE           $00     ;Enable for various registers.
.alias DISABLE          $01     ;Disable for various registers.

.alias INP_NO_IGNORE    $00     ;Respond to player's input on the controller.
.alias INP_IGNORE       $01     ;Ignore player's input on the controller.

.alias SCREEN_OFF       $00     ;Turn the screen off.
.alias SCREEN_ON        $1E     ;Turn the screen on.

.alias ANIM_ENABLE      $01     ;Enable animations.
.alias ANIM_DISABLE     $00     ;Disable animations.

.alias TXT_NAME         $F3     ;Display a character's name.
.alias TXT_ENMY         $F4     ;Display an enemy's name.
.alias TXT_AMNT         $F5     ;Display a numerical amount.
.alias TXT_ONE          $F6     ;Display text message once.
.alias TXT_YN           $F7     ;Display Yes/No text box.
.alias TXT_NONE_F8      $F8     ;Function not used.
.alias TXT_NONE_F9      $F9     ;Function not used.
.alias TXT_PRAY         $F0     ;Gives player Pray command.
.alias TXT_BRIB         $F1     ;Gives player Bribe command.
.alias TXT_NEWLINE      $FD     ;New line of text.
.alias TXT_END          $FF     ;Marks the end of a text string.
.alias TXT_SNGL_SPACE   $FE     ;Indicates text buffer already filles and should be single spaced.
.alias TXT_DBL_SPACE    $FF     ;Indicates text buffer already filles and should be double spaced.

.alias CMD_PRAY         $01     ;LSB set allowas party to pray.
.alias CMD_BRIBE        $02     ;Second bit set allows party to bribe.
.alias CMD_BOTH         $03     ;Both bits for bribe and pray.

.alias GME_NORMAL       $00     ;Game in normal mode.
.alias GME_EX_DEAD      $01     ;Exodus killed. Shake screen and drop debris.
.alias GME_WON          $02     ;Player made it out of Exodus castle alive.
.alias GME_LOST         $FF     ;Player did not make it out of the castle in time.

.alias SG_VALID1        $41     ;First byte indicating a save game is valid.
.alias SG_VALID2        $42     ;Second byte indicating a save game is valid.

.alias CLS_FIGHTER      $00     ;Fighter class.
.alias CLS_CLERIC       $01     ;Cleric
.alias CLS_WIZARD       $02     ;Wizard class.
.alias CLS_THIEF        $03     ;Thief class.
.alias CLS_PALADIN      $04     ;Paladin class.
.alias CLS_BARBARIAN    $05     ;Barbarian class.
.alias CLS_LARK         $06     ;Lark class.
.alias CLS_ILLUSIONIST  $07     ;Illusionist class.
.alias CLS_DRUID        $08     ;Druid class.
.alias CLS_ALCHEMIST    $09     ;Alchemist class.
.alias CLS_RANGER       $0A     ;Ranger class.
.alias CLS_UNCHOSEN     $FF     ;Unchosen class.