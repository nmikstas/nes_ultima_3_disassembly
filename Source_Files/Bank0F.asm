.org $C000

.include "Ultima_3_Defines.asm"

;----------------------------------------------------------------------------------------------------

;Forward declarations.

.alias  DialogPtrTbl1           $8000
.alias  GFXCharacterSet         $8000
.alias  InitMusic               $8000
.alias  DoCreateMenus           $8000
.alias  _DrawWindow             $8000
.alias  UpdateMusic             $8100
.alias  DoBinToBCD              $8400
.alias  SherryTalk              $8900
.alias  FortuneTalk             $8A00
.alias  HealerTalk              $8B00
.alias  WeaponTalk              $8D00
.alias  ArmoryTalk              $8F00
.alias  GFXForceField           $8F00
.alias  GroceryTalk             $9000
.alias  PubTalk                 $9100
.alias  GuildTalk               $9200
.alias  StableTalk              $9300
.alias  InnTalk                 $9400
.alias  TempleTalk              $9500
.alias  CasinoTalk              $9600
.alias  LgCharBase              $9600
.alias  ShrineTalk              $9700
.alias  LBTalk                  $9800
.alias  UpdateSpriteRAM         $9900
.alias  DialogPtrTbl2           $9D80
.alias  InitSFX                 $A000
.alias  DoStatusScreen          $A000
.alias  UpdateSFX               $A100
.alias  GetInput                $A500
.alias  TextConvert             $B000
.alias  GFXSnakeBack            $B100
.alias  GFXSnakeFront           $B140
.alias  GFXFlower1              $B180
.alias  GFXFlower2              $B1C0
.alias  ShowWhoWnd              $B700
.alias  ShowIntroText           $B800
.alias  CalcEnDmg               $B900

;----------------------------------------------------------------------------------------------------

Reset1:
LC000:  JMP ResetGame           ;($C06C)Reset game.

DisplayText1:
LC003:  JMP DisplayText         ;($F0BE)Display text on the screen.

LoadPPU1:
LC006:  JMP LoadPPU             ;($EFE3)Load values into PPU.

LdLgCharTiles1:
LC009:  JMP LdLgCharTiles       ;($FB16)Load large character tiles.

ChooseChar1:
LC00C:  JMP ChooseChar          ;($E42F)Select a character from a list.

ShowDialog1:
LC00F:  JMP ShowDialog          ;($E675)Show dialog in lower screen window.

ShowSelectWnd1:
LC012:  JMP ShowSelectWnd       ;($E4FF)Show a window where player makes a selection.

ShowWindow1:
LC015:  JMP ShowWindow          ;($F42A)Show a window on the display.

_ShowSelectWnd1:
LC018:  JMP _ShowSelectWnd      ;($E50B)Show a window where player makes a selection, variant.

LC01B:  JMP LE4A5

LoadnAlphaNumMaps1:
LC01E:  JMP LoadAlphaNumMaps    ;($ED76)Load character set and map tiles.

BinToBCD1:
LC021:  JMP BinToBCD            ;($F4D1)Convert binary number to BCD.

LC024:  JMP LF90B
LC027:  JMP LF981
LC02A:  JMP LE780
LC02D:  JMP LFC35
LC030:  JMP LFC45
LC033:  JMP LC55F
LC036:  JMP LC512
LC039:  JMP LED0D
LC03C:  JMP LC56F
LC03F:  JMP LEF13
LC042:  JMP LE49E

SetMapDatNPtrs1:
LC045:  JMP SetMapDatNPtrs      ;($C4EA)Load map data and pointers.

SwapBnkLdGFX1:
LC048:  JMP SwapBnkLdGFX        ;($EE23)Save lower bank then load character sprites GFX.

LC04B:  JMP LFAF6

FlashAndSound1:
LC04E:  JMP FlashAndSound       ;($DB2D)Flash screen with SFX.

ChkValidNPC1:
LC051:  JMP ChkValidNPC         ;($C6EC)Check if valid NPC in front of player.

LC054:  JMP LE602
LC057:  JMP LE62A
LC05A:  JMP LE616
LC05D:  JMP LC62D
LC060:  JMP LF570
LC063:  JMP LF590
LC066:  JMP LF580
LC069:  JMP LF5A0

;----------------------------------------------------------------------------------------------------

ResetGame:
LC06C:  SEI                     ;Disable maskable interrupts
LC06D:  CLD                     ;Set processor to binary mode.
LC06E:  LDX #$FF                ;
LC070:  TXS                     ;Reset the stack pointer.

LC071:  LDA #$00                ;Disable NMI.
LC073:  STA PPUControl1         ;

LC076:  LDA #BANK_HELPERS1      ;Switch lower bank to Bank0B. Helper functions.
LC078:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.

LC07B:  LDY #$00                ;
LC07D:  LDA #$00                ;
LC07F:* STA $0000,Y             ;Zero out the zero page RAM.
LC082:  INY                     ;
LC083:  BNE -                   ;

LC085:  LDY #$05                ;
LC087:* STA MMCCHR              ;Set MMC1 to CHR bank 0. CHR ROM is not used in this game.
LC08A:  DEY                     ;
LC08B:  BNE -                   ;

LC08D:  LDA #$02                ;
LC08F:  STA GenPtr29UB          ;
LC091:  LDA #$00                ;Prepare to clear RAM $0200 through $07FF.
LC093:  STA GenPtr29LB          ;
LC095:  LDX #$06                ;

RAMClearLoop:
LC097:  LDY #$00                ;
LC099:* STA (GenPtr29),Y        ;Has 256 bytes of RAM been zeroed out?
LC09B:  INY                     ;If not, branch to clear the next byte.
LC09C:  BNE -                   ;

LC09E:  INC GenPtr29UB          ;Has the RAM up to $07FF been cleared out?
LC0A0:  DEX                     ;If not, branch to clear another 256 bytes.
LC0A1:  BNE RAMClearLoop        ;

LC0A3:  LDA #SPRT_HIDE          ;
LC0A5:* STA SpriteBuffer,X      ;Set RAM $7300 through $73FF to #$F0. Hides sprites.
LC0A8:  INX                     ;
LC0A9:  BNE -                   ;

LC0AB:  LDA #$81
LC0AD:  STA RngSeed
LC0AF:  STA $D8

LC0B1:  LDA #BANK_MUSIC         ;Swap to the music player bank.
LC0B3:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.

LC0B6:  LDA #MUS_NONE           ;Silence music player.
LC0B8:  JSR InitMusic           ;($8000)Initialize music.

LC0BB:  LDA #MUS_DUNGEON        ;Prepare to start the intro music.
LC0BD:  JSR InitMusic           ;($8000)Initialize music.

LC0C0:  LDA #$90
LC0C2:  STA CurPPUConfig0
LC0C4:  STA PPUControl0

LC0C7:  LDA #>DialogPtrTbl1
LC0C9:  STA TextBasePtrUB
LC0CB:  LDA #<DialogPtrTbl1
LC0CD:  STA TextBasePtrLB

LC0CF:  LDA #$01
LC0D1:  STA TimeStopTimer

LC0D3:  JSR LoadAlphaNumMaps    ;($ED76)Load character set and map tiles.

LC0D6:  LDA Pad1Input           ;Is the B button being held down during startup?
LC0D8:  AND #BTN_B              ;
LC0DA:  BNE +                   ;If so, branch to skip intro sequence.

LC0DC:  LDA #BANK_INTRO         ;Prepare to show the intro.
LC0DE:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LC0E1:  JSR ShowIntroText       ;($B800)Display the intro text on the screen.

LC0E4:  LDA #$10
LC0E6:  STA $9B
LC0E8:  JSR LE6D8

LC0EB:* LDA #$01
LC0ED:  STA $B0
LC0EF:  LDA #$00
LC0F1:  STA CurPPUConfig1
LC0F3:  JSR LoadAlphaNumMaps    ;($ED76)Load character set and map tiles.
LC0F6:  JSR LEE2E
LC0F9:  JSR LEF65

LC0FC:  LDA #BANK_CREATE        ;Prepare to show save game selection screen.
LC0FE:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.

LC101:  LDA #ANIM_ENABLE        ;Enable sprite animations.
LC103:  STA DoAnimations        ;

LC105:  JSR DoCreateMenus       ;($8000)Run the load saveed game and other pre-game menus.

LC108:  LDA #ANIM_DISABLE       ;Disable sprite animations.
LC10A:  STA DoAnimations        ;

LC10C:  LDA MapBank
LC10E:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LC111:  JSR LEE2E
LC114:  JSR LoadAlphaNumMaps    ;($ED76)Load character set and map tiles.
LC117:  LDA #$18
LC119:  STA CurPPUConfig1
LC11B:  LDA #$01
LC11D:  STA $B0
LC11F:  LDX #$00

LC121:* LDA $C132,X
LC124:  STA $77E0,X
LC127:  INX
LC128:  CPX #$10
LC12A:  BNE -

LC12C:  JSR LFD93
LC12F:  JMP LoadNewMap          ;($C175)Load a new map.

LC132:  .word $A100, $A300, $A500, $A700, $A100, $A300, $A500, $A700

;----------------------------------------------------------------------------------------------------

PrepLoadOvrwld:
LC142:  LDA #MAP_PROP_OV
LC144:  STA MapProperties

PrepLoadMap:
LC146:  LDA #$00
LC148:  STA GenByte30
LC14A:  LDA MapProperties
LC14C:  AND #MAP_DUNGEON
LC14E:  BEQ SetRtnAndMapDat

LC150:  JMP PrepLoadDungeon     ;($F6CC)Prepare to load dungeon map.

SetRtnAndMapDat:
LC153:  JSR SetMapDatNPtrs      ;($C4EA)Load map data and pointers.
LC156:  LDA GenByte30
LC158:  BNE LC15E
LC15A:  LDA ThisMap
LC15C:  BNE LC169

LC15E:  LDA ReturnXPos
LC160:  STA MapXPos
LC162:  LDA ReturnYPos
LC164:  STA MapYPos
LC166:  JMP LoadNewMap          ;($C175)Load a new map.

LC169:  INX
LC16A:  LDA MapDatTbl,X
LC16D:  STA MapYPos
LC16F:  INX
LC170:  LDA MapDatTbl,X
LC173:  STA MapXPos

;----------------------------------------------------------------------------------------------------

LoadNewMap:
LC175:  LDA MapBank             ;Load the bank containing the current map data.
LC177:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.

LC17A:  JSR StartMusic          ;($FD6C)Determine which music to start playing.
LC17D:  JSR ZeroPartyTrail      ;($EFD6)Pile all characters on top of each other.
LC180:  JSR ResetNameTableF1    ;($FBDC)Reset nametable offsets and select nametable 0.

LC183:  LDA MapProperties       ;Is the map that needs to be loaded a dungeon level?
LC185:  AND #MAP_DUNGEON        ;
LC187:  BEQ +                   ;If not, branch.

LC189:  JMP LoadDungeon         ;($F71F)Load dungeon level.

LC18C:* LDA #SPRT_HIDE          ;Prepare to hide all sprites off screen.
LC18E:  LDY #$00                ;

LC190:* STA SpriteBuffer,Y      ;
LC193:  INY                     ;
LC194:  INY                     ;Hide all 64 sprites.
LC195:  INY                     ;
LC196:  INY                     ;
LC197:  BNE -                   ;

LC199:  JSR LoadMapData         ;($F4EB)Load map data into RAM.
LC19C:  JSR _SetCharSprites     ;($FCD0)Set character sprites initial properties.

LC19F:  LDA #ANIM_ENABLE        ;Enable sprite animations.
LC1A1:  STA DoAnimations        ;

LC1A3:  LDA #$10
LC1A5:  JSR WaitSomeFrames      ;($E6D0)Wait some frames before continuing.

LC1A8:  LDA #$00
LC1AA:  STA $C9
LC1AC:  LDA #SPRT_HIDE
LC1AE:  STA $7300

;----------------------------------------------------------------------------------------------------

MainGameLoop:
LC1B1:  LDA #INP_NO_IGNORE      ;React to player's input on the controller.
LC1B3:  STA IgnoreInput         ;

LC1B5:  STA $B0

LC1B7:  LDA MapProperties
LC1B9:  AND #MAP_DUNGEON
LC1BB:  BEQ +

LC1BD:  JMP LF86C

LC1C0:* LDA Increment0          ;
LC1C2:* CMP Increment0          ;Wait until next frame to continue.
LC1C4:  BEQ -                   ;

LC1C6:  JSR LC524

LC1C9:  LDA #INP_IGNORE         ;Ignore player's input on the controller.
LC1CB:  STA IgnoreInput         ;

LC1CD:  JSR BlockAlign          ;($FD1C)Update block aligned position of character 1.

LC1D0:  LDA Pad1Input
LC1D2:  AND #D_PAD
LC1D4:  BEQ +
LC1D6:  JMP LC2AB

LC1D9:* LDA ExodusDead
LC1DB:  BNE LC227

LC1DD:  LDA Pad1Input
LC1DF:  AND #BTN_A
LC1E1:  BNE LC23A
LC1E3:  JSR LFB06

LC1E6:  LDA #INP_NO_IGNORE      ;React to player's input on the controller.
LC1E8:  STA IgnoreInput         ;

LC1EA:  LDA $00
LC1EC:  CMP $00
LC1EE:  BEQ LC1EC
LC1F0:  JSR LC524

LC1F3:  LDA Pad1Input           ;Get button presses minus the select and start buttons.
LC1F5:  AND #$CF                ;

LC1F7:  BEQ LC211
LC1F9:  CMP #$40
LC1FB:  BNE LC207
LC1FD:  LDX InputChange
LC1FF:  BEQ LC211
LC201:  JSR LFC55
LC204:  JMP LC1E3
LC207:  PHA
LC208:  JSR BinToBCD            ;($F4D1)Convert binary number to BCD.
LC20B:  PLA
LC20C:  STA Pad1Input
LC20E:  JMP LC1C9
LC211:  LDA $01
LC213:  CMP #$3C
LC215:  BNE LC1E6
LC217:  JSR LFAE3
LC21A:  LDA #$FF
LC21C:  STA $9B
LC21E:  JSR LE6D8
LC221:  JSR BinToBCD            ;($F4D1)Convert binary number to BCD.
LC224:  JMP MainGameLoop        ;($C1B1)Main game engine loop.
LC227:  LDA $01
LC229:  CMP #$10
LC22B:  BNE LC237
LC22D:  LDA #$00
LC22F:  STA $01
LC231:  JSR LFDA3
LC234:  JSR BinToBCD            ;($F4D1)Convert binary number to BCD.
LC237:  JMP MainGameLoop        ;($C1B1)Main game engine loop.

LC23A:  LDA #$01
LC23C:  STA $B0
LC23E:  JSR LF447
LC241:  LDA MapProperties
LC243:  AND #$03
LC245:  BNE LC24D
LC247:  JSR LFC55
LC24A:  JSR LFB06
LC24D:  LDA #$D4
LC24F:  STA HideUprSprites
LC251:  LDA #$16
LC253:  STA Wnd2XPos
LC256:  LDA #$04
LC258:  STA Wnd2YPos
LC25B:  LDA #$0A
LC25D:  STA Wnd2Width
LC260:  LDA #$12
LC262:  STA Wnd2Height
LC265:  LDA BribePray
LC267:  AND #CMD_BOTH
LC269:  ASL
LC26A:  TAX
LC26B:  LDA $C4E2,X
LC26E:  STA TextIndex2
LC271:  LDA $C4E3,X
LC274:  STA $9D
LC276:  LDA #$08
LC278:  STA NumMenuItems
LC27A:  JSR ShowSelectWnd       ;($E4FF)Show a window where player makes a selection.
LC27D:  BCS FinishCommand       ;($C293)Post-command cleanup and run the game engine loop.
LC27F:  ASL
LC280:  TAX
LC281:  LDA CmdPtrTbl,X
LC284:  STA $8F
LC286:  INX
LC287:  LDA CmdPtrTbl,X
LC28A:  STA $90
LC28C:  LDA #$00
LC28E:  STA $9D
LC290:  JMP ($008F)

FinishCommand:
LC293:  LDA #CHR_CHK_DEAD
LC295:  STA ChkCharDead

LC297:  LDA #SPRT_HIDE
LC299:  STA SpriteBuffer
LC29C:  STA SpriteBuffer+$C4
LC29F:  STA SpriteBuffer+$C8
LC2A2:  STA SpriteBuffer+$CC
LC2A5:  JSR BinToBCD            ;($F4D1)Convert binary number to BCD.
LC2A8:  JMP MainGameLoop        ;($C1B1)Main game engine loop.

;----------------------------------------------------------------------------------------------------

LC2AB:  LDA #$01
LC2AD:  STA $B0
LC2AF:  LDA MapXPos
LC2B1:  STA $48
LC2B3:  LDA MapYPos
LC2B5:  STA $47
LC2B7:  LDA Pad1Input
LC2B9:  AND #BTN_RIGHT
LC2BB:  BEQ LC2C0
LC2BD:  JMP LC2DE
LC2C0:  LDA Pad1Input
LC2C2:  AND #BTN_LEFT
LC2C4:  BEQ LC2C9
LC2C6:  JMP LC2FE
LC2C9:  LDA Pad1Input
LC2CB:  AND #BTN_DOWN
LC2CD:  BEQ LC2D2
LC2CF:  JMP LC33E

LC2D2:  LDA Pad1Input
LC2D4:  AND #BTN_UP
LC2D6:  BEQ LC2DB
LC2D8:  JMP LC31E
LC2DB:  JMP MainGameLoop        ;($C1B1)Main game engine loop.
LC2DE:  STA Pad1Input
LC2E0:  INC $48
LC2E2:  LDX #$78
LC2E4:  JSR LE790
LC2E7:  BCC LC2EC
LC2E9:  JMP MainGameLoop        ;($C1B1)Main game engine loop.
LC2EC:  LDA CurPRGBank
LC2EE:  PHA
LC2EF:  LDA #BANK_HELPERS1
LC2F1:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LC2F4:  JSR $AB00
LC2F7:  PLA
LC2F8:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LC2FB:  JMP LC35E
LC2FE:  STA Pad1Input
LC300:  DEC $48
LC302:  LDX #$76
LC304:  JSR LE790
LC307:  BCC LC30C
LC309:  JMP MainGameLoop        ;($C1B1)Main game engine loop.
LC30C:  LDA CurPRGBank
LC30E:  PHA
LC30F:  LDA #BANK_HELPERS1
LC311:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LC314:  JSR $AB80
LC317:  PLA
LC318:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LC31B:  JMP LC35E
LC31E:  STA Pad1Input
LC320:  DEC $47
LC322:  LDX #$67
LC324:  JSR LE790
LC327:  BCC LC32C
LC329:  JMP MainGameLoop        ;($C1B1)Main game engine loop.
LC32C:  LDA CurPRGBank
LC32E:  PHA
LC32F:  LDA #BANK_HELPERS1
LC331:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LC334:  JSR $AC00
LC337:  PLA
LC338:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LC33B:  JMP LC35E

LC33E:  STA Pad1Input
LC340:  INC $47
LC342:  LDX #$87
LC344:  JSR LE790
LC347:  BCC LC34C
LC349:  JMP MainGameLoop        ;($C1B1)Main game engine loop.
LC34C:  LDA CurPRGBank
LC34E:  PHA
LC34F:  LDA #BANK_HELPERS1
LC351:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LC354:  JSR $AC80
LC357:  PLA
LC358:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LC35B:  JMP LC35E
LC35E:  LDA OnBoat
LC360:  AND #$02
LC362:  BEQ LC3AE
LC364:  LDA #MUS_BOAT+INIT
LC366:  STA InitNewMusic
LC368:  LDA #$01
LC36A:  STA OnBoat
LC36C:  JSR LoadChrGFX          ;($EE4E)Load the sprite tiles for current party members.
LC36F:  JSR _SetCharSprites     ;($FCD0)Set character sprites initial properties.
LC372:  LDY #$00
LC374:  LDA NPCSprIndex,Y
LC377:  CMP #$85
LC379:  BEQ LC381
LC37B:  INY
LC37C:  INY
LC37D:  INY
LC37E:  INY
LC37F:  BNE LC374
LC381:  LDA #$FF
LC383:  STA NPCSprIndex,Y
LC386:  LDA NPCOnscreen,Y
LC389:  TAX
LC38A:  LDA #$00
LC38C:  STA NPCOnscreen,Y
LC38F:  LDA #SPRT_HIDE
LC391:  STA $7300,X
LC394:  STA $7304,X
LC397:  STA $7308,X
LC39A:  STA $730C,X
LC39D:  LDA #$00
LC39F:  STA $7301,X
LC3A2:  STA $7305,X
LC3A5:  STA $7309,X
LC3A8:  STA $730D,X
LC3AB:  JMP LC3B4
LC3AE:  LDA OnBoat
LC3B0:  AND #$04
LC3B2:  BEQ LC3B4
LC3B4:  JSR LC55F
LC3B7:  LDA #$00
LC3B9:  STA $B0
LC3BB:  LDA ScrollDirAmt
LC3BD:  BNE LC3BB
LC3BF:  JSR LFC55
LC3C2:  LDA ExodusDead
LC3C4:  BEQ LC3E5
LC3C6:  JSR BlockAlign          ;($FD1C)Update block aligned position of character 1.
LC3C9:  JSR LFDA3
LC3CC:  JSR BinToBCD            ;($F4D1)Convert binary number to BCD.
LC3CF:  LDA MapYPos
LC3D1:  CMP #$31
LC3D3:  BNE LC3E5
LC3D5:  LDA #$11
LC3D7:  STA $7506
LC3DA:  LDA #$75
LC3DC:  STA $2A
LC3DE:  LDA #$00
LC3E0:  STA $29
LC3E2:  JSR LoadPPUPalData      ;($ED3F)Load palette data into the PPU.
LC3E5:  LDX #$77
LC3E7:  LDA ScreenBlocks,X
LC3EA:  CMP #$0D
LC3EC:  BEQ GetNextMap
LC3EE:  CMP #$0E
LC3F0:  BEQ GetNextMap
LC3F2:  CMP #$0F
LC3F4:  BEQ GetNextMap
LC3F6:  CMP #$05
LC3F8:  BNE ChkFloorFight
LC3FA:  JMP ChkEnterMoongate    ;($C491)Check if player entered a moongate.

ChkFloorFight:
LC3FD:  LDA MapProperties
LC3FF:  CMP #MAP_NPC_PRES
LC401:  BNE NoFloorFight

LC403:  LDA ExodusDead
LC405:  BNE NoFloorFight

LC407:  LDA ThisMap
LC409:  CMP #MAP_EXODUS
LC40B:  BNE NoFloorFight

LC40D:  LDA MapYPos
LC40F:  CMP #$0C
LC411:  BEQ LC417

LC413:  CMP #$0D
LC415:  BNE NoFloorFight

LC417:  LDA MapXPos
LC419:  CMP #$1E
LC41B:  BCC NoFloorFight

LC41D:  CMP #$22
LC41F:  BCS NoFloorFight

LC421:  JMP DoFloorFight        ;($C712)Initiate floor fight.

NoFloorFight:
LC424:  JMP MainGameLoop        ;($C1B1)Main game engine loop.

GetNextMap:
LC427:  LDA ThisMap
LC429:  CMP #MAP_AMBROSIA
LC42B:  BEQ EnterShrine

;----------------------------------------------------------------------------------------------------

;Enter a town, castle or dungeon from the Sosaria overworld map.
EnterSubMap:
LC42D:  LDY #$02
LC42F:  LDA SubMapTbl,Y
LC432:  CMP MapXPos
LC434:  BNE LC43D
LC436:  LDA SubMapTbl+1,Y
LC439:  CMP MapYPos
LC43B:  BEQ LC446
LC43D:  INY
LC43E:  INY
LC43F:  CPY #$2A
LC441:  BNE LC42F
LC443:  JMP MainGameLoop        ;($C1B1)Main game engine loop.

LC446:  LDA MapXPos
LC448:  STA ReturnXPos
LC44A:  LDA MapYPos
LC44C:  STA ReturnYPos
LC44E:  TYA
LC44F:  LSR
LC450:  STA ThisMap
LC452:  ASL
LC453:  ASL
LC454:  ASL
LC455:  TAX
LC456:  LDY #$08
LC458:  LDA MapDatTbl+7,X
LC45B:  BPL LC45F
LC45D:  LDY #$09
LC45F:  STY MapProperties
LC461:  AND #$7F
LC463:  STA $D1
LC465:  JMP PrepLoadMap         ;($C146)Prepare to load a new map.

EnterShrine:
LC468:  LDY #$00
LC46A:  LDA ShrineEntryTbl,Y
LC46D:  CMP MapXPos
LC46F:  BNE LC478
LC471:  LDA ShrineEntryTbl+1,Y
LC474:  CMP MapYPos
LC476:  BEQ LC481
LC478:  INY
LC479:  INY
LC47A:  CPY #$08
LC47C:  BNE LC46A
LC47E:  JMP MainGameLoop        ;($C1B1)Main game engine loop.
LC481:  TYA
LC482:  CLC
LC483:  ADC #$2A
LC485:  TAY
LC486:  JMP LC446

ShrineEntryTbl:
LC489:  .byte $06, $06          ;XY position of shrine of intelligence.
LC48B:  .byte $37, $1B          ;XY position of shrine of wisdom.
LC48D:  .byte $04, $24          ;XY position of shrine of strength.
LC48F:  .byte $2D, $34          ;XY position of shrine of dexterity.

ChkEnterMoongate:
LC491:  LDA MapProperties
LC493:  CMP #MAP_PROP_OV
LC495:  BEQ +
LC497:  JMP MainGameLoop        ;($C1B1)Main game engine loop.

LC49A:* LDA FirstMoonPhase
LC49C:  AND #$70
LC49E:  LSR
LC49F:  LSR
LC4A0:  LSR
LC4A1:  TAX
LC4A2:  LDA MoonGateTbl,X
LC4A5:  CMP MapXPos
LC4A7:  BNE LC497
LC4A9:  LDA MoonGateTbl+1,X
LC4AC:  CMP MapYPos
LC4AE:  BNE LC497
LC4B0:  LDA SecondMoonPhase
LC4B2:  AND #$70
LC4B4:  LSR
LC4B5:  LSR
LC4B6:  LSR
LC4B7:  TAX
LC4B8:  LDA MoonGateTbl,X
LC4BB:  STA MapXPos
LC4BD:  LDA MoonGateTbl+1,X
LC4C0:  STA MapYPos
LC4C2:  LDA #$03
LC4C4:  JSR FlashAndSound       ;($DB2D)Flash screen with SFX.
LC4C7:  LDA #$01
LC4C9:  STA $EC
LC4CB:  LDA #SFX_MN_GATE_B+INIT 
LC4CD:  STA ThisSFX
LC4CF:  JMP LoadNewMap          ;($C175)Load a new map.

MoonGateTbl:
LC4D2:  .byte $08, $08, $3B, $2E, $0F, $1B, $24, $3A, $0F, $1D, $0C, $37, $1F, $1F, $3A, $1F

LC4E2:  .byte $00, $0C, $DF, $0E, $00, $0D, $00, $0E

;----------------------------------------------------------------------------------------------------

SetMapDatNPtrs:
LC4EA:  LDA ThisMap
LC4EC:  ASL
LC4ED:  ASL
LC4EE:  ASL
LC4EF:  TAX
LC4F0:  LDA MapDatTbl,X
LC4F3:  STA MapBank
LC4F5:  INX
LC4F6:  LDA MapDatTbl,X
LC4F9:  STA _MapDatPtrLB
LC4FB:  STA MapDatPtrLB
LC4FD:  INX
LC4FE:  LDA MapDatTbl,X
LC501:  STA MapDatPtrUB
LC503:  STA _MapDatPtrUB
LC505:  INX
LC506:  LDA MapDatTbl,X
LC509:  STA NPCSrcPtrLB
LC50B:  INX
LC50C:  LDA MapDatTbl,X
LC50F:  STA NPCSrcPtrUB
LC511:  RTS

;----------------------------------------------------------------------------------------------------

LC512:  LDA $004F,Y
LC515:  AND #$F0
LC517:  BEQ LC520
LC519:  LSR 
LC51A:  LSR 
LC51B:  LSR 
LC51C:  LSR 
LC51D:  ORA #$10
LC51F:  RTS

LC520:  LDA $004F,Y
LC523:  RTS

LC524:  LDA $C9
LC526:  BNE LC534
LC528:  LDA ExodusDead
LC52A:  CMP #GME_LOST
LC52C:  BNE LC533
LC52E:  PLA
LC52F:  PLA
LC530:  JMP LE399
LC533:  RTS
LC534:  STA $30
LC536:  SEC
LC537:  SBC #$44
LC539:  LSR
LC53A:  LSR
LC53B:  LSR
LC53C:  LSR
LC53D:  TAX
LC53E:  LDA $82,X
LC540:  TAX
LC541:  LDA $C556,X
LC544:  STA Ch1Dir
LC546:  PLA
LC547:  PLA
LC548:  LDA #$00
LC54A:  STA $C9
LC54C:  LDA #$10
LC54E:  JSR WaitSomeFrames      ;($E6D0)Wait some frames before continuing.
LC551:  LDA $30
LC553:  JMP LC764

LC556:  .byte $00, $02, $01, $00, $08, $00, $00, $00, $04

LC55F: LDA CurPRGBank
LC561: PHA
LC562: LDA #BANK_CREATE
LC564: JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LC567: JSR $B800
LC56A: PLA
LC56B: JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LC56E: RTS

LC56F: TAX
LC570: LDA CurPRGBank
LC572: PHA
LC573: TXA
LC574: STY $30
LC576: PHA
LC577: LDA $77E0,Y
LC57A: STA $29
LC57C: LDA $77E1,Y
LC57F: STA $2A
LC581: PLA
LC582: TAY
LC583: TXA
LC584: PHA
LC585: LDA DirConvTbl,Y
LC588: STA RngInput0
LC58A: LDA #$80
LC58C: STA RngInput1
LC58E: JSR RngCore              ;($FBF5)Core of the random number generator.
LC591: CLC
LC592: LDA $29
LC594: ADC RngNum0
LC596: STA $29
LC598: LDA $2A
LC59A: ADC RngNum1
LC59C: STA $2A
LC59E: LDA $30
LC5A0: LSR
LC5A1: STA RngInput0
LC5A3: LDA #$80
LC5A5: STA RngInput1
LC5A7: JSR RngCore              ;($FBF5)Core of the random number generator.
LC5AA: CLC
LC5AB: LDA #$00
LC5AD: ADC RngNum0
LC5AF: STA $2B
LC5B1: LDA #$09
LC5B3: ADC RngNum1
LC5B5: STA $2C
LC5B7: LDA #BANK_NPCS
LC5B9: JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LC5BC: LDA #$40
LC5BE: JSR SetPPUBufNewSize    ;($F079)Update length of data in PPU buffer.
LC5C1: LDA $2C
LC5C3: STA PPUBufBase,X
LC5C6: INX
LC5C7: LDA $2B
LC5C9: STA PPUBufBase,X
LC5CC: INX
LC5CD: LDY #$00
LC5CF: LDA ($29),Y
LC5D1: STA PPUBufBase,X
LC5D4: INY
LC5D5: INX
LC5D6: CPY #$40
LC5D8: BNE LC5CF
LC5DA: CLC
LC5DB: LDA $2B
LC5DD: ADC #$40
LC5DF: STA $2B
LC5E1: LDA $2C
LC5E3: ADC #$00
LC5E5: STA $2C
LC5E7: LDA #$40
LC5E9: JSR SetPPUBufNewSize    ;($F079)Update length of data in PPU buffer.
LC5EC: LDA $2C
LC5EE: STA PPUBufBase,X
LC5F1: INX
LC5F2: LDA $2B
LC5F4: STA PPUBufBase,X
LC5F7: INX
LC5F8: LDY #$40
LC5FA: LDA ($29),Y
LC5FC: STA PPUBufBase,X
LC5FF: INY
LC600: INX
LC601: CPY #$80
LC603: BNE LC5FA
LC605: LDA #$01
LC607: JSR WaitSomeFrames      ;($E6D0)Wait some frames before continuing.
LC60A: PLA
LC60B: TAX
LC60C: PLA
LC60D: JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LC610: RTS

;----------------------------------------------------------------------------------------------------

;The following table are the functions to run when one of the 14 commands are
;selected from the command menu.

CmdPtrTbl:
LC611:  .word DoTalkCmd,  DoMagicCmd, DoFightCmd, DoStatusCmd
LC619:  .word DoToolsCmd, DoGiveCmd,  DoGetCmd,   DoClimbCmd
LC621:  .word DoFoodCmd,  DoGoldCmd,  DoHorseCmd, DoOrderCmd
LC629:  .word DoBribeCmd, DoPrayCmd

;----------------------------------------------------------------------------------------------------

LC62D:  LDA #$0C
LC62F:  STA Wnd2XPos
LC632:  LDA #$08
LC634:  STA Wnd2YPos
LC637:  LDA #$06
LC639:  STA Wnd2Width
LC63C:  LDA #$06
LC63E:  STA Wnd2Height
LC641:  LDA #$02
LC643:  STA NumMenuItems
LC645:  LDA #$00
LC647:  STA $9D
LC649:  LDA #$65
LC64B:  STA TextIndex2
LC64E:  JSR ShowSelectWnd       ;($E4FF)Show a window where player makes a selection.
LC651:  PHP
LC652:  PHA
LC653:  JSR LE699
LC656:  LDA $C8
LC658:  STA HideUprSprites
LC65A:  PLA
LC65B:  PLP
LC65C:  BCS LC65F
LC65E:  RTS
LC65F:  LDA #$01
LC661:  RTS

;----------------------------------------------------------------------------------------------------

DoTalkCmd:
LC662:  JSR ChkValidNPC         ;($C6EC)Check if valid NPC in front of player.
LC665:  BCS NoTalk              ;Is there a valid NPC in front of the player? If not, branch.

LC667:  LDA LastTalkedNPC0
LC669:  STA LastTalkedNPC1

LC66B:  LDA NPCSprIndex,Y
LC66E:  AND #$7F
LC670:  CMP #NPC_PLR_BOAT

LC672:  BEQ EndTalk

LC674:  CMP #NPC_WHIRLPOOL
LC676:  BEQ EndTalk

LC678:  CMP #NPC_LND_EN_1
LC67A:  BCC GetDialogByte

LC67C:  CMP #NPC_SHERRY
LC67E:  BCS GetDialogByte

EndTalk:
LC680:  JMP FinishCommand       ;($C293)Post-command cleanup and run the game engine loop.

GetDialogByte:
LC683:  INY
LC684:  LDA (NPCSrcPtr),Y
LC686:  STY LastTalkedNPC0
LC688:  CMP #$F0
LC68A:  BCC LC6AB
LC68C:  SEC
LC68D:  SBC #$F0
LC68F:  ASL
LC690:  TAX

LC691:  LDA TalkFuncTbl,X
LC694:  STA IndJumpPtrLB
LC696:  LDA TalkFuncTbl+1,X
LC699:  STA IndJumpPtrUB

LC69B:  LDA #BANK_HELPERS2
LC69D:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LC6A0:  JSR LC6E9

LC6A3:  LDA MapBank
LC6A5:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LC6A8:  JMP Do2BinToBCDs        ;($D3E3)Exit after doing 2 Bin to BCD conversions.

LC6AB:  STA TextIndex
LC6AD:  LDA #$9D
LC6AF:  STA TextBasePtrUB
LC6B1:  LDA #$80
LC6B3:  STA TextBasePtrLB

LC6B5:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.

LC6B8:  LDA #$80
LC6BA:  STA TextBasePtrUB
LC6BC:  LDA #$00
LC6BE:  STA TextBasePtrLB

LC6C0:  JMP FinishCommand       ;($C293)Post-command cleanup and run the game engine loop.

NoTalk:
LC6C3:  LDA #$02                ;NO ONE IS HERE text.
LC6C5:  STA TextIndex           ;
LC6C7:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LC6CA:  JMP FinishCommand       ;($C293)Post-command cleanup and run the game engine loop.

;The following table contains the function pointers to the various types of interactive
;dialog found in the game.

TalkFuncTbl:
LC6CD:  .word FortuneTalk, HealerTalk, WeaponTalk, ArmoryTalk
LC6D5:  .word GroceryTalk, PubTalk,    GuildTalk,  StableTalk
LC6DD:  .word InnTalk,     TempleTalk, CasinoTalk, ShrineTalk
LC6E5:  .word LBTalk,      SherryTalk

LC6E9:  JMP (IndJumpPtr)        ;Jump to interactive dialog function above.

;----------------------------------------------------------------------------------------------------

ChkValidNPC:
LC6EC:  JSR GetTargetNPC        ;($E6EF)Check if valid NPC at target.
LC6EF:  BCS LC704
LC6F1:  STA $30
LC6F3:  LDY #$00
LC6F5:  LDA NPCOnscreen,Y
LC6F8:  CMP $30
LC6FA:  BEQ LC703
LC6FC:  INY
LC6FD:  INY
LC6FE:  INY
LC6FF:  INY
LC700:  JMP LC6F5
LC703:  CLC
LC704:  RTS

;----------------------------------------------------------------------------------------------------

LC705:  LDA #SPRT_HIDE
LC707:  STA SpriteBuffer,X
LC70A:  INX
LC70B:  INX
LC70C:  INX
LC70D:  INX
LC70E:  DEY
LC70F:  BNE LC707
LC711:  RTS

;----------------------------------------------------------------------------------------------------

DoFloorFight:
LC712:  LDX #$00
LC714:  LDA #$00
LC716:  STA $0600,X
LC719:  INX
LC71A:  CPX #$80
LC71C:  BNE LC714
LC71E:  LDA #$05
LC720:  JMP LC72B
LC723:  LDA #BANK_HELPERS1
LC725:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LC728:  JSR $AE80
LC72B:  PHA
LC72C:  LDA #$00
LC72E:  STA CurPPUConfig1
LC730:  JSR LoadAlphaNumMaps    ;($ED76)Load character set and map tiles.
LC733:  LDA #$FE
LC735:  STA $2A
LC737:  LDA #$3E
LC739:  STA $29
LC73B:  JSR LED33
LC73E:  LDA #ENABLE
LC740:  STA DisNPCMovement
LC742:  STA FightTurnIndex
LC744:  STA CurPieceYVis
LC746:  STA $D9
LC748:  LDA #BANK_ENEMIES
LC74A:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LC74D:  LDA MapProperties
LC74F:  STA PrevMapProp
LC751:  LDA #MAP_PROP_FIGHT
LC753:  STA MapProperties
LC755:  PLA
LC756:  PHA
LC757:  LDX #$0A
LC759:  JMP LC7D4

;----------------------------------------------------------------------------------------------------

DoFightCmd:
LC75C:  JSR GetTargetNPC        ;($E6EF)Check if valid NPC at target.
LC75F:  BCC LC764
LC761:  JMP LC6C3
LC764:  STA $30
LC766:  LDA ScrollDirAmt
LC768:  BNE LC766
LC76A:  LDY #$00
LC76C:  LDA NPCOnscreen,Y
LC76F:  CMP $30
LC771:  BEQ LC77A
LC773:  INY
LC774:  INY
LC775:  INY
LC776:  INY
LC777:  JMP LC76C
LC77A:  STY $E6
LC77C:  LDA NPCSprIndex,Y
LC77F:  AND #$7F
LC781:  CMP #$05
LC783:  BEQ LC789
LC785:  CMP #$1E
LC787:  BNE LC790
LC789:  LDA #$00
LC78B:  STA $E6
LC78D:  JMP FinishCommand       ;($C293)Post-command cleanup and run the game engine loop.

