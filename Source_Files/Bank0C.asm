.org $8000

.include "Ultima_3_Defines.asm"

;----------------------------------------------------------------------------------------------------

;Forward declarations.

.alias  Reset1                  $C000
.alias  DisplayText1            $C003
.alias  LoadPPU1                $C006
.alias  LdLgCharTiles1          $C009
.alias  LoadnAlphaNumMaps1      $C01E
.alias  SwapBnkLdGFX1           $C048
.alias  MapDatTbl               $FEA0
.alias  SubMapTbl               $FF70
.alias  RESET                   $FFA0
.alias  ConfigMMC               $FFBC
.alias  NMI                     $FFF0
.alias  IRQ                     $FFF0

;----------------------------------------------------------------------------------------------------

DoCreateMenus:
L8000:  LDA #>CreatePalette     ;
L8002:  STA PPUPyLdPtrUB        ;Load palette data used while creating save games and characters.
L8004:  LDA #<CreatePalette     ;
L8006:  STA PPUPyLdPtrLB        ;

L8008:  JSR LoadPPUPalData      ;($9772)Load palette data into PPU buffer.

L800B:  LDA #$01                ;Stop animations of NPCs.
L800D:  STA TimeStopTimer       ;

L800F:  LDA #MUS_INTRO+INIT     ;Start the create character music.
L8011:  STA InitNewMusic        ;

L8013:  LDA #ANIM_ENABLE        ;Enable NPC animations.
L8015:  STA DisNPCMovement      ;

L8017:  JSR PrepLoadWnd         ;($8030)Prepare to show the load saved game menu.

L801A:  LDA #ANIM_DISABLE       ;Disable NPC animations.
L801C:  STA DisNPCMovement      ;

L801E:  LDA #$00                ;
L8020:  STA CurPPUConfig1       ;Turn off screen and disable time stop.
L8022:  STA TimeStopTimer       ;

L8024:  LDA #>JourneyOnPal      ;
L8026:  STA PPUPyLdPtrUB        ;Load the main game palette data.
L8028:  LDA #<JourneyOnPal      ;
L802A:  STA PPUPyLdPtrLB        ;

L802C:  JSR LoadPPUPalData      ;($9772)Load palette data into PPU buffer.
L802F:  RTS                     ;

;----------------------------------------------------------------------------------------------------

PrepLoadWnd:
L8030:  LDA #$00                ;Indicate no new games created.
L8032:  STA NewGmCreated        ;

PrepLoadLoop:
L8034:  LDA #$01                ;Stop NPC animations.
L8036:  STA TimeStopTimer       ;

L8038:  JSR DoLoadWindow        ;($837F)Show the load game/new game menu.

L803B:  PHA                     ;Save A on the stack.

L803C:  LDA #$00                ;Disable the time stop timer.
L803E:  STA TimeStopTimer       ;This allows the sprites to fully animate.

L8040:  PLA                     ;Restore A from the stack.

L8041:  CMP #$03                ;Was the register new game option selected?
L8043:  BNE PrepCreateCont      ;If not branch to load a game.

L8045:  JSR NameSaveGame        ;($8679)Load screen where player enters save game name.
L8048:  JSR InitSGSlot          ;($BE53)Initialize save game slot.

L804B:  LDA #$01                ;Indicate a new save game has been created.
L804D:  STA NewGmCreated        ;

L804F:  JMP PrepLoadLoop        ;($8034)Loop to begin showing the load save game window.

PrepCreateCont:
L8052:  JSR CreateContinue      ;($88BF)Show the create/continue window.

L8055:  CMP #$00                ;Was CREATE selected?
L8057:  BNE JourneyOnward       ;If not, branch.

CreateLoop:
L8059:  JSR DoCreate            ;($896B)Load and handle the create window.

L805C:  CMP #$01                ;Was CREATE selected?
L805E:  BEQ PrepCreateChr       ;If so, branch to do character creation.

L8060:  CMP #$02                ;Was DISCARD selected?
L8062:  BEQ PrepDiscard         ;If so, branch to do character discard.

L8064:  CMP #$03                ;Was FORM PARTY selected?
L8066:  BEQ PrepFormParty       ;If so, branch to do form party.

L8068:  CMP #$04                ;Was PREVIOUS MENU selected?
L806A:  BEQ PrepCreateCont      ;If so, branch back to create/continue menu.

PrepExamine:
L806C:  JSR ChrList             ;($8A7C)Character list screen.
L806F:  JMP CreateLoop          ;($8059)Loop back to the create window.

PrepCreateChr:
L8072:  JSR CreateChr           ;($89D5)Run character creation functions.

L8075:  CPX #$00                ;Did player choose to create a hand-made character?
L8077:  BEQ PrepHandMade        ;If so, branch.

L8079:  CPX #$01                ;Did player choose to create a ready made character?
L807B:  BEQ PrepReadyMade       ;If so, branch.

L807D:  BNE CreateLoop          ;($8059)Loop back to the create window.

PrepFormParty:
L807F:  JSR FormParty           ;($8AB0)Form a party of 4 characters.
L8082:  BCS CreateLoop          ;Does save game have at least 4 characters created? If not, branch.
L8084:  JMP PrepJourneyOnward   ;($80B3)Prepare to start the main game.

PrepDiscard:
L8087:  JSR Discard             ;($9470)Show discard character screen.
L808A:  JMP CreateLoop          ;($8059)Loop back to the create window.

PrepHandMade:
L808D:  JSR DoHandMade          ;($8D4B)Create a hand made character.
L8090:  JSR EnterCharName       ;($90FA)Enter a newly created character's name.
L8093:  JMP PrepCreateChr       ;($8072)Prepare to show create character window.

PrepReadyMade:
L8096:  JSR DoReadyMade         ;($91C2)Create a ready made character.
L8099:  BCS PrepCreateChr       ;Are there at least 4 empty character slots? If not, branch.

L809B:  LDX #$00                ;Zero out character created counter.

ReadyMadeLoop:
L809D:  TXA                     ;Save counter on the stack.
L809E:  PHA                     ;

L809F:  ASL                     ;*2. pointers are 2 bytes.
L80A0:  TAX                     ;

L80A1:  LDA PosChrPtrLB,X       ;
L80A3:  STA SGCharPtrLB         ;Get a pointer to the next open character slot.
L80A5:  LDA PosChrPtrUB,X       ;
L80A7:  STA SGCharPtrUB         ;

L80A9:  JSR EnterCharName       ;($90FA)Enter a newly created character's name.

L80AC:  PLA                     ;Restore counter from the stack.
L80AD:  TAX                     ;

L80AE:  INX                     ;Have 4 ready made characters been named?
L80AF:  CPX #$04                ;
L80B1:  BNE ReadyMadeLoop       ;If not, branch to do another on.

PrepJourneyOnward:
L80B3:  LDA NewGmCreated        ;Was a new game created?
L80B5:  BEQ JourneyOnward       ;If so, start party on overworld map. If not, branch.

L80B7:  LDA #$01                ;Activate the time stop timer.
L80B9:  STA TimeStopTimer       ;
L80BB:  JSR DoKingSequence      ;($8127)Show sequence where Lord British talks to the characters.

L80BE:  LDA #$00                ;Disable the time stop timer.
L80C0:  STA TimeStopTimer       ;

L80C2:  JMP StartOutside        ;($8103)Start game on the overworld map.

JourneyOnward:
L80C5:  LDY #SG_MAP_PROPS       ;
L80C7:  LDA (SGDatPtr),Y        ;Is the player on the overworld map?
L80C9:  CMP #$0C                ;If so, branch to start the characters outside.
L80CB:  BEQ StartOutside        ;

L80CD:  JSR InitPPU             ;($990C)Initialize the PPU.

L80D0:  LDA #$06                ;
L80D2:  STA WndXPos             ;Window will be located at tile coords X,Y=6,18.
L80D4:  LDA #$12                ;
L80D6:  STA WndYPos             ;

L80D8:  LDA #$10                ;
L80DA:  STA WndWidth            ;Window will be 16 tiles wide and 8 tiles tall.
L80DC:  LDA #$08                ;
L80DE:  STA WndHeight           ;

L80E0:  JSR DrawWndBrdr         ;($97A9)Draw window border.

L80E3:  LDA #$27                ;WELCOME! text.
L80E5:  STA TextIndex           ;

L80E7:  LDA #$08                ;
L80E9:  STA TXTXPos             ;Text will be at tile coords X,Y=8,20.
L80EB:  LDA #$14                ;
L80ED:  STA TXTYPos             ;

L80EF:  LDA #$0C                ;
L80F1:  STA TXTClrCols          ;Clear 12 columns and 3 rows for the text string.
L80F3:  LDA #$03                ;
L80F5:  STA TXTClrRows          ;

L80F7:  JSR ShowTextString      ;($995C)Show a text string on the screen.

L80FA:  LDA #$64                ;
L80FC:  CLC                     ;
L80FD:  ADC Increment0          ;Wait 100 frames before continuing.
L80FF:* CMP Increment0          ;
L8101:  BNE -                   ;

StartOutside:
L8103:  JSR LoadSGData          ;($BA41)Load save game data into game RAM.

L8106:  LDA #<Ch1Data           ;
L8108:  STA Pos1ChrPtrLB        ;Set a pointer to character 1's data base address.
L810A:  LDA #>Ch1Data           ;
L810C:  STA Pos1ChrPtrUB        ;

L810E:  LDA #<Ch2Data           ;
L8110:  STA Pos2ChrPtrLB        ;Set a pointer to character 2's data base address.
L8112:  LDA #>Ch2Data           ;
L8114:  STA Pos2ChrPtrUB        ;

L8116:  LDA #<Ch3Data           ;
L8118:  STA Pos3ChrPtrLB        ;Set a pointer to character 3's data base address.
L811A:  LDA #>Ch3Data           ;
L811C:  STA Pos3ChrPtrUB        ;

L811E:  LDA #<Ch4Data           ;
L8120:  STA Pos4ChrPtrLB        ;
L8122:  LDA #>Ch4Data           ;Set a pointer to character 4's data base address.
L8124:  STA Pos4ChrPtrUB        ;
L8126:  RTS                     ;

;----------------------------------------------------------------------------------------------------

DoKingSequence:
L8127:  JSR InitPPU             ;($990C)Initialize the PPU.

L812A:  LDA #$FF                ;Turn on the time stop timer.
L812C:  STA TimeStopTimer       ;

L812E:  LDA #CLS_PALADIN        ;
L8130:  STA Ch1Class            ;
L8132:  STA Ch2Class            ;Load a default class of paladin for all 4 characters.
L8134:  STA Ch3Class            ;
L8136:  STA Ch4Class            ;

L8138:  LDA #$00                ;Turn off the screen.
L813A:  STA CurPPUConfig1       ;

;Load tile patterns.
L813C:  LDA #>GFXStartNew       ;
L813E:  STA PPUSrcPtrUB         ;Set a pointer to the tile pattern data on this bank.
L8140:  LDA #<GFXStartNew       ;
L8142:  STA PPUSrcPtrLB         ;

L8144:  LDA #$1A                ;
L8146:  STA PPUDstPtrUB         ;Prepare to copy GFX data into pattern table 1
L8148:  LDA #$40                ;starting at tile index $A4.
L814A:  STA PPUDstPtrLB         ;

L814C:  LDA #$05                ;
L814E:  STA PPUByteCntUB        ;Prepare to transfer 1344 bytes into the PPU(84 tiles).
L8150:  LDA #$40                ;
L8152:  STA PPUByteCntLB        ;

L8154:  JSR LoadPPU1            ;($C006)Load values into PPU.

L8157:  LDA #>LBRoomNTDat       ;
L8159:  STA PPUSrcPtrUB         ;Set a pointer to the name table data on this bank.
L815B:  LDA #<LBRoomNTDat       ;
L815D:  STA PPUSrcPtrLB         ;

L815F:  LDA #PPU_NT0_UB         ;
L8161:  STA PPUDstPtrUB         ;Prepare write the entire contents of name table 0.
L8163:  LDA #PPU_NT0_LB         ;
L8165:  STA PPUDstPtrLB         ;

L8167:  LDA #$04                ;
L8169:  STA PPUByteCntUB        ;Prepare to transfer 1024 bytes into the PPU.
L816B:  LDA #$00                ;
L816D:  STA PPUByteCntLB        ;

L816F:  JSR LoadPPU1            ;($C006)Load values into PPU.

L8172:  LDA #>LBRoomATDat       ;
L8174:  STA PPUSrcPtrUB         ;Set a pointer to the attribute table data on this bank.
L8176:  LDA #<LBRoomATDat       ;
L8178:  STA PPUSrcPtrLB         ;

L817A:  LDA #PPU_AT0_UB         ;
L817C:  STA PPUDstPtrUB         ;Prepare write the entire contents of attribute table 0.
L817E:  LDA #PPU_AT0_LB         ;
L8180:  STA PPUDstPtrLB         ;

L8182:  LDA #$00                ;
L8184:  STA PPUByteCntUB        ;Prepare to transfer 64 bytes into the PPU.
L8186:  LDA #$40                ;
L8188:  STA PPUByteCntLB        ;

L818A:  JSR LoadPPU1            ;($C006)Load values into PPU.

L818D:  LDA #>LBRoomPalDat      ;
L818F:  STA PPUPyLdPtrUB        ;Load the palette data for the Lord British throne room scene.
L8191:  LDA #<LBRoomPalDat      ;
L8193:  STA PPUPyLdPtrLB        ;

L8195:  JSR LoadPPUPalData      ;($9772)Load palette data into PPU buffer.

L8198:  LDA #<Ch1Data           ;
L819A:  STA ChrDestPtrLB        ;Get a pointer to character 1's data.
L819C:  LDA #>Ch1Data           ;
L819E:  STA ChrDestPtrUB        ;

L81A0:  LDA SGDatPtrLB          ;
L81A2:  STA SGCharPtrLB         ;Get a pointer to the character list for the given save game.
L81A4:  LDX SGDatPtrUB          ;SGDatPtr=$6100, $6700 or $6D00.
L81A6:  INX                     ;
L81A7:  STX SGCharPtrUB         ;

L81A9:  LDX #$00                ;Zero out the counter. Will be either $00, $10, $20 or $30.

;Copy character data from character pool to active character slot.
CopyChrDatLoop:
L81AB:  TXA                     ;
L81AC:  LSR                     ;Transfer X to A and move upper nibble to lower nibble.
L81AD:  LSR                     ;A will now equal $00, $01, $02 or $03.
L81AE:  LSR                     ;
L81AF:  LSR                     ;

L81B0:  CLC                     ;A will now equal $10, $11, $12 or $13.
L81B1:  ADC #$10                ;

L81B3:  TAY                     ;
L81B4:  LDA (SGDatPtr),Y        ;Transfer the character pool index of the requested character
L81B6:  STA ChrSrcPtrUB         ;into the character data source pointer($1300-$0000).
L81B8:  LDA #$00                ;
L81BA:  STA ChrSrcPtrLB         ;

L81BC:  LSR ChrSrcPtrUB         ;
L81BE:  ROR ChrSrcPtrLB         ;/4. ChrSrcPtr=$04C0 through $0000.
L81C0:  LSR ChrSrcPtrUB         ;
L81C2:  ROR ChrSrcPtrLB         ;

L81C4:  CLC                     ;
L81C5:  LDA SGCharPtrLB         ;Add base address of character data to calculated offset.
L81C7:  ADC ChrSrcPtrLB         ;
L81C9:  STA ChrSrcPtrLB         ;

L81CB:  LDA SGCharPtrUB         ;
L81CD:  ADC ChrSrcPtrUB         ;Carry into upper byte, if necessary.
L81CF:  STA ChrSrcPtrUB         ;

L81D1:  LDY #$00                ;Zero out the index.

L81D3:* LDA (ChrSrcPtr),Y       ;
L81D5:  STA (ChrDestPtr),Y      ;Transfer all 64 bytes of data from selected character in the
L81D7:  INY                     ;character pool into an active character data slot.
L81D8:  CPY #$40                ;
L81DA:  BNE -                   ;

L81DC:  CLC                     ;
L81DD:  LDA ChrDestPtrLB        ;Move charcter data destination pointer to next open
L81DF:  ADC #$40                ;character slot.
L81E1:  STA ChrDestPtrLB        ;

L81E3:  LDA ChrDestPtrUB        ;
L81E5:  ADC #$00                ;Carry into upper byte, if necessary.
L81E7:  STA ChrDestPtrUB        ;

L81E9:  TXA                     ;
L81EA:  CLC                     ;Increment counter to next character.
L81EB:  ADC #$10                ;

L81ED:  TAX                     ;Have 4 character data transfers been completed?
L81EE:  CPX #$40                ;
L81F0:  BNE CopyChrDatLoop      ;If not, branch to do another one.

L81F2:  LDA #<Ch1Data           ;
L81F4:  STA Pos1ChrPtrLB        ;Set character 1 to position 1.
L81F6:  LDA #>Ch1Data           ;
L81F8:  STA Pos1ChrPtrUB        ;

L81FA:  LDA #<Ch2Data           ;
L81FC:  STA Pos2ChrPtrLB        ;Set character 2 to position 2.
L81FE:  LDA #>Ch2Data           ;
L8200:  STA Pos2ChrPtrUB        ;

L8202:  LDA #<Ch3Data           ;
L8204:  STA Pos3ChrPtrLB        ;Set character 3 to position 3.
L8206:  LDA #>Ch3Data           ;
L8208:  STA Pos3ChrPtrUB        ;

L820A:  LDA #<Ch4Data           ;
L820C:  STA Pos4ChrPtrLB        ;Set character 4 to position 4.
L820E:  LDA #>Ch4Data           ;
L8210:  STA Pos4ChrPtrUB        ;

L8212:  JSR SwapBnkLdGFX1       ;($C048)Save lower bank then load character sprites GFX.

L8215:  LDX #$00                ;Zero out the index.

L8217:* LDA #SPRT_HIDE          ;
L8219:  STA SpriteBuffer,X      ;
L821C:  INX                     ;
L821D:  INX                     ;Hide all sprites off the bottom of the screen.
L821E:  INX                     ;
L821F:  INX                     ;
L8220:  BNE -                   ;

L8222:  LDA #SCREEN_ON          ;Turn the screen on.
L8224:  STA CurPPUConfig1       ;

L8226:  LDA #$01                ;Wait 1 frame.
L8228:  JSR WaitSomeFrames      ;($BE4B)Wait a number of frames given by A.

L822B:  JSR MovePlayerChars     ;($8281)Move the player's 4 characters towards Lord British.

L822E:  LDA #$04                ;
L8230:  STA WndXPos             ;Window will be located at tile coords X,Y=4,22.
L8232:  LDA #$16                ;
L8234:  STA WndYPos             ;

L8236:  LDA #$18                ;
L8238:  STA WndWidth            ;Window will be 24 tiles wide and 6 tiles tall.
L823A:  LDA #$06                ;
L823C:  STA WndHeight           ;

L823E:  JSR DrawWndBrdr         ;($97A9)Draw window border.

L8241:  LDA #$20                ;WELCOME YE FOUR BRAVE SOULS text.

KingTextLoop:
L8243:  PHA                     ;Save text index on stack.

L8244:  LDA #$D4                ;Hide the upper 10 sprites.
L8246:  STA HideUprSprites      ;

L8248:  LDA #$06                ;
L824A:  STA TXTXPos             ;Text will be at tile coords X,Y=6,24.
L824C:  LDA #$18                ;
L824E:  STA TXTYPos             ;

L8250:  LDA #$14                ;
L8252:  STA TXTClrCols          ;Clear 20 columns and 2 rows for the text string.
L8254:  LDA #$02                ;
L8256:  STA TXTClrRows          ;

L8258:  PLA                     ;Get the text index from the stack.
L8259:  PHA                     ;
L825A:  STA TextIndex           ;
L825C:  JSR ShowTextString      ;($995C)Show a text string on the screen.

L825F:  CLC                     ;
L8260:  LDA Increment0          ;
L8262:  ADC #$B4                ;Wait 180 frames before continuing.
L8264:* CMP Increment0          ;
L8266:  BNE -                   ;

L8268:  PLA                     ;Has Lord British said his last segment of intro text?
L8269:  CMP #$25                ;
L826B:  BEQ +                   ;If not, branch to get next segment of text.

L826D:  CLC                     ;Increment to next Lord British text segment.
L826E:  ADC #$01                ;
L8270:  JMP KingTextLoop        ;($8243)Display next segment of Lord British intro text.

L8273:* JSR GetInputPress       ;($98EE)Get input button press and account for retrigger.
L8276:  LDA Pad1Input           ;
L8278:  CMP #BTN_A              ;Wait until player pushes the A button to continue.
L827A:  BNE -                   ;

L827C:  LDA #$00                ;
L827E:  STA TimeStopTimer       ;Turn off time stop before exiting.
L8280:  RTS                     ;

;----------------------------------------------------------------------------------------------------

MovePlayerChars:
L8281:  LDA #$FF                ;Move character -1 pixels in the X direction.
L8283:  STA ChrDX               ;

L8285:  LDX #$04                ;Character composed of sprites 1,2,3,4.

L8287:  LDA #$01                ;Move character down 1 pixel for every X direction update.
L8289:  STA ChrDYVar            ;
L828B:  STA ChrDYConst          ;
L828D:  JSR Move1Char           ;($82BE)Move 1 character towards Lord British.

L8290:  LDA #$FF                ;Move character -1 pixels in the X direction.
L8292:  STA ChrDX               ;

L8294:  LDX #$14                ;Character composed of sprites ,5,6,7,8.

L8296:  LDA #$03                ;Move character down 3 pixels for every X direction update.
L8298:  STA ChrDYVar            ;
L829A:  STA ChrDYConst          ;
L829C:  JSR Move1Char           ;($82BE)Move 1 character towards Lord British.

L829F:  LDA #$01                ;Move character 1 pixel in the X direction.
L82A1:  STA ChrDX               ;

L82A3:  LDX #$24                ;Character composed of sprites 9,10,11,12.

L82A5:  LDA #$03                ;Move character down 3 pixels for every X direction update.
L82A7:  STA ChrDYVar            ;
L82A9:  STA ChrDYConst          ;
L82AB:  JSR Move1Char           ;($82BE)Move 1 character towards Lord British.

L82AE:  LDA #$01                ;Move character 1 pixel in the X direction.
L82B0:  STA ChrDX               ;

L82B2:  LDX #$34                ;Character composed of sprites 13,14,15,16.

L82B4:  LDA #$01                ;Move character down 1 pixel for every X direction update.
L82B6:  STA ChrDYVar            ;
L82B8:  STA ChrDYConst          ;
L82BA:  JSR Move1Char           ;($82BE)Move 1 character towards Lord British.
L82BD:  RTS                     ;

;----------------------------------------------------------------------------------------------------

Move1Char:
L82BE:  LDA #$78                ;
L82C0:  STA NewChrX             ;Character starts at pixel position X,Y=120,32.
L82C2:  LDA #$20                ;
L82C4:  STA NewChrY             ;

UpdateChrXYLoop:
L82C6:  JSR UpdateChrPosition   ;($82E6)Update the XY position of the character.

L82C9:  LDA #$03                ;Wait for 3 frames.
L82CB:  JSR WaitSomeFrames      ;($BE4B)Wait a number of frames given by A.

L82CE:  INC NewChrY             ;Move the character down 1 pixel.
L82D0:  DEC ChrDYVar            ;Is it time to update the X position?
L82D2:  BNE UpdateChrXYLoop     ;If not, branch to move the character down another pixel.

L82D4:  CLC                     ;
L82D5:  LDA NewChrX             ;Move the character in the X direction 1 pixel.
L82D7:  ADC ChrDX               ;
L82D9:  STA NewChrX             ;

L82DB:  LDA ChrDYConst          ;Reload the Y position counter.
L82DD:  STA ChrDYVar            ;

L82DF:  LDA NewChrY             ;
L82E1:  CMP #$50                ;Has the character moved to pixel position Y=80?
L82E3:  BNE UpdateChrXYLoop     ;If not, branch to move the character sprites some more.
L82E5:  RTS                     ;

;----------------------------------------------------------------------------------------------------

UpdateChrPosition:
L82E6:  LDA NewChrX             ;
L82E8:  STA SpriteBuffer+$3,X   ;Update the X position of the upper 2 character sprites.
L82EB:  STA SpriteBuffer+$7,X   ;

L82EE:  CLC                     ;Move to lower 2 sprites.
L82EF:  ADC #$08                ;

L82F1:  STA SpriteBuffer+$B,X   ;Update the X position of the lower 2 character sprites.
L82F4:  STA SpriteBuffer+$F,X   ;

L82F7:  LDA NewChrY             ;
L82F9:  STA SpriteBuffer,X      ;Update the Y position of the upper 2 character sprites.
L82FC:  STA SpriteBuffer+$8,X   ;

L82FF:  CLC                     ;Move to lower 2 sprites.
L8300:  ADC #$08                ;

L8302:  STA SpriteBuffer+$4,X   ;
L8305:  STA SpriteBuffer+$C,X   ;Update the Y position of the lower 2 character sprites.
L8308:  RTS                     ;

;----------------------------------------------------------------------------------------------------

;Unused.
L8309:  .byte $10, $30, $50, $70, $90, $98, $A0, $A8, $B0, $B8, $C0, $00, $03, $00, $01, $03
L8319:  .byte $01, $01, $03, $00, $00, $01, $40, $10, $00, $60, $48, $11, $00, $60, $40, $12
L8329:  .byte $00, $68, $48, $13, $00, $68, $40, $30, $00, $70, $48, $31, $00, $70, $40, $32
L8339:  .byte $00, $78, $48, $33, $00, $78, $40, $50, $01, $80, $48, $51, $01, $80, $40, $52
L8349:  .byte $01, $88, $48, $53, $01, $88, $40, $70, $01, $90, $48, $71, $01, $90, $40, $72
L8359:  .byte $01, $98, $48, $73, $01, $98

;----------------------------------------------------------------------------------------------------

;Palette data for the Lord British throne room scene.

LBRoomPalDat:
L835F:  .byte $0F, $1C, $30, $26, $0F, $30, $15, $26, $0F, $0C, $15, $36, $0F, $30, $02, $36
L836F:  .byte $0F, $30, $11, $36, $0F, $06, $15, $26, $0F, $30, $0F, $2D, $0F, $30, $15, $36

;----------------------------------------------------------------------------------------------------

DoLoadWindow:
L837F:  JSR InitPPU             ;($990C)Initialize the PPU.

L8382:  LDA #$00                ;Clear valid save game flags before finding valid saved games.
L8384:  STA ValidGamesFlags     ;

L8386:  LDA #$08                ;
L8388:  STA WndXPos             ;Window will be at screen tile location X,Y = 8,10.
L838A:  LDA #$0A                ;
L838C:  STA WndYPos             ;

L838E:  LDA #$10                ;
L8390:  STA WndWidth            ;Window will be 16 tiles high and 16 tiles wide
L8392:  LDA #$10                ;
L8394:  STA WndHeight           ;

L8396:  JSR DrawWndBrdr         ;($97A9)Draw window border.
L8399:  JSR LoadLBs             ;($9B03)Load Lord British sprites on the screen.

L839C:  LDA #$F4                ;Hide the upper 3 sprites.
L839E:  STA HideUprSprites      ;

;Check for a valid saved game at slot 1.
ChkSG1:
L83A0:  LDA SG1Valid1           ;A save game is considered valid if the first 2 bytes in the
L83A3:  CMP #SG_VALID1          ;save game slot are $41 and $42 respectively.
L83A5:  BNE ChkSG2              ;
L83A7:  LDA SG1Valid2           ;Is save game 1 a valid save game?
L83AA:  CMP #SG_VALID2          ;If not, branch to check save game 2.
L83AC:  BNE ChkSG2              ;

L83AE:  LDA ValidGamesFlags     ;
L83B0:  ORA #$01                ;Set bit 0 to indicate save game 1 is valid.
L83B2:  STA ValidGamesFlags     ;

L83B4:  LDY #$00                ;Zero the index.

L83B6:* LDA SG1Name,Y           ;
L83B9:  STA TextBuffer,Y        ;
L83BC:  INY                     ;Copy the name of the saved game into the text buffer.
L83BD:  CPY #$05                ;
L83BF:  BNE -                   ;

L83C1:  LDA #TXT_END            ;Place a string end marker in the text buffer.
L83C3:  STA TextBuffer,Y        ;

L83C6:  LDA #$0F                ;
L83C8:  STA TXTXPos             ;Text will be located at tile coords X,Y=15,12.
L83CA:  LDA #$0C                ;
L83CC:  STA TXTYPos             ;

L83CE:  LDA #$07                ;
L83D0:  STA TXTClrCols          ;Clear 7 columns and 1 row for the text string.
L83D2:  LDA #$01                ;
L83D4:  STA TXTClrRows          ;

L83D6:  LDA #TXT_DBL_SPACE      ;Indicate text is already in the buffer and double spaced.
L83D8:  STA TextIndex           ;
L83DA:  JSR ShowTextString      ;($995C)Show a text string on the screen.

;Check for a valid saved game at slot 2.
ChkSG2:
L83DD:  LDA SG2Valid1           ;A save game is considered valid if the first 2 bytes in the
L83E0:  CMP #SG_VALID1          ;save game slot are $41 and $42 respectively.
L83E2:  BNE ChkSG3              ;
L83E4:  LDA SG2Valid2           ;Is save game 2 a valid save game?
L83E7:  CMP #SG_VALID2          ;If not, branch to check save game 3.
L83E9:  BNE ChkSG3              ;

L83EB:  LDA ValidGamesFlags     ;
L83ED:  ORA #$02                ;Set bit 1 to indicate save game 2 is valid.
L83EF:  STA ValidGamesFlags     ;

L83F1:  LDY #$00                ;Zero the index.

L83F3:* LDA SG2Name,Y           ;
L83F6:  STA TextBuffer,Y        ;
L83F9:  INY                     ;Copy the name of the saved game into the text buffer.
L83FA:  CPY #$05                ;
L83FC:  BNE -                   ;

L83FE:  LDA #TXT_END            ;Place a string end marker in the text buffer.
L8400:  STA TextBuffer,Y        ;

L8403:  LDA #$0F                ;
L8405:  STA TXTXPos             ;Text will be located at tile coords X,Y=15,15.
L8407:  LDA #$0F                ;
L8409:  STA TXTYPos             ;

L840B:  LDA #$07                ;
L840D:  STA TXTClrCols          ;Clear 7 columns and 1 row for the text string.
L840F:  LDA #$01                ;
L8411:  STA TXTClrRows          ;

L8413:  LDA #TXT_DBL_SPACE      ;Indicate text is already in the buffer and double spaced.
L8415:  STA TextIndex           ;
L8417:  JSR ShowTextString      ;($995C)Show a text string on the screen.

;Check for a valid saved game at slot 3.
ChkSG3:
L841A:  LDA SG3Valid1           ;A save game is considered valid if the first 2 bytes in the
L841D:  CMP #SG_VALID1          ;save game slot are $41 and $42 respectively.
L841F:  BNE LoadRegText         ;
L8421:  LDA SG3Valid2           ;Is save game 3 a valid save game?
L8424:  CMP #SG_VALID2          ;If not, branch to end checking for valid games.
L8426:  BNE LoadRegText         ;

L8428:  LDA ValidGamesFlags     ;
L842A:  ORA #$04                ;Set bit 2 to indicate save game 3 is valid.
L842C:  STA ValidGamesFlags     ;

L842E:  LDY #$00                ;Zero the index.

L8430:* LDA SG3Name,Y           ;
L8433:  STA TextBuffer,Y        ;
L8436:  INY                     ;Copy the name of the saved game into the text buffer.
L8437:  CPY #$05                ;
L8439:  BNE -                   ;

L843B:  LDA #TXT_END            ;Place a string end marker in the text buffer.
L843D:  STA TextBuffer,Y        ;

L8440:  LDA #$0F                ;
L8442:  STA TXTXPos             ;Text will be located at tile coords X,Y=15,18.
L8444:  LDA #$12                ;
L8446:  STA TXTYPos             ;

L8448:  LDA #$07                ;
L844A:  STA TXTClrCols          ;Clear 7 columns and 1 row for the text string.
L844C:  LDA #$01                ;
L844E:  STA TXTClrRows          ;

L8450:  LDA #TXT_DBL_SPACE      ;Indicate text is already in the buffer and double spaced.
L8452:  STA TextIndex           ;
L8454:  JSR ShowTextString      ;($995C)Show a text string on the screen.

;Load the REGISTER and ERASE text at the bottom of the load window.
LoadRegText:
L8457:  LDA #$0C                ;
L8459:  STA TXTXPos             ;Text will be located at tile coords X,Y=12,21.
L845B:  LDA #$15                ;
L845D:  STA TXTYPos             ;

L845F:  LDA #$08                ;
L8461:  STA TXTClrCols          ;Clear 8 columns and 1 row for the text string.
L8463:  LDA #$01                ;
L8465:  STA TXTClrRows          ;

L8467:  LDA #$00                ;write "REGISTER" into the text buffer.
L8469:  STA TextIndex           ;
L846B:  JSR ShowTextString      ;($995C)Show a text string on the screen.

L846E:  LDA #$0C                ;
L8470:  STA TXTXPos             ;Text will be located at tile coords X,Y=12,23.
L8472:  LDA #$17                ;
L8474:  STA TXTYPos             ;

L8476:  LDA #$0B                ;
L8478:  STA TXTClrCols          ;Clear 8 columns and 1 row for the text string.
L847A:  LDA #$01                ;
L847C:  STA TXTClrRows          ;

L847E:  LDA #$01                ;write "ERASE" into the text buffer.
L8480:  STA TextIndex           ;
L8482:  JSR ShowTextString      ;($995C)Show a text string on the screen.

;Set the position of the selector sprite.
LoadWndReset:
L8485:  LDX #$00                ;Default position of the selector sprite is in front of save game 1.

LoadWndSelectPos:
L8487:  LDA LoadWndYPosTbl,X    ;Set selector sprite Y position.
L848A:  STA SpriteBuffer        ;

L848D:  LDA #$50                ;X position of selector sprite is always X=80.
L848F:  STA SpriteBuffer+3      ;

;Check for user inputs.
LoadWndInputLoop:
L8492:  JSR GetInputPress       ;($98EE)Get input button press and account for retrigger.
L8495:  LDA Pad1Input           ;

L8497:  CMP #BTN_A              ;Was the A button pressed?
L8499:  BEQ ChkLoadSG1          ;If so, branch to process button press.

L849B:  CMP #BTN_UP             ;Was the up button pressed?
L849D:  BEQ LoadUpPressed       ;If so, branch to process button press.

L849F:  CMP #BTN_DOWN           ;Was the down button pressed?
L84A1:  BNE LoadWndInputLoop    ;If not, branch to ignire the input.

;Process user inputs.
LoadDnPressed:
L84A3:  CPX #$04                ;Is selector at bottom of window?
L84A5:  BEQ LoadWndInputLoop    ;If so, branch to ignore input.
L84A7:  INX                     ;Move selector down 1 position.
L84A8:  JMP LoadWndSelectPos    ;($8487)Set new selector sprite position.

LoadUpPressed:
L84AB:  CPX #$00                ;Is selector at top of window?
L84AD:  BEQ LoadWndInputLoop    ;If so, branch to ignore input.
L84AF:  DEX                     ;Move selector up 1 position.
L84B0:  JMP LoadWndSelectPos    ;($8487)Set new selector sprite position.

_LoadWndReset:
L84B3:  JMP LoadWndReset        ;($8485)Set selector sprite back to top of load window.

ChkLoadSG1:
L84B6:  CPX #$00                ;Has save game 1 been selected?
L84B8:  BNE ChkLoadSG2          ;If not, branch.

L84BA:  LDA ValidGamesFlags     ;Is save game 1 valid?
L84BC:  AND #$01                ;If not, branch.
L84BE:  BEQ LoadWndReset        ;($8485)Set selector sprite back to top of load window.

L84C0:  LDA #<SG1Base           ;
L84C2:  STA SGDatPtrLB          ;Load save game pointer with base address of save game 1 data.
L84C4:  LDA #>SG1Base           ;
L84C6:  STA SGDatPtrUB          ;

L84C8:  LDA #$00                ;Indicate save game 1 was selected and exit.
L84CA:  RTS                     ;

ChkLoadSG2:
L84CB:  CPX #$01                ;Has save game 2 been selected?
L84CD:  BNE ChkLoadSG3          ;If not, branch.

L84CF:  LDA ValidGamesFlags     ;
L84D1:  AND #$02                ;Is save game 2 valid?
L84D3:  BEQ _LoadWndReset       ;If not, branch.

L84D5:  LDA #<SG2Base           ;
L84D7:  STA SGDatPtrLB          ;Load save game pointer with base address of save game 2 data.
L84D9:  LDA #>SG2Base           ;
L84DB:  STA SGDatPtrUB          ;

L84DD:  LDA #$01                ;Indicate save game 2 was selected and exit.
L84DF:  RTS                     ;

ChkLoadSG3:
L84E0:  CPX #$02                ;Has save game 3 been selected?
L84E2:  BNE ChkLoadRegister     ;If not, branch.

L84E4:  LDA ValidGamesFlags     ;
L84E6:  AND #$04                ;Is save game 3 valid?
L84E8:  BEQ _LoadWndReset       ;If not, branch.

L84EA:  LDA #<SG3Base           ;
L84EC:  STA SGDatPtrLB          ;Load save game pointer with base address of save game 3 data.
L84EE:  LDA #>SG3Base           ;
L84F0:  STA SGDatPtrUB          ;

L84F2:  LDA #$02                ;Indicate save game 3 was selected and exit.
L84F4:  RTS                     ;

ChkLoadRegister:
L84F5:  CPX #$03                ;Has register new game been selected?
L84F7:  BNE ChkLoadErase        ;If not, branch.

L84F9:  LDA ValidGamesFlags     ;
L84FB:  CMP #$07                ;Are all the save game slots full?
L84FD:  BEQ _LoadWndReset       ;If so, branch to ignore selection.

L84FF:  LDY #$00                ;Zero out index.

L8501:* LDA SpriteBuffer,Y      ;
L8504:  STA SpriteBuffer+$F4,Y  ;
L8507:  INY                     ;Store the state of the selector sprite in sprite 61.
L8508:  CPY #$04                ;
L850A:  BNE -                   ;

L850C:  LDX #$00                ;Zero out index(save game 1).

SelectRegLoop:
L850E:  LDA LoadWndYPosTbl,X    ;Set the selector sprite at the given menu item.
L8511:  STA SpriteBuffer        ;

L8514:  LDA #$50                ;Set X position of new selector sprite at X=80.
L8516:  STA SpriteBuffer+3      ;

RegInputLoop:
L8519:  JSR GetInputPress       ;($98EE)Get input button press and account for retrigger.
L851C:  LDA Pad1Input           ;

L851E:  CMP #BTN_A              ;Was the A button pressed?
L8520:  BEQ ChkRegSlot          ;If so, branch to process button press.

L8522:  CMP #BTN_B              ;Was the B button pressed?
L8524:  BEQ RegBackout          ;If so, branch to process button press.

L8526:  CMP #BTN_UP             ;Was the up button pressed?
L8528:  BEQ RegUp               ;If so, branch to process button press.

L852A:  CMP #BTN_DOWN           ;Was the down button pressed?
L852C:  BNE RegInputLoop        ;If not, branch to ignore the input.

L852E:  CPX #$02                ;Is selector sprite on save game 3?
L8530:  BEQ SelectRegLoop       ;If so, branch to ignore the input.

L8532:  INX                     ;Move selector sprite down 1 menu item.
L8533:  JMP SelectRegLoop       ;

RegUp:
L8536:  CPX #$00                ;Is selector sprite on save game 1?
L8538:  BEQ SelectRegLoop       ;If so, branch to ignore the input.

L853A:  DEX                     ;Move selector sprite up 1 menu item.
L853B:  JMP SelectRegLoop       ;($850E)Wait for next input.

ChkRegSlot:
L853E:  LDA #>SG1Base           ;Prepare to point to save game 1 data.
L8540:  LDY #<SG1Base           ;

L8542:  CPX #$00                ;Was save game slot 1 selected?
L8544:  BEQ SetRegisterPtr      ;If so, branch to continue.

L8546:  LDA #>SG2Base           ;Prepare to point to save game 2 data.
L8548:  LDY #<SG2Base           ;

L854A:  CPX #$01                ;Was save game slot 2 selected?
L854C:  BEQ SetRegisterPtr      ;If so, branch to continue.

L854E:  LDA #>SG3Base           ;Save game slot 3 must have been selected.
L8550:  LDY #<SG3Base           ;Prepare to point to save game 3 data.

SetRegisterPtr:
L8552:  STY SGDatPtrLB          ;Set the save game data pointer to the selected save game slot.
L8554:  STA SGDatPtrUB          ;

L8556:  LDY #$00                ;Zero out the index.

L8558:  LDA (SGDatPtr),Y        ;Is the first save game valid byte invalid?
L855A:  CMP #SG_VALID1          ;If so, branch to continue the register process.
L855C:  BNE SGRegisterValid     ;

L855E:  INY                     ;Move to next save game valid byte.

L855F:  LDA (SGDatPtr),Y        ;Is the second save game valid byte invalid?
L8561:  CMP #SG_VALID2          ;If so, branch to continue the register process.
L8563:  BNE SGRegisterValid     ;

L8565:  JMP SelectRegLoop       ;($850E)Wait for next input.

SGRegisterValid:
L8568:  LDA #$03                ;Indicate the selected save game slot is verified empty
L856A:  RTS                     ;and ready to be registered.

RegBackout:
L856B:  LDA #SPRT_HIDE          ;Hide the selector sprite and back up 1 menu.
L856D:  STA SpriteBuffer+$F4    ;
L8570:* JMP LoadWndReset        ;($8485)Set selector sprite back to top of load window.

ChkLoadErase:
L8573:  CPX #$04                ;Has erase game been selected?
L8575:  BNE -                   ;If not, branch to ignore selection.

L8577:  LDA ValidGamesFlags     ;Are there valid games present on the cartridge?
L8579:  BEQ -                   ;If not, branch to ignore selection.

L857B:  LDY #$00                ;Zero out index.

L857D:* LDA SpriteBuffer,Y      ;
L8580:  STA SpriteBuffer+$F4,Y  ;
L8583:  INY                     ;Store the state of the selector sprite in sprite 61.
L8584:  CPY #$04                ;
L8586:  BNE -                   ;

L8588:  LDX #$00                ;Zero out index(save game 1).

SelectEraseLoop:
L858A:  LDA LoadWndYPosTbl,X    ;Set the selector sprite at the given menu item.
L858D:  STA SpriteBuffer        ;

L8590:  LDA #$50                ;Set X position of new selector sprite at X=80.
L8592:  STA SpriteBuffer+3      ;

EraseInputLoop:
L8595:  JSR GetInputPress       ;($98EE)Get input button press and account for retrigger.
L8598:  LDA Pad1Input           ;

L859A:  CMP #BTN_A              ;Was the A button pressed?
L859C:  BEQ ChkEraseSG1         ;If so, branch to process button press.

L859E:  CMP #BTN_B              ;Was the B button pressed?
L85A0:  BEQ EraseBackout        ;If so, branch to process button press.

L85A2:  CMP #BTN_UP             ;Was the up button pressed?
L85A4:  BEQ EraseUp             ;If so, branch to process button press.

L85A6:  CMP #BTN_DOWN           ;Was the down button pressed?
L85A8:  BNE EraseInputLoop      ;If not, branch to ignore the input.

L85AA:  CPX #$02                ;Is selector sprite on save game 3?
L85AC:  BEQ EraseInputLoop      ;If so, branch to ignore the input.

L85AE:  INX                     ;Move selector sprite down 1 menu item.
L85AF:  JMP SelectEraseLoop     ;($858A)Wait for next input.

EraseUp:
L85B2:  CPX #$00                ;Is the selector sprite on save game 1?
L85B4:  BEQ EraseInputLoop      ;If so, branch to ignore input.

L85B6:  DEX                     ;Move selector sprite up 1 menu item.
L85B7:  JMP SelectEraseLoop     ;($858A)Wait for next input.

EraseBackout:
L85BA:  LDA #SPRT_HIDE          ;Hide the selector sprite and back up 1 menu.
L85BC:  STA SpriteBuffer+$F4    ;
L85BF:  JMP LoadWndReset        ;($8485)Set selector sprite back to top of load window.

ChkEraseSG1:
L85C2:  CPX #$00                ;Was save game 1 selected?
L85C4:  BNE ChkEraseSG2         ;If not, branch to check save game 2.

L85C6:  LDA #<SG1Base           ;
L85C8:  STA SGDatPtrLB          ;Load save game pointer with base address of save game 1 data.
L85CA:  LDA #>SG1Base           ;
L85CC:  STA SGDatPtrUB          ;

L85CE:  JMP ChkEraseSGValid     ;($85E8)Check to see is save game slot has valid data.

ChkEraseSG2:
L85D1:  CPX #$01                ;Was save game 2 selected?
L85D3:  BNE ChkEraseSG3         ;If not, branch to check save game 3.

L85D5:  LDA #<SG2Base           ;
L85D7:  STA SGDatPtrLB          ;Load save game pointer with base address of save game 2 data.
L85D9:  LDA #>SG2Base           ;
L85DB:  STA SGDatPtrUB          ;

L85DD:  JMP ChkEraseSGValid     ;($85E8)Check to see is save game slot has valid data.

ChkEraseSG3:
L85E0:  LDA #<SG3Base           ;
L85E2:  STA SGDatPtrLB          ;Load save game pointer with base address of save game 3 data.
L85E4:  LDA #>SG3Base           ;
L85E6:  STA SGDatPtrUB          ;

ChkEraseSGValid:
L85E8:  LDY #$00                ;Zero out index.

L85EA:  LDA (SGDatPtr),Y        ;
L85EC:  CMP #SG_VALID1          ;Is the first validation bit for this save game correct?
L85EE:  BNE SelectEraseLoop     ;If not, branch to stop erasing this save game data.

L85F0:  INY                     ;Move to second valid indicator byte.

L85F1:  LDA (SGDatPtr),Y        ;
L85F3:  CMP #SG_VALID2          ;Is the second validation bit for this save game correct?
L85F5:  BNE SelectEraseLoop     ;If not, branch to stop erasing this save game data.

L85F7:  TXA                     ;Save the selected saved game on the stack.
L85F8:  PHA                     ;

L85F9:  LDA #$0C                ;
L85FB:  STA TXTXPos             ;Text will be located at tile coords X,Y=12,21.
L85FD:  LDA #$15                ;
L85FF:  STA TXTYPos             ;

L8601:  LDA #$0B                ;
L8603:  STA TXTClrCols          ;Clear 12 columns and 2 rows for the text string.
L8605:  LDA #$02                ;
L8607:  STA TXTClrRows          ;

L8609:  LDA #$1F                ;Ask player if they really want to erase this saved game.
L860B:  STA TextIndex           ;
L860D:  JSR ShowTextString      ;($995C)Show a text string on the screen.

L8610:  LDY #$00                ;Zero out index.

L8612:* LDA SpriteBuffer,Y      ;
L8615:  STA SpriteBuffer+$F4,Y  ;
L8618:  INY                     ;Store the state of the selector sprite in sprite 61.
L8619:  CPY #$04                ;
L861B:  BNE -                   ;

L861D:  LDX #$01                ;NO selected by default.

SelectErVerifyLoop:
L861F:  LDA EraseXPosTbl,X      ;Set the position of the selector sprite.
L8622:  STA SpriteBuffer+3      ;

L8625:  LDA #$B8                ;Set sprite Y position to Y=184.
L8627:  STA SpriteBuffer        ;

ErVerifyInputLoop:
L862A:  JSR GetInputPress       ;($98EE)Get input button press and account for retrigger.
L862D:  LDA Pad1Input           ;

L862F:  CMP #BTN_A              ;Was A button pressed?
L8631:  BEQ ChkDeleteYes        ;If so, branch to process input.

L8633:  CMP #BTN_B              ;Was B button pressed?
L8635:  BEQ ChkDeleteYes        ;If so, branch to process input.

L8637:  CMP #BTN_LEFT           ;Was left button pressed?
L8639:  BEQ MoveDeleteToYes     ;If so, branch to process input.

L863B:  CMP #BTN_RIGHT          ;Was right button pressed?
L863D:  BNE ErVerifyInputLoop   ;If not, branch to ignore input.

L863F:  CPX #$01                ;is No already selected?
L8641:  BEQ SelectErVerifyLoop  ; If so, branch to ignore input.

L8643:  INX                     ;Move selector sprite to NO selection.
L8644:  JMP SelectErVerifyLoop  ;($861F)Wait for next input.

MoveDeleteToYes:
L8647:  CPX #$00                ;is YES already selected? If so, branch.
L8649:  BEQ SelectErVerifyLoop  ;($861F)Wait for next input.

L864B:  DEX                     ;Move selector sprite to the YES selection.
L864C:  JMP SelectErVerifyLoop  ;($861F)Wait for next input.

ChkDeleteYes:
L864F:  CPX #$00                ;Is YES selected?
L8651:  BEQ DoEraseSG           ;If so, branch to erase the selected saved game.

L8653:  PLA                     ;Restore the selected saved game from the stack.
L8654:  TAX                     ;
L8655:  JMP DoLoadWindow        ;($837F)Show the load game/new game menu.

;Erase the selected saved game.
DoEraseSG:
L8658:  PLA                     ;Restore the selected saved game from the stack.
L8659:  TAX                     ;

L865A:  LDA #$00                ;Prepare to zero out the save game data at selected slot.
L865C:  LDY #$00                ;

L865E:  STA (SGDatPtr),Y        ;Erase the first valid data indicator byte.

L8660:  LDY #$10                ;Prepare to deselect characters.
L8662:  LDA #$FF                ;

L8664:  STA (SGDatPtr),Y        ;
L8666:  INY                     ;
L8667:  STA (SGDatPtr),Y        ;
L8669:  INY                     ;Make sure no characters are selected for adventuring.
L866A:  STA (SGDatPtr),Y        ;
L866C:  INY                     ;
L866D:  STA (SGDatPtr),Y        ;

L866F:  JMP DoLoadWindow        ;($837F)Show the load game/new game menu.

;----------------------------------------------------------------------------------------------------

;The following table contains the Y position of the selection sprite on the load saved game
;window. The first 3 entries are for the 3 saved games and the last 2 entries are for
;REGISTER and ERASE, respectively.

LoadWndYPosTbl:
L8672:  .byte $60, $78, $90, $A8, $B8

;----------------------------------------------------------------------------------------------------

;The following table contains the X position of the selection sprite on the erase Yes/No
;selection window.

EraseXPosTbl:
L8677:  .byte $58, $78

;----------------------------------------------------------------------------------------------------

NameSaveGame:
L8679:  JSR InitPPU             ;($990C)Initialize the PPU.

L867C:  LDA #$06                ;
L867E:  STA TXTXPos             ;Text will be located at tile coords X,Y=6,6.
L8680:  LDA #$06                ;
L8682:  STA TXTYPos             ;

L8684:  LDA #$17                ;
L8686:  STA TXTClrCols          ;Clear 23 columns and 1 row for the text string.
L8688:  LDA #$01                ;
L868A:  STA TXTClrRows          ;

L868C:  LDA #$02                ;REGISTER YOUR NAME.
L868E:  STA TextIndex           ;
L8690:  JSR ShowTextString      ;($995C)Show a text string on the screen.

L8693:  JSR EnterName           ;($871D)Show screen for entring name info.

L8696:  LDY #SG_VALID1_IDX      ;
L8698:  LDA #SG_VALID1          ;Add first valid save game byte to save game file.
L869A:  STA (SGDatPtr),Y        ;

L869C:  INY                     ;
L869D:  LDA #SG_VALID2          ;Add second valid save game byte to save game file.
L869F:  STA (SGDatPtr),Y        ;

L86A1:  LDY #SG_NAME            ;Set index for third byte of save game data.

SaveSGName:
L86A3:  LDA TextBuffer-2,Y      ;Has the end of the name string been reached?
L86A6:  CMP #SG_NONE            ;
L86A8:  BEQ SaveEmptyChars      ;If so, branch.

L86AA:  STA (SGDatPtr),Y        ;Save another name character in the save game file.
L86AC:  INY                     ;
L86AD:  CPY #$07                ;Has all 5 characters for the save game name been saved?
L86AF:  BNE SaveSGName          ;If not, branch to save another character.

L86B1:  JMP SGSetBlankData      ;($86BD)Set empty bytes in saved game slot.

SaveEmptyChars:
L86B4:  LDA #$00                ;Prepare to store empty characters.
L86B6:  STA (SGDatPtr),Y        ;
L86B8:  INY                     ;Loop until all 5 characters are saved.
L86B9:  CPY #$07                ;
L86BB:  BNE SaveEmptyChars      ;

SGSetBlankData:
L86BD:  LDY #$07                ;Move to next open index in the save game memory.

L86BF:* LDA #$00                ;
L86C1:  STA (SGDatPtr),Y        ;Zero out the next 249 bytes.
L86C3:  INY                     ;
L86C4:  BNE -                   ;

L86C6:  LDY #SG_CHR1_INDEX      ;
L86C8:  LDA #SG_NONE            ;
L86CA:  STA (SGDatPtr),Y        ;
L86CC:  INY                     ;Bytes 16-19 in the save game file are the indexes 
L86CD:  STA (SGDatPtr),Y        ;into the character pool for the 4 characters currently
L86CF:  INY                     ;selected in the active party. Setting these values to
L86D0:  STA (SGDatPtr),Y        ;$FF indicates no characters are currently selected.
L86D2:  INY                     ;
L86D3:  STA (SGDatPtr),Y        ;

L86D5:  LDY #SG_BOAT_X          ;
L86D7:  LDA #SG_NONE            ;These slots save the boat X,Y position. Setting them to
L86D9:  STA (SGDatPtr),Y        ;$FF indicates there is no boat.
L86DB:  INY                     ;
L86DC:  STA (SGDatPtr),Y        ;

L86DE:  LDY #SG_PARTY_X         ;
L86E0:  LDA #$2A                ;Set the initial X position of the party on the world map.
L86E2:  STA (SGDatPtr),Y        ;

L86E4:  LDA #$16                ;
L86E6:  INY                     ;Set the initial Y position of the party on the world map.
L86E7:  STA (SGDatPtr),Y        ;

L86E9:  LDY #SG_MAP_PROPS       ;
L86EB:  LDA #$0C                ;Set map properties of the current map(Overworld map).
L86ED:  STA (SGDatPtr),Y        ;

L86EF:  INY                     ;
L86F0:  LDA #MAP_OVERWORLD      ;Party starts on the overworld map.
L86F2:  STA (SGDatPtr),Y        ;

L86F4:  LDA SGDatPtrLB          ;
L86F6:  STA GenPtr29LB          ;Get a pointer to the base address of the current save game.
L86F8:  STA SGCharPtrLB         ;

L86FA:  LDA SGDatPtrUB          ;Move ahead 256 bytes in the save game. This is the start
L86FC:  STA GenPtr29UB          ;of the character data for the save game.
L86FE:  INC GenPtr29UB          ;

L8700:  LDA GenPtr29UB          ;Make a copy of character data pointer.
L8702:  STA SGCharPtrUB         ;

L8704:  LDY #$00                ;Prepare to designate all 20 character slots as empty.
L8706:  LDX #$14                ;

L8708:* LDA #$FF                ;Set first byte of current character data to $FF
L870A:  STA (GenPtr29),Y        ;to indicate a blank character slot.

L870C:  CLC                     ;
L870D:  LDA GenPtr29LB          ;
L870F:  ADC #$40                ;
L8711:  STA GenPtr29LB          ;Jump ahead 64 bytes to the next character data slot.
L8713:  LDA GenPtr29UB          ;
L8715:  ADC #$00                ;
L8717:  STA GenPtr29UB          ;

L8719:  DEX                     ;Have all 20 character slots been emptied out?
L871A:  BNE -                   ;
L871C:  RTS                     ;If not, branch to clear another slot.

;----------------------------------------------------------------------------------------------------

EnterName:
L871D:  LDA #$08                ;
L871F:  STA TXTXPos             ;Text will be located at tile coords X,Y=8,12.
L8721:  LDA #$0C                ;
L8723:  STA TXTYPos             ;

L8725:  LDA #$14                ;
L8727:  STA TXTClrCols          ;Clear 20 columns and 6 rows for the text string.
L8729:  LDA #$06                ;
L872B:  STA TXTClrRows          ;

L872D:  LDA #$03                ;Letters and numbers for name entries.
L872F:  STA TextIndex           ;
L8731:  JSR ShowTextString      ;($995C)Show a text string on the screen.

L8734:  LDA #$08                ;
L8736:  STA TXTXPos             ;Text will be located at tile coords X,Y=8,10.
L8738:  LDA #$0A                ;
L873A:  STA TXTYPos             ;

L873C:  LDA #$05                ;
L873E:  STA TXTClrCols          ;Clear 5 columns and 1 row for the text string.
L8740:  LDA #$01                ;
L8742:  STA TXTClrRows          ;

L8744:  LDA #$17                ;----- 5 dashes for the 5 name characters.
L8746:  STA TextIndex           ;
L8748:  JSR ShowTextString      ;($995C)Show a text string on the screen.

L874B:  LDX #$00                ;
L874D:  LDY #$00                ;Zero everything out for the next segment of code.
L874F:  LDA #$00                ;
L8751:  STA NameLength          ;

UpdateSelectorLoop:
L8753:  JSR SetSelectorXY       ;($8872)Set XY position of the selector sprite.

L8756:  JSR GetInputPress       ;($98EE)Get input button press and account for retrigger.
L8759:  LDA Pad1Input           ;

L875B:  CMP #BTN_RIGHT          ;Was the right button pressed?
L875D:  BNE ChkBtnLt1           ;If not, branch to check if other buttons pressed.

L875F:  CPX #$27                ;Are we at the last entry in the character table?
L8761:  BNE +                   ;If not, branch to increment to next index.

L8763:  JMP UpdateSelectorLoop  ;($8753)Update selector sprite position.

L8766:* INX                     ;Increment to the next character index.
L8767:  JMP UpdateSelectorLoop  ;($8753)Update selector sprite position.

ChkBtnLt1:
L876A:  CMP #BTN_LEFT           ;Was the left button pressed?
L876C:  BNE ChkBtnUp1           ;If not, branch to check if other buttons pressed.

L876E:  CPX #$00                ;Has the minimum index been reached?
L8770:  BNE +                   ;If not, branch to decrement the index.

L8772:  JMP UpdateSelectorLoop  ;($8753)Update selector sprite position.

L8775:* DEX                     ;Decrement to previous character.
L8776:  JMP UpdateSelectorLoop  ;($8753)Update selector sprite position.

ChkBtnUp1:
L8779:  CMP #BTN_UP             ;Was the up button pressed?
L877B:  BNE ChkBtnDn1           ;If not, branch to check if other buttons pressed.

L877D:  LDA NextIndexUpTbl,X    ;Load the next index to jump to from the table below.
L8780:  TAX                     ;
L8781:  JMP UpdateSelectorLoop  ;($8753)Update selector sprite position.

ChkBtnDn1:
L8784:  CMP #BTN_DOWN           ;Was the down button pressed?
L8786:  BNE ChkBtnA1            ;If not, branch to check if other buttons pressed.

L8788:  LDA NextIndexDnTbl,X    ;Load the next index to jump to from the table below.
L878B:  TAX                     ;
L878C:  JMP UpdateSelectorLoop  ;($8753)Update selector sprite position.

ChkBtnA1:
L878F:  CMP #BTN_A              ;Was the A button pressed?
L8791:  BEQ +                   ;If so, branch to process button press.

L8793:  JMP UpdateSelectorLoop  ;($8753)Update selector sprite position.

L8796:* STX NameCharIndex       ;Store the index to the selected character.
L8798:  STY NameSelRow          ;

L879A:  CPX #$26                ;Check if END or a character was selected.
L879C:  BCC AddLetter           ;Branch if character selected.

L879E:  BEQ BackSpace            ;Branch if back space selected.

L87A0:  RTS                      ;END was selected. Return.

BackSpace:
L87A1:  LDA NameLength          ;Are there any characters in the name yet?
L87A3:  BNE +                   ;If so, branch to delete the last character.

L87A5:  JMP UpdateSelectorLoop  ;($8753)Update selector sprite position.

L87A8:* DEC NameLength          ;Decrement name length by 1.

L87AA:  LDY NameLength          ;
L87AC:  LDA #TXT_END            ;Update the end of string marker for the new name length.
L87AE:  STA TextBuffer,Y        ;

L87B1:  DEC NameLength          ;Decrement again. This will be undone later.
L87B3:  JMP UpdateName          ;($87CC)Update current name on the screen.

AddLetter:
L87B6:  LDA NameLength          ;Has the max characters for the name been reached(5)?
L87B8:  CMP #$05                ;
L87BA:  BNE +                   ;If not, branch to add character to name.

L87BC:  JMP UpdateSelectorLoop  ;($8753)Update selector sprite position.

L87BF:* LDA NameCharsTbl,X      ;
L87C2:  LDY NameLength          ;Get selected character and add it to the text buffer.
L87C4:  STA TextBuffer,Y        ;

L87C7:  LDA #TXT_END            ;Update the end of string marker for the new name length.
L87C9:  STA TextBuffer+1,Y      ;

UpdateName:
L87CC:  LDA #$08                ;
L87CE:  STA TXTXPos             ;Text will be located at tile coords X,Y=8,9.
L87D0:  LDA #$09                ;
L87D2:  STA TXTYPos             ;

L87D4:  LDA #$0A                ;
L87D6:  STA TXTClrCols          ;Clear 10 columns and 1 row for the text string.
L87D8:  LDA #$01                ;
L87DA:  STA TXTClrRows          ;

L87DC:  LDA #TXT_DBL_SPACE      ;Indicate text buffer already has the data in it.
L87DE:  STA TextIndex           ;

L87E0:  LDA NameCharIndex       ;
L87E2:  PHA                     ;
L87E3:  LDA NameSelRow          ;Save name generation variables on the stack.
L87E5:  PHA                     ;
L87E6:  LDA NameLength          ;
L87E8:  PHA                     ;

L87E9:  JSR ShowTextString      ;($995C)Show a text string on the screen.

L87EC:  PLA                     ;
L87ED:  STA NameLength          ;
L87EF:  PLA                     ;
L87F0:  STA NameSelRow          ;Restore name generation variables from the stack.
L87F2:  TAY                     ;
L87F3:  PLA                     ;
L87F4:  STA NameCharIndex       ;
L87F6:  TAX                     ;

L87F7:  INC NameLength          ;Increment to next open spot in name string.
L87F9:  JMP UpdateSelectorLoop  ;($8753)Update selector sprite position.

;----------------------------------------------------------------------------------------------------

;These are the valid character that can be used in a name.

NameCharsTbl:
;              A    B    C    D    E    F    G    H    I    J
L87FC:  .byte $8A, $8B, $8C, $8D, $8E, $8F, $90, $91, $92, $93
;              K    L    M    N    O    P    Q    R    S    T
L8806:  .byte $94, $95, $96, $97, $98, $99, $9A, $9B, $9C, $9D
;              U    V    W    X    Y    Z    ,    .
L8810:  .byte $9E, $9F, $A0, $A1, $A2, $A3, $42, $43
;              0    1    2    3    4    5    6    7    8    9
L8818:  .byte $38, $39, $3A, $3B, $3C, $3D, $3E, $3F, $40, $41

;----------------------------------------------------------------------------------------------------

;The following table is used to figure out what the next index value to load into X after the
;down button has been pressed. For example, if the selector is in the 4th row and the
;down button is pressed, the selector will always move to the backspace selection (index $26).

NextIndexDnTbl:
L8822:  .byte $0A, $0B, $0C, $0D, $0E, $0F, $10, $11, $12, $13
L882C:  .byte $14, $15, $16, $17, $18, $19, $1A, $1B, $24, $25
L8836:  .byte $1C, $1D, $1E, $1F, $20, $21, $22, $23
L883E:  .byte $26, $26, $26, $26, $26, $26, $26, $26, $26, $26
L8848:  .byte                               $26,      $27

;----------------------------------------------------------------------------------------------------

;The following table is similar to the above table but is indicates what the next index will
;be if the player presses the up button.

NextIndexUpTbl:
L884A:  .byte $00, $01, $02, $03, $04, $05, $06, $07, $08, $09
L8854:  .byte $00, $01, $02, $03, $04, $05, $06, $07, $08, $09
L885E:  .byte $0A, $0B, $0C, $0D, $0E, $0F, $10, $11
L8866:  .byte $14, $15, $16, $17, $18, $19, $1A, $1B, $12, $13
L8870:  .byte                               $22,      $24                                          

;----------------------------------------------------------------------------------------------------

SetSelectorXY:
L8872:  LDA SelectorDatTbl,X    ;Get the X position of the selector.
L8875:  AND #$0F                ;

L8877:  ASL                     ;
L8878:  ASL                     ;*16. Characters are spaced 16 pixels apart.
L8879:  ASL                     ;
L887A:  ASL                     ;

L887B:  CLC                     ;Offset selector by 56 pixels to the right.
L887C:  ADC #$38                ;

L887E:  STA SpriteBuffer+3      ;Save final X position of the selector sprite.

L8881:  LDA SelectorDatTbl,X    ;Get the Y position of the selector.
L8884:  AND #$F0                ;

L8886:  CLC                     ;Offset selector by 96 pixels down.
L8887:  ADC #$60                ;

L8889:  STA SpriteBuffer        ;Save final Y position of the selector sprite.

L888C:  LDA SelectorDatTbl,X   ;
L888F:  AND #$F0               ;
L8891:  LSR                    ;
L8892:  LSR                    ;Get the row number where the selector is and put it in Y
L8893:  LSR                    ;
L8894:  LSR                    ;
L8895:  TAY                    ;
L8896:  RTS                    ;

;----------------------------------------------------------------------------------------------------

;The following data table represents the valid X and Y positions of the selector  sprite when
;inputting the name of a new save game slot. The data is laid aout the way it appears on the
;screen in the game.

SelectorDatTbl:
L8897:  .byte $00, $01, $02, $03, $04, $05, $06, $07, $08, $09
L88A1:  .byte $10, $11, $12, $13, $14, $15, $16, $17, $18, $19
L88AB:  .byte $20, $21, $22, $23, $24, $25, $26, $27
L88B3:  .byte $30, $31, $32, $33, $34, $35, $36, $37, $38, $39
L88BD:  .byte                               $46,      $48

;----------------------------------------------------------------------------------------------------

CreateContinue:
L88BF:  JSR DoCreateCont        ;(88C8)Display and handle create/continue window.

L88C2:  PHA                     ;Save A on the stack.

L88C3:  JSR SetDelayConst       ;($8962)Set a delay constant of 30 frames.

L88C6:  PLA                     ;Restore A from the stack and return.
L88C7:  RTS                     ;

;----------------------------------------------------------------------------------------------------

DoCreateCont:
L88C8:  JSR InitPPU             ;($990C)Initialize the PPU.
L88CB:  JSR LoadClassSprites    ;($9AEB)Load the various character class sprites on the screen.

L88CE:  LDA #$08                ;
L88D0:  STA WndXPos             ;Window will be located at tile coords X,Y=8,14
L88D2:  LDA #$0E                ;
L88D4:  STA WndYPos             ;

L88D6:  LDA #$10                ;
L88D8:  STA WndWidth            ;Window will be 16 tiles wide and 6 tiles tall.
L88DA:  LDA #$06                ;
L88DC:  STA WndHeight           ;

L88DE:  JSR DrawWndBrdr         ;($97A9)Draw window border.

L88E1:  LDA #$0A                ;
L88E3:  STA TXTXPos             ;Text will be located at tile coords X,Y=10,16.
L88E5:  LDA #$10                ;
L88E7:  STA TXTYPos             ;

L88E9:  LDA #$0D                ;
L88EB:  STA TXTClrCols          ;Clear 13 columns and 2 rows for the text string.
L88ED:  LDA #$02                ;
L88EF:  STA TXTClrRows          ;

L88F1:  LDA #$04                ;CREATE CONTINUE text.
L88F3:  STA TextIndex           ;
L88F5:  JSR ShowTextString      ;($995C)Show a text string on the screen.

L88F8:  LDA #$80                ;
L88FA:  STA SpriteBuffer        ;Set selector sprite to pixel coordinates X,Y=72,128
L88FD:  LDA #$48                ;
L88FF:  STA SpriteBuffer+3      ;

L8902:  LDY #$01                ;Prepare to get the next button press and handle it.
L8904:  LDX #$00                ;

CreateContInptLoop:
L8906:  JSR GetInputPress       ;($98EE)Get input button press and account for retrigger.
L8909:  LDA Pad1Input           ;

L890B:  CMP #BTN_UP             ;Was the up button pressed?
L890D:  BEQ CreateContUpBtn     ;If so, branch to handle button press.

L890F:  CMP #BTN_DOWN           ;Was the down button pressed?
L8911:  BEQ CreateContSGDnBtn   ;If so, branch to handle button press.

L8913:  CMP #BTN_A              ;Was the A button pressed?
L8915:  BNE CreateContInptLoop  ;If not, branch to get the next input.

CreateContABtn:
L8917:  TXA                     ;Was CONTINUE selected?
L8918:  BNE +                   ;If so, branch.

L891A:  RTS                     ;Exit indicating CREATE was selected.

L891B:* PHA                     ;Store current values of A and Y
L891C:  STY GenByte18           ;

L891E:  LDX #$05                ;Prepare to check if a valid party has been formed.
L8920:  LDY #$10                ;

L8922:* LDA (SGDatPtr),Y        ;
L8924:  CMP #SG_NONE            ;
L8926:  BEQ PartyNotValid       ;Make sure all 4 character slots have been chosen.
L8928:  INY                     ;If not, do not allow the player to journey onward.
L8929:  DEX                     ;If so, return to start the game engine.
L892A:  BNE -                   ;

L892C:  PLA                     ;Restore A from stack(should be 1).
L892D:  RTS                     ;Return indicating CONTINUE was selected.

PartyNotValid:
L892E:  LDY GenByte18           ;Restore the values of Y and A.
L8930:  PLA                     ;

L8931:  LDX #$00                ;Force the selector sprite back to CREATE.
L8933:  JMP UpdateSelectorPos   ;($8943)Update Y position of selector sprite.

CreateContUpBtn:
L8936:  CPX #$00                ;Is the selector sprite already at CREATE?
L8938:  BEQ CreateContInptLoop  ;If so, branch to ignore the input.

L893A:  DEX                     ;Move the selector sprite down to CONTINUE.
L893B:  JMP UpdateSelectorPos   ;($8943)Update Y position of selector sprite.

CreateContSGDnBtn:
L893E:  CPX #$01                ;Is the selector already on CONTINUE?
L8940:  BEQ CreateContInptLoop  ;If so, branch to ignore input.

L8942:  INX                     ;Move selector sprite to COMTINUE.

UpdateSelectorPos:
L8943:  LDA SelectYPosTbl,X     ;
L8946:  STA SpriteBuffer        ;Update the Y position of the selector sprite.
L8949:  LDA HiddenXPosTbl,Y     ;
L894C:  STA SpriteBuffer+$C7    ;Update the X position of a sprite hidden off screen.
L894F:  JMP CreateContInptLoop  ;

;It does not appear the code below this point can be reached.
L8952:  CPY #$00                ;Is Y=0(Should never be true)?
L8954:  BEQ CreateContInptLoop  ;If so, branch to get next input.

L8956:  DEY                     ;Set Y=0.
L8957:  JMP UpdateSelectorPos   ;($8943)Update Y position of selector sprite.

L895A:  CPY #$01                ;Is Y=1(Should always be true)?
L895C:  BEQ CreateContInptLoop  ;If so, branch to update selector sprite position.

L895E:  INY                     ;Set Y=1.
L895F:  JMP UpdateSelectorPos   ;($8943)Update Y position of selector sprite.

;----------------------------------------------------------------------------------------------------

SetDelayConst:
L8962:  LDA #$1E                ;Set a frame delay constant of 30 frames.
L8964:  STA DelayConst          ;Used throughout the game for various delays.
L8966:  RTS                     ;

;----------------------------------------------------------------------------------------------------

;The following table sets the Y position of the selector sprite for the create/continue menu.

SelectYPosTbl:
L8967:  .byte $80, $90

;The following table moves the X position of a sprite thats hidden off screen. No effect.

HiddenXPosTbl:
L8969:  .byte $78, $98

;----------------------------------------------------------------------------------------------------

DoCreate:
L896B:  JSR InitPPU             ;($990C)Initialize the PPU.
L896E:  JSR LoadClassSprites    ;($9AEB)Load the various character class sprites on the screen.

L8971:  LDA #$06                ;
L8973:  STA WndXPos             ;Window will be located at tile coords X,Y=6,12
L8975:  LDA #$0C                ;
L8977:  STA WndYPos             ;

L8979:  LDA #$14                ;
L897B:  STA WndWidth            ;Window will be 20 tiles wide and 12 tiles tall.
L897D:  LDA #$0C                ;
L897F:  STA WndHeight           ;

L8981:  JSR DrawWndBrdr         ;($97A9)Draw window border.

L8984:  LDA #$0A                ;
L8986:  STA TXTXPos             ;Text will be located at tile coords X,Y=10,14.
L8988:  LDA #$0E                ;
L898A:  STA TXTYPos             ;

L898C:  LDA #$0D                ;
L898E:  STA TXTClrCols          ;Clear 13 columns and 5 rows for the text string.
L8990:  LDA #$05                ;
L8992:  STA TXTClrRows          ;

L8994:  LDA #$05                ;EXAMINE CREATE DISCARD FORM PARTY PREVIOUS MENU.
L8996:  STA TextIndex           ;
L8998:  JSR ShowTextString      ;($995C)Show a text string on the screen.

L899B:  LDA #$70                ;
L899D:  STA SpriteBuffer        ;Set selector sprite to pixel coords X,Y=64,112.
L89A0:  LDA #$40                ;
L89A2:  STA SpriteBuffer+3      ;

L89A5:  LDX #$00                ;Set selector to default position EXAMINE.

CreateInputLoop:
L89A7:  JSR GetInputPress       ;($98EE)Get input button press and account for retrigger.
L89AA:  LDA Pad1Input           ;

L89AC:  CMP #BTN_UP             ;Was the up button pressed?
L89AE:  BEQ CreateBtnUp         ;If so, branch to handle input

L89B0:  CMP #BTN_DOWN           ;Was the down button pressed?
L89B2:  BEQ CreateBtnDn         ;If so, branch to handle input.

L89B4:  CMP #BTN_A              ;Was the A button pressed?
L89B6:  BNE CreateInputLoop     ;If not, branch to ignore all other inputs.

L89B8:  TXA                     ;Indicate what selection was made and return.
L89B9:  RTS                     ;

CreateBtnUp:
L89BA:  CPX #$00                ;Is the selector already at the top of the menu?
L89BC:  BEQ CreateInputLoop     ;If so, branch to ignore the input.

L89BE:  DEX                     ;Move the selector up 1 menu item.
L89BF:  JMP CreateUpdateY       ;

CreateBtnDn:
L89C2:  CPX #$04                ;Is the selector already at the bottom of the menu?
L89C4:  BEQ CreateInputLoop     ;If so, branch to ignore the input.

L89C6:  INX                     ;Move the selector down 1 menu item.

CreateUpdateY:
L89C7:  LDA CreateYPosTbl,X     ;Update the Y position of the selector sprite.
L89CA:  STA SpriteBuffer        ;
L89CD:  JMP CreateInputLoop     ;($89A7)Jump to get the next input.

;----------------------------------------------------------------------------------------------------

;The following table is used to set the Y position of the selector sprite on the create menu.

CreateYPosTbl:
L89D0:  .byte $70, $80, $90, $A0, $B0

;----------------------------------------------------------------------------------------------------

CreateChr:
L89D5:  JSR InitPPU             ;($990C)Initialize the PPU.
L89D8:  JSR LoadClassSprites    ;($9AEB)Load the various character class sprites on the screen.

L89DB:  LDA #$04                ;
L89DD:  STA WndXPos             ;Window will be located at tile coords X,Y=4,14
L89DF:  LDA #$0E                ;
L89E1:  STA WndYPos             ;

L89E3:  LDA #$18                ;
L89E5:  STA WndWidth            ;Window will be 24 tiles wide and 8 tiles tall.
L89E7:  LDA #$08                ;
L89E9:  STA WndHeight           ;

L89EB:  JSR DrawWndBrdr         ;($97A9)Draw window border.

L89EE:  LDA #$08                ;
L89F0:  STA TXTXPos             ;Text will be located at tile coords X,Y=8,20.
L89F2:  LDA #$10                ;
L89F4:  STA TXTYPos             ;

L89F6:  LDA #$13                ;
L89F8:  STA TXTClrCols          ;Clear 19 columns and 3 rows for the text string.
L89FA:  LDA #$03                ;
L89FC:  STA TXTClrRows          ;

L89FE:  LDA #$06                ;HAND-MADE READY-MADE PREVIOUS MENU text.
L8A00:  STA TextIndex           ;
L8A02:  JSR ShowTextString      ;($995C)Show a text string on the screen.

L8A05:  LDA #$80                ;
L8A07:  STA SpriteBuffer        ;Starting pixel position of selector sprite X,Y=48,128.
L8A0A:  LDA #$30                ;
L8A0C:  STA SpriteBuffer+3      ;

L8A0F:  LDX #$00                ;Index into CreateChrYPosTbl for Y position of selector sprite.

CreateCharLoop:
L8A11:  JSR GetInputPress       ;($98EE)Get input button press and account for retrigger.
L8A14:  LDA Pad1Input           ;

L8A16:  CMP #BTN_UP             ;Was up button pressed?
L8A18:  BEQ CreateChrMoveUp     ;If so, branch to process button press.

L8A1A:  CMP #BTN_DOWN           ;Was down button pressed?
L8A1C:  BEQ CreateChrMoveDn     ;If so, branch to process button press.

L8A1E:  CMP #BTN_A              ;Was A button pressed?
L8A20:  BNE CreateCharLoop      ;If not, branch to ignore the input.

L8A22:  LDY #$01                ;Prepare to look for 1 open spot for the new character.
L8A24:  TXA                     ;

L8A25:  CPX #$02                ;Did player select the previous menu?
L8A27:  BEQ ExitCreateChar      ;If so, branch to exit.

L8A29:  PHA                     ;Save the selection made on the stack.

L8A2A:  CPX #$00                ;Did player select to make a hand-made character?
L8A2C:  BEQ +                   ;If so, branch.

L8A2E:  LDY #$04                ;Prepare to look for 4 open spots for the new characters.
L8A30:* STY GenByte2E           ;

L8A32:  LDX #NUM_CHARACTERS     ;Prepare to look through all 20 character slots.

L8A34:  LDA SGDatPtrLB          ;
L8A36:  STA ChrDatPtrLB_        ;
L8A38:  LDA SGDatPtrUB          ;Get a pointer to the base of character data in the saved game.
L8A3A:  STA ChrDatPtrUB_        ;
L8A3C:  INC ChrDatPtrUB_        ;

L8A3E:  LDY #$00                ;Zero out the the index.

ChkNextSlot:
L8A40:  LDA (ChrDatPtr_),Y      ;Is the current character slot empty?
L8A42:  CMP #CHR_EMPTY_SLOT     ;
L8A44:  BEQ OpenSlotFound       ;If so, branch.

FindChrSlotsLoop:
L8A46:  CLC                     ;
L8A47:  LDA ChrDatPtrLB_        ;
L8A49:  ADC #$40                ;
L8A4B:  STA ChrDatPtrLB_        ;Move pointer to next character slot.
L8A4D:  LDA ChrDatPtrUB_        ;
L8A4F:  ADC #$00                ;
L8A51:  STA ChrDatPtrUB_        ;

L8A53:  DEX                     ;Update number of character slots remining to check.
L8A54:  BNE ChkNextSlot         ;More slots to check? Is fo, branch.

L8A56:  PLA                     ;Not enough empty character slots.
L8A57:  LDX #$02                ;Move selector sprite to previous menu selection.
L8A59:  JMP CreateChrUpdateY    ;($8A70)Update Y position of selector sprite.

OpenSlotFound:
L8A5C:  DEC GenByte2E           ;Have we found enough empty character slots?
L8A5E:  BNE FindChrSlotsLoop    ;If not, branch to find another one.

L8A60:  PLA                     ;Restore the menu item the player selected back into X.
L8A61:  TAX                     ;

ExitCreateChar:
L8A62:  RTS                     ;Exit create character screen.

CreateChrMoveUp:
L8A63:  CPX #$00                ;Is selector sprite at top menu selection?
L8A65:  BEQ CreateCharLoop      ;If not, move selector sprite up one position.
L8A67:  DEX                     ;
L8A68:  JMP CreateChrUpdateY    ;($8A70)Update Y position of selector sprite.

CreateChrMoveDn:
L8A6B:  CPX #$02                ;Is selector sprite at bottom menu selection?
L8A6D:  BEQ CreateCharLoop      ;
L8A6F:  INX                     ;If not, move selector down one position.

CreateChrUpdateY:
L8A70:  LDA CreateChrYPosTbl,X  ;Update selector sprite Y position.
L8A73:  STA SpriteBuffer        ;
L8A76:  JMP CreateCharLoop      ;($8A11)Wait for next input on create character screen.

;----------------------------------------------------------------------------------------------------

;The followong table is used to set the Y position of the selector sprite
;while on the create character screen.

CreateChrYPosTbl:
L8A79:  .byte $80, $90, $A0

;----------------------------------------------------------------------------------------------------

ChrList:
L8A7C:  JSR InitPPU             ;($990C)Initialize the PPU.

L8A7F:  LDA #$02                ;
L8A81:  STA TXTXPos             ;Text will be located at tile coords X,Y=2,4.
L8A83:  LDA #$04                ;
L8A85:  STA TXTYPos             ;

L8A87:  LDA #$1C                ;
L8A89:  STA TXTClrCols          ;Clear 12 columns and 1 row for the text string.
L8A8B:  LDA #$01                ;
L8A8D:  STA TXTClrRows          ;

L8A8F:  LDA #$07                ;CHARACTER LIST.
L8A91:  STA TextIndex           ;
L8A93:  JSR ShowTextString      ;($995C)Show a text string on the screen.

L8A96:  LDX SGDatPtrLB          ;
L8A98:  STX SGCharPtrLB         ;Get pointer to base of save game character data.
L8A9A:  LDX SGDatPtrUB          ;Pointer is always 256 bytes higher than base of save game data.
L8A9C:  INX                     ;
L8A9D:  STX SGCharPtrUB         ;

L8A9F:  JSR ShowCharList        ;($99DF)Show the list of character is the current save game file.
L8AA2:* JSR GetInputPress       ;($98EE)Get input button press and account for retrigger.

L8AA5:  LDA Pad1Input           ;Was A button pressed?
L8AA7:  CMP #BTN_A              ;
L8AA9:  BEQ EndChrList          ;If so, branch to exit.

L8AAB:  CMP #BTN_B              ;B button will also exit.
L8AAD:  BNE -                   ;Any other button will be ignored.

EndChrList:
L8AAF:  RTS                     ;Stop showing character list.

;----------------------------------------------------------------------------------------------------

FormParty:
L8AB0:  LDA SGDatPtrLB          ;
L8AB2:  STA ChrDatPtrLB_        ;
L8AB4:  LDX SGDatPtrUB          ;Get a pointer to the base of the character data.
L8AB6:  INX                     ;
L8AB7:  STX ChrDatPtrUB_        ;

L8AB9:  LDA #$04                ;We need to find at least 4 valid characters.
L8ABB:  STA GenByte30           ;

L8ABD:  LDY #$00                ;Zero out the index.

L8ABF:  LDX #NUM_CHARACTERS     ;Prepare to look through all 20 character slots.

FindChrLoop:
L8AC1:  LDA (ChrDatPtr_),Y      ;Did we find a valid character slot?
L8AC3:  CMP #CHR_EMPTY_SLOT     ;
L8AC5:  BEQ NextSlot            ;If not, branch to move to the next slot.

L8AC7:  DEC GenByte30           ;Found a valid character.
L8AC9:  BEQ FormPartyList       ;Did we find 4 valid characters? If not, branch to find another.

NextSlot:
L8ACB:  CLC                     ;
L8ACC:  LDA ChrDatPtrLB_        ;
L8ACE:  ADC #$40                ;
L8AD0:  STA ChrDatPtrLB_        ;Move the pointer to the next character slot.
L8AD2:  LDA ChrDatPtrUB_        ;
L8AD4:  ADC #$00                ;
L8AD6:  STA ChrDatPtrUB_        ;

L8AD8:  DEX                     ;Do we still have more character slots we can check?
L8AD9:  BNE FindChrLoop         ;If so, branch to check the next slot.

L8ADB:  SEC                     ;Save game does not have at least 4 characters created.
L8ADC:  RTS                     ;

FormPartyList:
L8ADD:  JSR InitPPU             ;($990C)Initialize the PPU.

L8AE0:  LDA #$02                ;
L8AE2:  STA TXTXPos             ;Text will be located at tile coords X,Y=2,4.
L8AE4:  LDA #$04                ;
L8AE6:  STA TXTYPos             ;

L8AE8:  LDA #$1C                ;
L8AEA:  STA TXTClrCols          ;Clear 12 columns and 1 row for the text string.
L8AEC:  LDA #$01                ;
L8AEE:  STA TXTClrRows          ;

L8AF0:  LDA #$1A                ;FORM A PARTY text and number list 1-20.
L8AF2:  STA TextIndex           ;
L8AF4:  JSR ShowTextString      ;($995C)Show a text string on the screen.

L8AF7:  LDX SGDatPtrLB          ;
L8AF9:  STX SGCharPtrLB         ;
L8AFB:  LDX SGDatPtrUB          ;Get a pointer to the base of the character data.
L8AFD:  INX                     ;
L8AFE:  STX SGCharPtrUB         ;

L8B00:  JSR ShowCharList        ;($99DF)Show the list of character is the current save game file.

L8B03:  LDA #$10                ;
L8B05:  STA TXTXPos             ;Text will be located at tile coords X,Y=20,26.
L8B07:  LDA #$1A                ;
L8B09:  STA TXTYPos             ;

L8B0B:  LDA #$0A                ;
L8B0D:  STA TXTClrCols          ;Clear 10 columns and 1 row for the text string.
L8B0F:  LDA #$01                ;
L8B11:  STA TXTClrRows          ;

L8B13:  LDA #$08                ;END text.
L8B15:  STA TextIndex           ;
L8B17:  JSR ShowTextString      ;($995C)Show a text string on the screen.

L8B1A:  LDA #$30                ;
L8B1C:  STA SpriteBuffer        ;Set start position of selector sprite at pixel coords X,Y=32,48.
L8B1F:  LDA #$20                ;
L8B21:  STA SpriteBuffer+3      ;

L8B24:  LDA #$00                ;Indicate player is forming their party.
L8B26:  STA IsFormingParty      ;

L8B28:  LDY #SG_CHR1_INDEX      ;
L8B2A:  LDA (SGDatPtr),Y        ;
L8B2C:  CLC                     ;Set index into character pool of character 1.
L8B2D:  ADC #$01                ;
L8B2F:  STA Ch1Index_           ;

L8B31:  INY                     ;
L8B32:  LDA (SGDatPtr),Y        ;
L8B34:  CLC                     ;Set index into character pool of character 2.
L8B35:  ADC #$01                ;
L8B37:  STA Ch2Index_           ;

L8B39:  INY                     ;
L8B3A:  LDA (SGDatPtr),Y        ;
L8B3C:  CLC                     ;Set index into character pool of character 3.
L8B3D:  ADC #$01                ;
L8B3F:  STA Ch3Index_           ;

L8B41:  INY                     ;
L8B42:  LDA (SGDatPtr),Y        ;
L8B44:  CLC                     ;Set index into character pool of character 4.
L8B45:  ADC #$01                ;
L8B47:  STA Ch4Index_           ;

L8B49:  JSR UpdateSelChars      ;($8CF5)Update which characters are selected while forming a party.
L8B4C:  LDX #$00                ;
L8B4E:  LDY #$00                ;Set current character at row 1, column 1.

FormPartyInputLoop:
L8B50:  JSR GetInputPress       ;($98EE)Get input button press and account for retrigger.

L8B53:  LDA IsFormingParty      ;Is player about to end and is not actively forming a party?
L8B55:  BNE FormChkBtnA         ;If so, branch.

L8B57:  LDA Pad1Input           ;Did player push the right d-pad button?
L8B59:  CMP #BTN_RIGHT          ;
L8B5B:  BNE FormChkBtnLft       ;If not, branch to check next button press.

L8B5D:  CPX #$01                ;Is selcetor in second column already?
L8B5F:  BNE +                   ;If not, branch to move selector to second column.

L8B61:  JMP FormPartyInputLoop  ;($8B50)Get user input while forming a party.

L8B64:* INX                     ;Indicate selector is in the second column.
L8B65:  LDA #$98                ;Move selector sprite to second column.
L8B67:  STA SpriteBuffer+3      ;
L8B6A:  JMP FormPartyInputLoop  ;($8B50)Get user input while forming a party.

FormChkBtnLft:
L8B6D:  CMP #BTN_LEFT           ;Did the player push the left button?
L8B6F:  BNE FormChkBtnUp        ;If not, branch to check other buttons.

L8B71:  CPX #$00                ;Is selector in the left most column?
L8B73:  BNE +                   ;If not branch to update selector sprite position.

L8B75:  JMP FormPartyInputLoop  ;($8B50)Get user input while forming a party.

L8B78:* DEX                     ;Indicate selector sprite is in first column.

L8B79:  LDA #$20                ;Move selector sprite X pixel coordinate to first column.
L8B7B:  STA SpriteBuffer+3      ;

L8B7E:  JMP FormPartyInputLoop  ;($8B50)Get user input while forming a party.

FormChkBtnUp:
L8B81:  CMP #BTN_UP             ;Did the player push the up button?
L8B83:  BNE FormChkBtnDn        ;If not, branch to check other buttons.

L8B85:  CPY #$00                ;Is selector sprite in top most row?
L8B87:  BNE +                   ;If not, branch to update its position.

L8B89:  JMP FormPartyInputLoop  ;($8B50)Get user input while forming a party.

L8B8C:* DEY                     ;Update row number of selector sprite.

L8B8D:  TYA                     ;
L8B8E:  ASL                     ;
L8B8F:  ASL                     ;
L8B90:  ASL                     ;Convert row number into Y pixel coordinate.
L8B91:  ASL                     ;
L8B92:  CLC                     ;
L8B93:  ADC #$30                ;

L8B95:  STA SpriteBuffer        ;Update pixel location of the selector sprite.
L8B98:  JMP FormPartyInputLoop  ;($8B50)Get user input while forming a party.

FormChkBtnDn:
L8B9B:  CMP #BTN_DOWN           ;Did the player push the down button?
L8B9D:  BNE FormChkBtnA         ;If not, branch to check other buttons.

L8B9F:  CPY #$09                ;Is selector on the last row?
L8BA1:  BNE +                   ;If not, branch to update the selector X position.

L8BA3:  JMP FormPartyInputLoop  ;($8B50)Get user input while forming a party.

L8BA6:* INY                     ;Update row number of selector sprite.

L8BA7:  TYA                     ;
L8BA8:  ASL                     ;
L8BA9:  ASL                     ;
L8BAA:  ASL                     ;Convert row number into Y pixel coordinate.
L8BAB:  ASL                     ;
L8BAC:  CLC                     ;
L8BAD:  ADC #$30                ;

L8BAF:  STA SpriteBuffer        ;Update pixel location of the selector sprite.
L8BB2:  JMP FormPartyInputLoop  ;($8B50)Get user input while forming a party.

FormChkBtnA:
L8BB5:  LDA Pad1Input           ;Did the player push the A button?
L8BB7:  CMP #BTN_A              ;
L8BB9:  BEQ +                   ;If so, branch to process button press.

L8BBB:  JMP FormChkBtnB         ;($8C6B)Check if button B was presed.

L8BBE:* LDA IsFormingParty      ;Is player still forming a party?
L8BC0:  BEQ UnselectChar        ;If so, branch to unselect current character.

L8BC2:  CMP #$01                ;Should never be 1.
L8BC4:  BEQ PartyNotFormed      ;

L8BC6:  TYA                     ;Store selector sprite row number on stack.
L8BC7:  PHA                     ;

L8BC8:  LDY #$00                ;Zero out the index.

L8BCA:*  LDA ChIndex_,Y         ;
L8BCD:  BEQ PartyNotComplete    ;Have 4 characters been selected?
L8BCF:  INY                     ;If not, branch. Party can't journey onward.
L8BD0:  CPY #$04                ;
L8BD2:  BNE -                   ;

L8BD4:  LDY #SG_CHR1_INDEX      ;
L8BD6:  LDA Ch1Index_           ;
L8BD8:  SEC                     ;Set index to character 1 data in the save game file.
L8BD9:  SBC #$01                ;
L8BDB:  STA (SGDatPtr),Y        ;

L8BDD:  INY                     ;
L8BDE:  LDA Ch2Index_           ;
L8BE0:  SEC                     ;Set index to character 2 data in the save game file.
L8BE1:  SBC #$01                ;
L8BE3:  STA (SGDatPtr),Y        ;

L8BE5:  INY                     ;
L8BE6:  LDA Ch3Index_           ;
L8BE8:  SEC                     ;Set index to character 3 data in the save game file.
L8BE9:  SBC #$01                ;
L8BEB:  STA (SGDatPtr),Y        ;

L8BED:  INY                     ;
L8BEE:  LDA Ch4Index_           ;
L8BF0:  SEC                     ;Set index to character 4 data in the save game file.
L8BF1:  SBC #$01                ;
L8BF3:  STA (SGDatPtr),Y        ;

L8BF5:  PLA                     ;
L8BF6:  CLC                     ;Indicate a valid party has been formed before returning.
L8BF7:  RTS                     ;

PartyNotComplete:
L8BF8:  PLA                     ;Restore row number of selector sprite.
L8BF9:  TAY                     ;
L8BFA:  JMP FormPartyInputLoop  ;($8B50)Get user input while forming a party.

PartyNotFormed:
L8BFD:  SEC                     ;Indicate the party has not been successfully formed and exit.
L8BFE:  RTS                     ;

UnselectChar:
L8BFF:  STX FormPartyX          ;Save column and row position of selector sprite.
L8C01:  STY FormPartyY          ;

L8C03:  LDA FormPartyX          ;Is selector sprite in first column?
L8C05:  BEQ +                   ;If so, branch.

L8C07:  LDA #$0A                ;Add 10 to index for characters 11-20.

L8C09:* CLC                     ;
L8C0A:  ADC FormPartyY          ;Start forming pointer to character data with character index(0-19).
L8C0C:  STA ChrSrcPtrUB         ;

L8C0E:  CLC                     ;
L8C0F:  ADC #$01                ;Make a copy of character index(1-20).
L8C11:  STA GenByte30           ;

L8C13:  LDA #$00                ;
L8C15:  STA ChrSrcPtrLB         ;
L8C17:  LSR ChrSrcPtrUB         ;
L8C19:  ROR ChrSrcPtrLB         ;
L8C1B:  LSR ChrSrcPtrUB         ;
L8C1D:  ROR ChrSrcPtrLB         ;Calculate the pointer to the selected character's data.
L8C1F:  CLC                     ;
L8C20:  LDA SGCharPtrLB         ;
L8C22:  ADC ChrSrcPtrLB         ;
L8C24:  STA ChrSrcPtrLB         ;
L8C26:  LDA SGCharPtrUB         ;
L8C28:  ADC ChrSrcPtrUB         ;
L8C2A:  STA ChrSrcPtrUB         ;

L8C2C:  LDY #$00                ;
L8C2E:  LDA (ChrSrcPtr),Y       ;Is the selected character slot empty?
L8C30:  CMP #CHR_EMPTY_SLOT     ;
L8C32:  BNE ValidChrData        ;If not, branch to process data.

L8C34:  LDY FormPartyY          ;Character slot empty. Restore row/column
L8C36:  LDX FormPartyX          ;of selector sprite and exit.
L8C38:  JMP FormPartyInputLoop  ;($8B50)Get user input while forming a party.

ValidChrData:
L8C3B:  LDY #$00                ;Prepare to check all 4 chosen character slots.

ChkChosenLoop:
L8C3D:  LDA ChIndex_,Y          ;Has selected character already been selected?
L8C40:  CMP GenByte30           ;
L8C42:  BEQ AlreadyChosen       ;If so, branch to ignore selection.

L8C44:  INY                     ;Check all 4 character slots to make sure
L8C45:  CPY #$04                ;character has not already been selected.
L8C47:  BNE ChkChosenLoop       ;

L8C49:  LDY #$00                ;Zero out the index.

L8C4B:* LDA ChIndex_,Y          ;Has current slot been filled witha character index?
L8C4E:  BEQ SetChindex          ;If not, branch to fill the slot with the selected character.

L8C50:  INY                     ;Have all 4 slots been checked?
L8C51:  CPY #$04                ;
L8C53:  BNE -                   ;If not, branch to check the next slot.

L8C55:  LDY FormPartyY          ;Restore row/column selector position before exiting.
L8C57:  LDX FormPartyX          ;
L8C59:  JMP FormPartyInputLoop  ;($8B50)Get user input while forming a party.

SetChindex:
L8C5C:  LDA GenByte30           ;Save the selected character index into the save game.
L8C5E:  STA ChIndex_,Y          ;

L8C61:  JSR UpdateSelChars      ;($8CF5)Update which characters are selected while forming a party.

AlreadyChosen:
L8C64:  LDY FormPartyY          ;Restore row/column of the selector sprite.
L8C66:  LDX FormPartyX          ;

L8C68:  JMP FormPartyInputLoop  ;($8B50)Get user input while forming a party.

FormChkBtnB:
L8C6B:  CMP #BTN_B              ;Was B button pressed?
L8C6D:  BNE FormChkBtnSel       ;If not, branch to check other buttons.

L8C6F:  LDA IsFormingParty      ;Is player currently forming a party.
L8C71:  BEQ +                   ;If so, branch to process B button press.

L8C73:  JMP FormChkBtnSel       ;($8CA9)Check if select button was pressed.

L8C76:* STX FormPartyX          ;Store selector sprite row/colomn position.
L8C78:  STY FormPartyY          ;

L8C7A:  LDA FormPartyX          ;Is selector in the first column?
L8C7C:  BEQ +                   ;If so, branch.

L8C7E:  LDA #$0A                ;Add 10. selector is on character 11-20.

L8C80:* SEC                     ;
L8C81:  ADC FormPartyY          ;Save the index to the selected character(0-19).
L8C83:  STA GenByte30           ;

L8C85:  LDY #$00                ;Zero out the index.

L8C87:* LDA ChIndex_,Y          ;Does the deselected character match the one in the save game slot?
L8C8A:  CMP GenByte30           ;
L8C8C:  BEQ UnselectChr         ;If so, branch to process unselect request.

L8C8E:  INY                     ;Have all 4 character slots been checked?
L8C8F:  CPY #$04                ;
L8C91:  BNE -                   ;If not, branch to check the next slot.

L8C93:  LDX FormPartyX          ;Character was not previously selected.
L8C95:  LDY FormPartyY          ;Restore selector sprite row/column positions.
L8C97:  JMP FormPartyInputLoop  ;($8B50)Get user input while forming a party.

UnselectChr:
L8C9A:  LDA #$00                ;Unselect character by zeroing out index.
L8C9C:  STA ChIndex_,Y          ;
L8C9F:  JSR UpdateSelChars      ;($8CF5)Update which characters are selected while forming a party.

L8CA2:  LDY FormPartyY          ;Restore selector sprite row/column positions.
L8CA4:  LDX FormPartyX          ;
L8CA6:  JMP FormPartyInputLoop  ;($8B50)Get user input while forming a party.

FormChkBtnSel:
L8CA9:  CMP #BTN_SELECT         ;Was the select button pressed? If so, branch.
L8CAB:  BEQ +                   ;Else ignore any other inputs.

L8CAD:  JMP FormPartyInputLoop  ;($8B50)Get user input while forming a party.

L8CB0:* INC IsFormingParty      ;Increment forming party indicator.

L8CB2:  LDA IsFormingParty      ;Did player just hit select and move to END form party process?
L8CB4:  CMP #$01                ;
L8CB6:  BNE +                   ;If not, branch.

L8CB8:  LDA #$02                ;Indicate player is ready to end form party process.
L8CBA:  STA IsFormingParty      ;

L8CBC:* CMP #$03                ;Is player going back to forming the party?
L8CBE:  BNE FormPrtyEnd         ;If not, branch.

L8CC0:  LDA #$00                ;Indicate player went back to forming party.
L8CC2:  STA IsFormingParty      ;

L8CC4:  LDA #$20                ;Assume selector sprite is in column 0.
L8CC6:  CPX #$00                ;
L8CC8:  BEQ +                   ;Branch if it actually is. X pixel position already set.

L8CCA:  LDA #$98                ;Set selector sprite X pixel position to 2nd column.

L8CCC:* STA SpriteBuffer+3      ;Update X coordinate of selector sprite.

L8CCF:  TYA                     ;
L8CD0:  ASL                     ;
L8CD1:  ASL                     ;
L8CD2:  ASL                     ;Convert selector sprite row number into Y pixel position.
L8CD3:  ASL                     ;
L8CD4:  CLC                     ;
L8CD5:  ADC #$30                ;
L8CD7:  STA SpriteBuffer        ;

L8CDA:  JMP FormPartyInputLoop  ;($8B50)Get user input while forming a party.

FormPrtyEnd:
L8CDD:  LDA #$D0                ;Set Y pixel position of selector sprite to 208.
L8CDF:  STA SpriteBuffer        ;

L8CE2:  LDA IsFormingParty      ;
L8CE4:  CMP #$01                ;Should never be 1 at this point.
L8CE6:  BEQ FormPrty1           ;

L8CE8:  LDA #$A8                ;Set X pixel coordinate of selector sprite to 168.
L8CEA:  JMP +                   ;

FormPrty1:
L8CED:  LDA #$78                ;Should never get here.

L8CEF:* STA SpriteBuffer+3      ;Update X pixel position f selector sprite.
L8CF2:  JMP FormPartyInputLoop  ;($8B50)Get user input while forming a party.

;----------------------------------------------------------------------------------------------------

UpdateSelChars:
L8CF5:  LDY #$00                ;Prepare to unselect all character on form party screen.
L8CF7:  LDA #SPRT_HIDE          ;

UnselectLoop:
L8CF9:  STA SpriteBuffer+$C4,Y  ;
L8CFC:  INY                     ;
L8CFD:  INY                     ;
L8CFE:  INY                     ;Remove all 4 sprites showing which characters are selected.
L8CFF:  INY                     ;
L8D00:  CPY #$10                ;
L8D02:  BNE UnselectLoop        ;

L8D04:  LDY #$00                ;start at selected character 0.
L8D06:  LDA #$00                ;
L8D08:  STA GenByte2D           ;Zero index into selected sprites.

ChkSelectedLoop:
L8D0A:  LDA FormPrtyIndex,Y     ;Does current character slot have a selected character?
L8D0D:  BNE ChrIsSelected       ;If so, branch.

ChkNextSelected:
L8D0F:  INY                     ;Have all 4 character slots been checked as being selected?
L8D10:  CPY #$04                ;
L8D12:  BNE ChkSelectedLoop     ;If not, branch to check another.

L8D14:  RTS                     ;All 4 character slots checked for being selected. Exit.

ChrIsSelected:
L8D15:  LDX #$20                ;Assume selected character is in the first column.

L8D17:  CMP #$0B                ;Is current character 
L8D19:  BCC +                   ;

L8D1B:  LDX #$98                ;Selected character is in the second column.

L8D1D:* TXA                     ;
L8D1E:  LDX GenByte2D           ;Set pixel X position of selected sprite.
L8D20:  STA SpriteBuffer+$C7,X  ;

L8D23:  LDA FormPrtyIndex,Y     ;Is current character in the second column?
L8D26:  CMP #$0B                ;
L8D28:  BCC +                   ;If so, branch.

L8D2A:  SEC                     ;Since character is in 2nd column, need to start back at the top.
L8D2B:  SBC #$0A                ;

L8D2D:* ASL                     ;
L8D2E:  ASL                     ;*16. 16 pixels in the Y direction per character slot.
L8D2F:  ASL                     ;
L8D30:  ASL                     ;

L8D31:  CLC                     ;+32. Character slots offset from the top by 32 pixels.
L8D32:  ADC #$20                ;

L8D34:  STA SpriteBuffer+$C4,X  ;Set Y pixel coordinate of selected sprite.

L8D37:  LDA #$01                ;Set tile pattern of selected sprite.
L8D39:  STA SpriteBuffer+$C5,X  ;

L8D3C:  LDA #$00                ;Set properties of the selected sprite.
L8D3E:  STA SpriteBuffer+$C6,X  ;

L8D41:  CLC                     ;
L8D42:  LDA GenByte2D           ;Increment index to next selected sprite offset(4 bytes per sprite).
L8D44:  ADC #$04                ;
L8D46:  STA GenByte2D           ;

L8D48:  JMP ChkNextSelected     ;($8D0F)Move to next character selection slot.

;----------------------------------------------------------------------------------------------------

DoHandMade:
L8D4B:  JSR InitPPU             ;($990C)Initialize the PPU.

L8D4E:  LDA SGDatPtrLB          ;
L8D50:  STA ChrDatPtrLB_        ;Get a pointer to the base address
L8D52:  LDA SGDatPtrUB          ;of the selected save game character data.
L8D54:  STA ChrDatPtrUB_        ;
L8D56:  INC ChrDatPtrUB_        ;

L8D58:  LDA #NUM_CHARACTERS     ;Prepare to decrement through all the characters.
L8D5A:  STA GenByte30           ;

L8D5C:  LDY #$00                ;Zero out the index.

ChkEmptyLoop_:
L8D5E:  LDA (ChrDatPtr_),Y      ;Is the current character slot empty?
L8D60:  CMP #CHR_EMPTY_SLOT     ;
L8D62:  BEQ EmptySlotFound_     ;If so, branch.

L8D64:  CLC                     ;
L8D65:  LDA ChrDatPtrLB_        ;
L8D67:  ADC #$40                ;
L8D69:  STA ChrDatPtrLB_        ;Increment to next character slot(64 bytes).
L8D6B:  LDA ChrDatPtrUB_        ;
L8D6D:  ADC #$00                ;
L8D6F:  STA ChrDatPtrUB_        ;

L8D71:  DEC GenByte30           ;Have all the character slots been checked for an empty space?
L8D73:  BNE ChkEmptyLoop_       ;If not, branch to check the next slot.

L8D75:  RTS                     ;No empty character slots available. Exit.

EmptySlotFound_:
L8D76:  LDA ChrDatPtrUB_        ;
L8D78:  STA CrntChrPtrUB        ;Save a pointer to the empty character slot.
L8D7A:  LDA ChrDatPtrLB_        ;
L8D7C:  STA CrntChrPtrLB        ;

L8D7E:  LDA #$07                ;
L8D80:  STA TXTXPos             ;Text will be located at tile coords X,Y=7,4.
L8D82:  LDA #$04                ;
L8D84:  STA TXTYPos             ;

L8D86:  LDA #$10                ;
L8D88:  STA TXTClrCols          ;Clear 10 columns and 1 row for the text string.
L8D8A:  LDA #$01                ;
L8D8C:  STA TXTClrRows          ;

L8D8E:  LDA #$09                ;CHARACTER MAKING text.
L8D90:  STA TextIndex           ;
L8D92:  JSR ShowTextString      ;($995C)Show a text string on the screen.

L8D95:  LDA #$02                ;
L8D97:  STA WndXPos             ;Window will be located at tile coords X,Y=2,6
L8D99:  LDA #$06                ;
L8D9B:  STA WndYPos             ;

L8D9D:  LDA #$08                ;
L8D9F:  STA WndWidth            ;Window will be 8 tiles wide and 12 tiles tall.
L8DA1:  LDA #$0C                ;
L8DA3:  STA WndHeight           ;

L8DA5:  JSR DrawWndBrdr         ;($97A9)Draw window border.

L8DA8:  LDA #$04                ;
L8DAA:  STA TXTXPos             ;Text will be located at tile coords X,Y=4,6.
L8DAC:  LDA #$06                ;
L8DAE:  STA TXTYPos             ;

L8DB0:  LDA #$05                ;
L8DB2:  STA TXTClrCols          ;Clear 5 columns and 6 rows for the text string.
L8DB4:  LDA #$06                ;
L8DB6:  STA TXTClrRows          ;

L8DB8:  LDA #$0A                ;RACE text followed by a list of races.
L8DBA:  STA TextIndex           ;
L8DBC:  JSR ShowTextString      ;($995C)Show a text string on the screen.

L8DBF:  LDA #00                 ;
L8DC1:  STA HandMadeState       ;Zero out state and current column.
L8DC3:  STA HandMadeStatCol     ;

L8DC5:  LDY #$01                ;
L8DC7:* STA (CrntChrPtr),Y      ;Fill all bytes of character data with $00.
L8DC9:  INY                     ;
L8DCA:  CPY #$40                ;
L8DCC:  BNE -                   ;

L8DCE:  LDA #$40                ;
L8DD0:  STA SpriteBuffer        ;Set beginning coords of selector sprite to X,Y=24,64.
L8DD3:  LDA #$18                ;
L8DD5:  STA SpriteBuffer+3      ;

HandMadeInputLoop:
L8DD8:  JSR GetInputPress       ;($98EE)Get input button press and account for retrigger.

L8DDB:  LDA Pad1Input           ;Did player push the right button on the d-pad?
L8DDD:  CMP #BTN_RIGHT          ;
L8DDF:  BNE HMChkLeft           ;If not, branch to check other buttons.

L8DE1:  LDA HandMadeState       ;is player selecting the character's race?
L8DE3:  BEQ HandMadeInputLoop   ;If so, branch to ignore input.

L8DE5:  CMP #HM_PROFESSION      ;Is the player choosing the character's class?
L8DE7:  BNE HMUpdateColumn      ;If not, branch.

L8DE9:  LDY #CHR_CLASS          ;
L8DEB:  LDA (CrntChrPtr),Y      ;Is the current selected class barbarian or greater?
L8DED:  CMP #CLS_BARBARIAN      ;If so, branch to ignore right d-pad press.
L8DEF:  BCS HandMadeInputLoop   ;

L8DF1:  CLC                     ;If class is less than barbarian, add 6 to class values.
L8DF2:  ADC #$06                ;All these classes are in the second column.
L8DF4:  STA (CrntChrPtr),Y      ;

L8DF6:  JSR HMSpritesNStats     ;($9016)Update selector sprite position and stats text.
L8DF9:  JMP HandMadeInputLoop   ;($8DD8)Input button processing for hand-made characters.

HMUpdateColumn:
L8DFC:  LDA HandMadeStatCol     ;Must be in stat entry mode.
L8DFE:  CMP #$03                ;Is selector sprite in right most column?
L8E00:  BEQ HandMadeInputLoop   ;If so, branch to ignore right d-pad press.

L8E02:  INC HandMadeStatCol     ;Move selector sprite one column to the right.

L8E04:  JSR HMSpritesNStats     ;($9016)Update selector sprite position and stats text.
L8E07:  JMP HandMadeInputLoop   ;($8DD8)Input button processing for hand-made characters.

HMChkLeft:
L8E0A:  CMP #BTN_LEFT           ;Was the left button pressed on the D pad?
L8E0C:  BNE HMChkUp             ;If not, branch to process other buttons.

L8E0E:  LDA HandMadeState       ;Is the player choosing the character's race?
L8E10:  BNE +                   ;If not, branch.

L8E12:  JMP HandMadeInputLoop   ;($8DD8)Input button processing for hand-made characters.

L8E15:* CMP #HM_PROFESSION      ;Is the player selecting the Character's class?
L8E17:  BNE ChkStatsLeft        ;If not, branch. Must be setting stats.

L8E19:  LDY #CHR_CLASS          ;
L8E1B:  LDA (CrntChrPtr),Y      ;Is the selector sprite in the right column(lark or higher)?
L8E1D:  CMP #CLS_LARK           ;If so, branch to move selector to left column.
L8E1F:  BCS +                   ;

L8E21:  JMP HandMadeInputLoop   ;($8DD8)Input button processing for hand-made characters.

L8E24:* SEC                     ;
L8E25:  SBC #$06                ;Subtract 6 from class to move selector to left column.
L8E27:  STA (CrntChrPtr),Y      ;

L8E29:  JSR HMSpritesNStats     ;($9016)Update selector sprite position and stats text.
L8E2C:  JMP HandMadeInputLoop   ;($8DD8)Input button processing for hand-made characters.

ChkStatsLeft:
L8E2F:  LDA HandMadeStatCol     ;When inputting stats, is selector sprite in the left most column?
L8E31:  BNE +                   ;If not, branch to move selector sprite over by 1 column.

L8E33:  JMP HandMadeInputLoop   ;($8DD8)Input button processing for hand-made characters.

L8E36:* DEC HandMadeStatCol     ;Move selector sprite left by one column.
L8E38:  JSR HMSpritesNStats     ;($9016)Update selector sprite position and stats text.
L8E3B:  JMP HandMadeInputLoop   ;($8DD8)Input button processing for hand-made characters.

HMChkUp:
L8E3E:  CMP #BTN_UP             ;Was the up button pressed on the d pad?
L8E40:  BNE HMChkDown           ;If not, branch to check other button presses.

L8E42:  LDA HandMadeState       ;Is player selecting the character's race?
L8E44:  BNE ChkClassUp          ;If not, branch.

L8E46:  LDY #CHR_RACE           ;Is character race human(Top of the list)?
L8E48:  LDA (CrntChrPtr),Y      ;
L8E4A:  BNE +                   ;If not, branch.

L8E4C:  JMP HandMadeInputLoop   ;($8DD8)Input button processing for hand-made characters.

L8E4F:* SEC                     ;
L8E50:  SBC #$01                ;Move selector sprite up 1 row on the race list.
L8E52:  STA (CrntChrPtr),Y      ;

L8E54:  JSR HMSpritesNStats     ;($9016)Update selector sprite position and stats text.
L8E57:  JMP HandMadeInputLoop   ;($8DD8)Input button processing for hand-made characters.

ChkClassUp:
L8E5A:  CMP #HM_PROFESSION      ;Is player choosing the character's class?
L8E5C:  BNE ChkStatUp           ;If not, branch. Must be setting stats.

L8E5E:  LDY #CHR_CLASS          ;Is the fighter class selected(top of the list)?
L8E60:  LDA (CrntChrPtr),Y      ;
L8E62:  BEQ ExitClassUp         ;If so, branch to exit.

L8E64:  CMP #CLS_LARK           ;Is the lark class selected(top of the list)?
L8E66:  BNE +                   ;If not, branch.

ExitClassUp:
L8E68:  JMP HandMadeInputLoop   ;($8DD8)Input button processing for hand-made characters.

L8E6B:* SEC                     ;
L8E6C:  SBC #$01                ;Move selector sprite up row in the class list.
L8E6E:  STA (CrntChrPtr),Y      ;

L8E70:  JSR HMSpritesNStats     ;($9016)Update selector sprite position and stats text.
L8E73:  JMP HandMadeInputLoop   ;($8DD8)Input button processing for hand-made characters.

ChkStatUp:
L8E76:  LDY #CHR_STR            ;Prepare to add all the stats values together.
L8E78:  LDA #$00                ;

L8E7A:* CLC                     ;
L8E7B:  ADC (CrntChrPtr),Y      ;Add the character's strength, dexterity,
L8E7D:  INY                     ;intelligence and wisdom together.
L8E7E:  CPY #CHR_WIS+1          ;
L8E80:  BNE -                   ;

L8E82:  CMP #$2E                ;Is the total stat value greater than 45?
L8E84:  BCC +                   ;If not, branch.

L8E86:  JMP HandMadeInputLoop   ;($8DD8)Input button processing for hand-made characters.

L8E89:* LDA #CHR_STR            ;Start with the index of the character's strength.
L8E8B:  CLC                     ;Add the current selected column to it to get the targeted stat.
L8E8C:  ADC HandMadeStatCol     ;

L8E8E:  TAY                     ;
L8E8F:  LDA (CrntChrPtr),Y      ;Get the target stat. Is it maxed out at 25?
L8E91:  CMP #25                 ;If so, branch to exit.
L8E93:  BEQ +                   ;

L8E95:  CLC                     ;
L8E96:  ADC #$05                ;Increase current stat by 5.
L8E98:  STA (CrntChrPtr),Y      ;

L8E9A:  JSR HMSpritesNStats     ;($9016)Update selector sprite position and stats text.

L8E9D:* JMP HandMadeInputLoop   ;($8DD8)Input button processing for hand-made characters.

HMChkDown:
L8EA0:  CMP #BTN_DOWN           ;Did player press the down button?
L8EA2:  BNE HMChkA              ;If not, branch to check other buttons.

L8EA4:  LDA HandMadeState       ;Is player selecting the character's race?
L8EA6:  BNE ChkClassDown        ;If not, branch.

L8EA8:  LDY #CHR_RACE           ;Is the current race selected a fuzzy?
L8EAA:  LDA (CrntChrPtr),Y      ;
L8EAC:  CMP #RC_FUZZY           ;If not, branch.
L8EAE:  BNE +                   ;Else ignore input.

L8EB0:  JMP HandMadeInputLoop   ;($8DD8)Input button processing for hand-made characters.

L8EB3:* CLC                     ;
L8EB4:  ADC #$01                ;Move down 1 row on the race list.
L8EB6:  STA (CrntChrPtr),Y      ;

L8EB8:  JSR HMSpritesNStats     ;($9016)Update selector sprite position and stats text.
L8EBB:  JMP HandMadeInputLoop   ;($8DD8)Input button processing for hand-made characters.

ChkClassDown:
L8EBE:  CMP #HM_PROFESSION      ;Is player selecting the character's class?
L8EC0:  BNE ChkStatDown         ;If not, branch.

L8EC2:  LDY #CHR_CLASS          ;Is the current class selected the barbarian?
L8EC4:  LDA (CrntChrPtr),Y      ;
L8EC6:  CMP #CLS_BARBARIAN      ;
L8EC8:  BEQ ClassDownExit       ;If so, branch to exit.

L8ECA:  CMP #CLS_RANGER         ;Is the current class selected the ranger?
L8ECC:  BNE +                   ;If so, exit.

ClassDownExit:
L8ECE:  JMP HandMadeInputLoop   ;($8DD8)Input button processing for hand-made characters.

L8ED1:* CLC                     ;
L8ED2:  ADC #$01                ;Move down 1 row on the class list.
L8ED4:  STA (CrntChrPtr),Y      ;

L8ED6:  JSR HMSpritesNStats     ;($9016)Update selector sprite position and stats text.
L8ED9:  JMP HandMadeInputLoop   ;($8DD8)Input button processing for hand-made characters.

ChkStatDown:
L8EDC:  CLC                     ;Start with the index of the character's strength.
L8EDD:  LDA #CHR_STR            ;Add the current selected column to it to get the targeted stat.
L8EDF:  ADC HandMadeStatCol     ;

L8EE1:  TAY                     ;Get the target stat. Is it at the minimum value of 0?
L8EE2:  LDA (CrntChrPtr),Y      ;
L8EE4:  BNE +                   ;If not, branch to reduce the stat by 5.

L8EE6:  JMP HandMadeInputLoop   ;($8DD8)Input button processing for hand-made characters.

L8EE9:* SEC                     ;
L8EEA:  SBC #$05                ;Reduce the selected stat by 5.
L8EEC:  STA (CrntChrPtr),Y      ;

L8EEE:  JSR HMSpritesNStats     ;($9016)Update selector sprite position and stats text.
L8EF1:  JMP HandMadeInputLoop   ;($8DD8)Input button processing for hand-made characters.

HMChkA:
L8EF4:  CMP #BTN_A              ;Did player press the A button?
L8EF6:  BEQ NextHandMadeState   ;If so, branch to process button press. Else exit.

L8EF8:  JMP HandMadeInputLoop   ;($8DD8)Input button processing for hand-made characters.

NextHandMadeState:
L8EFB:  INC HandMadeState       ;Move to next hand made stats state.

L8EFD:  LDA HandMadeState       ;Is the player about to select the character's class?
L8EFF:  CMP #HM_PROFESSION      ;
L8F01:  BNE ChkStatsState       ;If not, branch.

L8F03:  LDA SpriteBuffer        ;
L8F06:  STA SpriteBuffer+$C4    ;Copy selector sprite into sprite 49.
L8F09:  LDA SpriteBuffer+3      ;
L8F0C:  STA SpriteBuffer+$C7    ;

L8F0F:  LDA #$01                ;Set static selector sprite for race selection.
L8F11:  STA SpriteBuffer+$C5    ;

L8F14:  LDA #$40                ;
L8F16:  STA SpriteBuffer        ;Set initial pixel coords of new selector sprite to X,Y=72,64.
L8F19:  LDA #$48                ;
L8F1B:  STA SpriteBuffer+3      ;

L8F1E:  LDA #$08                ;
L8F20:  STA WndXPos             ;Window will be located at tile coords X,Y=8,6
L8F22:  LDA #$06                ;
L8F24:  STA WndYPos             ;

L8F26:  LDA #$10                ;
L8F28:  STA WndWidth            ;Window will be 16 tiles wide and 14 tiles tall.
L8F2A:  LDA #$0E                ;
L8F2C:  STA WndHeight           ;

L8F2E:  JSR DrawWndBrdr         ;($97A9)Draw window border.

L8F31:  LDA #$0A                ;
L8F33:  STA TXTXPos             ;Text will be located at tile coords X,Y=10,6.
L8F35:  LDA #$06                ;
L8F37:  STA TXTYPos             ;

L8F39:  LDA #$0C                ;
L8F3B:  STA TXTClrCols          ;Clear 12 columns and 7 rows for the text string.
L8F3D:  LDA #$07                ;
L8F3F:  STA TXTClrRows          ;

L8F41:  LDA #$0D                ;PROFESSION text followed by all professions.
L8F43:  STA TextIndex           ;
L8F45:  JSR ShowTextString      ;($995C)Show a text string on the screen.
L8F48:  JMP HandMadeInputLoop   ;($8DD8)Input button processing for hand-made characters.

ChkStatsState:
L8F4B:  CMP #HM_STATS           ;Is player setting the character's stats?
L8F4D:  BNE ChkOKState          ;If not, branch.

L8F4F:  LDA SpriteBuffer        ;
L8F52:  STA SpriteBuffer+$C8    ;Copy selector sprite into sprite 50.
L8F55:  LDA SpriteBuffer+3      ;
L8F58:  STA SpriteBuffer+$CB    ;

L8F5B:  LDA #$01                ;Set static selector sprite for class selection.
L8F5D:  STA SpriteBuffer+$C9    ;

L8F60:  LDA #$02                ;
L8F62:  STA WndXPos             ;Window will be located at tile coords X,Y=2,22.
L8F64:  LDA #$16                ;
L8F66:  STA WndYPos             ;

L8F68:  LDA #$1C                ;
L8F6A:  STA WndWidth            ;Window will be 26 tiles wide and 4 tiles tall.
L8F6C:  LDA #$04                ;
L8F6E:  STA WndHeight           ;

L8F70:  JSR DrawWndBrdr         ;($97A9)Draw window border.

L8F73:  LDA #$04                ;
L8F75:  STA TXTXPos             ;Text will be located at tile coords X,Y=4,22.
L8F77:  LDA #$16                ;
L8F79:  STA TXTYPos             ;

L8F7B:  LDA #$19                ;
L8F7D:  STA TXTClrCols          ;Clear 25 columns and 1 row for the text string.
L8F7F:  LDA #$01                ;
L8F81:  STA TXTClrRows          ;

L8F83:  LDA #$0B                ;REST STR DEX INT WIS text.
L8F85:  STA TextIndex           ;
L8F87:  JSR ShowTextString      ;($995C)Show a text string on the screen.

L8F8A:  LDA #$C0                ;
L8F8C:  STA SpriteBuffer        ;Set initial pixel coords of new selector sprite to X,Y=80,192.
L8F8F:  LDA #$50                ;
L8F91:  STA SpriteBuffer+3      ;

L8F94:  JSR HMSpritesNStats     ;($9016)Update selector sprite position and stats text.
L8F97:  JMP HandMadeInputLoop   ;($8DD8)Input button processing for hand-made characters.

ChkOKState:
L8F9A:  CMP #HM_OK_CANCEL       ;Does OK CANCEL message need to be displayed?
L8F9C:  BEQ ChkValidChar        ;If so, branch to check if character is valid.

L8F9E:  LDA SpriteBuffer+3      ;Did player just seleck OK?
L8FA1:  CMP #$A0                ;
L8FA3:  BNE +                   ;If not, they must have selected CANCEL. Branch to start over.

L8FA5:  RTS                     ;Character accepted. Enter name next.

L8FA6:* JMP DoHandMade          ;($8D4B)Create a hand made character. Character cancelled.

ChkValidChar:
L8FA9:  LDY #CHR_STR            ;Prepare to add together all the stats of the new character.
L8FAB:  LDA #$00                ;

L8FAD:* CLC                     ;
L8FAE:  ADC (CrntChrPtr),Y      ;
L8FB0:  INY                     ;Loop to add STR DEX INT WIS into one value.
L8FB1:  CPY #CHR_WIS+1          ;
L8FB3:  BNE -                   ;

L8FB5:  CMP #50                 ;Is total value of combined stats = 50?
L8FB7:  BEQ +                   ;If so, character is valid. Branch to continue.

L8FB9:  DEC HandMadeState       ;More stats need to be distributed.
L8FBB:  JMP HandMadeInputLoop   ;($8DD8)Input button processing for hand-made characters.

L8FBE:* LDA #SPRT_HIDE          ;Hide selector sprite off bottom of screen.
L8FC0:  STA SpriteBuffer        ;

L8FC3:  LDA #$0C                ;
L8FC5:  STA TXTXPos             ;Text will be located at tile coords X,Y=12,26.
L8FC7:  LDA #$1A                ;
L8FC9:  STA TXTYPos             ;

L8FCB:  LDA #$12                ;
L8FCD:  STA TXTClrCols          ;Clear 15 columns and 1 row for the text string.
L8FCF:  LDA #$01                ;
L8FD1:  STA TXTClrRows          ;

L8FD3:  LDA #$0C                ;OK CANCEL text.
L8FD5:  STA TextIndex           ;
L8FD7:  JSR ShowTextString      ;($995C)Show a text string on the screen.

L8FDA:  LDA #$A0                ;
L8FDC:  STA SpriteBuffer+3      ;Set initial position of selector sprite to OK.
L8FDF:  LDA #$D0                ;Pixel coords X,Y=160, 208.
L8FE1:  STA SpriteBuffer        ;

OKCnclInputLoop:
L8FE4:  JSR GetInputPress       ;($98EE)Get input button press and account for retrigger.
L8FE7:  LDA Pad1Input           ;

L8FE9:  CMP #BTN_RIGHT          ;Did player hit the right d-pad button?
L8FEB:  BNE ChkOKCnclLeft       ;If not, branch to check other buttons.

L8FED:  LDA SpriteBuffer+3      ;Is selector sprite on OK?
L8FF0:  CMP #$A0                ;
L8FF2:  BNE OKCnclInputLoop     ;If not, branch to ignore input.

L8FF4:  LDA #$B8                ;Move selector sprite to CANCEL selection.
L8FF6:  STA SpriteBuffer+3      ;
L8FF9:  JMP OKCnclInputLoop     ;($8FE4)Input loop for OK CANCEL selection.

ChkOKCnclLeft:
L8FFC:  CMP #BTN_LEFT           ;Did player hit the left d-pad button?
L8FFE:  BNE ChkOKCnclA          ;If not, branch to check other buttons.

L9000:  LDA SpriteBuffer+3      ;Is selector sprite on CANCEL?
L9003:  CMP #$B8                ;
L9005:  BNE OKCnclInputLoop     ;If not, branch to ignore input.

L9007:  LDA #$A0                ;Move selector sprite to OK selection.
L9009:  STA SpriteBuffer+3      ;
L900C:  JMP OKCnclInputLoop     ;($8FE4)Input loop for OK CANCEL selection.

ChkOKCnclA:
L900F:  CMP #BTN_A              ;Did player press the A button?
L9011:  BNE OKCnclInputLoop     ;If not, branch to ignore input.

L9013:  JMP NextHandMadeState   ;($8EFB)Increment to next hand made state.

;----------------------------------------------------------------------------------------------------

HMSpritesNStats:
L9016:  LDA HandMadeState       ;Is player selecting character's race?
L9018:  BNE ChkClass            ;If not, branch.

L901A:  LDY #CHR_RACE           ;Get the currently selected race.
L901C:  LDA (CrntChrPtr),Y      ;

L901E:  TAX                     ;
L901F:  LDA HMYPosTbl,X         ;Set the selector sprite Y coordinate based on current race.
L9022:  STA SpriteBuffer        ;
L9025:  RTS                     ;

ChkClass:
L9026:  CMP #HM_PROFESSION      ;Is player selecting character's class?
L9028:  BNE DoStats             ;If not, must be setting stats. branch.

L902A:  LDY #CHR_CLASS          ;Prepare to get character's currently selected class.
L902C:  LDX #$48                ;Assume selector sprite is in first column.

L902E:  LDA (CrntChrPtr),Y      ;Is selected class less than lark(second column classes)?
L9030:  CMP #CLS_LARK           ;
L9032:  BCC SetClassXY          ;If so, branch.

L9034:  LDX #$80                ;
L9036:  SEC                     ;Set appropriate row/column for second column classes.
L9037:  SBC #$06                ;

SetClassXY:
L9039:  STX SpriteBuffer+3      ;
L903C:  TAX                     ;
L903D:  LDA HMYPosTbl,X         ;Get proper pixel Y coord for selected class from table below.
L9040:  STA SpriteBuffer        ;
L9043:  RTS                     ;

DoStats:
L9044:  LDX HandMadeStatCol     ;
L9046:  LDA HMXPosTbl,X         ;Set the selector sprite pixel X coord based on its current column.
L9049:  STA SpriteBuffer+3      ;

L904C:  LDY #$00                ;Prepare to zero out portion of text buffer.
L904E:  LDA #$00                ;

L9050:* STA TextBuffer,Y        ;
L9053:  INY                     ;Zero out first 30 bytes of the text buffer.
L9054:  CPY #$1E                ;
L9056:  BNE -                   ;

L9058:  LDA #50                 ;Start with 50 and prep to subtract stats from this value.
L905A:  LDY #CHR_STR

L905C:* SEC                     ;
L905D:  SBC (CrntChrPtr),Y      ;
L905F:  INY                     ;Loop and subtract stat values from max value of 50.
L9060:  CPY #CHR_WIS+1          ;
L9062:  BNE -                   ;

L9064:  STA BinInputLB          ;
L9066:  LDA #$00                ;Prepare to convert REST value to BCD.
L9068:  STA BinInputUB          ;

L906A:  JSR BinToBCD            ;($9883)Convert 16-bit word to 4 digit number.

L906D:  LDA BCDOutput2          ;
L906F:  STA TextBufferBase      ;Put BCD REST value into text buffer.
L9072:  LDA BCDOutput3          ;
L9074:  STA TextBuffer+1        ;

L9077:  LDY #CHR_STR            ;
L9079:  LDA (CrntChrPtr),Y      ;
L907B:  STA BinInputLB          ;Get current STR value and prep to convert to BCD.
L907D:  LDA #$00                ;
L907F:  STA BinInputUB          ;

L9081:  JSR BinToBCD            ;($9883)Convert 16-bit word to 4 digit number.

L9084:  LDA BCDOutput2          ;
L9086:  STA TextBuffer+5        ;Put BCD STR value into text buffer.
L9089:  LDA BCDOutput3          ;
L908B:  STA TextBuffer+6        ;

L908E:  LDY #CHR_DEX            ;
L9090:  LDA (CrntChrPtr),Y      ;
L9092:  STA BinInputLB          ;Get current DEX value and prep to convert to BCD.
L9094:  LDA #$00                ;
L9096:  STA BinInputUB          ;

L9098:  JSR BinToBCD            ;($9883)Convert 16-bit word to 4 digit number.

L909B:  LDA BCDOutput2          ;
L909D:  STA TextBuffer+$A       ;Put BCD DEX value into text buffer.
L90A0:  LDA BCDOutput3          ;
L90A2:  STA TextBuffer+$B       ;

L90A5:  LDY #CHR_INT            ;
L90A7:  LDA (CrntChrPtr),Y      ;
L90A9:  STA BinInputLB          ;Get current INT value and prep to convert to BCD.
L90AB:  LDA #$00                ;
L90AD:  STA BinInputUB          ;

L90AF:  JSR BinToBCD            ;($9883)Convert 16-bit word to 4 digit number.

L90B2:  LDA BCDOutput2          ;
L90B4:  STA TextBuffer+$F       ;Put BCD INT value into text buffer.
L90B7:  LDA BCDOutput3          ;
L90B9:  STA TextBuffer+$10      ;

L90BC:  LDY #CHR_WIS            ;
L90BE:  LDA (CrntChrPtr),Y      ;
L90C0:  STA BinInputLB          ;Get current WIS value and prep to convert to BCD.
L90C2:  LDA #$00                ;
L90C4:  STA BinInputUB          ;

L90C6:  JSR BinToBCD            ;($9883)Convert 16-bit word to 4 digit number.

L90C9:  LDA BCDOutput2          ;
L90CB:  STA TextBuffer+$14      ;Put BCD WIS value into text buffer.
L90CE:  LDA BCDOutput3          ;
L90D0:  STA TextBuffer+$15      ;

L90D3:  LDA #TXT_END            ;Put end marker in text buffer.
L90D5:  STA TextBuffer+$16      ;

L90D8:  LDA #$06                ;
L90DA:  STA TXTXPos             ;Text will be located at tile coords X,Y=6,24.
L90DC:  LDA #$18                ;
L90DE:  STA TXTYPos             ;

L90E0:  LDA #$16                ;
L90E2:  STA TXTClrCols          ;Clear 22 columns and 1 row for the text string.
L90E4:  LDA #$01                ;
L90E6:  STA TXTClrRows          ;

L90E8:  LDA #TXT_DBL_SPACE      ;Indicate text buffer is already filled and double spaced.
L90EA:  STA TextIndex           ;
L90EC:  JSR ShowTextString      ;($995C)Show a text string on the screen.
L90EF:  RTS

;----------------------------------------------------------------------------------------------------

;The following table is used to set the pixel Y position of the selector sprite when selecting
;a hand made character's profession.

HMYPosTbl:
L90F0:  .byte $40, $50, $60, $70, $80, $90

;The following table is used to set the pixel X position of the selector sprite when setting
;the character's stats.

HMXPosTbl:
L90F6:  .byte $50, $78, $A0, $C8

;----------------------------------------------------------------------------------------------------

EnterCharName:
L90FA:  JSR InitPPU             ;($990C)Initialize the PPU.
L90FD:  LDA #SCREEN_OFF         ;
L90FF:  STA CurPPUConfig1       ;Turn the screen off.

L9101:  LDY #CHR_CLASS          ;
L9103:  LDA (CrntChrPtr),Y      ;Set character class in slot 4(right most character).
L9105:  STA Ch4StClass          ;

L9107:  LDA #CHR_EMPTY_SLOT     ;
L9109:  STA Ch1StClass          ;Clear out any other valid character selections.
L910B:  STA Ch2StClass          ;
L910D:  STA Ch3StClass          ;

L910F:  JSR LdLgCharTiles1      ;($C009)Load tiles to display large character class portraits.

L9112:  LDA #PPU_NT0_UB         ;
L9114:  STA NTDestAdrUB         ;Set name table destination address($2096).
L9116:  LDA #PPU_NT0_LB+$96     ;
L9118:  STA NTDestAdrLB         ;

L911A:  LDA #$DC                ;Set pattern table starting tile.
L911C:  STA PTStartTile         ;

L911E:  JSR LoadLargeChar       ;($96CD)Load large image of the character class.

L9121:  LDA #$40
L9123:  JSR UpdatePPUBufSize    ;($99A8)Update number of bytes filled in PPU buffer.

L9126:  LDA #PPU_AT0_UB         ;
L9128:  STA PPUBufBase,X        ;
L912B:  INX                     ;Set a destination address to write data to name table 0.
L912C:  LDA #PPU_AT0_LB         ;
L912E:  STA PPUBufBase,X        ;

L9131:  INX                     ;Prepare to write 64 bytes of data to name table 0.
L9132:  LDY #$00                ;

L9134:* LDA HndMadeATDat,Y      ;
L9137:  STA PPUBufBase,X        ;
L913A:  INX                     ;Copy 64 bytes of data to name table 0.
L913B:  INY                     ;
L913C:  CPY #$40                ;
L913E:  BNE -                   ;

L9140:  JSR ChkPPUBufFull       ;($99D5)Check if PPU buffer is full and set indicator if necessary.

L9143:  LDA #>AttribBuffer      ;
L9145:  STA PPUDstPtrUB         ;Set destination pointer to first character's palette data.
L9147:  LDA #<AttribBuffer+$04  ;
L9149:  STA PPUDstPtrLB         ;

L914B:  LDY #CHR_CLASS          ;Get current character class.
L914D:  LDA (CrntChrPtr),Y      ;
L914F:  JSR LoadLgChrPalettes   ;($9701)Load palette data for individual character portraits.

L9152:  LDA #SCREEN_ON          ;Turn the screen on.
L9154:  STA CurPPUConfig1       ;

L9156:  LDA #$06                ;
L9158:  STA TXTXPos             ;Text will be located at tile coords X,Y=6,6.
L915A:  LDA #$06                ;
L915C:  STA TXTYPos             ;

L915E:  LDA #$0E                ;
L9160:  STA TXTClrCols          ;Clear 14 columns and 1 row for the text string.
L9162:  LDA #$01                ;
L9164:  STA TXTClrRows          ;

L9166:  LDA #$0E                ;CHARACTER NAME text.
L9168:  STA TextIndex           ;

L916A:  JSR ShowTextString      ;($995C)Show a text string on the screen.
L916D:  JSR EnterName           ;($871D)Show screen for entring name info.

L9170:  LDY #CHR_COND           ;Start at character condition.

ChrClearLoop:
L9172:* LDA #$00                ;Zero out character stat.
L9174:  STA (CrntChrPtr),Y      ;
L9176:  INY                     ;Are there more character stats to clear?
L9177:  CPY #$40                ;
L9179:  BNE -                   ;If so, branch to clear the next one.

L917B:  LDY #CHR_LEVEL          ;
L917D:  LDA #$01                ;Set character level to 1.
L917F:  STA (CrntChrPtr),Y      ;

L9181:  LDY #CHR_UNUSED32       ;No effect.
L9183:  STA (CrntChrPtr),Y      ;

L9185:  LDY #CHR_GOLD           ;
L9187:  LDA #$64                ;Set character gold to 100.
L9189:  STA (CrntChrPtr),Y      ;

L918B:  LDA #$96                ;
L918D:  LDY #CHR_FOOD           ;Set character food to 150.
L918F:  STA (CrntChrPtr),Y      ;

L9191:  LDY #CHR_HIT_PNTS       ;Set character hit points to 150.
L9193:  STA (CrntChrPtr),Y      ;

L9195:  LDA #$01                ;
L9197:  LDY #CHR_WEAPONS        ;Set 1 dagger in character inventory.
L9199:  STA (CrntChrPtr),Y      ;

L919B:  LDY #CHR_ARMOR          ;Set 1 cloth in character inventory.
L919D:  STA (CrntChrPtr),Y      ;

L919F:  LDY #CHR_EQ_WEAPON      ;Equip the character's dagger.
L91A1:  STA (CrntChrPtr),Y      ;

L91A3:  LDY #CHR_EQ_ARMOR       ;Equip the character's cloth armor.
L91A5:  STA (CrntChrPtr),Y      ;

L91A7:  LDY #$00                ;Zero out index.

SetChrNameLoop:
L91A9:  LDA TextBuffer,Y        ;Get a letter of the character's name.
L91AC:  CMP #TXT_END            ;Is it the end of text marker?
L91AE:  BEQ +                   ;If so, branch.

L91B0:  STA (CrntChrPtr),Y      ;Store letter of character's name.

L91B2:  INY                     ;Have a max of 5 letters been saved?
L91B3:  CPY #$05                ;
L91B5:  BNE SetChrNameLoop      ;If not, branch to get another letter.
L91B7:  RTS                     ;Else done saving name. Exit.

L91B8:* LDA #TXT_BLANK          ;
L91BA:  STA (CrntChrPtr),Y      ;
L91BC:  INY                     ;Fill in any unused name letters with blank spaces.
L91BD:  CPY #$05                ;
L91BF:  BNE -                   ;
L91C1:  RTS                     ;

;----------------------------------------------------------------------------------------------------

DoReadyMade:
L91C2:  JSR Find4EmptySlots     ;($9421)Check to see if there are at least 4 empty character slots.
L91C5:  BCC +                   ;Have 4 empty slots been found? If so, branch to continue.
L91C7:  RTS                     ;Else exit.

L91C8:* LDA #CLS_UNCHOSEN       ;
L91CA:  STA Ch1Class            ;
L91CC:  STA Ch2Class            ;Clear the character classes of the 4 characters.
L91CE:  STA Ch3Class            ;
L91D0:  STA Ch4Class            ;

L91D2:  STA RdyMdSelection      ;Indicate no character chosen.
L91D4:  JSR InitPPU             ;($990C)Initialize the PPU.

L91D7:  LDA #SCREEN_OFF         ;Turn the screen off.
L91D9:  STA CurPPUConfig1       ;

L91DB:  LDA #$04                ;
L91DD:  STA TXTXPos             ;Text will be located at tile coords X,Y=4,4.
L91DF:  LDA #$04                ;
L91E1:  STA TXTYPos             ;

L91E3:  LDA #$14                ;
L91E5:  STA TXTClrCols          ;Clear 20 columns and 1 row for the text string.
L91E7:  LDA #$01                ;
L91E9:  STA TXTClrRows          ;

L91EB:  LDA #$0F                ;SELECT CHARACTERS text.
L91ED:  STA TextIndex           ;
L91EF:  JSR ShowTextString      ;($995C)Show a text string on the screen.

L91F2:  LDA #$04                ;
L91F4:  STA WndXPos             ;Window will be located at tile coords X,Y=4,13
L91F6:  LDA #$0C                ;
L91F8:  STA WndYPos             ;

L91FA:  LDA #$16                ;
L91FC:  STA WndWidth            ;Window will be 22 tiles wide and 16 tiles tall.
L91FE:  LDA #$10                ;
L9200:  STA WndHeight           ;

L9202:  JSR DrawWndBrdr         ;($97A9)Draw window border.

LoadRMScreen:
L9205:  LDA #SCREEN_OFF         ;Turn the screen off.
L9207:  STA CurPPUConfig1       ;

L9209:  LDA #$E0                ;Hide upper 8 sprites.
L920B:  STA HideUprSprites      ;

L920D:  LDA Increment0          ;Get lower 3 bits of counter. used to select character pair.
L920F:  AND #$07                ;
L9211:  CMP #$06                ;Is value above 5?
L9213:  BCC +                   ;If not, branch.

L9215:  SEC                     ;Subtract 4 to put number in useful range.
L9216:  SBC #$04                ;

L9218:* TAX                     ;Use number as index into table below.
L9219:  STX RdyMadeIndex        ;

L921B:  LDA RMTextTbl,X         ;Get text corresponding to ready-made character pair.
L921E:  PHA                     ;

L921F:  TXA                     ;
L9220:  ASL                     ;*2. 2 bytes per entry in RMClassTbl.
L9221:  TAX                     ;

L9222:  LDA RMClassTbl,X        ;
L9225:  STA RdyMadeChr1         ;Get the first ready-made character to choose from.
L9227:  STA RdyMadeChr1_        ;

L9229:  LDA RMClassTbl+1,X      ;
L922C:  STA RdyMadeChr2         ;Get the second ready-made character to choose from.
L922E:  STA RdyMadeChr2_        ;

L9230:  LDA #CLS_UNCHOSEN       ;Only 2 characters on ready-made screen. Make sure only 2 appear.
L9232:  STA Ch1StClass          ;
L9234:  STA Ch2StClass          ;
L9236:  JSR LdLgCharTiles1      ;($C009)Load tiles to display large character class portraits.

L9239:  LDA #PPU_NT0_UB         ;
L923B:  STA NTDestAdrUB         ;First character will appear on name table 0
L923D:  LDA #PPU_NT0_LB+$C4     ;starting at address $20C4.
L923F:  STA NTDestAdrLB         ;

L9241:  LDA #$B8                ;Tile patterns for character 1 will appear in the
L9243:  STA PTStartTile         ;pattern table starting at tile $B8.
L9245:  JSR LoadLargeChar       ;($96CD)Load large image of the character class.

L9248:  LDA #PPU_NT0_UB         ;
L924A:  STA NTDestAdrUB         ;Second character will appear on name table 0
L924C:  LDA #PPU_NT0_LB+$D2     ;starting at address $20D2.
L924E:  STA NTDestAdrLB         ;

L9250:  LDA #$DC                ;Tile patterns for character 2 will appear in the
L9252:  STA PTStartTile         ;pattern table starting at tile $DC.
L9254:  JSR LoadLargeChar       ;($96CD)Load large image of the character class.

L9257:  LDA #$40                ;Prepare to load 64 bytes into PPU buffer.
L9259:  JSR UpdatePPUBufSize    ;($99A8)Update number of bytes filled in PPU buffer.

L925C:  LDA #PPU_AT0_UB         ;
L925E:  STA PPUBufBase,X        ;
L9261:  INX                     ;Prepare to write data to attribute table 0.
L9262:  LDA #PPU_AT0_LB         ;
L9264:  STA PPUBufBase,X        ;

L9267:  INX                     ;Move to next empty slot in PPU buffer.
L9268:  LDY #$00                ;Zero out index.

L926A:* LDA RdyMadeATDat,Y      ;
L926D:  STA PPUBufBase,X        ;
L9270:  INX                     ;Write 64 bytes of attribute table data to the PPU buffer.
L9271:  INY                     ;
L9272:  CPY #$40                ;
L9274:  BNE -                   ;

L9276:  JSR ChkPPUBufFull       ;($99D5)Check if PPU buffer is full and set indicator if necessary.

L9279:  LDA #>AttribBuffer      ;
L927B:  STA PPUDstPtrUB         ;Set destination pointer to first character's palette data.
L927D:  LDA #<AttribBuffer+$04  ;
L927F:  STA PPUDstPtrLB         ;

L9281:  LDA RdyMadeChr1         ;Get class for first character.
L9283:  JSR LoadLgChrPalettes   ;($9701)Load palette and attrib table data for character portrait.

L9286:  LDA #>AttribBuffer      ;
L9288:  STA PPUDstPtrUB         ;Set destination pointer to second character's palette data.
L928A:  LDA #<AttribBuffer+$08  ;
L928C:  STA PPUDstPtrLB         ;

L928E:  LDA RdyMadeChr2         ;Get class for second character.
L9290:  TAX                     ;
L9291:  JSR LoadLgChrAttrib     ;(L970F)Load attribute table data for 2nd character portrait.

L9294:  PLA                     ;Restore text index for the character pair from the stack.
L9295:  STA TextIndex           ;

L9297:  LDA #$00                ;Set selector sprite to first character by default.
L9299:  STA RdyMdSelection      ;

L929B:  LDA #$06                ;
L929D:  STA TXTXPos             ;Text will be located at tile coords X,Y=6,14.
L929F:  LDA #$0E                ;
L92A1:  STA TXTYPos             ;

L92A3:  LDA #$13                ;
L92A5:  STA TXTClrCols          ;Clear 19 columns and 7 rows for the text string.
L92A7:  LDA #$07                ;
L92A9:  STA TXTClrRows          ;

L92AB:  JSR ShowTextString      ;($995C)Show a text string on the screen.

L92AE:  LDA #SCREEN_ON          ;Turn the screen on.
L92B0:  STA CurPPUConfig1       ;

L92B2:  JSR RMUpdateSelector    ;($9352)Update position of selector sprite on ready-made screen.

RMInputLoop:
L92B5:  JSR GetInputPress       ;($98EE)Get input button press and account for retrigger.
L92B8:  LDA Pad1Input           ;

L92BA:  CMP #BTN_RIGHT          ;Was the right button pressed?
L92BC:  BNE RMChkLeft           ;If not, branch to check the next button.

L92BE:  LDA RdyMdSelection      ;Is second character already selected?
L92C0:  BNE RMInputLoop         ;If so, branch to ignore button press.

L92C2:  INC RdyMdSelection      ;Move selector to second character.
L92C4:  JSR RMUpdateSelector    ;($9352)Update position of selector sprite on ready-made screen.
L92C7:  JMP RMInputLoop         ;($92B5)Input loop for ready-made character selection.

RMChkLeft:
L92CA:  CMP #BTN_LEFT           ;Was the left button pressed?
L92CC:  BNE RMChkUp             ;If not, branch to check the next button.

L92CE:  LDA RdyMdSelection      ;Is the first character selected?
L92D0:  CMP #$01                ;If so, branch to ignore input.
L92D2:  BNE RMInputLoop         ;

L92D4:  DEC RdyMdSelection      ;Move selector to first character.
L92D6:  JSR RMUpdateSelector    ;($9352)Update position of selector sprite on ready-made screen.
L92D9:  JMP RMInputLoop         ;($92B5)Input loop for ready-made character selection.

RMChkUp:
L92DC:  CMP #BTN_UP             ;Was the up button pressed?
L92DE:  BNE RMChkDn             ;If not, branch to check the next button.

L92E0:  LDA RdyMdSelection      ;
L92E2:  CMP #$03                ;
L92E4:  BEQ +                   ;This code has no function.
L92E6:  CMP #$04                ;
L92E8:  BEQ +                   ;

L92EA:  JMP RMInputLoop         ;($92B5)Input loop for ready-made character selection.

L92ED:* DEC RdyMdSelection      ;Should never get here.
L92EF:  JSR RMUpdateSelector    ;($9352)Update position of selector sprite on ready-made screen.
L92F2:  JMP RMInputLoop         ;($92B5)Input loop for ready-made character selection.

RMChkDn:
L92F5:  CMP #BTN_DOWN           ;Was the down button pressed?
L92F7:  BNE RMChkA              ;If not, branch to check the next button.

L92F9:  LDA RdyMdSelection      ;
L92FB:  CMP #$02                ;
L92FD:  BEQ +                   ;This code has no function.
L92FF:  CMP #$03                ;
L9301:  BEQ +                   ;

L9303:  JMP RMInputLoop         ;($92B5)Input loop for ready-made character selection.

L9306:* INC RdyMdSelection      ;Should never get here.
L9308:  JSR RMUpdateSelector    ;($9352)Update position of selector sprite on ready-made screen.
L930B:  JMP RMInputLoop         ;($92B5)Input loop for ready-made character selection.

RMChkA:
L930E:  CMP #BTN_A              ;Was A button pressed?
L9310:  BEQ +                   ;If so, branch to process button press.

L9312:  JMP RMChkB              ;($9344)Check if B button was pressed.

L9315:* LDX RdyMadeChr1         ;Assume character 1 wwas chosen?
L9317:  LDA RdyMdSelection      ;Was character 1 chosen?
L9319:  BEQ +                   ;If so, branch.

L931B:  LDX RdyMadeChr2         ;Set character 2 as selected.

L931D:* LDY #$00                ;Zero out the indexes.

L931F:* LDA ChClasses,Y         ;Is current character slot open?
L9322:  CMP #CHR_EMPTY_SLOT     ;If so, branch.
L9324:  BEQ RMSlotFound         ;

L9326:  INY                     ;Have 4 character slots been checked?
L9327:  CPY #$04                ;If not, branch to check the next one.
L9329:  BNE -                   ;

L932B:  CLC                     ;Could not find an open slot for the new character.
L932C:  RTS                     ;

RMSlotFound:
L932D:  TXA                     ;Store the chosen class of the character to fill the slot.
L932E:  STA ChClasses,Y         ;

L9331:  CPY #$03                ;Have all 4 characters been set?
L9333:  BEQ RMChrsComplete      ;If so, branch to finish ready-made characters.

L9335:  JSR RMUpdateSelector    ;($9352)Update position of selector sprite on ready-made screen.

L9338:  LDA #CLS_UNCHOSEN       ;Prepare to choose a new pair of characters to display.
L933A:  STA RdyMdSelection      ;

L933C:  JMP LoadRMScreen        ;($9205)Show the ready-made character screen.

RMChrsComplete:
L933F:  JSR SetPremadeChrs      ;($9379)Save the selected 4 characters in the player's save game.

L9342:  CLC                     ;Indicate 4 characters successfully created and exit.
L9343:  RTS                     ;

RMChkB:
L9344:  CMP #BTN_B              ;Was B button pressed?If so, branch to process input.
L9346:  BEQ +                   ;Else jump to ignore other inputs.
L9348:  JMP RMInputLoop         ;($92B5)Input loop for ready-made character selection.

L934B:* LDA #CLS_UNCHOSEN       ;Prepare to choose a new pair of characters to display.
L934D:  STA RdyMdSelection      ;
L934F:  JMP LoadRMScreen        ;($9205)Show the ready-made character screen.

;----------------------------------------------------------------------------------------------------

RMUpdateSelector:
L9352:  LDA RdyMdSelection      ;
L9354:  ASL                     ;*2. 2 bytes for X,Y sprite coordinates.
L9355:  TAX                     ;

L9356:  LDA RdyMadeTbl,X        ;
L9359:  STA SpriteBuffer        ;Update Y position of selection sprite.
L935C:  LDA RdyMadeTbl+1,X      ;
L935F:  STA SpriteBuffer+3      ;Update X position of selection sprite.
L9362:  RTS                     ;

;----------------------------------------------------------------------------------------------------

;The following table contains the Y,X coordinates of the selector sprite on the ready-made
;screen. The player can select 1 of 2 characters.

RdyMadeTbl:
L9363:  .byte $70, $28
L9365:  .byte $70, $90

;----------------------------------------------------------------------------------------------------

;The following table contains the text indexes for the approprate pairs of characters
;displayed on the ready-made screen. each entyr below corresponds to the entry pair
;in RMClassTbl

RMTextTbl:
L9367:  .byte $10               ;FIGHTER RANGER text.
L9368:  .byte $11               ;CLERIC DRUID text.
L9369:  .byte $12               ;THIEF ILLUSIONIST text.
L936A:  .byte $13               ;WIZARD ALCHEMIST text.
L936B:  .byte $14               ;PALADIN LARK text.
L936C:  .byte $15               ;FIGHTER BARBARIAN text.

;----------------------------------------------------------------------------------------------------

;The following table is the class pairs that show up when creating ready-made characters.

RMClassTbl:
L936D:  .byte CLS_FIGHTER, CLS_RANGER
L936F:  .byte CLS_CLERIC,  CLS_DRUID
L9371:  .byte CLS_THIEF,   CLS_ILLUSIONIST
L9373:  .byte CLS_WIZARD,  CLS_ALCHEMIST
L9375:  .byte CLS_PALADIN, CLS_LARK
L9377:  .byte CLS_FIGHTER, CLS_BARBARIAN

;----------------------------------------------------------------------------------------------------

SetPremadeChrs:
L9379: LDA #$00                 ;Zero out the character counter.
L937B: STA GenByte30            ;

SetPremadeLoop:
L937D: LDA GenByte30            ;
L937F: ASL                      ;Get index to next character pointer.
L9380: TAX                      ;

L9381: LDA PosChrPtrLB,X        ;
L9383: STA SGCharPtrLB          ;Get a pointer to the character data in the selected save game.
L9385: LDA PosChrPtrUB,X        ;
L9387: STA SGCharPtrUB          ;

L9389: LDX GenByte30            ;Get the class of the current character.
L938B: LDA Ch1Class,X           ;

L938D: ASL                      ;
L938E: ASL                      ;*8. 8 bytes per row in PremadeChrTbl below.
L938F: ASL                      ;
L9390: TAX                      ;

L9391: LDA PremadeChrTbl,X      ;
L9394: LDY #CHR_CLASS           ;
L9396: STA (CrntChrPtr),Y       ;
L9398: INX                      ;
L9399: LDA PremadeChrTbl,X      ;
L939C: LDY #CHR_RACE            ;
L939E: STA (CrntChrPtr),Y       ;
L93A0: INX                      ;
L93A1: LDA PremadeChrTbl,X      ;
L93A4: LDY #CHR_STR             ;
L93A6: STA (CrntChrPtr),Y       ;
L93A8: INX                      ;Copy the data row from the table
L93A9: LDA PremadeChrTbl,X      ;below into the character data slot.
L93AC: LDY #CHR_DEX             ;
L93AE: STA (CrntChrPtr),Y       ;
L93B0: INX                      ;
L93B1: LDA PremadeChrTbl,X      ;
L93B4: LDY #CHR_INT             ;
L93B6: STA (CrntChrPtr),Y       ;
L93B8: INX                      ;
L93B9: LDA PremadeChrTbl,X      ;
L93BC: LDY #CHR_WIS             ;
L93BE: STA (CrntChrPtr),Y       ;

L93C0: INC GenByte30            ;Have the 4 ready-made characters been
L93C2: LDA GenByte30            ;transferred into the player's save game?
L93C4: CMP #$04                 ;If not, branch to copy another's character
L93C6: BNE SetPremadeLoop       ;data into the save game.
L93C8: RTS                      ;

;----------------------------------------------------------------------------------------------------

;The following table contains the stats of the ready-made characters. The first 2 bytes
;are the character's class and race. The following 4 bytes are the character's strength,
;dexterity, intelligence and wisdom, respectively. The last 2 bytes are unused.

PremadeChrTbl:
L93C9:  .byte CLS_FIGHTER,     RC_DWARF,  25, 15, 05, 05, $00, $00
L93D1:  .byte CLS_CLERIC,      RC_DWARF,  05, 15, 05, 25, $00, $00
L93D9:  .byte CLS_WIZARD,      RC_FUZZY,  05, 15, 25, 05, $00, $00
L93E1:  .byte CLS_THIEF,       RC_DWARF,  15, 25, 05, 05, $00, $00
L93E9:  .byte CLS_PALADIN,     RC_BOBBIT, 25, 15, 05, 05, $00, $00
L93F1:  .byte CLS_BARBARIAN,   RC_DWARF,  25, 15, 05, 05, $00, $00
L93F9:  .byte CLS_LARK,        RC_ELF,    25, 15, 05, 05, $00, $00
L9401:  .byte CLS_ILLUSIONIST, RC_FUZZY,  05, 25, 05, 15, $00, $00
L9409:  .byte CLS_DRUID,       RC_BOBBIT, 05, 05, 20, 20, $00, $00
L9411:  .byte CLS_ALCHEMIST,   RC_ELF,    05, 20, 20, 05, $00, $00
L9419:  .byte CLS_RANGER,      RC_HUMAN,  25, 15, 05, 05, $00, $00                                             

;----------------------------------------------------------------------------------------------------

Find4EmptySlots:
L9421:  LDA SGDatPtrLB          ;
L9423:  STA ChrDatPtrLB_        ;
L9425:  LDA SGDatPtrUB          ;Get a pointer to the character data in the selected save game.
L9427:  STA ChrDatPtrUB_        ;
L9429:  INC ChrDatPtrUB_        ;

L942B:  LDA #$00                ;
L942D:  STA GenByte30           ;Zero out the character data index and empty slot counter.
L942F:  STA GenByte2E           ;

ChkEmptyLoop:
L9431:  LDY #$00                ;
L9433:  LDA (ChrDatPtr_),Y      ;Is the current character slot empty?
L9435:  CMP #CHR_EMPTY_SLOT     ;If so, branch.
L9437:  BEQ EmptySlotFound      ;

ChkNextEmpty:
L9439:  CLC                     ;
L943A:  LDA ChrDatPtrLB_        ;
L943C:  ADC #$40                ;
L943E:  STA ChrDatPtrLB_        ;Increment the pointer to the next character slot.
L9440:  LDA ChrDatPtrUB_        ;
L9442:  ADC #$00                ;
L9444:  STA ChrDatPtrUB_        ;

L9446:  INC GenByte30           ;
L9448:  LDA GenByte30           ;Have all 20 character slots been checked?
L944A:  CMP #$14                ;If not, branch to check another one.
L944C:  BNE ChkEmptyLoop        ;

L944E:  SEC                     ;4 slots not found.
L944F:  RTS                     ;

EmptySlotFound:
L9450:  LDA GenByte2E           ;
L9452:  CLC                     ;Calculate index to current character in the save game($10-$13).
L9453:  ADC #$10                ;
L9455:  TAY                     ;

L9456:  LDA GenByte30           ;Store the index of the empty character slot.
L9458:  STA (SGDatPtr),Y        ;

L945A:  LDA GenByte2E           ;
L945C:  ASL                     ;*2. Pointers are 2 bytes.
L945D:  TAX                     ;

L945E:  LDA ChrDatPtrLB_        ;
L9460:  STA PosChrPtrLB,X       ;Save the pointer to the character slot.
L9462:  LDA ChrDatPtrUB_        ;
L9464:  STA PosChrPtrUB,X       ;

L9466:  INC GenByte2E           ;
L9468:  LDA GenByte2E           ;Has a total of 4 empty slots been found?
L946A:  CMP #$04                ;If not, branch to find another empty slot.
L946C:  BNE ChkNextEmpty        ;

L946E:  CLC                     ;4 slots found.
L946F:  RTS                     ;

;----------------------------------------------------------------------------------------------------

Discard:
L9470:  JSR InitPPU             ;($990C)Initialize the PPU.

L9473:  LDA #$02                ;
L9475:  STA TXTXPos             ;Text will be located at tile coords X,Y=2,4.
L9477:  LDA #$04                ;
L9479:  STA TXTYPos             ;

L947B:  LDA #$1C                ;
L947D:  STA TXTClrCols          ;Clear 28 columns and 1 row for the text string.
L947F:  LDA #$01                ;
L9481:  STA TXTClrRows          ;

L9483:  LDA #$1B                ;DISCARDS THE CHARACTER text.
L9485:  STA TextIndex           ;
L9487:  JSR ShowTextString      ;($995C)Show a text string on the screen.

L948A:  LDX SGDatPtrLB          ;
L948C:  STX SGCharPtrLB         ;
L948E:  LDX SGDatPtrUB          ;Get a pointer to the base address of the save game character data.
L9490:  INX                     ;
L9491:  STX SGCharPtrUB         ;

L9493:  JSR ShowCharList        ;($99DF)Show the list of character is the current save game file.

L9496:  LDA #$10
L9498:  STA TXTXPos
L949A:  LDA #$1A
L949C:  STA TXTYPos

L949E:  LDA #$0A
L94A0:  STA TXTClrCols
L94A2:  LDA #$01
L94A4:  STA TXTClrRows

L94A6:  LDA #$08                ;END text.
L94A8:  STA TextIndex           ;
L94AA:  JSR ShowTextString      ;($995C)Show a text string on the screen.

L94AD:  LDA #$30
L94AF:  STA SpriteBuffer
L94B2:  LDA #$20
L94B4:  STA SpriteBuffer+3
L94B7:  LDA #$00
L94B9:  STA ValidGamesFlags
L94BB:  LDX #$00
L94BD:  LDY #$00
L94BF:  JSR GetInputPress       ;($98EE)Get input button press and account for retrigger.
L94C2:  LDA ValidGamesFlags
L94C4:  BNE L9524

L94C6:  LDA Pad1Input
L94C8:  CMP #$01
L94CA:  BNE L94DC

L94CC:  CPX #$01
L94CE:  BNE L94D3

L94D0:  JMP L94BF
L94D3:  INX
L94D4:  LDA #$98
L94D6:  STA $7303
L94D9:  JMP L94BF

L94DC:  CMP #$02
L94DE:  BNE L94F0
L94E0:  CPX #$00
L94E2:  BNE L94E7
L94E4:  JMP L94BF
L94E7:  DEX
L94E8:  LDA #$20
L94EA:  STA $7303
L94ED:  JMP L94BF
L94F0:  CMP #$08
L94F2:  BNE L950A
L94F4:  CPY #$00
L94F6:  BNE L94FB
L94F8:  JMP L94BF
L94FB:  DEY
L94FC:  TYA
L94FD:  ASL
L94FE:  ASL
L94FF:  ASL
L9500:  ASL
L9501:  CLC
L9502:  ADC #$30
L9504:  STA SpriteBuffer
L9507:  JMP L94BF
L950A:  CMP #$04
L950C:  BNE L9524
L950E:  CPY #$09
L9510:  BNE L9515
L9512:  JMP L94BF
L9515:  INY
L9516:  TYA
L9517:  ASL
L9518:  ASL
L9519:  ASL
L951A:  ASL
L951B:  CLC
L951C:  ADC #$30
L951E:  STA SpriteBuffer
L9521:  JMP L94BF
L9524:  LDA Pad1Input
L9526:  CMP #$80
L9528:  BEQ L952D
L952A:  JMP L9649
L952D:  LDA ValidGamesFlags
L952F:  BEQ L9535
L9531:  CLC
L9532:  RTS
L9533:  SEC
L9534:  RTS

L9535:  STX $19
L9537:  STY $18
L9539:  LDA $19
L953B:  BEQ L953F
L953D:  LDA #$0A
L953F:  CLC
L9540:  ADC $18
L9542:  STA $2A
L9544:  STA $B1
L9546:  CLC
L9547:  ADC #$01
L9549:  STA $30
L954B:  LDA #$00
L954D:  STA $29
L954F:  LSR $2A
L9551:  ROR $29
L9553:  LSR $2A
L9555:  ROR $29
L9557:  CLC
L9558:  LDA SGCharPtrLB
L955A:  ADC $29
L955C:  STA $29
L955E:  LDA SGCharPtrUB
L9560:  ADC $2A
L9562:  STA $2A
L9564:  LDY #$00
L9566:  LDA ($29),Y
L9568:  CMP #$FF
L956A:  BNE L9573
L956C:  LDY $18
L956E:  LDX $19
L9570:  JMP L94BF
L9573:  LDA $2A
L9575:  PHA
L9576:  LDA $29
L9578:  PHA

L9579:  LDA #$0E
L957B:  STA $2A
L957D:  LDA #$0A
L957F:  STA $29

L9581:  LDA #$0A
L9583:  STA $2E
L9585:  LDA #$0A
L9587:  STA $2D

L9589:  JSR DrawWndBrdr         ;($97A9)Draw window border.

L958C:  PLA
L958D:  STA $29
L958F:  PLA
L9590:  STA $2A
L9592:  LDY #$00
L9594:  LDX #$00
L9596:  LDA ($29),Y
L9598:  STA TextBuffer,X
L959B:  INY
L959C:  INX
L959D:  CPX #$05
L959F:  BNE L9596
L95A1:  LDA #$FD
L95A3:  STA TextBuffer,X
L95A6:  INX
L95A7:  LDY #$06
L95A9:  LDA ($29),Y
L95AB:  TAY
L95AC:  LDA $96B2,Y
L95AF:  STA TextBuffer,X
L95B2:  INX
L95B3:  LDY #$05
L95B5:  LDA ($29),Y
L95B7:  TAY
L95B8:  LDA $96BD,Y
L95BB:  STA TextBuffer,X
L95BE:  INX
L95BF:  LDY #$06
L95C1:  LDA ($29),Y
L95C3:  TAY
L95C4:  LDA $96C2,Y
L95C7:  STA TextBuffer,X
L95CA:  INX
L95CB:  LDA #$FF
L95CD:  STA TextBuffer,X
L95D0:  LDA $2A
L95D2:  PHA
L95D3:  LDA $29
L95D5:  PHA
L95D6:  LDA #$10
L95D8:  STA TXTXPos
L95DA:  LDA #$0C
L95DC:  STA TXTYPos
L95DE:  LDA #$06
L95E0:  STA TXTClrCols
L95E2:  LDA #$02
L95E4:  STA TXTClrRows
L95E6:  LDA #TXT_DBL_SPACE
L95E8:  STA TextIndex
L95EA:  JSR ShowTextString      ;($995C)Show a text string on the screen.

L95ED:  LDA #$10
L95EF:  STA TXTXPos
L95F1:  LDA #$10
L95F3:  STA TXTYPos
L95F5:  LDA #$07
L95F7:  STA TXTClrCols
L95F9:  LDA #$02
L95FB:  STA TXTClrRows
L95FD:  LDA #$28
L95FF:  STA TextIndex
L9601:  JSR ShowTextString      ;($995C)Show a text string on the screen.

L9604:  PLA
L9605:  STA $29
L9607:  PLA
L9608:  STA $2A
L960A:  LDX #$00

L960C:  LDA #$90
L960E:  STA SpriteBuffer
L9611:  LDA $96B0,X
L9614:  STA SpriteBuffer+3
L9617:  JSR GetInputPress       ;($98EE)Get input button press and account for retrigger.
L961A:  LDA Pad1Input
L961C:  CMP #$02
L961E:  BEQ L9632
L9620:  CMP #$01
L9622:  BEQ L963A
L9624:  CMP #$80
L9626:  BNE L960C
L9628:  CPX #$00
L962A:  BNE L962F
L962C:  JSR L9695
L962F:  JMP Discard             ;($9470)Show discard character screen.

L9632:  CPX #$00
L9634:  BEQ L960C
L9636:  DEX
L9637:  JMP L960C
L963A:  CPX #$01
L963C:  BEQ L960C
L963E:  INX
L963F:  JMP L960C
L9642:  LDY $18
L9644:  LDX $19
L9646:  JMP L94BF
L9649:  CMP #$20
L964B:  BEQ L9650
L964D:  JMP L94BF

L9650:  INC ValidGamesFlags
L9652:  LDA ValidGamesFlags
L9654:  CMP #$01
L9656:  BNE L965C
L9658:  LDA #$02
L965A:  STA ValidGamesFlags
L965C:  CMP #$03
L965E:  BNE L967D
L9660:  LDA #$00
L9662:  STA ValidGamesFlags
L9664:  LDA #$20
L9666:  CPX #$00
L9668:  BEQ L966C
L966A:  LDA #$98
L966C:  STA $7303
L966F:  TYA
L9670:  ASL
L9671:  ASL
L9672:  ASL
L9673:  ASL
L9674:  CLC
L9675:  ADC #$30
L9677:  STA SpriteBuffer
L967A:  JMP L94BF
L967D:  LDA #$D0
L967F:  STA SpriteBuffer
L9682:  LDA ValidGamesFlags
L9684:  CMP #$01
L9686:  BEQ L968D
L9688:  LDA #$A8
L968A:  JMP L968F
L968D:  LDA #$78
L968F:  STA $7303
L9692:  JMP L94BF
L9695:  LDY #$00
L9697:  LDA #$FF
L9699:  STA ($29),Y
L969B:  LDY #$10
L969D:  LDA (SGDatPtr),Y
L969F:  CMP $B1
L96A1:  BEQ L96AA
L96A3:  INY
L96A4:  CPY #$14
L96A6:  BNE L969D
L96A8:  CLC
L96A9:  RTS
L96AA:  LDA #$FF
L96AC:  STA (SGDatPtr),Y
L96AE:  CLC
L96AF:  RTS

;----------------------------------------------------------------------------------------------------

L96B0:  .byte $78, $98

;              M    F    M    M    F    M    F    F    M    M    M
l96B2:  .byte $96, $8F, $96, $96, $8F, $96, $8F, $8F, $96, $96, $96

;              H    E    D    B    F
L96BD:  .byte $91, $8E, $8D, $8B, $8F

;              F    C    W    T    P    B    L    I    D    A    R
L96C2:  .byte $8F, $8C, $A0, $9D, $99, $8B, $95, $92, $8D, $8A, $9B

;----------------------------------------------------------------------------------------------------

LoadLargeChar:
L96CD:  LDA #$06                ;Prepare to load 6 rows of data into the PPU buffer.
L96CF:  STA GenByte2E           ;

LoadLargeCharLoop:
L96D1:  LDA #$06                ;Prepare to load 6 payload bytes into PPU buffer.
L96D3:  JSR UpdatePPUBufSize    ;($99A8)Update number of bytes filled in PPU buffer.

L96D6:  LDA GenPtr29UB          ;
L96D8:  STA PPUBufBase,X        ;
L96DB:  INX                     ;Load the PPU destination address into the buffer.
L96DC:  LDA GenPtr29LB          ;
L96DE:  STA PPUBufBase,X        ;

L96E1:  INX                     ;Prepare to load 6 tile indexes into the PPU buffer.
L96E2:  LDY #$06                ;

L96E4:* LDA GenByte2D           ;Get current tile index and load it into the PPU buffer.
L96E6:  STA PPUBufBase,X        ;

L96E9:  INC GenByte2D           ;Increment to the next tile as they are in order.
L96EB:  INX                     ;

L96EC:  DEY                     ;Have all 6 tile indexes been loaded into the PPU buffer?
L96ED:  BNE -                   ;If not, branch to load another one.

L96EF:  CLC                     ;
L96F0:  LDA GenPtr29LB          ;
L96F2:  ADC #$20                ;
L96F4:  STA GenPtr29LB          ;Advance to the next row on the screen.
L96F6:  LDA GenPtr29UB          ;
L96F8:  ADC #$00                ;
L96FA:  STA GenPtr29UB          ;

L96FC:  DEC GenByte2E           ;Does another row of the large character image need to be loaded?
L96FE:  BNE LoadLargeCharLoop   ;If so, branch to do another row.
L9700:  RTS                     ;

;----------------------------------------------------------------------------------------------------

LoadLgChrPalettes:
L9701:  TAX                     ;Index to attribute table byte.
L9702:  LDY #$00                ;Zero out the index.

L9704:* LDA LgChrPalDat,Y       ;
L9707:  STA AttribBuffer,Y      ;
L970A:  INY                     ;Copy character palette data into the buffer.
L970B:  CPY #$20                ;
L970D:  BNE -                   ;

LoadLgChrAttrib:
L970F:  LDA LgChrAtribTbl,X     ;Get attribute table byte for selected character.

L9712:  ASL                     ;*4. 4 bytes of palette data per portrait.
L9713:  ASL                     ;

L9714:  CLC                     ;
L9715:  ADC #<SnglChrPalData    ;
L9717:  STA PPUSrcPtrLB         ;Get pointer to palette data for portrait.
L9719:  LDA #$00                ;
L971B:  ADC #>SnglChrPalData    ;
L971D:  STA PPUSrcPtrUB         ;

L971F:  LDY #$00                ;Zero out the index.

L9721:* LDA (PPUSrcPtr),Y       ;
L9723:  STA (PPUDstPtr),Y       ;
L9725:  INY                     ;Load the 4 bytes of palette data for this portrait.
L9726:  CPY #$04                ;
L9728:  BNE -                   ;

L972A:  LDA #>AttribBuffer      ;
L972C:  STA PPUPyLdPtrUB        ;Prepare to transfer the contents of the
L972E:  LDA #<AttribBuffer      ;attribute table buffer into the PPU buffer.
L9730:  STA PPUPyLdPtrLB        ;

L9732:  JSR LoadPPUPalData      ;($9772)Load palette data into PPU buffer.
L9735:  RTS                     ;

;----------------------------------------------------------------------------------------------------

;The following table contains the attribute bits to apply to large character portraits.
;There are 11 values in the table the index into the table is the character class value.

LgChrAtribTbl:
L9736:  .byte $00, $03, $00, $01, $03, $01, $01, $03, $00, $00, $01
L9741:  .byte $00

;The below data is used to replace the palette data for the second group of data
;when displaying a single character portrait. Only 4 bits are accessed.

SnglChrPalData:
L9742:  .byte $0F, $30, $11, $36, $0F, $06, $15, $26, $0F, $30, $12, $36, $0F, $30, $15, $36

;Palette data loaded when showing large character class portraits.

LgChrPalDat:
L9752:  .byte $0F, $30, $11, $36, $0F, $06, $15, $26, $0F, $30, $11, $36, $0F, $30, $15, $36
L9762:  .byte $0F, $30, $11, $36, $0F, $06, $15, $26, $0F, $30, $12, $36, $0F, $30, $15, $36

;----------------------------------------------------------------------------------------------------

LoadPPUPalData:
L9772:  LDA #$20                ;Prepare to load 32 payload bytes into PPU buffer.
L9774:  JSR UpdatePPUBufSize    ;($99A8)Update number of bytes filled in PPU buffer.

L9777:  LDA #PPU_PAL_UB         ;
L9779:  STA PPUBufBase,X        ;
L977C:  INX                     ;Store base address of palettes in the buffer.
L977D:  LDA #PPU_PAL_LB         ;
L977F:  STA PPUBufBase,X        ;

L9782:  LDY #$00                ;
L9784:* LDA (PPUPyLdPtr),Y      ;
L9786:  INX                     ;
L9787:  STA PPUBufBase,X        ;Copy 32 bytes of palette data into PPU buffer.
L978A:  INY                     ;
L978B:  CPY #$20                ;
L978D:  BNE -                   ;

L978F:  LDA #$01                ;Prepare to load 1 payload byte into PPU buffer.
L9791:  JSR UpdatePPUBufSize    ;($99A8)Update number of bytes filled in PPU buffer.

L9794:  LDA #$00                ;
L9796:  STA PPUBufBase,X        ;
L9799:  INX                     ;Set PPU destination address to $0000.
L979A:  LDA #$00                ;
L979C:  STA PPUBufBase,X        ;

L979F:  INX                     ;
L97A0:  LDA #$00                ;Store an empty byte in the buffer.
L97A2:  STA PPUBufBase,X        ;
L97A5:  JSR ChkPPUBufFull       ;($99D5)Check if PPU buffer is full and set indicator if necessary.
L97A8:  RTS                     ;

;----------------------------------------------------------------------------------------------------

DrawWndBrdr:
L97A9:  LDA WndXPos
L97AB:  STA $19
L97AD:  LDA WndYPos
L97AF:  STA $2A

L97B1:  LDA #$00
L97B3:  STA $29

L97B5:  LSR $2A
L97B7:  ROR $29
L97B9:  LSR $2A
L97BB:  ROR $29
L97BD:  LSR $2A
L97BF:  ROR $29

L97C1:  CLC
L97C2:  LDA $19
L97C4:  ADC $29
L97C6:  STA $29

L97C8:  LDA #$20
L97CA:  ADC $2A
L97CC:  STA $2A

L97CE:  LDA $2E
L97D0:  STA $2C
L97D2:  LDA $2D
L97D4:  STA $2B

L97D6:  LDA $2E
L97D8:  JSR UpdatePPUBufSize    ;($99A8)Update number of bytes filled in PPU buffer.

L97DB:  LDA $2A
L97DD:  STA PPUBufBase,X
L97E0:  LDA $29
L97E2:  INX
L97E3:  STA PPUBufBase,X
L97E6:  LDA #BRDR_TOP_LT
L97E8:  INX
L97E9:  STA PPUBufBase,X
L97EC:  DEC WndRowRemain
L97EE:  DEC WndRowRemain
L97F0:  BEQ TopBrdrLast

TopBrdrLoop:
L97F2:  LDA #BRDR_TOP
L97F4:  INX
L97F5:  STA PPUBufBase,X
L97F8:  DEC WndRowRemain
L97FA:  BNE TopBrdrLoop

TopBrdrLast:
L97FC:  LDA #BRDR_TOP_RT
L97FE:  INX
L97FF:  STA PPUBufBase,X
L9802:  LDA $2C
L9804:  STA $2E
L9806:  DEC $2D

L9808:  CLC
L9809:  LDA $29
L980B:  ADC #$20
L980D:  STA $29

L980F:  LDA $2A
L9811:  ADC #$00
L9813:  STA $2A

L9815:  LDA $2E
L9817:  JSR UpdatePPUBufSize    ;($99A8)Update number of bytes filled in PPU buffer.
L981A:  DEC $2D
L981C:  BEQ L984C

L981E:  LDA $2A
L9820:  STA PPUBufBase,X
L9823:  INX
L9824:  LDA $29
L9826:  STA PPUBufBase,X
L9829:  INX
L982A:  LDA #BRDR_LT
L982C:  STA PPUBufBase,X
L982F:  DEC WndRowRemain
L9831:  DEC WndRowRemain
L9833:  BEQ L983F

L9835:  LDA #$00
L9837:  INX
L9838:  STA PPUBufBase,X
L983B:  DEC $2E
L983D:  BNE L9835

L983F:  INX
L9840:  LDA #BRDR_RT
L9842:  STA PPUBufBase,X
L9845:  LDA $2C
L9847:  STA $2E
L9849:  JMP L9808

L984C:  LDA $2A
L984E:  STA PPUBufBase,X
L9851:  INX
L9852:  LDA $29
L9854:  STA PPUBufBase,X
L9857:  LDA $2B
L9859:  STA $2D
L985B:  LDA #BRDR_BTM_LT
L985D:  INX
L985E:  STA PPUBufBase,X
L9861:  DEC $2E
L9863:  DEC $2E
L9865:  BEQ L9871

BtmBrdrLoop:
L9867:  LDA #BRDR_BTM
L9869:  INX
L986A:  STA PPUBufBase,X
L986D:  DEC $2E
L986F:  BNE BtmBrdrLoop

L9871:  INX
L9872:  LDA #BRDR_BTM_RT
L9874:  STA PPUBufBase,X
L9877:  LDA $2C
L9879:  STA $2E
L987B:  JSR ChkPPUBufFull       ;($99D5)Check if PPU buffer is full and set indicator if necessary.

L987E:  LDA #$00
L9880:  STA DisSpriteAnim
L9882:  RTS

;----------------------------------------------------------------------------------------------------

BinToBCD:
L9883:  PHA                     ;Save A on the stack before beginning.

L9884:  LDA #TP_ZERO            ;
L9886:  STA BCDOutput0          ;
L9888:  STA BCDOutput1          ;Set all the output digits to zero.
L988A:  STA BCDOutput2          ;
L988C:  STA BCDOutput3          ;

L988E:* SEC                     ;
L988F:  LDA BinInputLB          ;
L9891:  SBC #$E8                ;
L9893:  STA BinInputLB          ;Keep subtracting 1,000 until number goes negative.
L9895:  LDA BinInputUB          ;
L9897:  SBC #$03                ;
L9899:  STA BinInputUB          ;
L989B:  BCC +                   ;

L989D:  INC BCDOutput0          ;Increment thousands digit for each subtrct loop.
L989F:  JMP -                   ;

L98A2:* CLC                     ;
L98A3:  LDA BinInputLB          ;
L98A5:  ADC #$E8                ;
L98A7:  STA BinInputLB          ;Undo last 1,000 subtract to put number positive again.
L98A9:  LDA BinInputUB          ;
L98AB:  ADC #$03                ;
L98AD:  STA BinInputUB          ;

L98AF:* SEC                     ;
L98B0:  LDA BinInputLB          ;
L98B2:  SBC #$64                ;
L98B4:  STA BinInputLB          ;Keep subtracting 100 until number goes negative.
L98B6:  LDA BinInputUB          ;
L98B8:  SBC #$00                ;
L98BA:  STA BinInputUB          ;
L98BC:  BCC +                   ;

L98BE:  INC BCDOutput1          ;Increment hundreds digit for each subtrct loop.
L98C0:  JMP -                   ;

L98C3:* CLC                     ;
L98C4:  LDA BinInputLB          ;
L98C6:  ADC #$64                ;
L98C8:  STA BinInputLB          ;Undo last 100 subtract to put number positive again.
L98CA:  LDA BinInputUB          ;
L98CC:  ADC #$00                ;
L98CE:  STA BinInputUB          ;

L98D0:* SEC                     ;
L98D1:  LDA BinInputLB          ;
L98D3:  SBC #$0A                ;Keep subtracting 100 until number goes negative.
L98D5:  STA BinInputLB          ;
L98D7:  BCC +                   ;

L98D9:  INC BCDOutput2          ;Increment tens digit for each subtrct loop.
L98DB:  JMP -                   ;

L98DE:* CLC                     ;
L98DF:  LDA BinInputLB          ;Undo last 10 subtract to put number positive again.
L98E1:  ADC #$0A                ;
L98E3:  STA BinInputLB          ;

L98E5:  CLC                     ;
L98E6:  LDA BCDOutput3          ;Add remainng value to the ones digit.
L98E8:  ADC BinInputLB          ;
L98EA:  STA BCDOutput3          ;

L98EC:  PLA                     ;Restore A from the stack and return.
L98ED:  RTS                     ;

;----------------------------------------------------------------------------------------------------

GetInputPress:
L98EE:  TXA                     ;
L98EF:  PHA                     ;Save X and Y on the stack.
L98F0:  TYA                     ;
L98F1:  PHA                     ;

L98F2:  LDY Pad1Input           ;Get most recent button presses.

L98F4:  LDX #$0A                ;Prepare to wait 10 frames to wait for a retrigger event.
L98F6:  LDA Increment0          ;

L98F8:* CMP Increment0          ;Wait for 1 frame.
L98FA:  BEQ -                   ;

L98FC:  LDA InputChange
L98FE:  BNE FinishInputPresses
L9900:  CPY Pad1Input
L9902:  BNE L98F2

L9904:  DEX
L9905:  BNE L98F6

FinishInputPresses:
L9907:  PLA                     ;
L9908:  TAY                     ;
L9909:  PLA                     ;Restore X and Y from the stack.
L990A:  TAX                     ;
L990B:  RTS                     ;

;----------------------------------------------------------------------------------------------------

InitPPU:
L990C:  LDA #SCREEN_OFF         ;Turn the screen off.
L990E:  STA CurPPUConfig1       ;

L9910:  CLC                     ;
L9911:  LDA Increment0          ;Prepare to wait 2 frames.
L9913:  ADC #$02                ;

L9915:* CMP Increment0          ;Have 2 frames passed?
L9917:  BNE -                   ;If not, branch to wait more.

L9919:  LDA #$D4                ;Hide the upper 10 sprites.
L991B:  STA HideUprSprites      ;

L991D:  LDY #$00                ;Prepare to hide all sprites off the bottom of the screen.
L991F:  LDA #SPRT_HIDE          ;

L9921:* STA SpriteBuffer,Y      ;
L9924:  INY                     ;
L9925:  INY                     ;Have all the sprites been hidden?
L9926:  INY                     ;If not, branch to hide another one.
L9927:  INY                     ;
L9928:  BNE -                   ;

L992A:  LDY #$00
L992C:  LDA #$00

L992E:* STA BlocksBuffer,Y
L9931:  INY
L9932:  BNE -

L9934:  LDA #$74
L9936:  STA $2A
L9938:  LDA #$00
L993A:  STA $29
L993C:  LDA #$20
L993E:  STA $2C
L9940:  LDA #$00
L9942:  STA $2B
L9944:  LDA #$01
L9946:  STA $2E
L9948:  LDA #$00
L994A:  STA $2D
L994C:* JSR LoadPPU1            ;($C006)Load values into PPU.

L994F:  INC $2C
L9951:  LDA $2C
L9953:  CMP #$24
L9955:  BNE -

L9957:  LDA #$1E
L9959:  STA CurPPUConfig1
L995B:  RTS

;----------------------------------------------------------------------------------------------------

ShowTextString:
L995C:  LDA GenByte2C
L995E:  PHA
L995F:  LDA GenByte2B
L9961:  PHA
L9962:  LDA GenByte2F
L9964:  PHA
L9965:  LDA GenByte27
L9967:  PHA
L9968:  LDA GenByte26
L996A:  PHA

L996B:  LDA TextIndex
L996D:  CMP #TXT_DBL_SPACE
L996F:  BEQ +
L9971:  CMP #TXT_SNGL_SPACE
L9973:  BEQ +

L9975:  JSR LoadTxtStringBuf    ;($998F)Load text string into text buffer.
L9978:  LDA #$FF                ;Set the index to the very end of the text buffer.
L997A:  STA TextIndex           ;
L997C:* JSR DisplayText1        ;($C003)Display text on screen.

L997F:  PLA
L9980:  STA GenByte26
L9982:  PLA
L9983:  STA GenByte27
L9985:  PLA
L9986:  STA GenByte2F
L9988:  PLA
L9989:  STA GenByte2B
L998B:  PLA
L998C:  STA GenByte2C
L998E:  RTS

;----------------------------------------------------------------------------------------------------

LoadTxtStringBuf:
L998F:  ASL                     ;*2. Pointers are 2 bbytes.
L9990:  TAX                     ;

L9991:  LDA StringPtrTbl,X      ;
L9994:  STA TXTSrcPtrLB         ;Get pointer to the text string.
L9996:  LDA StringPtrTbl+1,X    ;
L9999:  STA TXTSrcPtrUB         ;

L999B:  LDY #$00                ;Zero out the index.

L999D:* LDA (TXTSrcPtr),Y       ;
L999F:  STA TextBuffer,Y        ;Load letters into text buffer.
L99A2:  INY                     ;
L99A3:  CMP #TXT_END            ;Has the end of the string been reached?
L99A5:  BNE -                   ;If not, branch to get another letter.
L99A7:  RTS                     ;

;----------------------------------------------------------------------------------------------------

UpdatePPUBufSize:
L99A8:  PHA                     ;Save number of bytes to add to buffer.

L99A9:  CLC                     ;Get new buffer length.
L99AA:  ADC PPUBufLength        ;Will buffer overflow?
L99AD:  BCS +                   ;If so, branch to wait for buffer to clear first.

L99AF:  TAX                     ;Store a copy of A in X.
L99B0:  TXA                     ;

L99B1:  CMP #$60                ;Does buffer have 96 or mire bytes in it?
L99B3:  BCC BufferNotFull       ;If not, branch. Buffer has room.

L99B5:* LDA #$01                ;Buffer full. Wait for PPU update and buffer to clear.
L99B7:  STA UpdatePPU           ;

L99B9:* LDA UpdatePPU           ;Wait until the PPU has been updated and buffer emptied.
L99BB:  BNE -                   ;

BufferNotFull:
L99BD:  LDA #$00                ;Room in buffer. no need to wait yet.
L99BF:  STA UpdatePPU           ;

L99C1:  LDX PPUBufLength        ;Get buffer length and add 1 for next open slot.
L99C4:  INX                     ;

L99C5:  CLC                     ;
L99C6:  PLA                     ;Add 2 to string length to account for 2 byte PPU address.
L99C7:  ADC #$02                ;

L99C9:  STA PPUBufBase,X        ;Store the length of this PPU string in the buffer.

L99CC:  INX                     ;Increment index to next open buffer slot.

L99CD:  SEC                     ;
L99CE:  ADC PPUBufLength        ;Update PPU buffer used size and exit.
L99D1:  STA PPUBufLength        ;
L99D4:  RTS                     ;

;----------------------------------------------------------------------------------------------------

ChkPPUBufFull:
L99D5:  LDA PPUBufLength        ;Does PPU buffer have less than128 bytes in it?
L99D8:  BEQ +                   ;If so, branch to exit. Room for more data.

L99DA:  LDA #$01                ;
L99DC:  STA UpdatePPU           ;Indicate PPU buffer is full and needs to be emptied.
L99DE:* RTS                     ;

;----------------------------------------------------------------------------------------------------

ShowCharList:
L99DF:  LDA #$06                ;
L99E1:  STA ChrRow              ;Start at character 1 at tile row 6 on the screen.
L99E3:  LDA #$01                ;
L99E5:  STA ChrNum              ;

ChrListLoop:
L99E7:  LDX #$00                ;Zero out the index.

L99E9:  LDA ChrNum              ;Prepare to get data for current selected character.
L99EB:  JSR Show1Chr            ;($9A22)Show name, sex, class, race and condition of 1 character.

L99EE:  LDY #$02                ;Add 2 blanks spaces to text string.
L99F0:  JSR BlankChars          ;($9AB7)Add blank characters(spaces) to line of text.

L99F3:  LDA ChrNum              ;
L99F5:  CLC                     ;Prepare to get data for character in second column(11-20).
L99F6:  ADC #$0A                ;
L99F8:  JSR Show1Chr            ;($9A22)Show name, sex, class, race and condition of 1 character.

L99FB:  JSR ShowChrDatString    ;($9A07)Show character data string on the screen.

L99FE:  INC ChrNum              ;Increment to next character.
L9A00:  LDA ChrNum              ;

L9A02:  CMP #$0B                ;Have 10 rows of character data been shown?
L9A04:  BCC ChrListLoop         ;If not, loop to get the next 2 characters(1 row).
L9A06:  RTS                     ;

;----------------------------------------------------------------------------------------------------

ShowChrDatString:
L9A07:  LDA #$02                ;Character data row always starts at tile position X=2.
L9A09:  STA TXTXPos             ;

L9A0B:  LDA ChrRow              ;Set the tile Y position of the character data.
L9A0D:  STA TXTYPos             ;

L9A0F:  CLC                     ;
L9A10:  ADC #$02                ;Next character row is 2 tiles down.
L9A12:  STA ChrRow              ;

L9A14:  LDA #$1C                ;
L9A16:  STA TXTClrCols          ;Clear 28 columns and 1 row for the text string.
L9A18:  LDA #$01                ;
L9A1A:  STA TXTClrRows          ;

L9A1C:  LDA #TXT_DBL_SPACE      ;Indicate buffer is already populated, double spaced.
L9A1E:  JSR ShowTextString      ;($995C)Show a text string on the screen.
L9A21:  RTS

Show1Chr:
L9A22:  PHA                     ;Store the current character number on the stack(1-20).

L9A23:  LDY #$00                ;Zero out pointer upper byte.
L9A25:  STY ChrDatPtrUB         ;

L9A27:  SEC                     ;Subtract 1 from the character number.
L9A28:  SBC #$01                ;

L9A2A:  ASL                     ;
L9A2B:  ASL                     ;Shift character number into upper nibble and carry bit.
L9A2C:  ASL                     ;
L9A2D:  ASL                     ;

L9A2E:  ROL ChrDatPtrUB         ;ChrNum-1 is 5 bits of data ($00-$13).
L9A30:  ASL                     ;At this point, bit 4 is in carry and other bits in upper nibble.
L9A31:  ROL ChrDatPtrUB         ;Upper 3 bits of ChrNum-1 is in 3 LSBs of ChrDatPtrUB.
L9A33:  ASL                     ;Bit 1 and 0 are in 2 MSBs in Accum($00, $40, $80, $C0).
L9A34:  ROL ChrDatPtrUB         ;

L9A36:  CLC                     ;Add lower byte of calculated offset to base character pointer
L9A37:  ADC SGCharPtrLB         ;to get final lower pointer address byte. Lower byte of base
L9A39:  STA ChrDatPtrLB         ;pointer is always zero so lower byte always=offset.

L9A3B:  LDA ChrDatPtrUB         ;Add calculated offset to upper byte of character data base address
L9A3D:  ADC SGCharPtrUB         ;to get upper byte of this characters data pointer.
L9A3F:  STA ChrDatPtrUB         ;

L9A41:  PLA                     ;Is current character 0-9?
L9A42:  CMP #$0A                ;
L9A44:  BCC +                   ;If so, branch.

L9A46:  SBC #$0A                ;Minus 10 from character number.
L9A48:  INY                     ;Increment 1st digit. Will be either 1 or 2.

L9A49:* CMP #$0A                ;Is character number 0-9?
L9A4B:  BCC +                   ;If so, branch.

L9A4D:  LDA #$00                ;Second digit in character number is 0.
L9A4F:  INY                     ;First digit in character number is 2.

L9A50:* PHA                     ;Save second digit of character number on stack.

L9A51:  LDA NumTbl,Y            ;
L9A54:  STA TextBuffer,X        ;Put first digit of character number in text string(0-2).
L9A57:  INX                     ;

L9A58:  PLA                     ;Restore second digit of character number from stack.

L9A59:  TAY                     ;
L9A5A:  LDA NumTbl,Y            ;Put second digit of character number in text string(0-9).
L9A5D:  STA TextBuffer,X        ;
L9A60:  INX                     ;

L9A61:  LDA #TXT_BLANK          ;
L9A63:  STA TextBuffer,X        ;Add a blank space to the text string.
L9A66:  INX                     ;

L9A67:  LDY #$00                ;Zero out the index.

L9A69:* LDA (ChrDatPtr),Y       ;Is the current character slot empty?
L9A6B:  CMP #CHR_EMPTY_SLOT     ;If so, branch to print blank characters.
L9A6D:  BEQ ChrEmptySlot        ;

L9A6F:  STA TextBuffer,X        ;
L9A72:  INX                     ;Get the 5 letters in the character's name.
L9A73:  INY                     ;
L9A74:  INC ChrUnused2F         ;
L9A76:  CPY #$05                ;Have all the letters been put into the text string?
L9A78:  BNE -                   ;If not, branch to get another letter.

L9A7A:  LDA #TXT_BLANK          ;
L9A7C:  STA TextBuffer,X        ;Add a blank space to the text string.
L9A7F:  INX                     ;

L9A80:  LDY #CHR_CLASS          ;
L9A82:  LDA (ChrDatPtr),Y       ;
L9A84:  TAY                     ;Add an M or F to the text string indicating the character's sex.
L9A85:  LDA ChrSexTbl,Y         ;The sex is based on the character class. The classes have fixed
L9A88:  STA TextBuffer,X        ;genders.
L9A8B:  INX                     ;

L9A8C:  LDY #CHR_RACE           ;
L9A8E:  LDA (ChrDatPtr),Y       ;
L9A90:  TAY                     ;Put a letter in the text string indicating the character's race.
L9A91:  LDA ChrRcaeTbl,Y        ;
L9A94:  STA TextBuffer,X        ;
L9A97:  INX                     ;

L9A98:  LDY #CHR_CLASS          ;
L9A9A:  LDA (ChrDatPtr),Y       ;
L9A9C:  TAY                     ;Put a letter in the text string indicating the character's class.
L9A9D:  LDA ChrClassTbl,Y       ;
L9AA0:  STA TextBuffer,X        ;
L9AA3:  INX                     ;

L9AA4:  LDY #CHR_COND           ;
L9AA6:  LDA (ChrDatPtr),Y       ;
L9AA8:  TAY                     ;
L9AA9:  LDA ChrStatTbl,Y        ;Put a letter in text string indicating the character's condition.
L9AAC:  STA TextBuffer,X        ;
L9AAF:  INX                     ;
L9AB0:  RTS                     ;

ChrEmptySlot:
L9AB1:  LDY #$0A                ;Empty character slot. Store 10 blank spaces in text string.
L9AB3:  JSR BlankChars          ;($9AB7)Add blank characters(spaces) to line of text.
L9AB6:  RTS                     ;

;----------------------------------------------------------------------------------------------------

BlankChars:
L9AB7:  LDA #TXT_BLANK          ;
L9AB9:* STA TextBuffer,X        ;
L9ABC:  INX                     ;Add a series of blank spaces to the text string. The
L9ABD:  DEY                     ;number of blank spaces is stored in Y.
L9ABE:  BNE -                   ;
L9AC0:  RTS                     ;

;----------------------------------------------------------------------------------------------------

;The following table is the sex of the 11 classes. The index into the table is the class and
;the value in the table is the sex.

ChrSexTbl:
;              M    F    M    M    F    M    F    F    M    M    M
L9AC1:  .byte $96, $8F, $96, $96, $8F, $96, $8F, $8F, $96, $96, $96

;The following table is the single character class of each of the 11 classes.

ChrClassTbl:
;              F    C    W    T    P    B    L    I    D    A    R
L9ACC:  .byte $8F, $8C, $A0, $9D, $99, $8B, $95, $92, $8D, $8A, $9B

;The following table is the single character race of each of the 5 races.

ChrRcaeTbl:
;              H    E    D    B    F
L9AD7:  .byte $91, $8E, $8D, $8B, $8F

;The following table is the single character condition of each of the 5 conditions.

ChrStatTbl:
;              G    P    S    D    A
L9ADC:  .byte $90, $99, $9C, $8D, $8A

;Tile indexes to the numbers 0-9.

NumTbl:
;              0    1    2    3    4    5    6    7    8    9
L9AE1:  .byte $38, $39, $3A, $3B, $3C, $3D, $3E, $3F, $40, $41

;----------------------------------------------------------------------------------------------------

LoadClassSprites:
L9AEB:  LDY #$00                ;Zero out the index.

L9AED:* LDA ClassSpritesDat,Y   ;
L9AF0:  STA SpriteBuffer+4,Y    ;Load all the sprite data so show 11 characters on screen
L9AF3:  INY                     ;representing the 11 different classes.
L9AF4:  CPY #NUM_CLASSES*16     ;
L9AF6:  BNE -                   ;

L9AF8:  LDA #CLS_PALADIN        ;
L9AFA:  STA Ch1Class            ;
L9AFC:  STA Ch2Class            ;Set a default class for the 4 player characters - Paladin.
L9AFE:  STA Ch3Class            ;
L9B00:  STA Ch4Class            ;
L9B02:  RTS                     ;

;----------------------------------------------------------------------------------------------------

LoadLBs:
L9B03:  LDY #$00                ;Zero out index.

L9B05:* LDA LBSpritesDat,Y      ;
L9B08:  STA SpriteBuffer+$C4,Y  ;
L9B0B:  INY                     ;Load the 3 Lord British sprites on the screen.
L9B0C:  CPY #$30                ;
L9B0E:  BNE -                   ;

L9B10:  LDA #CLS_PALADIN        ;
L9B12:  STA Ch1Class            ;
L9B14:  STA Ch2Class            ;Set default classes of ready made characters to paladin.
L9B16:  STA Ch3Class            ;
L9B18:  STA Ch4Class            ;
L9B1A:  RTS                     ;

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

;The following data is loaded into name table 0 and attribute table 0 when a new party is formed
;and the Lord British scene is shown. This is the background graphics for that scene.

LBRoomNTDat:
L9B1B:  .byte $AB, $AC, $AB, $AC, $AB, $AC, $AB, $AC, $AB, $AC, $AB, $AC, $AB, $AC, $AB, $AC, $AB, $AC, $AB, $AC, $AB, $AC, $AB, $AC, $AB, $AC, $AB, $AC, $AB, $AC, $AB, $AC
L9B3B:  .byte $B8, $B9, $B8, $B9, $B8, $B9, $B8, $B9, $B8, $B9, $B8, $B9, $B8, $B9, $B8, $B9, $B8, $B9, $B8, $B9, $B8, $B9, $B8, $B9, $B8, $B9, $B8, $B9, $B8, $B9, $B8, $B9
L9B5B:  .byte $AB, $AC, $AB, $AC, $AB, $AC, $C6, $C7, $AB, $AC, $AB, $AC, $AB, $AC, $AD, $AE, $AF, $B0, $AB, $AC, $AB, $AC, $AB, $AC, $C6, $C7, $AB, $AC, $AB, $AC, $AB, $AC
L9B7B:  .byte $B8, $B9, $B8, $B9, $B8, $B9, $D2, $D3, $B8, $B9, $B8, $B9, $B8, $B9, $BA, $00, $00, $BB, $B8, $B9, $B8, $B9, $B8, $B9, $D2, $D3, $B8, $B9, $B8, $B9, $B8, $B9
L9B9B:  .byte $AB, $AC, $AB, $AC, $AB, $AC, $AB, $AC, $AB, $AC, $AB, $AC, $AB, $AC, $C4, $00, $00, $C5, $AB, $AC, $AB, $AC, $AB, $AC, $AB, $AC, $AB, $AC, $AB, $AC, $AB, $AC
L9BBB:  .byte $B8, $B9, $B8, $B9, $B8, $B9, $B8, $B9, $B8, $B9, $B8, $B9, $B8, $B9, $D0, $00, $00, $C5, $B8, $B9, $B8, $B9, $B8, $B9, $B8, $B9, $B8, $B9, $B8, $B9, $B8, $B9
L9BDB:  .byte $EC, $ED, $EC, $ED, $EC, $ED, $EC, $ED, $EC, $ED, $EC, $ED, $EE, $EF, $00, $00, $00, $00, $F0, $F1, $EC, $ED, $EC, $ED, $EC, $ED, $EC, $ED, $EC, $ED, $EC, $ED
L9BFB:  .byte $F4, $F5, $F4, $F5, $F4, $F5, $F4, $F5, $F4, $F5, $F4, $F5, $F6, $00, $00, $00, $00, $00, $00, $F7, $F4, $F5, $F4, $F5, $F4, $F5, $F4, $F5, $F4, $F5, $F4, $F5
L9C1B:  .byte $EC, $ED, $EC, $ED, $EC, $ED, $EC, $ED, $EC, $ED, $EE, $EF, $00, $00, $00, $00, $00, $00, $00, $00, $F0, $F1, $EC, $ED, $EC, $ED, $EC, $ED, $EC, $ED, $EC, $ED
L9C3B:  .byte $F4, $F5, $F4, $F5, $F4, $F5, $F4, $F5, $F4, $F5, $F6, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $F7, $F4, $F5, $F4, $F5, $F4, $F5, $F4, $F5, $F4, $F5
L9C5B:  .byte $EC, $ED, $EC, $ED, $EC, $ED, $EC, $ED, $EE, $EF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $F0, $F1, $EC, $ED, $EC, $ED, $EC, $ED, $EC, $ED
L9C7B:  .byte $F4, $F5, $F4, $F5, $F4, $F5, $F4, $F5, $F6, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $F7, $F4, $F5, $F4, $F5, $F4, $F5, $F4, $F5
L9C9B:  .byte $EC, $ED, $EC, $ED, $EC, $ED, $EE, $EF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $F0, $F1, $EC, $ED, $EC, $ED, $EC, $ED
L9CBB:  .byte $F4, $F5, $F4, $F5, $F4, $F5, $F6, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $F7, $F4, $F5, $F4, $F5, $F4, $F5
L9CDB:  .byte $EC, $ED, $EC, $ED, $EE, $EF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $F0, $F1, $EC, $ED, $EC, $ED
L9CFB:  .byte $F4, $F5, $F4, $F5, $F6, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $F7, $F4, $F5, $F4, $F5
L9D1B:  .byte $EC, $ED, $EE, $EF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $A6, $A7, $A8, $A9, $AA, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $F0, $F1, $EC, $ED
L9D3B:  .byte $F4, $F5, $F6, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $B3, $B4, $B5, $B6, $B7, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $F7, $F4, $F5
L9D5B:  .byte $EE, $EF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $BE, $BF, $C0, $C1, $C2, $C3, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $F0, $F1
L9D7B:  .byte $F6, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $CA, $CB, $CC, $CD, $CE, $CF, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $F7
L9D9B:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $D6, $D7, $D8, $D9, $DA, $DB, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9DBB:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $E0, $E1, $E2, $E3, $E4, $E5, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9DDB:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9DFB:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9E1B:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9E3B:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9E5B:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9E7B:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9E9B:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9EBB:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9EDB:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

LBRoomATDat:
L9EEB:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $A0, $A0, $A0, $20, $80, $A0, $A0, $A0
L9EFB:  .byte $AA, $AA, $2A, $0D, $06, $8A, $AA, $AA, $AA, $2A, $00, $00, $00, $00, $8A, $AA
L9F0B:  .byte $2A, $00, $00, $FF, $FF, $00, $00, $8A, $F0, $F0, $F0, $FF, $FF, $F0, $F0, $F0
L9F1B:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

;----------------------------------------------------------------------------------------------------

;Unused code from Bank B.
L9F2B:  .byte $C0, $29, $7C, $A8, $B9, $00, $04, $C9, $18, $F0, $0C, $C9, $1B, $F0, $08, $C9
L9F3B:  .byte $1C, $F0, $04, $C9, $1E, $D0, $09, $A5, $4E, $C9, $03, $D0, $40, $4C, $70, $9F
L9F4B:  .byte $A5, $4E, $C9, $03, $F0, $37, $C9, $04, $F0, $33, $C9, $08, $F0, $2F, $C9, $0C
L9F5B:  .byte $F0, $2B, $C9, $09, $F0, $27, $C9, $05, $D0, $06, $A5, $A8, $C9, $0C, $D0, $1D
L9F6B:  .byte $A5, $C0, $29, $7C, $A8, $18, $BD, $A3, $A0, $79, $02, $04, $29, $3F, $99, $02
L9F7B:  .byte $04, $18, $BD, $A4, $A0, $79, $03, $04, $29, $3F, $99, $03, $04, $A5, $C0, $29
L9F8B:  .byte $7C, $A8, $60, $68, $60, $8A, $48, $A2, $00, $A5, $4A, $38, $F9, $02, $04, $30
L9F9B:  .byte $02, $49, $FF, $C9, $F8, $20, $B9, $9F, $A5, $49, $38, $F9, $03, $04, $30, $04
L9FAB:  .byte $49, $FF, $69, $00, $C9, $F9, $20, $B9, $9F, $E0, $01, $68, $AA, $60, $10, $06
L9FBB:  .byte $C9, $C8, $30, $02, $A2, $FF, $60, $8A, $48, $A5, $4D, $48, $A9, $04, $85, $4D
L9FCB:  .byte $A2, $04, $BD, $00, $73, $4A, $4A, $4A, $4A, $18, $65, $49, $38, $E9, $07, $D9
L9FDB:  .byte $03, $04, $D0, $15, $BD, $03, $73, $4A, $4A, $4A, $4A, $18, $65, $4A, $38, $E9
L9FEB:  .byte $07, $D9, $02, $04, $D0, $03, $4C, $26, $A0, $8A, $18, $69, $10, $AA, $C6, $4D
L9FFB:  .byte $D0, $D0, $A2, $00, $BD

;----------------------------------------------------------------------------------------------------

DoStatusScreen:
LA000:  JSR InitPPU             ;($990C)Initialize the PPU.

LA003:  LDA #$00                ;Turn off the display.
LA005:  STA CurPPUConfig1       ;

LA007:  LDY #$06                ;
LA009:  LDA (Pos1ChrPtr),Y      ;
LA00B:  STA Ch1StClass          ;
LA00D:  LDA (Pos2ChrPtr),Y      ;
LA00F:  STA Ch2StClass          ;Get the classes for all 4 characters.
LA011:  LDA (Pos3ChrPtr),Y      ;
LA013:  STA Ch3StClass          ;
LA015:  LDA (Pos4ChrPtr),Y      ;
LA017:  STA Ch4StClass          ;

LA019:  JSR LdLgCharTiles1      ;($C009)Load tiles to display large character class portraits.

;Load character 1 large class portrait.
LA01C:  LDA #$20                ;
LA01E:  STA NTDestAdrUB         ;Image loaded onto NT 0 starting at X,Y=2,4.
LA020:  LDA #$82                ;
LA022:  STA NTDestAdrLB         ;

LA024:  LDA #$44                ;Image starts with tile pattern $44.
LA026:  STA PTStartTile         ;

LA028:  JSR LoadLargeChar       ;($96CD)Load large image of the character class.

;Load character 2 large class portrait.
LA02B:  LDA #$20                ;
LA02D:  STA NTDestAdrUB         ;Image loaded onto NT 0 starting at X,Y=9,4
LA02F:  LDA #$88                ;
LA031:  STA NTDestAdrLB         ;

LA033:  LDA #$68                ;Image starts with tile pattern $68.
LA035:  STA PTStartTile         ;

LA037:  JSR LoadLargeChar       ;($96CD)Load large image of the character class.

;Load character 3 large class portrait.
LA03A:  LDA #$20                ;
LA03C:  STA NTDestAdrUB         ;Image loaded onto NT 0 starting at X,Y=18,4
LA03E:  LDA #$92                ;
LA040:  STA NTDestAdrLB         ;

LA042:  LDA #$B8                ;Image starts with tile pattern $B8.
LA044:  STA PTStartTile         ;

LA046:  JSR LoadLargeChar       ;($96CD)Load large image of the character class.

;Load character 4 large class portrait.
LA049:  LDA #$20                ;
LA04B:  STA NTDestAdrUB         ;Image loaded onto NT 0 starting at X,Y=24,4
LA04D:  LDA #$98                ;
LA04F:  STA NTDestAdrLB         ;

LA051:  LDA #$DC                ;Image starts with tile pattern $DC.
LA053:  STA PTStartTile         ;

LA055:  JSR LoadLargeChar       ;($96CD)Load large image of the character class.

LA058:  LDY #$00                ;
LA05A:  LDA #$00                ;
LA05C:* STA AttribBuffer,Y      ;Clear out all 64 bytes of attribute table buffer.
LA05F:  INY                     ;
LA060:  CPY #$40                ;
LA062:  BNE -                   ;

;Load character 1 attribute table values.
LA064:  LDY #CHR_CLASS          ;Get class of character 1.
LA066:  LDA (Pos1ChrPtr),Y      ;

LA068:  TAX                     ;Get palette index for character portrait.
LA069:  LDA LgChrAtribTbl,X     ;

LA06C:  ASL                     ;
LA06D:  ASL                     ;*4. 4 bytes per attribute table data set.
LA06E:  TAX                     ;

LA06F:  LDA Chr13AttribTbl,X    ;
LA072:  STA AttribBuffer+$08    ;
LA075:  LDA Chr13AttribTbl+1,X  ;
LA078:  STA AttribBuffer+$09    ;Load Character 1 attribute table data into buffer.
LA07B:  LDA Chr13AttribTbl+2,X  ;
LA07E:  STA AttribBuffer+$10    ;
LA081:  LDA Chr13AttribTbl+3,X  ;
LA084:  STA AttribBuffer+$11    ;

;Load character 2 attribute table values.
LA087:  LDY #CHR_CLASS          ;Get class of character 2.
LA089:  LDA (Pos2ChrPtr),Y      ;

LA08B:  TAX                     ;Get palette index for character portrait.
LA08C:  LDA LgChrAtribTbl,X     ;

LA08F:  ASL                     ;
LA090:  ASL                     ;*4. 4 bytes per attribute table data set.
LA091:  TAX                     ;

LA092:  LDA Chr24AttribTbl,X    ;
LA095:  STA AttribBuffer+$0A    ;
LA098:  LDA Chr24AttribTbl+1,X  ;
LA09B:  STA AttribBuffer+$0B    ;Load Character 2 attribute table data into buffer.
LA09E:  LDA Chr24AttribTbl+2,X  ;
LA0A1:  STA AttribBuffer+$12    ;
LA0A4:  LDA Chr24AttribTbl+3,X  ;
LA0A7:  STA AttribBuffer+$13    ;

;Load character 3 attribute table values.
LA0AA:  LDY #CHR_CLASS          ;Get class of character 3.
LA0AC:  LDA (Pos3ChrPtr),Y      ;

LA0AE:  TAX                     ;Get palette index for character portrait.
LA0AF:  LDA LgChrAtribTbl,X     ;

LA0B2:  ASL                     ;
LA0B3:  ASL                     ;*4. 4 bytes per attribute table data set.
LA0B4:  TAX                     ;

LA0B5:  LDA Chr13AttribTbl,X    ;
LA0B8:  STA AttribBuffer+$0C    ;
LA0BB:  LDA Chr13AttribTbl+1,X  ;
LA0BE:  STA AttribBuffer+$0D    ;Load Character 3 attribute table data into buffer.
LA0C1:  LDA Chr13AttribTbl+2,X  ;
LA0C4:  STA AttribBuffer+$14    ;
LA0C7:  LDA Chr13AttribTbl+3,X  ;
LA0CA:  STA AttribBuffer+$15    ;

;Load character 4 attribute table values.
LA0CD:  LDY #CHR_CLASS          ;Get class of character 4.
LA0CF:  LDA (Pos4ChrPtr),Y      ;

LA0D1:  TAX                     ;Get palette index for character portrait.
LA0D2:  LDA LgChrAtribTbl,X     ;

LA0D5:  ASL                     ;
LA0D6:  ASL                     ;*4. 4 bytes per attribute table data set.
LA0D7:  TAX                     ;

LA0D8:  LDA Chr24AttribTbl,X    ;
LA0DB:  STA AttribBuffer+$0E    ;
LA0DE:  LDA Chr24AttribTbl+1,X  ;
LA0E1:  STA AttribBuffer+$0F    ;Load Character 4 attribute table data into buffer.
LA0E4:  LDA Chr24AttribTbl+2,X  ;
LA0E7:  STA AttribBuffer+$16    ;
LA0EA:  LDA Chr24AttribTbl+3,X  ;
LA0ED:  STA AttribBuffer+$17    ;

;Load attribute data into PPU buffer.
LA0F0:  LDA #$40                ;Prepare to load 64 bytes into PPU buffer.
LA0F2:  JSR UpdatePPUBufSize    ;($99A8)Update number of bytes filled in PPU buffer.

LA0F5:  LDA #PPU_AT0_UB         ;
LA0F7:  STA PPUBufBase,X        ;
LA0FA:  INX                     ;Set PPU pointer to the base address of attribute table 0.
LA0FB:  LDA #PPU_AT0_LB         ;
LA0FD:  STA PPUBufBase,X        ;
LA100:  INX                     ;

LA101:  LDY #$00                ;Zero out the index.

LA103:* LDA AttribBuffer,Y      ;
LA106:  STA PPUBufBase,X        ;
LA109:  INX                     ;Transfer 64 bytes of attribute table data to the PPU buffer.
LA10A:  INY                     ;
LA10B:  CPY #$40                ;
LA10D:  BNE -                   ;

LA10F:  JSR ChkPPUBufFull       ;($99D5)Check if PPU buffer is full and set indicator if necessary.

LA112:  LDA #>LgChrPalDat       ;
LA114:  STA PPUPyLdPtrUB        ;Prepare to load the large character portrait palettes.
LA116:  LDA #<LgChrPalDat       ;
LA118:  STA PPUPyLdPtrLB        ;

LA11A:  JSR LoadPPUPalData      ;($9772)Load palette data into PPU buffer.
LA11D:  JSR ShowChrStats        ;($A2ED)Show the 4 character's stats below their portraits.

LA120:  LDA #$1E                ;Turn on the display.
LA122:  STA CurPPUConfig1       ;

LA124:  LDA #$18                ;Set the Y pixel coord of the selector sprite Y=24.
LA126:  STA SpriteBuffer        ;

LA129:  LDA #$00                ;Set character 1 as the default selected character.
LA12B:  STA ChrStatSelect       ;

;Get user input.
StatLoop:
LA12D:  LDX ChrStatSelect       ;
LA12F:  LDA ChrStatXPosTbl,X    ;Set the X pixel coord of the selector sprite.
LA132:  STA SpriteBuffer+3      ;

StatInputLoop:
LA135:  LDA Increment0          ;
LA137:* CMP Increment0          ;Wait 1 frame.
LA139:  BEQ -                   ;

LA13B:  LDA InputChange         ;Wait for button release.
LA13D:  BEQ StatInputLoop       ;

LA13F:  LDA Pad1Input           ;Was the right button pressed?
LA141:  CMP #BTN_RIGHT          ;If not, branch to check other inputs.
LA143:  BNE StatChkLeft         ;

LA145:  INC ChrStatSelect       ;
LA147:  LDA ChrStatSelect       ;Increment selected character. Loop around if greater than 3.
LA149:  AND #$03                ;
LA14B:  STA ChrStatSelect       ;
LA14D:  JMP StatLoop            ;($A12D)Jump to update selected character.

StatChkLeft:
LA150:  CMP #BTN_LEFT           ;Was the left button pressed?
LA152:  BNE StatChkB            ;If not, branch to check other inputs.

LA154:  DEC ChrStatSelect       ;
LA156:  LDA ChrStatSelect       ;Decrement selected character. Loop around if less than 0.
LA158:  AND #$03                ;
LA15A:  STA ChrStatSelect       ;
LA15C:  JMP StatLoop            ;($A12D)Jump to update selected character.

StatChkB:
LA15F:  CMP #BTN_B              ;Was the B button pressed?
LA161:  BNE StatChkA            ;If so, exit status screen.
LA163:  RTS                     ;Else branch to check other inputs.

StatChkA:
LA164:  CMP #BTN_A              ;Was the A button pressed?
LA166:  BNE StatInputLoop       ;If not, branch to get next input.

;See individual character items.
LA168:  LDA ChrStatSelect       ;
LA16A:  ASL                     ;*2. Character addresses are 2 bytes.
LA16B:  TAX                     ;

LA16C:  LDA ChrPtrBaseLB,X      ;
LA16E:  STA CrntChrPtrLB        ;Get a pointer to the selected character's data.
LA170:  LDA ChrPtrBaseUB,X      ;
LA172:  STA CrntChrPtrUB        ;

LA174:  JSR InitPPU             ;($990C)Initialize the PPU.
LA177:  JSR LoadnAlphaNumMaps1  ;($C01E)Load character set and map tiles.

LA17A:  LDY #CHR_CLASS          ;
LA17C:  LDA (CrntChrPtr),Y      ;Get the character's class and store it in character 4 slot.
LA17E:  STA Ch4StClass          ;

LA180:  LDA #CLS_UNCHOSEN       ;
LA182:  STA Ch1StClass          ;Indicate the other characters are not active.
LA184:  STA Ch2StClass          ;
LA186:  STA Ch3StClass          ;

LA188:  JSR LdLgCharTiles1      ;($C009)Load tiles to display large character class portraits.
LA18B:  JSR StatLoad1Chr        ;($A28C)Load a single character's portrait.

LA18E:  LDA #$11                ;
LA190:  STA TXTXPos             ;Text will be located at tile coords X,Y=17,4.
LA192:  LDA #$04                ;
LA194:  STA TXTYPos             ;

LA196:  LDA #$0A                ;
LA198:  STA TXTClrCols          ;Clear 10 columns and 2 rows for the text string.
LA19A:  LDA #$02                ;
LA19C:  STA TXTClrRows          ;

LA19E:  LDA #$1C                ;WEAPON text.
LA1A0:  STA TextIndex           ;
LA1A2:  JSR ShowTextString      ;($995C)Show a text string on the screen.

LA1A5:  JSR Chr1stPage          ;($A3D3)Show marks and weapons status page.

LA1A8:  LDY #CHR_FLOWER         ;Does the character have a flower?
LA1AA:  LDA (CrntChrPtr),Y      ;
LA1AC:  BEQ PrepSelWeapon       ;If not, branch to skip showing flower text.

LA1AE:  LDA #$04                ;
LA1B0:  STA TXTXPos             ;Text will be located at tile coords X,Y=4,26.
LA1B2:  LDA #$1A                ;
LA1B4:  STA TXTYPos             ;

LA1B6:  LDA #$0A                ;
LA1B8:  STA TXTClrCols          ;Clear 10 columns and 1 row for the text string.
LA1BA:  LDA #$01                ;
LA1BC:  STA TXTClrRows          ;

LA1BE:  LDA #$26                ;FLOWER text.
LA1C0:  STA TextIndex           ;
LA1C2:  JSR ShowTextString      ;($995C)Show a text string on the screen.

PrepSelWeapon:
LA1C5:  LDA #SPRT_HIDE          ;Hide selectior sprite off bottom of screen.
LA1C7:  STA SpriteBuffer        ;

LA1CA:  JSR DoSelWeapon         ;($B5F8)Select equipped weapon.

LA1CD:  STA GenByte30           ;Is the selected weapon the mystic weapon?
LA1CF:  CMP #WPN_MYSTIC_W       ;
LA1D1:  BEQ ChrEquipWeapon      ;If so, branch to equip the weapon.

LA1D3:  LDY #CHR_CLASS          ;
LA1D5:  LDA (CrntChrPtr),Y      ;Get the highest allowable weapon for this character.
LA1D7:  TAX                     ;
LA1D8:  LDA ChrWeaponTbl,X      ;

LA1DB:  CMP GenByte30           ;Is the weapon being equipped equal or less than max weapon?
LA1DD:  BCS ChrEquipWeapon      ;If so, branch to equip weapon.

LA1DF:  BCC PrepSelWeapon       ;Weapon not equippable by character. Branch to not equip.

ChrEquipWeapon:
LA1E1:  LDY #CHR_EQ_WEAPON      ;
LA1E3:  LDA GenByte30           ;Equip selected weapon.
LA1E5:  STA (CrntChrPtr),Y      ;

LA1E7:  JSR InitPPU             ;($990C)Initialize the PPU.
LA1EA:  JSR StatLoad1Chr        ;($A28C)Load a single character's portrait.

LA1ED:  LDA #$11                ;
LA1EF:  STA TXTXPos             ;Text will be located at tile coords X,Y=17,4.
LA1F1:  LDA #$04                ;
LA1F3:  STA TXTYPos             ;

LA1F5:  LDA #$0A                ;
LA1F7:  STA TXTClrCols          ;Clear 10 columns and 2 rows for the text string.
LA1F9:  LDA #$02                ;
LA1FB:  STA TXTClrRows          ;

LA1FD:  LDA #$1D                ;ARMOR text.
LA1FF:  STA TextIndex           ;
LA201:  JSR ShowTextString      ;($995C)Show a text string on the screen.

LA204:  JSR Chr2ndPage          ;($A3ED)Show cards and armor status page.

PrepSelArmor:
LA207:  LDA #SPRT_HIDE          ;Hide selectior sprite off bottom of screen.
LA209:  STA SpriteBuffer        ;

LA20C:  JSR DoSelArmor          ;($B5E1)Select equipped armor.
LA20F:  STA GenByte30           ;

LA211:  LDA GenByte30           ;Is the selected armor the mystic armor?
LA213:  CMP #ARM_MYSTIC_A       ;
LA215:  BEQ ChrEquipArmor       ;If so, branch to equip the armor.

LA217:  LDY #CHR_CLASS          ;
LA219:  LDA (CrntChrPtr),Y      ;Get the highest allowable armor for this character.
LA21B:  TAX                     ;
LA21C:  LDA ChrArmorTbl,X       ;

LA21F:  CMP GenByte30           ;Is the armor being equipped equal or less than max armor?
LA221:  BCS ChrEquipArmor       ;If so, branch to equip armor.

LA223:  BCC PrepSelArmor        ;Armor not equippable by character. Branch to not equip.

ChrEquipArmor:
LA225:  LDA GenByte30           ;
LA227:  LDY #CHR_EQ_ARMOR       ;Equip selected armor.
LA229:  STA (CrntChrPtr),Y      ;

LA22B:  JMP DoStatusScreen      ;($A000)Show status screen on the display.

;----------------------------------------------------------------------------------------------------

;The following table is the 4 X positions of the selector sprite on the main
;character status screen.

ChrStatXPosTbl:
LA22E:  .byte $20, $50, $A0, $D0

;----------------------------------------------------------------------------------------------------

;Unused.
LA232:  .byte $30, $40, $50, $60, $70, $80, $90, $A0, $B0

;----------------------------------------------------------------------------------------------------

;The following 2 tables determine which weapons and armors each class can and cannot equip.
;There are 11 entries per table, one for each class. The class number is the index into each
;table. The weapon if the number in the table is less than the weapon/armor number, then the
;corresponding class cannot equip it. Since all characters can equip mystic items, they are
;not taken into account in the tables below.

ChrWeaponTbl:
LA23B:  .byte WPN_MYSTIC_W, WPN_MACE,     WPN_DAGGER,   WPN_SWORD
LA23F:  .byte WPN_MYSTIC_W, WPN_MYSTIC_W, WPN_MYSTIC_W, WPN_MACE
LA233:  .byte WPN_MACE,     WPN_DAGGER,   WPN_IRN_SWRD

ChrArmorTbl:
LA246:  .byte ARM_MYSTIC_A, ARM_BRONZE,  ARM_CLOTH, ARM_LEATHER
LA24A:  .byte ARM_IRON,     ARM_LEATHER, ARM_CLOTH, ARM_LEATHER
LA24E:  .byte ARM_CLOTH,    ARM_CLOTH,   ARM_DRAGON

;----------------------------------------------------------------------------------------------------

;Unused.
LA251:  .byte $A2, $00, $A5, $30, $D0, $01, $60, $B1, $99, $F0, $01, $E8, $C8, $C6, $30, $D0
LA261:  .byte $F6, $86, $30, $60, $A9, $00, $85, $19, $B1, $99, $F0, $02, $E6, $19, $C8, $CA
LA271:  .byte $D0, $F6, $60, $A2, $00, $A5, $30, $D0, $01, $60, $B1, $99, $F0, $04, $C6, $30
LA281:  .byte $F0, $05, $E8, $C8, $4C, $7B, $A2, $E8, $86, $30, $60

;----------------------------------------------------------------------------------------------------

StatLoad1Chr:
LA28C:  LDA #$20                ;
LA28E:  STA NTDestAdrUB         ;Prepare to load character portrait on name table 0 at X,Y=4,6.
LA290:  LDA #$C4                ;
LA292:  STA NTDestAdrLB         ;

LA294:  LDA #$DC                ;Prepare to load portrait statring at tile $DC.
LA296:  STA GenPtr2D            ;
LA298:  JSR LoadLargeChar       ;($96CD)Load large image of the character class.

LA29B:  LDA #$40                ;Prepare to load 64 bytes into PPU buffer.
LA29D:  JSR UpdatePPUBufSize    ;($99A8)Update number of bytes filled in PPU buffer.

LA2A0:  LDA #PPU_AT0_UB         ;
LA2A2:  STA PPUBufBase,X        ;
LA2A5:  INX                     ;Prepare to write data to attribute table 0.
LA2A6:  LDA #PPU_AT0_LB         ;
LA2A8:  STA PPUBufBase,X        ;

LA2AB:  INX                     ;Zero out index and counter.
LA2AC:  LDY #$00                ;

LA2AE:* LDA Chr1PtrtAtribDat,Y  ;
LA2B1:  STA PPUBufBase,X        ;
LA2B4:  INX                     ;Load 64 bytes of attribute table data into the PPU buffer.
LA2B5:  INY                     ;
LA2B6:  CPY #$40                ;
LA2B8:  BNE -                   ;

LA2BA:  JSR ChkPPUBufFull       ;($99D5)Check if PPU buffer is full and set indicator if necessary.

LA2BD:  LDA #>AttribBuffer      ;
LA2BF:  STA PPUDstPtrUB         ;Prepare to load 4 bytes of palette data into the PPU.
LA2C1:  LDA #<AttribBuffer+4    ;
LA2C3:  STA PPUDstPtrLB         ;

LA2C5:  LDY #CHR_CLASS          ;Get the ccharacter class so the proper palette data
LA2C7:  LDA (CrntChrPtr),Y      ;can be loaded into PPU.
LA2C9:  JSR LoadLgChrPalettes   ;($9701)Load palette data for individual character portraits.
LA2CC:  RTS                     ;

;----------------------------------------------------------------------------------------------------

;The attribute table data below if for the large portraits of the various character classes.
;The data in the Chr13AttribTbl is right justifies as characters 1 and 3 are right justified
;in their alignment on the name table with respect to the attribute table control bits.
;The Chr24AttribTblvhas the same type of data but it is left justified.

Chr13AttribTbl:
LA2CD:  .byte $00, $00, $00, $00
;0 0 | 0 0
;0 0 | 0 0   Used by:
;---------   Fighter, Wizard, Druid and Alchemist.
;0 0 | 0 0
;0 0 | 0 0

LA2D1:  .byte $44, $55, $04, $05
;0 1 | 1 1
;0 1 | 1 1   Used by:
;---------   Thief, Barbarian, Lark and Ranger.
;0 1 | 1 1
;0 0 | 0 0

LA2D5:  .byte $88, $AA, $08, $0A
;0 2 | 2 2
;0 2 | 2 2   Used by:
;---------   None.
;0 2 | 2 2
;0 0 | 0 0

LA2D9:  .byte $CC, $FF, $0C, $0F
;0 3 | 3 3
;0 3 | 3 3   Used by:
;---------   Cleric, Palladin, Illusionist.
;0 3 | 3 3
;0 0 | 0 0

Chr24AttribTbl:
LA2DD:  .byte $00, $00, $00, $00
;0 0 | 0 0
;0 0 | 0 0   Used by:
;---------   Fighter, Wizard, Druid and Alchemist.
;0 0 | 0 0
;0 0 | 0 0

LA2E1:  .byte $55, $11, $05, $01
;1 1 | 1 0
;1 1 | 1 0   Used by:
;---------   Thief, Barbarian, Lark and Ranger.
;1 1 | 1 0
;0 0 | 0 0

LA2E5:  .byte $AA, $22, $0A, $02
;2 2 | 2 0
;2 2 | 2 0   Used by:
;---------   None.
;2 2 | 2 0
;0 0 | 0 0

LA2E9:  .byte $FF, $33, $0F, $03
;3 3 | 3 0
;3 3 | 3 0   Used by:
;---------   Cleric, Palladin, Illusionist.
;3 3 | 3 0
;0 0 | 0 0

;----------------------------------------------------------------------------------------------------

ShowChrStats:
LA2ED:  LDX #$00                ;
LA2EF:* LDA StatsTxt,X          ;
LA2F2:  STA TextBuffer,X        ;Load STR DEX INT WIS MMP MHP EXP GOLD into the text buffer.
LA2F5:  INX                     ;This also loads a buch of unecessary stuff off screen.
LA2F6:  CPX #$41                ;
LA2F8:  BCC -                   ;

LA2FA:  LDA #$04                ;
LA2FC:  STA TXTClrCols          ;Clear 4 columns and 8 rows for the text string.
LA2FE:  LDA #$08                ;
LA300:  STA TXTClrRows          ;

LA302:  LDA #$0E                ;
LA304:  STA TXTXPos             ;Text will be located at tile coords X,Y=14,11.
LA306:  LDA #$0B                ;
LA308:  STA TXTYPos             ;

LA30A:  LDA #TXT_DBL_SPACE      ;Indicate buffer is already filled, double spaced.
LA30C:  STA TextIndex           ;
LA30E:  JSR ShowTextString      ;($995C)Show a text string on the screen.

LA311:  LDY #$00                ;Zero out the index.

GetStatsLoop:
LA313:  LDA StatsXPosTbl,Y      ;Set the column position of the numbers to display.
LA316:  STA TXTXPos             ;

LA318:  TYA                     ;
LA319:  ASL                     ;*2. Pointer is 2 bytes.
LA31A:  TAX                     ;

LA31B:  LDA ChrPtrBaseLB,X      ;
LA31D:  STA CrntChrPtrLB        ;Copy base address of character data to character pointer.
LA31F:  LDA ChrPtrBaseUB,X      ;
LA321:  STA CrntChrPtrUB        ;

LA323:  INY                     ;Prepare to move to next character.

LA324:  LDA #$0B                ;Set text tile Y coord to Y=11.
LA326:  STA TXTYPos             ;

LA328:  TYA                     ;Save next character on stack.
LA329:  PHA                     ;

LA32A:  JSR Show4ChrNums        ;($A334)Show the numerical stats of characters on status screen.

LA32D:  PLA                     ;Restore next character from stack.
LA32E:  TAY                     ;

LA32F:  CPY #$04                ;Has the stats from all 4 characters been displayed?
LA331:  BCC GetStatsLoop        ;If not, branch to get the stats of the next character.

LA333:  RTS                     ;The stats of all 4 characters are displayed. Exit.

;----------------------------------------------------------------------------------------------------

Show4ChrNums:
LA334:  LDX #$00                ;Start at top of the screen.

LA336:  LDY #CHR_STR            ;Get 2 digit strength value.
LA338:  JSR Txt2Digits          ;($A373)Convert byte to 2 base 10 digits.
LA33B:  LDY #CHR_DEX            ;Get 2 digit dexterity value.
LA33D:  JSR Txt2Digits          ;($A373)Convert byte to 2 base 10 digits.
LA340:  LDY #CHR_INT            ;Get 2 digit intelligence value.
LA342:  JSR Txt2Digits          ;($A373)Convert byte to 2 base 10 digits.
LA345:  LDY #CHR_WIS            ;Get 2 digit wisdom value.
LA347:  JSR Txt2Digits          ;($A373)Convert byte to 2 base 10 digits.
LA34A:  LDY #CHR_MAX_MP         ;Get 2 digit max magic points value.
LA34C:  JSR Txt2Digits          ;($A373)Convert byte to 2 base 10 digits.
LA34F:  LDY #CHR_MAX_HP         ;Get 4 digit max hit points value.
LA351:  JSR Txt4Digits          ;($A39A)Convert word to 4 base 10 digits.
LA354:  LDY #CHR_EXP            ;Get 4 digit experience points value.
LA356:  JSR Txt4Digits          ;($A39A)Convert word to 4 base 10 digits.
LA359:  LDY #CHR_GOLD           ;Get 4 digit gold value.
LA35B:  JSR Txt4Digits          ;($A39A)Convert word to 4 base 10 digits.

LA35E:  LDA #TXT_END            ;Add end of string indicator on the end of the text string.
LA360:  STA TextBuffer,X        ;

LA363:  LDA #$06                ;
LA365:  STA TXTClrCols          ;Clear 6 columns and 8 rows for the text string.
LA367:  LDA #$08                ;
LA369:  STA TXTClrRows          ;

LA36B:  LDA #TXT_DBL_SPACE      ;Indicate buffer is already filled, double spaced.
LA36D:  STA TextIndex           ;
LA36F:  JSR ShowTextString      ;($995C)Show a text string on the screen.
LA372:  RTS                     ;

;----------------------------------------------------------------------------------------------------

Txt2Digits:
LA373:  LDA (CrntChrPtr),Y      ;Get byte to convert.
LA375:  STA BinInputLB          ;

LA377:  LDA #$00                ;Set upper byte to zero as its not needed.
LA379:  STA BinInputUB          ;

LA37B:  STX GenByte2C           ;Temp storage for X.
LA37D:  JSR BinToBCD            ;($9883)Convert 16-bit word to 4 digit number.
LA380:  LDX GenByte2C           ;Restore X.

LA382:  LDY #$02                ;Clear 2 leading bytes in the buffer before the number.
LA384:  JSR ClrTxtBytes         ;($A3C5)Clear some bytes in the text buffer.

LA387:  LDA BCDOutput2          ;
LA389:  STA TextBuffer,X        ;
LA38C:  INX                     ;Put the 2 digit result in the text buffer.
LA38D:  LDA BCDOutput3          ;
LA38F:  STA TextBuffer,X        ;
LA392:  INX                     ;

LA393:  LDA #TXT_NEWLINE        ;
LA395:  STA TextBuffer,X        ;Add a newline after the number.
LA398:  INX                     ;
LA399:  RTS                     ;

;----------------------------------------------------------------------------------------------------

Txt4Digits:
LA39A:  LDA (CrntChrPtr),Y      ;
LA39C:  STA BinInputLB          ;
LA39E:  INY                     ;Get the 16-bit word to convert.
LA39F:  LDA (CrntChrPtr),Y      ;
LA3A1:  STA BinInputUB          ;

LA3A3:  STX GenByte2C           ;Temp storage for X.
LA3A5:  JSR BinToBCD            ;($9883)Convert 16-bit word to 4 digit number.
LA3A8:  LDX GenByte2C           ;Restore X.

LA3AA:  LDA #$00                ;
LA3AC:  STA TextBuffer,X        ;Clear a leading byte in the buffer before the number.
LA3AF:  INX                     ;

LA3B0:  LDY #$02                ;Set index to the beginning of the BCD digits.

LA3B2:* LDA BCDDigitBase,Y      ;
LA3B5:  STA TextBuffer,X        ;
LA3B8:  INX                     ;Copy the 4 digit number into the text buffer.
LA3B9:  INY                     ;
LA3BA:  CPY #$06                ;
LA3BC:  BCC -                   ;

LA3BE:  LDA #TXT_NEWLINE        ;
LA3C0:  STA TextBuffer,X        ;Add newline after number.
LA3C3:  INX                     ;
LA3C4:  RTS                     ;

;----------------------------------------------------------------------------------------------------

ClrTxtBytes:
LA3C5:  LDA #$00                ;
LA3C7:* STA TextBuffer,X        ;Clears bytes in text buffer.
LA3CA:  INX                     ;X is the index into the buffer.
LA3CB:  DEY                     ;Y is the number of bytes to clear.
LA3CC:  BNE -                   ;
LA3CE:  RTS                     ;

;----------------------------------------------------------------------------------------------------

;The following table contains the X position of each character's stats.

StatsXPosTbl:
LA3CF:  .byte $02, $08, $12, $18

;----------------------------------------------------------------------------------------------------

Chr1stPage:
LA3D3:  JSR TxtRaceClass        ;($A407)Print race and class of character on screen.

LA3D6:  LDX #$00                ;Prepare to print marks.
LA3D8:  JSR TxtMarksCards       ;($A43D)Print marks/cards of character on screen.

LA3DB:  LDA #<BlanksTxt         ;
LA3DD:  STA TXTSrcPtrLB         ;Prepare to load blank rows into PPU buffer.
LA3DF:  LDA #>BlanksTxt         ;
LA3E1:  STA TXTSrcPtrUB         ;

LA3E3:  LDY #CHR_WEAPONS        ;Offset to character's weapon inventory.
LA3E5:  LDX #$0F                ;Total number of weapons in the game.
LA3E7:  LDA #$00                ;Prepare to show weapons.
LA3E9:  JSR TxtBlankRows        ;($A470)Make a list of blank rows in front of weapons/armors.
LA3EC:  RTS                     ;

;----------------------------------------------------------------------------------------------------

Chr2ndPage:
LA3ED:  JSR TxtRaceClass        ;($A407)Print race and class of character on screen.

LA3F0:  LDX #$03                ;Prepare to print cards.
LA3F2:  JSR TxtMarksCards       ;($A43D)Print marks/cards of character on screen.

LA3F5:  LDA #<BlanksTxt         ;
LA3F7:  STA TXTSrcPtrLB         ;Prepare to load blank rows into PPU buffer.
LA3F9:  LDA #>BlanksTxt         ;
LA3FB:  STA TXTSrcPtrUB         ;

LA3FD:  LDY #CHR_ARMOR          ;Offset to character's armor inventory.
LA3FF:  LDX #$07                ;Total number of armors in the game.
LA401:  LDA #$10                ;Prepare to show armor.
LA403:  JSR TxtBlankRows        ;($A470)Make a list of blank rows in front of weapons/armors.
LA406:  RTS                     ;

;----------------------------------------------------------------------------------------------------

TxtRaceClass:
LA407:  LDX #$00                ;Start at beginning of the table below.

RaceClassLoop:
LA409:  LDA RaceClassTbl,X      ;
LA40C:  STA TXTSrcPtrLB         ;
LA40E:  INX                     ;Set a pointer to the race/class text string.
LA40F:  LDA RaceClassTbl,X      ;
LA412:  STA TXTSrcPtrUB         ;

LA414:  INX                     ;
LA415:  LDY RaceClassTbl,X      ;Get index to character's race/class.
LA418:  INX                     ;
LA419:  LDA (CrntChrPtr),Y      ;

LA41B:  CLC                     ;
LA41C:  ADC #$01                ;Save character's race/class+1.
LA41E:  STA GenByte30           ;

LA420:  LDY #$00                ;Start looking at the beginning of the string.

LA422:* JSR GetTxtSegment       ;($A4F5)Puts a newline terminated text segment in the text buffer.
LA425:  DEC GenByte30           ;Was this the text segment we were looking for?
LA427:  BNE -                   ;If not, branch to get the next text segment.

LA429:  LDA RaceClassTbl,X      ;Get Y position control byte for text.
LA42C:  INX                     ;
LA42D:  JSR ChrAlignText        ;($A490)Set the proper X and Y positions for status text.

LA430:  CPX #$08                ;Have both the race and class been processed?
LA432:  BNE RaceClassLoop       ;
LA434:  RTS                     ;If not, loop to get the class text.

;----------------------------------------------------------------------------------------------------

;The following 2 tables contain information about where to find the race and class test.
;The first work is the base address to the race/class text. The first byte after the word
;is the index into the text strings to find the proper race/class. The last byte is used
;to find the correct Y location for the text.

RaceClassTbl:

;Race data.
LA435:  .word RaceTxt
LA437:  .byte CHR_RACE, $18

;Class data.
LA439:  .word ClassTxt
LA43B:  .byte CHR_CLASS, $19

;----------------------------------------------------------------------------------------------------

TxtMarksCards:
LA43D:  LDA MarksCardsTbl,X     ;
LA440:  STA TXTSrcPtrLB         ;
LA442:  INX                     ;Set a pointer to the marks/cards text string.
LA443:  LDA MarksCardsTbl,X     ;
LA446:  STA TXTSrcPtrUB         ;

LA448:  INX                     ;
LA449:  LDY MarksCardsTbl,X     ;Get character's current marks/cards.
LA44C:  LDA (CrntChrPtr),Y      ;
LA44E:  STA GenByte2F           ;

LA450:  LDX #$04                ;Prepare to check 4 marks/cards.
LA452:  LDY #$00                ;Zero out index.

LA454:  LDA #$1A                ;Set proper row for marks/cards.
LA456:  STA GenByte30           ;

MarksCardsLoop:
LA458:  JSR GetTxtSegment       ;($A4F5)Puts a newline terminated text segment in the text buffer.

LA45B:  LSR GenByte2F           ;Shift LSB into carry.
LA45D:  BCC +                   ;Does character have this markcard? If not, branch to skip text.

LA45F:  LDA GenByte30           ;Align and print this mark/card.
LA461:  INC GenByte30           ;
LA463:  JSR ChrAlignText        ;($A490)Set the proper X and Y positions for status text.

LA466:* DEX                     ;Are there more marks/cards to check?
LA467:  BNE MarksCardsLoop      ;If so, branch to get next mark/card.
LA469:  RTS                     ;

;----------------------------------------------------------------------------------------------------

;The following tables hold pointers to the desired marks/cards text and the index into the
;character's current marks/cards.

MarksCardsTbl:
LA46A:  .word MarksTxt
LA46C:  .byte CHR_MARKS

LA46D:  .word CardsTxt
LA46F:  .byte CHR_CARDS

;----------------------------------------------------------------------------------------------------

TxtBlankRows:
LA470:  STA GenByte30           ;Store Y position control byte.
LA472:  STY GenByte26           ;Store index to inventory to check.

LA474:  LDY #$00                ;Zero out index.

BlankRowLoop:
LA476:  JSR GetTxtSegment       ;($A4F5)Puts a newline terminated text segment in the text buffer.
LA479:  STY GenByte25           ;tore updated index into inventory.

LA47B:  LDY GenByte26           ;Does character have any of the selected inventory item?
LA47D:  LDA (CrntChrPtr),Y      ;
LA47F:  BEQ +                   ;If not, branch to move to next inventory item.

LA481:  LDA GenByte30           ;Prepare to add blank row for upcomming weapon/armor.
LA483:  INC GenByte30           ;
LA485:  JSR ChrAlignText        ;($A490)Set the proper X and Y positions for status text.

LA488:* INC GenByte26           ;Increment to next inventory item.
LA48A:  LDY GenByte25           ;

LA48C:  DEX                     ;Are there more weapons/armor to make blank rows for?
LA48D:  BNE BlankRowLoop        ;If so, branch to check next inventory slot.
LA48F:  RTS                     ;

;----------------------------------------------------------------------------------------------------

ChrAlignText:
LA490:  STX GenByte28           ;
LA492:  STY GenByte27           ;Save the state of X, Y and A.
LA494:  PHA                     ;

LA495:  LSR                     ;
LA496:  LSR                     ;Divide by 8 to get index into tables below.
LA497:  LSR                     ;

LA498:  TAX                     ;
LA499:  LDA ChrXPosTbl,X        ;Get the X position of text from table below.
LA49C:  STA TXTXPos             ;

LA49E:  PLA                     ;Get Y alignment control byte.

LA49F:  CMP #$18                ;Is this loop showing race/class or marks/cards?
LA4A1:  AND #$07                ;
LA4A3:  BCC +                   ;If not, branch.

LA4A5:  ADC #$07                ;Move to second part of ChrYPosTbl.

LA4A7:* TAX                     ;
LA4A8:  LDA ChrYPosTbl,X        ;Get the Y position of text from the table below.
LA4AB:  STA TXTYPos             ;

LA4AD:  LDA GenByte30           ;
LA4AF:  PHA                     ;
LA4B0:  LDA GenByte2E           ;
LA4B2:  PHA                     ;
LA4B3:  LDA GenByte2D           ;
LA4B5:  PHA                     ;
LA4B6:  LDA GenByte28           ;
LA4B8:  PHA                     ;Temporarily save values on stack.
LA4B9:  LDA GenByte27           ;
LA4BB:  PHA                     ;
LA4BC:  LDA GenByte26           ;
LA4BE:  PHA                     ;
LA4BF:  LDA GenByte25           ;
LA4C1:  PHA                     ;

LA4C2:  LDA #TXT_DBL_SPACE      ;Indicate text buffer is aleady filled. Double space.
LA4C4:  STA TextIndex           ;
LA4C6:  JSR ShowTextString      ;($995C)Show a text string on the screen.

LA4C9:  PLA                     ;
LA4CA:  STA GenByte25           ;
LA4CC:  PLA                     ;
LA4CD:  STA GenByte26           ;
LA4CF:  PLA                     ;
LA4D0:  STA GenByte27           ;
LA4D2:  PLA                     ;
LA4D3:  STA GenByte28           ;Restore values from stack.
LA4D5:  PLA                     ;
LA4D6:  STA GenByte2D           ;
LA4D8:  PLA                     ;
LA4D9:  STA GenByte2E           ;
LA4DB:  PLA                     ;
LA4DC:  STA GenByte30           ;

LA4DE:  LDX GenByte28           ;
LA4E0:  LDY GenByte27           ;Restore X and Y from the stack.
LA4E2:  RTS                     ;

;----------------------------------------------------------------------------------------------------

ChrXPosTbl:
;X positions for wapons/armor and marks/cards.
LA4E3:  .byte $0D, $16, $11, $04

ChrYPosTbl:
;Y positions for weapons/armor.
LA4E7:  .byte $08, $0A, $0C, $0E, $10, $12, $14, $16

;Y positions for race, class marks/cards.
LA4EF:  .byte $0D, $0F, $12, $14, $16, $18

;----------------------------------------------------------------------------------------------------

GetTxtSegment:
LA4F5:  STX GenByte28           ;Store X just in case this is the wrong entry.
LA4F7:  LDX #$00                ;Zero out the index.

TxtSegmentLoop:
LA4F9:  LDA (TXTSrcPtr),Y       ;Get a byte from the text string.
LA4FB:  INY                     ;

LA4FC:  CMP #TXT_NEWLINE        ;Have we found the end of the text segment?
LA4FE:  BEQ TxtSegmentEnd       ;If so, branch.

LA500:  STA TextBuffer,X        ;Not a newline character so we are going to store the 
LA503:  INX                     ;character in the text buffer.
LA504:  JMP TxtSegmentLoop      ;($A4F9)Loop to keep looking for newline indicator.

TxtSegmentEnd:
LA507:  LDA #TXT_END            ;We found the end of this text segment so we will put
LA509:  STA TextBuffer,X        ;a string teminator in the buffer.

LA50C:  STX TXTClrCols          ;Keep track of the length of the text segment.

LA50E:  LDA #$01                ;Text segment will always be 1 row.
LA510:  STA TXTClrRows          ;

LA512:  LDX GenByte28           ;Restore the original value of X.
LA514:  RTS                     ;

;----------------------------------------------------------------------------------------------------

BlanksTxt:
;              _    \n   _    \n   _    \n   _    \n   _    \n   _    \n   _    \n   _    \n
LA515:  .byte $00, $FD, $00, $FD, $00, $FD, $00, $FD, $00, $FD, $00, $FD, $00, $FD, $00, $FD
;              _    \n   _    \n   _    \n   _    \n   _    \n   _    \n   _    \n   _    \n
LA525:  .byte $00, $FD, $00, $FD, $00, $FD, $00, $FD, $00, $FD, $00, $FD, $00, $FD, $00, $FD
;              _    \n   _    \n   _    \n   
LA535:  .byte $00, $FD, $00, $FD, $00, $FD

;----------------------------------------------------------------------------------------------------

StatsTxt:
;              S    T    R    _    \n   D    E    X    _    \n   I    N    T    _    \n   W
LA53B:  .byte $9C, $9D, $9B, $00, $FD, $8D, $8E, $A1, $00, $FD, $92, $97, $9D, $00, $FD, $A0
;              I    S    _    \n   M    M    P    _    \n   M    H    P    _    \n   E    X
LA54B:  .byte $92, $9C, $00, $FD, $96, $96, $99, $00, $FD, $96, $91, $99, $00, $FD, $8E, $A1
;              P    _    \n   G    O    L    D    \n  END
LA55B:  .byte $99, $00, $FD, $90, $98, $95, $8D, $FD, $FF

;----------------------------------------------------------------------------------------------------

RaceTxt:
;              H    U    M    A    N    \n   E    L    F    \n   D    W    A    R    F    \n
LA564:  .byte $91, $9E, $96, $8A, $97, $FD, $8E, $95, $8F, $FD, $8D, $A0, $8A, $9B, $8F, $FD
;              B    O    B    I    T    \n   F    U    Z    Z    Y    \n  END
LA574:  .byte $8B, $98, $8B, $92, $9D, $FD, $8F, $9E, $A3, $A3, $A2, $FD, $FF

;----------------------------------------------------------------------------------------------------

ClassTxt:
;              F    T    R    \n   C    L    R    C    \n   W    Z    R    D    \n   T    H
LA581:  .byte $8F, $9D, $9B, $FD, $8C, $95, $9B, $8C, $FD, $A0, $A3, $9B, $8D, $FD, $9D, $91
;              I    E    F    \n   P    L    D    N    \n   B    R    B    R    N    \n   L
LA591:  .byte $92, $8E, $8F, $FD, $99, $95, $8D, $97, $FD, $8B, $9B, $8B, $9B, $97, $FD, $95
;              A    R    K    \n   I    L    S    N    T    \n   D    R    U    I    D    \n
LA5A1:  .byte $8A, $9B, $94, $FD, $92, $95, $9C, $97, $9D, $FD, $8D, $9B, $9E, $92, $8D, $FD
;              A    L    C    M    T    \n   R    N    G    R   END
LA5B1:  .byte $8A, $95, $8C, $96, $9D, $FD, $9B, $97, $90, $9B, $FF

;----------------------------------------------------------------------------------------------------

InventoryTxt:
;              T    O    R    C    H    _    _    \n   K    E    Y    _    _    _    _    \n
LA5BC:  .byte $9D, $98, $9B, $8C, $91, $00, $00, $FD, $94, $8E, $A2, $00, $00, $00, $00, $FD
;              G    E    M    _    _    _    _    \n   S    A    N    D    S    _    _    \n
LA5CC:  .byte $90, $8E, $96, $00, $00, $00, $00, $FD, $9C, $8A, $97, $8D, $9C, $00, $00, $FD
;              T    E    N    T    _    _    _    \n   G    L    D    _    P    I    C    K
LA5DC:  .byte $9D, $8E, $97, $9D, $00, $00, $00, $FD, $90, $95, $8D, $00, $99, $92, $8C, $94
;              \n   S    L    V    _    P    I    C    K    \n   G    L    D    _    H    O
LA5EC:  .byte $FD, $9C, $95, $9F, $00, $99, $92, $8C, $94, $FD, $90, $95, $8D, $00, $91, $98
;              R    N    \n   C    O    M    P    A    S    S    \n  END
LA5FC:  .byte $9B, $97, $FD, $8C, $98, $96, $99, $8A, $9C, $9C, $FD, $FF

;----------------------------------------------------------------------------------------------------

MarksTxt:
;              F    O    R    C    E    \n   F    I    R    E    \n   S    N    A    K    E
LA608:  .byte $8F, $98, $9B, $8C, $8E, $FD, $8F, $92, $9B, $8E, $FD, $9C, $97, $8A, $94, $8E
;              \n   K    I    N    G    \n  END
LA618:  .byte $FD, $94, $92, $97, $90, $FD, $FF

;----------------------------------------------------------------------------------------------------

CardsTxt:
;              D    E    A    T    H    \n   S    O    L    \n   L    O    V    E    \n   M
LA61F:  .byte $8D, $8E, $8A, $9D, $91, $FD, $9C, $98, $95, $FD, $95, $98, $9F, $8E, $FD, $96
;              O    O    N    S    \n  END
LA62F:  .byte $98, $98, $97, $9C, $FD, $FF                                 

;----------------------------------------------------------------------------------------------------

;The following table is loaded into attribute table 0 when showing the character portrait
;when lookinig at an individual character's items. The attribute table is always the same.
;The palette data is what changes.

Chr1PtrtAtribDat:
LA635:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $50, $10, $00, $00, $00, $00, $00
LA645:  .byte $00, $55, $11, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA655:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA665:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

;----------------------------------------------------------------------------------------------------

;The following table points to the uncompressed text strings below.

StringPtrTbl:
LA675:  .word TB0E00, TB0E01, TB0E02, TB0E03, TB0E04, TB0E05, TB0E06, TB0E07
LA685:  .word TB0E08, TB0E09, TB0E0A, TB0E0B, TB0E0C, TB0E0D, TB0E0E, TB0E0F
LA695:  .word TB0E10, TB0E11, TB0E12, TB0E13, TB0E14, TB0E15, TB0E16, TB0E17
LA6A5:  .word TB0E18, TB0E19, TB0E1A, TB0E1B, TB0E1C, TB0E1D, TB0E1E, TB0E1F
LA6B5:  .word TB0E20, TB0E21, TB0E22, TB0E23, TB0E24, TB0E25, TB0E26, TB0E27
LA6C5:  .word TB0E28

;----------------------------------------------------------------------------------------------------

TB0E00:
;              R    E    G    I    S    T    E    R   END
LA6C7:  .byte $9B, $8E, $90, $92, $9C, $9D, $8E, $9B, $FF

;----------------------------------------------------------------------------------------------------

TB0E01:
;              E    R    A    S    E   END
LA6D0:  .byte $8E, $9B, $8A, $9C, $8E, $FF

;----------------------------------------------------------------------------------------------------

TB0E02:
;              R    E    G    I    S    T    E    R    _    Y    O    U    R    _    N    A
LA6D6:  .byte $9B, $8E, $90, $92, $9C, $9D, $8E, $9B, $00, $A2, $98, $9E, $9B, $00, $97, $8A
;              M    E   END
LA6E6:  .byte $96, $8E, $FF

;----------------------------------------------------------------------------------------------------

TB0E03:
;              A    _    B    _    C    _    D    _    E    _    F    _    G    _    H    _   
LA6E9:  .byte $8A, $00, $8B, $00, $8C, $00, $8D, $00, $8E, $00, $8F, $00, $90, $00, $91, $00
;              I    _    J    _    \n   K    _    L    _    M    _    N    _    O    _    P
LA6F9:  .byte $92, $00, $93, $00, $FD, $94, $00, $95, $00, $96, $00, $97, $00, $98, $00, $99
;              _    Q    _    R    _    S    _    T    \n   U    _    V    _    W    _    X
LA709:  .byte $00, $9A, $00, $9B, $00, $9C, $00, $9D, $FD, $9E, $00, $9F, $00, $A0, $00, $A1
;              _    Y    _    Z    _    ,    _    .    _    _    _    _    \n   0    _    1
LA719:  .byte $00, $A2, $00, $A3, $00, $42, $00, $43, $00, $00, $00, $00, $FD, $38, $00, $39
;              _    2    _    3    _    4    _    5    _    6    _    7    _    8    _    9
LA729:  .byte $00, $3A, $00, $3B, $00, $3C, $00, $3D, $00, $3E, $00, $3F, $00, $40, $00, $41
;              \n   _    _    _    _    _    _    _    _    _    _    _    _    B    S    _
LA739:  .byte $FD, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $8B, $9C, $00
;              _    E    N    D   END
LA749:  .byte $00, $8E, $97, $8D, $FF

;----------------------------------------------------------------------------------------------------

TB0E04:
;              C    R    E    A    T    E    \n   C    O    N    T    I    N    U    E   END
LA74E:  .byte $8C, $9B, $8E, $8A, $9D, $8E, $FD, $8C, $98, $97, $9D, $92, $97, $9E, $8E, $FF

;----------------------------------------------------------------------------------------------------

TB0E05:
;              E    X    A    M    I    N    E    \n   C    R    E    A    T    E    \n   D
LA75E:  .byte $8E, $A1, $8A, $96, $92, $97, $8E, $FD, $8C, $9B, $8E, $8A, $9D, $8E, $FD, $8D
;              I    S    C    A    R    D    \n   F    O    R    M    _    P    A    R    T
LA76E:  .byte $92, $9C, $8C, $8A, $9B, $8D, $FD, $8F, $98, $9B, $96, $00, $99, $8A, $9B, $9D
;              Y    \n   P    R    E    V    I    O    U    S    _    M    E    N    U   END
LA77E:  .byte $A2, $FD, $99, $9B, $8E, $9F, $92, $98, $9E, $9C, $00, $96, $8E, $97, $9E, $FF

;----------------------------------------------------------------------------------------------------

TB0E06:
;              H    A    N    D    -    M    A    D    E    \n   R    E    A    D    Y    -
LA78E:  .byte $91, $8A, $97, $8D, $02, $96, $8A, $8D, $8E, $FD, $9B, $8E, $8A, $8D, $A2, $02
;              M    A    D    E    \n   P    R    E    V    I    O    U    S    _    M    E
LA79E:  .byte $96, $8A, $8D, $8E, $FD, $99, $9B, $8E, $9F, $92, $98, $9E, $9C, $00, $96, $8E
;              N    U   END
LA7AE:  .byte $97, $9E, $FF

;----------------------------------------------------------------------------------------------------

TB0E07:
;              _    _    _    _    _    _    C    H    A    R    A    C    T    E    R    _
LA7B1:  .byte $00, $00, $00, $00, $00, $00, $8C, $91, $8A, $9B, $8A, $8C, $9D, $8E, $9B, $00
;              L    I    S    T    \n   0    1    _    _    _    _    _    _    _    _    _
LA7C1:  .byte $95, $92, $9C, $9D, $FD, $38, $39, $00, $00, $00, $00, $00, $00, $00, $00, $00
;              _    _    _    1    1    \n   0    2    _    _    _    _    _    _    _    _
LA7D1:  .byte $00, $00, $00, $39, $39, $FD, $38, $3A, $00, $00, $00, $00, $00, $00, $00, $00
;              _    _    _    _    1    2    \n   0    3    _    _    _    _    _    _    _
LA7E1:  .byte $00, $00, $00, $00, $39, $3A, $FD, $38, $3B, $00, $00, $00, $00, $00, $00, $00
;              _    _    _    _    _    1    3    \n   0    4    _    _    _    _    _    _
LA7F1:  .byte $00, $00, $00, $00, $00, $39, $3B, $FD, $38, $3C, $00, $00, $00, $00, $00, $00
;              _    _    _    _    _    _    1    4    \n   0    5    _    _    _    _    _
LA801:  .byte $00, $00, $00, $00, $00, $00, $39, $3C, $FD, $38, $3D, $00, $00, $00, $00, $00
;              _    _    _    _    _    _    _    1    5    \n   0    6    _    _    _    _
LA811:  .byte $00, $00, $00, $00, $00, $00, $00, $39, $3D, $FD, $38, $3E, $00, $00, $00, $00
;              _    _    _    _    _    _    _    _    1    6    \n   0    7    _    _    _
LA821:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $39, $3E, $FD, $38, $3F, $00, $00, $00
;              _    _    _    _    _    _    _    _    _    1    7    \n   0    8    _    _
LA831:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $39, $3F, $FD, $38, $40, $00, $00
;              _    _    _    _    _    _    _    _    _    _    1    8    \n   0    9    _
LA841:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $39, $40, $FD, $38, $41, $00
;              _    _    _    _    _    _    _    _    _    _    _    1    9    \n   1    0
LA851:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $39, $41, $FD, $39, $38
;              _    _    _    _    _    _    _    _    _    _    _    _    2    0   END
LA861:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3A, $38, $FF

;----------------------------------------------------------------------------------------------------

TB0E08:
;              _    _    _    _    _    _    E    N    D   END
LA870:  .byte $00, $00, $00, $00, $00, $00, $8E, $97, $8D, $FF

;----------------------------------------------------------------------------------------------------

TB0E09:
;              C    H    A    R    A    C    T    E    R    _    M    A    K    I    N    G
LA87A:  .byte $8C, $91, $8A, $9B, $8A, $8C, $9D, $8E, $9B, $00, $96, $8A, $94, $92, $97, $90
;             END
LA88A:  .byte $FF

;----------------------------------------------------------------------------------------------------

TB0E0A:
;              R    A    C    E    \n   H    U    M    A    N    \n   E    L    F    \n   D
LA88B:  .byte $9B, $8A, $8C, $8E, $FD, $91, $9E, $96, $8A, $97, $FD, $8E, $95, $8F, $FD, $8D
;              W    A    R    F    \n   B    O    B    I    T    \n   F    U    Z    Z    Y
LA89B:  .byte $A0, $8A, $9B, $8F, $FD, $8B, $98, $8B, $92, $9D, $FD, $8F, $9E, $A3, $A3, $A2
;             END
LA8AB:  .byte $FF

;----------------------------------------------------------------------------------------------------

TB0E0B:
;              R    E    S    T    _    _    S    T    R    _    _    D    E    X    _    _
LA8AC:  .byte $9B, $8E, $9C, $9D, $00, $00, $9C, $9D, $9B, $00, $00, $8D, $8E, $A1, $00, $00
;              I    N    T    _    _    W    I    S   END
LA8BC:  .byte $92, $97, $9D, $00, $00, $A0, $92, $9C, $FF

;----------------------------------------------------------------------------------------------------

TB0E0C:
;              _    _    _    _    _    _    _    _    _    O    K    _    C    A    N    C
LA8C5:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $98, $94, $00, $8C, $8A, $97, $8C
;              E    L   END
LA8D5:  .byte $8E, $95, $FF

;----------------------------------------------------------------------------------------------------

TB0E0D:
;              P    R    O    F    E    S    S    I    O    N    \n   F    T    R    _    _
LA8D8:  .byte $99, $9B, $98, $8F, $8E, $9C, $9C, $92, $98, $97, $FD, $8F, $9D, $9B, $00, $00
;              _    _    L    A    R    K    \n   C    L    R    C    _    _    _    I    L
LA8E8:  .byte $00, $00, $95, $8A, $9B, $94, $FD, $8C, $95, $9B, $8C, $00, $00, $00, $92, $95
;              S    N    T    \n   W    Z    R    D    _    _    _    D    R    U    I    D
LA8F8:  .byte $9C, $97, $9D, $FD, $A0, $A3, $9B, $8D, $00, $00, $00, $8D, $9B, $9E, $92, $8D
;              \n   T    H    I    E    F    _    _    A    L    C    M    T    \n   P    L
LA908:  .byte $FD, $9D, $91, $92, $8E, $8F, $00, $00, $8A, $95, $8C, $96, $9D, $FD, $99, $95
;              D    N    _    _    _    R    N    G    R    \n   B    R    B    R    N   END
LA918:  .byte $8D, $97, $00, $00, $00, $9B, $97, $90, $9B, $FD, $8B, $9B, $8B, $9B, $97, $FF

;----------------------------------------------------------------------------------------------------

TB0E0E:
;              C    H    A    R    A    C    T    E    R    _    N    A    M    E   END
LA928:  .byte $8C, $91, $8A, $9B, $8A, $8C, $9D, $8E, $9B, $00, $97, $8A, $96, $8E, $FF

;----------------------------------------------------------------------------------------------------

TB0E0F:
;              S    E    L    E    C    T    _    C    H    A    R    A    C    T    E    R
LA937:  .byte $9C, $8E, $95, $8E, $8C, $9D, $00, $8C, $91, $8A, $9B, $8A, $8C, $9D, $8E, $9B
;              S   END
LA947:  .byte $9C, $FF

;----------------------------------------------------------------------------------------------------

TB0E10:
;              F    T    R    _    _    _    P    R    O    F    E    S    _    _    R    N
LA949:  .byte $8F, $9D, $9B, $00, $00, $00, $99, $9B, $98, $8F, $8E, $9C, $00, $00, $9B, $97
;              G    R    \n   D    W    A    R    F    _    _    R    A    C    E    _    _
LA959:  .byte $90, $9B, $FD, $8D, $A0, $8A, $9B, $8F, $00, $00, $9B, $8A, $8C, $8E, $00, $00
;              H    U    M    A    N    \n   _    _    _    _    A    T    T    R    I    B
LA969:  .byte $91, $9E, $96, $8A, $97, $FD, $00, $00, $00, $00, $8A, $9D, $9D, $9B, $92, $8B
;              U    T    E    S    \n   _    _    2    5    _    _    _    S    T    R    _
LA979:  .byte $9E, $9D, $8E, $9C, $FD, $00, $00, $3A, $3D, $00, $00, $00, $9C, $9D, $9B, $00
;              _    _    _    2    5    \n   _    _    1    5    _    _    _    D    E    X
LA989:  .byte $00, $00, $00, $3A, $3D, $FD, $00, $00, $39, $3D, $00, $00, $00, $8D, $8E, $A1
;              _    _    _    _    1    5    \n   _    _    0    5    _    _    _    I    N
LA999:  .byte $00, $00, $00, $00, $39, $3D, $FD, $00, $00, $38, $3D, $00, $00, $00, $92, $97
;              T    _    _    _    _    0    5    \n   _    _    0    5    _    _    _    W
LA9A9:  .byte $9D, $00, $00, $00, $00, $38, $3D, $FD, $00, $00, $38, $3D, $00, $00, $00, $A0
;              I    S    _    _    _    _    0    5   END
LA9B9:  .byte $92, $9C, $00, $00, $00, $00, $38, $3D, $FF

;----------------------------------------------------------------------------------------------------

TB0E11:
;              C    L    R    C    _    _    P    R    O    F    E    S    _    D    R    U
LA9C2:  .byte $8C, $95, $9B, $8C, $00, $00, $99, $9B, $98, $8F, $8E, $9C, $00, $8D, $9B, $9E
;              I    D    \n   D    W    A    R    F    _    _    R    A    C    E    _    _
LA9D2:  .byte $92, $8D, $FD, $8D, $A0, $8A, $9B, $8F, $00, $00, $9B, $8A, $8C, $8E, $00, $00
;              B    O    B    I    T    \n   _    _    _    _    A    T    T    R    I    B
LA9E2:  .byte $8B, $98, $8B, $92, $9D, $FD, $00, $00, $00, $00, $8A, $9D, $9D, $9B, $92, $8B
;              U    T    E    S    \n   _    _    0    5    _    _    _    S    T    R    _
LA9F2:  .byte $9E, $9D, $8E, $9C, $FD, $00, $00, $38, $3D, $00, $00, $00, $9C, $9D, $9B, $00
;              _    _    _    0    5    \n   _    _    1    5    _    _    _    D    E    X
LAA02:  .byte $00, $00, $00, $38, $3D, $FD, $00, $00, $39, $3D, $00, $00, $00, $8D, $8E, $A1
;              _    _    _    _    0    5    \n   _    _    0    5    _    _    _    I    N
LAA12:  .byte $00, $00, $00, $00, $38, $3D, $FD, $00, $00, $38, $3D, $00, $00, $00, $92, $97
;              T    _    _    _    _    2    0    \n   _    _    2    5    _    _    _    W
LAA22:  .byte $9D, $00, $00, $00, $00, $3A, $38, $FD, $00, $00, $3A, $3D, $00, $00, $00, $A0
;              I    S    _    _    _    _    2    0   END
LAA32:  .byte $92, $9C, $00, $00, $00, $00, $3A, $38, $FF

;----------------------------------------------------------------------------------------------------

TB0E12:
;              T    H    I    E    F    _    P    R    O    F    E    S    _    I    L    S
LAA3B:  .byte $9D, $91, $92, $8E, $8F, $00, $99, $9B, $98, $8F, $8E, $9C, $00, $92, $95, $9C
;              N    T    \n   D    W    A    R    F    _    _    R    A    C    E    _    _
LAA4B:  .byte $97, $9D, $FD, $8D, $A0, $8A, $9B, $8F, $00, $00, $9B, $8A, $8C, $8E, $00, $00
;              F    U    Z    Z    Y    \n   _    _    _    _    A    T    T    R    I    B
LAA5B:  .byte $8F, $9E, $A3, $A3, $A2, $FD, $00, $00, $00, $00, $8A, $9D, $9D, $9B, $92, $8B
;              U    T    E    S    \n   _    _    1    5    _    _    _    S    T    R    _
LAA6B:  .byte $9E, $9D, $8E, $9C, $FD, $00, $00, $39, $3D, $00, $00, $00, $9C, $9D, $9B, $00
;              _    _    _    0    5    \n   _    _    1    5    _    _    _    D    E    X
LAA7B:  .byte $00, $00, $00, $38, $3D, $FD, $00, $00, $3A, $3D, $00, $00, $00, $8D, $8E, $A1
;              _    _    _    _    2    5    \n   _    _    0    5    _    _    _    I    N
LAA8B:  .byte $00, $00, $00, $00, $3A, $3D, $FD, $00, $00, $38, $3D, $00, $00, $00, $92, $97
;              T    _    _    _    _    0    5    \n   _    _    0    5    _    _    _    W
LAA9B:  .byte $9D, $00, $00, $00, $00, $38, $3D, $FD, $00, $00, $38, $3D, $00, $00, $00, $A0
;              I    S    _    _    _    _    1    5   END
LAAAB:  .byte $92, $9C, $00, $00, $00, $00, $39, $3D, $FF

;----------------------------------------------------------------------------------------------------

TB0E13:
;              W    Z    R    D    _    _    P    R    O    F    E    S    _    A    L    S
LAAB4:  .byte $A0, $A3, $9B, $8D, $00, $00, $99, $9B, $98, $8F, $8E, $9C, $00, $8A, $95, $8C
;              N    T    \n   F    U    Z    Z    Y    _    _    R    A    C    E    _    _
LAAC4:  .byte $96, $9D, $FD, $8F, $9E, $A3, $A3, $A2, $00, $00, $9B, $8A, $8C, $8E, $00, $00
;              _    _    E    L    F    \n   _    _    _    _    A    T    T    R    I    B
LAAD4:  .byte $00, $00, $8E, $95, $8F, $FD, $00, $00, $00, $00, $8A, $9D, $9D, $9B, $92, $8B
;              U    T    E    S    \n   _    _    0    5    _    _    _    S    T    R    _
LAAE4:  .byte $9E, $9D, $8E, $9C, $FD, $00, $00, $38, $3D, $00, $00, $00, $9C, $9D, $9B, $00
;              _    _    _    0    5    \n   _    _    1    5    _    _    _    D    E    X
LAAF4:  .byte $00, $00, $00, $38, $3D, $FD, $00, $00, $39, $3D, $00, $00, $00, $8D, $8E, $A1
;              _    _    _    _    2    5    \n   _    _    2    5    _    _    _    I    N
LAB04:  .byte $00, $00, $00, $00, $3A, $38, $FD, $00, $00, $3A, $3D, $00, $00, $00, $92, $97
;              T    _    _    _    _    2    0    \n   _    _    0    5    _    _    _    W
LAB14:  .byte $9D, $00, $00, $00, $00, $3A, $38, $FD, $00, $00, $38, $3D, $00, $00, $00, $A0
;              I    S    _    _    _    _    0    5   END
LAB24:  .byte $92, $9C, $00, $00, $00, $00, $38, $3D, $FF

;----------------------------------------------------------------------------------------------------

TB0E14:
;              W    Z    R    D    _    _    P    R    O    F    E    S    _    _    L    A
LAB2D:  .byte $99, $95, $8D, $97, $00, $00, $99, $9B, $98, $8F, $8E, $9C, $00, $00, $95, $8A
;              R    K    \n   B    O    B    I    T    _    _    R    A    C    E    _    _
LAB3D:  .byte $9B, $94, $FD, $8B, $98, $8B, $92, $9D, $00, $00, $9B, $8A, $8C, $8E, $00, $00
;              _    _    E    L    F    \n   _    _    _    _    A    T    T    R    I    B
LAB4D:  .byte $00, $00, $8E, $95, $8F, $FD, $00, $00, $00, $00, $8A, $9D, $9D, $9B, $92, $8B
;              U    T    E    S    \n   _    _    2    5    _    _    _    S    T    R    _
LAB5D:  .byte $9E, $9D, $8E, $9C, $FD, $00, $00, $3A, $3D, $00, $00, $00, $9C, $9D, $9B, $00
;              _    _    _    2    5    \n   _    _    1    5    _    _    _    D    E    X
LAB6D:  .byte $00, $00, $00, $3A, $3D, $FD, $00, $00, $39, $3D, $00, $00, $00, $8D, $8E, $A1
;              _    _    _    _    1    5    \n   _    _    0    5    _    _    _    I    N
LAB7D:  .byte $00, $00, $00, $00, $39, $3D, $FD, $00, $00, $38, $3D, $00, $00, $00, $92, $97
;              T    _    _    _    _    0    5    \n   _    _    0    5    _    _    _    W
LAB8D:  .byte $9D, $00, $00, $00, $00, $38, $3D, $FD, $00, $00, $38, $3D, $00, $00, $00, $A0
;              I    S    _    _    _    _    0    5   END
LAB9D:  .byte $92, $9C, $00, $00, $00, $00, $38, $3D, $FF

;----------------------------------------------------------------------------------------------------

TB0E15:
;              F    T    R    _    _    _    P    R    O    F    E    S    _    B    R    B
LABA6:  .byte $8F, $9D, $9B, $00, $00, $00, $99, $9B, $98, $8F, $8E, $9C, $00, $8B, $9B, $8B
;              R    N    \n   D    W    A    R    F    _    _    R    A    C    E    _    _
LABB6:  .byte $9B, $97, $FD, $8D, $A0, $8A, $9B, $8F, $00, $00, $9B, $8A, $8C, $8E, $00, $00
;              D    W    A    R    F    \n   _    _    _    _    A    T    T    R    I    B
LABC6:  .byte $8D, $A0, $8A, $9B, $8F, $FD, $00, $00, $00, $00, $8A, $9D, $9D, $9B, $92, $8B
;              U    T    E    S    \n   _    _    2    5    _    _    _    S    T    R    _
LABD6:  .byte $9E, $9D, $8E, $9C, $FD, $00, $00, $3A, $3D, $00, $00, $00, $9C, $9D, $9B, $00
;              _    _    _    2    5    \n   _    _    1    5    _    _    _    D    E    X
LABE6:  .byte $00, $00, $00, $3A, $3D, $FD, $00, $00, $39, $3D, $00, $00, $00, $8D, $8E, $A1
;              _    _    _    _    1    5    \n   _    _    0    5    _    _    _    I    N
LABF6:  .byte $00, $00, $00, $00, $39, $3D, $FD, $00, $00, $38, $3D, $00, $00, $00, $92, $97
;              T    _    _    _    _    0    5    \n   _   _     0    5    _    _    _    W
LAC06:  .byte $9D, $00, $00, $00, $00, $38, $3D, $FD, $00, $00, $38, $3D, $00, $00, $00, $A0
;              I    S    _    _    _    _    0    5   END
LAC16:  .byte $92, $9C, $00, $00, $00, $00, $38, $3D, $FF

;----------------------------------------------------------------------------------------------------

TB0E16:
;             END
LAC1F:  .byte $FF

;----------------------------------------------------------------------------------------------------

TB0E17:
;              -    -    -    -    -   END
LAC20:  .byte $02, $02, $02, $02, $02, $FF

;----------------------------------------------------------------------------------------------------

TB0E18:
;             END
LAC26:  .byte $FF

;----------------------------------------------------------------------------------------------------

TB0E19:
;             END
LAC27:  .byte $FF

;----------------------------------------------------------------------------------------------------

TB0E1A:
;              F    O    R    M    _    A    _    P    A    R    T    Y    \n   0    1    _
LAC28:  .byte $8F, $98, $9B, $96, $00, $8A, $00, $99, $8A, $9B, $9D, $A2, $FD, $38, $39, $00
;              _    _    _    _    _    _    _    _    _    _    _    1    1    \n   0    2
LAC38:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $39, $39, $FD, $38, $3A
;              _    _    _    _    _    _    _    _    _    _    _    _    1    2    \n   0
LAC48:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $39, $3A, $FD, $38
;              3    _    _    _    _    _    _    _    _    _    _    _    _    1    3    \n
LAC58:  .byte $3B, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $39, $3B, $FD
;              0    4    _    _    _    _    _    _    _    _    _    _    _    _    1    4
LAC68:  .byte $38, $3C, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $39, $3C
;              \n   0    5    _    _    _    _    _    _    _    _    _    _    _    _    1
LAC78:  .byte $FD, $38, $3D, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $39
;              5    \n   0    6    _    _    _    _    _    _    _    _    _    _    _    _
LAC88:  .byte $3D, $FD, $38, $3E, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;              1    6    \n   0    7    _    _    _    _    _    _    _    _    _    _    _
LAC98:  .byte $39, $3E, $FD, $38, $3F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;              _    1    7    \n   0    8    _    _    _    _    _    _    _    _    _    _
LACA8:  .byte $00, $39, $3F, $FD, $38, $40, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;              _    _    1    8    \n   0    9    _    _    _    _    _    _    _    _    _
LACB8:  .byte $00, $00, $39, $40, $FD, $38, $41, $00, $00, $00, $00, $00, $00, $00, $00, $00
;              _    _    _    1    9    \n   1    0    _    _    _    _    _    _    _    _
LACC8:  .byte $00, $00, $00, $39, $41, $FD, $39, $38, $00, $00, $00, $00, $00, $00, $00, $00
;              _    _    _    _    2    0   END
LACD8:  .byte $00, $00, $00, $00, $3A, $38, $FF

;----------------------------------------------------------------------------------------------------

TB0E1B:
;              D    I    S    C    A    R    D    S    _    T    H    E    _    C    H    A
LACDF:  .byte $8D, $92, $9C, $8C, $8A, $9B, $8D, $9C, $00, $9D, $91, $8E, $00, $8C, $91, $8A
;              R    A    C    T    E    R    \n   0    1    _    _    _    _    _    _    _
LACEF:  .byte $9B, $8A, $8C, $9D, $8E, $9B, $FD, $38, $39, $00, $00, $00, $00, $00, $00, $00
;              _    _    _    _    _    1    1    \n   0    2    _    _    _    _    _    _
LACFF:  .byte $00, $00, $00, $00, $00, $39, $39, $FD, $38, $3A, $00, $00, $00, $00, $00, $00
;              _    _    _    _    _    _    1    2    \n   0    3    _    _    _    _    _
LAD0F:  .byte $00, $00, $00, $00, $00, $00, $39, $3A, $FD, $38, $3B, $00, $00, $00, $00, $00
;              _    _    _    _    _    _    _    1    3    \n   0    4    _    _    _    _
LAD1F:  .byte $00, $00, $00, $00, $00, $00, $00, $39, $3B, $FD, $38, $3C, $00, $00, $00, $00
;              _    _    _    _    _    _    _    _    1    4    \n   0    5    _    _    _
LAD2F:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $39, $3C, $FD, $38, $3D, $00, $00, $00
;              _    _    _    _    _    _    _    _    _    1    5    \n   0    6    _    _
LAD3F:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $39, $3D, $FD, $38, $3E, $00, $00
;              _    _    _    _    _    _    _    _    _    _    1    6    \n   0    7    _
LAD4F:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $39, $3E, $FD, $38, $3F, $00
;              _    _    _    _    _    _    _    _    _    _    _    1    7    \n   0    8
LAD5F:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $39, $3F, $FD, $38, $40
;              _    _    _    _    _    _    _    _    _    _    _    _    1    8    \n   0
LAD6F:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $39, $40, $FD, $38
;              9    _    _    _    _    _    _    _    _    _    _    _    _    1    9    \n
LAD7F:  .byte $41, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $39, $41, $FD
;              1    0    _    _    _    _    _    _    _    _    _    _    _    _    2    0
LAD8F:  .byte $39, $38, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3A, $38
;             END
LAD9F:  .byte $FF

;----------------------------------------------------------------------------------------------------

TB0E1C:
;              _    W    E    A    P    O    N    \n   H    A    N    D   END
LADA0:  .byte $00, $A0, $8E, $8A, $99, $98, $97, $FD, $91, $8A, $97, $8D, $FF

;----------------------------------------------------------------------------------------------------

TB0E1D:
;              A    R    M    O    R    \n   S    K    I    N   END
LADAD:  .byte $8A, $9B, $96, $98, $9B, $FD, $9C, $94, $92, $97, $FF

;----------------------------------------------------------------------------------------------------

TB0E1E:
;              O    K    \n   C    A    N    C    E    L   END
LADB8:  .byte $98, $94, $FD, $8C, $8A, $97, $8C, $8E, $95, $FF

;----------------------------------------------------------------------------------------------------

TB0E1F:
;              E    R    A    S    E    \n   Y    E    S    _    N    0   END
LADC2:  .byte $8E, $9B, $8A, $9C, $8E, $FD, $A2, $8E, $9C, $00, $97, $98, $FF

;----------------------------------------------------------------------------------------------------

TB0E20:
;              W    E    L    C    O    M    E    ,    _    Y    E    \n   F    O    U    R
LADCF:  .byte $A0, $8E, $95, $8C, $98, $96, $8E, $42, $00, $A2, $8E, $FD, $8F, $98, $9E, $9B
;              _    B    R    A    V    E    _    S    O    U    L    S    .   END
LADDF:  .byte $00, $8B, $9B, $8A, $9F, $8E, $00, $9C, $98, $9E, $95, $9C, $43, $FF

;----------------------------------------------------------------------------------------------------

TB0E21:
;              E    X    O    D    U    S    ,    D    R    E    A    D    F    U    L    \n
LADED:  .byte $8E, $A1, $98, $8D, $9E, $9C, $42, $8D, $9B, $8E, $8A, $8D, $8F, $9E, $95, $FD
;              D    E    V    I    L    ,    _    I    S    _    A    B    O    U    T    _
LADFD:  .byte $8D, $8E, $9F, $92, $95, $42, $00, $92, $9C, $00, $8A, $8B, $98, $9E, $9D, $00
;              T    O   END
LAE0D:  .byte $9D, $98, $FF

;----------------------------------------------------------------------------------------------------

TB0E22:
;              W    A    K    E    _    U    P    _    N    O    W    _    I    N    _    T
LAE10:  .byte $A0, $8A, $94, $8E, $00, $9E, $99, $00, $97, $98, $A0, $00, $92, $97, $00, $9D
;              H    I    S    \n   R    E    G    I    o    N    .   END
LAE20:  .byte $91, $92, $9C, $FD, $9B, $8E, $90, $92, $98, $97, $43, $FF

;----------------------------------------------------------------------------------------------------

TB0E23:
;              I    F    _    S    O    ,    _    O    U    R    _    W    O    R    L    D
LAE2C:  .byte $92, $8F, $00, $9C, $98, $42, $00, $98, $9E, $9B, $00, $A0, $98, $9B, $95, $8D
;              \n   W    I    L    L    _    B    E    _    C    O    V    E    R    E    D
LAE3C:  .byte $FD, $A0, $92, $95, $95, $00, $8B, $8E, $00, $8C, $98, $9F, $8E, $9B, $8E, $8D
;              _    B    Y   END
LAE4C:  .byte $00, $8B, $A2, $FF

;----------------------------------------------------------------------------------------------------

TB0E24:
;              D    A    R    K    N    E    S    S    .    B    R    A    V    E    _    O
LAE50:  .byte $8D, $8A, $9B, $94, $97, $8E, $9C, $9C, $43, $8B, $9B, $8A, $9F, $8E, $00, $98
;              N    E    S    ,    \n   S    E    A    L    _    E    X    O    D    U    S
LAE60:  .byte $97, $8E, $9C, $42, $FD, $9C, $8E, $8A, $95, $00, $8E, $A1, $98, $8D, $9E, $9C
;              _    A    N    D    _    S    A    V    E   END
LAE70:  .byte $00, $8A, $97, $8D, $00, $9C, $8A, $9F, $8E, $FF

;----------------------------------------------------------------------------------------------------

TB0E25:
;              T    H    I    S    _    W    O    R    L    D    .    G    E    T    _    R
LAE7A:  .byte $9D, $91, $92, $9C, $00, $A0, $98, $9B, $95, $8D, $43, $90, $8E, $9D, $00, $9B
;              E    A    D    Y    \n   F    O    R    _    Y    O    U    R    _    J    O
LAE8A:  .byte $8E, $8A, $8D, $A2, $FD, $8F, $98, $9B, $00, $A2, $98, $9E, $9B, $00, $93, $98
;              U    R    N    E    Y    .   END
LAE9A:  .byte $9E, $9B, $97, $8E, $A2, $43, $FF

;----------------------------------------------------------------------------------------------------

TB0E26:
;              F    L    O    W    E    R   END
LAEA1:  .byte $8F, $95, $98, $A0, $8E, $9B, $FF

;----------------------------------------------------------------------------------------------------

TB0E27:
;              W    E    L    C    O    M    E    _    !   END
LAEA8:  .byte $A0, $8E, $95, $8C, $98, $96, $8E, $00, $7C, $FF

;----------------------------------------------------------------------------------------------------

TB0E28:
;              D    I    S    C    A    R    D    \n   Y    E    S    _    N    O   END
LAEB2:  .byte $8D, $92, $9C, $8C, $8A, $9B, $8D, $FD, $A2, $8E, $9C, $00, $97, $98, $FF

;----------------------------------------------------------------------------------------------------

;The first row of each set of palette data is background palette data.
;The second row of each set of palette data is sprite palette data.

CreatePalette:
LAEC1:  .byte $0F, $30, $0F, $0F, $0F, $30, $11, $0C, $0F, $16, $37, $19, $0F, $0A, $19, $29
LAED1:  .byte $0F, $30, $11, $36, $0F, $06, $15, $26, $0F, $30, $12, $36, $0F, $30, $15, $36

JourneyOnPal:
LAEE1:  .byte $0F, $0F, $0F, $0F, $0F, $30, $11, $0C, $0F, $16, $37, $19, $0F, $0A, $19, $29
LAEF1:  .byte $0F, $30, $11, $36, $0F, $06, $15, $26, $0F, $30, $0F, $2D, $0F, $30, $15, $36

;----------------------------------------------------------------------------------------------------

;Graphics used when a new party talks to Lord British.

GFXStartNew:
LAF01:  .byte $04, $83, $81, $82, $83, $89, $88, $88, $01, $00, $06, $07, $07, $17, $17, $37
LAF11:  .byte $90, $60, $C0, $A0, $E0, $FF, $63, $41, $40, $80, $30, $F0, $F0, $80, $9C, $BE
LAF21:  .byte $00, $22, $2A, $22, $2A, $E3, $08, $5D, $00, $1C, $14, $1C, $14, $1C, $F7, $A2
LAF31:  .byte $00, $00, $00, $00, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80
LAF41:  .byte $00, $00, $03, $2E, $38, $30, $30, $38, $00, $00, $00, $01, $07, $0F, $0F, $07
LAF51:  .byte $40, $E0, $F8, $0E, $03, $01, $01, $03, $00, $00, $00, $F0, $FC, $FE, $FE, $FC
LAF61:  .byte $00, $00, $00, $80, $80, $80, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00
LAF71:  .byte $00, $FE, $FE, $FE, $00, $EF, $EF, $EF, $00, $00, $00, $00, $00, $00, $00, $00
LAF81:  .byte $00, $FE, $FE, $FE, $00, $EF, $EF, $EF, $00, $00, $00, $00, $00, $00, $00, $00
LAF91:  .byte $00, $FC, $F9, $F7, $0F, $CF, $D7, $BA, $00, $00, $00, $00, $00, $00, $00, $00
LAFA1:  .byte $00, $7E, $3E, $BE, $C0, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAFB1:  .byte $00, $7E, $7C, $7D, $03, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAFC1:  .byte $00, $3E, $9E, $EE, $F0, $F3, $EB, $5D, $00, $00, $00, $00, $00, $00, $00, $00
LAFD1:  .byte $88, $C0, $07, $00, $80, $00, $0F, $1F, $77, $37, $E0, $C7, $0F, $0F, $00, $00
LAFE1:  .byte $41, $41, $E3, $36, $1C, $00, $00, $98, $BE, $BE, $1C, $C8, $E0, $78, $38, $00
LAFF1:  .byte $08, $E3, $2A, $22, $2A, $22, $2A, $00, $F7, $1C, $14, $1C, $14, $1C, $14, $1C
LB001:  .byte $00, $80, $00, $00, $00, $00, $00, $00, $80, $00, $00, $00, $00, $00, $00, $00
LB011:  .byte $3E, $5F, $EF, $F3, $FC, $7F, $3F, $1F, $01, $60, $D0, $CC, $C3, $40, $00, $00
LB021:  .byte $0F, $BF, $BE, $B9, $07, $FF, $FF, $FF, $F0, $40, $41, $46, $F8, $00, $00, $00
LB031:  .byte $80, $40, $E0, $E0, $E0, $C0, $80, $00, $00, $C0, $60, $60, $60, $40, $00, $00
LB041:  .byte $00, $FE, $FE, $FE, $00, $EF, $EF, $EF, $00, $00, $00, $00, $00, $00, $00, $00
LB051:  .byte $00, $FE, $FE, $FE, $00, $EF, $EF, $EF, $00, $00, $00, $00, $00, $00, $00, $00
LB061:  .byte $3C, $7C, $78, $78, $00, $78, $78, $78, $00, $00, $00, $00, $00, $00, $00, $00
LB071:  .byte $3C, $3E, $1E, $1E, $00, $1E, $1E, $1E, $00, $00, $00, $00, $00, $00, $00, $00
LB081:  .byte $07, $0F, $0F, $0D, $0F, $07, $0F, $1F, $00, $00, $00, $07, $07, $03, $00, $00
LB091:  .byte $C0, $E0, $EE, $6A, $EE, $C4, $FF, $F4, $00, $00, $00, $C4, $C0, $8A, $00, $0A
LB0A1:  .byte $00, $1C, $22, $3E, $3F, $3F, $1F, $1F, $1C, $00, $3E, $3E, $3F, $38, $10, $00
LB0B1:  .byte $00, $00, $00, $00, $06, $FE, $FF, $FF, $00, $00, $01, $03, $01, $01, $00, $00
LB0C1:  .byte $1F, $0F, $47, $63, $20, $20, $10, $10, $00, $00, $B8, $9C, $DF, $DF, $EF, $EF
LB0D1:  .byte $FF, $FE, $FE, $E8, $00, $00, $01, $01, $00, $00, $01, $17, $FF, $FF, $FE, $FE
LB0E1:  .byte $00, $00, $40, $40, $8C, $8F, $1F, $1F, $00, $00, $B0, $B8, $70, $70, $E0, $E0
LB0F1:  .byte $06, $07, $17, $1F, $1F, $FF, $FE, $FE, $06, $07, $17, $1F, $1F, $07, $02, $00
LB101:  .byte $78, $78, $00, $78, $78, $78, $78, $78, $00, $00, $00, $00, $00, $00, $00, $00
LB111:  .byte $1E, $1E, $00, $1E, $1E, $1E, $1E, $1E, $00, $00, $00, $00, $00, $00, $00, $00
LB121:  .byte $00, $E1, $C3, $87, $07, $07, $07, $03, $00, $1F, $3F, $7F, $07, $EF, $E7, $E3
LB131:  .byte $00, $06, $02, $80, $80, $C0, $C0, $80, $00, $F8, $FC, $FE, $80, $EF, $CF, $8F
LB141:  .byte $07, $03, $00, $00, $30, $10, $00, $07, $18, $3C, $3F, $3F, $3F, $1F, $0F, $08
LB151:  .byte $C4, $84, $0E, $0E, $04, $04, $04, $04, $30, $7A, $FE, $FE, $EA, $E0, $E0, $E0
LB161:  .byte $1F, $3F, $3F, $3F, $3F, $3F, $3F, $1F, $00, $00, $00, $00, $00, $00, $00, $00
LB171:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FD, $F9, $00, $00, $00, $00, $00, $00, $00, $00
LB181:  .byte $10, $10, $10, $10, $10, $10, $10, $10, $EF, $EF, $EF, $EF, $EF, $EF, $EF, $EF
LB191:  .byte $01, $01, $01, $01, $01, $01, $01, $01, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE
LB1A1:  .byte $1F, $1F, $1F, $1F, $1F, $1F, $17, $17, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0
LB1B1:  .byte $FF, $FF, $FF, $FF, $FE, $FE, $FE, $FE, $00, $00, $00, $00, $00, $00, $00, $00
LB1C1:  .byte $78, $78, $00, $78, $78, $78, $78, $78, $00, $00, $00, $00, $00, $00, $00, $00
LB1D1:  .byte $1E, $1E, $00, $1E, $1E, $1E, $1E, $1E, $00, $00, $00, $00, $00, $00, $00, $00
LB1E1:  .byte $00, $08, $06, $00, $07, $83, $C3, $E1, $08, $E7, $E1, $E0, $00, $68, $28, $0C
LB1F1:  .byte $00, $00, $00, $00, $00, $01, $83, $0F, $20, $EE, $CE, $0E, $C0, $AE, $2C, $60
LB201:  .byte $07, $0F, $0F, $0F, $1F, $1F, $0F, $08, $00, $00, $01, $05, $07, $03, $01, $07
LB211:  .byte $C0, $E0, $E0, $E0, $F0, $F0, $FE, $FF, $00, $00, $00, $40, $C0, $C0, $00, $AA
LB221:  .byte $1F, $1F, $1F, $0F, $0F, $0F, $07, $03, $00, $00, $00, $10, $10, $10, $18, $1C
LB231:  .byte $F0, $F0, $E1, $E3, $C3, $C3, $87, $07, $01, $01, $00, $00, $00, $00, $00, $00
LB241:  .byte $10, $18, $08, $0C, $04, $03, $01, $00, $EF, $E7, $F7, $F3, $FB, $FC, $FE, $FF
LB251:  .byte $01, $03, $02, $06, $04, $18, $10, $A0, $FE, $FC, $FD, $F9, $FB, $E7, $EF, $5F
LB261:  .byte $03, $03, $11, $19, $19, $1C, $1C, $1C, $F0, $F0, $E0, $E0, $E0, $E0, $E0, $E0
LB271:  .byte $FC, $FC, $FC, $F8, $F0, $F0, $E0, $00, $00, $00, $00, $00, $00, $00, $00, $00
LB281:  .byte $80, $80, $20, $70, $F8, $FC, $7E, $00, $00, $00, $00, $00, $00, $00, $00, $00
LB291:  .byte $01, $01, $04, $0E, $1E, $3F, $0E, $C1, $00, $00, $00, $00, $00, $00, $00, $00
LB2A1:  .byte $00, $00, $1F, $0F, $00, $03, $07, $07, $1F, $3F, $20, $00, $07, $07, $07, $06
LB2B1:  .byte $5F, $7D, $76, $56, $78, $E0, $C0, $C0, $AA, $EA, $EE, $AE, $A0, $00, $C0, $00
LB2C1:  .byte $00, $00, $14, $14, $14, $14, $1C, $08, $1C, $1C, $08, $08, $08, $08, $00, $00
LB2D1:  .byte $0E, $1E, $1E, $3E, $7E, $7C, $0C, $00, $01, $01, $01, $01, $01, $03, $03, $07
LB2E1:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB2F1:  .byte $A0, $A0, $A0, $A0, $A0, $A0, $00, $00, $5F, $5F, $5F, $5F, $5F, $5F, $FF, $FF
LB301:  .byte $0E, $0E, $0F, $0F, $0F, $07, $06, $00, $F0, $F0, $F0, $F0, $F0, $F8, $F8, $FC
LB311:  .byte $00, $00, $00, $80, $C0, $C0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LB321:  .byte $FF, $F0, $E7, $EF, $07, $E0, $F6, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LB331:  .byte $00, $00, $E0, $F0, $F0, $E4, $0E, $BF, $00, $00, $00, $00, $00, $00, $00, $00
LB341:  .byte $01, $00, $07, $0F, $07, $20, $76, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LB351:  .byte $0F, $2F, $F7, $F0, $F2, $E7, $0F, $BF, $00, $00, $00, $00, $00, $00, $00, $00
LB361:  .byte $00, $07, $06, $03, $01, $18, $38, $B8, $03, $07, $07, $07, $03, $1F, $3F, $2F
LB371:  .byte $00, $F0, $B0, $E0, $C0, $0C, $8E, $0E, $E0, $F0, $F0, $F0, $E0, $FC, $FE, $FE
LB381:  .byte $FF, $82, $30, $7C, $FE, $FE, $7E, $00, $00, $00, $00, $00, $00, $00, $00, $00
LB391:  .byte $7F, $01, $FC, $FE, $7E, $3F, $8E, $C1, $00, $00, $00, $00, $00, $00, $00, $00
LB3A1:  .byte $FF, $86, $38, $7C, $FE, $FE, $7E, $00, $00, $00, $00, $00, $00, $00, $00, $00
LB3B1:  .byte $7F, $00, $FC, $F8, $70, $20, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00
LB3C1:  .byte $FF, $06, $38, $1C, $0E, $06, $02, $00, $00, $00, $00, $00, $00, $00, $00, $00
LB3D1:  .byte $7F, $01, $FC, $FE, $7E, $3F, $8E, $C1, $00, $00, $00, $00, $00, $00, $00, $00
LB3E1:  .byte $F8, $CF, $EF, $7E, $3C, $00, $00, $1E, $07, $33, $17, $07, $03, $0F, $0F, $1E
LB3F1:  .byte $0F, $FF, $C7, $7F, $0E, $00, $78, $7C, $FF, $FF, $3F, $83, $FE, $78, $78, $7C
LB401:  .byte $FF, $F0, $E7, $EF, $07, $E0, $F6, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LB411:  .byte $0F, $2F, $F7, $F0, $F2, $E7, $0F, $BF, $00, $00, $00, $00, $00, $00, $00, $00
LB421:  .byte $FF, $F0, $E4, $E8, $00, $E0, $C0, $80, $00, $00, $00, $00, $00, $00, $00, $00
LB431:  .byte $0F, $2F, $37, $10, $02, $07, $03, $01, $00, $00, $00, $00, $00, $00, $00, $00

;----------------------------------------------------------------------------------------------------

;These are the sprites that load the small images of the 11 classes.

ClassSpritesDat:
LB441:  .byte $20, $10, $00, $30, $28, $11, $00, $30, $20, $12, $00, $38, $28, $13, $00, $38
LB451:  .byte $20, $30, $03, $60, $28, $31, $03, $60, $20, $32, $03, $68, $28, $33, $03, $68
LB461:  .byte $20, $50, $00, $90, $28, $51, $00, $90, $20, $52, $00, $98, $28, $53, $00, $98
LB471:  .byte $20, $70, $01, $C0, $28, $71, $01, $C0, $20, $72, $01, $C8, $28, $73, $01, $C8
LB481:  .byte $30, $90, $03, $40, $38, $91, $03, $40, $30, $92, $03, $48, $38, $93, $03, $48
LB491:  .byte $30, $98, $01, $70, $38, $99, $01, $70, $30, $9A, $01, $78, $38, $9B, $01, $78
LB4A1:  .byte $30, $A0, $01, $A0, $38, $A1, $01, $A0, $30, $A2, $01, $A8, $38, $A3, $01, $A8
LB4B1:  .byte $30, $A8, $03, $D0, $38, $A9, $03, $D0, $30, $AA, $03, $D8, $38, $AB, $03, $D8
LB4C1:  .byte $40, $B0, $02, $30, $48, $B1, $02, $30, $40, $B2, $02, $38, $48, $B3, $02, $38
LB4D1:  .byte $40, $B8, $00, $60, $48, $B9, $00, $60, $40, $BA, $00, $68, $48, $BB, $00, $68
LB4E1:  .byte $40, $C0, $01, $90, $48, $C1, $01, $90, $40, $C2, $01, $98, $48, $C3, $01, $98

;----------------------------------------------------------------------------------------------------

;This is the sprite data for the 3 Lord British NPCs in the load game window.

LBSpritesDat:
LB4F1:  .byte $58, $C8, $03, $60, $60, $C9, $03, $60, $58, $CA, $03, $68, $60, $CB, $03, $68
LB501:  .byte $70, $C8, $03, $60, $78, $C9, $03, $60, $70, $CA, $03, $68, $78, $CB, $03, $68
LB511:  .byte $88, $C8, $03, $60, $90, $C9, $03, $60, $88, $CA, $03, $68, $90, $CB, $03, $68

;----------------------------------------------------------------------------------------------------

;Attribute table data when viewing large portraits on the ready-made character screen.

RdyMadeATDat:
LB521:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $50, $10, $00, $80, $A0, $00, $00
LB531:  .byte $00, $55, $11, $00, $88, $AA, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LB541:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LB551:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

;----------------------------------------------------------------------------------------------------

;Attribute table data when viewing large portraits on the hand-made name entry screen.

HndMadeATDat:
LB561:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $44, $55, $00
LB571:  .byte $00, $00, $00, $00, $00, $04, $05, $00, $00, $00, $00, $00, $00, $00, $00, $00
LB581:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LB591:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

;----------------------------------------------------------------------------------------------------

;Unused attribute table data.
LB5A1:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LB5B1:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LB5C1:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $55, $11, $00, $00, $00
LB5D1:  .byte $00, $00, $00, $05, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00                                             

;----------------------------------------------------------------------------------------------------

DoSelArmor:
LB5E1:  LDA #>ArmorDesc
LB5E3:  STA $2A
LB5E5:  LDA #<ArmorDesc
LB5E7:  STA $29

LB5E9:  LDA #$10
LB5EB:  STA Wnd2Width
LB5EE:  LDA #$07
LB5F0:  STA $2E

LB5F2:  LDA #$1B
LB5F4:  PHA
LB5F5:  JMP DoList              ;($B60C)Show list of armor/weapons.

;----------------------------------------------------------------------------------------------------

DoSelWeapon:
LB5F8:  LDA #>WeaponDesc
LB5FA:  STA $2A
LB5FC:  LDA #<WeaponDesc
LB5FE:  STA $29

LB600:  LDA #$10
LB602:  STA Wnd2Width
LB605:  LDA #$0F
LB607:  STA $2E

LB609:  LDA #$0C
LB60B:  PHA

;----------------------------------------------------------------------------------------------------

DoList:
LB60C:  LDA #$06
LB60E:  STA $2C
LB610:  LDA #$00
LB612:  STA $2B

LB614:  LDY #$00
LB616:  LDA ($29),Y
LB618:  STA ($2B),Y
LB61A:  INY
LB61B:  CMP #$FF
LB61D:  BNE LB616

LB61F:  LDX #$00
LB621:  LDY #$01
LB623:  LDA #$00
LB625:  STA TextBufferBase
LB628:  PLA
LB629:  PHA
LB62A:  CMP #$1B
LB62C:  BEQ LB63D

LB62E:* LDA HandTxt,X
LB631:  STA TextBuffer,Y
LB634:  INX
LB635:  INY
LB636:  CMP #$FD
LB638:  BEQ LB64C
LB63A:  JMP -

LB63D:* LDA SkinTxt,X
LB640:  STA TextBuffer,Y
LB643:  INX
LB644:  INY
LB645:  CMP #$FD
LB647:  BEQ LB64C
LB649:  JMP -

LB64C:  LDA #$FF
LB64E:  STA TextBuffer,Y
LB651:  STY $2D
LB653:  LDA #$00
LB655:  STA MultiWindow
LB657:  LDA #$01
LB659:  STA NumMenuItems

LB65B:  LDX #$00
LB65D:  PLA
LB65E:  PHA
LB65F:  TAY

LB660:  TYA
LB661:  PHA
LB662:  LDA (CrntChrPtr),Y
LB664:  BEQ LB6A7

LB666:  INC NumMenuItems
LB668:  JSR LB703

LB66B:  LDY $2D
LB66D:  LDA $0600,X
LB670:  CMP #$FD
LB672:  BEQ LB67C

LB674:  STA TextBuffer,Y
LB677:  INX
LB678:  INY
LB679:  JMP LB66D

LB67C:  STY $2D
LB67E:  PLA
LB67F:  PHA
LB680:  TAY
LB681:  LDA (CrntChrPtr),Y
LB683:  STA BinInputLB
LB685:  LDA #$00
LB687:  STA BinInputUB
LB689:  JSR BinToBCD            ;($9883)Convert 16-bit word to 4 digit number.
LB68C:  LDA BCDOutput2
LB68E:  LDY $2D
LB690:  STA TextBuffer,Y
LB693:  INY
LB694:  LDA BCDOutput3
LB696:  STA TextBuffer,Y
LB699:  INY
LB69A:  LDA #$FD
LB69C:  STA TextBuffer,Y
LB69F:  INY
LB6A0:  LDA #$FF
LB6A2:  STA TextBuffer,Y
LB6A5:  STY $2D
LB6A7:  LDA $0600,X
LB6AA:  INX
LB6AB:  CMP #$FD
LB6AD:  BNE LB6A7
LB6AF:  PLA
LB6B0:  TAY
LB6B1:  INY
LB6B2:  DEC $2E
LB6B4:  BEQ LB6B9

LB6B6:  JMP LB660

LB6B9:  LDA #$0E
LB6BB:  STA Wnd2XPos
LB6BE:  LDA #$06
LB6C0:  STA Wnd2YPos
LB6C3:  LDA NumMenuItems
LB6C5:  CLC
LB6C6:  ADC #$01
LB6C8:  ASL
LB6C9:  STA Wnd2Height
LB6CC:  LDA #$FF
LB6CE:  STA TextIndex2
LB6D1:  JSR LBE2C
LB6D4:  JSR LBBF8
LB6D7:  CMP #$00
LB6D9:  BEQ LB6FE
LB6DB:  SBC #$01
LB6DD:  STA $30
LB6DF:  PLA
LB6E0:  TAY
LB6E1:  LDA #$00
LB6E3:  STA $2E
LB6E5:  LDA (CrntChrPtr),Y
LB6E7:  BNE LB6EF
LB6E9:  INC $2E
LB6EB:  INY
LB6EC:  JMP LB6E5
LB6EF:  LDA $30
LB6F1:  BEQ LB6F8
LB6F3:  DEC $30
LB6F5:  JMP LB6E9
LB6F8:  LDA $2E
LB6FA:  CLC
LB6FB:  ADC #$01
LB6FD:  RTS
LB6FE:  PLA
LB6FF:  LDA #$00
LB701:  CLC
LB702:  RTS

;----------------------------------------------------------------------------------------------------

LB703:  CPY #$0C
LB705:  BCC LB71A

LB707:  CPY #$1B
LB709:  BCS LB71A

LB70B:  TYA
LB70C:  SEC
LB70D:  SBC #$0B
LB70F:  LDY #$34
LB711:  PHA
LB712:  LDA (CrntChrPtr),Y
LB714:  BEQ LB74A
LB716:  PLA
LB717:  JMP LB72E

LB71A:  CPY #$1B
LB71C:  BCC LB749

LB71E:  CPY #$22
LB720:  BCS LB749

LB722:  TYA
LB723:  SEC
LB724:  SBC #$1A
LB726:  LDY #CHR_EQ_ARMOR
LB728:  PHA
LB729:  LDA (CrntChrPtr),Y
LB72B:  BEQ LB74A
LB72D:  PLA

LB72E:  CMP (CrntChrPtr),Y
LB730:  BNE LB73F
LB732:  LDY $2D
LB734:  LDA #$09
LB736:  STA TextBuffer,Y
LB739:  INY
LB73A:  STY $2D
LB73C:  JMP LB749

LB73F:  LDY $2D
LB741:  LDA #$00
LB743:  STA TextBuffer,Y
LB746:  INY
LB747:  STY $2D
LB749:  RTS

LB74A:  PLA
LB74B:  LDA #CHAR_ASTRK
LB74D:  STA TextBufferBase
LB750:  JMP LB73F

LB753:  LDA #$FF
LB755:  STA TextBuffer,X
LB758:  RTS

;----------------------------------------------------------------------------------------------------

;Unused.
LB759:  .byte $A0, $91, $98, $00, $00, $FD, $A9, $F0, $9D, $00, $73, $E8, $E8, $E8, $E8, $88
LB769:  .byte $D0, $F6, $60, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB779:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $A5, $19, $0A, $A8, $A5, $18, $0A, $AA, $B9
LB789:  .byte $91, $00, $85, $2D, $B9, $92, $00, $85, $2E, $B5, $91, $99, $91, $00, $B5, $92
LB799:  .byte $99, $92, $00, $A5, $2D, $95, $91, $A5, $2E, $95, $92, $A5, $19, $0A, $0A, $0A
LB7A9:  .byte $0A, $AA, $A5, $18, $0A, $0A, $0A, $0A, $A8, $60, $FF, $FF, $FF, $FF, $FF, $FF
LB7B9:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB7C9:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB7D9:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB7E9:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB7F9:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF

;----------------------------------------------------------------------------------------------------

LB800:  LDA ScrollDirAmt
LB802:  BEQ LB808
LB804:  CMP #$A0
LB806:  BCC LB800
LB808:  SEC
LB809:  LDA MapXPos
LB80B:  SBC #$07
LB80D:  BCS LB811
LB80F:  LDA #$00
LB811:  STA $2E
LB813:  CLC
LB814:  LDA MapXPos
LB816:  ADC #$08
LB818:  CMP #$40
LB81A:  BCC LB81E
LB81C:  LDA #$40
LB81E:  STA $2D
LB820:  SEC
LB821:  LDA MapYPos
LB823:  SBC #$07
LB825:  BCS LB829
LB827:  LDA #$00
LB829:  STA $2C
LB82B:  CLC
LB82C:  LDA MapYPos
LB82E:  ADC #$07
LB830:  CMP #$40
LB832:  BCC LB836
LB834:  LDA #$40
LB836:  STA $2B
LB838:  LDX #$00
LB83A:  LDA NPCSprIndex,X
LB83D:  CMP #$FF
LB83F:  BNE LB844
LB841:  JMP LB9AA
LB844:  LDA NPCSprIndex+1,X
LB847:  BEQ LB876
LB849:  JSR LB9B6
LB84C:  BCS LB851
LB84E:  JMP LB9AA
LB851:  LDY NPCSprIndex+1,X
LB854:  LDA #SPRT_HIDE
LB856:  STA SpriteBuffer,Y
LB859:  STA $7304,Y
LB85C:  STA $7308,Y
LB85F:  STA $730C,Y
LB862:  LDA #$00
LB864:  STA NPCSprIndex+1,X
LB867:  STA $7301,Y
LB86A:  STA $7305,Y
LB86D:  STA $7309,Y
LB870:  STA $730D,Y
LB873:  JMP LB9AA
LB876:  JSR LB9B6
LB879:  BCS LB898
LB87B:  LDY #$44
LB87D:  LDA NPCSprIndex,X
LB880:  BPL LB884
LB882:  LDY #$84
LB884:  LDA #$04
LB886:  STA $30
LB888:  LDA SpriteBuffer,Y
LB88B:  CMP #$F0
LB88D:  BEQ LB89B
LB88F:  TYA
LB890:  CLC
LB891:  ADC #$10
LB893:  TAY
LB894:  DEC $30
LB896:  BNE LB888
LB898:  JMP LB9AA
LB89B:  TYA
LB89C:  STA NPCSprIndex+1,X
LB89F:  LDA NPCSprIndex+2,X
LB8A2:  SEC
LB8A3:  SBC MapXPos
LB8A5:  CLC
LB8A6:  ADC #$07
LB8A8:  ASL
LB8A9:  ASL
LB8AA:  ASL
LB8AB:  ASL
LB8AC:  STA $19
LB8AE:  LDA NPCSprIndex+3,X
LB8B1:  SEC
LB8B2:  SBC MapYPos
LB8B4:  CLC
LB8B5:  ADC #$07
LB8B7:  ASL
LB8B8:  ASL
LB8B9:  ASL
LB8BA:  ASL
LB8BB:  STA $18
LB8BD:  LDA ScrollDirAmt
LB8BF:  AND #$F0
LB8C1:  BEQ LB900
LB8C3:  EOR #$FF
LB8C5:  LSR
LB8C6:  LSR
LB8C7:  LSR
LB8C8:  LSR
LB8C9:  STA $30
LB8CB:  LDA ScrollDirAmt
LB8CD:  AND #$0F
LB8CF:  CMP #$02
LB8D1:  BNE LB8DD
LB8D3:  CLC
LB8D4:  LDA $19
LB8D6:  SBC $30
LB8D8:  STA $19
LB8DA:  JMP LB900
LB8DD:  CMP #$01
LB8DF:  BNE LB8EB
LB8E1:  SEC
LB8E2:  LDA $30
LB8E4:  ADC $19
LB8E6:  STA $19
LB8E8:  JMP LB900
LB8EB:  CMP #$04
LB8ED:  BNE LB8F9
LB8EF:  SEC
LB8F0:  LDA $30
LB8F2:  ADC $18
LB8F4:  STA $18
LB8F6:  JMP LB900
LB8F9:  CLC
LB8FA:  LDA $18
LB8FC:  SBC $30
LB8FE:  STA $18
LB900:  LDY NPCSprIndex+1,X
LB903:  LDA $19
LB905:  STA $7303,Y
LB908:  STA $7307,Y
LB90B:  CLC
LB90C:  ADC #$08
LB90E:  STA $730B,Y
LB911:  STA $730F,Y
LB914:  LDA $18
LB916:  STA SpriteBuffer,Y
LB919:  STA $7308,Y
LB91C:  CLC
LB91D:  ADC #$08
LB91F:  STA $7304,Y
LB922:  STA $730C,Y
LB925:  TYA
LB926:  PHA
LB927:  TXA
LB928:  PHA
LB929:  LDA $2E
LB92B:  PHA
LB92C:  LDA $2D
LB92E:  PHA
LB92F:  LDA $2C
LB931:  PHA
LB932:  LDA $2B
LB934:  PHA
LB935:  TYA
LB936:  PHA
LB937:  LDA NPCSprIndex+1,X
LB93A:  SEC
LB93B:  SBC #$44
LB93D:  LSR
LB93E:  LSR
LB93F:  LSR
LB940:  TAY
LB941:  STY $18
LB943:  LDA NPCSprIndex,X
LB946:  AND #$7F
LB948:  ASL
LB949:  CLC
LB94A:  ADC #$80
LB94C:  STA $77E1,Y
LB94F:  LDA #$00
LB951:  STA $77E0,Y
LB954:  LDA NPCSprIndex,X
LB957:  AND #$7F
LB959:  TAX
LB95A:  LDA $BA08,X
LB95D:  STA $19
LB95F:  PLA
LB960:  TAY
LB961:  LDA $18
LB963:  ASL
LB964:  ASL
LB965:  CLC
LB966:  ADC #$90
LB968:  STA $7301,Y
LB96B:  CLC
LB96C:  ADC #$01
LB96E:  STA $7305,Y
LB971:  CLC
LB972:  ADC #$01
LB974:  STA $7309,Y
LB977:  CLC
LB978:  ADC #$01
LB97A:  STA $730D,Y
LB97D:  LDA $19
LB97F:  STA $7302,Y
LB982:  STA $7306,Y
LB985:  STA $730A,Y
LB988:  STA $730E,Y
LB98B:  LDY $18
LB98D:  LDA #$01
LB98F:  STA UnusedB0            ;No effect.
LB991:  LDA #$00
LB993:  JSR $C03C
LB996:  LDA #$00
LB998:  STA UnusedB0            ;No effect.
LB99A:  PLA
LB99B:  STA $2B
LB99D:  PLA
LB99E:  STA $2C
LB9A0:  PLA
LB9A1:  STA $2D
LB9A3:  PLA
LB9A4:  STA $2E
LB9A6:  PLA
LB9A7:  TAX
LB9A8:  PLA
LB9A9:  TAY
LB9AA:  INX
LB9AB:  INX
LB9AC:  INX
LB9AD:  INX
LB9AE:  CPX #$80
LB9B0:  BEQ LB9B5
LB9B2:  JMP LB83A
LB9B5:  RTS
LB9B6:  LDA MapProperties
LB9B8:  AND #$04
LB9BA:  BEQ LB9EE
LB9BC:  TYA
LB9BD:  PHA
LB9BE:  LDY #$00
LB9C0:  LDA MapXPos
LB9C2:  SEC
LB9C3:  SBC NPCSprIndex+2,X
LB9C6:  BMI LB9CA
LB9C8:  EOR #$FF
LB9CA:  CMP #$F8
LB9CC:  JSR LB9E5
LB9CF:  LDA MapYPos
LB9D1:  SEC
LB9D2:  SBC NPCSprIndex+3,X
LB9D5:  BMI LB9DB
LB9D7:  EOR #$FF
LB9D9:  ADC #$00
LB9DB:  CMP #$F9
LB9DD:  JSR LB9E5
LB9E0:  CPY #$01
LB9E2:  PLA
LB9E3:  TAY
LB9E4:  RTS
LB9E5:  BPL LB9ED
LB9E7:  CMP #$C8
LB9E9:  BMI LB9ED
LB9EB:  LDY #$FF
LB9ED:  RTS

LB9EE:  LDA NPCSprIndex+2,X
LB9F1:  CMP $2E
LB9F3:  BCC LBA06
LB9F5:  CMP $2D
LB9F7:  BCS LBA06
LB9F9:  LDA NPCSprIndex+3,X
LB9FC:  CMP $2C
LB9FE:  BCC LBA06
LBA00:  CMP $2B
LBA02:  BCS LBA06
LBA04:  CLC
LBA05:  RTS
LBA06:  SEC
LBA07:  RTS

LBA08:  .byte $03, $00, $00, $00, $01, $03, $00, $03, $00, $00, $00, $03, $03, $03, $01, $03
LBA18:  .byte $00, $00, $03, $00, $00, $02, $02, $02, $02, $02, $02, $02, $02, $03, $00

;----------------------------------------------------------------------------------------------------

Multiply:
LBA27:  TXA                     ;
LBA28:  PHA                     ;
LBA29:  LDA #$00                ;
LBA2B:  STA MultOutLB           ;
LBA2D:  LDX #$08                ;
LBA2F:* LSR MultIn0             ;
LBA31:  BCC +                   ;
LBA33:  CLC                     ;Take 2 8-bit number and multiply them
LBA34:  ADC MultIn1             ;together. The result is a 16-byte number.
LBA36:* ROR                     ;
LBA37:  ROR MultOutLB           ;
LBA39:  DEX                     ;
LBA3A:  BNE --                  ;
LBA3C:  STA MultOutUB           ;
LBA3E:  PLA                     ;
LBA3F:  TAX                     ;
LBA40:  RTS                     ;

;----------------------------------------------------------------------------------------------------

LoadSGData:
LBA41:  LDY #SG_BOAT_X          ;
LBA43:  LDA (SGDatPtr),Y        ;Get the boat X coord from the saved game.
LBA45:  STA BoatXPos            ;

LBA48:  INY                     ;
LBA49:  LDA (SGDatPtr),Y        ;Get the boat Y coord from the saved game.
LBA4B:  STA BoatYPos            ;

LBA4E:  LDY #SG_HORSE           ;
LBA50:  LDA (SGDatPtr),Y        ;Get the horse status from the saved game.
LBA52:  STA OnHorse             ;

LBA54:  LDY #SG_BRIB_PRAY       ;
LBA56:  LDA (SGDatPtr),Y        ;Get the bribe/pray commands from the saved game.
LBA58:  STA BribePray           ;

LBA5A:  LDY #SG_PARTY_X         ;
LBA5C:  LDA (SGDatPtr),Y        ;Get the party's X coord from the saved game.
LBA5E:  STA MapXPos             ;

LBA60:  INY                     ;
LBA61:  LDA (SGDatPtr),Y        ;Get the party's Y coord from the saved game.
LBA63:  STA MapYPos             ;

LBA65:  LDY #SG_MAP_PROPS       ;
LBA67:  LDA (SGDatPtr),Y        ;Get the current map's properties from the saved game.
LBA69:  STA MapProperties       ;

LBA6B:  INY                     ;
LBA6C:  LDA (SGDatPtr),Y        ;get the current map from the saved game.
LBA6E:  STA ThisMap             ;

;Get Character data.
LBA70:  LDY #SG_CHR1_INDEX      ;
LBA72:  LDA (SGDatPtr),Y        ;
LBA74:  STA Ch1Index            ;
LBA77:  INY                     ;
LBA78:  LDA (SGDatPtr),Y        ;
LBA7A:  STA Ch2Index            ;Get the index of each of the 4 characters from the character pool.
LBA7D:  INY                     ;
LBA7E:  LDA (SGDatPtr),Y        ;
LBA80:  STA Ch3Index            ;
LBA83:  INY                     ;
LBA84:  LDA (SGDatPtr),Y        ;
LBA86:  STA Ch4Index            ;

LBA89:  LDA #>Ch1Data           ;
LBA8B:  STA GenPtr29UB          ;Set the pointer to the 1st character's data.
LBA8D:  LDA #<Ch1Data           ;
LBA8F:  STA GenPtr29LB          ;

LBA91:  LDA #SG_CHR1_INDEX      ;Set an index to the 1st character's index in the character pool.
LBA93:  STA GenByte30           ;

LoadCharDatLoop:
LBA95:  LDY GenByte30           ;
LBA97:  LDA (SGDatPtr),Y        ;Get the index to the character's data.
LBA99:  STA MultIn0             ;

LBA9B:  LDA #$40                ;*64. 64 bytes per character.
LBA9D:  STA MultIn1             ;
LBA9F:  JSR Multiply            ;($BA27)Multiply 2 bytes for a 16 byte result.

LBAA2:  CLC                     ;
LBAA3:  LDA SGDatPtrLB          ;
LBAA5:  ADC MultOutLB           ;Set the pointer to the base of the character's data.
LBAA7:  STA ChrDestPtrLB        ;
LBAA9:  LDA SGDatPtrUB          ;
LBAAB:  ADC MultOutUB           ;
LBAAD:  STA ChrDestPtrUB        ;

LBAAF:  INC ChrDestPtrUB        ;Data is offset by 256 bytes.
LBAB1:  LDY #$00                ;

LBAB3:* LDA (ChrDestPtr),Y      ;
LBAB5:  STA (GenPtr29),Y        ;Transfer the 64 bytes of character
LBAB7:  INY                     ;data into the given character slot.
LBAB8:  CPY #$40                ;
LBABA:  BNE -                   ;

LBABC:  CLC                     ;
LBABD:  LDA GenPtr29LB          ;Move pointer to the next character's data.
LBABF:  ADC #$40                ;
LBAC1:  STA GenPtr29LB          ;

LBAC3:  INC GenByte30           ;
LBAC5:  LDA GenByte30           ;Has the data for all 4 characters been loaded?
LBAC7:  CMP #$14                ;If not, branch to get the next character's data.
LBAC9:  BNE LoadCharDatLoop     ;

;Load map data.
LBACB:  LDA ThisMap             ;
LBACD:  ASL                     ;
LBACE:  ASL                     ;*8. 8 bytes of data per map.
LBACF:  ASL                     ;
LBAD0:  TAX                     ;

LBAD1:  LDA MapDatTbl,X         ;
LBAD4:  STA MapBank             ;Get the bank the map data is located on.
LBAD6:  INX                     ;

LBAD7:  LDA MapDatTbl,X         ;
LBADA:  STA _MapDatPtrLB        ;
LBADC:  STA MapDatPtrLB         ;
LBADE:  INX                     ;Get a pointer to the map layout data.
LBADF:  LDA MapDatTbl,X         ;
LBAE2:  STA MapDatPtrUB         ;
LBAE4:  STA _MapDatPtrUB        ;
LBAE6:  INX                     ;

LBAE7:  LDA MapDatTbl,X         ;
LBAEA:  STA NPCSrcPtrLB         ;
LBAEC:  INX                     ;Get a pointer to the map NPC data.
LBAED:  LDA MapDatTbl,X         ;
LBAF0:  STA NPCSrcPtrUB         ;

;Load return position when exiting map to the overworld map.
LBAF2:  LDA ThisMap             ;
LBAF4:  ASL                     ;*2. 2 bytes of data per map.
LBAF5:  TAX                     ;

LBAF6:  LDA SubMapTbl,X         ;
LBAF9:  STA ReturnXPos          ;
LBAFB:  LDA SubMapTbl+1,X       ;Get the X,Y coordinates on overworld map when exiting current map.
LBAFE:  STA ReturnYPos          ;
LBB00:  RTS                     ;

;----------------------------------------------------------------------------------------------------

WeaponDesc:
;              D    A    G    G    E    R    _    _    _    \n
LBB01:  .byte $8D, $8A, $90, $90, $8E, $9B, $00, $00, $00, $FD
;              M    A    C    E    _    _    _    _    _    \n
LBB0B:  .byte $96, $8A, $8C, $8E, $00, $00, $00, $00, $00, $FD
;              S    L    I    N    G    _    _    _    _    \n
LBB15:  .byte $9C, $95, $92, $97, $90, $00, $00, $00, $00, $FD
;              A    X    _    _    _    _    _    _    _    \n
LBB1F:  .byte $8A, $A1, $00, $00, $00, $00, $00, $00, $00, $FD
;              B    L    O    W    G    U    N    _    _    \n
LBB29:  .byte $8B, $95, $98, $A0, $90, $9E, $97, $00, $00, $FD
;              S    W    O    R    D    _    _    _    _    \n
LBB33:  .byte $9C, $A0, $98, $9B, $8D, $00, $00, $00, $00, $FD
;              S    P    E    A    R    _    _    _    _    \n
LBB3D:  .byte $9C, $99, $8E, $8A, $9B, $00, $00, $00, $00, $FD
;              B    R    O    A    D    _    A    X    _    \n
LBB47:  .byte $8B, $9B, $98, $8A, $8D, $00, $8A, $A1, $00, $FD
;              B    o    W    _    _    _    _    _    _    \n
LBB51:  .byte $8B, $98, $A0, $00, $00, $00, $00, $00, $00, $FD
;              I    R    O    N    _    S    W    R    D    \n
LBB5B:  .byte $92, $9B, $98, $97, $00, $9C, $A0, $9B, $8D, $FD
;              G    L    O    V    E    S    _    _    _    \n
LBB65:  .byte $90, $95, $98, $9F, $8E, $9C, $00, $00, $00, $FD
;              F    T    R    '    S    _    A    X    _    \n
LBB6F:  .byte $8F, $9D, $9B, $04, $9C, $00, $8A, $A1, $00, $FD
;              S    L    V    _    B    O    W    _    _    \n
LBB79:  .byte $9C, $95, $9F, $00, $8B, $98, $A0, $00, $00, $FD
;              S    U    N    _    S    W    R    D    _    \n
LBB83:  .byte $9C, $9E, $97, $00, $9C, $A0, $9B, $8D, $00, $FD
;              M    Y    S    T    I    C    _    W    .    \n
LBB8D:  .byte $96, $A2, $9C, $9D, $92, $8C, $00, $A0, $43, $FD

ArmorDesc:
;              C    L    O    T    H    _    _    _    _    \n
LBB97:  .byte $8C, $95, $98, $9D, $91, $00, $00, $00, $00, $FD
;              L    E    A    T    H    E    R    _    _    \n
LBBA1:  .byte $95, $8E, $8A, $9D, $91, $8E, $9B, $00, $00, $FD
;              B    R    O    N    Z    E    _    _    _    \n
LBBAB:  .byte $8B, $9B, $98, $97, $A3, $8E, $00, $00, $00, $FD
;              I    R    O    N    _    _    _    _    _    \n
LBBB5:  .byte $92, $9B, $98, $97, $00, $00, $00, $00, $00, $FD
;              S    T    E    E    L    _    _    _    _    \n
LBBBF:  .byte $9C, $9D, $8E, $8E, $95, $00, $00, $00, $00, $FD
;              D    R    G    N    _    A    R    M    _    \n
LBBC9:  .byte $8D, $9B, $90, $97, $00, $8A, $9B, $96, $00, $FD
;              M    Y    S    T    I    C    _    A    .    \n  END
LBBD3:  .byte $96, $A2, $9C, $9D, $92, $8C, $00, $8A, $43, $FD, $FF

HandTxt:
;              H    A    N    D    _    _    _    _    _    _    _    _    \n
LBBDE:  .byte $91, $8A, $97, $8D, $00, $00, $00, $00, $00, $00, $00, $00, $FD

SkinTxt:
;              S    K    I    N    _    _    _    _    _    _    _    _    \n
LBBEB:  .byte $9C, $94, $92, $97, $00, $00, $00, $00, $00, $00, $00, $00, $FD                        

;----------------------------------------------------------------------------------------------------

LBBF8:  LDA HideUprSprites
LBBFA:  STA HideSpriteTemp

LBBFC:  LDA Wnd2XPos
LBBFF:  STA $2A
LBC01:  LDA Wnd2YPos
LBC04:  STA $29
LBC06:  LDA Wnd2Width
LBC09:  STA $2E
LBC0B:  LDA Wnd2Height
LBC0E:  STA $2D
LBC10:  JSR DrawWndBrdr         ;($97A9)Draw window border.

LBC13:  LDA TextIndex2
LBC16:  STA $30
LBC18:  LDA Wnd2XPos
LBC1B:  CLC
LBC1C:  ADC #$02
LBC1E:  STA $2A
LBC20:  LDA Wnd2YPos
LBC23:  CLC
LBC24:  ADC #$02
LBC26:  STA $29
LBC28:  LDA Wnd2Width
LBC2B:  SEC
LBC2C:  SBC #$03
LBC2E:  STA $2E
LBC30:  SEC
LBC31:  LDA Wnd2Height
LBC34:  SBC #$02
LBC36:  LSR
LBC37:  STA $2D

LBC39:  LDA HideSpriteTemp
LBC3B:  STA HideUprSprites

LBC3D:  JSR ShowTextString      ;($995C)Show a text string on the screen.
LBC40:  LDA $9C
LBC42:  CLC
LBC43:  ADC #$01
LBC45:  ASL
LBC46:  STA $2E
LBC48:  LDX #$02
LBC4A:  SEC
LBC4B:  LDA Wnd2Height
LBC4E:  SBC $2E
LBC50:  BEQ LBC56
LBC52:  CLC
LBC53:  ADC #$02
LBC55:  TAX
LBC56:  STX $2E
LBC58:  LDA Wnd2YPos
LBC5B:  CLC
LBC5C:  ADC $2E
LBC5E:  ASL
LBC5F:  ASL
LBC60:  ASL
LBC61:  STA SpriteBuffer
LBC64:  LDA Wnd2XPos
LBC67:  CLC
LBC68:  ADC #$01
LBC6A:  ASL
LBC6B:  ASL
LBC6C:  ASL
LBC6D:  STA $7303
LBC70:  LDA #$01
LBC72:  STA $2E
LBC74:  LDA $9C
LBC76:  STA $2D
LBC78:  JSR LBCE9
LBC7B:  BCS LBC40
LBC7D:  CMP #$FF
LBC7F:  BNE LBCD5
LBC81:  LDA MultiWindow
LBC83:  BEQ LBC40
LBC85:  AND #$80
LBC87:  BEQ LBCA0
LBC89:  LDA MultiWindow
LBC8B:  AND #$7F
LBC8D:  STA MultiWindow
LBC8F:  LDA #$08
LBC91:  STA $9C
LBC93:  LDA #$12
LBC95:  STA Wnd2Height
LBC98:  LDA TextIndex2
LBC9B:  STA $30
LBC9D:  JMP LBBF8
LBCA0:  LDA MultiWindow
LBCA2:  ORA #$80
LBCA4:  STA MultiWindow
LBCA6:  AND #$7F
LBCA8:  SEC
LBCA9:  SBC #$08
LBCAB:  STA $9C
LBCAD:  CLC
LBCAE:  ADC #$01
LBCB0:  ASL
LBCB1:  STA Wnd2Height
LBCB4:  LDA Wnd2XPos
LBCB7:  STA $2A
LBCB9:  LDA Wnd2YPos
LBCBC:  STA $29
LBCBE:  LDA Wnd2Width
LBCC1:  STA $2E
LBCC3:  LDA #$12
LBCC5:  STA $2D
LBCC7:  JSR DrawWndBrdr         ;($97A9)Draw window border.
LBCCA:  LDA TextIndex2
LBCCD:  CLC
LBCCE:  ADC #$01
LBCD0:  STA $30
LBCD2:  JMP LBC18
LBCD5:  STA $2E
LBCD7:  LDX #$00
LBCD9:  LDA MultiWindow
LBCDB:  BPL LBCDF
LBCDD:  LDX #$08
LBCDF:  CLC
LBCE0:  TXA
LBCE1:  ADC $2E
LBCE3:  PHA
LBCE4:  PLA
LBCE5:  CLC
LBCE6:  RTS
LBCE7:  SEC
LBCE8:  RTS

;----------------------------------------------------------------------------------------------------

LBCE9:  LDA #$00
LBCEB:  STA $2C
LBCED:  LDA $BF
LBCEF:  STA $2B
LBCF1:  ASL
LBCF2:  ASL
LBCF3:  ASL
LBCF4:  ASL
LBCF5:  CLC
LBCF6:  ADC SpriteBuffer
LBCF9:  STA SpriteBuffer
LBCFC:  LDA #$FF
LBCFE:  STA $9B
LBD00:  JSR LBE15
LBD03:  LDX #$01
LBD05:  CMP #$01
LBD07:  BEQ LBD30
LBD09:  LDX #$FF
LBD0B:  CMP #$02
LBD0D:  BEQ LBD30
LBD0F:  LDX #$01
LBD11:  CMP #$04
LBD13:  BEQ LBD7A
LBD15:  LDX #$FF
LBD17:  CMP #$08
LBD19:  BEQ LBD7A
LBD1B:  CMP #$80
LBD1D:  BEQ LBD2A
LBD1F:  CMP #$40
LBD21:  BEQ LBD2D
LBD23:  CMP #$20
LBD25:  BNE LBCFC
LBD27:  JMP LBDDA
LBD2A:  JMP LBDC4
LBD2D:  JMP LBDC2
LBD30:  CLC
LBD31:  TXA
LBD32:  ADC $2C
LBD34:  CMP #$FF
LBD36:  BEQ LBD4F
LBD38:  CMP $2E
LBD3A:  BEQ LBD61
LBD3C:  STA $2C
LBD3E:  TXA
LBD3F:  ASL
LBD40:  ASL
LBD41:  ASL
LBD42:  ASL
LBD43:  ASL
LBD44:  ASL
LBD45:  CLC
LBD46:  ADC $7303
LBD49:  STA $7303
LBD4C:  JMP LBCFC
LBD4F:  LDA $2E
LBD51:  SEC
LBD52:  SBC #$01
LBD54:  STA $2C
LBD56:  ASL
LBD57:  ASL
LBD58:  ASL
LBD59:  ASL
LBD5A:  CLC
LBD5B:  ADC $7303
LBD5E:  JMP LBD49
LBD61:  LDA #$00
LBD63:  STA $2C
LBD65:  LDA $2E
LBD67:  SEC
LBD68:  SBC #$01
LBD6A:  ASL
LBD6B:  ASL
LBD6C:  ASL
LBD6D:  ASL
LBD6E:  SEC
LBD6F:  SBC $7303
LBD72:  EOR #$FF
LBD74:  CLC
LBD75:  ADC #$01
LBD77:  JMP LBD49
LBD7A:  CLC
LBD7B:  TXA
LBD7C:  ADC $2B
LBD7E:  CMP #$FF
LBD80:  BEQ LBD97
LBD82:  CMP $2D
LBD84:  BEQ LBDA9
LBD86:  STA $2B
LBD88:  TXA
LBD89:  ASL
LBD8A:  ASL
LBD8B:  ASL
LBD8C:  ASL
LBD8D:  CLC
LBD8E:  ADC SpriteBuffer
LBD91:  STA SpriteBuffer
LBD94:  JMP LBCFC
LBD97:  LDA $2D
LBD99:  SEC
LBD9A:  SBC #$01
LBD9C:  STA $2B
LBD9E:  ASL
LBD9F:  ASL
LBDA0:  ASL
LBDA1:  ASL
LBDA2:  CLC
LBDA3:  ADC SpriteBuffer
LBDA6:  JMP LBD91
LBDA9:  LDA #$00
LBDAB:  STA $2B
LBDAD:  LDA $2D
LBDAF:  SEC
LBDB0:  SBC #$01
LBDB2:  ASL
LBDB3:  ASL
LBDB4:  ASL
LBDB5:  ASL
LBDB6:  SEC
LBDB7:  SBC SpriteBuffer
LBDBA:  EOR #$FF
LBDBC:  CLC
LBDBD:  ADC #$01
LBDBF:  JMP LBD91
LBDC2:  SEC
LBDC3:  RTS
LBDC4:  LDA $2C
LBDC6:  PHA
LBDC7:  INC $2C
LBDC9:  LDA #$00
LBDCB:  CLC
LBDCC:  ADC $2B
LBDCE:  DEC $2C
LBDD0:  BNE LBDCB
LBDD2:  STA $2B
LBDD4:  PLA
LBDD5:  CLC
LBDD6:  ADC $2B
LBDD8:  CLC
LBDD9:  RTS
LBDDA:  LDA #$FF
LBDDC:  CLC
LBDDD:  RTS
LBDDE:  PHA
LBDDF:  TXA
LBDE0:  PHA
LBDE1:  LDX #$C4
LBDE3:  LDA SpriteBuffer,X
LBDE6:  CMP #$F0
LBDE8:  BEQ LBDF4
LBDEA:  TXA
LBDEB:  CLC
LBDEC:  ADC #$04
LBDEE:  TAX
LBDEF:  BEQ LBE0C
LBDF1:  JMP LBDE3
LBDF4:  LDA SpriteBuffer
LBDF7:  STA SpriteBuffer,X
LBDFA:  LDA $7301
LBDFD:  STA $7301,X
LBE00:  LDA $7302
LBE03:  STA $7302,X
LBE06:  LDA $7303
LBE09:  STA $7303,X
LBE0C:  LDA #SPRT_HIDE
LBE0E:  STA SpriteBuffer
LBE11:  PLA
LBE12:  TAX
LBE13:  PLA
LBE14:  RTS

LBE15:  LDA #$00
LBE17:  STA IgnoreInput
LBE19:  STA InputChange
LBE1B:  LDA $00
LBE1D:  CMP $00
LBE1F:  BEQ LBE1D
LBE21:  LDA InputChange
LBE23:  BEQ LBE15
LBE25:  LDA Pad1Input
LBE27:  AND $9B
LBE29:  BEQ LBE15
LBE2B:  RTS

LBE2C:  LDX #$00
LBE2E:  LDY #$00
LBE30:  LDA TextBuffer,X
LBE33:  CMP #$FF
LBE35:  BEQ LBE46
LBE37:  CMP #$FD
LBE39:  BEQ LBE42
LBE3B:  CMP #$09
LBE3D:  BNE LBE43
LBE3F:  STY $BF
LBE41:  RTS

LBE42:  INY
LBE43:  INX
LBE44:  BNE LBE30
LBE46:  LDA #$00
LBE48:  STA $BF
LBE4A:  RTS

;----------------------------------------------------------------------------------------------------

WaitSomeFrames:
LBE4B:  CLC
LBE4C:  ADC Increment0
LBE4E:* CMP Increment0
LBE50:  BNE -
LBE52:  RTS

;----------------------------------------------------------------------------------------------------

InitSGSlot:
LBE53:  LDY #SG_BOAT_X          ;
LBE55:  LDA #SG_NONE            ;
LBE57:  STA (SGDatPtr),Y        ;Make sure save game has no boats.
LBE59:  INY                     ;
LBE5A:  STA (SGDatPtr),Y        ;

LBE5C:  LDY #SG_HORSE           ;
LBE5E:  LDA #$00                ;Make sure save game has no horses.
LBE60:  STA (SGDatPtr),Y        ;

LBE62:  LDY #SG_BRIB_PRAY       ;Make sure save game has no bribe and pray commands.
LBE64:  STA (SGDatPtr),Y        ;

LBE66:  LDY #SG_PARTY_X         ;
LBE68:  LDA #$2D                ;
LBE6A:  STA (SGDatPtr),Y        ;Set party starting map position X,Y=$2D,$13.
LBE6C:  INY                     ;
LBE6D:  LDA #$13                ;
LBE6F:  STA (SGDatPtr),Y        ;

LBE71:  LDY #SG_MAP_PROPS       ;
LBE73:  LDA #$0C                ;Set map properties(show moon phases).
LBE75:  STA (SGDatPtr),Y        ;

LBE77:  INY                     ;
LBE78:  LDA #MAP_OVERWORLD      ;Set current map as overworld map.
LBE7A:  STA (SGDatPtr),Y        ;

LBE7C:  LDY #SG_CHR1_INDEX      ;
LBE7E:  LDA #SG_NONE            ;
LBE80:  STA (SGDatPtr),Y        ;
LBE82:  INY                     ;
LBE83:  STA (SGDatPtr),Y        ;Make sure save game has no characters selected from character pool.
LBE85:  INY                     ;
LBE86:  STA (SGDatPtr),Y        ;
LBE88:  INY                     ;
LBE89:  STA (SGDatPtr),Y        ;
LBE8B:  RTS                     ;

;----------------------------------------------------------------------------------------------------

;Unused code from Bank B.
LBE8C:  .byte $9D, $00, $03, $E8, $A9, $E0, $9D, $00, $03, $E8, $A0, $00, $B9, $60, $05, $9D
LBE9C:  .byte $00, $03, $E8, $C8, $C0, $20, $D0, $F4, $20, $CA, $B6, $60

;----------------------------------------------------------------------------------------------------

;Unused.
LBEA8:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBEB8:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBEC8:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBED8:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBEE8:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBEF8:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

;----------------------------------------------------------------------------------------------------

;Unused code from Bank B.
LBF00:  .byte $A9, $A6, $85, $D6, $A2, $02, $8A, $48, $A9, $40, $85, $30, $20, $FF, $B5, $A5
LBF10:  .byte $BA, $85, $48, $A9, $40, $85, $30, $20, $FF, $B5, $A5, $BA, $85, $47, $20, $75
LBF20:  .byte $BD, $B0, $2B, $38, $A5, $4A, $E5, $48, $18, $69, $07, $29, $0F, $85, $2E, $38
LBF30:  .byte $A5, $49, $E5, $47, $18, $69, $07, $C9, $0F, $29, $0F, $0A, $0A, $0A, $0A, $05
LBF40:  .byte $2E, $A8, $B9, $00, $07, $29, $70, $09, $04, $09, $80, $99, $00, $07, $A9, $00
LBF50:  .byte $85, $2E, $A5, $47, $29, $3F, $0A, $26, $2E, $0A, $26, $2E, $0A, $26, $2E, $0A
LBF60:  .byte $26, $2E, $0A, $26, $2E, $85, $30, $A5, $48, $4A, $05, $30, $18, $69, $00, $85
LBF70:  .byte $43, $A5, $2E, $69, $78, $85, $44, $A0, $00, $A5, $4A, $4A, $B1, $43, $B0, $06
LBF80:  .byte $29, $0F, $09, $40, $90, $04, $29, $F0, $09, $04, $91, $43, $68, $AA, $CA, $F0
LBF90:  .byte $03, $4C, $06, $BF, $60                                 

;----------------------------------------------------------------------------------------------------

;Unused.
LBF95:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

;----------------------------------------------------------------------------------------------------

_RESET:
LBFA0:  LDA #$00                ;Disable NMI.
LBFA2:  STA PPUControl0         ;

LBFA5:  LDX #$02                ;
LBFA7:* LDA PPUStatus           ;Wait for at least one full screen to be drawn before continuing.
LBFAA:  BPL -                   ;Writes to PPUControl register are ignored for 30,000 clock cycles
LBFAC:  DEX                     ;after reset or power cycle.
LBFAD:  BNE -                   ;

LBFAF:  ORA #$FF                ;Reset the MMC1 chip. Bank0F at address $C000.
LBFB1:  STA MMCCfg              ;

LBFB4:  LDA #$1E                ;Configure the MMC1. Vertical mirroring, Last bank fixed.
LBFB6:  JSR ConfigMMC           ;($FFBC)Configure MMC1 mapper.
LBFB9:  JMP Reset1              ;($C000)Begin resetting the game.

;----------------------------------------------------------------------------------------------------

LBFBC:  STA MMCCfg              ;
LBFBF:  LSR                     ;
LBFC0:  STA MMCCfg              ;
LBFC3:  LSR                     ;
LBFC4:  STA MMCCfg              ;Load MMC1 configuration.
LBFC7:  LSR                     ;
LBFC8:  STA MMCCfg              ;
LBFCB:  LSR                     ;
LBFCC:  STA MMCCfg              ;
LBFCF:  RTS                     ;

;----------------------------------------------------------------------------------------------------

;Unused.
LBFD0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBFE0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

;----------------------------------------------------------------------------------------------------

_NMI:
_IRQ:
LBFF0:  RTI                     ;Return from interrupt if ever executed.

;----------------------------------------------------------------------------------------------------

;Unused.
LBFF1:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

;----------------------------------------------------------------------------------------------------

LBFFA:  .word NMI               ;($FFF0)NMI vector.
LBFFC:  .word RESET             ;($FFA0)Reset vector.
LBFFE:  .word IRQ               ;($FFF0)IRQ vector.
