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
L8000:  CMP MusCurrent
L8003:  BNE +
L8005:  RTS

L8006:* STA MusCurrent
L8009:  SEC
L800A:  SBC #MUS_INTRO
L800C:  BCS +
L800E:  LDA #$01

GetMusPointers:
L8010:* ASL                     ;
L8011:  ASL                     ;
L8012:  ASL                     ;*8. 8 bytes of data for music pointers(1 word per channel).
L8013:  TAY                     ;

L8014:  LDA MusicPtrTbl,Y       ;
L8017:  STA SQ1DatPtrLB         ;
L8019:  INY                     ;
L801A:  LDA MusicPtrTbl,Y       ;
L801D:  STA SQ1DatPtrUB         ;
L801F:  INY                     ;
L8020:  LDA MusicPtrTbl,Y       ;
L8023:  STA SQ2DatPtrLB         ;
L8025:  INY                     ;
L8026:  LDA MusicPtrTbl,Y       ;
L8029:  STA SQ2DatPtrUB         ;Load pointer data for the desired music from the table below.
L802B:  INY                     ;
L802C:  LDA MusicPtrTbl,Y       ;
L802F:  STA TriDatPtrLB         ;
L8031:  INY                     ;
L8032:  LDA MusicPtrTbl,Y       ;
L8035:  STA TriDatPtrUB         ;
L8037:  INY                     ;
L8038:  LDA MusicPtrTbl,Y       ;
L803B:  STA NseDatPtrLB         ;
L803D:  INY                     ;
L803E:  LDA MusicPtrTbl,Y       ;
L8041:  STA NseDatPtrUB         ;

L8043:  LDA #$01                ;
L8045:  STA SQ1LenCounter       ;
L8048:  STA SQ2LenCounter       ;Set all counters to expire so all channels update immediately.
L804B:  STA TriLenCounter       ;
L804E:  STA NseLenCounter       ;
L8051:  RTS                     ;

;----------------------------------------------------------------------------------------------------

;The following table contains the pointers to the music channel data for the various songs.
;The first word is for the SQ1 data, followed by SQ2, tiangle and noise data, respectively.

MusicPtrTbl:
L8052:  .word $8797,     $8C07,     $9173,     MusNone   ;Character creation music.
L8059:  .word MusNone,   MusNone,   MusNone,   MusNone   ;Silence music.
L8062:  .word $98D1,     $98DD,     $98EB,     $98FD     ;Exodus heart beat music.
L8069:  .word $9840,     $985A,     MusNone,   MusNone   ;Silver horn music.
L8072:  .word $9874,     MusNone,   MusNone-3, $A74B     ;Not used.
L8079:  .word $A803,     $A903,     MusNone-3, $AA52     ;Not used.
L8082:  .word $AB56,     $AC5A,     MusNone-3, $B2DE     ;Not used.
L8089:  .word $B4E2,     $B6DA,     MusNone-3, $ADB3     ;Not used.
L8092:  .word $AEB3,     $B121,     MusNone-3, MusNone-3 ;Not used.
L8099:  .word MusNone-3, MusNone-3, MusNone-3            ;Not used.

;----------------------------------------------------------------------------------------------------

;Unused.
L80A0:  .byte $78, $04, $00, $00, $40, $80, $80, $7C, $00, $00, $00, $00, $00, $00, $00, $00
L80B0:  .byte $20, $10, $FE, $08, $04, $40, $40, $3C, $00, $00, $00, $00, $00, $00, $00, $00
L80C0:  .byte $40, $40, $40, $40, $40, $40, $44, $38, $00, $00, $00, $00, $00, $00, $00, $00
L80D0:  .byte $08, $FE, $08, $38, $48, $38, $08, $30, $00, $00, $00, $00, $00, $00, $00, $00
L80E0:  .byte $44, $44, $FE, $44, $44, $40, $42, $3C, $00, $00, $00, $00, $00, $00, $00, $00
L80F0:  .byte $78, $10, $20, $FE, $10, $20, $22, $1C, $00, $00, $00, $00, $00, $00, $00, $00

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
L821F:  STA GenPtrF1UB          ;

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
L8241:  STA GenPtrF1UB          ;

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
L825E:  STA GenPtrF1UB          ;

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
L82D4:  LDA ($F2,X)
L82D6:  CMP #$FE
L82D8:  BNE L82DD
L82DA:  JMP L8400
L82DD:  CMP #$F0
L82DF:  BCS L82F0
L82E1:  CPX #$08
L82E3:  BCC L82ED
L82E5:  BEQ L82EA
L82E7:  JMP L851D
L82EA:  JMP L8452
L82ED:  JMP L8452
L82F0:  CMP #$FF
L82F2:  BEQ L8312
L82F4:  CMP #$FC
L82F6:  BNE L82FB
L82F8:  JMP L8336
L82FB:  CMP #$FD
L82FD:  BNE L8302
L82FF:  JMP L83A7
L8302:  CMP #$FB
L8304:  BNE L8309
L8306:  JMP L8393

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
L831A:  BCC +                   ;This function jumps the data pointer to a new location.-->
L831C:  INC ChnDatPtrUB,X       ;The control byte if $FF followed by $00. The next 2-->
L831E:* STA ChnDatPtrLB,X       ;Bytes are the amount of bytes to jump the pointer. Those-->
L8320:  PLA                     ;bytes are typically going to be in 2's compliment as the-->
L8321:  CLC                     ;pointer will most likely jump backwards. The point of-->
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


L8336:  INC $F2,X
L8338:  BNE L833C
L833A:  INC $F3,X

L833C:  LDA ($F2,X)
L833E:  SEC
L833F:  SBC #$32
L8341:  ASL
L8342:  TAY

L8343:  LDA AttackPtrTbl,Y      ;
L8346:  STA AttackDatPtrLB,X    ;
L8349:  STA GenPtrF4LB          ;Update the attack data pointer for the channel.
L834B:  LDA AttackPtrTbl+1,Y    ;
L834E:  STA AttackDatPtrUB,X    ;
L8351:  STA GenPtrF5UB          ;

L8353:  STY $F8
L8355:  LDY #$00
L8357:  LDA ($F4),Y
L8359:  STA $7630,X
L835C:  LDY $F8
L835E:  LDA $8660,Y
L8361:  STA $7612,X
L8364:  STA $F4
L8366:  LDA $8661,Y
L8369:  STA $7613,X
L836C:  STA $F5
L836E:  STY $F8
L8370:  LDY #$00
L8372:  LDA ($F4),Y
L8374:  STA $7631,X
L8377:  LDY $F8
L8379:  LDA $867A,Y
L837C:  STA $7620,X
L837F:  STA $F4
L8381:  LDA $867B,Y
L8384:  STA $7621,X
L8387:  STA $F5
L8389:  LDY #$00
L838B:  LDA ($F4),Y
L838D:  STA $7632,X
L8390:  JMP L8309

UpdateVolume:
L8393:  INC $F2,X
L8395:  BNE L8399
L8397:  INC $F3,X
L8399:  LDA ($F2,X)
L839B:  ASL
L839C:  ASL
L839D:  ASL
L839E:  ASL
L839F:  EOR #$FF
L83A1:  STA $768A,X
L83A4:  JMP L8309
L83A7:  INC $F2,X
L83A9:  BNE L83AD
L83AB:  INC $F3,X
L83AD:  LDA ($F2,X)
L83AF:  STA $7643,X
L83B2:  INC $F2,X
L83B4:  BNE L83B8
L83B6:  INC $F3,X
L83B8:  LDA ($F2,X)
L83BA:  CMP #$02
L83BC:  BCS L83D1
L83BE:  LDA #$00
L83C0:  STA $7650,X
L83C3:  STA $7651,X
L83C6:  STA $7652,X
L83C9:  LDA #$00
L83CB:  STA $7653,X
L83CE:  JMP L83F2
L83D1:  STA $F8
L83D3:  LDA #$00
L83D5:  STA $F4
L83D7:  LDA #$08
L83D9:  STA $F5
L83DB:  JSR L857F
L83DE:  LDA $F4
L83E0:  STA $7650,X
L83E3:  LDA $F5
L83E5:  STA $7651,X
L83E8:  LDA #$00
L83EA:  STA $7652,X
L83ED:  LDA #$02
L83EF:  STA $7653,X
L83F2:  INC $F2,X
L83F4:  BNE L83F8
L83F6:  INC $F3,X
L83F8:  LDA ($F2,X)
L83FA:  STA $7678,X
L83FD:  JMP L8309

SilenceChannel:
L8400:  INC $F2,X
L8402:  BNE L8406
L8404:  INC $F3,X
L8406:  LDA ($F2,X)
L8408:  STA $7623,X
L840B:  STA $7640,X
L840E:  SEC
L840F:  SBC $7630,X
L8412:  BCS L8416
L8414:  LDA #$00
L8416:  STA $7641,X
L8419:  CMP $7632,X
L841C:  BCC L8421
L841E:  LDA $7632,X
L8421:  STA $7642,X
L8424:  LDA $85A2,X
L8427:  STA $7600,X
L842A:  LDA $85A3,X
L842D:  STA $7601,X
L8430:  LDA $85A4,X
L8433:  STA $7602,X
L8436:  LDA $85A5,X
L8439:  STA $7603,X
L843C:  LDA #$FF
L843E:  STA $7622,X
L8441:  LDA SFXFinished,X
L8444:  BNE L844B
L8446:  LDA #$01
L8448:  STA SFXFinished,X
L844B:  INC $F2,X
L844D:  BNE L8451
L844F:  INC $F3,X
L8451:  RTS

L8452:  CPX #$08
L8454:  BNE L8461
L8456:  PHA
L8457:  LDA $764B
L845A:  CMP #$FF
L845C:  PLA
L845D:  BCS L8461
L845F:  ADC #$0C
L8461:  TAY
L8462:  LDA $8600,Y
L8465:  STA $F4
L8467:  LDA $85B2,Y
L846A:  LSR
L846B:  ROR $F4
L846D:  LSR
L846E:  ROR $F4
L8470:  LSR
L8471:  ROR $F4
L8473:  LDA #$00
L8475:  STA $F5
L8477:  LDA $7678,X
L847A:  STA $F8
L847C:  STY $FD
L847E:  JSR L857F
L8481:  LDY $FD
L8483:  LDA $F4
L8485:  STA $7679,X
L8488:  LDA $85B2,Y
L848B:  STA $7603,X
L848E:  LDA $8600,Y
L8491:  STX $FD
L8493:  ASL $FD
L8495:  LDY $FD
L8497:  STA $7660,Y
L849A:  STA $7664,Y
L849D:  CLC
L849E:  ADC $7679,X
L84A1:  BCC L84A5
L84A3:  LDA #$FF
L84A5:  STA $7661,Y
L84A8:  STA $7663,Y
L84AB:  CLC
L84AC:  ADC $7679,X
L84AF:  BCC L84B3
L84B1:  LDA #$FF
L84B3:  STA $7662,Y
L84B6:  SEC
L84B7:  LDA $7660,Y
L84BA:  SBC $7679,X
L84BD:  BCS L84C1
L84BF:  LDA #$FF
L84C1:  STA $7665,Y
L84C4:  STA $7667,Y
L84C7:  SEC
L84C8:  SBC $7679,X
L84CB:  BCS L84CF
L84CD:  LDA #$FF
L84CF:  STA $7666,Y
L84D2:  INC $F2,X
L84D4:  BNE L84D8
L84D6:  INC $F3,X
L84D8:  LDA ($F2,X)
L84DA:  STA $7623,X
L84DD:  STA $7640,X
L84E0:  SEC
L84E1:  SBC $7630,X
L84E4:  BCS L84E8
L84E6:  LDA #$00
L84E8:  STA $7641,X
L84EB:  SEC
L84EC:  SBC $7632,X
L84EF:  BCS L84F3
L84F1:  LDA #$00
L84F3:  CMP $7631,X
L84F6:  BCC L84FB
L84F8:  LDA $7631,X
L84FB:  STA $F4
L84FD:  LDA $7641,X
L8500:  SEC
L8501:  SBC $F4
L8503:  STA $7642,X
L8506:  INC $F2,X
L8508:  BNE L850C
L850A:  INC $F3,X
L850C:  LDA $768A,X
L850F:  STA $7622,X
L8512:  LDA SFXFinished,X
L8515:  BNE L851C
L8517:  LDA #$01
L8519:  STA SFXFinished,X
L851C:  RTS

L851D:  AND #$0F
L851F:  STA $760E
L8522:  LDA $85AE
L8525:  STA $760C
L8528:  LDA $85AF
L852B:  STA $760D
L852E:  LDA $85B1
L8531:  STA $760F
L8534:  INC $FE
L8536:  BNE L853A
L8538:  INC $FF
L853A:  LDA ($F2,X)
L853C:  STA $762F
L853F:  STA $764C
L8542:  SEC
L8543:  SBC $763C
L8546:  BCS L854A
L8548:  LDA #$00
L854A:  STA $764D
L854D:  SEC
L854E:  SBC $763E
L8551:  BCS L8555
L8553:  LDA #$00
L8555:  CMP $763D
L8558:  BCC L855D
L855A:  LDA $763D
L855D:  STA $F4
L855F:  LDA $764D
L8562:  SEC
L8563:  SBC $F4
L8565:  STA $764E
L8568:  INC $F2,X
L856A:  BNE L856E
L856C:  INC $F3,X
L856E:  LDA $7696
L8571:  STA $762E
L8574:  LDA $7697
L8577:  BNE L857E
L8579:  LDA #$01
L857B:  STA $7697
L857E:  RTS


;----------------------------------------------------------------------------------------------------

DoDiv:
L857F:  CLC                     ;
L8580:  LDA #$00                ;
L8582:  LDY #$08                ;Prepare to divide the word in $F5,$F4 by $F8.
L8584:  ROL DivLBF4             ;
L8586:  ROL DivUBF5             ;

DivCalcLoop:
L8588:  ROL                     ;
L8589:  CMP DivisorF8           ;
L858B:  BCC +                   ;
L858D:  SBC DivisorF8           ;
L858F:* ROL DivLBF4             ;
L8591:  ROL DivUBF5             ;
L8593:  ROL                     ;This is a division algorithm. It divides the word in $F5,$F4-->
L8594:  CMP DivisorF8           ;by $F8. The integer word result is placed back into $F5,$F4.
L8596:  BCC +                   ;
L8598:  SBC DivisorF8           ;
L859A:* ROL DivLBF4             ;
L859C:  ROL DivUBF5             ;
L859E:  DEY                     ;
L859F:  BNE DivCalcLoop         ;
L85A1:  RTS                     ;

;----------------------------------------------------------------------------------------------------

;The following table loads the control bytes for each channel to turn it off.

SilenceChnTbl:
L85A2:  .byte $30, $11, $00, $00 ;SQ1 channel.
L85A6:  .byte $30, $11, $00, $00 ;SQ2 channel.
L85AA:  .byte $80, $00, $00, $F8 ;Triangle channel.
L85AE:  .byte $30, $00, $00, $00 ;Noise channel.

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
L85B2:  .byte $06, $06, $05, $05, $05, $05, $04, $04, $04, $03, $03, $03, $03, $03, $02, $02
L85C2:  .byte $02, $02, $02, $02, $02, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
L85D2:  .byte $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L85E2:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

;Not used:
L85EE:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L85FE:  .byte $00, $00

NoteTblLo:
L8600:  .byte $AE, $4E, $F4, $9E, $4D, $01, $B9, $75, $35, $F9, $C0, $8A, $57, $27, $FA, $CF
L8610:  .byte $A7, $81, $5D, $3B, $1B, $FC, $E0, $C5, $AC, $94, $7D, $68, $53, $40, $2E, $1D
L8620:  .byte $0D, $FE, $F0, $E2, $D6, $CA, $BE, $B4, $AA, $A0, $97, $8F, $87, $7F, $78, $71
L8630:  .byte $6B, $65, $5F, $5A, $55, $50, $4C, $47, $43, $40, $3C, $39

;----------------------------------------------------------------------------------------------------

;The noise channel is not used in any music so the
;noise channel is disabled with the following code:

MusNone:
L863C:  .byte CHN_ASR, $00               ;Set ASR data index to 0.
L863E:  .byte CHN_VOLUME, $08            ;Set channel volume to 8.
L8640:  .byte CHN_SILENCE, $40           ;Silence channel for 64 frames.
L8642:  .byte CHN_JUMP, $00, $FE, $FF    ;Jump back 2 bytes to $863D.

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
L8646:  .byte $94, $86, $B7, $86, $E3, $86, $07, $87, $2A, $87
L8650:  .byte $57, $87, $7F, $87, $8E, $98, $A5, $98, $BB, $98, $B3, $97, $E6, $97, $14, $98
L8660:  .byte $98, $86, $BA, $86, $EC, $86, $0B, $87, $2D, $87, $5F, $87, $87, $87, $93, $98
L8670:  .byte $AF, $98, $C2, $98, $B8, $97, $EB, $97, $1D, $98, $A0, $86, $DB, $86, $FD, $86
L8680:  .byte $13, $87, $4E, $87, $61, $87, $89, $87, $98, $98, $B8, $98, $C5, $98, $DC, $97
L8690:  .byte $0A, $98, $36, $98, $03, $08, $4F, $4F, $07, $4E, $4C, $4B, $4A, $49, $49, $49
L86A0:  .byte $15, $48, $48, $48, $48, $47, $47, $47, $47, $46, $46, $46, $46, $45, $45, $45
L86B0:  .byte $45, $44, $44, $44, $44, $43, $43, $02, $8C, $8F, $20, $8B, $8B, $8B, $8B, $8B
L86C0:  .byte $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B
L86D0:  .byte $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $06, $89, $87, $85, $84
L86E0:  .byte $82, $80, $80, $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $10, $0F, $0F, $0F
L86F0:  .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $00, $00, $00, $00, $00, $08, $00, $00
L8700:  .byte $00, $00, $00, $00, $00, $00, $00, $03, $08, $0F, $0F, $07, $0E, $0C, $0B, $0A
L8710:  .byte $09, $09, $09, $15, $08, $08, $08, $08, $07, $07, $07, $07, $06, $06, $06, $06
L8720:  .byte $05, $05, $05, $05, $04, $04, $04, $04, $03, $03, $02, $CC, $CF, $20, $CB, $CB
L8730:  .byte $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB
L8740:  .byte $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $07, $CA
L8750:  .byte $C9, $C7, $C5, $C4, $C2, $C0, $C0, $07, $88, $8C, $8E, $90, $8F, $8E, $8D, $01
L8760:  .byte $8D, $1C, $8C, $86, $87, $89, $88, $88, $88, $87, $87, $87, $87, $86, $86, $86
L8770:  .byte $86, $86, $85, $85, $85, $85, $85, $84, $84, $84, $84, $84, $84, $83, $83, $07
L8780:  .byte $48, $4C, $50, $4F, $4D, $49, $46, $01, $48, $0C, $48, $47, $46, $47, $46, $46
L8790:  .byte $45, $45, $44, $44, $44, $43, $43