LC790:  STA EnemyNum
LC792:  PHA
LC793:  LDA MapProperties
LC795:  STA PrevMapProp
LC797:  ORA #MAP_TURN
LC799:  STA MapProperties
LC79B:  LDA #$00
LC79D:  STA FightTurnIndex
LC79F:  STA CurPieceYVis
LC7A1:  STA $D9
LC7A3:  LDA #BANK_ENEMIES
LC7A5:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LC7A8:  LDA #$00
LC7AA:  STA CurPPUConfig1
LC7AC:  LDX $30
LC7AE:  LDA SpriteBuffer+3,X
LC7B1:  LSR
LC7B2:  LSR
LC7B3:  LSR
LC7B4:  LSR
LC7B5:  STA $30
LC7B7:  LDA SpriteBuffer,X
LC7BA:  CLC
LC7BB:  ADC $30
LC7BD:  TAX
LC7BE:  LDA ScreenBlocks,X
LC7C1:  TAX
LC7C2:  CPX #$03
LC7C4:  BEQ LC7CA
LC7C6:  AND #$10
LC7C8:  BEQ LC7D4
LC7CA:  PLA
LC7CB:  PHA
LC7CC:  LDX #$04
LC7CE:  CMP #$1C
LC7D0:  BEQ LC7D4
LC7D2:  LDX #$03

LC7D4:  LDA OnBoat
LC7D6:  BEQ LC7E8
LC7D8:  LDY #$10
LC7DA:  CPX #$03
LC7DC:  BEQ LC7E6
LC7DE:  LDY #$11
LC7E0:  CPX #$04
LC7E2:  BEQ LC7E6
LC7E4:  LDY #$12
LC7E6:  TYA
LC7E7:  TAX
LC7E8:  TXA
LC7E9:  AND #$1F
LC7EB:  ASL
LC7EC:  TAX
LC7ED:  LDA FightMapAdrTbl,X
LC7F0:  STA $29
LC7F2:  LDA FightMapAdrTbl+1,X
LC7F5:  STA $2A

LC7F7:  LDA #MUS_FIGHT+INIT
LC7F9:  STA InitNewMusic
LC7FB:  LDY #$00
LC7FD:  LDA ($29),Y
LC7FF:  STA ScreenBlocks,Y
LC802:  INY
LC803:  BNE LC7FD
LC805:  JSR ResetNameTableF1    ;($FBDC)Reset nametable offsets and select nametable 0.
LC808:  JSR BinToBCD            ;($F4D1)Convert binary number to BCD.
LC80B:  PLA
LC80C:  CMP #$1D
LC80E:  BEQ LC814
LC810:  CMP #$15
LC812:  BCS LC893
LC814:  STA $30
LC816:  ASL
LC817:  TAX
LC818:  LDA #$00
LC81A:  STA $C9
LC81C:  LDA $B500,X
LC81F:  STA $2E
LC821:  STA $DC
LC823:  LDA $B501,X
LC826:  STA $CA
LC828:  LDA #$00
LC82A:  PHA
LC82B:  LDA $30
LC82D:  CMP #$05
LC82F:  BNE LC837
LC831:  LDA #$06
LC833:  PHA
LC834:  JMP LC83C
LC837:  ASL
LC838:  CLC
LC839:  ADC #$80
LC83B:  PHA
LC83C:  LDX $30
LC83E:  LDA $CED2,X
LC841:  ASL
LC842:  ASL
LC843:  TAX
LC844:  LDA $FE4F,X
LC847:  STA $7519
LC84A:  LDA $FE50,X
LC84D:  STA $751A
LC850:  LDA $FE51,X
LC853:  STA $751B
LC856:  LDX $2E
LC858:  LDA $30
LC85A:  CMP #$02
LC85C:  BEQ LC868
LC85E:  CMP #$0E
LC860:  BEQ LC868
LC862:  CMP #$05
LC864:  BEQ LC868
LC866:  LDX #$00
LC868:  STX $2D
LC86A:  LDX #$00
LC86C:  LDA $30
LC86E:  CLC
LC86F:  ADC #$1E
LC871:  STA EnTypeBase,X
LC874:  LDA $2D
LC876:  STA EnHPBase,X
LC879:  INX
LC87A:  INX
LC87B:  CPX #$10
LC87D:  BNE LC86C
LC87F:  LDA #$08
LC881:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LC884:  ASL
LC885:  TAX
LC886:  LDA $2E
LC888:  STA EnHPBase,X
LC88B:  LDA #BANK_NPCS
LC88D:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LC890:  JMP LC903
LC893:  SEC
LC894:  SBC #$15
LC896:  ASL
LC897:  ASL
LC898:  ASL
LC899:  STA $30
LC89B:  LDA $00
LC89D:  AND #$07
LC89F:  CLC
LC8A0:  ADC $30
LC8A2:  TAX
LC8A3:  LDA $B300,X
LC8A6:  STA $30
LC8A8:  ASL
LC8A9:  ASL
LC8AA:  ASL
LC8AB:  TAX
LC8AC:  LDA $B400,X
LC8AF:  PHA
LC8B0:  LDA $B401,X
LC8B3:  PHA
LC8B4:  LDA $B402,X
LC8B7:  STA $C9
LC8B9:  LDA $B403,X
LC8BC:  STA $2E
LC8BE:  STA $DC
LC8C0:  LDA $B404,X
LC8C3:  STA $CA
LC8C5:  LDA $B405,X
LC8C8:  STA $7519
LC8CB:  LDA $B406,X
LC8CE:  STA $751A
LC8D1:  LDA $B407,X
LC8D4:  STA $751B
LC8D7:  LDX #$00
LC8D9:  LDY #$08
LC8DB:  LDA $30
LC8DD:  STA EnTypeBase,X
LC8E0:  INX
LC8E1:  LDA #$80
LC8E3:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LC8E6:  AND #$08
LC8E8:  BEQ LC8F2
LC8EA:  LDA #$0F
LC8EC:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LC8EF:  CLC
LC8F0:  ADC $2E
LC8F2:  STA EnTypeBase,X
LC8F5:  INX
LC8F6:  DEY
LC8F7:  BNE LC8DB
LC8F9:  LDA $2E
LC8FB:  STA $03F7
LC8FE:  LDA #BANK_ENEMIES
LC900:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LC903:  LDA #$75
LC905:  STA $2A
LC907:  LDA #$00
LC909:  STA $29
LC90B:  JSR LED33
LC90E:  LDA #$09
LC910:  STA $2C
LC912:  LDA #$00
LC914:  STA $2B
LC916:  LDA #$00
LC918:  STA $2E
LC91A:  LDA #$80
LC91C:  STA $2D
LC91E:  PLA
LC91F:  STA $2A
LC921:  PLA
LC922:  STA $29
LC924:  LDA #$00
LC926:  PHA
LC927:  JSR LoadPPU             ;($EFE3)Load values into PPU.
LC92A:  CLC
LC92B:  LDA $2C
LC92D:  PHA
LC92E:  ADC #$02
LC930:  STA $2C
LC932:  JSR LoadPPU             ;($EFE3)Load values into PPU.
LC935:  PLA
LC936:  STA $2C
LC938:  LDA $C9
LC93A:  BPL LC949
LC93C:  CLC
LC93D:  LDA $29
LC93F:  ADC #$80
LC941:  STA $29
LC943:  LDA $2A
LC945:  ADC #$00
LC947:  STA $2A
LC949:  CLC
LC94A:  LDA $2B
LC94C:  ADC #$80
LC94E:  STA $2B
LC950:  LDA $2C
LC952:  ADC #$00
LC954:  STA $2C
LC956:  PLA
LC957:  CLC
LC958:  ADC #$01
LC95A:  CMP #$04
LC95C:  BNE LC926
LC95E:  LDA #BANK_ENEMIES
LC960:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LC963:  LDX #$B0
LC965:  LDY #$00
LC967:  LDA OnBoat
LC969:  BEQ LC97E
LC96B:  LDX #$B0
LC96D:  LDY #$80
LC96F:  LDA En1Type
LC972:  CMP #$14
LC974:  BEQ LC97E
LC976:  CMP #$15
LC978:  BEQ LC97E
LC97A:  LDX #$B0
LC97C:  LDY #$40
LC97E:  STX $2A
LC980:  STY $29
LC982:  LDY #$00
LC984:  LDA ($29),Y
LC986:  STA CurPieceYVis
LC988:  LDA ($29),Y
LC98A:  STA $7304,Y
LC98D:  INY
LC98E:  CPY #$40
LC990:  BNE LC988
LC992:  JSR LFCE6
LC995:  LDX #$B1
LC997:  LDY #$80
LC999:  LDA $C9
LC99B:  BMI LC9BF
LC99D:  LDX #$B2
LC99F:  LDY #$80
LC9A1:  LDA En1Type
LC9A4:  CMP #$16
LC9A6:  BEQ LC9BF
LC9A8:  LDA OnBoat
LC9AA:  BEQ LC9BB
LC9AC:  LDX #$B2
LC9AE:  LDY #$00
LC9B0:  LDA $03F0
LC9B3:  CMP #$14
LC9B5:  BEQ LC9BF
LC9B7:  CMP #$15
LC9B9:  BEQ LC9BF
LC9BB:  LDX #$B1
LC9BD:  LDY #$00
LC9BF:  STX $2A
LC9C1:  STY $29
LC9C3:  LDY #$00
LC9C5:  LDA ($29),Y
LC9C7:  STA $7344,Y
LC9CA:  INY
LC9CB:  CPY #$80
LC9CD:  BNE LC9C5
LC9CF:  LDA $C9
LC9D1:  BPL LC9F2
LC9D3:  LDA #$00
LC9D5:  STA En1HP
LC9D8:  STA En2HP
LC9DB:  STA En3HP
LC9DE:  STA En5HP
LC9E1:  STA En6HP
LC9E4:  STA En7HP
LC9E7:  LDA $DC
LC9E9:  STA En4HP
LC9EC:  STA En8HP
LC9EF:  JMP LCA14
LC9F2:  LDA #$00
LC9F4:  STA $30
LC9F6:  LDA $30
LC9F8:  ASL
LC9F9:  TAX
LC9FA:  LDA EnHPBase,X
LC9FD:  BNE LCA0C
LC9FF:  TXA
LCA00:  ASL
LCA01:  ASL
LCA02:  ASL
LCA03:  CLC
LCA04:  ADC #$44
LCA06:  TAX
LCA07:  LDY #$04
LCA09:  JSR LC705
LCA0C:  INC $30
LCA0E:  LDA $30
LCA10:  CMP #$08
LCA12:  BNE LC9F6
LCA14:  LDA #$80
LCA16:  ORA OnBoat
LCA18:  STA OnBoat
LCA1A:  JSR LoadChrGFX          ;($EE4E)Load the sprite tiles for current party members.
LCA1D:  JSR LD1B0
LCA20:  LDA TimeStopTimer
LCA22:  AND #$7F
LCA24:  STA TimeStopTimer
LCA26:  LDA #$04
LCA28:  LDY #$04
LCA2A:  STA $007E,Y
LCA2D:  INY
LCA2E:  CPY #$0C
LCA30:  BNE LCA2A
LCA32:  LDA #$08
LCA34:  JSR LEFD8
LCA37:  LDA MapBank
LCA39:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LCA3C:  JSR LEFC6
LCA3F:  LDX #$00
LCA41:  LDA ScreenBlocks,X
LCA44:  STA $7400,X
LCA47:  INX
LCA48:  BNE LCA41
LCA4A:  LDA #$1E
LCA4C:  STA CurPPUConfig1
LCA4E:  LDA #$F2
LCA50:  JSR LD227
LCA53:  LDA DelayConst
LCA55:  ASL
LCA56:  JSR WaitSomeFrames      ;($E6D0)Wait some frames before continuing.
LCA59:  LDA #$D4
LCA5B:  STA HideUprSprites
LCA5D:  LDA #$FF
LCA5F:  STA TextBuffer
LCA62:  LDA #$FF
LCA64:  STA $30
LCA66:  JSR ShowCmbtSideMsg     ;($D2BA)Show message in combat side window.
LCA69:  LDA FightTurnIndex
LCA6B:  ASL
LCA6C:  TAX
LCA6D:  LDA ChrPtrBaseLB,X
LCA6F:  STA CrntChrPtrLB
LCA71:  LDA ChrPtrBaseUB,X
LCA73:  STA CrntChrPtrUB
LCA75:  LDY #CHR_COND
LCA77:  LDA (CrntChrPtr),Y
LCA79:  CMP #$03
LCA7B:  BCS LCAD0
LCA7D:  LDA #$CF
LCA7F:  STA $9B
LCA81:  JSR LE6D8
LCA84:  CMP #$80
LCA86:  BEQ LCA8F
LCA88:  CMP #$40
LCA8A:  BEQ LCAD0
LCA8C:  JMP LD03C
LCA8F:  LDA #$21
LCA91:  JSR ShowCmbtSideMsg     ;($D2BA)Show message in combat side window.
LCA94:  LDA #$B0
LCA96:  STA $7300
LCA99:  LDA #$A8
LCA9B:  STA $7303
LCA9E:  LDA #$00
LCAA0:  STA $7302
LCAA3:  LDA #$01
LCAA5:  STA $2E
LCAA7:  LDA #$03
LCAA9:  STA $2D
LCAAB:  JSR LE685
LCAAE:  BCS LCAD0
LCAB0:  CMP #$FF
LCAB2:  BEQ LCA94
LCAB4:  JSR LE699
LCAB7:  CMP #$00
LCAB9:  BNE LCAC3
LCABB:  LDA #SPRT_HIDE
LCABD:  STA $73C4
LCAC0:  JMP LD0B3
LCAC3:  CMP #$01
LCAC5:  BNE LCACA
LCAC7:  JMP LD199
LCACA:  JMP LD1A7

LCACD:  JSR BinToBCD            ;($F4D1)Convert binary number to BCD.

LCAD0:  LDA #$08
LCAD2:  JSR LEFD8
LCAD5:  LDA #SPRT_HIDE
LCAD7:  STA $7300
LCADA:  LDA CurPieceYVis
LCADC:  AND #$01
LCADE:  BNE LCADA
LCAE0:  LDA #$D4
LCAE2:  STA HideUprSprites
LCAE4:  INC FightTurnIndex
LCAE6:  LDA FightTurnIndex
LCAE8:  CMP #$0C
LCAEA:  BNE LCAF1
LCAEC:  JSR LFC55
LCAEF:  LDA #$00
LCAF1:  STA FightTurnIndex
LCAF3:  ASL
LCAF4:  ASL
LCAF5:  ASL
LCAF6:  ASL
LCAF7:  TAX
LCAF8:  LDA $7304,X
LCAFB:  STA CurPieceYVis
LCAFD:  JSR LFAF6
LCB00:  LDA FightTurnIndex
LCB02:  CMP #$04
LCB04:  BCS LCB09
LCB06:  JMP LCA59
LCB09:  LDA #$D4
LCB0B:  STA HideUprSprites
LCB0D:  LDA #$FF
LCB0F:  STA TextBuffer
LCB12:  LDA #$FF
LCB14:  STA $30
LCB16:  JSR ShowCmbtSideMsg     ;($D2BA)Show message in combat side window.
LCB19:  LDA TimeStopTimer
LCB1B:  BNE LCADA
LCB1D:  LDA FightTurnIndex
LCB1F:  SEC
LCB20:  SBC #$04
LCB22:  ASL
LCB23:  TAX
LCB24:  LDA EnHPBase,X
LCB27:  BEQ LCAD0
LCB29:  LDA #$64
LCB2B:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LCB2E:  CMP #$32
LCB30:  BCS LCB44
LCB32:  LDA $C9
LCB34:  AND #$7F
LCB36:  CMP #$04
LCB38:  BNE LCB3D
LCB3A:  JMP LCF06
LCB3D:  CMP #$03
LCB3F:  BNE LCB44
LCB41:  JMP LCF46
LCB44:  JSR LCEF1
LCB47:  LDX #$00
LCB49:  LDA #$FF
LCB4B:  STA $30
LCB4D:  LDA $0600,X
LCB50:  CMP $30
LCB52:  BCS LCB58
LCB54:  STX $2E
LCB56:  STA $30
LCB58:  INX
LCB59:  CPX #$04
LCB5B:  BNE LCB4D
LCB5D:  LDA $2E
LCB5F:  ASL
LCB60:  ASL
LCB61:  ASL
LCB62:  ASL
LCB63:  TAX
LCB64:  LDA $7304,X
LCB67:  SEC
LCB68:  SBC $18
LCB6A:  BEQ LCB88
LCB6C:  LDY #$04
LCB6E:  BCS LCB77
LCB70:  LDY #$08
LCB72:  EOR #$FF
LCB74:  CLC
LCB75:  ADC #$01
LCB77:  CMP #$10
LCB79:  BEQ LCB88
LCB7B:  TXA
LCB7C:  PHA
LCB7D:  TYA
LCB7E:  PHA
LCB7F:  JSR LCFA0
LCB82:  PLA
LCB83:  TAY
LCB84:  PLA
LCB85:  TAX
LCB86:  BCC LCBAB
LCB88:  LDA $7307,X
LCB8B:  SEC
LCB8C:  SBC $19
LCB8E:  BEQ LCB9F
LCB90:  LDY #$01
LCB92:  BCS LCB9B
LCB94:  LDY #$02
LCB96:  EOR #$FF
LCB98:  CLC
LCB99:  ADC #$01
LCB9B:  CMP #$10
LCB9D:  BNE LCBAB
LCB9F:  LDX $2E
LCBA1:  LDA $0604,X
LCBA4:  ORA $0608,X
LCBA7:  CMP #$11
LCBA9:  BCC LCBC3
LCBAB:  JSR LCFA0
LCBAE:  BCC LCBB3
LCBB0:  JMP LCAD0
LCBB3:  LDX FightTurnIndex
LCBB5:  TYA
LCBB6:  STA Ch1Dir,X
LCBB8:  LDA #$01
LCBBA:  STA ScrollDirAmt
LCBBC:  LDA ScrollDirAmt
LCBBE:  BNE LCBBC
LCBC0:  JMP LCAD0
LCBC3:  LDA #SFX_EN_MISS+INIT
LCBC5:  STA ThisSFX
LCBC7:  LDA $2E
LCBC9:  ASL
LCBCA:  TAX
LCBCB:  LDA ChrPtrBaseLB,X
LCBCD:  STA CrntChrPtrLB
LCBCF:  LDA ChrPtrBaseUB,X
LCBD1:  STA CrntChrPtrUB
LCBD3:  LDY #CHR_EQ_ARMOR
LCBD5:  LDA (CrntChrPtr),Y
LCBD7:  CLC
LCBD8:  ADC #$0A
LCBDA:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LCBDD:  CMP #$08
LCBDF:  BCC LCBE4
LCBE1:  JMP LCD62
LCBE4:  LDA #SFX_SWING+INIT
LCBE6:  STA ThisSFX
LCBE8:  LDA FightTurnIndex
LCBEA:  SEC
LCBEB:  SBC #$04
LCBED:  LDA $DC
LCBEF:  LSR
LCBF0:  LSR
LCBF1:  LSR
LCBF2:  STA $30
LCBF4:  LDY #CHR_MAX_HP+1
LCBF6:  LDA (CrntChrPtr),Y
LCBF8:  ASL
LCBF9:  SEC
LCBFA:  ADC $30
LCBFC:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LCBFF:  STA $30
LCC01:  LDA $C9
LCC03:  BPL LCC10
LCC05:  LDA $30
LCC07:  CLC
LCC08:  ADC #$38
LCC0A:  BCC LCC0E
LCC0C:  LDA #$B0
LCC0E:  STA $30
LCC10:  LDX #$06
LCC12:  LDA PrevMapProp
LCC14:  AND #$04
LCC16:  BNE LCC2A
LCC18:  LDX #$10
LCC1A:  LDA PrevMapProp
LCC1C:  AND #$01
LCC1E:  BNE LCC2A
LCC20:  LDX #$1A
LCC22:  LDA ThisMap
LCC24:  CMP #MAP_EXODUS
LCC26:  BNE LCC2A
LCC28:  LDX #$24
LCC2A:  TXA
LCC2B:  SEC
LCC2C:  ADC $30
LCC2E:  STA $A0
LCC30:  LDA #$00
LCC32:  STA $A1
LCC34:  LDY #CHR_HIT_PNTS
LCC36:  LDA (CrntChrPtr),Y
LCC38:  SEC
LCC39:  SBC $A0
LCC3B:  STA $2B
LCC3D:  INY
LCC3E:  LDA (CrntChrPtr),Y
LCC40:  SBC #$00
LCC42:  STA $2C
LCC44:  BCS LCC49
LCC46:  JMP LCD12
LCC49:  LDA $2C
LCC4B:  ORA $2B
LCC4D:  BEQ LCC46
LCC4F:  LDA #SFX_PLYR_HIT+INIT
LCC51:  STA ThisSFX
LCC53:  LDA $2E
LCC55:  STA $30
LCC57:  JSR LD215
LCC5A:  LDY #CHR_HIT_PNTS
LCC5C:  LDA $2B
LCC5E:  STA (CrntChrPtr),Y
LCC60:  LDA $2C
LCC62:  INY
LCC63:  STA (CrntChrPtr),Y
LCC65:  LDA #$22
LCC67:  STA $2A
LCC69:  JSR LD225
LCC6C:  LDA $C9
LCC6E:  AND #$7F
LCC70:  CMP #$02
LCC72:  BNE LCC8E
LCC74:  LDA #$04
LCC76:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LCC79:  BEQ +

LCC7B:  JMP LCD07

LCC7E:* LDY #CHR_COND
LCC80:  LDA #COND_POIS
LCC82:  STA (CrntChrPtr),Y

LCC84:  LDA #$2E                ;POISON TRAP! CHARACTER IS POISONED! text.
LCC86:  STA TextIndex           ;
LCC88:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.

LCC8B:  JMP LCD07

LCC8E:  CMP #$01
LCC90:  BNE LCD07
LCC92:  LDA #$64
LCC94:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LCC97:  CMP #$32
LCC99:  BCS LCCBF
LCC9B:  LDA $00
LCC9D:  AND #$03
LCC9F:  BNE LCD07
LCCA1:  LDY #CHR_EQ_WEAPON
LCCA3:  LDA (CrntChrPtr),Y
LCCA5:  CLC
LCCA6:  ADC #$0B
LCCA8:  STA $30
LCCAA:  LDA #$0C
LCCAC:  STA $2C
LCCAE:  LDA #$1B
LCCB0:  STA $2D
LCCB2:  LDA $00
LCCB4:  AND #$07
LCCB6:  CLC
LCCB7:  ADC #$0C
LCCB9:  TAY
LCCBA:  LDX #$0F
LCCBC:  JMP LCCE0
LCCBF:  LDA $00
LCCC1:  AND #$03
LCCC3:  BNE LCD07
LCCC5:  LDY #CHR_EQ_ARMOR
LCCC7:  LDA (CrntChrPtr),Y
LCCC9:  CLC
LCCCA:  ADC #$1A
LCCCC:  STA $30
LCCCE:  LDA #$1B
LCCD0:  STA $2C
LCCD2:  LDA #$22
LCCD4:  STA $2D
LCCD6:  LDA $00
LCCD8:  AND #$03
LCCDA:  CLC
LCCDB:  ADC #$1B
LCCDD:  TAY
LCCDE:  LDX #$07
LCCE0:  LDA (CrntChrPtr),Y
LCCE2:  BEQ LCCEC
LCCE4:  CMP #$01
LCCE6:  BNE LCCF9
LCCE8:  CPY $30
LCCEA:  BNE LCCF9
LCCEC:  INY
LCCED:  CPY $2D
LCCEF:  BNE LCCF3
LCCF1:  LDY $2C
LCCF3:  DEX
LCCF4:  BNE LCCE0
LCCF6:  JMP LCD07
LCCF9:  LDA (CrntChrPtr),Y
LCCFB:  SEC
LCCFC:  SBC #$01
LCCFE:  STA (CrntChrPtr),Y

LCD00:  LDA #$D7                ;CHARACTER WAS ROBBED text.
LCD02:  STA TextIndex           ;
LCD04:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.

LCD07:  JMP LCAD0

LCD0A:  STA $30
LCD0C:  JSR ShowCmbtSideMsg     ;($D2BA)Show message in combat side window.
LCD0F:  JMP LD178
LCD12:  LDA #$00
LCD14:  STA (CrntChrPtr),Y
LCD16:  DEY
LCD17:  STA (CrntChrPtr),Y
LCD19:  LDY #CHR_COND
LCD1B:  LDA #$03
LCD1D:  STA (CrntChrPtr),Y
LCD1F:  LDX $2E
LCD21:  LDA #$F0
LCD23:  STA $03E0,X
LCD26:  LDA $2E
LCD28:  ASL
LCD29:  ASL
LCD2A:  ASL
LCD2B:  ASL
LCD2C:  TAX
LCD2D:  LDA #SPRT_HIDE
LCD2F:  STA $7304,X
LCD32:  STA $7308,X
LCD35:  STA $730C,X
LCD38:  STA $7310,X
LCD3B:  LDY #$0B
LCD3D:  LDA (Pos1ChrPtr),Y
LCD3F:  CMP #$03
LCD41:  BCC LCD58
LCD43:  LDA (Pos2ChrPtr),Y
LCD45:  CMP #$03
LCD47:  BCC LCD58
LCD49:  LDA (Pos3ChrPtr),Y
LCD4B:  CMP #$03
LCD4D:  BCC LCD58
LCD4F:  LDA (Pos4ChrPtr),Y
LCD51:  CMP #$03
LCD53:  BCC LCD58
LCD55:  JMP LD315
LCD58:  LDA #$29
LCD5A:  STA $30
LCD5C:  JSR ShowCmbtSideMsg     ;($D2BA)Show message in combat side window.
LCD5F:  JMP LD178
LCD62:  LDA #$24
LCD64:  JMP LCD0A

BattleWon:
LCD67:  LDA #$2A
LCD69:  JSR LD227
LCD6C:  LDA PrevMapProp
LCD6E:  AND #$01
LCD70:  BEQ LCD75
LCD72:  JMP LCE91
LCD75:  LDA En1Type
LCD78:  CMP #$1E
LCD7A:  BCC LCD8A
LCD7C:  LDA #$FF
LCD7E:  STA EnemyNum
LCD80:  TYA
LCD81:  PHA
LCD82:  JSR LF651
LCD85:  PLA
LCD86:  TAY
LCD87:  JMP LCE1F
LCD8A:  CMP #$16
LCD8C:  BEQ LCD91
LCD8E:  JMP LCE17
LCD91:  LDA OnBoat
LCD93:  BEQ LCD98
LCD95:  JMP LCE45
LCD98:  LDY $E6
LCD9A:  LDA NPCOnscreen,Y
LCD9D:  BEQ LCDBF
LCD9F:  TAX
LCDA0:  LDA #SPRT_HIDE
LCDA2:  STA $7300,X
LCDA5:  STA $7304,X
LCDA8:  STA $7308,X
LCDAB:  STA $730C,X
LCDAE:  LDA #$00
LCDB0:  STA $7301,X
LCDB3:  STA $7305,X
LCDB6:  STA $7309,X
LCDB9:  STA $730D,X
LCDBC:  STA NPCOnscreen,Y
LCDBF:  LDA NPCXPos,Y
LCDC2:  STA $047E
LCDC5:  STA $03D7
LCDC8:  LDA NPCYPOS,Y
LCDCB:  STA $047F
LCDCE:  STA $03D8
LCDD1:  LDA MapProperties
LCDD3:  AND #MAP_MOON_PH
LCDD5:  BEQ LCDE3
LCDD7:  LDA $03D7
LCDDA:  STA BoatXPos
LCDDD:  LDA $03D8
LCDE0:  STA BoatYPos
LCDE3:  LDA ThisMap
LCDE5:  CMP #MAP_AMBROSIA
LCDE7:  BNE LCE0F
LCDE9:  LDX #$00
LCDEB:  LDA $03D8
LCDEE:  CMP #$20
LCDF0:  BCC LCDFB
LCDF2:  INX
LCDF3:  LDA $03D7
LCDF6:  CMP #$20
LCDF8:  BCC LCDFB
LCDFA:  INX
LCDFB:  LDA #$9C
LCDFD:  STA NPCSprIndex
LCE00:  STA $0404
LCE03:  STA $0408
LCE06:  TXA
LCE07:  ASL
LCE08:  ASL
LCE09:  TAX
LCE0A:  LDA #$FF
LCE0C:  STA NPCSprIndex,X
LCE0F:  LDA #$85
LCE11:  STA $047C
LCE14:  JMP LCE45
LCE17:  CMP #$14
LCE19:  BEQ LCE45
LCE1B:  CMP #$15
LCE1D:  BEQ LCE45
LCE1F:  LDY $E6
LCE21:  LDA NPCXPos,Y
LCE24:  STA $48
LCE26:  PHA
LCE27:  LDA NPCYPOS,Y
LCE2A:  STA $47
LCE2C:  JSR LF5B0
LCE2F:  PLA
LCE30:  AND #$01
LCE32:  BNE LCE3D
LCE34:  LDA ($43),Y
LCE36:  AND #$0F
LCE38:  ORA #$A0
LCE3A:  JMP LCE43
LCE3D:  LDA ($43),Y
LCE3F:  AND #$F0
LCE41:  ORA #$0A
LCE43:  STA ($43),Y
LCE45:  LDA #$FE
LCE47:  STA $2A
LCE49:  LDA #$3E
LCE4B:  STA $29
LCE4D:  JSR LED33
LCE50:  LDA #$00
LCE52:  STA $C9
LCE54:  STA TimeStopTimer
LCE56:  LDX #$01
LCE58:  LDA En1Type
LCE5B:  CMP #$14
LCE5D:  BEQ LCE69
LCE5F:  CMP #$15
LCE61:  BEQ LCE69
LCE63:  CMP #$16
LCE65:  BEQ LCE69
LCE67:  LDX #$00
LCE69:  STX $30
LCE6B:  LDA EnemyNum
LCE6D:  CMP #$FF
LCE6F:  BEQ LCE91
LCE71:  STA $18
LCE73:  LDA MapXPos
LCE75:  STA $48
LCE77:  LDA MapYPos
LCE79:  CLC
LCE7A:  ADC #$0A
LCE7C:  STA $47
LCE7E:  LDA $E6
LCE80:  STA $19
LCE82:  LDA ThisMap
LCE84:  CMP #MAP_AMBROSIA
LCE86:  BNE LCE8E
LCE88:  LDA EnemyNum
LCE8A:  CMP #$1C
LCE8C:  BEQ LCE91
LCE8E:  JSR LF641
LCE91:  LDA #$00
LCE93:  STA $E6
LCE95:  LDA #$FF
LCE97:  STA $D2
LCE99:  LDA PrevMapProp
LCE9B:  STA MapProperties
LCE9D:  JSR LFC55
LCEA0:  JMP LoadNewMap          ;($C175)Load a new map.

LCEA3:  .byte $00, $78, $76, $00, $87, $00, $00, $00, $67

FightMapAdrTbl:
LCEAC:  .word $A100, $A200, $A300, $A600, $A800, $A400, $A400, $A400
LCEBC:  .word $A500, $A500, $A500, $A500, $A500, $A500, $A500, $A500
LCECC:  .word $A700, $AA00, $A900

LCED2:  .byte $03, $00, $00, $00, $01, $03, $00, $03, $00, $00, $00, $03, $03, $03, $01, $03
LCEE2:  .byte $00, $00, $03, $00, $00, $02, $02, $02, $02, $02, $02, $02, $02, $03, $00

LCEF1:  LDA CurPRGBank
LCEF3:  PHA
LCEF4:  LDA #BANK_HELPERS1
LCEF6:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LCEF9:  JSR $9480
LCEFC:  PLA
LCEFD:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LCF00:  RTS
LCF01:  LDA #$01
LCF03:  JMP LCF08
LCF06:  LDA #$00
LCF08:  STA $EE
LCF0A:  LDA #SFX_EN_MJ_SPL+INIT
LCF0C:  STA ThisSFX
LCF0E:  JSR Flash8              ;($DB36)Repeat screen flashing routine 8 times.
LCF11:  LDA #$04
LCF13:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LCF16:  STA $2E
LCF18:  INC $2E
LCF1A:  LDA $2E
LCF1C:  AND #$03
LCF1E:  STA $2E
LCF20:  ASL
LCF21:  TAX
LCF22:  LDA ChrPtrBaseLB,X
LCF24:  STA CrntChrPtrLB
LCF26:  LDA ChrPtrBaseUB,X
LCF28:  STA CrntChrPtrUB
LCF2A:  LDY #$0B
LCF2C:  LDA (CrntChrPtr),Y
LCF2E:  CMP #$03
LCF30:  BCS LCF18
LCF32:  LDA #$64
LCF34:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LCF37:  CMP #$4B
LCF39:  BCC LCF43
LCF3B:  LDA $EE
LCF3D:  BNE LCF43
LCF3F:  LDA #$01
LCF41:  STA (CrntChrPtr),Y
LCF43:  JMP LCBE4
LCF46:  LDA $C9
LCF48:  BMI LCF01
LCF4A:  JSR LCEF1

LCF4D:  LDA #$04
LCF4F:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LCF52:  TAX
LCF53:  LDA $060C,X
LCF56:  STA $2E
LCF58:  LDA $0610,X
LCF5B:  STA $2D
LCF5D:  LDA $0604,X
LCF60:  STA $30
LCF62:  LDA $0608,X
LCF65:  LDX #$10
LCF67:  LDY #$00
LCF69:  CMP $30
LCF6B:  BCS LCF76
LCF6D:  LDA $2E
LCF6F:  BEQ LCF80
LCF71:  LDX #$F0
LCF73:  JMP LCF80
LCF76:  LDX #$00
LCF78:  LDY #$10
LCF7A:  LDA $2D
LCF7C:  BEQ LCF80
LCF7E:  LDY #$F0
LCF80:  STX $19
LCF82:  STY $18
LCF84:  JSR LD303
LCF87:  BCS LCF9D
LCF89:  TYA
LCF8A:  SEC
LCF8B:  SBC #$04
LCF8D:  STA $2E
LCF8F:  TAY
LCF90:  ASL
LCF91:  TAX
LCF92:  LDA ChrPtrBaseLB,X
LCF94:  STA CrntChrPtrLB
LCF96:  LDA ChrPtrBaseUB,X
LCF98:  STA CrntChrPtrUB
LCF9A:  JMP LCBE4
LCF9D:  JMP LCAD0
LCFA0:  TYA
LCFA1:  PHA
LCFA2:  LDA #$00
LCFA4:  STA $48
LCFA6:  LDA #$10
LCFA8:  STA $47
LCFAA:  CPY #$04
LCFAC:  BEQ LCFC6
LCFAE:  LDA #$F0
LCFB0:  STA $47
LCFB2:  CPY #$08
LCFB4:  BEQ LCFC6
LCFB6:  LDA #$00
LCFB8:  STA $47
LCFBA:  LDA #$10
LCFBC:  STA $48
LCFBE:  CPY #$01
LCFC0:  BEQ LCFC6
LCFC2:  LDA #$F0
LCFC4:  STA $48
LCFC6:  CLC
LCFC7:  LDA $19
LCFC9:  ADC $48
LCFCB:  STA $48
LCFCD:  CLC
LCFCE:  LDA $18
LCFD0:  ADC $47
LCFD2:  STA $47
LCFD4:  LDA MapProperties
LCFD6:  AND #MAP_TURN
LCFD8:  BEQ LD018
LCFDA:  LDA $48
LCFDC:  LSR
LCFDD:  LSR
LCFDE:  LSR
LCFDF:  LSR
LCFE0:  CLC
LCFE1:  ADC $47
LCFE3:  TAX
LCFE4:  LDA ScreenBlocks,X
LCFE7:  CMP #$08
LCFE9:  BEQ LD038
LCFEB:  CMP #$0C
LCFED:  BEQ LD038
LCFEF:  CMP #$03
LCFF1:  BNE LD007
LCFF3:  LDA FightTurnIndex
LCFF5:  CMP #$04
LCFF7:  BCC LD038
LCFF9:  LDA En1Type
LCFFC:  CMP #$14
LCFFE:  BEQ LD018
LD000:  CMP #$15
LD002:  BEQ LD018
LD004:  JMP LD038
LD007:  LDA FightTurnIndex
LD009:  CMP #$04
LD00B:  BCC LD018
LD00D:  LDA En1Type
LD010:  CMP #$14
LD012:  BEQ LD038
LD014:  CMP #$15
LD016:  BEQ LD038
LD018:  LDY #$00
LD01A:  LDX #$00
LD01C:  LDA $7304,X
LD01F:  CMP $47
LD021:  BNE LD02A
LD023:  LDA $7307,X
LD026:  CMP $48
LD028:  BEQ LD038
LD02A:  TXA
LD02B:  CLC
LD02C:  ADC #$10
LD02E:  TAX
LD02F:  INY
LD030:  CPY #$0C
LD032:  BNE LD01C
LD034:  PLA
LD035:  TAY
LD036:  CLC
LD037:  RTS
LD038:  PLA
LD039:  TAY
LD03A:  SEC
LD03B:  RTS
LD03C:  STA $30
LD03E:  LDX #$10
LD040:  LDY #$00
LD042:  CMP #$01
LD044:  BEQ LD064
LD046:  LDX #$F0
LD048:  CMP #$02
LD04A:  BEQ LD064
LD04C:  LDX #$00
LD04E:  LDY #$10
LD050:  CMP #$04
LD052:  BEQ LD064
LD054:  LDY #$F0
LD056:  CMP #$08
LD058:  BEQ LD064
LD05A:  LDA #$27
LD05C:  STA $30
LD05E:  JSR ShowCmbtSideMsg     ;($D2BA)Show message in combat side window.
LD061:  JMP LCA7D
LD064:  STX $2A
LD066:  STY $29
LD068:  LDA FightTurnIndex
LD06A:  ASL
LD06B:  ASL
LD06C:  ASL
LD06D:  ASL
LD06E:  TAX
LD06F:  LDA CurPieceYVis
LD071:  AND #$FE
LD073:  STA $18
LD075:  CLC
LD076:  ADC $29
LD078:  BEQ LD0A9
LD07A:  CMP #$E0
LD07C:  BEQ LD0A9
LD07E:  LDA $7307,X
LD081:  STA $19
LD083:  CLC
LD084:  ADC $2A
LD086:  BEQ LD0A9
LD088:  CMP #$A0
LD08A:  BEQ LD0A9
LD08C:  LDY $30
LD08E:  JSR LCFA0
LD091:  BCS LD0A9
LD093:  LDA #$08
LD095:  JSR LEFD8
LD098:  LDX FightTurnIndex
LD09A:  LDA $30
LD09C:  STA Ch1Dir,X
LD09E:  LDA #$01
LD0A0:  STA ScrollDirAmt
LD0A2:  LDA ScrollDirAmt
LD0A4:  BNE LD0A2
LD0A6:  JMP LCAD0
LD0A9:  LDA #$2C
LD0AB:  STA $30
LD0AD:  JSR ShowCmbtSideMsg     ;($D2BA)Show message in combat side window.
LD0B0:  JMP LCA7D
LD0B3:  LDA ThisMap
LD0B5:  CMP #MAP_EXODUS
LD0B7:  BNE LD0CB
LD0B9:  LDY #$34
LD0BB:  LDA (CrntChrPtr),Y
LD0BD:  CMP #$0F
LD0BF:  BEQ LD0CB
LD0C1:  LDA #$F5
LD0C3:  STA $30
LD0C5:  JSR LD227
LD0C8:  JMP LCAD0
LD0CB:  JSR LD26B
LD0CE:  BCC LD0D3
LD0D0:  JMP LCAD0
LD0D3:  LDY #$34
LD0D5:  LDA (CrntChrPtr),Y
LD0D7:  TAX
LD0D8:  LDA $D189,X
LD0DB:  BEQ LD0FB

