.org $8000

.include "Ultima_3_Defines.asm"

;----------------------------------------------------------------------------------------------------

;Forward declarations.

.alias  Reset1                  $C000
.alias  RESET                   $FFA0
.alias  ConfigMMC               $FFBC
.alias  NMI                     $FFF0
.alias  IRQ                     $FFF0

;----------------------------------------------------------------------------------------------------

InitMusic:
L8000:  CMP #MUS_INTRO          ;Is music to be played a valid music number?
L8002:  BCC +                   ;If so, branch.
L8004:  LDA #MUS_INTRO          ;Prepare to turn off music.

L8006:* CMP MusCurrent          ;Is new music the same as the current music?
L8009:  BNE GetMusPointers      ;If not, branch to start new music,
L800B:  RTS                     ;else exit.

GetMusPointers:
L800C:  STA MusCurrent          ;Update the current music track number being played.
L800F:  ASL                     ;
L8010:  ASL                     ;
L8011:  ASL                     ;*8. 8 bytes of data for music pointers(1 word per channel).
L8012:  TAY                     ;

L8013:  LDA MusicPtrTbl,Y       ;
L8016:  STA SQ1DatPtrLB         ;
L8018:  INY                     ;
L8019:  LDA MusicPtrTbl,Y       ;
L801C:  STA SQ1DatPtrUB         ;
L801E:  INY                     ;
L801F:  LDA MusicPtrTbl,Y       ;
L8022:  STA SQ2DatPtrLB         ;
L8024:  INY                     ;
L8025:  LDA MusicPtrTbl,Y       ;
L8028:  STA SQ2DatPtrUB         ;Load pointer data for the desired music from the table below.
L802A:  INY                     ;
L802B:  LDA MusicPtrTbl,Y       ;
L802E:  STA TriDatPtrLB         ;
L8030:  INY                     ;
L8031:  LDA MusicPtrTbl,Y       ;
L8034:  STA TriDatPtrUB         ;
L8036:  INY                     ;
L8037:  LDA MusicPtrTbl,Y       ;
L803A:  STA NseDatPtrLB         ;
L803C:  INY                     ;
L803D:  LDA MusicPtrTbl,Y       ;
L8040:  STA NseDatPtrUB         ;

L8042:  LDA #$01                ;
L8044:  STA SQ1LenCounter       ;
L8047:  STA SQ2LenCounter       ;Set all counters to expire so all channels update immediately.
L804A:  STA TriLenCounter       ;
L804D:  STA NseLenCounter       ;
L8050:  RTS                     ;

;----------------------------------------------------------------------------------------------------

;The following table contains the pointers to the music channel data for the various songs.
;The first word is for the SQ1 data, followed by SQ2, tiangle and noise data, respectively.

MusicPtrTbl:
L8051:  .word DungeonSQ1,   DungeonSQ2,   DungeonTri,   MusNone ;Dungeon music.
l8058:  .word TownSQ1,      TownSQ2,      TownTri,      MusNone ;Town music.
L8061:  .word BoatSQ1,      BoatSQ2,      BoatTri,      MusNone ;Boat music.
L8068:  .word EndSQ1,       EndSQ2,       EndTri,       MusNone ;End music.
L8071:  .word AmbrosiaSQ1,  AmbrosiaSQ2,  AmbrosiaTri,  MusNone ;Ambrosia music.
L8078:  .word FightSQ1,     FightSQ2,     FightTri,     MusNone ;Fight music.
L8081:  .word ExodusSQ1,    ExodusSQ2,    ExodusTri,    MusNone ;Exodus castle music.
L8088:  .word UnusedSQ1,    UnusedSQ2,    UnusedTri,    MusNone ;Unused theme music.
L8091:  .word OverworldSQ1, OverworldSQ2, OverworldTri, MusNone ;Overworld music.
L8098:  .word LBCastleSQ1,  LBCastleSQ2,  LBCastleTri,  MusNone ;Lord British castle music.
L80A1:  .word MusNone,      MusNone,      MusNone,      MusNone ;No music.

;----------------------------------------------------------------------------------------------------

;Unused tile patterns from Bank $A.
L80A9:  .byte $00, $00, $00, $00, $00, $00, $00, $20, $10, $FE, $08, $04, $40, $40, $3C, $00
L80B9:  .byte $00, $00, $00, $00, $00, $00, $00, $40, $40, $40, $40, $40, $40, $44, $38, $00
L80C9:  .byte $00, $00, $00, $00, $00, $00, $00, $08, $FE, $08, $38, $48, $38, $08, $30, $00
L80D9:  .byte $00, $00, $00, $00, $00, $00, $00, $44, $44, $FE, $44, $44, $40, $42, $3C, $00
L80E9:  .byte $00, $00, $00, $00, $00, $00, $00, $78, $10, $20, $FE, $10, $20, $22, $1C, $00
L80F9:  .byte $00, $00, $00, $00, $00, $00, $00

;----------------------------------------------------------------------------------------------------

UpdateMusic:
L8100:  LDX #SQ1_DAT_OFFSET     ;Has the SQ1 note finished?
L8102:  DEC SQ1LenCounter       ;If not, branch.
L8105:  BNE +                   ;
L8107:  JSR GetChannelData      ;($82D4)Get data for next musical note.
L810A:* JSR UpdateChnl          ;($81EB)Update selected channel.

L810D:  LDX #SQ2_DAT_OFFSET     ;Has the SQ2 note finished?
L810F:  DEC SQ2LenCounter       ;If not, branch.
L8112:  BNE +                   ;
L8114:  JSR GetChannelData      ;($82D4)Get data for next musical note.
L8117:* JSR UpdateChnl          ;($81EB)Update selected channel.

L811A:  LDX #TRI_DAT_OFFSET     ;Has the Triangle note finished?
L811C:  DEC TriLenCounter       ;If not, branch.
L811F:  BNE +                   ;
L8121:  JSR GetChannelData      ;($82D4)Get data for next musical note.
L8124:* JSR UpdateChnl          ;($81EB)Update selected channel.

L8127:  LDX #NSE_DAT_OFFSET     ;Has the noise channel finished(not used)?
L8129:  DEC NseLenCounter       ;If not, branch.
L812C:  BNE ChkSQ1Update        ;
L812E:  JSR GetChannelData      ;($82D4)Get data for next musical note.

ChkSQ1Update:
L8131:  JSR UpdateChnl_         ;($820D)Update channel but not the vibrato.
L8134:  LDA SFXSQ1Finished      ;
L8137:  AND #SFX_UNUSED         ;Second bit not used. Should never branch.
L8139:  BNE ChkSQ2Update        ;

DoSQ1Update:
L813B:  LDA NextSQ1Ctrl0        ;Always enable length counter and constant volume.
L813E:  ORA SilenceChnTbl       ;
L8141:  STA SQ1Cntrl0           ;Store new SQ1 control0 value.
L8144:  LDA NextSQ1Ctrl1        ;
L8147:  STA SQ1Cntrl1           ;Store control1 and control2 bytes.
L814A:  LDA NextSQ1Ctrl2        ;
L814D:  STA SQ1Cntrl2           ;

L8150:  LDA SFXSQ1Finished      ;Did a SQ1 SFX just finish?
L8153:  AND #SFX_FINISHED       ;If not, branch.
L8155:  BEQ ChkSQ2Update        ;

L8157:  LDA #SFX_RESET          ;
L8159:  STA SFXSQ1Finished      ;Reset the SQ1 SFX status and resume the music.
L815C:  LDA NextSQ1Ctrl3        ;
L815F:  STA SQ1Cntrl3           ;

ChkSQ2Update:
L8162:  LDA SFXSQ2Finished      ;
L8165:  AND #SFX_UNUSED         ;Second bit not used. Should never branch.
L8167:  BNE ChkTriUpdate        ;

DoSQ2Update:
L8169:  LDA NextSQ2Ctrl0        ;Always enable length counter and constant volume.
L816C:  ORA SilenceChnTbl+$4    ;
L816F:  STA SQ2Cntrl0           ;
L8172:  LDA NextSQ2Ctrl1        ;Update SQ2 control registers 0,1 and 2.
L8175:  STA SQ2Cntrl1           ;
L8178:  LDA NextSQ2Ctrl2        ;
L817B:  STA SQ2Cntrl2           ;

L817E:  LDA SFXSQ2Finished      ;Did a SQ2 SFX just finish?
L8181:  AND #SFX_FINISHED       ;If not, branch.
L8183:  BEQ ChkTriUpdate        ;

L8185:  LDA #SFX_RESET          ;
L8187:  STA SFXSQ2Finished      ;Reset the SQ2 SFX status and resume the music.
L818A:  LDA NextSQ2Ctrl3        ;
L818D:  STA SQ2Cntrl3           ;

ChkTriUpdate:
L8190:  LDA SFXTriFinished      ;
L8193:  AND #SFX_UNUSED         ;Second bit not used. Should never branch.
L8195:  BNE ChkNoiseUpdate      ;

DoTriUpdate:
L8197:  LDA NextTriCtrl0        ;
L819A:  AND #$8C                ;
L819C:  ORA SilenceChnTbl+$8    ;Update control buts 0 and 2 of the Triangle hardware.
L819F:  STA TriangleCntrl0      ;
L81A2:  LDA NextTriCtrl2        ;
L81A5:  STA TriangleCntrl2      ;

L81A8:  LDA SFXTriFinished      ;Did a Triangle SFX just finish?
L81AB:  AND #SFX_FINISHED       ;If not, branch.
L81AD:  BEQ ChkNoiseUpdate      ;

L81AF:  LDA #SFX_RESET          ;
L81B1:  STA SFXTriFinished      ;
L81B4:  LDA NextTriCtrl3        ;Reset the Triangle SFX status and resume the music.
L81B7:  ORA SilenceChnTbl+$B    ;
L81BA:  STA TriangleCntrl3      ;

ChkNoiseUpdate:
L81BD:  LDA SFXNseFinished      ;
L81C0:  AND #SFX_UNUSED         ;Second bit not used. Should never branch.
L81C2:  BNE FinishMusUpdate     ;

DoNoiseUpdate:
L81C4:  LDA NextNseCtrl0        ;
L81C7:  ORA SilenceChnTbl+$C    ;
L81CA:  STA NoiseCntrl0         ;Update control buts 0 and 2 of the Noise hardware.
L81CD:  LDA NextNseCtrl2        ;
L81D0:  STA NoiseCntrl2         ;

L81D3:  LDA SFXNseFinished      ;Did a Noise SFX just finish?
L81D6:  AND #SFX_FINISHED       ;If not, branch.
L81D8:  BEQ FinishMusUpdate     ;

L81DA:  LDA #SFX_RESET          ;
L81DC:  STA SFXNseFinished      ;Reset the Noise SFX status and resume the silence.
L81DF:  LDA NextNseCtrl3        ;
L81E2:  STA NoiseCntrl3         ;

FinishMusUpdate:
L81E5:  LDA #MUS_CHANS_EN       ;
L81E7:  STA APUCommonCntrl0     ;Enable SQ1, SQ2, Tri and noise channels.
L81EA:  RTS                     ;

;----------------------------------------------------------------------------------------------------

UpdateChnl:
L81EB:  CLC                     ;
L81EC:  LDA ChnVibCntLB,X       ;
L81EF:  ADC ChnVibSpeedLB,X     ;
L81F2:  STA ChnVibCntLB,X       ;Update the current channel's vibrato counter.
L81F5:  LDA ChnVibCntUB,X       ;
L81F8:  ADC ChnVibSpeedUB,X     ;
L81FB:  STA ChnVibCntUB,X       ;

L81FE:  AND #$07                ;Save the current index into the vibrato table.
L8200:  STA GenByteF4           ;

L8202:  TXA                     ;Multiply current channel index by 2. 8 bytes per vibrato table.
L8203:  ASL                     ;This give the vibrato table plus its current index.
L8204:  ORA GenByteF4           ;

L8206:  TAY                     ;
L8207:  LDA ChnVibBase,Y        ;Get the vibrato modified frequency control byte and save it.
L820A:  STA ChnCtrl2,X          ;

UpdateChnl_:
L820D:  LDA ChnLenCounter,X     ;Get the remaining frames to play the current note(or silence).
L8210:  STA GenByteF4           ;

UpdateASRData:
L8212:  CMP ChnSustainTime,X    ;Has the attack time expired for the current note?
L8215:  BCC GetSustainData      ;If so, branch.

GetAttackData:
L8217:  LDA AttackDatPtrLB,X    ;
L821A:  STA GenPtrF0LB          ;Load the pointer to the attack data.
L821C:  LDA AttackDatPtrUB,X    ;
L821F:  STA GenPtrF0UB          ;

L8221:  LDA ChnNoteLength,X     ;Get remaining time to play attack phase of note.
L8224:  SBC GenByteF4           ;
L8226:  CLC                     ;
L8227:  ADC #$01                ;Is there still attack data bytes left to use?
L8229:  CMP ChnAttackDatLen,X   ;If so, branch.
L822C:  BCC ContinueChnUpdate   ;

L822E:  LDA ChnAttackDatLen,X   ;Get the length of the attack data string.
L8231:  JMP ContinueChnUpdate   ;($8273)Continue on with the music channel update.

GetSustainData:
L8234:  CMP ChnReleaseTime,X    ;Has the sustain time expired for the current note?
L8237:  BCC GetReleaseData      ;If so, branch.

L8239:  LDA SustainDatPtrLB,X   ;
L823C:  STA GenPtrF0LB          ;Load the pointer to the sustain data.
L823E:  LDA SustainDatPtrUB,X   ;
L8241:  STA GenPtrF0UB          ;

L8243:  LDA ChnSustainTime,X    ;Get remaining time to play sustain phase of note.
L8246:  SBC GenByteF4           ;
L8248:  CLC                     ;
L8249:  ADC #$01                ;Is there still sustain data bytes left to use?
L824B:  CMP ChnSustainDatLen,X  ;If so, branch.
L824E:  BCC ContinueChnUpdate   ;

L8250:  LDA ChnSustainDatLen,X  ;Get the length of the sustain data string.
L8253:  JMP ContinueChnUpdate   ;($8273)Continue on with the music channel update.

GetReleaseData:
L8256:  LDA ReleaseDatPtrLB,X   ;
L8259:  STA GenPtrF0LB          ;Load the pointer to the release data.
L825B:  LDA ReleaseDatPtrUB,X   ;
L825E:  STA GenPtrF0UB          ;

L8260:  SEC                     ;
L8261:  LDA ChnReleaseTime,X    ;Get remaining time to play release phase of note.
L8264:  SBC GenByteF4           ;
L8266:  CLC                     ;
L8267:  ADC #$01                ;
L8269:  LDY #$00                ;Is there still releae data bytes left to use?
L826B:  CMP ChnReleaseDatLen,X  ;If so, branch.
L826E:  BCC ContinueChnUpdate   ;

L8270:  LDA ChnReleaseDatLen,X  ;Get the length of the release data string.

ContinueChnUpdate:
L8273:  TAY                     ;Are we updating the Triangle channel?
L8274:  CPX #TRI_DAT_OFFSET     ;If not, branch.
L8276:  BNE SetChnVolume        ;

L8278:  LDA ChnLenCounter,X     ;Is the current note about to end?
L827B:  CMP #$01                ;If so, branch.
L827D:  BEQ TurnOffChn          ;

L827F:  CPX #TRI_DAT_OFFSET     ;Are we updating the Triangle channel?
L8281:  BNE SetChnVolume        ;If not, branch.

L8283:  LDA Volume1sComp,X      ;Is the triangle channel about to be silenced?
L8286:  CMP #$FF                ;If not, branch.
L8288:  BCC SetTriCntrl0        ;

TurnOffChn:
L828A:  LDA SilenceChnTbl,X     ;Turn off the channel.
L828D:  STA ChnCtrl0,X          ;
L8290:  JMP UpdateCtrl0         ;($82C8)Update the control0 byte of the sound channel.

SetTriCntrl0:
L8293:  LDA (GenPtrF0),Y        ;
L8295:  ORA #$80                ;Get the next control 0 byte for the triangle channel.
L8297:  STA NextTriCtrl0        ;
L829A:  RTS                     ;

SetChnVolume:
L829B:  LDA (GenPtrF0),Y        ;The following code combines the volume 4-bit with the
L829D:  AND #$1F                ;5-bit envelope associated with the ASR data. The result
L829F:  STA GenByteF4           ;can vary bepending on the envelope value. The following
L82A1:  LDA Volume1sComp,X      ;is a rough formula for figuring out the end result:
L82A4:  STA GenByteF5           ;
L82A6:  LDA #$00                ;(ASR envelope value-1) * multiplier
L82A8:  LSR GenByteF4           ;
L82AA:  ASL GenByteF5           ;The multiplier is approximately the following based on
L82AC:  BCS +                   ;the volume data:
L82AE:  ADC GenByteF4           ;
L82B0:* LSR GenByteF4           ;Mult=.87 when vol=$F      Mult=.37 when vol=$7
L82B2:  ASL GenByteF5           ;Mult=.83 when vol=$E      Mult=.33 when vol=$6
L82B4:  BCS +                   ;Mult=.77 when vol=$D      Mult=.27 when vol=$5
L82B6:  ADC GenByteF4           ;Mult=.73 when vol=$C      Mult=.23 when vol=$4
L82B8:* LSR GenByteF4           ;Mult=.63 when vol=$B      Mult=.13 when vol=$3
L82BA:  ASL GenByteF5           ;Mult=.60 when vol=$A      Mult=.10 when vol=$2
L82BC:  BCS +                   ;Mult=.53 when vol=$9      Mult=.03 when vol=$1
L82BE:  ADC GenByteF4           ;Mult=.50 when vol=$8      Mult=.00 when vol=$0
L82C0:* LSR GenByteF4           ;
L82C2:  ASL GenByteF5           ;These are rough values calculated at 100% Envelope value.
L82C4:  BCS +                   ;The values can change considerbly.
L82C6:  ADC GenByteF4           ;

UpdateCtrl0:
L82C8:* STA GenByteF4           ;
L82CA:  LDA (GenPtrF0),Y        ;Get the duty cycle data.
L82CC:  AND #$C0                ;
L82CE:  ORA GenByteF4           ;Combine it with the newly calculated volume.
L82D0:  STA ChnCtrl0,X          ;Update the hardware!
L82D3:  RTS                     ;

;----------------------------------------------------------------------------------------------------

GetChannelData:
L82D4:  LDA (ChnDatPtr,X)       ;Does the current channel need to be silenced?
L82D6:  CMP #CHN_SILENCE        ;If not, branch.
L82D8:  BNE +                   ;

L82DA:  JMP SilenceChannel      ;($83FD)Silence the channel for a period of time.

L82DD:* CMP #CHN_CONTROL        ;Is this a control byte?
L82DF:  BCS GetCntrlByte        ;If so, branch to process the control byte.

L82E1:  CPX #TRI_DAT_OFFSET     ;Are we looking for SQ1 or SQ2 data?
L82E3:  BCC GetSQData           ;If so, brach to get SQ music data.

L82E5:  BEQ +                   ;Are we looking for triangle data? If so, branch.
L82E7:  JMP SilenceNseChnl      ;($851A)Must be noise channel. Not used in music jump to silence.

L82EA:*  JMP GetSQTriData       ;($844F)Get the triangle/SQ data.

GetSQData:
L82ED:  JMP GetSQTriData        ;($844F)Get the triangle/SQ data.

;----------------------------------------------------------------------------------------------------

GetCntrlByte:
L82F0:  CMP #CHN_JUMP           ;Does the pointer need to jump? If so, branch.
L82F2:  BEQ DoDataJump          ;($8312)Jump the data pointer to a new location.

L82F4:  CMP #CHN_ASR            ;Is this an ASR control byte?
L82F6:  BNE +                   ;If not, branch.
L82F8:  JMP UpdateASR           ;($8336)Update the ASR(attack, sustain, release) profile.

L82FB:* CMP #CHN_VIBRATO        ;Is this a vibrato control byte?
L82FD:  BNE +                   ;If not branch.
L82FF:  JMP UpdateVibratoData   ;($83A4)Update channel vibrato data.

L8302:* CMP #CHN_VOLUME         ;Is this a volume control byte?
L8304:  BNE NextChnByte         ;If not, branch. Invalid control byte.
L8306:  JMP UpdateVolume        ;($8390)Update the channel base volume.

NextChnByte:
L8309:  INC ChnDatPtrLB,X       ;
L830B:  BNE GetDataLoop         ;Increment to next musical data byte.
L830D:  INC ChnDatPtrUB,X       ;

GetDataLoop:
L830F:  JMP GetChannelData      ;($82D4)Get data for next musical note.

;----------------------------------------------------------------------------------------------------

DoDataJump:
L8312:  LDY ChnDatPtrUB,X       ;
L8314:  LDA ChnDatPtrLB,X       ;
L8316:  PHA                     ;
L8317:  CLC                     ;
L8318:  ADC #$02                ;
L831A:  BCC +                   ;This function jumps the data pointer to a new location.
L831C:  INC ChnDatPtrUB,X       ;The control byte if $FF followed by $00. The next 2
L831E:* STA ChnDatPtrLB,X       ;Bytes are the amount of bytes to jump the pointer. Those
L8320:  PLA                     ;bytes are typically going to be in 2's compliment as the
L8321:  CLC                     ;pointer will most likely jump backwards. The point of
L8322:  ADC (ChnDatPtr,X)       ;reference for the jump is the address of the $FF byte.
L8324:  INC ChnDatPtrLB,X       ;
L8326:  BNE +                   ;For example, the following data bytes:
L8328:  INC ChnDatPtrUB,X       ;$FF, $00, $B6, $FE
L832A:* PHA                     ;will jump the pointer back 330 bytes.
L832B:  TYA                     ;
L832C:  ADC (ChnDatPtr,X)       ;
L832E:  STA ChnDatPtrUB,X       ;
L8330:  PLA                     ;
L8331:  STA ChnDatPtrLB,X       ;
L8333:  JMP GetDataLoop         ;($830F)Jump to get the next data byte.

;----------------------------------------------------------------------------------------------------

UpdateASR:
L8336:  INC ChnDatPtrLB,X       ;
L8338:  BNE +                   ;Increment to next musical data byte.
L833A:  INC ChnDatPtrUB,X       ;

L833C:* LDA (ChnDatPtr,X)       ;Get the index into the ASR data tables.
L833E:  ASL                     ;*2. The addresses in the table are 2 bytes each.
L833F:  TAY                     ;

L8340:  LDA AttackPtrTbl,Y      ;
L8343:  STA AttackDatPtrLB,X    ;
L8346:  STA GenPtrF4LB          ;Update the attack data pointer for the channel.
L8348:  LDA AttackPtrTbl+1,Y    ;
L834B:  STA AttackDatPtrUB,X    ;
L834E:  STA GenPtrF4UB          ;

L8350:  STY GenByteF8           ;Temporarily save the value of Y.

L8352:  LDY #$00                ;
L8354:  LDA (GenPtrF4),Y        ;Save the length of the attack data string.
L8356:  STA ChnAttackDatLen,X   ;

L8359:  LDY GenByteF8           ;Restore the value of Y.

L835B:  LDA SustainPtrTbl,Y     ;
L835E:  STA SustainDatPtrLB,X   ;
L8361:  STA GenPtrF4LB          ;Update the sustain data pointer for the channel.
L8363:  LDA SustainPtrTbl+1,Y   ;
L8366:  STA SustainDatPtrUB,X   ;
L8369:  STA GenPtrF4UB          ;

L836B:  STY GenByteF8           ;Temporarily save the value of Y.

L836D:  LDY #$00                ;
L836F:  LDA (GenPtrF4),Y        ;Save the length of the sustain data string.
L8371:  STA ChnSustainDatLen,X  ;

L8374:  LDY GenByteF8           ;Restore the value of Y.

L8376:  LDA ReleasePtrTbl,Y     ;
L8379:  STA ReleaseDatPtrLB,X   ;
L837C:  STA GenPtrF4LB          ;Update the release data pointer for the channel.
L837E:  LDA ReleasePtrTbl+1,Y   ;
L8381:  STA ReleaseDatPtrUB,X   ;
L8384:  STA GenPtrF4UB          ;

L8386:  LDY #$00                ;
L8388:  LDA (GenPtrF4),Y        ;Save the length of the release data string.
L838A:  STA ChnReleaseDatLen,X  ;

L838D:  JMP NextChnByte         ;($8309)Get next byte of channel music data.

;----------------------------------------------------------------------------------------------------

UpdateVolume:
L8390:  INC ChnDatPtrLB,X       ;
L8392:  BNE +                   ;Increment to next music data byte.
L8394:  INC ChnDatPtrUB,X       ;

L8396:* LDA (ChnDatPtr,X)       ;
L8398:  ASL                     ;
L8399:  ASL                     ;Move 4-bit volume data to upper byte.
L839A:  ASL                     ;
L839B:  ASL                     ;

L839C:  EOR #$FF                ;1s compliment the byte.
L839E:  STA Volume1sComp_,X     ;
L83A1:  JMP NextChnByte         ;($8309)Get next byte of channel music data.

;----------------------------------------------------------------------------------------------------

UpdateVibratoData:
L83A4:  INC ChnDatPtrLB,X       ;
L83A6:  BNE +                   ;Increment to next music data byte.
L83A8:  INC ChnDatPtrUB,X       ;

L83AA:* LDA (ChnDatPtr,X)       ;Get unused data byte. Always 0.
L83AC:  STA ChnVibUnused,X      ;

L83AF:  INC ChnDatPtrLB,X       ;
L83B1:  BNE +                   ;Increment to next music data byte.
L83B3:  INC ChnDatPtrUB,X       ;

L83B5:* LDA (ChnDatPtr,X)       ;Get the vibrato speed control byte.
L83B7:  CMP #$02                ;Is speed control byte 2 or less?
L83B9:  BCS PrepVibratoCalc     ;If so, disable vibrato, else branch to calculate vibrato.

L83BB:  LDA #$00                ;
L83BD:  STA ChnVibSpeedLB,X     ;
L83C0:  STA ChnVibSpeedUB,X     ;Disable vibrato.
L83C3:  STA ChnVibCntLB,X       ;
L83C6:  LDA #$00                ;
L83C8:  STA ChnVibCntUB,X       ;

L83CB:  JMP GetVibratoData      ;($83EF)Get vibrato intensity byte.

PrepVibratoCalc:
L83CE:  STA DivisorF8           ;
L83D0:  LDA #$00                ;
L83D2:  STA DivLBF4             ;Divide #$0800 by the value in $F8.
L83D4:  LDA #$08                ;
L83D6:  STA DivUBF5             ;
L83D8:  JSR DoDiv               ;($857C)Integer divide a word by a byte.

L83DB:  LDA DivLBF4             ;
L83DD:  STA ChnVibSpeedLB,X     ;Set the vibrato speed control with results from previous division.
L83E0:  LDA DivUBF5             ;
L83E2:  STA ChnVibSpeedUB,X     ;

L83E5:  LDA #$00                ;
L83E7:  STA ChnVibCntLB,X       ;Reset the vibrato counter to #$0200.
L83EA:  LDA #$02                ;
L83EC:  STA ChnVibCntUB,X       ;

GetVibratoData:
L83EF:  INC ChnDatPtrLB,X       ;
L83F1:  BNE +                   ;Increment to next musical data byte.
L83F3:  INC ChnDatPtrUB,X       ;

L83F5:* LDA (ChnDatPtr,X)       ;Store the vibrato intensity byte.
L83F7:  STA ChnVibIntensity,X   ;
L83FA:  JMP NextChnByte         ;($8309)Get next byte of channel music data.

;----------------------------------------------------------------------------------------------------

SilenceChannel:
L83FD:  INC ChnDatPtrLB,X       ;
L83FF:  BNE +                   ;Increment channel data pointer.
L8401:  INC ChnDatPtrUB,X       ;

L8403:* LDA (ChnDatPtr,X)       ;
L8405:  STA ChnLenCounter,X     ;Set the time period in frames to silence the channel.
L8408:  STA ChnNoteLength,X     ;

L840B:  SEC                     ;
L840C:  SBC ChnAttackDatLen,X   ;Caclulate the time for the sustain phase to start.
L840F:  BCS +                   ;
L8411:  LDA #$00                ;

L8413:* STA ChnSustainTime,X    ;If the sustain time less than the release time?
L8416:  CMP ChnReleaseDatLen,X  ;If so, branch.
L8419:  BCC +                   ;

L841B:  LDA ChnReleaseDatLen,X  ;Set the release time.
L841E:* STA ChnReleaseTime,X    ;

L8421:  LDA SilenceChnTbl,X     ;
L8424:  STA ChnCtrl0,X          ;
L8427:  LDA SilenceChnTbl+1,X   ;
L842A:  STA ChnCtrl1,X          ;Load data from the table below to silence the selected channel.
L842D:  LDA SilenceChnTbl+2,X   ;
L8430:  STA ChnCtrl2,X          ;
L8433:  LDA SilenceChnTbl+3,X   ;
L8436:  STA ChnCtrl3,X          ;

L8439:  LDA #$FF                ;Set volume to 0.
L843B:  STA Volume1sComp,X      ;

L843E:  LDA SFXFinished,X       ;
L8441:  BNE +                   ;Set any playing SFX on this channel as just finished.
L8443:  LDA #$01                ;
L8445:  STA SFXFinished,X       ;

L8448:* INC ChnDatPtrLB,X       ;
L844A:  BNE +                   ;Increment to next musical data byte.
L844C:  INC ChnDatPtrUB,X       ;

L844E:*  RTS

;----------------------------------------------------------------------------------------------------

GetSQTriData:
L844F:  CPX #TRI_DAT_OFFSET     ;Are we getting triangle music data?
L8451:  BNE GetMusData          ;If not, branch.

L8453:  PHA                     ;
L8454:  LDA TriCompensate       ;Should triangle notes be on the same octive as the SQ notes?
L8457:  CMP #TRI_CHN_COMP       ;If so, look 12 entries ahead in the notes table as the
L8459:  PLA                     ;triangle notes play at half frequency as the SQ notes by
L845A:  BCS GetMusData          ;default. This is 1 octive lower. 
L845C:  ADC #$0C                ;

GetMusData:
L845E:  TAY                     ;
L845F:  LDA NoteTblLo,Y         ;
L8462:  STA DivLBF4             ;
L8464:  LDA NoteTblHi,Y         ;
L8467:  LSR                     ;Get the upper 8 bits of the note frequency
L8468:  ROR DivLBF4             ;and but it into $F4.
L846A:  LSR                     ;
L846B:  ROR DivLBF4             ;
L846D:  LSR                     ;
L846E:  ROR DivLBF4             ;

L8470:  LDA #$00                ;Zero out $F5 to use in a division algorithm.
L8472:  STA DivUBF5             ;

L8474:  LDA ChnVibIntensity,X   ;Prepare to add vibrato to note being played.
L8477:  STA DivisorF8           ;
L8479:  STY GenByteFD           ;Store the index value in Y.
L847B:  JSR DoDiv               ;($857C)Integer divide a word by a byte.

L847E:  LDY GenByteFD           ;Restore the index value to Y.

L8480:  LDA DivLBF4             ;Store the delta frequency for vibrato notes.
L8482:  STA ChnVibratoDF,X      ;

L8485:  LDA NoteTblHi,Y         ;Store the lower counter value. This is the base note frequency.
L8488:  STA ChnCtrl3,X          ;

;The following code creates an 8 byte table of vibrato frequencies.
;Visually, the table looks something like this:
; Y Axis = Frequency
; |
; |    P
; |   / \
; |  H   H
; |/      \
; B--------B--------   X Axis = Table Entry Number
; |         \     /
; |          L   L
; |           \ /
; |            M
; |
;Where:
;B = Base frequency.
;H = Higher frequency.
;P = Peak frequency.
;L = Lower frequency.
;M = Minimum frequency.

LoadVibratoTbl:
L848B:  LDA NoteTblLo,Y         ;
L848E:  STX GenByteFD           ;Save the channel index. A multiple of 4.
L8490:  ASL GenByteFD           ;*2. 8 bytes per vibrato lookup table.
L8492:  LDY GenByteFD           ;

L8494:  STA ChnVibBase,Y        ;Spots 0 and 4 in the vibrato lookup table are the base frequency.
L8497:  STA ChnVibBase+4,Y      ;

L849A:  CLC                     ;Add the delta frequency to base frequency.
L849B:  ADC ChnVibratoDF,X      ;Creates higher frequency.
L849E:  BCC +                   ;
L84A0:  LDA #$FF                ;Make sure value does not wrap around.

L84A2:* STA ChnVibBase+1,Y      ;Higher frequency stored in spots 1 and 3
L84A5:  STA ChnVibBase+3,Y      ;of the vibrato lookup table.

L84A8:  CLC                     ;Add the delta frequency to previous frequency.
L84A9:  ADC ChnVibratoDF,X      ;Creates peak frequency.
L84AC:  BCC +                   ;
L84AE:  LDA #$FF                ;Make sure value does not wrap around.

L84B0:* STA ChnVibBase+2,Y      ;Peak frequency stored in position 2 of vibrato lookup table.

L84B3:  SEC                     ;
L84B4:  LDA ChnVibBase,Y        ;Subtract the delta frequency from base frequency.
L84B7:  SBC ChnVibratoDF,X      ;Creates lower frequency.
L84BA:  BCS +                   ;
L84BC:  LDA #$FF                ;If wraps, set to max freq. Is this a bug? Should be 0?

L84BE:* STA ChnVibBase+5,Y      ;Lower frequency stored in spots 5 and 7
L84C1:  STA ChnVibBase+7,Y      ;of the vibrato lookup table.

L84C4:  SEC                     ;Subtract the delta frequency from previous frequency.
L84C5:  SBC ChnVibratoDF,X      ;Creates minimum frequency.
L84C8:  BCS +
L84CA:  LDA #$FF                ;If wraps, set to max freq. Is this a bug? Should be 0?

L84CC:* STA ChnVibBase+6,Y      ;Minimum frequency stored in position 6 of vibrato lookup table.

L84CF:  INC ChnDatPtrLB,X       ;
L84D1:  BNE +                   ;Increment to next musical data byte.
L84D3:  INC ChnDatPtrUB,X       ;

L84D5:* LDA (ChnDatPtr,X)       ;
L84D7:  STA ChnLenCounter,X     ;Set the duration of the new note to play.
L84DA:  STA ChnNoteLength,X     ;

L84DD:  SEC                     ;
L84DE:  SBC ChnAttackDatLen,X   ;
L84E1:  BCS +                   ;Calculate frame when sustain starts and save it.
L84E3:  LDA #$00                ;
L84E5:* STA ChnSustainTime,X    ;

L84E8:  SEC                     ;
L84E9:  SBC ChnReleaseDatLen,X  ;Calculate frame when sustain ends.
L84EC:  BCS +                   ;
L84EE:  LDA #$00                ;

L84F0:* CMP ChnSustainDatLen,X  ;Is the end time less than the sustain data length?
L84F3:  BCC +                   ;If so, branch.

L84F5:  LDA ChnSustainDatLen,X  ;Sustain time=sustain data length.

L84F8:* STA GenByteF4           ;Store frame when sustain ends.

L84FA:  LDA ChnSustainTime,X    ;
L84FD:  SEC                     ;
L84FE:  SBC GenByteF4           ;Caclulate frame when release starts and save it.
L8500:  STA ChnReleaseTime,X    ;

L8503:  INC ChnDatPtrLB,X       ;
L8505:  BNE +                   ;Increment to next musical data byte.
L8507:  INC ChnDatPtrUB,X       ;

L8509:* LDA Volume1sComp_,X     ;Transfer the 1s compliment of the volume to the working register.
L850C:  STA Volume1sComp,X      ;

L850F:  LDA SFXFinished,X       ;
L8512:  BNE +                   ;
L8514:  LDA #$01                ;Set any playing SFX on the noise channel as just finished.
L8516:  STA SFXFinished,X       ;
L8519:* RTS                     ;

;----------------------------------------------------------------------------------------------------

SilenceNseChnl:
L851A:  AND #$0F                ;
L851C:  STA NextNseCtrl2        ;
L851F:  LDA SilenceChnTbl+$C    ;
L8522:  STA NextNseCtrl0        ;Load the noise hardware registers with the data in the table below.
L8525:  LDA SilenceChnTbl+$D    ;
L8528:  STA NextNseCtrl1        ;
L852B:  LDA SilenceChnTbl+$F    ;
L852E:  STA NextNseCtrl3        ;

L8531:  INC NseDatPtrLB         ;
L8533:  BNE +                   ;Increment to the next noise data byte.
L8535:  INC NseDatPtrUB         ;

L8537:* LDA (ChnDatPtr,X)       ;
L8539:  STA NseLenCounter       ;Set the number of frames Noise channel is silent.
L853C:  STA NseNoteLength       ;

L853F:  SEC                     ;
L8540:  SBC NseAttackDatLen     ;
L8543:  BCS +                   ;Calculate frame when sustain starts and save it.
L8545:  LDA #$00                ;
L8547:* STA NseSustainTime      ;

L854A:  SEC                     ;
L854B:  SBC NseReleaseDatLen    ;Calculate frame when sustain ends.
L854E:  BCS +                   ;
L8550:  LDA #$00                ;

L8552:* CMP NseSustainDatLen    ;Is the end time less than the sustain data length?
L8555:  BCC +                   ;If so, branch.

L8557:  LDA NseSustainDatLen    ;Sustain time=sustain data length.

L855A:* STA GenByteF4           ;Store frame when sustain ends.

L855C:  LDA NseSustainTime      ;
L855F:  SEC                     ;
L8560:  SBC GenByteF4           ;Caclulate frame when release starts and save it.
L8562:  STA NseReleaseTime      ;

L8565:  INC ChnDatPtrLB,X       ;
L8567:  BNE +                   ;Increment to next musical data byte.
L8569:  INC ChnDatPtrUB,X       ;

L856B:* LDA SFXNseUnused7696    ;Not used.
L856E:  STA NseUnused762E       ;

L8571:  LDA SFXNseFinished      ;
L8574:  BNE +                   ;
L8576:  LDA #$01                ;Set any playing SFX on the noise channel as just finished.
L8578:  STA SFXNseFinished      ;
L857B:* RTS                     ;

;----------------------------------------------------------------------------------------------------

DoDiv:
L857C:  CLC                     ;
L857D:  LDA #$00                ;
L857F:  LDY #$08                ;Prepare to divide the word in $F5,$F4 by $F8.
L8581:  ROL DivLBF4             ;
L8583:  ROL DivUBF5             ;

DivCalcLoop:
L8585:  ROL                     ;
L8586:  CMP DivisorF8           ;
L8588:  BCC +                   ;
L858A:  SBC DivisorF8           ;
L858C:* ROL DivLBF4             ;
L858E:  ROL DivUBF5             ;
L8590:  ROL                     ;This is a division algorithm. It divides the word in $F5,$F4
L8591:  CMP DivisorF8           ;by $F8. The integer word result is placed back into $F5,$F4.
L8593:  BCC +                   ;
L8595:  SBC DivisorF8           ;
L8597:* ROL DivLBF4             ;
L8599:  ROL DivUBF5             ;
L859B:  DEY                     ;
L859C:  BNE DivCalcLoop         ;
L859E:  RTS                     ;

;----------------------------------------------------------------------------------------------------

;The following table loads the control bytes for each channel to turn it off.

SilenceChnTbl:
L859F:  .byte $30, $11, $00, $00 ;SQ1 channel.
L85A3:  .byte $30, $11, $00, $00 ;SQ2 channel.
L85A7:  .byte $80, $00, $00, $F8 ;Triangle channel.
L85AB:  .byte $30, $00, $00, $00 ;Noise channel.

;----------------------------------------------------------------------------------------------------

;NoteTblHi contains the upper 3 bits of the note to play. NoteTblLo is the lower byte. 
;the period high information(3 bits) and the second byte is the period low information(8 bits).
;The formula for figuring out the SQ1, SQ2 frequency is as follows: 1789773/(16*(hhhllllllll+1)).
;The frequency for the triangle channel is 1/2 the frequency for the square wave channels.

;$06, $AE Index $00 - 65.38Hz   - C2  (SQ1/SQ2), 32.69Hz  - C1  (TRI).
;$06, $4E Index $01 - 69.26Hz   - C#2 (SQ1/SQ2), 34.63Hz  - C#1 (TRI).
;$05, $F4 Index $02 - 73.35Hz   - D2  (SQ1/SQ2), 36.68Hz  - D1  (TRI).
;$05, $9E Index $03 - 77.74Hz   - D#2 (SQ1/SQ2), 38.87Hz  - D#1 (TRI).
;$05, $4D Index $04 - 82.37Hz   - E2  (SQ1/SQ2), 41.19Hz  - E1  (TRI).
;$05, $01 Index $05 - 87.25Hz   - F2  (SQ1/SQ2), 43.63Hz  - F1  (TRI).
;$04, $B9 Index $06 - 92.45Hz   - F#2 (SQ1/SQ2), 46.22Hz  - F#1 (TRI).
;$04, $75 Index $07 - 97.95Hz   - G2  (SQ1/SQ2), 48.98Hz  - G1  (TRI).
;$04, $35 Index $08 - 103.77Hz  - G#2 (SQ1/SQ2), 51.88Hz  - G#1 (TRI).
;$03, $F9 Index $09 - 109.88Hz  - A2  (SQ1/SQ2), 54.94Hz  - A1  (TRI).
;$03, $C0 Index $0A - 116.40Hz  - A#2 (SQ1/SQ2), 58.20Hz  - A#1 (TRI).
;$03, $8A Index $0B - 123.33Hz  - B2  (SQ1/SQ2), 61.67Hz  - B1  (TRI).
;$03, $57 Index $0C - 130.68Hz  - C3  (SQ1/SQ2), 65.34Hz  - C2  (TRI).
;$03, $27 Index $0D - 138.44Hz  - C#3 (SQ1/SQ2), 69.22Hz  - C#2 (TRI).
;$02, $FA Index $0E - 146.61Hz  - D3  (SQ1/SQ2), 73.30Hz  - D2  (TRI).
;$02, $CF Index $0F - 155.36Hz  - D#3 (SQ1/SQ2), 77.68Hz  - D#2 (TRI).
;$02, $A7 Index $10 - 164.50Hz  - E3  (SQ1/SQ2), 82.25Hz  - E2  (TRI).
;$02, $81 Index $11 - 174.24Hz  - F3  (SQ1/SQ2), 87.12Hz  - F2  (TRI).
;$02, $5D Index $12 - 184.59Hz  - F#3 (SQ1/SQ2), 92.29Hz  - F#2 (TRI).
;$02, $3B Index $13 - 195.56Hz  - G3  (SQ1/SQ2), 97.78Hz  - G2  (TRI).
;$02, $1B Index $14 - 207.15Hz  - G#3 (SQ1/SQ2), 103.57Hz - G#2 (TRI).
;$01, $FC Index $15 - 219.77Hz  - A3  (SQ1/SQ2), 109.88Hz - A2  (TRI).
;$01, $E0 Index $16 - 232.56Hz  - A#3 (SQ1/SQ2), 116.28Hz - A#2 (TRI).
;$01, $C5 Index $17 - 246.39Hz  - B3  (SQ1/SQ2), 123.19Hz - B2  (TRI).
;$01, $AC Index $18 - 260.75Hz  - C4  (SQ1/SQ2), 130.37Hz - C3  (TRI).
;$01, $94 Index $19 - 276.20Hz  - C#4 (SQ1/SQ2), 138.10Hz - C#3 (TRI).
;$01, $7D Index $1A - 292.83Hz  - D4  (SQ1/SQ2), 146.41Hz - D3  (TRI).
;$01, $68 Index $1B - 309.86Hz  - D#4 (SQ1/SQ2), 154.93Hz - D#3 (TRI).
;$01, $53 Index $1C - 329.00Hz  - E4  (SQ1/SQ2), 164.50Hz - E3  (TRI).
;$01, $40 Index $1D - 348.48Hz  - F4  (SQ1/SQ2), 174.24Hz - F3  (TRI).
;$01, $2E Index $1E - 369.18Hz  - F#4 (SQ1/SQ2), 184.59Hz - F#3 (TRI).
;$01, $1D Index $1F - 391.12Hz  - G4  (SQ1/SQ2), 195.56Hz - G3  (TRI).
;$01, $0D Index $20 - 414.30Hz  - G#4 (SQ1/SQ2), 207.15Hz - G#3 (TRI).
;$00, $FE Index $21 - 438.67Hz  - A4  (SQ1/SQ2), 219.33Hz - A3  (TRI).
;$00, $F0 Index $22 - 464.15Hz  - A#4 (SQ1/SQ2), 232.08Hz - A#3 (TRI).
;$00, $E2 Index $23 - 492.78Hz  - B4  (SQ1/SQ2), 246.39Hz - B3  (TRI).
;$00, $D6 Index $24 - 520.28Hz  - C5  (SQ1/SQ2), 260.14Hz - C4  (TRI).
;$00, $CA Index $25 - 551.04Hz  - C#5 (SQ1/SQ2), 275.52Hz - C#4 (TRI).
;$00, $BE Index $26 - 585.66Hz  - D5  (SQ1/SQ2), 292.83Hz - D4  (TRI).
;$00, $B4 Index $27 - 618.02Hz  - D#5 (SQ1/SQ2), 309.01Hz - D#4 (TRI).
;$00, $AA Index $28 - 654.16Hz  - E5  (SQ1/SQ2), 327.08Hz - E4  (TRI).
;$00, $A0 Index $29 - 694.79Hz  - F5  (SQ1/SQ2), 347.39Hz - F4  (TRI).
;$00, $97 Index $2A - 735.93Hz  - F#5 (SQ1/SQ2), 367.96Hz - F#4 (TRI).
;$00, $8F Index $2B - 776.81Hz  - G5  (SQ1/SQ2), 388.41Hz - G4  (TRI).
;$00, $87 Index $2C - 822.51Hz  - G#5 (SQ1/SQ2), 411.25Hz - G#4 (TRI).
;$00, $7F Index $2D - 873.91Hz  - A5  (SQ1/SQ2), 436.96Hz - A4  (TRI).
;$00, $78 Index $2E - 924.47Hz  - A#5 (SQ1/SQ2), 462.23Hz - A#4 (TRI).
;$00, $71 Index $2F - 981.24Hz  - B5  (SQ1/SQ2), 490.62Hz - B4  (TRI).
;$00, $6B Index $30 - 1035.75Hz - C6  (SQ1/SQ2), 517.87Hz - C5  (TRI).
;$00, $65 Index $31 - 1096.67Hz - C#6 (SQ1/SQ2), 548.34Hz - C#5 (TRI).
;$00, $5F Index $32 - 1165.22Hz - D6  (SQ1/SQ2), 582.61Hz - D5  (TRI).
;$00, $5A Index $33 - 1229.24Hz - D#6 (SQ1/SQ2), 614.62Hz - D#5 (TRI).
;$00, $55 Index $34 - 1300.71Hz - E6  (SQ1/SQ2), 650.35Hz - E5  (TRI).
;$00, $50 Index $35 - 1381.00Hz - F6  (SQ1/SQ2), 690.50Hz - F5  (TRI).
;$00, $4C Index $36 - 1452.74Hz - F#6 (SQ1/SQ2), 726.37Hz - F#5 (TRI).
;$00, $47 Index $37 - 1553.62Hz - G6  (SQ1/SQ2), 776.81Hz - G5  (TRI).
;$00, $43 Index $38 - 1645.01Hz - G#6 (SQ1/SQ2), 822.51Hz - G#5 (TRI).
;$00, $40 Index $39 - 1720.94Hz - A6  (SQ1/SQ2), 860.47Hz - A5  (TRI).
;$00, $3C Index $3A - 1833.78Hz - A#6 (SQ1/SQ2), 916.89Hz - A#5 (TRI).
;$00, $39 Index $3B - 1928.63Hz - B6  (SQ1/SQ2), 964.32Hz - B5  (TRI).

NoteTblHi:
L85AF:  .byte $06, $06, $05, $05, $05, $05, $04, $04, $04, $03, $03, $03, $03, $03, $02, $02
L85BF:  .byte $02, $02, $02, $02, $02, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
L85CF:  .byte $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L85DF:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

;Not used:
L85EB:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L85FB:  .byte $00, $00

NoteTblLo:
L85FD:  .byte $AE, $4E, $F4, $9E, $4D, $01, $B9, $75, $35, $F9, $C0, $8A, $57, $27, $FA, $CF
L860D:  .byte $A7, $81, $5D, $3B, $1B, $FC, $E0, $C5, $AC, $94, $7D, $68, $53, $40, $2E, $1D
L861D:  .byte $0D, $FE, $F0, $E2, $D6, $CA, $BE, $B4, $AA, $A0, $97, $8F, $87, $7F, $78, $71
L862D:  .byte $6B, $65, $5F, $5A, $55, $50, $4C, $47, $43, $40, $3C, $39

;----------------------------------------------------------------------------------------------------

;The noise channel is not used in any music so the
;noise channel is disabled with the following code:

MusNone:
L8639:  .byte CHN_ASR, $00               ;Set ASR data index to 0.
L863B:  .byte CHN_VOLUME, $08            ;Set channel volume to 8.
L863D:  .byte CHN_SILENCE, $40           ;Silence channel for 64 frames.
L863F:  .byte CHN_JUMP, $00, $FE, $FF    ;Jump back 2 bytes to $863D.

;----------------------------------------------------------------------------------------------------

;The folowing tables point to volume data for the notes being played. This music engine
;uses an ASR (attack, sustain releas) model for every note that is played. During the attack
;phase of the note, the volume is typically increased. During the sustain phase, the
;volume is typically held at a near constant volume. Finally, during the release phase, the
;volume is slowly tapered off. The data that is pointed to by the below tables describes
;the volume on a frame by frame basis. The first byte in the table is the length of the
;given phase in frames (1\60th of a second). The remaining bytes are the volumes for
;each frame. Typically, the value of the first byte is the same as the length of the 
;data bytes in the table, but not necessarily. The 2 MSBs in the data bytes contain the
;duty cycle for the square wave channels. The MSB contains length counter halt bit for
;the triangle channel. The bottom 5 bits are the volume data.

AttackPtrTbl:
L8643:  .word SQ1Attack00, SQ2Attack01, TriAttack02, SQ2Attack03
L864B:  .word SQ1Attack04, SQ2Attack05, TriAttack06, SQ12Attack07
L8653:  .word SQ2Attack08, TriAttack09, TriAttack0A, SQ1Attack0B
L865B:  .word SQ2Attack0C, TriAttack0D, SQ1Attack0E, SQ2Attack0F
L8663:  .word TriAttack10, SQ1Attack11, SQ2Attack12, SQ1Attack13
L866B:  .word SQ2Attack14, TriAttack15, SQ2Attack16, TriAttack17
L8673:  .word NoAttack18,  SQ1Attack19, SQ2Attack1A, TriAttack1B
L867B:  .word SQ2Attack1C, SQ1Attack1D, SQ1Attack1E, SQ1Attack1F
L8683:  .word SQ1Attack20, SQ1Attack21, SQ2Attack22, TriAttack23
L868B:  .word TriAttack24, SQ2Attack25, SQ1Attack26, SQ2Attack27
L8693:  .word TriAttack28, SQ1Attack29, SQ2Attack2A, TriAttack2B
L869B:  .word SQ2Attack2C, SQ1Attack2D, SQ1Attack2E, SQ2Attack2F
L86A3:  .word TriAttack30, TriAttack31

SustainPtrTbl:
L86A7:  .word SQ1Sustain00, SQ2Sustain01, TriSustain02, SQ2Sustain03
L86AF:  .word SQ1Sustain04, SQ2Sustain05, TriSustain06, SQ12Sustain07
L86B7:  .word SQ2Sustain08, TriSustain09, TriSustain0A, SQ1Sustain0B
L86BF:  .word SQ2Sustain0C, TriSustain0D, SQ1Sustain0E, SQ2Sustain0F
L86C7:  .word TriSustain10, SQ1Sustain11, SQ2Sustain12, SQ1Sustain13
L86CF:  .word SQ2Sustain14, TriSustain15, SQ2Sustain16, TriSustain17
L86D7:  .word NoSustain18,  SQ1Sustain19, SQ2Sustain1A, TriSustain1B
L86DF:  .word SQ2Sustain1C, SQ1Sustain1D, SQ1Sustain1E, SQ1Sustain1F
L86E7:  .word SQ1Sustain20, SQ1Sustain21, SQ2Sustain22, TriSustain23
L86EF:  .word TriSustain24, SQ2Sustain25, SQ1Sustain26, SQ2Sustain27
L86F7:  .word TriSustain28, SQ1Sustain29, SQ2Sustain2A, TriSustain2B
L86FF:  .word SQ2Sustain2C, SQ1Sustain2D, SQ1Sustain2E, SQ2Sustain2F
L8707:  .word TriSustain30, TriSustain31

ReleasePtrTbl:
L870B:  .word SQ1Release00, SQ2Release01, TriRelease02, SQ2Release03
L8713:  .word SQ1Release04, SQ2Release05, TriRelease06, SQ12Release07
L871B:  .word SQ2Release08, TriRelease09, TriRelease0A, SQ1Release0B
L8723:  .word SQ2Release0C, TriRelease0D, SQ1Release0E, SQ2Release0F
L872B:  .word TriRelease10, SQ1Release11, SQ2Release12, SQ1Release13
L8733:  .word SQ2Release14, TriRelease15, SQ2Release16, TriRelease17
L873B:  .word NoRelease18,  SQ1Release19, SQ2Release1A, TriRelease1B
L8743:  .word SQ2Release1C, SQ1Release1D, SQ1Release1E, SQ1Release1F
L874B:  .word SQ1Release20, SQ1Release21, SQ2Release22, TriRelease23
L8753:  .word TriRelease24, SQ2Release25, SQ1Release26, SQ2Release27
L875B:  .word TriRelease28, SQ1Release29, SQ2Release2A, TriRelease2B
L8763:  .word SQ2Release2C, SQ1Release2D,SQ1Release2E, SQ2Release2F
L876B:  .word TriRelease30, TriRelease31

;----------------------------------------------------------------------------------------------------

;Used by dungeon music SQ1.

SQ1Attack00:
L876F:  .byte $03, $8C, $90, $8D

SQ1Sustain00:
L8773:  .byte $01, $88

SQ1Release00:
L8775:  .byte $08, $88, $87, $86, $85, $84, $83, $82, $81

;----------------------------------------------------------------------------------------------------

;Used by dungeon music SQ2.

SQ2Attack01:
L877E:  .byte $04, $86, $89, $8C, $90

SQ2Sustain01:
L8783:  .byte $04, $90, $8E, $90, $8E

SQ2Release01:
L8788:  .byte $0C, $8D, $89, $87, $86, $86, $85, $85, $84, $84, $83, $83, $82

;----------------------------------------------------------------------------------------------------

;Used by dungeon music Triangle.

TriAttack02:
L8795:  .byte $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

TriSustain02:
L879E:  .byte $10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0F, $00, $00, $00, $00, $00
L87AE:  .byte $00

TriRelease02:
L87AF:  .byte $08, $00, $00, $00, $00, $00, $00, $00, $00

;----------------------------------------------------------------------------------------------------

;Used by dungeon music SQ2.

SQ2Attack03:
L87B8:  .byte $03, $0C, $10, $0D

SQ2Sustain03:
L87BC:  .byte $01, $08

SQ2Release03:
L87BE:  .byte $08, $08, $07, $06, $05, $04, $03, $02, $01

;----------------------------------------------------------------------------------------------------

;Dungeon music SQ1 data.

DungeonSQ1:
L87C7:  .byte CHN_VOLUME, $0C            ;Set channel volume to 12.
L87C9:  .byte CHN_VIBRATO, $00, $00, $00 ;Disable vibrato.
L87CD:  .byte CHN_ASR, $00               ;Set ASR data index to 0.
L87CF:  .byte $24, $07                   ;Play note C5  for 7 frames.
L87D1:  .byte $21, $07                   ;Play note A4  for 7 frames.
L87D3:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L87D5:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L87D7:  .byte $24, $07                   ;Play note C5  for 7 frames.
L87D9:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L87DB:  .byte $21, $07                   ;Play note A4  for 7 frames.
L87DD:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L87DF:  .byte $24, $07                   ;Play note C5  for 7 frames.
L87E1:  .byte $21, $07                   ;Play note A4  for 7 frames.
L87E3:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L87E5:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L87E7:  .byte $24, $07                   ;Play note C5  for 7 frames.
L87E9:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L87EB:  .byte $21, $07                   ;Play note A4  for 7 frames.
L87ED:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L87EF:  .byte $24, $07                   ;Play note C5  for 7 frames.
L87F1:  .byte $21, $07                   ;Play note A4  for 7 frames.
L87F3:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L87F5:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L87F7:  .byte $24, $07                   ;Play note C5  for 7 frames.
L87F9:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L87FB:  .byte $21, $07                   ;Play note A4  for 7 frames.
L87FD:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L87FF:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8801:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8803:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8805:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8807:  .byte $24, $07                   ;Play note C5  for 7 frames.
L8809:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L880B:  .byte $21, $07                   ;Play note A4  for 7 frames.
L880D:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L880F:  .byte $24, $07                   ;Play note C5  for 7 frames.
L8811:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8813:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8815:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8817:  .byte $24, $07                   ;Play note C5  for 7 frames.
L8819:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L881B:  .byte $21, $07                   ;Play note A4  for 7 frames.
L881D:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L881F:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8821:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8823:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8825:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8827:  .byte $24, $07                   ;Play note C5  for 7 frames.
L8829:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L882B:  .byte $21, $07                   ;Play note A4  for 7 frames.
L882D:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L882F:  .byte $24, $07                   ;Play note C5  for 7 frames.
L8831:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8833:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8835:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8837:  .byte $24, $07                   ;Play note C5  for 7 frames.
L8839:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L883B:  .byte $21, $07                   ;Play note A4  for 7 frames.
L883D:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L883F:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8841:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8843:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8845:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8847:  .byte $24, $07                   ;Play note C5  for 7 frames.
L8849:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L884B:  .byte $21, $07                   ;Play note A4  for 7 frames.
L884D:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L884F:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8851:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8853:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8855:  .byte $26, $07                   ;Play note D5  for 7 frames.
L8857:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8859:  .byte $23, $07                   ;Play note B4  for 7 frames.
L885B:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L885D:  .byte $23, $07                   ;Play note B4  for 7 frames.
L885F:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8861:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8863:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8865:  .byte $26, $07                   ;Play note D5  for 7 frames.
L8867:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8869:  .byte $23, $07                   ;Play note B4  for 7 frames.
L886B:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L886D:  .byte $23, $07                   ;Play note B4  for 7 frames.
L886F:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8871:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8873:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8875:  .byte $26, $07                   ;Play note D5  for 7 frames.
L8877:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8879:  .byte $23, $07                   ;Play note B4  for 7 frames.
L887B:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L887D:  .byte $23, $07                   ;Play note B4  for 7 frames.
L887F:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8881:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8883:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8885:  .byte $26, $07                   ;Play note D5  for 7 frames.
L8887:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8889:  .byte $23, $07                   ;Play note B4  for 7 frames.
L888B:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L888D:  .byte $23, $07                   ;Play note B4  for 7 frames.
L888F:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8891:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8893:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8895:  .byte $26, $07                   ;Play note D5  for 7 frames.
L8897:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8899:  .byte $23, $07                   ;Play note B4  for 7 frames.
L889B:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L889D:  .byte $23, $07                   ;Play note B4  for 7 frames.
L889F:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L88A1:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L88A3:  .byte $23, $07                   ;Play note B4  for 7 frames.
L88A5:  .byte $26, $07                   ;Play note D5  for 7 frames.
L88A7:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L88A9:  .byte $23, $07                   ;Play note B4  for 7 frames.
L88AB:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L88AD:  .byte $23, $07                   ;Play note B4  for 7 frames.
L88AF:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L88B1:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L88B3:  .byte $23, $07                   ;Play note B4  for 7 frames.
L88B5:  .byte $26, $07                   ;Play note D5  for 7 frames.
L88B7:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L88B9:  .byte $23, $07                   ;Play note B4  for 7 frames.
L88BB:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L88BD:  .byte $23, $07                   ;Play note B4  for 7 frames.
L88BF:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L88C1:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L88C3:  .byte $23, $07                   ;Play note B4  for 7 frames.
L88C5:  .byte $26, $07                   ;Play note D5  for 7 frames.
L88C7:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L88C9:  .byte $23, $07                   ;Play note B4  for 7 frames.
L88CB:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L88CD:  .byte $23, $07                   ;Play note B4  for 7 frames.
L88CF:  .byte $24, $07                   ;Play note C5  for 7 frames.
L88D1:  .byte $21, $07                   ;Play note A4  for 7 frames.
L88D3:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L88D5:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L88D7:  .byte $24, $07                   ;Play note C5  for 7 frames.
L88D9:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L88DB:  .byte $21, $07                   ;Play note A4  for 7 frames.
L88DD:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L88DF:  .byte $24, $07                   ;Play note C5  for 7 frames.
L88E1:  .byte $21, $07                   ;Play note A4  for 7 frames.
L88E3:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L88E5:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L88E7:  .byte $24, $07                   ;Play note C5  for 7 frames.
L88E9:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L88EB:  .byte $21, $07                   ;Play note A4  for 7 frames.
L88ED:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L88EF:  .byte $24, $07                   ;Play note C5  for 7 frames.
L88F1:  .byte $21, $07                   ;Play note A4  for 7 frames.
L88F3:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L88F5:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L88F7:  .byte $24, $07                   ;Play note C5  for 7 frames.
L88F9:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L88FB:  .byte $21, $07                   ;Play note A4  for 7 frames.
L88FD:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L88FF:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8901:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8903:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8905:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8907:  .byte $24, $07                   ;Play note C5  for 7 frames.
L8909:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L890B:  .byte $21, $07                   ;Play note A4  for 7 frames.
L890D:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L890F:  .byte $24, $07                   ;Play note C5  for 7 frames.
L8911:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8913:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8915:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8917:  .byte $24, $07                   ;Play note C5  for 7 frames.
L8919:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L891B:  .byte $21, $07                   ;Play note A4  for 7 frames.
L891D:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L891F:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8921:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8923:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8925:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8927:  .byte $24, $07                   ;Play note C5  for 7 frames.
L8929:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L892B:  .byte $21, $07                   ;Play note A4  for 7 frames.
L892D:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L892F:  .byte $24, $07                   ;Play note C5  for 7 frames.
L8931:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8933:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8935:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8937:  .byte $24, $07                   ;Play note C5  for 7 frames.
L8939:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L893B:  .byte $21, $07                   ;Play note A4  for 7 frames.
L893D:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L893F:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8941:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8943:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8945:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8947:  .byte $24, $07                   ;Play note C5  for 7 frames.
L8949:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L894B:  .byte $21, $07                   ;Play note A4  for 7 frames.
L894D:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L894F:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8951:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8953:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8955:  .byte $26, $07                   ;Play note D5  for 7 frames.
L8957:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8959:  .byte $23, $07                   ;Play note B4  for 7 frames.
L895B:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L895D:  .byte $23, $07                   ;Play note B4  for 7 frames.
L895F:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8961:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8963:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8965:  .byte $26, $07                   ;Play note D5  for 7 frames.
L8967:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8969:  .byte $23, $07                   ;Play note B4  for 7 frames.
L896B:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L896D:  .byte $23, $07                   ;Play note B4  for 7 frames.
L896F:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8971:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8973:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8975:  .byte $26, $07                   ;Play note D5  for 7 frames.
L8977:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8979:  .byte $23, $07                   ;Play note B4  for 7 frames.
L897B:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L897D:  .byte $23, $07                   ;Play note B4  for 7 frames.
L897F:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8981:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8983:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8985:  .byte $26, $07                   ;Play note D5  for 7 frames.
L8987:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8989:  .byte $23, $07                   ;Play note B4  for 7 frames.
L898B:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L898D:  .byte $23, $07                   ;Play note B4  for 7 frames.
L898F:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8991:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8993:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8995:  .byte $26, $07                   ;Play note D5  for 7 frames.
L8997:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8999:  .byte $23, $07                   ;Play note B4  for 7 frames.
L899B:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L899D:  .byte $23, $07                   ;Play note B4  for 7 frames.
L899F:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L89A1:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L89A3:  .byte $23, $07                   ;Play note B4  for 7 frames.
L89A5:  .byte $26, $07                   ;Play note D5  for 7 frames.
L89A7:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L89A9:  .byte $23, $07                   ;Play note B4  for 7 frames.
L89AB:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L89AD:  .byte $23, $07                   ;Play note B4  for 7 frames.
L89AF:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L89B1:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L89B3:  .byte $23, $07                   ;Play note B4  for 7 frames.
L89B5:  .byte $26, $07                   ;Play note D5  for 7 frames.
L89B7:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L89B9:  .byte $23, $07                   ;Play note B4  for 7 frames.
L89BB:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L89BD:  .byte $23, $07                   ;Play note B4  for 7 frames.
L89BF:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L89C1:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L89C3:  .byte $23, $07                   ;Play note B4  for 7 frames.
L89C5:  .byte $26, $07                   ;Play note D5  for 7 frames.
L89C7:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L89C9:  .byte $23, $07                   ;Play note B4  for 7 frames.
L89CB:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L89CD:  .byte $23, $07                   ;Play note B4  for 7 frames.
L89CF:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L89D1:  .byte $29, $07                   ;Play note F5  for 7 frames.
L89D3:  .byte $26, $07                   ;Play note D5  for 7 frames.
L89D5:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L89D7:  .byte $29, $07                   ;Play note F5  for 7 frames.
L89D9:  .byte $27, $07                   ;Play note D#5 for 7 frames.
L89DB:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L89DD:  .byte $21, $07                   ;Play note A4  for 7 frames.
L89DF:  .byte $1B, $07                   ;Play note D#4 for 7 frames.
L89E1:  .byte $1B, $07                   ;Play note D#4 for 7 frames.
L89E3:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L89E5:  .byte $1B, $07                   ;Play note D#4 for 7 frames.
L89E7:  .byte $1B, $07                   ;Play note D#4 for 7 frames.
L89E9:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L89EB:  .byte $1F, $07                   ;Play note G4  for 7 frames.
L89ED:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L89EF:  .byte $21, $07                   ;Play note A4  for 7 frames.
L89F1:  .byte $24, $07                   ;Play note C5  for 7 frames.
L89F3:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L89F5:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L89F7:  .byte $24, $07                   ;Play note C5  for 7 frames.
L89F9:  .byte $27, $07                   ;Play note D#5 for 7 frames.
L89FB:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L89FD:  .byte $29, $07                   ;Play note F5  for 7 frames.
L89FF:  .byte $27, $07                   ;Play note D#5 for 7 frames.
L8A01:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A03:  .byte CHN_SILENCE, $07           ;Silence channel for 7 frames.
L8A05:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8A07:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8A09:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8A0B:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A0D:  .byte $29, $07                   ;Play note F5  for 7 frames.
L8A0F:  .byte $26, $07                   ;Play note D5  for 7 frames.
L8A11:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8A13:  .byte $29, $07                   ;Play note F5  for 7 frames.
L8A15:  .byte $27, $07                   ;Play note D#5 for 7 frames.
L8A17:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8A19:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8A1B:  .byte $1B, $07                   ;Play note D#4 for 7 frames.
L8A1D:  .byte $1B, $07                   ;Play note D#4 for 7 frames.
L8A1F:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8A21:  .byte $1B, $07                   ;Play note D#4 for 7 frames.
L8A23:  .byte $1B, $07                   ;Play note D#4 for 7 frames.
L8A25:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8A27:  .byte $1F, $07                   ;Play note G4  for 7 frames.
L8A29:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8A2B:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8A2D:  .byte $24, $07                   ;Play note C5  for 7 frames.
L8A2F:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8A31:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8A33:  .byte $24, $07                   ;Play note C5  for 7 frames.
L8A35:  .byte $27, $07                   ;Play note D#5 for 7 frames.
L8A37:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8A39:  .byte $29, $07                   ;Play note F5  for 7 frames.
L8A3B:  .byte $27, $07                   ;Play note D#5 for 7 frames.
L8A3D:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A3F:  .byte CHN_SILENCE, $07           ;Silence channel for 7 frames.
L8A41:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8A43:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8A45:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8A47:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8A49:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A4B:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A4D:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8A4F:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A51:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A53:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8A55:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A57:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A59:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8A5B:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A5D:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A5F:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8A61:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A63:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A65:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8A67:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A69:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A6B:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8A6D:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A6F:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A71:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8A73:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A75:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A77:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8A79:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A7B:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A7D:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8A7F:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A81:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A83:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8A85:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A87:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A89:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8A8B:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A8D:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A8F:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8A91:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A93:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A95:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8A97:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A99:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A9B:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8A9D:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8A9F:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8AA1:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8AA3:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8AA5:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8AA7:  .byte CHN_JUMP, $00, $20, $FD    ;Jump back 736 bytes to $87C7.

;----------------------------------------------------------------------------------------------------

;Dungeon music SQ2 data.

DungeonSQ2:
L8AAB:  .byte CHN_VOLUME, $0A            ;Set channel volume to 10.
L8AAD:  .byte CHN_VIBRATO, $00, $08, $0C ;Set vibrato speed=8, intensity=12.
L8AB1:  .byte CHN_ASR, $01               ;Set ASR data index to 1.
L8AB3:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8AB5:  .byte $1B, $1C                   ;Play note D#4 for 28 frames.
L8AB7:  .byte $19, $1C                   ;Play note C#4 for 28 frames.
L8AB9:  .byte $1B, $1C                   ;Play note D#4 for 28 frames.
L8ABB:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8ABD:  .byte $1B, $1C                   ;Play note D#4 for 28 frames.
L8ABF:  .byte $19, $1C                   ;Play note C#4 for 28 frames.
L8AC1:  .byte $1B, $1C                   ;Play note D#4 for 28 frames.
L8AC3:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8AC5:  .byte $1B, $1C                   ;Play note D#4 for 28 frames.
L8AC7:  .byte $19, $1C                   ;Play note C#4 for 28 frames.
L8AC9:  .byte $1B, $1C                   ;Play note D#4 for 28 frames.
L8ACB:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8ACD:  .byte $1B, $1C                   ;Play note D#4 for 28 frames.
L8ACF:  .byte $19, $1C                   ;Play note C#4 for 28 frames.
L8AD1:  .byte $1B, $1C                   ;Play note D#4 for 28 frames.
L8AD3:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8AD5:  .byte $1C, $1C                   ;Play note E4  for 28 frames.
L8AD7:  .byte $1A, $1C                   ;Play note D4  for 28 frames.
L8AD9:  .byte $1C, $1C                   ;Play note E4  for 28 frames.
L8ADB:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8ADD:  .byte $1C, $1C                   ;Play note E4  for 28 frames.
L8ADF:  .byte $1A, $1C                   ;Play note D4  for 28 frames.
L8AE1:  .byte $1C, $1C                   ;Play note E4  for 28 frames.
L8AE3:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8AE5:  .byte $1C, $1C                   ;Play note E4  for 28 frames.
L8AE7:  .byte $1A, $1C                   ;Play note D4  for 28 frames.
L8AE9:  .byte $1C, $1C                   ;Play note E4  for 28 frames.
L8AEB:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8AED:  .byte $1C, $1C                   ;Play note E4  for 28 frames.
L8AEF:  .byte $1A, $1C                   ;Play note D4  for 28 frames.
L8AF1:  .byte $1C, $1C                   ;Play note E4  for 28 frames.
L8AF3:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8AF5:  .byte $1B, $1C                   ;Play note D#4 for 28 frames.
L8AF7:  .byte $19, $1C                   ;Play note C#4 for 28 frames.
L8AF9:  .byte $1B, $1C                   ;Play note D#4 for 28 frames.
L8AFB:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8AFD:  .byte $1B, $1C                   ;Play note D#4 for 28 frames.
L8AFF:  .byte $19, $1C                   ;Play note C#4 for 28 frames.
L8B01:  .byte $1B, $1C                   ;Play note D#4 for 28 frames.
L8B03:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8B05:  .byte $1B, $1C                   ;Play note D#4 for 28 frames.
L8B07:  .byte $19, $1C                   ;Play note C#4 for 28 frames.
L8B09:  .byte $1B, $1C                   ;Play note D#4 for 28 frames.
L8B0B:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8B0D:  .byte $1B, $1C                   ;Play note D#4 for 28 frames.
L8B0F:  .byte $19, $1C                   ;Play note C#4 for 28 frames.
L8B11:  .byte $1B, $1C                   ;Play note D#4 for 28 frames.
L8B13:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8B15:  .byte $1C, $1C                   ;Play note E4  for 28 frames.
L8B17:  .byte $1A, $1C                   ;Play note D4  for 28 frames.
L8B19:  .byte $1C, $1C                   ;Play note E4  for 28 frames.
L8B1B:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8B1D:  .byte $1C, $1C                   ;Play note E4  for 28 frames.
L8B1F:  .byte $1A, $1C                   ;Play note D4  for 28 frames.
L8B21:  .byte $1C, $1C                   ;Play note E4  for 28 frames.
L8B23:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8B25:  .byte $1C, $1C                   ;Play note E4  for 28 frames.
L8B27:  .byte $1A, $1C                   ;Play note D4  for 28 frames.
L8B29:  .byte $1C, $1C                   ;Play note E4  for 28 frames.
L8B2B:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8B2D:  .byte $1C, $1C                   ;Play note E4  for 28 frames.
L8B2F:  .byte $1A, $1C                   ;Play note D4  for 28 frames.
L8B31:  .byte $1C, $1C                   ;Play note E4  for 28 frames.
L8B33:  .byte CHN_VIBRATO, $00, $00, $00 ;Disable vibrato.
L8B37:  .byte CHN_ASR, $03               ;Set ASR data index to 3.
L8B39:  .byte CHN_SILENCE, $38           ;Silence channel for 56 frames.
L8B3B:  .byte $18, $07                   ;Play note C4  for 7 frames.
L8B3D:  .byte $18, $07                   ;Play note C4  for 7 frames.
L8B3F:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8B41:  .byte $18, $07                   ;Play note C4  for 7 frames.
L8B43:  .byte $18, $07                   ;Play note C4  for 7 frames.
L8B45:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8B47:  .byte $1F, $07                   ;Play note G4  for 7 frames.
L8B49:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8B4B:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8B4D:  .byte $24, $07                   ;Play note C5  for 7 frames.
L8B4F:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8B51:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8B53:  .byte $24, $07                   ;Play note C5  for 7 frames.
L8B55:  .byte $27, $07                   ;Play note D#5 for 7 frames.
L8B57:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8B59:  .byte $29, $07                   ;Play note F5  for 7 frames.
L8B5B:  .byte $27, $07                   ;Play note D#5 for 7 frames.
L8B5D:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8B5F:  .byte CHN_SILENCE, $07           ;Silence channel for 7 frames.
L8B61:  .byte $27, $07                   ;Play note D#5 for 7 frames.
L8B63:  .byte $27, $07                   ;Play note D#5 for 7 frames.
L8B65:  .byte $27, $07                   ;Play note D#5 for 7 frames.
L8B67:  .byte CHN_SILENCE, $38           ;Silence channel for 56 frames.
L8B69:  .byte $18, $07                   ;Play note C4  for 7 frames.
L8B6B:  .byte $18, $07                   ;Play note C4  for 7 frames.
L8B6D:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8B6F:  .byte $18, $07                   ;Play note C4  for 7 frames.
L8B71:  .byte $18, $07                   ;Play note C4  for 7 frames.
L8B73:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8B75:  .byte $1F, $07                   ;Play note G4  for 7 frames.
L8B77:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8B79:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8B7B:  .byte $24, $07                   ;Play note C5  for 7 frames.
L8B7D:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L8B7F:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8B81:  .byte $24, $07                   ;Play note C5  for 7 frames.
L8B83:  .byte $27, $07                   ;Play note D#5 for 7 frames.
L8B85:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8B87:  .byte $29, $07                   ;Play note F5  for 7 frames.
L8B89:  .byte $27, $07                   ;Play note D#5 for 7 frames.
L8B8B:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L8B8D:  .byte CHN_SILENCE, $07           ;Silence channel for 7 frames.
L8B8F:  .byte $27, $07                   ;Play note D#5 for 7 frames.
L8B91:  .byte $27, $07                   ;Play note D#5 for 7 frames.
L8B93:  .byte $27, $07                   ;Play note D#5 for 7 frames.
L8B95:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8B97:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8B99:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8B9B:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8B9D:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8B9F:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BA1:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8BA3:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BA5:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BA7:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8BA9:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BAB:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BAD:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8BAF:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BB1:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BB3:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8BB5:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BB7:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BB9:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8BBB:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BBD:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BBF:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8BC1:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BC3:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BC5:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8BC7:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BC9:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BCB:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8BCD:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BCF:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BD1:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8BD3:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BD5:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BD7:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8BD9:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BDB:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BDD:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8BDF:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BE1:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BE3:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8BE5:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BE7:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BE9:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8BEB:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BED:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BEF:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8BF1:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BF3:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BF5:  .byte CHN_JUMP, $00, $B6, $FE    ;Jump back 330 bytes to $8AAB.

;----------------------------------------------------------------------------------------------------

;Dungeon music triangle data.

DungeonTri:
L8BF9:  .byte CHN_VOLUME, $0F            ;Set channel volume to 15.
L8BFB:  .byte CHN_VIBRATO, $00, $0A, $40 ;Set vibrato speed=10, intensity=64.
L8BFF:  .byte CHN_ASR, $02               ;Set ASR data index to 2.
L8C01:  .byte $05, $07                   ;Play note F1  for 7 frames.
L8C03:  .byte $05, $07                   ;Play note F1  for 7 frames.
L8C05:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8C07:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8C09:  .byte $05, $07                   ;Play note F1  for 7 frames.
L8C0B:  .byte $05, $07                   ;Play note F1  for 7 frames.
L8C0D:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8C0F:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8C11:  .byte $00, $07                   ;Play note C1  for 7 frames.
L8C13:  .byte $00, $07                   ;Play note C1  for 7 frames.
L8C15:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8C17:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8C19:  .byte $00, $07                   ;Play note C1  for 7 frames.
L8C1B:  .byte $00, $07                   ;Play note C1  for 7 frames.
L8C1D:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8C1F:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8C21:  .byte $05, $07                   ;Play note F1  for 7 frames.
L8C23:  .byte $05, $07                   ;Play note F1  for 7 frames.
L8C25:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8C27:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8C29:  .byte $05, $07                   ;Play note F1  for 7 frames.
L8C2B:  .byte $05, $07                   ;Play note F1  for 7 frames.
L8C2D:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8C2F:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8C31:  .byte $00, $07                   ;Play note C1  for 7 frames.
L8C33:  .byte $00, $07                   ;Play note C1  for 7 frames.
L8C35:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8C37:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8C39:  .byte $00, $07                   ;Play note C1  for 7 frames.
L8C3B:  .byte $00, $07                   ;Play note C1  for 7 frames.
L8C3D:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8C3F:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8C41:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L8C43:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L8C45:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8C47:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8C49:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L8C4B:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L8C4D:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8C4F:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8C51:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
L8C53:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
L8C55:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8C57:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8C59:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
L8C5B:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
L8C5D:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8C5F:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8C61:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L8C63:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L8C65:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8C67:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8C69:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L8C6B:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L8C6D:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8C6F:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8C71:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
L8C73:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
L8C75:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8C77:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8C79:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
L8C7B:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
L8C7D:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8C7F:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8C81:  .byte $05, $07                   ;Play note F1  for 7 frames.
L8C83:  .byte $05, $07                   ;Play note F1  for 7 frames.
L8C85:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8C87:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8C89:  .byte $05, $07                   ;Play note F1  for 7 frames.
L8C8B:  .byte $05, $07                   ;Play note F1  for 7 frames.
L8C8D:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8C8F:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8C91:  .byte $00, $07                   ;Play note C1  for 7 frames.
L8C93:  .byte $00, $07                   ;Play note C1  for 7 frames.
L8C95:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8C97:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8C99:  .byte $00, $07                   ;Play note C1  for 7 frames.
L8C9B:  .byte $00, $07                   ;Play note C1  for 7 frames.
L8C9D:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8C9F:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8CA1:  .byte $05, $07                   ;Play note F1  for 7 frames.
L8CA3:  .byte $05, $07                   ;Play note F1  for 7 frames.
L8CA5:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8CA7:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8CA9:  .byte $05, $07                   ;Play note F1  for 7 frames.
L8CAB:  .byte $05, $07                   ;Play note F1  for 7 frames.
L8CAD:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8CAF:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8CB1:  .byte $00, $07                   ;Play note C1  for 7 frames.
L8CB3:  .byte $00, $07                   ;Play note C1  for 7 frames.
L8CB5:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8CB7:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8CB9:  .byte $00, $07                   ;Play note C1  for 7 frames.
L8CBB:  .byte $00, $07                   ;Play note C1  for 7 frames.
L8CBD:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8CBF:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8CC1:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L8CC3:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L8CC5:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8CC7:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8CC9:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L8CCB:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L8CCD:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8CCF:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8CD1:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
L8CD3:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
L8CD5:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8CD7:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8CD9:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
L8CDB:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
L8CDD:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8CDF:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8CE1:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L8CE3:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L8CE5:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8CE7:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8CE9:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L8CEB:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L8CED:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8CEF:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8CF1:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
L8CF3:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
L8CF5:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8CF7:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8CF9:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
L8CFB:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
L8CFD:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8CFF:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L8D01:  .byte CHN_SILENCE, $70           ;Silence channel for 112 frames.
L8D03:  .byte CHN_SILENCE, $70           ;Silence channel for 112 frames.
L8D05:  .byte $09, $07                   ;Play note A1  for 7 frames.
L8D07:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D09:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
L8D0B:  .byte $0F, $07                   ;Play note D#2 for 7 frames.
L8D0D:  .byte $10, $07                   ;Play note E2  for 7 frames.
L8D0F:  .byte $0F, $07                   ;Play note D#2 for 7 frames.
L8D11:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8D13:  .byte $15, $07                   ;Play note A2  for 7 frames.
L8D15:  .byte $15, $07                   ;Play note A2  for 7 frames.
L8D17:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8D19:  .byte $15, $07                   ;Play note A2  for 7 frames.
L8D1B:  .byte $15, $07                   ;Play note A2  for 7 frames.
L8D1D:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8D1F:  .byte $09, $07                   ;Play note A1  for 7 frames.
L8D21:  .byte $09, $07                   ;Play note A1  for 7 frames.
L8D23:  .byte $09, $07                   ;Play note A1  for 7 frames.
L8D25:  .byte $09, $07                   ;Play note A1  for 7 frames.
L8D27:  .byte $09, $07                   ;Play note A1  for 7 frames.
L8D29:  .byte $09, $07                   ;Play note A1  for 7 frames.
L8D2B:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L8D2D:  .byte $09, $07                   ;Play note A1  for 7 frames.
L8D2F:  .byte $09, $07                   ;Play note A1  for 7 frames.
L8D31:  .byte $09, $07                   ;Play note A1  for 7 frames.
L8D33:  .byte $09, $07                   ;Play note A1  for 7 frames.
L8D35:  .byte $09, $07                   ;Play note A1  for 7 frames.
L8D37:  .byte $09, $07                   ;Play note A1  for 7 frames.
L8D39:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L8D3B:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D3D:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D3F:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8D41:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8D43:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D45:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D47:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8D49:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8D4B:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D4D:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D4F:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8D51:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8D53:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D55:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D57:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8D59:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8D5B:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D5D:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D5F:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8D61:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8D63:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D65:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D67:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8D69:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8D6B:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D6D:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D6F:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8D71:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8D73:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D75:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D77:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8D79:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8D7B:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D7D:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D7F:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8D81:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8D83:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D85:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D87:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8D89:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8D8B:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D8D:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D8F:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8D91:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8D93:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D95:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D97:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8D99:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8D9B:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D9D:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8D9F:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8DA1:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8DA3:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8DA5:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8DA7:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8DA9:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8DAB:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8DAD:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8DAF:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8DB1:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8DB3:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8DB5:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L8DB7:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8DB9:  .byte $18, $07                   ;Play note C3  for 7 frames.
L8DBB:  .byte CHN_JUMP, $00, $3E, $FE    ;Jump back 450 bytes to $8BF9.

;----------------------------------------------------------------------------------------------------

;Used by Town music SQ1.

SQ1Attack04:
L8DBF:  .byte $0A, $86, $89, $8C, $8F, $90, $8E, $8C, $8A, $88, $86

SQ1Sustain04:
L8DCA:  .byte $02, $88, $88

SQ1Release04:
L8DCD:  .byte $2D, $88, $88, $88, $88, $88, $88, $87, $87, $87, $87, $87, $87, $87, $87, $86
L8DDD:  .byte $86, $86, $86, $86, $86, $86, $86, $86, $85, $85, $85, $85, $85, $85, $85, $85
L8DED:  .byte $85, $85, $84, $84, $84, $84, $84, $84, $84, $84, $84, $84, $84, $83

;----------------------------------------------------------------------------------------------------

;Used by Town music SQ2.

SQ2Attack05:
L8DFB:  .byte $06, $06, $10, $0D, $0A, $05

SQ2Sustain05:
L8E01:  .byte $04, $07, $07, $07, $07

SQ2Release05:
L8E06:  .byte $0D, $06, $06, $06, $06, $05, $05, $05, $05, $04, $04, $04, $04, $04

;----------------------------------------------------------------------------------------------------

;Used by Town music Triangle.

TriAttack06:
L8E14:  .byte $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

TriSustain06:
L8E1D:  .byte $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

TriRelease06:
L8E26:  .byte $10, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $00, $00
L8E36:  .byte $00

;----------------------------------------------------------------------------------------------------

;Used in Town music SQ1 and SQ2.

SQ12Attack07:
L8E37:  .byte $06, $86, $8D, $90, $8D, $8A, $86

SQ12Sustain07:
L8E3E:  .byte $02, $87, $87

SQ12Release07:
L8E41:  .byte $09, $86, $86, $86, $85, $85, $85, $84, $84, $84

;----------------------------------------------------------------------------------------------------

;Used by Town music SQ2.

SQ2Attack08:
L8E4B:  .byte $06, $46, $50, $4D, $4A, $45

SQ2Sustain08:
L8E51:  .byte $04, $47, $47, $47, $47

SQ2Release08:
L8E56:  .byte $0D, $46, $46, $46, $46, $45, $45, $45, $45, $44, $44, $44, $44, $44

;----------------------------------------------------------------------------------------------------

;Used by Town music Triangle.

TriAttack09:
L8E64:  .byte $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

TriSustain09:
L8E6D:  .byte $08, $0F, $0F, $0F, $00, $00, $00, $00, $00

TriRelease09:
L8E76:  .byte $10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L8E86:  .byte $00

;----------------------------------------------------------------------------------------------------

;Used by Town music Triangle.

TriAttack0A:
L8E87:  .byte $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

TriSustain0A:
L8E90:  .byte $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

TriRelease0A:
L8E99:  .byte $10, $0F, $0F, $0F, $0F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L8EA9:  .byte $00

;----------------------------------------------------------------------------------------------------

;Town music SQ1 data.

TownSQ1:
L8EAA:  .byte CHN_VOLUME, $0F            ;Set channel volume to 15.
L8EAC:  .byte CHN_VIBRATO, $00, $08, $14 ;Set vibrato speed=8, intensity=20.
L8EB0:  .byte CHN_ASR, $04               ;Set ASR data index to 4.
L8EB2:  .byte $2A, $48                   ;Play note F#5 for 72 frames.
L8EB4:  .byte $2B, $12                   ;Play note G5  for 18 frames.
L8EB6:  .byte $2A, $12                   ;Play note F#5 for 18 frames.
L8EB8:  .byte $28, $12                   ;Play note E5  for 18 frames.
L8EBA:  .byte $26, $12                   ;Play note D5  for 18 frames.
L8EBC:  .byte $2D, $48                   ;Play note A5  for 72 frames.
L8EBE:  .byte $2B, $48                   ;Play note G5  for 72 frames.
L8EC0:  .byte $2B, $48                   ;Play note G5  for 72 frames.
L8EC2:  .byte $2B, $12                   ;Play note G5  for 18 frames.
L8EC4:  .byte $2A, $12                   ;Play note F#5 for 18 frames.
L8EC6:  .byte $28, $12                   ;Play note E5  for 18 frames.
L8EC8:  .byte $2A, $12                   ;Play note F#5 for 18 frames.
L8ECA:  .byte $21, $90                   ;Play note A4  for 144 frames.
L8ECC:  .byte $2F, $48                   ;Play note B5  for 72 frames.
L8ECE:  .byte $2B, $09                   ;Play note G5  for 9 frames.
L8ED0:  .byte $2D, $09                   ;Play note A5  for 9 frames.
L8ED2:  .byte $2B, $12                   ;Play note G5  for 18 frames.
L8ED4:  .byte $2A, $12                   ;Play note F#5 for 18 frames.
L8ED6:  .byte $28, $12                   ;Play note E5  for 18 frames.
L8ED8:  .byte $2D, $48                   ;Play note A5  for 72 frames.
L8EDA:  .byte $2A, $09                   ;Play note F#5 for 9 frames.
L8EDC:  .byte $2B, $09                   ;Play note G5  for 9 frames.
L8EDE:  .byte $2A, $12                   ;Play note F#5 for 18 frames.
L8EE0:  .byte $28, $12                   ;Play note E5  for 18 frames.
L8EE2:  .byte $26, $12                   ;Play note D5  for 18 frames.
L8EE4:  .byte $26, $18                   ;Play note D5  for 24 frames.
L8EE6:  .byte $28, $18                   ;Play note E5  for 24 frames.
L8EE8:  .byte $2A, $18                   ;Play note F#5 for 24 frames.
L8EEA:  .byte $2A, $18                   ;Play note F#5 for 24 frames.
L8EEC:  .byte $28, $18                   ;Play note E5  for 24 frames.
L8EEE:  .byte $26, $18                   ;Play note D5  for 24 frames.
L8EF0:  .byte $26, $18                   ;Play note D5  for 24 frames.
L8EF2:  .byte $28, $18                   ;Play note E5  for 24 frames.
L8EF4:  .byte $2A, $18                   ;Play note F#5 for 24 frames.
L8EF6:  .byte $2A, $18                   ;Play note F#5 for 24 frames.
L8EF8:  .byte $28, $18                   ;Play note E5  for 24 frames.
L8EFA:  .byte $26, $18                   ;Play note D5  for 24 frames.
L8EFC:  .byte $2D, $12                   ;Play note A5  for 18 frames.
L8EFE:  .byte $28, $24                   ;Play note E5  for 36 frames.
L8F00:  .byte $28, $12                   ;Play note E5  for 18 frames.
L8F02:  .byte $2D, $12                   ;Play note A5  for 18 frames.
L8F04:  .byte $28, $24                   ;Play note E5  for 36 frames.
L8F06:  .byte $28, $12                   ;Play note E5  for 18 frames.
L8F08:  .byte $2D, $12                   ;Play note A5  for 18 frames.
L8F0A:  .byte $28, $24                   ;Play note E5  for 36 frames.
L8F0C:  .byte $28, $12                   ;Play note E5  for 18 frames.
L8F0E:  .byte $2D, $12                   ;Play note A5  for 18 frames.
L8F10:  .byte $28, $24                   ;Play note E5  for 36 frames.
L8F12:  .byte $28, $12                   ;Play note E5  for 18 frames.
L8F14:  .byte $2D, $12                   ;Play note A5  for 18 frames.
L8F16:  .byte $28, $24                   ;Play note E5  for 36 frames.
L8F18:  .byte $28, $12                   ;Play note E5  for 18 frames.
L8F1A:  .byte $2D, $12                   ;Play note A5  for 18 frames.
L8F1C:  .byte $28, $24                   ;Play note E5  for 36 frames.
L8F1E:  .byte $28, $12                   ;Play note E5  for 18 frames.
L8F20:  .byte $2D, $12                   ;Play note A5  for 18 frames.
L8F22:  .byte $28, $24                   ;Play note E5  for 36 frames.
L8F24:  .byte $28, $12                   ;Play note E5  for 18 frames.
L8F26:  .byte $2D, $12                   ;Play note A5  for 18 frames.
L8F28:  .byte $28, $24                   ;Play note E5  for 36 frames.
L8F2A:  .byte $28, $12                   ;Play note E5  for 18 frames.
L8F2C:  .byte $32, $12                   ;Play note D6  for 18 frames.
L8F2E:  .byte $31, $06                   ;Play note C#6 for 6 frames.
L8F30:  .byte $32, $06                   ;Play note D6  for 6 frames.
L8F32:  .byte $31, $06                   ;Play note C#6 for 6 frames.
L8F34:  .byte $2F, $12                   ;Play note B5  for 18 frames.
L8F36:  .byte $2D, $12                   ;Play note A5  for 18 frames.
L8F38:  .byte $2F, $12                   ;Play note B5  for 18 frames.
L8F3A:  .byte $31, $12                   ;Play note C#6 for 18 frames.
L8F3C:  .byte $32, $12                   ;Play note D6  for 18 frames.
L8F3E:  .byte $2F, $12                   ;Play note B5  for 18 frames.
L8F40:  .byte $34, $12                   ;Play note E6  for 18 frames.
L8F42:  .byte $32, $06                   ;Play note D6  for 6 frames.
L8F44:  .byte $34, $06                   ;Play note E6  for 6 frames.
L8F46:  .byte $32, $06                   ;Play note D6  for 6 frames.
L8F48:  .byte $31, $12                   ;Play note C#6 for 18 frames.
L8F4A:  .byte $2F, $12                   ;Play note B5  for 18 frames.
L8F4C:  .byte $2D, $12                   ;Play note A5  for 18 frames.
L8F4E:  .byte $2F, $12                   ;Play note B5  for 18 frames.
L8F50:  .byte $31, $12                   ;Play note C#6 for 18 frames.
L8F52:  .byte $34, $12                   ;Play note E6  for 18 frames.
L8F54:  .byte $36, $12                   ;Play note F#6 for 18 frames.
L8F56:  .byte $34, $06                   ;Play note E6  for 6 frames.
L8F58:  .byte $36, $06                   ;Play note F#6 for 6 frames.
L8F5A:  .byte $34, $06                   ;Play note E6  for 6 frames.
L8F5C:  .byte $32, $12                   ;Play note D6  for 18 frames.
L8F5E:  .byte $34, $12                   ;Play note E6  for 18 frames.
L8F60:  .byte $36, $12                   ;Play note F#6 for 18 frames.
L8F62:  .byte $34, $06                   ;Play note E6  for 6 frames.
L8F64:  .byte $36, $06                   ;Play note F#6 for 6 frames.
L8F66:  .byte $34, $06                   ;Play note E6  for 6 frames.
L8F68:  .byte $32, $12                   ;Play note D6  for 18 frames.
L8F6A:  .byte $34, $12                   ;Play note E6  for 18 frames.
L8F6C:  .byte $36, $12                   ;Play note F#6 for 18 frames.
L8F6E:  .byte $34, $06                   ;Play note E6  for 6 frames.
L8F70:  .byte $36, $06                   ;Play note F#6 for 6 frames.
L8F72:  .byte $34, $06                   ;Play note E6  for 6 frames.
L8F74:  .byte $32, $12                   ;Play note D6  for 18 frames.
L8F76:  .byte $34, $12                   ;Play note E6  for 18 frames.
L8F78:  .byte $36, $12                   ;Play note F#6 for 18 frames.
L8F7A:  .byte $34, $06                   ;Play note E6  for 6 frames.
L8F7C:  .byte $36, $06                   ;Play note F#6 for 6 frames.
L8F7E:  .byte $34, $06                   ;Play note E6  for 6 frames.
L8F80:  .byte $32, $12                   ;Play note D6  for 18 frames.
L8F82:  .byte $34, $12                   ;Play note E6  for 18 frames.
L8F84:  .byte $2D, $36                   ;Play note A5  for 54 frames.
L8F86:  .byte $26, $12                   ;Play note D5  for 18 frames.
L8F88:  .byte $26, $48                   ;Play note D5  for 72 frames.
L8F8A:  .byte $2D, $36                   ;Play note A5  for 54 frames.
L8F8C:  .byte $26, $12                   ;Play note D5  for 18 frames.
L8F8E:  .byte $26, $48                   ;Play note D5  for 72 frames.
L8F90:  .byte $2D, $36                   ;Play note A5  for 54 frames.
L8F92:  .byte $26, $12                   ;Play note D5  for 18 frames.
L8F94:  .byte $26, $24                   ;Play note D5  for 36 frames.
L8F96:  .byte $2D, $24                   ;Play note A5  for 36 frames.
L8F98:  .byte $2D, $90                   ;Play note A5  for 144 frames.
L8F9A:  .byte CHN_ASR, $07               ;Set ASR data index to 7.
L8F9C:  .byte $23, $06                   ;Play note B4  for 6 frames.
L8F9E:  .byte $25, $06                   ;Play note C#5 for 6 frames.
L8FA0:  .byte $26, $06                   ;Play note D5  for 6 frames.
L8FA2:  .byte $28, $06                   ;Play note E5  for 6 frames.
L8FA4:  .byte $26, $06                   ;Play note D5  for 6 frames.
L8FA6:  .byte $25, $06                   ;Play note C#5 for 6 frames.
L8FA8:  .byte $25, $06                   ;Play note C#5 for 6 frames.
L8FAA:  .byte $26, $06                   ;Play note D5  for 6 frames.
L8FAC:  .byte $28, $06                   ;Play note E5  for 6 frames.
L8FAE:  .byte $2A, $06                   ;Play note F#5 for 6 frames.
L8FB0:  .byte $28, $06                   ;Play note E5  for 6 frames.
L8FB2:  .byte $26, $06                   ;Play note D5  for 6 frames.
L8FB4:  .byte $26, $06                   ;Play note D5  for 6 frames.
L8FB6:  .byte $28, $06                   ;Play note E5  for 6 frames.
L8FB8:  .byte $2A, $06                   ;Play note F#5 for 6 frames.
L8FBA:  .byte $2B, $06                   ;Play note G5  for 6 frames.
L8FBC:  .byte $2A, $06                   ;Play note F#5 for 6 frames.
L8FBE:  .byte $28, $06                   ;Play note E5  for 6 frames.
L8FC0:  .byte $28, $06                   ;Play note E5  for 6 frames.
L8FC2:  .byte $2A, $06                   ;Play note F#5 for 6 frames.
L8FC4:  .byte $2B, $06                   ;Play note G5  for 6 frames.
L8FC6:  .byte $2D, $06                   ;Play note A5  for 6 frames.
L8FC8:  .byte $2B, $06                   ;Play note G5  for 6 frames.
L8FCA:  .byte $2A, $06                   ;Play note F#5 for 6 frames.
L8FCC:  .byte CHN_JUMP, $00, $DE, $FE    ;Jump back 290 bytes to $8EAA.

;----------------------------------------------------------------------------------------------------

;Town music SQ2 data.

TownSQ2:
L8FD0:  .byte CHN_VOLUME, $0A            ;Set channel volume to 10.
L8FD2:  .byte CHN_VIBRATO, $00, $10, $18 ;Set vibrato speed=16, intensity=24.
L8FD6:  .byte CHN_ASR, $08               ;Set ASR data index to 8.
L8FD8:  .byte $1C, $12                   ;Play note E4  for 18 frames.
L8FDA:  .byte $1A, $12                   ;Play note D4  for 18 frames.
L8FDC:  .byte $1C, $12                   ;Play note E4  for 18 frames.
L8FDE:  .byte $15, $12                   ;Play note A3  for 18 frames.
L8FE0:  .byte $1C, $12                   ;Play note E4  for 18 frames.
L8FE2:  .byte $1A, $12                   ;Play note D4  for 18 frames.
L8FE4:  .byte $1C, $12                   ;Play note E4  for 18 frames.
L8FE6:  .byte $15, $12                   ;Play note A3  for 18 frames.
L8FE8:  .byte $1C, $12                   ;Play note E4  for 18 frames.
L8FEA:  .byte $1A, $12                   ;Play note D4  for 18 frames.
L8FEC:  .byte $1C, $12                   ;Play note E4  for 18 frames.
L8FEE:  .byte $17, $12                   ;Play note B3  for 18 frames.
L8FF0:  .byte $1C, $12                   ;Play note E4  for 18 frames.
L8FF2:  .byte $1A, $12                   ;Play note D4  for 18 frames.
L8FF4:  .byte $1C, $12                   ;Play note E4  for 18 frames.
L8FF6:  .byte $17, $12                   ;Play note B3  for 18 frames.
L8FF8:  .byte $1C, $12                   ;Play note E4  for 18 frames.
L8FFA:  .byte $1A, $12                   ;Play note D4  for 18 frames.
L8FFC:  .byte $1C, $12                   ;Play note E4  for 18 frames.
L8FFE:  .byte $16, $12                   ;Play note A#3 for 18 frames.
L9000:  .byte $1C, $12                   ;Play note E4  for 18 frames.
L9002:  .byte $1A, $12                   ;Play note D4  for 18 frames.
L9004:  .byte $1C, $12                   ;Play note E4  for 18 frames.
L9006:  .byte $17, $12                   ;Play note B3  for 18 frames.
L9008:  .byte $1C, $12                   ;Play note E4  for 18 frames.
L900A:  .byte $1A, $12                   ;Play note D4  for 18 frames.
L900C:  .byte $1C, $12                   ;Play note E4  for 18 frames.
L900E:  .byte $15, $12                   ;Play note A3  for 18 frames.
L9010:  .byte $1C, $12                   ;Play note E4  for 18 frames.
L9012:  .byte $1A, $12                   ;Play note D4  for 18 frames.
L9014:  .byte $1C, $12                   ;Play note E4  for 18 frames.
L9016:  .byte $15, $12                   ;Play note A3  for 18 frames.
L9018:  .byte $1F, $12                   ;Play note G4  for 18 frames.
L901A:  .byte $1E, $12                   ;Play note F#4 for 18 frames.
L901C:  .byte $1C, $12                   ;Play note E4  for 18 frames.
L901E:  .byte $1A, $12                   ;Play note D4  for 18 frames.
L9020:  .byte $19, $12                   ;Play note C#4 for 18 frames.
L9022:  .byte $1A, $12                   ;Play note D4  for 18 frames.
L9024:  .byte $1C, $12                   ;Play note E4  for 18 frames.
L9026:  .byte $19, $12                   ;Play note C#4 for 18 frames.
L9028:  .byte $21, $12                   ;Play note A4  for 18 frames.
L902A:  .byte $1F, $12                   ;Play note G4  for 18 frames.
L902C:  .byte $1E, $12                   ;Play note F#4 for 18 frames.
L902E:  .byte $1C, $12                   ;Play note E4  for 18 frames.
L9030:  .byte $1A, $12                   ;Play note D4  for 18 frames.
L9032:  .byte $1C, $12                   ;Play note E4  for 18 frames.
L9034:  .byte $1E, $12                   ;Play note F#4 for 18 frames.
L9036:  .byte $1A, $12                   ;Play note D4  for 18 frames.
L9038:  .byte $23, $18                   ;Play note B4  for 24 frames.
L903A:  .byte $25, $18                   ;Play note C#5 for 24 frames.
L903C:  .byte $26, $18                   ;Play note D5  for 24 frames.
L903E:  .byte $26, $18                   ;Play note D5  for 24 frames.
L9040:  .byte $25, $18                   ;Play note C#5 for 24 frames.
L9042:  .byte $23, $18                   ;Play note B4  for 24 frames.
L9044:  .byte $23, $18                   ;Play note B4  for 24 frames.
L9046:  .byte $25, $18                   ;Play note C#5 for 24 frames.
L9048:  .byte $26, $18                   ;Play note D5  for 24 frames.
L904A:  .byte $26, $18                   ;Play note D5  for 24 frames.
L904C:  .byte $25, $18                   ;Play note C#5 for 24 frames.
L904E:  .byte $23, $18                   ;Play note B4  for 24 frames.
L9050:  .byte $28, $12                   ;Play note E5  for 18 frames.
L9052:  .byte $23, $12                   ;Play note B4  for 18 frames.
L9054:  .byte $26, $12                   ;Play note D5  for 18 frames.
L9056:  .byte $28, $12                   ;Play note E5  for 18 frames.
L9058:  .byte $28, $12                   ;Play note E5  for 18 frames.
L905A:  .byte $23, $12                   ;Play note B4  for 18 frames.
L905C:  .byte $26, $12                   ;Play note D5  for 18 frames.
L905E:  .byte $28, $12                   ;Play note E5  for 18 frames.
L9060:  .byte $28, $12                   ;Play note E5  for 18 frames.
L9062:  .byte $23, $12                   ;Play note B4  for 18 frames.
L9064:  .byte $26, $12                   ;Play note D5  for 18 frames.
L9066:  .byte $28, $12                   ;Play note E5  for 18 frames.
L9068:  .byte $28, $12                   ;Play note E5  for 18 frames.
L906A:  .byte $23, $12                   ;Play note B4  for 18 frames.
L906C:  .byte $26, $12                   ;Play note D5  for 18 frames.
L906E:  .byte $28, $12                   ;Play note E5  for 18 frames.
L9070:  .byte $28, $12                   ;Play note E5  for 18 frames.
L9072:  .byte $23, $12                   ;Play note B4  for 18 frames.
L9074:  .byte $26, $12                   ;Play note D5  for 18 frames.
L9076:  .byte $28, $12                   ;Play note E5  for 18 frames.
L9078:  .byte $28, $12                   ;Play note E5  for 18 frames.
L907A:  .byte $23, $12                   ;Play note B4  for 18 frames.
L907C:  .byte $26, $12                   ;Play note D5  for 18 frames.
L907E:  .byte $28, $12                   ;Play note E5  for 18 frames.
L9080:  .byte $28, $12                   ;Play note E5  for 18 frames.
L9082:  .byte $23, $12                   ;Play note B4  for 18 frames.
L9084:  .byte $26, $12                   ;Play note D5  for 18 frames.
L9086:  .byte $28, $12                   ;Play note E5  for 18 frames.
L9088:  .byte $28, $12                   ;Play note E5  for 18 frames.
L908A:  .byte $23, $12                   ;Play note B4  for 18 frames.
L908C:  .byte $26, $12                   ;Play note D5  for 18 frames.
L908E:  .byte $28, $12                   ;Play note E5  for 18 frames.
L9090:  .byte CHN_ASR, $05               ;Set ASR data index to 5.
L9092:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
L9094:  .byte $21, $12                   ;Play note A4  for 18 frames.
L9096:  .byte $2A, $12                   ;Play note F#5 for 18 frames.
L9098:  .byte $21, $12                   ;Play note A4  for 18 frames.
L909A:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
L909C:  .byte $21, $12                   ;Play note A4  for 18 frames.
L909E:  .byte $2A, $12                   ;Play note F#5 for 18 frames.
L90A0:  .byte $21, $12                   ;Play note A4  for 18 frames.
L90A2:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
L90A4:  .byte $21, $12                   ;Play note A4  for 18 frames.
L90A6:  .byte $28, $12                   ;Play note E5  for 18 frames.
L90A8:  .byte $21, $12                   ;Play note A4  for 18 frames.
L90AA:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
L90AC:  .byte $21, $12                   ;Play note A4  for 18 frames.
L90AE:  .byte $28, $12                   ;Play note E5  for 18 frames.
L90B0:  .byte $21, $12                   ;Play note A4  for 18 frames.
L90B2:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
L90B4:  .byte $1E, $12                   ;Play note F#4 for 18 frames.
L90B6:  .byte $26, $12                   ;Play note D5  for 18 frames.
L90B8:  .byte $1E, $12                   ;Play note F#4 for 18 frames.
L90BA:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
L90BC:  .byte $1E, $12                   ;Play note F#4 for 18 frames.
L90BE:  .byte $26, $12                   ;Play note D5  for 18 frames.
L90C0:  .byte $1E, $12                   ;Play note F#4 for 18 frames.
L90C2:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
L90C4:  .byte $1E, $12                   ;Play note F#4 for 18 frames.
L90C6:  .byte $26, $12                   ;Play note D5  for 18 frames.
L90C8:  .byte $1E, $12                   ;Play note F#4 for 18 frames.
L90CA:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
L90CC:  .byte $1F, $12                   ;Play note G4  for 18 frames.
L90CE:  .byte $26, $12                   ;Play note D5  for 18 frames.
L90D0:  .byte $1F, $12                   ;Play note G4  for 18 frames.
L90D2:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
L90D4:  .byte $26, $12                   ;Play note D5  for 18 frames.
L90D6:  .byte $23, $12                   ;Play note B4  for 18 frames.
L90D8:  .byte $2A, $12                   ;Play note F#5 for 18 frames.
L90DA:  .byte $26, $12                   ;Play note D5  for 18 frames.
L90DC:  .byte $23, $12                   ;Play note B4  for 18 frames.
L90DE:  .byte $26, $12                   ;Play note D5  for 18 frames.
L90E0:  .byte $2A, $12                   ;Play note F#5 for 18 frames.
L90E2:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
L90E4:  .byte $26, $12                   ;Play note D5  for 18 frames.
L90E6:  .byte $21, $12                   ;Play note A4  for 18 frames.
L90E8:  .byte $2A, $12                   ;Play note F#5 for 18 frames.
L90EA:  .byte $26, $12                   ;Play note D5  for 18 frames.
L90EC:  .byte $21, $12                   ;Play note A4  for 18 frames.
L90EE:  .byte $26, $12                   ;Play note D5  for 18 frames.
L90F0:  .byte $2A, $12                   ;Play note F#5 for 18 frames.
L90F2:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
L90F4:  .byte $26, $12                   ;Play note D5  for 18 frames.
L90F6:  .byte $23, $12                   ;Play note B4  for 18 frames.
L90F8:  .byte $29, $12                   ;Play note F5  for 18 frames.
L90FA:  .byte $26, $12                   ;Play note D5  for 18 frames.
L90FC:  .byte $23, $12                   ;Play note B4  for 18 frames.
L90FE:  .byte $26, $12                   ;Play note D5  for 18 frames.
L9100:  .byte $2A, $12                   ;Play note F#5 for 18 frames.
L9102:  .byte CHN_ASR, $07               ;Set ASR data index to 7.
L9104:  .byte $1C, $06                   ;Play note E4  for 6 frames.
L9106:  .byte $1E, $06                   ;Play note F#4 for 6 frames.
L9108:  .byte $1F, $06                   ;Play note G4  for 6 frames.
L910A:  .byte $21, $06                   ;Play note A4  for 6 frames.
L910C:  .byte $1F, $06                   ;Play note G4  for 6 frames.
L910E:  .byte $1E, $06                   ;Play note F#4 for 6 frames.
L9110:  .byte $1E, $06                   ;Play note F#4 for 6 frames.
L9112:  .byte $1F, $06                   ;Play note G4  for 6 frames.
L9114:  .byte $21, $06                   ;Play note A4  for 6 frames.
L9116:  .byte $23, $06                   ;Play note B4  for 6 frames.
L9118:  .byte $21, $06                   ;Play note A4  for 6 frames.
L911A:  .byte $1F, $06                   ;Play note G4  for 6 frames.
L911C:  .byte $1F, $06                   ;Play note G4  for 6 frames.
L911E:  .byte $21, $06                   ;Play note A4  for 6 frames.
L9120:  .byte $23, $06                   ;Play note B4  for 6 frames.
L9122:  .byte $25, $06                   ;Play note C#5 for 6 frames.
L9124:  .byte $23, $06                   ;Play note B4  for 6 frames.
L9126:  .byte $21, $06                   ;Play note A4  for 6 frames.
L9128:  .byte $21, $06                   ;Play note A4  for 6 frames.
L912A:  .byte $23, $06                   ;Play note B4  for 6 frames.
L912C:  .byte $25, $06                   ;Play note C#5 for 6 frames.
L912E:  .byte $26, $06                   ;Play note D5  for 6 frames.
L9130:  .byte $25, $06                   ;Play note C#5 for 6 frames.
L9132:  .byte $23, $06                   ;Play note B4  for 6 frames.
L9134:  .byte $23, $06                   ;Play note B4  for 6 frames.
L9136:  .byte $25, $06                   ;Play note C#5 for 6 frames.
L9138:  .byte $26, $06                   ;Play note D5  for 6 frames.
L913A:  .byte $28, $06                   ;Play note E5  for 6 frames.
L913C:  .byte $26, $06                   ;Play note D5  for 6 frames.
L913E:  .byte $25, $06                   ;Play note C#5 for 6 frames.
L9140:  .byte $25, $06                   ;Play note C#5 for 6 frames.
L9142:  .byte $26, $06                   ;Play note D5  for 6 frames.
L9144:  .byte $28, $06                   ;Play note E5  for 6 frames.
L9146:  .byte $2A, $06                   ;Play note F#5 for 6 frames.
L9148:  .byte $28, $06                   ;Play note E5  for 6 frames.
L914A:  .byte $26, $06                   ;Play note D5  for 6 frames.
L914C:  .byte $26, $06                   ;Play note D5  for 6 frames.
L914E:  .byte $28, $06                   ;Play note E5  for 6 frames.
L9150:  .byte $2A, $06                   ;Play note F#5 for 6 frames.
L9152:  .byte $2B, $06                   ;Play note G5  for 6 frames.
L9154:  .byte $2A, $06                   ;Play note F#5 for 6 frames.
L9156:  .byte $28, $06                   ;Play note E5  for 6 frames.
L9158:  .byte $28, $06                   ;Play note E5  for 6 frames.
L915A:  .byte $2A, $06                   ;Play note F#5 for 6 frames.
L915C:  .byte $2B, $06                   ;Play note G5  for 6 frames.
L915E:  .byte $2D, $06                   ;Play note A5  for 6 frames.
L9160:  .byte $2B, $06                   ;Play note G5  for 6 frames.
L9162:  .byte $2A, $06                   ;Play note F#5 for 6 frames.
L9164:  .byte CHN_JUMP, $00, $6C, $FE    ;Jump back 404 bytes to $8FD0.

;----------------------------------------------------------------------------------------------------

;Town music Triangle data.

TownTri:
L9168:  .byte CHN_VOLUME, $0F            ;Set channel volume to 15.
L916A:  .byte CHN_VIBRATO, $00, $10, $20 ;Set vibrato speed=16, intensity=32.
L916E:  .byte CHN_ASR, $06               ;Set ASR data index to 6.
L9170:  .byte $02, $48                   ;Play note D1  for 72 frames.
L9172:  .byte $0E, $48                   ;Play note D2  for 72 frames.
L9174:  .byte $02, $24                   ;Play note D1  for 36 frames.
L9176:  .byte $02, $24                   ;Play note D1  for 36 frames.
L9178:  .byte $0E, $48                   ;Play note D2  for 72 frames.
L917A:  .byte $02, $48                   ;Play note D1  for 72 frames.
L917C:  .byte $0E, $48                   ;Play note D2  for 72 frames.
L917E:  .byte CHN_ASR, $0A               ;Set ASR data index to 10.
L9180:  .byte $02, $24                   ;Play note D1  for 36 frames.
L9182:  .byte $02, $24                   ;Play note D1  for 36 frames.
L9184:  .byte $0E, $24                   ;Play note D2  for 36 frames.
L9186:  .byte $09, $09                   ;Play note A1  for 9 frames.
L9188:  .byte $0B, $09                   ;Play note B1  for 9 frames.
L918A:  .byte $0E, $09                   ;Play note D2  for 9 frames.
L918C:  .byte $0B, $09                   ;Play note B1  for 9 frames.
L918E:  .byte $10, $24                   ;Play note E2  for 36 frames.
L9190:  .byte $13, $24                   ;Play note G2  for 36 frames.
L9192:  .byte $0D, $24                   ;Play note C#2 for 36 frames.
L9194:  .byte $15, $24                   ;Play note A2  for 36 frames.
L9196:  .byte $15, $24                   ;Play note A2  for 36 frames.
L9198:  .byte $0E, $24                   ;Play note D2  for 36 frames.
L919A:  .byte $12, $24                   ;Play note F#2 for 36 frames.
L919C:  .byte $0B, $24                   ;Play note B1  for 36 frames.
L919E:  .byte $10, $48                   ;Play note E2  for 72 frames.
L91A0:  .byte $04, $24                   ;Play note E1  for 36 frames.
L91A2:  .byte $10, $24                   ;Play note E2  for 36 frames.
L91A4:  .byte $10, $48                   ;Play note E2  for 72 frames.
L91A6:  .byte $04, $24                   ;Play note E1  for 36 frames.
L91A8:  .byte $10, $24                   ;Play note E2  for 36 frames.
L91AA:  .byte $15, $24                   ;Play note A2  for 36 frames.
L91AC:  .byte $15, $24                   ;Play note A2  for 36 frames.
L91AE:  .byte $13, $24                   ;Play note G2  for 36 frames.
L91B0:  .byte $13, $24                   ;Play note G2  for 36 frames.
L91B2:  .byte $12, $24                   ;Play note F#2 for 36 frames.
L91B4:  .byte $12, $24                   ;Play note F#2 for 36 frames.
L91B6:  .byte $10, $24                   ;Play note E2  for 36 frames.
L91B8:  .byte $10, $24                   ;Play note E2  for 36 frames.
L91BA:  .byte CHN_ASR, $09               ;Set ASR data index to 9.
L91BC:  .byte $15, $12                   ;Play note A2  for 18 frames.
L91BE:  .byte $15, $24                   ;Play note A2  for 36 frames.
L91C0:  .byte $15, $12                   ;Play note A2  for 18 frames.
L91C2:  .byte $13, $12                   ;Play note G2  for 18 frames.
L91C4:  .byte $13, $24                   ;Play note G2  for 36 frames.
L91C6:  .byte $13, $12                   ;Play note G2  for 18 frames.
L91C8:  .byte $12, $12                   ;Play note F#2 for 18 frames.
L91CA:  .byte $12, $24                   ;Play note F#2 for 36 frames.
L91CC:  .byte $12, $12                   ;Play note F#2 for 18 frames.
L91CE:  .byte $10, $12                   ;Play note E2  for 18 frames.
L91D0:  .byte $10, $24                   ;Play note E2  for 36 frames.
L91D2:  .byte $10, $12                   ;Play note E2  for 18 frames.
L91D4:  .byte $0E, $12                   ;Play note D2  for 18 frames.
L91D6:  .byte $0E, $12                   ;Play note D2  for 18 frames.
L91D8:  .byte $0E, $09                   ;Play note D2  for 9 frames.
L91DA:  .byte $0E, $09                   ;Play note D2  for 9 frames.
L91DC:  .byte $0E, $09                   ;Play note D2  for 9 frames.
L91DE:  .byte $0E, $09                   ;Play note D2  for 9 frames.
L91E0:  .byte $0E, $12                   ;Play note D2  for 18 frames.
L91E2:  .byte $0E, $12                   ;Play note D2  for 18 frames.
L91E4:  .byte $0E, $09                   ;Play note D2  for 9 frames.
L91E6:  .byte $0E, $09                   ;Play note D2  for 9 frames.
L91E8:  .byte $0E, $09                   ;Play note D2  for 9 frames.
L91EA:  .byte $0E, $09                   ;Play note D2  for 9 frames.
L91EC:  .byte $0D, $12                   ;Play note C#2 for 18 frames.
L91EE:  .byte $0D, $12                   ;Play note C#2 for 18 frames.
L91F0:  .byte $0D, $09                   ;Play note C#2 for 9 frames.
L91F2:  .byte $0D, $09                   ;Play note C#2 for 9 frames.
L91F4:  .byte $0D, $09                   ;Play note C#2 for 9 frames.
L91F6:  .byte $0D, $09                   ;Play note C#2 for 9 frames.
L91F8:  .byte $0D, $12                   ;Play note C#2 for 18 frames.
L91FA:  .byte $0D, $12                   ;Play note C#2 for 18 frames.
L91FC:  .byte $0D, $09                   ;Play note C#2 for 9 frames.
L91FE:  .byte $0D, $09                   ;Play note C#2 for 9 frames.
L9200:  .byte $0D, $09                   ;Play note C#2 for 9 frames.
L9202:  .byte $0D, $09                   ;Play note C#2 for 9 frames.
L9204:  .byte $0B, $12                   ;Play note B1  for 18 frames.
L9206:  .byte $0B, $12                   ;Play note B1  for 18 frames.
L9208:  .byte $0B, $09                   ;Play note B1  for 9 frames.
L920A:  .byte $0B, $09                   ;Play note B1  for 9 frames.
L920C:  .byte $0B, $09                   ;Play note B1  for 9 frames.
L920E:  .byte $0B, $09                   ;Play note B1  for 9 frames.
L9210:  .byte $0A, $12                   ;Play note A#1 for 18 frames.
L9212:  .byte $0A, $12                   ;Play note A#1 for 18 frames.
L9214:  .byte $0A, $09                   ;Play note A#1 for 9 frames.
L9216:  .byte $0A, $09                   ;Play note A#1 for 9 frames.
L9218:  .byte $0A, $09                   ;Play note A#1 for 9 frames.
L921A:  .byte $0A, $09                   ;Play note A#1 for 9 frames.
L921C:  .byte $09, $12                   ;Play note A1  for 18 frames.
L921E:  .byte $09, $12                   ;Play note A1  for 18 frames.
L9220:  .byte $09, $09                   ;Play note A1  for 9 frames.
L9222:  .byte $09, $09                   ;Play note A1  for 9 frames.
L9224:  .byte $09, $09                   ;Play note A1  for 9 frames.
L9226:  .byte $09, $09                   ;Play note A1  for 9 frames.
L9228:  .byte $08, $12                   ;Play note G#1 for 18 frames.
L922A:  .byte $08, $12                   ;Play note G#1 for 18 frames.
L922C:  .byte $08, $09                   ;Play note G#1 for 9 frames.
L922E:  .byte $08, $09                   ;Play note G#1 for 9 frames.
L9230:  .byte $08, $09                   ;Play note G#1 for 9 frames.
L9232:  .byte $08, $09                   ;Play note G#1 for 9 frames.
L9234:  .byte $07, $12                   ;Play note G1  for 18 frames.
L9236:  .byte $07, $12                   ;Play note G1  for 18 frames.
L9238:  .byte $07, $12                   ;Play note G1  for 18 frames.
L923A:  .byte $07, $12                   ;Play note G1  for 18 frames.
L923C:  .byte $07, $12                   ;Play note G1  for 18 frames.
L923E:  .byte $07, $12                   ;Play note G1  for 18 frames.
L9240:  .byte $07, $12                   ;Play note G1  for 18 frames.
L9242:  .byte $07, $12                   ;Play note G1  for 18 frames.
L9244:  .byte $06, $12                   ;Play note F#1 for 18 frames.
L9246:  .byte $06, $12                   ;Play note F#1 for 18 frames.
L9248:  .byte $06, $12                   ;Play note F#1 for 18 frames.
L924A:  .byte $06, $12                   ;Play note F#1 for 18 frames.
L924C:  .byte $06, $12                   ;Play note F#1 for 18 frames.
L924E:  .byte $06, $12                   ;Play note F#1 for 18 frames.
L9250:  .byte $06, $12                   ;Play note F#1 for 18 frames.
L9252:  .byte $06, $12                   ;Play note F#1 for 18 frames.
L9254:  .byte $05, $12                   ;Play note F1  for 18 frames.
L9256:  .byte $05, $12                   ;Play note F1  for 18 frames.
L9258:  .byte $05, $12                   ;Play note F1  for 18 frames.
L925A:  .byte $05, $12                   ;Play note F1  for 18 frames.
L925C:  .byte $05, $12                   ;Play note F1  for 18 frames.
L925E:  .byte $05, $12                   ;Play note F1  for 18 frames.
L9260:  .byte $05, $12                   ;Play note F1  for 18 frames.
L9262:  .byte $05, $12                   ;Play note F1  for 18 frames.
L9264:  .byte $04, $06                   ;Play note E1  for 6 frames.
L9266:  .byte $04, $06                   ;Play note E1  for 6 frames.
L9268:  .byte $04, $06                   ;Play note E1  for 6 frames.
L926A:  .byte $04, $06                   ;Play note E1  for 6 frames.
L926C:  .byte $04, $06                   ;Play note E1  for 6 frames.
L926E:  .byte $04, $06                   ;Play note E1  for 6 frames.
L9270:  .byte $05, $06                   ;Play note F1  for 6 frames.
L9272:  .byte $05, $06                   ;Play note F1  for 6 frames.
L9274:  .byte $05, $06                   ;Play note F1  for 6 frames.
L9276:  .byte $05, $06                   ;Play note F1  for 6 frames.
L9278:  .byte $05, $06                   ;Play note F1  for 6 frames.
L927A:  .byte $05, $06                   ;Play note F1  for 6 frames.
L927C:  .byte $07, $06                   ;Play note G1  for 6 frames.
L927E:  .byte $07, $06                   ;Play note G1  for 6 frames.
L9280:  .byte $07, $06                   ;Play note G1  for 6 frames.
L9282:  .byte $07, $06                   ;Play note G1  for 6 frames.
L9284:  .byte $07, $06                   ;Play note G1  for 6 frames.
L9286:  .byte $07, $06                   ;Play note G1  for 6 frames.
L9288:  .byte $09, $06                   ;Play note A1  for 6 frames.
L928A:  .byte $09, $06                   ;Play note A1  for 6 frames.
L928C:  .byte $09, $06                   ;Play note A1  for 6 frames.
L928E:  .byte $09, $06                   ;Play note A1  for 6 frames.
L9290:  .byte $09, $06                   ;Play note A1  for 6 frames.
L9292:  .byte $09, $06                   ;Play note A1  for 6 frames.
L9294:  .byte $04, $06                   ;Play note E1  for 6 frames.
L9296:  .byte $04, $06                   ;Play note E1  for 6 frames.
L9298:  .byte $04, $06                   ;Play note E1  for 6 frames.
L929A:  .byte $04, $06                   ;Play note E1  for 6 frames.
L929C:  .byte $04, $06                   ;Play note E1  for 6 frames.
L929E:  .byte $04, $06                   ;Play note E1  for 6 frames.
L92A0:  .byte $05, $06                   ;Play note F1  for 6 frames.
L92A2:  .byte $05, $06                   ;Play note F1  for 6 frames.
L92A4:  .byte $05, $06                   ;Play note F1  for 6 frames.
L92A6:  .byte $05, $06                   ;Play note F1  for 6 frames.
L92A8:  .byte $05, $06                   ;Play note F1  for 6 frames.
L92AA:  .byte $05, $06                   ;Play note F1  for 6 frames.
L92AC:  .byte $07, $06                   ;Play note G1  for 6 frames.
L92AE:  .byte $07, $06                   ;Play note G1  for 6 frames.
L92B0:  .byte $07, $06                   ;Play note G1  for 6 frames.
L92B2:  .byte $07, $06                   ;Play note G1  for 6 frames.
L92B4:  .byte $07, $06                   ;Play note G1  for 6 frames.
L92B6:  .byte $07, $06                   ;Play note G1  for 6 frames.
L92B8:  .byte $09, $06                   ;Play note A1  for 6 frames.
L92BA:  .byte $09, $06                   ;Play note A1  for 6 frames.
L92BC:  .byte $09, $06                   ;Play note A1  for 6 frames.
L92BE:  .byte $09, $06                   ;Play note A1  for 6 frames.
L92C0:  .byte $09, $06                   ;Play note A1  for 6 frames.
L92C2:  .byte $09, $06                   ;Play note A1  for 6 frames.
L92C4:  .byte CHN_JUMP, $00, $A4, $FE    ;Jump back 348 bytes to $9168.

;----------------------------------------------------------------------------------------------------

;Used by Boat music SQ1.

SQ1Attack0B:
L92C8:  .byte $04, $84, $87, $8C, $90

SQ1Sustain0B:
L92CD:  .byte $13, $90, $8F, $8D, $8B, $8A, $89, $88, $87, $86, $85, $84, $84, $85, $86, $87
L92DD:  .byte $88, $89, $8A, $8A

SQ1Release0B:
L92E1:  .byte $14, $89, $89, $88, $88, $87, $87, $86, $86, $86, $85, $85, $85, $85, $84, $84
L92F1:  .byte $84, $84, $84, $84, $83

;----------------------------------------------------------------------------------------------------

;Used by Boat music SQ2.

SQ2Attack0C:
L92F6:  .byte $06, $86, $8D, $90, $8D, $8A, $86

SQ2Sustain0C:
L92FD:  .byte $04, $87, $87, $87, $87

SQ2Release0C:
L9302:  .byte $18, $86, $86, $86, $86, $85, $85, $85, $85, $84, $84, $84, $84, $83, $83, $83
L9312:  .byte $83, $82, $82, $82, $82, $81, $81, $81, $80

;----------------------------------------------------------------------------------------------------

;Used by Boat music Triangle.

TriAttack0D:
L931B:  .byte $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

TriSustain0D:
L9324:  .byte $04, $0F, $0F, $0F, $0F

TriRelease0D:
L9329:  .byte $18, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9339:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00

;----------------------------------------------------------------------------------------------------

;Boat music SQ1 data.

BoatSQ1:
L9342:  .byte CHN_VOLUME, $0F            ;Set channel volume to 15.
L9344:  .byte CHN_VIBRATO, $00, $07, $0D ;Set vibrato speed=7, intensity=13.
L9348:  .byte CHN_ASR, $0B               ;Set ASR data index to 11.
L934A:  .byte $2F, $15                   ;Play note B5  for 21 frames.
L934C:  .byte $2F, $15                   ;Play note B5  for 21 frames.
L934E:  .byte $2F, $0E                   ;Play note B5  for 14 frames.
L9350:  .byte $32, $15                   ;Play note D6  for 21 frames.
L9352:  .byte $32, $31                   ;Play note D6  for 49 frames.
L9354:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L9356:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L9358:  .byte $2F, $0E                   ;Play note B5  for 14 frames.
L935A:  .byte $32, $0E                   ;Play note D6  for 14 frames.
L935C:  .byte $37, $0E                   ;Play note G6  for 14 frames.
L935E:  .byte $36, $0E                   ;Play note F#6 for 14 frames.
L9360:  .byte $34, $0E                   ;Play note E6  for 14 frames.
L9362:  .byte $32, $0E                   ;Play note D6  for 14 frames.
L9364:  .byte $34, $15                   ;Play note E6  for 21 frames.
L9366:  .byte $34, $15                   ;Play note E6  for 21 frames.
L9368:  .byte $30, $0E                   ;Play note C6  for 14 frames.
L936A:  .byte $30, $15                   ;Play note C6  for 21 frames.
L936C:  .byte $30, $85                   ;Play note C6  for 133 frames.
L936E:  .byte $36, $0E                   ;Play note F#6 for 14 frames.
L9370:  .byte $36, $0E                   ;Play note F#6 for 14 frames.
L9372:  .byte $34, $0E                   ;Play note E6  for 14 frames.
L9374:  .byte $34, $0E                   ;Play note E6  for 14 frames.
L9376:  .byte $32, $0E                   ;Play note D6  for 14 frames.
L9378:  .byte $32, $15                   ;Play note D6  for 21 frames.
L937A:  .byte $30, $15                   ;Play note C6  for 21 frames.
L937C:  .byte $36, $0E                   ;Play note F#6 for 14 frames.
L937E:  .byte $36, $0E                   ;Play note F#6 for 14 frames.
L9380:  .byte $34, $0E                   ;Play note E6  for 14 frames.
L9382:  .byte $34, $0E                   ;Play note E6  for 14 frames.
L9384:  .byte $32, $0E                   ;Play note D6  for 14 frames.
L9386:  .byte $32, $15                   ;Play note D6  for 21 frames.
L9388:  .byte $30, $15                   ;Play note C6  for 21 frames.
L938A:  .byte $2F, $07                   ;Play note B5  for 7 frames.
L938C:  .byte $30, $07                   ;Play note C6  for 7 frames.
L938E:  .byte $32, $0E                   ;Play note D6  for 14 frames.
L9390:  .byte $32, $1C                   ;Play note D6  for 28 frames.
L9392:  .byte $2F, $07                   ;Play note B5  for 7 frames.
L9394:  .byte $30, $07                   ;Play note C6  for 7 frames.
L9396:  .byte $32, $0E                   ;Play note D6  for 14 frames.
L9398:  .byte $32, $1C                   ;Play note D6  for 28 frames.
L939A:  .byte $2F, $07                   ;Play note B5  for 7 frames.
L939C:  .byte $30, $07                   ;Play note C6  for 7 frames.
L939E:  .byte $32, $2A                   ;Play note D6  for 42 frames.
L93A0:  .byte $2F, $07                   ;Play note B5  for 7 frames.
L93A2:  .byte $30, $07                   ;Play note C6  for 7 frames.
L93A4:  .byte $36, $0E                   ;Play note F#6 for 14 frames.
L93A6:  .byte $34, $0E                   ;Play note E6  for 14 frames.
L93A8:  .byte $32, $1C                   ;Play note D6  for 28 frames.
L93AA:  .byte $2F, $15                   ;Play note B5  for 21 frames.
L93AC:  .byte $2F, $15                   ;Play note B5  for 21 frames.
L93AE:  .byte $2F, $0E                   ;Play note B5  for 14 frames.
L93B0:  .byte $32, $15                   ;Play note D6  for 21 frames.
L93B2:  .byte $32, $31                   ;Play note D6  for 49 frames.
L93B4:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L93B6:  .byte $2B, $07                   ;Play note G5  for 7 frames.
L93B8:  .byte $2F, $0E                   ;Play note B5  for 14 frames.
L93BA:  .byte $32, $0E                   ;Play note D6  for 14 frames.
L93BC:  .byte $37, $0E                   ;Play note G6  for 14 frames.
L93BE:  .byte $36, $0E                   ;Play note F#6 for 14 frames.
L93C0:  .byte $34, $0E                   ;Play note E6  for 14 frames.
L93C2:  .byte $32, $0E                   ;Play note D6  for 14 frames.
L93C4:  .byte $34, $15                   ;Play note E6  for 21 frames.
L93C6:  .byte $34, $15                   ;Play note E6  for 21 frames.
L93C8:  .byte $30, $0E                   ;Play note C6  for 14 frames.
L93CA:  .byte $30, $15                   ;Play note C6  for 21 frames.
L93CC:  .byte $30, $85                   ;Play note C6  for 133 frames.
L93CE:  .byte $36, $0E                   ;Play note F#6 for 14 frames.
L93D0:  .byte $36, $0E                   ;Play note F#6 for 14 frames.
L93D2:  .byte $34, $0E                   ;Play note E6  for 14 frames.
L93D4:  .byte $34, $0E                   ;Play note E6  for 14 frames.
L93D6:  .byte $32, $0E                   ;Play note D6  for 14 frames.
L93D8:  .byte $32, $15                   ;Play note D6  for 21 frames.
L93DA:  .byte $30, $15                   ;Play note C6  for 21 frames.
L93DC:  .byte $36, $0E                   ;Play note F#6 for 14 frames.
L93DE:  .byte $36, $0E                   ;Play note F#6 for 14 frames.
L93E0:  .byte $34, $0E                   ;Play note E6  for 14 frames.
L93E2:  .byte $34, $0E                   ;Play note E6  for 14 frames.
L93E4:  .byte $32, $0E                   ;Play note D6  for 14 frames.
L93E6:  .byte $32, $15                   ;Play note D6  for 21 frames.
L93E8:  .byte $30, $15                   ;Play note C6  for 21 frames.
L93EA:  .byte $2F, $07                   ;Play note B5  for 7 frames.
L93EC:  .byte $30, $07                   ;Play note C6  for 7 frames.
L93EE:  .byte $32, $0E                   ;Play note D6  for 14 frames.
L93F0:  .byte $32, $1C                   ;Play note D6  for 28 frames.
L93F2:  .byte $2F, $07                   ;Play note B5  for 7 frames.
L93F4:  .byte $30, $07                   ;Play note C6  for 7 frames.
L93F6:  .byte $32, $0E                   ;Play note D6  for 14 frames.
L93F8:  .byte $32, $1C                   ;Play note D6  for 28 frames.
L93FA:  .byte $2F, $07                   ;Play note B5  for 7 frames.
L93FC:  .byte $30, $07                   ;Play note C6  for 7 frames.
L93FE:  .byte $32, $46                   ;Play note D6  for 70 frames.
L9400:  .byte $35, $07                   ;Play note F6  for 7 frames.
L9402:  .byte $32, $07                   ;Play note D6  for 7 frames.
L9404:  .byte $34, $0E                   ;Play note E6  for 14 frames.
L9406:  .byte $35, $0E                   ;Play note F6  for 14 frames.
L9408:  .byte $34, $15                   ;Play note E6  for 21 frames.
L940A:  .byte $34, $15                   ;Play note E6  for 21 frames.
L940C:  .byte $34, $1C                   ;Play note E6  for 28 frames.
L940E:  .byte $34, $0E                   ;Play note E6  for 14 frames.
L9410:  .byte $37, $0E                   ;Play note G6  for 14 frames.
L9412:  .byte $34, $0E                   ;Play note E6  for 14 frames.
L9414:  .byte $39, $15                   ;Play note A6  for 21 frames.
L9416:  .byte $39, $15                   ;Play note A6  for 21 frames.
L9418:  .byte $37, $46                   ;Play note G6  for 70 frames.
L941A:  .byte $32, $15                   ;Play note D6  for 21 frames.
L941C:  .byte $32, $15                   ;Play note D6  for 21 frames.
L941E:  .byte $32, $1C                   ;Play note D6  for 28 frames.
L9420:  .byte $32, $0E                   ;Play note D6  for 14 frames.
L9422:  .byte $34, $0E                   ;Play note E6  for 14 frames.
L9424:  .byte $32, $0E                   ;Play note D6  for 14 frames.
L9426:  .byte $36, $15                   ;Play note F#6 for 21 frames.
L9428:  .byte $36, $15                   ;Play note F#6 for 21 frames.
L942A:  .byte $34, $46                   ;Play note E6  for 70 frames.
L942C:  .byte $30, $0E                   ;Play note C6  for 14 frames.
L942E:  .byte $32, $0E                   ;Play note D6  for 14 frames.
L9430:  .byte $34, $0E                   ;Play note E6  for 14 frames.
L9432:  .byte $30, $07                   ;Play note C6  for 7 frames.
L9434:  .byte $32, $0E                   ;Play note D6  for 14 frames.
L9436:  .byte $34, $0E                   ;Play note E6  for 14 frames.
L9438:  .byte $30, $07                   ;Play note C6  for 7 frames.
L943A:  .byte $32, $0E                   ;Play note D6  for 14 frames.
L943C:  .byte $34, $0E                   ;Play note E6  for 14 frames.
L943E:  .byte $30, $0E                   ;Play note C6  for 14 frames.
L9440:  .byte $32, $0E                   ;Play note D6  for 14 frames.
L9442:  .byte $34, $0E                   ;Play note E6  for 14 frames.
L9444:  .byte $30, $07                   ;Play note C6  for 7 frames.
L9446:  .byte $32, $0E                   ;Play note D6  for 14 frames.
L9448:  .byte $34, $0E                   ;Play note E6  for 14 frames.
L944A:  .byte $30, $07                   ;Play note C6  for 7 frames.
L944C:  .byte $32, $0E                   ;Play note D6  for 14 frames.
L944E:  .byte $34, $1C                   ;Play note E6  for 28 frames.
L9450:  .byte $33, $1C                   ;Play note D#6 for 28 frames.
L9452:  .byte $33, $0E                   ;Play note D#6 for 14 frames.
L9454:  .byte $33, $15                   ;Play note D#6 for 21 frames.
L9456:  .byte $33, $31                   ;Play note D#6 for 49 frames.
L9458:  .byte $33, $1C                   ;Play note D#6 for 28 frames.
L945A:  .byte $33, $0E                   ;Play note D#6 for 14 frames.
L945C:  .byte $33, $15                   ;Play note D#6 for 21 frames.
L945E:  .byte $33, $07                   ;Play note D#6 for 7 frames.
L9460:  .byte $32, $07                   ;Play note D6  for 7 frames.
L9462:  .byte $33, $07                   ;Play note D#6 for 7 frames.
L9464:  .byte $35, $07                   ;Play note F6  for 7 frames.
L9466:  .byte $37, $07                   ;Play note G6  for 7 frames.
L9468:  .byte CHN_JUMP, $00, $DA, $FE    ;Jump back 294 bytes to $9342.

;----------------------------------------------------------------------------------------------------

;Boat music SQ2 data.

BoatSQ2:
L946C:  .byte CHN_VOLUME, $08            ;Set channel volume to 8.
L946E:  .byte CHN_VIBRATO, $00, $03, $80 ;Set vibrato speed=3, intensity=128.
L9472:  .byte CHN_ASR, $0C               ;Set ASR data index to 12.
L9474:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L9476:  .byte $23, $0E                   ;Play note B4  for 14 frames.
L9478:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L947A:  .byte $23, $07                   ;Play note B4  for 7 frames.
L947C:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L947E:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L9480:  .byte $23, $07                   ;Play note B4  for 7 frames.
L9482:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L9484:  .byte $23, $0E                   ;Play note B4  for 14 frames.
L9486:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L9488:  .byte $23, $0E                   ;Play note B4  for 14 frames.
L948A:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L948C:  .byte $23, $07                   ;Play note B4  for 7 frames.
L948E:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L9490:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L9492:  .byte $23, $07                   ;Play note B4  for 7 frames.
L9494:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L9496:  .byte $23, $0E                   ;Play note B4  for 14 frames.
L9498:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L949A:  .byte $24, $0E                   ;Play note C5  for 14 frames.
L949C:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L949E:  .byte $24, $07                   ;Play note C5  for 7 frames.
L94A0:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L94A2:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L94A4:  .byte $24, $07                   ;Play note C5  for 7 frames.
L94A6:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L94A8:  .byte $24, $0E                   ;Play note C5  for 14 frames.
L94AA:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L94AC:  .byte $24, $0E                   ;Play note C5  for 14 frames.
L94AE:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L94B0:  .byte $24, $07                   ;Play note C5  for 7 frames.
L94B2:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L94B4:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L94B6:  .byte $24, $07                   ;Play note C5  for 7 frames.
L94B8:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L94BA:  .byte $24, $0E                   ;Play note C5  for 14 frames.
L94BC:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L94BE:  .byte $24, $0E                   ;Play note C5  for 14 frames.
L94C0:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L94C2:  .byte $24, $07                   ;Play note C5  for 7 frames.
L94C4:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L94C6:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L94C8:  .byte $24, $07                   ;Play note C5  for 7 frames.
L94CA:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L94CC:  .byte $24, $0E                   ;Play note C5  for 14 frames.
L94CE:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L94D0:  .byte $24, $0E                   ;Play note C5  for 14 frames.
L94D2:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L94D4:  .byte $24, $07                   ;Play note C5  for 7 frames.
L94D6:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L94D8:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L94DA:  .byte $24, $07                   ;Play note C5  for 7 frames.
L94DC:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L94DE:  .byte $24, $0E                   ;Play note C5  for 14 frames.
L94E0:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L94E2:  .byte $23, $0E                   ;Play note B4  for 14 frames.
L94E4:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L94E6:  .byte $23, $07                   ;Play note B4  for 7 frames.
L94E8:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L94EA:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L94EC:  .byte $26, $07                   ;Play note D5  for 7 frames.
L94EE:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L94F0:  .byte $23, $0E                   ;Play note B4  for 14 frames.
L94F2:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L94F4:  .byte $23, $0E                   ;Play note B4  for 14 frames.
L94F6:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L94F8:  .byte $23, $07                   ;Play note B4  for 7 frames.
L94FA:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L94FC:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L94FE:  .byte $26, $07                   ;Play note D5  for 7 frames.
L9500:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L9502:  .byte $23, $0E                   ;Play note B4  for 14 frames.
L9504:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L9506:  .byte $23, $0E                   ;Play note B4  for 14 frames.
L9508:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L950A:  .byte $23, $07                   ;Play note B4  for 7 frames.
L950C:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L950E:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L9510:  .byte $23, $07                   ;Play note B4  for 7 frames.
L9512:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L9514:  .byte $23, $0E                   ;Play note B4  for 14 frames.
L9516:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L9518:  .byte $23, $0E                   ;Play note B4  for 14 frames.
L951A:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L951C:  .byte $23, $07                   ;Play note B4  for 7 frames.
L951E:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L9520:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L9522:  .byte $23, $07                   ;Play note B4  for 7 frames.
L9524:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L9526:  .byte $23, $0E                   ;Play note B4  for 14 frames.
L9528:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L952A:  .byte $24, $0E                   ;Play note C5  for 14 frames.
L952C:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L952E:  .byte $24, $07                   ;Play note C5  for 7 frames.
L9530:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L9532:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L9534:  .byte $24, $07                   ;Play note C5  for 7 frames.
L9536:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L9538:  .byte $24, $0E                   ;Play note C5  for 14 frames.
L953A:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L953C:  .byte $24, $0E                   ;Play note C5  for 14 frames.
L953E:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L9540:  .byte $24, $07                   ;Play note C5  for 7 frames.
L9542:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L9544:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L9546:  .byte $24, $07                   ;Play note C5  for 7 frames.
L9548:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L954A:  .byte $24, $0E                   ;Play note C5  for 14 frames.
L954C:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L954E:  .byte $24, $0E                   ;Play note C5  for 14 frames.
L9550:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L9552:  .byte $24, $07                   ;Play note C5  for 7 frames.
L9554:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L9556:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L9558:  .byte $24, $07                   ;Play note C5  for 7 frames.
L955A:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L955C:  .byte $24, $0E                   ;Play note C5  for 14 frames.
L955E:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L9560:  .byte $24, $0E                   ;Play note C5  for 14 frames.
L9562:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L9564:  .byte $24, $07                   ;Play note C5  for 7 frames.
L9566:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L9568:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L956A:  .byte $24, $07                   ;Play note C5  for 7 frames.
L956C:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L956E:  .byte $24, $0E                   ;Play note C5  for 14 frames.
L9570:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L9572:  .byte $23, $0E                   ;Play note B4  for 14 frames.
L9574:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L9576:  .byte $23, $07                   ;Play note B4  for 7 frames.
L9578:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L957A:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L957C:  .byte $26, $07                   ;Play note D5  for 7 frames.
L957E:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L9580:  .byte $23, $0E                   ;Play note B4  for 14 frames.
L9582:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L9584:  .byte $23, $0E                   ;Play note B4  for 14 frames.
L9586:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L9588:  .byte $23, $07                   ;Play note B4  for 7 frames.
L958A:  .byte $26, $07                   ;Play note D5  for 7 frames.
L958C:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L958E:  .byte $26, $07                   ;Play note D5  for 7 frames.
L9590:  .byte $23, $07                   ;Play note B4  for 7 frames.
L9592:  .byte $24, $0E                   ;Play note C5  for 14 frames.
L9594:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L9596:  .byte $1F, $15                   ;Play note G4  for 21 frames.
L9598:  .byte $1F, $15                   ;Play note G4  for 21 frames.
L959A:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
L959C:  .byte CHN_SILENCE, $38           ;Silence channel for 56 frames.
L959E:  .byte $2A, $15                   ;Play note F#5 for 21 frames.
L95A0:  .byte $2A, $15                   ;Play note F#5 for 21 frames.
L95A2:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L95A4:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L95A6:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L95A8:  .byte $28, $07                   ;Play note E5  for 7 frames.
L95AA:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L95AC:  .byte $28, $07                   ;Play note E5  for 7 frames.
L95AE:  .byte $26, $07                   ;Play note D5  for 7 frames.
L95B0:  .byte $24, $07                   ;Play note C5  for 7 frames.
L95B2:  .byte $1E, $15                   ;Play note F#4 for 21 frames.
L95B4:  .byte $1E, $15                   ;Play note F#4 for 21 frames.
L95B6:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
L95B8:  .byte CHN_SILENCE, $38           ;Silence channel for 56 frames.
L95BA:  .byte $26, $15                   ;Play note D5  for 21 frames.
L95BC:  .byte $26, $15                   ;Play note D5  for 21 frames.
L95BE:  .byte $23, $0E                   ;Play note B4  for 14 frames.
L95C0:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L95C2:  .byte $28, $07                   ;Play note E5  for 7 frames.
L95C4:  .byte $26, $07                   ;Play note D5  for 7 frames.
L95C6:  .byte $28, $07                   ;Play note E5  for 7 frames.
L95C8:  .byte $26, $07                   ;Play note D5  for 7 frames.
L95CA:  .byte $23, $07                   ;Play note B4  for 7 frames.
L95CC:  .byte $26, $07                   ;Play note D5  for 7 frames.
L95CE:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L95D0:  .byte $24, $0E                   ;Play note C5  for 14 frames.
L95D2:  .byte $21, $0E                   ;Play note A4  for 14 frames.
L95D4:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L95D6:  .byte $24, $0E                   ;Play note C5  for 14 frames.
L95D8:  .byte $21, $0E                   ;Play note A4  for 14 frames.
L95DA:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L95DC:  .byte $24, $0E                   ;Play note C5  for 14 frames.
L95DE:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L95E0:  .byte $24, $0E                   ;Play note C5  for 14 frames.
L95E2:  .byte $21, $0E                   ;Play note A4  for 14 frames.
L95E4:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L95E6:  .byte $24, $0E                   ;Play note C5  for 14 frames.
L95E8:  .byte $21, $0E                   ;Play note A4  for 14 frames.
L95EA:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L95EC:  .byte $24, $0E                   ;Play note C5  for 14 frames.
L95EE:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L95F0:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
L95F2:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L95F4:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
L95F6:  .byte $22, $15                   ;Play note A#4 for 21 frames.
L95F8:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L95FA:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L95FC:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L95FE:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
L9600:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L9602:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
L9604:  .byte $22, $15                   ;Play note A#4 for 21 frames.
L9606:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L9608:  .byte $22, $07                   ;Play note A#4 for 7 frames.
L960A:  .byte $24, $07                   ;Play note C5  for 7 frames.
L960C:  .byte $26, $07                   ;Play note D5  for 7 frames.
L960E:  .byte $27, $07                   ;Play note D#5 for 7 frames.
L9610:  .byte CHN_JUMP, $00, $5C, $FE    ;Jump back 420 bytes to $946C.

;----------------------------------------------------------------------------------------------------

;Boat music Triangle data.

BoatTri:
L9614:  .byte CHN_VOLUME, $0F            ;Set channel volume to 15.
L9616:  .byte CHN_VIBRATO, $00, $03, $30 ;Set vibrato speed=3, intensity=48.
L961A:  .byte CHN_ASR, $0D               ;Set ASR data index to 13.
L961C:  .byte $07, $15                   ;Play note G1  for 21 frames.
L961E:  .byte $0E, $15                   ;Play note D2  for 21 frames.
L9620:  .byte $07, $0E                   ;Play note G1  for 14 frames.
L9622:  .byte $07, $15                   ;Play note G1  for 21 frames.
L9624:  .byte $0B, $15                   ;Play note B1  for 21 frames.
L9626:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9628:  .byte $07, $15                   ;Play note G1  for 21 frames.
L962A:  .byte $0E, $15                   ;Play note D2  for 21 frames.
L962C:  .byte $07, $0E                   ;Play note G1  for 14 frames.
L962E:  .byte $07, $15                   ;Play note G1  for 21 frames.
L9630:  .byte $0B, $15                   ;Play note B1  for 21 frames.
L9632:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9634:  .byte $09, $15                   ;Play note A1  for 21 frames.
L9636:  .byte $10, $15                   ;Play note E2  for 21 frames.
L9638:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L963A:  .byte $09, $15                   ;Play note A1  for 21 frames.
L963C:  .byte $0C, $15                   ;Play note C2  for 21 frames.
L963E:  .byte $10, $0E                   ;Play note E2  for 14 frames.
L9640:  .byte $09, $15                   ;Play note A1  for 21 frames.
L9642:  .byte $10, $15                   ;Play note E2  for 21 frames.
L9644:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L9646:  .byte $09, $15                   ;Play note A1  for 21 frames.
L9648:  .byte $0C, $15                   ;Play note C2  for 21 frames.
L964A:  .byte $10, $0E                   ;Play note E2  for 14 frames.
L964C:  .byte $0E, $15                   ;Play note D2  for 21 frames.
L964E:  .byte $15, $15                   ;Play note A2  for 21 frames.
L9650:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9652:  .byte $0E, $15                   ;Play note D2  for 21 frames.
L9654:  .byte $12, $15                   ;Play note F#2 for 21 frames.
L9656:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L9658:  .byte $0E, $15                   ;Play note D2  for 21 frames.
L965A:  .byte $15, $15                   ;Play note A2  for 21 frames.
L965C:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L965E:  .byte $0E, $15                   ;Play note D2  for 21 frames.
L9660:  .byte $12, $15                   ;Play note F#2 for 21 frames.
L9662:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L9664:  .byte $07, $15                   ;Play note G1  for 21 frames.
L9666:  .byte $0E, $15                   ;Play note D2  for 21 frames.
L9668:  .byte $07, $0E                   ;Play note G1  for 14 frames.
L966A:  .byte $07, $15                   ;Play note G1  for 21 frames.
L966C:  .byte $0B, $15                   ;Play note B1  for 21 frames.
L966E:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9670:  .byte $07, $15                   ;Play note G1  for 21 frames.
L9672:  .byte $0E, $15                   ;Play note D2  for 21 frames.
L9674:  .byte $07, $0E                   ;Play note G1  for 14 frames.
L9676:  .byte $07, $15                   ;Play note G1  for 21 frames.
L9678:  .byte $0B, $15                   ;Play note B1  for 21 frames.
L967A:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L967C:  .byte $07, $15                   ;Play note G1  for 21 frames.
L967E:  .byte $0E, $15                   ;Play note D2  for 21 frames.
L9680:  .byte $07, $0E                   ;Play note G1  for 14 frames.
L9682:  .byte $07, $15                   ;Play note G1  for 21 frames.
L9684:  .byte $0B, $15                   ;Play note B1  for 21 frames.
L9686:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9688:  .byte $07, $15                   ;Play note G1  for 21 frames.
L968A:  .byte $0E, $15                   ;Play note D2  for 21 frames.
L968C:  .byte $07, $0E                   ;Play note G1  for 14 frames.
L968E:  .byte $07, $15                   ;Play note G1  for 21 frames.
L9690:  .byte $0B, $15                   ;Play note B1  for 21 frames.
L9692:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9694:  .byte $09, $15                   ;Play note A1  for 21 frames.
L9696:  .byte $10, $15                   ;Play note E2  for 21 frames.
L9698:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L969A:  .byte $09, $15                   ;Play note A1  for 21 frames.
L969C:  .byte $0C, $15                   ;Play note C2  for 21 frames.
L969E:  .byte $10, $0E                   ;Play note E2  for 14 frames.
L96A0:  .byte $09, $15                   ;Play note A1  for 21 frames.
L96A2:  .byte $10, $15                   ;Play note E2  for 21 frames.
L96A4:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L96A6:  .byte $09, $15                   ;Play note A1  for 21 frames.
L96A8:  .byte $0C, $15                   ;Play note C2  for 21 frames.
L96AA:  .byte $10, $0E                   ;Play note E2  for 14 frames.
L96AC:  .byte $0E, $15                   ;Play note D2  for 21 frames.
L96AE:  .byte $15, $15                   ;Play note A2  for 21 frames.
L96B0:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L96B2:  .byte $0E, $15                   ;Play note D2  for 21 frames.
L96B4:  .byte $12, $15                   ;Play note F#2 for 21 frames.
L96B6:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L96B8:  .byte $0E, $15                   ;Play note D2  for 21 frames.
L96BA:  .byte $15, $15                   ;Play note A2  for 21 frames.
L96BC:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L96BE:  .byte $0E, $15                   ;Play note D2  for 21 frames.
L96C0:  .byte $12, $15                   ;Play note F#2 for 21 frames.
L96C2:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L96C4:  .byte $07, $15                   ;Play note G1  for 21 frames.
L96C6:  .byte $0E, $15                   ;Play note D2  for 21 frames.
L96C8:  .byte $07, $0E                   ;Play note G1  for 14 frames.
L96CA:  .byte $07, $15                   ;Play note G1  for 21 frames.
L96CC:  .byte $0B, $15                   ;Play note B1  for 21 frames.
L96CE:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L96D0:  .byte $07, $15                   ;Play note G1  for 21 frames.
L96D2:  .byte $0E, $15                   ;Play note D2  for 21 frames.
L96D4:  .byte $07, $0E                   ;Play note G1  for 14 frames.
L96D6:  .byte $07, $15                   ;Play note G1  for 21 frames.
L96D8:  .byte $0B, $15                   ;Play note B1  for 21 frames.
L96DA:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L96DC:  .byte $0C, $15                   ;Play note C2  for 21 frames.
L96DE:  .byte $0C, $15                   ;Play note C2  for 21 frames.
L96E0:  .byte $0C, $0E                   ;Play note C2  for 14 frames.
L96E2:  .byte CHN_SILENCE, $38           ;Silence channel for 56 frames.
L96E4:  .byte $0C, $15                   ;Play note C2  for 21 frames.
L96E6:  .byte $0C, $15                   ;Play note C2  for 21 frames.
L96E8:  .byte $0C, $0E                   ;Play note C2  for 14 frames.
L96EA:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L96EC:  .byte $12, $07                   ;Play note F#2 for 7 frames.
L96EE:  .byte $10, $07                   ;Play note E2  for 7 frames.
L96F0:  .byte $12, $07                   ;Play note F#2 for 7 frames.
L96F2:  .byte $10, $07                   ;Play note E2  for 7 frames.
L96F4:  .byte $0E, $07                   ;Play note D2  for 7 frames.
L96F6:  .byte $0C, $07                   ;Play note C2  for 7 frames.
L96F8:  .byte $0B, $15                   ;Play note B1  for 21 frames.
L96FA:  .byte $0B, $15                   ;Play note B1  for 21 frames.
L96FC:  .byte $0B, $0E                   ;Play note B1  for 14 frames.
L96FE:  .byte CHN_SILENCE, $38           ;Silence channel for 56 frames.
L9700:  .byte $10, $15                   ;Play note E2  for 21 frames.
L9702:  .byte $10, $15                   ;Play note E2  for 21 frames.
L9704:  .byte $10, $0E                   ;Play note E2  for 14 frames.
L9706:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L9708:  .byte $10, $07                   ;Play note E2  for 7 frames.
L970A:  .byte $0E, $07                   ;Play note D2  for 7 frames.
L970C:  .byte $10, $07                   ;Play note E2  for 7 frames.
L970E:  .byte $0E, $07                   ;Play note D2  for 7 frames.
L9710:  .byte $0B, $07                   ;Play note B1  for 7 frames.
L9712:  .byte $0E, $07                   ;Play note D2  for 7 frames.
L9714:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L9716:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L9718:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L971A:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L971C:  .byte $09, $15                   ;Play note A1  for 21 frames.
L971E:  .byte $09, $15                   ;Play note A1  for 21 frames.
L9720:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L9722:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L9724:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L9726:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L9728:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L972A:  .byte $06, $15                   ;Play note F#1 for 21 frames.
L972C:  .byte $06, $15                   ;Play note F#1 for 21 frames.
L972E:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L9730:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L9732:  .byte $12, $0E                   ;Play note F#2 for 14 frames.
L9734:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L9736:  .byte $12, $0E                   ;Play note F#2 for 14 frames.
L9738:  .byte $12, $15                   ;Play note F#2 for 21 frames.
L973A:  .byte $12, $07                   ;Play note F#2 for 7 frames.
L973C:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L973E:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L9740:  .byte $12, $0E                   ;Play note F#2 for 14 frames.
L9742:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L9744:  .byte $12, $0E                   ;Play note F#2 for 14 frames.
L9746:  .byte $12, $15                   ;Play note F#2 for 21 frames.
L9748:  .byte $12, $07                   ;Play note F#2 for 7 frames.
L974A:  .byte CHN_SILENCE, $1C           ;Silence channel for 28 frames.
L974C:  .byte CHN_JUMP, $00, $C8, $FE    ;Jump back 312 bytes to $9614.

;----------------------------------------------------------------------------------------------------

;Used by End music SQ1.

SQ1Attack0E:
L9750:  .byte $04, $84, $88, $8C, $90

SQ1Sustain0E:
L9755:  .byte $38, $8F, $8D, $8B, $89, $88, $8A, $8C, $8E, $8F, $8D, $8B, $89, $88, $8A, $8C
L9765:  .byte $8E, $8D, $8B, $89, $87, $86, $87, $89, $8B, $8B, $89, $87, $85, $84, $85, $87
L9775:  .byte $89, $89, $87, $85, $83, $82, $83, $85, $87, $89, $87, $85, $83, $82, $83, $85
L9785:  .byte $87, $89, $87, $85, $83, $82, $83, $85, $87

SQ1Release0E:
L978E:  .byte $10, $87, $87, $86, $86, $86, $85, $85, $85, $85, $84, $84, $84, $84, $84, $84
L979E:  .byte $83

;----------------------------------------------------------------------------------------------------

;Used by End music SQ2.

SQ2Attack0F:
L979F:  .byte $07, $06, $0D, $10, $0D, $0A, $06, $05

SQ2Sustain0F:
L97A7:  .byte $08, $06, $07, $07, $07, $07, $07, $07, $07

SQ2Release0F:
L97B0:  .byte $10, $06, $06, $06, $06, $05, $05, $05, $05, $04, $04, $04, $04, $03, $03, $03
L97C0:  .byte $03

;----------------------------------------------------------------------------------------------------

;Used by End music Triangle.

TriAttack10:
L97C1:  .byte $08, $0F, $0F, $0F, $0F, $0F, $0F, $00, $00

TriSustain10:
L97CA:  .byte $10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L97DA:  .byte $00

TriRelease10:
L97DB:  .byte $08, $00, $00, $00, $00, $00, $00, $00, $00

;----------------------------------------------------------------------------------------------------

;Used by End music SQ1.

SQ1Attack11:
L97E4:  .byte $07, $45, $49, $50, $8D, $88, $86, $85

SQ1Sustain11:
L97EC:  .byte $08, $86, $87, $88, $87, $88, $87, $88, $87

SQ1Release11:
L97F5:  .byte $14, $88, $87, $88, $88, $87, $87, $88, $87, $87, $86, $86, $86, $86, $86, $85
L9805:  .byte $85, $85, $85, $85, $84

;----------------------------------------------------------------------------------------------------

;Used by End music SQ2.

SQ2Attack12:
L980A:  .byte $06, $48, $4C, $50, $4D, $48, $46

SQ2Sustain12:
L9811:  .byte $0C, $48, $48, $48, $48, $48, $48, $48, $48, $48, $48, $48, $48

SQ2Release12:
L981E:  .byte $14, $48, $48, $48, $47, $47, $47, $46, $46, $46, $46, $45, $45, $45, $45, $44
L982E:  .byte $44, $44, $44, $43, $43

;----------------------------------------------------------------------------------------------------

;End music SQ1 data.

EndSQ1:
L9833:  .byte CHN_VOLUME, $0D            ;Set channel volume to 13.
L9835:  .byte CHN_VIBRATO, $00, $06, $0E ;Set vibrato speed=6, intensity=14.
L9839:  .byte CHN_ASR, $0E               ;Set ASR data index to 14.
L983B:  .byte $30, $34                   ;Play note C6  for 52 frames.
L983D:  .byte $30, $0D                   ;Play note C6  for 13 frames.
L983F:  .byte $32, $0D                   ;Play note D6  for 13 frames.
L9841:  .byte $34, $0D                   ;Play note E6  for 13 frames.
L9843:  .byte $30, $0D                   ;Play note C6  for 13 frames.
L9845:  .byte $32, $27                   ;Play note D6  for 39 frames.
L9847:  .byte $37, $41                   ;Play note G6  for 65 frames.
L9849:  .byte $34, $34                   ;Play note E6  for 52 frames.
L984B:  .byte $30, $0D                   ;Play note C6  for 13 frames.
L984D:  .byte $32, $0D                   ;Play note D6  for 13 frames.
L984F:  .byte $34, $0D                   ;Play note E6  for 13 frames.
L9851:  .byte $30, $0D                   ;Play note C6  for 13 frames.
L9853:  .byte $34, $27                   ;Play note E6  for 39 frames.
L9855:  .byte $39, $27                   ;Play note A6  for 39 frames.
L9857:  .byte $34, $1A                   ;Play note E6  for 26 frames.
L9859:  .byte $35, $9C                   ;Play note F6  for 156 frames.
L985B:  .byte $35, $11                   ;Play note F6  for 17 frames.
L985D:  .byte $37, $11                   ;Play note G6  for 17 frames.
L985F:  .byte $39, $12                   ;Play note A6  for 18 frames.
L9861:  .byte $35, $34                   ;Play note F6  for 52 frames.
L9863:  .byte $35, $0D                   ;Play note F6  for 13 frames.
L9865:  .byte $34, $0D                   ;Play note E6  for 13 frames.
L9867:  .byte $32, $0D                   ;Play note D6  for 13 frames.
L9869:  .byte $39, $0D                   ;Play note A6  for 13 frames.
L986B:  .byte $35, $27                   ;Play note F6  for 39 frames.
L986D:  .byte $34, $41                   ;Play note E6  for 65 frames.
L986F:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9871:  .byte $35, $06                   ;Play note F6  for 6 frames.
L9873:  .byte $34, $07                   ;Play note E6  for 7 frames.
L9875:  .byte $32, $06                   ;Play note D6  for 6 frames.
L9877:  .byte $35, $07                   ;Play note F6  for 7 frames.
L9879:  .byte $34, $06                   ;Play note E6  for 6 frames.
L987B:  .byte $32, $07                   ;Play note D6  for 7 frames.
L987D:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L987F:  .byte $37, $06                   ;Play note G6  for 6 frames.
L9881:  .byte $35, $07                   ;Play note F6  for 7 frames.
L9883:  .byte $34, $06                   ;Play note E6  for 6 frames.
L9885:  .byte $37, $07                   ;Play note G6  for 7 frames.
L9887:  .byte $35, $06                   ;Play note F6  for 6 frames.
L9889:  .byte $34, $07                   ;Play note E6  for 7 frames.
L988B:  .byte $39, $27                   ;Play note A6  for 39 frames.
L988D:  .byte $38, $41                   ;Play note G#6 for 65 frames.
L988F:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9891:  .byte $39, $06                   ;Play note A6  for 6 frames.
L9893:  .byte $38, $07                   ;Play note G#6 for 7 frames.
L9895:  .byte $36, $06                   ;Play note F#6 for 6 frames.
L9897:  .byte $39, $07                   ;Play note A6  for 7 frames.
L9899:  .byte $38, $06                   ;Play note G#6 for 6 frames.
L989B:  .byte $36, $07                   ;Play note F#6 for 7 frames.
L989D:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L989F:  .byte $3B, $06                   ;Play note B6  for 6 frames.
L98A1:  .byte $39, $07                   ;Play note A6  for 7 frames.
L98A3:  .byte $38, $06                   ;Play note G#6 for 6 frames.
L98A5:  .byte $3B, $07                   ;Play note B6  for 7 frames.
L98A7:  .byte $39, $06                   ;Play note A6  for 6 frames.
L98A9:  .byte $38, $07                   ;Play note G#6 for 7 frames.
L98AB:  .byte $30, $34                   ;Play note C6  for 52 frames.
L98AD:  .byte $30, $0D                   ;Play note C6  for 13 frames.
L98AF:  .byte $32, $0D                   ;Play note D6  for 13 frames.
L98B1:  .byte $34, $0D                   ;Play note E6  for 13 frames.
L98B3:  .byte $30, $0D                   ;Play note C6  for 13 frames.
L98B5:  .byte $32, $27                   ;Play note D6  for 39 frames.
L98B7:  .byte $37, $41                   ;Play note G6  for 65 frames.
L98B9:  .byte $34, $34                   ;Play note E6  for 52 frames.
L98BB:  .byte $30, $0D                   ;Play note C6  for 13 frames.
L98BD:  .byte $32, $0D                   ;Play note D6  for 13 frames.
L98BF:  .byte $34, $0D                   ;Play note E6  for 13 frames.
L98C1:  .byte $30, $0D                   ;Play note C6  for 13 frames.
L98C3:  .byte $34, $27                   ;Play note E6  for 39 frames.
L98C5:  .byte $39, $27                   ;Play note A6  for 39 frames.
L98C7:  .byte $34, $1A                   ;Play note E6  for 26 frames.
L98C9:  .byte $35, $9C                   ;Play note F6  for 156 frames.
L98CB:  .byte $35, $11                   ;Play note F6  for 17 frames.
L98CD:  .byte $37, $11                   ;Play note G6  for 17 frames.
L98CF:  .byte $39, $12                   ;Play note A6  for 18 frames.
L98D1:  .byte $35, $34                   ;Play note F6  for 52 frames.
L98D3:  .byte $35, $0D                   ;Play note F6  for 13 frames.
L98D5:  .byte $34, $0D                   ;Play note E6  for 13 frames.
L98D7:  .byte $32, $0D                   ;Play note D6  for 13 frames.
L98D9:  .byte $39, $0D                   ;Play note A6  for 13 frames.
L98DB:  .byte $35, $27                   ;Play note F6  for 39 frames.
L98DD:  .byte $34, $41                   ;Play note E6  for 65 frames.
L98DF:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L98E1:  .byte $35, $06                   ;Play note F6  for 6 frames.
L98E3:  .byte $34, $07                   ;Play note E6  for 7 frames.
L98E5:  .byte $32, $06                   ;Play note D6  for 6 frames.
L98E7:  .byte $35, $07                   ;Play note F6  for 7 frames.
L98E9:  .byte $34, $06                   ;Play note E6  for 6 frames.
L98EB:  .byte $32, $07                   ;Play note D6  for 7 frames.
L98ED:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L98EF:  .byte $37, $06                   ;Play note G6  for 6 frames.
L98F1:  .byte $35, $07                   ;Play note F6  for 7 frames.
L98F3:  .byte $34, $06                   ;Play note E6  for 6 frames.
L98F5:  .byte $37, $07                   ;Play note G6  for 7 frames.
L98F7:  .byte $35, $06                   ;Play note F6  for 6 frames.
L98F9:  .byte $34, $07                   ;Play note E6  for 7 frames.
L98FB:  .byte $39, $27                   ;Play note A6  for 39 frames.
L98FD:  .byte $38, $41                   ;Play note G#6 for 65 frames.
L98FF:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9901:  .byte $39, $06                   ;Play note A6  for 6 frames.
L9903:  .byte $38, $07                   ;Play note G#6 for 7 frames.
L9905:  .byte $36, $06                   ;Play note F#6 for 6 frames.
L9907:  .byte $39, $07                   ;Play note A6  for 7 frames.
L9909:  .byte $38, $06                   ;Play note G#6 for 6 frames.
L990B:  .byte $36, $07                   ;Play note F#6 for 7 frames.
L990D:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L990F:  .byte $3B, $06                   ;Play note B6  for 6 frames.
L9911:  .byte $39, $07                   ;Play note A6  for 7 frames.
L9913:  .byte $38, $06                   ;Play note G#6 for 6 frames.
L9915:  .byte $3B, $07                   ;Play note B6  for 7 frames.
L9917:  .byte $39, $06                   ;Play note A6  for 6 frames.
L9919:  .byte $38, $07                   ;Play note G#6 for 7 frames.
L991B:  .byte CHN_VOLUME, $0D            ;Set channel volume to 13.
L991D:  .byte CHN_VIBRATO, $00, $06, $40 ;Set vibrato speed=6, intensity=64.
L9921:  .byte CHN_ASR, $11               ;Set ASR data index to 17.
L9923:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L9925:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L9927:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L9929:  .byte $28, $1A                   ;Play note E5  for 26 frames.
L992B:  .byte $26, $1A                   ;Play note D5  for 26 frames.
L992D:  .byte $28, $1A                   ;Play note E5  for 26 frames.
L992F:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L9931:  .byte $26, $1A                   ;Play note D5  for 26 frames.
L9933:  .byte $28, $1A                   ;Play note E5  for 26 frames.
L9935:  .byte $2B, $1A                   ;Play note G5  for 26 frames.
L9937:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L9939:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L993B:  .byte $24, $0D                   ;Play note C5  for 13 frames.
L993D:  .byte $26, $1A                   ;Play note D5  for 26 frames.
L993F:  .byte $24, $1A                   ;Play note C5  for 26 frames.
L9941:  .byte $26, $1A                   ;Play note D5  for 26 frames.
L9943:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L9945:  .byte $24, $1A                   ;Play note C5  for 26 frames.
L9947:  .byte $26, $1A                   ;Play note D5  for 26 frames.
L9949:  .byte $28, $1A                   ;Play note E5  for 26 frames.
L994B:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L994D:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L994F:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L9951:  .byte $28, $1A                   ;Play note E5  for 26 frames.
L9953:  .byte $26, $1A                   ;Play note D5  for 26 frames.
L9955:  .byte $28, $1A                   ;Play note E5  for 26 frames.
L9957:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L9959:  .byte $26, $1A                   ;Play note D5  for 26 frames.
L995B:  .byte $28, $1A                   ;Play note E5  for 26 frames.
L995D:  .byte $2B, $1A                   ;Play note G5  for 26 frames.
L995F:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L9961:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L9963:  .byte $24, $0D                   ;Play note C5  for 13 frames.
L9965:  .byte $26, $1A                   ;Play note D5  for 26 frames.
L9967:  .byte $24, $1A                   ;Play note C5  for 26 frames.
L9969:  .byte $26, $1A                   ;Play note D5  for 26 frames.
L996B:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L996D:  .byte $24, $1A                   ;Play note C5  for 26 frames.
L996F:  .byte $26, $1A                   ;Play note D5  for 26 frames.
L9971:  .byte $28, $1A                   ;Play note E5  for 26 frames.
L9973:  .byte $29, $0D                   ;Play note F5  for 13 frames.
L9975:  .byte $29, $0D                   ;Play note F5  for 13 frames.
L9977:  .byte $29, $0D                   ;Play note F5  for 13 frames.
L9979:  .byte $29, $0D                   ;Play note F5  for 13 frames.
L997B:  .byte $29, $0D                   ;Play note F5  for 13 frames.
L997D:  .byte $2B, $1A                   ;Play note G5  for 26 frames.
L997F:  .byte $29, $1A                   ;Play note F5  for 26 frames.
L9981:  .byte $29, $0D                   ;Play note F5  for 13 frames.
L9983:  .byte $28, $1A                   ;Play note E5  for 26 frames.
L9985:  .byte $26, $1A                   ;Play note D5  for 26 frames.
L9987:  .byte $24, $0D                   ;Play note C5  for 13 frames.
L9989:  .byte $2D, $34                   ;Play note A5  for 52 frames.
L998B:  .byte $2C, $0D                   ;Play note G#5 for 13 frames.
L998D:  .byte $2C, $27                   ;Play note G#5 for 39 frames.
L998F:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L9991:  .byte $2A, $27                   ;Play note F#5 for 39 frames.
L9993:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L9995:  .byte $2A, $06                   ;Play note F#5 for 6 frames.
L9997:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
L9999:  .byte $2D, $0D                   ;Play note A5  for 13 frames.
L999B:  .byte $2C, $06                   ;Play note G#5 for 6 frames.
L999D:  .byte $2D, $07                   ;Play note A5  for 7 frames.
L999F:  .byte $2F, $0D                   ;Play note B5  for 13 frames.
L99A1:  .byte CHN_JUMP, $00, $92, $FE    ;Jump back 366 bytes to $9833.

;----------------------------------------------------------------------------------------------------

;End music SQ2 data.

EndSQ2:
L99A5:  .byte CHN_VOLUME, $0C            ;Set channel volume to 12.
L99A7:  .byte CHN_VIBRATO, $00, $03, $80 ;Set vibrato speed=3, intensity=128.
L99AB:  .byte CHN_ASR, $0F               ;Set ASR data index to 15.
L99AD:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L99AF:  .byte $18, $0D                   ;Play note C4  for 13 frames.
L99B1:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L99B3:  .byte $18, $0D                   ;Play note C4  for 13 frames.
L99B5:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L99B7:  .byte $18, $0D                   ;Play note C4  for 13 frames.
L99B9:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L99BB:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L99BD:  .byte $1F, $0D                   ;Play note G4  for 13 frames.
L99BF:  .byte $17, $0D                   ;Play note B3  for 13 frames.
L99C1:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L99C3:  .byte $17, $0D                   ;Play note B3  for 13 frames.
L99C5:  .byte $1F, $0D                   ;Play note G4  for 13 frames.
L99C7:  .byte $17, $0D                   ;Play note B3  for 13 frames.
L99C9:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L99CB:  .byte $1F, $0D                   ;Play note G4  for 13 frames.
L99CD:  .byte $1F, $0D                   ;Play note G4  for 13 frames.
L99CF:  .byte $18, $0D                   ;Play note C4  for 13 frames.
L99D1:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L99D3:  .byte $18, $0D                   ;Play note C4  for 13 frames.
L99D5:  .byte $1F, $0D                   ;Play note G4  for 13 frames.
L99D7:  .byte $18, $0D                   ;Play note C4  for 13 frames.
L99D9:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L99DB:  .byte $1F, $0D                   ;Play note G4  for 13 frames.
L99DD:  .byte $1F, $0D                   ;Play note G4  for 13 frames.
L99DF:  .byte $19, $0D                   ;Play note C#4 for 13 frames.
L99E1:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L99E3:  .byte $19, $0D                   ;Play note C#4 for 13 frames.
L99E5:  .byte $1F, $0D                   ;Play note G4  for 13 frames.
L99E7:  .byte $19, $0D                   ;Play note C#4 for 13 frames.
L99E9:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L99EB:  .byte $1F, $0D                   ;Play note G4  for 13 frames.
L99ED:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L99EF:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L99F1:  .byte $1D, $0D                   ;Play note F4  for 13 frames.
L99F3:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L99F5:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L99F7:  .byte $19, $0D                   ;Play note C#4 for 13 frames.
L99F9:  .byte $1D, $0D                   ;Play note F4  for 13 frames.
L99FB:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L99FD:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L99FF:  .byte $18, $0D                   ;Play note C4  for 13 frames.
L9A01:  .byte $1D, $0D                   ;Play note F4  for 13 frames.
L9A03:  .byte $18, $0D                   ;Play note C4  for 13 frames.
L9A05:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L9A07:  .byte $17, $0D                   ;Play note B3  for 13 frames.
L9A09:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L9A0B:  .byte $1F, $0D                   ;Play note G4  for 13 frames.
L9A0D:  .byte $1D, $0D                   ;Play note F4  for 13 frames.
L9A0F:  .byte $16, $0D                   ;Play note A#3 for 13 frames.
L9A11:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L9A13:  .byte $16, $0D                   ;Play note A#3 for 13 frames.
L9A15:  .byte $1D, $0D                   ;Play note F4  for 13 frames.
L9A17:  .byte $16, $0D                   ;Play note A#3 for 13 frames.
L9A19:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L9A1B:  .byte $1D, $0D                   ;Play note F4  for 13 frames.
L9A1D:  .byte $1D, $0D                   ;Play note F4  for 13 frames.
L9A1F:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L9A21:  .byte $18, $0D                   ;Play note C4  for 13 frames.
L9A23:  .byte $1D, $0D                   ;Play note F4  for 13 frames.
L9A25:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L9A27:  .byte $18, $0D                   ;Play note C4  for 13 frames.
L9A29:  .byte $1D, $0D                   ;Play note F4  for 13 frames.
L9A2B:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L9A2D:  .byte $1D, $0D                   ;Play note F4  for 13 frames.
L9A2F:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L9A31:  .byte $18, $0D                   ;Play note C4  for 13 frames.
L9A33:  .byte $1D, $0D                   ;Play note F4  for 13 frames.
L9A35:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L9A37:  .byte $18, $0D                   ;Play note C4  for 13 frames.
L9A39:  .byte $1D, $0D                   ;Play note F4  for 13 frames.
L9A3B:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L9A3D:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L9A3F:  .byte $20, $0D                   ;Play note G#4 for 13 frames.
L9A41:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L9A43:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L9A45:  .byte $20, $0D                   ;Play note G#4 for 13 frames.
L9A47:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L9A49:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L9A4B:  .byte $20, $0D                   ;Play note G#4 for 13 frames.
L9A4D:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L9A4F:  .byte $20, $0D                   ;Play note G#4 for 13 frames.
L9A51:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L9A53:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L9A55:  .byte $20, $0D                   ;Play note G#4 for 13 frames.
L9A57:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L9A59:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L9A5B:  .byte $20, $0D                   ;Play note G#4 for 13 frames.
L9A5D:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L9A5F:  .byte $18, $0D                   ;Play note C4  for 13 frames.
L9A61:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L9A63:  .byte $18, $0D                   ;Play note C4  for 13 frames.
L9A65:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L9A67:  .byte $18, $0D                   ;Play note C4  for 13 frames.
L9A69:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L9A6B:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L9A6D:  .byte $1F, $0D                   ;Play note G4  for 13 frames.
L9A6F:  .byte $17, $0D                   ;Play note B3  for 13 frames.
L9A71:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L9A73:  .byte $17, $0D                   ;Play note B3  for 13 frames.
L9A75:  .byte $1F, $0D                   ;Play note G4  for 13 frames.
L9A77:  .byte $17, $0D                   ;Play note B3  for 13 frames.
L9A79:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L9A7B:  .byte $1F, $0D                   ;Play note G4  for 13 frames.
L9A7D:  .byte $1F, $0D                   ;Play note G4  for 13 frames.
L9A7F:  .byte $18, $0D                   ;Play note C4  for 13 frames.
L9A81:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L9A83:  .byte $18, $0D                   ;Play note C4  for 13 frames.
L9A85:  .byte $1F, $0D                   ;Play note G4  for 13 frames.
L9A87:  .byte $18, $0D                   ;Play note C4  for 13 frames.
L9A89:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L9A8B:  .byte $1F, $0D                   ;Play note G4  for 13 frames.
L9A8D:  .byte $1F, $0D                   ;Play note G4  for 13 frames.
L9A8F:  .byte $19, $0D                   ;Play note C#4 for 13 frames.
L9A91:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L9A93:  .byte $19, $0D                   ;Play note C#4 for 13 frames.
L9A95:  .byte $1F, $0D                   ;Play note G4  for 13 frames.
L9A97:  .byte $19, $0D                   ;Play note C#4 for 13 frames.
L9A99:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L9A9B:  .byte $1F, $0D                   ;Play note G4  for 13 frames.
L9A9D:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L9A9F:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L9AA1:  .byte $1D, $0D                   ;Play note F4  for 13 frames.
L9AA3:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L9AA5:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L9AA7:  .byte $19, $0D                   ;Play note C#4 for 13 frames.
L9AA9:  .byte $1D, $0D                   ;Play note F4  for 13 frames.
L9AAB:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L9AAD:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L9AAF:  .byte $18, $0D                   ;Play note C4  for 13 frames.
L9AB1:  .byte $1D, $0D                   ;Play note F4  for 13 frames.
L9AB3:  .byte $18, $0D                   ;Play note C4  for 13 frames.
L9AB5:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L9AB7:  .byte $17, $0D                   ;Play note B3  for 13 frames.
L9AB9:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L9ABB:  .byte $1F, $0D                   ;Play note G4  for 13 frames.
L9ABD:  .byte $1D, $0D                   ;Play note F4  for 13 frames.
L9ABF:  .byte $16, $0D                   ;Play note A#3 for 13 frames.
L9AC1:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L9AC3:  .byte $16, $0D                   ;Play note A#3 for 13 frames.
L9AC5:  .byte $1D, $0D                   ;Play note F4  for 13 frames.
L9AC7:  .byte $16, $0D                   ;Play note A#3 for 13 frames.
L9AC9:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L9ACB:  .byte $1D, $0D                   ;Play note F4  for 13 frames.
L9ACD:  .byte $1D, $0D                   ;Play note F4  for 13 frames.
L9ACF:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L9AD1:  .byte $18, $0D                   ;Play note C4  for 13 frames.
L9AD3:  .byte $1D, $0D                   ;Play note F4  for 13 frames.
L9AD5:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L9AD7:  .byte $18, $0D                   ;Play note C4  for 13 frames.
L9AD9:  .byte $1D, $0D                   ;Play note F4  for 13 frames.
L9ADB:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L9ADD:  .byte $1D, $0D                   ;Play note F4  for 13 frames.
L9ADF:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L9AE1:  .byte $18, $0D                   ;Play note C4  for 13 frames.
L9AE3:  .byte $1D, $0D                   ;Play note F4  for 13 frames.
L9AE5:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L9AE7:  .byte $18, $0D                   ;Play note C4  for 13 frames.
L9AE9:  .byte $1D, $0D                   ;Play note F4  for 13 frames.
L9AEB:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L9AED:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L9AEF:  .byte $20, $0D                   ;Play note G#4 for 13 frames.
L9AF1:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L9AF3:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L9AF5:  .byte $20, $0D                   ;Play note G#4 for 13 frames.
L9AF7:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L9AF9:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L9AFB:  .byte $20, $0D                   ;Play note G#4 for 13 frames.
L9AFD:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L9AFF:  .byte $20, $0D                   ;Play note G#4 for 13 frames.
L9B01:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L9B03:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L9B05:  .byte $20, $0D                   ;Play note G#4 for 13 frames.
L9B07:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L9B09:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L9B0B:  .byte $20, $0D                   ;Play note G#4 for 13 frames.
L9B0D:  .byte CHN_VOLUME, $0D            ;Set channel volume to 13.
L9B0F:  .byte CHN_ASR, $12               ;Set ASR data index to 18.
L9B11:  .byte $24, $0D                   ;Play note C5  for 13 frames.
L9B13:  .byte $24, $0D                   ;Play note C5  for 13 frames.
L9B15:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L9B17:  .byte $24, $1A                   ;Play note C5  for 26 frames.
L9B19:  .byte $23, $1A                   ;Play note B4  for 26 frames.
L9B1B:  .byte $24, $1A                   ;Play note C5  for 26 frames.
L9B1D:  .byte $24, $0D                   ;Play note C5  for 13 frames.
L9B1F:  .byte $23, $1A                   ;Play note B4  for 26 frames.
L9B21:  .byte $24, $1A                   ;Play note C5  for 26 frames.
L9B23:  .byte $28, $1A                   ;Play note E5  for 26 frames.
L9B25:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L9B27:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L9B29:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L9B2B:  .byte $23, $1A                   ;Play note B4  for 26 frames.
L9B2D:  .byte $21, $1A                   ;Play note A4  for 26 frames.
L9B2F:  .byte $23, $1A                   ;Play note B4  for 26 frames.
L9B31:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L9B33:  .byte $21, $1A                   ;Play note A4  for 26 frames.
L9B35:  .byte $23, $1A                   ;Play note B4  for 26 frames.
L9B37:  .byte $24, $1A                   ;Play note C5  for 26 frames.
L9B39:  .byte $24, $0D                   ;Play note C5  for 13 frames.
L9B3B:  .byte $24, $0D                   ;Play note C5  for 13 frames.
L9B3D:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L9B3F:  .byte $24, $1A                   ;Play note C5  for 26 frames.
L9B41:  .byte $23, $1A                   ;Play note B4  for 26 frames.
L9B43:  .byte $24, $1A                   ;Play note C5  for 26 frames.
L9B45:  .byte $24, $0D                   ;Play note C5  for 13 frames.
L9B47:  .byte $23, $1A                   ;Play note B4  for 26 frames.
L9B49:  .byte $24, $1A                   ;Play note C5  for 26 frames.
L9B4B:  .byte $28, $1A                   ;Play note E5  for 26 frames.
L9B4D:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L9B4F:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L9B51:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L9B53:  .byte $23, $1A                   ;Play note B4  for 26 frames.
L9B55:  .byte $21, $1A                   ;Play note A4  for 26 frames.
L9B57:  .byte $23, $1A                   ;Play note B4  for 26 frames.
L9B59:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L9B5B:  .byte $21, $1A                   ;Play note A4  for 26 frames.
L9B5D:  .byte $23, $1A                   ;Play note B4  for 26 frames.
L9B5F:  .byte $24, $1A                   ;Play note C5  for 26 frames.
L9B61:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L9B63:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L9B65:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L9B67:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L9B69:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L9B6B:  .byte $28, $1A                   ;Play note E5  for 26 frames.
L9B6D:  .byte $26, $1A                   ;Play note D5  for 26 frames.
L9B6F:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L9B71:  .byte $24, $1A                   ;Play note C5  for 26 frames.
L9B73:  .byte $23, $1A                   ;Play note B4  for 26 frames.
L9B75:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L9B77:  .byte $28, $34                   ;Play note E5  for 52 frames.
L9B79:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L9B7B:  .byte $28, $27                   ;Play note E5  for 39 frames.
L9B7D:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L9B7F:  .byte $26, $27                   ;Play note D5  for 39 frames.
L9B81:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L9B83:  .byte $26, $06                   ;Play note D5  for 6 frames.
L9B85:  .byte $28, $07                   ;Play note E5  for 7 frames.
L9B87:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L9B89:  .byte $28, $06                   ;Play note E5  for 6 frames.
L9B8B:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L9B8D:  .byte $2C, $0D                   ;Play note G#5 for 13 frames.
L9B8F:  .byte CHN_JUMP, $00, $16, $FE    ;Jump back 490 bytes to $99A5.

;----------------------------------------------------------------------------------------------------

;End music Triangle data.

EndTri:
L9B93:  .byte CHN_VOLUME, $0F            ;Set channel volume to 15.
L9B95:  .byte CHN_VIBRATO, $00, $03, $80 ;Set vibrato speed=3, intensity=128.
L9B99:  .byte CHN_ASR, $10               ;Set ASR data index to 16.
L9B9B:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9B9D:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9B9F:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9BA1:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9BA3:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9BA5:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9BA7:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9BA9:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9BAB:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9BAD:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9BAF:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9BB1:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9BB3:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9BB5:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9BB7:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9BB9:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9BBB:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9BBD:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9BBF:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9BC1:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9BC3:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9BC5:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9BC7:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9BC9:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9BCB:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L9BCD:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L9BCF:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L9BD1:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L9BD3:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L9BD5:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L9BD7:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L9BD9:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L9BDB:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9BDD:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9BDF:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9BE1:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9BE3:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L9BE5:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L9BE7:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L9BE9:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L9BEB:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9BED:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9BEF:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9BF1:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9BF3:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9BF5:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9BF7:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9BF9:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9BFB:  .byte $0A, $0D                   ;Play note A#1 for 13 frames.
L9BFD:  .byte $0A, $0D                   ;Play note A#1 for 13 frames.
L9BFF:  .byte $0A, $0D                   ;Play note A#1 for 13 frames.
L9C01:  .byte $0A, $0D                   ;Play note A#1 for 13 frames.
L9C03:  .byte $0A, $0D                   ;Play note A#1 for 13 frames.
L9C05:  .byte $0A, $0D                   ;Play note A#1 for 13 frames.
L9C07:  .byte $0A, $0D                   ;Play note A#1 for 13 frames.
L9C09:  .byte $0A, $0D                   ;Play note A#1 for 13 frames.
L9C0B:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9C0D:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9C0F:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9C11:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9C13:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9C15:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9C17:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9C19:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9C1B:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9C1D:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9C1F:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9C21:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9C23:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9C25:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9C27:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9C29:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9C2B:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9C2D:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9C2F:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9C31:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9C33:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9C35:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9C37:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9C39:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9C3B:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9C3D:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9C3F:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9C41:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9C43:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9C45:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9C47:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9C49:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9C4B:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9C4D:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9C4F:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9C51:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9C53:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9C55:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9C57:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9C59:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9C5B:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9C5D:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9C5F:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9C61:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9C63:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9C65:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9C67:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9C69:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9C6B:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9C6D:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9C6F:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9C71:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9C73:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9C75:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9C77:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9C79:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9C7B:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L9C7D:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L9C7F:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L9C81:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L9C83:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L9C85:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L9C87:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L9C89:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L9C8B:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9C8D:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9C8F:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9C91:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9C93:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L9C95:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L9C97:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L9C99:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L9C9B:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9C9D:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9C9F:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9CA1:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9CA3:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9CA5:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9CA7:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9CA9:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9CAB:  .byte $0A, $0D                   ;Play note A#1 for 13 frames.
L9CAD:  .byte $0A, $0D                   ;Play note A#1 for 13 frames.
L9CAF:  .byte $0A, $0D                   ;Play note A#1 for 13 frames.
L9CB1:  .byte $0A, $0D                   ;Play note A#1 for 13 frames.
L9CB3:  .byte $0A, $0D                   ;Play note A#1 for 13 frames.
L9CB5:  .byte $0A, $0D                   ;Play note A#1 for 13 frames.
L9CB7:  .byte $0A, $0D                   ;Play note A#1 for 13 frames.
L9CB9:  .byte $0A, $0D                   ;Play note A#1 for 13 frames.
L9CBB:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9CBD:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9CBF:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9CC1:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9CC3:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9CC5:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9CC7:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9CC9:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9CCB:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9CCD:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9CCF:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9CD1:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9CD3:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9CD5:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9CD7:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9CD9:  .byte $0C, $0D                   ;Play note C2  for 13 frames.
L9CDB:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9CDD:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9CDF:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9CE1:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9CE3:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9CE5:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9CE7:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9CE9:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9CEB:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9CED:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9CEF:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9CF1:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9CF3:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9CF5:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9CF7:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9CF9:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9CFB:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9CFD:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9CFF:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D01:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D03:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D05:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D07:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D09:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D0B:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D0D:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D0F:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D11:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D13:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D15:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D17:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D19:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D1B:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D1D:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D1F:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D21:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D23:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D25:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D27:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D29:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D2B:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D2D:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D2F:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D31:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D33:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D35:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D37:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D39:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D3B:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D3D:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D3F:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D41:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D43:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D45:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D47:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D49:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D4B:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D4D:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D4F:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D51:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D53:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D55:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D57:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D59:  .byte $11, $0D                   ;Play note F2  for 13 frames.
L9D5B:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D5D:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D5F:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D61:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D63:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D65:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D67:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D69:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D6B:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D6D:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D6F:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D71:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D73:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D75:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D77:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D79:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D7B:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9D7D:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9D7F:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9D81:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9D83:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9D85:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9D87:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9D89:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9D8B:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9D8D:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9D8F:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9D91:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9D93:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9D95:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9D97:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9D99:  .byte $10, $1A                   ;Play note E2  for 26 frames.
L9D9B:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D9D:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9D9F:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9DA1:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9DA3:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9DA5:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9DA7:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9DA9:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9DAB:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9DAD:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9DAF:  .byte $10, $0D                   ;Play note E2  for 13 frames.
L9DB1:  .byte $10, $06                   ;Play note E2  for 6 frames.
L9DB3:  .byte $0E, $07                   ;Play note D2  for 7 frames.
L9DB5:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9DB7:  .byte $10, $06                   ;Play note E2  for 6 frames.
L9DB9:  .byte $0E, $07                   ;Play note D2  for 7 frames.
L9DBB:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9DBD:  .byte CHN_JUMP, $00, $D6, $FD    ;Jump back 554 bytes to $9B93.

;----------------------------------------------------------------------------------------------------

;Used by Ambrosia music SQ1.

SQ1Attack13:
L9DC1:  .byte $0A, $82, $83, $84, $85, $87, $89, $8B, $8A, $8C, $8D

SQ1Sustain13:
L9DCC:  .byte $10, $8D, $8D, $8D, $8D, $8D, $8D, $8D, $8D, $8C, $8C, $8C, $8C, $8C, $8C, $8C
L9DDC:  .byte $8C

SQ1Release13:
L9DDD:  .byte $12, $8C, $8B, $8A, $89, $89, $88, $88, $87, $87, $86, $86, $86, $85, $85, $85
L9DED:  .byte $84, $84, $84, $84

;----------------------------------------------------------------------------------------------------

;Used by Ambrosia music SQ2.

SQ2Attack14:
L9DF1:  .byte $0A, $82, $83, $84, $85, $87, $89, $8B, $8A, $8C, $8D

SQ2Sustain14:
L9DFC:  .byte $10, $8D, $8D, $8D, $8D, $8D, $8D, $8D, $8D, $8C, $8C, $8C, $8C, $8C, $8C, $8C
L9E0C:  .byte $8C

SQ2Release14:
L9E0D:  .byte $10, $8C, $8B, $8A, $89, $89, $88, $88, $87, $87, $86, $86, $86, $85, $85, $85
L9E1D:  .byte $84, $84, $84, $84

;----------------------------------------------------------------------------------------------------

;Used by Ambrosia music Triangle.

TriAttack15:
L9E21:  .byte $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

TriSustain15:
L9E2A:  .byte $10, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
L9E3A:  .byte $0F

TriRelease15:
L9E3B:  .byte $08, $0F, $0F, $00, $00, $00, $00, $00, $00, $00

;----------------------------------------------------------------------------------------------------

;Used by Ambrosia music SQ2.

SQ2Attack16:
L9E45:  .byte $07, $85, $89, $8C, $8E, $90, $8C, $88

SQ2Sustain16:
L9E4D:  .byte $01, $88

SQ2Release16:
L9E4F:  .byte $0D, $87, $88, $88, $88, $87, $87, $87, $87, $86, $86, $86, $86, $85, $85

;----------------------------------------------------------------------------------------------------

;Used by Ambrosia music Triangle.

TriAttack17:
L9E5E:  .byte $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

TriSustain17:
L9E67:  .byte $20, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
L9E77:  .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $00, $00, $00, $00, $00, $00, $00
L9E87:  .byte $00

TriRelease17:
L9E88:  .byte $08, $00, $00, $00, $00, $00, $00, $00, $00, $00

;----------------------------------------------------------------------------------------------------

;Not used by any music.

NoAttack18:
L9E92:  .byte $07, $85, $89, $8C, $8E, $90, $8C, $88

NoSustain18:
L9E9A:  .byte $01, $88

NoRelease18:
L9E9C:  .byte $0D, $87, $88, $88, $88, $87, $87, $87, $87, $86, $86, $86, $86, $85, $85

;----------------------------------------------------------------------------------------------------

;Ambrosia music SQ1 data.

AmbrosiaSQ1:
L9EAB:  .byte CHN_VOLUME, $0E            ;Set channel volume to 14.
L9EAD:  .byte CHN_VIBRATO, $00, $0F, $14 ;Set vibrato speed=15, intensity=20.
L9EB1:  .byte CHN_ASR, $13               ;Set ASR data index to 19.
L9EB3:  .byte $1D, $4E                   ;Play note F4  for 78 frames.
L9EB5:  .byte $1D, $13                   ;Play note F4  for 19 frames.
L9EB7:  .byte $1F, $14                   ;Play note G4  for 20 frames.
L9EB9:  .byte $21, $13                   ;Play note A4  for 19 frames.
L9EBB:  .byte $1A, $14                   ;Play note D4  for 20 frames.
L9EBD:  .byte $22, $4E                   ;Play note A#4 for 78 frames.
L9EBF:  .byte $1D, $4E                   ;Play note F4  for 78 frames.
L9EC1:  .byte $1F, $4E                   ;Play note G4  for 78 frames.
L9EC3:  .byte $18, $27                   ;Play note C4  for 39 frames.
L9EC5:  .byte $24, $27                   ;Play note C5  for 39 frames.
L9EC7:  .byte $21, $9C                   ;Play note A4  for 156 frames.
L9EC9:  .byte CHN_SILENCE, $27           ;Silence channel for 39 frames.
L9ECB:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
L9ECD:  .byte $1A, $14                   ;Play note D4  for 20 frames.
L9ECF:  .byte $21, $13                   ;Play note A4  for 19 frames.
L9ED1:  .byte $22, $14                   ;Play note A#4 for 20 frames.
L9ED3:  .byte $24, $13                   ;Play note C5  for 19 frames.
L9ED5:  .byte $21, $14                   ;Play note A4  for 20 frames.
L9ED7:  .byte $22, $3A                   ;Play note A#4 for 58 frames.
L9ED9:  .byte $1A, $3B                   ;Play note D4  for 59 frames.
L9EDB:  .byte $1F, $27                   ;Play note G4  for 39 frames.
L9EDD:  .byte $1D, $4E                   ;Play note F4  for 78 frames.
L9EDF:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
L9EE1:  .byte $1F, $0A                   ;Play note G4  for 10 frames.
L9EE3:  .byte $20, $0A                   ;Play note G#4 for 10 frames.
L9EE5:  .byte $1F, $13                   ;Play note G4  for 19 frames.
L9EE7:  .byte $1D, $14                   ;Play note F4  for 20 frames.
L9EE9:  .byte $1D, $3A                   ;Play note F4  for 58 frames.
L9EEB:  .byte $1D, $0A                   ;Play note F4  for 10 frames.
L9EED:  .byte $1F, $0A                   ;Play note G4  for 10 frames.
L9EEF:  .byte $1C, $4E                   ;Play note E4  for 78 frames.
L9EF1:  .byte $1D, $4E                   ;Play note F4  for 78 frames.
L9EF3:  .byte $1D, $13                   ;Play note F4  for 19 frames.
L9EF5:  .byte $1F, $14                   ;Play note G4  for 20 frames.
L9EF7:  .byte $21, $13                   ;Play note A4  for 19 frames.
L9EF9:  .byte $1A, $14                   ;Play note D4  for 20 frames.
L9EFB:  .byte $22, $4E                   ;Play note A#4 for 78 frames.
L9EFD:  .byte $1D, $4E                   ;Play note F4  for 78 frames.
L9EFF:  .byte $1F, $4E                   ;Play note G4  for 78 frames.
L9F01:  .byte $18, $27                   ;Play note C4  for 39 frames.
L9F03:  .byte $24, $27                   ;Play note C5  for 39 frames.
L9F05:  .byte $21, $9C                   ;Play note A4  for 156 frames.
L9F07:  .byte CHN_SILENCE, $27           ;Silence channel for 39 frames.
L9F09:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
L9F0B:  .byte $1A, $14                   ;Play note D4  for 20 frames.
L9F0D:  .byte $21, $13                   ;Play note A4  for 19 frames.
L9F0F:  .byte $22, $14                   ;Play note A#4 for 20 frames.
L9F11:  .byte $24, $13                   ;Play note C5  for 19 frames.
L9F13:  .byte $21, $14                   ;Play note A4  for 20 frames.
L9F15:  .byte $22, $3A                   ;Play note A#4 for 58 frames.
L9F17:  .byte $1A, $3B                   ;Play note D4  for 59 frames.
L9F19:  .byte $1F, $27                   ;Play note G4  for 39 frames.
L9F1B:  .byte $1D, $4E                   ;Play note F4  for 78 frames.
L9F1D:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
L9F1F:  .byte $1F, $0A                   ;Play note G4  for 10 frames.
L9F21:  .byte $20, $0A                   ;Play note G#4 for 10 frames.
L9F23:  .byte $1F, $13                   ;Play note G4  for 19 frames.
L9F25:  .byte $1D, $14                   ;Play note F4  for 20 frames.
L9F27:  .byte $1D, $3A                   ;Play note F4  for 58 frames.
L9F29:  .byte $1D, $0A                   ;Play note F4  for 10 frames.
L9F2B:  .byte $1F, $0A                   ;Play note G4  for 10 frames.
L9F2D:  .byte $1C, $4E                   ;Play note E4  for 78 frames.
L9F2F:  .byte $28, $13                   ;Play note E5  for 19 frames.
L9F31:  .byte $29, $27                   ;Play note F5  for 39 frames.
L9F33:  .byte $2B, $14                   ;Play note G5  for 20 frames.
L9F35:  .byte $28, $4E                   ;Play note E5  for 78 frames.
L9F37:  .byte $28, $13                   ;Play note E5  for 19 frames.
L9F39:  .byte $29, $27                   ;Play note F5  for 39 frames.
L9F3B:  .byte $2B, $14                   ;Play note G5  for 20 frames.
L9F3D:  .byte $2D, $13                   ;Play note A5  for 19 frames.
L9F3F:  .byte $2B, $06                   ;Play note G5  for 6 frames.
L9F41:  .byte $2D, $06                   ;Play note A5  for 6 frames.
L9F43:  .byte $2B, $08                   ;Play note G5  for 8 frames.
L9F45:  .byte $29, $13                   ;Play note F5  for 19 frames.
L9F47:  .byte $28, $14                   ;Play note E5  for 20 frames.
L9F49:  .byte $26, $3A                   ;Play note D5  for 58 frames.
L9F4B:  .byte $24, $62                   ;Play note C5  for 98 frames.
L9F4D:  .byte $24, $0C                   ;Play note C5  for 12 frames.
L9F4F:  .byte $24, $0D                   ;Play note C5  for 13 frames.
L9F51:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L9F53:  .byte $26, $0C                   ;Play note D5  for 12 frames.
L9F55:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L9F57:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L9F59:  .byte $28, $0C                   ;Play note E5  for 12 frames.
L9F5B:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L9F5D:  .byte $29, $0E                   ;Play note F5  for 14 frames.
L9F5F:  .byte $29, $0C                   ;Play note F5  for 12 frames.
L9F61:  .byte $2B, $0D                   ;Play note G5  for 13 frames.
L9F63:  .byte $2B, $0E                   ;Play note G5  for 14 frames.
L9F65:  .byte $28, $13                   ;Play note E5  for 19 frames.
L9F67:  .byte $29, $27                   ;Play note F5  for 39 frames.
L9F69:  .byte $2B, $14                   ;Play note G5  for 20 frames.
L9F6B:  .byte $28, $4E                   ;Play note E5  for 78 frames.
L9F6D:  .byte $28, $13                   ;Play note E5  for 19 frames.
L9F6F:  .byte $29, $27                   ;Play note F5  for 39 frames.
L9F71:  .byte $2B, $14                   ;Play note G5  for 20 frames.
L9F73:  .byte $2D, $13                   ;Play note A5  for 19 frames.
L9F75:  .byte $2B, $06                   ;Play note G5  for 6 frames.
L9F77:  .byte $2D, $06                   ;Play note A5  for 6 frames.
L9F79:  .byte $2B, $08                   ;Play note G5  for 8 frames.
L9F7B:  .byte $29, $13                   ;Play note F5  for 19 frames.
L9F7D:  .byte $28, $14                   ;Play note E5  for 20 frames.
L9F7F:  .byte $26, $3A                   ;Play note D5  for 58 frames.
L9F81:  .byte $24, $62                   ;Play note C5  for 98 frames.
L9F83:  .byte $24, $0C                   ;Play note C5  for 12 frames.
L9F85:  .byte $24, $0D                   ;Play note C5  for 13 frames.
L9F87:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L9F89:  .byte $26, $0C                   ;Play note D5  for 12 frames.
L9F8B:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L9F8D:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L9F8F:  .byte $28, $0C                   ;Play note E5  for 12 frames.
L9F91:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L9F93:  .byte $29, $0E                   ;Play note F5  for 14 frames.
L9F95:  .byte $29, $0C                   ;Play note F5  for 12 frames.
L9F97:  .byte $2B, $0D                   ;Play note G5  for 13 frames.
L9F99:  .byte $2B, $0E                   ;Play note G5  for 14 frames.
L9F9B:  .byte $2C, $13                   ;Play note G#5 for 19 frames.
L9F9D:  .byte $29, $14                   ;Play note F5  for 20 frames.
L9F9F:  .byte $29, $13                   ;Play note F5  for 19 frames.
L9FA1:  .byte $26, $14                   ;Play note D5  for 20 frames.
L9FA3:  .byte $26, $13                   ;Play note D5  for 19 frames.
L9FA5:  .byte $23, $27                   ;Play note B4  for 39 frames.
L9FA7:  .byte $2C, $14                   ;Play note G#5 for 20 frames.
L9FA9:  .byte $2C, $13                   ;Play note G#5 for 19 frames.
L9FAB:  .byte $29, $14                   ;Play note F5  for 20 frames.
L9FAD:  .byte $29, $13                   ;Play note F5  for 19 frames.
L9FAF:  .byte $26, $14                   ;Play note D5  for 20 frames.
L9FB1:  .byte $26, $13                   ;Play note D5  for 19 frames.
L9FB3:  .byte $23, $3B                   ;Play note B4  for 59 frames.
L9FB5:  .byte $28, $3A                   ;Play note E5  for 58 frames.
L9FB7:  .byte $28, $0A                   ;Play note E5  for 10 frames.
L9FB9:  .byte $29, $0A                   ;Play note F5  for 10 frames.
L9FBB:  .byte $2B, $3A                   ;Play note G5  for 58 frames.
L9FBD:  .byte $2B, $0A                   ;Play note G5  for 10 frames.
L9FBF:  .byte $2D, $0A                   ;Play note A5  for 10 frames.
L9FC1:  .byte $2E, $3A                   ;Play note A#5 for 58 frames.
L9FC3:  .byte $2E, $0A                   ;Play note A#5 for 10 frames.
L9FC5:  .byte $30, $0A                   ;Play note C6  for 10 frames.
L9FC7:  .byte $2D, $4E                   ;Play note A5  for 78 frames.
L9FC9:  .byte CHN_JUMP, $00, $E2, $FE    ;Jump back 286 bytes to $9EAB.

;----------------------------------------------------------------------------------------------------

;Ambrosia music SQ2 data.

AmbrosiaSQ2:
L9FCD:  .byte CHN_VOLUME, $0C            ;Set channel volume to 12.
L9FCF:  .byte CHN_VIBRATO, $00, $0A, $18 ;Set vibrato speed=10, intensity=24.
L9FD3:  .byte CHN_ASR, $14               ;Set ASR data index to 20.
L9FD5:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
L9FD7:  .byte $1A, $14                   ;Play note D4  for 20 frames.
L9FD9:  .byte $1D, $13                   ;Play note F4  for 19 frames.
L9FDB:  .byte $1F, $14                   ;Play note G4  for 20 frames.
L9FDD:  .byte $21, $27                   ;Play note A4  for 39 frames.
L9FDF:  .byte $1A, $27                   ;Play note D4  for 39 frames.
L9FE1:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
L9FE3:  .byte $1A, $14                   ;Play note D4  for 20 frames.
L9FE5:  .byte $1D, $13                   ;Play note F4  for 19 frames.
L9FE7:  .byte $1F, $14                   ;Play note G4  for 20 frames.
L9FE9:  .byte $22, $27                   ;Play note A#4 for 39 frames.
L9FEB:  .byte $1A, $27                   ;Play note D4  for 39 frames.
L9FED:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
L9FEF:  .byte $18, $14                   ;Play note C4  for 20 frames.
L9FF1:  .byte $1C, $13                   ;Play note E4  for 19 frames.
L9FF3:  .byte $1D, $14                   ;Play note F4  for 20 frames.
L9FF5:  .byte $1F, $27                   ;Play note G4  for 39 frames.
L9FF7:  .byte $18, $27                   ;Play note C4  for 39 frames.
L9FF9:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
L9FFB:  .byte $18, $14                   ;Play note C4  for 20 frames.
L9FFD:  .byte $1D, $13                   ;Play note F4  for 19 frames.
L9FFF:  .byte $1F, $14                   ;Play note G4  for 20 frames.
LA001:  .byte $21, $27                   ;Play note A4  for 39 frames.
LA003:  .byte $18, $27                   ;Play note C4  for 39 frames.
LA005:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA007:  .byte $1A, $14                   ;Play note D4  for 20 frames.
LA009:  .byte $1E, $13                   ;Play note F#4 for 19 frames.
LA00B:  .byte $21, $14                   ;Play note A4  for 20 frames.
LA00D:  .byte $24, $13                   ;Play note C5  for 19 frames.
LA00F:  .byte $22, $14                   ;Play note A#4 for 20 frames.
LA011:  .byte $21, $13                   ;Play note A4  for 19 frames.
LA013:  .byte $1E, $14                   ;Play note F#4 for 20 frames.
LA015:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA017:  .byte $1F, $14                   ;Play note G4  for 20 frames.
LA019:  .byte $1A, $13                   ;Play note D4  for 19 frames.
LA01B:  .byte $22, $14                   ;Play note A#4 for 20 frames.
LA01D:  .byte $24, $13                   ;Play note C5  for 19 frames.
LA01F:  .byte $22, $06                   ;Play note A#4 for 6 frames.
LA021:  .byte $24, $06                   ;Play note C5  for 6 frames.
LA023:  .byte $22, $08                   ;Play note A#4 for 8 frames.
LA025:  .byte $21, $13                   ;Play note A4  for 19 frames.
LA027:  .byte $1A, $14                   ;Play note D4  for 20 frames.
LA029:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA02B:  .byte $1D, $14                   ;Play note F4  for 20 frames.
LA02D:  .byte $17, $13                   ;Play note B3  for 19 frames.
LA02F:  .byte $1A, $14                   ;Play note D4  for 20 frames.
LA031:  .byte $1D, $13                   ;Play note F4  for 19 frames.
LA033:  .byte $17, $14                   ;Play note B3  for 20 frames.
LA035:  .byte $20, $13                   ;Play note G#4 for 19 frames.
LA037:  .byte $1D, $14                   ;Play note F4  for 20 frames.
LA039:  .byte $1A, $3A                   ;Play note D4  for 58 frames.
LA03B:  .byte $1A, $0A                   ;Play note D4  for 10 frames.
LA03D:  .byte $1C, $0A                   ;Play note E4  for 10 frames.
LA03F:  .byte $19, $4E                   ;Play note C#4 for 78 frames.
LA041:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA043:  .byte $1A, $14                   ;Play note D4  for 20 frames.
LA045:  .byte $1D, $13                   ;Play note F4  for 19 frames.
LA047:  .byte $1F, $14                   ;Play note G4  for 20 frames.
LA049:  .byte $21, $27                   ;Play note A4  for 39 frames.
LA04B:  .byte $1A, $27                   ;Play note D4  for 39 frames.
LA04D:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA04F:  .byte $1A, $14                   ;Play note D4  for 20 frames.
LA051:  .byte $1D, $13                   ;Play note F4  for 19 frames.
LA053:  .byte $1F, $14                   ;Play note G4  for 20 frames.
LA055:  .byte $22, $27                   ;Play note A#4 for 39 frames.
LA057:  .byte $1A, $27                   ;Play note D4  for 39 frames.
LA059:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA05B:  .byte $18, $14                   ;Play note C4  for 20 frames.
LA05D:  .byte $1C, $13                   ;Play note E4  for 19 frames.
LA05F:  .byte $1D, $14                   ;Play note F4  for 20 frames.
LA061:  .byte $1F, $27                   ;Play note G4  for 39 frames.
LA063:  .byte $18, $27                   ;Play note C4  for 39 frames.
LA065:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA067:  .byte $18, $14                   ;Play note C4  for 20 frames.
LA069:  .byte $1D, $13                   ;Play note F4  for 19 frames.
LA06B:  .byte $1F, $14                   ;Play note G4  for 20 frames.
LA06D:  .byte $21, $27                   ;Play note A4  for 39 frames.
LA06F:  .byte $18, $27                   ;Play note C4  for 39 frames.
LA071:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA073:  .byte $1A, $14                   ;Play note D4  for 20 frames.
LA075:  .byte $1E, $13                   ;Play note F#4 for 19 frames.
LA077:  .byte $21, $14                   ;Play note A4  for 20 frames.
LA079:  .byte $24, $13                   ;Play note C5  for 19 frames.
LA07B:  .byte $22, $14                   ;Play note A#4 for 20 frames.
LA07D:  .byte $21, $13                   ;Play note A4  for 19 frames.
LA07F:  .byte $1E, $14                   ;Play note F#4 for 20 frames.
LA081:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA083:  .byte $1F, $14                   ;Play note G4  for 20 frames.
LA085:  .byte $1A, $13                   ;Play note D4  for 19 frames.
LA087:  .byte $22, $14                   ;Play note A#4 for 20 frames.
LA089:  .byte $24, $13                   ;Play note C5  for 19 frames.
LA08B:  .byte $22, $06                   ;Play note A#4 for 6 frames.
LA08D:  .byte $24, $06                   ;Play note C5  for 6 frames.
LA08F:  .byte $22, $08                   ;Play note A#4 for 8 frames.
LA091:  .byte $21, $13                   ;Play note A4  for 19 frames.
LA093:  .byte $1A, $14                   ;Play note D4  for 20 frames.
LA095:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA097:  .byte $1D, $14                   ;Play note F4  for 20 frames.
LA099:  .byte $17, $13                   ;Play note B3  for 19 frames.
LA09B:  .byte $1A, $14                   ;Play note D4  for 20 frames.
LA09D:  .byte $1D, $13                   ;Play note F4  for 19 frames.
LA09F:  .byte $17, $14                   ;Play note B3  for 20 frames.
LA0A1:  .byte $20, $13                   ;Play note G#4 for 19 frames.
LA0A3:  .byte $1D, $14                   ;Play note F4  for 20 frames.
LA0A5:  .byte $1A, $3A                   ;Play note D4  for 58 frames.
LA0A7:  .byte $1A, $0A                   ;Play note D4  for 10 frames.
LA0A9:  .byte $1C, $0A                   ;Play note E4  for 10 frames.
LA0AB:  .byte $19, $4E                   ;Play note C#4 for 78 frames.
LA0AD:  .byte CHN_ASR, $16               ;Set ASR data index to 22.
LA0AF:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA0B1:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA0B3:  .byte $28, $0A                   ;Play note E5  for 10 frames.
LA0B5:  .byte $29, $09                   ;Play note F5  for 9 frames.
LA0B7:  .byte $28, $0A                   ;Play note E5  for 10 frames.
LA0B9:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA0BB:  .byte $28, $0A                   ;Play note E5  for 10 frames.
LA0BD:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA0BF:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA0C1:  .byte $28, $0A                   ;Play note E5  for 10 frames.
LA0C3:  .byte $29, $09                   ;Play note F5  for 9 frames.
LA0C5:  .byte $28, $0A                   ;Play note E5  for 10 frames.
LA0C7:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA0C9:  .byte $28, $0A                   ;Play note E5  for 10 frames.
LA0CB:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA0CD:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA0CF:  .byte $28, $0A                   ;Play note E5  for 10 frames.
LA0D1:  .byte $29, $09                   ;Play note F5  for 9 frames.
LA0D3:  .byte $28, $0A                   ;Play note E5  for 10 frames.
LA0D5:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA0D7:  .byte $28, $0A                   ;Play note E5  for 10 frames.
LA0D9:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA0DB:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA0DD:  .byte $28, $0A                   ;Play note E5  for 10 frames.
LA0DF:  .byte $29, $09                   ;Play note F5  for 9 frames.
LA0E1:  .byte $28, $0A                   ;Play note E5  for 10 frames.
LA0E3:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA0E5:  .byte $28, $0A                   ;Play note E5  for 10 frames.
LA0E7:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA0E9:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LA0EB:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA0ED:  .byte $28, $09                   ;Play note E5  for 9 frames.
LA0EF:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA0F1:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LA0F3:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA0F5:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA0F7:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LA0F9:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA0FB:  .byte $28, $09                   ;Play note E5  for 9 frames.
LA0FD:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA0FF:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LA101:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA103:  .byte $21, $0C                   ;Play note A4  for 12 frames.
LA105:  .byte $21, $0D                   ;Play note A4  for 13 frames.
LA107:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LA109:  .byte $22, $0C                   ;Play note A#4 for 12 frames.
LA10B:  .byte $24, $0D                   ;Play note C5  for 13 frames.
LA10D:  .byte $24, $0E                   ;Play note C5  for 14 frames.
LA10F:  .byte $24, $0C                   ;Play note C5  for 12 frames.
LA111:  .byte $24, $0D                   ;Play note C5  for 13 frames.
LA113:  .byte $26, $0E                   ;Play note D5  for 14 frames.
LA115:  .byte $26, $0C                   ;Play note D5  for 12 frames.
LA117:  .byte $28, $0D                   ;Play note E5  for 13 frames.
LA119:  .byte $28, $0E                   ;Play note E5  for 14 frames.
LA11B:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA11D:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA11F:  .byte $28, $0A                   ;Play note E5  for 10 frames.
LA121:  .byte $29, $09                   ;Play note F5  for 9 frames.
LA123:  .byte $28, $0A                   ;Play note E5  for 10 frames.
LA125:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA127:  .byte $28, $0A                   ;Play note E5  for 10 frames.
LA129:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA12B:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA12D:  .byte $28, $0A                   ;Play note E5  for 10 frames.
LA12F:  .byte $29, $09                   ;Play note F5  for 9 frames.
LA131:  .byte $28, $0A                   ;Play note E5  for 10 frames.
LA133:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA135:  .byte $28, $0A                   ;Play note E5  for 10 frames.
LA137:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA139:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA13B:  .byte $28, $0A                   ;Play note E5  for 10 frames.
LA13D:  .byte $29, $09                   ;Play note F5  for 9 frames.
LA13F:  .byte $28, $0A                   ;Play note E5  for 10 frames.
LA141:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA143:  .byte $28, $0A                   ;Play note E5  for 10 frames.
LA145:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA147:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA149:  .byte $28, $0A                   ;Play note E5  for 10 frames.
LA14B:  .byte $29, $09                   ;Play note F5  for 9 frames.
LA14D:  .byte $28, $0A                   ;Play note E5  for 10 frames.
LA14F:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA151:  .byte $28, $0A                   ;Play note E5  for 10 frames.
LA153:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA155:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LA157:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA159:  .byte $28, $09                   ;Play note E5  for 9 frames.
LA15B:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA15D:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LA15F:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA161:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA163:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LA165:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA167:  .byte $28, $09                   ;Play note E5  for 9 frames.
LA169:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA16B:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LA16D:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA16F:  .byte $21, $0C                   ;Play note A4  for 12 frames.
LA171:  .byte $21, $0D                   ;Play note A4  for 13 frames.
LA173:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LA175:  .byte $22, $0C                   ;Play note A#4 for 12 frames.
LA177:  .byte $24, $0D                   ;Play note C5  for 13 frames.
LA179:  .byte $24, $0E                   ;Play note C5  for 14 frames.
LA17B:  .byte $24, $0C                   ;Play note C5  for 12 frames.
LA17D:  .byte $24, $0D                   ;Play note C5  for 13 frames.
LA17F:  .byte $26, $0E                   ;Play note D5  for 14 frames.
LA181:  .byte $26, $0C                   ;Play note D5  for 12 frames.
LA183:  .byte $28, $0D                   ;Play note E5  for 13 frames.
LA185:  .byte $28, $0E                   ;Play note E5  for 14 frames.
LA187:  .byte $29, $13                   ;Play note F5  for 19 frames.
LA189:  .byte $26, $14                   ;Play note D5  for 20 frames.
LA18B:  .byte $26, $13                   ;Play note D5  for 19 frames.
LA18D:  .byte $23, $14                   ;Play note B4  for 20 frames.
LA18F:  .byte $23, $13                   ;Play note B4  for 19 frames.
LA191:  .byte $20, $27                   ;Play note G#4 for 39 frames.
LA193:  .byte $29, $14                   ;Play note F5  for 20 frames.
LA195:  .byte $29, $13                   ;Play note F5  for 19 frames.
LA197:  .byte $26, $14                   ;Play note D5  for 20 frames.
LA199:  .byte $26, $13                   ;Play note D5  for 19 frames.
LA19B:  .byte $23, $14                   ;Play note B4  for 20 frames.
LA19D:  .byte $23, $13                   ;Play note B4  for 19 frames.
LA19F:  .byte $20, $3B                   ;Play note G#4 for 59 frames.
LA1A1:  .byte $25, $3A                   ;Play note C#5 for 58 frames.
LA1A3:  .byte $25, $0A                   ;Play note C#5 for 10 frames.
LA1A5:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LA1A7:  .byte $28, $3A                   ;Play note E5  for 58 frames.
LA1A9:  .byte $28, $0A                   ;Play note E5  for 10 frames.
LA1AB:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LA1AD:  .byte $2B, $3A                   ;Play note G5  for 58 frames.
LA1AF:  .byte $2B, $0A                   ;Play note G5  for 10 frames.
LA1B1:  .byte $2D, $0A                   ;Play note A5  for 10 frames.
LA1B3:  .byte $28, $4E                   ;Play note E5  for 78 frames.
LA1B5:  .byte CHN_JUMP, $00, $18, $FE    ;Jump back 488 bytes to $9FCD.

;----------------------------------------------------------------------------------------------------

;Ambrosia music Triangle data.

AmbrosiaTri:
LA1B9:  .byte CHN_VOLUME, $0F            ;Set channel volume to 15.
LA1BB:  .byte CHN_VIBRATO, $FF, $00, $00 ;Disable vibrato.
LA1BF:  .byte CHN_ASR, $17               ;Set ASR data index to 23.
LA1C1:  .byte $0E, $75                   ;Play note D2  for 117 frames.
LA1C3:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA1C5:  .byte $0C, $14                   ;Play note C2  for 20 frames.
LA1C7:  .byte $0E, $75                   ;Play note D2  for 117 frames.
LA1C9:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA1CB:  .byte $0E, $14                   ;Play note D2  for 20 frames.
LA1CD:  .byte $10, $75                   ;Play note E2  for 117 frames.
LA1CF:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA1D1:  .byte $10, $14                   ;Play note E2  for 20 frames.
LA1D3:  .byte $11, $75                   ;Play note F2  for 117 frames.
LA1D5:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA1D7:  .byte $11, $14                   ;Play note F2  for 20 frames.
LA1D9:  .byte $12, $75                   ;Play note F#2 for 117 frames.
LA1DB:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA1DD:  .byte $12, $14                   ;Play note F#2 for 20 frames.
LA1DF:  .byte $13, $75                   ;Play note G2  for 117 frames.
LA1E1:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA1E3:  .byte $13, $14                   ;Play note G2  for 20 frames.
LA1E5:  .byte $14, $75                   ;Play note G#2 for 117 frames.
LA1E7:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA1E9:  .byte $14, $14                   ;Play note G#2 for 20 frames.
LA1EB:  .byte $15, $27                   ;Play note A2  for 39 frames.
LA1ED:  .byte $09, $4E                   ;Play note A1  for 78 frames.
LA1EF:  .byte $11, $09                   ;Play note F2  for 9 frames.
LA1F1:  .byte $10, $0A                   ;Play note E2  for 10 frames.
LA1F3:  .byte $0E, $0A                   ;Play note D2  for 10 frames.
LA1F5:  .byte $0D, $0A                   ;Play note C#2 for 10 frames.
LA1F7:  .byte $0E, $75                   ;Play note D2  for 117 frames.
LA1F9:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA1FB:  .byte $0C, $14                   ;Play note C2  for 20 frames.
LA1FD:  .byte $0E, $75                   ;Play note D2  for 117 frames.
LA1FF:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA201:  .byte $0E, $14                   ;Play note D2  for 20 frames.
LA203:  .byte $10, $75                   ;Play note E2  for 117 frames.
LA205:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA207:  .byte $10, $14                   ;Play note E2  for 20 frames.
LA209:  .byte $11, $75                   ;Play note F2  for 117 frames.
LA20B:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA20D:  .byte $11, $14                   ;Play note F2  for 20 frames.
LA20F:  .byte $12, $75                   ;Play note F#2 for 117 frames.
LA211:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA213:  .byte $12, $14                   ;Play note F#2 for 20 frames.
LA215:  .byte $13, $75                   ;Play note G2  for 117 frames.
LA217:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA219:  .byte $13, $14                   ;Play note G2  for 20 frames.
LA21B:  .byte $14, $75                   ;Play note G#2 for 117 frames.
LA21D:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA21F:  .byte $14, $14                   ;Play note G#2 for 20 frames.
LA221:  .byte $15, $27                   ;Play note A2  for 39 frames.
LA223:  .byte $09, $4E                   ;Play note A1  for 78 frames.
LA225:  .byte $11, $09                   ;Play note F2  for 9 frames.
LA227:  .byte $10, $0A                   ;Play note E2  for 10 frames.
LA229:  .byte $0E, $0A                   ;Play note D2  for 10 frames.
LA22B:  .byte $0D, $0A                   ;Play note C#2 for 10 frames.
LA22D:  .byte $0B, $27                   ;Play note B1  for 39 frames.
LA22F:  .byte CHN_SILENCE, $27           ;Silence channel for 39 frames.
LA231:  .byte $0B, $27                   ;Play note B1  for 39 frames.
LA233:  .byte CHN_SILENCE, $27           ;Silence channel for 39 frames.
LA235:  .byte $0B, $27                   ;Play note B1  for 39 frames.
LA237:  .byte CHN_SILENCE, $27           ;Silence channel for 39 frames.
LA239:  .byte $0B, $27                   ;Play note B1  for 39 frames.
LA23B:  .byte CHN_SILENCE, $27           ;Silence channel for 39 frames.
LA23D:  .byte $09, $27                   ;Play note A1  for 39 frames.
LA23F:  .byte CHN_SILENCE, $27           ;Silence channel for 39 frames.
LA241:  .byte $09, $27                   ;Play note A1  for 39 frames.
LA243:  .byte CHN_SILENCE, $27           ;Silence channel for 39 frames.
LA245:  .byte $09, $27                   ;Play note A1  for 39 frames.
LA247:  .byte CHN_SILENCE, $27           ;Silence channel for 39 frames.
LA249:  .byte $09, $27                   ;Play note A1  for 39 frames.
LA24B:  .byte CHN_SILENCE, $27           ;Silence channel for 39 frames.
LA24D:  .byte $0B, $27                   ;Play note B1  for 39 frames.
LA24F:  .byte CHN_SILENCE, $27           ;Silence channel for 39 frames.
LA251:  .byte $0B, $27                   ;Play note B1  for 39 frames.
LA253:  .byte CHN_SILENCE, $27           ;Silence channel for 39 frames.
LA255:  .byte $0B, $27                   ;Play note B1  for 39 frames.
LA257:  .byte CHN_SILENCE, $27           ;Silence channel for 39 frames.
LA259:  .byte $0B, $27                   ;Play note B1  for 39 frames.
LA25B:  .byte CHN_SILENCE, $27           ;Silence channel for 39 frames.
LA25D:  .byte $09, $27                   ;Play note A1  for 39 frames.
LA25F:  .byte CHN_SILENCE, $27           ;Silence channel for 39 frames.
LA261:  .byte $09, $27                   ;Play note A1  for 39 frames.
LA263:  .byte CHN_SILENCE, $27           ;Silence channel for 39 frames.
LA265:  .byte $09, $27                   ;Play note A1  for 39 frames.
LA267:  .byte CHN_SILENCE, $27           ;Silence channel for 39 frames.
LA269:  .byte $09, $27                   ;Play note A1  for 39 frames.
LA26B:  .byte CHN_SILENCE, $27           ;Silence channel for 39 frames.
LA26D:  .byte CHN_ASR, $15               ;Set ASR data index to 21.
LA26F:  .byte $08, $13                   ;Play note G#1 for 19 frames.
LA271:  .byte $0B, $14                   ;Play note B1  for 20 frames.
LA273:  .byte $0E, $13                   ;Play note D2  for 19 frames.
LA275:  .byte $11, $14                   ;Play note F2  for 20 frames.
LA277:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA279:  .byte $11, $14                   ;Play note F2  for 20 frames.
LA27B:  .byte $0E, $13                   ;Play note D2  for 19 frames.
LA27D:  .byte $0B, $14                   ;Play note B1  for 20 frames.
LA27F:  .byte $08, $13                   ;Play note G#1 for 19 frames.
LA281:  .byte $0B, $14                   ;Play note B1  for 20 frames.
LA283:  .byte $0E, $13                   ;Play note D2  for 19 frames.
LA285:  .byte $11, $14                   ;Play note F2  for 20 frames.
LA287:  .byte CHN_SILENCE, $13           ;Silence channel for 19 frames.
LA289:  .byte $11, $14                   ;Play note F2  for 20 frames.
LA28B:  .byte $0E, $13                   ;Play note D2  for 19 frames.
LA28D:  .byte $0B, $14                   ;Play note B1  for 20 frames.
LA28F:  .byte $09, $13                   ;Play note A1  for 19 frames.
LA291:  .byte $15, $14                   ;Play note A2  for 20 frames.
LA293:  .byte $09, $13                   ;Play note A1  for 19 frames.
LA295:  .byte $15, $14                   ;Play note A2  for 20 frames.
LA297:  .byte $09, $13                   ;Play note A1  for 19 frames.
LA299:  .byte $15, $14                   ;Play note A2  for 20 frames.
LA29B:  .byte $09, $13                   ;Play note A1  for 19 frames.
LA29D:  .byte $15, $14                   ;Play note A2  for 20 frames.
LA29F:  .byte $15, $09                   ;Play note A2  for 9 frames.
LA2A1:  .byte $13, $0A                   ;Play note G2  for 10 frames.
LA2A3:  .byte $10, $0A                   ;Play note E2  for 10 frames.
LA2A5:  .byte $09, $0A                   ;Play note A1  for 10 frames.
LA2A7:  .byte $15, $09                   ;Play note A2  for 9 frames.
LA2A9:  .byte $13, $0A                   ;Play note G2  for 10 frames.
LA2AB:  .byte $10, $0A                   ;Play note E2  for 10 frames.
LA2AD:  .byte $09, $0A                   ;Play note A1  for 10 frames.
LA2AF:  .byte $09, $27                   ;Play note A1  for 39 frames.
LA2B1:  .byte $0C, $27                   ;Play note C2  for 39 frames.
LA2B3:  .byte CHN_JUMP, $00, $06, $FF    ;Jump back 250 bytes to $A1B9.

;----------------------------------------------------------------------------------------------------

;Used by Fight music SQ1.

SQ1Attack19:
LA2B7:  .byte $06, $08, $10, $0E, $0B, $08, $05

SQ1Sustain19:
LA2BE:  .byte $04, $06, $07, $08, $07

SQ1Release19:
LA2C3:  .byte $15, $07, $07, $07, $06, $06, $06, $05, $05, $05, $04, $04, $04, $03, $03, $03
LA2D3:  .byte $02, $02, $02, $01, $01, $00

;----------------------------------------------------------------------------------------------------

;Used by Fight music SQ2.

SQ2Attack1A:
LA2D9:  .byte $06, $48, $50, $4E, $4B, $48, $45

SQ2Sustain1A:
LA2E0:  .byte $04, $46, $47, $48, $47

SQ2Release1A:
LA2E5:  .byte $1A, $47, $47, $47, $47, $46, $46, $46, $46, $45, $45, $45, $45, $44, $44, $44
LA2F5:  .byte $44, $43, $43, $43, $43, $42, $42, $42, $41, $41, $40

;----------------------------------------------------------------------------------------------------

;Used by Fight music Triangle.

TriAttack1B:
LA300:  .byte $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

TriSustain1B:
LA309:  .byte $10, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $00, $00, $00, $00, $00, $00, $00
LA319:  .byte $00

TriRelease1B:
LA31A:  .byte $08, $00, $00, $00, $00, $00, $00, $00, $00

;----------------------------------------------------------------------------------------------------

;Used by Fight music SQ2.

SQ2Attack1C:
LA323:  .byte $04, $08, $10, $4E, $48

SQ2Sustain1C:
LA328:  .byte $04, $46, $47, $48, $47

SQ2Release1C:
LA32D:  .byte $14, $47, $47, $47, $47, $46, $46, $46, $46, $45, $45, $45, $45, $44, $44, $44
LA33D:  .byte $44, $43, $43, $43, $43

;----------------------------------------------------------------------------------------------------

;Used by Fight music SQ1.

SQ1Attack1D:
LA342:  .byte $05, $48, $50, $8E, $88, $88

SQ1Sustain1D:
LA348:  .byte $04, $86, $87, $88, $87

SQ1Release1D:
LA34D:  .byte $10, $87, $87, $87, $86, $86, $86, $85, $85, $85, $84, $84, $84, $83, $83, $83
LA35D:  .byte $83

;----------------------------------------------------------------------------------------------------

;Fight music SQ1 data.

FightSQ1:
LA35E:  .byte CHN_VOLUME, $0D            ;Set channel volume to 13.
LA360:  .byte CHN_VIBRATO, $00, $04, $18 ;Set vibrato speed=4, intensity=24.
LA364:  .byte CHN_ASR, $19               ;Set ASR data index to 25.
LA366:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA368:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA36A:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
LA36C:  .byte $18, $12                   ;Play note C4  for 18 frames.
LA36E:  .byte $17, $09                   ;Play note B3  for 9 frames.
LA370:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA372:  .byte CHN_SILENCE, $24           ;Silence channel for 36 frames.
LA374:  .byte CHN_SILENCE, $09           ;Silence channel for 9 frames.
LA376:  .byte $13, $09                   ;Play note G3  for 9 frames.
LA378:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA37A:  .byte $18, $09                   ;Play note C4  for 9 frames.
LA37C:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA37E:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA380:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
LA382:  .byte $18, $12                   ;Play note C4  for 18 frames.
LA384:  .byte $17, $09                   ;Play note B3  for 9 frames.
LA386:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA388:  .byte CHN_SILENCE, $24           ;Silence channel for 36 frames.
LA38A:  .byte CHN_SILENCE, $09           ;Silence channel for 9 frames.
LA38C:  .byte $13, $09                   ;Play note G3  for 9 frames.
LA38E:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA390:  .byte $18, $09                   ;Play note C4  for 9 frames.
LA392:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA394:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA396:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
LA398:  .byte $18, $12                   ;Play note C4  for 18 frames.
LA39A:  .byte $17, $09                   ;Play note B3  for 9 frames.
LA39C:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA39E:  .byte CHN_SILENCE, $24           ;Silence channel for 36 frames.
LA3A0:  .byte CHN_SILENCE, $09           ;Silence channel for 9 frames.
LA3A2:  .byte $13, $09                   ;Play note G3  for 9 frames.
LA3A4:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA3A6:  .byte $18, $09                   ;Play note C4  for 9 frames.
LA3A8:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA3AA:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA3AC:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
LA3AE:  .byte $18, $12                   ;Play note C4  for 18 frames.
LA3B0:  .byte $17, $09                   ;Play note B3  for 9 frames.
LA3B2:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA3B4:  .byte CHN_SILENCE, $24           ;Silence channel for 36 frames.
LA3B6:  .byte CHN_SILENCE, $09           ;Silence channel for 9 frames.
LA3B8:  .byte $13, $09                   ;Play note G3  for 9 frames.
LA3BA:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA3BC:  .byte $18, $09                   ;Play note C4  for 9 frames.
LA3BE:  .byte CHN_ASR, $1D               ;Set ASR data index to 29.
LA3C0:  .byte $12, $09                   ;Play note F#3 for 9 frames.
LA3C2:  .byte $12, $09                   ;Play note F#3 for 9 frames.
LA3C4:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA3C6:  .byte $12, $09                   ;Play note F#3 for 9 frames.
LA3C8:  .byte $18, $09                   ;Play note C4  for 9 frames.
LA3CA:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA3CC:  .byte CHN_SILENCE, $09           ;Silence channel for 9 frames.
LA3CE:  .byte $1B, $12                   ;Play note D#4 for 18 frames.
LA3D0:  .byte $1B, $09                   ;Play note D#4 for 9 frames.
LA3D2:  .byte $1A, $09                   ;Play note D4  for 9 frames.
LA3D4:  .byte $18, $09                   ;Play note C4  for 9 frames.
LA3D6:  .byte $1A, $09                   ;Play note D4  for 9 frames.
LA3D8:  .byte $1B, $09                   ;Play note D#4 for 9 frames.
LA3DA:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
LA3DC:  .byte $12, $09                   ;Play note F#3 for 9 frames.
LA3DE:  .byte $12, $09                   ;Play note F#3 for 9 frames.
LA3E0:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA3E2:  .byte $12, $09                   ;Play note F#3 for 9 frames.
LA3E4:  .byte $18, $09                   ;Play note C4  for 9 frames.
LA3E6:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA3E8:  .byte CHN_SILENCE, $09           ;Silence channel for 9 frames.
LA3EA:  .byte $1B, $12                   ;Play note D#4 for 18 frames.
LA3EC:  .byte $1B, $09                   ;Play note D#4 for 9 frames.
LA3EE:  .byte $1A, $09                   ;Play note D4  for 9 frames.
LA3F0:  .byte $18, $09                   ;Play note C4  for 9 frames.
LA3F2:  .byte $1A, $09                   ;Play note D4  for 9 frames.
LA3F4:  .byte $1B, $09                   ;Play note D#4 for 9 frames.
LA3F6:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
LA3F8:  .byte $12, $09                   ;Play note F#3 for 9 frames.
LA3FA:  .byte $12, $09                   ;Play note F#3 for 9 frames.
LA3FC:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA3FE:  .byte $12, $09                   ;Play note F#3 for 9 frames.
LA400:  .byte $18, $09                   ;Play note C4  for 9 frames.
LA402:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA404:  .byte CHN_SILENCE, $09           ;Silence channel for 9 frames.
LA406:  .byte $1B, $12                   ;Play note D#4 for 18 frames.
LA408:  .byte $1B, $09                   ;Play note D#4 for 9 frames.
LA40A:  .byte $1A, $09                   ;Play note D4  for 9 frames.
LA40C:  .byte $18, $09                   ;Play note C4  for 9 frames.
LA40E:  .byte $1A, $09                   ;Play note D4  for 9 frames.
LA410:  .byte $1B, $09                   ;Play note D#4 for 9 frames.
LA412:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
LA414:  .byte $12, $09                   ;Play note F#3 for 9 frames.
LA416:  .byte $12, $09                   ;Play note F#3 for 9 frames.
LA418:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA41A:  .byte $12, $09                   ;Play note F#3 for 9 frames.
LA41C:  .byte $18, $09                   ;Play note C4  for 9 frames.
LA41E:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA420:  .byte CHN_SILENCE, $09           ;Silence channel for 9 frames.
LA422:  .byte $1B, $12                   ;Play note D#4 for 18 frames.
LA424:  .byte $1B, $09                   ;Play note D#4 for 9 frames.
LA426:  .byte $1A, $09                   ;Play note D4  for 9 frames.
LA428:  .byte $18, $09                   ;Play note C4  for 9 frames.
LA42A:  .byte $1A, $09                   ;Play note D4  for 9 frames.
LA42C:  .byte $1B, $09                   ;Play note D#4 for 9 frames.
LA42E:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
LA430:  .byte CHN_JUMP, $00, $2E, $FF    ;Jump back 210 bytes to $A35E.

;----------------------------------------------------------------------------------------------------

;Fight music SQ2 data.

FightSQ2:
LA434:  .byte CHN_VOLUME, $0D            ;Set channel volume to 13.
LA436:  .byte CHN_VIBRATO, $00, $08, $18 ;Set vibrato speed=8, intensity=24.
LA43A:  .byte CHN_ASR, $1A               ;Set ASR data index to 26.
LA43C:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA43E:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA440:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
LA442:  .byte $1C, $12                   ;Play note E4  for 18 frames.
LA444:  .byte $1B, $09                   ;Play note D#4 for 9 frames.
LA446:  .byte $1A, $09                   ;Play note D4  for 9 frames.
LA448:  .byte CHN_SILENCE, $24           ;Silence channel for 36 frames.
LA44A:  .byte CHN_SILENCE, $09           ;Silence channel for 9 frames.
LA44C:  .byte $13, $09                   ;Play note G3  for 9 frames.
LA44E:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA450:  .byte $18, $09                   ;Play note C4  for 9 frames.
LA452:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA454:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA456:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
LA458:  .byte $1C, $12                   ;Play note E4  for 18 frames.
LA45A:  .byte $1B, $09                   ;Play note D#4 for 9 frames.
LA45C:  .byte $1A, $09                   ;Play note D4  for 9 frames.
LA45E:  .byte CHN_SILENCE, $24           ;Silence channel for 36 frames.
LA460:  .byte CHN_SILENCE, $09           ;Silence channel for 9 frames.
LA462:  .byte $13, $09                   ;Play note G3  for 9 frames.
LA464:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA466:  .byte $18, $09                   ;Play note C4  for 9 frames.
LA468:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA46A:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA46C:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
LA46E:  .byte $1C, $12                   ;Play note E4  for 18 frames.
LA470:  .byte $1B, $09                   ;Play note D#4 for 9 frames.
LA472:  .byte $1A, $09                   ;Play note D4  for 9 frames.
LA474:  .byte CHN_SILENCE, $24           ;Silence channel for 36 frames.
LA476:  .byte CHN_SILENCE, $09           ;Silence channel for 9 frames.
LA478:  .byte $13, $09                   ;Play note G3  for 9 frames.
LA47A:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA47C:  .byte $18, $09                   ;Play note C4  for 9 frames.
LA47E:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA480:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA482:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
LA484:  .byte $1C, $12                   ;Play note E4  for 18 frames.
LA486:  .byte $1B, $09                   ;Play note D#4 for 9 frames.
LA488:  .byte $1A, $09                   ;Play note D4  for 9 frames.
LA48A:  .byte CHN_SILENCE, $24           ;Silence channel for 36 frames.
LA48C:  .byte CHN_SILENCE, $09           ;Silence channel for 9 frames.
LA48E:  .byte $13, $09                   ;Play note G3  for 9 frames.
LA490:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA492:  .byte $18, $09                   ;Play note C4  for 9 frames.
LA494:  .byte CHN_ASR, $1C               ;Set ASR data index to 28.
LA496:  .byte $12, $09                   ;Play note F#3 for 9 frames.
LA498:  .byte $12, $09                   ;Play note F#3 for 9 frames.
LA49A:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA49C:  .byte $12, $09                   ;Play note F#3 for 9 frames.
LA49E:  .byte $18, $09                   ;Play note C4  for 9 frames.
LA4A0:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA4A2:  .byte CHN_SILENCE, $09           ;Silence channel for 9 frames.
LA4A4:  .byte $1B, $12                   ;Play note D#4 for 18 frames.
LA4A6:  .byte $1B, $09                   ;Play note D#4 for 9 frames.
LA4A8:  .byte $1A, $09                   ;Play note D4  for 9 frames.
LA4AA:  .byte $18, $09                   ;Play note C4  for 9 frames.
LA4AC:  .byte $1A, $09                   ;Play note D4  for 9 frames.
LA4AE:  .byte $1B, $09                   ;Play note D#4 for 9 frames.
LA4B0:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
LA4B2:  .byte $12, $09                   ;Play note F#3 for 9 frames.
LA4B4:  .byte $12, $09                   ;Play note F#3 for 9 frames.
LA4B6:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA4B8:  .byte $12, $09                   ;Play note F#3 for 9 frames.
LA4BA:  .byte $18, $09                   ;Play note C4  for 9 frames.
LA4BC:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA4BE:  .byte CHN_SILENCE, $09           ;Silence channel for 9 frames.
LA4C0:  .byte $1B, $12                   ;Play note D#4 for 18 frames.
LA4C2:  .byte $1B, $09                   ;Play note D#4 for 9 frames.
LA4C4:  .byte $1A, $09                   ;Play note D4  for 9 frames.
LA4C6:  .byte $18, $09                   ;Play note C4  for 9 frames.
LA4C8:  .byte $1A, $09                   ;Play note D4  for 9 frames.
LA4CA:  .byte $1B, $09                   ;Play note D#4 for 9 frames.
LA4CC:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
LA4CE:  .byte $12, $09                   ;Play note F#3 for 9 frames.
LA4D0:  .byte $12, $09                   ;Play note F#3 for 9 frames.
LA4D2:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA4D4:  .byte $12, $09                   ;Play note F#3 for 9 frames.
LA4D6:  .byte $18, $09                   ;Play note C4  for 9 frames.
LA4D8:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA4DA:  .byte CHN_SILENCE, $09           ;Silence channel for 9 frames.
LA4DC:  .byte $1B, $12                   ;Play note D#4 for 18 frames.
LA4DE:  .byte $1B, $09                   ;Play note D#4 for 9 frames.
LA4E0:  .byte $1A, $09                   ;Play note D4  for 9 frames.
LA4E2:  .byte $18, $09                   ;Play note C4  for 9 frames.
LA4E4:  .byte $1A, $09                   ;Play note D4  for 9 frames.
LA4E6:  .byte $1B, $09                   ;Play note D#4 for 9 frames.
LA4E8:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
LA4EA:  .byte $12, $09                   ;Play note F#3 for 9 frames.
LA4EC:  .byte $12, $09                   ;Play note F#3 for 9 frames.
LA4EE:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA4F0:  .byte $12, $09                   ;Play note F#3 for 9 frames.
LA4F2:  .byte $18, $09                   ;Play note C4  for 9 frames.
LA4F4:  .byte $15, $09                   ;Play note A3  for 9 frames.
LA4F6:  .byte CHN_SILENCE, $09           ;Silence channel for 9 frames.
LA4F8:  .byte $1B, $12                   ;Play note D#4 for 18 frames.
LA4FA:  .byte $1B, $09                   ;Play note D#4 for 9 frames.
LA4FC:  .byte $1A, $09                   ;Play note D4  for 9 frames.
LA4FE:  .byte $18, $09                   ;Play note C4  for 9 frames.
LA500:  .byte $1A, $09                   ;Play note D4  for 9 frames.
LA502:  .byte $1B, $09                   ;Play note D#4 for 9 frames.
LA504:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
LA506:  .byte CHN_JUMP, $00, $2E, $FF    ;Jump back 210 bytes to $A434.

;----------------------------------------------------------------------------------------------------

;Fight music Triangle data.

FightTri:
LA50A:  .byte CHN_VOLUME, $0F            ;Set channel volume to 15.
LA50C:  .byte CHN_VIBRATO, $00, $00, $00 ;Disable vibrato.
LA510:  .byte CHN_ASR, $1B               ;Set ASR data index to 27.
LA512:  .byte $09, $09                   ;Play note A1  for 9 frames.
LA514:  .byte $09, $09                   ;Play note A1  for 9 frames.
LA516:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
LA518:  .byte $10, $12                   ;Play note E2  for 18 frames.
LA51A:  .byte $0F, $09                   ;Play note D#2 for 9 frames.
LA51C:  .byte $0E, $09                   ;Play note D2  for 9 frames.
LA51E:  .byte CHN_SILENCE, $24           ;Silence channel for 36 frames.
LA520:  .byte CHN_SILENCE, $09           ;Silence channel for 9 frames.
LA522:  .byte $07, $09                   ;Play note G1  for 9 frames.
LA524:  .byte $09, $09                   ;Play note A1  for 9 frames.
LA526:  .byte $0C, $09                   ;Play note C2  for 9 frames.
LA528:  .byte $09, $09                   ;Play note A1  for 9 frames.
LA52A:  .byte $09, $09                   ;Play note A1  for 9 frames.
LA52C:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
LA52E:  .byte $10, $12                   ;Play note E2  for 18 frames.
LA530:  .byte $0F, $09                   ;Play note D#2 for 9 frames.
LA532:  .byte $0E, $09                   ;Play note D2  for 9 frames.
LA534:  .byte CHN_SILENCE, $24           ;Silence channel for 36 frames.
LA536:  .byte CHN_SILENCE, $09           ;Silence channel for 9 frames.
LA538:  .byte $07, $09                   ;Play note G1  for 9 frames.
LA53A:  .byte $09, $09                   ;Play note A1  for 9 frames.
LA53C:  .byte $0C, $09                   ;Play note C2  for 9 frames.
LA53E:  .byte $09, $09                   ;Play note A1  for 9 frames.
LA540:  .byte $09, $09                   ;Play note A1  for 9 frames.
LA542:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
LA544:  .byte $10, $12                   ;Play note E2  for 18 frames.
LA546:  .byte $0F, $09                   ;Play note D#2 for 9 frames.
LA548:  .byte $0E, $09                   ;Play note D2  for 9 frames.
LA54A:  .byte CHN_SILENCE, $24           ;Silence channel for 36 frames.
LA54C:  .byte CHN_SILENCE, $09           ;Silence channel for 9 frames.
LA54E:  .byte $07, $09                   ;Play note G1  for 9 frames.
LA550:  .byte $09, $09                   ;Play note A1  for 9 frames.
LA552:  .byte $0C, $09                   ;Play note C2  for 9 frames.
LA554:  .byte $09, $09                   ;Play note A1  for 9 frames.
LA556:  .byte $09, $09                   ;Play note A1  for 9 frames.
LA558:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
LA55A:  .byte $10, $12                   ;Play note E2  for 18 frames.
LA55C:  .byte $0F, $09                   ;Play note D#2 for 9 frames.
LA55E:  .byte $0E, $09                   ;Play note D2  for 9 frames.
LA560:  .byte CHN_SILENCE, $24           ;Silence channel for 36 frames.
LA562:  .byte CHN_SILENCE, $09           ;Silence channel for 9 frames.
LA564:  .byte $07, $09                   ;Play note G1  for 9 frames.
LA566:  .byte $09, $09                   ;Play note A1  for 9 frames.
LA568:  .byte $0C, $09                   ;Play note C2  for 9 frames.
LA56A:  .byte $06, $09                   ;Play note F#1 for 9 frames.
LA56C:  .byte $06, $09                   ;Play note F#1 for 9 frames.
LA56E:  .byte $09, $09                   ;Play note A1  for 9 frames.
LA570:  .byte $06, $09                   ;Play note F#1 for 9 frames.
LA572:  .byte $0C, $09                   ;Play note C2  for 9 frames.
LA574:  .byte $09, $09                   ;Play note A1  for 9 frames.
LA576:  .byte CHN_SILENCE, $09           ;Silence channel for 9 frames.
LA578:  .byte $0F, $12                   ;Play note D#2 for 18 frames.
LA57A:  .byte $0F, $09                   ;Play note D#2 for 9 frames.
LA57C:  .byte $0E, $09                   ;Play note D2  for 9 frames.
LA57E:  .byte $0C, $09                   ;Play note C2  for 9 frames.
LA580:  .byte $0E, $09                   ;Play note D2  for 9 frames.
LA582:  .byte $0F, $09                   ;Play note D#2 for 9 frames.
LA584:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
LA586:  .byte $06, $09                   ;Play note F#1 for 9 frames.
LA588:  .byte $06, $09                   ;Play note F#1 for 9 frames.
LA58A:  .byte $09, $09                   ;Play note A1  for 9 frames.
LA58C:  .byte $06, $09                   ;Play note F#1 for 9 frames.
LA58E:  .byte $0C, $09                   ;Play note C2  for 9 frames.
LA590:  .byte $09, $09                   ;Play note A1  for 9 frames.
LA592:  .byte CHN_SILENCE, $09           ;Silence channel for 9 frames.
LA594:  .byte $0F, $12                   ;Play note D#2 for 18 frames.
LA596:  .byte $0F, $09                   ;Play note D#2 for 9 frames.
LA598:  .byte $0E, $09                   ;Play note D2  for 9 frames.
LA59A:  .byte $0C, $09                   ;Play note C2  for 9 frames.
LA59C:  .byte $0E, $09                   ;Play note D2  for 9 frames.
LA59E:  .byte $0F, $09                   ;Play note D#2 for 9 frames.
LA5A0:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
LA5A2:  .byte $06, $09                   ;Play note F#1 for 9 frames.
LA5A4:  .byte $06, $09                   ;Play note F#1 for 9 frames.
LA5A6:  .byte $09, $09                   ;Play note A1  for 9 frames.
LA5A8:  .byte $06, $09                   ;Play note F#1 for 9 frames.
LA5AA:  .byte $0C, $09                   ;Play note C2  for 9 frames.
LA5AC:  .byte $09, $09                   ;Play note A1  for 9 frames.
LA5AE:  .byte CHN_SILENCE, $09           ;Silence channel for 9 frames.
LA5B0:  .byte $0F, $12                   ;Play note D#2 for 18 frames.
LA5B2:  .byte $0F, $09                   ;Play note D#2 for 9 frames.
LA5B4:  .byte $0E, $09                   ;Play note D2  for 9 frames.
LA5B6:  .byte $0C, $09                   ;Play note C2  for 9 frames.
LA5B8:  .byte $0E, $09                   ;Play note D2  for 9 frames.
LA5BA:  .byte $0F, $09                   ;Play note D#2 for 9 frames.
LA5BC:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
LA5BE:  .byte $06, $09                   ;Play note F#1 for 9 frames.
LA5C0:  .byte $06, $09                   ;Play note F#1 for 9 frames.
LA5C2:  .byte $09, $09                   ;Play note A1  for 9 frames.
LA5C4:  .byte $06, $09                   ;Play note F#1 for 9 frames.
LA5C6:  .byte $0C, $09                   ;Play note C2  for 9 frames.
LA5C8:  .byte $09, $09                   ;Play note A1  for 9 frames.
LA5CA:  .byte CHN_SILENCE, $09           ;Silence channel for 9 frames.
LA5CC:  .byte $0F, $12                   ;Play note D#2 for 18 frames.
LA5CE:  .byte $0F, $09                   ;Play note D#2 for 9 frames.
LA5D0:  .byte $0E, $09                   ;Play note D2  for 9 frames.
LA5D2:  .byte $0C, $09                   ;Play note C2  for 9 frames.
LA5D4:  .byte $0E, $09                   ;Play note D2  for 9 frames.
LA5D6:  .byte $0F, $09                   ;Play note D#2 for 9 frames.
LA5D8:  .byte CHN_SILENCE, $12           ;Silence channel for 18 frames.
LA5DA:  .byte CHN_JUMP, $00, $30, $FF    ;Jump back 208 bytes to $A50A.

;----------------------------------------------------------------------------------------------------

;Used by Castle Exodus music SQ1.

SQ1Attack1E:
LA5DE:  .byte $04, $84, $88, $8C, $90

SQ1Sustain1E:
LA5E3:  .byte $23, $8E, $8C, $89, $8C, $8E, $8E, $8C, $89, $8C, $8E, $8E, $8C, $89, $8C, $8E
LA5F3:  .byte $8E, $8C, $89, $8C, $8E, $8E, $8C, $89, $8C, $8E, $8E, $8C, $89, $8C, $8E, $8E
LA603:  .byte $8C, $89, $8C, $8E

SQ1Release1E:
LA607:  .byte $08, $8C, $8A, $88, $88, $86, $86, $84, $82, $82

;----------------------------------------------------------------------------------------------------

;Used by Castle Exodus music SQ1.

SQ1Attack1F:
LA611:  .byte $04, $44, $48, $4C, $50

SQ1Sustain1F:
LA616:  .byte $23, $4E, $4C, $4E, $4C, $4E, $4E, $4C, $4E, $4C, $4E, $4E, $4C, $4E, $4C, $4E
LA626:  .byte $4E, $4C, $4E, $4C, $4E, $4E, $4C, $4E, $4C, $4E, $4E, $4C, $4E, $4C, $4E, $4E
LA636:  .byte $4C, $4E, $4C, $4E

SQ1Release1F:
LA63A:  .byte $08, $4C, $4A, $48, $48, $46, $46, $44, $42, $42

;----------------------------------------------------------------------------------------------------

;Used by Castle Exodus music SQ1.

SQ1Attack20:
LA644:  .byte $04, $C4, $C8, $CC, $D0

SQ1Sustain20:
LA649:  .byte $23, $CE, $CC, $C9, $CC, $CE, $CE, $CC, $C9, $CC, $CE, $CE, $CC, $C9, $CC, $CE
LA659:  .byte $CE, $CC, $C9, $CC, $CE, $CE, $CC, $C9, $CC, $CE, $CE, $CC, $C9, $CC, $CE, $CE
LA669:  .byte $CC, $C9, $CC, $CE

SQ1Release20:
LA66D:  .byte $08, $CC, $CA, $C8, $C8, $C6, $C6, $C4, $C2, $C2

;----------------------------------------------------------------------------------------------------

;Used by Castle Exodus music SQ1.

SQ1Attack21:
LA677:  .byte $07, $88, $8C, $90, $8E, $8C, $88, $86

SQ1Sustain21:
LA67F:  .byte $08, $88, $88, $88, $88, $88, $88, $88, $88

SQ1Release21:
LA688:  .byte $27, $88, $88, $88, $88, $87, $87, $87, $87, $87, $86, $86, $86, $86, $86, $86
LA698:  .byte $85, $85, $85, $85, $85, $85, $85, $84, $84, $84, $84, $84, $84, $84, $84, $83
LA6A8:  .byte $83, $83, $83, $83, $83, $83, $83, $82, $82

;----------------------------------------------------------------------------------------------------

;Used by Castle Exodus music SQ2.

SQ2Attack22:
LA6B1:  .byte $04, $84, $88, $8C, $90

SQ2Sustain22:
LA6B6:  .byte $1E, $8E, $8C, $8A, $8A, $8C, $8E, $8C, $8A, $8A, $8C, $8E, $8C, $8A, $8A, $8C
LA6C6:  .byte $8E, $8C, $8A, $8A, $8C, $8E, $8C, $8A, $8A, $8C, $8E, $8C, $8A, $8A, $8C

SQ2Release22:
LA6D5:  .byte $08, $8C, $8A, $88, $88, $86, $86, $84, $82, $82

;----------------------------------------------------------------------------------------------------

;Used by Castle Exodus music Triangle.

TriAttack23:
LA6DF:  .byte $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

TriSustain23:
LA6E8:  .byte $18, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
LA6F8:  .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

TriRelease23:
LA701:  .byte $08, $0F, $0F, $0F, $0F, $0F, $00, $00, $00, $00

;----------------------------------------------------------------------------------------------------

;Used by Castle Exodus music Triangle.

TriAttack24:
LA70B:  .byte $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

TriSustain24:
LA714:  .byte $10, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
LA724:  .byte $0F

TriRelease24:
LA725:  .byte $08, $00, $00, $00, $00, $00, $00, $00, $00, $00

;----------------------------------------------------------------------------------------------------
;Used by Castle Exodus music SQ2.

SQ2Attack25:
LA72F:  .byte $03, $88, $8C, $90

SQ2Sustain25:
LA733:  .byte $0A, $8E, $8C, $8A, $8A, $8C, $8E, $8C, $8A, $8A, $8C

SQ2Release25:
LA73E:  .byte $0B, $8C, $8A, $88, $88, $87, $86, $86, $85, $84, $84, $83, $83

;----------------------------------------------------------------------------------------------------

;Castle Exodus music SQ1 data.

ExodusSQ1:
LA74B:  .byte CHN_VOLUME, $0E            ;Set channel volume to 14.
LA74D:  .byte CHN_VIBRATO, $00, $0F, $18 ;Set vibrato speed=15, intensity=24.
LA751:  .byte CHN_ASR, $1E               ;Set ASR data index to 30.
LA753:  .byte $18, $30                   ;Play note C4  for 48 frames.
LA755:  .byte $1B, $30                   ;Play note D#4 for 48 frames.
LA757:  .byte $1D, $20                   ;Play note F4  for 32 frames.
LA759:  .byte $1B, $30                   ;Play note D#4 for 48 frames.
LA75B:  .byte $18, $10                   ;Play note C4  for 16 frames.
LA75D:  .byte CHN_SILENCE, $40           ;Silence channel for 64 frames.
LA75F:  .byte $18, $30                   ;Play note C4  for 48 frames.
LA761:  .byte $1B, $30                   ;Play note D#4 for 48 frames.
LA763:  .byte $1D, $20                   ;Play note F4  for 32 frames.
LA765:  .byte $1B, $30                   ;Play note D#4 for 48 frames.
LA767:  .byte $18, $10                   ;Play note C4  for 16 frames.
LA769:  .byte CHN_SILENCE, $40           ;Silence channel for 64 frames.
LA76B:  .byte CHN_ASR, $1F               ;Set ASR data index to 31.
LA76D:  .byte $18, $30                   ;Play note C4  for 48 frames.
LA76F:  .byte $1B, $30                   ;Play note D#4 for 48 frames.
LA771:  .byte $1D, $20                   ;Play note F4  for 32 frames.
LA773:  .byte $1B, $30                   ;Play note D#4 for 48 frames.
LA775:  .byte $18, $10                   ;Play note C4  for 16 frames.
LA777:  .byte CHN_SILENCE, $40           ;Silence channel for 64 frames.
LA779:  .byte $18, $30                   ;Play note C4  for 48 frames.
LA77B:  .byte $1B, $30                   ;Play note D#4 for 48 frames.
LA77D:  .byte $1D, $20                   ;Play note F4  for 32 frames.
LA77F:  .byte $1B, $30                   ;Play note D#4 for 48 frames.
LA781:  .byte $18, $10                   ;Play note C4  for 16 frames.
LA783:  .byte CHN_SILENCE, $20           ;Silence channel for 32 frames.
LA785:  .byte $1F, $08                   ;Play note G4  for 8 frames.
LA787:  .byte $1D, $08                   ;Play note F4  for 8 frames.
LA789:  .byte $1B, $08                   ;Play note D#4 for 8 frames.
LA78B:  .byte $18, $08                   ;Play note C4  for 8 frames.
LA78D:  .byte CHN_VIBRATO, $00, $10, $30 ;Set vibrato speed=16, intensity=48.
LA791:  .byte CHN_ASR, $20               ;Set ASR data index to 32.
LA793:  .byte $22, $30                   ;Play note A#4 for 48 frames.
LA795:  .byte $21, $10                   ;Play note A4  for 16 frames.
LA797:  .byte CHN_SILENCE, $20           ;Silence channel for 32 frames.
LA799:  .byte $1F, $30                   ;Play note G4  for 48 frames.
LA79B:  .byte $1D, $10                   ;Play note F4  for 16 frames.
LA79D:  .byte CHN_SILENCE, $20           ;Silence channel for 32 frames.
LA79F:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA7A1:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA7A3:  .byte $1B, $08                   ;Play note D#4 for 8 frames.
LA7A5:  .byte $1D, $08                   ;Play note F4  for 8 frames.
LA7A7:  .byte $1F, $10                   ;Play note G4  for 16 frames.
LA7A9:  .byte $22, $30                   ;Play note A#4 for 48 frames.
LA7AB:  .byte $21, $10                   ;Play note A4  for 16 frames.
LA7AD:  .byte CHN_SILENCE, $20           ;Silence channel for 32 frames.
LA7AF:  .byte $1F, $30                   ;Play note G4  for 48 frames.
LA7B1:  .byte $1D, $10                   ;Play note F4  for 16 frames.
LA7B3:  .byte CHN_SILENCE, $20           ;Silence channel for 32 frames.
LA7B5:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA7B7:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA7B9:  .byte $1B, $08                   ;Play note D#4 for 8 frames.
LA7BB:  .byte $1D, $08                   ;Play note F4  for 8 frames.
LA7BD:  .byte $1F, $10                   ;Play note G4  for 16 frames.
LA7BF:  .byte CHN_VIBRATO, $00, $08, $04 ;Set vibrato speed=8, intensity=4.
LA7C3:  .byte CHN_ASR, $21               ;Set ASR data index to 33.
LA7C5:  .byte CHN_VOLUME, $0F            ;Set channel volume to 15.
LA7C7:  .byte $1B, $20                   ;Play note D#4 for 32 frames.
LA7C9:  .byte $18, $10                   ;Play note C4  for 16 frames.
LA7CB:  .byte $1D, $40                   ;Play note F4  for 64 frames.
LA7CD:  .byte $18, $10                   ;Play note C4  for 16 frames.
LA7CF:  .byte $1B, $20                   ;Play note D#4 for 32 frames.
LA7D1:  .byte $18, $10                   ;Play note C4  for 16 frames.
LA7D3:  .byte $1D, $50                   ;Play note F4  for 80 frames.
LA7D5:  .byte $1B, $20                   ;Play note D#4 for 32 frames.
LA7D7:  .byte $18, $10                   ;Play note C4  for 16 frames.
LA7D9:  .byte $1D, $40                   ;Play note F4  for 64 frames.
LA7DB:  .byte $18, $10                   ;Play note C4  for 16 frames.
LA7DD:  .byte $1B, $20                   ;Play note D#4 for 32 frames.
LA7DF:  .byte $18, $10                   ;Play note C4  for 16 frames.
LA7E1:  .byte $1D, $50                   ;Play note F4  for 80 frames.
LA7E3:  .byte $1B, $20                   ;Play note D#4 for 32 frames.
LA7E5:  .byte $18, $10                   ;Play note C4  for 16 frames.
LA7E7:  .byte $1D, $40                   ;Play note F4  for 64 frames.
LA7E9:  .byte $18, $10                   ;Play note C4  for 16 frames.
LA7EB:  .byte $1B, $20                   ;Play note D#4 for 32 frames.
LA7ED:  .byte $18, $10                   ;Play note C4  for 16 frames.
LA7EF:  .byte $1D, $50                   ;Play note F4  for 80 frames.
LA7F1:  .byte $1B, $20                   ;Play note D#4 for 32 frames.
LA7F3:  .byte $18, $10                   ;Play note C4  for 16 frames.
LA7F5:  .byte $1D, $40                   ;Play note F4  for 64 frames.
LA7F7:  .byte $18, $10                   ;Play note C4  for 16 frames.
LA7F9:  .byte $1B, $20                   ;Play note D#4 for 32 frames.
LA7FB:  .byte $18, $10                   ;Play note C4  for 16 frames.
LA7FD:  .byte $1D, $50                   ;Play note F4  for 80 frames.
LA7FF:  .byte CHN_JUMP, $00, $4C, $FF    ;Jump back 180 bytes to $A74B.

;----------------------------------------------------------------------------------------------------

;Castle Exodus music SQ2 data.

ExodusSQ2:
LA803:  .byte CHN_VOLUME, $0E            ;Set channel volume to 14.
LA805:  .byte CHN_VIBRATO, $00, $1D, $12 ;Set vibrato speed=29, intensity=18.
LA809:  .byte CHN_ASR, $22               ;Set ASR data index to 34.
LA80B:  .byte $18, $30                   ;Play note C4  for 48 frames.
LA80D:  .byte $1B, $30                   ;Play note D#4 for 48 frames.
LA80F:  .byte $1D, $20                   ;Play note F4  for 32 frames.
LA811:  .byte $1B, $30                   ;Play note D#4 for 48 frames.
LA813:  .byte $18, $10                   ;Play note C4  for 16 frames.
LA815:  .byte CHN_SILENCE, $40           ;Silence channel for 64 frames.
LA817:  .byte $18, $30                   ;Play note C4  for 48 frames.
LA819:  .byte $1B, $30                   ;Play note D#4 for 48 frames.
LA81B:  .byte $1D, $20                   ;Play note F4  for 32 frames.
LA81D:  .byte $1B, $30                   ;Play note D#4 for 48 frames.
LA81F:  .byte $18, $10                   ;Play note C4  for 16 frames.
LA821:  .byte CHN_SILENCE, $40           ;Silence channel for 64 frames.
LA823:  .byte $18, $30                   ;Play note C4  for 48 frames.
LA825:  .byte $1B, $30                   ;Play note D#4 for 48 frames.
LA827:  .byte $1D, $20                   ;Play note F4  for 32 frames.
LA829:  .byte $1B, $30                   ;Play note D#4 for 48 frames.
LA82B:  .byte $18, $10                   ;Play note C4  for 16 frames.
LA82D:  .byte CHN_SILENCE, $40           ;Silence channel for 64 frames.
LA82F:  .byte $18, $30                   ;Play note C4  for 48 frames.
LA831:  .byte $1B, $30                   ;Play note D#4 for 48 frames.
LA833:  .byte $1D, $20                   ;Play note F4  for 32 frames.
LA835:  .byte $1B, $30                   ;Play note D#4 for 48 frames.
LA837:  .byte $18, $10                   ;Play note C4  for 16 frames.
LA839:  .byte CHN_SILENCE, $20           ;Silence channel for 32 frames.
LA83B:  .byte $1F, $08                   ;Play note G4  for 8 frames.
LA83D:  .byte $1D, $08                   ;Play note F4  for 8 frames.
LA83F:  .byte $1B, $08                   ;Play note D#4 for 8 frames.
LA841:  .byte $18, $08                   ;Play note C4  for 8 frames.
LA843:  .byte $1F, $30                   ;Play note G4  for 48 frames.
LA845:  .byte $1D, $10                   ;Play note F4  for 16 frames.
LA847:  .byte CHN_SILENCE, $20           ;Silence channel for 32 frames.
LA849:  .byte $1B, $30                   ;Play note D#4 for 48 frames.
LA84B:  .byte $1A, $10                   ;Play note D4  for 16 frames.
LA84D:  .byte CHN_SILENCE, $20           ;Silence channel for 32 frames.
LA84F:  .byte $18, $10                   ;Play note C4  for 16 frames.
LA851:  .byte $18, $10                   ;Play note C4  for 16 frames.
LA853:  .byte $18, $08                   ;Play note C4  for 8 frames.
LA855:  .byte $1A, $08                   ;Play note D4  for 8 frames.
LA857:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA859:  .byte $1F, $30                   ;Play note G4  for 48 frames.
LA85B:  .byte $1D, $10                   ;Play note F4  for 16 frames.
LA85D:  .byte CHN_SILENCE, $20           ;Silence channel for 32 frames.
LA85F:  .byte $1B, $30                   ;Play note D#4 for 48 frames.
LA861:  .byte $1A, $10                   ;Play note D4  for 16 frames.
LA863:  .byte CHN_SILENCE, $20           ;Silence channel for 32 frames.
LA865:  .byte $18, $10                   ;Play note C4  for 16 frames.
LA867:  .byte $18, $10                   ;Play note C4  for 16 frames.
LA869:  .byte $18, $08                   ;Play note C4  for 8 frames.
LA86B:  .byte $1A, $08                   ;Play note D4  for 8 frames.
LA86D:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA86F:  .byte CHN_VIBRATO, $00, $08, $30 ;Set vibrato speed=8, intensity=48.
LA873:  .byte CHN_VOLUME, $0A            ;Set channel volume to 10.
LA875:  .byte CHN_ASR, $25               ;Set ASR data index to 37.
LA877:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA879:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA87B:  .byte $1F, $10                   ;Play note G4  for 16 frames.
LA87D:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA87F:  .byte $1D, $10                   ;Play note F4  for 16 frames.
LA881:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA883:  .byte $1A, $10                   ;Play note D4  for 16 frames.
LA885:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA887:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA889:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA88B:  .byte $1F, $10                   ;Play note G4  for 16 frames.
LA88D:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA88F:  .byte $1D, $10                   ;Play note F4  for 16 frames.
LA891:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA893:  .byte $18, $08                   ;Play note C4  for 8 frames.
LA895:  .byte $1A, $08                   ;Play note D4  for 8 frames.
LA897:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA899:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA89B:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA89D:  .byte $1F, $10                   ;Play note G4  for 16 frames.
LA89F:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8A1:  .byte $1D, $10                   ;Play note F4  for 16 frames.
LA8A3:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8A5:  .byte $1A, $10                   ;Play note D4  for 16 frames.
LA8A7:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8A9:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8AB:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8AD:  .byte $1F, $10                   ;Play note G4  for 16 frames.
LA8AF:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8B1:  .byte $1D, $10                   ;Play note F4  for 16 frames.
LA8B3:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8B5:  .byte $18, $08                   ;Play note C4  for 8 frames.
LA8B7:  .byte $1A, $08                   ;Play note D4  for 8 frames.
LA8B9:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8BB:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8BD:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8BF:  .byte $1F, $10                   ;Play note G4  for 16 frames.
LA8C1:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8C3:  .byte $1D, $10                   ;Play note F4  for 16 frames.
LA8C5:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8C7:  .byte $1A, $10                   ;Play note D4  for 16 frames.
LA8C9:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8CB:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8CD:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8CF:  .byte $1F, $10                   ;Play note G4  for 16 frames.
LA8D1:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8D3:  .byte $1D, $10                   ;Play note F4  for 16 frames.
LA8D5:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8D7:  .byte $18, $08                   ;Play note C4  for 8 frames.
LA8D9:  .byte $1A, $08                   ;Play note D4  for 8 frames.
LA8DB:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8DD:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8DF:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8E1:  .byte $1F, $10                   ;Play note G4  for 16 frames.
LA8E3:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8E5:  .byte $1D, $10                   ;Play note F4  for 16 frames.
LA8E7:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8E9:  .byte $1A, $10                   ;Play note D4  for 16 frames.
LA8EB:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8ED:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8EF:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8F1:  .byte $1F, $10                   ;Play note G4  for 16 frames.
LA8F3:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8F5:  .byte $1D, $10                   ;Play note F4  for 16 frames.
LA8F7:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8F9:  .byte $18, $08                   ;Play note C4  for 8 frames.
LA8FB:  .byte $1A, $08                   ;Play note D4  for 8 frames.
LA8FD:  .byte $1B, $10                   ;Play note D#4 for 16 frames.
LA8FF:  .byte CHN_JUMP, $00, $04, $FF    ;Jump back 252 bytes to $A803.

;----------------------------------------------------------------------------------------------------

;Castle Exodus music SQ1 data.

ExodusTri:
LA903:  .byte CHN_VOLUME, $0F            ;Set channel volume to 15.
LA905:  .byte CHN_VIBRATO, $00, $10, $10 ;Set vibrato speed=16, intensity=16.
LA909:  .byte CHN_ASR, $23               ;Set ASR data index to 35.
LA90B:  .byte $0C, $30                   ;Play note C2  for 48 frames.
LA90D:  .byte $0F, $30                   ;Play note D#2 for 48 frames.
LA90F:  .byte $11, $20                   ;Play note F2  for 32 frames.
LA911:  .byte $0F, $30                   ;Play note D#2 for 48 frames.
LA913:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA915:  .byte CHN_SILENCE, $40           ;Silence channel for 64 frames.
LA917:  .byte $0C, $30                   ;Play note C2  for 48 frames.
LA919:  .byte $0F, $30                   ;Play note D#2 for 48 frames.
LA91B:  .byte $11, $20                   ;Play note F2  for 32 frames.
LA91D:  .byte $0F, $30                   ;Play note D#2 for 48 frames.
LA91F:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA921:  .byte CHN_SILENCE, $40           ;Silence channel for 64 frames.
LA923:  .byte $0C, $30                   ;Play note C2  for 48 frames.
LA925:  .byte $0F, $30                   ;Play note D#2 for 48 frames.
LA927:  .byte $11, $20                   ;Play note F2  for 32 frames.
LA929:  .byte $0F, $30                   ;Play note D#2 for 48 frames.
LA92B:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA92D:  .byte CHN_SILENCE, $40           ;Silence channel for 64 frames.
LA92F:  .byte $0C, $30                   ;Play note C2  for 48 frames.
LA931:  .byte $0F, $30                   ;Play note D#2 for 48 frames.
LA933:  .byte $11, $20                   ;Play note F2  for 32 frames.
LA935:  .byte $0F, $30                   ;Play note D#2 for 48 frames.
LA937:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA939:  .byte CHN_SILENCE, $20           ;Silence channel for 32 frames.
LA93B:  .byte $13, $08                   ;Play note G2  for 8 frames.
LA93D:  .byte $11, $08                   ;Play note F2  for 8 frames.
LA93F:  .byte $0F, $08                   ;Play note D#2 for 8 frames.
LA941:  .byte $0C, $08                   ;Play note C2  for 8 frames.
LA943:  .byte CHN_VIBRATO, $00, $02, $20 ;Set vibrato speed=2, intensity=32.
LA947:  .byte CHN_ASR, $24               ;Set ASR data index to 36.
LA949:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA94B:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA94D:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA94F:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA951:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA953:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA955:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA957:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA959:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA95B:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA95D:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA95F:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA961:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA963:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA965:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA967:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA969:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA96B:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA96D:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA96F:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA971:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA973:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA975:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA977:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA979:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA97B:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA97D:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA97F:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA981:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA983:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA985:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA987:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA989:  .byte CHN_VIBRATO, $00, $0A, $20 ;Set vibrato speed=10, intensity=32.
LA98D:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA98F:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA991:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA993:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA995:  .byte $0F, $10                   ;Play note D#2 for 16 frames.
LA997:  .byte $11, $20                   ;Play note F2  for 32 frames.
LA999:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA99B:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA99D:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA99F:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9A1:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9A3:  .byte $0F, $10                   ;Play note D#2 for 16 frames.
LA9A5:  .byte $11, $20                   ;Play note F2  for 32 frames.
LA9A7:  .byte $0A, $10                   ;Play note A#1 for 16 frames.
LA9A9:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9AB:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9AD:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9AF:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9B1:  .byte $0F, $10                   ;Play note D#2 for 16 frames.
LA9B3:  .byte $11, $20                   ;Play note F2  for 32 frames.
LA9B5:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9B7:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9B9:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9BB:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9BD:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9BF:  .byte $0F, $10                   ;Play note D#2 for 16 frames.
LA9C1:  .byte $11, $20                   ;Play note F2  for 32 frames.
LA9C3:  .byte $0A, $10                   ;Play note A#1 for 16 frames.
LA9C5:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9C7:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9C9:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9CB:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9CD:  .byte $0F, $10                   ;Play note D#2 for 16 frames.
LA9CF:  .byte $11, $20                   ;Play note F2  for 32 frames.
LA9D1:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9D3:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9D5:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9D7:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9D9:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9DB:  .byte $0F, $10                   ;Play note D#2 for 16 frames.
LA9DD:  .byte $11, $20                   ;Play note F2  for 32 frames.
LA9DF:  .byte $0A, $10                   ;Play note A#1 for 16 frames.
LA9E1:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9E3:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9E5:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9E7:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9E9:  .byte $0F, $10                   ;Play note D#2 for 16 frames.
LA9EB:  .byte $11, $20                   ;Play note F2  for 32 frames.
LA9ED:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9EF:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9F1:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9F3:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9F5:  .byte $0C, $10                   ;Play note C2  for 16 frames.
LA9F7:  .byte $0F, $10                   ;Play note D#2 for 16 frames.
LA9F9:  .byte $11, $20                   ;Play note F2  for 32 frames.
LA9FB:  .byte $0A, $10                   ;Play note A#1 for 16 frames.
LA9FD:  .byte CHN_JUMP, $00, $06, $FF    ;Jump back 250 bytes to $A903.

;----------------------------------------------------------------------------------------------------

;Uses in Unused Theme music SQ1.

SQ1Attack26:
LAA01:  .byte $03, $8C, $90, $8D

SQ1Sustain26:
LAA05:  .byte $03, $87, $88, $88

SQ1Release26:
LAA09:  .byte $08, $87, $86, $86, $85, $85, $84, $84, $83, $83

;----------------------------------------------------------------------------------------------------

;Uses in Unused Theme music SQ2.

SQ2Attack27:
LAA13:  .byte $06, $86, $90, $8D, $8A, $85, $86

SQ2Sustain27:
LAA1A:  .byte $04, $87, $87, $87, $87

SQ2Release27:
LAA1F:  .byte $0D, $86, $86, $86, $86, $85, $85, $85, $85, $84, $84, $84, $84, $83, $83

;----------------------------------------------------------------------------------------------------

;Uses in Unused Theme music Triangle.

TriAttack28:
LAA2E:  .byte $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

TriSustain28:
LAA37:  .byte $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

TriRelease28:
LAA40:  .byte $10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAA50:  .byte $00, $00

;----------------------------------------------------------------------------------------------------

;Unused theme music SQ1 data.

UnusedSQ1:
LAA52:  .byte CHN_VOLUME, $0E            ;Set channel volume to 14.
LAA54:  .byte CHN_VIBRATO, $00, $0A, $28 ;Set vibrato speed=10, intensity=40.
LAA58:  .byte CHN_ASR, $26               ;Set ASR data index to 38.
LAA5A:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
LAA5C:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAA5E:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAA60:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAA62:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAA64:  .byte $1F, $1C                   ;Play note G4  for 28 frames.
LAA66:  .byte $21, $1C                   ;Play note A4  for 28 frames.
LAA68:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAA6A:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAA6C:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAA6E:  .byte $22, $07                   ;Play note A#4 for 7 frames.
LAA70:  .byte $24, $07                   ;Play note C5  for 7 frames.
LAA72:  .byte $26, $0E                   ;Play note D5  for 14 frames.
LAA74:  .byte $24, $0E                   ;Play note C5  for 14 frames.
LAA76:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAA78:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
LAA7A:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAA7C:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAA7E:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAA80:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAA82:  .byte $1F, $1C                   ;Play note G4  for 28 frames.
LAA84:  .byte $21, $1C                   ;Play note A4  for 28 frames.
LAA86:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAA88:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAA8A:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAA8C:  .byte $22, $07                   ;Play note A#4 for 7 frames.
LAA8E:  .byte $24, $07                   ;Play note C5  for 7 frames.
LAA90:  .byte $26, $0E                   ;Play note D5  for 14 frames.
LAA92:  .byte $24, $0E                   ;Play note C5  for 14 frames.
LAA94:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAA96:  .byte $24, $0E                   ;Play note C5  for 14 frames.
LAA98:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAA9A:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAA9C:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAA9E:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAAA0:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAAA2:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAAA4:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAAA6:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAAA8:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LAAAA:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LAAAC:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LAAAE:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAAB0:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LAAB2:  .byte $1F, $07                   ;Play note G4  for 7 frames.
LAAB4:  .byte $21, $07                   ;Play note A4  for 7 frames.
LAAB6:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAAB8:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAABA:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAABC:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAABE:  .byte $22, $2A                   ;Play note A#4 for 42 frames.
LAAC0:  .byte $1F, $2A                   ;Play note G4  for 42 frames.
LAAC2:  .byte $1C, $07                   ;Play note E4  for 7 frames.
LAAC4:  .byte $1D, $07                   ;Play note F4  for 7 frames.
LAAC6:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LAAC8:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LAACA:  .byte $1D, $07                   ;Play note F4  for 7 frames.
LAACC:  .byte $1F, $07                   ;Play note G4  for 7 frames.
LAACE:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAAD0:  .byte $1F, $07                   ;Play note G4  for 7 frames.
LAAD2:  .byte $21, $07                   ;Play note A4  for 7 frames.
LAAD4:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAAD6:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
LAAD8:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAADA:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAADC:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAADE:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAAE0:  .byte $1F, $1C                   ;Play note G4  for 28 frames.
LAAE2:  .byte $21, $1C                   ;Play note A4  for 28 frames.
LAAE4:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAAE6:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAAE8:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAAEA:  .byte $22, $07                   ;Play note A#4 for 7 frames.
LAAEC:  .byte $24, $07                   ;Play note C5  for 7 frames.
LAAEE:  .byte $26, $0E                   ;Play note D5  for 14 frames.
LAAF0:  .byte $24, $0E                   ;Play note C5  for 14 frames.
LAAF2:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAAF4:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
LAAF6:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAAF8:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAAFA:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAAFC:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAAFE:  .byte $1F, $1C                   ;Play note G4  for 28 frames.
LAB00:  .byte $21, $1C                   ;Play note A4  for 28 frames.
LAB02:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAB04:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAB06:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAB08:  .byte $22, $07                   ;Play note A#4 for 7 frames.
LAB0A:  .byte $24, $07                   ;Play note C5  for 7 frames.
LAB0C:  .byte $26, $0E                   ;Play note D5  for 14 frames.
LAB0E:  .byte $24, $0E                   ;Play note C5  for 14 frames.
LAB10:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAB12:  .byte $24, $0E                   ;Play note C5  for 14 frames.
LAB14:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAB16:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAB18:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAB1A:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAB1C:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAB1E:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAB20:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAB22:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAB24:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LAB26:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LAB28:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LAB2A:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAB2C:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LAB2E:  .byte $1F, $07                   ;Play note G4  for 7 frames.
LAB30:  .byte $21, $07                   ;Play note A4  for 7 frames.
LAB32:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAB34:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAB36:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAB38:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAB3A:  .byte $22, $2A                   ;Play note A#4 for 42 frames.
LAB3C:  .byte $1F, $2A                   ;Play note G4  for 42 frames.
LAB3E:  .byte $1C, $07                   ;Play note E4  for 7 frames.
LAB40:  .byte $1D, $07                   ;Play note F4  for 7 frames.
LAB42:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LAB44:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LAB46:  .byte $1D, $07                   ;Play note F4  for 7 frames.
LAB48:  .byte $1F, $07                   ;Play note G4  for 7 frames.
LAB4A:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAB4C:  .byte $1F, $07                   ;Play note G4  for 7 frames.
LAB4E:  .byte $21, $07                   ;Play note A4  for 7 frames.
LAB50:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAB52:  .byte CHN_JUMP, $00, $00, $FF    ;Jump back 256 bytes to $AA52.

;----------------------------------------------------------------------------------------------------

;Unused theme music SQ2 data.

UnusedSQ2:
LAB56:  .byte CHN_VOLUME, $0C            ;Set channel volume to 12.
LAB58:  .byte CHN_VIBRATO, $00, $0F, $30 ;Set vibrato speed=15, intensity=48.
LAB5C:  .byte CHN_ASR, $27               ;Set ASR data index to 39.
LAB5E:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
LAB60:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAB62:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAB64:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAB66:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAB68:  .byte $1C, $1C                   ;Play note E4  for 28 frames.
LAB6A:  .byte $1D, $1C                   ;Play note F4  for 28 frames.
LAB6C:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAB6E:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAB70:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAB72:  .byte $1F, $07                   ;Play note G4  for 7 frames.
LAB74:  .byte $21, $07                   ;Play note A4  for 7 frames.
LAB76:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAB78:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAB7A:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LAB7C:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
LAB7E:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAB80:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAB82:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAB84:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAB86:  .byte $1C, $1C                   ;Play note E4  for 28 frames.
LAB88:  .byte $1D, $1C                   ;Play note F4  for 28 frames.
LAB8A:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAB8C:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAB8E:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAB90:  .byte $1F, $07                   ;Play note G4  for 7 frames.
LAB92:  .byte $21, $07                   ;Play note A4  for 7 frames.
LAB94:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAB96:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAB98:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LAB9A:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAB9C:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LAB9E:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LABA0:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LABA2:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LABA4:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LABA6:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LABA8:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LABAA:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LABAC:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LABAE:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LABB0:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LABB2:  .byte $1A, $0E                   ;Play note D4  for 14 frames.
LABB4:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LABB6:  .byte $1C, $07                   ;Play note E4  for 7 frames.
LABB8:  .byte $1D, $07                   ;Play note F4  for 7 frames.
LABBA:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LABBC:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LABBE:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LABC0:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LABC2:  .byte $1F, $2A                   ;Play note G4  for 42 frames.
LABC4:  .byte $1C, $2A                   ;Play note E4  for 42 frames.
LABC6:  .byte $18, $07                   ;Play note C4  for 7 frames.
LABC8:  .byte $1A, $07                   ;Play note D4  for 7 frames.
LABCA:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LABCC:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LABCE:  .byte $1A, $07                   ;Play note D4  for 7 frames.
LABD0:  .byte $1C, $07                   ;Play note E4  for 7 frames.
LABD2:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LABD4:  .byte $1A, $07                   ;Play note D4  for 7 frames.
LABD6:  .byte $1D, $07                   ;Play note F4  for 7 frames.
LABD8:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LABDA:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
LABDC:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LABDE:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LABE0:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LABE2:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LABE4:  .byte $1C, $1C                   ;Play note E4  for 28 frames.
LABE6:  .byte $1D, $1C                   ;Play note F4  for 28 frames.
LABE8:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LABEA:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LABEC:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LABEE:  .byte $1F, $07                   ;Play note G4  for 7 frames.
LABF0:  .byte $21, $07                   ;Play note A4  for 7 frames.
LABF2:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LABF4:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LABF6:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LABF8:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
LABFA:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LABFC:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LABFE:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAC00:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAC02:  .byte $1C, $1C                   ;Play note E4  for 28 frames.
LAC04:  .byte $1D, $1C                   ;Play note F4  for 28 frames.
LAC06:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAC08:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAC0A:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAC0C:  .byte $1F, $07                   ;Play note G4  for 7 frames.
LAC0E:  .byte $21, $07                   ;Play note A4  for 7 frames.
LAC10:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAC12:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAC14:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LAC16:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LAC18:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LAC1A:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LAC1C:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LAC1E:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LAC20:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAC22:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAC24:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAC26:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAC28:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LAC2A:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LAC2C:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LAC2E:  .byte $1A, $0E                   ;Play note D4  for 14 frames.
LAC30:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LAC32:  .byte $1C, $07                   ;Play note E4  for 7 frames.
LAC34:  .byte $1D, $07                   ;Play note F4  for 7 frames.
LAC36:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LAC38:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAC3A:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAC3C:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAC3E:  .byte $1F, $2A                   ;Play note G4  for 42 frames.
LAC40:  .byte $1C, $2A                   ;Play note E4  for 42 frames.
LAC42:  .byte $18, $07                   ;Play note C4  for 7 frames.
LAC44:  .byte $1A, $07                   ;Play note D4  for 7 frames.
LAC46:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LAC48:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LAC4A:  .byte $1A, $07                   ;Play note D4  for 7 frames.
LAC4C:  .byte $1C, $07                   ;Play note E4  for 7 frames.
LAC4E:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LAC50:  .byte $1A, $07                   ;Play note D4  for 7 frames.
LAC52:  .byte $1D, $07                   ;Play note F4  for 7 frames.
LAC54:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LAC56:  .byte CHN_JUMP, $00, $00, $FF    ;Jump back 256 bytes to $AB56.

;----------------------------------------------------------------------------------------------------

;Unused theme music Triangle data.

UnusedTri:
LAC5A:  .byte CHN_VOLUME, $0F            ;Set channel volume to 15.
LAC5C:  .byte CHN_VIBRATO, $00, $0A, $40 ;Set vibrato speed=10, intensity=64.
LAC60:  .byte CHN_ASR, $28               ;Set ASR data index to 40.
LAC62:  .byte $05, $1C                   ;Play note F1  for 28 frames.
LAC64:  .byte $11, $1C                   ;Play note F2  for 28 frames.
LAC66:  .byte $05, $0E                   ;Play note F1  for 14 frames.
LAC68:  .byte $05, $0E                   ;Play note F1  for 14 frames.
LAC6A:  .byte $11, $0E                   ;Play note F2  for 14 frames.
LAC6C:  .byte $05, $1C                   ;Play note F1  for 28 frames.
LAC6E:  .byte $05, $0E                   ;Play note F1  for 14 frames.
LAC70:  .byte $11, $1C                   ;Play note F2  for 28 frames.
LAC72:  .byte $05, $0E                   ;Play note F1  for 14 frames.
LAC74:  .byte $05, $0E                   ;Play note F1  for 14 frames.
LAC76:  .byte $11, $1C                   ;Play note F2  for 28 frames.
LAC78:  .byte $0E, $1C                   ;Play note D2  for 28 frames.
LAC7A:  .byte $0E, $1C                   ;Play note D2  for 28 frames.
LAC7C:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
LAC7E:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
LAC80:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
LAC82:  .byte $0E, $1C                   ;Play note D2  for 28 frames.
LAC84:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
LAC86:  .byte $0E, $1C                   ;Play note D2  for 28 frames.
LAC88:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
LAC8A:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
LAC8C:  .byte $0E, $1C                   ;Play note D2  for 28 frames.
LAC8E:  .byte $0A, $1C                   ;Play note A#1 for 28 frames.
LAC90:  .byte $0A, $1C                   ;Play note A#1 for 28 frames.
LAC92:  .byte $0A, $0E                   ;Play note A#1 for 14 frames.
LAC94:  .byte $0A, $0E                   ;Play note A#1 for 14 frames.
LAC96:  .byte $0A, $0E                   ;Play note A#1 for 14 frames.
LAC98:  .byte $0A, $1C                   ;Play note A#1 for 28 frames.
LAC9A:  .byte $0A, $0E                   ;Play note A#1 for 14 frames.
LAC9C:  .byte $0A, $1C                   ;Play note A#1 for 28 frames.
LAC9E:  .byte $0A, $0E                   ;Play note A#1 for 14 frames.
LACA0:  .byte $0A, $0E                   ;Play note A#1 for 14 frames.
LACA2:  .byte $0A, $1C                   ;Play note A#1 for 28 frames.
LACA4:  .byte $0C, $1C                   ;Play note C2  for 28 frames.
LACA6:  .byte $0C, $1C                   ;Play note C2  for 28 frames.
LACA8:  .byte $0C, $0E                   ;Play note C2  for 14 frames.
LACAA:  .byte $0C, $0E                   ;Play note C2  for 14 frames.
LACAC:  .byte $0C, $0E                   ;Play note C2  for 14 frames.
LACAE:  .byte $0C, $1C                   ;Play note C2  for 28 frames.
LACB0:  .byte $0C, $0E                   ;Play note C2  for 14 frames.
LACB2:  .byte $0C, $1C                   ;Play note C2  for 28 frames.
LACB4:  .byte $0C, $0E                   ;Play note C2  for 14 frames.
LACB6:  .byte $0C, $0E                   ;Play note C2  for 14 frames.
LACB8:  .byte $0C, $07                   ;Play note C2  for 7 frames.
LACBA:  .byte $0C, $07                   ;Play note C2  for 7 frames.
LACBC:  .byte $0C, $07                   ;Play note C2  for 7 frames.
LACBE:  .byte $0C, $07                   ;Play note C2  for 7 frames.
LACC0:  .byte $05, $1C                   ;Play note F1  for 28 frames.
LACC2:  .byte $11, $1C                   ;Play note F2  for 28 frames.
LACC4:  .byte $05, $0E                   ;Play note F1  for 14 frames.
LACC6:  .byte $05, $0E                   ;Play note F1  for 14 frames.
LACC8:  .byte $11, $0E                   ;Play note F2  for 14 frames.
LACCA:  .byte $05, $1C                   ;Play note F1  for 28 frames.
LACCC:  .byte $05, $0E                   ;Play note F1  for 14 frames.
LACCE:  .byte $11, $1C                   ;Play note F2  for 28 frames.
LACD0:  .byte $05, $0E                   ;Play note F1  for 14 frames.
LACD2:  .byte $05, $0E                   ;Play note F1  for 14 frames.
LACD4:  .byte $11, $1C                   ;Play note F2  for 28 frames.
LACD6:  .byte $0E, $1C                   ;Play note D2  for 28 frames.
LACD8:  .byte $0E, $1C                   ;Play note D2  for 28 frames.
LACDA:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
LACDC:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
LACDE:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
LACE0:  .byte $0E, $1C                   ;Play note D2  for 28 frames.
LACE2:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
LACE4:  .byte $0E, $1C                   ;Play note D2  for 28 frames.
LACE6:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
LACE8:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
LACEA:  .byte $0E, $1C                   ;Play note D2  for 28 frames.
LACEC:  .byte $0A, $1C                   ;Play note A#1 for 28 frames.
LACEE:  .byte $0A, $1C                   ;Play note A#1 for 28 frames.
LACF0:  .byte $0A, $0E                   ;Play note A#1 for 14 frames.
LACF2:  .byte $0A, $0E                   ;Play note A#1 for 14 frames.
LACF4:  .byte $0A, $0E                   ;Play note A#1 for 14 frames.
LACF6:  .byte $0A, $1C                   ;Play note A#1 for 28 frames.
LACF8:  .byte $0A, $0E                   ;Play note A#1 for 14 frames.
LACFA:  .byte $0A, $1C                   ;Play note A#1 for 28 frames.
LACFC:  .byte $0A, $0E                   ;Play note A#1 for 14 frames.
LACFE:  .byte $0A, $0E                   ;Play note A#1 for 14 frames.
LAD00:  .byte $0A, $1C                   ;Play note A#1 for 28 frames.
LAD02:  .byte $0C, $1C                   ;Play note C2  for 28 frames.
LAD04:  .byte $0C, $1C                   ;Play note C2  for 28 frames.
LAD06:  .byte $0C, $0E                   ;Play note C2  for 14 frames.
LAD08:  .byte $0C, $0E                   ;Play note C2  for 14 frames.
LAD0A:  .byte $0C, $0E                   ;Play note C2  for 14 frames.
LAD0C:  .byte $0C, $1C                   ;Play note C2  for 28 frames.
LAD0E:  .byte $0C, $0E                   ;Play note C2  for 14 frames.
LAD10:  .byte $0C, $1C                   ;Play note C2  for 28 frames.
LAD12:  .byte $0C, $0E                   ;Play note C2  for 14 frames.
LAD14:  .byte $0C, $0E                   ;Play note C2  for 14 frames.
LAD16:  .byte $0C, $07                   ;Play note C2  for 7 frames.
LAD18:  .byte $0C, $07                   ;Play note C2  for 7 frames.
LAD1A:  .byte $0C, $07                   ;Play note C2  for 7 frames.
LAD1C:  .byte $0C, $07                   ;Play note C2  for 7 frames.
LAD1E:  .byte CHN_JUMP, $00, $3C, $FF    ;Jump back 196 bytes to $AC5A.

;----------------------------------------------------------------------------------------------------

;Used in Overworld music SQ1.

SQ1Attack29:
LAD22:  .byte $05, $88, $8C, $90, $8E, $8B

SQ1Sustain29:
LAD28:  .byte $03, $87, $88, $88

SQ1Release29:
LAD2C:  .byte $08, $87, $86, $86, $85, $85, $84, $84, $83, $83

;----------------------------------------------------------------------------------------------------

;Used in Overworld music SQ2.

SQ2Attack2A:
LAD36:  .byte $04, $8C, $90, $8D, $88

SQ2Sustain2A:
LAD3B:  .byte $08, $87, $88, $88, $88, $88, $88, $88, $88

SQ2Release2A:
LAD44:  .byte $1D, $87, $87, $87, $87, $86, $86, $86, $86, $86, $86, $85, $85, $85, $85, $85
LAD54:  .byte $85, $85, $85, $84, $84, $84, $84, $84, $84, $84, $84, $84, $84, $83, $83

;----------------------------------------------------------------------------------------------------

;Used in Overworld music Triangle.

TriAttack2B:
LAD63:  .byte $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

TriSustain2B:
LAD6C:  .byte $10, $0F, $0F, $0F, $0F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAD7C:  .byte $00

TriRelease2B:
LAD7D:  .byte $08, $00, $00, $00, $00, $00, $00, $00, $00, $00

;----------------------------------------------------------------------------------------------------

;Used in Overworld music SQ2.

SQ2Attack2C:
LAD87:  .byte $06, $86, $8D, $90, $8D, $8A, $86

SQ2Sustain2C:
LAD8E:  .byte $04, $87, $87, $87, $87

SQ2Release2C:
LAD93:  .byte $18, $86, $86, $86, $86, $85, $85, $85, $85, $84, $84, $84, $84, $83, $83, $83
LADA3:  .byte $83, $82, $82, $82, $82, $81, $81, $81, $80, $80

;----------------------------------------------------------------------------------------------------

;Used in Overworld music SQ1.

SQ1Attack2D:
LADAD:  .byte $04, $8A, $8E, $90, $8E, $8B

SQ1Sustain2D:
LADB3:  .byte $03, $87, $88, $88

SQ1Release2D:
LADB7:  .byte $08, $87, $86, $86, $85, $85, $84, $84, $83, $83

;----------------------------------------------------------------------------------------------------

;Overworld theme music SQ1 data.

OverworldSQ1:
LADC1:  .byte CHN_VOLUME, $0E            ;Set channel volume to 14.
LADC3:  .byte CHN_VIBRATO, $00, $0A, $20 ;Set vibrato speed=10, intensity=32.
LADC7:  .byte CHN_ASR, $29               ;Set ASR data index to 41.
LADC9:  .byte $26, $0E                   ;Play note D5  for 14 frames.
LADCB:  .byte $28, $07                   ;Play note E5  for 7 frames.
LADCD:  .byte $29, $07                   ;Play note F5  for 7 frames.
LADCF:  .byte $28, $0E                   ;Play note E5  for 14 frames.
LADD1:  .byte $26, $0E                   ;Play note D5  for 14 frames.
LADD3:  .byte $26, $0E                   ;Play note D5  for 14 frames.
LADD5:  .byte $28, $07                   ;Play note E5  for 7 frames.
LADD7:  .byte $29, $07                   ;Play note F5  for 7 frames.
LADD9:  .byte $28, $0E                   ;Play note E5  for 14 frames.
LADDB:  .byte $26, $0E                   ;Play note D5  for 14 frames.
LADDD:  .byte $26, $0E                   ;Play note D5  for 14 frames.
LADDF:  .byte $28, $07                   ;Play note E5  for 7 frames.
LADE1:  .byte $29, $07                   ;Play note F5  for 7 frames.
LADE3:  .byte $2B, $0E                   ;Play note G5  for 14 frames.
LADE5:  .byte $29, $07                   ;Play note F5  for 7 frames.
LADE7:  .byte $28, $07                   ;Play note E5  for 7 frames.
LADE9:  .byte $29, $0E                   ;Play note F5  for 14 frames.
LADEB:  .byte $28, $07                   ;Play note E5  for 7 frames.
LADED:  .byte $26, $07                   ;Play note D5  for 7 frames.
LADEF:  .byte $28, $0E                   ;Play note E5  for 14 frames.
LADF1:  .byte $26, $07                   ;Play note D5  for 7 frames.
LADF3:  .byte $24, $07                   ;Play note C5  for 7 frames.
LADF5:  .byte $24, $0E                   ;Play note C5  for 14 frames.
LADF7:  .byte $26, $07                   ;Play note D5  for 7 frames.
LADF9:  .byte $28, $07                   ;Play note E5  for 7 frames.
LADFB:  .byte $26, $0E                   ;Play note D5  for 14 frames.
LADFD:  .byte $24, $0E                   ;Play note C5  for 14 frames.
LADFF:  .byte $24, $0E                   ;Play note C5  for 14 frames.
LAE01:  .byte $26, $07                   ;Play note D5  for 7 frames.
LAE03:  .byte $28, $07                   ;Play note E5  for 7 frames.
LAE05:  .byte $26, $0E                   ;Play note D5  for 14 frames.
LAE07:  .byte $24, $0E                   ;Play note C5  for 14 frames.
LAE09:  .byte $24, $0E                   ;Play note C5  for 14 frames.
LAE0B:  .byte $26, $07                   ;Play note D5  for 7 frames.
LAE0D:  .byte $28, $07                   ;Play note E5  for 7 frames.
LAE0F:  .byte $29, $0E                   ;Play note F5  for 14 frames.
LAE11:  .byte $28, $07                   ;Play note E5  for 7 frames.
LAE13:  .byte $26, $07                   ;Play note D5  for 7 frames.
LAE15:  .byte $28, $0E                   ;Play note E5  for 14 frames.
LAE17:  .byte $26, $07                   ;Play note D5  for 7 frames.
LAE19:  .byte $24, $07                   ;Play note C5  for 7 frames.
LAE1B:  .byte $26, $0E                   ;Play note D5  for 14 frames.
LAE1D:  .byte $24, $07                   ;Play note C5  for 7 frames.
LAE1F:  .byte $22, $07                   ;Play note A#4 for 7 frames.
LAE21:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAE23:  .byte $24, $07                   ;Play note C5  for 7 frames.
LAE25:  .byte $26, $07                   ;Play note D5  for 7 frames.
LAE27:  .byte $24, $0E                   ;Play note C5  for 14 frames.
LAE29:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAE2B:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAE2D:  .byte $24, $07                   ;Play note C5  for 7 frames.
LAE2F:  .byte $26, $07                   ;Play note D5  for 7 frames.
LAE31:  .byte $24, $0E                   ;Play note C5  for 14 frames.
LAE33:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAE35:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAE37:  .byte $24, $07                   ;Play note C5  for 7 frames.
LAE39:  .byte $26, $07                   ;Play note D5  for 7 frames.
LAE3B:  .byte $28, $0E                   ;Play note E5  for 14 frames.
LAE3D:  .byte $26, $07                   ;Play note D5  for 7 frames.
LAE3F:  .byte $24, $07                   ;Play note C5  for 7 frames.
LAE41:  .byte $26, $0E                   ;Play note D5  for 14 frames.
LAE43:  .byte $24, $07                   ;Play note C5  for 7 frames.
LAE45:  .byte $22, $07                   ;Play note A#4 for 7 frames.
LAE47:  .byte $24, $0E                   ;Play note C5  for 14 frames.
LAE49:  .byte $22, $07                   ;Play note A#4 for 7 frames.
LAE4B:  .byte $21, $07                   ;Play note A4  for 7 frames.
LAE4D:  .byte $21, $07                   ;Play note A4  for 7 frames.
LAE4F:  .byte $22, $07                   ;Play note A#4 for 7 frames.
LAE51:  .byte $24, $07                   ;Play note C5  for 7 frames.
LAE53:  .byte $25, $07                   ;Play note C#5 for 7 frames.
LAE55:  .byte $24, $0E                   ;Play note C5  for 14 frames.
LAE57:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAE59:  .byte $21, $07                   ;Play note A4  for 7 frames.
LAE5B:  .byte $22, $07                   ;Play note A#4 for 7 frames.
LAE5D:  .byte $24, $07                   ;Play note C5  for 7 frames.
LAE5F:  .byte $25, $07                   ;Play note C#5 for 7 frames.
LAE61:  .byte $24, $0E                   ;Play note C5  for 14 frames.
LAE63:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAE65:  .byte $21, $07                   ;Play note A4  for 7 frames.
LAE67:  .byte $22, $07                   ;Play note A#4 for 7 frames.
LAE69:  .byte $24, $07                   ;Play note C5  for 7 frames.
LAE6B:  .byte $25, $07                   ;Play note C#5 for 7 frames.
LAE6D:  .byte $24, $0E                   ;Play note C5  for 14 frames.
LAE6F:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAE71:  .byte $21, $07                   ;Play note A4  for 7 frames.
LAE73:  .byte $22, $07                   ;Play note A#4 for 7 frames.
LAE75:  .byte $24, $07                   ;Play note C5  for 7 frames.
LAE77:  .byte $25, $07                   ;Play note C#5 for 7 frames.
LAE79:  .byte $24, $0E                   ;Play note C5  for 14 frames.
LAE7B:  .byte $22, $0E                   ;Play note A#4 for 14 frames.
LAE7D:  .byte CHN_VOLUME, $0A            ;Set channel volume to 10.
LAE7F:  .byte CHN_ASR, $2D               ;Set ASR data index to 45.
LAE81:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAE83:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
LAE85:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAE87:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAE89:  .byte $2D, $07                   ;Play note A5  for 7 frames.
LAE8B:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAE8D:  .byte $2D, $07                   ;Play note A5  for 7 frames.
LAE8F:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAE91:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAE93:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
LAE95:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAE97:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
LAE99:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAE9B:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAE9D:  .byte $2D, $07                   ;Play note A5  for 7 frames.
LAE9F:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAEA1:  .byte $2D, $07                   ;Play note A5  for 7 frames.
LAEA3:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAEA5:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAEA7:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
LAEA9:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAEAB:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
LAEAD:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAEAF:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAEB1:  .byte $2D, $07                   ;Play note A5  for 7 frames.
LAEB3:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAEB5:  .byte $2D, $07                   ;Play note A5  for 7 frames.
LAEB7:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAEB9:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAEBB:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
LAEBD:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAEBF:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
LAEC1:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAEC3:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAEC5:  .byte $2D, $07                   ;Play note A5  for 7 frames.
LAEC7:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAEC9:  .byte $2D, $07                   ;Play note A5  for 7 frames.
LAECB:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAECD:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAECF:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
LAED1:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAED3:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAED5:  .byte $28, $0E                   ;Play note E5  for 14 frames.
LAED7:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAED9:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAEDB:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
LAEDD:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAEDF:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
LAEE1:  .byte $28, $0E                   ;Play note E5  for 14 frames.
LAEE3:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAEE5:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAEE7:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAEE9:  .byte $28, $0E                   ;Play note E5  for 14 frames.
LAEEB:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAEED:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAEEF:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
LAEF1:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAEF3:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
LAEF5:  .byte $28, $0E                   ;Play note E5  for 14 frames.
LAEF7:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAEF9:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAEFB:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAEFD:  .byte $28, $0E                   ;Play note E5  for 14 frames.
LAEFF:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAF01:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAF03:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
LAF05:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAF07:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
LAF09:  .byte $28, $0E                   ;Play note E5  for 14 frames.
LAF0B:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAF0D:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAF0F:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAF11:  .byte $28, $0E                   ;Play note E5  for 14 frames.
LAF13:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAF15:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAF17:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
LAF19:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAF1B:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
LAF1D:  .byte $28, $0E                   ;Play note E5  for 14 frames.
LAF1F:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAF21:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAF23:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
LAF25:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAF27:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAF29:  .byte $2D, $07                   ;Play note A5  for 7 frames.
LAF2B:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAF2D:  .byte $2D, $07                   ;Play note A5  for 7 frames.
LAF2F:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAF31:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAF33:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
LAF35:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAF37:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
LAF39:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAF3B:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAF3D:  .byte $2D, $07                   ;Play note A5  for 7 frames.
LAF3F:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAF41:  .byte $2D, $07                   ;Play note A5  for 7 frames.
LAF43:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAF45:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAF47:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
LAF49:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAF4B:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
LAF4D:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAF4F:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAF51:  .byte $2D, $07                   ;Play note A5  for 7 frames.
LAF53:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAF55:  .byte $2D, $07                   ;Play note A5  for 7 frames.
LAF57:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAF59:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAF5B:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
LAF5D:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAF5F:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
LAF61:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAF63:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAF65:  .byte $2D, $07                   ;Play note A5  for 7 frames.
LAF67:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAF69:  .byte $2D, $07                   ;Play note A5  for 7 frames.
LAF6B:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAF6D:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAF6F:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
LAF71:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAF73:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAF75:  .byte $28, $0E                   ;Play note E5  for 14 frames.
LAF77:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAF79:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAF7B:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
LAF7D:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAF7F:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
LAF81:  .byte $28, $0E                   ;Play note E5  for 14 frames.
LAF83:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAF85:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAF87:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAF89:  .byte $28, $0E                   ;Play note E5  for 14 frames.
LAF8B:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAF8D:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAF8F:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
LAF91:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAF93:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
LAF95:  .byte $28, $0E                   ;Play note E5  for 14 frames.
LAF97:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAF99:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAF9B:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAF9D:  .byte $28, $0E                   ;Play note E5  for 14 frames.
LAF9F:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAFA1:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAFA3:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
LAFA5:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAFA7:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
LAFA9:  .byte $28, $0E                   ;Play note E5  for 14 frames.
LAFAB:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAFAD:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAFAF:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAFB1:  .byte $28, $0E                   ;Play note E5  for 14 frames.
LAFB3:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
LAFB5:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAFB7:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
LAFB9:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LAFBB:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
LAFBD:  .byte $28, $0E                   ;Play note E5  for 14 frames.
LAFBF:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
LAFC1:  .byte CHN_SILENCE, $70           ;Silence channel for 112 frames.
LAFC3:  .byte CHN_SILENCE, $70           ;Silence channel for 112 frames.
LAFC5:  .byte $1B, $07                   ;Play note D#4 for 7 frames.
LAFC7:  .byte $1D, $07                   ;Play note F4  for 7 frames.
LAFC9:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
LAFCB:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LAFCD:  .byte $22, $07                   ;Play note A#4 for 7 frames.
LAFCF:  .byte $24, $07                   ;Play note C5  for 7 frames.
LAFD1:  .byte $25, $07                   ;Play note C#5 for 7 frames.
LAFD3:  .byte $27, $07                   ;Play note D#5 for 7 frames.
LAFD5:  .byte $1D, $07                   ;Play note F4  for 7 frames.
LAFD7:  .byte $1F, $07                   ;Play note G4  for 7 frames.
LAFD9:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LAFDB:  .byte $22, $07                   ;Play note A#4 for 7 frames.
LAFDD:  .byte $24, $07                   ;Play note C5  for 7 frames.
LAFDF:  .byte $26, $07                   ;Play note D5  for 7 frames.
LAFE1:  .byte $27, $07                   ;Play note D#5 for 7 frames.
LAFE3:  .byte $29, $07                   ;Play note F5  for 7 frames.
LAFE5:  .byte $1F, $07                   ;Play note G4  for 7 frames.
LAFE7:  .byte $21, $07                   ;Play note A4  for 7 frames.
LAFE9:  .byte $22, $07                   ;Play note A#4 for 7 frames.
LAFEB:  .byte $24, $07                   ;Play note C5  for 7 frames.
LAFED:  .byte $26, $07                   ;Play note D5  for 7 frames.
LAFEF:  .byte $28, $07                   ;Play note E5  for 7 frames.
LAFF1:  .byte $29, $07                   ;Play note F5  for 7 frames.
LAFF3:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
LAFF5:  .byte $21, $07                   ;Play note A4  for 7 frames.
LAFF7:  .byte $23, $07                   ;Play note B4  for 7 frames.
LAFF9:  .byte $24, $07                   ;Play note C5  for 7 frames.
LAFFB:  .byte $26, $07                   ;Play note D5  for 7 frames.
LAFFD:  .byte $28, $07                   ;Play note E5  for 7 frames.
LAFFF:  .byte $29, $07                   ;Play note F5  for 7 frames.
LB001:  .byte $2B, $07                   ;Play note G5  for 7 frames.
LB003:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LB005:  .byte CHN_JUMP, $00, $BC, $FD    ;Jump back 580 bytes to $ADC1.

;----------------------------------------------------------------------------------------------------

;Overworld theme music SQ2 data.

OverworldSQ2:
LB009:  .byte CHN_VOLUME, $0C            ;Set channel volume to 12.
LB00B:  .byte CHN_VIBRATO, $00, $00, $00 ;Disable vibrato.
LB00F:  .byte CHN_ASR, $2A               ;Set ASR data index to 42.
LB011:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LB013:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LB015:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LB017:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LB019:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LB01B:  .byte $1F, $07                   ;Play note G4  for 7 frames.
LB01D:  .byte $1D, $07                   ;Play note F4  for 7 frames.
LB01F:  .byte $1A, $07                   ;Play note D4  for 7 frames.
LB021:  .byte $1C, $07                   ;Play note E4  for 7 frames.
LB023:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LB025:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LB027:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LB029:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LB02B:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LB02D:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LB02F:  .byte $1F, $07                   ;Play note G4  for 7 frames.
LB031:  .byte $1D, $07                   ;Play note F4  for 7 frames.
LB033:  .byte $1A, $07                   ;Play note D4  for 7 frames.
LB035:  .byte $1C, $07                   ;Play note E4  for 7 frames.
LB037:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LB039:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LB03B:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LB03D:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LB03F:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LB041:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LB043:  .byte $1D, $07                   ;Play note F4  for 7 frames.
LB045:  .byte $1C, $07                   ;Play note E4  for 7 frames.
LB047:  .byte $18, $07                   ;Play note C4  for 7 frames.
LB049:  .byte $1A, $07                   ;Play note D4  for 7 frames.
LB04B:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LB04D:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LB04F:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LB051:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LB053:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LB055:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LB057:  .byte $1D, $07                   ;Play note F4  for 7 frames.
LB059:  .byte $1C, $07                   ;Play note E4  for 7 frames.
LB05B:  .byte $18, $07                   ;Play note C4  for 7 frames.
LB05D:  .byte $1A, $07                   ;Play note D4  for 7 frames.
LB05F:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LB061:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LB063:  .byte $1A, $0E                   ;Play note D4  for 14 frames.
LB065:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LB067:  .byte $1A, $0E                   ;Play note D4  for 14 frames.
LB069:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LB06B:  .byte $1C, $07                   ;Play note E4  for 7 frames.
LB06D:  .byte $1A, $07                   ;Play note D4  for 7 frames.
LB06F:  .byte $16, $07                   ;Play note A#3 for 7 frames.
LB071:  .byte $18, $07                   ;Play note C4  for 7 frames.
LB073:  .byte $1A, $0E                   ;Play note D4  for 14 frames.
LB075:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LB077:  .byte $1A, $0E                   ;Play note D4  for 14 frames.
LB079:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LB07B:  .byte $1A, $0E                   ;Play note D4  for 14 frames.
LB07D:  .byte $1D, $0E                   ;Play note F4  for 14 frames.
LB07F:  .byte $1C, $07                   ;Play note E4  for 7 frames.
LB081:  .byte $1A, $07                   ;Play note D4  for 7 frames.
LB083:  .byte $16, $07                   ;Play note A#3 for 7 frames.
LB085:  .byte $18, $07                   ;Play note C4  for 7 frames.
LB087:  .byte $1A, $0E                   ;Play note D4  for 14 frames.
LB089:  .byte $1C, $07                   ;Play note E4  for 7 frames.
LB08B:  .byte $1F, $07                   ;Play note G4  for 7 frames.
LB08D:  .byte $21, $07                   ;Play note A4  for 7 frames.
LB08F:  .byte $22, $07                   ;Play note A#4 for 7 frames.
LB091:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LB093:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LB095:  .byte $1C, $07                   ;Play note E4  for 7 frames.
LB097:  .byte $1F, $07                   ;Play note G4  for 7 frames.
LB099:  .byte $21, $07                   ;Play note A4  for 7 frames.
LB09B:  .byte $22, $07                   ;Play note A#4 for 7 frames.
LB09D:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LB09F:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LB0A1:  .byte $1C, $07                   ;Play note E4  for 7 frames.
LB0A3:  .byte $1F, $07                   ;Play note G4  for 7 frames.
LB0A5:  .byte $21, $07                   ;Play note A4  for 7 frames.
LB0A7:  .byte $22, $07                   ;Play note A#4 for 7 frames.
LB0A9:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LB0AB:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LB0AD:  .byte $1C, $07                   ;Play note E4  for 7 frames.
LB0AF:  .byte $1F, $07                   ;Play note G4  for 7 frames.
LB0B1:  .byte $21, $07                   ;Play note A4  for 7 frames.
LB0B3:  .byte $22, $07                   ;Play note A#4 for 7 frames.
LB0B5:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LB0B7:  .byte $1F, $0E                   ;Play note G4  for 14 frames.
LB0B9:  .byte CHN_VOLUME, $0A            ;Set channel volume to 10.
LB0BB:  .byte CHN_ASR, $2C               ;Set ASR data index to 44.
LB0BD:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB0BF:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LB0C1:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB0C3:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB0C5:  .byte $21, $07                   ;Play note A4  for 7 frames.
LB0C7:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB0C9:  .byte $21, $07                   ;Play note A4  for 7 frames.
LB0CB:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB0CD:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB0CF:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LB0D1:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB0D3:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LB0D5:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB0D7:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB0D9:  .byte $21, $07                   ;Play note A4  for 7 frames.
LB0DB:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB0DD:  .byte $21, $07                   ;Play note A4  for 7 frames.
LB0DF:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB0E1:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB0E3:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LB0E5:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB0E7:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LB0E9:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB0EB:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB0ED:  .byte $21, $07                   ;Play note A4  for 7 frames.
LB0EF:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB0F1:  .byte $21, $07                   ;Play note A4  for 7 frames.
LB0F3:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB0F5:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB0F7:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LB0F9:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB0FB:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LB0FD:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB0FF:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB101:  .byte $21, $07                   ;Play note A4  for 7 frames.
LB103:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB105:  .byte $21, $07                   ;Play note A4  for 7 frames.
LB107:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB109:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB10B:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LB10D:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB10F:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB111:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LB113:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB115:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB117:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
LB119:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB11B:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
LB11D:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LB11F:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB121:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB123:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB125:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LB127:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB129:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB12B:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
LB12D:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB12F:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
LB131:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LB133:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB135:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB137:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB139:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LB13B:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB13D:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB13F:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
LB141:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB143:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
LB145:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LB147:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB149:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB14B:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB14D:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LB14F:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB151:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB153:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
LB155:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB157:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
LB159:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LB15B:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB15D:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB15F:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LB161:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB163:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB165:  .byte $21, $07                   ;Play note A4  for 7 frames.
LB167:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB169:  .byte $21, $07                   ;Play note A4  for 7 frames.
LB16B:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB16D:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB16F:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LB171:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB173:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LB175:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB177:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB179:  .byte $21, $07                   ;Play note A4  for 7 frames.
LB17B:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB17D:  .byte $21, $07                   ;Play note A4  for 7 frames.
LB17F:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB181:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB183:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LB185:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB187:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LB189:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB18B:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB18D:  .byte $21, $07                   ;Play note A4  for 7 frames.
LB18F:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB191:  .byte $21, $07                   ;Play note A4  for 7 frames.
LB193:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB195:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB197:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LB199:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB19B:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LB19D:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB19F:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB1A1:  .byte $21, $07                   ;Play note A4  for 7 frames.
LB1A3:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB1A5:  .byte $21, $07                   ;Play note A4  for 7 frames.
LB1A7:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB1A9:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB1AB:  .byte $21, $0E                   ;Play note A4  for 14 frames.
LB1AD:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB1AF:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB1B1:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LB1B3:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB1B5:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB1B7:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
LB1B9:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB1BB:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
LB1BD:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LB1BF:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB1C1:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB1C3:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB1C5:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LB1C7:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB1C9:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB1CB:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
LB1CD:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB1CF:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
LB1D1:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LB1D3:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB1D5:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB1D7:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB1D9:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LB1DB:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB1DD:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB1DF:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
LB1E1:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB1E3:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
LB1E5:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LB1E7:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB1E9:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB1EB:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB1ED:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LB1EF:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
LB1F1:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB1F3:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
LB1F5:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB1F7:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
LB1F9:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
LB1FB:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
LB1FD:  .byte $1B, $07                   ;Play note D#4 for 7 frames.
LB1FF:  .byte $1D, $07                   ;Play note F4  for 7 frames.
LB201:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
LB203:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB205:  .byte $22, $07                   ;Play note A#4 for 7 frames.
LB207:  .byte $24, $07                   ;Play note C5  for 7 frames.
LB209:  .byte $25, $07                   ;Play note C#5 for 7 frames.
LB20B:  .byte $27, $07                   ;Play note D#5 for 7 frames.
LB20D:  .byte $1D, $07                   ;Play note F4  for 7 frames.
LB20F:  .byte $1F, $07                   ;Play note G4  for 7 frames.
LB211:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB213:  .byte $22, $07                   ;Play note A#4 for 7 frames.
LB215:  .byte $24, $07                   ;Play note C5  for 7 frames.
LB217:  .byte $26, $07                   ;Play note D5  for 7 frames.
LB219:  .byte $27, $07                   ;Play note D#5 for 7 frames.
LB21B:  .byte $29, $07                   ;Play note F5  for 7 frames.
LB21D:  .byte $1F, $07                   ;Play note G4  for 7 frames.
LB21F:  .byte $21, $07                   ;Play note A4  for 7 frames.
LB221:  .byte $22, $07                   ;Play note A#4 for 7 frames.
LB223:  .byte $24, $07                   ;Play note C5  for 7 frames.
LB225:  .byte $26, $07                   ;Play note D5  for 7 frames.
LB227:  .byte $28, $07                   ;Play note E5  for 7 frames.
LB229:  .byte $29, $07                   ;Play note F5  for 7 frames.
LB22B:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
LB22D:  .byte $21, $07                   ;Play note A4  for 7 frames.
LB22F:  .byte $23, $07                   ;Play note B4  for 7 frames.
LB231:  .byte $24, $07                   ;Play note C5  for 7 frames.
LB233:  .byte $26, $07                   ;Play note D5  for 7 frames.
LB235:  .byte $28, $07                   ;Play note E5  for 7 frames.
LB237:  .byte $29, $07                   ;Play note F5  for 7 frames.
LB239:  .byte $2B, $07                   ;Play note G5  for 7 frames.
LB23B:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LB23D:  .byte $1B, $07                   ;Play note D#4 for 7 frames.
LB23F:  .byte $1D, $07                   ;Play note F4  for 7 frames.
LB241:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
LB243:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB245:  .byte $22, $07                   ;Play note A#4 for 7 frames.
LB247:  .byte $24, $07                   ;Play note C5  for 7 frames.
LB249:  .byte $25, $07                   ;Play note C#5 for 7 frames.
LB24B:  .byte $27, $07                   ;Play note D#5 for 7 frames.
LB24D:  .byte $1D, $07                   ;Play note F4  for 7 frames.
LB24F:  .byte $1F, $07                   ;Play note G4  for 7 frames.
LB251:  .byte $20, $07                   ;Play note G#4 for 7 frames.
LB253:  .byte $22, $07                   ;Play note A#4 for 7 frames.
LB255:  .byte $24, $07                   ;Play note C5  for 7 frames.
LB257:  .byte $26, $07                   ;Play note D5  for 7 frames.
LB259:  .byte $27, $07                   ;Play note D#5 for 7 frames.
LB25B:  .byte $29, $07                   ;Play note F5  for 7 frames.
LB25D:  .byte $1F, $07                   ;Play note G4  for 7 frames.
LB25F:  .byte $21, $07                   ;Play note A4  for 7 frames.
LB261:  .byte $22, $07                   ;Play note A#4 for 7 frames.
LB263:  .byte $24, $07                   ;Play note C5  for 7 frames.
LB265:  .byte $26, $07                   ;Play note D5  for 7 frames.
LB267:  .byte $28, $07                   ;Play note E5  for 7 frames.
LB269:  .byte $29, $07                   ;Play note F5  for 7 frames.
LB26B:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
LB26D:  .byte $21, $07                   ;Play note A4  for 7 frames.
LB26F:  .byte $23, $07                   ;Play note B4  for 7 frames.
LB271:  .byte $24, $07                   ;Play note C5  for 7 frames.
LB273:  .byte $26, $07                   ;Play note D5  for 7 frames.
LB275:  .byte $28, $07                   ;Play note E5  for 7 frames.
LB277:  .byte $29, $07                   ;Play note F5  for 7 frames.
LB279:  .byte $2B, $07                   ;Play note G5  for 7 frames.
LB27B:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
LB27D:  .byte CHN_JUMP, $00, $8C, $FD    ;Jump back 628 bytes to $B009.

;----------------------------------------------------------------------------------------------------

;Overworld theme music Triangle data.

OverworldTri:
LB281:  .byte CHN_VOLUME, $0F            ;Set channel volume to 15.
LB283:  .byte CHN_VIBRATO, $00, $0A, $25 ;Set vibrato speed=10, intensity=37.
LB287:  .byte CHN_ASR, $2B               ;Set ASR data index to 43.
LB289:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
LB28B:  .byte $0C, $0E                   ;Play note C2  for 14 frames.
LB28D:  .byte $0C, $0E                   ;Play note C2  for 14 frames.
LB28F:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
LB291:  .byte CHN_SILENCE, $38           ;Silence channel for 56 frames.
LB293:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
LB295:  .byte $0C, $0E                   ;Play note C2  for 14 frames.
LB297:  .byte $0C, $0E                   ;Play note C2  for 14 frames.
LB299:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
LB29B:  .byte CHN_SILENCE, $38           ;Silence channel for 56 frames.
LB29D:  .byte $0C, $0E                   ;Play note C2  for 14 frames.
LB29F:  .byte $0A, $0E                   ;Play note A#1 for 14 frames.
LB2A1:  .byte $0A, $0E                   ;Play note A#1 for 14 frames.
LB2A3:  .byte $0C, $0E                   ;Play note C2  for 14 frames.
LB2A5:  .byte CHN_SILENCE, $38           ;Silence channel for 56 frames.
LB2A7:  .byte $0C, $0E                   ;Play note C2  for 14 frames.
LB2A9:  .byte $0A, $0E                   ;Play note A#1 for 14 frames.
LB2AB:  .byte $0A, $0E                   ;Play note A#1 for 14 frames.
LB2AD:  .byte $0C, $0E                   ;Play note C2  for 14 frames.
LB2AF:  .byte CHN_SILENCE, $38           ;Silence channel for 56 frames.
LB2B1:  .byte $0A, $0E                   ;Play note A#1 for 14 frames.
LB2B3:  .byte $09, $0E                   ;Play note A1  for 14 frames.
LB2B5:  .byte $09, $0E                   ;Play note A1  for 14 frames.
LB2B7:  .byte $0A, $0E                   ;Play note A#1 for 14 frames.
LB2B9:  .byte CHN_SILENCE, $38           ;Silence channel for 56 frames.
LB2BB:  .byte $0A, $0E                   ;Play note A#1 for 14 frames.
LB2BD:  .byte $09, $0E                   ;Play note A1  for 14 frames.
LB2BF:  .byte $09, $0E                   ;Play note A1  for 14 frames.
LB2C1:  .byte $0A, $0E                   ;Play note A#1 for 14 frames.
LB2C3:  .byte CHN_SILENCE, $38           ;Silence channel for 56 frames.
LB2C5:  .byte $09, $0E                   ;Play note A1  for 14 frames.
LB2C7:  .byte $15, $0E                   ;Play note A2  for 14 frames.
LB2C9:  .byte $13, $0E                   ;Play note G2  for 14 frames.
LB2CB:  .byte $15, $0E                   ;Play note A2  for 14 frames.
LB2CD:  .byte $09, $0E                   ;Play note A1  for 14 frames.
LB2CF:  .byte $15, $0E                   ;Play note A2  for 14 frames.
LB2D1:  .byte $13, $0E                   ;Play note G2  for 14 frames.
LB2D3:  .byte $15, $0E                   ;Play note A2  for 14 frames.
LB2D5:  .byte $13, $0E                   ;Play note G2  for 14 frames.
LB2D7:  .byte $13, $0E                   ;Play note G2  for 14 frames.
LB2D9:  .byte $13, $0E                   ;Play note G2  for 14 frames.
LB2DB:  .byte $10, $0E                   ;Play note E2  for 14 frames.
LB2DD:  .byte $10, $0E                   ;Play note E2  for 14 frames.
LB2DF:  .byte $10, $0E                   ;Play note E2  for 14 frames.
LB2E1:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
LB2E3:  .byte $0A, $0E                   ;Play note A#1 for 14 frames.
LB2E5:  .byte $06, $1C                   ;Play note F#1 for 28 frames.
LB2E7:  .byte $12, $1C                   ;Play note F#2 for 28 frames.
LB2E9:  .byte $06, $1C                   ;Play note F#1 for 28 frames.
LB2EB:  .byte $12, $1C                   ;Play note F#2 for 28 frames.
LB2ED:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
LB2EF:  .byte $10, $0E                   ;Play note E2  for 14 frames.
LB2F1:  .byte $0F, $0E                   ;Play note D#2 for 14 frames.
LB2F3:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
LB2F5:  .byte $12, $07                   ;Play note F#2 for 7 frames.
LB2F7:  .byte $10, $07                   ;Play note E2  for 7 frames.
LB2F9:  .byte $0F, $07                   ;Play note D#2 for 7 frames.
LB2FB:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
LB2FD:  .byte CHN_SILENCE, $07           ;Silence channel for 7 frames.
LB2FF:  .byte $09, $07                   ;Play note A1  for 7 frames.
LB301:  .byte $08, $07                   ;Play note G#1 for 7 frames.
LB303:  .byte $04, $07                   ;Play note E1  for 7 frames.
LB305:  .byte $06, $1C                   ;Play note F#1 for 28 frames.
LB307:  .byte $12, $1C                   ;Play note F#2 for 28 frames.
LB309:  .byte $06, $1C                   ;Play note F#1 for 28 frames.
LB30B:  .byte $12, $1C                   ;Play note F#2 for 28 frames.
LB30D:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
LB30F:  .byte $10, $0E                   ;Play note E2  for 14 frames.
LB311:  .byte $0F, $0E                   ;Play note D#2 for 14 frames.
LB313:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
LB315:  .byte $12, $07                   ;Play note F#2 for 7 frames.
LB317:  .byte $10, $07                   ;Play note E2  for 7 frames.
LB319:  .byte $0F, $07                   ;Play note D#2 for 7 frames.
LB31B:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
LB31D:  .byte CHN_SILENCE, $07           ;Silence channel for 7 frames.
LB31F:  .byte $09, $07                   ;Play note A1  for 7 frames.
LB321:  .byte $08, $07                   ;Play note G#1 for 7 frames.
LB323:  .byte $04, $07                   ;Play note E1  for 7 frames.
LB325:  .byte $04, $1C                   ;Play note E1  for 28 frames.
LB327:  .byte $10, $1C                   ;Play note E2  for 28 frames.
LB329:  .byte $04, $1C                   ;Play note E1  for 28 frames.
LB32B:  .byte $10, $1C                   ;Play note E2  for 28 frames.
LB32D:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
LB32F:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
LB331:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
LB333:  .byte $0B, $0E                   ;Play note B1  for 14 frames.
LB335:  .byte $10, $07                   ;Play note E2  for 7 frames.
LB337:  .byte $0E, $07                   ;Play note D2  for 7 frames.
LB339:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
LB33B:  .byte $0B, $07                   ;Play note B1  for 7 frames.
LB33D:  .byte CHN_SILENCE, $07           ;Silence channel for 7 frames.
LB33F:  .byte $08, $07                   ;Play note G#1 for 7 frames.
LB341:  .byte $06, $07                   ;Play note F#1 for 7 frames.
LB343:  .byte $02, $07                   ;Play note D1  for 7 frames.
LB345:  .byte $04, $1C                   ;Play note E1  for 28 frames.
LB347:  .byte $10, $1C                   ;Play note E2  for 28 frames.
LB349:  .byte $04, $1C                   ;Play note E1  for 28 frames.
LB34B:  .byte $10, $1C                   ;Play note E2  for 28 frames.
LB34D:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
LB34F:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
LB351:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
LB353:  .byte $0B, $0E                   ;Play note B1  for 14 frames.
LB355:  .byte $10, $07                   ;Play note E2  for 7 frames.
LB357:  .byte $0E, $07                   ;Play note D2  for 7 frames.
LB359:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
LB35B:  .byte $0B, $07                   ;Play note B1  for 7 frames.
LB35D:  .byte CHN_SILENCE, $07           ;Silence channel for 7 frames.
LB35F:  .byte $08, $07                   ;Play note G#1 for 7 frames.
LB361:  .byte $06, $07                   ;Play note F#1 for 7 frames.
LB363:  .byte $02, $07                   ;Play note D1  for 7 frames.
LB365:  .byte $06, $1C                   ;Play note F#1 for 28 frames.
LB367:  .byte $12, $1C                   ;Play note F#2 for 28 frames.
LB369:  .byte $06, $1C                   ;Play note F#1 for 28 frames.
LB36B:  .byte $12, $1C                   ;Play note F#2 for 28 frames.
LB36D:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
LB36F:  .byte $10, $0E                   ;Play note E2  for 14 frames.
LB371:  .byte $0F, $0E                   ;Play note D#2 for 14 frames.
LB373:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
LB375:  .byte $12, $07                   ;Play note F#2 for 7 frames.
LB377:  .byte $10, $07                   ;Play note E2  for 7 frames.
LB379:  .byte $0F, $07                   ;Play note D#2 for 7 frames.
LB37B:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
LB37D:  .byte CHN_SILENCE, $07           ;Silence channel for 7 frames.
LB37F:  .byte $09, $07                   ;Play note A1  for 7 frames.
LB381:  .byte $08, $07                   ;Play note G#1 for 7 frames.
LB383:  .byte $04, $07                   ;Play note E1  for 7 frames.
LB385:  .byte $06, $1C                   ;Play note F#1 for 28 frames.
LB387:  .byte $12, $1C                   ;Play note F#2 for 28 frames.
LB389:  .byte $06, $1C                   ;Play note F#1 for 28 frames.
LB38B:  .byte $12, $1C                   ;Play note F#2 for 28 frames.
LB38D:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
LB38F:  .byte $10, $0E                   ;Play note E2  for 14 frames.
LB391:  .byte $0F, $0E                   ;Play note D#2 for 14 frames.
LB393:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
LB395:  .byte $12, $07                   ;Play note F#2 for 7 frames.
LB397:  .byte $10, $07                   ;Play note E2  for 7 frames.
LB399:  .byte $0F, $07                   ;Play note D#2 for 7 frames.
LB39B:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
LB39D:  .byte CHN_SILENCE, $07           ;Silence channel for 7 frames.
LB39F:  .byte $09, $07                   ;Play note A1  for 7 frames.
LB3A1:  .byte $08, $07                   ;Play note G#1 for 7 frames.
LB3A3:  .byte $04, $07                   ;Play note E1  for 7 frames.
LB3A5:  .byte $04, $1C                   ;Play note E1  for 28 frames.
LB3A7:  .byte $10, $1C                   ;Play note E2  for 28 frames.
LB3A9:  .byte $04, $1C                   ;Play note E1  for 28 frames.
LB3AB:  .byte $10, $1C                   ;Play note E2  for 28 frames.
LB3AD:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
LB3AF:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
LB3B1:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
LB3B3:  .byte $0B, $0E                   ;Play note B1  for 14 frames.
LB3B5:  .byte $10, $07                   ;Play note E2  for 7 frames.
LB3B7:  .byte $0E, $07                   ;Play note D2  for 7 frames.
LB3B9:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
LB3BB:  .byte $0B, $07                   ;Play note B1  for 7 frames.
LB3BD:  .byte CHN_SILENCE, $07           ;Silence channel for 7 frames.
LB3BF:  .byte $08, $07                   ;Play note G#1 for 7 frames.
LB3C1:  .byte $06, $07                   ;Play note F#1 for 7 frames.
LB3C3:  .byte $02, $07                   ;Play note D1  for 7 frames.
LB3C5:  .byte $04, $1C                   ;Play note E1  for 28 frames.
LB3C7:  .byte $10, $1C                   ;Play note E2  for 28 frames.
LB3C9:  .byte $04, $1C                   ;Play note E1  for 28 frames.
LB3CB:  .byte $10, $1C                   ;Play note E2  for 28 frames.
LB3CD:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
LB3CF:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
LB3D1:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
LB3D3:  .byte $0B, $0E                   ;Play note B1  for 14 frames.
LB3D5:  .byte $10, $07                   ;Play note E2  for 7 frames.
LB3D7:  .byte $0E, $07                   ;Play note D2  for 7 frames.
LB3D9:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
LB3DB:  .byte $0B, $07                   ;Play note B1  for 7 frames.
LB3DD:  .byte CHN_SILENCE, $07           ;Silence channel for 7 frames.
LB3DF:  .byte $08, $07                   ;Play note G#1 for 7 frames.
LB3E1:  .byte $06, $07                   ;Play note F#1 for 7 frames.
LB3E3:  .byte $02, $07                   ;Play note D1  for 7 frames.
LB3E5:  .byte $03, $07                   ;Play note D#1 for 7 frames.
LB3E7:  .byte $05, $07                   ;Play note F1  for 7 frames.
LB3E9:  .byte $06, $07                   ;Play note F#1 for 7 frames.
LB3EB:  .byte $08, $07                   ;Play note G#1 for 7 frames.
LB3ED:  .byte $0A, $07                   ;Play note A#1 for 7 frames.
LB3EF:  .byte $0C, $07                   ;Play note C2  for 7 frames.
LB3F1:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
LB3F3:  .byte $0F, $07                   ;Play note D#2 for 7 frames.
LB3F5:  .byte $05, $07                   ;Play note F1  for 7 frames.
LB3F7:  .byte $07, $07                   ;Play note G1  for 7 frames.
LB3F9:  .byte $08, $07                   ;Play note G#1 for 7 frames.
LB3FB:  .byte $0A, $07                   ;Play note A#1 for 7 frames.
LB3FD:  .byte $0C, $07                   ;Play note C2  for 7 frames.
LB3FF:  .byte $0E, $07                   ;Play note D2  for 7 frames.
LB401:  .byte $0F, $07                   ;Play note D#2 for 7 frames.
LB403:  .byte $11, $07                   ;Play note F2  for 7 frames.
LB405:  .byte $07, $07                   ;Play note G1  for 7 frames.
LB407:  .byte $09, $07                   ;Play note A1  for 7 frames.
LB409:  .byte $0A, $07                   ;Play note A#1 for 7 frames.
LB40B:  .byte $0C, $07                   ;Play note C2  for 7 frames.
LB40D:  .byte $0E, $07                   ;Play note D2  for 7 frames.
LB40F:  .byte $10, $07                   ;Play note E2  for 7 frames.
LB411:  .byte $11, $07                   ;Play note F2  for 7 frames.
LB413:  .byte $12, $07                   ;Play note F#2 for 7 frames.
LB415:  .byte $09, $07                   ;Play note A1  for 7 frames.
LB417:  .byte $0B, $07                   ;Play note B1  for 7 frames.
LB419:  .byte $0C, $07                   ;Play note C2  for 7 frames.
LB41B:  .byte $0E, $07                   ;Play note D2  for 7 frames.
LB41D:  .byte $10, $07                   ;Play note E2  for 7 frames.
LB41F:  .byte $11, $07                   ;Play note F2  for 7 frames.
LB421:  .byte $13, $07                   ;Play note G2  for 7 frames.
LB423:  .byte $14, $07                   ;Play note G#2 for 7 frames.
LB425:  .byte $03, $07                   ;Play note D#1 for 7 frames.
LB427:  .byte $05, $07                   ;Play note F1  for 7 frames.
LB429:  .byte $06, $07                   ;Play note F#1 for 7 frames.
LB42B:  .byte $08, $07                   ;Play note G#1 for 7 frames.
LB42D:  .byte $0A, $07                   ;Play note A#1 for 7 frames.
LB42F:  .byte $0C, $07                   ;Play note C2  for 7 frames.
LB431:  .byte $0D, $07                   ;Play note C#2 for 7 frames.
LB433:  .byte $0F, $07                   ;Play note D#2 for 7 frames.
LB435:  .byte $05, $07                   ;Play note F1  for 7 frames.
LB437:  .byte $07, $07                   ;Play note G1  for 7 frames.
LB439:  .byte $08, $07                   ;Play note G#1 for 7 frames.
LB43B:  .byte $0A, $07                   ;Play note A#1 for 7 frames.
LB43D:  .byte $0C, $07                   ;Play note C2  for 7 frames.
LB43F:  .byte $0E, $07                   ;Play note D2  for 7 frames.
LB441:  .byte $0F, $07                   ;Play note D#2 for 7 frames.
LB443:  .byte $11, $07                   ;Play note F2  for 7 frames.
LB445:  .byte $07, $07                   ;Play note G1  for 7 frames.
LB447:  .byte $09, $07                   ;Play note A1  for 7 frames.
LB449:  .byte $0A, $07                   ;Play note A#1 for 7 frames.
LB44B:  .byte $0C, $07                   ;Play note C2  for 7 frames.
LB44D:  .byte $0E, $07                   ;Play note D2  for 7 frames.
LB44F:  .byte $10, $07                   ;Play note E2  for 7 frames.
LB451:  .byte $11, $07                   ;Play note F2  for 7 frames.
LB453:  .byte $12, $07                   ;Play note F#2 for 7 frames.
LB455:  .byte $09, $07                   ;Play note A1  for 7 frames.
LB457:  .byte $0B, $07                   ;Play note B1  for 7 frames.
LB459:  .byte $0C, $07                   ;Play note C2  for 7 frames.
LB45B:  .byte $0E, $07                   ;Play note D2  for 7 frames.
LB45D:  .byte $10, $07                   ;Play note E2  for 7 frames.
LB45F:  .byte $11, $07                   ;Play note F2  for 7 frames.
LB461:  .byte $13, $07                   ;Play note G2  for 7 frames.
LB463:  .byte $14, $07                   ;Play note G#2 for 7 frames.
LB465:  .byte CHN_JUMP, $00, $1C, $FE    ;Jump back 484 bytes to $B281.

;----------------------------------------------------------------------------------------------------

;Used by LBCastle music SQ1.

SQ1Attack2E:
LB469:  .byte $08, $88, $8C, $90, $8E, $8C, $8A, $88, $87

SQ1Sustain2E:
LB472:  .byte $08, $88, $88, $88, $88, $88, $88, $88, $88

SQ1Release2E:
LB47B:  .byte $17, $88, $87, $87, $87, $86, $86, $86, $86, $86, $85, $85, $85, $85, $85, $85
LB48B:  .byte $84, $84, $84, $84, $84, $84, $84, $83

;----------------------------------------------------------------------------------------------------

;Used by LBCastle music SQ2.

SQ2Attack2F:
LB493:  .byte $04, $86, $89, $8C, $90

SQ2Sustain2F:
LB498:  .byte $04, $90, $8E, $90, $8E

SQ2Release2F:
LB49D:  .byte $0C, $8D, $89, $87, $86, $86, $85, $85, $84, $84, $83, $83, $82

;----------------------------------------------------------------------------------------------------

;Used by LBCastle music Triangle.

TriAttack30:
LB4AA:  .byte $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

TriSustain30:
LB4B3:  .byte $20, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
LB4C3:  .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
LB4D3:  .byte $0F

TriRelease30:
LB4D4:  .byte $04, $00, $00, $00, $00

;----------------------------------------------------------------------------------------------------

;Used by LBCastle music Triangle.

TriAttack31:
LB4D9:  .byte $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

TriSustain31:
LB4E2:  .byte $10, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $00, $00, $00
LB4F2:  .byte $00

TriRelease31:
LB4F3:  .byte $06, $00, $00, $00, $00, $00, $00

;----------------------------------------------------------------------------------------------------

;Castle of Lord British theme music SQ1 data.

LBCastleSQ1:
LB4FA:  .byte CHN_VOLUME, $0A            ;Set channel volume to 10.
LB4FC:  .byte CHN_VIBRATO, $00, $0F, $10 ;Set vibrato speed=15, intensity=16.
LB500:  .byte CHN_ASR, $2E               ;Set ASR data index to 46.
LB502:  .byte $24, $28                   ;Play note C5  for 40 frames.
LB504:  .byte $24, $14                   ;Play note C5  for 20 frames.
LB506:  .byte $24, $14                   ;Play note C5  for 20 frames.
LB508:  .byte $24, $14                   ;Play note C5  for 20 frames.
LB50A:  .byte $26, $14                   ;Play note D5  for 20 frames.
LB50C:  .byte $24, $14                   ;Play note C5  for 20 frames.
LB50E:  .byte $22, $14                   ;Play note A#4 for 20 frames.
LB510:  .byte $26, $28                   ;Play note D5  for 40 frames.
LB512:  .byte $22, $14                   ;Play note A#4 for 20 frames.
LB514:  .byte $22, $64                   ;Play note A#4 for 100 frames.
LB516:  .byte $24, $28                   ;Play note C5  for 40 frames.
LB518:  .byte $24, $14                   ;Play note C5  for 20 frames.
LB51A:  .byte $24, $14                   ;Play note C5  for 20 frames.
LB51C:  .byte $24, $14                   ;Play note C5  for 20 frames.
LB51E:  .byte $26, $14                   ;Play note D5  for 20 frames.
LB520:  .byte $24, $14                   ;Play note C5  for 20 frames.
LB522:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB524:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB526:  .byte $26, $78                   ;Play note D5  for 120 frames.
LB528:  .byte $22, $14                   ;Play note A#4 for 20 frames.
LB52A:  .byte $24, $14                   ;Play note C5  for 20 frames.
LB52C:  .byte $26, $14                   ;Play note D5  for 20 frames.
LB52E:  .byte $26, $14                   ;Play note D5  for 20 frames.
LB530:  .byte $26, $14                   ;Play note D5  for 20 frames.
LB532:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB534:  .byte $26, $28                   ;Play note D5  for 40 frames.
LB536:  .byte $29, $14                   ;Play note F5  for 20 frames.
LB538:  .byte $27, $0A                   ;Play note D#5 for 10 frames.
LB53A:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB53C:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB53E:  .byte $26, $14                   ;Play note D5  for 20 frames.
LB540:  .byte $26, $14                   ;Play note D5  for 20 frames.
LB542:  .byte $26, $14                   ;Play note D5  for 20 frames.
LB544:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB546:  .byte $26, $28                   ;Play note D5  for 40 frames.
LB548:  .byte $29, $14                   ;Play note F5  for 20 frames.
LB54A:  .byte $27, $0A                   ;Play note D#5 for 10 frames.
LB54C:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB54E:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB550:  .byte $26, $64                   ;Play note D5  for 100 frames.
LB552:  .byte $22, $28                   ;Play note A#4 for 40 frames.
LB554:  .byte $1F, $14                   ;Play note G4  for 20 frames.
LB556:  .byte $22, $1E                   ;Play note A#4 for 30 frames.
LB558:  .byte $24, $82                   ;Play note C5  for 130 frames.
LB55A:  .byte $24, $28                   ;Play note C5  for 40 frames.
LB55C:  .byte $24, $14                   ;Play note C5  for 20 frames.
LB55E:  .byte $24, $14                   ;Play note C5  for 20 frames.
LB560:  .byte $24, $14                   ;Play note C5  for 20 frames.
LB562:  .byte $26, $14                   ;Play note D5  for 20 frames.
LB564:  .byte $24, $14                   ;Play note C5  for 20 frames.
LB566:  .byte $22, $14                   ;Play note A#4 for 20 frames.
LB568:  .byte $26, $28                   ;Play note D5  for 40 frames.
LB56A:  .byte $22, $14                   ;Play note A#4 for 20 frames.
LB56C:  .byte $22, $64                   ;Play note A#4 for 100 frames.
LB56E:  .byte $24, $28                   ;Play note C5  for 40 frames.
LB570:  .byte $24, $14                   ;Play note C5  for 20 frames.
LB572:  .byte $24, $14                   ;Play note C5  for 20 frames.
LB574:  .byte $24, $14                   ;Play note C5  for 20 frames.
LB576:  .byte $26, $14                   ;Play note D5  for 20 frames.
LB578:  .byte $24, $14                   ;Play note C5  for 20 frames.
LB57A:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB57C:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB57E:  .byte $26, $78                   ;Play note D5  for 120 frames.
LB580:  .byte $22, $14                   ;Play note A#4 for 20 frames.
LB582:  .byte $24, $14                   ;Play note C5  for 20 frames.
LB584:  .byte $26, $14                   ;Play note D5  for 20 frames.
LB586:  .byte $26, $14                   ;Play note D5  for 20 frames.
LB588:  .byte $26, $14                   ;Play note D5  for 20 frames.
LB58A:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB58C:  .byte $26, $28                   ;Play note D5  for 40 frames.
LB58E:  .byte $29, $14                   ;Play note F5  for 20 frames.
LB590:  .byte $27, $0A                   ;Play note D#5 for 10 frames.
LB592:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB594:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB596:  .byte $26, $14                   ;Play note D5  for 20 frames.
LB598:  .byte $26, $14                   ;Play note D5  for 20 frames.
LB59A:  .byte $26, $14                   ;Play note D5  for 20 frames.
LB59C:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB59E:  .byte $26, $28                   ;Play note D5  for 40 frames.
LB5A0:  .byte $29, $14                   ;Play note F5  for 20 frames.
LB5A2:  .byte $27, $0A                   ;Play note D#5 for 10 frames.
LB5A4:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB5A6:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB5A8:  .byte $26, $64                   ;Play note D5  for 100 frames.
LB5AA:  .byte $22, $28                   ;Play note A#4 for 40 frames.
LB5AC:  .byte $1F, $14                   ;Play note G4  for 20 frames.
LB5AE:  .byte $22, $1E                   ;Play note A#4 for 30 frames.
LB5B0:  .byte $24, $82                   ;Play note C5  for 130 frames.
LB5B2:  .byte CHN_VOLUME, $0C            ;Set channel volume to 12.
LB5B4:  .byte $2B, $50                   ;Play note G5  for 80 frames.
LB5B6:  .byte $2B, $14                   ;Play note G5  for 20 frames.
LB5B8:  .byte $29, $14                   ;Play note F5  for 20 frames.
LB5BA:  .byte $29, $14                   ;Play note F5  for 20 frames.
LB5BC:  .byte $22, $14                   ;Play note A#4 for 20 frames.
LB5BE:  .byte $24, $14                   ;Play note C5  for 20 frames.
LB5C0:  .byte $26, $14                   ;Play note D5  for 20 frames.
LB5C2:  .byte $27, $14                   ;Play note D#5 for 20 frames.
LB5C4:  .byte $26, $64                   ;Play note D5  for 100 frames.
LB5C6:  .byte $2B, $50                   ;Play note G5  for 80 frames.
LB5C8:  .byte $2B, $14                   ;Play note G5  for 20 frames.
LB5CA:  .byte $29, $14                   ;Play note F5  for 20 frames.
LB5CC:  .byte $29, $14                   ;Play note F5  for 20 frames.
LB5CE:  .byte $22, $14                   ;Play note A#4 for 20 frames.
LB5D0:  .byte $24, $78                   ;Play note C5  for 120 frames.
LB5D2:  .byte $2D, $14                   ;Play note A5  for 20 frames.
LB5D4:  .byte $2E, $14                   ;Play note A#5 for 20 frames.
LB5D6:  .byte CHN_VOLUME, $0E            ;Set channel volume to 14.
LB5D8:  .byte $2D, $14                   ;Play note A5  for 20 frames.
LB5DA:  .byte $2B, $3C                   ;Play note G5  for 60 frames.
LB5DC:  .byte $29, $3C                   ;Play note F5  for 60 frames.
LB5DE:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB5E0:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB5E2:  .byte $26, $50                   ;Play note D5  for 80 frames.
LB5E4:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB5E6:  .byte $2D, $28                   ;Play note A5  for 40 frames.
LB5E8:  .byte $2E, $14                   ;Play note A#5 for 20 frames.
LB5EA:  .byte $2D, $14                   ;Play note A5  for 20 frames.
LB5EC:  .byte $2B, $64                   ;Play note G5  for 100 frames.
LB5EE:  .byte $2D, $14                   ;Play note A5  for 20 frames.
LB5F0:  .byte $2E, $14                   ;Play note A#5 for 20 frames.
LB5F2:  .byte $2B, $14                   ;Play note G5  for 20 frames.
LB5F4:  .byte $29, $8C                   ;Play note F5  for 140 frames.
LB5F6:  .byte CHN_JUMP, $00, $04, $FF    ;Jump back 252 bytes to $B4FA.

;----------------------------------------------------------------------------------------------------

;Castle of Lord British theme music SQ2 data.

LBCastleSQ2:
LB5FA:  .byte CHN_VOLUME, $08            ;Set channel volume to 8.
LB5FC:  .byte CHN_VIBRATO, $00, $00, $80 ;Set vibrato speed=0, intensity=128.
LB600:  .byte CHN_ASR, $2F               ;Set ASR data index to 47.
LB602:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB604:  .byte $2B, $0A                   ;Play note G5  for 10 frames.
LB606:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB608:  .byte $27, $0A                   ;Play note D#5 for 10 frames.
LB60A:  .byte $2B, $0A                   ;Play note G5  for 10 frames.
LB60C:  .byte $27, $0A                   ;Play note D#5 for 10 frames.
LB60E:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB610:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB612:  .byte $2A, $0A                   ;Play note F#5 for 10 frames.
LB614:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB616:  .byte $27, $0A                   ;Play note D#5 for 10 frames.
LB618:  .byte $2A, $0A                   ;Play note F#5 for 10 frames.
LB61A:  .byte $27, $0A                   ;Play note D#5 for 10 frames.
LB61C:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB61E:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB620:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB622:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB624:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB626:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB628:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB62A:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB62C:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB62E:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB630:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB632:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB634:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB636:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB638:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB63A:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB63C:  .byte $2B, $0A                   ;Play note G5  for 10 frames.
LB63E:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB640:  .byte $27, $0A                   ;Play note D#5 for 10 frames.
LB642:  .byte $2B, $0A                   ;Play note G5  for 10 frames.
LB644:  .byte $27, $0A                   ;Play note D#5 for 10 frames.
LB646:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB648:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB64A:  .byte $2A, $0A                   ;Play note F#5 for 10 frames.
LB64C:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB64E:  .byte $27, $0A                   ;Play note D#5 for 10 frames.
LB650:  .byte $2A, $0A                   ;Play note F#5 for 10 frames.
LB652:  .byte $27, $0A                   ;Play note D#5 for 10 frames.
LB654:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB656:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB658:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB65A:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB65C:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB65E:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB660:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB662:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB664:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB666:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB668:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB66A:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB66C:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB66E:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB670:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB672:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB674:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB676:  .byte $1F, $0A                   ;Play note G4  for 10 frames.
LB678:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB67A:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB67C:  .byte $1F, $0A                   ;Play note G4  for 10 frames.
LB67E:  .byte $1B, $0A                   ;Play note D#4 for 10 frames.
LB680:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB682:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB684:  .byte $1D, $0A                   ;Play note F4  for 10 frames.
LB686:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB688:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB68A:  .byte $1D, $0A                   ;Play note F4  for 10 frames.
LB68C:  .byte $1A, $0A                   ;Play note D4  for 10 frames.
LB68E:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB690:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB692:  .byte $1F, $0A                   ;Play note G4  for 10 frames.
LB694:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB696:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB698:  .byte $1F, $0A                   ;Play note G4  for 10 frames.
LB69A:  .byte $1B, $0A                   ;Play note D#4 for 10 frames.
LB69C:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB69E:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB6A0:  .byte $1D, $0A                   ;Play note F4  for 10 frames.
LB6A2:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB6A4:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB6A6:  .byte $1D, $0A                   ;Play note F4  for 10 frames.
LB6A8:  .byte $1A, $0A                   ;Play note D4  for 10 frames.
LB6AA:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB6AC:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB6AE:  .byte $1F, $0A                   ;Play note G4  for 10 frames.
LB6B0:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB6B2:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB6B4:  .byte $1F, $0A                   ;Play note G4  for 10 frames.
LB6B6:  .byte $1B, $0A                   ;Play note D#4 for 10 frames.
LB6B8:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB6BA:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB6BC:  .byte $1F, $0A                   ;Play note G4  for 10 frames.
LB6BE:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB6C0:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB6C2:  .byte $1F, $0A                   ;Play note G4  for 10 frames.
LB6C4:  .byte $1B, $0A                   ;Play note D#4 for 10 frames.
LB6C6:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB6C8:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB6CA:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB6CC:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB6CE:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB6D0:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB6D2:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB6D4:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB6D6:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB6D8:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB6DA:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB6DC:  .byte $21, $0A                   ;Play note A4  for 10 frames.
LB6DE:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB6E0:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB6E2:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB6E4:  .byte $2B, $0A                   ;Play note G5  for 10 frames.
LB6E6:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB6E8:  .byte $27, $0A                   ;Play note D#5 for 10 frames.
LB6EA:  .byte $2B, $0A                   ;Play note G5  for 10 frames.
LB6EC:  .byte $27, $0A                   ;Play note D#5 for 10 frames.
LB6EE:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB6F0:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB6F2:  .byte $2A, $0A                   ;Play note F#5 for 10 frames.
LB6F4:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB6F6:  .byte $27, $0A                   ;Play note D#5 for 10 frames.
LB6F8:  .byte $2A, $0A                   ;Play note F#5 for 10 frames.
LB6FA:  .byte $27, $0A                   ;Play note D#5 for 10 frames.
LB6FC:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB6FE:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB700:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB702:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB704:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB706:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB708:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB70A:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB70C:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB70E:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB710:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB712:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB714:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB716:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB718:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB71A:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB71C:  .byte $2B, $0A                   ;Play note G5  for 10 frames.
LB71E:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB720:  .byte $27, $0A                   ;Play note D#5 for 10 frames.
LB722:  .byte $2B, $0A                   ;Play note G5  for 10 frames.
LB724:  .byte $27, $0A                   ;Play note D#5 for 10 frames.
LB726:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB728:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB72A:  .byte $2A, $0A                   ;Play note F#5 for 10 frames.
LB72C:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB72E:  .byte $27, $0A                   ;Play note D#5 for 10 frames.
LB730:  .byte $2A, $0A                   ;Play note F#5 for 10 frames.
LB732:  .byte $27, $0A                   ;Play note D#5 for 10 frames.
LB734:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB736:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB738:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB73A:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB73C:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB73E:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB740:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB742:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB744:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB746:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB748:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB74A:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB74C:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB74E:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB750:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB752:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB754:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB756:  .byte $1F, $0A                   ;Play note G4  for 10 frames.
LB758:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB75A:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB75C:  .byte $1F, $0A                   ;Play note G4  for 10 frames.
LB75E:  .byte $1B, $0A                   ;Play note D#4 for 10 frames.
LB760:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB762:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB764:  .byte $1D, $0A                   ;Play note F4  for 10 frames.
LB766:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB768:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB76A:  .byte $1D, $0A                   ;Play note F4  for 10 frames.
LB76C:  .byte $1A, $0A                   ;Play note D4  for 10 frames.
LB76E:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB770:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB772:  .byte $1F, $0A                   ;Play note G4  for 10 frames.
LB774:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB776:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB778:  .byte $1F, $0A                   ;Play note G4  for 10 frames.
LB77A:  .byte $1B, $0A                   ;Play note D#4 for 10 frames.
LB77C:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB77E:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB780:  .byte $1D, $0A                   ;Play note F4  for 10 frames.
LB782:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB784:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB786:  .byte $1D, $0A                   ;Play note F4  for 10 frames.
LB788:  .byte $1A, $0A                   ;Play note D4  for 10 frames.
LB78A:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB78C:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB78E:  .byte $1F, $0A                   ;Play note G4  for 10 frames.
LB790:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB792:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB794:  .byte $1F, $0A                   ;Play note G4  for 10 frames.
LB796:  .byte $1B, $0A                   ;Play note D#4 for 10 frames.
LB798:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB79A:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB79C:  .byte $1F, $0A                   ;Play note G4  for 10 frames.
LB79E:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB7A0:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB7A2:  .byte $1F, $0A                   ;Play note G4  for 10 frames.
LB7A4:  .byte $1B, $0A                   ;Play note D#4 for 10 frames.
LB7A6:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB7A8:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB7AA:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB7AC:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB7AE:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB7B0:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB7B2:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB7B4:  .byte CHN_SILENCE, $14           ;Silence channel for 20 frames.
LB7B6:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB7B8:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB7BA:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB7BC:  .byte $21, $0A                   ;Play note A4  for 10 frames.
LB7BE:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB7C0:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB7C2:  .byte $1F, $50                   ;Play note G4  for 80 frames.
LB7C4:  .byte $1F, $14                   ;Play note G4  for 20 frames.
LB7C6:  .byte $1D, $14                   ;Play note F4  for 20 frames.
LB7C8:  .byte $1D, $14                   ;Play note F4  for 20 frames.
LB7CA:  .byte $16, $14                   ;Play note A#3 for 20 frames.
LB7CC:  .byte $18, $14                   ;Play note C4  for 20 frames.
LB7CE:  .byte $1A, $14                   ;Play note D4  for 20 frames.
LB7D0:  .byte $1B, $14                   ;Play note D#4 for 20 frames.
LB7D2:  .byte $1A, $64                   ;Play note D4  for 100 frames.
LB7D4:  .byte $1F, $50                   ;Play note G4  for 80 frames.
LB7D6:  .byte $1F, $14                   ;Play note G4  for 20 frames.
LB7D8:  .byte $1D, $14                   ;Play note F4  for 20 frames.
LB7DA:  .byte $1D, $14                   ;Play note F4  for 20 frames.
LB7DC:  .byte $16, $14                   ;Play note A#3 for 20 frames.
LB7DE:  .byte $18, $78                   ;Play note C4  for 120 frames.
LB7E0:  .byte $21, $14                   ;Play note A4  for 20 frames.
LB7E2:  .byte $22, $14                   ;Play note A#4 for 20 frames.
LB7E4:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB7E6:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB7E8:  .byte $1F, $0A                   ;Play note G4  for 10 frames.
LB7EA:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB7EC:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB7EE:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB7F0:  .byte $1F, $0A                   ;Play note G4  for 10 frames.
LB7F2:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB7F4:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB7F6:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB7F8:  .byte $21, $0A                   ;Play note A4  for 10 frames.
LB7FA:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB7FC:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB7FE:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB800:  .byte $21, $0A                   ;Play note A4  for 10 frames.
LB802:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB804:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB806:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB808:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB80A:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB80C:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB80E:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB810:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB812:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB814:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB816:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB818:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB81A:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB81C:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB81E:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB820:  .byte $26, $0A                   ;Play note D5  for 10 frames.
LB822:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB824:  .byte $2B, $0A                   ;Play note G5  for 10 frames.
LB826:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB828:  .byte $27, $0A                   ;Play note D#5 for 10 frames.
LB82A:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB82C:  .byte $2B, $0A                   ;Play note G5  for 10 frames.
LB82E:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB830:  .byte $27, $0A                   ;Play note D#5 for 10 frames.
LB832:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB834:  .byte $2B, $0A                   ;Play note G5  for 10 frames.
LB836:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB838:  .byte $27, $0A                   ;Play note D#5 for 10 frames.
LB83A:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB83C:  .byte $2B, $0A                   ;Play note G5  for 10 frames.
LB83E:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB840:  .byte $27, $0A                   ;Play note D#5 for 10 frames.
LB842:  .byte $22, $0A                   ;Play note A#4 for 10 frames.
LB844:  .byte $2D, $0A                   ;Play note A5  for 10 frames.
LB846:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB848:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB84A:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB84C:  .byte $2D, $0A                   ;Play note A5  for 10 frames.
LB84E:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB850:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB852:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB854:  .byte $2D, $0A                   ;Play note A5  for 10 frames.
LB856:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB858:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB85A:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB85C:  .byte $2D, $0A                   ;Play note A5  for 10 frames.
LB85E:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB860:  .byte $29, $0A                   ;Play note F5  for 10 frames.
LB862:  .byte $24, $0A                   ;Play note C5  for 10 frames.
LB864:  .byte CHN_JUMP, $00, $96, $FD    ;Jump back 618 bytes to $B5FA.

;----------------------------------------------------------------------------------------------------

;Castle of Lord British theme music Triangle data.

LBCastleTri:
LB868:  .byte CHN_VOLUME, $0F            ;Set channel volume to 15.
LB86A:  .byte CHN_VIBRATO, $00, $00, $80 ;Set vibrato speed=0, intensity=128.
LB86E:  .byte CHN_ASR, $30               ;Set ASR data index to 48.
LB870:  .byte $0A, $3C                   ;Play note A#1 for 60 frames.
LB872:  .byte $0A, $14                   ;Play note A#1 for 20 frames.
LB874:  .byte $0A, $50                   ;Play note A#1 for 80 frames.
LB876:  .byte $0A, $3C                   ;Play note A#1 for 60 frames.
LB878:  .byte $0A, $14                   ;Play note A#1 for 20 frames.
LB87A:  .byte $0A, $50                   ;Play note A#1 for 80 frames.
LB87C:  .byte $0A, $3C                   ;Play note A#1 for 60 frames.
LB87E:  .byte $0A, $14                   ;Play note A#1 for 20 frames.
LB880:  .byte $0A, $50                   ;Play note A#1 for 80 frames.
LB882:  .byte $0A, $3C                   ;Play note A#1 for 60 frames.
LB884:  .byte $0A, $14                   ;Play note A#1 for 20 frames.
LB886:  .byte $0A, $50                   ;Play note A#1 for 80 frames.
LB888:  .byte $0F, $3C                   ;Play note D#2 for 60 frames.
LB88A:  .byte $0F, $14                   ;Play note D#2 for 20 frames.
LB88C:  .byte $0E, $3C                   ;Play note D2  for 60 frames.
LB88E:  .byte $0E, $14                   ;Play note D2  for 20 frames.
LB890:  .byte $0C, $3C                   ;Play note C2  for 60 frames.
LB892:  .byte $0C, $14                   ;Play note C2  for 20 frames.
LB894:  .byte $0E, $3C                   ;Play note D2  for 60 frames.
LB896:  .byte $0E, $14                   ;Play note D2  for 20 frames.
LB898:  .byte $0F, $3C                   ;Play note D#2 for 60 frames.
LB89A:  .byte $0F, $14                   ;Play note D#2 for 20 frames.
LB89C:  .byte $0F, $3C                   ;Play note D#2 for 60 frames.
LB89E:  .byte $0F, $14                   ;Play note D#2 for 20 frames.
LB8A0:  .byte $11, $3C                   ;Play note F2  for 60 frames.
LB8A2:  .byte $11, $14                   ;Play note F2  for 20 frames.
LB8A4:  .byte $11, $3C                   ;Play note F2  for 60 frames.
LB8A6:  .byte $11, $14                   ;Play note F2  for 20 frames.
LB8A8:  .byte $0A, $3C                   ;Play note A#1 for 60 frames.
LB8AA:  .byte $0A, $14                   ;Play note A#1 for 20 frames.
LB8AC:  .byte $0A, $50                   ;Play note A#1 for 80 frames.
LB8AE:  .byte $0A, $3C                   ;Play note A#1 for 60 frames.
LB8B0:  .byte $0A, $14                   ;Play note A#1 for 20 frames.
LB8B2:  .byte $0A, $50                   ;Play note A#1 for 80 frames.
LB8B4:  .byte $0A, $3C                   ;Play note A#1 for 60 frames.
LB8B6:  .byte $0A, $14                   ;Play note A#1 for 20 frames.
LB8B8:  .byte $0A, $50                   ;Play note A#1 for 80 frames.
LB8BA:  .byte $0A, $3C                   ;Play note A#1 for 60 frames.
LB8BC:  .byte $0A, $14                   ;Play note A#1 for 20 frames.
LB8BE:  .byte $0A, $50                   ;Play note A#1 for 80 frames.
LB8C0:  .byte $0F, $3C                   ;Play note D#2 for 60 frames.
LB8C2:  .byte $0F, $14                   ;Play note D#2 for 20 frames.
LB8C4:  .byte $0E, $3C                   ;Play note D2  for 60 frames.
LB8C6:  .byte $0E, $14                   ;Play note D2  for 20 frames.
LB8C8:  .byte $0C, $3C                   ;Play note C2  for 60 frames.
LB8CA:  .byte $0C, $14                   ;Play note C2  for 20 frames.
LB8CC:  .byte $0E, $3C                   ;Play note D2  for 60 frames.
LB8CE:  .byte $0E, $14                   ;Play note D2  for 20 frames.
LB8D0:  .byte $0F, $3C                   ;Play note D#2 for 60 frames.
LB8D2:  .byte $0F, $14                   ;Play note D#2 for 20 frames.
LB8D4:  .byte $0F, $3C                   ;Play note D#2 for 60 frames.
LB8D6:  .byte $0F, $14                   ;Play note D#2 for 20 frames.
LB8D8:  .byte $11, $3C                   ;Play note F2  for 60 frames.
LB8DA:  .byte $11, $14                   ;Play note F2  for 20 frames.
LB8DC:  .byte $11, $3C                   ;Play note F2  for 60 frames.
LB8DE:  .byte $11, $14                   ;Play note F2  for 20 frames.
LB8E0:  .byte CHN_ASR, $31               ;Set ASR data index to 49.
LB8E2:  .byte $0F, $14                   ;Play note D#2 for 20 frames.
LB8E4:  .byte $0F, $14                   ;Play note D#2 for 20 frames.
LB8E6:  .byte $0F, $14                   ;Play note D#2 for 20 frames.
LB8E8:  .byte $0F, $14                   ;Play note D#2 for 20 frames.
LB8EA:  .byte $0C, $14                   ;Play note C2  for 20 frames.
LB8EC:  .byte $0C, $14                   ;Play note C2  for 20 frames.
LB8EE:  .byte $0C, $14                   ;Play note C2  for 20 frames.
LB8F0:  .byte $0C, $14                   ;Play note C2  for 20 frames.
LB8F2:  .byte $05, $14                   ;Play note F1  for 20 frames.
LB8F4:  .byte $05, $14                   ;Play note F1  for 20 frames.
LB8F6:  .byte $05, $14                   ;Play note F1  for 20 frames.
LB8F8:  .byte $05, $14                   ;Play note F1  for 20 frames.
LB8FA:  .byte $0A, $14                   ;Play note A#1 for 20 frames.
LB8FC:  .byte $0A, $14                   ;Play note A#1 for 20 frames.
LB8FE:  .byte $0A, $14                   ;Play note A#1 for 20 frames.
LB900:  .byte $0A, $14                   ;Play note A#1 for 20 frames.
LB902:  .byte $0F, $14                   ;Play note D#2 for 20 frames.
LB904:  .byte $0F, $14                   ;Play note D#2 for 20 frames.
LB906:  .byte $0F, $14                   ;Play note D#2 for 20 frames.
LB908:  .byte $0F, $14                   ;Play note D#2 for 20 frames.
LB90A:  .byte $0E, $14                   ;Play note D2  for 20 frames.
LB90C:  .byte $0E, $14                   ;Play note D2  for 20 frames.
LB90E:  .byte $0E, $14                   ;Play note D2  for 20 frames.
LB910:  .byte $0E, $14                   ;Play note D2  for 20 frames.
LB912:  .byte $0C, $14                   ;Play note C2  for 20 frames.
LB914:  .byte $0C, $14                   ;Play note C2  for 20 frames.
LB916:  .byte $0C, $14                   ;Play note C2  for 20 frames.
LB918:  .byte $0C, $14                   ;Play note C2  for 20 frames.
LB91A:  .byte $05, $14                   ;Play note F1  for 20 frames.
LB91C:  .byte $05, $14                   ;Play note F1  for 20 frames.
LB91E:  .byte $05, $14                   ;Play note F1  for 20 frames.
LB920:  .byte $05, $14                   ;Play note F1  for 20 frames.
LB922:  .byte $07, $14                   ;Play note G1  for 20 frames.
LB924:  .byte $07, $14                   ;Play note G1  for 20 frames.
LB926:  .byte $07, $0A                   ;Play note G1  for 10 frames.
LB928:  .byte $07, $0A                   ;Play note G1  for 10 frames.
LB92A:  .byte $07, $0A                   ;Play note G1  for 10 frames.
LB92C:  .byte $07, $0A                   ;Play note G1  for 10 frames.
LB92E:  .byte $09, $14                   ;Play note A1  for 20 frames.
LB930:  .byte $09, $14                   ;Play note A1  for 20 frames.
LB932:  .byte $09, $0A                   ;Play note A1  for 10 frames.
LB934:  .byte $09, $0A                   ;Play note A1  for 10 frames.
LB936:  .byte $09, $0A                   ;Play note A1  for 10 frames.
LB938:  .byte $09, $0A                   ;Play note A1  for 10 frames.
LB93A:  .byte $0A, $14                   ;Play note A#1 for 20 frames.
LB93C:  .byte $0A, $14                   ;Play note A#1 for 20 frames.
LB93E:  .byte $0A, $0A                   ;Play note A#1 for 10 frames.
LB940:  .byte $0A, $0A                   ;Play note A#1 for 10 frames.
LB942:  .byte $0A, $0A                   ;Play note A#1 for 10 frames.
LB944:  .byte $0A, $0A                   ;Play note A#1 for 10 frames.
LB946:  .byte $0E, $14                   ;Play note D2  for 20 frames.
LB948:  .byte $0E, $14                   ;Play note D2  for 20 frames.
LB94A:  .byte $0E, $0A                   ;Play note D2  for 10 frames.
LB94C:  .byte $0E, $0A                   ;Play note D2  for 10 frames.
LB94E:  .byte $0E, $0A                   ;Play note D2  for 10 frames.
LB950:  .byte $0E, $0A                   ;Play note D2  for 10 frames.
LB952:  .byte $0F, $14                   ;Play note D#2 for 20 frames.
LB954:  .byte $0F, $14                   ;Play note D#2 for 20 frames.
LB956:  .byte $0F, $0A                   ;Play note D#2 for 10 frames.
LB958:  .byte $0F, $0A                   ;Play note D#2 for 10 frames.
LB95A:  .byte $0F, $0A                   ;Play note D#2 for 10 frames.
LB95C:  .byte $0F, $0A                   ;Play note D#2 for 10 frames.
LB95E:  .byte $0F, $14                   ;Play note D#2 for 20 frames.
LB960:  .byte $0F, $14                   ;Play note D#2 for 20 frames.
LB962:  .byte $0F, $0A                   ;Play note D#2 for 10 frames.
LB964:  .byte $0F, $0A                   ;Play note D#2 for 10 frames.
LB966:  .byte $0F, $0A                   ;Play note D#2 for 10 frames.
LB968:  .byte $0F, $0A                   ;Play note D#2 for 10 frames.
LB96A:  .byte $05, $14                   ;Play note F1  for 20 frames.
LB96C:  .byte $05, $14                   ;Play note F1  for 20 frames.
LB96E:  .byte $05, $0A                   ;Play note F1  for 10 frames.
LB970:  .byte $05, $0A                   ;Play note F1  for 10 frames.
LB972:  .byte $05, $0A                   ;Play note F1  for 10 frames.
LB974:  .byte $05, $0A                   ;Play note F1  for 10 frames.
LB976:  .byte $05, $14                   ;Play note F1  for 20 frames.
LB978:  .byte $05, $14                   ;Play note F1  for 20 frames.
LB97A:  .byte $05, $0A                   ;Play note F1  for 10 frames.
LB97C:  .byte $05, $0A                   ;Play note F1  for 10 frames.
LB97E:  .byte $05, $0A                   ;Play note F1  for 10 frames.
LB980:  .byte $05, $0A                   ;Play note F1  for 10 frames.
LB982:  .byte CHN_JUMP, $00, $E6, $FE    ;Jump back 282 bytes to $B868.

;----------------------------------------------------------------------------------------------------

;Unused.
LB986:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB996:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB9A6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB9B6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB9C6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB9D6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB9E6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB9F6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBA06:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBA16:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBA26:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBA36:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBA46:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBA56:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBA66:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBA76:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBA86:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBA96:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBAA6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBAB6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBAC6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBAD6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBAE6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBAF6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBB06:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBB16:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBB26:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBB36:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBB46:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBB56:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBB66:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBB76:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBB86:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBB96:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBBA6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBBB6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBBC6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBBD6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBBE6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBBF6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBC06:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBC16:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBC26:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBC36:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBC46:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBC56:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBC66:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBC76:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBC86:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBC96:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBCA6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBCB6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBCC6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBCD6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBCE6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBCF6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBD06:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBD16:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBD26:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBD36:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBD46:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBD56:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBD66:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBD76:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBD86:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBD96:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBDA6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBDB6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBDC6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBDD6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBDE6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBDF6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBE06:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBE16:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBE26:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBE36:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBE46:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBE56:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBE66:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBE76:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBE86:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBE96:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBEA6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBEB6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBEC6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBED6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBEE6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBEF6:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBF06:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBF16:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBF26:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBF36:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBF46:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBF56:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBF66:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBF76:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBF86:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBF96:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

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