L8797:  .byte $FB, $0C, $FD, $00, $08, $0E, $FC, $32, $15
L87A0:  .byte $1B, $1A, $0D, $1C, $0E, $FE, $0D, $14, $0E, $15, $0D, $1C, $0E, $FE, $0D, $1E
L87B0:  .byte $0E, $1A, $0D, $17, $0E, $15, $1B, $14, $1B, $15, $1B, $1A, $0D, $1C, $0E, $FE
L87C0:  .byte $0D, $14, $0E, $15, $0D, $1C, $0E, $FE, $0D, $1E, $0E, $1A, $0D, $17, $0E, $15
L87D0:  .byte $1B, $14, $1B, $FC, $35, $28, $1B, $28, $1B, $FE, $0D, $2A, $0E, $2A, $0D, $2B
L87E0:  .byte $0E, $FE, $1B, $FE, $0D, $2B, $0E, $2A, $0D, $2B, $0E, $2A, $0D, $28, $0E, $2B
L87F0:  .byte $1B, $2B, $1B, $FE, $0D, $2A, $0E, $2A, $0D, $28, $0E, $FE, $1B, $FE, $0D, $2B
L8800:  .byte $0E, $2A, $0D, $2B, $0E, $2A, $0D, $28, $0E, $FD, $00, $0C, $12, $FC, $37, $FB
L8810:  .byte $0C, $FE, $1B, $FE, $0D, $28, $1B, $25, $0E, $28, $0D, $25, $0E, $28, $0D, $2A
L8820:  .byte $1B, $28, $1B, $FE, $0E, $FE, $1B, $FE, $1B, $FE, $0D, $2A, $1B, $2A, $0E, $28
L8830:  .byte $0D, $26, $0E, $25, $0D, $23, $1B, $21, $1B, $FE, $0E, $FE, $1B, $FE, $1B, $2A
L8840:  .byte $1B, $2A, $1B, $25, $1B, $28, $1B, $2A, $0D, $28, $1B, $25, $0E, $23, $0D, $21
L8850:  .byte $0E, $23, $14, $25, $14, $25, $1B, $FE, $0E, $FE, $1B, $20, $06, $23, $07, $25
L8860:  .byte $0E, $28, $0D, $25, $0E, $20, $06, $23, $07, $25, $0E, $28, $0D, $25, $0E, $FE
L8870:  .byte $1B, $FE, $0D, $28, $1B, $25, $0E, $28, $0D, $25, $0E, $28, $0D, $2A, $1B, $28
L8880:  .byte $1B, $FE, $0E, $FE, $1B, $FE, $1B, $FE, $0D, $2A, $1B, $2A, $0E, $28, $0D, $26
L8890:  .byte $0E, $25, $0D, $23, $1B, $21, $1B, $FE, $0E, $FE, $1B, $FE, $1B, $2A, $1B, $2A
L88A0:  .byte $1B, $25, $1B, $28, $1B, $2A, $0D, $28, $1B, $25, $0E, $23, $0D, $21, $0E, $28
L88B0:  .byte $14, $25, $14, $25, $1B, $FE, $0E, $FE, $1B, $FE, $0D, $2C, $0E, $2C, $0D, $2C
L88C0:  .byte $0E, $2C, $0D, $2A, $0E, $2C, $0D, $2D, $1B, $26, $0E, $26, $51, $FE, $0D, $26
L88D0:  .byte $0E, $2D, $0D, $2C, $0E, $2D, $0D, $2C, $0E, $2A, $0D, $28, $0E, $2C, $14, $2C
L88E0:  .byte $14, $2C, $0E, $2C, $14, $28, $14, $25, $5F, $FE, $0D, $2A, $1B, $26, $0E, $26
L88F0:  .byte $51, $26, $0D, $2D, $0E, $2C, $0D, $2D, $1B, $2A, $1B, $28, $0E, $2C, $1B, $25
L8900:  .byte $0D, $28, $44, $FE, $1B, $FE, $1B, $FE, $0D, $2F, $0E, $2D, $0D, $2F, $0E, $2C
L8910:  .byte $1B, $25, $0D, $28, $36, $20, $07, $23, $07, $25, $0D, $25, $0E, $23, $0D, $25
L8920:  .byte $0E, $25, $0D, $25, $0E, $23, $0D, $25, $0E, $2A, $14, $2C, $14, $25, $0E, $2A
L8930:  .byte $14, $2C, $22, $FE, $0D, $2A, $0E, $2C, $0D, $2D, $0E, $2F, $0D, $2D, $1B, $2C
L8940:  .byte $07, $2A, $07, $2A, $14, $2A, $14, $28, $5F, $FE, $1B, $FE, $1B, $FE, $0D, $2A
L8950:  .byte $0E, $2D, $14, $2C, $14, $2A, $0E, $2A, $14, $2C, $14, $2D, $0E, $2D, $36, $FE
L8960:  .byte $0D, $2D, $0E, $2C, $0D, $2A, $0E, $2F, $28, $2C, $44, $1D, $06, $20, $07, $21
L8970:  .byte $0E, $20, $06, $21, $07, $23, $0E, $25, $06, $23, $07, $21, $07, $20, $07, $1E
L8980:  .byte $06, $1D, $07, $1A, $07, $19, $07, $2A, $14, $2C, $14, $25, $0E, $2A, $14, $2C
L8990:  .byte $22, $FE, $0D, $2A, $0E, $2C, $0D, $2D, $0E, $2F, $0D, $2D, $1B, $2C, $07, $2A
L89A0:  .byte $07, $2A, $14, $2A, $14, $28, $5F, $FE, $1B, $FE, $1B, $FE, $0D, $2A, $0E, $2D
L89B0:  .byte $14, $2C, $14, $2A, $0E, $2A, $14, $2C, $14, $2D, $0E, $2D, $36, $2D, $14, $2F
L89C0:  .byte $14, $2A, $0E, $2C, $36, $2C, $14, $2F, $14, $29, $0E, $FE, $0D, $25, $0E, $23
L89D0:  .byte $0D, $25, $0E, $20, $06, $21, $07, $23, $0E, $1D, $06, $1E, $07, $20, $0E, $2C
L89E0:  .byte $28, $2D, $95, $FE, $1B, $2C, $28, $2A, $95, $FE, $1B, $FC, $35, $28, $1B, $28
L89F0:  .byte $1B, $FE, $0D, $2A, $0E, $2A, $0D, $2B, $0E, $FE, $1B, $FE, $0D, $2B, $0E, $2A
L8A00:  .byte $0D, $2B, $0E, $2A, $0D, $28, $0E, $2B, $1B, $2B, $1B, $FE, $0D, $2A, $0E, $2A
L8A10:  .byte $0D, $28, $0E, $FE, $1B, $FE, $0D, $2B, $0E, $2A, $0D, $2B, $0E, $2A, $0D, $28
L8A20:  .byte $0E, $FD, $00, $0C, $12, $FC, $37, $FB, $0C, $FE, $1B, $FE, $0D, $28, $1B, $25
L8A30:  .byte $0E, $28, $0D, $25, $0E, $28, $0D, $2A, $1B, $28, $1B, $FE, $0E, $FE, $1B, $FE
L8A40:  .byte $1B, $FE, $0D, $2A, $1B, $2A, $0E, $28, $0D, $26, $0E, $25, $0D, $23, $1B, $21
L8A50:  .byte $1B, $FE, $0E, $FE, $1B, $FE, $1B, $2A, $1B, $2A, $1B, $25, $1B, $28, $1B, $2A
L8A60:  .byte $0D, $28, $1B, $25, $0E, $23, $0D, $21, $0E, $23, $14, $25, $14, $25, $1B, $FE
L8A70:  .byte $0E, $FE, $1B, $20, $06, $23, $07, $25, $0E, $28, $0D, $25, $0E, $20, $06, $23
L8A80:  .byte $07, $25, $0E, $28, $0D, $25, $0E, $FE, $1B, $FE, $0D, $28, $1B, $25, $0E, $28
L8A90:  .byte $0D, $25, $0E, $28, $0D, $2A, $1B, $28, $1B, $FE, $0E, $FE, $1B, $FE, $1B, $FE
L8AA0:  .byte $0D, $2A, $1B, $2A, $0E, $28, $0D, $26, $0E, $25, $0D, $23, $1B, $21, $1B, $FE
L8AB0:  .byte $0E, $FE, $1B, $FE, $1B, $2A, $1B, $2A, $1B, $25, $1B, $28, $1B, $2A, $0D, $28
L8AC0:  .byte $1B, $25, $0E, $23, $0D, $21, $0E, $28, $14, $25, $14, $25, $1B, $FE, $0E, $FE
L8AD0:  .byte $1B, $FE, $0D, $2C, $0E, $2C, $0D, $2C, $0E, $2C, $0D, $2A, $0E, $2C, $0D, $2D
L8AE0:  .byte $1B, $26, $0E, $26, $51, $FE, $0D, $26, $0E, $2D, $0D, $2C, $0E, $2D, $0D, $2C
L8AF0:  .byte $0E, $2A, $0D, $28, $0E, $2C, $14, $2C, $14, $2C, $0E, $2C, $14, $28, $14, $25
L8B00:  .byte $5F, $FE, $0D, $2A, $1B, $26, $0E, $26, $51, $26, $0D, $2D, $0E, $2C, $0D, $2D
L8B10:  .byte $1B, $2A, $1B, $28, $0E, $2C, $1B, $25, $0D, $28, $44, $FE, $1B, $FE, $1B, $FE
L8B20:  .byte $0D, $2F, $0E, $2D, $0D, $2F, $0E, $2C, $1B, $25, $0D, $28, $36, $20, $07, $23
L8B30:  .byte $07, $25, $0D, $25, $0E, $23, $0D, $25, $0E, $25, $0D, $25, $0E, $23, $0D, $25
L8B40:  .byte $0E, $2A, $14, $2C, $14, $25, $0E, $2A, $14, $2C, $22, $FE, $0D, $2A, $0E, $2C
L8B50:  .byte $0D, $2D, $0E, $2F, $0D, $2D, $1B, $2C, $07, $2A, $07, $2A, $14, $2A, $14, $28
L8B60:  .byte $5F, $FE, $1B, $FE, $1B, $FE, $0D, $2A, $0E, $2D, $14, $2C, $14, $2A, $0E, $2A
L8B70:  .byte $14, $2C, $14, $2D, $0E, $2D, $36, $FE, $0D, $2D, $0E, $2C, $0D, $2A, $0E, $2F
L8B80:  .byte $28, $2C, $44, $1D, $06, $20, $07, $21, $0E, $20, $06, $21, $07, $23, $0E, $25
L8B90:  .byte $06, $23, $07, $21, $07, $20, $07, $1E, $06, $1D, $07, $1A, $07, $19, $07, $2A
L8BA0:  .byte $14, $2C, $14, $25, $0E, $2A, $14, $2C, $22, $FE, $0D, $2A, $0E, $2C, $0D, $2D
L8BB0:  .byte $0E, $2F, $0D, $2D, $1B, $2C, $07, $2A, $07, $2A, $14, $2A, $14, $28, $5F, $FE
L8BC0:  .byte $1B, $FE, $1B, $FE, $0D, $2A, $0E, $2D, $14, $2C, $14, $2A, $0E, $2A, $14, $2C
L8BD0:  .byte $14, $2D, $0E, $2D, $36, $2D, $14, $2F, $14, $2A, $0E, $2C, $36, $2C, $14, $2F
L8BE0:  .byte $14, $29, $0E, $FE, $0D, $25, $0E, $23, $0D, $25, $0E, $20, $06, $21, $07, $23
L8BF0:  .byte $0E, $1D, $06, $1E, $07, $20, $0E, $2C, $28, $2D, $95, $FE, $1B, $2C, $28, $2A
L8C00:  .byte $95, $FE, $1B, $FF, $00, $94, $FB