LD0DD:  LDA #SFX_EN_MISS+INIT
LD0DF:  STA ThisSFX

LD0E1:  JSR LD303
LD0E4:  BCS LD12E
LD0E6:  STY $30
LD0E8:  LDA #$C8
LD0EA:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LD0ED:  LDY #$08
LD0EF:  LDA (CrntChrPtr),Y
LD0F1:  CLC
LD0F2:  ADC #$64
LD0F4:  CMP RngNum1
LD0F6:  BCS LD148
LD0F8:  JMP LD180
LD0FB:  LDA #SFX_SWING+INIT
LD0FD:  STA ThisSFX
LD0FF:  LDA $19
LD101:  PHA
LD102:  LDA $18
LD104:  PHA
LD105:  JSR LD232
LD108:  TAX
LD109:  PLA
LD10A:  STA $18
LD10C:  PLA
LD10D:  STA $19
LD10F:  TXA
LD110:  BCC LD133
LD112:  LDY #$34
LD114:  LDA (CrntChrPtr),Y
LD116:  CMP #$01
LD118:  BNE LD12E
LD11A:  LDY #$0C
LD11C:  LDA (CrntChrPtr),Y
LD11E:  SEC
LD11F:  SBC #$01
LD121:  STA (CrntChrPtr),Y
LD123:  BNE LD0DD
LD125:  LDY #$34
LD127:  LDA #$00
LD129:  STA (CrntChrPtr),Y
LD12B:  JMP LD0DD
LD12E:  LDA #$02
LD130:  JMP LD173
LD133:  STA $30
LD135:  LDA #$C8
LD137:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LD13A:  LDY #$08
LD13C:  LDA (CrntChrPtr),Y
LD13E:  SEC
LD13F:  ADC #$64
LD141:  CMP RngNum1
LD143:  BCS LD148
LD145:  JMP LD180
LD148:  LDY #CHR_STR
LD14A:  LDA (CrntChrPtr),Y
LD14C:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LD14F:  LDY #CHR_STR
LD151:  LDA (CrntChrPtr),Y
LD153:  LSR
LD154:  SEC
LD155:  ADC RngNum1
LD157:  STA RngNum1
LD159:  CLC
LD15A:  LDY #CHR_EQ_WEAPON
LD15C:  LDA (CrntChrPtr),Y
LD15E:  ASL
LD15F:  CLC
LD160:  ADC (CrntChrPtr),Y
LD162:  ADC RngNum1
LD164:  ADC #$04
LD166:  STA RngNum1
LD168:  JSR DoEnHit             ;($D1DC)Enemy hit. Init SFX and calculate damage.
LD16B:  BCS LD170
LD16D:  JMP LCAD0
LD170:  JMP BattleWon           ;($CD67)Enemy battle has been won.

LD173:  STA $30
LD175:  JSR ShowCmbtSideMsg     ;($D2BA)Show message in combat side window.
LD178:  LDA DelayConst
LD17A:  JSR WaitSomeFrames      ;($E6D0)Wait some frames before continuing.
LD17D:  JMP LCAD0
LD180:  LDA #SFX_PLYR_MISS+INIT
LD182:  STA ThisSFX
LD184:  LDA #$24
LD186:  JMP LD173

LD189:  .byte $00, $00, $00, $01, $00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00

LD199:  JSR CastMagic           ;($D34D)Cast a magic spell if player can do it.
LD19C:  JSR ChkAllEnDead        ;($D1C7)Check to see if all the enemies are dead.
LD19F:  BCS +                   ;Are all the enemies dead? If so, branch to exit fight.

LD1A1:  JMP LCACD

LD1A4:* JMP BattleWon           ;($CD67)Enemy battle has been won.

LD1A7:  JSR LDB5F
LD1AA:  JSR LD1B0
LD1AD:  JMP LCACD
LD1B0:  LDA #$14
LD1B2:  STA $2A
LD1B4:  LDA #$14
LD1B6:  STA $29
LD1B8:  LDA #$0C
LD1BA:  STA $2E
LD1BC:  LDA #$08
LD1BE:  STA $2D
LD1C0:  JSR ShowWindow          ;($F42A)Show a window on the display.
LD1C3:  JSR LFAE3
LD1C6:  RTS

;----------------------------------------------------------------------------------------------------

ChkAllEnDead:
LD1C7:  LDX #$00
LD1C9:  LDY #$08
LD1CB:  LDA #$00
LD1CD:  ORA EnHPBase,X
LD1D0:  INX
LD1D1:  INX
LD1D2:  DEY
LD1D3:  BNE LD1CD
LD1D5:  TAX
LD1D6:  BNE LD1DA

LD1D8:  SEC
LD1D9:  RTS

LD1DA:  CLC
LD1DB:  RTS

;----------------------------------------------------------------------------------------------------

DoEnHit:
LD1DC:  LDA RngNum1
LD1DE:  CMP #$FF
LD1E0:  BEQ LD1F1
LD1E2:  LDA $C9
LD1E4:  BPL LD1F1
LD1E6:  LSR RngNum1
LD1E8:  LDA RngNum1
LD1EA:  LSR
LD1EB:  SEC
LD1EC:  ADC RngNum1
LD1EE:  LSR
LD1EF:  STA RngNum1

LD1F1:  LDA #SFX_EN_HIT+INIT
LD1F3:  STA ThisSFX
LD1F5:  LDA $30
LD1F7:  PHA
LD1F8:  CLC
LD1F9:  ADC #$04
LD1FB:  STA $30
LD1FD:  JSR LD215
LD200:  PLA
LD201:  STA $30
LD203:  LDA CurPRGBank
LD205:  PHA
LD206:  LDA #BANK_HELPERS1
LD208:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LD20B:  JSR CalcEnDmg           ;($B900)Calculate damage to an enemy.
LD20E:  PLA
LD20F:  PHP
LD210:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LD213:  PLP
LD214:  RTS

;----------------------------------------------------------------------------------------------------

LD215:  LDA CurPRGBank
LD217:  PHA
LD218:  LDA #BANK_HELPERS1
LD21A:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LD21D:  JSR $BA00
LD220:  PLA
LD221:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LD224:  RTS

;----------------------------------------------------------------------------------------------------

LD225:  LDA $2A
LD227:  STA $30
LD229:  JSR ShowCmbtSideMsg     ;($D2BA)Show message in combat side window.
LD22C:  LDA DelayConst
LD22E:  JSR WaitSomeFrames      ;($E6D0)Wait some frames before continuing.
LD231:  RTS
LD232:  LDA FightTurnIndex
LD234:  ASL
LD235:  ASL
LD236:  ASL
LD237:  ASL
LD238:  TAX
LD239:  LDA CurPieceYVis
LD23B:  AND #$FE
LD23D:  CLC
LD23E:  ADC $18
LD240:  STA $18
LD242:  LDA $7307,X
LD245:  CLC
LD246:  ADC $19
LD248:  STA $19
LD24A:  LDX #$00
LD24C:  LDY #$00
LD24E:  LDA $7344,X
LD251:  CMP $18
LD253:  BNE LD25F
LD255:  LDA $7347,X
LD258:  CMP $19
LD25A:  BNE LD25F
LD25C:  TYA
LD25D:  CLC
LD25E:  RTS
LD25F:  TXA
LD260:  CLC
LD261:  ADC #$10
LD263:  TAX
LD264:  INY
LD265:  CPY #$08
LD267:  BNE LD24E
LD269:  SEC
LD26A:  RTS
LD26B:  LDA #$26
LD26D:  JSR ShowCmbtSideMsg     ;($D2BA)Show message in combat side window.
LD270:  LDA #$00
LD272:  STA $19
LD274:  STA $18
LD276:  LDA #$4F
LD278:  STA $9B
LD27A:  JSR LE6D8
LD27D:  TAX
LD27E:  CMP #$01
LD280:  BNE LD288
LD282:  LDA #$10
LD284:  STA $19
LD286:  BNE LD2A4
LD288:  CMP #$02
LD28A:  BNE LD292
LD28C:  LDA #$F0
LD28E:  STA $19
LD290:  BNE LD2A4
LD292:  CMP #$08
LD294:  BNE LD29C
LD296:  LDA #$F0
LD298:  STA $18
LD29A:  BNE LD2A4
LD29C:  CMP #$04
LD29E:  BNE LD2B0
LD2A0:  LDA #$10
LD2A2:  STA $18
LD2A4:  TXA
LD2A5:  LDX FightTurnIndex
LD2A7:  STA Ch1Dir,X
LD2A9:  LDA #$10
LD2AB:  JSR WaitSomeFrames      ;($E6D0)Wait some frames before continuing.
LD2AE:  CLC
LD2AF:  RTS
LD2B0:  CMP #$40
LD2B2:  BNE LD276
LD2B4:  LDA #$08
LD2B6:  STA Ch1Dir,X
LD2B8:  SEC
LD2B9:  RTS

;----------------------------------------------------------------------------------------------------

ShowCmbtSideMsg:
LD2BA:  PHA
LD2BB:  LDA #$D4
LD2BD:  STA HideUprSprites

LD2BF:  PLA
LD2C0:  STA $30

LD2C2:  LDA #$15
LD2C4:  STA $2A
LD2C6:  LDA #$16
LD2C8:  STA $29

LD2CA:  LDA #$09
LD2CC:  STA $2E
LD2CE:  LDA #$03
LD2D0:  STA $2D

LD2D2:  JSR DisplayText         ;($F0BE)Display text on the screen.
LD2D5:  RTS                     ;

;----------------------------------------------------------------------------------------------------

LD2D6:  LDA $30
LD2D8:  ASL
LD2D9:  TAY
LD2DA:  LDA EnHPBase,Y
LD2DD:  SEC
LD2DE:  SBC $2E
LD2E0:  BCC LD2E7
LD2E2:  STA EnHPBase,Y
LD2E5:  CLC
LD2E6:  RTS
LD2E7:  LDA #$00
LD2E9:  STA EnHPBase,Y
LD2EC:  LDA $30
LD2EE:  ASL
LD2EF:  ASL
LD2F0:  ASL
LD2F1:  ASL
LD2F2:  TAX
LD2F3:  LDA #SPRT_HIDE
LD2F5:  STA $7344,X
LD2F8:  STA $7348,X
LD2FB:  STA $734C,X
LD2FE:  STA $7350,X
LD301:  SEC
LD302:  RTS
LD303:  LDA CurPRGBank
LD305:  PHA
LD306:  LDA #BANK_HELPERS1
LD308:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LD30B:  JSR $BB00
LD30E:  PLA
LD30F:  PHP
LD310:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LD313:  PLP
LD314:  RTS

LD315:  LDA ScrollDirAmt
LD317:  BNE LD315
LD319:  STA ExodusDead
LD31B:  STA DisNPCMovement
LD31D:  STA OnBoat
LD31F:  JSR LFAE3
LD322:  LDA CurPRGBank
LD324:  PHA
LD325:  LDA #MUS_NONE+INIT
LD327:  STA InitNewMusic
LD329:  LDA #BANK_HELPERS1
LD32B:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LD32E:  JSR $9380
LD331:  PLA
LD332:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LD335:  JMP LoadNewMap          ;($C175)Load a new map.

;----------------------------------------------------------------------------------------------------

DoMagicCmd:
LD338:  JSR ChooseChar          ;($E42F)Select a character from a list.
LD33B:  BCC +                   ;Was a character selected? If so, branch.
LD33D:  JMP Do2BinToBCDs        ;($D3E3)Exit after doing 2 Bin to BCD conversions.

LD340:* JSR CastMagic           ;($D34D)Cast a magic spell if player can do it.
LD343:  CMP #MAP_NEW            ;Do we need to change to a new map after spell was cast?
LD345:  BNE +                   ;If not, branch.

LD347:  JMP LoadNewMap          ;($C175)Load a new map.

LD34A:* JMP Do2BinToBCDs        ;($D3E3)Exit after doing 2 Bin to BCD conversions.

CastMagic:
LD34D:  LDY #CHR_CLASS          ;
LD34F:  LDA (CrntChrPtr),Y      ;Get the type of magics the selected character can use.
LD351:  TAX                     ;
LD352:  LDA ClassMagicTbl,X     ;

LD355:  AND #$03                ;Can this character cast any magic at all?
LD357:  BEQ ChrNoMagic          ;If not, branch.

LD359:  CMP #$01                ;Can the character cast cleric magic?
LD35B:  BEQ ChrClericMagic      ;If so, branch.

LD35D:  CMP #$02                ;Can the character cast wizard magic?
LD35F:  BNE ChrBothMagic        ;If so, branch.

LD361:  JMP ChrWizardMagic      ;($D3AA)Player can do wizard magic.

ChrNoMagic:
LD364:  LDA #$25                ;YOU CAN'T CAST SPELLS text.
LD366:  JMP ShowMagicText       ;($D3DB)Show magic text.

ChrBothMagic:
LD369:  JSR LD3F0
LD36C:  BCC +

LD36E:  LDA #$00
LD370:  RTS

LD371:* CMP #$00
LD373:  BEQ ChrClericMagic

LD375:  JMP ChrWizardMagic      ;($D3AA)Player can do wizard magic.

ChrClericMagic:
LD378:  LDA #$05
LD37A:  STA TextIndex2
LD37D:  JSR LD415
LD380:  BCC LD383
LD382:  RTS

LD383:  STA $30
LD385:  ASL
LD386:  ASL
LD387:  TAX
LD388:  INX
LD389:  DEX
LD38A:  LDA $D4A0,X
LD38D:  AND MapProperties
LD38F:  BEQ LD3D9
LD391:  INX
LD392:  INX
LD393:  LDA $D4A0,X
LD396:  STA $8F
LD398:  LDA $D4A1,X
LD39B:  STA $90
LD39D:  CLC
LD39E:  LDA $30
LD3A0:  ADC #$10
LD3A2:  JSR LDD6E
LD3A5:  BCS LD3D9
LD3A7:  JMP ($008F)

ChrWizardMagic:
LD3AA:  LDA #$03
LD3AC:  STA TextIndex2
LD3AF:  JSR LD415
LD3B2:  BCC LD3B5
LD3B4:  RTS

LD3B5:  STA $30
LD3B7:  ASL
LD3B8:  ASL
LD3B9:  TAX
LD3BA:  INX
LD3BB:  DEX
LD3BC:  LDA $D460,X
LD3BF:  AND MapProperties
LD3C1:  BEQ LD3D9
LD3C3:  INX
LD3C4:  INX
LD3C5:  LDA $D460,X
LD3C8:  STA $8F
LD3CA:  LDA $D461,X
LD3CD:  STA $90
LD3CF:  LDA $30
LD3D1:  JSR LDD6E
LD3D4:  BCS LD3D9
LD3D6:  JMP ($008F)
LD3D9:  LDA #$17

ShowMagicText:
LD3DB:  STA TextIndex
LD3DD:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LD3E0:  LDA #$00
LD3E2:  RTS

;----------------------------------------------------------------------------------------------------

Do2BinToBCDs:
LD3E3:  JSR GetBCDNum           ;($D3EC)Convert binary number to BCD.
LD3E6:  JSR BinToBCD            ;($F4D1)Convert binary number to BCD.
LD3E9:  JMP FinishCommand       ;($C293)Post-command cleanup and run the game engine loop.

;----------------------------------------------------------------------------------------------------

GetBCDNum:
LD3EC:  JSR BinToBCD            ;($F4D1)Convert binary number to BCD.
LD3EF:  RTS                     ;

;----------------------------------------------------------------------------------------------------

LD3F0:  LDA #$00
LD3F2:  STA $9D
LD3F4:  LDA #$02
LD3F6:  STA NumMenuItems
LD3F8:  LDA #$19
LD3FA:  STA TextIndex2
LD3FD:  LDA #$0A
LD3FF:  STA Wnd2XPos
LD402:  LDA #$06
LD404:  STA Wnd2YPos
LD407:  LDA #$0A
LD409:  STA Wnd2Width
LD40C:  LDA #$06
LD40E:  STA Wnd2Height
LD411:  JSR ShowSelectWnd       ;($E4FF)Show a window where player makes a selection.
LD414:  RTS

;----------------------------------------------------------------------------------------------------

LD415:  JSR LD441
LD418:  LDX #$00
LD41A:  CMP #$09
LD41C:  BCC LD421
LD41E:  TAX
LD41F:  LDA #$08
LD421:  STA NumMenuItems
LD423:  STX $9D
LD425:  LDA #$0A
LD427:  STA Wnd2XPos
LD42A:  LDA #$06
LD42C:  STA Wnd2YPos
LD42F:  LDA #$0A
LD431:  STA Wnd2Width
LD434:  LDA NumMenuItems
LD436:  CLC
LD437:  ADC #$01
LD439:  ASL
LD43A:  STA Wnd2Height
LD43D:  JSR ShowSelectWnd       ;($E4FF)Show a window where player makes a selection.
LD440:  RTS
LD441:  LDY #CHR_MAG_PNTS
LD443:  LDA (CrntChrPtr),Y
LD445:  LDY #$00
LD447:  INY
LD448:  SEC
LD449:  SBC #$05
LD44B:  BCS LD447
LD44D:  CPY #$10
LD44F:  BCC LD453
LD451:  LDY #$10

LD453:  TYA
LD454:  RTS

;----------------------------------------------------------------------------------------------------

;The following table indicates which class can use which magic. The index into the table
;is the class. The value at the given index is the type of magic the class can use.
;0=No magic, 1=Cleric magic, 2=Wizard magic, 3=Both magics.

ClassMagicTbl:
LD455:  .byte MAGIC_NONE,   MAGIC_CLERIC, MAGIC_WIZARD, MAGIC_NONE
LD459:  .byte MAGIC_CLERIC, MAGIC_NONE,   MAGIC_WIZARD, MAGIC_CLERIC
LD45D:  .byte MAGIC_BOTH,   MAGIC_WIZARD, MAGIC_BOTH

;----------------------------------------------------------------------------------------------------

;The following 2 tables are spell data. The first byte in each entry is the places the spell
;can be used. 1=Dungeons, 2=Battles, 4=Overworld, $F=Always. The second byte is the MP cost
;required to cast the spell. The 3rd and 4th bytes are the function pointer to the spell
;handling routine.

WizSpellTbl:

;Repel.
LD460:  .byte SPL_BATTLE, $00   ;Battle spell, 0MP cost.
LD462:  .word DoRepel           ;

;Missile.
LD464:  .byte SPL_BATTLE, $05   ;Battle spell, 5MP cost.
LD466:  .word DoMissile         ;

;Light.
LD468:  .byte SPL_DUNGEON, $0A  ;Dungeon spell, 10MP cost.
LD46A:  .word DoLight           ;

;Descend.
LD46C:  .byte SPL_DUNGEON, $0F  ;Dungeon spell, 15MP cost.
LD46E:  .word DoDescend         ;

;Ascend.
LD470:  .byte SPL_DUNGEON, $14  ;Dungeon spell, 20MP cost.
LD472:  .word DoAscend          ;

;Flame.
LD474:  .byte SPL_BATTLE, $19   ;Battle spell, 25MP cost.
LD476:  .word DoFlame           ;

;Trans.
LD478:  .byte SPL_OVRWRLD, $1E  ;Overworld spell, 30MP cost.
LD47A:  .word DoTrans           ;

;PSI.
LD47C:  .byte SPL_BATTLE, $23   ;Battle spell, 35MP cost.
LD47E:  .word DoPSI             ;

;Bright.
LD480:  .byte SPL_DUNGEON, $28  ;Dungeon spell, 40MP cost.
LD482:  .word DoBright          ;

;Cleric.
LD484:  .byte SPL_ALWAYS, $2D   ;Always useable spell, 45MP cost.
LD486:  .word DoCleric          ;

;Poison.
LD488:  .byte SPL_BATTLE, $32   ;Battle spell, 50MP cost.
LD48A:  .word DoPoison          ;

;Kill.
LD48C:  .byte SPL_BATTLE, $37   ;Battle spell, 55MP cost.
LD48E:  .word DoKill            ;

;Stop.
LD490:  .byte SPL_ALWAYS, $3C   ;Always useable spell, 60MP cost.
LD492:  .word DoStop            ;

;PSI Kill.
LD494:  .byte SPL_BATTLE, $41   ;Battle spell, 65MP cost.
LD496:  .word DoPSIKill         ;

;Rot.
LD498:  .byte SPL_BATTLE, $46   ;Battle spell, 70MP cost.
LD49A:  .word DoRot             ;

;Death.
LD49C:  .byte SPL_BATTLE, $4B   ;Battle spell, 75MP cost.
LD49E:  .word DoDeath           ;

;----------------------------------------------------------------------------------------------------

ClrcSpellTbl:

;Undead.
LD4A0:  .byte SPL_BATTLE, $00   ;Battle spell, 0MP cost.
LD4A2:  .word DoUndead          ;

;Open.
LD4A4:  .byte SPL_ALWAYS, $05   ;Always useable spell, 5MP cost.
LD4A6:  .word DoOpen            ;

;Heal.
LD4A8:  .byte SPL_ALWAYS, $0A   ;Always useable spell, 10MP cost.
LD4AA:  .word DoHeal            ;

;Glow.
LD4AC:  .byte SPL_DUNGEON, $0F  ;Dungeon spell, 15MP cost.
LD4AE:  .word DoGlow            ;

;Rise.
LD4B0:  .byte SPL_DUNGEON, $14  ;Dungeon spell, 20MP cost.
LD4B2:  .word DoRise            ;

;Sink.
LD4B4:  .byte SPL_DUNGEON, $19  ;Dungeon spell, 25MP cost.
LD4B6:  .word DoSink            ;

;Move.
LD4B8:  .byte SPL_DUNGEON, $1E  ;Dungeon spell, 30MP cost.
LD4BA:  .word DoMove            ;

;Cure.
LD4BC:  .byte SPL_ALWAYS, $23   ;Always useable spell, 35MP cost.
LD4BE:  .word DoCure            ;

;Surface.
LD4C0:  .byte SPL_DUNGEON, $28  ;Dungeon spell, 40MP cost.
LD4C2:  .word DoSurface         ;

;Star.
LD4C4:  .byte SPL_DUNGEON, $2D  ;Dungeon spell, 45MP cost.
LD4C6:  .word DoStar            ;

;Large Heal.
LD4C8:  .byte SPL_ALWAYS, $32   ;Always useable spell, 50MP cost.
LD4CA:  .word DoLargeHeal       ;

;Map.
LD4CC:  .byte SPL_ALWAYS, $37   ;Always useable spell, 55MP cost.
LD4CE:  .word DoMap             ;

;Banish.
LD4D0:  .byte SPL_BATTLE, $3C   ;Battle spell, 60MP cost.
LD4D2:  .word DoBanish          ;

;Raise.
LD4D4:  .byte SPL_ALWAYS, $41   ;Always useable spell, 65MP cost.
LD4D6:  .word DoRaise           ;

;Destroy.
LD4D8:  .byte SPL_BATTLE, $46   ;Battle spell, 70MP cost.
LD4DA:  .word DoDestroy         ;

;Recall
LD4DC:  .byte SPL_ALWAYS, $4B   ;Always useable spell, 75MP cost.
LD4DE:  .word DoRecall          ;

;----------------------------------------------------------------------------------------------------

DoRepel:
LD4E0:  LDA En1Type             ;Are the enemies orcs?
LD4E3:  BEQ ContinueRepel       ;If so, branch to do repel.

LD4E5:  CMP #EN_GOBLIN          ;Are the enemies goblins?
LD4E7:  BEQ ContinueRepel       ;If so, branch to do repel.

LD4E9:  LDX #$17                ;FAILED text.

RepelText:
LD4EB:  STX TextIndex           ;Display results of repel spell cast if missed/failed.
LD4ED:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.

LD4F0:  LDA #MAP_SAME           ;Indicate we are staying on the same map before exiting.
LD4F2:  RTS                     ;

ContinueRepel:
LD4F3:  LDX #$24                ;Prepare MISSED text if we miss.

LD4F5:  LDA Increment0          ;
LD4F7:  AND #$10                ;Repel will miss if bit 4 is clear. Changes every 16 frames.
LD4F9:  BEQ RepelText           ;

LD4FB:  LDA #$FF                ;Base damage of spell=255 points.
LD4FD:  PHA                     ;

LD4FE:  JSR GetBCDNum           ;($D3EC)Convert binary number to BCD.

LD501:  LDA #$0A                ;Wait 10 frames.
LD503:  JSR WaitSomeFrames      ;($E6D0)Wait some frames before continuing.

LD506:  LDA #SFX_SPELL_B+INIT   ;Start the whistling SFX.
LD508:  STA ThisSFX             ;

LD50A:  JSR Flash8              ;($DB36)Repeat screen flashing routine 8 times.

LD50D:  PLA
LD50E:  STA $2D

LD510:  LDA #$00                ;Start at the first enemy.
LD512:  STA EnCounter           ;

RepelLoop:
LD514:  LDA EnCounter           ;*2. 2 bytes per enemy.
LD516:  ASL                     ;

LD517:  TAX                     ;Does the current enemy exist?
LD518:  LDA EnHPBase,X          ;
LD51B:  BEQ RepelNext           ;If not, branch to check the next enemy.

LD51D:  LDA #100                ;Generate random number between 0-99, inclusive.
LD51F:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.

LD522:  CMP #75                 ;Is number <= 75(75% chance to hit)?
LD524:  BCS RepelNext           ;If not, missed. Branch to check repel on next enemy.

LD526:  LDA Increment0
LD528:  AND #$3F
LD52A:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.

LD52D:  CLC
LD52E:  ADC $2D
LD530:  BCC LD534

LD532:  LDA #$FF
LD534:  STA RngNum1

LD536:  LDA EnCounter
LD538:  PHA

LD539:  LDA $2D
LD53B:  PHA

LD53C:  JSR DoEnHit             ;($D1DC)Enemy hit. Init SFX and calculate damage.

LD53F:  PLA
LD540:  STA $2D

LD542:  PLA
LD543:  STA EnCounter

LD545:  BCS FinishRepel

RepelNext:
LD547:  INC EnCounter           ;Increment to next enemy.
LD549:  LDA EnCounter           ;
LD54B:  CMP #$08                ;Have all 8 enemies been checked?
LD54D:  BNE RepelLoop           ;If not, branch.

LD54F:  CLC                     ;Indicate the map should not be changed.

FinishRepel:
LD550:  LDA #GME_NORMAL         ;Indicate exodus is not dead and we are
LD552:  STA ExodusDead          ;staying on the same map before exiting.
LD554:  RTS                     ;

;----------------------------------------------------------------------------------------------------

DoMissile:
LD555:  LDX #$05
LD557:  LDA #$19

LD559:  PHA
LD55A:  TXA
LD55B:  PHA
LD55C:  JSR GetBCDNum           ;($D3EC)Convert binary number to BCD.
LD55F:  JSR LD26B
LD562:  BCC LD569
LD564:  PLA
LD565:  PLA
LD566:  LDA #$00
LD568:  RTS
LD569:  PLA
LD56A:  JSR CastSpell           ;($DA62)Update MP and flash screen.

LD56D:  LDA #$05                ;Wait 5 frames.
LD56F:  JSR WaitSomeFrames      ;($E6D0)Wait some frames before continuing.

LD572:  PLA
LD573:  STA $2E
LD575:  JSR LD303
LD578:  BCS LD595
LD57A:  STY $30
LD57C:  LDA $00
LD57E:  AND #$0F
LD580:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LD583:  CLC
LD584:  ADC $2E
LD586:  BCC LD58A
LD588:  LDA #$FF
LD58A:  STA RngNum1
LD58C:  JSR DoEnHit             ;($D1DC)Enemy hit. Init SFX and calculate damage.
LD58F:  LDA #$00
LD591:  STA $7302
LD594:  RTS
LD595:  LDA #$24
LD597:  JSR LD227
LD59A:  LDA #$00
LD59C:  STA $7302
LD59F:  RTS

DoLight:
LD5A0:  LDA #$0A
LD5A2:  JSR CastSpell           ;($DA62)Update MP and flash screen.
LD5A5:  LDA #$50
LD5A7:  STA $B1
LD5A9:  LDA #$1A
LD5AB:  JMP LD5AE
LD5AE:  JMP LD661

DoDescend:
LD5B1:  LDA #$0F
LD5B3:  JSR CastSpell           ;($DA62)Update MP and flash screen.
LD5B6:  LDA DungeonLevel
LD5B8:  CMP #$07
LD5BA:  BEQ LD5C8
LD5BC:  INC DungeonLevel
LD5BE:  INC MapDatPtrUB
LD5C0:  JSR LDB0E
LD5C3:  LDA #$1B
LD5C5:  JMP LD5CA
LD5C8:  LDA #$17
LD5CA:  STA TextIndex
LD5CC:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LD5CF:  LDA #$00
LD5D1:  RTS

DoAscend:
LD5D2:  LDA #$14
LD5D4:  JSR CastSpell           ;($DA62)Update MP and flash screen.
LD5D7:  LDA DungeonLevel
LD5D9:  BEQ LD5E7
LD5DB:  JSR LDB0E
LD5DE:  DEC DungeonLevel
LD5E0:  DEC MapDatPtrUB
LD5E2:  LDA #$1C
LD5E4:  JMP LD5EA
LD5E7:  JMP LD7E9
LD5EA:  STA TextIndex
LD5EC:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LD5EF:  LDA #$00
LD5F1:  RTS

DoFlame:
LD5F2:  LDX #$19
LD5F4:  LDA #$4B
LD5F6:  JMP LD559

DoTrans:
LD5F9:  LDA #$1E
LD5FB:  JSR CastSpell           ;($DA62)Update MP and flash screen.
LD5FE:  LDA $00
LD600:  AND #$3F
LD602:  STA MapXPos
LD604:  LDA $00
LD606:  LSR
LD607:  LSR
LD608:  STA MapYPos
LD60A:  LDA MapXPos
LD60C:  AND #$3F
LD60E:  STA $48
LD610:  LDA MapYPos
LD612:  AND #$3F
LD614:  STA $47
LD616:  JSR LF5B0
LD619:  LDX #$20
LD61B:  LDA ($43),Y
LD61D:  AND #$F0
LD61F:  BEQ LD63A
LD621:  INC $48
LD623:  LDA ($43),Y
LD625:  AND #$0F
LD627:  BEQ LD63A
LD629:  INC $48
LD62B:  INY
LD62C:  CPY #$20
LD62E:  BNE LD632
LD630:  LDY #$00
LD632:  DEX
LD633:  BNE LD61B
LD635:  INC MapYPos
LD637:  JMP LD60A
LD63A:  LDA $48
LD63C:  AND #$3F
LD63E:  STA MapXPos
LD640:  LDA $47
LD642:  AND #$3F
LD644:  STA MapYPos
LD646:  LDA #$01
LD648:  RTS

DoPSI:
LD649:  LDX #$23
LD64B:  LDY #CHR_INT
LD64D:  LDA (CrntChrPtr),Y
LD64F:  ASL
LD650:  JMP LD559

DoBright:
LD653:  LDA #$28
LD655:  JSR CastSpell           ;($DA62)Update MP and flash screen.
LD658:  LDA #$F0
LD65A:  STA $B1
LD65C:  LDA #$1A
LD65E:  JMP LD661
LD661:  PHA
LD662:  LDA #SFX_PLYR_MISS+INIT
LD664:  STA ThisSFX
LD666:  JSR LF981
LD669:  PLA
LD66A:  STA TextIndex
LD66C:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LD66F:  JSR GetDngnXYData       ;($F974)Get the dungeon data for character's current location.
LD672:  CMP #$09
LD674:  BNE LD690
LD676:  LDA #$01
LD678:  STA $B1
LD67A:  JSR LF981
LD67D:  LDA #$14
LD67F:  JSR WaitSomeFrames      ;($E6D0)Wait some frames before continuing.
LD682:  LDA #$00
LD684:  STA $B1
LD686:  JSR LF981
LD689:  LDA #$34
LD68B:  STA TextIndex
LD68D:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LD690:  LDA #$00
LD692:  RTS

DoCleric:
LD693:  LDA #$2D
LD695:  JSR CastSpell           ;($DA62)Update MP and flash screen.
LD698:  JMP LD378

DoPoison:
LD69B:  LDA #$32
LD69D:  JSR CastSpell           ;($DA62)Update MP and flash screen.
LD6A0:  LDA #$4B
LD6A2:  JMP LD4FD

DoKill:
LD6A5:  LDX #$37
LD6A7:  LDA #$FF
LD6A9:  JMP LD559

DoStop:
LD6AC:  LDA #$3C
LD6AE:  JSR CastSpell           ;($DA62)Update MP and flash screen.
LD6B1:  LDA #$14
LD6B3:  STA TimeStopTimer
LD6B5:  LDA #SFX_TIME_STOP+INIT
LD6B7:  STA ThisSFX
LD6B9:  LDA #$32
LD6BB:  STA TextIndex
LD6BD:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LD6C0:  LDA #$00
LD6C2:  RTS

DoPSIKill:
LD6C3:  LDA #$41
LD6C5:  JSR CastSpell           ;($DA62)Update MP and flash screen.
LD6C8:  LDY #CHR_INT
LD6CA:  LDA (CrntChrPtr),Y
LD6CC:  ASL
LD6CD:  JMP LD4FD

DoRot:
LD6D0:  LDA #$46
LD6D2:  JSR CastSpell           ;($DA62)Update MP and flash screen.
LD6D5:  JSR GetBCDNum           ;($D3EC)Convert binary number to BCD.
LD6D8:  LDA #$0A
LD6DA:  JSR WaitSomeFrames      ;($E6D0)Wait some frames before continuing.
LD6DD:  LDA #SFX_SPELL_B+INIT
LD6DF:  STA ThisSFX
LD6E1:  LDX #$00
LD6E3:  LDA #$04
LD6E5:  STA $30
LD6E7:  LDA EnHPBase,X
LD6EA:  BEQ LD71A
LD6EC:  JSR LD215
LD6EF:  LDA #$05
LD6F1:  STA $2E
LD6F3:  SEC
LD6F4:  LDA EnHPBase,X
LD6F7:  SBC $2E
LD6F9:  BCS LD702
LD6FB:  LDA EnHPBase,X
LD6FE:  STA $2E
LD700:  LDA #$00
LD702:  STA $A0
LD704:  LDA #$00
LD706:  STA $A1
LD708:  LDA $2E
LD70A:  STA EnHPBase,X
LD70D:  LDA #$28
LD70F:  STA $2A
LD711:  LDA $30
LD713:  PHA
LD714:  JSR LD225
LD717:  PLA
LD718:  STA $30
LD71A:  INC $30
LD71C:  LDA $30
LD71E:  SEC
LD71F:  SBC #$04
LD721:  ASL
LD722:  TAX
LD723:  CPX #$10
LD725:  BNE LD6E7
LD727:  LDA #$00
LD729:  CLC
LD72A:  RTS

DoDeath:
LD72B:  LDA #GME_EX_DEAD
LD72D:  STA ExodusDead
LD72F:  LDA #$4B
LD731:  JSR CastSpell           ;($DA62)Update MP and flash screen.
LD734:  LDA #$FF
LD736:  JMP LD4FD

DoUndead:
LD739:  LDA En1Type
LD73C:  CMP #EN_SKELETON
LD73E:  BEQ LD74E

LD740:  CMP #EN_GHOUL
LD742:  BEQ LD74E

LD744:  LDX #$17
LD746:  STX TextIndex
LD748:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LD74B:  LDA #$00
LD74D:  RTS
LD74E:  LDX #$24
LD750:  LDA $00
LD752:  AND #$10
LD754:  BEQ LD746
LD756:  LDA #$FF
LD758:  JMP LD4FD

DoOpen:
LD75B:  LDA #$05
LD75D:  JSR CastSpell           ;($DA62)Update MP and flash screen.
LD760:  LDA $00
LD762:  AND #$05
LD764:  BEQ LD779
LD766:  JSR LDD9B
LD769:  BCS LD776
LD76B:  LDA #$01
LD76D:  STA $DF
LD76F:  JSR LDDDB
LD772:  LDA #$00
LD774:  STA $DF
LD776:  LDA #$00
LD778:  RTS
LD779:  LDA #$F6
LD77B:  STA TextIndex
LD77D:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LD780:  JMP LD776

DoHeal:
LD783:  LDA #$0A
LD785:  JSR LDA2B
LD788:  BCS LD797
LD78A:  LDA #$1E
LD78C:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LD78F:  CLC
LD790:  ADC #$14
LD792:  STA $30
LD794:  JSR LDAC0
LD797:  LDA #$00
LD799:  RTS

DoGlow:
LD79A:  LDA #$05
LD79C:  JSR CastSpell           ;($DA62)Update MP and flash screen.
LD79F:  JMP DoLight             ;($D5A0)Light dungeon.

DoRise:
LD7A2:  JMP DoAscend            ;($D5D2)Ascend in dungeon.

DoSink:
LD7A5:  LDA #$0A
LD7A7:  JSR CastSpell           ;($DA62)Update MP and flash screen.
LD7AA:  JMP DoDescend           ;($D5B1)Descend in dungeon.

DoMove:
LD7AD:  LDA #$1E
LD7AF:  JSR CastSpell           ;($DA62)Update MP and flash screen.
LD7B2:  JSR LDB0E
LD7B5:  LDA #$1E
LD7B7:  STA TextIndex
LD7B9:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LD7BC:  LDA #$00
LD7BE:  RTS

DoCure:
LD7BF:  LDA #$23
LD7C1:  JSR LDA2B
LD7C4:  BCS LD7DC
LD7C6:  LDY #CHR_COND
LD7C8:  LDA (CrntChrPtr),Y
LD7CA:  TAX
LD7CB:  CMP #$02
LD7CD:  BCS LD7D3
LD7CF:  LDA #$00
LD7D1:  STA (CrntChrPtr),Y
LD7D3:  TXA
LD7D4:  LDA $D7DF,X
LD7D7:  STA TextIndex
LD7D9:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LD7DC:  LDA #$00
LD7DE:  RTS

LD7DF:  .byte $17, $42, $17, $43, $44

DoSurface:
LD7E4:  LDA #$28
LD7E6:  JSR CastSpell           ;($DA62)Update MP and flash screen.
LD7E9:  LDA #$1F
LD7EB:  STA TextIndex
LD7ED:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LD7F0:  LDA #$00
LD7F2:  STA CurPPUConfig1
LD7F4:  STA PPUControl1
LD7F7:  STA ThisMap
LD7F9:  LDA #$00
LD7FB:  RTS

DoStar:
LD7FC:  LDA #$05
LD7FE:  JSR CastSpell           ;($DA62)Update MP and flash screen.
LD801:  JMP DoBright            ;($D653)Light a dungeon for a longer period of time.

DoLargeHeal:
LD804:  LDA #$32
LD806:  JSR LDA2B
LD809:  BCS LD818
LD80B:  LDA #$96
LD80D:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LD810:  CLC
LD811:  ADC #$64
LD813:  STA $30
LD815:  JSR LDAC0
LD818:  LDA #$00
LD81A:  RTS

DoMap:
LD81B:  LDA #$37
LD81D:  JSR CastSpell           ;($DA62)Update MP and flash screen.
LD820:  LDA MapProperties
LD822:  AND #MAP_DUNGEON
LD824:  BNE LD838
LD826:  LDA ThisMap
LD828:  BEQ LD853
LD82A:  CMP #MAP_AMBROSIA
LD82C:  BEQ LD853
LD82E:  LDA #$17
LD830:  STA TextIndex
LD832:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LD835:  LDA #$00
LD837:  RTS

LD838:  LDA #$20                ;VIEW THE MAP text.
LD83A:  STA TextIndex           ;
LD83C:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.

LD83F:  LDA #SFX_MAP+INIT
LD841:  STA ThisSFX

LD843:  LDA DisNPCMovement
LD845:  ORA #$40
LD847:  STA DisNPCMovement
LD849:  LDA #$00
LD84B:  STA CurPPUConfig1
LD84D:  STA PPUControl1
LD850:  LDA #$00
LD852:  RTS

LD853:  LDA #$20                ;VIEW THE MAP text.
LD855:  STA TextIndex           ;
LD857:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.

LD85A:  LDA #SFX_MAP+INIT
LD85C:  STA ThisSFX

LD85E:  LDA #BANK_GEM
LD860:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LD863:  LDA DisNPCMovement
LD865:  PHA
LD866:  LDA #DISABLE
LD868:  STA DisNPCMovement
LD86A:  LDA #$00
LD86C:  STA CurPPUConfig1
LD86E:  STA PPUControl1
LD871:  JSR ResetNameTableF1    ;($FBDC)Reset nametable offsets and select nametable 0.
LD874:  LDA #$04
LD876:  STA $0600
LD879:  LDX #$9F
LD87B:  LDY #$00
LD87D:  LDA ThisMap
LD87F:  BEQ LD88A
LD881:  LDA #$27
LD883:  STA $0600
LD886:  LDX #$AF
LD888:  LDY #$00
LD88A:  STX $2A
LD88C:  STY $29
LD88E:  LDA $01
LD890:  STA TimeStopTimer
LD892:  LDA #$10
LD894:  STA $2C
LD896:  LDA #$00
LD898:  STA $2B
LD89A:  LDA #$10
LD89C:  STA $2E
LD89E:  LDA #$00
LD8A0:  STA $2D
LD8A2:  JSR LoadPPU             ;($EFE3)Load values into PPU.
LD8A5:  LDX #$00
LD8A7:  LDY #$40
LD8A9:  JSR LC705
LD8AC:  LDX #$00
LD8AE:  LDA $0600
LD8B1:  STA ScreenBlocks,X
LD8B4:  INX
LD8B5:  BNE LD8AE
LD8B7:  LDA #$07
LD8B9:  STA $2A
LD8BB:  LDA #$00
LD8BD:  STA $29
LD8BF:  LDA #$20
LD8C1:  STA $2C
LD8C3:  LDA #$00
LD8C5:  STA $2B
LD8C7:  LDA #$01
LD8C9:  STA $2E
LD8CB:  LDA #$00
LD8CD:  STA $2D
LD8CF:  JSR LoadPPU             ;($EFE3)Load values into PPU.
LD8D2:  LDA #$00
LD8D4:  STA $30
LD8D6:  JSR LD92B
LD8D9:  INC $2C
LD8DB:  JSR LoadPPU             ;($EFE3)Load values into PPU.
LD8DE:  LDA #$80
LD8E0:  STA $30
LD8E2:  JSR LD92B
LD8E5:  INC $2C
LD8E7:  JSR LoadPPU             ;($EFE3)Load values into PPU.
LD8EA:  LDX #$00
LD8EC:  LDA $0600
LD8EF:  STA ScreenBlocks,X
LD8F2:  INX
LD8F3:  BNE LD8EC
LD8F5:  INC $2C
LD8F7:  JSR LoadPPU             ;($EFE3)Load values into PPU.
LD8FA:  LDA #$FF
LD8FC:  STA $2A
LD8FE:  LDA #$D0
LD900:  STA $29
LD902:  JSR LED33
LD905:  LDA MapYPos
LD907:  ASL
LD908:  CLC
LD909:  ADC #$3C
LD90B:  STA $7300
LD90E:  LDA MapXPos
LD910:  ASL
LD911:  CLC
LD912:  ADC #$3C
LD914:  STA $7303
LD917:  LDA #$1E
LD919:  STA CurPPUConfig1
LD91B:  LDA #$FF
LD91D:  STA $9B
LD91F:  JSR LE6D8
LD922:  PLA
LD923:  STA DisNPCMovement
LD925:  JSR LoadAlphaNumMaps    ;($ED76)Load character set and map tiles.
LD928:  LDA #$01
LD92A:  RTS
LD92B:  LDX #$00
LD92D:  LDA $0600
LD930:  STA ScreenBlocks,X
LD933:  INX
LD934:  TXA
LD935:  AND #$1F
LD937:  CMP #$08
LD939:  BNE LD92D
LD93B:  LDA $30
LD93D:  STA ScreenBlocks,X
LD940:  INC $30
LD942:  INX
LD943:  TXA
LD944:  AND #$1F
LD946:  CMP #$18
LD948:  BNE LD93B
LD94A:  LDA $0600
LD94D:  STA ScreenBlocks,X
LD950:  INX
LD951:  TXA
LD952:  AND #$1F
LD954:  BNE LD94A
LD956:  TXA
LD957:  BNE LD92D
LD959:  RTS

DoBanish:
LD95A:  LDX #$3C
LD95C:  LDA #$FF
LD95E:  JMP LD559

DoRaise:
LD961:  LDA #CHR_NO_CHK_DEAD
LD963:  STA ChkCharDead
LD965:  LDA #$41
LD967:  JSR LDA2B
LD96A:  LDA #CHR_CHK_DEAD
LD96C:  STA ChkCharDead
LD96E:  BCS LD9A8
LD970:  LDY #CHR_COND
LD972:  LDA (CrntChrPtr),Y
LD974:  TAX
LD975:  CMP #$03
LD977:  BNE LD9A0
LD979:  LDA #$64
LD97B:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LD97E:  LDX #$05
LD980:  CMP #$4B
LD982:  BCS LD99C
LD984:  LDA #$00
LD986:  STA (CrntChrPtr),Y
LD988:  LDY #CHR_HIT_PNTS
LD98A:  LDA #$96
LD98C:  STA (CrntChrPtr),Y
LD98E:  LDY #CHR_MAG_PNTS
LD990:  LDA #$00
LD992:  STA (CrntChrPtr),Y
LD994:  JSR LEF13
LD997:  LDX #$03
LD999:  JMP LD9A0
LD99C:  LDA #$04
LD99E:  STA (CrntChrPtr),Y
LD9A0:  LDA $D9AB,X
LD9A3:  STA TextIndex
LD9A5:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LD9A8:  LDA #$00
LD9AA:  RTS

LD9AB:  .byte $17, $17, $17, $46, $17, $47   

DoDestroy:
LD9B1:  LDA #GME_EX_DEAD
LD9B3:  STA ExodusDead
LD9B5:  LDA #$46
LD9B7:  JSR CastSpell           ;($DA62)Update MP and flash screen.
LD9BA:  LDA #$FF
LD9BC:  JMP LD4FD

DoRecall:
LD9BF:  LDA #CHR_NO_CHK_DEAD
LD9C1:  STA ChkCharDead
LD9C3:  LDA #$4B
LD9C5:  JSR LDA2B
LD9C8:  LDA #CHR_CHK_DEAD
LD9CA:  STA ChkCharDead
LD9CC:  BCS LDA28
LD9CE:  LDY #$0A
LD9D0:  LDA ($29),Y
LD9D2:  SEC
LD9D3:  SBC #$05
LD9D5:  STA ($29),Y
LD9D7:  LDY #CHR_COND
LD9D9:  LDA (CrntChrPtr),Y
LD9DB:  LDX #$17
LD9DD:  CMP #$04
LD9DF:  BNE LDA23
LD9E1:  LDA #$00
LD9E3:  STA (CrntChrPtr),Y
LD9E5:  LDY #CHR_HIT_PNTS
LD9E7:  LDA #$96
LD9E9:  STA (CrntChrPtr),Y
LD9EB:  LDY #CHR_FOOD
LD9ED:  LDA #$00
LD9EF:  STA (CrntChrPtr),Y
LD9F1:  INY
LD9F2:  STA (CrntChrPtr),Y
LD9F4:  LDY #CHR_MAG_PNTS
LD9F6:  STA (CrntChrPtr),Y
LD9F8:  LDY #CHR_ITEMS
LD9FA:  STA (CrntChrPtr),Y
LD9FC:  INY
LD9FD:  CPY #$2B
LD9FF:  BNE LD9FA
LDA01:  LDY #CHR_WEAPONS
LDA03:  STA (CrntChrPtr),Y
LDA05:  INY
LDA06:  CPY #$1B
LDA08:  BNE LDA03
LDA0A:  LDY #CHR_ARMOR
LDA0C:  STA (CrntChrPtr),Y
LDA0E:  INY
LDA0F:  CPY #$22
LDA11:  BNE LDA0C
LDA13:  LDY #CHR_EQ_WEAPON
LDA15:  STA (CrntChrPtr),Y
LDA17:  LDY #CHR_EQ_ARMOR
LDA19:  STA (CrntChrPtr),Y
LDA1B:  JSR LEF13
LDA1E:  LDX #$45
LDA20:  JMP LDA23
LDA23:  STX TextIndex
LDA25:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LDA28:  LDA #$00
LDA2A:  RTS

LDA2B:  PHA
LDA2C:  LDA CrntChrPtrLB
LDA2E:  PHA
LDA2F:  LDA CrntChrPtrUB
LDA31:  PHA
LDA32:  JSR LE49E
LDA35:  BCS LDA5D
LDA37:  LDA CrntChrPtrLB
LDA39:  STA $2B
LDA3B:  LDA CrntChrPtrUB
LDA3D:  STA $2C
LDA3F:  PLA
LDA40:  STA CrntChrPtrUB
LDA42:  STA $2A
LDA44:  PLA
LDA45:  STA CrntChrPtrLB
LDA47:  STA $29
LDA49:  PLA
LDA4A:  TAX
LDA4B:  LDA $2B
LDA4D:  PHA
LDA4E:  LDA $2C
LDA50:  PHA
LDA51:  TXA
LDA52:  JSR CastSpell           ;($DA62)Update MP and flash screen.
LDA55:  PLA
LDA56:  STA CrntChrPtrUB
LDA58:  PLA
LDA59:  STA CrntChrPtrLB
LDA5B:  CLC
LDA5C:  RTS
LDA5D:  PLA
LDA5E:  PLA
LDA5F:  PLA
LDA60:  SEC
LDA61:  RTS

;----------------------------------------------------------------------------------------------------

CastSpell:
LDA62:  STA $30
LDA64:  LDY #CHR_MAG_PNTS
LDA66:  LDA (CrntChrPtr),Y
LDA68:  SEC
LDA69:  SBC $30
LDA6B:  STA (CrntChrPtr),Y
LDA6D:  LDA #SFX_SPELL_A+INIT
LDA6F:  STA ThisSFX

LDA71:  LDA $30
LDA73:  PHA
LDA74:  LDA $19
LDA76:  PHA
LDA77:  LDA $18
LDA79:  PHA
LDA7A:  LDA MapProperties
LDA7C:  AND #MAP_DUNGEON
LDA7E:  BNE LDA83

LDA80:  JSR BinToBCD            ;($F4D1)Convert binary number to BCD.

LDA83:  PLA
LDA84:  STA $18
LDA86:  PLA
LDA87:  STA $19
LDA89:  PLA
LDA8A:  LSR
LDA8B:  LSR
LDA8C:  CLC
LDA8D:  ADC #$01
LDA8F:  JSR FlashScreen         ;($DB38)Flash screen a given number of times.
LDA92:  RTS

;----------------------------------------------------------------------------------------------------

LDA93:  STA $30
LDA95:  STA $A0
LDA97:  LDY #CHR_HIT_PNTS
LDA99:  LDA (CrntChrPtr),Y
LDA9B:  SEC
LDA9C:  SBC $30
LDA9E:  STA (CrntChrPtr),Y
LDAA0:  INY
LDAA1:  LDA (CrntChrPtr),Y
LDAA3:  SBC #$00
LDAA5:  STA (CrntChrPtr),Y
LDAA7:  BCS LDABB
LDAA9:  LDA #$00
LDAAB:  STA (CrntChrPtr),Y
LDAAD:  DEY
LDAAE:  STA (CrntChrPtr),Y
LDAB0:  LDY #CHR_COND
LDAB2:  LDA #$03
LDAB4:  STA (CrntChrPtr),Y
LDAB6:  LDA #$29
LDAB8:  JMP LDABD

LDABB:  LDA #$2D
LDABD:  JMP LDC23
LDAC0:  STA $30
LDAC2:  LDY #CHR_HIT_PNTS
LDAC4:  LDA (CrntChrPtr),Y
LDAC6:  CLC
LDAC7:  ADC $30
LDAC9:  STA $2D
LDACB:  INY
LDACC:  LDA (CrntChrPtr),Y
LDACE:  ADC #$00
LDAD0:  STA $2E
LDAD2:  LDY #CHR_MAX_HP+1
LDAD4:  CMP (CrntChrPtr),Y
LDAD6:  BCC LDAEC
LDAD8:  BNE LDAE1
LDADA:  LDA $2D
LDADC:  DEY
LDADD:  CMP (CrntChrPtr),Y
LDADF:  BCC LDAEC
LDAE1:  LDY #CHR_MAX_HP
LDAE3:  LDA (CrntChrPtr),Y
LDAE5:  STA $2D
LDAE7:  INY
LDAE8:  LDA (CrntChrPtr),Y
LDAEA:  STA $2E
LDAEC:  LDY #CHR_HIT_PNTS
LDAEE:  LDA $2D
LDAF0:  SEC
LDAF1:  SBC (CrntChrPtr),Y
LDAF3:  STA $A0
LDAF5:  LDA $2D
LDAF7:  STA (CrntChrPtr),Y
LDAF9:  INY
LDAFA:  LDA $2E
LDAFC:  STA (CrntChrPtr),Y
LDAFE:  LDA #$00
LDB00:  STA $A1
LDB02:  LDA CurPPUConfig1
LDB04:  BEQ LDB0D
LDB06:  LDA #$5A
LDB08:  STA TextIndex
LDB0A:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LDB0D:  RTS
LDB0E:  LDY $00
LDB10:  LDA (MapDatPtr),Y
LDB12:  CMP #$0D
LDB14:  BEQ LDB1A
LDB16:  INY
LDB17:  JMP LDB10
LDB1A:  TYA
LDB1B:  AND #$0F
LDB1D:  STA MapXPos
LDB1F:  TYA
LDB20:  LSR
LDB21:  LSR
LDB22:  LSR
LDB23:  LSR
LDB24:  STA MapYPos
LDB26:  LDA #$80
LDB28:  ORA DisNPCMovement
LDB2A:  STA DisNPCMovement
LDB2C:  RTS

;----------------------------------------------------------------------------------------------------

FlashAndSound:
LDB2D:  STA FlashCounter        ;
LDB2F:  LDA #SFX_MN_GATE_A+INIT ;Start the moongate enter SFX.
LDB31:  STA ThisSFX             ;
LDB33:  JMP FlashLoop           ;($DB3A)Flash the screen.

Flash8:
LDB36:  LDA #$08                ;Repeat flash routine 8 times.

FlashScreen:
LDB38:  STA FlashCounter        ;Prepare to flash screen a given number of times.

FlashLoop:
LDB3A:  LDA #>FlashPal          ;
LDB3C:  STA PPUSrcPtrUB         ;Load the screen flashing palette.
LDB3E:  LDA #<FlashPal          ;
LDB40:  STA PPUSrcPtrLB         ;
LDB42:  JSR LoadPPUPalData      ;($ED3F)Load palette data into the PPU.

LDB45:  LDA #$02                ;Wait for 2 frames.
LDB47:  JSR WaitSomeFrames      ;($E6D0)Wait some frames before continuing.

LDB4A:  LDA #>BkPalBuffer       ;
LDB4C:  STA PPUSrcPtrUB         ;Reload the normal background and sprite palettes.
LDB4E:  LDA #<BkPalBuffer       ;
LDB50:  STA PPUSrcPtrLB         ;
LDB52:  JSR LoadPPUPalData      ;($ED3F)Load palette data into the PPU.

LDB55:  LDA #$02                ;Wait for 2 frames.
LDB57:  JSR WaitSomeFrames      ;($E6D0)Wait some frames before continuing.

LDB5A:  DEC FlashCounter        ;Has the screen finished flashing?
LDB5C:  BNE FlashLoop           ;
LDB5E:  RTS                     ;If not, branch to run the flash sequence again.

;----------------------------------------------------------------------------------------------------

LDB5F:  JSR LE602
LDB62:  BCS LDB67
LDB64:  JSR LDB7E
LDB67:  JSR BinToBCD            ;($F4D1)Convert binary number to BCD.
LDB6A:  RTS

;----------------------------------------------------------------------------------------------------

DoToolsCmd:
LDB6B:  JSR ChooseChar          ;($E42F)Select a character from a list.
LDB6E:  BCS LDB7B
LDB70:  JSR LE602
LDB73:  BCS LDB7B
LDB75:  JSR LDB7E
LDB78:  JSR BinToBCD            ;($F4D1)Convert binary number to BCD.
LDB7B:  JMP LD3E6

LDB7E:  PHA
LDB7F:  CLC
LDB80:  ADC #$20
LDB82:  JSR LDD6E
LDB85:  PLA
LDB86:  BCS LDBAC
LDB88:  PHA
LDB89:  TAY
LDB8A:  LDA $DBC3,Y
LDB8D:  STA $2A
LDB8F:  PLA
LDB90:  PHA
LDB91:  CLC
LDB92:  ADC #$22
LDB94:  TAY
LDB95:  LDA (CrntChrPtr),Y
LDB97:  CLC
LDB98:  ADC $2A
LDB9A:  STA (CrntChrPtr),Y
LDB9C:  PLA
LDB9D:  ASL
LDB9E:  TAX
LDB9F:  LDA UseItmFuncTbl,X
LDBA2:  STA IndJumpPtrLB
LDBA4:  LDA UseItmFuncTbl+1,X
LDBA7:  STA IndJumpPtrUB
LDBA9:  JMP (IndJumpPtr)

LDBAC:  LDA #$F5
LDBAE:  JMP LDC23

UseItmFuncTbl:
LDBB1:  .word UseTorch, UseKey, UseGem, UsePowder, UseTent, UseGldPick, UseSlvrPick, PlayHorn
LDBC1:  .word UseCompass

LDBC2:  .byte $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $FF

UseTent:
LDBCC:  JSR LFD2D
LDBCF:  LDA #$1E
LDBD1:  JSR WaitSomeFrames      ;($E6D0)Wait some frames before continuing.
LDBD4:  LDA #$31
LDBD6:  STA $30
LDBD8:  JSR LE66D
LDBDB:  LDA #$B4
LDBDD:  JSR WaitSomeFrames      ;($E6D0)Wait some frames before continuing.
LDBE0:  LDA #$00
LDBE2:  STA CurPPUConfig1
LDBE4:  LDX #$00
LDBE6:  LDA ChrPtrBaseLB,X
LDBE8:  STA CrntChrPtrLB
LDBEA:  LDA ChrPtrBaseUB,X
LDBEC:  STA CrntChrPtrUB
LDBEE:  TXA
LDBEF:  PHA
LDBF0:  LDY #CHR_COND
LDBF2:  LDA (CrntChrPtr),Y
LDBF4:  CMP #$03
LDBF6:  BCS LDBFD
LDBF8:  LDA #$64
LDBFA:  JSR LDAC0
LDBFD:  PLA
LDBFE:  TAX
LDBFF:  INX
LDC00:  INX
LDC01:  CPX #$08
LDC03:  BNE LDBE6
LDC05:  LDA #$1E
LDC07:  STA CurPPUConfig1
LDC09:  JSR LFD52
LDC0C:  RTS

UseTorch:
LDC0D:  JMP LD658

UsePowder:
LDC10:  LDA ThisMap
LDC12:  CMP #MAP_EXODUS
LDC14:  BNE LDC19
LDC16:  JMP LDBAC
LDC19:  LDA #SFX_TIME_STOP+INIT
LDC1B:  STA ThisSFX
LDC1D:  LDA #$0A
LDC1F:  STA TimeStopTimer
LDC21:  LDA #$32
LDC23:  STA TextIndex
LDC25:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LDC28:  RTS

UseKey:
LDC29:  LDA MapProperties
LDC2B:  AND #$07
LDC2D:  BNE LDC86
LDC2F:  JSR GetFrontBlock       ;($E739)Get the block in front of character 1.
LDC32:  AND #$1F
LDC34:  CMP #$05
LDC36:  BNE LDC86
LDC38:  LDA #$8B
LDC3A:  STA ScreenBlocks,Y
LDC3D:  LDA $19
LDC3F:  LDX #$00
LDC41:  CMP #$70
LDC43:  BEQ LDC4A
LDC45:  INX
LDC46:  BCS LDC4A
LDC48:  LDX #$FF
LDC4A:  TXA
LDC4B:  CLC
LDC4C:  ADC MapXPos
LDC4E:  STA $48
LDC50:  LDA $18
LDC52:  LDX #$00
LDC54:  CMP #$70
LDC56:  BEQ LDC5D
LDC58:  INX
LDC59:  BCS LDC5D
LDC5B:  LDX #$FF
LDC5D:  TXA
LDC5E:  CLC
LDC5F:  ADC MapYPos
LDC61:  STA $47
LDC63:  JSR LF5B0
LDC66:  LDA $48
LDC68:  AND #$01
LDC6A:  BNE LDC75
LDC6C:  LDA ($43),Y
LDC6E:  AND #$0F
LDC70:  ORA #$B0
LDC72:  JMP LDC7B
LDC75:  LDA ($43),Y
LDC77:  AND #$F0
LDC79:  ORA #$0B
LDC7B:  STA ($43),Y
LDC7D:  LDA #SFX_OPEN_DOOR+INIT
LDC7F:  STA ThisSFX
LDC81:  LDA #$3E
LDC83:  JMP LDC23
LDC86:  LDY #$23
LDC88:  LDA (CrntChrPtr),Y
LDC8A:  CLC
LDC8B:  ADC #$01
LDC8D:  STA (CrntChrPtr),Y
LDC8F:  LDA #$0F
LDC91:  JMP LDC23

UseGem:
LDC94:  LDA #$A8
LDC96:  AND #$02
LDC98:  BNE LDC86
LDC9A:  JSR LD820
LDC9D:  CMP #$00
LDC9F:  BEQ LDCA6
LDCA1:  PLA
LDCA2:  PLA
LDCA3:  JMP LoadNewMap          ;($C175)Load a new map.
LDCA6:  RTS

UseCompass:
LDCA7:  LDA #$D3
LDCA9:  STA TextIndex
LDCAB:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LDCAE:  LDA #MAP_PROP_OV
LDCB0:  STA MapProperties
LDCB2:  LDA #MAP_OVERWORLD
LDCB4:  STA ThisMap
LDCB6:  STA DisNPCMovement
LDCB8:  LDA #$2D
LDCBA:  STA ReturnXPos
LDCBC:  LDA #$13
LDCBE:  STA ReturnYPos
LDCC0:  LDA OnBoat
LDCC2:  BEQ LDCD4
LDCC4:  LDA #$00
LDCC6:  STA OnBoat
LDCC8:  LDA #$2F
LDCCA:  STA BoatXPos
LDCCD:  STA $D8
LDCCF:  LDA #$11
LDCD1:  STA BoatYPos
LDCD4:  PLA
LDCD5:  PLA
LDCD6:  JMP PrepLoadMap         ;($C146)Prepare to load a new map.

UseGldPick:
LDCD9:  LDA MapProperties
LDCDB:  CMP #MAP_PROP_OV
LDCDD:  BNE LDCF6
LDCDF:  LDA MapXPos
LDCE1:  CMP #$13
LDCE3:  BNE LDCF6
LDCE5:  LDA MapYPos
LDCE7:  CMP #$2C
LDCE9:  BNE LDCF6
LDCEB:  LDY #$21
LDCED:  LDA #$01
LDCEF:  STA (CrntChrPtr),Y
LDCF1:  LDA #$5E
LDCF3:  JMP LDC23
LDCF6:  LDA #$60
LDCF8:  JMP LDCF3

UseSlvrPick:
LDCFB:  LDA MapProperties
LDCFD:  CMP #MAP_PROP_OV
LDCFF:  BNE LDD18
LDD01:  LDA MapXPos
LDD03:  CMP #$21
LDD05:  BNE LDD18
LDD07:  LDA MapYPos
LDD09:  CMP #$03
LDD0B:  BNE LDD18
LDD0D:  LDY #$1A
LDD0F:  LDA #$01
LDD11:  STA (CrntChrPtr),Y
LDD13:  LDA #$5D
LDD15:  JMP LDC23
LDD18:  LDA #$5F
LDD1A:  JMP LDD15

PlayHorn:
LDD1D:  LDA #MUS_HORN+INIT
LDD1F:  STA InitNewMusic
LDD21:  LDA #$FF
LDD23:  JSR WaitSomeFrames      ;($E6D0)Wait some frames before continuing.
LDD26:  LDA MapProperties
LDD28:  CMP #MAP_PROP_OV
LDD2A:  BNE LDD66
LDD2C:  LDY #CHR_MARKS
LDD2E:  LDA (CrntChrPtr),Y
LDD30:  AND #$04
LDD32:  BEQ LDD66
LDD34:  LDA MapXPos
LDD36:  CMP #$0A
LDD38:  BNE LDD66
LDD3A:  LDA MapYPos
LDD3C:  CMP #$3B
LDD3E:  BEQ LDD44
LDD40:  CMP #$38
LDD42:  BNE LDD66
LDD44:  LDA $7F25
LDD47:  CMP #$34
LDD49:  BEQ LDD66
LDD4B:  LDA #$F8
LDD4D:  STA $30
LDD4F:  JSR LE66D
LDD52:  LDA #$B4
LDD54:  JSR WaitSomeFrames      ;($E6D0)Wait some frames before continuing.
LDD57:  LDA #$34
LDD59:  STA $7F25
LDD5C:  LDA #$30
LDD5E:  STA $7F45
LDD61:  PLA
LDD62:  PLA
LDD63:  JMP LoadNewMap          ;($C175)Load a new map.
LDD66:  JSR StartMusic          ;($FD6C)Determine which music to start playing.
LDD69:  LDA #$5C
LDD6B:  JMP LDC23
LDD6E:  STA $30
LDD70:  LDA CurPRGBank
LDD72:  PHA
LDD73:  LDA #BANK_HELPERS1
LDD75:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LDD78:  LDA $30
LDD7A:  JSR $AF00
LDD7D:  PLA
LDD7E:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LDD81:  RTS

;----------------------------------------------------------------------------------------------------

DoGetCmd:
LDD82:  JSR LDD9B
LDD85:  BCC LDD8A
LDD87:  JMP LDD95
LDD8A:  JSR ChooseChar          ;($E42F)Select a character from a list.
LDD8D:  BCC LDD92
LDD8F:  JMP LD3E6
LDD92:  JSR LDDDB
LDD95:  JSR BinToBCD            ;($F4D1)Convert binary number to BCD.
LDD98:  JMP FinishCommand       ;($C293)Post-command cleanup and run the game engine loop.

LDD9B:  LDA MapProperties
LDD9D:  AND #MAP_DUNGEON
LDD9F:  BEQ LDDAA

LDDA1:  JSR GetDngnXYData       ;($F974)Get the dungeon data for character's current location.
LDDA4:  CMP #$0B
LDDA6:  BEQ LDDD9
LDDA8:  BNE LDDD0
LDDAA:  LDA #$00
LDDAC:  STA NumMenuItems
LDDAE:  STA $9D
LDDB0:  LDA CharBlock
LDDB3:  AND #$1F
LDDB5:  CMP #BLK_CHEST
LDDB7:  BEQ LDDD9
LDDB9:  LDA ThisMap
LDDBB:  CMP #MAP_AMBROSIA
LDDBD:  BNE LDDCB
LDDBF:  LDA CharBlock
LDDC2:  AND #$1F
LDDC4:  CMP #BLK_FLOWER
LDDC6:  BNE LDDCB
LDDC8:  JMP LDEB5
LDDCB:  JSR LDECF
LDDCE:  BCC LDDD9
LDDD0:  LDA #$0F
LDDD2:  STA TextIndex
LDDD4:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LDDD7:  SEC
LDDD8:  RTS
LDDD9:  CLC
LDDDA:  RTS
LDDDB:  LDA #SFX_CHST_OPEN+INIT
LDDDD:  STA ThisSFX
LDDDF:  LDA MapProperties
LDDE1:  CMP #MAP_NPC_PRES
LDDE3:  BNE LDE27
LDDE5:  LDA $E2
LDDE7:  PHA
LDDE8:  JSR LF667
LDDEB:  PLA
LDDEC:  CMP $E2
LDDEE:  BEQ LDDF7
LDDF0:  LDA #$F7
LDDF2:  STA TextIndex
LDDF4:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LDDF7:  LDA ThisMap
LDDF9:  CMP #MAP_DAWN
LDDFB:  BNE LDE27
LDDFD:  LDA MapXPos
LDDFF:  CMP #$20
LDE01:  BNE LDE27
LDE03:  LDA MapYPos
LDE05:  CMP #$15
LDE07:  BNE LDE27
LDE09:  LDA NumMenuItems
LDE0B:  BEQ LDE27
LDE0D:  LDY #$27
LDE0F:  LDA (Pos1ChrPtr),Y
LDE11:  ORA (Pos2ChrPtr),Y
LDE13:  ORA (Pos3ChrPtr),Y
LDE15:  ORA (Pos4ChrPtr),Y
LDE17:  BNE LDE27
LDE19:  LDX #$D5
LDE1B:  LDA #$01
LDE1D:  STA (CrntChrPtr),Y
LDE1F:  STX TextIndex
LDE21:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LDE24:  JMP LE00C
LDE27:  LDA MapProperties
LDE29:  AND #MAP_DUNGEON
LDE2B:  BEQ LDE56
LDE2D:  LDA ThisMap
LDE2F:  CMP #MAP_CV_DEATH
LDE31:  BNE LDE56
LDE33:  LDA DungeonLevel
LDE35:  CMP #$07
LDE37:  BNE LDE56
LDE39:  LDA MapXPos
LDE3B:  CMP #$01
LDE3D:  BNE LDE56
LDE3F:  LDA MapYPos
LDE41:  CMP #$0F
LDE43:  BNE LDE56
LDE45:  LDX #$D4
LDE47:  LDY #$28
LDE49:  LDA (Pos1ChrPtr),Y
LDE4B:  ORA (Pos2ChrPtr),Y
LDE4D:  ORA (Pos3ChrPtr),Y
LDE4F:  ORA (Pos4ChrPtr),Y
LDE51:  BNE LDE56
LDE53:  JMP LDE1B
LDE56:  LDA #$46
LDE58:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LDE5B:  CLC
LDE5C:  ADC #$1E
LDE5E:  STA $A0
LDE60:  LDA #$00
LDE62:  STA $A1
LDE64:  LDY #CHR_GOLD
LDE66:  LDA (CrntChrPtr),Y
LDE68:  CLC
LDE69:  ADC $A0
LDE6B:  STA $2B
LDE6D:  INY
LDE6E:  LDA (CrntChrPtr),Y
LDE70:  ADC #$00
LDE72:  STA $2C
LDE74:  LDA $2C
LDE76:  CMP #$27
LDE78:  BCC LDE88
LDE7A:  LDA $2B
LDE7C:  CMP #$0F
LDE7E:  BCC LDE88
LDE80:  LDA #$27
LDE82:  STA $2C
LDE84:  LDA #$0F
LDE86:  STA $2B
LDE88:  LDY #CHR_GOLD
LDE8A:  LDA $2B
LDE8C:  STA (CrntChrPtr),Y
LDE8E:  INY
LDE8F:  LDA $2C
LDE91:  STA (CrntChrPtr),Y
LDE93:  LDA #$10
LDE95:  STA TextIndex
LDE97:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LDE9A:  LDA #$64
LDE9C:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LDE9F:  CMP #$32
LDEA1:  BCC LDEA6
LDEA3:  JMP LE00C
LDEA6:  JSR LDF39
LDEA9:  RTS

LDEAA:  .byte $00, $00, $00, $80, $00, $40, $00, $40, $00, $40, $40

LDEB5:  JSR ChooseChar          ;($E42F)Select a character from a list.
LDEB8:  BCS LDECD
LDEBA:  LDX #$6D
LDEBC:  LDY #CHR_FLOWER
LDEBE:  LDA (CrntChrPtr),Y
LDEC0:  BNE LDEC8
LDEC2:  LDX #$63
LDEC4:  LDA #$01
LDEC6:  STA (CrntChrPtr),Y
LDEC8:  STX TextIndex
LDECA:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LDECD:  SEC
LDECE:  RTS
LDECF:  JSR GetFrontBlock       ;($E739)Get the block in front of character 1.
LDED2:  CMP #$09
LDED4:  BNE LDF0E
LDED6:  LDA $E75F,X
LDED9:  CLC
LDEDA:  ADC $19
LDEDC:  STA $19
LDEDE:  LDA $E760,X
LDEE1:  CLC
LDEE2:  ADC $18
LDEE4:  STA $18
LDEE6:  LDA $19
LDEE8:  LSR
LDEE9:  LSR
LDEEA:  LSR
LDEEB:  LSR
LDEEC:  CLC
LDEED:  ADC $18
LDEEF:  TAY
LDEF0:  LDA ScreenBlocks,Y
LDEF3:  AND #$1F
LDEF5:  CMP #$0A
LDEF7:  BNE LDF0E
LDEF9:  STY $EB
LDEFB:  LDX Ch1Dir
LDEFD:  LDA DirConvTbl,X
LDF00:  ASL
LDF01:  TAX
LDF02:  LDA $DF10,X
LDF05:  STA NumMenuItems
LDF07:  LDA $DF11,X
LDF0A:  STA $9D
LDF0C:  CLC
LDF0D:  RTS
LDF0E:  SEC
LDF0F:  RTS

LDF10:  .byte $40, $00, $C0, $FF, $01, $00, $FF, $FF

LDF18:  LDA $DF
LDF1A:  BNE LDF37
LDF1C:  LDY #CHR_CLASS
LDF1E:  LDA (CrntChrPtr),Y
LDF20:  TAX
LDF21:  LDA $DEAA,X
LDF24:  STA $30
LDF26:  LDY #CHR_DEX
LDF28:  LDA (CrntChrPtr),Y
LDF2A:  CLC
LDF2B:  ADC $30
LDF2D:  STA $30
LDF2F:  LDA #$FF
LDF31:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LDF34:  CMP $30
LDF36:  RTS
LDF37:  CLC
LDF38:  RTS
LDF39:  JSR LDF18
LDF3C:  BCS LDF48
LDF3E:  LDA #$2F
LDF40:  STA TextIndex
LDF42:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LDF45:  JMP LE00C
LDF48:  LDA #$64
LDF4A:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LDF4D:  CMP #$14
LDF4F:  BCS LDF66
LDF51:  LDA #$25
LDF53:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LDF56:  ORA #$01
LDF58:  STA $A0
LDF5A:  LDA #$00
LDF5C:  STA $A1
LDF5E:  LDA $A0
LDF60:  JSR LDA93
LDF63:  JMP LE00C
LDF66:  CMP #$28
LDF68:  BCS LDF7B
LDF6A:  LDY #CHR_COND
LDF6C:  LDA (CrntChrPtr),Y
LDF6E:  CMP #$02
LDF70:  BCS LDF63
LDF72:  LDA #$01
LDF74:  STA (CrntChrPtr),Y
LDF76:  LDA #$2E
LDF78:  JMP LE007
LDF7B:  CMP #$3C
LDF7D:  BCS LDF90
LDF7F:  LDY #CHR_COND
LDF81:  LDA (CrntChrPtr),Y
LDF83:  CMP #$03
LDF85:  BCS LDF63
LDF87:  LDA #$02
LDF89:  STA (CrntChrPtr),Y
LDF8B:  LDA #$D9
LDF8D:  JMP LE007
LDF90:  CMP #$50
LDF92:  BCS LDFDD
LDF94:  LDA #$4D
LDF96:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LDF99:  STA $30
LDF9B:  LDA MapProperties
LDF9D:  AND #MAP_DUNGEON
LDF9F:  BEQ LDFA6
LDFA1:  LDA DungeonLevel
LDFA3:  ASL
LDFA4:  ASL
LDFA5:  ASL
LDFA6:  CLC
LDFA7:  ADC #$08
LDFA9:  ADC $30
LDFAB:  STA $A0
LDFAD:  LDA #$00
LDFAF:  STA $A1
LDFB1:  LDX #$00
LDFB3:  LDA ChrPtrBaseLB,X
LDFB5:  STA CrntChrPtrLB
LDFB7:  LDA ChrPtrBaseUB,X
LDFB9:  STA CrntChrPtrUB
LDFBB:  LDY #CHR_COND
LDFBD:  LDA (CrntChrPtr),Y
LDFBF:  CMP #$03
LDFC1:  BCS LDFD4
LDFC3:  TXA
LDFC4:  PHA
LDFC5:  LDA $A0
LDFC7:  PHA
LDFC8:  JSR LDA93
LDFCB:  PLA
LDFCC:  STA $A0
LDFCE:  LDA #$00
LDFD0:  STA $A1
LDFD2:  PLA
LDFD3:  TAX
LDFD4:  INX
LDFD5:  INX
LDFD6:  CPX #$08
LDFD8:  BNE LDFB3
LDFDA:  JMP LE00C
LDFDD:  LDX #$00
LDFDF:  LDA ChrPtrBaseLB,X
LDFE1:  STA CrntChrPtrLB
LDFE3:  LDA ChrPtrBaseUB,X
LDFE5:  STA CrntChrPtrUB
LDFE7:  TXA
LDFE8:  PHA
LDFE9:  LDY #CHR_COND
LDFEB:  LDA (CrntChrPtr),Y
LDFED:  CMP #$02
LDFEF:  BCS LDFFC
LDFF1:  LDA #$01
LDFF3:  STA (CrntChrPtr),Y
LDFF5:  LDA #$2E
LDFF7:  STA TextIndex
LDFF9:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LDFFC:  PLA
LDFFD:  TAX
LDFFE:  INX
LDFFF:  INX
LE000:  CPX #$08
LE002:  BNE LDFDF
LE004:  JMP LE00C
LE007:  STA TextIndex
LE009:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LE00C:  LDA MapProperties
LE00E:  AND #MAP_DUNGEON
LE010:  BNE LE082
LE012:  LDA NumMenuItems
LE014:  BNE LE047
LE016:  JSR LE090
LE019:  PHA
LE01A:  TXA
LE01B:  ORA #$80
LE01D:  CMP #$8A
LE01F:  BEQ LE028
LE021:  STA CharBlock
LE024:  PLA
LE025:  STA ($43),Y
LE027:  RTS