L8C07:  .byte $FB, $0C, $FD, $00, $08, $0E, $FC, $33, $15
L8C10:  .byte $1B, $1A, $0D, $1C, $0E, $FE, $0D, $14, $0E, $15, $0D, $1C, $0E, $FE, $0D, $1E
L8C20:  .byte $0E, $1A, $0D, $17, $0E, $15, $1B, $14, $1B, $15, $1B, $1A, $0D, $1C, $0E, $FE
L8C30:  .byte $0D, $14, $0E, $15, $0D, $1C, $0E, $FE, $0D, $1E, $0E, $1A, $0D, $17, $0E, $15
L8C40:  .byte $1B, $14, $1B, $FC, $36, $19, $1B, $19, $1B, $FE, $0D, $1A, $0E, $1A, $0D, $1C
L8C50:  .byte $0E, $FE, $1B, $FE, $0D, $1C, $0E, $1A, $0D, $1C, $0E, $1A, $0D, $19, $0E, $1C
L8C60:  .byte $1B, $1C, $1B, $FE, $0D, $1A, $0E, $1A, $0D, $19, $0E, $FE, $1B, $FE, $0D, $1A
L8C70:  .byte $0E, $19, $0D, $1A, $0E, $19, $0D, $17, $0E, $FB, $09, $FC, $38, $FE, $0D, $21
L8C80:  .byte $07, $25, $07, $2A, $0D, $28, $0E, $FE, $0D, $21, $07, $25, $07, $28, $0D, $28
L8C90:  .byte $0E, $FE, $0D, $20, $07, $23, $07, $2A, $0D, $28, $0E, $FE, $0D, $20, $07, $23
L8CA0:  .byte $07, $28, $0D, $28, $0E, $FE, $0D, $1E, $07, $21, $07, $28, $0D, $26, $0E, $FE
L8CB0:  .byte $0D, $1E, $07, $21, $07, $26, $0D, $26, $0E, $FE, $0D, $1E, $07, $21, $07, $26
L8CC0:  .byte $0D, $25, $0E, $FE, $0D, $1E, $07, $21, $07, $25, $0D, $25, $0E, $26, $0D, $1E
L8CD0:  .byte $0E, $21, $0D, $28, $1B, $26, $1B, $21, $0E, $26, $0D, $1E, $0E, $21, $0D, $1C
L8CE0:  .byte $1B, $1A, $1B, $21, $0E, $25, $0D, $20, $0E, $23, $0D, $28, $1B, $25, $1B, $20
L8CF0:  .byte $0E, $14, $06, $17, $07, $19, $0E, $1C, $0D, $19, $0E, $14, $06, $17, $07, $19
L8D00:  .byte $0E, $1C, $0D, $19, $0E, $FE, $0D, $21, $07, $25, $07, $2A, $0D, $28, $0E, $FE
L8D10:  .byte $0D, $21, $07, $25, $07, $28, $0D, $28, $0E, $FE, $0D, $20, $07, $23, $07, $2A
L8D20:  .byte $0D, $28, $0E, $FE, $0D, $20, $07, $23, $07, $28, $0D, $28, $0E, $FE, $0D, $1E
L8D30:  .byte $07, $21, $07, $28, $0D, $26, $0E, $FE, $0D, $1E, $07, $21, $07, $26, $0D, $26
L8D40:  .byte $0E, $FE, $0D, $1E, $07, $21, $07, $26, $0D, $25, $0E, $FE, $0D, $1E, $07, $21
L8D50:  .byte $07, $25, $0D, $25, $0E, $26, $0D, $1E, $0E, $21, $0D, $28, $1B, $26, $1B, $21
L8D60:  .byte $0E, $26, $0D, $1E, $0E, $21, $0D, $28, $1B, $26, $1B, $21, $0E, $25, $0D, $20
L8D70:  .byte $0E, $23, $0D, $28, $1B, $25, $1B, $20, $0E, $25, $0D, $20, $0E, $23, $0D, $28
L8D80:  .byte $1B, $25, $1B, $2D, $1B, $1A, $0E, $1A, $51, $FE, $0D, $1A, $0E, $21, $0D, $20
L8D90:  .byte $0E, $21, $0D, $20, $0E, $1E, $0D, $1C, $0E, $20, $14, $20, $14, $20, $0E, $20
L8DA0:  .byte $14, $1C, $14, $19, $5F, $FE, $0D, $1E, $1B, $1A, $0E, $1A, $51, $1A, $0D, $21
L8DB0:  .byte $0E, $20, $0D, $21, $1B, $1E, $1B, $1C, $0E, $19, $0D, $20, $1B, $20, $0E, $1E
L8DC0:  .byte $0D, $1C, $1B, $19, $0E, $19, $0D, $20, $1B, $20, $0E, $1E, $0D, $1C, $1B, $19
L8DD0:  .byte $0E, $19, $0D, $20, $1B, $20, $0E, $1E, $0D, $1C, $1B, $19, $0E, $19, $0D, $19
L8DE0:  .byte $0E, $17, $0D, $19, $0E, $19, $0D, $19, $0E, $17, $0D, $19, $0E, $21, $14, $23
L8DF0:  .byte $14, $1E, $0E, $21, $14, $23, $07, $23, $1B, $FE, $0D, $1E, $0E, $20, $0D, $21
L8E00:  .byte $0E, $23, $0D, $21, $1B, $20, $07, $1E, $07, $1E, $14, $1E, $14, $1C, $5F, $FE
L8E10:  .byte $1B, $FE, $1B, $FE, $0D, $26, $0E, $2A, $14, $28, $14, $26, $0E, $26, $14, $28
L8E20:  .byte $14, $2A, $0E, $2A, $36, $FE, $0D, $2A, $0E, $28, $0D, $26, $0E, $2C, $28, $29
L8E30:  .byte $0E, $29, $36, $1D, $06, $20, $07, $21, $0E, $20, $06, $21, $07, $23, $0E, $25
L8E40:  .byte $06, $23, $07, $21, $07, $20, $07, $1E, $06, $1D, $07, $1A, $07, $19, $07, $21
L8E50:  .byte $14, $23, $14, $1E, $0E, $21, $14, $23, $07, $23, $1B, $FE, $0D, $1E, $0E, $20
L8E60:  .byte $0D, $21, $0E, $23, $0D, $21, $1B, $20, $07, $1E, $07, $1E, $14, $1E, $14, $1C
L8E70:  .byte $5F, $FE, $1B, $FE, $1B, $FE, $0D, $26, $0E, $2A, $14, $28, $14, $26, $0E, $26
L8E80:  .byte $14, $28, $14, $2A, $0E, $2A, $36, $2A, $14, $2C, $14, $26, $0E, $29, $36, $29
L8E90:  .byte $14, $2C, $14, $25, $0E, $FE, $0D, $25, $0E, $23, $0D, $25, $0E, $20, $06, $21
L8EA0:  .byte $07, $23, $0E, $1D, $06, $1E, $07, $20, $0E, $20, $1B, $20, $0D, $1C, $0E, $1E
L8EB0:  .byte $0D, $1E, $1B, $1A, $0E, $20, $1B, $20, $0D, $1C, $0E, $1E, $0D, $1E, $1B, $1A
L8EC0:  .byte $0E, $20, $1B, $20, $0D, $1C, $0E, $22, $0D, $22, $1B, $1E, $0E, $20, $1B, $20
L8ED0:  .byte $0D, $1C, $0E, $22, $0D, $22, $1B, $1E, $0E, $FC, $36, $19, $1B, $19, $1B, $FE
L8EE0:  .byte $0D, $1A, $0E, $1A, $0D, $1C, $0E, $FE, $1B, $FE, $0D, $1C, $0E, $1A, $0D, $1C
L8EF0:  .byte $0E, $1A, $0D, $19, $0E, $1C, $1B, $1C, $1B, $FE, $0D, $1A, $0E, $1A, $0D, $19
L8F00:  .byte $0E, $FE, $1B, $FE, $0D, $1A, $0E, $19, $0D, $1A, $0E, $19, $0D, $17, $0E, $FB
L8F10:  .byte $09, $FC, $38, $FE, $0D, $21, $07, $25, $07, $2A, $0D, $28, $0E, $FE, $0D, $21
L8F20:  .byte $07, $25, $07, $28, $0D, $28, $0E, $FE, $0D, $20, $07, $23, $07, $2A, $0D, $28
L8F30:  .byte $0E, $FE, $0D, $20, $07, $23, $07, $28, $0D, $28, $0E, $FE, $0D, $1E, $07, $21
L8F40:  .byte $07, $28, $0D, $26, $0E, $FE, $0D, $1E, $07, $21, $07, $26, $0D, $26, $0E, $FE
L8F50:  .byte $0D, $1E, $07, $21, $07, $26, $0D, $25, $0E, $FE, $0D, $1E, $07, $21, $07, $25
L8F60:  .byte $0D, $25, $0E, $26, $0D, $1E, $0E, $21, $0D, $28, $1B, $26, $1B, $21, $0E, $26
L8F70:  .byte $0D, $1E, $0E, $21, $0D, $1C, $1B, $1A, $1B, $21, $0E, $25, $0D, $20, $0E, $23
L8F80:  .byte $0D, $28, $1B, $25, $1B, $20, $0E, $14, $06, $17, $07, $19, $0E, $1C, $0D, $19
L8F90:  .byte $0E, $14, $06, $17, $07, $19, $0E, $1C, $0D, $19, $0E, $FE, $0D, $21, $07, $25
L8FA0:  .byte $07, $2A, $0D, $28, $0E, $FE, $0D, $21, $07, $25, $07, $28, $0D, $28, $0E, $FE
L8FB0:  .byte $0D, $20, $07, $23, $07, $2A, $0D, $28, $0E, $FE, $0D, $20, $07, $23, $07, $28
L8FC0:  .byte $0D, $28, $0E, $FE, $0D, $1E, $07, $21, $07, $28, $0D, $26, $0E, $FE, $0D, $1E
L8FD0:  .byte $07, $21, $07, $26, $0D, $26, $0E, $FE, $0D, $1E, $07, $21, $07, $26, $0D, $25
L8FE0:  .byte $0E, $FE, $0D, $1E, $07, $21, $07, $25, $0D, $25, $0E, $26, $0D, $1E, $0E, $21
L8FF0:  .byte $0D, $28, $1B, $26, $1B, $21, $0E, $26, $0D, $1E, $0E, $21, $0D, $28, $1B, $26
L9000:  .byte $1B, $21, $0E, $25, $0D, $20, $0E, $23, $0D, $28, $1B, $25, $1B, $20, $0E, $25
L9010:  .byte $0D, $20, $0E, $23, $0D, $28, $1B, $25, $1B, $2D, $1B, $1A, $0E, $1A, $51, $FE
L9020:  .byte $0D, $1A, $0E, $21, $0D, $20, $0E, $21, $0D, $20, $0E, $1E, $0D, $1C, $0E, $20
L9030:  .byte $14, $20, $14, $20, $0E, $20, $14, $1C, $14, $19, $5F, $FE, $0D, $1E, $1B, $1A
L9040:  .byte $0E, $1A, $51, $1A, $0D, $21, $0E, $20, $0D, $21, $1B, $1E, $1B, $1C, $0E, $19
L9050:  .byte $0D, $20, $1B, $20, $0E, $1E, $0D, $1C, $1B, $19, $0E, $19, $0D, $20, $1B, $20
L9060:  .byte $0E, $1E, $0D, $1C, $1B, $19, $0E, $19, $0D, $20, $1B, $20, $0E, $1E, $0D, $1C
L9070:  .byte $1B, $19, $0E, $19, $0D, $19, $0E, $17, $0D, $19, $0E, $19, $0D, $19, $0E, $17
L9080:  .byte $0D, $19, $0E, $21, $14, $23, $14, $1E, $0E, $21, $14, $23, $07, $23, $1B, $FE
L9090:  .byte $0D, $1E, $0E, $20, $0D, $21, $0E, $23, $0D, $21, $1B, $20, $07, $1E, $07, $1E
L90A0:  .byte $14, $1E, $14, $1C, $5F, $FE, $1B, $FE, $1B, $FE, $0D, $26, $0E, $2A, $14, $28
L90B0:  .byte $14, $26, $0E, $26, $14, $28, $14, $2A, $0E, $2A, $36, $FE, $0D, $2A, $0E, $28
L90C0:  .byte $0D, $26, $0E, $2C, $28, $29, $0E, $29, $36, $1D, $06, $20, $07, $21, $0E, $20
L90D0:  .byte $06, $21, $07, $23, $0E, $25, $06, $23, $07, $21, $07, $20, $07, $1E, $06, $1D
L90E0:  .byte $07, $1A, $07, $19, $07, $21, $14, $23, $14, $1E, $0E, $21, $14, $23, $07, $23
L90F0:  .byte $1B, $FE, $0D, $1E, $0E, $20, $0D, $21, $0E, $23, $0D, $21, $1B, $20, $07, $1E
L9100:  .byte $07, $1E, $14, $1E, $14, $1C, $5F, $FE, $1B, $FE, $1B, $FE, $0D, $26, $0E, $2A
L9110:  .byte $14, $28, $14, $26, $0E, $26, $14, $28, $14, $2A, $0E, $2A, $36, $2A, $14, $2C
L9120:  .byte $14, $26, $0E, $29, $36, $29, $14, $2C, $14, $25, $0E, $FE, $0D, $25, $0E, $23
L9130:  .byte $0D, $25, $0E, $20, $06, $21, $07, $23, $0E, $1D, $06, $1E, $07, $20, $0E, $20
L9140:  .byte $1B, $20, $0D, $1C, $0E, $1E, $0D, $1E, $1B, $1A, $0E, $20, $1B, $20, $0D, $1C
L9150:  .byte $0E, $1E, $0D, $1E, $1B, $1A, $0E, $20, $1B, $20, $0D, $1C, $0E, $22, $0D, $22
L9160:  .byte $1B, $1E, $0E, $20, $1B, $20, $0D, $1C, $0E, $22, $0D, $22, $1B, $1E, $0E, $FF
L9170:  .byte $00, $98, $FA, $FB, $0F, $FD, $00, $08, $18, $FC, $34, $09, $1B, $0E, $0D, $10
L9180:  .byte $0E, $FE, $0D, $08, $0E, $09, $0D, $10, $0E, $FE, $0D, $12, $0E, $0E, $0D, $0B
L9190:  .byte $0E, $09, $1B, $08, $1B, $09, $1B, $0E, $0D, $10, $0E, $FE, $0D, $08, $0E, $09
L91A0:  .byte $0D, $10, $0E, $FE, $0D, $12, $0E, $0E, $0D, $0B, $0E, $09, $1B, $08, $1B, $09
L91B0:  .byte $0D, $15, $0E, $09, $0D, $15, $0E, $09, $0D, $15, $0E, $09, $0D, $15, $0E, $09
L91C0:  .byte $0D, $15, $0E, $09, $0D, $15, $0E, $09, $0D, $15, $0E, $09, $0D, $15, $0E, $09
L91D0:  .byte $0D, $15, $0E, $09, $0D, $15, $0E, $09, $0D, $15, $0E, $09, $0D, $15, $0E, $09
L91E0:  .byte $0D, $15, $0E, $09, $0D, $15, $0E, $09, $0D, $15, $0E, $09, $0D, $15, $0E, $09
L91F0:  .byte $0D, $FE, $0E, $FE, $1B, $FE, $0D, $09, $0E, $06, $0D, $04, $0E, $FE, $1B, $FE
L9200:  .byte $0D, $04, $0E, $FE, $0D, $04, $0E, $FE, $1B, $0B, $0D, $FE, $0E, $FE, $1B, $FE
L9210:  .byte $0D, $0B, $0E, $09, $0D, $06, $0E, $FE, $0D, $FE, $1B, $06, $0E, $FE, $0D, $06
L9220:  .byte $0E, $FE, $1B, $0E, $0D, $FE, $0E, $FE, $1B, $FE, $0D, $0E, $0E, $0B, $0D, $09
L9230:  .byte $0E, $FE, $1B, $FE, $0D, $0E, $0E, $FE, $0D, $0E, $0E, $FE, $1B, $0D, $0D, $FE
L9240:  .byte $0E, $FE, $1B, $FE, $0D, $0D, $0E, $0B, $0D, $08, $0E, $FE, $1B, $FE, $0D, $0D
L9250:  .byte $0E, $FE, $0D, $0D, $0E, $FE, $1B, $09, $0D, $FE, $0E, $FE, $1B, $FE, $0D, $09
L9260:  .byte $0E, $06, $0D, $04, $0E, $FE, $1B, $FE, $0D, $04, $0E, $FE, $0D, $04, $0E, $FE
L9270:  .byte $1B, $0B, $0D, $FE, $0E, $FE, $1B, $FE, $0D, $0B, $0E, $09, $0D, $06, $0E, $FE
L9280:  .byte $0D, $FE, $1B, $06, $0E, $FE, $0D, $06, $0E, $FE, $1B, $0E, $0D, $0E, $1B, $0E
L9290:  .byte $0E, $0E, $0D, $0E, $1B, $0E, $0E, $0E, $0D, $0E, $1B, $0E, $0E, $0E, $0D, $0E
L92A0:  .byte $1B, $0E, $0E, $0D, $0D, $0D, $1B, $0D, $0E, $0D, $0D, $0D, $1B, $0D, $0E, $0D
L92B0:  .byte $0D, $0D, $1B, $0D, $0E, $0D, $0D, $0D, $1B, $0D, $0E, $0E, $0D, $1A, $0E, $0B
L92C0:  .byte $0D, $17, $0E, $09, $0D, $15, $0E, $0B, $0D, $17, $0E, $0E, $0D, $1A, $0E, $0B
L92D0:  .byte $0D, $17, $0E, $09, $0D, $15, $0E, $0B, $0D, $17, $0E, $0D, $0D, $19, $0E, $0B
L92E0:  .byte $0D, $17, $0E, $09, $0D, $15, $0E, $0B, $0D, $17, $0E, $0D, $0D, $19, $0E, $0B
L92F0:  .byte $0D, $17, $0E, $09, $0D, $15, $0E, $0B, $0D, $17, $0E, $0B, $0D, $17, $0E, $09
L9300:  .byte $0D, $15, $0E, $08, $0D, $12, $0E, $09, $0D, $15, $0E, $0B, $0D, $17, $0E, $09
L9310:  .byte $0D, $15, $0E, $08, $0D, $12, $0E, $09, $0D, $15, $0E, $09, $0D, $09, $0E, $09
L9320:  .byte $0D, $09, $0E, $09, $0D, $09, $0E, $09, $0D, $09, $0E, $09, $0D, $09, $0E, $09
L9330:  .byte $0D, $09, $0E, $09, $0D, $09, $0E, $09, $0D, $09, $0E, $0E, $0D, $0E, $0E, $0E
L9340:  .byte $0D, $0E, $0E, $0E, $0D, $0E, $0E, $0E, $0D, $0E, $0E, $09, $28, $0D, $0E, $FE
L9350:  .byte $0D, $0D, $29, $06, $0D, $FE, $1B, $06, $0E, $FE, $0D, $06, $07, $08, $07, $09
L9360:  .byte $06, $08, $07, $06, $07, $04, $07, $08, $0D, $FE, $0E, $FE, $0D, $08, $0E, $FE
L9370:  .byte $0D, $12, $07, $14, $07, $15, $06, $14, $07, $12, $07, $10, $07, $04, $0D, $FE
L9380:  .byte $0E, $FE, $0D, $04, $0E, $FE, $0D, $04, $07, $06, $07, $08, $06, $06, $07, $04
L9390:  .byte $07, $0B, $07, $04, $0D, $FE, $0E, $FE, $0D, $04, $0E, $FE, $0D, $10, $07, $12
L93A0:  .byte $07, $14, $06, $12, $07, $10, $07, $17, $07, $0E, $0D, $FE, $0E, $FE, $0D, $0E
L93B0:  .byte $0E, $FE, $0D, $0E, $0E, $FE, $1B, $0E, $0D, $FE, $0E, $FE, $0D, $0E, $0E, $FE
L93C0:  .byte $0D, $0E, $0E, $FE, $1B, $0D, $0D, $FE, $0E, $FE, $0D, $0D, $0E, $FE, $0D, $0D
L93D0:  .byte $0E, $FE, $1B, $0D, $0D, $FE, $0E, $FE, $0D, $0D, $0E, $FE, $0D, $0B, $07, $08
L93E0:  .byte $07, $0D, $06, $08, $07, $0B, $07, $08, $07, $06, $0D, $FE, $1B, $06, $0E, $FE
L93F0:  .byte $0D, $06, $07, $08, $07, $09, $06, $08, $07, $06, $07, $04, $07, $08, $0D, $FE
L9400:  .byte $0E, $FE, $0D, $08, $0E, $FE, $0D, $12, $07, $14, $07, $15, $06, $14, $07, $12
L9410:  .byte $07, $10, $07, $04, $0D, $FE, $0E, $FE, $0D, $04, $0E, $FE, $0D, $04, $07, $06
L9420:  .byte $07, $08, $06, $06, $07, $04, $07, $0B, $07, $04, $0D, $FE, $0E, $FE, $0D, $04
L9430:  .byte $0E, $FE, $0D, $10, $07, $12, $07, $14, $06, $12, $07, $10, $07, $17, $07, $0E
L9440:  .byte $0D, $FE, $0E, $FE, $0D, $0E, $0E, $FE, $0D, $0E, $0E, $FE, $1B, $0E, $0D, $FE
L9450:  .byte $0E, $FE, $0D, $0E, $0E, $FE, $0D, $0E, $0E, $FE, $1B, $0D, $0D, $FE, $0E, $FE
L9460:  .byte $0D, $0D, $0E, $FE, $0D, $0D, $0E, $FE, $1B, $0D, $0D, $FE, $0E, $FE, $0D, $0D
L9470:  .byte $0E, $FE, $0D, $0D, $0E, $FE, $1B, $0E, $0D, $0E, $0E, $0E, $0D, $0E, $1B, $0E
L9480:  .byte $0E, $0E, $0D, $0E, $0E, $0E, $0D, $0E, $0E, $0E, $0D, $0E, $1B, $0E, $0E, $0E
L9490:  .byte $0D, $0E, $0E, $06, $0D, $06, $0E, $06, $0D, $06, $1B, $06, $0E, $06, $0D, $06
L94A0:  .byte $0E, $06, $0D, $06, $0E, $06, $0D, $06, $1B, $06, $0E, $06, $0D, $06, $0E, $09
L94B0:  .byte $0D, $15, $0E, $09, $0D, $15, $0E, $09, $0D, $15, $0E, $09, $0D, $15, $0E, $09
L94C0:  .byte $0D, $15, $0E, $09, $0D, $15, $0E, $09, $0D, $15, $0E, $09, $0D, $15, $0E, $09
L94D0:  .byte $0D, $15, $0E, $09, $0D, $15, $0E, $09, $0D, $15, $0E, $09, $0D, $15, $0E, $09
L94E0:  .byte $0D, $15, $0E, $09, $0D, $15, $0E, $09, $0D, $15, $0E, $09, $0D, $15, $0E, $09
L94F0:  .byte $0D, $FE, $0E, $FE, $1B, $FE, $0D, $09, $0E, $06, $0D, $04, $0E, $FE, $1B, $FE
L9500:  .byte $0D, $04, $0E, $FE, $0D, $04, $0E, $FE, $1B, $0B, $0D, $FE, $0E, $FE, $1B, $FE
L9510:  .byte $0D, $0B, $0E, $09, $0D, $06, $0E, $FE, $0D, $FE, $1B, $06, $0E, $FE, $0D, $06
L9520:  .byte $0E, $FE, $1B, $0E, $0D, $FE, $0E, $FE, $1B, $FE, $0D, $0E, $0E, $0B, $0D, $09
L9530:  .byte $0E, $FE, $1B, $FE, $0D, $0E, $0E, $FE, $0D, $0E, $0E, $FE, $1B, $0D, $0D, $FE
L9540:  .byte $0E, $FE, $1B, $FE, $0D, $0D, $0E, $0B, $0D, $08, $0E, $FE, $1B, $FE, $0D, $0D
L9550:  .byte $0E, $FE, $0D, $0D, $0E, $FE, $1B, $09, $0D, $FE, $0E, $FE, $1B, $FE, $0D, $09
L9560:  .byte $0E, $06, $0D, $04, $0E, $FE, $1B, $FE, $0D, $04, $0E, $FE, $0D, $04, $0E, $FE
L9570:  .byte $1B, $0B, $0D, $FE, $0E, $FE, $1B, $FE, $0D, $0B, $0E, $09, $0D, $06, $0E, $FE
L9580:  .byte $0D, $FE, $1B, $06, $0E, $FE, $0D, $06, $0E, $FE, $1B, $0E, $0D, $0E, $1B, $0E
L9590:  .byte $0E, $0E, $0D, $0E, $1B, $0E, $0E, $0E, $0D, $0E, $1B, $0E, $0E, $0E, $0D, $0E
L95A0:  .byte $1B, $0E, $0E, $0D, $0D, $0D, $1B, $0D, $0E, $0D, $0D, $0D, $1B, $0D, $0E, $0D
L95B0:  .byte $0D, $0D, $1B, $0D, $0E, $0D, $0D, $0D, $1B, $0D, $0E, $0E, $0D, $1A, $0E, $0B
L95C0:  .byte $0D, $17, $0E, $09, $0D, $15, $0E, $0B, $0D, $17, $0E, $0E, $0D, $1A, $0E, $0B
L95D0:  .byte $0D, $17, $0E, $09, $0D, $15, $0E, $0B, $0D, $17, $0E, $0D, $0D, $19, $0E, $0B
L95E0:  .byte $0D, $17, $0E, $09, $0D, $15, $0E, $0B, $0D, $17, $0E, $0D, $0D, $19, $0E, $0B
L95F0:  .byte $0D, $17, $0E, $09, $0D, $15, $0E, $0B, $0D, $17, $0E, $0B, $0D, $17, $0E, $09
L9600:  .byte $0D, $15, $0E, $08, $0D, $12, $0E, $09, $0D, $15, $0E, $0B, $0D, $17, $0E, $09
L9610:  .byte $0D, $15, $0E, $08, $0D, $12, $0E, $09, $0D, $15, $0E, $09, $0D, $09, $0E, $09
L9620:  .byte $0D, $09, $0E, $09, $0D, $09, $0E, $09, $0D, $09, $0E, $09, $0D, $09, $0E, $09
L9630:  .byte $0D, $09, $0E, $09, $0D, $09, $0E, $09, $0D, $09, $0E, $0E, $0D, $0E, $0E, $0E
L9640:  .byte $0D, $0E, $0E, $0E, $0D, $0E, $0E, $0E, $0D, $0E, $0E, $09, $28, $0D, $0E, $FE
L9650:  .byte $0D, $0D, $29, $06, $0D, $FE, $1B, $06, $0E, $FE, $0D, $06, $07, $08, $07, $09
L9660:  .byte $06, $08, $07, $06, $07, $04, $07, $08, $0D, $FE, $0E, $FE, $0D, $08, $0E, $FE
L9670:  .byte $0D, $12, $07, $14, $07, $15, $06, $14, $07, $12, $07, $10, $07, $04, $0D, $FE
L9680:  .byte $0E, $FE, $0D, $04, $0E, $FE, $0D, $04, $07, $06, $07, $08, $06, $06, $07, $04
L9690:  .byte $07, $0B, $07, $04, $0D, $FE, $0E, $FE, $0D, $04, $0E, $FE, $0D, $10, $07, $12
L96A0:  .byte $07, $14, $06, $12, $07, $10, $07, $17, $07, $0E, $0D, $FE, $0E, $FE, $0D, $0E
L96B0:  .byte $0E, $FE, $0D, $0E, $0E, $FE, $1B, $0E, $0D, $FE, $0E, $FE, $0D, $0E, $0E, $FE
L96C0:  .byte $0D, $0E, $0E, $FE, $1B, $0D, $0D, $FE, $0E, $FE, $0D, $0D, $0E, $FE, $0D, $0D
L96D0:  .byte $0E, $FE, $1B, $0D, $0D, $FE, $0E, $FE, $0D, $0D, $0E, $FE, $0D, $0B, $07, $08
L96E0:  .byte $07, $0D, $06, $08, $07, $0B, $07, $08, $07, $06, $0D, $FE, $1B, $06, $0E, $FE
L96F0:  .byte $0D, $06, $07, $08, $07, $09, $06, $08, $07, $06, $07, $04, $07, $08, $0D, $FE
L9700:  .byte $0E, $FE, $0D, $08, $0E, $FE, $0D, $12, $07, $14, $07, $15, $06, $14, $07, $12
L9710:  .byte $07, $10, $07, $04, $0D, $FE, $0E, $FE, $0D, $04, $0E, $FE, $0D, $04, $07, $06
L9720:  .byte $07, $08, $06, $06, $07, $04, $07, $0B, $07, $04, $0D, $FE, $0E, $FE, $0D, $04
L9730:  .byte $0E, $FE, $0D, $10, $07, $12, $07, $14, $06, $12, $07, $10, $07, $17, $07, $0E
L9740:  .byte $0D, $FE, $0E, $FE, $0D, $0E, $0E, $FE, $0D, $0E, $0E, $FE, $1B, $0E, $0D, $FE
L9750:  .byte $0E, $FE, $0D, $0E, $0E, $FE, $0D, $0E, $0E, $FE, $1B, $0D, $0D, $FE, $0E, $FE
L9760:  .byte $0D, $0D, $0E, $FE, $0D, $0D, $0E, $FE, $1B, $0D, $0D, $FE, $0E, $FE, $0D, $0D
L9770:  .byte $0E, $FE, $0D, $0D, $0E, $FE, $1B, $0E, $0D, $0E, $0E, $0E, $0D, $0E, $1B, $0E
L9780:  .byte $0E, $0E, $0D, $0E, $0E, $0E, $0D, $0E, $0E, $0E, $0D, $0E, $1B, $0E, $0E, $0E
L9790:  .byte $0D, $0E, $0E, $06, $0D, $06, $0E, $06, $0D, $06, $1B, $06, $0E, $06, $0D, $06
L97A0:  .byte $0E, $06, $0D, $06, $0E, $06, $0D, $06, $1B, $06, $0E, $06, $0D, $06, $0E, $FF
L97B0:  .byte $00, $C4, $F9, $04, $84, $88, $8C, $90, $23, $8E, $8C, $89, $8C, $8E, $8E, $8C
L97C0:  .byte $89, $8C, $8E, $8E, $8C, $89, $8C, $8E, $8E, $8C, $89, $8C, $8E, $8E, $8C, $89
L97D0:  .byte $8C, $8E, $8E, $8C, $89, $8C, $8E, $8E, $8C, $89, $8C, $8E, $08, $8C, $8A, $88
L97E0:  .byte $88, $86, $86, $84, $82, $82, $04, $84, $88, $8C, $90, $1E, $8E, $8C, $8A, $8A
L97F0:  .byte $8C, $8E, $8C, $8A, $8A, $8C, $8E, $8C, $8A, $8A, $8C, $8E, $8C, $8A, $8A, $8C
L9800:  .byte $8E, $8C, $8A, $8A, $8C, $8E, $8C, $8A, $8A, $8C, $08, $8C, $8A, $88, $88, $86
L9810:  .byte $86, $84, $82, $82, $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $18, $0F, $0F
L9820:  .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
L9830:  .byte $0F, $0F, $0F, $0F, $0F, $0F, $08, $0F, $0F, $0F, $0F, $0F, $00, $00, $00, $00
L9840:  .byte $FB, $0E, $FD, $00, $0F, $18, $FC, $3C, $24, $30, $27, $30, $29, $20, $27, $30
L9850:  .byte $24, $10, $FE, $40, $FE, $40, $FF, $00, $FE, $FF, $FB, $0E, $FD, $00, $1D, $12
L9860:  .byte $FC, $3D, $24, $30, $27, $30, $29, $20, $27, $30, $24, $10, $FE, $40, $FE, $40
L9870:  .byte $FF, $00, $FE, $FF, $FB, $0F, $FD, $00, $10, $10, $FC, $3E, $18, $30, $1B, $30
L9880:  .byte $1D, $20, $1B, $30, $18, $10, $FE, $40, $FE, $40, $FF, $00, $FE, $FF, $04, $86
L9890:  .byte $89, $8C, $90, $04, $90, $8E, $90, $8E, $0C, $8D, $89, $87, $86, $86, $85, $85
L98A0:  .byte $84, $84, $83, $83, $82, $09, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $08
L98B0:  .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $02, $0F, $0F, $06, $08, $0C, $0F, $0D
L98C0:  .byte $09, $08, $02, $08, $08, $0A, $07, $06, $05, $05, $04, $04, $03, $03, $02, $01
L98D0:  .byte $00, $FD, $00, $00, $00, $FC, $39, $FE, $58, $FF, $00, $FE, $FF, $FB, $0F, $FD
L98E0:  .byte $00, $00, $00, $FC, $39, $FE, $40, $FF, $00, $FE, $FF, $FB, $08, $FD, $00, $00
L98F0:  .byte $00, $FC, $3A, $02, $08, $04, $08, $FE, $40, $FF, $00, $FA, $FF, $FB, $00, $FD
L9900:  .byte $00, $00, $00, $FC, $3B, $FE, $40, $FF, $00, $FE, $FF, $36, $07, $FE, $0D, $3B
L9910:  .byte $06, $39, $07, $38, $06, $3B, $07, $39, $06, $38, $07, $FB, $0D, $FD, $00, $06
L9920:  .byte $40, $FC, $11, $28, $0D, $28, $0D, $26, $0D, $28, $1A, $26, $1A, $28, $1A, $28
L9930:  .byte $0D, $26, $1A, $28, $1A, $2B, $1A, $26, $0D, $26, $0D, $24, $0D, $26, $1A, $24
L9940:  .byte $1A, $26, $1A, $26, $0D, $24, $1A, $26, $1A, $28, $1A, $28, $0D, $28, $0D, $26
L9950:  .byte $0D, $28, $1A, $26, $1A, $28, $1A, $28, $0D, $26, $1A, $28, $1A, $2B, $1A, $26
L9960:  .byte $0D, $26, $0D, $24, $0D, $26, $1A, $24, $1A, $26, $1A, $26, $0D, $24, $1A, $26
L9970:  .byte $1A, $28, $1A, $29, $0D, $29, $0D, $29, $0D, $29, $0D, $29, $0D, $2B, $1A, $29
L9980:  .byte $1A, $29, $0D, $28, $1A, $26, $1A, $24, $0D, $2D, $34, $2C, $0D, $2C, $27, $2A
L9990:  .byte $0D, $2A, $27, $2A, $0D, $2A, $06, $2C, $07, $2D, $0D, $2C, $06, $2D, $07, $2F
L99A0:  .byte $0D, $FF, $00, $92, $FE, $FB, $0C, $FD, $00, $03, $80, $FC, $0F, $21, $0D, $18
L99B0:  .byte $0D, $1C, $0D, $18, $0D, $21, $0D, $18, $0D, $1C, $0D, $21, $0D, $1F, $0D, $17
L99C0:  .byte $0D, $1A, $0D, $17, $0D, $1F, $0D, $17, $0D, $1A, $0D, $1F, $0D, $1F, $0D, $18
L99D0:  .byte $0D, $1C, $0D, $18, $0D, $1F, $0D, $18, $0D, $1C, $0D, $1F, $0D, $1F, $0D, $19
L99E0:  .byte $0D, $1C, $0D, $19, $0D, $1F, $0D, $19, $0D, $1C, $0D, $1F, $0D, $21, $0D, $1A
L99F0:  .byte $0D, $1D, $0D, $1A, $0D, $21, $0D, $19, $0D, $1D, $0D, $21, $0D, $21, $0D, $18
L9A00:  .byte $0D, $1D, $0D, $18, $0D, $21, $0D, $17, $0D, $1A, $0D, $1F, $0D, $1D, $0D, $16
L9A10:  .byte $0D, $1A, $0D, $16, $0D, $1D, $0D, $16, $0D, $1A, $0D, $1D, $0D, $1D, $0D, $1C
L9A20:  .byte $0D, $18, $0D, $1D, $0D, $1C, $0D, $18, $0D, $1D, $0D, $1C, $0D, $1D, $0D, $1C
L9A30:  .byte $0D, $18, $0D, $1D, $0D, $1C, $0D, $18, $0D, $1D, $0D, $1C, $0D, $21, $0D, $20
L9A40:  .byte $0D, $1C, $0D, $21, $0D, $20, $0D, $1C, $0D, $21, $0D, $20, $0D, $21, $0D, $20
L9A50:  .byte $0D, $1C, $0D, $21, $0D, $20, $0D, $1C, $0D, $21, $0D, $20, $0D, $21, $0D, $18
L9A60:  .byte $0D, $1C, $0D, $18, $0D, $21, $0D, $18, $0D, $1C, $0D, $21, $0D, $1F, $0D, $17
L9A70:  .byte $0D, $1A, $0D, $17, $0D, $1F, $0D, $17, $0D, $1A, $0D, $1F, $0D, $1F, $0D, $18
L9A80:  .byte $0D, $1C, $0D, $18, $0D, $1F, $0D, $18, $0D, $1C, $0D, $1F, $0D, $1F, $0D, $19
L9A90:  .byte $0D, $1C, $0D, $19, $0D, $1F, $0D, $19, $0D, $1C, $0D, $1F, $0D, $21, $0D, $1A
L9AA0:  .byte $0D, $1D, $0D, $1A, $0D, $21, $0D, $19, $0D, $1D, $0D, $21, $0D, $21, $0D, $18
L9AB0:  .byte $0D, $1D, $0D, $18, $0D, $21, $0D, $17, $0D, $1A, $0D, $1F, $0D, $1D, $0D, $16
L9AC0:  .byte $0D, $1A, $0D, $16, $0D, $1D, $0D, $16, $0D, $1A, $0D, $1D, $0D, $1D, $0D, $1C
L9AD0:  .byte $0D, $18, $0D, $1D, $0D, $1C, $0D, $18, $0D, $1D, $0D, $1C, $0D, $1D, $0D, $1C
L9AE0:  .byte $0D, $18, $0D, $1D, $0D, $1C, $0D, $18, $0D, $1D, $0D, $1C, $0D, $21, $0D, $20
L9AF0:  .byte $0D, $1C, $0D, $21, $0D, $20, $0D, $1C, $0D, $21, $0D, $20, $0D, $21, $0D, $20
L9B00:  .byte $0D, $1C, $0D, $21, $0D, $20, $0D, $1C, $0D, $21, $0D, $20, $0D, $FB, $0D, $FC
L9B10:  .byte $12, $24, $0D, $24, $0D, $23, $0D, $24, $1A, $23, $1A, $24, $1A, $24, $0D, $23
L9B20:  .byte $1A, $24, $1A, $28, $1A, $23, $0D, $23, $0D, $21, $0D, $23, $1A, $21, $1A, $23
L9B30:  .byte $1A, $23, $0D, $21, $1A, $23, $1A, $24, $1A, $24, $0D, $24, $0D, $23, $0D, $24
L9B40:  .byte $1A, $23, $1A, $24, $1A, $24, $0D, $23, $1A, $24, $1A, $28, $1A, $23, $0D, $23
L9B50:  .byte $0D, $21, $0D, $23, $1A, $21, $1A, $23, $1A, $23, $0D, $21, $1A, $23, $1A, $24
L9B60:  .byte $1A, $26, $0D, $26, $0D, $26, $0D, $26, $0D, $26, $0D, $28, $1A, $26, $1A, $26
L9B70:  .byte $0D, $24, $1A, $23, $1A, $21, $0D, $28, $34, $28, $0D, $28, $27, $26, $0D, $26
L9B80:  .byte $27, $26, $0D, $26, $06, $28, $07, $2A, $0D, $28, $06, $2A, $07, $2C, $0D, $FF
L9B90:  .byte $00, $16, $FE, $FB, $0F, $FD, $00, $03, $80, $FC, $10, $09, $0D, $09, $0D, $09
L9BA0:  .byte $0D, $09, $0D, $09, $0D, $09, $0D, $09, $0D, $09, $0D, $0B, $0D, $0B, $0D, $0B
L9BB0:  .byte $0D, $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D, $0C, $0D, $0C, $0D, $0C
L9BC0:  .byte $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0D, $0D, $0D, $0D, $0D
L9BD0:  .byte $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0E, $0D, $0E, $0D, $0E
L9BE0:  .byte $0D, $0E, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0C, $0D, $0C, $0D, $0C
L9BF0:  .byte $0D, $0C, $0D, $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D, $0A, $0D, $0A, $0D, $0A
L9C00:  .byte $0D, $0A, $0D, $0A, $0D, $0A, $0D, $0A, $0D, $0A, $0D, $0C, $0D, $0C, $0D, $0C
L9C10:  .byte $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C
L9C20:  .byte $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $10, $0D, $10, $0D, $10
L9C30:  .byte $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10
L9C40:  .byte $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $09, $0D, $09, $0D, $09
L9C50:  .byte $0D, $09, $0D, $09, $0D, $09, $0D, $09, $0D, $09, $0D, $0B, $0D, $0B, $0D, $0B
L9C60:  .byte $0D, $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D, $0C, $0D, $0C, $0D, $0C
L9C70:  .byte $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0D, $0D, $0D, $0D, $0D
L9C80:  .byte $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0E, $0D, $0E, $0D, $0E
L9C90:  .byte $0D, $0E, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0C, $0D, $0C, $0D, $0C
L9CA0:  .byte $0D, $0C, $0D, $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D, $0A, $0D, $0A, $0D, $0A
L9CB0:  .byte $0D, $0A, $0D, $0A, $0D, $0A, $0D, $0A, $0D, $0A, $0D, $0C, $0D, $0C, $0D, $0C
L9CC0:  .byte $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C
L9CD0:  .byte $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $10, $0D, $10, $0D, $10
L9CE0:  .byte $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10
L9CF0:  .byte $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $11, $0D, $11, $0D, $11
L9D00:  .byte $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D, $11
L9D10:  .byte $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D, $10, $0D, $10, $0D, $10
L9D20:  .byte $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10
L9D30:  .byte $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $11, $0D, $11, $0D, $11
L9D40:  .byte $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D, $11
L9D50:  .byte $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D, $10, $0D, $10, $0D, $10
L9D60:  .byte $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10
L9D70:  .byte $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $0E, $0D, $0E, $0D, $0E
L9D80:  .byte $0D, $0E, $0D, $0E, $0D, $0E, $0D, $0E, $0D, $0E, $0D, $0E, $0D, $0E, $0D, $0E
L9D90:  .byte $0D, $0E, $0D, $0E, $0D, $0E, $0D, $0E, $0D, $10, $1A, $10, $0D, $10, $0D, $10
L9DA0:  .byte $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10
L9DB0:  .byte $0D, $10, $06, $0E, $07, $0B, $0D, $10, $06, $0E, $07, $0B, $0D, $FF, $00, $D6
L9DC0:  .byte $FD, $0A, $82, $83, $84, $85, $87, $89, $8B, $8A, $8C, $8D, $10, $8D, $8D, $8D
L9DD0:  .byte $8D, $8D, $8D, $8D, $8D, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $12, $8C, $8B
L9DE0:  .byte $8A, $89, $89, $88, $88, $87, $87, $86, $86, $86, $85, $85, $85, $84, $84, $84
L9DF0:  .byte $84, $0A, $82, $83, $84, $85, $87, $89, $8B, $8A, $8C, $8D, $10, $8D, $8D, $8D
L9E00:  .byte $8D, $8D, $8D, $8D, $8D, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $8C, $10, $8C, $8B
L9E10:  .byte $8A, $89, $89, $88, $88, $87, $87, $86, $86, $86, $85, $85, $85, $84, $84, $84
L9E20:  .byte $84, $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $10, $0F, $0F, $0F, $0F, $0F
L9E30:  .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $08, $0F, $0F, $00, $00
L9E40:  .byte $00, $00, $00, $00, $00, $07, $85, $89, $8C, $8E, $90, $8C, $88, $01, $88, $0D
L9E50:  .byte $87, $88, $88, $88, $87, $87, $87, $87, $86, $86, $86, $86, $85, $85, $08, $0F
L9E60:  .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $20, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
L9E70:  .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
L9E80:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $08, $00, $00, $00, $00, $00, $00, $00
L9E90:  .byte $00, $00, $07, $85, $89, $8C, $8E, $90, $8C, $88, $01, $88, $0D, $87, $88, $88
L9EA0:  .byte $88, $87, $87, $87, $87, $86, $86, $86, $86, $85, $85, $FB, $0E, $FD, $00, $0F
L9EB0:  .byte $14, $FC, $13, $1D, $4E, $1D, $13, $1F, $14, $21, $13, $1A, $14, $22, $4E, $1D
L9EC0:  .byte $4E, $1F, $4E, $18, $27, $24, $27, $21, $9C, $FE, $27, $FE, $13, $1A, $14, $21
L9ED0:  .byte $13, $22, $14, $24, $13, $21, $14, $22, $3A, $1A, $3B, $1F, $27, $1D, $4E, $FE
L9EE0:  .byte $13, $1F, $0A, $20, $0A, $1F, $13, $1D, $14, $1D, $3A, $1D, $0A, $1F, $0A, $1C
L9EF0:  .byte $4E, $1D, $4E, $1D, $13, $1F, $14, $21, $13, $1A, $14, $22, $4E, $1D, $4E, $1F
L9F00:  .byte $4E, $18, $27, $24, $27, $21, $9C, $FE, $27, $FE, $13, $1A, $14, $21, $13, $22
L9F10:  .byte $14, $24, $13, $21, $14, $22, $3A, $1A, $3B, $1F, $27, $1D, $4E, $FE, $13, $1F
L9F20:  .byte $0A, $20, $0A, $1F, $13, $1D, $14, $1D, $3A, $1D, $0A, $1F, $0A, $1C, $4E, $28
L9F30:  .byte $13, $29, $27, $2B, $14, $28, $4E, $28, $13, $29, $27, $2B, $14, $2D, $13, $2B
L9F40:  .byte $06, $2D, $06, $2B, $08, $29, $13, $28, $14, $26, $3A, $24, $62, $24, $0C, $24
L9F50:  .byte $0D, $26, $0E, $26, $0C, $28, $0D, $28, $0E, $28, $0C, $28, $0D, $29, $0E, $29
L9F60:  .byte $0C, $2B, $0D, $2B, $0E, $28, $13, $29, $27, $2B, $14, $28, $4E, $28, $13, $29
L9F70:  .byte $27, $2B, $14, $2D, $13, $2B, $06, $2D, $06, $2B, $08, $29, $13, $28, $14, $26
L9F80:  .byte $3A, $24, $62, $24, $0C, $24, $0D, $26, $0E, $26, $0C, $28, $0D, $28, $0E, $28
L9F90:  .byte $0C, $28, $0D, $29, $0E, $29, $0C, $2B, $0D, $2B, $0E, $2C, $13, $29, $14, $29
L9FA0:  .byte $13, $26, $14, $26, $13, $23, $27, $2C, $14, $2C, $13, $29, $14, $29, $13, $26
L9FB0:  .byte $14, $26, $13, $23, $3B, $28, $3A, $28, $0A, $29, $0A, $2B, $3A, $2B, $0A, $2D
L9FC0:  .byte $0A, $2E, $3A, $2E, $0A, $30, $0A, $2D, $4E, $FF, $00, $E2, $FE, $FB, $0C, $FD
L9FD0:  .byte $00, $0A, $18, $FC, $14, $FE, $13, $1A, $14, $1D, $13, $1F, $14, $21, $27, $1A
L9FE0:  .byte $27, $FE, $13, $1A, $14, $1D, $13, $1F, $14, $22, $27, $1A, $27, $FE, $13, $18
L9FF0:  .byte $14, $1C, $13, $1D, $14, $1F, $27, $18, $27, $FE, $13, $18, $14, $1D, $13, $1F