LE028:  LDA #$8B
LE02A:  STA CharBlock
LE02D:  PLA
LE02E:  LDA ($43),Y
LE030:  PHA
LE031:  LDA MapXPos
LE033:  AND #$01
LE035:  BNE LE03F
LE037:  PLA
LE038:  AND #$0F
LE03A:  ORA #$B0
LE03C:  JMP LE044
LE03F:  PLA
LE040:  AND #$F0
LE042:  ORA #$0B
LE044:  STA ($43),Y
LE046:  RTS
LE047:  LDA MapXPos
LE049:  STA $48
LE04B:  LDA MapYPos
LE04D:  STA $47
LE04F:  JSR LF5B0
LE052:  CLC
LE053:  LDA $43
LE055:  ADC NumMenuItems
LE057:  STA $43
LE059:  LDA $44
LE05B:  ADC $9D
LE05D:  STA $44
LE05F:  LDA ($43),Y
LE061:  STA $30
LE063:  LDA MapXPos
LE065:  AND #$01
LE067:  BNE LE072
LE069:  LDA $30
LE06B:  AND #$0F
LE06D:  ORA #$B0
LE06F:  JMP LE078
LE072:  LDA $30
LE074:  AND #$F0
LE076:  ORA #$0B
LE078:  STA ($43),Y
LE07A:  LDY $EB
LE07C:  LDA #$8B
LE07E:  STA ScreenBlocks,Y
LE081:  RTS
LE082:  JSR GetDngnXYData       ;($F974)Get the dungeon data for character's current location.
LE085:  LDA #$0D
LE087:  STA (MapDatPtr),Y
LE089:  LDA DisNPCMovement
LE08B:  ORA #$80
LE08D:  STA DisNPCMovement
LE08F:  RTS
LE090:  LDA CurPRGBank
LE092:  PHA
LE093:  LDA MapBank
LE095:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE098:  LDA MapXPos
LE09A:  STA $48
LE09C:  LDA MapYPos
LE09E:  STA $47
LE0A0:  JSR LF5B0
LE0A3:  SEC
LE0A4:  LDA _MapDatPtrLB
LE0A6:  SBC #$00
LE0A8:  STA $29
LE0AA:  LDA _MapDatPtrUB
LE0AC:  SBC #$78
LE0AE:  STA $2A
LE0B0:  CLC
LE0B1:  LDA $43
LE0B3:  PHA
LE0B4:  ADC $29
LE0B6:  STA $43
LE0B8:  LDA $44
LE0BA:  PHA
LE0BB:  ADC $2A
LE0BD:  STA $44
LE0BF:  LDA MapXPos
LE0C1:  AND #$01
LE0C3:  BNE LE0D1
LE0C5:  LDA ($43),Y
LE0C7:  AND #$F0
LE0C9:  LSR
LE0CA:  LSR
LE0CB:  LSR
LE0CC:  LSR
LE0CD:  TAX
LE0CE:  JMP LE0D6
LE0D1:  LDA ($43),Y
LE0D3:  AND #$0F
LE0D5:  TAX
LE0D6:  LDA ($43),Y
LE0D8:  STA $2A
LE0DA:  PLA
LE0DB:  STA $44
LE0DD:  PLA
LE0DE:  STA $43
LE0E0:  PLA
LE0E1:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE0E4:  LDA $2A
LE0E6:  RTS

;----------------------------------------------------------------------------------------------------

DoClimbCmd:
LE0E7:  LDA DisNPCMovement
LE0E9:  BEQ LE139
LE0EB:  JSR GetDngnXYData       ;($F974)Get the dungeon data for character's current location.
LE0EE:  CMP #$03
LE0F0:  BEQ LE120
LE0F2:  CMP #$04
LE0F4:  BEQ LE143
LE0F6:  CMP #$05
LE0F8:  BNE LE139
LE0FA:  LDA #$02
LE0FC:  STA NumMenuItems
LE0FE:  LDA #$35
LE100:  STA TextIndex2
LE103:  LDA #$0A
LE105:  STA Wnd2XPos
LE108:  LDA #$06
LE10A:  STA Wnd2YPos
LE10D:  LDA #$0A
LE10F:  STA Wnd2Width
LE112:  LDA #$06
LE114:  STA Wnd2Height
LE117:  JSR ShowSelectWnd       ;($E4FF)Show a window where player makes a selection.
LE11A:  BCS LE140
LE11C:  CMP #$00
LE11E:  BNE LE143
LE120:  LDA DungeonLevel
LE122:  BEQ LE133
LE124:  DEC DungeonLevel
LE126:  DEC MapDatPtrUB
LE128:  LDA DisNPCMovement
LE12A:  ORA #$80
LE12C:  STA DisNPCMovement
LE12E:  LDA #$1C
LE130:  JMP LE13B
LE133:  JSR LD7E9
LE136:  JMP FinishCommand       ;($C293)Post-command cleanup and run the game engine loop.
LE139:  LDA #$11

LE13B:  STA TextIndex
LE13D:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LE140:  JMP FinishCommand       ;($C293)Post-command cleanup and run the game engine loop.
LE143:  LDA DungeonLevel
LE145:  CMP #$07
LE147:  BEQ LE158
LE149:  INC DungeonLevel
LE14B:  INC MapDatPtrUB
LE14D:  LDA DisNPCMovement
LE14F:  ORA #$80
LE151:  STA DisNPCMovement
LE153:  LDA #$1B
LE155:  JMP LE13B
LE158:  LDA #$17
LE15A:  JMP LE13B

;----------------------------------------------------------------------------------------------------

DoFoodCmd:
LE15D:  LDA CurPRGBank
LE15F:  PHA
LE160:  LDA #BANK_HELPERS1
LE162:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE165:  JSR $B300
LE168:  PLA
LE169:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE16C:  JMP FinishCommand       ;($C293)Post-command cleanup and run the game engine loop.

;--------------------------------------------------------------------------------------------------

DoHorseCmd:
LE16F:  LDA OnHorse
LE171:  AND #$01
LE173:  BEQ LE18C
LE175:  LDY #$81
LE177:  LDX #$61
LE179:  LDA OnHorse
LE17B:  BPL LE181
LE17D:  LDY #$01
LE17F:  LDX #$62
LE181:  STY OnHorse
LE183:  TXA
LE184:  PHA
LE185:  JSR LoadChrGFX          ;($EE4E)Load the sprite tiles for current party members.
LE188:  PLA
LE189:  JMP LE18E
LE18C:  LDA #$13
LE18E:  STA TextIndex
LE190:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LE193:  LDA $C0
LE195:  AND #$7C
LE197:  STA $C0
LE199:  JMP FinishCommand       ;($C293)Post-command cleanup and run the game engine loop.

;----------------------------------------------------------------------------------------------------

DoGoldCmd:
LE19C:  LDA CurPRGBank
LE19E:  PHA

LE19F:  LDA #BANK_HELPERS2
LE1A1:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.

LE1A4:  LDA #CHR_NO_CHK_DEAD
LE1A6:  STA ChkCharDead
LE1A8:  JSR $9F00
LE1AB:  PLA
LE1AC:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE1AF:  JMP FinishCommand       ;($C293)Post-command cleanup and run the game engine loop.

;----------------------------------------------------------------------------------------------------

DoOrderCmd:
LE1B2:  JSR ChooseChar          ;($E42F)Select a character from a list.
LE1B5:  PHA
LE1B6:  BCS LE1D5
LE1B8:  JSR LE49E
LE1BB:  BCS LE1D5
LE1BD:  TAX
LE1BE:  STA $18
LE1C0:  PLA
LE1C1:  STA $19
LE1C3:  JSR LE1DC
LE1C6:  LDA #$04
LE1C8:  STA $2E
LE1CA:  JSR LoadChrGFX          ;($EE4E)Load the sprite tiles for current party members.
LE1CD:  LDA #$16
LE1CF:  STA TextIndex
LE1D1:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LE1D4:  PHA
LE1D5:  PLA
LE1D6:  JSR BinToBCD            ;($F4D1)Convert binary number to BCD.
LE1D9:  JMP FinishCommand       ;($C293)Post-command cleanup and run the game engine loop.
LE1DC:  LDA CurPRGBank
LE1DE:  PHA
LE1DF:  LDX $19
LE1E1:  LDA $03D9,X
LE1E4:  STA $2E
LE1E6:  LDY $18
LE1E8:  LDA $03D9,Y
LE1EB:  STA $03D9,X
LE1EE:  LDA $2E
LE1F0:  STA $03D9,Y
LE1F3:  LDA #BANK_HELPERS1
LE1F5:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE1F8:  JSR $B780
LE1FB:  PLA
LE1FC:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE1FF:  RTS

;----------------------------------------------------------------------------------------------------

DoStatusCmd:
LE200:  LDA MapProperties
LE202:  PHA
LE203:  LDA #$80
LE205:  STA MapProperties
LE207:  JSR ResetNameTableF1    ;($FBDC)Reset nametable offsets and select nametable 0.

LE20A:  LDA #BANK_CREATE
LE20C:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE20F:  JSR DoStatusScreen      ;($A000)Show status window.

LE212:  LDA #$00
LE214:  STA CurPPUConfig1
LE216:  STA PPUControl1

LE219:  LDA MapBank
LE21B:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.

LE21E:  JSR LoadAlphaNumMaps    ;($ED76)Load character set and map tiles.
LE221:  LDA #$FE
LE223:  STA $2A
LE225:  LDA #$3E
LE227:  STA $29
LE229:  JSR LED33

LE22C:  PLA
LE22D:  STA MapProperties

LE22F:  LDA #$FF
LE231:  STA $D2
LE233:  LDA #$1E
LE235:  STA CurPPUConfig1
LE237:  JMP LoadNewMap          ;($C175)Load a new map.

;----------------------------------------------------------------------------------------------------

DoGiveCmd:
LE23A:  LDA CurPRGBank
LE23C:  PHA
LE23D:  LDA #BANK_HELPERS1
LE23F:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE242:  LDA #CHR_NO_CHK_DEAD
LE244:  STA ChkCharDead
LE246:  JSR $A800
LE249:  PLA
LE24A:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE24D:  JMP FinishCommand       ;($C293)Post-command cleanup and run the game engine loop.

;----------------------------------------------------------------------------------------------------

DoBribeCmd:
LE250:  LDA BribePray
LE252:  AND #CMD_BRIBE
LE254:  BEQ LE2BE
LE256:  JSR ChkValidNPC         ;($C6EC)Check if valid NPC in front of player.
LE259:  LDX #$02
LE25B:  BCS LE2B5
LE25D:  LDA NPCSprIndex,Y
LE260:  AND #$7F
LE262:  CMP #$05
LE264:  BEQ LE2BE
LE266:  CMP #$1E
LE268:  BEQ LE2BE
LE26A:  CMP #$15
LE26C:  BCC LE272
LE26E:  CMP #$1D
LE270:  BCC LE2BE
LE272:  TYA
LE273:  PHA
LE274:  JSR ChooseChar          ;($E42F)Select a character from a list.
LE277:  BCS LE2BD
LE279:  LDY #CHR_GOLD
LE27B:  LDA (CrntChrPtr),Y
LE27D:  SEC
LE27E:  SBC #$64
LE280:  STA $2D
LE282:  INY
LE283:  LDA (CrntChrPtr),Y
LE285:  SBC #$00
LE287:  STA $2E
LE289:  PLA
LE28A:  BCS LE291
LE28C:  LDX #$68
LE28E:  JMP LE2B5
LE291:  PHA
LE292:  LDA $2E
LE294:  STA (CrntChrPtr),Y
LE296:  DEY
LE297:  LDA $2D
LE299:  STA (CrntChrPtr),Y
LE29B:  PLA
LE29C:  TAY
LE29D:  LDA NPCSprIndex,Y
LE2A0:  LDX #$58
LE2A2:  AND #$7F
LE2A4:  CMP #$0E
LE2A6:  BNE LE2B5
LE2A8:  LDA #$FF
LE2AA:  STA NPCSprIndex,Y
LE2AD:  STX TextIndex
LE2AF:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LE2B2:  JMP LoadNewMap          ;($C175)Load a new map.
LE2B5:  STX TextIndex
LE2B7:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LE2BA:  JMP FinishCommand       ;($C293)Post-command cleanup and run the game engine loop.
LE2BD:  PLA
LE2BE:  JMP FinishCommand       ;($C293)Post-command cleanup and run the game engine loop.

;----------------------------------------------------------------------------------------------------

DoPrayCmd:
LE2C1:  LDA ThisMap             ;Is the player praying in Exodus castle?
LE2C3:  CMP #MAP_EXODUS         ;If so, branch to check if they are praying
LE2C5:  BEQ ChkEndPray          ;in th right place to start the end game.

LE2C7:  JSR ChooseChar          ;($E42F)Select a character from a list.
LE2CA:  BCC +

JmpPrayNoEffect:
LE2CC:  JMP PrayerNotHeard      ;($E38F)Indicate nothing was found after praying.

LE2CF:* LDA #$03
LE2D1:  JSR FlashAndSound       ;($DB2D)Flash screen with SFX.

LE2D4:  LDA BribePray
LE2D6:  AND #CMD_PRAY
LE2D8:  BEQ LE2F7

LE2DA:  LDA ThisMap
LE2DC:  CMP #MAP_YEW
LE2DE:  BNE LE2F7

LE2E0:  LDA MapXPos
LE2E2:  CMP #$30
LE2E4:  BNE JmpPrayNoEffect
LE2E6:  LDA MapYPos
LE2E8:  CMP #$30
LE2EA:  BNE JmpPrayNoEffect
LE2EC:  LDY #$29
LE2EE:  LDA #$01
LE2F0:  STA (CrntChrPtr),Y
LE2F2:  LDA #$56
LE2F4:  JMP LE391

LE2F7:  LDA ThisMap
LE2F9:  CMP #MAP_EXODUS
LE2FB:  BNE ChkNPCPray

ChkEndPray:
LE2FD:  LDA MapYPos
LE2FF:  CMP #$0B
LE301:  BNE JmpPrayNoEffect

LE303:  LDA MapXPos
LE305:  CMP #$1E
LE307:  BCC JmpPrayNoEffect

LE309:  CMP #$22
LE30B:  BCS JmpPrayNoEffect

LE30D:  LDY #$3C
LE30F:  LDA (Pos1ChrPtr),Y
LE311:  ORA (Pos2ChrPtr),Y
LE313:  ORA (Pos3ChrPtr),Y
LE315:  ORA (Pos4ChrPtr),Y

LE317:  CMP #$0F
LE319:  BEQ +

LE31B:  JMP PrayerNotHeard      ;($E38F)Indicate nothing was found after praying.

LE31E:* LDA #$03
LE320:  JSR FlashAndSound       ;($DB2D)Flash screen with SFX.

LE323:  LDA #MUS_EXODUS_HB+INIT ;Start Exodus heart beat music.
LE325:  STA InitNewMusic        ;

LE327:  JSR LE3C7
LE32A:  LDA #BANK_HELPERS2
LE32C:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE32F:  JSR $9E00

LE332:  BCS LE399
LE334:  JSR DisplayEndText      ;($E3D7)Exodus defeated. Display end text.
LE337:  LDA #$FF
LE339:  LDX #$00
LE33B:  STA NPCSprIndex,X
LE33E:  INX
LE33F:  CPX #$80
LE341:  BNE LE33B

LE343:  LDA #MUS_NONE+INIT
LE345:  STA InitNewMusic

LE347:  LDA #$00                ;
LE349:  STA EndGmTimerLB        ;Zero out end game timer in preparation for count.
LE34B:  STA EndGmTimerUB        ;

LE34D:  LDA #GME_EX_DEAD        ;Set Exodus dead flag to start the screen shaking.
LE34F:  STA ExodusDead          ;

LE351:  JMP FinishCommand       ;($C293)Post-command cleanup and run the game engine loop.

ChkNPCPray:
LE354:  JSR ChkValidNPC         ;($C6EC)Check if valid NPC in front of player.
LE357:  BCS PrayerNotHeard      ;($E38F)Indicate nothing was found after praying.

LE359:  LDA ThisMap
LE35B:  CMP #MAP_SH_INT
LE35D:  BCC PrayerNotHeard      ;($E38F)Indicate nothing was found after praying.
LE35F:  LDA ThisMap
LE361:  SEC
LE362:  SBC #$15
LE364:  TAX
LE365:  LDA $E3C3,X
LE368:  STA $30
LE36A:  LDY #CHR_CARDS
LE36C:  LDA (CrntChrPtr),Y
LE36E:  AND $30
LE370:  BNE PrayerNotHeard      ;($E38F)Indicate nothing was found after praying.
LE372:  LDA (CrntChrPtr),Y
LE374:  ORA $30
LE376:  STA (CrntChrPtr),Y
LE378:  CLC

LE379:  LDA ThisMap
LE37B:  ADC #$8D
LE37D:  STA TextIndex
LE37F:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LE382:  CLC
LE383:  LDA ThisMap
LE385:  ADC #$91
LE387:  STA TextIndex
LE389:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LE38C:  JMP FinishCommand       ;($C293)Post-command cleanup and run the game engine loop.

PrayerNotHeard:
LE38F:  LDA #$57                ;YOUR PRAYER WAS NOT HEARD text.
LE391:  STA TextIndex           ;
LE393:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LE396:  JMP FinishCommand       ;($C293)Post-command cleanup and run the game engine loop.

;----------------------------------------------------------------------------------------------------

LE399:  LDX #$00
LE39B:  LDA ChrPtrBaseLB,X
LE39D:  STA CrntChrPtrLB
LE39F:  LDA ChrPtrBaseUB,X
LE3A1:  STA CrntChrPtrUB
LE3A3:  LDY #CHR_COND
LE3A5:  LDA (CrntChrPtr),Y
LE3A7:  CMP #$03
LE3A9:  BCS LE3BA
LE3AB:  LDA #$03
LE3AD:  STA (CrntChrPtr),Y
LE3AF:  LDY #CHR_HIT_PNTS
LE3B1:  LDA #$00
LE3B3:  STA (CrntChrPtr),Y
LE3B5:  INY
LE3B6:  LDA #$00
LE3B8:  STA (CrntChrPtr),Y
LE3BA:  INX
LE3BB:  INX
LE3BC:  CPX #$08
LE3BE:  BNE LE39B
LE3C0:  JMP LD315

LE3C3:  .byte $02, $08, $01, $04

LE3C7:  LDA CurPRGBank
LE3C9:  PHA
LE3CA:  LDA #BANK_HELPERS1
LE3CC:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE3CF:  JSR $9100
LE3D2:  PLA
LE3D3:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE3D6:  RTS

DisplayEndText:
LE3D7:  LDA CurPRGBank
LE3D9:  PHA
LE3DA:  LDA #BANK_HELPERS1
LE3DC:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE3DF:  JSR $AD00
LE3E2:  PLA
LE3E3:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE3E6:  RTS

LE3E7:  LDA #GME_WON
LE3E9:  STA ExodusDead
LE3EB:  LDA #$00
LE3ED:  STA CurPPUConfig1
LE3EF:  LDA #$78
LE3F1:  JSR WaitSomeFrames      ;($E6D0)Wait some frames before continuing.
LE3F4:  LDA #$1E
LE3F6:  STA CurPPUConfig1
LE3F8:  LDA #MUS_END+INIT
LE3FA:  STA InitNewMusic
LE3FC:  LDA #BANK_HELPERS2
LE3FE:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE401:  LDA #$BE
LE403:  STA $2A
LE405:  LDA #$00
LE407:  STA $29
LE409:  LDA #$18
LE40B:  STA $2C
LE40D:  LDA #$A0
LE40F:  STA $2B
LE411:  LDA #$02
LE413:  STA $2E
LE415:  LDA #$00
LE417:  STA $2D
LE419:  JSR LoadPPU             ;($EFE3)Load values into PPU.
LE41C:  JSR ResetNameTableF1    ;($FBDC)Reset nametable offsets and select nametable 0.
LE41F:  LDA #BANK_GEM
LE421:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE424:  LDA #$FF
LE426:  STA $05FF
LE429:  JSR UpdateSpriteRAM     ;($9900)Move sprite buffer data into sprite RAM.
LE42C:  JMP LE42C

;----------------------------------------------------------------------------------------------------

ChooseChar:
LE42F:  LDA #$02
LE431:  STA WndXPos
LE433:  LDA #$04
LE435:  STA WndYPos

LE437:  LDA #$08
LE439:  STA WndWidth
LE43B:  LDA #$0C
LE43D:  STA WndHeight

LE43F:  JSR ShowWindow          ;($F42A)Show a window on the display.

LE442:  JSR SelectWho           ;($E770)Player selects a character window.
LE445:  LDA #$04
LE447:  STA $2A
LE449:  LDA #$06
LE44B:  STA $29
LE44D:  LDA #$05
LE44F:  STA $2E
LE451:  LDA #$05
LE453:  STA $2D
LE455:  LDA #$FF
LE457:  STA $30
LE459:  JSR DisplayText         ;($F0BE)Display text on the screen.

LE45C:  LDA #$40
LE45E:  STA $7300
LE461:  LDA #$18
LE463:  STA $7303
LE466:  LDA #$01
LE468:  STA $2E
LE46A:  LDA #$04
LE46C:  STA $2D
LE46E:  JSR LE685
LE471:  BCS LE49C
LE473:  CMP #$FF
LE475:  BEQ LE45C
LE477:  ASL
LE478:  TAX
LE479:  LDA ChrPtrBaseLB,X
LE47B:  STA CrntChrPtrLB
LE47D:  LDA ChrPtrBaseUB,X
LE47F:  STA CrntChrPtrUB

LE481:  LDA ChkCharDead
LE483:  BNE LE48D

LE485:  LDY #CHR_COND
LE487:  LDA (CrntChrPtr),Y
LE489:  CMP #COND_DEAD
LE48B:  BCS LE494

LE48D:  JSR LE699
LE490:  TXA
LE491:  LSR
LE492:  CLC
LE493:  RTS

LE494:  CLC
LE495:  ADC #$40                ;CHARACTER IS DEAD, CHARACTER HAS TURNED INTO ASHES text.
LE497:  STA TextIndex           ;
LE499:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LE49C:  SEC
LE49D:  RTS

;----------------------------------------------------------------------------------------------------

LE49E:  LDA #$96
LE4A0:  LDX #$00
LE4A2:  JMP LE4A9

LE4A5:  LDA #$9C
LE4A7:  LDX #$8E
LE4A9:  PHA
LE4AA:  TXA
LE4AB:  PHA
LE4AC:  LDA #$02
LE4AE:  STA $2A
LE4B0:  LDA #$10
LE4B2:  STA $29
LE4B4:  LDA #$08
LE4B6:  STA $2E
LE4B8:  LDA #$0C
LE4BA:  STA $2D
LE4BC:  JSR ShowWindow          ;($F42A)Show a window on the display.
LE4BF:  JSR SelectWho           ;($E770)Player selects a character window.
LE4C2:  PLA
LE4C3:  STA TextBuffer+4
LE4C6:  PLA
LE4C7:  STA TextBuffer+3
LE4CA:  LDA #$04
LE4CC:  STA $2A
LE4CE:  LDA #$12
LE4D0:  STA $29
LE4D2:  LDA #$05
LE4D4:  STA $2E
LE4D6:  LDA #$05
LE4D8:  STA $2D
LE4DA:  LDA #$FF
LE4DC:  STA $30
LE4DE:  JSR DisplayText         ;($F0BE)Display text on the screen.
LE4E1:  LDA #$A0
LE4E3:  STA $7300
LE4E6:  LDA #$18
LE4E8:  STA $7303
LE4EB:  LDA #$01
LE4ED:  STA $2E
LE4EF:  LDA #$04
LE4F1:  STA $2D
LE4F3:  JSR LE685
LE4F6:  BCS LE49C
LE4F8:  CMP #$FF
LE4FA:  BEQ LE4E1
LE4FC:  JMP LE477

;----------------------------------------------------------------------------------------------------

ShowSelectWnd:
LE4FF:  LDA NumMenuItems
LE501:  CLC
LE502:  ADC #$01
LE504:  ASL
LE505:  STA Wnd2Height
LE508:  JMP _ShowSelectWnd      ;($E50B)Show a window where player makes a selection, variant.

_ShowSelectWnd:
LE50B:  LDA HideUprSprites
LE50D:  STA $E1

LE50F:  LDA Wnd2XPos
LE512:  STA $2A
LE514:  LDA Wnd2YPos
LE517:  STA $29
LE519:  LDA Wnd2Width
LE51C:  STA $2E
LE51E:  LDA Wnd2Height
LE521:  STA $2D
LE523:  JSR ShowWindow          ;($F42A)Show a window on the display.
LE526:  LDA TextIndex2
LE529:  STA $30
LE52B:  LDA Wnd2XPos
LE52E:  CLC
LE52F:  ADC #$02
LE531:  STA $2A
LE533:  LDA Wnd2YPos
LE536:  CLC
LE537:  ADC #$02
LE539:  STA $29
LE53B:  LDA Wnd2Width
LE53E:  SEC
LE53F:  SBC #$03
LE541:  STA $2E
LE543:  SEC
LE544:  LDA Wnd2Height
LE547:  SBC #$02
LE549:  LSR
LE54A:  STA $2D
LE54C:  LDA $E1
LE54E:  STA HideUprSprites
LE550:  JSR DisplayText         ;($F0BE)Display text on the screen.
LE553:  LDA NumMenuItems
LE555:  CLC
LE556:  ADC #$01
LE558:  ASL
LE559:  STA $2E
LE55B:  LDX #$02
LE55D:  SEC
LE55E:  LDA Wnd2Height
LE561:  SBC $2E
LE563:  BEQ LE569
LE565:  CLC
LE566:  ADC #$02
LE568:  TAX
LE569:  STX $2E
LE56B:  LDA Wnd2YPos
LE56E:  CLC
LE56F:  ADC $2E
LE571:  ASL
LE572:  ASL
LE573:  ASL
LE574:  STA $7300
LE577:  LDA Wnd2XPos
LE57A:  CLC
LE57B:  ADC #$01
LE57D:  ASL
LE57E:  ASL
LE57F:  ASL
LE580:  STA $7303
LE583:  LDA #$01
LE585:  STA $2E
LE587:  LDA NumMenuItems
LE589:  STA $2D
LE58B:  JSR LE685
LE58E:  BCS LE5FD
LE590:  CMP #$FF
LE592:  BNE LE5E8
LE594:  LDA $9D
LE596:  BEQ LE553
LE598:  AND #$80
LE59A:  BEQ LE5B3
LE59C:  LDA $9D
LE59E:  AND #$7F
LE5A0:  STA $9D
LE5A2:  LDA #$08
LE5A4:  STA NumMenuItems
LE5A6:  LDA #$12
LE5A8:  STA Wnd2Height
LE5AB:  LDA TextIndex2
LE5AE:  STA $30
LE5B0:  JMP _ShowSelectWnd      ;($E50B)Show a window where player makes a selection, variant.
LE5B3:  LDA $9D
LE5B5:  ORA #$80
LE5B7:  STA $9D
LE5B9:  AND #$7F
LE5BB:  SEC
LE5BC:  SBC #$08
LE5BE:  STA NumMenuItems
LE5C0:  CLC
LE5C1:  ADC #$01
LE5C3:  ASL
LE5C4:  STA Wnd2Height
LE5C7:  LDA Wnd2XPos
LE5CA:  STA $2A
LE5CC:  LDA Wnd2YPos
LE5CF:  STA $29
LE5D1:  LDA Wnd2Width
LE5D4:  STA $2E
LE5D6:  LDA #$12
LE5D8:  STA $2D
LE5DA:  JSR ShowWindow          ;($F42A)Show a window on the display.
LE5DD:  LDA TextIndex2
LE5E0:  CLC
LE5E1:  ADC #$01
LE5E3:  STA $30
LE5E5:  JMP LE52B
LE5E8:  STA $2E
LE5EA:  LDX #$00
LE5EC:  LDA $9D
LE5EE:  BPL LE5F2
LE5F0:  LDX #$08
LE5F2:  CLC
LE5F3:  TXA
LE5F4:  ADC $2E
LE5F6:  PHA
LE5F7:  JSR LE699
LE5FA:  PLA
LE5FB:  CLC
LE5FC:  RTS

LE5FD:  JSR BinToBCD            ;($F4D1)Convert binary number to BCD.
LE600:  SEC
LE601:  RTS

LE602:  LDA CurPRGBank
LE604:  PHA
LE605:  LDA #BANK_HELPERS2
LE607:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE60A:  JSR $9A00
LE60D:  TAX
LE60E:  PLA
LE60F:  PHP
LE610:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE613:  TXA
LE614:  PLP
LE615:  RTS

LE616:  LDA CurPRGBank
LE618:  PHA
LE619:  LDA #BANK_HELPERS2
LE61B:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE61E:  JSR $9C40
LE621:  TAX
LE622:  PLA
LE623:  PHP
LE624:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE627:  TXA
LE628:  PLP
LE629:  RTS

LE62A:  LDA CurPRGBank
LE62C:  PHA
LE62D:  LDA #BANK_HELPERS2
LE62F:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE632:  JSR $9D00
LE635:  TAX
LE636:  PLA
LE637:  PHP
LE638:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE63B:  TXA
LE63C:  PLP
LE63D:  RTS

LE63E:  LDA CurPRGBank
LE640:  PHA
LE641:  LDA #BANK_HELPERS1
LE643:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE646:  JSR $B400
LE649:  PLA
LE64A:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE64D:  RTS

;----------------------------------------------------------------------------------------------------

;This function generates an random number between 0 and Accum-1. The result is put into A.

GenRandomNum:
LE64E:  PHA                     ;
LE64F:  LDA RngSeed             ;
LE651:  STA RngInput1           ;
LE653:  LDA #$11                ;
LE655:  STA RngInput0           ;
LE657:  JSR RngCore             ;($FBF5)Core of the random number generator.
LE65A:  CLC                     ;
LE65B:  LDA RngNum0             ;
LE65D:  ADC #$17                ;Generate a random number and put it in A.
LE65F:  STA RngInput1           ;
LE661:  STA RngSeed             ;
LE663:  PLA                     ;
LE664:  STA RngInput0           ;
LE666:  JSR RngCore             ;($FBF5)Core of the random number generator.
LE669:  CLC                     ;
LE66A:  LDA RngNum1             ;
LE66C:  RTS                     ;

;----------------------------------------------------------------------------------------------------

LE66D:  LDA HideUprSprites
LE66F:  STA $C8
LE671:  LDA #$80
LE673:  STA $C7

;----------------------------------------------------------------------------------------------------

ShowDialog:
LE675:  LDA CurPRGBank
LE677:  PHA
LE678:  LDA #BANK_HELPERS1
LE67A:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE67D:  JSR $AA00
LE680:  PLA
LE681:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE684:  RTS

;----------------------------------------------------------------------------------------------------

LE685:  LDA CurPRGBank
LE687:  PHA
LE688:  LDA #BANK_HELPERS1
LE68A:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE68D:  JSR $B500
LE690:  TAX
LE691:  PLA
LE692:  PHP
LE693:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE696:  PLP
LE697:  TXA
LE698:  RTS
LE699:  PHA
LE69A:  TXA
LE69B:  PHA
LE69C:  LDX #$C4
LE69E:  LDA $7300,X
LE6A1:  CMP #SPRT_HIDE
LE6A3:  BEQ LE6AF
LE6A5:  TXA
LE6A6:  CLC
LE6A7:  ADC #$04
LE6A9:  TAX
LE6AA:  BEQ LE6C7
LE6AC:  JMP LE69E

LE6AF:  LDA $7300
LE6B2:  STA $7300,X
LE6B5:  LDA $7301
LE6B8:  STA $7301,X
LE6BB:  LDA $7302
LE6BE:  STA $7302,X
LE6C1:  LDA $7303
LE6C4:  STA $7303,X
LE6C7:  LDA #SPRT_HIDE
LE6C9:  STA $7300
LE6CC:  PLA
LE6CD:  TAX
LE6CE:  PLA
LE6CF:  RTS

;----------------------------------------------------------------------------------------------------

WaitSomeFrames:
LE6D0:  CLC                     ;
LE6D1:  ADC Increment0          ;The game will wait a certain number of frames.
LE6D3:* CMP Increment0          ;The number of frames is the value in A.
LE6D5:  BNE -                   ;
LE6D7:  RTS                     ;

;----------------------------------------------------------------------------------------------------

LE6D8:  LDA #$00
LE6DA:  STA IgnoreInput
LE6DC:  STA InputChange

LE6DE:  LDA Increment0          ;
LE6E0:* CMP Increment0          ;Wait here until the next NMI interrupt.
LE6E2:  BEQ -                   ;

LE6E4:  LDA InputChange
LE6E6:  BEQ LE6D8
LE6E8:  LDA Pad1Input
LE6EA:  AND $9B
LE6EC:  BEQ LE6D8
LE6EE:  RTS

;----------------------------------------------------------------------------------------------------

GetTargetNPC:
LE6EF:  JSR GetFrontBlock       ;($E739)Get the block in front of character 1.
LE6F2:  CMP #BLK_COUNTER        ;Is the target block a shop counter?
LE6F4:  BNE +                   ;If not, branch.

LE6F6:  LDA FrntBlkOfstTbl,X    ;
LE6F9:  CLC                     ;
LE6FA:  ADC TargetX             ;
LE6FC:  STA TargetX             ;Set the new target block to be the
LE6FE:  LDA FrntBlkOfstTbl+1,X  ;one just beyond the shop counter.
LE701:  CLC                     ;
LE702:  ADC TargetY             ;
LE704:  STA TargetY             ;

LE706:* LDX #$44                ;Start at the NPC sprites.

FindNPCLoop:
LE708:  LDA SpriteBuffer,X
LE70B:  CMP TargetY
LE70D:  BNE +

LE70F:  LDA SpriteBuffer+3,X
LE712:  CMP TargetX
LE714:  BEQ NPCFound

LE716:* CPX #$B4
LE718:  BEQ NPCNotFound

LE71A:  TXA
LE71B:  CLC
LE71C:  ADC #$10
LE71E:  TAX
LE71F:  JMP FindNPCLoop         ;($E708)Loop to find an NPC at the target location.

NPCFound:
LE722:  TXA                     ;Save a copy of the sprite byte index on the stack.
LE723:  PHA                     ;

LE724:  SEC                     ;Subtract starting point of NPC sprites from index.
LE725:  SBC #$44                ;
LE727:  LSR                     ;/8. Create an index
LE728:  LSR                     ;
LE729:  LSR                     ;

LE72A:  TAY
LE72B:  LDX Ch1Dir
LE72D:  LDA NPCDirTbl,X
LE730:  JSR LC56F

LE733:  PLA
LE734:  TAX

LE735:  CLC
LE736:  RTS

NPCNotFound:
LE737:  SEC
LE738:  RTS

;----------------------------------------------------------------------------------------------------

GetFrontBlock:
LE739:  LDX Ch1Dir              ;Convert character direction to 0,1,2 or 3.
LE73B:  LDA DirConvTbl,X        ;

LE73E:  ASL                     ;*2. Up/down and left/right stored in same table.
LE73F:  TAX                     ;

LE740:  LDA FrntBlkOfstTbl,X    ;Get the offset in the X direction in pixels of the target block.
LE743:  CLC                     ;
LE744:  ADC SpriteBuffer+7      ;Target block will always br +16, -16 or 0 pixels offset from
LE747:  STA TargetX             ;the character's X pixel position.

LE749:  LDA FrntBlkOfstTbl+1,X  ;Calculate up/down block offset from character's block row.
LE74C:  CLC                     ;Target block will always be on row $6F,$70 or $71.
LE74D:  ADC #$70                ;Add $70 as character is always on row starting with $70.
LE74F:  STA TargetY             ;Store the row number that target block is on. 

LE751:  LDA TargetX             ;
LE753:  LSR                     ;/16. To convert sprite X position to screen block position, the
LE754:  LSR                     ;pixel position is /16 since sprites are always block aligned.
LE755:  LSR                     ;
LE756:  LSR                     ;

LE757:  CLC                     ;
LE758:  ADC TargetY             ;Add X and Y offsets together to get final target block index.
LE75A:  TAY                     ;

LE75B:  LDA ScreenBlocks,Y      ;Store the block type in front of the character to A.
LE75E:  RTS                     ;

;----------------------------------------------------------------------------------------------------

;The following table is used to calculate the block in front of character 1.

FrntBlkOfstTbl:
;              0   +16   0   -16  +16   0   -16   0
LE75F:  .byte $00, $10, $00, $F0, $10, $00, $F0, $00

;----------------------------------------------------------------------------------------------------

;The following table is used to change the direction of an NPC when talking to them.
;The index into the table is the player's character direction. The value in the table
;at the given index is the opposite direction as the player's character.

NPCDirTbl:
LE767:  .byte $00, $02, $01, $00, $08, $00, $00, $00, $04

;----------------------------------------------------------------------------------------------------

SelectWho:
LE770:  LDA CurPRGBank          ;Save the current active lower bank.
LE772:  PHA                     ;

LE773:  LDA #BANK_HELPERS1      ;Load Bank0B.
LE775:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE778:  JSR ShowWhoWnd          ;($B700)Show the WHO selection window.

LE77B:  PLA                     ;Restore previous lower bank.
LE77C:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE77F:  RTS                     ;

;----------------------------------------------------------------------------------------------------

LE780:  LDA CurPRGBank
LE782:  PHA
LE783:  LDA #BANK_HELPERS1
LE785:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE788:  JSR $BE00
LE78B:  PLA
LE78C:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE78F:  RTS

LE790:  LDA CharBlock
LE793:  CMP #BLK_SHRUB
LE795:  BEQ LE79B
LE797:  CMP #BLK_TREE
LE799:  BNE LE7A8
LE79B:  LDA #SFX_FOREST+INIT
LE79D:  STA ThisSFX
LE79F:  LDA CharBlock
LE7A2:  ASL
LE7A3:  ASL
LE7A4:  ASL
LE7A5:  JSR WaitSomeFrames      ;($E6D0)Wait some frames before continuing.
LE7A8:  LDA #$00
LE7AA:  STA $0600
LE7AD:  LDA ScreenBlocks,X
LE7B0:  AND #$10
LE7B2:  BNE LE800
LE7B4:  LDA ScreenBlocks,X
LE7B7:  CMP #BLK_WATER
LE7B9:  BEQ LE800
LE7BB:  CMP #BLK_MOUNTAIN
LE7BD:  BEQ LE7ED
LE7BF:  CMP #BLK_HWALL
LE7C1:  BEQ LE7ED
LE7C3:  CMP #BLK_VWALL
LE7C5:  BEQ LE7ED
LE7C7:  CMP #BLK_COUNTER
LE7C9:  BEQ LE7ED
LE7CB:  CMP #BLK_DOOR
LE7CD:  BNE LE7D5
LE7CF:  LDA MapProperties
LE7D1:  CMP #MAP_PROP_OV
LE7D3:  BNE LE7ED
LE7D5:  LDA MapProperties
LE7D7:  AND #MAP_MOON_PH
LE7D9:  BEQ LE7DE
LE7DB:  JMP LE85F
LE7DE:  LDA MapXPos
LE7E0:  BNE LE839
LE7E2:  LDA $48
LE7E4:  AND #$3F
LE7E6:  CMP #$3F
LE7E8:  BNE LE846
LE7EA:  JMP LE94F
LE7ED:  LDA #SFX_BLOCKED+INIT
LE7EF:  STA ThisSFX

LE7F1:  LDA #$08                ;Wait 8 frames.
LE7F3:  JSR WaitSomeFrames      ;($E6D0)Wait some frames before continuing.

LE7F6:  LDA Pad1Input
LE7F8:  AND #D_PAD
LE7FA:  STA Ch1Dir
LE7FC:  SEC
LE7FD:  LDA #$00
LE7FF:  RTS