;----------------------------------------------------------------------------------------------------

InitSFX:
LA000:  ASL                     ;*4. 4 bytes of data per channel.
LA001:  ASL                     ;

LA002:  TAY                     ;
LA003:  LDA SFXInitData,Y       ;Get the channel number to be updated(0 to 3).
LA006:  STA SFXChannel,X        ;

LA009:  AND #$03                ;Get the channel for the current SFX data.
LA00B:  ASL                     ;
LA00C:  ASL                     ;*4. 4 control registers per channel.
LA00D:  TAX                     ;

LA00E:  INY
LA00F:  LDA SFXInitData,Y
LA012:  STA SFXLeft,X
LA015:  INY
LA016:  LDA SFXInitData,Y
LA019:  STA SFXPtrLB,X
LA01C:  INY
LA01D:  LDA SFXInitData,Y
LA020:  STA SFXPtrUB,X
LA023:  INY
LA024:  LDA SFXPtrLB,X
LA027:  STA GenPtrF0LB
LA029:  LDA SFXPtrUB,X
LA02C:  STA GenPtrF1UB

LA02E:  LDY #$00
LA030:  LDA (GenPtrF0),Y
LA032:  STA ChnCntrl0,X
LA035:  INY
LA036:  LDA (GenPtrF0),Y
LA038:  STA ChnCntrl1,X
LA03B:  INY
LA03C:  LDA (GenPtrF0),Y
LA03E:  STA ChnCntrl2,X
LA041:  INY
LA042:  LDA (GenPtrF0),Y
LA044:  STA ChnCntrl3,X
LA047:  INY
LA048:  TYA
LA049:  STA SFXIndex,X
LA04C:  RTS