LE800:  LDA #$01
LE802:  STA $0600
LE805:  LDA OnBoat
LE807:  BNE LE81C
LE809:  JSR ChkValidNPC         ;($C6EC)Check if valid NPC in front of player.
LE80C:  BCS LE7ED
LE80E:  LDA NPCSprIndex,Y
LE811:  CMP #$85
LE813:  BNE LE7ED
LE815:  LDA #$02
LE817:  STA OnBoat
LE819:  JMP LE920
LE81C:  LDA $D5
LE81E:  ASL
LE81F:  ASL
LE820:  STA $30
LE822:  LDA Pad1Input
LE824:  AND #D_PAD
LE826:  TAX
LE827:  LDA DirConvTbl,X
LE82A:  CLC
LE82B:  ADC $30
LE82D:  TAX
LE82E:  LDA $EA20,X
LE831:  BEQ LE836
LE833:  JSR WaitSomeFrames      ;($E6D0)Wait some frames before continuing.
LE836:  JMP LE7D5
LE839:  CMP #$3F
LE83B:  BNE LE846
LE83D:  LDA $48
LE83F:  AND #$3F
LE841:  BNE LE846
LE843:  JMP LE94F
LE846:  LDA MapYPos
LE848:  BNE LE855
LE84A:  LDA $47
LE84C:  AND #$3F
LE84E:  CMP #$3F
LE850:  BNE LE85F
LE852:  JMP LE94F
LE855:  CMP #$3F
LE857:  BNE LE85F
LE859:  LDA $47
LE85B:  AND #$3F
LE85D:  BEQ LE843
LE85F:  JSR LE983
LE862:  BCC LE8D9
LE864:  LDA NPCSprIndex,Y
LE867:  CMP #$1E
LE869:  BEQ LE872
LE86B:  CMP #$85
LE86D:  BEQ LE8D6
LE86F:  JMP LE7ED
LE872:  LDA MapProperties
LE874:  CMP #MAP_PROP_OV
LE876:  BNE LE8BC
LE878:  PLA
LE879:  PLA
LE87A:  LDA #$00
LE87C:  STA OnBoat
LE87E:  LDA #MAP_NPC_PRES
LE880:  STA MapProperties
LE882:  LDA MapXPos
LE884:  STA ReturnXPos
LE886:  STA BoatXPos
LE889:  LDA MapYPos
LE88B:  STA ReturnYPos
LE88D:  STA BoatYPos
LE890:  LDA #$23
LE892:  STA $03D7
LE895:  LDA #$0A
LE897:  STA $03D8
LE89A:  LDA #MAP_AMBROSIA
LE89C:  STA ThisMap
LE89E:  JSR LE9C2
LE8A1:  JSR LFD2D
LE8A4:  LDA #$EE
LE8A6:  PHA
LE8A7:  STA $30
LE8A9:  JSR LE66D
LE8AC:  LDA #$B4
LE8AE:  JSR WaitSomeFrames      ;($E6D0)Wait some frames before continuing.
LE8B1:  PLA
LE8B2:  CLC
LE8B3:  ADC #$01
LE8B5:  CMP #$F1
LE8B7:  BNE LE8A6
LE8B9:  JMP PrepLoadMap         ;($C146)Prepare to load a new map.
LE8BC:  PLA
LE8BD:  PLA
LE8BE:  LDA #MAP_PROP_OV
LE8C0:  STA MapProperties
LE8C2:  LDA BoatXPos
LE8C5:  STA ReturnXPos
LE8C7:  LDA BoatYPos
LE8CA:  STA ReturnYPos
LE8CC:  LDA #MAP_OVERWORLD
LE8CE:  STA ThisMap
LE8D0:  JSR LE9C2
LE8D3:  JMP PrepLoadMap         ;($C146)Prepare to load a new map.
LE8D6:  JMP LE8D9
LE8D9:  LDA $0600
LE8DC:  BNE LE920
LE8DE:  LDA OnBoat
LE8E0:  BEQ LE920
LE8E2:  LDA #$00
LE8E4:  STA OnBoat
LE8E6:  JSR LoadChrGFX          ;($EE4E)Load the sprite tiles for current party members.
LE8E9:  JSR _SetCharSprites     ;($FCD0)Set character sprites initial properties.
LE8EC:  JSR ZeroPartyTrail      ;($EFD6)Pile all characters on top of each other.
LE8EF:  JSR StartMusic          ;($FD6C)Determine which music to start playing.
LE8F2:  LDA MapXPos
LE8F4:  STA $047E
LE8F7:  LDA MapYPos
LE8F9:  STA $047F
LE8FC:  LDA #$85
LE8FE:  STA $047C
LE901:  LDA #$00
LE903:  STA $047D
LE906:  LDA MapXPos
LE908:  STA $03D7
LE90B:  LDA MapYPos
LE90D:  STA $03D8
LE910:  LDA MapProperties
LE912:  CMP #MAP_PROP_OV
LE914:  BNE LE920

LE916:  LDA MapXPos
LE918:  STA BoatXPos
LE91B:  LDA MapYPos
LE91D:  STA BoatYPos
LE920:  LDA #$01
LE922:  STA WorldUpdating
LE924:  LDX #$00
LE926:  LDA ScreenBlocks,X
LE929:  STA BlocksBuffer,X
LE92C:  INX
LE92D:  BNE LE926
LE92F:  LDA Pad1Input
LE931:  AND #D_PAD
LE933:  TAX
LE934:  LDA Ch3Dir
LE936:  STA Ch4Dir
LE938:  LDA Ch2Dir
LE93A:  STA Ch3Dir
LE93C:  LDA LastDirMoved
LE93E:  STA Ch2Dir
LE940:  STX Ch1Dir
LE942:  STX LastDirMoved
LE944:  STX ScrollDirAmt
LE946:  JSR LE9B2
LE949:  LDA #$00
LE94B:  STA WorldUpdating
LE94D:  CLC
LE94E:  RTS

LE94F:  LDA ThisMap
LE951:  CMP #MAP_SH_INT
LE953:  BCC LE96F

LE955:  SEC
LE956:  SBC #$15
LE958:  ASL
LE959:  TAY
LE95A:  LDA ShrineEntryTbl,Y
LE95D:  STA ReturnXPos
LE95F:  LDA ShrineEntryTbl+1,Y
LE962:  STA ReturnYPos
LE964:  PLA
LE965:  PLA
LE966:  LDA #MAP_AMBROSIA
LE968:  STA ThisMap
LE96A:  STA GenByte30
LE96C:  JMP SetRtnAndMapDat     ;($C153)Set the return coordinates and get map data.

LE96F:  PLA
LE970:  PLA
LE971:  LDA #MAP_OVERWORLD
LE973:  STA ThisMap
LE975:  LDA ExodusDead
LE977:  BEQ LE97C
LE979:  JMP LE3E7
LE97C:  LDA #$00
LE97E:  STA $E2
LE980:  JMP PrepLoadOvrwld      ;($C142)Prepare to load overworld map.

LE983:  LDA Pad1Input
LE985:  TAY
LE986:  LDA #$70
LE988:  STA $19
LE98A:  STA $18
LE98C:  JSR LCFA0
LE98F:  BCC LE9B0
LE991:  CPX #$40
LE993:  BCC LE9B0
LE995:  LDA $7304,X
LE998:  TXA
LE999:  CLC
LE99A:  ADC #$04
LE99C:  STA $30
LE99E:  LDY #$00
LE9A0:  LDA NPCOnscreen,Y
LE9A3:  CMP $30
LE9A5:  BEQ LE9AE
LE9A7:  INY
LE9A8:  INY
LE9A9:  INY
LE9AA:  INY
LE9AB:  JMP LE9A0
LE9AE:  SEC
LE9AF:  RTS
LE9B0:  CLC
LE9B1:  RTS
LE9B2:  LDA CurPRGBank
LE9B4:  PHA
LE9B5:  LDA #BANK_HELPERS1
LE9B7:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE9BA:  JSR $AFA0
LE9BD:  PLA
LE9BE:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LE9C1:  RTS

LE9C2:  LDA #MUS_NONE+INIT
LE9C4:  STA InitNewMusic
LE9C6:  LDA #DISABLE
LE9C8:  STA DisNPCMovement
LE9CA:  LDX #$14
LE9CC:  LDY #$2C
LE9CE:  JSR LC705
LE9D1:  LDA #$00
LE9D3:  STA $30
LE9D5:  LDY #$20
LE9D7:  LDA #$08
LE9D9:  JSR WaitSomeFrames      ;($E6D0)Wait some frames before continuing.
LE9DC:  LDX $30
LE9DE:  LDA $EA07,X
LE9E1:  TAX
LE9E2:  STX $7305
LE9E5:  INX
LE9E6:  STX $7309
LE9E9:  INX
LE9EA:  STX $730D
LE9ED:  INX
LE9EE:  STX $7311
LE9F1:  LDX $30
LE9F3:  LDA $EA0B,X
LE9F6:  STA Ch1Dir
LE9F8:  LDA $30
LE9FA:  CLC
LE9FB:  ADC #$01
LE9FD:  AND #$03
LE9FF:  STA $30
LEA01:  DEY
LEA02:  BNE LE9D7
LEA04:  STA DisNPCMovement
LEA06:  RTS

LEA07:  .byte $10, $18, $14, $1C, $08, $02, $04, $01, $70, $70, $78, $70, $70, $78, $78, $78

;----------------------------------------------------------------------------------------------------

;The following table converts character direction/D pad input and converts it to 0,1,2 or 3.
;Down -> 0, Up -> 1, Right -> 2, Left -> 3.

DirConvTbl:
LEA17:  .byte $00, $02, $03, $01, $00, $01, $01, $01, $01

;----------------------------------------------------------------------------------------------------

LEA20:  .byte $10, $30, $00, $00, $00, $00, $30, $10, $30, $10, $00, $00, $00, $00, $10, $30

;----------------------------------------------------------------------------------------------------

NMI:
LEA30:  PHA                     ;
LEA31:  TXA                     ;
LEA32:  PHA                     ;Save A, X and Y on the stack.
LEA33:  TYA                     ;
LEA34:  PHA                     ;

LEA35:  LDA PPUStatus           ;Clear vblank flag.

LEA38:  INC Increment0          ;Increment frame counters.
LEA3A:  INC Increment1          ;

LEA3C:  LDA CurPRGBank
LEA3E:  PHA
LEA3F:  LDA #BANK_HELPERS1
LEA41:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.

LEA44:  LDA WorldUpdating
LEA46:  BEQ +
LEA48:  JMP NMISpriteUpdate     ;($ECCF)Skip most NMI processing.

LEA4B:* LDA #$01
LEA4D:  STA WorldUpdating

LEA4F:  LDA CurPPUConfig0
LEA51:  AND #$7F
LEA53:  STA PPUControl0
LEA56:  LDA #$00
LEA58:  STA PPUControl1
LEA5B:  LDA DisSpriteAnim
LEA5D:  BNE LEA8C
LEA5F:  LDA DisNPCMovement
LEA61:  BEQ LEA6B
LEA63:  LDA DoAnimations
LEA65:  BNE LEA6B
LEA67:  LDA UpdatePPU
LEA69:  BNE LEA8C
LEA6B:  LDA $00
LEA6D:  AND #$7F
LEA6F:  CMP #$10
LEA71:  BEQ LEA8C
LEA73:  CMP #$50
LEA75:  BEQ LEA8C
LEA77:  LDA $0D
LEA79:  JSR $A1C0
LEA7C:  LDA $00
LEA7E:  AND #$0C
LEA80:  LSR
LEA81:  LSR
LEA82:  CLC
LEA83:  ADC #$01
LEA85:  STA $7301
LEA88:  LDA #$00
LEA8A:  STA $0D
LEA8C:  LDA DisNPCMovement
LEA8E:  BNE LEA9A
LEA90:  LDA DoAnimations
LEA92:  BEQ LEA9A
LEA94:  LDA $00
LEA96:  AND #$0F
LEA98:  BEQ LEA9D
LEA9A:  JMP LEB6D
LEA9D:  LDA TimeStopTimer
LEA9F:  AND #$7F
LEAA1:  BNE LEA9A
LEAA3:  LDA Increment0
LEAA5:  AND #$70
LEAA7:  BNE LEACA
LEAA9:  LDA #$1B
LEAAB:  STA PPUAddress
LEAAE:  LDA #$00
LEAB0:  STA PPUAddress
LEAB3:  LDX #$20
LEAB5:  JSR $9800
LEAB8:  LDA #$1B
LEABA:  STA PPUAddress
LEABD:  LDA #$20
LEABF:  STA PPUAddress
LEAC2:  LDX #$00
LEAC4:  JSR $9800
LEAC7:  JMP LEB77
LEACA:  CMP #$20
LEACC:  BNE LEAEF
LEACE:  LDA #$1B
LEAD0:  STA PPUAddress
LEAD3:  LDA #$10
LEAD5:  STA PPUAddress
LEAD8:  LDX #$30
LEADA:  JSR $9800
LEADD:  LDA #$1B
LEADF:  STA PPUAddress
LEAE2:  LDA #$30
LEAE4:  STA PPUAddress
LEAE7:  LDX #$10
LEAE9:  JSR $9800
LEAEC:  JMP LEB77
LEAEF:  CMP #$40
LEAF1:  BNE LEB14
LEAF3:  LDA #$1B
LEAF5:  STA PPUAddress
LEAF8:  LDA #$00
LEAFA:  STA PPUAddress
LEAFD:  LDX #$00
LEAFF:  JSR $9800
LEB02:  LDA #$1B
LEB04:  STA PPUAddress
LEB07:  LDA #$20
LEB09:  STA PPUAddress
LEB0C:  LDX #$20
LEB0E:  JSR $9800
LEB11:  JMP LEB77
LEB14:  CMP #$60
LEB16:  BNE LEB39
LEB18:  LDA #$1B
LEB1A:  STA PPUAddress
LEB1D:  LDA #$10
LEB1F:  STA PPUAddress
LEB22:  LDX #$10
LEB24:  JSR $9800
LEB27:  LDA #$1B
LEB29:  STA PPUAddress
LEB2C:  LDA #$30
LEB2E:  STA PPUAddress
LEB31:  LDX #$30
LEB33:  JSR $9800
LEB36:  JMP LEB77
LEB39:  TAX
LEB3A:  LDA MapProperties
LEB3C:  CMP #MAP_PROP_OV
LEB3E:  BNE LEB77
LEB40:  TXA
LEB41:  CMP #$10
LEB43:  BNE LEB57
LEB45:  LDA #$1B
LEB47:  STA PPUAddress
LEB4A:  LDA #$80
LEB4C:  STA PPUAddress
LEB4F:  LDX #$00
LEB51:  JSR $9840
LEB54:  JMP LEB77
LEB57:  CMP #$50
LEB59:  BNE LEB77
LEB5B:  LDA #$1B
LEB5D:  STA PPUAddress
LEB60:  LDA #$80
LEB62:  STA PPUAddress
LEB65:  LDX #$40
LEB67:  JSR $9840
LEB6A:  JMP LEB77
LEB6D:  LDA UpdatePPU
LEB6F:  BEQ LEB77
LEB71:  JSR $A200
LEB74:  JMP LEB7E
LEB77:  LDA #$00
LEB79:  STA $BC
LEB7B:  JSR $A280

LEB7E:  LDA ExodusDead
LEB80:  CMP #GME_EX_DEAD
LEB82:  BNE UpdatePPUScroll

DoEndEscape:
LEB84:  LDX $00
LEB86:  LDA $D000,X
LEB89:  TAX
LEB8A:  AND #$07
LEB8C:  STA $4E
LEB8E:  LDA $E000,X
LEB91:  AND #$07
LEB93:  STA $4D
LEB95:  LDA NTXPosLB
LEB97:  CLC
LEB98:  ADC $4E
LEB9A:  STA PPUScroll
LEB9D:  CLC
LEB9E:  LDA NTYPosLB
LEBA0:  ADC $4D
LEBA2:  STA PPUScroll
LEBA5:  INC EndGmTimerLB
LEBA7:  BNE +

LEBA9:  INC EndGmTimerUB
LEBAB:  LDA EndGmTimerUB
LEBAD:  CMP #$0F
LEBAF:  BNE +

LEBB1:  LDA #GME_LOST           ;
LEBB3:  STA ExodusDead          ;End game timer has expired. Indicate the game has been lost.
LEBB5:  JMP +                   ;

UpdatePPUScroll:
LEBB8:  LDA NTXPosLB            ;
LEBBA:  STA PPUScroll           ;Update the scroll registers.
LEBBD:  LDA NTYPosLB            ;
LEBBF:  STA PPUScroll           ;

UpdatePPUConfig:
LEBC2:* LDA CurPPUConfig1
LEBC4:  STA PPUControl1
LEBC7:  LDA CurPPUConfig0
LEBC9:  STA PPUControl0

LEBCC:  LDA ScrollDirAmt
LEBCE:  BEQ LEBDF
LEBD0:  LDA ExodusDead
LEBD2:  CMP #GME_WON
LEBD4:  BNE LEBDC
LEBD6:  LDA $00
LEBD8:  AND #$03
LEBDA:  BNE LEBDF
LEBDC:  JSR $A300
LEBDF:  LDA IgnoreInput
LEBE1:  BNE LEBF4
LEBE3:  LDA Pad1Input
LEBE5:  PHA
LEBE6:  JSR GetInput            ;($A500)Get controller inputs.
LEBE9:  PLA
LEBEA:  EOR Pad1Input
LEBEC:  STA InputChange
LEBEE:  BEQ LEBF4
LEBF0:  LDA #$00
LEBF2:  STA $01
LEBF4:  LDA MapProperties
LEBF6:  AND #MAP_TURN
LEBF8:  BEQ LEC41
LEBFA:  LDA $00
LEBFC:  AND #$07
LEBFE:  BEQ LEC03
LEC00:  JMP LEC51
LEC03:  LDA FightTurnIndex
LEC05:  CMP #$04
LEC07:  BCS LEC51
LEC09:  ASL
LEC0A:  ASL
LEC0B:  ASL
LEC0C:  ASL
LEC0D:  TAX
LEC0E:  LDA ScrollDirAmt
LEC10:  BNE LEC1C
LEC12:  LDA CurPieceYVis
LEC14:  EOR #$01
LEC16:  STA CurPieceYVis
LEC18:  AND #$01
LEC1A:  BNE LEC30
LEC1C:  LDA CurPieceYVis
LEC1E:  STA $7304,X
LEC21:  STA $730C,X
LEC24:  CLC
LEC25:  ADC #$08
LEC27:  STA $7308,X
LEC2A:  STA $7310,X
LEC2D:  JMP LEC51
LEC30:  LDA #SPRT_HIDE
LEC32:  STA $7304,X
LEC35:  STA $7308,X
LEC38:  STA $730C,X
LEC3B:  STA $7310,X
LEC3E:  JMP LEC51
LEC41:  LDA DoAnimations
LEC43:  BEQ LEC4B
LEC45:  LDA MapProperties
LEC47:  CMP #$09
LEC49:  BNE +
LEC4B:  JMP LECCB
LEC4E:* JSR $9C00
LEC51:  LDA $00
LEC53:  AND #$0F
LEC55:  BEQ LEC5A
LEC57:  JMP LECCB
LEC5A:  LDA $00
LEC5C:  AND #$10
LEC5E:  LSR
LEC5F:  LSR
LEC60:  STA $7305
LEC63:  STA $7315
LEC66:  STA $7325
LEC69:  STA $7335
LEC6C:  LDY Ch1Dir
LEC6E:  LDX #$00
LEC70:  LDA #$10
LEC72:  STA $4E
LEC74:  JSR $9880
LEC77:  LDY Ch2Dir
LEC79:  LDX #$10
LEC7B:  LDA #$30
LEC7D:  STA $4E
LEC7F:  JSR $9880
LEC82:  LDY Ch3Dir
LEC84:  LDX #$20
LEC86:  LDA #$50
LEC88:  STA $4E
LEC8A:  JSR $9880
LEC8D:  LDY Ch4Dir
LEC8F:  LDX #$30
LEC91:  LDA #$70
LEC93:  STA $4E
LEC95:  JSR $9880
LEC98:  LDA TimeStopTimer
LEC9A:  AND #$7F
LEC9C:  BNE LECCB
LEC9E:  LDA #$04
LECA0:  STA $4D
LECA2:  LDA #$90
LECA4:  STA $4E
LECA6:  LDA #$40
LECA8:  STA $BC
LECAA:  LDY $4D
LECAC:  LDA $007E,Y
LECAF:  TAY
LECB0:  LDX $BC
LECB2:  JSR $98C0
LECB5:  INC $4D
LECB7:  CLC
LECB8:  LDA $4E
LECBA:  ADC #$08
LECBC:  STA $4E
LECBE:  CLC
LECBF:  LDA $BC
LECC1:  ADC #$10
LECC3:  STA $BC
LECC5:  LDA $4D
LECC7:  CMP #$0C
LECC9:  BNE LECAA
LECCB:  LDA #$00
LECCD:  STA WorldUpdating

NMISpriteUpdate:
LECCF:  JSR UpdateSpriteRAM     ;($9900)Move sprite buffer data into sprite RAM.

LECD2:  LDX #BANK_SFX           ;Prepare to update music from the second SFX bank.

LECD4:  LDA InitNewMusic        ;
LECD6:  AND #$7F                ;Is the current music data located in the SFX bank?
LECD8:  CMP #MUS_INTRO          ;If so, branch.
LECDA:  BCS +                   ;

LECDC:  LDX #BANK_MUSIC         ;Current music data is in the first music bank.
LECDE:* TXA                     ;
LECDF:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.

LECE2:  LDA InitNewMusic        ;Does new music need to be initialized?
LECE4:  BPL +                   ;If not, branch.

LECE6:  AND #$7F                ;Remove MSB to indicate the new music is initialized.
LECE8:  STA InitNewMusic        ;
LECEA:  JSR InitMusic           ;($8000)Initialize music.

LECED:* JSR UpdateMusic         ;($8100)Update current music being played.

;----------------------------------------------------------------------------------------------------

DoSFX:
LECF0:  LDA #BANK_SFX           ;Switch to the SFX handling bank #$09.
LECF2:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.

LECF5:  LDA ThisSFX             ;Load the current SFX to play.
LECF7:  BPL +                   ;Has it been previously playing? If so, branch.
LECF9:  AND #$7F                ;Remove initialization flag.
LECFB:  STA ThisSFX             ;

LECFD:  JSR InitSFX             ;($A000)Start new SFX.
LED00:* JSR UpdateSFX           ;($A100)Update current SFX.

LED03:  PLA                     ;Load previous lower bank.
LED04:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.

LED07:  PLA                     ;
LED08:  TAY                     ;
LED09:  PLA                     ;Restore the A, X and Y registers and end the VBlank interrupt.
LED0A:  TAX                     ;
LED0B:  PLA                     ;
LED0C:  RTI                     ;

;----------------------------------------------------------------------------------------------------

LED0D:  LDA CurPRGBank
LED0F:  PHA
LED10:  LDA #BANK_NPCS
LED12:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LED15:  LDY #$00
LED17:  LDA ($4D),Y
LED19:  STA $7580,Y
LED1C:  INY
LED1D:  CPY #$80
LED1F:  BNE LED17
LED21:  PLA
LED22:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LED25:  RTS

LED26:  .byte $00, $01, $00, $FF, $01, $00, $FF, $00, $01, $02, $04, $08

;----------------------------------------------------------------------------------------------------

IRQ:
LED32:  RTI                     ;Always immediately exit an IRQ.

;----------------------------------------------------------------------------------------------------

LED33:  LDY #$00
LED35:* LDA ($29),Y
LED37:  STA $7500,Y
LED3A:  INY
LED3B:  CPY #$20
LED3D:  BNE -

LoadPPUPalData:
LED3F:  LDA #$20
LED41:  JSR SetPPUBufNewSize    ;($F079)Update length of data in PPU buffer.
LED44:  LDA #$3F
LED46:  STA PPUBufBase,X
LED49:  INX
LED4A:  LDA #$00
LED4C:  STA PPUBufBase,X

LED4F:  LDY #$00

LED51:* LDA ($29),Y
LED53:  INX
LED54:  STA PPUBufBase,X
LED57:  INY
LED58:  CPY #$20
LED5A:  BNE -

LED5C:  LDA #$01
LED5E:  JSR SetPPUBufNewSize    ;($F079)Update length of data in PPU buffer.

LED61:  LDA #$00
LED63:  STA PPUBufBase,X
LED66:  INX
LED67:  LDA #$00
LED69:  STA PPUBufBase,X
LED6C:  INX
LED6D:  LDA #$00
LED6F:  STA PPUBufBase,X
LED72:  JSR SetPPUUpdate        ;($F0B4)Check if PPU update flag needs to be set.
LED75:  RTS

;----------------------------------------------------------------------------------------------------

LoadAlphaNumMaps:
LED76:  LDA CurPRGBank          ;Save the current lower PRG bank.
LED78:  PHA                     ;

LED79:  LDA #BANK_MISC_GFX      ;Load the misc. graphics bank.
LED7B:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.

;Load character set and overhead map tiles.
LED7E:  LDA #>GFXCharacterSet   ;
LED80:  STA PPUSrcPtrUB         ;Get a pointer to the character set and overhead map tiles.
LED82:  LDA #<GFXCharacterSet   ;
LED84:  STA PPUSrcPtrLB         ;

LED86:  LDA #PPU_PT1_UB         ;
LED88:  STA PPUDstPtrUB         ;Prepare to fill pattern table 1.
LED8A:  LDA #PPU_PT1_LB         ;
LED8C:  STA PPUDstPtrLB         ;

LED8E:  LDA #$10                ;
LED90:  STA PPUByteCntUB        ;Prepare to load 4096 bytes.
LED92:  LDA #$00                ;The entire pattern table 1.
LED94:  STA PPUByteCntLB        ;

LED96:  JSR LoadPPU             ;($EFE3)Load values into PPU.

;Load unique tiles for overworld map.
LED99:  LDA ThisMap             ;Is this the overworld map?
LED9B:  BNE ChkAmbrosiaMap      ;If not, branch to check other maps.

LED9D:  LDA #>GFXSnakeBack      ;
LED9F:  STA PPUSrcPtrUB         ;Get a pointer to the snake back tiles.
LEDA1:  LDA #<GFXSnakeBack      ;
LEDA3:  STA PPUSrcPtrLB         ;

LEDA5:  LDA #$1C                ;
LEDA7:  STA PPUDstPtrUB         ;Destination is PT1 starting tile $C4.
LEDA9:  LDA #$40                ;
LEDAB:  STA PPUDstPtrLB         ;

LEDAD:  LDA #$00                ;
LEDAF:  STA PPUByteCntUB        ;Copy 64 bytes to the PPU.
LEDB1:  LDA #$40                ;
LEDB3:  STA PPUByteCntLB        ;

LEDB5:  JSR LoadPPU             ;($EFE3)Load values into PPU.

LEDB8:  LDA #$40                ;
LEDBA:  STA PPUSrcPtrLB         ;Copy the snake back tiles to the PPU.
LEDBC:  LDA #$1D                ;
LEDBE:  STA PPUDstPtrUB         ;

LEDC0:  JSR LoadPPU             ;($EFE3)Load values into PPU.
LEDC3:  JMP EndLoadMap          ;($EE1E)Finish loading map GFX.

;Load unique tiles for Ambrosia map.
ChkAmbrosiaMap:
LEDC6:  CMP #MAP_AMBROSIA       ;Is the current map Ambrosia?
LEDC8:  BNE ChkLBCastleMap      ;If not, branch to check other maps.

LEDCA:  LDA #$8E
LEDCC:  STA PPUSrcPtrUB
LEDCE:  LDA #$40
LEDD0:  STA PPUSrcPtrLB

LEDD2:  LDA #$1D
LEDD4:  STA PPUDstPtrUB
LEDD6:  LDA #$C0
LEDD8:  STA PPUDstPtrLB

LEDDA:  LDA #$00
LEDDC:  STA PPUByteCntUB
LEDDE:  LDA #$40
LEDE0:  STA PPUByteCntLB

LEDE2:  JSR LoadPPU             ;($EFE3)Load values into PPU.

LEDE5:  LDA #$B1
LEDE7:  STA PPUSrcPtrUB
LEDE9:  LDA #$80
LEDEB:  STA PPUSrcPtrLB

LEDED:  LDA #$1D
LEDEF:  STA PPUDstPtrUB
LEDF1:  LDA #$80
LEDF3:  STA PPUDstPtrLB

LEDF5:  JSR LoadPPU             ;($EFE3)Load values into PPU.
LEDF8:  JMP EndLoadMap          ;($EE1E)Finish loading map GFX.

;Load unique tiles for Lord British and Exodus castles.
ChkLBCastleMap:
LEDFB:  CMP #MAP_LB_CSTL
LEDFD:  BEQ +

LEDFF:  CMP #MAP_EXODUS
LEE01:  BNE EndLoadMap

LEE03:* LDA #>GFXForceField
LEE05:  STA PPUSrcPtrUB
LEE07:  LDA #<GFXForceField
LEE09:  STA PPUSrcPtrLB

LEE0B:  LDA #$1D
LEE0D:  STA PPUDstPtrUB
LEE0F:  LDA #$C0
LEE11:  STA PPUDstPtrLB

LEE13:  LDA #$00
LEE15:  STA PPUByteCntUB
LEE17:  LDA #$40
LEE19:  STA PPUByteCntLB

LEE1B:  JSR LoadPPU             ;($EFE3)Load values into PPU.

EndLoadMap:
LEE1E:  PLA                     ;Restore A from stack before exiting.
LEE1F:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LEE22:  RTS                     ;

;----------------------------------------------------------------------------------------------------

SwapBnkLdGFX:
LEE23:  LDA CurPRGBank          ;Save current lower bank.
LEE25:  PHA                     ;

LEE26:  JSR LoadChrGFX          ;($EE4E)Load the sprite tiles for current party members.

LEE29:  PLA                     ;Restore lower bank.
LEE2A:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LEE2D:  RTS                     ;

;----------------------------------------------------------------------------------------------------

LEE2E:  LDA #BANK_MISC_GFX
LEE30:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.

LEE33:  LDA #$A0
LEE35:  STA $2A
LEE37:  LDA #$00
LEE39:  STA $29
LEE3B:  LDA #$00
LEE3D:  STA $2C
LEE3F:  LDA #$00
LEE41:  STA $2B
LEE43:  LDA #$10
LEE45:  STA $2E
LEE47:  LDA #$00
LEE49:  STA $2D
LEE4B:  JSR LoadPPU             ;($EFE3)Load values into PPU.

;----------------------------------------------------------------------------------------------------

LoadChrGFX:
LEE4E:  LDA MapProperties
LEE50:  AND #MAP_TURN
LEE52:  BNE LEE6A
LEE54:  LDA OnBoat
LEE56:  BMI LEE5D
LEE58:  BEQ LEE5D
LEE5A:  JMP LEEF0

LEE5D:  LDA MapProperties
LEE5F:  AND #MAP_TURN
LEE61:  BNE LEE6A
LEE63:  LDA OnHorse
LEE65:  BPL LEE6A
LEE67:  JMP LEF28

LEE6A:  LDA #BANK_CHARS
LEE6C:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LEE6F:  LDA #$01
LEE71:  STA $2C
LEE73:  LDA #$00
LEE75:  STA $2B
LEE77:  LDA #$02
LEE79:  STA $2E
LEE7B:  LDA #$00
LEE7D:  STA $2D
LEE7F:  LDA #$00
LEE81:  STA $30
LEE83:  LDA $30
LEE85:  ASL
LEE86:  TAX
LEE87:  LDA ChrPtrBaseLB,X
LEE89:  STA CrntChrPtrLB
LEE8B:  LDA ChrPtrBaseUB,X
LEE8D:  STA CrntChrPtrUB
LEE8F:  LDY #CHR_CLASS
LEE91:  LDA (CrntChrPtr),Y
LEE93:  ASL
LEE94:  CLC
LEE95:  ADC #$80
LEE97:  STA $2A
LEE99:  LDA #$00
LEE9B:  STA $29
LEE9D:  JSR LoadPPU             ;($EFE3)Load values into PPU.
LEEA0:  LDY #CHR_CLASS
LEEA2:  LDA (CrntChrPtr),Y
LEEA4:  TAX
LEEA5:  LDA $EF5A,X
LEEA8:  TAX
LEEA9:  LDA $30
LEEAB:  ASL
LEEAC:  ASL
LEEAD:  ASL
LEEAE:  ASL
LEEAF:  CLC
LEEB0:  ADC #$04
LEEB2:  TAY
LEEB3:  TXA
LEEB4:  LDX #$04
LEEB6:  STA $7302,Y
LEEB9:  INY
LEEBA:  INY
LEEBB:  INY
LEEBC:  INY
LEEBD:  DEX
LEEBE:  BNE LEEB6
LEEC0:  CLC
LEEC1:  LDA $2C
LEEC3:  ADC #$02
LEEC5:  STA $2C
LEEC7:  INC $30
LEEC9:  LDA $30
LEECB:  CMP #$04
LEECD:  BNE LEE83
LEECF:  LDX #$00
LEED1:  LDA #SPRT_HIDE
LEED3:  STA SpriteBuffer,X
LEED6:  INX
LEED7:  LDA #$00
LEED9:  STA SpriteBuffer,X
LEEDC:  INX
LEEDD:  STA SpriteBuffer,X
LEEE0:  INX
LEEE1:  STA SpriteBuffer,X
LEEE4:  LDA MapBank
LEEE6:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LEEE9:  LDA OnBoat
LEEEB:  AND #$7F
LEEED:  STA OnBoat
LEEEF:  RTS

LEEF0:  LDA #BANK_NPCS
LEEF2:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LEEF5:  LDA #$8A
LEEF7:  STA $2A
LEEF9:  LDA #$00
LEEFB:  STA $29
LEEFD:  LDA #$01
LEEFF:  STA $2C
LEF01:  LDA #$00
LEF03:  STA $2B
LEF05:  LDA #$02
LEF07:  STA $2E
LEF09:  LDA #$00
LEF0B:  STA $2D
LEF0D:  JSR LoadPPU             ;($EFE3)Load values into PPU.
LEF10:  JMP LEECF
LEF13:  LDA CurPRGBank
LEF15:  PHA
LEF16:  JSR LoadChrGFX          ;($EE4E)Load the sprite tiles for current party members.
LEF19:  LDA ScrollDirAmt
LEF1B:  BNE LEF19
LEF1D:  JSR _SetCharSprites     ;($FCD0)Set character sprites initial properties.
LEF20:  JSR ZeroPartyTrail      ;($EFD6)Pile all characters on top of each other.
LEF23:  PLA
LEF24:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LEF27:  RTS

LEF28:  LDA #BANK_SFX
LEF2A:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.

LEF2D:  LDA #$01
LEF2F:  STA PPUDstPtrUB
LEF31:  LDA #$00
LEF33:  STA PPUDstPtrLB
LEF35:  LDA #$02
LEF37:  STA PPUByteCntUB
LEF39:  LDA #$00
LEF3B:  STA PPUByteCntLB
LEF3D:  LDA #$B8
LEF3F:  STA PPUSrcPtrUB
LEF41:  LDA #$00
LEF43:  STA PPUSrcPtrLB
LEF45:  LDA #$04
LEF47:  STA $30
LEF49:  JSR LoadPPU             ;($EFE3)Load values into PPU.

LEF4C:  INC $2C
LEF4E:  INC $2C
LEF50:  DEC $30
LEF52:  BNE LEF49
LEF54:  LDA MapBank
LEF56:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LEF59:  RTS

LEF5A:  .byte $00, $03, $00, $01, $03, $01, $01, $03, $00, $00, $01

LEF65:  LDA #BANK_CHARS
LEF67:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LEF6A:  LDA #$80
LEF6C:  STA $2A
LEF6E:  LDA #$00
LEF70:  STA $29
LEF72:  LDA #$01
LEF74:  STA $2C
LEF76:  LDA #$00
LEF78:  STA $2B
LEF7A:  LDA #$08
LEF7C:  STA $2E
LEF7E:  LDA #$00
LEF80:  STA $2D
LEF82:  JSR LoadPPU             ;($EFE3)Load values into PPU.
LEF85:  LDA #$88
LEF87:  STA $2A
LEF89:  LDA #$09
LEF8B:  STA $2C
LEF8D:  LDA #$00
LEF8F:  STA $2E
LEF91:  LDA #$80
LEF93:  STA $2D
LEF95:  LDA #$07
LEF97:  PHA
LEF98:  JSR LoadPPU             ;($EFE3)Load values into PPU.
LEF9B:  CLC
LEF9C:  LDA $2A
LEF9E:  ADC #$02
LEFA0:  STA $2A
LEFA2:  CLC
LEFA3:  LDA $2B
LEFA5:  ADC #$80
LEFA7:  STA $2B
LEFA9:  LDA $2C
LEFAB:  ADC #$00
LEFAD:  STA $2C
LEFAF:  PLA
LEFB0:  SEC
LEFB1:  SBC #$01
LEFB3:  BNE LEF97
LEFB5:  LDA #BANK_NPCS
LEFB7:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LEFBA:  LDA #$80
LEFBC:  STA $2A
LEFBE:  LDA #$00
LEFC0:  STA $29
LEFC2:  JSR LoadPPU             ;($EFE3)Load values into PPU.
LEFC5:  RTS

LEFC6:  LDA CurPRGBank
LEFC8:  PHA
LEFC9:  LDA #BANK_HELPERS1
LEFCB:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LEFCE:  JSR $B880
LEFD1:  PLA
LEFD2:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LEFD5:  RTS

;----------------------------------------------------------------------------------------------------

ZeroPartyTrail:
LEFD6:  LDA #$00                ;
LEFD8:  STA Ch1Dir              ;
LEFDA:  STA Ch2Dir              ;
LEFDC:  STA Ch3Dir              ;Place all party members on top of each other.
LEFDE:  STA Ch4Dir              ;
LEFE0:  STA LastDirMoved        ;
LEFE2:  RTS                     ;

;----------------------------------------------------------------------------------------------------

;Loads a string of bytes into the PPU. The following pointers and counters are used:
;Pointer $29-Source address of PPU data.
;Pointer $2B-Destination address in the PPU.
;16-bit counter $2D-Number of bytes to load into the PPU.

LoadPPU:
LEFE3:  LDA DisSpriteAnim
LEFE5:  PHA
LEFE6:  LDA TextIndex
LEFE8:  PHA
LEFE9:  LDA $2F
LEFEB:  PHA
LEFEC:  LDA PPUSrcPtrUB
LEFEE:  PHA
LEFEF:  LDA PPUSrcPtrLB
LEFF1:  PHA
LEFF2:  LDA PPUDstPtrUB
LEFF4:  PHA
LEFF5:  LDA PPUDstPtrLB
LEFF7:  PHA
LEFF8:  LDA PPUByteCntUB
LEFFA:  PHA
LEFFB:  LDA PPUByteCntLB
LEFFD:  PHA
LEFFE:  LDA CurPPUConfig1
LF000:  PHA
LF001:  LDA WorldUpdating
LF003:  PHA

LF004:  LDA #SCREEN_OFF         ;Turn the screen off.
LF006:  STA CurPPUConfig1       ;
 
LF008:  LDA #$02                ;Wait 2 frames before continuing.
LF00A:  JSR WaitSomeFrames      ;($E6D0)Wait some frames before continuing.

LF00D:  LDA #$01
LF00F:  STA DisSpriteAnim
LF011:  STA WorldUpdating

LF013:  LDA $2C
LF015:  STA PPUAddress
LF018:  LDA $2B
LF01A:  STA PPUAddress

LF01D:  LDY #$00
LF01F:  LDX $2D
LF021:  BEQ LF039

LF023:* LDA (PPUSrcPtr),Y
LF025:  STA PPUIOReg
LF028:  INY
LF029:  DEX
LF02A:  BNE -

LF02C:  CLC
LF02D:  LDA $2D
LF02F:  ADC $29
LF031:  STA $29

LF033:  LDA #$00
LF035:  ADC $2A
LF037:  STA $2A

LF039:  LDA $2E
LF03B:  BEQ FinishPPULoad

LF03D:  LDY #$00

LF03F:* LDA ($29),Y
LF041:  STA PPUIOReg
LF044:  INY
LF045:  BNE -