LA04D:  .byte $03, $09, $6B
LA050:  .byte $A1, $03, $09, $81, $A1, $22, $27, $1A, $27, $FE, $13, $18, $14, $1C, $13, $1D
LA060:  .byte $14, $1F, $27, $18, $27, $FE, $13, $18, $14, $1D, $13, $1F, $14, $21, $27, $18
LA070:  .byte $27, $FE, $13, $1A, $14, $1E, $13, $21, $14, $24, $13, $22, $14, $21, $13, $1E
LA080:  .byte $14, $FE, $13, $1F, $14, $1A, $13, $22, $14, $24, $13, $22, $06, $24, $06, $22
LA090:  .byte $08, $21, $13, $1A, $14, $FE, $13, $1D, $14, $17, $13, $1A, $14, $1D, $13, $17
LA0A0:  .byte $14, $20, $13, $1D, $14, $1A, $3A, $1A, $0A, $1C, $0A, $19, $4E, $FC, $16, $FE
LA0B0:  .byte $13, $26, $0A, $28, $0A, $29, $09, $28, $0A, $26, $0A, $28, $0A, $FE, $13, $26
LA0C0:  .byte $0A, $28, $0A, $29, $09, $28, $0A, $26, $0A, $28, $0A, $FE, $13, $26, $0A, $28
LA0D0:  .byte $0A, $29, $09, $28, $0A, $26, $0A, $28, $0A, $FE, $13, $26, $0A, $28, $0A, $29
LA0E0:  .byte $09, $28, $0A, $26, $0A, $28, $0A, $FE, $13, $24, $0A, $26, $0A, $28, $09, $26
LA0F0:  .byte $0A, $24, $0A, $26, $0A, $FE, $13, $24, $0A, $26, $0A, $28, $09, $26, $0A, $24

UpdateSFX:
LA100:  LDX #$00                ;Start with SQ1 SFX data.

UpdateSFXChnLoop:
LA102:  LDA SFXLeft,X           ;Is there remaining time to play current SFX?
LA105:  BEQ FinishSFXChnUpdate  ;If not, branch to check next channel.

LA107:  LDA SFXChannel,X        ;
LA10A:  AND #$F0                ;Does only control register 0 needs to be updated?
LA10C:  CMP #$10                ;If so, branch(does not appear to be used in this game).
LA10E:  BEQ SFX1RegUpdate       ;

LA110:  LDY SFXIndex,X
LA113:  LDA SFXPtrLB,X
LA116:  STA GenPtrF0LB
LA118:  LDA SFXPtrUB,X
LA11B:  STA GenPtrF1UB

LA11D:  LDA (GenPtrF0),Y
LA11F:  STA ChnCntrl0,X
LA122:  INY
LA123:  LDA (GenPtrF0),Y
LA125:  STA ChnCntrl2,X
LA128:  INY
LA129:  JMP SFXDecrementTime    ;($A13F)Dec rement remining time for SFX channel.

SFX1RegUpdate:
LA12C:  LDY SFXIndex,X
LA12F:  LDA SFXPtrLB,X
LA132:  STA GenPtrF0LB
LA134:  LDA SFXPtrUB,X
LA137:  STA GenPtrF1UB
LA139:  LDA (GenPtrF0),Y
LA13B:  STA ChnCntrl0,X
LA13E:  INY

SFXDecrementTime:
LA13F:  TYA
LA140:  STA SFXIndex,X
LA143:  DEC SFXLeft,X
LA146:  BNE LA14D
LA148:  LDA #$01
LA14A:  STA SFXFinished,X

FinishSFXChnUpdate:
LA14D:  INX
LA14E:  INX
LA14F:  INX
LA150:  INX
LA151:  CPX #$10
LA153:  BCC UpdateSFXChnLoop

LA155:  LDA #$0F
LA157:  STA APUCommonCntrl0
LA15A:  RTS

;----------------------------------------------------------------------------------------------------

;The following table loads the control bytes for each channel to turn it off.

_SilenceChnTbl:
LA15B:  .byte $30, $11, $00, $00 ;SQ1 channel.
LA15F:  .byte $30, $11, $00, $00 ;SQ2 channel.
LA163:  .byte $80, $00, $00, $00 ;Triangle channel.
LA167:  .byte $30, $00, $00, $00 ;Noise channel.

;----------------------------------------------------------------------------------------------------

SFXInitData:
LA16B:  .byte $03, $1E
LA16D:  .word $A23B

LA16F:  .byte $00, $08
LA171:  .word $A27B

LA173:  .byte $00, $08
LA175:  .word $A28F

LA177:  .byte $01, $08
LA179:  .word $A2A3

LA17B:  .byte $01, $08
LA17D:  .word $A2B7

LA17F:  .byte $01, $33
LA181:  .word $A2CB

LA183:  .byte $01, $33
LA185:  .word $A335

LA187:  .byte $01, $33, $9F, $A3
LA18B:  .byte $03, $0F, $09, $A4
LA18F:  .byte $00, $1B, $2B, $A4
LA193:  .byte $00, $1B, $65, $A4
LA197:  .byte $00, $1B, $9F, $A4
LA19B:  .byte $00, $1B, $D9, $A4
LA19F:  .byte $00, $0F, $13, $A5
LA1A3:  .byte $00, $0F, $35, $A5
LA1A7:  .byte $00, $11, $57, $A5
LA1AB:  .byte $00, $1A, $7D, $A5
LA1AF:  .byte $00, $21, $B5, $A5
LA1B3:  .byte $00, $21, $FB, $A5
LA1B7:  .byte $10, $3D, $41, $A6
LA1BB:  .byte $03, $1C, $82, $A6
LA1BF:  .byte $03, $1C, $BE, $A6
LA1C3:  .byte $03, $0F, $FA, $A6
LA1C7:  .byte $03, $0E, $1C, $A7
LA1CB:  .byte $03, $09, $3C, $A7
LA1CF:  .byte $03, $09, $52, $A7
LA1D3:  .byte $03, $09, $68, $A7
LA1D7:  .byte $00, $04, $7E, $A7
LA1DB:  .byte $03, $05, $8A, $A7
LA1DF:  .byte $03, $09, $98, $A7
LA1E3:  .byte $00, $09, $AE, $A7
LA1E7:  .byte $00, $09, $C4, $A7
LA1EB:  .byte $00, $09, $DA, $A7
LA1EF:  .byte $00, $09, $F0, $A7
LA1F3:  .byte $00, $14, $06, $A8
LA1F7:  .byte $00, $14, $32, $A8
LA1FB:  .byte $00, $39, $5E, $A8
LA1FF:  .byte $03, $39, $D4, $A8
LA203:  .byte $03, $39, $4A, $A9
LA207:  .byte $03, $2C, $C0, $A9
LA20B:  .byte $00, $21, $1C, $AA
LA20F:  .byte $00, $1F, $62, $AA
LA213:  .byte $00, $1F, $A4, $AA
LA217:  .byte $00, $1F, $E6, $AA
LA21B:  .byte $01, $1E, $28, $AB
LA21F:  .byte $03, $08, $68, $AB
LA223:  .byte $03, $0A, $7C, $AB
LA227:  .byte $00, $09, $94, $AB
LA22B:  .byte $00, $09, $AA, $AB
LA22F:  .byte $02, $09, $C0, $AB
LA233:  .byte $02, $09, $D6, $AB
LA237:  .byte $02, $0C, $EC, $AB

;----------------------------------------------------------------------------------------------------

;The following data tables contain the SFX data. The first 4 bytes are loaded into control registers
;0 through 3 on initialization. During the SFX updates, only control registers 0 and 2 are updated.

LA23B:  .byte $3F, $40, $04, $01
LA23F:  .byte $3F, $0F
LA241:  .byte $3F, $0F
LA243:  .byte $3F, $0F
LA245:  .byte $3F, $0F
LA247:  .byte $3F, $0F
La249:  .byte $3F, $0F
LA24B:  .byte $38, $08
La24D:  .byte $38, $08
LA24F:  .byte $38, $08
La251:  .byte $38, $08
LA253:  .byte $38, $08
LA255:  .byte $38, $08
LA257:  .byte $38, $06
La259:  .byte $38, $06
LA25B:  .byte $38, $06
LA25D:  .byte $38, $06
LA25F:  .byte $38, $06
LA261:  .byte $38, $06
LA263:  .byte $34, $04
LA265:  .byte $34, $04
LA267:  .byte $34, $04
LA269:  .byte $34, $04
LA26B:  .byte $34, $04
LA26D:  .byte $34, $04
LA26F:  .byte $34, $04
LA271:  .byte $34, $04
LA273:  .byte $30, $04
LA275:  .byte $30, $04
LA277:  .byte $30, $04
LA279:  .byte $30, $04

LA27B:  .byte $3F, $93, $20, $00
LA27F:  .byte $3E, $40, $7D, $50
LA283:  .byte $3C, $00, $7B, $00
LA287:  .byte $3A, $00, $79, $00
LA28B:  .byte $38, $02, $77, $02