LF047:  INC $2A
LF049:  DEC $2E
LF04B:  BNE -

FinishPPULoad:
LF04D:  LDA NTXPosLB
LF04F:  STA PPUScroll
LF052:  LDA NTYPosLB
LF054:  STA PPUScroll
LF057:  PLA
LF058:  STA WorldUpdating
LF05A:  PLA
LF05B:  STA CurPPUConfig1
LF05D:  PLA
LF05E:  STA PPUByteCntLB
LF060:  PLA
LF061:  STA PPUByteCntUB
LF063:  PLA
LF064:  STA PPUDstPtrLB
LF066:  PLA
LF067:  STA PPUDstPtrUB
LF069:  PLA
LF06A:  STA PPUSrcPtrLB
LF06C:  PLA
LF06D:  STA PPUSrcPtrUB
LF06F:  PLA
LF070:  STA $2F
LF072:  PLA
LF073:  STA TextIndex
LF075:  PLA
LF076:  STA DisSpriteAnim
LF078:  RTS

;----------------------------------------------------------------------------------------------------

SetPPUBufNewSize:
LF079:  PHA                     ;Save A on the stack.
LF07A:  CLC                     ;
LF07B:  ADC PPUBufLength        ;Update the buffer length by adding A to it.
LF07E:  BCS WaitForPPUUpdate    ;Branch if buffer length has exceeded 256 bytes.

LF080:  TAX                     ;
LF081:  LDA DisSpriteAnim       ;Are animations and NPC movements disabled?
LF083:  ORA DisNPCMovement      ;If so, branch. Buffer might be big.
LF085:  BEQ ChkBufLen20         ;

LF087:  TXA                     ;Is the PPU buffer currently over 96 bytes in length?
LF088:  CMP #$60                ;If so, wait for the buffer to be emptied.
LF08A:  BCC UpdatePPUBufLen     ;

LF08C:  JMP WaitForPPUUpdate   ;($F094)Wait for the next PPU update to complete.

ChkBufLen20:
LF08F:  TXA                     ;Is the buffer under 32 bytes of data?
LF090:  CMP #$20                ;If so, branch to update buffer length.
LF092:  BCC UpdatePPUBufLen     ;

WaitForPPUUpdate:
LF094:  LDA #$01                ;Indicate the PPU needs to update.
LF096:  STA UpdatePPU           ;

LF098:* LDA UpdatePPU           ;Wait until the PPU is updated.
LF09A:  BNE -                   ;

UpdatePPUBufLen:
LF09C:  LDA #$00                ;Clear PPU update flag.
LF09E:  STA UpdatePPU           ;

LF0A0:  LDX PPUBufLength        ;Set the index to the next available spot in the PPU buffer.
LF0A3:  INX                     ;

LF0A4:  CLC                     ;
LF0A5:  PLA                     ;
LF0A6:  ADC #$02                ;Set the PPU string length. Add 2 for the PPU destination address.
LF0A8:  STA PPUBufBase,X        ;
LF0AB:  INX                     ;

LF0AC:  SEC                     ;
LF0AD:  ADC PPUBufLength        ;Add thei PPU string length to the total PPU buffer length.
LF0B0:  STA PPUBufLength        ;
LF0B3:  RTS                     ;

;----------------------------------------------------------------------------------------------------

SetPPUUpdate:
LF0B4:  LDA PPUBufLength        ;
LF0B7:  BEQ +                   ;Is there data in the PPU buffer?
LF0B9:  LDA #$01                ;If so, set the flag indicating the PPU needs to be updated.
LF0BB:  STA UpdatePPU           ;
LF0BD:* RTS                     ;

;----------------------------------------------------------------------------------------------------

DisplayText:
LF0BE:  LDA CurPRGBank          ;Save current PRG bank on the stack.
LF0C0:  PHA                     ;

LF0C1:  LDA #BANK_TEXT          ;Load the text PRG bank ito lower memory.
LF0C3:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.

LF0C6:  LDA HideUprSprites      ;Store a copy of the hide upper sprites value.
LF0C8:  STA GenByte25           ;

LF0CA:  JSR DoHideUprSprites    ;($F41C)Hide upper sprites.
LF0CD:  LDA TXTXPos
LF0CF:  STA $AB
LF0D1:  LDA TXTYPos
LF0D3:  STA $AC
LF0D5:  LDA #$00
LF0D7:  STA $AD
LF0D9:  STA $AE
LF0DB:  LDA TextIndex
LF0DD:  CMP #TXT_DBL_SPACE
LF0DF:  BEQ TxtBufAlreadyFilled
LF0E1:  CMP #TXT_SNGL_SPACE
LF0E3:  BNE ShowTextString

TxtBufAlreadyFilled:
LF0E5:  LDA #>TextBuffer
LF0E7:  STA TextCharPtrUB
LF0E9:  LDA #<TextBuffer
LF0EB:  STA TextCharPtrLB
LF0ED:  JMP LF11A

ShowTextString:
LF0F0:  ASL
LF0F1:  BCC LF104
LF0F3:  INC $8C
LF0F5:  TAY
LF0F6:  LDA (TextBasePtr),Y
LF0F8:  STA TextCharPtrLB
LF0FA:  INY
LF0FB:  LDA (TextBasePtr),Y
LF0FD:  STA TextCharPtrUB
LF0FF:  DEC TextBasePtrUB
LF101:  JMP LF10E

LF104:  TAY
LF105:  LDA (TextBasePtr),Y
LF107:  STA TextCharPtrLB
LF109:  INY
LF10A:  LDA (TextBasePtr),Y
LF10C:  STA TextCharPtrUB

LF10E:  JSR PrepUncompress      ;($FDB4)Prepare to uncompress a string of text.
LF111:  BCC +                   ;Was this a one time text that needs to show the alternate text?
LF113:  INC TextIndex           ;If so, increment the text index and get
LF115:  LDA TextIndex           ;the next text string instead.
LF117:  JMP ShowTextString      ;($F0F0)Get a text string to show on the screen.

LF11A:* LDA NTYPosLB
LF11C:  LSR
LF11D:  LSR
LF11E:  LSR
LF11F:  CLC
LF120:  ADC TXTYPos
LF122:  CMP #$1E
LF124:  BCC LF129

LF126:  SEC
LF127:  SBC #$1E

LF129:  STA $18

LF12B:  LDA NTXPosUB
LF12D:  LSR
LF12E:  LDA NTXPosLB
LF130:  ROR
LF131:  LSR
LF132:  LSR
LF133:  CLC
LF134:  ADC TXTXPos
LF136:  AND #$3F

LF138:  STA $19

LF13A:  LDX #$20
LF13C:  CMP #$20
LF13E:  BCC LF142

LF140:  LDX #$24

LF142:  TXA
LF143:  PHA
LF144:  LDA $18
LF146:  STA $2A
LF148:  LDA #$00
LF14A:  STA $29
LF14C:  LSR $2A
LF14E:  ROR $29
LF150:  LSR $2A
LF152:  ROR $29
LF154:  LSR $2A
LF156:  ROR $29
LF158:  CLC
LF159:  LDA $19
LF15B:  AND #$1F
LF15D:  ADC $29
LF15F:  STA $29
LF161:  STA $26

LF163:  PLA
LF164:  ADC $2A
LF166:  STA $2A
LF168:  STA $27
LF16A:  LDA $19
LF16C:  STA $21
LF16E:  LDA $18
LF170:  STA $20
LF172:  LDA $2E
LF174:  STA $2C
LF176:  LDA $2D
LF178:  STA $2B
LF17A:  LDY #$00
LF17C:  STY $17
LF17E:  STY $1A
LF180:  JSR LF454
LF183:  LDA $2A
LF185:  STA PPUBufBase,X
LF188:  INX
LF189:  LDA $29
LF18B:  STA PPUBufBase,X

LF18E:  LDA $17
LF190:  BEQ LF195
LF192:  JMP LF2BE

LF195:  LDA (TextCharPtr),Y
LF197:  CMP #TXT_END
LF199:  BNE LF19E
LF19B:  JMP LF2BA
LF19E:  CMP #TXT_NEWLINE
LF1A0:  BNE LF1A5
LF1A2:  JMP LF2BE
LF1A5:  CMP #TXT_ONE
LF1A7:  BNE LF1AC
LF1A9:  JMP LF2C4
LF1AC:  CMP #TXT_YN 
LF1AE:  BNE LF1B3
LF1B0:  JMP LF2C7
LF1B3:  CMP #TXT_NONE_F8
LF1B5:  BNE LF1BA
LF1B7:  JMP LF2D0
LF1BA:  CMP #TXT_NONE_F9
LF1BC:  BNE LF1C1
LF1BE:  JMP LF2E5
LF1C1:  CMP #TXT_PRAY
LF1C3:  BNE LF1C8
LF1C5:  JMP LF2EC
LF1C8:  CMP #TXT_BRIB
LF1CA:  BNE LF1CF
LF1CC:  JMP LF2F6
LF1CF:  CMP #TXT_NAME
LF1D1:  BNE LF1D6
LF1D3:  JMP LF300
LF1D6:  CMP #TXT_ENMY
LF1D8:  BNE LF1DD
LF1DA:  JMP LF31B
LF1DD:  CMP #TXT_AMNT
LF1DF:  BNE LF1E4
LF1E1:  JMP LF352
LF1E4:  CMP #TXT_AMNT
LF1E6:  BNE LF1EB
LF1E8:  JMP LF352
LF1EB:  INC $AD
LF1ED:  INY
LF1EE:  INX
LF1EF:  STA PPUBufBase,X
LF1F2:  DEC $2E
LF1F4:  BEQ LF1FC
LF1F6:  JSR LF472
LF1F9:  JMP LF195
LF1FC:  LDA (TextCharPtr),Y
LF1FE:  CMP #TXT_END
LF200:  BEQ LF20A
LF202:  CMP #$FD
LF204:  BEQ LF20E
LF206:  INY
LF207:  JMP LF1FC
LF20A:  LDA #$01
LF20C:  STA $17
LF20E:  LDA #$00
LF210:  STA $AD
LF212:  INY
LF213:  LDA $2C
LF215:  STA $2E
LF217:  LDA $21
LF219:  STA $19
LF21B:  CLC
LF21C:  LDA $29
LF21E:  ADC #$20
LF220:  STA $29
LF222:  LDA $2A
LF224:  ADC #$00
LF226:  STA $2A
LF228:  LDA $30
LF22A:  CMP #$FE
LF22C:  BEQ LF244
LF22E:  LDA ActiveMessage
LF230:  BNE LF244
LF232:  CLC
LF233:  LDA $29
LF235:  ADC #$20
LF237:  STA $29
LF239:  LDA $2A
LF23B:  ADC #$00
LF23D:  STA $2A
LF23F:  JSR LF4BB
LF242:  INC $AE
LF244:  JSR LF4BB
LF247:  INC $AE
LF249:  DEC $2D
LF24B:  BEQ LF250
LF24D:  JMP LF180
LF250:  LDA $C7
LF252:  BEQ LF2B1
LF254:  LDA $17
LF256:  BNE LF2B1
LF258:  LDA #$C0
LF25A:  STA $7300
LF25D:  LDX #$A0
LF25F:  LDA MapProperties
LF261:  AND #MAP_TURN
LF263:  BEQ LF267
LF265:  LDX #$90
LF267:  STX $7303
LF26A:  JSR SetPPUUpdate        ;($F0B4)Check if PPU update flag needs to be set.
LF26D:  LDA #$FF
LF26F:  STA $9B
LF271:  JSR LE6D8
LF274:  LDA #SPRT_HIDE
LF276:  STA $7300
LF279:  LDA $1A
LF27B:  CLC
LF27C:  ADC #$06
LF27E:  STA $1A
LF280:  TAX
LF281:  LDY #$00
LF283:  LDA (TextCharPtr),Y
LF285:  CMP #TXT_NEWLINE
LF287:  BEQ LF28D
LF289:  INY
LF28A:  JMP LF283
LF28D:  INY
LF28E:  DEX
LF28F:  BNE LF283
LF291:  LDA $2B
LF293:  STA $2D
LF295:  LDA $27
LF297:  STA $2A
LF299:  LDA $26
LF29B:  STA $29
LF29D:  LDA $20
LF29F:  STA $18

LF2A1:  LDA GenByte25           ;Restore the hide upper sprites value.
LF2A3:  STA HideUprSprites      ;

LF2A5:  JSR DoHideUprSprites    ;($F41C)Hide upper sprites.
LF2A8:  LDA #$00
LF2AA:  STA $AD
LF2AC:  STA $AE
LF2AE:  JMP LF180
LF2B1:  JSR SetPPUUpdate        ;($F0B4)Check if PPU update flag needs to be set.
LF2B4:  PLA
LF2B5:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LF2B8:  CLC
LF2B9:  RTS

;----------------------------------------------------------------------------------------------------

LF2BA:  LDA #$01
LF2BC:  STA $17
LF2BE:  JSR LF400
LF2C1:  JMP LF20E
LF2C4:  JMP LF195
LF2C7:  JSR LF400
LF2CA:  PLA
LF2CB:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LF2CE:  SEC
LF2CF:  RTS

LF2D0:  TXA
LF2D1:  PHA
LF2D2:  LDX #$01
LF2D4:  JSR LF3BC
LF2D7:  TXA
LF2D8:  BNE LF2DF
LF2DA:  PLA
LF2DB:  TAX
LF2DC:  JMP LF2C4
LF2DF:  PLA
LF2E0:  TAX
LF2E1:  INY
LF2E2:  JMP LF195

LF2E5:  TXA
LF2E6:  PHA
LF2E7:  LDX #$02
LF2E9:  JMP LF2D4

LF2EC:  LDA BribePray
LF2EE:  ORA #CMD_PRAY
LF2F0:  STA BribePray
LF2F2:  INY
LF2F3:  JMP LF195

LF2F6:  LDA BribePray
LF2F8:  ORA #CMD_BRIBE
LF2FA:  STA BribePray
LF2FC:  INY
LF2FD:  JMP LF195

LF300:  TXA
LF301:  PHA
LF302:  TYA
LF303:  PHA
LF304:  LDY #$00
LF306:  LDX #$00
LF308:  LDA (CrntChrPtr),Y
LF30A:  BEQ LF315
LF30C:  STA $7521,X
LF30F:  INX
LF310:  INY
LF311:  CPX #$05
LF313:  BNE LF308
LF315:  STX $7520
LF318:  JMP LF37C
LF31B:  TXA
LF31C:  PHA
LF31D:  TYA
LF31E:  PHA
LF31F:  LDA $2A
LF321:  PHA
LF322:  LDA $29
LF324:  PHA
LF325:  LDA En1Type
LF328:  ASL
LF329:  TAX
LF32A:  LDA $BC80,X
LF32D:  STA $29
LF32F:  LDA $BC81,X
LF332:  STA $2A
LF334:  LDY #$00
LF336:  LDX #$00
LF338:  LDA ($29),Y
LF33A:  CMP #$FF
LF33C:  BEQ LF346
LF33E:  STA $7521,X
LF341:  INY
LF342:  INX
LF343:  JMP LF338
LF346:  STX $7520
LF349:  PLA
LF34A:  STA $29
LF34C:  PLA
LF34D:  STA $2A
LF34F:  JMP LF37C

LF352:  TXA
LF353:  PHA
LF354:  TYA
LF355:  PHA
LF356:  JSR LE63E
LF359:  LDY #$00
LF35B:  LDX #$00
LF35D:  LDA $00A2,Y
LF360:  CMP #$38
LF362:  BNE LF36A
LF364:  INY
LF365:  CPY #$04
LF367:  BNE LF35D
LF369:  DEY
LF36A:  STA $7521,X
LF36D:  INY
LF36E:  INX
LF36F:  LDA $00A2,Y
LF372:  CPY #$04
LF374:  BNE LF36A
LF376:  STX $7520
LF379:  JMP LF37C
LF37C:  INC $7520
LF37F:  LDA #$00
LF381:  LDX $7520
LF384:  STA $7520,X
LF387:  PLA
LF388:  TAY
LF389:  PLA
LF38A:  TAX
LF38B:  TYA
LF38C:  PHA
LF38D:  LDY #$00
LF38F:  LDA $7520,Y
LF392:  PHA
LF393:  INY
LF394:  LDA $7520,Y
LF397:  INC $AD
LF399:  INY
LF39A:  INX
LF39B:  STA PPUBufBase,X
LF39E:  DEC $2E
LF3A0:  BEQ LF3B5
LF3A2:  JSR LF472
LF3A5:  PLA
LF3A6:  SEC
LF3A7:  SBC #$01
LF3A9:  BEQ LF3AF
LF3AB:  PHA
LF3AC:  JMP LF394
LF3AF:  PLA
LF3B0:  TAY
LF3B1:  INY
LF3B2:  JMP LF195
LF3B5:  PLA
LF3B6:  PLA
LF3B7:  TAY
LF3B8:  INY
LF3B9:  JMP LF1FC

LF3BC:  TYA
LF3BD:  PHA
LF3BE:  LDA $2E
LF3C0:  PHA
LF3C1:  LDA $2D
LF3C3:  PHA
LF3C4:  STX $2E
LF3C6:  LDA #$00
LF3C8:  STA $2D
LF3CA:  LDY #$06
LF3CC:  LDA (Pos1ChrPtr),Y
LF3CE:  TAX
LF3CF:  LDA $F411,X
LF3D2:  AND $2E
LF3D4:  ORA $2D
LF3D6:  LDA (Pos2ChrPtr),Y
LF3D8:  TAX
LF3D9:  LDA $F411,X
LF3DC:  AND $2E
LF3DE:  ORA $2D
LF3E0:  LDA (Pos3ChrPtr),Y
LF3E2:  TAX
LF3E3:  LDA $F411,X
LF3E6:  AND $2E
LF3E8:  ORA $2D
LF3EA:  LDA (Pos4ChrPtr),Y
LF3EC:  TAX
LF3ED:  LDA $F411,X
LF3F0:  AND $2E
LF3F2:  ORA $2D
LF3F4:  LDA $2D
LF3F6:  TAX
LF3F7:  PLA
LF3F8:  STA $2D
LF3FA:  PLA
LF3FB:  STA $2E
LF3FD:  PLA
LF3FE:  TAY
LF3FF:  RTS

LF400:  LDA #$00
LF402:  INX
LF403:  STA PPUBufBase,X
LF406:  DEC $2E
LF408:  BEQ LF410
LF40A:  JSR LF472
LF40D:  JMP LF400
LF410:  RTS

LF411:  .byte $02, $01, $02, $02, $01, $02, $01, $01, $02, $02, $02    

;----------------------------------------------------------------------------------------------------

DoHideUprSprites:
LF41C:  LDX HideUprSprites      ;Start at given index.
LF41E:  LDA #SPRT_HIDE          ;Prepare to set Y value of sprite off the screen.

LF420:* STA SpriteBuffer,X      ;Hide given sprite.

LF423:  INX                     ;
LF424:  INX                     ;Increment by 4. 4 bytes per sprite.
LF425:  INX                     ;
LF426:  INX                     ;All upper sprites hidden?
LF427:  BNE -                   ;If not, branch to hide another one.
LF429:  RTS                     ;

;----------------------------------------------------------------------------------------------------

ShowWindow:
LF42A:* LDA ScrollDirAmt
LF42C:  BNE -

LF42E:  JSR BlockAlign          ;($FD1C)Update block aligned position of character 1.
LF431:  LDA TimeStopTimer
LF433:  ORA #$80
LF435:  STA TimeStopTimer
LF437:  LDA CurPRGBank
LF439:  PHA

LF43A:  LDA #BANK_HELPERS1
LF43C:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LF43F:  JSR _DrawWindow         ;($8000)Draw window on scree and all its content.

LF442:  PLA                     ;Reload previous bank.
LF443:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LF446:  RTS                     ;

;----------------------------------------------------------------------------------------------------

LF447:  LDA #$F0
LF449:  LDY #$00
LF44B:  STA $03E0,Y
LF44E:  INY
LF44F:  CPY #$0C
LF451:  BNE LF44B
LF453:  RTS
LF454:  LDA $19
LF456:  AND #$1F
LF458:  SEC
LF459:  SBC #$20
LF45B:  CLC
LF45C:  ADC $2E
LF45E:  BCC LF46C
LF460:  BEQ LF46C
LF462:  SBC $2E
LF464:  EOR #$FF
LF466:  CLC
LF467:  ADC #$01
LF469:  JMP LF46E
LF46C:  LDA $2E
LF46E:  JSR SetPPUBufNewSize    ;($F079)Update length of data in PPU buffer.
LF471:  RTS

LF472:  INC $19
LF474:  LDA $19
LF476:  AND #$1F
LF478:  BEQ LF47B
LF47A:  RTS
LF47B:  LDA $19
LF47D:  AND #$3F
LF47F:  STA $19
LF481:  LDA $2E
LF483:  JSR SetPPUBufNewSize    ;($F079)Update length of data in PPU buffer.
LF486:  LDA $2A
LF488:  PHA
LF489:  LDA $29
LF48B:  PHA
LF48C:  LDA $29
LF48E:  AND #$E0
LF490:  STA $29
LF492:  LDA $19
LF494:  AND #$20
LF496:  BNE LF4A2
LF498:  SEC
LF499:  LDA $2A
LF49B:  SBC #$04
LF49D:  STA $2A
LF49F:  JMP LF4A9
LF4A2:  CLC
LF4A3:  LDA $2A
LF4A5:  ADC #$04
LF4A7:  STA $2A
LF4A9:  STA PPUBufBase,X
LF4AC:  INX
LF4AD:  LDA $29
LF4AF:  AND #$E0
LF4B1:  STA PPUBufBase,X
LF4B4:  PLA
LF4B5:  STA $29
LF4B7:  PLA
LF4B8:  STA $2A
LF4BA:  RTS

LF4BB:  INC $18
LF4BD:  LDA $18
LF4BF:  CMP #$1E
LF4C1:  BEQ LF4C4
LF4C3:  RTS
LF4C4:  LDA $29
LF4C6:  AND #$1F
LF4C8:  STA $29
LF4CA:  LDA $2A
LF4CC:  AND #$FC
LF4CE:  STA $2A
LF4D0:  RTS

;----------------------------------------------------------------------------------------------------

BinToBCD:
LF4D1:  LDA CurPRGBank          ;Save current lower bank on the stack.
LF4D3:  PHA                     ;

LF4D4:  LDA #BANK_HELPERS1      ;Put DoBinToBCD function in memory.
LF4D6:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LF4D9:  JSR DoBinToBCD          ;($8400)Convert binary number to BCD.

LF4DC:  PLA                     ;Restore previous lower bank.
LF4DD:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.

LF4E0:  LDA TimeStopTimer       ;
LF4E2:  AND #$7F                ;Remove time stop being caused by open window.
LF4E4:  STA TimeStopTimer       ;

LF4E6:  LDA #$00                ;
LF4E8:  STA UnusedE4            ;Value is unused.
LF4EA:  RTS                     ;

;----------------------------------------------------------------------------------------------------

LoadMapData:
LF4EB:  LDA CurPRGBank          ;Save lower bank number on the stack.
LF4ED:  PHA                     ;

LF4EE:  LDA #DISABLE            ;
LF4F0:  STA DisSpriteAnim       ;Turn off the screen and disable sprite animations.
LF4F2:  LDA #SCREEN_OFF         ;
LF4F4:  STA CurPPUConfig1       ;

LF4F6:  LDA #$01                ;Wait 1 frame.
LF4F8:  JSR WaitSomeFrames      ;($E6D0)Wait some frames before continuing.

LF4FB:  LDA MapBank             ;Get the bank to the map data we need.
LF4FD:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.

LF500:  LDY #$00
LF502:  LDX #$08

LF504:  LDA #>MapRAM
LF506:  STA GenPtr29UB
LF508:  LDA #<MapRAM
LF50A:  STA GenPtr29LB

MapLoadLoop:
LF50C:  LDA (MapDatPtr),Y
LF50E:  STA (GenPtr29),Y
LF510:  INY
LF511:  BNE MapLoadLoop

LF513:  INC MapDatPtrUB
LF515:  INC GenPtr29UB
LF517:  DEX
LF518:  BNE MapLoadLoop

LF51A:  LDA #BANK_HELPERS1
LF51C:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LF51F:  JSR $8800
LF522:  LDA #$00
LF524:  STA CurPPUConfig1
LF526:  PLA
LF527:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LF52A:  JSR LoadAlphaNumMaps    ;($ED76)Load character set and map tiles.
LF52D:  JSR LEE2E
LF530:  JSR LF5C0
LF533:  LDX #$00
LF535:  LDY #$40
LF537:  JSR LC705
LF53A:  LDX #$01
LF53C:  LDY #$40
LF53E:  LDA #$00
LF540:  JSR LC707
LF543:  JSR LC55F
LF546:  JSR LF447
LF549:  LDX #$FE
LF54B:  LDY #$3E

LF54D:  LDA ThisMap
LF54F:  CMP #MAP_AMBROSIA
LF551:  BNE +
LF553:  LDX #$FE
LF555:  LDY #$5E

LF557:* STX $2A
LF559:  STY $29
LF55B:  JSR LED33
LF55E:  LDA #$1E
LF560:  STA CurPPUConfig1
LF562:  LDA $EC
LF564:  BEQ LF56F
LF566:  LDA #$00
LF568:  STA $EC
LF56A:  LDA #$03
LF56C:  JSR FlashAndSound       ;($DB2D)Flash screen with SFX.
LF56F:  RTS

;----------------------------------------------------------------------------------------------------

LF570:  LDA CurPRGBank
LF572:  PHA
LF573:  LDA #BANK_HELPERS1
LF575:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LF578:  JSR $8A00
LF57B:  PLA
LF57C:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LF57F:  RTS

LF580:  LDA CurPRGBank
LF582:  PHA
LF583:  LDA #BANK_HELPERS1
LF585:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LF588:  JSR $8C00
LF58B:  PLA
LF58C:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LF58F:  RTS

LF590:  LDA CurPRGBank
LF592:  PHA
LF593:  LDA #BANK_HELPERS1
LF595:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LF598:  JSR $8D00
LF59B:  PLA
LF59C:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LF59F:  RTS

LF5A0:  LDA CurPRGBank
LF5A2:  PHA
LF5A3:  LDA #BANK_HELPERS1
LF5A5:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LF5A8:  JSR $8E00
LF5AB:  PLA
LF5AC:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LF5AF:  RTS

LF5B0:  LDA CurPRGBank
LF5B2:  PHA
LF5B3:  LDA #BANK_HELPERS1
LF5B5:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LF5B8:  JSR $9000
LF5BB:  PLA
LF5BC:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LF5BF:  RTS

LF5C0:  LDA ThisMap
LF5C2:  CMP $D8
LF5C4:  BNE LF5D6
LF5C6:  LDX #$00
LF5C8:  LDA #$00
LF5CA:  STA NPCOnscreen,X
LF5CD:  INX
LF5CE:  INX
LF5CF:  INX
LF5D0:  INX
LF5D1:  CPX #$80
LF5D3:  BNE LF5C8
LF5D5:  RTS

LF5D6:  STA $D8
LF5D8:  LDA MapProperties
LF5DA:  CMP #MAP_PROP_OV
LF5DC:  BEQ LF628
LF5DE:  LDY #$00
LF5E0:  LDX #$00
LF5E2:  LDA (NPCSrcPtr),Y
LF5E4:  STA NPCSprIndex,X
LF5E7:  LDA #$00
LF5E9:  STA NPCOnscreen,X
LF5EC:  INY
LF5ED:  INY
LF5EE:  LDA (NPCSrcPtr),Y
LF5F0:  STA NPCXPos,X
LF5F3:  INY
LF5F4:  LDA (NPCSrcPtr),Y
LF5F6:  STA NPCYPOS,X
LF5F9:  INX
LF5FA:  INX
LF5FB:  INX
LF5FC:  INX
LF5FD:  TXA
LF5FE:  TAY
LF5FF:  CPX #$80
LF601:  BNE LF5E2
LF603:  LDX #$44
LF605:  LDA #SPRT_HIDE
LF607:  STA $7300,X
LF60A:  INX
LF60B:  INX
LF60C:  INX
LF60D:  INX
LF60E:  BNE LF605
LF610:  LDA ThisMap
LF612:  CMP #MAP_AMBROSIA
LF614:  BNE LF627
LF616:  LDA $03D7
LF619:  STA $047E
LF61C:  LDA $03D8
LF61F:  STA $047F
LF622:  LDA #$85
LF624:  STA $047C
LF627:  RTS

LF628:  LDA CurPRGBank
LF62A:  PHA
LF62B:  LDA #BANK_HELPERS1
LF62D:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LF630:  JSR $B000
LF633:  LDA OnBoat
LF635:  BEQ LF63C
LF637:  LDA #$FF
LF639:  STA $047C
LF63C:  PLA
LF63D:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LF640:  RTS
LF641:  LDA CurPRGBank
LF643:  PHA
LF644:  LDA #BANK_HELPERS1
LF646:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LF649:  JSR $B100
LF64C:  PLA
LF64D:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LF650:  RTS
LF651:  JSR LF6B3
LF654:  BCS LF6B2
LF656:  LDX #$00
LF658:  LDA #$00
LF65A:  STA NPCOnscreen,X
LF65D:  INX
LF65E:  INX
LF65F:  INX
LF660:  INX
LF661:  CPX #$78
LF663:  BNE LF658
LF665:  BEQ LF66C
LF667:  JSR LF6B3
LF66A:  BCS LF6B2
LF66C:  LDA #$01
LF66E:  STA $E2
LF670:  LDA $00
LF672:  ORA #$01
LF674:  STA RngSeed
LF676:  LDA #$0E
LF678:  STA $18
LF67A:  LDA #$00
LF67C:  STA $30
LF67E:  LDX #$00
LF680:  LDA NPCSprIndex,X
LF683:  AND #$7F
LF685:  STA NPCSprIndex,X
LF688:  LDA NPCOnscreen,X
LF68B:  BNE LF6A4
LF68D:  STX $19
LF68F:  LDA #$40
LF691:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LF694:  STA $48
LF696:  LDA #$40
LF698:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LF69B:  STA $47
LF69D:  TXA
LF69E:  PHA
LF69F:  JSR LF641
LF6A2:  PLA
LF6A3:  TAX
LF6A4:  INX
LF6A5:  INX
LF6A6:  INX
LF6A7:  INX
LF6A8:  CPX #$7C
LF6AA:  BNE LF680
LF6AC:  LDA $C0
LF6AE:  AND #$7C
LF6B0:  STA $C0
LF6B2:  RTS
LF6B3:  LDA ThisMap
LF6B5:  CMP #MAP_AMBROSIA
LF6B7:  BEQ LF6CA
LF6B9:  CMP #$14
LF6BB:  BEQ LF6CA
LF6BD:  LDA MapProperties
LF6BF:  AND #MAP_TURN
LF6C1:  BNE LF6C8
LF6C3:  JSR LDF1C
LF6C6:  BCC LF6CA
LF6C8:  CLC
LF6C9:  RTS
LF6CA:  SEC
LF6CB:  RTS

;----------------------------------------------------------------------------------------------------

PrepLoadDungeon:
LF6CC:  LDA #$00
LF6CE:  STA IgnoreInput
LF6D0:  STA DisSpriteAnim
LF6D2:  STA ScrollDirAmt
LF6D4:  STA DungeonLevel
LF6D6:  STA $B1
LF6D8:  STA $D2
LF6DA:  LDA #$FF
LF6DC:  STA $D8
LF6DE:  LDA #BANK_DUNGEONS
LF6E0:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LF6E3:  LDA ThisMap
LF6E5:  AND #$7F
LF6E7:  ASL
LF6E8:  ASL
LF6E9:  ASL
LF6EA:  TAX
LF6EB:  INX
LF6EC:  LDA MapDatTbl,X
LF6EF:  STA $29
LF6F1:  INX
LF6F2:  LDA MapDatTbl,X
LF6F5:  STA $2A
LF6F7:  LDA #$78
LF6F9:  STA $2C
LF6FB:  LDA #$00
LF6FD:  STA $2B
LF6FF:  LDY #$00
LF701:  LDX #$08
LF703:  LDA ($29),Y
LF705:  STA ($2B),Y
LF707:  INY
LF708:  BNE LF703
LF70A:  INC $2A
LF70C:  INC $2C
LF70E:  DEX
LF70F:  BNE LF703

LF711:  LDA #>MapRAM            ;
LF713:  STA MapDatPtrUB         ;Set the map data pointer to the map data base.
LF715:  LDA #<MapRAM            ;
LF717:  STA MapDatPtrLB         ;

LF719:  LDA #$01                ;
LF71B:  STA MapXPos             ;Set player's start position to XY=1,1.
LF71D:  STA MapYPos             ;

LoadDungeon:
LF71F:  LDA #ANIM_DISABLE
LF721:  STA DoAnimations

LF723:  LDA #MUS_DUNGEON+INIT
LF725:  STA InitNewMusic

LF727:  LDA #SCREEN_OFF
LF729:  STA CurPPUConfig1
LF72B:  STA PPUControl1

LF72E:  LDA #DISABLE
LF730:  STA DisNPCMovement

LF732:  LDA #BANK_DUNGEONS
LF734:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.

LF737:  JSR LF991
LF73A:  JSR LFAC2
LF73D:  LDA #$1E
LF73F:  STA CurPPUConfig1
LF741:  JMP LF8B5
LF744:  LDA #$8F
LF746:  STA $9B
LF748:  JSR LE6D8
LF74B:  LDA Pad1Input
LF74D:  CMP #BTN_A
LF74F:  BNE LF757
LF751:  JSR LF8F7
LF754:  JMP LC23A
LF757:  LDA Pad1Input
LF759:  AND #D_PAD
LF75B:  BEQ LF744
LF75D:  LDA Pad1Input
LF75F:  CMP #BTN_RIGHT
LF761:  BNE LF76E
LF763:  INC $7D
LF765:  LDA $7D
LF767:  AND #$03
LF769:  STA $7D
LF76B:  JMP LF7EB
LF76E:  LDA Pad1Input
LF770:  CMP #BTN_LEFT
LF772:  BNE LF77F
LF774:  DEC $7D
LF776:  LDA $7D
LF778:  AND #$03
LF77A:  STA $7D
LF77C:  JMP LF7EB
LF77F:  LDA Pad1Input
LF781:  CMP #BTN_DOWN
LF783:  BNE LF7B4
LF785:  LDA MapXPos
LF787:  PHA
LF788:  LDA MapYPos
LF78A:  PHA
LF78B:  LDA $7D
LF78D:  ASL
LF78E:  TAX
LF78F:  LDA $F8EF,X
LF792:  CLC
LF793:  ADC MapXPos
LF795:  AND #$0F
LF797:  STA MapXPos
LF799:  INX
LF79A:  LDA $F8EF,X
LF79D:  CLC
LF79E:  ADC MapYPos
LF7A0:  AND #$0F
LF7A2:  STA MapYPos
LF7A4:  JSR GetDngnXYData       ;($F974)Get the dungeon data for character's current location.
LF7A7:  CMP #$00
LF7A9:  BNE LF7E9
LF7AB:  PLA
LF7AC:  STA MapYPos
LF7AE:  PLA
LF7AF:  STA MapXPos
LF7B1:  JMP LF744
LF7B4:  LDA Pad1Input
LF7B6:  CMP #BTN_UP
LF7B8:  BNE LF7B1
LF7BA:  LDA MapXPos
LF7BC:  PHA
LF7BD:  LDA MapYPos
LF7BF:  PHA
LF7C0:  LDA $7D
LF7C2:  ASL
LF7C3:  TAX
LF7C4:  LDA $F8E7,X
LF7C7:  CLC
LF7C8:  ADC MapXPos
LF7CA:  AND #$0F
LF7CC:  STA MapXPos
LF7CE:  INX
LF7CF:  LDA $F8E7,X
LF7D2:  CLC
LF7D3:  ADC MapYPos
LF7D5:  AND #$0F
LF7D7:  STA MapYPos
LF7D9:  JSR GetDngnXYData       ;($F974)Get the dungeon data for character's current location.
LF7DC:  CMP #$00
LF7DE:  BNE LF7E9
LF7E0:  PLA
LF7E1:  STA MapYPos
LF7E3:  PLA
LF7E4:  STA MapXPos
LF7E6:  JMP LF744
LF7E9:  PLA
LF7EA:  PLA
LF7EB:  LDA #SFX_DNGN_MOVE+INIT
LF7ED:  STA ThisSFX
LF7EF:  LDA Pad1Input
LF7F1:  STA $ED
LF7F3:  PHA
LF7F4:  JSR LFAC2
LF7F7:  PLA
LF7F8:  CMP #$08
LF7FA:  BEQ LF800
LF7FC:  CMP #$04
LF7FE:  BNE LF869
LF800:  JSR GetDngnXYData       ;($F974)Get the dungeon data for character's current location.
LF803:  CMP #$09
LF805:  BNE LF81E
LF807:  LDA #$00
LF809:  STA $B1
LF80B:  JSR LF981
LF80E:  JSR LF8F7
LF811:  LDA #$33
LF813:  STA TextIndex
LF815:  JSR ShowDialog          ;($E675)Show dialog in lower screen window.
LF818:  JSR BinToBCD            ;($F4D1)Convert binary number to BCD.
LF81B:  JMP LF86C
LF81E:  CMP #$0D
LF820:  BNE LF835
LF822:  LDA #$63
LF824:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LF827:  CMP #$03
LF829:  BCS LF869
LF82B:  JSR GetDngnXYData       ;($F974)Get the dungeon data for character's current location.
LF82E:  LDA #$0B
LF830:  STA (MapDatPtr),Y
LF832:  JMP LC723
LF835:  CMP #$0C
LF837:  BNE LF84D
LF839:  JSR LF8F7
LF83C:  LDA Pos1ChrPtrLB
LF83E:  STA CrntChrPtrLB
LF840:  LDA Pos1ChrPtrUB
LF842:  STA CrntChrPtrUB
LF844:  JSR LDF39
LF847:  JSR BinToBCD            ;($F4D1)Convert binary number to BCD.
LF84A:  JMP LF86C
LF84D:  CMP #$0A
LF84F:  BNE LF85B
LF851:  JSR GetDngnXYData       ;($F974)Get the dungeon data for character's current location.
LF854:  LDA #$0D
LF856:  STA (MapDatPtr),Y
LF858:  JMP LF869
LF85B:  CMP #$08
LF85D:  BNE LF869
LF85F:  JSR GetDngnXYData       ;($F974)Get the dungeon data for character's current location.
LF862:  LDA #$0D
LF864:  STA (MapDatPtr),Y
LF866:  JMP LF86C
LF869:  JMP LF8B5
LF86C:  JSR ResetNameTableF1    ;($FBDC)Reset nametable offsets and select nametable 0.
LF86F:  LDA ThisMap
LF871:  BNE LF876
LF873:  JMP LF8CB
LF876:  LDA #$01
LF878:  STA DisSpriteAnim
LF87A:  LDA #$40
LF87C:  JSR SetPPUBufNewSize    ;($F079)Update length of data in PPU buffer.
LF87F:  LDA #$27
LF881:  STA PPUBufBase,X
LF884:  INX
LF885:  LDA #$C0
LF887:  STA PPUBufBase,X
LF88A:  INX
LF88B:  LDY #$00
LF88D:  LDA AttribBuffer,Y
LF890:  STA PPUBufBase,X
LF893:  INY
LF894:  INX
LF895:  CPY #$40
LF897:  BNE LF88D
LF899:  LDA DisNPCMovement
LF89B:  BPL LF8A7
LF89D:  AND #$7F
LF89F:  STA DisNPCMovement
LF8A1:  JSR LFAC2
LF8A4:  JMP LF8B5
LF8A7:  AND #$40
LF8A9:  BEQ LF8B2
LF8AB:  LDA #DISABLE
LF8AD:  STA DisNPCMovement
LF8AF:  JMP LFA8B
LF8B2:  JSR LFAD2
LF8B5:  JSR LF981
LF8B8:  LDA #$00
LF8BA:  STA DisSpriteAnim
LF8BC:  JSR LF8F7
LF8BF:  JSR LFC55
LF8C2:  JSR ResetNameTableF1    ;($FBDC)Reset nametable offsets and select nametable 0.
LF8C5:  JSR LFAF6
LF8C8:  JMP LF744
LF8CB:  LDA #$00
LF8CD:  STA CurPPUConfig1
LF8CF:  STA PPUControl1
LF8D2:  LDA #$FE
LF8D4:  STA $2A
LF8D6:  LDA #$3E
LF8D8:  STA $29
LF8DA:  JSR LED33
LF8DD:  JSR LoadAlphaNumMaps    ;($ED76)Load character set and map tiles.
LF8E0:  LDA #ENABLE
LF8E2:  STA DisNPCMovement
LF8E4:  JMP PrepLoadOvrwld      ;($C142)Prepare to load overworld map.

LF8E7:  .byte $00, $FF, $01, $00, $00, $01, $FF, $00, $00, $01, $FF, $00, $00, $FF, $01, $00

LF8F7:  LDA #$01
LF8F9:  STA NTXPosUB
LF8FB:  STA NTXPosUB16
LF8FD:  LDA CurPPUConfig0
LF8FF:  ORA #$01
LF901:  STA CurPPUConfig0
LF903:  LDA #$D4
LF905:  STA HideUprSprites
LF907:  JSR LFAF6
LF90A:  RTS

LF90B:  LDA CurPRGBank
LF90D:  PHA
LF90E:  LDA #$00
LF910:  STA CurPPUConfig1
LF912:  LDA #BANK_MISC_GFX
LF914:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LF917:  JSR GetDngnXYData       ;($F974)Get the dungeon data for character's current location.
LF91A:  LDX #$00
LF91C:  CMP #$06
LF91E:  BEQ LF929
LF920:  CMP #$07
LF922:  BEQ LF929
LF924:  CMP #$0E
LF926:  BNE LF92A
LF928:  INX
LF929:  INX
LF92A:  CPX $D2
LF92C:  BEQ LF96B
LF92E:  STX $D2
LF930:  TXA
LF931:  BNE LF93E
LF933:  LDA #$90
LF935:  STA $2A
LF937:  LDA #$00
LF939:  STA $29
LF93B:  JMP LF955
LF93E:  CPX #$02
LF940:  BEQ LF94D
LF942:  LDA #$96
LF944:  STA $2A
LF946:  LDA #$00
LF948:  STA $29
LF94A:  JMP LF955

LF94D:  LDA #$9B
LF94F:  STA $2A
LF951:  LDA #$00
LF953:  STA $29
LF955:  LDA #$1A
LF957:  STA $2C
LF959:  LDA #$40
LF95B:  STA $2B
LF95D:  LDA #$05
LF95F:  STA $2E
LF961:  LDA #$00
LF963:  STA $2D
LF965:  JSR LoadPPU             ;($EFE3)Load values into PPU.

LF968:  JSR LF981
LF96B:  PLA
LF96C:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LF96F:  LDA #$1E
LF971:  STA CurPPUConfig1
LF973:  RTS

;----------------------------------------------------------------------------------------------------

GetDngnXYData:
LF974:  LDA MapYPos             ;
LF976:  ASL                     ;
LF977:  ASL                     ;/16. 16 columns per dungeon map row.
LF978:  ASL                     ;
LF979:  ASL                     ;

LF97A:  CLC                     ;
LF97B:  ADC MapXPos             ;Add in X position to get final index.
LF97D:  TAY                     ;

LF97E:  LDA (MapDatPtr),Y       ;Save dungeon map data byte into A.
LF980:  RTS                     ;

;----------------------------------------------------------------------------------------------------

LF981:  LDA CurPRGBank
LF983:  PHA
LF984:  LDA #BANK_HELPERS1
LF986:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LF989:  JSR $B380
LF98C:  PLA
LF98D:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LF990:  RTS
LF991:  LDA #SPRT_HIDE
LF993:  LDX #$00
LF995:  STA $7300,X
LF998:  INX
LF999:  INX
LF99A:  INX
LF99B:  INX
LF99C:  BNE LF995
LF99E:  JSR SetPPUUpdate        ;($F0B4)Check if PPU update flag needs to be set.
LF9A1:  LDA #$20
LF9A3:  STA $2C
LF9A5:  LDA #$00
LF9A7:  STA $2B
LF9A9:  LDX #$00
LF9AB:  LDA #$00
LF9AD:  STA ScreenBlocks,X
LF9B0:  INX
LF9B1:  BNE LF9AD
LF9B3:  LDA #$07
LF9B5:  STA $2A
LF9B7:  LDA #$00
LF9B9:  STA $29
LF9BB:  LDA #$01
LF9BD:  STA $2E
LF9BF:  LDA #$00
LF9C1:  STA $2D
LF9C3:  LDA #$08
LF9C5:  STA $30
LF9C7:  JSR LoadPPU             ;($EFE3)Load values into PPU.
LF9CA:  INC $2C
LF9CC:  DEC $30
LF9CE:  BNE LF9C7
LF9D0:  JSR LFA6C
LF9D3:  LDA #$00
LF9D5:  STA $72
LF9D7:  STA $71
LF9D9:  JSR LFC35

LF9DC:  LDA #$23
LF9DE:  STA $2C
LF9E0:  LDA #$C0
LF9E2:  STA $2B
LF9E4:  LDA #$05
LF9E6:  STA $2A
LF9E8:  LDA #$00
LF9EA:  STA $29
LF9EC:  LDA #$00
LF9EE:  STA $2E
LF9F0:  LDA #$40
LF9F2:  STA $2D
LF9F4:  JSR LoadPPU             ;($EFE3)Load values into PPU.

LF9F7:  LDA #$27
LF9F9:  STA $2C
LF9FB:  LDA #$C0
LF9FD:  STA $2B
LF9FF:  JSR LoadPPU             ;($EFE3)Load values into PPU.

LFA02:  LDA #$20
LFA04:  STA $2C
LFA06:  LDA #$64
LFA08:  STA $2B
LFA0A:  LDA #$FA
LFA0C:  STA $2A
LFA0E:  LDA #$7C
LFA10:  STA $29
LFA12:  LDA #$00
LFA14:  STA $2E
LFA16:  LDA #$0F
LFA18:  STA $2D
LFA1A:  JSR LoadPPU             ;($EFE3)Load values into PPU.

LFA1D:  LDA #$24
LFA1F:  STA $2C
LFA21:  JSR LoadPPU             ;($EFE3)Load values into PPU.

LFA24:  JSR LF981
LFA27:  LDA #BANK_MISC_GFX
LFA29:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.

LFA2C:  LDA #$90
LFA2E:  STA $2A
LFA30:  LDA #$00
LFA32:  STA $29
LFA34:  LDA #$1A
LFA36:  STA $2C
LFA38:  LDA #$40
LFA3A:  STA $2B
LFA3C:  LDA #$05
LFA3E:  STA $2E
LFA40:  LDA #$C0
LFA42:  STA $2D
LFA44:  JSR LoadPPU             ;($EFE3)Load values into PPU.

LFA47:  LDA #$B0
LFA49:  STA $2A
LFA4B:  LDA #$00
LFA4D:  STA $29
LFA4F:  LDA #$0E
LFA51:  STA $2C
LFA53:  LDA #$00
LFA55:  STA $2B
LFA57:  STA $2E
LFA59:  LDA #$B0
LFA5B:  STA $2D
LFA5D:  JSR LoadPPU             ;($EFE3)Load values into PPU.

LFA60:  LDA MapBank
LFA62:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFA65:  JSR ResetNameTableF1    ;($FBDC)Reset nametable offsets and select nametable 0.
LFA68:  JSR LFAF6
LFA6B:  RTS

LFA6C:  LDA CurPRGBank
LFA6E:  PHA
LFA6F:  LDA #BANK_HELPERS2
LFA71:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFA74:  JSR $BD00
LFA77:  PLA
LFA78:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFA7B:  RTS

LFA7C:  .byte $95, $8E, $9F, $8E, $95, $00, $39, $00, $00, $00, $8D, $92, $9B, $00, $97

LFA8B:  LDA CurPRGBank
LFA8D:  PHA
LFA8E:  LDA #BANK_HELPERS2
LFA90:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFA93:  JSR $BC00
LFA96:  PLA
LFA97:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFA9A:  LDA #SPRT_HIDE
LFA9C:  STA $7300
LFA9F:  JMP LF86C
LFAA2:  STA $2E
LFAA4:  JSR SetPPUBufNewSize    ;($F079)Update length of data in PPU buffer.
LFAA7:  LDA $2A
LFAA9:  STA PPUBufBase,X
LFAAC:  INX
LFAAD:  LDA $29
LFAAF:  STA PPUBufBase,X
LFAB2:  INX
LFAB3:  LDY #$00
LFAB5:  LDA TextBuffer,Y
LFAB8:  STA PPUBufBase,X
LFABB:  INY
LFABC:  INX
LFABD:  DEC $2E
LFABF:  BNE LFAB5
LFAC1:  RTS
LFAC2:  LDA CurPRGBank
LFAC4:  PHA
LFAC5:  LDA #BANK_HELPERS2
LFAC7:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFACA:  JSR $A800
LFACD:  PLA
LFACE:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFAD1:  RTS
LFAD2:  LDA CurPRGBank
LFAD4:  PHA
LFAD5:  LDA #BANK_HELPERS2
LFAD7:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFADA:  JSR $AA00
LFADD:  PLA
LFADE:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFAE1:  RTS

LFAE2:  .byte $FF

LFAE3:  LDA #$14
LFAE5:  STA $2A
LFAE7:  LDA #$02
LFAE9:  STA $29
LFAEB:  LDA #$0C
LFAED:  STA $2E
LFAEF:  LDA #$12
LFAF1:  STA $2D
LFAF3:  JSR ShowWindow          ;($F42A)Show a window on the display.
LFAF6:  LDA CurPRGBank
LFAF8:  PHA
LFAF9:  LDA #BANK_HELPERS2
LFAFB:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFAFE:  JSR $A600
LFB01:  PLA
LFB02:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFB05:  RTS
LFB06:  LDA CurPRGBank
LFB08:  PHA
LFB09:  LDA #BANK_HELPERS1
LFB0B:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFB0E:  JSR $B800
LFB11:  PLA
LFB12:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFB15:  RTS

;----------------------------------------------------------------------------------------------------

LdLgCharTiles:
LFB16:  LDA CurPRGBank          ;Save current lower PRG bank on the stack.
LFB18:  PHA                     ;

LFB19:  LDA #BANK_CHARS         ;Load the character class tile patterns bank.
LFB1B:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.

LFB1E:  LDA Ch1StClass          ;Does character 1 have a valid class?
LFB20:  CMP #CLS_UNCHOSEN       ;If not, branch to check character 2.
LFB22:  BEQ ChkCh2Class         ;

LFB24:  LDA Ch2StClass          ;
LFB26:  PHA                     ;
LFB27:  LDA Ch3StClass          ;Save character classes on the stack.
LFB29:  PHA                     ;
LFB2A:  LDA Ch4StClass          ;
LFB2C:  PHA                     ;

LFB2D:  LDX Ch1StClass          ;Use character 1 class as an index.
LFB2F:  JSR LdPPUSrcDat         ;($FBBF)Load pointers to PPU source data.

LFB32:  LDA #$14                ;
LFB34:  STA PPUDstPtrUB         ;Prepare to load pattern table tiles starting at tile $44.
LFB36:  LDA #$40                ;
LFB38:  STA PPUDstPtrLB         ;

LFB3A:  LDA #$02                ;
LFB3C:  STA PPUByteCntUB        ;Prepare to load 576 bytes into the PPU.
LFB3E:  LDA #$40                ;
LFB40:  STA PPUByteCntLB        ;

LFB42:  JSR LoadPPU             ;($EFE3)Load values into PPU.

LFB45:  PLA                     ;
LFB46:  STA Ch4StClass          ;
LFB48:  PLA                     ;Restore character classes from the stack.
LFB49:  STA Ch3StClass          ;
LFB4B:  PLA                     ;
LFB4C:  STA Ch2StClass          ;

ChkCh2Class:
LFB4E:  LDA Ch2StClass          ;Does character 2 have a valid class?
LFB50:  CMP #CLS_UNCHOSEN       ;If not, branch to check character 3.
LFB52:  BEQ ChkCh3Class         ;

LFB54:  LDA Ch3StClass          ;
LFB56:  PHA                     ;
LFB57:  LDA Ch4StClass          ;Save character classes on the stack.
LFB59:  PHA                     ;

LFB5A:  LDX Ch2StClass          ;Use character 2 class as an index.
LFB5C:  JSR LdPPUSrcDat         ;($FBBF)Load pointers to PPU source data.

LFB5F:  LDA #$16                ;
LFB61:  STA PPUDstPtrUB         ;Prepare to load pattern table tiles starting at tile $68.
LFB63:  LDA #$80                ;
LFB65:  STA PPUDstPtrLB         ;

LFB67:  LDA #$02                ;
LFB69:  STA PPUByteCntUB        ;Prepare to load 576 bytes into the PPU.
LFB6B:  LDA #$40                ;
LFB6D:  STA PPUByteCntLB        ;

LFB6F:  JSR LoadPPU             ;($EFE3)Load values into PPU.

LFB72:  PLA                     ;
LFB73:  STA Ch4StClass          ;Restore character classes from the stack.
LFB75:  PLA                     ;
LFB76:  STA Ch3StClass          ;

ChkCh3Class:
LFB78:  LDA Ch3StClass          ;Does character 3 have a valid class?
LFB7A:  CMP #CLS_UNCHOSEN       ;If not, branch to check character 4.
LFB7C:  BEQ ChkCh4Class         ;

LFB7E:  LDA Ch4StClass          ;Save character class on the stack.
LFB80:  PHA                     ;

LFB81:  LDX Ch3StClass          ;Use character 3 class as an index.
LFB83:  JSR LdPPUSrcDat         ;($FBBF)Load pointers to PPU source data.

LFB86:  LDA #$1B                ;
LFB88:  STA PPUDstPtrUB         ;Prepare to load pattern table tiles starting at tile $B8.
LFB8A:  LDA #$80                ;
LFB8C:  STA PPUDstPtrLB         ;

LFB8E:  LDA #$02                ;
LFB90:  STA PPUByteCntUB        ;Prepare to load 576 bytes into the PPU.
LFB92:  LDA #$40                ;
LFB94:  STA PPUByteCntLB        ;

LFB96:  JSR LoadPPU             ;($EFE3)Load values into PPU.

LFB99:  PLA                     ;Restore character class from the stack.
LFB9A:  STA Ch4StClass          ;

ChkCh4Class:
LFB9C:  LDA Ch4StClass          ;Does character 4 have a valid class?
LFB9E:  CMP #CLS_UNCHOSEN       ;If not, branch to exit.
LFBA0:  BEQ EndChrTilesLoad     ;

LFBA2:  LDX Ch4StClass          ;Use character 4 class as an index.
LFBA4:  JSR LdPPUSrcDat         ;($FBBF)Load pointers to PPU source data.

LFBA7:  LDA #$1D                ;
LFBA9:  STA PPUDstPtrUB         ;Prepare to load pattern table tiles starting at tile $DC.
LFBAB:  LDA #$C0                ;
LFBAD:  STA PPUDstPtrLB         ;

LFBAF:  LDA #$02                ;
LFBB1:  STA PPUByteCntUB        ;Prepare to load 576 bytes into the PPU.
LFBB3:  LDA #$40                ;
LFBB5:  STA PPUByteCntLB        ;

LFBB7:  JSR LoadPPU             ;($EFE3)Load values into PPU.

EndChrTilesLoad:
LFBBA:  PLA                     ;Restore original lower bank.
LFBBB:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFBBE:  RTS                     ;

;----------------------------------------------------------------------------------------------------

LdPPUSrcDat:
LFBBF:  LDA #>LgCharBase        ;
LFBC1:  STA PPUSrcPtrUB         ;Set the source pointer to the base
LFBC3:  LDA #<LgCharBase        ;address of the large character tile data.
LFBC5:  STA PPUSrcPtrLB         ;

IncPtrLoop:
LFBC7:  CPX #$00                ;Have we reached the correct index?
LFBC9:  BEQ SetPtrComplete      ;If so, branch to exit.

LFBCB:  CLC                     ;
LFBCC:  LDA PPUSrcPtrLB         ;
LFBCE:  ADC #$40                ;Move the pointer forward by 576.
LFBD0:  STA PPUSrcPtrLB         ;There are 576 bytes per large portrait.
LFBD2:  LDA PPUSrcPtrUB         ;
LFBD4:  ADC #$02                ;
LFBD6:  STA PPUSrcPtrUB         ;

LFBD8:  DEX                     ;Have we reached the correct index?
LFBD9:  BNE IncPtrLoop          ;If not, branch to increment again.

SetPtrComplete:
LFBDB:  RTS                     ;Data pointer is now correct. Return.

;----------------------------------------------------------------------------------------------------

ResetNameTableF1:
LFBDC:  LDA #$00                ;
LFBDE:  STA NTXPosLB            ;
LFBE0:  STA NTXPosUB            ;
LFBE2:  STA NTYPosLB            ;
LFBE4:  STA NTYPosUB            ;
LFBE6:  STA NTXPosLB16          ;Reset all nametable offset values and select nametable 0;
LFBE8:  STA NTXPosUB16          ;
LFBEA:  STA NTYPosLB16          ;
LFBEC:  STA NTYPosUB16          ;
LFBEE:  LDA CurPPUConfig0       ;
LFBF0:  AND #$FC                ;
LFBF2:  STA CurPPUConfig0       ;
LFBF4:  RTS                     ;

;----------------------------------------------------------------------------------------------------

RngCore:
LFBF5:  TXA                     ;
LFBF6:  PHA                     ;
LFBF7:  LDA #$00                ;
LFBF9:  STA RngNum0             ;
LFBFB:  LDX #$08                ;
LFBFD:* LSR RngInput0           ;
LFBFF:  BCC +                   ;The core of the RNG algorithm.
LFC01:  CLC                     ;The output will be a value between
LFC02:  ADC RngInput1           ;0 and RngInput0-1, inclusive.
LFC04:* ROR                     ;
LFC05:  ROR RngNum0             ;
LFC07:  DEX                     ;
LFC08:  BNE --                  ;
LFC0A:  STA RngNum1             ;
LFC0C:  PLA                     ;
LFC0D:  TAX                     ;
LFC0E:  RTS                     ;

;----------------------------------------------------------------------------------------------------

SetPRGBank:
LFC0F:  PHP
LFC10:  PHA
	  
LFC11:  LDA CurPPUConfig0
LFC13:  AND #$7F
LFC15:  STA PPUControl0
	  
LFC18:  PLA
LFC19:  STA CurPRGBank
	  
LFC1B:  STA MMCPRG
LFC1E:  LSR
LFC1F:  STA MMCPRG
LFC22:  LSR
LFC23:  STA MMCPRG
LFC26:  LSR
LFC27:  STA MMCPRG
LFC2A:  LSR
LFC2B:  STA MMCPRG
	  
LFC2E:  LDA CurPPUConfig0
LFC30:  STA PPUControl0
LFC33:  PLP
LFC34:  RTS

LFC35:  LDA CurPRGBank
LFC37:  PHA
LFC38:  LDA #BANK_HELPERS2
LFC3A:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFC3D:  JSR $8400
LFC40:  PLA
LFC41:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFC44:  RTS

LFC45:  LDA CurPRGBank
LFC47:  PHA

LFC48:  LDA #BANK_HELPERS2
LFC4A:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFC4D:  JSR $8000

LFC50:  PLA
LFC51:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFC54:  RTS

LFC55:  LDA CurPRGBank
LFC57:  PHA
LFC58:  LDA #BANK_HELPERS2
LFC5A:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFC5D:  JSR $8600
LFC60:  LDA MapProperties
LFC62:  AND #MAP_TURN
LFC64:  BNE LFC71
LFC66:  JSR LFD0A
LFC69:  BCC LFC71
LFC6B:  PLA
LFC6C:  PLA
LFC6D:  PLA
LFC6E:  JMP LD315
LFC71:  LDA TimeStopTimer
LFC73:  BEQ LFC79
LFC75:  BMI LFC79
LFC77:  DEC TimeStopTimer
LFC79:  LDA #$FF
LFC7B:  JSR GenRandomNum        ;($E64E)Generate random number between 0 and Accum-1.
LFC7E:  AND #$1C
LFC80:  BNE LFC88
LFC82:  LDA $00
LFC84:  AND #$03
LFC86:  STA $D5
LFC88:  INC FirstMoonPhase
LFC8A:  INC $D4
LFC8C:  LDA FirstMoonPhase
LFC8E:  AND #$0F
LFC90:  CMP #$0C
LFC92:  BNE LFCA3
LFC94:  CLC
LFC95:  LDA FirstMoonPhase
LFC97:  ADC #$10
LFC99:  AND #$F0
LFC9B:  CMP #$80
LFC9D:  BNE LFCA1
LFC9F:  LDA #$00
LFCA1:  STA FirstMoonPhase
LFCA3:  LDA SecondMoonPhase
LFCA5:  AND #$03
LFCA7:  BNE LFCBB
LFCA9:  CLC
LFCAA:  LDA SecondMoonPhase
LFCAC:  ADC #$10
LFCAE:  AND #$F0
LFCB0:  CMP #$80
LFCB2:  BNE LFCB6
LFCB4:  LDA #$00
LFCB6:  STA SecondMoonPhase
LFCB8:  JSR LFCC0
LFCBB:  PLA
LFCBC:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFCBF:  RTS

LFCC0:  LDA CurPRGBank
LFCC2:  PHA
LFCC3:  LDA #BANK_HELPERS1
LFCC5:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFCC8:  JSR $B200
LFCCB:  PLA
LFCCC:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFCCF:  RTS

;----------------------------------------------------------------------------------------------------

_SetCharSprites:
LFCD0:  LDA MapProperties       ;Is this a dungeon map?
LFCD2:  AND #MAP_DUNGEON        ;
LFCD4:  BNE +                   ;If so, branch to exit.

LFCD6:  LDA CurPRGBank
LFCD8:  PHA
LFCD9:  LDA #BANK_HELPERS1
LFCDB:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFCDE:  JSR $BC00
LFCE1:  PLA
LFCE2:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFCE5:* RTS

;----------------------------------------------------------------------------------------------------

LFCE6:  LDY #$0B
LFCE8:  LDA (Pos2ChrPtr),Y
LFCEA:  CMP #$03
LFCEC:  BCC LFCF3
LFCEE:  LDA #SPRT_HIDE
LFCF0:  STA $7314
LFCF3:  LDA (Pos3ChrPtr),Y
LFCF5:  CMP #$03
LFCF7:  BCC LFCFE
LFCF9:  LDA #SPRT_HIDE
LFCFB:  STA $7324
LFCFE:  LDA (Pos4ChrPtr),Y
LFD00:  CMP #$03
LFD02:  BCC LFD09
LFD04:  LDA #SPRT_HIDE
LFD06:  STA $7334
LFD09:  RTS

LFD0A:  LDA CurPRGBank
LFD0C:  PHA
LFD0D:  LDA #BANK_HELPERS1
LFD0F:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFD12:  JSR $BD00
LFD15:  PLA
LFD16:  PHP
LFD17:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFD1A:  PLP
LFD1B:  RTS

;----------------------------------------------------------------------------------------------------

BlockAlign:
LFD1C:  LDA NTXPosLB            ;
LFD1E:  STA NTXPosLB16          ;Update block aligned X coordinates of character 1.
LFD20:  LDA NTXPosUB            ;
LFD22:  STA NTXPosUB16          ;

LFD24:  LDA NTYPosLB            ;
LFD26:  STA NTYPosLB16          ;
LFD28:  LDA NTYPosUB            ;Update block aligned Y coordinates of character 1.
LFD2A:  STA NTYPosUB16          ;
LFD2C:  RTS                     ;

;----------------------------------------------------------------------------------------------------

LFD2D:  LDA MapProperties
LFD2F:  AND #MAP_DUNGEON
LFD31:  BNE LFD44
LFD33:  LDX #$00
LFD35:  LDA ScreenBlocks,X
LFD38:  ORA #$C0
LFD3A:  STA ScreenBlocks,X
LFD3D:  INX
LFD3E:  BNE LFD35
LFD40:  JSR BinToBCD            ;($F4D1)Convert binary number to BCD.
LFD43:  RTS

LFD44:  LDA $B1
LFD46:  PHA
LFD47:  LDA #$00
LFD49:  STA $B1
LFD4B:  JSR LF981
LFD4E:  PLA
LFD4F:  STA $B1
LFD51:  RTS

LFD52:  LDA MapProperties
LFD54:  AND #MAP_DUNGEON
LFD56:  BNE LFD68
LFD58:  JSR BinToBCD            ;($F4D1)Convert binary number to BCD.
LFD5B:  JSR LFC45
LFD5E:  LDA #$00
LFD60:  STA $19
LFD62:  STA $18
LFD64:  JSR LE780
LFD67:  RTS
LFD68:  JSR LF981
LFD6B:  RTS

;----------------------------------------------------------------------------------------------------

StartMusic:
LFD6C:  LDX #MUS_BOAT+INIT      ;Prepare to start boat music.
LFD6E:  LDA OnBoat              ;Is the player on a boat?
LFD70:  BNE SetMusicInit        ;If so, branch to start boat music.

LFD72:  LDX #MUS_WORLD+INIT     ;Prepare to start Sosaria overworld music.
LFD74:  LDA MapProperties       ;
LFD76:  AND #MAP_MOON_PH        ;Are the moon phases currently be shown?
LFD78:  BNE SetMusicInit        ;If so, branch to start Sosaria overworld music.

LFD7A:  LDX #MUS_AMBROSIA+INIT  ;Prepare to start Ambrosia music.
LFD7C:  LDA ThisMap             ;
LFD7E:  CMP #MAP_AMBROSIA       ;Is player on the Ambrosia map?
LFD80:  BEQ SetMusicInit        ;If so, branch to start Ambrosia music.

LFD82:  LDX #MUS_EXODUS+INIT    ;Prepare to start castle Exodus music.
LFD84:  CMP #MAP_EXODUS         ;Is the player on the castle Exodus map?
LFD86:  BEQ SetMusicInit        ;If so, branch to start castle Exodus music.

LFD88:  LDX #MUS_CASTLE+INIT    ;Prepare to start Lord British castle music.
LFD8A:  CMP #MAP_LB_CSTL        ;Is the player on the Lord British castle map?
LFD8C:  BEQ SetMusicInit        ;If so, branch to start Lord British castle music.

LFD8E:  LDX #MUS_TOWN+INIT      ;Prepare to start town music.

SetMusicInit:
LFD90:  STX InitNewMusic        ;Set init music flag with selected music.
LFD92:  RTS                     ;

;----------------------------------------------------------------------------------------------------

LFD93:  LDA CurPRGBank
LFD95:  PHA
LFD96:  LDA #BANK_HELPERS2
LFD98:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFD9B:  JSR $8800
LFD9E:  PLA
LFD9F:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFDA2:  RTS

;----------------------------------------------------------------------------------------------------

LFDA3:  LDA CurPRGBank
LFDA5:  PHA
LFDA6:  LDA #BANK_HELPERS1
LFDA8:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFDAB:  JSR $BF00
LFDAE:  PLA
LFDAF:  JSR SetPRGBank          ;($FC0F)Swap out lower PRG ROM bank.
LFDB2:  RTS

LFDB3:  .byte $C0

;----------------------------------------------------------------------------------------------------

PrepUncompress:
LFDB4:  LDX #$00               ;Zero out text buffer indexes.
LFDB6:  LDY #$00               ;

LFDB8:* JSR UncompressText     ;($FDCF)uncompress 3 bytes into 4 text characters.
LFDBB:  AND #TXT_END           ;Has the end of the text string been reached?
LFDBD:  BNE -                  ;If not, branch to get more text.

LFDBF:  LDA CurPRGBank         ;Save the current lower PRG bank on the stack.
LFDC1:  PHA                    ;

LFDC2:  LDA #BANK_INTRO        ;Prepare to convert text code into tile indexes.
LFDC4:  JSR SetPRGBank         ;($FC0F)Swap out lower PRG ROM bank.
LFDC7:  JSR TextConvert        ;($B000)Convert 6-bit text code into text tile block index.

LFDCA:  PLA                    ;Reload previous lower bank.
LFDCB:  JSR SetPRGBank         ;($FC0F)Swap out lower PRG ROM bank.
LFDCE:  RTS                    ;

;----------------------------------------------------------------------------------------------------

UncompressText:
LFDCF:  LDA (TextCharPtr),Y     ;
LFDD1:  STA TextBuffer,X        ;
LFDD4:  INY                     ;
LFDD5:  LDA (TextCharPtr),Y     ;
LFDD7:  STA TextBuffer+1,X      ;Store the 3 compressed data bytes in the text buffer.
LFDDA:  INY                     ;
LFDDB:  LDA (TextCharPtr),Y     ;
LFDDD:  STA TextBuffer+2,X      ;
LFDE0:  INY                     ;

LFDE1:  AND #$3F
LFDE3:  STA TextBuffer+3,X
LFDE6:  LDA TextBuffer+1,X
LFDE9:  ASL TextBuffer+2,X
LFDEC:  ROL
LFDED:  ASL TextBuffer+2,X
LFDF0:  ROL
LFDF1:  AND #$3F
LFDF3:  STA TextBuffer+2,X

LFDF6:  LDA TextBuffer,X
LFDF9:  ASL TextBuffer+1,X
LFDFC:  ROL
LFDFD:  ASL TextBuffer+1,X
LFE00:  ROL
LFE01:  ASL TextBuffer+1,X
LFE04:  ROL
LFE05:  ASL TextBuffer+1,X
LFE08:  ROL
LFE09:  AND #$3F
LFE0B:  STA TextBuffer+1,X

LFE0E:  LDA TextBuffer,X        ;
LFE11:  LSR                     ;Get 6 MSBs of 1st byte to form 1st uncompressed byte.
LFE12:  LSR                     ;
LFE13:  STA TextBuffer,X        ;

LFE16:  LDA TextBuffer,X
LFE19:  CMP #$3F
LFE1B:  BEQ EndUncompress

LFE1D:  LDA TextBuffer+1,X
LFE20:  CMP #$3F
LFE22:  BEQ EndUncompress

LFE24:  LDA TextBuffer+2,X
LFE27:  CMP #$3F
LFE29:  BEQ EndUncompress

LFE2B:  LDA TextBuffer+3,X
LFE2E:  CMP #$3F
LFE30:  BEQ EndUncompress

LFE32:  LDA #$01                ;Indicate the end of the text string has not been reached.
LFE34:  JMP +                   ;

EndUncompress:
LFE37:  LDA #$00                ;Indicate the end of the text string has been reached.

LFE39:* INX                     ;
LFE3A:  INX                     ;
LFE3B:  INX                     ;Increment index to next available buffer slot.
LFE3C:  INX                     ;
LFE3D:  RTS                     ;

;----------------------------------------------------------------------------------------------------

LFE3E:  .byte $0F, $0F, $0F, $0F, $0F, $30, $11, $0C, $0F, $16, $37, $19, $0F, $0A, $19, $29
LFE4E:  .byte $0F, $30, $01, $26, $0F, $06, $15, $26, $0F, $30, $3F, $3D, $0F, $30, $15, $26
LFE5E:  .byte $0F, $0F, $0F, $0F, $0F, $30, $11, $0C, $0F, $22, $20, $00, $0F, $22, $00, $20
LFE6E:  .byte $0F, $30, $01, $26, $0F, $06, $15, $26, $0F, $30, $3F, $3D, $0F, $30, $15, $26

;----------------------------------------------------------------------------------------------------

;Palette used to flash the screen when casting certain spells.

FlashPal:
LFE7E:  .byte $10, $10, $10, $10, $10, $29, $0A, $19, $10, $34, $38, $3C, $10, $0F, $0C, $11
LFE8E:  .byte $10, $30, $15, $36, $10, $30, $02, $36, $10, $06, $15, $26, $10, $30, $0A, $26

;----------------------------------------------------------------------------------------------------

LFE9E:  .byte $FF, $FF

;----------------------------------------------------------------------------------------------------

;Byte 0 - The bank containing the map data.
;Byte 2, byte 1 - Pointer to map data.
;Byte 4, byte 3 - Pointer to NPC data(not used for cave maps).
;Byte 5 - Y start position on map(except dungeons and overworld).
;Byte 6 - X start position on map(except dungeons and overworld).
;Byte 7 - ?

MapDatTbl:
LFEA0:  .byte $00, $00, $80, $00, $B8, $16, $2A, $00 ;Overworld.
LFEA8:  .byte $00, $00, $98, $00, $BB, $21, $00, $03 ;Town of Fawn.
LFEB0:  .byte $02, $00, $90, $00, $BB, $20, $00, $81 ;Cave of Gold.
LFEB8:  .byte $02, $00, $98, $00, $BB, $20, $00, $80 ;Cave of Death.
LFEC0:  .byte $00, $00, $A8, $00, $BD, $20, $00, $05 ;Town of Moon.
LFEC8:  .byte $00, $00, $A0, $00, $BC, $20, $00, $04 ;Town of Yew.
LFED0:  .byte $00, $00, $88, $00, $B9, $3F, $20, $01 ;Lord British castle.
LFED8:  .byte $00, $00, $90, $00, $BA, $20, $00, $02 ;Royal city.
LFEE0:  .byte $02, $00, $88, $00, $BB, $20, $00, $85 ;Cave of Madness.
LFEE8:  .byte $02, $00, $B0, $00, $BB, $20, $00, $82 ;Cave of Moon.
LFEF0:  .byte $01, $00, $98, $00, $BB, $1E, $00, $0A ;Town of Devil Guard.
LFEF8:  .byte $01, $00, $90, $00, $BA, $20, $00, $09 ;Town of Death Gulch.
LFF00:  .byte $02, $00, $80, $00, $BB, $20, $00, $83 ;Cave of Fire.
LFF08:  .byte $01, $00, $88, $00, $B9, $20, $00, $08 ;Town of Gray
LFF10:  .byte $02, $00, $A8, $00, $BB, $20, $00, $86 ;Cave of Sol.
LFF18:  .byte $01, $00, $A8, $00, $BD, $36, $20, $0C ;Ambrosia.
LFF20:  .byte $02, $00, $A0, $00, $BB, $20, $00, $84 ;Cave of Fool.
LFF28:  .byte $01, $00, $80, $00, $B8, $20, $00, $07 ;Town of Montor West.
LFF30:  .byte $00, $00, $B0, $00, $BE, $20, $00, $06 ;Town of Montor East.
LFF38:  .byte $01, $00, $A0, $00, $BC, $20, $00, $0B ;Town of Dawn.
LFF40:  .byte $01, $00, $B0, $00, $BE, $3F, $20, $0D ;Castle of Exodus.
LFF48:  .byte $06, $00, $90, $00, $98, $00, $1F, $0D ;Shrine of intelligence
LFF50:  .byte $06, $00, $90, $00, $98, $1F, $00, $0D ;Shrine of Wisdom.
LFF58:  .byte $06, $00, $90, $00, $98, $1F, $3F, $0D ;Shrine of Strength.
LFF60:  .byte $06, $00, $90, $00, $98, $3F, $1F, $0D ;Shrine of Dexterity.
LFF68:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF ;Not used.

;----------------------------------------------------------------------------------------------------

;The following table contains the X,Y return coordinates
;on the overworld map when exiting sub map.

SubMapTbl:
LFF70:  .byte $00, $00          ;Not used.
LFF72:  .byte $1E, $02          ;XY position of Fawn.
LFF74:  .byte $38, $06          ;XY position of Cave of Gold.
LFF76:  .byte $2E, $07          ;XY position of Cave of Death.
LFF78:  .byte $06, $0D          ;XY position of Moon.
LFF7A:  .byte $22, $10          ;XY position of Yew.
LFF7C:  .byte $2D, $12          ;XY position of Lord British's Castle.
LFF7E:  .byte $2E, $13          ;XY position of the Royal City.
LFF80:  .byte $09, $1C          ;XY position of Cave of Madness.
LFF82:  .byte $3A, $1E          ;XY position of Cave of Moon.
LFF84:  .byte $12, $1F          ;XY position of Devil Guard.
LFF86:  .byte $38, $1F          ;XY position of Death Gulch.
LFF88:  .byte $31, $22          ;XY position of Cave of Fire.
LFF8A:  .byte $07, $2C          ;XY position of Gray.
LFF8C:  .byte $3A, $2C          ;XY position of Cave of Sol.
LFF8E:  .byte $20, $36          ;XY position of Ambrosia.
LFF90:  .byte $13, $39          ;XY position of Cave of Fool.
LFF92:  .byte $2F, $3A          ;XY position of Montor West.
LFF94:  .byte $31, $3A          ;XY position of Montor East.
LFF96:  .byte $26, $36          ;XY position of Dawn.
LFF98:  .byte $0A, $35          ;XY position of Exoduc Castle.

;----------------------------------------------------------------------------------------------------

;Unused.
LFF9A:  .byte $FF, $FF, $FF, $FF, $FF, $FF

;----------------------------------------------------------------------------------------------------

RESET:
LFFA0:  LDA #$00                ;Disable NMI.
LFFA2:  STA PPUControl0         ;

LFFA5:  LDX #$02                ;
LFFA7:* LDA PPUStatus           ;Wait for at least one full screen to be drawn before continuing.
LFFAA:  BPL -                   ;Writes to PPUControl register are ignored for 30,000 clock cycles
LFFAC:  DEX                     ;after reset or power cycle.
LFFAD:  BNE -                   ;

LFFAF:  ORA #$FF                ;Reset the MMC1 chip. Bank0F at address $C000.
LFFB1:  STA MMCCfg              ;

LFFB4:  LDA #$0E                ;Configure the MMC1. Vertical mirroring, Last bank fixed.
LFFB6:  JSR ConfigMMC           ;($FFBC)Configure MMC1 mapper.
LFFB9:  JMP Reset1              ;($C000)Begin resetting the game.

;----------------------------------------------------------------------------------------------------

ConfigMMC:
LFFBC:  STA MMCCfg              ;
LFFBF:  LSR                     ;
LFFC0:  STA MMCCfg              ;
LFFC3:  LSR                     ;
LFFC4:  STA MMCCfg              ;Load MMC1 configuration.
LFFC7:  LSR                     ;
LFFC8:  STA MMCCfg              ;
LFFCB:  LSR                     ;
LFFCC:  STA MMCCfg              ;
LFFCF:  RTS                     ;

;----------------------------------------------------------------------------------------------------

LFFD0:  .byte $0F, $19, $07, $30, $0F, $19, $07, $30, $0F, $19, $07, $30, $0F, $19, $07, $30
LFFE0:  .byte $0F, $30, $0F, $0F, $0F, $30, $0F, $0F, $0F, $30, $0F, $0F, $0F, $30, $0F, $0F
LFFF0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

;----------------------------------------------------------------------------------------------------

LFFFA:  .word NMI               ;($EA30)NMI vector.
LFFFC:  .word RESET             ;($FFA0)Reset vector.
LFFFE:  .word IRQ               ;($ED32)IRQ vector.