LA28F:  .byte $3F
LA290:  .byte $92, $20, $00, $3D, $40, $7B, $50, $39, $00, $77, $00, $35, $00, $73, $00, $31
LA2A0:  .byte $02, $70, $02, $30, $00, $20, $01, $3C, $44, $3A, $54, $3A, $04, $3A, $44, $38
LA2B0:  .byte $04, $38, $04, $30, $04, $30, $04, $30, $00, $20, $01, $7C, $00, $BA, $00, $FA
LA2C0:  .byte $00, $3A, $00, $78, $00, $B8, $00, $F4, $00, $30, $00, $BF, $00, $F0, $00, $FF
LA2D0:  .byte $E0, $BF, $D0, $FE, $B0, $BE, $DC, $FE, $BC, $FD, $B0, $BD, $D8, $FD, $B8, $FC
LA2E0:  .byte $B0, $BC, $D4, $FC, $B4, $FB, $B0, $BB, $D0, $FB, $B0, $FA, $B0, $BA, $CC, $FA
LA2F0:  .byte $BC, $F9, $B0, $B9, $C8, $F9, $B8, $F8, $B0, $B8, $C4, $F8, $B4, $F7, $B0, $B7
LA300:  .byte $C0, $F7, $B0, $F6, $B0, $B6, $BC, $F6, $BC, $F5, $B0, $B5, $B8, $F5, $B8, $F4
LA310:  .byte $B0, $B4, $B4, $F4, $B4, $F3, $B0, $B3, $B0, $F3, $B0, $F2, $B0, $B2, $AC, $F2
LA320:  .byte $BC, $F2, $B0, $B2, $A8, $F2, $B8, $F2, $B0, $B2, $A4, $F2, $B4, $F1, $B0, $B1
LA330:  .byte $A0, $F1, $B0, $70, $20, $BF, $00, $F0, $00, $FF, $E0, $BF, $D0, $FE, $B0, $BE
LA340:  .byte $FC, $FE, $BC, $FD, $B0, $BD, $F8, $FD, $B8, $FC, $B0, $BC, $F4, $FC, $B4, $FB
LA350:  .byte $B0, $BB, $F0, $FB, $B0, $FA, $B0, $BA, $EC, $FA, $BC, $F9, $B0, $B9, $E8, $F9
LA360:  .byte $B8, $F8, $B0, $B8, $E4, $F8, $B4, $F7, $B0, $B7, $E0, $F7, $B0, $F6, $B0, $B6
LA370:  .byte $DC, $F6, $BC, $F5, $B0, $B5, $D8, $F5, $B8, $F4, $B0, $B4, $D4, $F4, $B4, $F3
LA380:  .byte $B0, $B3, $D0, $F3, $B0, $F2, $B0, $B2, $CC, $F2, $BC, $F2, $B0, $B2, $C8, $F2
LA390:  .byte $B8, $F2, $B0, $B2, $C4, $F2, $B4, $F1, $B0, $B1, $C0, $F1, $B0, $70, $20, $BF
LA3A0:  .byte $BB, $F0, $00, $FF, $E0, $BF, $D0, $FE, $B0, $BE, $FC, $FE, $BC, $FD, $B0, $BD
LA3B0:  .byte $F8, $FD, $B8, $FC, $B0, $BC, $F4, $FC, $B4, $FB, $B0, $BB, $F0, $FB, $B0, $FA
LA3C0:  .byte $B0, $BA, $EC, $FA, $BC, $F9, $B0, $B9, $E8, $F9, $B8, $F8, $B0, $B8, $E4, $F8
LA3D0:  .byte $B4, $F7, $B0, $B7, $E0, $F7, $B0, $F6, $B0, $B6, $DC, $F6, $BC, $F5, $B0, $B5
LA3E0:  .byte $D8, $F5, $B8, $F4, $B0, $B4, $D4, $F4, $B4, $F3, $B0, $B3, $D0, $F3, $B0, $F2
LA3F0:  .byte $B0, $B2, $CC, $F2, $BC, $F2, $B0, $B2, $C8, $F2, $B8, $F2, $B0, $B2, $C4, $F2
LA400:  .byte $B4, $F1, $B0, $B1, $C0, $F1, $B0, $70, $20, $BF, $00, $0C, $00, $FF, $0C, $BF
LA410:  .byte $08, $FF, $0C, $BF, $08, $FF, $0C, $FC, $08, $BC, $0C, $FA, $08, $FA, $0C, $B8
LA420:  .byte $08, $F8, $0C, $F6, $08, $B4, $0C, $F2, $08, $70, $00, $3F, $04, $0C, $01, $3F
LA430:  .byte $04, $3F, $00, $3C, $06, $3C, $06, $3C, $06, $38, $06, $38, $06, $38, $06, $36
LA440:  .byte $06, $36, $06, $36, $06, $34, $06, $34, $06, $34, $06, $34, $06, $34, $06, $34
LA450:  .byte $06, $32, $06, $32, $06, $32, $06, $31, $06, $31, $06, $31, $06, $31, $06, $31
LA460:  .byte $06, $31, $06, $70, $00, $3F, $00, $C0, $00, $3F, $F0, $3F, $E0, $3C, $D0, $7C
LA470:  .byte $C0, $BC, $F0, $38, $E0, $78, $D0, $B8, $C0, $36, $F0, $76, $E0, $B6, $D0, $34
LA480:  .byte $C0, $74, $F0, $B4, $E0, $34, $D0, $74, $C0, $B4, $F0, $32, $E0, $72, $D0, $B2
LA490:  .byte $C0, $31, $F0, $71, $E0, $B1, $D0, $31, $C0, $71, $F0, $B1, $E0, $70, $80, $3F
LA4A0:  .byte $00, $20, $00, $7F, $20, $FF, $20, $3C, $20, $7C, $20, $FC, $20, $38, $22, $78
LA4B0:  .byte $22, $F8, $22, $36, $24, $76, $24, $F6, $24, $34, $26, $74, $26, $F4, $26, $34
LA4C0:  .byte $28, $74, $28, $F4, $28, $32, $2A, $72, $2A, $F2, $2A, $31, $2C, $71, $2C, $F1
LA4D0:  .byte $2C, $31, $2E, $71, $2E, $F1, $2E, $70, $80, $7F, $00, $30, $00, $7F, $30, $7F
LA4E0:  .byte $30, $7C, $30, $7C, $30, $7C, $30, $78, $32, $78, $32, $78, $32, $76, $34, $76
LA4F0:  .byte $34, $76, $34, $74, $36, $74, $36, $74, $36, $74, $38, $74, $38, $74, $38, $72
LA500:  .byte $3A, $72, $3A, $72, $3A, $71, $3C, $71, $3C, $71, $3C, $71, $3E, $71, $3E, $71
LA510:  .byte $3E, $70, $80, $3F, $00, $E0, $00, $3F, $D8, $3F, $D0, $3D, $C4, $3D, $D8, $3D
LA520:  .byte $AC, $3B, $A0, $3B, $90, $3B, $80, $38, $70, $38, $60, $38, $50, $34, $40, $34
LA530:  .byte $30, $34, $20, $70, $00, $FF, $00, $E0, $00, $FF, $D8, $FF, $D0, $FD, $C4, $FD
LA540:  .byte $D8, $FD, $AC, $FB, $A0, $FB, $90, $FB, $80, $F8, $70, $F8, $60, $F8, $50, $F4
LA550:  .byte $40, $F4, $30, $F4, $20, $70, $00, $FF, $00, $80, $00, $FF, $40, $FF, $78, $FD
LA560:  .byte $48, $FD, $70, $FD, $50, $FB, $68, $FB, $58, $FB, $60, $F8, $60, $F8, $68, $F8
LA570:  .byte $70, $F4, $78, $F4, $80, $F4, $88, $F4, $90, $F4, $98, $70, $A0, $FF, $00, $80
LA580:  .byte $00, $FF, $60, $FF, $40, $FD, $60, $FD, $78, $FD, $60, $FB, $48, $FB, $60, $FB
LA590:  .byte $70, $F8, $60, $F8, $50, $F8, $60, $F7, $68, $F7, $60, $F6, $58, $F6, $60, $F5
LA5A0:  .byte $58, $F4, $50, $F4, $48, $F4, $40, $F4, $38, $F4, $30, $F4, $28, $F4, $24, $F2
LA5B0:  .byte $20, $F2, $1C, $70, $1C, $BF, $00, $60, $00, $BF, $70, $BF, $80, $BF, $C0, $BF
LA5C0:  .byte $80, $BD, $F0, $BD, $60, $BD, $10, $BD, $20, $BB, $F0, $BB, $C0, $BB, $C0, $BB
LA5D0:  .byte $40, $B9, $80, $B9, $A8, $B9, $10, $B9, $F0, $B7, $80, $B7, $10, $B7, $D0, $B7
LA5E0:  .byte $10, $B5, $30, $B5, $F0, $B5, $50, $B5, $B0, $B3, $70, $B3, $50, $B3, $D0, $B3
LA5F0:  .byte $60, $B1, $90, $B1, $30, $B1, $20, $B1, $30, $B0, $80, $BF, $00, $10, $00, $BF
LA600:  .byte $12, $BF, $14, $BF, $16, $BF, $18, $BD, $1A, $BD, $1C, $BD, $1E, $BD, $20, $BB
LA610:  .byte $24, $BB, $28, $BB, $2C, $BB, $30, $B9, $34, $B9, $38, $B9, $3C, $B9, $40, $B7
LA620:  .byte $48, $B7, $50, $B7, $58, $B7, $60, $B5, $68, $B5, $70, $B5, $78, $B5, $80, $B3
LA630:  .byte $90, $B3, $A0, $B3, $B0, $B3, $C0, $B1, $D0, $B1, $E0, $B1, $F0, $B1, $FF, $B0
LA640:  .byte $80, $BF, $94, $20, $00, $BF, $B0, $BF, $B0, $BE, $B0, $BE, $B0, $BD, $B0, $BD
LA650:  .byte $B0, $BC, $B0, $BC, $B0, $BB, $B0, $BB, $B0, $BA, $B0, $BA, $B0, $B9, $B0, $B9
LA660:  .byte $B0, $B8, $B0, $B8, $B0, $B7, $B0, $B7, $B0, $B6, $B0, $B6, $B0, $B5, $B0, $B5
LA670:  .byte $B0, $B4, $B0, $B4, $B0, $B3, $B0, $B3, $B0, $B2, $B0, $B2, $B0, $B1, $B1, $B1
LA680:  .byte $B1, $B0, $38, $00, $07, $F0, $3F, $08, $3D, $09, $3B, $0A, $39, $0B, $38, $0C
LA690:  .byte $38, $0D, $37, $0E, $37, $0F, $36, $0F, $36, $0F, $35, $0F, $35, $0F, $36, $0F
LA6A0:  .byte $36, $0F, $35, $0F, $35, $0F, $34, $0F, $34, $0F, $34, $0F, $33, $0F, $33, $0F
LA6B0:  .byte $33, $0F, $33, $0F, $32, $0F, $32, $0F, $32, $0F, $32, $0F, $30, $0F, $38, $00
LA6C0:  .byte $07, $F0, $3F, $09, $3D, $0B, $3B, $0E, $39, $0B, $38, $09, $38, $07, $37, $07
LA6D0:  .byte $37, $07, $36, $07, $36, $07, $35, $07, $35, $07, $36, $07, $36, $07, $35, $07
LA6E0:  .byte $35, $07, $34, $07, $34, $07, $34, $07, $33, $07, $33, $07, $33, $07, $33, $07
LA6F0:  .byte $32, $07, $32, $07, $32, $07, $32, $07, $30, $07, $38, $00, $07, $F0, $3F, $09
LA700:  .byte $3D, $0B, $3B, $0E, $39, $0B, $38, $09, $37, $0A, $36, $0A, $35, $0A, $34, $0A
LA710:  .byte $34, $0A, $33, $0A, $33, $0A, $32, $0A, $32, $0A, $30, $0A, $34, $00, $0F, $F0
LA720:  .byte $3B, $0C, $3F, $09, $3B, $09, $38, $0A, $37, $0B, $36, $0C, $35, $0C, $34, $0C
LA730:  .byte $34, $0C, $33, $0C, $33, $0C, $32, $0C, $32, $0C, $30, $0C, $34, $00, $0B, $F0
LA740:  .byte $38, $0B, $3C, $0C, $3F, $0C, $34, $0E, $30, $0E, $30, $0C, $30, $0C, $30, $0C
LA750:  .byte $30, $0C, $34, $00, $09, $F0, $38, $09, $3C, $09, $3F, $09, $34, $0A, $30, $0A
LA760:  .byte $30, $0C, $30, $0C, $30, $0C, $30, $0C, $34, $00, $09, $F0, $38, $09, $3C, $09
LA770:  .byte $3F, $09, $34, $0A, $30, $0A, $30, $0C, $30, $0C, $30, $0C, $30, $0C, $BF, $81
LA780:  .byte $00, $02, $BF, $00, $BF, $00, $BF, $00, $B0, $00, $32, $00, $07, $F0, $38, $07
LA790:  .byte $3F, $07, $38, $07, $34, $07, $30, $00, $3F, $00, $0F, $F0, $3F, $0D, $3F, $0C
LA7A0:  .byte $3F, $0B, $3F, $0A, $3F, $09, $3F, $09, $3F, $09, $3F, $09, $30, $00, $3F, $00
LA7B0:  .byte $C0, $00, $7F, $C0, $3F, $C0, $7E, $C0, $3E, $C0, $7B, $C0, $3A, $C0, $78, $C0
LA7C0:  .byte $34, $C0, $30, $00, $B4, $00, $F0, $00, $B8, $E0, $BF, $D0, $BE, $C0, $BE, $B0
LA7D0:  .byte $BB, $A0, $BA, $90, $B8, $80, $B4, $70, $B0, $00, $B4, $00, $40, $00, $B8, $3C
LA7E0:  .byte $BF, $38, $BE, $34, $BE, $30, $BB, $3C, $BA, $28, $B8, $24, $B4, $20, $B0, $10
LA7F0:  .byte $B4, $00, $80, $00, $B8, $40, $BF, $70, $BE, $40, $BE, $60, $BB, $40, $BA, $50
LA800:  .byte $B8, $40, $B4, $40, $B0, $10, $BF, $00, $F0, $00, $BC, $D0, $BF, $B0, $BC, $90
LA810:  .byte $BF, $70, $BC, $F0, $BF, $D0, $BC, $B0, $BF, $90, $BF, $70, $BC, $F0, $BF, $D0
LA820:  .byte $BC, $B0, $BF, $90, $BF, $70, $BC, $F0, $BF, $D0, $BC, $B0, $BF, $90, $BF, $70
LA830:  .byte $B0, $40, $BF, $00, $F0, $00, $BC, $D0, $BF, $B0, $BC, $90, $BF, $70, $B8, $F0
LA840:  .byte $BC, $D0, $B8, $B0, $BC, $90, $B8, $70, $B4, $F0, $B8, $D0, $B4, $B0, $B8, $90
LA850:  .byte $B4, $70, $B2, $F0, $B4, $D0, $B2, $B0, $B4, $90, $B2, $70, $B0, $40, $BF, $00
LA860:  .byte $F0, $00, $BF, $E0, $BF, $D0, $BF, $C0, $BF, $B0, $BF, $A0, $BF, $90, $BF, $80
LA870:  .byte $BF, $70, $BD, $E0, $BD, $D0, $BD, $C0, $BD, $B0, $BD, $A0, $BD, $90, $BD, $80
LA880:  .byte $BD, $70, $BB, $E0, $BB, $D0, $BB, $C0, $BB, $B0, $BB, $A0, $BB, $90, $BB, $80
LA890:  .byte $BB, $70, $B9, $E0, $B9, $D0, $B9, $C0, $B9, $B0, $B9, $A0, $B9, $90, $B9, $80
LA8A0:  .byte $B9, $70, $B7, $E0, $B7, $D0, $B7, $C0, $B7, $B0, $B7, $A0, $B7, $90, $B7, $80
LA8B0:  .byte $B7, $70, $B5, $E0, $B5, $D0, $B5, $C0, $B5, $B0, $B5, $A0, $B5, $90, $B5, $80
LA8C0:  .byte $B5, $70, $B3, $E0, $B3, $D0, $B3, $C0, $B3, $B0, $B3, $A0, $B3, $90, $B3, $80
LA8D0:  .byte $B3, $70, $B0, $40, $3F, $00, $0F, $F0, $3F, $0E, $3F, $0D, $3F, $0C, $3F, $0B
LA8E0:  .byte $3F, $0A, $3F, $09, $3F, $08, $3F, $07, $3D, $0E, $3D, $0D, $3D, $0C, $3D, $0B
LA8F0:  .byte $3D, $0A, $3D, $09, $3D, $08, $3D, $07, $3B, $0E, $3B, $0D, $3B, $0C, $3B, $0B
LA900:  .byte $3B, $0A, $3B, $09, $3B, $08, $3B, $07, $39, $0E, $39, $0D, $39, $0C, $39, $0B
LA910:  .byte $39, $0A, $39, $09, $39, $08, $39, $07, $37, $0E, $37, $0D, $37, $0C, $37, $0B
LA920:  .byte $37, $0A, $37, $09, $37, $08, $37, $07, $35, $0E, $35, $0D, $35, $0C, $35, $0B
LA930:  .byte $35, $0A, $35, $09, $35, $08, $35, $07, $33, $0E, $33, $0D, $33, $0C, $33, $0B
LA940:  .byte $33, $0A, $33, $09, $33, $08, $33, $07, $30, $04, $3F, $00, $0F, $F0, $3F, $0D
LA950:  .byte $3F, $0B, $3F, $0D, $3F, $0F, $3F, $0D, $3F, $0B, $3F, $0D, $3F, $0F, $3D, $0D
LA960:  .byte $3D, $0B, $3D, $0D, $3D, $0F, $3D, $0D, $3D, $0B, $3D, $0D, $3D, $0F, $3B, $0D
LA970:  .byte $3B, $0B, $3B, $0D, $3B, $0F, $3B, $0D, $3B, $0B, $3B, $0D, $3B, $0F, $39, $0D
LA980:  .byte $39, $0B, $39, $0D, $39, $0F, $39, $0D, $39, $0B, $39, $0D, $39, $0F, $37, $0D
LA990:  .byte $37, $0B, $37, $0D, $37, $0F, $37, $0D, $37, $0B, $37, $0D, $37, $0F, $35, $0D
LA9A0:  .byte $35, $0B, $35, $0D, $35, $0F, $35, $0D, $35, $0B, $35, $0D, $35, $0F, $33, $0D
LA9B0:  .byte $33, $0B, $33, $0D, $33, $0F, $33, $0D, $33, $0B, $33, $0D, $33, $0F, $30, $04
LA9C0:  .byte $3F, $00, $0B, $F8, $3F, $0B, $3F, $0B, $3F, $0B, $3E, $0B, $3E, $0B, $3E, $0B
LA9D0:  .byte $3E, $0B, $3D, $0A, $3D, $0A, $3D, $0A, $3D, $0A, $3C, $0A, $3C, $0A, $3C, $0A
LA9E0:  .byte $3C, $0A, $3B, $0A, $3B, $0A, $3B, $0A, $3B, $0A, $3A, $0A, $3A, $0A, $3A, $0A
LA9F0:  .byte $3A, $0A, $39, $09, $39, $09, $39, $09, $39, $09, $38, $09, $38, $09, $38, $09
LAA00:  .byte $38, $09, $37, $09, $37, $09, $37, $09, $37, $09, $36, $09, $36, $09, $36, $09
LAA10:  .byte $36, $09, $35, $09, $35, $09, $35, $09, $35, $09, $30, $04, $BF, $00, $80, $00
LAA20:  .byte $BF, $A0, $BF, $C0, $BF, $A0, $BF, $80, $BD, $68, $BD, $58, $BD, $68, $BD, $84
LAA30:  .byte $BB, $A0, $BB, $C0, $BB, $A0, $BB, $80, $B9, $68, $B9, $58, $B9, $68, $B9, $84
LAA40:  .byte $B7, $A0, $B7, $C0, $B7, $A0, $B7, $80, $B5, $68, $B5, $58, $B5, $68, $B5, $84
LAA50:  .byte $B3, $A0, $B3, $C0, $B3, $A0, $B3, $80, $B1, $68, $B1, $58, $B1, $68, $B1, $84
LAA60:  .byte $B0, $80, $BF, $00, $8C, $00, $BF, $61, $BF, $86, $BE, $FB, $BE, $C0, $BD, $D5
LAA70:  .byte $BD, $3A, $BC, $EF, $BC, $F4, $BB, $49, $BB, $EE, $BA, $E3, $BA, $28, $B9, $BD
LAA80:  .byte $B9, $A2, $B8, $D7, $B8, $5C, $B7, $31, $B7, $56, $B6, $CB, $B6, $90, $B5, $A5
LAA90:  .byte $B5, $0A, $B4, $BF, $B4, $C4, $B3, $19, $B3, $BE, $B2, $B3, $B2, $F8, $B1, $8D
LAAA0:  .byte $B1, $72, $B0, $10, $B4, $00, $8C, $01, $B4, $61, $B8, $86, $BC, $FB, $BE, $C0
LAAB0:  .byte $BD, $D5, $BD, $3A, $BC, $EF, $BC, $F4, $BB, $49, $BB, $EE, $BA, $E3, $BA, $28
LAAC0:  .byte $B9, $BD, $B9, $A2, $B8, $D7, $B8, $5C, $B7, $31, $B7, $56, $B6, $CB, $B6, $90
LAAD0:  .byte $B5, $A5, $B5, $0A, $B4, $BF, $B4, $C4, $B3, $19, $B3, $BE, $B2, $B3, $B2, $F8
LAAE0:  .byte $B1, $8D, $B1, $72, $B0, $10, $B4, $00, $5C, $00, $B4, $41, $B8, $56, $BC, $6B
LAAF0:  .byte $BE, $50, $BD, $45, $BD, $5A, $BC, $6F, $BC, $54, $BB, $49, $BB, $5E, $BA, $63
LAB00:  .byte $BA, $58, $B9, $4D, $B9, $52, $B8, $67, $B8, $55, $B7, $41, $B7, $56, $B6, $6B
LAB10:  .byte $B6, $50, $B5, $45, $B5, $5A, $B4, $6F, $B4, $54, $B3, $49, $B3, $5E, $B2, $63
LAB20:  .byte $B2, $58, $B1, $4D, $B1, $52, $B0, $10, $BF, $00, $36, $00, $BF, $36, $BF, $36
LAB30:  .byte $BF, $36, $BF, $36, $BE, $35, $BE, $35, $BD, $35, $BD, $35, $BC, $34, $BC, $34
LAB40:  .byte $BB, $34, $BB, $34, $BA, $33, $BA, $33, $B9, $33, $B9, $33, $B8, $32, $B8, $32
LAB50:  .byte $B7, $32, $B7, $32, $B6, $31, $B6, $31, $B5, $31, $B5, $31, $B4, $30, $B4, $30
LAB60:  .byte $B3, $30, $B3, $30, $B2, $2F, $B2, $2F, $38, $00, $07, $00, $3C, $07, $3F, $08
LAB70:  .byte $38, $09, $34, $0A, $30, $0A, $30, $0A, $30, $0A, $30, $0A, $36, $00, $04, $00
LAB80:  .byte $33, $07, $36, $04, $34, $07, $38, $04, $34, $07, $36, $04, $33, $04, $30, $0A
LAB90:  .byte $30, $0A, $30, $0A, $B6, $00, $60, $00, $BA, $90, $BF, $70, $BC, $A0, $BA, $80
LABA0:  .byte $B7, $C0, $B5, $90, $B2, $E0, $B1, $A0, $B0, $10, $B6, $00, $00, $01, $3A, $10
LABB0:  .byte $BF, $20, $3C, $30, $BA, $40, $37, $50, $B5, $60, $32, $70, $B1, $80, $B0, $90
LABC0:  .byte $B6, $00, $00, $02, $3A, $30, $BF, $10, $3C, $40, $BA, $30, $37, $60, $B5, $40
LABD0:  .byte $32, $80, $B1, $60, $B0, $A0, $36, $00, $00, $01, $3A, $20, $3F, $40, $3C, $60
LABE0:  .byte $3A, $80, $37, $A0, $35, $C0, $32, $E0, $31, $F0, $30, $F0

LABEC:  .byte $36, $00, $30, $00
LABF0:  .byte $3A, $1E
LABF2:  .byte $3F, $4C
LABF4:  .byte $3C, $2A
LABF6:  .byte $3A, $58
LABF8:  .byte $37, $36
LABFA:  .byte $35, $64
LABFC:  .byte $35, $42
LABFE:  .byte $35, $80
LAC00:  .byte $35, $A0
LAC02:  .byte $35, $C0
LAC04:  .byte $35, $E0
LAC06:  .byte $30, $80

LAC08:  .byte $1D, $0E, $1D, $0E, $1F, $07, $21, $07
LAC10:  .byte $22, $0E, $21, $0E, $1F, $0E, $21, $0E, $1F, $0E, $1F, $0E, $1F, $0E, $1F, $0E
LAC20:  .byte $1D, $0E, $1D, $0E, $1D, $0E, $1D, $0E, $1C, $0E, $1C, $0E, $1C, $0E, $1A, $0E
LAC30:  .byte $1C, $0E, $1C, $07, $1D, $07, $1F, $0E, $1D, $0E, $1D, $0E, $1D, $0E, $1F, $2A
LAC40:  .byte $1C, $2A, $18, $07, $1A, $07, $1C, $0E, $1C, $0E, $1A, $07, $1C, $07, $1D, $0E
LAC50:  .byte $1A, $07, $1D, $07, $1F, $0E, $FF, $00, $00, $FF, $FB, $0F, $FD, $00, $0A, $40
LAC60:  .byte $FC, $28, $05, $1C, $11, $1C, $05, $0E, $05, $0E, $11, $0E, $05, $1C, $05, $0E
LAC70:  .byte $11, $1C, $05, $0E, $05, $0E, $11, $1C, $0E, $1C, $0E, $1C, $0E, $0E, $0E, $0E
LAC80:  .byte $0E, $0E, $0E, $1C, $0E, $0E, $0E, $1C, $0E, $0E, $0E, $0E, $0E, $1C, $0A, $1C
LAC90:  .byte $0A, $1C, $0A, $0E, $0A, $0E, $0A, $0E, $0A, $1C, $0A, $0E, $0A, $1C, $0A, $0E
LACA0:  .byte $0A, $0E, $0A, $1C, $0C, $1C, $0C, $1C, $0C, $0E, $0C, $0E, $0C, $0E, $0C, $1C
LACB0:  .byte $0C, $0E, $0C, $1C, $0C, $0E, $0C, $0E, $0C, $07, $0C, $07, $0C, $07, $0C, $07
LACC0:  .byte $05, $1C, $11, $1C, $05, $0E, $05, $0E, $11, $0E, $05, $1C, $05, $0E, $11, $1C
LACD0:  .byte $05, $0E, $05, $0E, $11, $1C, $0E, $1C, $0E, $1C, $0E, $0E, $0E, $0E, $0E, $0E
LACE0:  .byte $0E, $1C, $0E, $0E, $0E, $1C, $0E, $0E, $0E, $0E, $0E, $1C, $0A, $1C, $0A, $1C
LACF0:  .byte $0A, $0E, $0A, $0E, $0A, $0E, $0A, $1C, $0A, $0E, $0A, $1C, $0A, $0E, $0A, $0E
LAD00:  .byte $0A, $1C, $0C, $1C, $0C, $1C, $0C, $0E, $0C, $0E, $0C, $0E, $0C, $1C, $0C, $0E
LAD10:  .byte $0C, $1C, $0C, $0E, $0C, $0E, $0C, $07, $0C, $07, $0C, $07, $0C, $07, $FF, $00
LAD20:  .byte $3C, $FF, $08, $88, $8C, $90, $8E, $8C, $8A, $88, $87, $08, $88, $88, $88, $88
LAD30:  .byte $88, $88, $88, $88, $17, $88, $87, $87, $87, $86, $86, $86, $86, $86, $85, $85
LAD40:  .byte $85, $85, $85, $85, $84, $84, $84, $84, $84, $84, $84, $83, $04, $86, $89, $8C
LAD50:  .byte $90, $04, $90, $8E, $90, $8E, $0C, $8D, $89, $87, $86, $86, $85, $85, $84, $84
LAD60:  .byte $83, $83, $82, $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $20, $0F, $0F, $0F
LAD70:  .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
LAD80:  .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $04, $00, $00
LAD90:  .byte $00, $00, $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $10, $0F, $0F, $0F, $0F
LADA0:  .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $00, $00, $00, $00, $06, $00, $00, $00
LADB0:  .byte $00, $00, $00, $FB, $0A, $FD, $00, $0F, $10, $FC, $2E, $24, $28, $24, $14, $24
LADC0:  .byte $14, $24, $14, $26, $14, $24, $14, $22, $14, $26, $28, $22, $14, $22, $64, $24
LADD0:  .byte $28, $24, $14, $24, $14, $24, $14, $26, $14, $24, $14, $22, $0A, $24, $0A, $26
LADE0:  .byte $78, $22, $14, $24, $14, $26, $14, $26, $14, $26, $14, $24, $0A, $26, $28, $29
LADF0:  .byte $14, $27, $0A, $26, $0A, $24, $0A, $26, $14, $26, $14, $26, $14, $24, $0A, $26
LAE00:  .byte $28, $29, $14, $27, $0A, $26, $0A, $24, $0A, $26, $64, $22, $28, $1F, $14, $22
LAE10:  .byte $1E, $24, $82, $24, $28, $24, $14, $24, $14, $24, $14, $26, $14, $24, $14, $22
LAE20:  .byte $14, $26, $28, $22, $14, $22, $64, $24, $28, $24, $14, $24, $14, $24, $14, $26
LAE30:  .byte $14, $24, $14, $22, $0A, $24, $0A, $26, $78, $22, $14, $24, $14, $26, $14, $26
LAE40:  .byte $14, $26, $14, $24, $0A, $26, $28, $29, $14, $27, $0A, $26, $0A, $24, $0A, $26
LAE50:  .byte $14, $26, $14, $26, $14, $24, $0A, $26, $28, $29, $14, $27, $0A, $26, $0A, $24
LAE60:  .byte $0A, $26, $64, $22, $28, $1F, $14, $22, $1E, $24, $82, $FB, $0C, $2B, $50, $2B
LAE70:  .byte $14, $29, $14, $29, $14, $22, $14, $24, $14, $26, $14, $27, $14, $26, $64, $2B
LAE80:  .byte $50, $2B, $14, $29, $14, $29, $14, $22, $14, $24, $78, $2D, $14, $2E, $14, $FB
LAE90:  .byte $0E, $2D, $14, $2B, $3C, $29, $3C, $26, $0A, $24, $0A, $26, $50, $FE, $14, $2D
LAEA0:  .byte $28, $2E, $14, $2D, $14, $2B, $64, $2D, $14, $2E, $14, $2B, $14, $29, $8C, $FF
LAEB0:  .byte $00, $04, $FF, $FB, $08, $FD, $00, $00, $80, $FC, $2F, $FE, $14, $2B, $0A, $22
LAEC0:  .byte $0A, $27, $0A, $2B, $0A, $27, $0A, $22, $0A, $FE, $14, $2A, $0A, $22, $0A, $27
LAED0:  .byte $0A, $2A, $0A, $27, $0A, $22, $0A, $FE, $14, $29, $0A, $22, $0A, $26, $0A, $29
LAEE0:  .byte $0A, $26, $0A, $22, $0A, $FE, $14, $29, $0A, $22, $0A, $26, $0A, $29, $0A, $26
LAEF0:  .byte $0A, $22, $0A, $FE, $14, $2B, $0A, $22, $0A, $27, $0A, $2B, $0A, $27, $0A, $22
LAF00:  .byte $0A, $FE, $14, $2A, $0A, $22, $0A, $27, $0A, $2A, $0A, $27, $0A, $22, $0A, $FE
LAF10:  .byte $14, $29, $0A, $22, $0A, $26, $0A, $29, $0A, $26, $0A, $22, $0A, $FE, $14, $29
LAF20:  .byte $0A, $22, $0A, $26, $0A, $29, $0A, $26, $0A, $22, $0A, $FE, $14, $22, $0A, $1F
LAF30:  .byte $0A, $26, $0A, $22, $0A, $1F, $0A, $1B, $0A, $FE, $14, $22, $0A, $1D, $0A, $26
LAF40:  .byte $0A, $22, $0A, $1D, $0A, $1A, $0A, $FE, $14, $22, $0A, $1F, $0A, $26, $0A, $22
LAF50:  .byte $0A, $1F, $0A, $1B, $0A, $FE, $14, $22, $0A, $1D, $0A, $26, $0A, $22, $0A, $1D
LAF60:  .byte $0A, $1A, $0A, $FE, $14, $22, $0A, $1F, $0A, $26, $0A, $22, $0A, $1F, $0A, $1B
LAF70:  .byte $0A, $FE, $14, $22, $0A, $1F, $0A, $26, $0A, $22, $0A, $1F, $0A, $1B, $0A, $FE
LAF80:  .byte $14, $24, $0A, $22, $0A, $24, $0A, $22, $0A, $29, $0A, $24, $0A, $FE, $14, $24
LAF90:  .byte $0A, $22, $0A, $24, $0A, $21, $0A, $29, $0A, $24, $0A, $FE, $14, $2B, $0A, $22
LAFA0:  .byte $0A, $27, $0A, $2B, $0A, $27, $0A, $22, $0A, $FE, $14, $2A, $0A, $22, $0A, $27
LAFB0:  .byte $0A, $2A, $0A, $27, $0A, $22, $0A, $FE, $14, $29, $0A, $22, $0A, $26, $0A, $29
LAFC0:  .byte $0A, $26, $0A, $22, $0A, $FE, $14, $29, $0A, $22, $0A, $26, $0A, $29, $0A, $26
LAFD0:  .byte $0A, $22, $0A, $FE, $14, $2B, $0A, $22, $0A, $27, $0A, $2B, $0A, $27, $0A, $22
LAFE0:  .byte $0A, $FE, $14, $2A, $0A, $22, $0A, $27, $0A, $2A, $0A, $27, $0A, $22, $0A, $FE
LAFF0:  .byte $14, $29, $0A, $22, $0A, $26, $0A, $29, $0A, $26, $0A, $22, $0A, $FE, $14, $29
LB000:  .byte $0A, $22, $0A, $26, $0A, $29, $0A, $26, $0A, $22, $0A, $FE, $14, $22, $0A, $1F
LB010:  .byte $0A, $26, $0A, $22, $0A, $1F, $0A, $1B, $0A, $FE, $14, $22, $0A, $1D, $0A, $26
LB020:  .byte $0A, $22, $0A, $1D, $0A, $1A, $0A, $FE, $14, $22, $0A, $1F, $0A, $26, $0A, $22
LB030:  .byte $0A, $1F, $0A, $1B, $0A, $FE, $14, $22, $0A, $1D, $0A, $26, $0A, $22, $0A, $1D
LB040:  .byte $0A, $1A, $0A, $FE, $14, $22, $0A, $1F, $0A, $26, $0A, $22, $0A, $1F, $0A, $1B
LB050:  .byte $0A, $FE, $14, $22, $0A, $1F, $0A, $26, $0A, $22, $0A, $1F, $0A, $1B, $0A, $FE
LB060:  .byte $14, $24, $0A, $22, $0A, $24, $0A, $22, $0A, $29, $0A, $24, $0A, $FE, $14, $24
LB070:  .byte $0A, $22, $0A, $24, $0A, $21, $0A, $29, $0A, $24, $0A, $1F, $50, $1F, $14, $1D
LB080:  .byte $14, $1D, $14, $16, $14, $18, $14, $1A, $14, $1B, $14, $1A, $64, $1F, $50, $1F
LB090:  .byte $14, $1D, $14, $1D, $14, $16, $14, $18, $78, $21, $14, $22, $14, $26, $0A, $22
LB0A0:  .byte $0A, $1F, $0A, $22, $0A, $26, $0A, $22, $0A, $1F, $0A, $22, $0A, $29, $0A, $24
LB0B0:  .byte $0A, $21, $0A, $29, $0A, $29, $0A, $24, $0A, $21, $0A, $29, $0A, $29, $0A, $22
LB0C0:  .byte $0A, $26, $0A, $22, $0A, $29, $0A, $22, $0A, $26, $0A, $22, $0A, $29, $0A, $22
LB0D0:  .byte $0A, $26, $0A, $22, $0A, $29, $0A, $22, $0A, $26, $0A, $22, $0A, $2B, $0A, $22
LB0E0:  .byte $0A, $27, $0A, $22, $0A, $2B, $0A, $22, $0A, $27, $0A, $22, $0A, $2B, $0A, $22
LB0F0:  .byte $0A, $27, $0A, $22, $0A, $2B, $0A, $22, $0A, $27, $0A, $22, $0A, $2D, $0A, $24
LB100:  .byte $0A, $29, $0A, $24, $0A, $2D, $0A, $24, $0A, $29, $0A, $24, $0A, $2D, $0A, $24
LB110:  .byte $0A, $29, $0A, $24, $0A, $2D, $0A, $24, $0A, $29, $0A, $24, $0A, $FF, $00, $96
LB120:  .byte $FD, $FB, $0F, $FD, $00, $00, $80, $FC, $30, $0A, $3C, $0A, $14, $0A, $50, $0A
LB130:  .byte $3C, $0A, $14, $0A, $50, $0A, $3C, $0A, $14, $0A, $50, $0A, $3C, $0A, $14, $0A
LB140:  .byte $50, $0F, $3C, $0F, $14, $0E, $3C, $0E, $14, $0C, $3C, $0C, $14, $0E, $3C, $0E
LB150:  .byte $14, $0F, $3C, $0F, $14, $0F, $3C, $0F, $14, $11, $3C, $11, $14, $11, $3C, $11
LB160:  .byte $14, $0A, $3C, $0A, $14, $0A, $50, $0A, $3C, $0A, $14, $0A, $50, $0A, $3C, $0A
LB170:  .byte $14, $0A, $50, $0A, $3C, $0A, $14, $0A, $50, $0F, $3C, $0F, $14, $0E, $3C, $0E
LB180:  .byte $14, $0C, $3C, $0C, $14, $0E, $3C, $0E, $14, $0F, $3C, $0F, $14, $0F, $3C, $0F
LB190:  .byte $14, $11, $3C, $11, $14, $11, $3C, $11, $14, $FC, $31, $0F, $14, $0F, $14, $0F
LB1A0:  .byte $14, $0F, $14, $0C, $14, $0C, $14, $0C, $14, $0C, $14, $05, $14, $05, $14, $05
LB1B0:  .byte $14, $05, $14, $0A, $14, $0A, $14, $0A, $14, $0A, $14, $0F, $14, $0F, $14, $0F
LB1C0:  .byte $14, $0F, $14, $0E, $14, $0E, $14, $0E, $14, $0E, $14, $0C, $14, $0C, $14, $0C
LB1D0:  .byte $14, $0C, $14, $05, $14, $05, $14, $05, $14, $05, $14, $07, $14, $07, $14, $07
LB1E0:  .byte $0A, $07, $0A, $07, $0A, $07, $0A, $09, $14, $09, $14, $09, $0A, $09, $0A, $09
LB1F0:  .byte $0A, $09, $0A, $0A, $14, $0A, $14, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0E
LB200:  .byte $14, $0E, $14, $0E, $0A, $0E, $0A, $0E, $0A, $0E, $0A, $0F, $14, $0F, $14, $0F
LB210:  .byte $0A, $0F, $0A, $0F, $0A, $0F, $0A, $0F, $14, $0F, $14, $0F, $0A, $0F, $0A, $0F
LB220:  .byte $0A, $0F, $0A, $05, $14, $05, $14, $05, $0A, $05, $0A, $05, $0A, $05, $0A, $05
LB230:  .byte $14, $05, $14, $05, $0A, $05, $0A, $05, $0A, $05, $0A, $FF, $00, $E6, $FE, $05
LB240:  .byte $88, $8C, $90, $8E, $8B, $03, $87, $88, $88, $08, $87, $86, $86, $85, $85, $84
LB250:  .byte $84, $83, $83, $04, $8C, $90, $8D, $88, $08, $87, $88, $88, $88, $88, $88, $88
LB260:  .byte $88, $1D, $87, $87, $87, $87, $86, $86, $86, $86, $86, $86, $85, $85, $85, $85
LB270:  .byte $85, $85, $85, $85, $84, $84, $84, $84, $84, $84, $84, $84, $84, $84, $83, $83
LB280:  .byte $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $10, $0F, $0F, $0F, $0F, $00, $00
LB290:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $08, $00, $00, $00, $00, $00
LB2A0:  .byte $00, $00, $00, $00, $06, $86, $8D, $90, $8D, $8A, $86, $04, $87, $87, $87, $87
LB2B0:  .byte $18, $86, $86, $86, $86, $85, $85, $85, $85, $84, $84, $84, $84, $83, $83, $83
LB2C0:  .byte $83, $82, $82, $82, $82, $81, $81, $81, $80, $80, $04, $8A, $8E, $90, $8E, $8B
LB2D0:  .byte $03, $87, $88, $88, $08, $87, $86, $86, $85, $85, $84, $84, $83, $83, $FB, $0E
LB2E0:  .byte $FD, $00, $0A, $20, $FC, $29, $26, $0E, $28, $07, $29, $07, $28, $0E, $26, $0E
LB2F0:  .byte $26, $0E, $28, $07, $29, $07, $28, $0E, $26, $0E, $26, $0E, $28, $07, $29, $07
LB300:  .byte $2B, $0E, $29, $07, $28, $07, $29, $0E, $28, $07, $26, $07, $28, $0E, $26, $07
LB310:  .byte $24, $07, $24, $0E, $26, $07, $28, $07, $26, $0E, $24, $0E, $24, $0E, $26, $07
LB320:  .byte $28, $07, $26, $0E, $24, $0E, $24, $0E, $26, $07, $28, $07, $29, $0E, $28, $07
LB330:  .byte $26, $07, $28, $0E, $26, $07, $24, $07, $26, $0E, $24, $07, $22, $07, $22, $0E
LB340:  .byte $24, $07, $26, $07, $24, $0E, $22, $0E, $22, $0E, $24, $07, $26, $07, $24, $0E
LB350:  .byte $22, $0E, $22, $0E, $24, $07, $26, $07, $28, $0E, $26, $07, $24, $07, $26, $0E
LB360:  .byte $24, $07, $22, $07, $24, $0E, $22, $07, $21, $07, $21, $07, $22, $07, $24, $07
LB370:  .byte $25, $07, $24, $0E, $22, $0E, $21, $07, $22, $07, $24, $07, $25, $07, $24, $0E
LB380:  .byte $22, $0E, $21, $07, $22, $07, $24, $07, $25, $07, $24, $0E, $22, $0E, $21, $07
LB390:  .byte $22, $07, $24, $07, $25, $07, $24, $0E, $22, $0E, $FB, $0A, $FC, $2D, $2C, $0E
LB3A0:  .byte $2D, $0E, $2A, $0E, $2C, $0E, $2D, $07, $2C, $07, $2D, $07, $2C, $07, $2A, $0E
LB3B0:  .byte $2D, $0E, $2C, $0E, $2D, $0E, $2A, $0E, $2C, $0E, $2D, $07, $2C, $07, $2D, $07
LB3C0:  .byte $2C, $07, $2A, $0E, $2D, $0E, $2C, $0E, $2D, $0E, $2A, $0E, $2C, $0E, $2D, $07
LB3D0:  .byte $2C, $07, $2D, $07, $2C, $07, $2A, $0E, $2D, $0E, $2C, $0E, $2D, $0E, $2A, $0E
LB3E0:  .byte $2C, $0E, $2D, $07, $2C, $07, $2D, $07, $2C, $07, $2A, $0E, $2D, $0E, $2A, $0E
LB3F0:  .byte $2C, $0E, $28, $0E, $2A, $0E, $2C, $07, $2A, $07, $2C, $07, $2A, $07, $28, $0E
LB400:  .byte $2C, $0E, $2A, $0E, $2C, $0E, $28, $0E, $2A, $0E, $2C, $07, $2A, $07, $2C, $07
LB410:  .byte $2A, $07, $28, $0E, $2C, $0E, $2A, $0E, $2C, $0E, $28, $0E, $2A, $0E, $2C, $07
LB420:  .byte $2A, $07, $2C, $07, $2A, $07, $28, $0E, $2C, $0E, $2A, $0E, $2C, $0E, $28, $0E
LB430:  .byte $2A, $0E, $2C, $07, $2A, $07, $2C, $07, $2A, $07, $28, $0E, $2C, $0E, $2C, $0E
LB440:  .byte $2D, $0E, $2A, $0E, $2C, $0E, $2D, $07, $2C, $07, $2D, $07, $2C, $07, $2A, $0E
LB450:  .byte $2D, $0E, $2C, $0E, $2D, $0E, $2A, $0E, $2C, $0E, $2D, $07, $2C, $07, $2D, $07
LB460:  .byte $2C, $07, $2A, $0E, $2D, $0E, $2C, $0E, $2D, $0E, $2A, $0E, $2C, $0E, $2D, $07
LB470:  .byte $2C, $07, $2D, $07, $2C, $07, $2A, $0E, $2D, $0E, $2C, $0E, $2D, $0E, $2A, $0E
LB480:  .byte $2C, $0E, $2D, $07, $2C, $07, $2D, $07, $2C, $07, $2A, $0E, $2D, $0E, $2A, $0E
LB490:  .byte $2C, $0E, $28, $0E, $2A, $0E, $2C, $07, $2A, $07, $2C, $07, $2A, $07, $28, $0E
LB4A0:  .byte $2C, $0E, $2A, $0E, $2C, $0E, $28, $0E, $2A, $0E, $2C, $07, $2A, $07, $2C, $07
LB4B0:  .byte $2A, $07, $28, $0E, $2C, $0E, $2A, $0E, $2C, $0E, $28, $0E, $2A, $0E, $2C, $07
LB4C0:  .byte $2A, $07, $2C, $07, $2A, $07, $28, $0E, $2C, $0E, $2A, $0E, $2C, $0E, $28, $0E
LB4D0:  .byte $2A, $0E, $2C, $07, $2A, $07, $2C, $07, $2A, $07, $28, $0E, $2C, $0E, $FF, $00
LB4E0:  .byte $00, $FE, $FB, $0C, $FD, $00, $00, $00, $FC, $2A, $21, $0E, $1D, $0E, $1F, $0E
LB4F0:  .byte $1D, $0E, $21, $0E, $1F, $07, $1D, $07, $1A, $07, $1C, $07, $1D, $0E, $21, $0E
LB500:  .byte $1D, $0E, $1F, $0E, $1D, $0E, $21, $0E, $1F, $07, $1D, $07, $1A, $07, $1C, $07
LB510:  .byte $1D, $0E, $1F, $0E, $1C, $0E, $1D, $0E, $1C, $0E, $1F, $0E, $1D, $07, $1C, $07
LB520:  .byte $18, $07, $1A, $07, $1C, $0E, $1F, $0E, $1C, $0E, $1D, $0E, $1C, $0E, $1F, $0E
LB530:  .byte $1D, $07, $1C, $07, $18, $07, $1A, $07, $1C, $0E, $1D, $0E, $1A, $0E, $1C, $0E
LB540:  .byte $1A, $0E, $1D, $0E, $1C, $07, $1A, $07, $16, $07, $18, $07, $1A, $0E, $1D, $0E
LB550:  .byte $1A, $0E, $1C, $0E, $1A, $0E, $1D, $0E, $1C, $07, $1A, $07, $16, $07, $18, $07
LB560:  .byte $1A, $0E, $1C, $07, $1F, $07, $21, $07, $22, $07, $21, $0E, $1F, $0E, $1C, $07
LB570:  .byte $1F, $07, $21, $07, $22, $07, $21, $0E, $1F, $0E, $1C, $07, $1F, $07, $21, $07
LB580:  .byte $22, $07, $21, $0E, $1F, $0E, $1C, $07, $1F, $07, $21, $07, $22, $07, $21, $0E
LB590:  .byte $1F, $0E, $FB, $0A, $FC, $2C, $20, $0E, $21, $0E, $1E, $0E, $20, $0E, $21, $07
LB5A0:  .byte $20, $07, $21, $07, $20, $07, $1E, $0E, $21, $0E, $20, $0E, $21, $0E, $1E, $0E
LB5B0:  .byte $20, $0E, $21, $07, $20, $07, $21, $07, $20, $07, $1E, $0E, $21, $0E, $20, $0E
LB5C0:  .byte $21, $0E, $1E, $0E, $20, $0E, $21, $07, $20, $07, $21, $07, $20, $07, $1E, $0E
LB5D0:  .byte $21, $0E, $20, $0E, $21, $0E, $1E, $0E, $20, $0E, $21, $07, $20, $07, $21, $07
LB5E0:  .byte $20, $07, $1E, $0E, $21, $0E, $1E, $0E, $20, $0E, $1C, $0E, $1E, $0E, $20, $07
LB5F0:  .byte $1E, $07, $20, $07, $1E, $07, $1C, $0E, $20, $0E, $1E, $0E, $20, $0E, $1C, $0E
LB600:  .byte $1E, $0E, $20, $07, $1E, $07, $20, $07, $1E, $07, $1C, $0E, $20, $0E, $1E, $0E
LB610:  .byte $20, $0E, $1C, $0E, $1E, $0E, $20, $07, $1E, $07, $20, $07, $1E, $07, $1C, $0E
LB620:  .byte $20, $0E, $1E, $0E, $20, $0E, $1C, $0E, $1E, $0E, $20, $07, $1E, $07, $20, $07
LB630:  .byte $1E, $07, $1C, $0E, $20, $0E, $20, $0E, $21, $0E, $1E, $0E, $20, $0E, $21, $07
LB640:  .byte $20, $07, $21, $07, $20, $07, $1E, $0E, $21, $0E, $20, $0E, $21, $0E, $1E, $0E
LB650:  .byte $20, $0E, $21, $07, $20, $07, $21, $07, $20, $07, $1E, $0E, $21, $0E, $20, $0E
LB660:  .byte $21, $0E, $1E, $0E, $20, $0E, $21, $07, $20, $07, $21, $07, $20, $07, $1E, $0E
LB670:  .byte $21, $0E, $20, $0E, $21, $0E, $1E, $0E, $20, $0E, $21, $07, $20, $07, $21, $07
LB680:  .byte $20, $07, $1E, $0E, $21, $0E, $1E, $0E, $20, $0E, $1C, $0E, $1E, $0E, $20, $07
LB690:  .byte $1E, $07, $20, $07, $1E, $07, $1C, $0E, $20, $0E, $1E, $0E, $20, $0E, $1C, $0E
LB6A0:  .byte $1E, $0E, $20, $07, $1E, $07, $20, $07, $1E, $07, $1C, $0E, $20, $0E, $1E, $0E
LB6B0:  .byte $20, $0E, $1C, $0E, $1E, $0E, $20, $07, $1E, $07, $20, $07, $1E, $07, $1C, $0E
LB6C0:  .byte $20, $0E, $1E, $0E, $20, $0E, $1C, $0E, $1E, $0E, $20, $07, $1E, $07, $20, $07
LB6D0:  .byte $1E, $07, $1C, $0E, $20, $0E, $FF, $00, $0C, $FE

LB6DA:  .byte $FB, $0F, $FD, $00, $0A, $25
LB6E0:  .byte $FC, $2B, $0E, $0E, $0C, $0E, $0C, $0E, $0E, $0E, $FE, $38, $0E, $0E, $0C, $0E
LB6F0:  .byte $0C, $0E, $0E, $0E, $FE, $38, $0C, $0E, $0A, $0E, $0A, $0E, $0C, $0E, $FE, $38
LB700:  .byte $0C, $0E, $0A, $0E, $0A, $0E, $0C, $0E, $FE, $38, $0A, $0E, $09, $0E, $09, $0E
LB710:  .byte $0A, $0E, $FE, $38, $0A, $0E, $09, $0E, $09, $0E, $0A, $0E, $FE, $38, $09, $0E
LB720:  .byte $15, $0E, $13, $0E, $15, $0E, $09, $0E, $15, $0E, $13, $0E, $15, $0E, $13, $0E
LB730:  .byte $13, $0E, $13, $0E, $10, $0E, $10, $0E, $10, $0E, $0D, $0E, $0A, $0E, $06, $1C
LB740:  .byte $12, $1C, $06, $1C, $12, $1C, $FE, $0E, $10, $0E, $0F, $0E, $0D, $0E, $12, $07
LB750:  .byte $10, $07, $0F, $07, $0D, $07, $FE, $07, $09, $07, $08, $07, $04, $07, $06, $1C
LB760:  .byte $12, $1C, $06, $1C, $12, $1C, $FE, $0E, $10, $0E, $0F, $0E, $0D, $0E, $12, $07
LB770:  .byte $10, $07, $0F, $07, $0D, $07, $FE, $07, $09, $07, $08, $07, $04, $07, $04, $1C
LB780:  .byte $10, $1C, $04, $1C, $10, $1C, $FE, $0E, $0E, $0E, $0D, $0E, $0B, $0E, $10, $07
LB790:  .byte $0E, $07, $0D, $07, $0B, $07, $FE, $07, $08, $07, $06, $07, $02, $07, $04, $1C
LB7A0:  .byte $10, $1C, $04, $1C, $10, $1C, $FE, $0E, $0E, $0E, $0D, $0E, $0B, $0E, $10, $07
LB7B0:  .byte $0E, $07, $0D, $07, $0B, $07, $FE, $07, $08, $07, $06, $07, $02, $07, $06, $1C
LB7C0:  .byte $12, $1C, $06, $1C, $12, $1C, $FE, $0E, $10, $0E, $0F, $0E, $0D, $0E, $12, $07
LB7D0:  .byte $10, $07, $0F, $07, $0D, $07, $FE, $07, $09, $07, $08, $07, $04, $07, $06, $1C
LB7E0:  .byte $12, $1C, $06, $1C, $12, $1C, $FE, $0E, $10, $0E, $0F, $0E, $0D, $0E, $12, $07
LB7F0:  .byte $10, $07, $0F, $07, $0D, $07, $FE, $07, $09, $07, $08, $07, $04, $07, $04, $1C

;----------------------------------------------------------------------------------------------------

;Mounted horse sprites.

;Facing front, variant 1(same as facing left).
LB800:  .byte $00, $00, $10, $30, $F8, $5C, $1F, $0F, $00, $00, $00, $08, $04, $03, $0E, $00
LB810:  .byte $0F, $1F, $1E, $34, $2C, $48, $08, $00, $00, $00, $01, $00, $00, $00, $C0, $18
LB820:  .byte $00, $00, $00, $00, $00, $00, $81, $03, $30, $30, $10, $38, $F8, $38, $78, $F0
LB830:  .byte $3C, $3C, $7C, $7C, $2E, $16, $14, $00, $C0, $C0, $80, $00, $00, $00, $00, $16

;Facing front, variant 2(same as facing left).
LB840:  .byte $00, $00, $00, $20, $20, $70, $FE, $4F, $00, $00, $00, $00, $10, $0C, $03, $0C
LB850:  .byte $07, $0F, $1F, $26, $14, $0C, $0E, $00, $00, $00, $00, $00, $00, $00, $00, $0E
LB860:  .byte $00, $00, $00, $00, $00, $00, $00, $80, $00, $C0, $C0, $30, $78, $B8, $38, $70
LB870:  .byte $3E, $3D, $9D, $18, $1C, $1C, $68, $00, $C0, $C0, $60, $20, $00, $00, $00, $D8

;Facing back, variant 1(same as facing right).
LB880:  .byte $00, $00, $00, $00, $00, $00, $81, $C0, $0C, $0C, $08, $1C, $1F, $1C, $1E, $0F
LB890:  .byte $3C, $3C, $3E, $3E, $74, $68, $28, $00, $03, $03, $01, $00, $00, $00, $00, $68
LB8A0:  .byte $00, $00, $08, $0C, $1F, $3A, $F8, $F0, $00, $00, $00, $10, $20, $C0, $70, $00
LB8B0:  .byte $F0, $F8, $78, $2C, $34, $12, $10, $00, $00, $00, $80, $00, $00, $00, $03, $18

;Facing back, variant 2(same as facing right).
LB8C0:  .byte $00, $00, $00, $00, $00, $00, $00, $01, $00, $03, $03, $0C, $1E, $1D, $1C, $0E
LB8D0:  .byte $7C, $BC, $B9, $18, $38, $38, $16, $00, $03, $03, $06, $04, $00, $00, $00, $1B
LB8E0:  .byte $00, $00, $00, $04, $04, $0E, $7F, $F2, $00, $00, $00, $00, $08, $30, $C0, $30
LB8F0:  .byte $E0, $F0, $F8, $64, $28, $30, $70, $00, $00, $00, $00, $00, $00, $00, $00, $70

;Facing right, variant 1.
LB900:  .byte $00, $00, $00, $00, $00, $00, $81, $C0, $0C, $0C, $08, $1C, $1F, $1C, $1E, $0F
LB910:  .byte $3C, $3C, $3E, $3E, $74, $68, $28, $00, $03, $03, $01, $00, $00, $00, $00, $68
LB920:  .byte $00, $00, $08, $0C, $1F, $3A, $F8, $F0, $00, $00, $00, $10, $20, $C0, $70, $00
LB930:  .byte $F0, $F8, $78, $2C, $34, $12, $10, $00, $00, $00, $80, $00, $00, $00, $03, $18

;Facing right, variant 2.
LB940:  .byte $00, $00, $00, $00, $00, $00, $00, $01, $00, $03, $03, $0C, $1E, $1D, $1C, $0E
LB950:  .byte $7C, $BC, $B9, $18, $38, $38, $16, $00, $03, $03, $06, $04, $00, $00, $00, $1B
LB960:  .byte $00, $00, $00, $04, $04, $0E, $7F, $F2, $00, $00, $00, $00, $08, $30, $C0, $30
LB970:  .byte $E0, $F0, $F8, $64, $28, $30, $70, $00, $00, $00, $00, $00, $00, $00, $00, $70

;Facing left, variant 1.
LB980:  .byte $00, $00, $10, $30, $F8, $5C, $1F, $0F, $00, $00, $00, $08, $04, $03, $0E, $00
LB990:  .byte $0F, $1F, $1E, $34, $2C, $48, $08, $00, $00, $00, $01, $00, $00, $00, $C0, $18
LB9A0:  .byte $00, $00, $00, $00, $00, $00, $81, $03, $30, $30, $10, $38, $F8, $38, $78, $F0
LB9B0:  .byte $3C, $3C, $7C, $7C, $2E, $16, $14, $00, $C0, $C0, $80, $00, $00, $00, $00, $16

;Facing left, variant 2.
LB9C0:  .byte $00, $00, $00, $20, $20, $70, $FE, $4F, $00, $00, $00, $00, $10, $0C, $03, $0C
LB9D0:  .byte $07, $0F, $1F, $26, $14, $0C, $0E, $00, $00, $00, $00, $00, $00, $00, $00, $0E
LB9E0:  .byte $00, $00, $00, $00, $00, $00, $00, $80, $00, $C0, $C0, $30, $78, $B8, $38, $70
LB9F0:  .byte $3E, $3D, $9D, $18, $1C, $1C, $68, $00, $C0, $C0, $60, $20, $00, $00, $00, $D8

;----------------------------------------------------------------------------------------------------

;Unused.
LBA00:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBA10:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBA20:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBA30:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBA40:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBA50:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBA60:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBA70:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBA80:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBA90:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBAA0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBAB0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBAC0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBAD0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBAE0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBAF0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBB00:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBB10:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBB20:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBB30:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBB40:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBB50:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBB60:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBB70:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBB80:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBB90:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBBA0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBBB0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBBC0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBBD0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBBE0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBBF0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBC00:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBC10:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBC20:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBC30:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBC40:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBC50:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBC60:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBC70:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBC80:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBC90:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBCA0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBCB0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBCC0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBCD0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBCE0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBCF0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBD00:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBD10:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBD20:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBD30:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBD40:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBD50:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBD60:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBD70:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBD80:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBD90:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBDA0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBDB0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBDC0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBDD0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBDE0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBDF0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBE00:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBE10:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBE20:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBE30:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBE40:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBE50:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBE60:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBE70:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBE80:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBE90:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBEA0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBEB0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBEC0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBED0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBEE0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBEF0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBF00:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBF10:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBF20:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBF30:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBF40:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBF50:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBF60:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBF70:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBF80:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBF90:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

;----------------------------------------------------------------------------------------------------

_RESET:
LBFA0:  LDA #$00                ;Disable NMI.
LBFA2:  STA PPUControl0         ;

LBFA5:  LDX #$02                ;
LBFA7:* LDA PPUStatus           ;Wait for at least one full screen to be drawn before continuing.-->
LBFAA:  BPL -                   ;Writes to PPUControl register are ignored for 30,000 clock cycles-->
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
