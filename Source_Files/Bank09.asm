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
L8000:  CMP MusCurrent          ;Is a new song being requested?
L8003:  BNE +                   ;If so, branch.
L8005:  RTS                     ;Else exit.

L8006:* STA MusCurrent          ;Set the new music as the current music.

L8009:  SEC                     ;Subtract 10 from music being requested as the first 10
L800A:  SBC #MUS_INTRO          ;songs are located in Bank08.
L800C:  BCS +                   ;IF song is valid, branch to get music pointer data.

L800E:  LDA #$01                ;Invalid song. Silence music.

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
L8052:  .word ChrCreateSQ1, ChrCreateSQ2, ChrCreateTri, MusNone     ;Character creation music.
L8059:  .word MusNone,      MusNone,      MusNone,      MusNone     ;Silence music.
L8062:  .word ExodusHBSQ1,  ExodusHBSQ2,  ExodusHBTri,  ExodusHBNse ;Exodus heart beat music.
L8069:  .word SlvrHornSQ1,  SlvrHornSQ2,  MusNone,      MusNone     ;Silver horn music.

;The following entries in the table are not used.
L8072:  .word UnusedSQ1,    MusNone,      MusNone-3,    $A74B       ;Not used.
L8079:  .word $A803,        $A903,        MusNone-3,    $AA52       ;Not used.
L8082:  .word $AB56,        $AC5A,        MusNone-3,    $B2DE       ;Not used.
L8089:  .word $B4E2,        $B6DA,        MusNone-3,    $ADB3       ;Not used.
L8092:  .word $AEB3,        $B121,        MusNone-3,    MusNone-3   ;Not used.
L8099:  .word MusNone-3,    MusNone-3,    MusNone-3                 ;Not used.

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

L82DA:  JMP SilenceChannel      ;($8400)Silence the channel for a period of time.

L82DD:* CMP #CHN_CONTROL        ;Is this a control byte?
L82DF:  BCS GetCntrlByte        ;If so, branch to process the control byte.

L82E1:  CPX #TRI_DAT_OFFSET     ;Are we looking for SQ1 or SQ2 data?
L82E3:  BCC GetSQData           ;If so, brach to get SQ music data.

L82E5:  BEQ +                   ;Are we looking for triangle data? If so, branch.
L82E7:  JMP SilenceNseChnl      ;($851D)Must be noise channel. Not used in music jump to silence.

L82EA:*  JMP GetSQTriData       ;($8452)Get the triangle/SQ data.

GetSQData:
L82ED:  JMP GetSQTriData        ;($8452)Get the triangle/SQ data.

;----------------------------------------------------------------------------------------------------

GetCntrlByte:
L82F0:  CMP #CHN_JUMP           ;Does the pointer need to jump? If so, branch.
L82F2:  BEQ DoDataJump          ;($8312)Jump the data pointer to a new location.

L82F4:  CMP #CHN_ASR            ;Is this an ASR control byte?
L82F6:  BNE +                   ;If not, branch.
L82F8:  JMP UpdateASR           ;($8336)Update the ASR(attack, sustain, release) profile.

L82FB:* CMP #CHN_VIBRATO        ;Is this a vibrato control byte?
L82FD:  BNE +                   ;If not branch.
L82FF:  JMP UpdateVibratoData   ;($83A7)Update channel vibrato data.

L8302:* CMP #CHN_VOLUME         ;Is this a volume control byte?
L8304:  BNE NextChnByte         ;If not, branch. Invalid control byte.
L8306:  JMP UpdateVolume        ;($8393)Update the channel base volume.

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
L833E:  SEC                     ;
L833F:  SBC #$32                ;Subtract 50.
L8341:  ASL                     ;*2. The addresses in the table are 2 bytes each.
L8342:  TAY                     ;

L8343:  LDA AttackPtrTbl,Y      ;
L8346:  STA AttackDatPtrLB,X    ;
L8349:  STA GenPtrF4LB          ;Update the attack data pointer for the channel.
L834B:  LDA AttackPtrTbl+1,Y    ;
L834E:  STA AttackDatPtrUB,X    ;
L8351:  STA GenPtrF4UB          ;

L8353:  STY GenByteF8           ;Temporarily save the value of Y.

L8355:  LDY #$00                ;
L8357:  LDA (GenPtrF4),Y        ;Save the length of the attack data string.
L8359:  STA ChnAttackDatLen,X   ;

L835C:  LDY GenByteF8           ;Restore the value of Y.

L835E:  LDA SustainPtrTbl,Y     ;
L8361:  STA SustainDatPtrLB,X   ;
L8364:  STA GenPtrF4LB          ;Update the sustain data pointer for the channel.
L8366:  LDA SustainPtrTbl+1,Y   ;
L8369:  STA SustainDatPtrUB,X   ;
L836C:  STA GenPtrF4UB          ;

L836E:  STY GenByteF8           ;Temporarily save the value of Y.

L8370:  LDY #$00                ;
L8372:  LDA (GenPtrF4),Y        ;Save the length of the sustain data string.
L8374:  STA ChnSustainDatLen,X  ;

L8377:  LDY GenByteF8           ;Restore the value of Y.

L8379:  LDA ReleasePtrTbl,Y     ;
L837C:  STA ReleaseDatPtrLB,X   ;
L837F:  STA GenPtrF4LB          ;Update the release data pointer for the channel.
L8381:  LDA ReleasePtrTbl+1,Y   ;
L8384:  STA ReleaseDatPtrUB,X   ;
L8387:  STA GenPtrF4UB          ;

L8389:  LDY #$00                ;
L838B:  LDA (GenPtrF4),Y        ;Save the length of the release data string.
L838D:  STA ChnReleaseDatLen,X  ;

L8390:  JMP NextChnByte         ;($8309)Get next byte of channel music data.

;----------------------------------------------------------------------------------------------------

UpdateVolume:
L8393:  INC ChnDatPtrLB,X       ;
L8395:  BNE +                   ;Increment to next music data byte.
L8397:  INC ChnDatPtrUB,X       ;

L8399:* LDA (ChnDatPtr,X)       ;
L839B:  ASL                     ;
L839C:  ASL                     ;Move 4-bit volume data to upper byte.
L839D:  ASL                     ;
L839E:  ASL                     ;

L839F:  EOR #$FF                ;1s compliment the byte.
L83A1:  STA Volume1sComp_,X     ;
L83A4:  JMP NextChnByte         ;($8309)Get next byte of channel music data.

;----------------------------------------------------------------------------------------------------

UpdateVibratoData:
L83A7:  INC ChnDatPtrLB,X       ;
L83A9:  BNE +                   ;Increment to next music data byte.
L83AB:  INC ChnDatPtrUB,X       ;

L83AD:* LDA (ChnDatPtr,X)       ;Get unused data byte. Always 0.
L83AF:  STA ChnVibUnused,X      ;

L83B2:  INC ChnDatPtrLB,X       ;
L83B4:  BNE +                   ;Increment to next music data byte.
L83B6:  INC ChnDatPtrUB,X       ;

L83B8:* LDA (ChnDatPtr,X)       ;Get the vibrato speed control byte.
L83BA:  CMP #$02                ;Is speed control byte 2 or less?
L83BC:  BCS PrepVibratoCalc     ;If so, disable vibrato, else branch to calculate vibrato.

L83BE:  LDA #$00                ;
L83C0:  STA ChnVibSpeedLB,X     ;
L83C3:  STA ChnVibSpeedUB,X     ;Disable vibrato.
L83C6:  STA ChnVibCntLB,X       ;
L83C9:  LDA #$00                ;
L83CB:  STA ChnVibCntUB,X       ;

L83CE:  JMP GetVibratoData      ;($83F2)Get vibrato intensity byte.

PrepVibratoCalc:
L83D1:  STA DivisorF8           ;
L83D3:  LDA #$00                ;
L83D5:  STA DivLBF4             ;Divide #$0800 by the value in $F8.
L83D7:  LDA #$08                ;
L83D9:  STA DivUBF5             ;
L83DB:  JSR DoDiv               ;($857F)Integer divide a word by a byte.

L83DE:  LDA DivLBF4             ;
L83E0:  STA ChnVibSpeedLB,X     ;Set the vibrato speed control with results from previous division.
L83E3:  LDA DivUBF5             ;
L83E5:  STA ChnVibSpeedUB,X     ;

L83E8:  LDA #$00                ;
L83EA:  STA ChnVibCntLB,X       ;Reset the vibrato counter to #$0200.
L83ED:  LDA #$02                ;
L83EF:  STA ChnVibCntUB,X       ;

GetVibratoData:
L83F2:  INC ChnDatPtrLB,X       ;
L83F4:  BNE +                   ;Increment to next musical data byte.
L83F6:  INC ChnDatPtrUB,X       ;

L83F8:* LDA (ChnDatPtr,X)       ;Store the vibrato intensity byte.
L83FA:  STA ChnVibIntensity,X   ;
L83FD:  JMP NextChnByte         ;($8309)Get next byte of channel music data.

;----------------------------------------------------------------------------------------------------

SilenceChannel:
L8400:  INC ChnDatPtrLB,X       ;
L8402:  BNE +                   ;Increment channel data pointer.
L8404:  INC ChnDatPtrUB,X       ;

L8406:* LDA (ChnDatPtr,X)       ;
L8408:  STA ChnLenCounter,X     ;Set the time period in frames to silence the channel.
L840B:  STA ChnNoteLength,X     ;

L840E:  SEC                     ;
L840F:  SBC ChnAttackDatLen,X   ;Caclulate the time for the sustain phase to start.
L8412:  BCS +                   ;
L8414:  LDA #$00                ;

L8416:* STA ChnSustainTime,X    ;If the sustain time less than the release time?
L8419:  CMP ChnReleaseDatLen,X  ;If so, branch.
L841C:  BCC +                   ;

L841E:  LDA ChnReleaseDatLen,X  ;Set the release time.
L8421:* STA ChnReleaseTime,X    ;

L8424:  LDA SilenceChnTbl,X     ;
L8427:  STA ChnCtrl0,X          ;
L842A:  LDA SilenceChnTbl+1,X   ;
L842D:  STA ChnCtrl1,X          ;Load data from the table below to silence the selected channel.
L8430:  LDA SilenceChnTbl+2,X   ;
L8433:  STA ChnCtrl2,X          ;
L8436:  LDA SilenceChnTbl+3,X   ;
L8439:  STA ChnCtrl3,X          ;

L843C:  LDA #$FF                ;Set volume to 0.
L843E:  STA Volume1sComp,X      ;

L8441:  LDA SFXFinished,X       ;
L8444:  BNE +                   ;Set any playing SFX on this channel as just finished.
L8446:  LDA #$01                ;
L8448:  STA SFXFinished,X       ;

L844B:* INC ChnDatPtrLB,X       ;
L844D:  BNE +                   ;Increment to next musical data byte.
L844F:  INC ChnDatPtrUB,X       ;
L8451:*  RTS                    ;

;----------------------------------------------------------------------------------------------------

GetSQTriData:
L8452:  CPX #TRI_DAT_OFFSET     ;Are we getting triangle music data?
L8454:  BNE GetMusData          ;If not, branch.

L8456:  PHA                     ;
L8457:  LDA TriCompensate       ;Should triangle notes be on the same octive as the SQ notes?
L845A:  CMP #TRI_CHN_COMP       ;If so, look 12 entries ahead in the notes table as the
L845C:  PLA                     ;triangle notes play at half frequency as the SQ notes by
L845D:  BCS GetMusData          ;default. This is 1 octive lower. 
L845F:  ADC #$0C                ;

GetMusData:
L8461:  TAY                     ;
L8462:  LDA NoteTblLo,Y         ;
L8465:  STA DivLBF4             ;
L8467:  LDA NoteTblHi,Y         ;
L846A:  LSR                     ;Get the upper 8 bits of the note frequency
L846B:  ROR DivLBF4             ;and but it into $F4.
L846D:  LSR                     ;
L846E:  ROR DivLBF4             ;
L8470:  LSR                     ;
L8471:  ROR DivLBF4             ;

L8473:  LDA #$00                ;Zero out $F5 to use in a division algorithm.
L8475:  STA DivUBF5             ;

L8477:  LDA ChnVibIntensity,X   ;Prepare to add vibrato to note being played.
L847A:  STA DivisorF8           ;
L847C:  STY GenByteFD           ;Store the index value in Y.
L847E:  JSR DoDiv               ;($857F)Integer divide a word by a byte.

L8481:  LDY GenByteFD           ;Restore the index value to Y.

L8483:  LDA DivLBF4             ;Store the delta frequency for vibrato notes.
L8485:  STA ChnVibratoDF,X      ;

L8488:  LDA NoteTblHi,Y         ;Store the lower counter value. This is the base note frequency.
L848B:  STA ChnCtrl3,X          ;

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
L848E:  LDA NoteTblLo,Y         ;
L8491:  STX GenByteFD           ;Save the channel index. A multiple of 4.
L8493:  ASL GenByteFD           ;*2. 8 bytes per vibrato lookup table.
L8495:  LDY GenByteFD           ;

L8497:  STA ChnVibBase,Y        ;Spots 0 and 4 in the vibrato lookup table are the base frequency.
L849A:  STA ChnVibBase+4,Y      ;

L849D:  CLC                     ;Add the delta frequency to base frequency.
L849E:  ADC ChnVibratoDF,X      ;Creates higher frequency.
L84A1:  BCC +                   ;
L84A3:  LDA #$FF                ;Make sure value does not wrap around.

L84A5:* STA ChnVibBase+1,Y      ;Higher frequency stored in spots 1 and 3
L84A8:  STA ChnVibBase+3,Y      ;of the vibrato lookup table.

L84AB:  CLC                     ;Add the delta frequency to previous frequency.
L84AC:  ADC ChnVibratoDF,X      ;Creates peak frequency.
L84AF:  BCC +                   ;
L84B1:  LDA #$FF                ;Make sure value does not wrap around.

L84B3:* STA ChnVibBase+2,Y      ;Peak frequency stored in position 2 of vibrato lookup table.

L84B6:  SEC                     ;
L84B7:  LDA ChnVibBase,Y        ;Subtract the delta frequency from base frequency.
L84BA:  SBC ChnVibratoDF,X      ;Creates lower frequency.
L84BD:  BCS +                   ;
L84BF:  LDA #$FF                ;If wraps, set to max freq. Is this a bug? Should be 0?

L84C1:* STA ChnVibBase+5,Y      ;Lower frequency stored in spots 5 and 7
L84C4:  STA ChnVibBase+7,Y      ;of the vibrato lookup table.

L84C7:  SEC                     ;Subtract the delta frequency from previous frequency.
L84C8:  SBC ChnVibratoDF,X      ;Creates minimum frequency.
L84CB:  BCS +
L84CD:  LDA #$FF                ;If wraps, set to max freq. Is this a bug? Should be 0?

L84CF:* STA ChnVibBase+6,Y      ;Minimum frequency stored in position 6 of vibrato lookup table.

L84D2:  INC ChnDatPtrLB,X       ;
L84D4:  BNE +                   ;Increment to next musical data byte.
L84D6:  INC ChnDatPtrUB,X       ;

L84D8:* LDA (ChnDatPtr,X)       ;
L84DA:  STA ChnLenCounter,X     ;Set the duration of the new note to play.
L84DD:  STA ChnNoteLength,X     ;

L84E0:  SEC                     ;
L84E1:  SBC ChnAttackDatLen,X   ;
L84E4:  BCS +                   ;Calculate frame when sustain starts and save it.
L84E6:  LDA #$00                ;
L84E8:* STA ChnSustainTime,X    ;

L84EB:  SEC                     ;
L84EC:  SBC ChnReleaseDatLen,X  ;Calculate frame when sustain ends.
L84EF:  BCS +                   ;
L84F1:  LDA #$00                ;

L84F3:* CMP ChnSustainDatLen,X  ;Is the end time less than the sustain data length?
L84F6:  BCC +                   ;If so, branch.

L84F8:  LDA ChnSustainDatLen,X  ;Sustain time=sustain data length.

L84FB:* STA GenByteF4           ;Store frame when sustain ends.

L84FD:  LDA ChnSustainTime,X    ;
L8500:  SEC                     ;
L8501:  SBC GenByteF4           ;Caclulate frame when release starts and save it.
L8503:  STA ChnReleaseTime,X    ;

L8506:  INC ChnDatPtrLB,X       ;
L8508:  BNE +                   ;Increment to next musical data byte.
L850A:  INC ChnDatPtrUB,X       ;

L850C:* LDA Volume1sComp_,X     ;Transfer the 1s compliment of the volume to the working register.
L850F:  STA Volume1sComp,X      ;

L8512:  LDA SFXFinished,X       ;
L8515:  BNE +                   ;
L8517:  LDA #$01                ;Set any playing SFX on the noise channel as just finished.
L8519:  STA SFXFinished,X       ;
L851C:* RTS                     ;

;----------------------------------------------------------------------------------------------------

SilenceNseChnl:
L851D:  AND #$0F                ;
L851F:  STA NextNseCtrl2        ;
L8522:  LDA SilenceChnTbl+$C    ;
L8525:  STA NextNseCtrl0        ;Load the noise hardware registers with the data in the table below.
L8528:  LDA SilenceChnTbl+$D    ;
L852B:  STA NextNseCtrl1        ;
L852E:  LDA SilenceChnTbl+$F    ;
L8531:  STA NextNseCtrl3        ;

L8534:  INC NseDatPtrLB         ;
L8536:  BNE +                   ;Increment to the next noise data byte.
L8538:  INC NseDatPtrUB         ;

L853A:* LDA (ChnDatPtr,X)       ;
L853C:  STA NseLenCounter       ;Set the number of frames Noise channel is silent.
L853F:  STA NseNoteLength       ;

L8542:  SEC                     ;
L8543:  SBC NseAttackDatLen     ;
L8546:  BCS +                   ;Calculate frame when sustain starts and save it.
L8548:  LDA #$00                ;
L854A:* STA NseSustainTime      ;

L854D:  SEC                     ;
L854E:  SBC NseReleaseDatLen    ;Calculate frame when sustain ends.
L8551:  BCS +                   ;
L8553:  LDA #$00                ;

L8555:* CMP NseSustainDatLen    ;Is the end time less than the sustain data length?
L8558:  BCC +                   ;If so, branch.

L855A:  LDA NseSustainDatLen    ;Sustain time=sustain data length.

L855D:* STA GenByteF4           ;Store frame when sustain ends.

L855F:  LDA NseSustainTime      ;
L8562:  SEC                     ;
L8563:  SBC GenByteF4           ;Caclulate frame when release starts and save it.
L8565:  STA NseReleaseTime      ;

L8568:  INC ChnDatPtrLB,X       ;
L856A:  BNE +                   ;Increment to next musical data byte.
L856C:  INC ChnDatPtrUB,X       ;

L856E:* LDA SFXNseUnused7696    ;Not used.
L8571:  STA NseUnused762E       ;

L8574:  LDA SFXNseFinished      ;
L8577:  BNE +                   ;
L8579:  LDA #$01                ;Set any playing SFX on the noise channel as just finished.
L857B:  STA SFXNseFinished      ;
L857E:* RTS                     ;

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
L8593:  ROL                     ;This is a division algorithm. It divides the word in $F5,$F4
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
L8646:  .word SQ1Attack00, SQ2Attack01, TriAttack02, SQ1Attack03
L864D:  .word SQ2Attack04, SQ1Attack05, SQ2Attack06, SQ12Attack07
L8656:  .word TriAttack08, NseAttack09, SQ1Attack0A, SQ2Attack0B
L865D:  .word SQ1Attack0C

SustainPtrTbl:
L8660:  .word SQ1Sustain00, SQ2Sustain01, TriSustain02, SQ1Sustain03
L8668:  .word SQ2Sustain04, SQ1Sustain05, SQ2Sustain06, SQ12Sustain07
L8670:  .word TriSustain08, NseSustain09, SQ1Sustain0A, SQ2Sustain0B
L8678:  .word SQ1Sustain0C

ReleasePtrTbl:
L867A:  .word SQ1Release00, SQ2Release01, TriRelease02, SQ1Release03
L8682:  .word SQ2Release04, SQ1Release05, SQ2Release06, SQ12Release07
L868A:  .word TriRelease08, NseRelease09, SQ1Release0A, SQ2Release0B
L8692:  .word SQ1Release0C

;----------------------------------------------------------------------------------------------------

;Used by character creation music SQ1.

SQ1Attack00:
L8694:  .byte $03, $08, $4F, $4F

SQ1Sustain00:
L8698:  .byte $07, $4E, $4C, $4B, $4A, $49, $49, $49

SQ1Release00:
L86A0:  .byte $15, $48, $48, $48, $48, $47, $47, $47, $47, $46, $46, $46, $46, $45, $45, $45
L86B0:  .byte $45, $44, $44, $44, $44, $43, $43

;----------------------------------------------------------------------------------------------------

;Used by dungeon music SQ2.

SQ2Attack01:
L86B7:  .byte $02, $8C, $8F

SQ2Sustain01:
L86BA:  .byte $20, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B
L86CA:  .byte $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B, $8B
L86DA:  .byte $8B

SQ2Release01:
L86DB:  .byte $06, $89, $87, $85, $84, $82, $80, $80

;----------------------------------------------------------------------------------------------------

;Used by dungeon music triangle.

TriAttack02:
L86E3:  .byte $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

TriSustain02:
L86EC:  .byte $10, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $00, $00, $00, $00
L86FC:  .byte $00

TriRelease02:
L86FD:  .byte $08, $00, $00, $00, $00, $00, $00, $00, $00, $00

;----------------------------------------------------------------------------------------------------

;Used by character creation music SQ1.

SQ1Attack03:
L8707:  .byte $03, $08, $0F, $0F

SQ1Sustain03:
L870B:  .byte $07, $0E, $0C, $0B, $0A, $09, $09, $09

SQ1Release03:
L8713:  .byte $15, $08, $08, $08, $08, $07, $07, $07, $07, $06, $06, $06, $06, $05, $05, $05
L8723:  .byte $05, $04, $04, $04, $04, $03, $03

;----------------------------------------------------------------------------------------------------

;Used by character creation music SQ2.

SQ2Attack04:
L872A:  .byte $02, $CC, $CF

SQ2Sustain04:
L872D:  .byte $20, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB
L873D:  .byte $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB, $CB
L874D:  .byte $CB

SQ2Release04:
L874E:  .byte $07, $CA, $C9, $C7, $C5, $C4, $C2, $C0, $C0

;----------------------------------------------------------------------------------------------------

;Used by character creation music SQ1.

SQ1Attack05:
L8757:  .byte $07, $88, $8C, $8E, $90, $8F, $8E, $8D

SQ1Sustain05:
L875F:  .byte $01, $8D

SQ1Release05:
L8761:  .byte $1C, $8C, $86, $87, $89, $88, $88, $88, $87, $87, $87, $87, $86, $86, $86, $86
L8771:  .byte $86, $85, $85, $85, $85, $85, $84, $84, $84, $84, $84, $84, $83, $83

;----------------------------------------------------------------------------------------------------

;Used by character creation music SQ2.

SQ2Attack06:
L877F:  .byte $07, $48, $4C, $50, $4F, $4D, $49, $46

SQ2Sustain06:
L8787:  .byte $01, $48

SQ2Release06:
L8789:  .byte $0C, $48, $47, $46, $47, $46, $46, $45, $45, $44, $44, $44, $43, $43

;----------------------------------------------------------------------------------------------------

;Character creation music SQ1 data.

ChrCreateSQ1:
L8797:  .byte CHN_VOLUME, $0C            ;Set channel volume to 12.
L8799:  .byte CHN_VIBRATO, $00, $08, $0E ;Set vibrato speed=8, intensity=14.
L879D:  .byte CHN_ASR, $32               ;Set ASR data index to 00.
L879F:  .byte $15, $1B                   ;Play note A3  for 27 frames.
L87A1:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L87A3:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
L87A5:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L87A7:  .byte $14, $0E                   ;Play note G#3 for 14 frames.
L87A9:  .byte $15, $0D                   ;Play note A3  for 13 frames.
L87AB:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
L87AD:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L87AF:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
L87B1:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L87B3:  .byte $17, $0E                   ;Play note B3  for 14 frames.
L87B5:  .byte $15, $1B                   ;Play note A3  for 27 frames.
L87B7:  .byte $14, $1B                   ;Play note G#3 for 27 frames.
L87B9:  .byte $15, $1B                   ;Play note A3  for 27 frames.
L87BB:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L87BD:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
L87BF:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L87C1:  .byte $14, $0E                   ;Play note G#3 for 14 frames.
L87C3:  .byte $15, $0D                   ;Play note A3  for 13 frames.
L87C5:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
L87C7:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L87C9:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
L87CB:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L87CD:  .byte $17, $0E                   ;Play note B3  for 14 frames.
L87CF:  .byte $15, $1B                   ;Play note A3  for 27 frames.
L87D1:  .byte $14, $1B                   ;Play note G#3 for 27 frames.
L87D3:  .byte CHN_ASR, $35               ;Set ASR data index to 03.
L87D5:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L87D7:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L87D9:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L87DB:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L87DD:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L87DF:  .byte $2B, $0E                   ;Play note G5  for 14 frames.
L87E1:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L87E3:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L87E5:  .byte $2B, $0E                   ;Play note G5  for 14 frames.
L87E7:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L87E9:  .byte $2B, $0E                   ;Play note G5  for 14 frames.
L87EB:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L87ED:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L87EF:  .byte $2B, $1B                   ;Play note G5  for 27 frames.
L87F1:  .byte $2B, $1B                   ;Play note G5  for 27 frames.
L87F3:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L87F5:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L87F7:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L87F9:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L87FB:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L87FD:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L87FF:  .byte $2B, $0E                   ;Play note G5  for 14 frames.
L8801:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L8803:  .byte $2B, $0E                   ;Play note G5  for 14 frames.
L8805:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L8807:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L8809:  .byte CHN_VIBRATO, $00, $0C, $12 ;Set vibrato speed=12, intensity=18.
L880D:  .byte CHN_ASR, $37               ;Set ASR data index to 05.
L880F:  .byte CHN_VOLUME, $0C            ;Set channel volume to 12.
L8811:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8813:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8815:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L8817:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8819:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L881B:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L881D:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L881F:  .byte $2A, $1B                   ;Play note F#5 for 27 frames.
L8821:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L8823:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8825:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8827:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8829:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L882B:  .byte $2A, $1B                   ;Play note F#5 for 27 frames.
L882D:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L882F:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L8831:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L8833:  .byte $25, $0D                   ;Play note C#5 for 13 frames.
L8835:  .byte $23, $1B                   ;Play note B4  for 27 frames.
L8837:  .byte $21, $1B                   ;Play note A4  for 27 frames.
L8839:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L883B:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L883D:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L883F:  .byte $2A, $1B                   ;Play note F#5 for 27 frames.
L8841:  .byte $2A, $1B                   ;Play note F#5 for 27 frames.
L8843:  .byte $25, $1B                   ;Play note C#5 for 27 frames.
L8845:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L8847:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L8849:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L884B:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L884D:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L884F:  .byte $21, $0E                   ;Play note A4  for 14 frames.
L8851:  .byte $23, $14                   ;Play note B4  for 20 frames.
L8853:  .byte $25, $14                   ;Play note C#5 for 20 frames.
L8855:  .byte $25, $1B                   ;Play note C#5 for 27 frames.
L8857:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8859:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L885B:  .byte $20, $06                   ;Play note G#4 for 6 frames.
L885D:  .byte $23, $07                   ;Play note B4  for 7 frames.
L885F:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8861:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L8863:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8865:  .byte $20, $06                   ;Play note G#4 for 6 frames.
L8867:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8869:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L886B:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L886D:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L886F:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8871:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8873:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L8875:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8877:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L8879:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L887B:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L887D:  .byte $2A, $1B                   ;Play note F#5 for 27 frames.
L887F:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L8881:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8883:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8885:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8887:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8889:  .byte $2A, $1B                   ;Play note F#5 for 27 frames.
L888B:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L888D:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L888F:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L8891:  .byte $25, $0D                   ;Play note C#5 for 13 frames.
L8893:  .byte $23, $1B                   ;Play note B4  for 27 frames.
L8895:  .byte $21, $1B                   ;Play note A4  for 27 frames.
L8897:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8899:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L889B:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L889D:  .byte $2A, $1B                   ;Play note F#5 for 27 frames.
L889F:  .byte $2A, $1B                   ;Play note F#5 for 27 frames.
L88A1:  .byte $25, $1B                   ;Play note C#5 for 27 frames.
L88A3:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L88A5:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L88A7:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L88A9:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L88AB:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L88AD:  .byte $21, $0E                   ;Play note A4  for 14 frames.
L88AF:  .byte $28, $14                   ;Play note E5  for 20 frames.
L88B1:  .byte $25, $14                   ;Play note C#5 for 20 frames.
L88B3:  .byte $25, $1B                   ;Play note C#5 for 27 frames.
L88B5:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L88B7:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L88B9:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L88BB:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
L88BD:  .byte $2C, $0D                   ;Play note G#5 for 13 frames.
L88BF:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
L88C1:  .byte $2C, $0D                   ;Play note G#5 for 13 frames.
L88C3:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L88C5:  .byte $2C, $0D                   ;Play note G#5 for 13 frames.
L88C7:  .byte $2D, $1B                   ;Play note A5  for 27 frames.
L88C9:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L88CB:  .byte $26, $51                   ;Play note D5  for 81 frames.
L88CD:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L88CF:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L88D1:  .byte $2D, $0D                   ;Play note A5  for 13 frames.
L88D3:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
L88D5:  .byte $2D, $0D                   ;Play note A5  for 13 frames.
L88D7:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
L88D9:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L88DB:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L88DD:  .byte $2C, $14                   ;Play note G#5 for 20 frames.
L88DF:  .byte $2C, $14                   ;Play note G#5 for 20 frames.
L88E1:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
L88E3:  .byte $2C, $14                   ;Play note G#5 for 20 frames.
L88E5:  .byte $28, $14                   ;Play note E5  for 20 frames.
L88E7:  .byte $25, $5F                   ;Play note C#5 for 95 frames.
L88E9:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L88EB:  .byte $2A, $1B                   ;Play note F#5 for 27 frames.
L88ED:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L88EF:  .byte $26, $51                   ;Play note D5  for 81 frames.
L88F1:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L88F3:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
L88F5:  .byte $2C, $0D                   ;Play note G#5 for 13 frames.
L88F7:  .byte $2D, $1B                   ;Play note A5  for 27 frames.
L88F9:  .byte $2A, $1B                   ;Play note F#5 for 27 frames.
L88FB:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L88FD:  .byte $2C, $1B                   ;Play note G#5 for 27 frames.
L88FF:  .byte $25, $0D                   ;Play note C#5 for 13 frames.
L8901:  .byte $28, $44                   ;Play note E5  for 68 frames.
L8903:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8905:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8907:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8909:  .byte $2F, $0E                   ;Play note B5  for 14 frames.
L890B:  .byte $2D, $0D                   ;Play note A5  for 13 frames.
L890D:  .byte $2F, $0E                   ;Play note B5  for 14 frames.
L890F:  .byte $2C, $1B                   ;Play note G#5 for 27 frames.
L8911:  .byte $25, $0D                   ;Play note C#5 for 13 frames.
L8913:  .byte $28, $36                   ;Play note E5  for 54 frames.
L8915:  .byte $20, $07                   ;Play note G#4 for 7 frames.
L8917:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8919:  .byte $25, $0D                   ;Play note C#5 for 13 frames.
L891B:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L891D:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L891F:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8921:  .byte $25, $0D                   ;Play note C#5 for 13 frames.
L8923:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8925:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L8927:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8929:  .byte $2A, $14                   ;Play note F#5 for 20 frames.
L892B:  .byte $2C, $14                   ;Play note G#5 for 20 frames.
L892D:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L892F:  .byte $2A, $14                   ;Play note F#5 for 20 frames.
L8931:  .byte $2C, $22                   ;Play note G#5 for 34 frames.
L8933:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8935:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L8937:  .byte $2C, $0D                   ;Play note G#5 for 13 frames.
L8939:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
L893B:  .byte $2F, $0D                   ;Play note B5  for 13 frames.
L893D:  .byte $2D, $1B                   ;Play note A5  for 27 frames.
L893F:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
L8941:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8943:  .byte $2A, $14                   ;Play note F#5 for 20 frames.
L8945:  .byte $2A, $14                   ;Play note F#5 for 20 frames.
L8947:  .byte $28, $5F                   ;Play note E5  for 95 frames.
L8949:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L894B:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L894D:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L894F:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L8951:  .byte $2D, $14                   ;Play note A5  for 20 frames.
L8953:  .byte $2C, $14                   ;Play note G#5 for 20 frames.
L8955:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L8957:  .byte $2A, $14                   ;Play note F#5 for 20 frames.
L8959:  .byte $2C, $14                   ;Play note G#5 for 20 frames.
L895B:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
L895D:  .byte $2D, $36                   ;Play note A5  for 54 frames.
L895F:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8961:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
L8963:  .byte $2C, $0D                   ;Play note G#5 for 13 frames.
L8965:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L8967:  .byte $2F, $28                   ;Play note B5  for 40 frames.
L8969:  .byte $2C, $44                   ;Play note G#5 for 68 frames.
L896B:  .byte $1D, $06                   ;Play note F4  for 6 frames.
L896D:  .byte $20, $07                   ;Play note G#4 for 7 frames.
L896F:  .byte $21, $0E                   ;Play note A4  for 14 frames.
L8971:  .byte $20, $06                   ;Play note G#4 for 6 frames.
L8973:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8975:  .byte $23, $0E                   ;Play note B4  for 14 frames.
L8977:  .byte $25, $06                   ;Play note C#5 for 6 frames.
L8979:  .byte $23, $07                   ;Play note B4  for 7 frames.
L897B:  .byte $21, $07                   ;Play note A4  for 7 frames.
L897D:  .byte $20, $07                   ;Play note G#4 for 7 frames.
L897F:  .byte $1E, $06                   ;Play note F#4 for 6 frames.
L8981:  .byte $1D, $07                   ;Play note F4  for 7 frames.
L8983:  .byte $1A, $07                   ;Play note D4  for 7 frames.
L8985:  .byte $19, $07                   ;Play note C#4 for 7 frames.
L8987:  .byte $2A, $14                   ;Play note F#5 for 20 frames.
L8989:  .byte $2C, $14                   ;Play note G#5 for 20 frames.
L898B:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L898D:  .byte $2A, $14                   ;Play note F#5 for 20 frames.
L898F:  .byte $2C, $22                   ;Play note G#5 for 34 frames.
L8991:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8993:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L8995:  .byte $2C, $0D                   ;Play note G#5 for 13 frames.
L8997:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
L8999:  .byte $2F, $0D                   ;Play note B5  for 13 frames.
L899B:  .byte $2D, $1B                   ;Play note A5  for 27 frames.
L899D:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
L899F:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L89A1:  .byte $2A, $14                   ;Play note F#5 for 20 frames.
L89A3:  .byte $2A, $14                   ;Play note F#5 for 20 frames.
L89A5:  .byte $28, $5F                   ;Play note E5  for 95 frames.
L89A7:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L89A9:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L89AB:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L89AD:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L89AF:  .byte $2D, $14                   ;Play note A5  for 20 frames.
L89B1:  .byte $2C, $14                   ;Play note G#5 for 20 frames.
L89B3:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L89B5:  .byte $2A, $14                   ;Play note F#5 for 20 frames.
L89B7:  .byte $2C, $14                   ;Play note G#5 for 20 frames.
L89B9:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
L89BB:  .byte $2D, $36                   ;Play note A5  for 54 frames.
L89BD:  .byte $2D, $14                   ;Play note A5  for 20 frames.
L89BF:  .byte $2F, $14                   ;Play note B5  for 20 frames.
L89C1:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L89C3:  .byte $2C, $36                   ;Play note G#5 for 54 frames.
L89C5:  .byte $2C, $14                   ;Play note G#5 for 20 frames.
L89C7:  .byte $2F, $14                   ;Play note B5  for 20 frames.
L89C9:  .byte $29, $0E                   ;Play note F5  for 14 frames.
L89CB:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L89CD:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L89CF:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L89D1:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L89D3:  .byte $20, $06                   ;Play note G#4 for 6 frames.
L89D5:  .byte $21, $07                   ;Play note A4  for 7 frames.
L89D7:  .byte $23, $0E                   ;Play note B4  for 14 frames.
L89D9:  .byte $1D, $06                   ;Play note F4  for 6 frames.
L89DB:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
L89DD:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
L89DF:  .byte $2C, $28                   ;Play note G#5 for 40 frames.
L89E1:  .byte $2D, $95                   ;Play note A5  for 149 frames.
L89E3:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L89E5:  .byte $2C, $28                   ;Play note G#5 for 40 frames.
L89E7:  .byte $2A, $95                   ;Play note F#5 for 149 frames.
L89E9:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L89EB:  .byte CHN_ASR, $35               ;Set ASR data index to 03.
L89ED:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L89EF:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L89F1:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L89F3:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L89F5:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L89F7:  .byte $2B, $0E                   ;Play note G5  for 14 frames.
L89F9:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L89FB:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L89FD:  .byte $2B, $0E                   ;Play note G5  for 14 frames.
L89FF:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L8A01:  .byte $2B, $0E                   ;Play note G5  for 14 frames.
L8A03:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L8A05:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L8A07:  .byte $2B, $1B                   ;Play note G5  for 27 frames.
L8A09:  .byte $2B, $1B                   ;Play note G5  for 27 frames.
L8A0B:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8A0D:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L8A0F:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L8A11:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L8A13:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8A15:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8A17:  .byte $2B, $0E                   ;Play note G5  for 14 frames.
L8A19:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L8A1B:  .byte $2B, $0E                   ;Play note G5  for 14 frames.
L8A1D:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L8A1F:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L8A21:  .byte CHN_VIBRATO, $00, $0C, $12 ;Set vibrato speed=12, intensity=18.
L8A25:  .byte CHN_ASR, $37               ;Set ASR data index to 05.
L8A27:  .byte CHN_VOLUME, $0C            ;Set channel volume to 12.
L8A29:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8A2B:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8A2D:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L8A2F:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8A31:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L8A33:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8A35:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L8A37:  .byte $2A, $1B                   ;Play note F#5 for 27 frames.
L8A39:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L8A3B:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8A3D:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8A3F:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8A41:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8A43:  .byte $2A, $1B                   ;Play note F#5 for 27 frames.
L8A45:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L8A47:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L8A49:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L8A4B:  .byte $25, $0D                   ;Play note C#5 for 13 frames.
L8A4D:  .byte $23, $1B                   ;Play note B4  for 27 frames.
L8A4F:  .byte $21, $1B                   ;Play note A4  for 27 frames.
L8A51:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8A53:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8A55:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8A57:  .byte $2A, $1B                   ;Play note F#5 for 27 frames.
L8A59:  .byte $2A, $1B                   ;Play note F#5 for 27 frames.
L8A5B:  .byte $25, $1B                   ;Play note C#5 for 27 frames.
L8A5D:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L8A5F:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L8A61:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L8A63:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8A65:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L8A67:  .byte $21, $0E                   ;Play note A4  for 14 frames.
L8A69:  .byte $23, $14                   ;Play note B4  for 20 frames.
L8A6B:  .byte $25, $14                   ;Play note C#5 for 20 frames.
L8A6D:  .byte $25, $1B                   ;Play note C#5 for 27 frames.
L8A6F:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8A71:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8A73:  .byte $20, $06                   ;Play note G#4 for 6 frames.
L8A75:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8A77:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8A79:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L8A7B:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8A7D:  .byte $20, $06                   ;Play note G#4 for 6 frames.
L8A7F:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8A81:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8A83:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L8A85:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8A87:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8A89:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8A8B:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L8A8D:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8A8F:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L8A91:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8A93:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L8A95:  .byte $2A, $1B                   ;Play note F#5 for 27 frames.
L8A97:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L8A99:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8A9B:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8A9D:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8A9F:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8AA1:  .byte $2A, $1B                   ;Play note F#5 for 27 frames.
L8AA3:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L8AA5:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L8AA7:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L8AA9:  .byte $25, $0D                   ;Play note C#5 for 13 frames.
L8AAB:  .byte $23, $1B                   ;Play note B4  for 27 frames.
L8AAD:  .byte $21, $1B                   ;Play note A4  for 27 frames.
L8AAF:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8AB1:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8AB3:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8AB5:  .byte $2A, $1B                   ;Play note F#5 for 27 frames.
L8AB7:  .byte $2A, $1B                   ;Play note F#5 for 27 frames.
L8AB9:  .byte $25, $1B                   ;Play note C#5 for 27 frames.
L8ABB:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L8ABD:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L8ABF:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L8AC1:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8AC3:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L8AC5:  .byte $21, $0E                   ;Play note A4  for 14 frames.
L8AC7:  .byte $28, $14                   ;Play note E5  for 20 frames.
L8AC9:  .byte $25, $14                   ;Play note C#5 for 20 frames.
L8ACB:  .byte $25, $1B                   ;Play note C#5 for 27 frames.
L8ACD:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L8ACF:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8AD1:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8AD3:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
L8AD5:  .byte $2C, $0D                   ;Play note G#5 for 13 frames.
L8AD7:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
L8AD9:  .byte $2C, $0D                   ;Play note G#5 for 13 frames.
L8ADB:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L8ADD:  .byte $2C, $0D                   ;Play note G#5 for 13 frames.
L8ADF:  .byte $2D, $1B                   ;Play note A5  for 27 frames.
L8AE1:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L8AE3:  .byte $26, $51                   ;Play note D5  for 81 frames.
L8AE5:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8AE7:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L8AE9:  .byte $2D, $0D                   ;Play note A5  for 13 frames.
L8AEB:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
L8AED:  .byte $2D, $0D                   ;Play note A5  for 13 frames.
L8AEF:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
L8AF1:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L8AF3:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L8AF5:  .byte $2C, $14                   ;Play note G#5 for 20 frames.
L8AF7:  .byte $2C, $14                   ;Play note G#5 for 20 frames.
L8AF9:  .byte $2C, $0E                   ;Play note G#5 for 14 frames.
L8AFB:  .byte $2C, $14                   ;Play note G#5 for 20 frames.
L8AFD:  .byte $28, $14                   ;Play note E5  for 20 frames.
L8AFF:  .byte $25, $5F                   ;Play note C#5 for 95 frames.
L8B01:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8B03:  .byte $2A, $1B                   ;Play note F#5 for 27 frames.
L8B05:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L8B07:  .byte $26, $51                   ;Play note D5  for 81 frames.
L8B09:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L8B0B:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
L8B0D:  .byte $2C, $0D                   ;Play note G#5 for 13 frames.
L8B0F:  .byte $2D, $1B                   ;Play note A5  for 27 frames.
L8B11:  .byte $2A, $1B                   ;Play note F#5 for 27 frames.
L8B13:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L8B15:  .byte $2C, $1B                   ;Play note G#5 for 27 frames.
L8B17:  .byte $25, $0D                   ;Play note C#5 for 13 frames.
L8B19:  .byte $28, $44                   ;Play note E5  for 68 frames.
L8B1B:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8B1D:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8B1F:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8B21:  .byte $2F, $0E                   ;Play note B5  for 14 frames.
L8B23:  .byte $2D, $0D                   ;Play note A5  for 13 frames.
L8B25:  .byte $2F, $0E                   ;Play note B5  for 14 frames.
L8B27:  .byte $2C, $1B                   ;Play note G#5 for 27 frames.
L8B29:  .byte $25, $0D                   ;Play note C#5 for 13 frames.
L8B2B:  .byte $28, $36                   ;Play note E5  for 54 frames.
L8B2D:  .byte $20, $07                   ;Play note G#4 for 7 frames.
L8B2F:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8B31:  .byte $25, $0D                   ;Play note C#5 for 13 frames.
L8B33:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8B35:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L8B37:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8B39:  .byte $25, $0D                   ;Play note C#5 for 13 frames.
L8B3B:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8B3D:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L8B3F:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8B41:  .byte $2A, $14                   ;Play note F#5 for 20 frames.
L8B43:  .byte $2C, $14                   ;Play note G#5 for 20 frames.
L8B45:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8B47:  .byte $2A, $14                   ;Play note F#5 for 20 frames.
L8B49:  .byte $2C, $22                   ;Play note G#5 for 34 frames.
L8B4B:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8B4D:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L8B4F:  .byte $2C, $0D                   ;Play note G#5 for 13 frames.
L8B51:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
L8B53:  .byte $2F, $0D                   ;Play note B5  for 13 frames.
L8B55:  .byte $2D, $1B                   ;Play note A5  for 27 frames.
L8B57:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
L8B59:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8B5B:  .byte $2A, $14                   ;Play note F#5 for 20 frames.
L8B5D:  .byte $2A, $14                   ;Play note F#5 for 20 frames.
L8B5F:  .byte $28, $5F                   ;Play note E5  for 95 frames.
L8B61:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8B63:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8B65:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8B67:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L8B69:  .byte $2D, $14                   ;Play note A5  for 20 frames.
L8B6B:  .byte $2C, $14                   ;Play note G#5 for 20 frames.
L8B6D:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L8B6F:  .byte $2A, $14                   ;Play note F#5 for 20 frames.
L8B71:  .byte $2C, $14                   ;Play note G#5 for 20 frames.
L8B73:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
L8B75:  .byte $2D, $36                   ;Play note A5  for 54 frames.
L8B77:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8B79:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
L8B7B:  .byte $2C, $0D                   ;Play note G#5 for 13 frames.
L8B7D:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L8B7F:  .byte $2F, $28                   ;Play note B5  for 40 frames.
L8B81:  .byte $2C, $44                   ;Play note G#5 for 68 frames.
L8B83:  .byte $1D, $06                   ;Play note F4  for 6 frames.
L8B85:  .byte $20, $07                   ;Play note G#4 for 7 frames.
L8B87:  .byte $21, $0E                   ;Play note A4  for 14 frames.
L8B89:  .byte $20, $06                   ;Play note G#4 for 6 frames.
L8B8B:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8B8D:  .byte $23, $0E                   ;Play note B4  for 14 frames.
L8B8F:  .byte $25, $06                   ;Play note C#5 for 6 frames.
L8B91:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8B93:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8B95:  .byte $20, $07                   ;Play note G#4 for 7 frames.
L8B97:  .byte $1E, $06                   ;Play note F#4 for 6 frames.
L8B99:  .byte $1D, $07                   ;Play note F4  for 7 frames.
L8B9B:  .byte $1A, $07                   ;Play note D4  for 7 frames.
L8B9D:  .byte $19, $07                   ;Play note C#4 for 7 frames.
L8B9F:  .byte $2A, $14                   ;Play note F#5 for 20 frames.
L8BA1:  .byte $2C, $14                   ;Play note G#5 for 20 frames.
L8BA3:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8BA5:  .byte $2A, $14                   ;Play note F#5 for 20 frames.
L8BA7:  .byte $2C, $22                   ;Play note G#5 for 34 frames.
L8BA9:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8BAB:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L8BAD:  .byte $2C, $0D                   ;Play note G#5 for 13 frames.
L8BAF:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
L8BB1:  .byte $2F, $0D                   ;Play note B5  for 13 frames.
L8BB3:  .byte $2D, $1B                   ;Play note A5  for 27 frames.
L8BB5:  .byte $2C, $07                   ;Play note G#5 for 7 frames.
L8BB7:  .byte $2A, $07                   ;Play note F#5 for 7 frames.
L8BB9:  .byte $2A, $14                   ;Play note F#5 for 20 frames.
L8BBB:  .byte $2A, $14                   ;Play note F#5 for 20 frames.
L8BBD:  .byte $28, $5F                   ;Play note E5  for 95 frames.
L8BBF:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8BC1:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8BC3:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8BC5:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L8BC7:  .byte $2D, $14                   ;Play note A5  for 20 frames.
L8BC9:  .byte $2C, $14                   ;Play note G#5 for 20 frames.
L8BCB:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L8BCD:  .byte $2A, $14                   ;Play note F#5 for 20 frames.
L8BCF:  .byte $2C, $14                   ;Play note G#5 for 20 frames.
L8BD1:  .byte $2D, $0E                   ;Play note A5  for 14 frames.
L8BD3:  .byte $2D, $36                   ;Play note A5  for 54 frames.
L8BD5:  .byte $2D, $14                   ;Play note A5  for 20 frames.
L8BD7:  .byte $2F, $14                   ;Play note B5  for 20 frames.
L8BD9:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L8BDB:  .byte $2C, $36                   ;Play note G#5 for 54 frames.
L8BDD:  .byte $2C, $14                   ;Play note G#5 for 20 frames.
L8BDF:  .byte $2F, $14                   ;Play note B5  for 20 frames.
L8BE1:  .byte $29, $0E                   ;Play note F5  for 14 frames.
L8BE3:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8BE5:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8BE7:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L8BE9:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8BEB:  .byte $20, $06                   ;Play note G#4 for 6 frames.
L8BED:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8BEF:  .byte $23, $0E                   ;Play note B4  for 14 frames.
L8BF1:  .byte $1D, $06                   ;Play note F4  for 6 frames.
L8BF3:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
L8BF5:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
L8BF7:  .byte $2C, $28                   ;Play note G#5 for 40 frames.
L8BF9:  .byte $2D, $95                   ;Play note A5  for 149 frames.
L8BFB:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8BFD:  .byte $2C, $28                   ;Play note G#5 for 40 frames.
L8BFF:  .byte $2A, $95                   ;Play note F#5 for 149 frames.
L8C01:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8C03:  .byte CHN_JUMP, $00, $94, $FB    ;Jump back 1132 bytes to $8797.

;----------------------------------------------------------------------------------------------------

;Character creation music SQ2 data.

ChrCreateSQ2:
L8C07:  .byte CHN_VOLUME, $0C            ;Set channel volume to 12.
L8C09:  .byte CHN_VIBRATO, $00, $08, $0E ;Set vibrato speed=8, intensity=14.
L8C0D:  .byte CHN_ASR, $33               ;Set ASR data index to 01.
L8C0F:  .byte $15, $1B                   ;Play note A3  for 27 frames.
L8C11:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L8C13:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
L8C15:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8C17:  .byte $14, $0E                   ;Play note G#3 for 14 frames.
L8C19:  .byte $15, $0D                   ;Play note A3  for 13 frames.
L8C1B:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
L8C1D:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8C1F:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
L8C21:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L8C23:  .byte $17, $0E                   ;Play note B3  for 14 frames.
L8C25:  .byte $15, $1B                   ;Play note A3  for 27 frames.
L8C27:  .byte $14, $1B                   ;Play note G#3 for 27 frames.
L8C29:  .byte $15, $1B                   ;Play note A3  for 27 frames.
L8C2B:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L8C2D:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
L8C2F:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8C31:  .byte $14, $0E                   ;Play note G#3 for 14 frames.
L8C33:  .byte $15, $0D                   ;Play note A3  for 13 frames.
L8C35:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
L8C37:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8C39:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
L8C3B:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L8C3D:  .byte $17, $0E                   ;Play note B3  for 14 frames.
L8C3F:  .byte $15, $1B                   ;Play note A3  for 27 frames.
L8C41:  .byte $14, $1B                   ;Play note G#3 for 27 frames.
L8C43:  .byte CHN_ASR, $36               ;Set ASR data index to 04.
L8C45:  .byte $19, $1B                   ;Play note C#4 for 27 frames.
L8C47:  .byte $19, $1B                   ;Play note C#4 for 27 frames.
L8C49:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8C4B:  .byte $1A, $0E                   ;Play note D4  for 14 frames.
L8C4D:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L8C4F:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
L8C51:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8C53:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8C55:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
L8C57:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L8C59:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
L8C5B:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L8C5D:  .byte $19, $0E                   ;Play note C#4 for 14 frames.
L8C5F:  .byte $1C, $1B                   ;Play note E4  for 27 frames.
L8C61:  .byte $1C, $1B                   ;Play note E4  for 27 frames.
L8C63:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8C65:  .byte $1A, $0E                   ;Play note D4  for 14 frames.
L8C67:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L8C69:  .byte $19, $0E                   ;Play note C#4 for 14 frames.
L8C6B:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8C6D:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8C6F:  .byte $1A, $0E                   ;Play note D4  for 14 frames.
L8C71:  .byte $19, $0D                   ;Play note C#4 for 13 frames.
L8C73:  .byte $1A, $0E                   ;Play note D4  for 14 frames.
L8C75:  .byte $19, $0D                   ;Play note C#4 for 13 frames.
L8C77:  .byte $17, $0E                   ;Play note B3  for 14 frames.
L8C79:  .byte CHN_VOLUME, $09            ;Set channel volume to 9.
L8C7B:  .byte CHN_ASR, $38               ;Set ASR data index to 06.
L8C7D:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8C7F:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8C81:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8C83:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L8C85:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L8C87:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8C89:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8C8B:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8C8D:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L8C8F:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L8C91:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8C93:  .byte $20, $07                   ;Play note G#4 for 7 frames.
L8C95:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8C97:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L8C99:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L8C9B:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8C9D:  .byte $20, $07                   ;Play note G#4 for 7 frames.
L8C9F:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8CA1:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L8CA3:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L8CA5:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8CA7:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
L8CA9:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8CAB:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L8CAD:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L8CAF:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8CB1:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
L8CB3:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8CB5:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L8CB7:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L8CB9:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8CBB:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
L8CBD:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8CBF:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L8CC1:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8CC3:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8CC5:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
L8CC7:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8CC9:  .byte $25, $0D                   ;Play note C#5 for 13 frames.
L8CCB:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8CCD:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L8CCF:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
L8CD1:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L8CD3:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L8CD5:  .byte $26, $1B                   ;Play note D5  for 27 frames.
L8CD7:  .byte $21, $0E                   ;Play note A4  for 14 frames.
L8CD9:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L8CDB:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
L8CDD:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L8CDF:  .byte $1C, $1B                   ;Play note E4  for 27 frames.
L8CE1:  .byte $1A, $1B                   ;Play note D4  for 27 frames.
L8CE3:  .byte $21, $0E                   ;Play note A4  for 14 frames.
L8CE5:  .byte $25, $0D                   ;Play note C#5 for 13 frames.
L8CE7:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
L8CE9:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L8CEB:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L8CED:  .byte $25, $1B                   ;Play note C#5 for 27 frames.
L8CEF:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
L8CF1:  .byte $14, $06                   ;Play note G#3 for 6 frames.
L8CF3:  .byte $17, $07                   ;Play note B3  for 7 frames.
L8CF5:  .byte $19, $0E                   ;Play note C#4 for 14 frames.
L8CF7:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L8CF9:  .byte $19, $0E                   ;Play note C#4 for 14 frames.
L8CFB:  .byte $14, $06                   ;Play note G#3 for 6 frames.
L8CFD:  .byte $17, $07                   ;Play note B3  for 7 frames.
L8CFF:  .byte $19, $0E                   ;Play note C#4 for 14 frames.
L8D01:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L8D03:  .byte $19, $0E                   ;Play note C#4 for 14 frames.
L8D05:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8D07:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8D09:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8D0B:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L8D0D:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L8D0F:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8D11:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8D13:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8D15:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L8D17:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L8D19:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8D1B:  .byte $20, $07                   ;Play note G#4 for 7 frames.
L8D1D:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8D1F:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L8D21:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L8D23:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8D25:  .byte $20, $07                   ;Play note G#4 for 7 frames.
L8D27:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8D29:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L8D2B:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L8D2D:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8D2F:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
L8D31:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8D33:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L8D35:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L8D37:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8D39:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
L8D3B:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8D3D:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L8D3F:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L8D41:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8D43:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
L8D45:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8D47:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L8D49:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8D4B:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8D4D:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
L8D4F:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8D51:  .byte $25, $0D                   ;Play note C#5 for 13 frames.
L8D53:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8D55:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L8D57:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
L8D59:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L8D5B:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L8D5D:  .byte $26, $1B                   ;Play note D5  for 27 frames.
L8D5F:  .byte $21, $0E                   ;Play note A4  for 14 frames.
L8D61:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L8D63:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
L8D65:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L8D67:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L8D69:  .byte $26, $1B                   ;Play note D5  for 27 frames.
L8D6B:  .byte $21, $0E                   ;Play note A4  for 14 frames.
L8D6D:  .byte $25, $0D                   ;Play note C#5 for 13 frames.
L8D6F:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
L8D71:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L8D73:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L8D75:  .byte $25, $1B                   ;Play note C#5 for 27 frames.
L8D77:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
L8D79:  .byte $25, $0D                   ;Play note C#5 for 13 frames.
L8D7B:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
L8D7D:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L8D7F:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L8D81:  .byte $25, $1B                   ;Play note C#5 for 27 frames.
L8D83:  .byte $2D, $1B                   ;Play note A5  for 27 frames.
L8D85:  .byte $1A, $0E                   ;Play note D4  for 14 frames.
L8D87:  .byte $1A, $51                   ;Play note D4  for 81 frames.
L8D89:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8D8B:  .byte $1A, $0E                   ;Play note D4  for 14 frames.
L8D8D:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L8D8F:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
L8D91:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L8D93:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
L8D95:  .byte $1E, $0D                   ;Play note F#4 for 13 frames.
L8D97:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
L8D99:  .byte $20, $14                   ;Play note G#4 for 20 frames.
L8D9B:  .byte $20, $14                   ;Play note G#4 for 20 frames.
L8D9D:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
L8D9F:  .byte $20, $14                   ;Play note G#4 for 20 frames.
L8DA1:  .byte $1C, $14                   ;Play note E4  for 20 frames.
L8DA3:  .byte $19, $5F                   ;Play note C#4 for 95 frames.
L8DA5:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8DA7:  .byte $1E, $1B                   ;Play note F#4 for 27 frames.
L8DA9:  .byte $1A, $0E                   ;Play note D4  for 14 frames.
L8DAB:  .byte $1A, $51                   ;Play note D4  for 81 frames.
L8DAD:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L8DAF:  .byte $21, $0E                   ;Play note A4  for 14 frames.
L8DB1:  .byte $20, $0D                   ;Play note G#4 for 13 frames.
L8DB3:  .byte $21, $1B                   ;Play note A4  for 27 frames.
L8DB5:  .byte $1E, $1B                   ;Play note F#4 for 27 frames.
L8DB7:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
L8DB9:  .byte $19, $0D                   ;Play note C#4 for 13 frames.
L8DBB:  .byte $20, $1B                   ;Play note G#4 for 27 frames.
L8DBD:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
L8DBF:  .byte $1E, $0D                   ;Play note F#4 for 13 frames.
L8DC1:  .byte $1C, $1B                   ;Play note E4  for 27 frames.
L8DC3:  .byte $19, $0E                   ;Play note C#4 for 14 frames.
L8DC5:  .byte $19, $0D                   ;Play note C#4 for 13 frames.
L8DC7:  .byte $20, $1B                   ;Play note G#4 for 27 frames.
L8DC9:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
L8DCB:  .byte $1E, $0D                   ;Play note F#4 for 13 frames.
L8DCD:  .byte $1C, $1B                   ;Play note E4  for 27 frames.
L8DCF:  .byte $19, $0E                   ;Play note C#4 for 14 frames.
L8DD1:  .byte $19, $0D                   ;Play note C#4 for 13 frames.
L8DD3:  .byte $20, $1B                   ;Play note G#4 for 27 frames.
L8DD5:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
L8DD7:  .byte $1E, $0D                   ;Play note F#4 for 13 frames.
L8DD9:  .byte $1C, $1B                   ;Play note E4  for 27 frames.
L8DDB:  .byte $19, $0E                   ;Play note C#4 for 14 frames.
L8DDD:  .byte $19, $0D                   ;Play note C#4 for 13 frames.
L8DDF:  .byte $19, $0E                   ;Play note C#4 for 14 frames.
L8DE1:  .byte $17, $0D                   ;Play note B3  for 13 frames.
L8DE3:  .byte $19, $0E                   ;Play note C#4 for 14 frames.
L8DE5:  .byte $19, $0D                   ;Play note C#4 for 13 frames.
L8DE7:  .byte $19, $0E                   ;Play note C#4 for 14 frames.
L8DE9:  .byte $17, $0D                   ;Play note B3  for 13 frames.
L8DEB:  .byte $19, $0E                   ;Play note C#4 for 14 frames.
L8DED:  .byte $21, $14                   ;Play note A4  for 20 frames.
L8DEF:  .byte $23, $14                   ;Play note B4  for 20 frames.
L8DF1:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
L8DF3:  .byte $21, $14                   ;Play note A4  for 20 frames.
L8DF5:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8DF7:  .byte $23, $1B                   ;Play note B4  for 27 frames.
L8DF9:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8DFB:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
L8DFD:  .byte $20, $0D                   ;Play note G#4 for 13 frames.
L8DFF:  .byte $21, $0E                   ;Play note A4  for 14 frames.
L8E01:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L8E03:  .byte $21, $1B                   ;Play note A4  for 27 frames.
L8E05:  .byte $20, $07                   ;Play note G#4 for 7 frames.
L8E07:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
L8E09:  .byte $1E, $14                   ;Play note F#4 for 20 frames.
L8E0B:  .byte $1E, $14                   ;Play note F#4 for 20 frames.
L8E0D:  .byte $1C, $5F                   ;Play note E4  for 95 frames.
L8E0F:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8E11:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8E13:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8E15:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L8E17:  .byte $2A, $14                   ;Play note F#5 for 20 frames.
L8E19:  .byte $28, $14                   ;Play note E5  for 20 frames.
L8E1B:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L8E1D:  .byte $26, $14                   ;Play note D5  for 20 frames.
L8E1F:  .byte $28, $14                   ;Play note E5  for 20 frames.
L8E21:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L8E23:  .byte $2A, $36                   ;Play note F#5 for 54 frames.
L8E25:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8E27:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L8E29:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L8E2B:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L8E2D:  .byte $2C, $28                   ;Play note G#5 for 40 frames.
L8E2F:  .byte $29, $0E                   ;Play note F5  for 14 frames.
L8E31:  .byte $29, $36                   ;Play note F5  for 54 frames.
L8E33:  .byte $1D, $06                   ;Play note F4  for 6 frames.
L8E35:  .byte $20, $07                   ;Play note G#4 for 7 frames.
L8E37:  .byte $21, $0E                   ;Play note A4  for 14 frames.
L8E39:  .byte $20, $06                   ;Play note G#4 for 6 frames.
L8E3B:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8E3D:  .byte $23, $0E                   ;Play note B4  for 14 frames.
L8E3F:  .byte $25, $06                   ;Play note C#5 for 6 frames.
L8E41:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8E43:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8E45:  .byte $20, $07                   ;Play note G#4 for 7 frames.
L8E47:  .byte $1E, $06                   ;Play note F#4 for 6 frames.
L8E49:  .byte $1D, $07                   ;Play note F4  for 7 frames.
L8E4B:  .byte $1A, $07                   ;Play note D4  for 7 frames.
L8E4D:  .byte $19, $07                   ;Play note C#4 for 7 frames.
L8E4F:  .byte $21, $14                   ;Play note A4  for 20 frames.
L8E51:  .byte $23, $14                   ;Play note B4  for 20 frames.
L8E53:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
L8E55:  .byte $21, $14                   ;Play note A4  for 20 frames.
L8E57:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8E59:  .byte $23, $1B                   ;Play note B4  for 27 frames.
L8E5B:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8E5D:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
L8E5F:  .byte $20, $0D                   ;Play note G#4 for 13 frames.
L8E61:  .byte $21, $0E                   ;Play note A4  for 14 frames.
L8E63:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L8E65:  .byte $21, $1B                   ;Play note A4  for 27 frames.
L8E67:  .byte $20, $07                   ;Play note G#4 for 7 frames.
L8E69:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
L8E6B:  .byte $1E, $14                   ;Play note F#4 for 20 frames.
L8E6D:  .byte $1E, $14                   ;Play note F#4 for 20 frames.
L8E6F:  .byte $1C, $5F                   ;Play note E4  for 95 frames.
L8E71:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8E73:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8E75:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8E77:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L8E79:  .byte $2A, $14                   ;Play note F#5 for 20 frames.
L8E7B:  .byte $28, $14                   ;Play note E5  for 20 frames.
L8E7D:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L8E7F:  .byte $26, $14                   ;Play note D5  for 20 frames.
L8E81:  .byte $28, $14                   ;Play note E5  for 20 frames.
L8E83:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L8E85:  .byte $2A, $36                   ;Play note F#5 for 54 frames.
L8E87:  .byte $2A, $14                   ;Play note F#5 for 20 frames.
L8E89:  .byte $2C, $14                   ;Play note G#5 for 20 frames.
L8E8B:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L8E8D:  .byte $29, $36                   ;Play note F5  for 54 frames.
L8E8F:  .byte $29, $14                   ;Play note F5  for 20 frames.
L8E91:  .byte $2C, $14                   ;Play note G#5 for 20 frames.
L8E93:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8E95:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8E97:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8E99:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L8E9B:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8E9D:  .byte $20, $06                   ;Play note G#4 for 6 frames.
L8E9F:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8EA1:  .byte $23, $0E                   ;Play note B4  for 14 frames.
L8EA3:  .byte $1D, $06                   ;Play note F4  for 6 frames.
L8EA5:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
L8EA7:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
L8EA9:  .byte $20, $1B                   ;Play note G#4 for 27 frames.
L8EAB:  .byte $20, $0D                   ;Play note G#4 for 13 frames.
L8EAD:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
L8EAF:  .byte $1E, $0D                   ;Play note F#4 for 13 frames.
L8EB1:  .byte $1E, $1B                   ;Play note F#4 for 27 frames.
L8EB3:  .byte $1A, $0E                   ;Play note D4  for 14 frames.
L8EB5:  .byte $20, $1B                   ;Play note G#4 for 27 frames.
L8EB7:  .byte $20, $0D                   ;Play note G#4 for 13 frames.
L8EB9:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
L8EBB:  .byte $1E, $0D                   ;Play note F#4 for 13 frames.
L8EBD:  .byte $1E, $1B                   ;Play note F#4 for 27 frames.
L8EBF:  .byte $1A, $0E                   ;Play note D4  for 14 frames.
L8EC1:  .byte $20, $1B                   ;Play note G#4 for 27 frames.
L8EC3:  .byte $20, $0D                   ;Play note G#4 for 13 frames.
L8EC5:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
L8EC7:  .byte $22, $0D                   ;Play note A#4 for 13 frames.
L8EC9:  .byte $22, $1B                   ;Play note A#4 for 27 frames.
L8ECB:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
L8ECD:  .byte $20, $1B                   ;Play note G#4 for 27 frames.
L8ECF:  .byte $20, $0D                   ;Play note G#4 for 13 frames.
L8ED1:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
L8ED3:  .byte $22, $0D                   ;Play note A#4 for 13 frames.
L8ED5:  .byte $22, $1B                   ;Play note A#4 for 27 frames.
L8ED7:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
L8ED9:  .byte CHN_ASR, $36               ;Set ASR data index to 04.
L8EDB:  .byte $19, $1B                   ;Play note C#4 for 27 frames.
L8EDD:  .byte $19, $1B                   ;Play note C#4 for 27 frames.
L8EDF:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8EE1:  .byte $1A, $0E                   ;Play note D4  for 14 frames.
L8EE3:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L8EE5:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
L8EE7:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8EE9:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8EEB:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
L8EED:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L8EEF:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
L8EF1:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L8EF3:  .byte $19, $0E                   ;Play note C#4 for 14 frames.
L8EF5:  .byte $1C, $1B                   ;Play note E4  for 27 frames.
L8EF7:  .byte $1C, $1B                   ;Play note E4  for 27 frames.
L8EF9:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8EFB:  .byte $1A, $0E                   ;Play note D4  for 14 frames.
L8EFD:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L8EFF:  .byte $19, $0E                   ;Play note C#4 for 14 frames.
L8F01:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L8F03:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8F05:  .byte $1A, $0E                   ;Play note D4  for 14 frames.
L8F07:  .byte $19, $0D                   ;Play note C#4 for 13 frames.
L8F09:  .byte $1A, $0E                   ;Play note D4  for 14 frames.
L8F0B:  .byte $19, $0D                   ;Play note C#4 for 13 frames.
L8F0D:  .byte $17, $0E                   ;Play note B3  for 14 frames.
L8F0F:  .byte CHN_VOLUME, $09            ;Set channel volume to 9.
L8F11:  .byte CHN_ASR, $38               ;Set ASR data index to 06.
L8F13:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8F15:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8F17:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8F19:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L8F1B:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L8F1D:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8F1F:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8F21:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8F23:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L8F25:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L8F27:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8F29:  .byte $20, $07                   ;Play note G#4 for 7 frames.
L8F2B:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8F2D:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L8F2F:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L8F31:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8F33:  .byte $20, $07                   ;Play note G#4 for 7 frames.
L8F35:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8F37:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L8F39:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L8F3B:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8F3D:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
L8F3F:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8F41:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L8F43:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L8F45:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8F47:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
L8F49:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8F4B:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L8F4D:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L8F4F:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8F51:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
L8F53:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8F55:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L8F57:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8F59:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8F5B:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
L8F5D:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8F5F:  .byte $25, $0D                   ;Play note C#5 for 13 frames.
L8F61:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8F63:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L8F65:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
L8F67:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L8F69:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L8F6B:  .byte $26, $1B                   ;Play note D5  for 27 frames.
L8F6D:  .byte $21, $0E                   ;Play note A4  for 14 frames.
L8F6F:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L8F71:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
L8F73:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L8F75:  .byte $1C, $1B                   ;Play note E4  for 27 frames.
L8F77:  .byte $1A, $1B                   ;Play note D4  for 27 frames.
L8F79:  .byte $21, $0E                   ;Play note A4  for 14 frames.
L8F7B:  .byte $25, $0D                   ;Play note C#5 for 13 frames.
L8F7D:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
L8F7F:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L8F81:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L8F83:  .byte $25, $1B                   ;Play note C#5 for 27 frames.
L8F85:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
L8F87:  .byte $14, $06                   ;Play note G#3 for 6 frames.
L8F89:  .byte $17, $07                   ;Play note B3  for 7 frames.
L8F8B:  .byte $19, $0E                   ;Play note C#4 for 14 frames.
L8F8D:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L8F8F:  .byte $19, $0E                   ;Play note C#4 for 14 frames.
L8F91:  .byte $14, $06                   ;Play note G#3 for 6 frames.
L8F93:  .byte $17, $07                   ;Play note B3  for 7 frames.
L8F95:  .byte $19, $0E                   ;Play note C#4 for 14 frames.
L8F97:  .byte $1C, $0D                   ;Play note E4  for 13 frames.
L8F99:  .byte $19, $0E                   ;Play note C#4 for 14 frames.
L8F9B:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8F9D:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8F9F:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8FA1:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L8FA3:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L8FA5:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8FA7:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8FA9:  .byte $25, $07                   ;Play note C#5 for 7 frames.
L8FAB:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L8FAD:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L8FAF:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8FB1:  .byte $20, $07                   ;Play note G#4 for 7 frames.
L8FB3:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8FB5:  .byte $2A, $0D                   ;Play note F#5 for 13 frames.
L8FB7:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L8FB9:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8FBB:  .byte $20, $07                   ;Play note G#4 for 7 frames.
L8FBD:  .byte $23, $07                   ;Play note B4  for 7 frames.
L8FBF:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L8FC1:  .byte $28, $0E                   ;Play note E5  for 14 frames.
L8FC3:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8FC5:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
L8FC7:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8FC9:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L8FCB:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L8FCD:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8FCF:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
L8FD1:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8FD3:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L8FD5:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L8FD7:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8FD9:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
L8FDB:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8FDD:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L8FDF:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8FE1:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L8FE3:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
L8FE5:  .byte $21, $07                   ;Play note A4  for 7 frames.
L8FE7:  .byte $25, $0D                   ;Play note C#5 for 13 frames.
L8FE9:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L8FEB:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L8FED:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
L8FEF:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L8FF1:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L8FF3:  .byte $26, $1B                   ;Play note D5  for 27 frames.
L8FF5:  .byte $21, $0E                   ;Play note A4  for 14 frames.
L8FF7:  .byte $26, $0D                   ;Play note D5  for 13 frames.
L8FF9:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
L8FFB:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L8FFD:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L8FFF:  .byte $26, $1B                   ;Play note D5  for 27 frames.
L9001:  .byte $21, $0E                   ;Play note A4  for 14 frames.
L9003:  .byte $25, $0D                   ;Play note C#5 for 13 frames.
L9005:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
L9007:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L9009:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L900B:  .byte $25, $1B                   ;Play note C#5 for 27 frames.
L900D:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
L900F:  .byte $25, $0D                   ;Play note C#5 for 13 frames.
L9011:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
L9013:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L9015:  .byte $28, $1B                   ;Play note E5  for 27 frames.
L9017:  .byte $25, $1B                   ;Play note C#5 for 27 frames.
L9019:  .byte $2D, $1B                   ;Play note A5  for 27 frames.
L901B:  .byte $1A, $0E                   ;Play note D4  for 14 frames.
L901D:  .byte $1A, $51                   ;Play note D4  for 81 frames.
L901F:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9021:  .byte $1A, $0E                   ;Play note D4  for 14 frames.
L9023:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L9025:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
L9027:  .byte $21, $0D                   ;Play note A4  for 13 frames.
L9029:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
L902B:  .byte $1E, $0D                   ;Play note F#4 for 13 frames.
L902D:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
L902F:  .byte $20, $14                   ;Play note G#4 for 20 frames.
L9031:  .byte $20, $14                   ;Play note G#4 for 20 frames.
L9033:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
L9035:  .byte $20, $14                   ;Play note G#4 for 20 frames.
L9037:  .byte $1C, $14                   ;Play note E4  for 20 frames.
L9039:  .byte $19, $5F                   ;Play note C#4 for 95 frames.
L903B:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L903D:  .byte $1E, $1B                   ;Play note F#4 for 27 frames.
L903F:  .byte $1A, $0E                   ;Play note D4  for 14 frames.
L9041:  .byte $1A, $51                   ;Play note D4  for 81 frames.
L9043:  .byte $1A, $0D                   ;Play note D4  for 13 frames.
L9045:  .byte $21, $0E                   ;Play note A4  for 14 frames.
L9047:  .byte $20, $0D                   ;Play note G#4 for 13 frames.
L9049:  .byte $21, $1B                   ;Play note A4  for 27 frames.
L904B:  .byte $1E, $1B                   ;Play note F#4 for 27 frames.
L904D:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
L904F:  .byte $19, $0D                   ;Play note C#4 for 13 frames.
L9051:  .byte $20, $1B                   ;Play note G#4 for 27 frames.
L9053:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
L9055:  .byte $1E, $0D                   ;Play note F#4 for 13 frames.
L9057:  .byte $1C, $1B                   ;Play note E4  for 27 frames.
L9059:  .byte $19, $0E                   ;Play note C#4 for 14 frames.
L905B:  .byte $19, $0D                   ;Play note C#4 for 13 frames.
L905D:  .byte $20, $1B                   ;Play note G#4 for 27 frames.
L905F:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
L9061:  .byte $1E, $0D                   ;Play note F#4 for 13 frames.
L9063:  .byte $1C, $1B                   ;Play note E4  for 27 frames.
L9065:  .byte $19, $0E                   ;Play note C#4 for 14 frames.
L9067:  .byte $19, $0D                   ;Play note C#4 for 13 frames.
L9069:  .byte $20, $1B                   ;Play note G#4 for 27 frames.
L906B:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
L906D:  .byte $1E, $0D                   ;Play note F#4 for 13 frames.
L906F:  .byte $1C, $1B                   ;Play note E4  for 27 frames.
L9071:  .byte $19, $0E                   ;Play note C#4 for 14 frames.
L9073:  .byte $19, $0D                   ;Play note C#4 for 13 frames.
L9075:  .byte $19, $0E                   ;Play note C#4 for 14 frames.
L9077:  .byte $17, $0D                   ;Play note B3  for 13 frames.
L9079:  .byte $19, $0E                   ;Play note C#4 for 14 frames.
L907B:  .byte $19, $0D                   ;Play note C#4 for 13 frames.
L907D:  .byte $19, $0E                   ;Play note C#4 for 14 frames.
L907F:  .byte $17, $0D                   ;Play note B3  for 13 frames.
L9081:  .byte $19, $0E                   ;Play note C#4 for 14 frames.
L9083:  .byte $21, $14                   ;Play note A4  for 20 frames.
L9085:  .byte $23, $14                   ;Play note B4  for 20 frames.
L9087:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
L9089:  .byte $21, $14                   ;Play note A4  for 20 frames.
L908B:  .byte $23, $07                   ;Play note B4  for 7 frames.
L908D:  .byte $23, $1B                   ;Play note B4  for 27 frames.
L908F:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9091:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
L9093:  .byte $20, $0D                   ;Play note G#4 for 13 frames.
L9095:  .byte $21, $0E                   ;Play note A4  for 14 frames.
L9097:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L9099:  .byte $21, $1B                   ;Play note A4  for 27 frames.
L909B:  .byte $20, $07                   ;Play note G#4 for 7 frames.
L909D:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
L909F:  .byte $1E, $14                   ;Play note F#4 for 20 frames.
L90A1:  .byte $1E, $14                   ;Play note F#4 for 20 frames.
L90A3:  .byte $1C, $5F                   ;Play note E4  for 95 frames.
L90A5:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L90A7:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L90A9:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L90AB:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L90AD:  .byte $2A, $14                   ;Play note F#5 for 20 frames.
L90AF:  .byte $28, $14                   ;Play note E5  for 20 frames.
L90B1:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L90B3:  .byte $26, $14                   ;Play note D5  for 20 frames.
L90B5:  .byte $28, $14                   ;Play note E5  for 20 frames.
L90B7:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L90B9:  .byte $2A, $36                   ;Play note F#5 for 54 frames.
L90BB:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L90BD:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L90BF:  .byte $28, $0D                   ;Play note E5  for 13 frames.
L90C1:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L90C3:  .byte $2C, $28                   ;Play note G#5 for 40 frames.
L90C5:  .byte $29, $0E                   ;Play note F5  for 14 frames.
L90C7:  .byte $29, $36                   ;Play note F5  for 54 frames.
L90C9:  .byte $1D, $06                   ;Play note F4  for 6 frames.
L90CB:  .byte $20, $07                   ;Play note G#4 for 7 frames.
L90CD:  .byte $21, $0E                   ;Play note A4  for 14 frames.
L90CF:  .byte $20, $06                   ;Play note G#4 for 6 frames.
L90D1:  .byte $21, $07                   ;Play note A4  for 7 frames.
L90D3:  .byte $23, $0E                   ;Play note B4  for 14 frames.
L90D5:  .byte $25, $06                   ;Play note C#5 for 6 frames.
L90D7:  .byte $23, $07                   ;Play note B4  for 7 frames.
L90D9:  .byte $21, $07                   ;Play note A4  for 7 frames.
L90DB:  .byte $20, $07                   ;Play note G#4 for 7 frames.
L90DD:  .byte $1E, $06                   ;Play note F#4 for 6 frames.
L90DF:  .byte $1D, $07                   ;Play note F4  for 7 frames.
L90E1:  .byte $1A, $07                   ;Play note D4  for 7 frames.
L90E3:  .byte $19, $07                   ;Play note C#4 for 7 frames.
L90E5:  .byte $21, $14                   ;Play note A4  for 20 frames.
L90E7:  .byte $23, $14                   ;Play note B4  for 20 frames.
L90E9:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
L90EB:  .byte $21, $14                   ;Play note A4  for 20 frames.
L90ED:  .byte $23, $07                   ;Play note B4  for 7 frames.
L90EF:  .byte $23, $1B                   ;Play note B4  for 27 frames.
L90F1:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L90F3:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
L90F5:  .byte $20, $0D                   ;Play note G#4 for 13 frames.
L90F7:  .byte $21, $0E                   ;Play note A4  for 14 frames.
L90F9:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L90FB:  .byte $21, $1B                   ;Play note A4  for 27 frames.
L90FD:  .byte $20, $07                   ;Play note G#4 for 7 frames.
L90FF:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
L9101:  .byte $1E, $14                   ;Play note F#4 for 20 frames.
L9103:  .byte $1E, $14                   ;Play note F#4 for 20 frames.
L9105:  .byte $1C, $5F                   ;Play note E4  for 95 frames.
L9107:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9109:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L910B:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L910D:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L910F:  .byte $2A, $14                   ;Play note F#5 for 20 frames.
L9111:  .byte $28, $14                   ;Play note E5  for 20 frames.
L9113:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L9115:  .byte $26, $14                   ;Play note D5  for 20 frames.
L9117:  .byte $28, $14                   ;Play note E5  for 20 frames.
L9119:  .byte $2A, $0E                   ;Play note F#5 for 14 frames.
L911B:  .byte $2A, $36                   ;Play note F#5 for 54 frames.
L911D:  .byte $2A, $14                   ;Play note F#5 for 20 frames.
L911F:  .byte $2C, $14                   ;Play note G#5 for 20 frames.
L9121:  .byte $26, $0E                   ;Play note D5  for 14 frames.
L9123:  .byte $29, $36                   ;Play note F5  for 54 frames.
L9125:  .byte $29, $14                   ;Play note F5  for 20 frames.
L9127:  .byte $2C, $14                   ;Play note G#5 for 20 frames.
L9129:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L912B:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L912D:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L912F:  .byte $23, $0D                   ;Play note B4  for 13 frames.
L9131:  .byte $25, $0E                   ;Play note C#5 for 14 frames.
L9133:  .byte $20, $06                   ;Play note G#4 for 6 frames.
L9135:  .byte $21, $07                   ;Play note A4  for 7 frames.
L9137:  .byte $23, $0E                   ;Play note B4  for 14 frames.
L9139:  .byte $1D, $06                   ;Play note F4  for 6 frames.
L913B:  .byte $1E, $07                   ;Play note F#4 for 7 frames.
L913D:  .byte $20, $0E                   ;Play note G#4 for 14 frames.
L913F:  .byte $20, $1B                   ;Play note G#4 for 27 frames.
L9141:  .byte $20, $0D                   ;Play note G#4 for 13 frames.
L9143:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
L9145:  .byte $1E, $0D                   ;Play note F#4 for 13 frames.
L9147:  .byte $1E, $1B                   ;Play note F#4 for 27 frames.
L9149:  .byte $1A, $0E                   ;Play note D4  for 14 frames.
L914B:  .byte $20, $1B                   ;Play note G#4 for 27 frames.
L914D:  .byte $20, $0D                   ;Play note G#4 for 13 frames.
L914F:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
L9151:  .byte $1E, $0D                   ;Play note F#4 for 13 frames.
L9153:  .byte $1E, $1B                   ;Play note F#4 for 27 frames.
L9155:  .byte $1A, $0E                   ;Play note D4  for 14 frames.
L9157:  .byte $20, $1B                   ;Play note G#4 for 27 frames.
L9159:  .byte $20, $0D                   ;Play note G#4 for 13 frames.
L915B:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
L915D:  .byte $22, $0D                   ;Play note A#4 for 13 frames.
L915F:  .byte $22, $1B                   ;Play note A#4 for 27 frames.
L9161:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
L9163:  .byte $20, $1B                   ;Play note G#4 for 27 frames.
L9165:  .byte $20, $0D                   ;Play note G#4 for 13 frames.
L9167:  .byte $1C, $0E                   ;Play note E4  for 14 frames.
L9169:  .byte $22, $0D                   ;Play note A#4 for 13 frames.
L916B:  .byte $22, $1B                   ;Play note A#4 for 27 frames.
L916D:  .byte $1E, $0E                   ;Play note F#4 for 14 frames.
L916F:  .byte CHN_JUMP, $00, $98, $FA    ;Jump back 1384 bytes to $8C07.

;----------------------------------------------------------------------------------------------------

;Character creation music triangle data.

ChrCreateTri:
L9173:  .byte CHN_VOLUME, $0F            ;Set channel volume to 15.
L9175:  .byte CHN_VIBRATO, $00, $08, $18 ;Set vibrato speed=8, intensity=24.
L9179:  .byte CHN_ASR, $34               ;Set ASR data index to 02.
L917B:  .byte $09, $1B                   ;Play note A1  for 27 frames.
L917D:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L917F:  .byte $10, $0E                   ;Play note E2  for 14 frames.
L9181:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9183:  .byte $08, $0E                   ;Play note G#1 for 14 frames.
L9185:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9187:  .byte $10, $0E                   ;Play note E2  for 14 frames.
L9189:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L918B:  .byte $12, $0E                   ;Play note F#2 for 14 frames.
L918D:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L918F:  .byte $0B, $0E                   ;Play note B1  for 14 frames.
L9191:  .byte $09, $1B                   ;Play note A1  for 27 frames.
L9193:  .byte $08, $1B                   ;Play note G#1 for 27 frames.
L9195:  .byte $09, $1B                   ;Play note A1  for 27 frames.
L9197:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9199:  .byte $10, $0E                   ;Play note E2  for 14 frames.
L919B:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L919D:  .byte $08, $0E                   ;Play note G#1 for 14 frames.
L919F:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L91A1:  .byte $10, $0E                   ;Play note E2  for 14 frames.
L91A3:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L91A5:  .byte $12, $0E                   ;Play note F#2 for 14 frames.
L91A7:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L91A9:  .byte $0B, $0E                   ;Play note B1  for 14 frames.
L91AB:  .byte $09, $1B                   ;Play note A1  for 27 frames.
L91AD:  .byte $08, $1B                   ;Play note G#1 for 27 frames.
L91AF:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L91B1:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L91B3:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L91B5:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L91B7:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L91B9:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L91BB:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L91BD:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L91BF:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L91C1:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L91C3:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L91C5:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L91C7:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L91C9:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L91CB:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L91CD:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L91CF:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L91D1:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L91D3:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L91D5:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L91D7:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L91D9:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L91DB:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L91DD:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L91DF:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L91E1:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L91E3:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L91E5:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L91E7:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L91E9:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L91EB:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L91ED:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L91EF:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L91F1:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L91F3:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L91F5:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L91F7:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L91F9:  .byte $06, $0D                   ;Play note F#1 for 13 frames.
L91FB:  .byte $04, $0E                   ;Play note E1  for 14 frames.
L91FD:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L91FF:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9201:  .byte $04, $0E                   ;Play note E1  for 14 frames.
L9203:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9205:  .byte $04, $0E                   ;Play note E1  for 14 frames.
L9207:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9209:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L920B:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L920D:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L920F:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9211:  .byte $0B, $0E                   ;Play note B1  for 14 frames.
L9213:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9215:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L9217:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9219:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L921B:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L921D:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L921F:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L9221:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9223:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9225:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L9227:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9229:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L922B:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L922D:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L922F:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L9231:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9233:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9235:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9237:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9239:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L923B:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L923D:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L923F:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L9241:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9243:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9245:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L9247:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9249:  .byte $08, $0E                   ;Play note G#1 for 14 frames.
L924B:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L924D:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L924F:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L9251:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9253:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L9255:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9257:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9259:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L925B:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L925D:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L925F:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L9261:  .byte $06, $0D                   ;Play note F#1 for 13 frames.
L9263:  .byte $04, $0E                   ;Play note E1  for 14 frames.
L9265:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9267:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9269:  .byte $04, $0E                   ;Play note E1  for 14 frames.
L926B:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L926D:  .byte $04, $0E                   ;Play note E1  for 14 frames.
L926F:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9271:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9273:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L9275:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9277:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9279:  .byte $0B, $0E                   ;Play note B1  for 14 frames.
L927B:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L927D:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L927F:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9281:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9283:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L9285:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9287:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L9289:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L928B:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L928D:  .byte $0E, $1B                   ;Play note D2  for 27 frames.
L928F:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9291:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9293:  .byte $0E, $1B                   ;Play note D2  for 27 frames.
L9295:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9297:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9299:  .byte $0E, $1B                   ;Play note D2  for 27 frames.
L929B:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L929D:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L929F:  .byte $0E, $1B                   ;Play note D2  for 27 frames.
L92A1:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L92A3:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L92A5:  .byte $0D, $1B                   ;Play note C#2 for 27 frames.
L92A7:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L92A9:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L92AB:  .byte $0D, $1B                   ;Play note C#2 for 27 frames.
L92AD:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L92AF:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L92B1:  .byte $0D, $1B                   ;Play note C#2 for 27 frames.
L92B3:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L92B5:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L92B7:  .byte $0D, $1B                   ;Play note C#2 for 27 frames.
L92B9:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L92BB:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L92BD:  .byte $1A, $0E                   ;Play note D3  for 14 frames.
L92BF:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L92C1:  .byte $17, $0E                   ;Play note B2  for 14 frames.
L92C3:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L92C5:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L92C7:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L92C9:  .byte $17, $0E                   ;Play note B2  for 14 frames.
L92CB:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L92CD:  .byte $1A, $0E                   ;Play note D3  for 14 frames.
L92CF:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L92D1:  .byte $17, $0E                   ;Play note B2  for 14 frames.
L92D3:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L92D5:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L92D7:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L92D9:  .byte $17, $0E                   ;Play note B2  for 14 frames.
L92DB:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L92DD:  .byte $19, $0E                   ;Play note C#3 for 14 frames.
L92DF:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L92E1:  .byte $17, $0E                   ;Play note B2  for 14 frames.
L92E3:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L92E5:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L92E7:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L92E9:  .byte $17, $0E                   ;Play note B2  for 14 frames.
L92EB:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L92ED:  .byte $19, $0E                   ;Play note C#3 for 14 frames.
L92EF:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L92F1:  .byte $17, $0E                   ;Play note B2  for 14 frames.
L92F3:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L92F5:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L92F7:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L92F9:  .byte $17, $0E                   ;Play note B2  for 14 frames.
L92FB:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L92FD:  .byte $17, $0E                   ;Play note B2  for 14 frames.
L92FF:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9301:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L9303:  .byte $08, $0D                   ;Play note G#1 for 13 frames.
L9305:  .byte $12, $0E                   ;Play note F#2 for 14 frames.
L9307:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9309:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L930B:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L930D:  .byte $17, $0E                   ;Play note B2  for 14 frames.
L930F:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9311:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L9313:  .byte $08, $0D                   ;Play note G#1 for 13 frames.
L9315:  .byte $12, $0E                   ;Play note F#2 for 14 frames.
L9317:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9319:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L931B:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L931D:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L931F:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9321:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L9323:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9325:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L9327:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9329:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L932B:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L932D:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L932F:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9331:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L9333:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9335:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L9337:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9339:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L933B:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L933D:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L933F:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9341:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9343:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9345:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9347:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9349:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L934B:  .byte $09, $28                   ;Play note A1  for 40 frames.
L934D:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L934F:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9351:  .byte $0D, $29                   ;Play note C#2 for 41 frames.
L9353:  .byte $06, $0D                   ;Play note F#1 for 13 frames.
L9355:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9357:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L9359:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L935B:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L935D:  .byte $08, $07                   ;Play note G#1 for 7 frames.
L935F:  .byte $09, $06                   ;Play note A1  for 6 frames.
L9361:  .byte $08, $07                   ;Play note G#1 for 7 frames.
L9363:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L9365:  .byte $04, $07                   ;Play note E1  for 7 frames.
L9367:  .byte $08, $0D                   ;Play note G#1 for 13 frames.
L9369:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L936B:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L936D:  .byte $08, $0E                   ;Play note G#1 for 14 frames.
L936F:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9371:  .byte $12, $07                   ;Play note F#2 for 7 frames.
L9373:  .byte $14, $07                   ;Play note G#2 for 7 frames.
L9375:  .byte $15, $06                   ;Play note A2  for 6 frames.
L9377:  .byte $14, $07                   ;Play note G#2 for 7 frames.
L9379:  .byte $12, $07                   ;Play note F#2 for 7 frames.
L937B:  .byte $10, $07                   ;Play note E2  for 7 frames.
L937D:  .byte $04, $0D                   ;Play note E1  for 13 frames.
L937F:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L9381:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9383:  .byte $04, $0E                   ;Play note E1  for 14 frames.
L9385:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9387:  .byte $04, $07                   ;Play note E1  for 7 frames.
L9389:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L938B:  .byte $08, $06                   ;Play note G#1 for 6 frames.
L938D:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L938F:  .byte $04, $07                   ;Play note E1  for 7 frames.
L9391:  .byte $0B, $07                   ;Play note B1  for 7 frames.
L9393:  .byte $04, $0D                   ;Play note E1  for 13 frames.
L9395:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L9397:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9399:  .byte $04, $0E                   ;Play note E1  for 14 frames.
L939B:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L939D:  .byte $10, $07                   ;Play note E2  for 7 frames.
L939F:  .byte $12, $07                   ;Play note F#2 for 7 frames.
L93A1:  .byte $14, $06                   ;Play note G#2 for 6 frames.
L93A3:  .byte $12, $07                   ;Play note F#2 for 7 frames.
L93A5:  .byte $10, $07                   ;Play note E2  for 7 frames.
L93A7:  .byte $17, $07                   ;Play note B2  for 7 frames.
L93A9:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L93AB:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L93AD:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L93AF:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L93B1:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L93B3:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L93B5:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L93B7:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L93B9:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L93BB:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L93BD:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L93BF:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L93C1:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L93C3:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L93C5:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L93C7:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L93C9:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L93CB:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L93CD:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L93CF:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L93D1:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L93D3:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L93D5:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L93D7:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L93D9:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L93DB:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L93DD:  .byte $0B, $07                   ;Play note B1  for 7 frames.
L93DF:  .byte $08, $07                   ;Play note G#1 for 7 frames.
L93E1:  .byte $0D, $06                   ;Play note C#2 for 6 frames.
L93E3:  .byte $08, $07                   ;Play note G#1 for 7 frames.
L93E5:  .byte $0B, $07                   ;Play note B1  for 7 frames.
L93E7:  .byte $08, $07                   ;Play note G#1 for 7 frames.
L93E9:  .byte $06, $0D                   ;Play note F#1 for 13 frames.
L93EB:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L93ED:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L93EF:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L93F1:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L93F3:  .byte $08, $07                   ;Play note G#1 for 7 frames.
L93F5:  .byte $09, $06                   ;Play note A1  for 6 frames.
L93F7:  .byte $08, $07                   ;Play note G#1 for 7 frames.
L93F9:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L93FB:  .byte $04, $07                   ;Play note E1  for 7 frames.
L93FD:  .byte $08, $0D                   ;Play note G#1 for 13 frames.
L93FF:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L9401:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9403:  .byte $08, $0E                   ;Play note G#1 for 14 frames.
L9405:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9407:  .byte $12, $07                   ;Play note F#2 for 7 frames.
L9409:  .byte $14, $07                   ;Play note G#2 for 7 frames.
L940B:  .byte $15, $06                   ;Play note A2  for 6 frames.
L940D:  .byte $14, $07                   ;Play note G#2 for 7 frames.
L940F:  .byte $12, $07                   ;Play note F#2 for 7 frames.
L9411:  .byte $10, $07                   ;Play note E2  for 7 frames.
L9413:  .byte $04, $0D                   ;Play note E1  for 13 frames.
L9415:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L9417:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9419:  .byte $04, $0E                   ;Play note E1  for 14 frames.
L941B:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L941D:  .byte $04, $07                   ;Play note E1  for 7 frames.
L941F:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L9421:  .byte $08, $06                   ;Play note G#1 for 6 frames.
L9423:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L9425:  .byte $04, $07                   ;Play note E1  for 7 frames.
L9427:  .byte $0B, $07                   ;Play note B1  for 7 frames.
L9429:  .byte $04, $0D                   ;Play note E1  for 13 frames.
L942B:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L942D:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L942F:  .byte $04, $0E                   ;Play note E1  for 14 frames.
L9431:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9433:  .byte $10, $07                   ;Play note E2  for 7 frames.
L9435:  .byte $12, $07                   ;Play note F#2 for 7 frames.
L9437:  .byte $14, $06                   ;Play note G#2 for 6 frames.
L9439:  .byte $12, $07                   ;Play note F#2 for 7 frames.
L943B:  .byte $10, $07                   ;Play note E2  for 7 frames.
L943D:  .byte $17, $07                   ;Play note B2  for 7 frames.
L943F:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9441:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L9443:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9445:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9447:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9449:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L944B:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L944D:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L944F:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L9451:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9453:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9455:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9457:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9459:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L945B:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L945D:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L945F:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9461:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L9463:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9465:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L9467:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9469:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L946B:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L946D:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L946F:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L9471:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9473:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L9475:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9477:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9479:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L947B:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L947D:  .byte $0E, $1B                   ;Play note D2  for 27 frames.
L947F:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9481:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9483:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9485:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9487:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9489:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L948B:  .byte $0E, $1B                   ;Play note D2  for 27 frames.
L948D:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L948F:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9491:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9493:  .byte $06, $0D                   ;Play note F#1 for 13 frames.
L9495:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L9497:  .byte $06, $0D                   ;Play note F#1 for 13 frames.
L9499:  .byte $06, $1B                   ;Play note F#1 for 27 frames.
L949B:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L949D:  .byte $06, $0D                   ;Play note F#1 for 13 frames.
L949F:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L94A1:  .byte $06, $0D                   ;Play note F#1 for 13 frames.
L94A3:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L94A5:  .byte $06, $0D                   ;Play note F#1 for 13 frames.
L94A7:  .byte $06, $1B                   ;Play note F#1 for 27 frames.
L94A9:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L94AB:  .byte $06, $0D                   ;Play note F#1 for 13 frames.
L94AD:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L94AF:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L94B1:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L94B3:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L94B5:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L94B7:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L94B9:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L94BB:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L94BD:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L94BF:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L94C1:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L94C3:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L94C5:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L94C7:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L94C9:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L94CB:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L94CD:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L94CF:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L94D1:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L94D3:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L94D5:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L94D7:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L94D9:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L94DB:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L94DD:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L94DF:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L94E1:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L94E3:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L94E5:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L94E7:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L94E9:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L94EB:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L94ED:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L94EF:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L94F1:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L94F3:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L94F5:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L94F7:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L94F9:  .byte $06, $0D                   ;Play note F#1 for 13 frames.
L94FB:  .byte $04, $0E                   ;Play note E1  for 14 frames.
L94FD:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L94FF:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9501:  .byte $04, $0E                   ;Play note E1  for 14 frames.
L9503:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9505:  .byte $04, $0E                   ;Play note E1  for 14 frames.
L9507:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9509:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L950B:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L950D:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L950F:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9511:  .byte $0B, $0E                   ;Play note B1  for 14 frames.
L9513:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9515:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L9517:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9519:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L951B:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L951D:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L951F:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L9521:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9523:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9525:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L9527:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9529:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L952B:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L952D:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L952F:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L9531:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9533:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9535:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9537:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9539:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L953B:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L953D:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L953F:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L9541:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9543:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9545:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L9547:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9549:  .byte $08, $0E                   ;Play note G#1 for 14 frames.
L954B:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L954D:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L954F:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L9551:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9553:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L9555:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9557:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9559:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L955B:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L955D:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L955F:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L9561:  .byte $06, $0D                   ;Play note F#1 for 13 frames.
L9563:  .byte $04, $0E                   ;Play note E1  for 14 frames.
L9565:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9567:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9569:  .byte $04, $0E                   ;Play note E1  for 14 frames.
L956B:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L956D:  .byte $04, $0E                   ;Play note E1  for 14 frames.
L956F:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9571:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L9573:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L9575:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9577:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9579:  .byte $0B, $0E                   ;Play note B1  for 14 frames.
L957B:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L957D:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L957F:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9581:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9583:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L9585:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9587:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L9589:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L958B:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L958D:  .byte $0E, $1B                   ;Play note D2  for 27 frames.
L958F:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9591:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9593:  .byte $0E, $1B                   ;Play note D2  for 27 frames.
L9595:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9597:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9599:  .byte $0E, $1B                   ;Play note D2  for 27 frames.
L959B:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L959D:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L959F:  .byte $0E, $1B                   ;Play note D2  for 27 frames.
L95A1:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L95A3:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L95A5:  .byte $0D, $1B                   ;Play note C#2 for 27 frames.
L95A7:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L95A9:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L95AB:  .byte $0D, $1B                   ;Play note C#2 for 27 frames.
L95AD:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L95AF:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L95B1:  .byte $0D, $1B                   ;Play note C#2 for 27 frames.
L95B3:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L95B5:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L95B7:  .byte $0D, $1B                   ;Play note C#2 for 27 frames.
L95B9:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L95BB:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L95BD:  .byte $1A, $0E                   ;Play note D3  for 14 frames.
L95BF:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L95C1:  .byte $17, $0E                   ;Play note B2  for 14 frames.
L95C3:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L95C5:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L95C7:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L95C9:  .byte $17, $0E                   ;Play note B2  for 14 frames.
L95CB:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L95CD:  .byte $1A, $0E                   ;Play note D3  for 14 frames.
L95CF:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L95D1:  .byte $17, $0E                   ;Play note B2  for 14 frames.
L95D3:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L95D5:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L95D7:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L95D9:  .byte $17, $0E                   ;Play note B2  for 14 frames.
L95DB:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L95DD:  .byte $19, $0E                   ;Play note C#3 for 14 frames.
L95DF:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L95E1:  .byte $17, $0E                   ;Play note B2  for 14 frames.
L95E3:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L95E5:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L95E7:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L95E9:  .byte $17, $0E                   ;Play note B2  for 14 frames.
L95EB:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L95ED:  .byte $19, $0E                   ;Play note C#3 for 14 frames.
L95EF:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L95F1:  .byte $17, $0E                   ;Play note B2  for 14 frames.
L95F3:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L95F5:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L95F7:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L95F9:  .byte $17, $0E                   ;Play note B2  for 14 frames.
L95FB:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L95FD:  .byte $17, $0E                   ;Play note B2  for 14 frames.
L95FF:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9601:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L9603:  .byte $08, $0D                   ;Play note G#1 for 13 frames.
L9605:  .byte $12, $0E                   ;Play note F#2 for 14 frames.
L9607:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9609:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L960B:  .byte $0B, $0D                   ;Play note B1  for 13 frames.
L960D:  .byte $17, $0E                   ;Play note B2  for 14 frames.
L960F:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9611:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L9613:  .byte $08, $0D                   ;Play note G#1 for 13 frames.
L9615:  .byte $12, $0E                   ;Play note F#2 for 14 frames.
L9617:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9619:  .byte $15, $0E                   ;Play note A2  for 14 frames.
L961B:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L961D:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L961F:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9621:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L9623:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9625:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L9627:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9629:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L962B:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L962D:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L962F:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9631:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L9633:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9635:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L9637:  .byte $09, $0D                   ;Play note A1  for 13 frames.
L9639:  .byte $09, $0E                   ;Play note A1  for 14 frames.
L963B:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L963D:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L963F:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9641:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9643:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9645:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9647:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9649:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L964B:  .byte $09, $28                   ;Play note A1  for 40 frames.
L964D:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L964F:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9651:  .byte $0D, $29                   ;Play note C#2 for 41 frames.
L9653:  .byte $06, $0D                   ;Play note F#1 for 13 frames.
L9655:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9657:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L9659:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L965B:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L965D:  .byte $08, $07                   ;Play note G#1 for 7 frames.
L965F:  .byte $09, $06                   ;Play note A1  for 6 frames.
L9661:  .byte $08, $07                   ;Play note G#1 for 7 frames.
L9663:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L9665:  .byte $04, $07                   ;Play note E1  for 7 frames.
L9667:  .byte $08, $0D                   ;Play note G#1 for 13 frames.
L9669:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L966B:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L966D:  .byte $08, $0E                   ;Play note G#1 for 14 frames.
L966F:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9671:  .byte $12, $07                   ;Play note F#2 for 7 frames.
L9673:  .byte $14, $07                   ;Play note G#2 for 7 frames.
L9675:  .byte $15, $06                   ;Play note A2  for 6 frames.
L9677:  .byte $14, $07                   ;Play note G#2 for 7 frames.
L9679:  .byte $12, $07                   ;Play note F#2 for 7 frames.
L967B:  .byte $10, $07                   ;Play note E2  for 7 frames.
L967D:  .byte $04, $0D                   ;Play note E1  for 13 frames.
L967F:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L9681:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9683:  .byte $04, $0E                   ;Play note E1  for 14 frames.
L9685:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9687:  .byte $04, $07                   ;Play note E1  for 7 frames.
L9689:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L968B:  .byte $08, $06                   ;Play note G#1 for 6 frames.
L968D:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L968F:  .byte $04, $07                   ;Play note E1  for 7 frames.
L9691:  .byte $0B, $07                   ;Play note B1  for 7 frames.
L9693:  .byte $04, $0D                   ;Play note E1  for 13 frames.
L9695:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L9697:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9699:  .byte $04, $0E                   ;Play note E1  for 14 frames.
L969B:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L969D:  .byte $10, $07                   ;Play note E2  for 7 frames.
L969F:  .byte $12, $07                   ;Play note F#2 for 7 frames.
L96A1:  .byte $14, $06                   ;Play note G#2 for 6 frames.
L96A3:  .byte $12, $07                   ;Play note F#2 for 7 frames.
L96A5:  .byte $10, $07                   ;Play note E2  for 7 frames.
L96A7:  .byte $17, $07                   ;Play note B2  for 7 frames.
L96A9:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L96AB:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L96AD:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L96AF:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L96B1:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L96B3:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L96B5:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L96B7:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L96B9:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L96BB:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L96BD:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L96BF:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L96C1:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L96C3:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L96C5:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L96C7:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L96C9:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L96CB:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L96CD:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L96CF:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L96D1:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L96D3:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L96D5:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L96D7:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L96D9:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L96DB:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L96DD:  .byte $0B, $07                   ;Play note B1  for 7 frames.
L96DF:  .byte $08, $07                   ;Play note G#1 for 7 frames.
L96E1:  .byte $0D, $06                   ;Play note C#2 for 6 frames.
L96E3:  .byte $08, $07                   ;Play note G#1 for 7 frames.
L96E5:  .byte $0B, $07                   ;Play note B1  for 7 frames.
L96E7:  .byte $08, $07                   ;Play note G#1 for 7 frames.
L96E9:  .byte $06, $0D                   ;Play note F#1 for 13 frames.
L96EB:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L96ED:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L96EF:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L96F1:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L96F3:  .byte $08, $07                   ;Play note G#1 for 7 frames.
L96F5:  .byte $09, $06                   ;Play note A1  for 6 frames.
L96F7:  .byte $08, $07                   ;Play note G#1 for 7 frames.
L96F9:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L96FB:  .byte $04, $07                   ;Play note E1  for 7 frames.
L96FD:  .byte $08, $0D                   ;Play note G#1 for 13 frames.
L96FF:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L9701:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9703:  .byte $08, $0E                   ;Play note G#1 for 14 frames.
L9705:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9707:  .byte $12, $07                   ;Play note F#2 for 7 frames.
L9709:  .byte $14, $07                   ;Play note G#2 for 7 frames.
L970B:  .byte $15, $06                   ;Play note A2  for 6 frames.
L970D:  .byte $14, $07                   ;Play note G#2 for 7 frames.
L970F:  .byte $12, $07                   ;Play note F#2 for 7 frames.
L9711:  .byte $10, $07                   ;Play note E2  for 7 frames.
L9713:  .byte $04, $0D                   ;Play note E1  for 13 frames.
L9715:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L9717:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9719:  .byte $04, $0E                   ;Play note E1  for 14 frames.
L971B:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L971D:  .byte $04, $07                   ;Play note E1  for 7 frames.
L971F:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L9721:  .byte $08, $06                   ;Play note G#1 for 6 frames.
L9723:  .byte $06, $07                   ;Play note F#1 for 7 frames.
L9725:  .byte $04, $07                   ;Play note E1  for 7 frames.
L9727:  .byte $0B, $07                   ;Play note B1  for 7 frames.
L9729:  .byte $04, $0D                   ;Play note E1  for 13 frames.
L972B:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L972D:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L972F:  .byte $04, $0E                   ;Play note E1  for 14 frames.
L9731:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9733:  .byte $10, $07                   ;Play note E2  for 7 frames.
L9735:  .byte $12, $07                   ;Play note F#2 for 7 frames.
L9737:  .byte $14, $06                   ;Play note G#2 for 6 frames.
L9739:  .byte $12, $07                   ;Play note F#2 for 7 frames.
L973B:  .byte $10, $07                   ;Play note E2  for 7 frames.
L973D:  .byte $17, $07                   ;Play note B2  for 7 frames.
L973F:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9741:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L9743:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9745:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9747:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9749:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L974B:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L974D:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L974F:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L9751:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9753:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9755:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9757:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9759:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L975B:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L975D:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L975F:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9761:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L9763:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9765:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L9767:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9769:  .byte $0D, $0D                   ;Play note C#2 for 13 frames.
L976B:  .byte CHN_SILENCE, $0E           ;Silence channel for 14 frames.
L976D:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L976F:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L9771:  .byte CHN_SILENCE, $0D           ;Silence channel for 13 frames.
L9773:  .byte $0D, $0E                   ;Play note C#2 for 14 frames.
L9775:  .byte CHN_SILENCE, $1B           ;Silence channel for 27 frames.
L9777:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9779:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L977B:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L977D:  .byte $0E, $1B                   ;Play note D2  for 27 frames.
L977F:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9781:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9783:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9785:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9787:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9789:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L978B:  .byte $0E, $1B                   ;Play note D2  for 27 frames.
L978D:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L978F:  .byte $0E, $0D                   ;Play note D2  for 13 frames.
L9791:  .byte $0E, $0E                   ;Play note D2  for 14 frames.
L9793:  .byte $06, $0D                   ;Play note F#1 for 13 frames.
L9795:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L9797:  .byte $06, $0D                   ;Play note F#1 for 13 frames.
L9799:  .byte $06, $1B                   ;Play note F#1 for 27 frames.
L979B:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L979D:  .byte $06, $0D                   ;Play note F#1 for 13 frames.
L979F:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L97A1:  .byte $06, $0D                   ;Play note F#1 for 13 frames.
L97A3:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L97A5:  .byte $06, $0D                   ;Play note F#1 for 13 frames.
L97A7:  .byte $06, $1B                   ;Play note F#1 for 27 frames.
L97A9:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L97AB:  .byte $06, $0D                   ;Play note F#1 for 13 frames.
L97AD:  .byte $06, $0E                   ;Play note F#1 for 14 frames.
L97AF:  .byte CHN_JUMP, $00, $C4, $F9    ;Jump back 1596 bytes to $9173.

;----------------------------------------------------------------------------------------------------

;Silver horn music SQ1 data.

SQ1Attack0A:
L97B3:  .byte $04, $84, $88, $8C, $90

SQ1Sustain0A:
L97B8:  .byte $23, $8E, $8C, $89, $8C, $8E, $8E, $8C, $89, $8C, $8E, $8E, $8C, $89, $8C, $8E
L97C8:  .byte $8E, $8C, $89, $8C, $8E, $8E, $8C, $89, $8C, $8E, $8E, $8C, $89, $8C, $8E, $8E
L97D8:  .byte $8C, $89, $8C, $8E

SQ1Release0A:
L97DC:  .byte $08, $8C, $8A, $88, $88, $86, $86, $84, $82, $82

;----------------------------------------------------------------------------------------------------

;Silver horn music SQ2 data.

SQ2Attack0B:
L97E6:  .byte $04, $84, $88, $8C, $90

SQ2Sustain0B:
L97EB:  .byte $1E, $8E, $8C, $8A, $8A, $8C, $8E, $8C, $8A, $8A, $8C, $8E, $8C, $8A, $8A, $8C
L97FB:  .byte $8E, $8C, $8A, $8A, $8C, $8E, $8C, $8A, $8A, $8C, $8E, $8C, $8A, $8A, $8C

SQ2Release0B:
L980A:  .byte $08, $8C, $8A, $88, $88, $86, $86, $84, $82, $82

;----------------------------------------------------------------------------------------------------

;Unused music SQ1 data.

SQ1Attack0C:
L9814:  .byte $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

SQ1Sustain0C:
L981D:  .byte $18, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
L982D:  .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

SQ1Release0C:
L9836:  .byte $08, $0F, $0F, $0F, $0F, $0F, $00, $00, $00, $00

;----------------------------------------------------------------------------------------------------

;Silver horn music SQ1 data.

SlvrHornSQ1:
L9840:  .byte CHN_VOLUME, $0E            ;Set channel volume to 14.
L9842:  .byte CHN_VIBRATO, $00, $0F, $18 ;Set vibrato speed=15, intensity=24.
L9846:  .byte CHN_ASR, $3C               ;Set ASR data index to 10.
L9848:  .byte $24, $30                   ;Play note C5  for 48 frames.
L984A:  .byte $27, $30                   ;Play note D#5 for 48 frames.
L984C:  .byte $29, $20                   ;Play note F5  for 32 frames.
L984E:  .byte $27, $30                   ;Play note D#5 for 48 frames.
L9850:  .byte $24, $10                   ;Play note C5  for 16 frames.
L9852:  .byte CHN_SILENCE, $40           ;Silence channel for 64 frames.
L9854:  .byte CHN_SILENCE, $40           ;Silence channel for 64 frames.
L9856:  .byte CHN_JUMP, $00, $FE, $FF    ;Jump back 2 bytes to $9854.

;----------------------------------------------------------------------------------------------------

;Silver horn music SQ2 data.

SlvrHornSQ2:
L985A:  .byte CHN_VOLUME, $0E            ;Set channel volume to 14.
L985C:  .byte CHN_VIBRATO, $00, $1D, $12 ;Set vibrato speed=29, intensity=18.
L9860:  .byte CHN_ASR, $3D               ;Set ASR data index to 11.
L9862:  .byte $24, $30                   ;Play note C5  for 48 frames.
L9864:  .byte $27, $30                   ;Play note D#5 for 48 frames.
L9866:  .byte $29, $20                   ;Play note F5  for 32 frames.
L9868:  .byte $27, $30                   ;Play note D#5 for 48 frames.
L986A:  .byte $24, $10                   ;Play note C5  for 16 frames.
L986C:  .byte CHN_SILENCE, $40           ;Silence channel for 64 frames.
L986E:  .byte CHN_SILENCE, $40           ;Silence channel for 64 frames.
L9870:  .byte CHN_JUMP, $00, $FE, $FF    ;Jump back 2 bytes to $986E.

;----------------------------------------------------------------------------------------------------

;Unused music SQ1 data.

UnusedSQ1:
L9874:  .byte CHN_VOLUME, $0F            ;Set channel volume to 15.
L9876:  .byte CHN_VIBRATO, $00, $10, $10 ;Set vibrato speed=16, intensity=16.
L987A:  .byte CHN_ASR, $3E               ;Set ASR data index to 12.
L987C:  .byte $18, $30                   ;Play note C4  for 48 frames.
L987E:  .byte $1B, $30                   ;Play note D#4 for 48 frames.
L9880:  .byte $1D, $20                   ;Play note F4  for 32 frames.
L9882:  .byte $1B, $30                   ;Play note D#4 for 48 frames.
L9884:  .byte $18, $10                   ;Play note C4  for 16 frames.
L9886:  .byte CHN_SILENCE, $40           ;Silence channel for 64 frames.
L9888:  .byte CHN_SILENCE, $40           ;Silence channel for 64 frames.
L988A:  .byte CHN_JUMP, $00, $FE, $FF    ;Jump back 2 bytes to $9888.

;----------------------------------------------------------------------------------------------------

;Used by Exodus heartbeat music SQ1 and SQ2.

SQ12Attack07:
L988E:  .byte $04, $86, $89, $8C, $90

SQ12Sustain07:
L9893:  .byte $04, $90, $8E, $90, $8E

SQ12Release07:
L9898:  .byte $0C, $8D, $89, $87, $86, $86, $85, $85, $84, $84, $83, $83, $82

;----------------------------------------------------------------------------------------------------

;Used by Exodus heartbeat music triangle.

TriAttack08:
L98A5:  .byte $09, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

TriSustain08:
L98AF:  .byte $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

TriRelease08:
L98B8:  .byte $02, $0F, $0F

;----------------------------------------------------------------------------------------------------

;Used by Exodus heartbeat music noise.

NseAttack09:
L98BB:  .byte $06, $08, $0C, $0F, $0D, $09, $08

NseSustain09:
L98C2:  .byte $02, $08, $08

NseRelease09:
L98C5:  .byte $0A, $07, $06, $05, $05, $04, $04, $03, $03, $02, $01, $00

;----------------------------------------------------------------------------------------------------

;Exodus Heartbeat music SQ1 data.

ExodusHBSQ1:
L98D1:  .byte CHN_VIBRATO, $00, $00, $00 ;Disable vibrato.
L98D5:  .byte CHN_ASR, $39               ;Set ASR data index to 07.
L98D7:  .byte CHN_SILENCE, $58           ;Silence channel for 88 frames.
L98D9:  .byte CHN_JUMP, $00, $FE, $FF    ;Jump back 2 bytes to $98D7.

;----------------------------------------------------------------------------------------------------

;Exodus Heartbeat music SQ2 data.

ExodusHBSQ2:
L98DD:  .byte CHN_VOLUME, $0F            ;Set channel volume to 15.
L98DF:  .byte CHN_VIBRATO, $00, $00, $00 ;Disable vibrato.
L98E3:  .byte CHN_ASR, $39               ;Set ASR data index to 07.
L98E5:  .byte CHN_SILENCE, $40           ;Silence channel for 64 frames.
L98E7:  .byte CHN_JUMP, $00, $FE, $FF    ;Jump back 2 bytes to $98E5.

;----------------------------------------------------------------------------------------------------

;Exodus Heartbeat music Triangle data.

ExodusHBTri:
L98EB:  .byte CHN_VOLUME, $08            ;Set channel volume to 8.
L98ED:  .byte CHN_VIBRATO, $00, $00, $00 ;Disable vibrato.
L98F1:  .byte CHN_ASR, $3A               ;Set ASR data index to 08.
L98F3:  .byte $02, $08                   ;Play note D1  for 8 frames.
L98F5:  .byte $04, $08                   ;Play note E1  for 8 frames.
L98F7:  .byte CHN_SILENCE, $40           ;Silence channel for 64 frames.
L98F9:  .byte CHN_JUMP, $00, $FA, $FF    ;Jump back 6 bytes to $98F3.

;----------------------------------------------------------------------------------------------------

;Exodus Heartbeat music Noise data.

ExodusHBNse:
L98FD:  .byte CHN_VOLUME, $00            ;Set channel volume to 0.
L98FF:  .byte CHN_VIBRATO, $00, $00, $00 ;Disable vibrato.
L9903:  .byte CHN_ASR, $3B               ;Set ASR data index to 09.
L9905:  .byte CHN_SILENCE, $40           ;Silence channel for 64 frames.
L9907:  .byte CHN_JUMP, $00, $FE, $FF    ;Jump back 2 bytes to $9905.

;----------------------------------------------------------------------------------------------------

;Unused music data from Bank08.
L990B:  .byte $36, $07, $FE, $0D, $3B, $06, $39, $07, $38, $06, $3B, $07, $39, $06, $38, $07
L991B:  .byte $FB, $0D, $FD, $00, $06, $40, $FC, $11, $28, $0D, $28, $0D, $26, $0D, $28, $1A
L992B:  .byte $26, $1A, $28, $1A, $28, $0D, $26, $1A, $28, $1A, $2B, $1A, $26, $0D, $26, $0D
L993B:  .byte $24, $0D, $26, $1A, $24, $1A, $26, $1A, $26, $0D, $24, $1A, $26, $1A, $28, $1A
L994B:  .byte $28, $0D, $28, $0D, $26, $0D, $28, $1A, $26, $1A, $28, $1A, $28, $0D, $26, $1A
L995B:  .byte $28, $1A, $2B, $1A, $26, $0D, $26, $0D, $24, $0D, $26, $1A, $24, $1A, $26, $1A
L996B:  .byte $26, $0D, $24, $1A, $26, $1A, $28, $1A, $29, $0D, $29, $0D, $29, $0D, $29, $0D
L997B:  .byte $29, $0D, $2B, $1A, $29, $1A, $29, $0D, $28, $1A, $26, $1A, $24, $0D, $2D, $34
L998B:  .byte $2C, $0D, $2C, $27, $2A, $0D, $2A, $27, $2A, $0D, $2A, $06, $2C, $07, $2D, $0D
L999B:  .byte $2C, $06, $2D, $07, $2F, $0D, $FF, $00, $92, $FE, $FB, $0C, $FD, $00, $03, $80
L99AB:  .byte $FC, $0F, $21, $0D, $18, $0D, $1C, $0D, $18, $0D, $21, $0D, $18, $0D, $1C, $0D
L99BB:  .byte $21, $0D, $1F, $0D, $17, $0D, $1A, $0D, $17, $0D, $1F, $0D, $17, $0D, $1A, $0D
L99CB:  .byte $1F, $0D, $1F, $0D, $18, $0D, $1C, $0D, $18, $0D, $1F, $0D, $18, $0D, $1C, $0D
L99DB:  .byte $1F, $0D, $1F, $0D, $19, $0D, $1C, $0D, $19, $0D, $1F, $0D, $19, $0D, $1C, $0D
L99EB:  .byte $1F, $0D, $21, $0D, $1A, $0D, $1D, $0D, $1A, $0D, $21, $0D, $19, $0D, $1D, $0D
L99FB:  .byte $21, $0D, $21, $0D, $18, $0D, $1D, $0D, $18, $0D, $21, $0D, $17, $0D, $1A, $0D
L9A0B:  .byte $1F, $0D, $1D, $0D, $16, $0D, $1A, $0D, $16, $0D, $1D, $0D, $16, $0D, $1A, $0D
L9A1B:  .byte $1D, $0D, $1D, $0D, $1C, $0D, $18, $0D, $1D, $0D, $1C, $0D, $18, $0D, $1D, $0D
L9A2B:  .byte $1C, $0D, $1D, $0D, $1C, $0D, $18, $0D, $1D, $0D, $1C, $0D, $18, $0D, $1D, $0D
L9A3B:  .byte $1C, $0D, $21, $0D, $20, $0D, $1C, $0D, $21, $0D, $20, $0D, $1C, $0D, $21, $0D
L9A4B:  .byte $20, $0D, $21, $0D, $20, $0D, $1C, $0D, $21, $0D, $20, $0D, $1C, $0D, $21, $0D
L9A5B:  .byte $20, $0D, $21, $0D, $18, $0D, $1C, $0D, $18, $0D, $21, $0D, $18, $0D, $1C, $0D
L9A6B:  .byte $21, $0D, $1F, $0D, $17, $0D, $1A, $0D, $17, $0D, $1F, $0D, $17, $0D, $1A, $0D
L9A7B:  .byte $1F, $0D, $1F, $0D, $18, $0D, $1C, $0D, $18, $0D, $1F, $0D, $18, $0D, $1C, $0D
L9A8B:  .byte $1F, $0D, $1F, $0D, $19, $0D, $1C, $0D, $19, $0D, $1F, $0D, $19, $0D, $1C, $0D
L9A9B:  .byte $1F, $0D, $21, $0D, $1A, $0D, $1D, $0D, $1A, $0D, $21, $0D, $19, $0D, $1D, $0D
L9AAB:  .byte $21, $0D, $21, $0D, $18, $0D, $1D, $0D, $18, $0D, $21, $0D, $17, $0D, $1A, $0D
L9ABB:  .byte $1F, $0D, $1D, $0D, $16, $0D, $1A, $0D, $16, $0D, $1D, $0D, $16, $0D, $1A, $0D
L9ACB:  .byte $1D, $0D, $1D, $0D, $1C, $0D, $18, $0D, $1D, $0D, $1C, $0D, $18, $0D, $1D, $0D
L9ADB:  .byte $1C, $0D, $1D, $0D, $1C, $0D, $18, $0D, $1D, $0D, $1C, $0D, $18, $0D, $1D, $0D
L9AEB:  .byte $1C, $0D, $21, $0D, $20, $0D, $1C, $0D, $21, $0D, $20, $0D, $1C, $0D, $21, $0D
L9AFB:  .byte $20, $0D, $21, $0D, $20, $0D, $1C, $0D, $21, $0D, $20, $0D, $1C, $0D, $21, $0D
L9B0B:  .byte $20, $0D, $FB, $0D, $FC, $12, $24, $0D, $24, $0D, $23, $0D, $24, $1A, $23, $1A
L9B1B:  .byte $24, $1A, $24, $0D, $23, $1A, $24, $1A, $28, $1A, $23, $0D, $23, $0D, $21, $0D
L9B2B:  .byte $23, $1A, $21, $1A, $23, $1A, $23, $0D, $21, $1A, $23, $1A, $24, $1A, $24, $0D
L9B3B:  .byte $24, $0D, $23, $0D, $24, $1A, $23, $1A, $24, $1A, $24, $0D, $23, $1A, $24, $1A
L9B4B:  .byte $28, $1A, $23, $0D, $23, $0D, $21, $0D, $23, $1A, $21, $1A, $23, $1A, $23, $0D
L9B5B:  .byte $21, $1A, $23, $1A, $24, $1A, $26, $0D, $26, $0D, $26, $0D, $26, $0D, $26, $0D
L9B6B:  .byte $28, $1A, $26, $1A, $26, $0D, $24, $1A, $23, $1A, $21, $0D, $28, $34, $28, $0D
L9B7B:  .byte $28, $27, $26, $0D, $26, $27, $26, $0D, $26, $06, $28, $07, $2A, $0D, $28, $06
L9B8B:  .byte $2A, $07, $2C, $0D, $FF, $00, $16, $FE, $FB, $0F, $FD, $00, $03, $80, $FC, $10
L9B9B:  .byte $09, $0D, $09, $0D, $09, $0D, $09, $0D, $09, $0D, $09, $0D, $09, $0D, $09, $0D
L9BAB:  .byte $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D
L9BBB:  .byte $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D
L9BCB:  .byte $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D
L9BDB:  .byte $0E, $0D, $0E, $0D, $0E, $0D, $0E, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D
L9BEB:  .byte $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D
L9BFB:  .byte $0A, $0D, $0A, $0D, $0A, $0D, $0A, $0D, $0A, $0D, $0A, $0D, $0A, $0D, $0A, $0D
L9C0B:  .byte $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D
L9C1B:  .byte $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D
L9C2B:  .byte $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D
L9C3B:  .byte $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D
L9C4B:  .byte $09, $0D, $09, $0D, $09, $0D, $09, $0D, $09, $0D, $09, $0D, $09, $0D, $09, $0D
L9C5B:  .byte $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D
L9C6B:  .byte $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D
L9C7B:  .byte $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D
L9C8B:  .byte $0E, $0D, $0E, $0D, $0E, $0D, $0E, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D
L9C9B:  .byte $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0B, $0D, $0B, $0D, $0B, $0D, $0B, $0D
L9CAB:  .byte $0A, $0D, $0A, $0D, $0A, $0D, $0A, $0D, $0A, $0D, $0A, $0D, $0A, $0D, $0A, $0D
L9CBB:  .byte $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D
L9CCB:  .byte $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D, $0C, $0D
L9CDB:  .byte $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D
L9CEB:  .byte $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D
L9CFB:  .byte $11, $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D
L9D0B:  .byte $11, $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D
L9D1B:  .byte $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D
L9D2B:  .byte $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D
L9D3B:  .byte $11, $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D
L9D4B:  .byte $11, $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D, $11, $0D
L9D5B:  .byte $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D
L9D6B:  .byte $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D
L9D7B:  .byte $0E, $0D, $0E, $0D, $0E, $0D, $0E, $0D, $0E, $0D, $0E, $0D, $0E, $0D, $0E, $0D
L9D8B:  .byte $0E, $0D, $0E, $0D, $0E, $0D, $0E, $0D, $0E, $0D, $0E, $0D, $0E, $0D, $10, $1A
L9D9B:  .byte $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D, $10, $0D
L9DAB:  .byte $10, $0D, $10, $0D, $10, $0D, $10, $06, $0E, $07, $0B, $0D, $10, $06, $0E, $07
L9DBB:  .byte $0B, $0D, $FF, $00, $D6, $FD, $0A, $82, $83, $84, $85, $87, $89, $8B, $8A, $8C
L9DCB:  .byte $8D, $10, $8D, $8D, $8D, $8D, $8D, $8D, $8D, $8D, $8C, $8C, $8C, $8C, $8C, $8C
L9DDB:  .byte $8C, $8C, $12, $8C, $8B, $8A, $89, $89, $88, $88, $87, $87, $86, $86, $86, $85
L9DEB:  .byte $85, $85, $84, $84, $84, $84, $0A, $82, $83, $84, $85, $87, $89, $8B, $8A, $8C
L9DFB:  .byte $8D, $10, $8D, $8D, $8D, $8D, $8D, $8D, $8D, $8D, $8C, $8C, $8C, $8C, $8C, $8C
L9E0B:  .byte $8C, $8C, $10, $8C, $8B, $8A, $89, $89, $88, $88, $87, $87, $86, $86, $86, $85
L9E1B:  .byte $85, $85, $84, $84, $84, $84, $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $10
L9E2B:  .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
L9E3B:  .byte $08, $0F, $0F, $00, $00, $00, $00, $00, $00, $00, $07, $85, $89, $8C, $8E, $90
L9E4B:  .byte $8C, $88, $01, $88, $0D, $87, $88, $88, $88, $87, $87, $87, $87, $86, $86, $86
L9E5B:  .byte $86, $85, $85, $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $20, $0F, $0F, $0F
L9E6B:  .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
L9E7B:  .byte $0F, $0F, $0F, $0F, $0F, $00, $00, $00, $00, $00, $00, $00, $00, $08, $00, $00
L9E8B:  .byte $00, $00, $00, $00, $00, $00, $00, $07, $85, $89, $8C, $8E, $90, $8C, $88, $01
L9E9B:  .byte $88, $0D, $87, $88, $88, $88, $87, $87, $87, $87, $86, $86, $86, $86, $85, $85
L9EAB:  .byte $FB, $0E, $FD, $00, $0F, $14, $FC, $13, $1D, $4E, $1D, $13, $1F, $14, $21, $13
L9EBB:  .byte $1A, $14, $22, $4E, $1D, $4E, $1F, $4E, $18, $27, $24, $27, $21, $9C, $FE, $27
L9ECB:  .byte $FE, $13, $1A, $14, $21, $13, $22, $14, $24, $13, $21, $14, $22, $3A, $1A, $3B
L9EDB:  .byte $1F, $27, $1D, $4E, $FE, $13, $1F, $0A, $20, $0A, $1F, $13, $1D, $14, $1D, $3A
L9EEB:  .byte $1D, $0A, $1F, $0A, $1C, $4E, $1D, $4E, $1D, $13, $1F, $14, $21, $13, $1A, $14
L9EFB:  .byte $22, $4E, $1D, $4E, $1F, $4E, $18, $27, $24, $27, $21, $9C, $FE, $27, $FE, $13
L9F0B:  .byte $1A, $14, $21, $13, $22, $14, $24, $13, $21, $14, $22, $3A, $1A, $3B, $1F, $27
L9F1B:  .byte $1D, $4E, $FE, $13, $1F, $0A, $20, $0A, $1F, $13, $1D, $14, $1D, $3A, $1D, $0A
L9F2B:  .byte $1F, $0A, $1C, $4E, $28, $13, $29, $27, $2B, $14, $28, $4E, $28, $13, $29, $27
L9F3B:  .byte $2B, $14, $2D, $13, $2B, $06, $2D, $06, $2B, $08, $29, $13, $28, $14, $26, $3A
L9F4B:  .byte $24, $62, $24, $0C, $24, $0D, $26, $0E, $26, $0C, $28, $0D, $28, $0E, $28, $0C
L9F5B:  .byte $28, $0D, $29, $0E, $29, $0C, $2B, $0D, $2B, $0E, $28, $13, $29, $27, $2B, $14
L9F6B:  .byte $28, $4E, $28, $13, $29, $27, $2B, $14, $2D, $13, $2B, $06, $2D, $06, $2B, $08
L9F7B:  .byte $29, $13, $28, $14, $26, $3A, $24, $62, $24, $0C, $24, $0D, $26, $0E, $26, $0C
L9F8B:  .byte $28, $0D, $28, $0E, $28, $0C, $28, $0D, $29, $0E, $29, $0C, $2B, $0D, $2B, $0E
L9F9B:  .byte $2C, $13, $29, $14, $29, $13, $26, $14, $26, $13, $23, $27, $2C, $14, $2C, $13
L9FAB:  .byte $29, $14, $29, $13, $26, $14, $26, $13, $23, $3B, $28, $3A, $28, $0A, $29, $0A
L9FBB:  .byte $2B, $3A, $2B, $0A, $2D, $0A, $2E, $3A, $2E, $0A, $30, $0A, $2D, $4E, $FF, $00
L9FCB:  .byte $E2, $FE, $FB, $0C, $FD, $00, $0A, $18, $FC, $14, $FE, $13, $1A, $14, $1D, $13
L9FDB:  .byte $1F, $14, $21, $27, $1A, $27, $FE, $13, $1A, $14, $1D, $13, $1F, $14, $22, $27
L9FEB:  .byte $1A, $27, $FE, $13, $18, $14, $1C, $13, $1D, $14, $1F, $27, $18, $27, $FE, $13
L9FFB:  .byte $18, $14, $1D, $13, $1F

;----------------------------------------------------------------------------------------------------

InitSFX:
LA000:  ASL                     ;*4. 4 bytes of data per SFX init entry.
LA001:  ASL                     ;

LA002:  TAY                     ;
LA003:  LDA SFXInitData,Y       ;Get the channel number to be updated(0 to 3).
LA006:  STA SFXChannel,X        ;

LA009:  AND #$03                ;Get the channel for the current SFX data.
LA00B:  ASL                     ;
LA00C:  ASL                     ;*4. 4 control registers per channel.
LA00D:  TAX                     ;

LA00E:  INY                     ;
LA00F:  LDA SFXInitData,Y       ;Store the length of the SFX.
LA012:  STA SFXLeft,X           ;

LA015:  INY                     ;
LA016:  LDA SFXInitData,Y       ;
LA019:  STA SFXPtrLB,X          ;
LA01C:  INY                     ;Save the pointer to the SFX data.
LA01D:  LDA SFXInitData,Y       ;
LA020:  STA SFXPtrUB,X          ;
LA023:  INY                     ;

LA024:  LDA SFXPtrLB,X          ;
LA027:  STA GenPtrF0LB          ;Make a copy of the SFX data pointer.
LA029:  LDA SFXPtrUB,X          ;
LA02C:  STA GenPtrF0UB          ;

LA02E:  LDY #$00                ;Zero out the index.

LA030:  LDA (GenPtrF0),Y        ;
LA032:  STA ChnCntrl0,X         ;
LA035:  INY                     ;
LA036:  LDA (GenPtrF0),Y        ;
LA038:  STA ChnCntrl1,X         ;Set the initial values of the music channel registers
LA03B:  INY                     ;for the selected SFX.
LA03C:  LDA (GenPtrF0),Y        ;
LA03E:  STA ChnCntrl2,X         ;
LA041:  INY                     ;
LA042:  LDA (GenPtrF0),Y        ;
LA044:  STA ChnCntrl3,X         ;

LA047:  INY                     ;
LA048:  TYA                     ;Store the index to the SFX data for the next SFX update.
LA049:  STA SFXIndex,X          ;
LA04C:  RTS                     ;

;----------------------------------------------------------------------------------------------------

;Unused.
LA04D:  .byte $03, $09, $6B, $A1, $03, $09, $81, $A1, $22, $27, $1A, $27, $FE, $13, $18, $14
LA05D:  .byte $1C, $13, $1D, $14, $1F, $27, $18, $27, $FE, $13, $18, $14, $1D, $13, $1F, $14
LA06D:  .byte $21, $27, $18, $27, $FE, $13, $1A, $14, $1E, $13, $21, $14, $24, $13, $22, $14
LA07D:  .byte $21, $13, $1E, $14, $FE, $13, $1F, $14, $1A, $13, $22, $14, $24, $13, $22, $06
LA08D:  .byte $24, $06, $22, $08, $21, $13, $1A, $14, $FE, $13, $1D, $14, $17, $13, $1A, $14
LA09D:  .byte $1D, $13, $17, $14, $20, $13, $1D, $14, $1A, $3A, $1A, $0A, $1C, $0A, $19, $4E
LA0AD:  .byte $FC, $16, $FE, $13, $26, $0A, $28, $0A, $29, $09, $28, $0A, $26, $0A, $28, $0A
LA0BD:  .byte $FE, $13, $26, $0A, $28, $0A, $29, $09, $28, $0A, $26, $0A, $28, $0A, $FE, $13
LA0CD:  .byte $26, $0A, $28, $0A, $29, $09, $28, $0A, $26, $0A, $28, $0A, $FE, $13, $26, $0A
LA0DD:  .byte $28, $0A, $29, $09, $28, $0A, $26, $0A, $28, $0A, $FE, $13, $24, $0A, $26, $0A
LA0ED:  .byte $28, $09, $26, $0A, $24, $0A, $26, $0A, $FE, $13, $24, $0A, $26, $0A, $28, $09
LA0FD:  .byte $26, $0A, $24

;----------------------------------------------------------------------------------------------------

UpdateSFX:
LA100:  LDX #$00                ;Start with SQ1 SFX data.

UpdateSFXChnLoop:
LA102:  LDA SFXLeft,X           ;Is there remaining time to play current SFX?
LA105:  BEQ FinishSFXChnUpdate  ;If not, branch to check next channel.

LA107:  LDA SFXChannel,X        ;
LA10A:  AND #$F0                ;Does only control register 0 needs to be updated?
LA10C:  CMP #$10                ;If so, branch(does not appear to be used in this game).
LA10E:  BEQ SFX1RegUpdate       ;

LA110:  LDY SFXIndex,X          ;Get the index to the current SFX data.

LA113:  LDA SFXPtrLB,X          ;
LA116:  STA GenPtrF0LB          ;Get the pointer to the base address of the SFX data.
LA118:  LDA SFXPtrUB,X          ;
LA11B:  STA GenPtrF0UB          ;

LA11D:  LDA (GenPtrF0),Y        ;
LA11F:  STA ChnCntrl0,X         ;
LA122:  INY                     ;Update control registers 0 and 2 for the given audio channel.
LA123:  LDA (GenPtrF0),Y        ;
LA125:  STA ChnCntrl2,X         ;
LA128:  INY                     ;

LA129:  JMP SFXDecrementTime    ;($A13F)Decrement remining time for SFX channel.

SFX1RegUpdate:
LA12C:  LDY SFXIndex,X          ;Get the index to the current SFX data.

LA12F:  LDA SFXPtrLB,X          ;
LA132:  STA GenPtrF0LB          ;Get the pointer to the base address of the SFX data.
LA134:  LDA SFXPtrUB,X          ;
LA137:  STA GenPtrF0UB          ;

LA139:  LDA (GenPtrF0),Y        ;
LA13B:  STA ChnCntrl0,X         ;Update control register 0 for the given audio channel.
LA13E:  INY                     ;

SFXDecrementTime:
LA13F:  TYA                     ;Update to index to the SFX data for the next frame.
LA140:  STA SFXIndex,X          ;

LA143:  DEC SFXLeft,X           ;Decrement frames remaining for current SFX. Has the time expired?
LA146:  BNE FinishSFXChnUpdate  ;If not, branch.

LA148:  LDA #$01                ;Indicate the SFX has completed.
LA14A:  STA SFXFinished,X       ;

FinishSFXChnUpdate:
LA14D:  INX                     ;
LA14E:  INX                     ;Move intex to next audio channel.
LA14F:  INX                     ;
LA150:  INX                     ;

LA151:  CPX #$10                ;Have all 4 audio channels been checked?
LA153:  BCC UpdateSFXChnLoop    ;If not, branch to check next channel.

LA155:  LDA #$0F                ;
LA157:  STA APUCommonCntrl0     ;Enable SQ1, SQ2, triangle and noise channels.
LA15A:  RTS                     ;

;----------------------------------------------------------------------------------------------------

;The following table loads the control bytes for each channel to turn it off.

_SilenceChnTbl:
LA15B:  .byte $30, $11, $00, $00 ;SQ1 channel.
LA15F:  .byte $30, $11, $00, $00 ;SQ2 channel.
LA163:  .byte $80, $00, $00, $00 ;Triangle channel.
LA167:  .byte $30, $00, $00, $00 ;Noise channel.

;----------------------------------------------------------------------------------------------------

SFXInitData:

;The following data entries are used to initialize the SFX. There are 4 bytes per entry.
;The first byte is the channel the SFX will use 0=SQ1, 1-SQ2, 2=Tri, 3=Nse.
;The second byte is the length in frames of the SFX. The SFX is updated every frame with
;new data so the number of entries in the SFX data will be this value + 2.
;The last 2 bytes is the pointer to the SFX data.

InitSFX00:
LA16B:  .byte $03, $1E          ;Noise SFX, 30 frames long.
LA16D:  .word SFXDat00          ;Unused SFX.

InitSFX01:
LA16F:  .byte $00, $08          ;SQ1 SFX, 8 frames long.
LA171:  .word SFXDat01          ;Unused SFX.

InitSFX02:
LA173:  .byte $00, $08          ;SQ1 SFX, 8 frames long.
LA175:  .word SFXDat02          ;Unused SFX.

InitSFX03:
LA177:  .byte $01, $08          ;SQ2 SFX, 8 frames long.
LA179:  .word SFXDat03          ;Door open SFX.

InitSFX04:
LA17B:  .byte $01, $08          ;SQ2 SFX, 8 frames long.
LA17D:  .word SFXDat04          ;Unused SFX.

InitSFX05:
LA17F:  .byte $01, $33          ;SQ2 SFX, 51 frames long.
LA181:  .word SFXDat05          ;Unused SFX.

InitSFX06:
LA183:  .byte $01, $33          ;SQ2 SFX, 51 frames long.
LA185:  .word SFXDat06          ;Unused SFX.

InitSFX07:
LA187:  .byte $01, $33          ;SQ2 SFX, 51 frames long.
LA189:  .word SFXDat07          ;Travel through moon gate SFX.

InitSFX08:
LA18B:  .byte $03, $0F          ;Noise SFX, 15 frames long.
LA18D:  .word SFXDat08          ;Unused SFX.

InitSFX09:
LA18F:  .byte $00, $1B          ;SQ1 SFX, 27 frames long.
LA191:  .word SFXDat09          ;Casino SFX.

InitSFX0A:
LA193:  .byte $00, $1B          ;SQ1 SFX, 27 frames long.
LA195:  .word SFXDat0A          ;Unused SFX.

InitSFX0B:
LA197:  .byte $00, $1B          ;SQ1 SFX, 27 frames long.
LA199:  .word SFXDat0B          ;Spell variant B SFX.

InitSFX0C:
LA19B:  .byte $00, $1B          ;SQ1 SFX, 27 frames long.
LA19D:  .word SFXDat0C          ;Unused SFX.

InitSFX0D:
LA19F:  .byte $00, $0F          ;SQ1 SFX, 15 frames long.
LA1A1:  .word SFXDat0D          ;Unused SFX.

InitSFX0E:
LA1A3:  .byte $00, $0F          ;SQ1 SFX, 15 frames long.
LA1A5:  .word SFXDat0E          ;Chest opened/card placed SFX.

InitSFX0F:
LA1A7:  .byte $00, $11          ;SQ1 SFX, 17 frames long.
LA1A9:  .word SFXDat0F          ;Unused SFX.

InitSFX10:
LA1AB:  .byte $00, $1A          ;SQ1 SFX, 26 frames long.
LA1AD:  .word SFXDat10          ;Unused SFX.

InitSFX11:
LA1AF:  .byte $00, $21          ;SQ1 SFX, 33 frames long.
LA1B1:  .word SFXDat11          ;Time stopped SFX.

InitSFX12:
LA1B3:  .byte $00, $21          ;SQ1 SFX, 33 frames long.
LA1B5:  .word SFXDat12          ;Enemy miss physical attack SFX.

InitSFX13:
LA1B7:  .byte $10, $3D          ;SQ1 SFX, 61 frames long. Only update control register 0.
LA1B9:  .word SFXDat13          ;Unused SFX.

InitSFX14:
LA1BB:  .byte $03, $1C          ;Noise SFX, 28 frames long.
LA1BD:  .word SFXDat14          ;Player suffers fire/force damage SFX.

InitSFX15:
LA1BF:  .byte $03, $1C          ;Noise SFX, 28 frames long.
LA1C1:  .word SFXDat15          ;Unused SFX.

InitSFX16:
LA1C3:  .byte $03, $0F          ;Noise SFX, 15 frames long.
LA1C5:  .word SFXDat16          ;Player hit enemy SFX.

InitSFX17:
LA1C7:  .byte $03, $0E          ;Noise SFX, 14 frames long.
LA1C9:  .word SFXDat17          ;Enemy hit player SFX.

InitSFX18:
LA1CB:  .byte $03, $09          ;Noise SFX, 9 frames long.
LA1CD:  .word SFXDat18          ;Player is poisoned/has cold SFX.

InitSFX19:
LA1CF:  .byte $03, $09          ;Noise SFX, 9 frames long.
LA1D1:  .word SFXDat19          ;Walking through forest/shrubs SFX.

InitSFX1A:
LA1D3:  .byte $03, $09          ;Noise SFX, 9 frames long.
LA1D5:  .word SFXDat1A          ;Unused SFX.

InitSFX1B:
LA1D7:  .byte $00, $04          ;SQ1 SFX, 4 frames long.
LA1D9:  .word SFXDat1B          ;Player bumping into object SFX.

InitSFX1C:
LA1DB:  .byte $03, $05          ;Noise SFX, 5 frames long.
LA1DD:  .word SFXDat1C          ;Unused SFX.

InitSFX1D:
LA1DF:  .byte $03, $09          ;Noise SFX, 9 frames long.
LA1E1:  .word SFXDat1D          ;Player physical attack SFX.

InitSFX1E:
LA1E3:  .byte $00, $09          ;SQ1 SFX, 9 frames long.
LA1E5:  .word SFXDat1E          ;Unused SFX.

InitSFX1F:
LA1E7:  .byte $00, $09          ;SQ1 SFX, 9 frames long.
LA1E9:  .word SFXDat1F          ;Player miss physical attack/Light torch SFX.

InitSFX20:
LA1EB:  .byte $00, $09          ;SQ1 SFX, 9 frames long.
LA1ED:  .word SFXDat20          ;Unused SFX.

InitSFX21:
LA1EF:  .byte $00, $09          ;SQ1 SFX, 9 frames long.
LA1F1:  .word SFXDat21          ;Unused SFX.

InitSFX22:
LA1F3:  .byte $00, $14          ;SQ1 SFX, 20 frames long.
LA1F5:  .word SFXDat22          ;Unused SFX.

InitSFX23:
LA1F7:  .byte $00, $14          ;SQ1 SFX, 20 frames long.
LA1F9:  .word SFXDat23          ;View map SFX.

InitSFX24:
LA1FB:  .byte $00, $39          ;SQ1 SFX, 57 frames long.
LA1FD:  .word SFXDat24          ;Spell variant A SFX.

InitSFX25:
LA1FF:  .byte $03, $39          ;Noise SFX, 57 frames long.
LA201:  .word SFXDat25          ;Enemy casts major spell SFX.

InitSFX26:
LA203:  .byte $03, $39          ;Noise SFX, 57 frames long.
LA205:  .word SFXDat26          ;Castle Exodus falling apart SFX.

InitSFX27:
LA207:  .byte $03, $2C          ;Noise SFX, 44 frames long.
LA209:  .word SFXDat27          ;Unused SFX.

InitSFX28:
LA20B:  .byte $00, $21          ;SQ1 SFX, 33 frames long.
LA20D:  .word SFXDat28          ;Unused SFX.

InitSFX29:
LA20F:  .byte $00, $1F          ;SQ1 SFX, 31 frames long.
LA211:  .word SFXDat29          ;Unused SFX.

InitSFX2A:
LA213:  .byte $00, $1F          ;SQ1 SFX, 31 frames long.
LA215:  .word SFXDat2A          ;Unused SFX.

InitSFX2B:
LA217:  .byte $00, $1F          ;SQ1 SFX, 31 frames long.
LA219:  .word SFXDat2B          ;Unused SFX.

InitSFX2C:
LA21B:  .byte $01, $1E          ;SQ2 SFX, 30 frames long.
LA21D:  .word SFXDat2C          ;Player enters/exits moongate SFX.

InitSFX2D:
LA21F:  .byte $03, $08          ;Noise SFX, 8 frames long.
LA221:  .word SFXDat2D          ;Player move in dungeon SFX.

InitSFX2E:
LA223:  .byte $03, $0A          ;Noise SFX, 10 frames long.
LA225:  .word SFXDat2E          ;Unused SFX.

InitSFX2F:
LA227:  .byte $00, $09          ;SQ1 SFX, 9 frames long.
LA229:  .word SFXDat2F          ;Unused SFX.

InitSFX30:
LA22B:  .byte $00, $09          ;SQ1 SFX, 9 frames long.
LA22D:  .word SFXDat30          ;Unused SFX.

InitSFX31:
LA22F:  .byte $02, $09          ;Triangle SFX, 9 frames long.
LA231:  .word SFXDat31          ;Unused SFX.

InitSFX32:
LA233:  .byte $02, $09          ;Triangle SFX, 9 frames long.
LA235:  .word SFXDat32          ;Unused SFX.

InitSFX33:
LA237:  .byte $02, $0C          ;Tri SFX, 12 frames long.
LA239:  .word SFXDat33          ;Unused SFX.

;----------------------------------------------------------------------------------------------------

;The following data tables contain the SFX data. The first 4 bytes are loaded into control registers
;0 through 3 on initialization. During the SFX updates, only control registers 0 and 2 are updated.

SFXDat00:
LA23B:  .byte $3F, $40, $04, $01 ;
LA23F:  .byte $3F, $0F           ;
LA241:  .byte $3F, $0F           ;
LA243:  .byte $3F, $0F           ;
LA245:  .byte $3F, $0F           ;
LA247:  .byte $3F, $0F           ;
LA249:  .byte $3F, $0F           ;
LA24B:  .byte $38, $08           ;
La24D:  .byte $38, $08           ;
LA24F:  .byte $38, $08           ;
LA251:  .byte $38, $08           ;
LA253:  .byte $38, $08           ;
LA255:  .byte $38, $08           ;
LA257:  .byte $38, $06           ;
LA259:  .byte $38, $06           ;Unused SFX data.
LA25B:  .byte $38, $06           ;
LA25D:  .byte $38, $06           ;
LA25F:  .byte $38, $06           ;
LA261:  .byte $38, $06           ;
LA263:  .byte $34, $04           ;
LA265:  .byte $34, $04           ;
LA267:  .byte $34, $04           ;
LA269:  .byte $34, $04           ;
LA26B:  .byte $34, $04           ;
LA26D:  .byte $34, $04           ;
LA26F:  .byte $34, $04           ;
LA271:  .byte $34, $04           ;
LA273:  .byte $30, $04           ;
LA275:  .byte $30, $04           ;
LA277:  .byte $30, $04           ;
LA279:  .byte $30, $04           ;

SFXDat01:
LA27B:  .byte $3F, $93, $20, $00 ;
LA27F:  .byte $3E, $40           ;
LA281:  .byte $7D, $50           ;
LA283:  .byte $3C, $00           ;
LA285:  .byte $7B, $00           ;Unused SFX data.
LA287:  .byte $3A, $00           ;
LA289:  .byte $79, $00           ;
LA28B:  .byte $38, $02           ;
LA28D:  .byte $77, $02           ;

SFXDat02:
LA28F:  .byte $3F, $92, $20, $00 ;
LA293:  .byte $3D, $40           ;
LA295:  .byte $7B, $50           ;
LA297:  .byte $39, $00           ;
LA299:  .byte $77, $00           ;Unused SFX data.
LA29B:  .byte $35, $00           ;
LA29D:  .byte $73, $00           ;
LA29F:  .byte $31, $02           ;
LA2A1:  .byte $70, $02           ;

SFXDat03:
LA2A3:  .byte $30, $00, $20, $01 ;
LA2A7:  .byte $3C, $44           ;
LA2A9:  .byte $3A, $54           ;
LA2AB:  .byte $3A, $04           ;
LA2AD:  .byte $3A, $44           ;Door open SFX data.
LA2AF:  .byte $38, $04           ;
LA2B1:  .byte $38, $04           ;
LA2B3:  .byte $30, $04           ;
LA2B5:  .byte $30, $04           ;

SFXDat04:
LA2B7:  .byte $30, $00, $20, $01 ;
LA2BB:  .byte $7C, $00           ;
LA2BD:  .byte $BA, $00           ;
LA2BF:  .byte $FA, $00           ;
LA2C1:  .byte $3A, $00           ;Unused SFX data.
LA2C3:  .byte $78, $00           ;
LA2C5:  .byte $B8, $00           ;
LA2C7:  .byte $F4, $00           ;
LA2C9:  .byte $30, $00           ;

SFXDat05:
LA2CB:  .byte $BF, $00, $F0, $00 ;
LA2CD:  .byte $FF, $E0           ;
LA2CF:  .byte $BF, $D0           ;
LA2D1:  .byte $FE, $B0           ;
LA2D3:  .byte $BE, $DC           ;
LA2D5:  .byte $FE, $BC           ;
LA2D7:  .byte $FD, $B0           ;
LA2D9:  .byte $BD, $D8           ;
LA2DB:  .byte $FD, $B8           ;
LA2DD:  .byte $FC, $B0           ;
LA2DF:  .byte $BC, $D4           ;
LA2E1:  .byte $FC, $B4           ;
LA2E3:  .byte $FB, $B0           ;
LA2E5:  .byte $BB, $D0           ;
LA2E7:  .byte $FB, $B0           ;
LA2E9:  .byte $FA, $B0           ;
LA2EB:  .byte $BA, $CC           ;
LA2ED:  .byte $FA, $BC           ;
LA2EF:  .byte $F9, $B0           ;
LA2F1:  .byte $B9, $C8           ;
LA2F3:  .byte $F9, $B8           ;
LA2F5:  .byte $F8, $B0           ;
LA2F7:  .byte $B8, $C4           ;
LA2F9:  .byte $F8, $B4           ;
LA2FB:  .byte $F7, $B0           ;
LA2FD:  .byte $B7, $C0           ;
LA2FF:  .byte $F7, $B0           ;Unused SFX data.
LA301:  .byte $F6, $B0           ;
LA303:  .byte $B6, $BC           ;
LA305:  .byte $F6, $BC           ;
LA307:  .byte $F5, $B0           ;
LA309:  .byte $B5, $B8           ;
LA30B:  .byte $F5, $B8           ;
LA30D:  .byte $F4, $B0           ;
LA30F:  .byte $B4, $B4           ;
LA311:  .byte $F4, $B4           ;
LA313:  .byte $F3, $B0           ;
LA315:  .byte $B3, $B0           ;
LA317:  .byte $F3, $B0           ;
LA319:  .byte $F2, $B0           ;
LA31B:  .byte $B2, $AC           ;
LA31D:  .byte $F2, $BC           ;
LA31F:  .byte $F2, $B0           ;
LA321:  .byte $B2, $A8           ;
LA323:  .byte $F2, $B8           ;
LA325:  .byte $F2, $B0           ;
LA327:  .byte $B2, $A4           ;
LA329:  .byte $F2, $B4           ;
LA32B:  .byte $F1, $B0           ;
LA32D:  .byte $B1, $A0           ;
LA32F:  .byte $F1, $B0           ;
LA331:  .byte $70, $20           ;

SFXDat06:
LA335:  .byte $BF, $00, $F0, $00 ;
LA339:  .byte $FF, $E0           ;
LA33B:  .byte $BF, $D0           ;
LA33D:  .byte $FE, $B0           ;
LA33F:  .byte $BE, $FC           ;
LA341:  .byte $FE, $BC           ;
LA343:  .byte $FD, $B0           ;
LA345:  .byte $BD, $F8           ;
LA347:  .byte $FD, $B8           ;
LA349:  .byte $FC, $B0           ;
LA34B:  .byte $BC, $F4           ;
LA34D:  .byte $FC, $B4           ;
LA34F:  .byte $FB, $B0           ;
LA351:  .byte $BB, $F0           ;
LA353:  .byte $FB, $B0           ;
LA355:  .byte $FA, $B0           ;
LA357:  .byte $BA, $EC           ;
LA359:  .byte $FA, $BC           ;
LA35B:  .byte $F9, $B0           ;
LA35D:  .byte $B9, $E8           ;
LA35F:  .byte $F9, $B8           ;
LA361:  .byte $F8, $B0           ;
LA363:  .byte $B8, $E4           ;
LA365:  .byte $F8, $B4           ;
LA367:  .byte $F7, $B0           ;
LA369:  .byte $B7, $E0           ;
LA36B:  .byte $F7, $B0           ;Unused SFX data.
LA36D:  .byte $F6, $B0           ;
LA36F:  .byte $B6, $DC           ;
LA371:  .byte $F6, $BC           ;
LA373:  .byte $F5, $B0           ;
LA375:  .byte $B5, $D8           ;
LA377:  .byte $F5, $B8           ;
LA379:  .byte $F4, $B0           ;
LA37B:  .byte $B4, $D4           ;
LA37D:  .byte $F4, $B4           ;
LA37F:  .byte $F3, $B0           ;
LA381:  .byte $B3, $D0           ;
LA383:  .byte $F3, $B0           ;
LA385:  .byte $F2, $B0           ;
LA387:  .byte $B2, $CC           ;
LA389:  .byte $F2, $BC           ;
LA38B:  .byte $F2, $B0           ;
LA38D:  .byte $B2, $C8           ;
LA38F:  .byte $F2, $B8           ;
LA391:  .byte $F2, $B0           ;
LA393:  .byte $B2, $C4           ;
LA395:  .byte $F2, $B4           ;
LA397:  .byte $F1, $B0           ;
LA399:  .byte $B1, $C0           ;
LA39B:  .byte $F1, $B0           ;
LA39D:  .byte $70, $20           ;

SFXDat07:
LA39F:  .byte $BF, $BB, $F0, $00 ;
LA3A3:  .byte $FF, $E0           ;
LA3A5:  .byte $BF, $D0           ;
LA3A7:  .byte $FE, $B0           ;
LA3A9:  .byte $BE, $FC           ;
LA3AB:  .byte $FE, $BC           ;
LA3AD:  .byte $FD, $B0           ;
LA3AF:  .byte $BD, $F8           ;
LA3A1:  .byte $FD, $B8           ;
LA3B3:  .byte $FC, $B0           ;
LA3B5:  .byte $BC, $F4           ;
LA3B7:  .byte $FC, $B4           ;
LA3B9:  .byte $FB, $B0           ;
LA3BB:  .byte $BB, $F0           ;
LA3BD:  .byte $FB, $B0           ;
LA3BF:  .byte $FA, $B0           ;
LA3B1:  .byte $BA, $EC           ;
LA3C3:  .byte $FA, $BC           ;
LA3C5:  .byte $F9, $B0           ;
LA3C7:  .byte $B9, $E8           ;
LA3C9:  .byte $F9, $B8           ;
LA3CB:  .byte $F8, $B0           ;
LA3CD:  .byte $B8, $E4           ;
LA3CF:  .byte $F8, $B4           ;
LA3C1:  .byte $F7, $B0           ;
LA3D3:  .byte $B7, $E0           ;Travel through moon gate SFX.
LA3D5:  .byte $F7, $B0           ;
LA3D7:  .byte $F6, $B0           ;
LA3D9:  .byte $B6, $DC           ;
LA3DB:  .byte $F6, $BC           ;
LA3DD:  .byte $F5, $B0           ;
LA3DF:  .byte $B5, $D8           ;
LA3D1:  .byte $F5, $B8           ;
LA3E3:  .byte $F4, $B0           ;
LA3E5:  .byte $B4, $D4           ;
LA3E7:  .byte $F4, $B4           ;
LA3E9:  .byte $F3, $B0           ;
LA3EB:  .byte $B3, $D0           ;
LA3ED:  .byte $F3, $B0           ;
LA3EF:  .byte $F2, $B0           ;
LA3E1:  .byte $B2, $CC           ;
LA3F3:  .byte $F2, $BC           ;
LA3F5:  .byte $F2, $B0           ;
LA3F7:  .byte $B2, $C8           ;
LA3F9:  .byte $F2, $B8           ;
LA3FB:  .byte $F2, $B0           ;
LA3FD:  .byte $B2, $C4           ;
LA3FF:  .byte $F2, $B4           ;
LA3F1:  .byte $F1, $B0           ;
LA403:  .byte $B1, $C0           ;
LA405:  .byte $F1, $B0           ;
LA407:  .byte $70, $20           ;

SFXDat08:
LA409:  .byte $BF, $00, $0C, $00 ;
LA40D:  .byte $FF, $0C           ;
LA40F:  .byte $BF, $08           ;
LA411:  .byte $FF, $0C           ;
LA413:  .byte $BF, $08           ;
LA415:  .byte $FF, $0C           ;
LA417:  .byte $FC, $08           ;
LA419:  .byte $BC, $0C           ;Unused SFX data.
LA41B:  .byte $FA, $08           ;
LA41D:  .byte $FA, $0C           ;
LA41F:  .byte $B8, $08           ;
LA421:  .byte $F8, $0C           ;
LA423:  .byte $F6, $08           ;
LA425:  .byte $B4, $0C           ;
LA427:  .byte $F2, $08           ;
LA429:  .byte $70, $00           ;

SFXDat09:
LA42B:  .byte $3F, $04, $0C, $01 ;
LA42F:  .byte $3F, $04           ;
LA431:  .byte $3F, $00           ;
LA433:  .byte $3C, $06           ;
LA435:  .byte $3C, $06           ;
LA437:  .byte $3C, $06           ;
LA439:  .byte $38, $06           ;
LA43B:  .byte $38, $06           ;
LA43D:  .byte $38, $06           ;
LA43F:  .byte $36, $06           ;
LA441:  .byte $36, $06           ;
LA443:  .byte $36, $06           ;
LA445:  .byte $34, $06           ;
LA447:  .byte $34, $06           ;
LA449:  .byte $34, $06           ;Casino SFX data.
LA44B:  .byte $34, $06           ;
LA44D:  .byte $34, $06           ;
LA44F:  .byte $34, $06           ;
LA451:  .byte $32, $06           ;
LA453:  .byte $32, $06           ;
LA455:  .byte $32, $06           ;
LA457:  .byte $31, $06           ;
LA459:  .byte $31, $06           ;
LA45B:  .byte $31, $06           ;
LA45D:  .byte $31, $06           ;
LA45F:  .byte $31, $06           ;
LA461:  .byte $31, $06           ;
LA463:  .byte $70, $00           ;

SFXDat0A:
LA465:  .byte $3F, $00, $C0, $00 ;
LA469:  .byte $3F, $F0           ;
LA46B:  .byte $3F, $E0           ;
LA46D:  .byte $3C, $D0           ;
LA46F:  .byte $7C, $C0           ;
LA471:  .byte $BC, $F0           ;
LA473:  .byte $38, $E0           ;
LA475:  .byte $78, $D0           ;
LA477:  .byte $B8, $C0           ;
LA479:  .byte $36, $F0           ;
LA47B:  .byte $76, $E0           ;
LA47D:  .byte $B6, $D0           ;
LA47F:  .byte $34, $C0           ;
LA481:  .byte $74, $F0           ;Unused SFX data.
LA483:  .byte $B4, $E0           ;
LA485:  .byte $34, $D0           ;
LA487:  .byte $74, $C0           ;
LA489:  .byte $B4, $F0           ;
LA48B:  .byte $32, $E0           ;
LA48D:  .byte $72, $D0           ;
LA48F:  .byte $B2, $C0           ;
LA491:  .byte $31, $F0           ;
LA493:  .byte $71, $E0           ;
LA495:  .byte $B1, $D0           ;
LA497:  .byte $31, $C0           ;
LA499:  .byte $71, $F0           ;
LA49B:  .byte $B1, $E0           ;
LA49D:  .byte $70, $80           ;

SFXDat0B:
LA49F:  .byte $3F, $00, $20, $00 ;
LA4A3:  .byte $7F, $20           ;
LA4A5:  .byte $FF, $20           ;
LA4A7:  .byte $3C, $20           ;
LA4A9:  .byte $7C, $20           ;
LA4AB:  .byte $FC, $20           ;
LA4AD:  .byte $38, $22           ;
LA4AF:  .byte $78, $22           ;
LA4B1:  .byte $F8, $22           ;
LA4B3:  .byte $36, $24           ;
LA4B5:  .byte $76, $24           ;
LA4B7:  .byte $F6, $24           ;
LA4B9:  .byte $34, $26           ;
LA4BB:  .byte $74, $26           ;
LA4BD:  .byte $F4, $26           ;Spell variant B SFX.
LA4BF:  .byte $34, $28           ;
LA4C1:  .byte $74, $28           ;
LA4C3:  .byte $F4, $28           ;
LA4C5:  .byte $32, $2A           ;
LA4C7:  .byte $72, $2A           ;
LA4C9:  .byte $F2, $2A           ;
LA4CB:  .byte $31, $2C           ;
LA4CD:  .byte $71, $2C           ;
LA4CF:  .byte $F1, $2C           ;
LA4D1:  .byte $31, $2E           ;
LA4D3:  .byte $71, $2E           ;
LA4D5:  .byte $F1, $2E           ;
LA4D7:  .byte $70, $80           ;

SFXDat0C:
LA4D9:  .byte $7F, $00, $30, $00 ;
LA4DD:  .byte $7F, $30           ;
LA4DF:  .byte $7F, $30           ;
LA4E1:  .byte $7C, $30           ;
LA4E3:  .byte $7C, $30           ;
LA4E5:  .byte $7C, $30           ;
LA4E7:  .byte $78, $32           ;
LA4E9:  .byte $78, $32           ;
LA4EB:  .byte $78, $32           ;
LA4ED:  .byte $76, $34           ;
LA4EF:  .byte $76, $34           ;
LA4F1:  .byte $76, $34           ;
LA4F3:  .byte $74, $36           ;
LA4F5:  .byte $74, $36           ;
LA4F7:  .byte $74, $36           ;Unused SFX data.
LA4F9:  .byte $74, $38           ;
LA4FB:  .byte $74, $38           ;
LA4FD:  .byte $74, $38           ;
LA4FF:  .byte $72, $3A           ;
LA501:  .byte $72, $3A           ;
LA503:  .byte $72, $3A           ;
LA505:  .byte $71, $3C           ;
LA507:  .byte $71, $3C           ;
LA509:  .byte $71, $3C           ;
LA50B:  .byte $71, $3E           ;
LA50D:  .byte $71, $3E           ;
LA50F:  .byte $71, $3E           ;
LA511:  .byte $70, $80           ;

SFXDat0D:
LA513:  .byte $3F, $00, $E0, $00 ;
LA517:  .byte $3F, $D8           ;
LA519:  .byte $3F, $D0           ;
LA51B:  .byte $3D, $C4           ;
LA51D:  .byte $3D, $D8           ;
LA51F:  .byte $3D, $AC           ;
LA521:  .byte $3B, $A0           ;
LA523:  .byte $3B, $90           ;Unused SFX data.
LA525:  .byte $3B, $80           ;
LA527:  .byte $38, $70           ;
LA529:  .byte $38, $60           ;
LA52B:  .byte $38, $50           ;
LA52D:  .byte $34, $40           ;
LA52F:  .byte $34, $30           ;
LA531:  .byte $34, $20           ;
LA533:  .byte $70, $00           ;

SFXDat0E:
LA535:  .byte $FF, $00, $E0, $00 ;
LA539:  .byte $FF, $D8           ;
LA53B:  .byte $FF, $D0           ;
LA53D:  .byte $FD, $C4           ;
LA53F:  .byte $FD, $D8           ;
LA541:  .byte $FD, $AC           ;
LA543:  .byte $FB, $A0           ;
LA545:  .byte $FB, $90           ;
LA547:  .byte $FB, $80           ;Chest opened/card placed SFX data.
LA549:  .byte $F8, $70           ;
LA54B:  .byte $F8, $60           ;
LA54D:  .byte $F8, $50           ;
LA54F:  .byte $F4, $40           ;
LA551:  .byte $F4, $30           ;
LA553:  .byte $F4, $20           ;
LA555:  .byte $70, $00           ;

SFXDat0F:
LA557:  .byte $FF, $00, $80, $00 ;
LA55B:  .byte $FF, $40           ;
LA55D:  .byte $FF, $78           ;
LA55F:  .byte $FD, $48           ;
LA561:  .byte $FD, $70           ;
LA563:  .byte $FD, $50           ;
LA565:  .byte $FB, $68           ;
LA567:  .byte $FB, $58           ;
LA569:  .byte $FB, $60           ;Unused SFX data.
LA56B:  .byte $F8, $60           ;
LA56D:  .byte $F8, $68           ;
LA56F:  .byte $F8, $70           ;
LA571:  .byte $F4, $78           ;
LA573:  .byte $F4, $80           ;
LA575:  .byte $F4, $88           ;
LA577:  .byte $F4, $90           ;
LA579:  .byte $F4, $98           ;
LA57B:  .byte $70, $A0           ;

SFXDat10:
LA57D:  .byte $FF, $00, $80, $00 ;
LA581:  .byte $FF, $60           ;
LA583:  .byte $FF, $40           ;
LA585:  .byte $FD, $60           ;
LA587:  .byte $FD, $78           ;
LA589:  .byte $FD, $60           ;
LA58B:  .byte $FB, $48           ;
LA58D:  .byte $FB, $60           ;
LA58F:  .byte $FB, $70           ;
LA591:  .byte $F8, $60           ;
LA593:  .byte $F8, $50           ;
LA595:  .byte $F8, $60           ;
LA597:  .byte $F7, $68           ;
LA599:  .byte $F7, $60           ;Unused SFX data.
LA59B:  .byte $F6, $58           ;
LA59D:  .byte $F6, $60           ;
LA59F:  .byte $F5, $58           ;
LA5A1:  .byte $F4, $50           ;
LA5A3:  .byte $F4, $48           ;
LA5A5:  .byte $F4, $40           ;
LA5A7:  .byte $F4, $38           ;
LA5A9:  .byte $F4, $30           ;
LA5AB:  .byte $F4, $28           ;
LA5AD:  .byte $F4, $24           ;
LA5AF:  .byte $F2, $20           ;
LA5B1:  .byte $F2, $1C           ;
LA5B3:  .byte $70, $1C           ;

SFXDat11:
LA5B5:  .byte $BF, $00, $60, $00 ;
LA5B9:  .byte $BF, $70           ;
LA5BB:  .byte $BF, $80           ;
LA5BD:  .byte $BF, $C0           ;
LA5BF:  .byte $BF, $80           ;
LA5C1:  .byte $BD, $F0           ;
LA5C3:  .byte $BD, $60           ;
LA5C5:  .byte $BD, $10           ;
LA5C7:  .byte $BD, $20           ;
LA5C9:  .byte $BB, $F0           ;
LA5CB:  .byte $BB, $C0           ;
LA5CD:  .byte $BB, $C0           ;
LA5CF:  .byte $BB, $40           ;
LA5D1:  .byte $B9, $80           ;
LA5D3:  .byte $B9, $A8           ;
LA5D5:  .byte $B9, $10           ;
LA5D7:  .byte $B9, $F0           ;Time stopped SFX data.
LA5D9:  .byte $B7, $80           ;
LA5DB:  .byte $B7, $10           ;
LA5DD:  .byte $B7, $D0           ;
LA5DF:  .byte $B7, $10           ;
LA5E1:  .byte $B5, $30           ;
LA5E3:  .byte $B5, $F0           ;
LA5E5:  .byte $B5, $50           ;
LA5E7:  .byte $B5, $B0           ;
LA5E9:  .byte $B3, $70           ;
LA5EB:  .byte $B3, $50           ;
LA5ED:  .byte $B3, $D0           ;
LA5EF:  .byte $B3, $60           ;
LA5F1:  .byte $B1, $90           ;
LA5F3:  .byte $B1, $30           ;
LA5F5:  .byte $B1, $20           ;
LA5F7:  .byte $B1, $30           ;
LA5F9:  .byte $B0, $80           ;

SFXDat12:
LA5FB:  .byte $BF, $00, $10, $00 ;
LA5FF:  .byte $BF, $12           ;
LA601:  .byte $BF, $14           ;
LA603:  .byte $BF, $16           ;
LA605:  .byte $BF, $18           ;
LA607:  .byte $BD, $1A           ;
LA609:  .byte $BD, $1C           ;
LA60B:  .byte $BD, $1E           ;
LA60D:  .byte $BD, $20           ;
LA60F:  .byte $BB, $24           ;
LA611:  .byte $BB, $28           ;
LA613:  .byte $BB, $2C           ;
LA615:  .byte $BB, $30           ;
LA617:  .byte $B9, $34           ;
LA619:  .byte $B9, $38           ;
LA61B:  .byte $B9, $3C           ;
LA61D:  .byte $B9, $40           ;Enemy miss physical attack SFX data.
LA61F:  .byte $B7, $48           ;
LA621:  .byte $B7, $50           ;
LA623:  .byte $B7, $58           ;
LA625:  .byte $B7, $60           ;
LA627:  .byte $B5, $68           ;
LA629:  .byte $B5, $70           ;
LA62B:  .byte $B5, $78           ;
LA62D:  .byte $B5, $80           ;
LA62F:  .byte $B3, $90           ;
LA631:  .byte $B3, $A0           ;
LA633:  .byte $B3, $B0           ;
LA635:  .byte $B3, $C0           ;
LA637:  .byte $B1, $D0           ;
LA639:  .byte $B1, $E0           ;
LA63B:  .byte $B1, $F0           ;
LA63D:  .byte $B1, $FF           ;
LA63F:  .byte $B0, $80           ;

SFXDat13:
LA641:  .byte $BF, $94, $20, $00 ;
LA645:  .byte $BF                ;
LA646:  .byte $B0                ;
LA647:  .byte $BF                ;
LA648:  .byte $B0                ;
LA649:  .byte $BE                ;
LA64A:  .byte $B0                ;
LA64B:  .byte $BE                ;
LA64C:  .byte $B0                ;
LA64D:  .byte $BD                ;
LA64E:  .byte $B0                ;
LA64F:  .byte $BD                ;
LA650:  .byte $B0                ;
LA651:  .byte $BC                ;
LA652:  .byte $B0                ;
LA653:  .byte $BC                ;
LA654:  .byte $B0                ;
LA655:  .byte $BB                ;
LA656:  .byte $B0                ;
LA657:  .byte $BB                ;
LA658:  .byte $B0                ;
LA659:  .byte $BA                ;
LA65A:  .byte $B0                ;
LA65B:  .byte $BA                ;
LA65C:  .byte $B0                ;
LA65D:  .byte $B9                ;
LA65E:  .byte $B0                ;
LA65F:  .byte $B9                ;
LA660:  .byte $B0                ;
LA661:  .byte $B8                ;
LA662:  .byte $B0                ;
LA663:  .byte $B8                ;
LA664:  .byte $B0                ;
LA665:  .byte $B7                ;Unused SFX data.
LA666:  .byte $B0                ;
LA667:  .byte $B7                ;
LA668:  .byte $B0                ;
LA669:  .byte $B6                ;
LA66A:  .byte $B0                ;
LA66B:  .byte $B6                ;
LA66C:  .byte $B0                ;
LA66D:  .byte $B5                ;
LA66E:  .byte $B0                ;
LA66F:  .byte $B5                ;
LA670:  .byte $B0                ;
LA671:  .byte $B4                ;
LA672:  .byte $B0                ;
LA673:  .byte $B4                ;
LA674:  .byte $B0                ;
LA675:  .byte $B3                ;
LA676:  .byte $B0                ;
LA677:  .byte $B3                ;
LA678:  .byte $B0                ;
LA679:  .byte $B2                ;
LA67A:  .byte $B0                ;
LA67B:  .byte $B2                ;
LA67C:  .byte $B0                ;
LA67D:  .byte $B1                ;
LA67E:  .byte $B1                ;
LA67F:  .byte $B1                ;
LA680:  .byte $B1                ;
LA681:  .byte $B0                ;

SFXDat14:
LA682:  .byte $38, $00, $07, $F0 ;
LA686:  .byte $3F, $08           ;
LA688:  .byte $3D, $09           ;
LA68A:  .byte $3B, $0A           ;
LA68C:  .byte $39, $0B           ;
LA68E:  .byte $38, $0C           ;
LA690:  .byte $38, $0D           ;
LA692:  .byte $37, $0E           ;
LA694:  .byte $37, $0F           ;
LA696:  .byte $36, $0F           ;
LA698:  .byte $36, $0F           ;
LA69A:  .byte $35, $0F           ;
LA69C:  .byte $35, $0F           ;
LA69E:  .byte $36, $0F           ;
LA6A0:  .byte $36, $0F           ;
LA6A2:  .byte $35, $0F           ;Player suffers fire/force damage SFX data.
LA6A4:  .byte $35, $0F           ;
LA6A6:  .byte $34, $0F           ;
LA6A8:  .byte $34, $0F           ;
LA6AA:  .byte $34, $0F           ;
LA6AC:  .byte $33, $0F           ;
LA6AE:  .byte $33, $0F           ;
LA6B0:  .byte $33, $0F           ;
LA6B2:  .byte $33, $0F           ;
LA6B4:  .byte $32, $0F           ;
LA6B6:  .byte $32, $0F           ;
LA6B8:  .byte $32, $0F           ;
LA6BA:  .byte $32, $0F           ;
LA6BC:  .byte $30, $0F           ;

SFXDat15:
LA6BE:  .byte $38, $00, $07, $F0 ;
LA6C2:  .byte $3F, $09           ;
LA6C4:  .byte $3D, $0B           ;
LA6C6:  .byte $3B, $0E           ;
LA6C8:  .byte $39, $0B           ;
LA6CA:  .byte $38, $09           ;
LA6CC:  .byte $38, $07           ;
LA6CE:  .byte $37, $07           ;
LA6D0:  .byte $37, $07           ;
LA6D2:  .byte $36, $07           ;
LA6D4:  .byte $36, $07           ;
LA6D6:  .byte $35, $07           ;
LA6D8:  .byte $35, $07           ;
LA6DA:  .byte $36, $07           ;
LA6DC:  .byte $36, $07           ;Unused SFX data.
LA6DE:  .byte $35, $07           ;
LA6E0:  .byte $35, $07           ;
LA6E2:  .byte $34, $07           ;
LA6E4:  .byte $34, $07           ;
LA6E6:  .byte $34, $07           ;
LA6E8:  .byte $33, $07           ;
LA6EA:  .byte $33, $07           ;
LA6EC:  .byte $33, $07           ;
LA6EE:  .byte $33, $07           ;
LA6F0:  .byte $32, $07           ;
LA6F2:  .byte $32, $07           ;
LA6F4:  .byte $32, $07           ;
LA6F6:  .byte $32, $07           ;
LA6F8:  .byte $30, $07           ;

SFXDat16:
LA6FA:  .byte $38, $00, $07, $F0 ;
LA6FE:  .byte $3F, $09           ;
LA700:  .byte $3D, $0B           ;
LA702:  .byte $3B, $0E           ;
LA704:  .byte $39, $0B           ;
LA706:  .byte $38, $09           ;
LA708:  .byte $37, $0A           ;
LA70A:  .byte $36, $0A           ;Player hit enemy SFX data.
LA70C:  .byte $35, $0A           ;
LA70E:  .byte $34, $0A           ;
LA710:  .byte $34, $0A           ;
LA712:  .byte $33, $0A           ;
LA714:  .byte $33, $0A           ;
LA716:  .byte $32, $0A           ;
LA718:  .byte $32, $0A           ;
LA71A:  .byte $30, $0A           ;

SFXDat17:
LA71C:  .byte $34, $00, $0F, $F0 ;
LA720:  .byte $3B, $0C           ;
LA722:  .byte $3F, $09           ;
LA724:  .byte $3B, $09           ;
LA726:  .byte $38, $0A           ;
LA728:  .byte $37, $0B           ;
LA72A:  .byte $36, $0C           ;
LA72C:  .byte $35, $0C           ;Enemy hit player SFX data.
LA72E:  .byte $34, $0C           ;
LA730:  .byte $34, $0C           ;
LA732:  .byte $33, $0C           ;
LA734:  .byte $33, $0C           ;
LA736:  .byte $32, $0C           ;
LA738:  .byte $32, $0C           ;
LA73A:  .byte $30, $0C           ;

SFXDat18:
LA73C:  .byte $34, $00, $0B, $F0 ;
LA740:  .byte $38, $0B           ;
LA742:  .byte $3C, $0C           ;
LA744:  .byte $3F, $0C           ;
LA746:  .byte $34, $0E           ;
LA748:  .byte $30, $0E           ;Player is poisoned/has cold SFX data.
LA74A:  .byte $30, $0C           ;
LA74C:  .byte $30, $0C           ;
LA74E:  .byte $30, $0C           ;
LA750:  .byte $30, $0C           ;

SFXDat19:
LA752:  .byte $34, $00, $09, $F0 ;
LA756:  .byte $38, $09           ;
LA758:  .byte $3C, $09           ;
LA75A:  .byte $3F, $09           ;
LA75C:  .byte $34, $0A           ;
LA75E:  .byte $30, $0A           ;Walking through forest/shrubs SFX data.
LA760:  .byte $30, $0C           ;
LA762:  .byte $30, $0C           ;
LA764:  .byte $30, $0C           ;
LA766:  .byte $30, $0C           ;

SFXDat1A:
LA768:  .byte $34, $00, $09, $F0 ;
LA76C:  .byte $38, $09           ;
LA76E:  .byte $3C, $09           ;
LA770:  .byte $3F, $09           ;
LA772:  .byte $34, $0A           ;
LA774:  .byte $30, $0A           ;Unused SFX data.
LA776:  .byte $30, $0C           ;
LA778:  .byte $30, $0C           ;
LA77A:  .byte $30, $0C           ;
LA77C:  .byte $30, $0C           ;

SFXDat1B:
LA77E:  .byte $BF, $81, $00, $02 ;
LA782:  .byte $BF, $00           ;
LA784:  .byte $BF, $00           ;Player bumping into object SFX data.
LA786:  .byte $BF, $00           ;
LA788:  .byte $B0, $00           ;

SFXDat1C:
LA78A:  .byte $32, $00, $07, $F0 ;
LA78E:  .byte $38, $07           ;
LA790:  .byte $3F, $07           ;Unused SFX data.
LA792:  .byte $38, $07           ;
LA794:  .byte $34, $07           ;
LA796:  .byte $30, $00           ;

SFXDat1D:
LA798:  .byte $3F, $00, $0F, $F0 ;
LA79C:  .byte $3F, $0D           ;
LA79E:  .byte $3F, $0C           ;
LA7A0:  .byte $3F, $0B           ;
LA7A2:  .byte $3F, $0A           ;
LA7A4:  .byte $3F, $09           ;Player physical attack SFX data.
LA7A6:  .byte $3F, $09           ;
LA7A8:  .byte $3F, $09           ;
LA7AA:  .byte $3F, $09           ;
LA7AC:  .byte $30, $00           ;

SFXDat1E:
LA7AE:  .byte $3F, $00, $C0, $00 ;
LA7B2:  .byte $7F, $C0           ;
LA7B4:  .byte $3F, $C0           ;
LA7B6:  .byte $7E, $C0           ;
LA7B8:  .byte $3E, $C0           ;Unused SFX data.
LA7BA:  .byte $7B, $C0           ;
LA7BC:  .byte $3A, $C0           ;
LA7BE:  .byte $78, $C0           ;
LA7C0:  .byte $34, $C0           ;
LA7C2:  .byte $30, $00           ;

SFXDat1F:
LA7C4:  .byte $B4, $00, $F0, $00 ;
LA7C8:  .byte $B8, $E0           ;
LA7CA:  .byte $BF, $D0           ;
LA7CC:  .byte $BE, $C0           ;
LA7CE:  .byte $BE, $B0           ;
LA7D0:  .byte $BB, $A0           ;Player miss physical attack/Light torch SFX data.
LA7D2:  .byte $BA, $90           ;
LA7D4:  .byte $B8, $80           ;
LA7D6:  .byte $B4, $70           ;
LA7D8:  .byte $B0, $00           ;

SFXDat20:
LA7DA:  .byte $B4, $00, $40, $00 ;
LA7DE:  .byte $B8, $3C           ;
LA7E0:  .byte $BF, $38           ;
LA7E2:  .byte $BE, $34           ;
LA7E4:  .byte $BE, $30           ;
LA7E6:  .byte $BB, $3C           ;Unused SFX data.
LA7E8:  .byte $BA, $28           ;
LA7EA:  .byte $B8, $24           ;
LA7EC:  .byte $B4, $20           ;
LA7EE:  .byte $B0, $10           ;

SFXDat21:
LA7F0:  .byte $B4, $00, $80, $00 ;
LA7F4:  .byte $B8, $40           ;
LA7F6:  .byte $BF, $70           ;
LA7F8:  .byte $BE, $40           ;
LA7FA:  .byte $BE, $60           ;
LA7FC:  .byte $BB, $40           ;Unused SFX data.
LA7FE:  .byte $BA, $50           ;
LA800:  .byte $B8, $40           ;
LA802:  .byte $B4, $40           ;
LA804:  .byte $B0, $10           ;

SFXDat22:
LA806:  .byte $BF, $00, $F0, $00 ;
LA80A:  .byte $BC, $D0           ;
LA80C:  .byte $BF, $B0           ;
LA80E:  .byte $BC, $90           ;
LA810:  .byte $BF, $70           ;
LA812:  .byte $BC, $F0           ;
LA814:  .byte $BF, $D0           ;
LA816:  .byte $BC, $B0           ;
LA818:  .byte $BF, $90           ;
LA81A:  .byte $BF, $70           ;
LA81C:  .byte $BC, $F0           ;Unused SFX data.
LA81E:  .byte $BF, $D0           ;
LA820:  .byte $BC, $B0           ;
LA822:  .byte $BF, $90           ;
LA824:  .byte $BF, $70           ;
LA826:  .byte $BC, $F0           ;
LA828:  .byte $BF, $D0           ;
LA82A:  .byte $BC, $B0           ;
LA82C:  .byte $BF, $90           ;
LA82E:  .byte $BF, $70           ;
LA830:  .byte $B0, $40           ;

SFXDat23:
LA832:  .byte $BF, $00, $F0, $00 ;
LA836:  .byte $BC, $D0           ;
LA838:  .byte $BF, $B0           ;
LA83A:  .byte $BC, $90           ;
LA83C:  .byte $BF, $70           ;
LA83E:  .byte $B8, $F0           ;
LA840:  .byte $BC, $D0           ;
LA842:  .byte $B8, $B0           ;
LA844:  .byte $BC, $90           ;
LA846:  .byte $B8, $70           ;
LA848:  .byte $B4, $F0           ;View map SFX data.
LA84A:  .byte $B8, $D0           ;
LA84C:  .byte $B4, $B0           ;
LA84E:  .byte $B8, $90           ;
LA850:  .byte $B4, $70           ;
LA852:  .byte $B2, $F0           ;
LA854:  .byte $B4, $D0           ;
LA856:  .byte $B2, $B0           ;
LA858:  .byte $B4, $90           ;
LA85A:  .byte $B2, $70           ;
LA85C:  .byte $B0, $40           ;

SFXDat24:
LA85E:  .byte $BF, $00, $F0, $00 ;
LA862:  .byte $BF, $E0           ;
LA864:  .byte $BF, $D0           ;
LA866:  .byte $BF, $C0           ;
LA868:  .byte $BF, $B0           ;
LA86A:  .byte $BF, $A0           ;
LA86C:  .byte $BF, $90           ;
LA86E:  .byte $BF, $80           ;
LA870:  .byte $BF, $70           ;
LA872:  .byte $BD, $E0           ;
LA874:  .byte $BD, $D0           ;
LA876:  .byte $BD, $C0           ;
LA878:  .byte $BD, $B0           ;
LA87A:  .byte $BD, $A0           ;
LA87C:  .byte $BD, $90           ;
LA87E:  .byte $BD, $80           ;
LA880:  .byte $BD, $70           ;
LA882:  .byte $BB, $E0           ;
LA884:  .byte $BB, $D0           ;
LA886:  .byte $BB, $C0           ;
LA888:  .byte $BB, $B0           ;
LA88A:  .byte $BB, $A0           ;
LA88C:  .byte $BB, $90           ;
LA88E:  .byte $BB, $80           ;
LA890:  .byte $BB, $70           ;
LA892:  .byte $B9, $E0           ;Spell variant A SFX data.
LA894:  .byte $B9, $D0           ;
LA896:  .byte $B9, $C0           ;
LA898:  .byte $B9, $B0           ;
LA89A:  .byte $B9, $A0           ;
LA89C:  .byte $B9, $90           ;
LA89E:  .byte $B9, $80           ;
LA8A0:  .byte $B9, $70           ;
LA8A2:  .byte $B7, $E0           ;
LA8A4:  .byte $B7, $D0           ;
LA8A6:  .byte $B7, $C0           ;
LA8A8:  .byte $B7, $B0           ;
LA8AA:  .byte $B7, $A0           ;
LA8AC:  .byte $B7, $90           ;
LA8AE:  .byte $B7, $80           ;
LA8B0:  .byte $B7, $70           ;
LA8B2:  .byte $B5, $E0           ;
LA8B4:  .byte $B5, $D0           ;
LA8B6:  .byte $B5, $C0           ;
LA8B8:  .byte $B5, $B0           ;
LA8BA:  .byte $B5, $A0           ;
LA8BC:  .byte $B5, $90           ;
LA8BE:  .byte $B5, $80           ;
LA8C0:  .byte $B5, $70           ;
LA8C2:  .byte $B3, $E0           ;
LA8C4:  .byte $B3, $D0           ;
LA8C6:  .byte $B3, $C0           ;
LA8C8:  .byte $B3, $B0           ;
LA8CA:  .byte $B3, $A0           ;
LA8CC:  .byte $B3, $90           ;
LA8CE:  .byte $B3, $80           ;
LA8D0:  .byte $B3, $70           ;
LA8D2:  .byte $B0, $40           ;

SFXDat25:
LA8D4:  .byte $3F, $00, $0F, $F0 ;
LA8D8:  .byte $3F, $0E           ;
LA8DA:  .byte $3F, $0D           ;
LA8DC:  .byte $3F, $0C           ;
LA8DE:  .byte $3F, $0B           ;
LA8E0:  .byte $3F, $0A           ;
LA8E2:  .byte $3F, $09           ;
LA8E4:  .byte $3F, $08           ;
LA8E6:  .byte $3F, $07           ;
LA8E8:  .byte $3D, $0E           ;
LA8EA:  .byte $3D, $0D           ;
LA8EC:  .byte $3D, $0C           ;
LA8EE:  .byte $3D, $0B           ;
LA8F0:  .byte $3D, $0A           ;
LA8F2:  .byte $3D, $09           ;
LA8F4:  .byte $3D, $08           ;
LA8F6:  .byte $3D, $07           ;
LA8F8:  .byte $3B, $0E           ;
LA8FA:  .byte $3B, $0D           ;
LA8FC:  .byte $3B, $0C           ;
LA8FE:  .byte $3B, $0B           ;
LA900:  .byte $3B, $0A           ;
LA902:  .byte $3B, $09           ;
LA904:  .byte $3B, $08           ;
LA906:  .byte $3B, $07           ;
LA908:  .byte $39, $0E           ;
LA90A:  .byte $39, $0D           ;
LA90C:  .byte $39, $0C           ;Enemy casts major spell SFX data.
LA90E:  .byte $39, $0B           ;
LA910:  .byte $39, $0A           ;
LA912:  .byte $39, $09           ;
LA914:  .byte $39, $08           ;
LA916:  .byte $39, $07           ;
LA918:  .byte $37, $0E           ;
LA91A:  .byte $37, $0D           ;
LA91C:  .byte $37, $0C           ;
LA91E:  .byte $37, $0B           ;
LA920:  .byte $37, $0A           ;
LA922:  .byte $37, $09           ;
LA924:  .byte $37, $08           ;
LA926:  .byte $37, $07           ;
LA928:  .byte $35, $0E           ;
LA92A:  .byte $35, $0D           ;
LA92C:  .byte $35, $0C           ;
LA92E:  .byte $35, $0B           ;
LA930:  .byte $35, $0A           ;
LA932:  .byte $35, $09           ;
LA934:  .byte $35, $08           ;
LA936:  .byte $35, $07           ;
LA938:  .byte $33, $0E           ;
LA93A:  .byte $33, $0D           ;
LA93C:  .byte $33, $0C           ;
LA93E:  .byte $33, $0B           ;
LA940:  .byte $33, $0A           ;
LA942:  .byte $33, $09           ;
LA944:  .byte $33, $08           ;
LA946:  .byte $33, $07           ;
LA948:  .byte $30, $04           ;

SFXDat26:
LA94A:  .byte $3F, $00, $0F, $F0 ;
LA94E:  .byte $3F, $0D           ;
LA950:  .byte $3F, $0B           ;
LA952:  .byte $3F, $0D           ;
LA954:  .byte $3F, $0F           ;
LA956:  .byte $3F, $0D           ;
LA958:  .byte $3F, $0B           ;
LA95A:  .byte $3F, $0D           ;
LA95C:  .byte $3F, $0F           ;
LA95E:  .byte $3D, $0D           ;
LA960:  .byte $3D, $0B           ;
LA962:  .byte $3D, $0D           ;
LA964:  .byte $3D, $0F           ;
LA966:  .byte $3D, $0D           ;
LA968:  .byte $3D, $0B           ;
LA96A:  .byte $3D, $0D           ;
LA96C:  .byte $3D, $0F           ;
LA96E:  .byte $3B, $0D           ;
LA970:  .byte $3B, $0B           ;
LA972:  .byte $3B, $0D           ;
LA974:  .byte $3B, $0F           ;
LA976:  .byte $3B, $0D           ;
LA978:  .byte $3B, $0B           ;
LA97A:  .byte $3B, $0D           ;
LA97C:  .byte $3B, $0F           ;
LA97E:  .byte $39, $0D           ;
LA980:  .byte $39, $0B           ;
LA982:  .byte $39, $0D           ;
LA984:  .byte $39, $0F           ;Castle Exodus falling apart SFX data.
LA986:  .byte $39, $0D           ;
LA988:  .byte $39, $0B           ;
LA98A:  .byte $39, $0D           ;
LA98C:  .byte $39, $0F           ;
LA98E:  .byte $37, $0D           ;
LA990:  .byte $37, $0B           ;
LA992:  .byte $37, $0D           ;
LA994:  .byte $37, $0F           ;
LA996:  .byte $37, $0D           ;
LA998:  .byte $37, $0B           ;
LA99A:  .byte $37, $0D           ;
LA99C:  .byte $37, $0F           ;
LA99E:  .byte $35, $0D           ;
LA9A0:  .byte $35, $0B           ;
LA9A2:  .byte $35, $0D           ;
LA9A4:  .byte $35, $0F           ;
LA9A6:  .byte $35, $0D           ;
LA9A8:  .byte $35, $0B           ;
LA9AA:  .byte $35, $0D           ;
LA9AC:  .byte $35, $0F           ;
LA9AE:  .byte $33, $0D           ;
LA9B0:  .byte $33, $0B           ;
LA9B2:  .byte $33, $0D           ;
LA9B4:  .byte $33, $0F           ;
LA9B6:  .byte $33, $0D           ;
LA9B8:  .byte $33, $0B           ;
LA9BA:  .byte $33, $0D           ;
LA9BC:  .byte $33, $0F           ;
LA9BE:  .byte $30, $04           ;

SFXDat27:
LA9C0:  .byte $3F, $00, $0B, $F8 ;
LA9C4:  .byte $3F, $0B           ;
LA9C6:  .byte $3F, $0B           ;
LA9C8:  .byte $3F, $0B           ;
LA9CA:  .byte $3E, $0B           ;
LA9CC:  .byte $3E, $0B           ;
LA9CE:  .byte $3E, $0B           ;
LA9D0:  .byte $3E, $0B           ;
LA9D2:  .byte $3D, $0A           ;
LA9D4:  .byte $3D, $0A           ;
LA9D6:  .byte $3D, $0A           ;
LA9D8:  .byte $3D, $0A           ;
LA9DA:  .byte $3C, $0A           ;
LA9DC:  .byte $3C, $0A           ;
LA9DE:  .byte $3C, $0A           ;
LA9E0:  .byte $3C, $0A           ;
LA9E2:  .byte $3B, $0A           ;
LA9E4:  .byte $3B, $0A           ;
LA9E6:  .byte $3B, $0A           ;
LA9E8:  .byte $3B, $0A           ;
LA9EA:  .byte $3A, $0A           ;
LA9EC:  .byte $3A, $0A           ;
LA9EE:  .byte $3A, $0A           ;
LA9F0:  .byte $3A, $0A           ;
LA9F2:  .byte $39, $09           ;
LA9F4:  .byte $39, $09           ;Unused SFX data.
LA9F6:  .byte $39, $09           ;
LA9F8:  .byte $39, $09           ;
LA9FA:  .byte $38, $09           ;
LA9FC:  .byte $38, $09           ;
LA9FE:  .byte $38, $09           ;
LAA00:  .byte $38, $09           ;
LAA02:  .byte $37, $09           ;
LAA04:  .byte $37, $09           ;
LAA06:  .byte $37, $09           ;
LAA08:  .byte $37, $09           ;
LAA0A:  .byte $36, $09           ;
LAA0C:  .byte $36, $09           ;
LAA0E:  .byte $36, $09           ;
LAA10:  .byte $36, $09           ;
LAA12:  .byte $35, $09           ;
LAA14:  .byte $35, $09           ;
LAA16:  .byte $35, $09           ;
LAA18:  .byte $35, $09           ;
LAA1A:  .byte $30, $04           ;

SFXDat28:
LAA1C:  .byte $BF, $00, $80, $00 ;
LAA20:  .byte $BF, $A0           ;
LAA22:  .byte $BF, $C0           ;
LAA24:  .byte $BF, $A0           ;
LAA26:  .byte $BF, $80           ;
LAA28:  .byte $BD, $68           ;
LAA2A:  .byte $BD, $58           ;
LAA2C:  .byte $BD, $68           ;
LAA2E:  .byte $BD, $84           ;
LAA30:  .byte $BB, $A0           ;
LAA32:  .byte $BB, $C0           ;
LAA34:  .byte $BB, $A0           ;
LAA36:  .byte $BB, $80           ;
LAA38:  .byte $B9, $68           ;
LAA3A:  .byte $B9, $58           ;
LAA3C:  .byte $B9, $68           ;
LAA3E:  .byte $B9, $84           ;Unused SFX data.
LAA40:  .byte $B7, $A0           ;
LAA42:  .byte $B7, $C0           ;
LAA44:  .byte $B7, $A0           ;
LAA46:  .byte $B7, $80           ;
LAA48:  .byte $B5, $68           ;
LAA4A:  .byte $B5, $58           ;
LAA4C:  .byte $B5, $68           ;
LAA4E:  .byte $B5, $84           ;
LAA50:  .byte $B3, $A0           ;
LAA52:  .byte $B3, $C0           ;
LAA54:  .byte $B3, $A0           ;
LAA56:  .byte $B3, $80           ;
LAA58:  .byte $B1, $68           ;
LAA5A:  .byte $B1, $58           ;
LAA5C:  .byte $B1, $68           ;
LAA5E:  .byte $B1, $84           ;
LAA60:  .byte $B0, $80           ;

SFXDat29:
LAA62:  .byte $BF, $00, $8C, $00 ;
LAA66:  .byte $BF, $61           ;
LAA68:  .byte $BF, $86           ;
LAA6A:  .byte $BE, $FB           ;
LAA6C:  .byte $BE, $C0           ;
LAA6E:  .byte $BD, $D5           ;
LAA70:  .byte $BD, $3A           ;
LAA72:  .byte $BC, $EF           ;
LAA74:  .byte $BC, $F4           ;
LAA76:  .byte $BB, $49           ;
LAA78:  .byte $BB, $EE           ;
LAA7A:  .byte $BA, $E3           ;
LAA7C:  .byte $BA, $28           ;
LAA7E:  .byte $B9, $BD           ;
LAA80:  .byte $B9, $A2           ;
LAA82:  .byte $B8, $D7           ;Unused SFX data.
LAA84:  .byte $B8, $5C           ;
LAA86:  .byte $B7, $31           ;
LAA88:  .byte $B7, $56           ;
LAA8A:  .byte $B6, $CB           ;
LAA8C:  .byte $B6, $90           ;
LAA8E:  .byte $B5, $A5           ;
LAA90:  .byte $B5, $0A           ;
LAA92:  .byte $B4, $BF           ;
LAA94:  .byte $B4, $C4           ;
LAA96:  .byte $B3, $19           ;
LAA98:  .byte $B3, $BE           ;
LAA9A:  .byte $B2, $B3           ;
LAA9C:  .byte $B2, $F8           ;
LAA9E:  .byte $B1, $8D           ;
LAAA0:  .byte $B1, $72           ;
LAAA2:  .byte $B0, $10           ;

SFXDat2A:
LAAA4:  .byte $B4, $00, $8C, $01 ;
LAAA8:  .byte $B4, $61           ;
LAAAA:  .byte $B8, $86           ;
LAAAC:  .byte $BC, $FB           ;
LAAAE:  .byte $BE, $C0           ;
LAAB0:  .byte $BD, $D5           ;
LAAB2:  .byte $BD, $3A           ;
LAAB4:  .byte $BC, $EF           ;
LAAB6:  .byte $BC, $F4           ;
LAAB8:  .byte $BB, $49           ;
LAABA:  .byte $BB, $EE           ;
LAABC:  .byte $BA, $E3           ;
LAABE:  .byte $BA, $28           ;
LAAC0:  .byte $B9, $BD           ;
LAAC2:  .byte $B9, $A2           ;
LAAC4:  .byte $B8, $D7           ;Unused SFX data.
LAAC6:  .byte $B8, $5C           ;
LAAC8:  .byte $B7, $31           ;
LAACA:  .byte $B7, $56           ;
LAACC:  .byte $B6, $CB           ;
LAACE:  .byte $B6, $90           ;
LAAD0:  .byte $B5, $A5           ;
LAAD2:  .byte $B5, $0A           ;
LAAD4:  .byte $B4, $BF           ;
LAAD6:  .byte $B4, $C4           ;
LAAD8:  .byte $B3, $19           ;
LAADA:  .byte $B3, $BE           ;
LAADC:  .byte $B2, $B3           ;
LAADE:  .byte $B2, $F8           ;
LAAE0:  .byte $B1, $8D           ;
LAAE2:  .byte $B1, $72           ;
LAAE4:  .byte $B0, $10           ;

SFXDat2B:
LAAE6:  .byte $B4, $00, $5C, $00 ;
LAAEA:  .byte $B4, $41           ;
LAAEC:  .byte $B8, $56           ;
LAAEE:  .byte $BC, $6B           ;
LAAF0:  .byte $BE, $50           ;
LAAF2:  .byte $BD, $45           ;
LAAF4:  .byte $BD, $5A           ;
LAAF6:  .byte $BC, $6F           ;
LAAF8:  .byte $BC, $54           ;
LAAFA:  .byte $BB, $49           ;
LAAFC:  .byte $BB, $5E           ;
LAAFE:  .byte $BA, $63           ;
LAB00:  .byte $BA, $58           ;
LAB02:  .byte $B9, $4D           ;
LAB04:  .byte $B9, $52           ;Unused SFX data.
LAB06:  .byte $B8, $67           ;
LAB08:  .byte $B8, $55           ;
LAB0A:  .byte $B7, $41           ;
LAB0C:  .byte $B7, $56           ;
LAB0E:  .byte $B6, $6B           ;
LAB10:  .byte $B6, $50           ;
LAB12:  .byte $B5, $45           ;
LAB14:  .byte $B5, $5A           ;
LAB16:  .byte $B4, $6F           ;
LAB18:  .byte $B4, $54           ;
LAB1A:  .byte $B3, $49           ;
LAB1C:  .byte $B3, $5E           ;
LAB1E:  .byte $B2, $63           ;
LAB20:  .byte $B2, $58           ;
LAB22:  .byte $B1, $4D           ;
LAB24:  .byte $B1, $52           ;
LAB26:  .byte $B0, $10           ;

SFXDat2C:
LAB28:  .byte $BF, $00, $36, $00 ;
LAB2C:  .byte $BF, $36           ;
LAB2E:  .byte $BF, $36           ;
LAB30:  .byte $BF, $36           ;
LAB32:  .byte $BF, $36           ;
LAB34:  .byte $BE, $35           ;
LAB36:  .byte $BE, $35           ;
LAB38:  .byte $BD, $35           ;
LAB3A:  .byte $BD, $35           ;
LAB3C:  .byte $BC, $34           ;
LAB3E:  .byte $BC, $34           ;
LAB40:  .byte $BB, $34           ;
LAB42:  .byte $BB, $34           ;
LAB44:  .byte $BA, $33           ;
LAB46:  .byte $BA, $33           ;
LAB48:  .byte $B9, $33           ;Player enters/exits moongate SFX data.
LAB4A:  .byte $B9, $33           ;
LAB4C:  .byte $B8, $32           ;
LAB4E:  .byte $B8, $32           ;
LAB50:  .byte $B7, $32           ;
LAB52:  .byte $B7, $32           ;
LAB54:  .byte $B6, $31           ;
LAB56:  .byte $B6, $31           ;
LAB58:  .byte $B5, $31           ;
LAB5A:  .byte $B5, $31           ;
LAB5C:  .byte $B4, $30           ;
LAB5E:  .byte $B4, $30           ;
LAB60:  .byte $B3, $30           ;
LAB62:  .byte $B3, $30           ;
LAB64:  .byte $B2, $2F           ;
LAB66:  .byte $B2, $2F           ;

SFXDat2D:
LAB68:  .byte $38, $00, $07, $00 ;
LAB6C:  .byte $3C, $07           ;
LAB6E:  .byte $3F, $08           ;
LAB70:  .byte $38, $09           ;
LAB72:  .byte $34, $0A           ;Player move in dungeon SFX data.
LAB74:  .byte $30, $0A           ;
LAB76:  .byte $30, $0A           ;
LAB78:  .byte $30, $0A           ;
LAB7A:  .byte $30, $0A           ;

SFXDat2E:
LAB7C:  .byte $36, $00, $04, $00 ;
LAB80:  .byte $33, $07           ;
LAB82:  .byte $36, $04           ;
LAB84:  .byte $34, $07           ;
LAB86:  .byte $38, $04           ;
LAB88:  .byte $34, $07           ;Unused SFX data.
LAB8A:  .byte $36, $04           ;
LAB8C:  .byte $33, $04           ;
LAB8E:  .byte $30, $0A           ;
LAB90:  .byte $30, $0A           ;
LAB92:  .byte $30, $0A           ;

SFXDat2F:
LAB94:  .byte $B6, $00, $60, $00 ;
LAB98:  .byte $BA, $90           ;
LAB9A:  .byte $BF, $70           ;
LAB9C:  .byte $BC, $A0           ;
LAB9E:  .byte $BA, $80           ;
LABA0:  .byte $B7, $C0           ;Unused SFX data.
LABA2:  .byte $B5, $90           ;
LABA4:  .byte $B2, $E0           ;
LABA6:  .byte $B1, $A0           ;
LABA8:  .byte $B0, $10           ;

SFXDat30:
LABAA:  .byte $B6, $00, $00, $01 ;
LABAE:  .byte $3A, $10           ;
LABB0:  .byte $BF, $20           ;
LABB2:  .byte $3C, $30           ;
LABB4:  .byte $BA, $40           ;
LABB6:  .byte $37, $50           ;Unused SFX data.
LABB8:  .byte $B5, $60           ;
LABBA:  .byte $32, $70           ;
LABBC:  .byte $B1, $80           ;
LABBE:  .byte $B0, $90           ;

SFXDat31:
LABC0:  .byte $B6, $00, $00, $02 ;
LABC4:  .byte $3A, $30           ;
LABC6:  .byte $BF, $10           ;
LABC8:  .byte $3C, $40           ;
LABCA:  .byte $BA, $30           ;
LABCC:  .byte $37, $60           ;Unused SFX data.
LABCE:  .byte $B5, $40           ;
LABD0:  .byte $32, $80           ;
LABD2:  .byte $B1, $60           ;
LABD4:  .byte $B0, $A0           ;

SFXDat32:
LABD6:  .byte $36, $00, $00, $01 ;
LABDA:  .byte $3A, $20           ;
LABDC:  .byte $3F, $40           ;
LABDE:  .byte $3C, $60           ;
LABE0:  .byte $3A, $80           ;Unused SFX data.
LABE2:  .byte $37, $A0           ;
LABE4:  .byte $35, $C0           ;
LABE6:  .byte $32, $E0           ;
LABE8:  .byte $31, $F0           ;
LABEA:  .byte $30, $F0           ;

SFXDat33:
LABEC:  .byte $36, $00, $30, $00 ;
LABF0:  .byte $3A, $1E           ;
LABF2:  .byte $3F, $4C           ;
LABF4:  .byte $3C, $2A           ;
LABF6:  .byte $3A, $58           ;
LABF8:  .byte $37, $36           ;
LABFA:  .byte $35, $64           ;Unused SFX data.
LABFC:  .byte $35, $42           ;
LABFE:  .byte $35, $80           ;
LAC00:  .byte $35, $A0           ;
LAC02:  .byte $35, $C0           ;
LAC04:  .byte $35, $E0           ;
LAC06:  .byte $30, $80           ;

;----------------------------------------------------------------------------------------------------

;Unused.
LAC08:  .byte $1D, $0E, $1D, $0E, $1F, $07, $21, $07, $22, $0E, $21, $0E, $1F, $0E, $21, $0E
LAC18:  .byte $1F, $0E, $1F, $0E, $1F, $0E, $1F, $0E, $1D, $0E, $1D, $0E, $1D, $0E, $1D, $0E
LAC28:  .byte $1C, $0E, $1C, $0E, $1C, $0E, $1A, $0E, $1C, $0E, $1C, $07, $1D, $07, $1F, $0E
LAC38:  .byte $1D, $0E, $1D, $0E, $1D, $0E, $1F, $2A, $1C, $2A, $18, $07, $1A, $07, $1C, $0E
LAC48:  .byte $1C, $0E, $1A, $07, $1C, $07, $1D, $0E, $1A, $07, $1D, $07, $1F, $0E, $FF, $00
LAC58:  .byte $00, $FF, $FB, $0F, $FD, $00, $0A, $40, $FC, $28, $05, $1C, $11, $1C, $05, $0E
LAC68:  .byte $05, $0E, $11, $0E, $05, $1C, $05, $0E, $11, $1C, $05, $0E, $05, $0E, $11, $1C
LAC78:  .byte $0E, $1C, $0E, $1C, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $1C, $0E, $0E, $0E, $1C
LAC88:  .byte $0E, $0E, $0E, $0E, $0E, $1C, $0A, $1C, $0A, $1C, $0A, $0E, $0A, $0E, $0A, $0E
LAC98:  .byte $0A, $1C, $0A, $0E, $0A, $1C, $0A, $0E, $0A, $0E, $0A, $1C, $0C, $1C, $0C, $1C
LACA8:  .byte $0C, $0E, $0C, $0E, $0C, $0E, $0C, $1C, $0C, $0E, $0C, $1C, $0C, $0E, $0C, $0E
LACB8:  .byte $0C, $07, $0C, $07, $0C, $07, $0C, $07, $05, $1C, $11, $1C, $05, $0E, $05, $0E
LACC8:  .byte $11, $0E, $05, $1C, $05, $0E, $11, $1C, $05, $0E, $05, $0E, $11, $1C, $0E, $1C
LACD8:  .byte $0E, $1C, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $1C, $0E, $0E, $0E, $1C, $0E, $0E
LACE8:  .byte $0E, $0E, $0E, $1C, $0A, $1C, $0A, $1C, $0A, $0E, $0A, $0E, $0A, $0E, $0A, $1C
LACF8:  .byte $0A, $0E, $0A, $1C, $0A, $0E, $0A, $0E, $0A, $1C, $0C, $1C, $0C, $1C, $0C, $0E
LAD08:  .byte $0C, $0E, $0C, $0E, $0C, $1C, $0C, $0E, $0C, $1C, $0C, $0E, $0C, $0E, $0C, $07
LAD18:  .byte $0C, $07, $0C, $07, $0C, $07, $FF, $00, $3C, $FF, $08, $88, $8C, $90, $8E, $8C
LAD28:  .byte $8A, $88, $87, $08, $88, $88, $88, $88, $88, $88, $88, $88, $17, $88, $87, $87
LAD38:  .byte $87, $86, $86, $86, $86, $86, $85, $85, $85, $85, $85, $85, $84, $84, $84, $84
LAD48:  .byte $84, $84, $84, $83, $04, $86, $89, $8C, $90, $04, $90, $8E, $90, $8E, $0C, $8D
LAD58:  .byte $89, $87, $86, $86, $85, $85, $84, $84, $83, $83, $82, $08, $0F, $0F, $0F, $0F
LAD68:  .byte $0F, $0F, $0F, $0F, $20, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
LAD78:  .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
LAD88:  .byte $0F, $0F, $0F, $0F, $0F, $04, $00, $00, $00, $00, $08, $0F, $0F, $0F, $0F, $0F
LAD98:  .byte $0F, $0F, $0F, $10, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
LADA8:  .byte $00, $00, $00, $00, $06, $00, $00, $00, $00, $00, $00, $FB, $0A, $FD, $00, $0F
LADB8:  .byte $10, $FC, $2E, $24, $28, $24, $14, $24, $14, $24, $14, $26, $14, $24, $14, $22
LADC8:  .byte $14, $26, $28, $22, $14, $22, $64, $24, $28, $24, $14, $24, $14, $24, $14, $26
LADD8:  .byte $14, $24, $14, $22, $0A, $24, $0A, $26, $78, $22, $14, $24, $14, $26, $14, $26
LADE8:  .byte $14, $26, $14, $24, $0A, $26, $28, $29, $14, $27, $0A, $26, $0A, $24, $0A, $26
LADF8:  .byte $14, $26, $14, $26, $14, $24, $0A, $26, $28, $29, $14, $27, $0A, $26, $0A, $24
LAE08:  .byte $0A, $26, $64, $22, $28, $1F, $14, $22, $1E, $24, $82, $24, $28, $24, $14, $24
LAE18:  .byte $14, $24, $14, $26, $14, $24, $14, $22, $14, $26, $28, $22, $14, $22, $64, $24
LAE28:  .byte $28, $24, $14, $24, $14, $24, $14, $26, $14, $24, $14, $22, $0A, $24, $0A, $26
LAE38:  .byte $78, $22, $14, $24, $14, $26, $14, $26, $14, $26, $14, $24, $0A, $26, $28, $29
LAE48:  .byte $14, $27, $0A, $26, $0A, $24, $0A, $26, $14, $26, $14, $26, $14, $24, $0A, $26
LAE58:  .byte $28, $29, $14, $27, $0A, $26, $0A, $24, $0A, $26, $64, $22, $28, $1F, $14, $22
LAE68:  .byte $1E, $24, $82, $FB, $0C, $2B, $50, $2B, $14, $29, $14, $29, $14, $22, $14, $24
LAE78:  .byte $14, $26, $14, $27, $14, $26, $64, $2B, $50, $2B, $14, $29, $14, $29, $14, $22
LAE88:  .byte $14, $24, $78, $2D, $14, $2E, $14, $FB, $0E, $2D, $14, $2B, $3C, $29, $3C, $26
LAE98:  .byte $0A, $24, $0A, $26, $50, $FE, $14, $2D, $28, $2E, $14, $2D, $14, $2B, $64, $2D
LAEA8:  .byte $14, $2E, $14, $2B, $14, $29, $8C, $FF, $00, $04, $FF, $FB, $08, $FD, $00, $00
LAEB8:  .byte $80, $FC, $2F, $FE, $14, $2B, $0A, $22, $0A, $27, $0A, $2B, $0A, $27, $0A, $22
LAEC8:  .byte $0A, $FE, $14, $2A, $0A, $22, $0A, $27, $0A, $2A, $0A, $27, $0A, $22, $0A, $FE
LAED8:  .byte $14, $29, $0A, $22, $0A, $26, $0A, $29, $0A, $26, $0A, $22, $0A, $FE, $14, $29
LAEE8:  .byte $0A, $22, $0A, $26, $0A, $29, $0A, $26, $0A, $22, $0A, $FE, $14, $2B, $0A, $22
LAEF8:  .byte $0A, $27, $0A, $2B, $0A, $27, $0A, $22, $0A, $FE, $14, $2A, $0A, $22, $0A, $27
LAF08:  .byte $0A, $2A, $0A, $27, $0A, $22, $0A, $FE, $14, $29, $0A, $22, $0A, $26, $0A, $29
LAF18:  .byte $0A, $26, $0A, $22, $0A, $FE, $14, $29, $0A, $22, $0A, $26, $0A, $29, $0A, $26
LAF28:  .byte $0A, $22, $0A, $FE, $14, $22, $0A, $1F, $0A, $26, $0A, $22, $0A, $1F, $0A, $1B
LAF38:  .byte $0A, $FE, $14, $22, $0A, $1D, $0A, $26, $0A, $22, $0A, $1D, $0A, $1A, $0A, $FE
LAF48:  .byte $14, $22, $0A, $1F, $0A, $26, $0A, $22, $0A, $1F, $0A, $1B, $0A, $FE, $14, $22
LAF58:  .byte $0A, $1D, $0A, $26, $0A, $22, $0A, $1D, $0A, $1A, $0A, $FE, $14, $22, $0A, $1F
LAF68:  .byte $0A, $26, $0A, $22, $0A, $1F, $0A, $1B, $0A, $FE, $14, $22, $0A, $1F, $0A, $26
LAF78:  .byte $0A, $22, $0A, $1F, $0A, $1B, $0A, $FE, $14, $24, $0A, $22, $0A, $24, $0A, $22
LAF88:  .byte $0A, $29, $0A, $24, $0A, $FE, $14, $24, $0A, $22, $0A, $24, $0A, $21, $0A, $29
LAF98:  .byte $0A, $24, $0A, $FE, $14, $2B, $0A, $22, $0A, $27, $0A, $2B, $0A, $27, $0A, $22
LAFA8:  .byte $0A, $FE, $14, $2A, $0A, $22, $0A, $27, $0A, $2A, $0A, $27, $0A, $22, $0A, $FE
LAFB8:  .byte $14, $29, $0A, $22, $0A, $26, $0A, $29, $0A, $26, $0A, $22, $0A, $FE, $14, $29
LAFC8:  .byte $0A, $22, $0A, $26, $0A, $29, $0A, $26, $0A, $22, $0A, $FE, $14, $2B, $0A, $22
LAFD8:  .byte $0A, $27, $0A, $2B, $0A, $27, $0A, $22, $0A, $FE, $14, $2A, $0A, $22, $0A, $27
LAFE8:  .byte $0A, $2A, $0A, $27, $0A, $22, $0A, $FE, $14, $29, $0A, $22, $0A, $26, $0A, $29
LAFF8:  .byte $0A, $26, $0A, $22, $0A, $FE, $14, $29, $0A, $22, $0A, $26, $0A, $29, $0A, $26
LB008:  .byte $0A, $22, $0A, $FE, $14, $22, $0A, $1F, $0A, $26, $0A, $22, $0A, $1F, $0A, $1B
LB018:  .byte $0A, $FE, $14, $22, $0A, $1D, $0A, $26, $0A, $22, $0A, $1D, $0A, $1A, $0A, $FE
LB028:  .byte $14, $22, $0A, $1F, $0A, $26, $0A, $22, $0A, $1F, $0A, $1B, $0A, $FE, $14, $22
LB038:  .byte $0A, $1D, $0A, $26, $0A, $22, $0A, $1D, $0A, $1A, $0A, $FE, $14, $22, $0A, $1F
LB048:  .byte $0A, $26, $0A, $22, $0A, $1F, $0A, $1B, $0A, $FE, $14, $22, $0A, $1F, $0A, $26
LB058:  .byte $0A, $22, $0A, $1F, $0A, $1B, $0A, $FE, $14, $24, $0A, $22, $0A, $24, $0A, $22
LB068:  .byte $0A, $29, $0A, $24, $0A, $FE, $14, $24, $0A, $22, $0A, $24, $0A, $21, $0A, $29
LB078:  .byte $0A, $24, $0A, $1F, $50, $1F, $14, $1D, $14, $1D, $14, $16, $14, $18, $14, $1A
LB088:  .byte $14, $1B, $14, $1A, $64, $1F, $50, $1F, $14, $1D, $14, $1D, $14, $16, $14, $18
LB098:  .byte $78, $21, $14, $22, $14, $26, $0A, $22, $0A, $1F, $0A, $22, $0A, $26, $0A, $22
LB0A8:  .byte $0A, $1F, $0A, $22, $0A, $29, $0A, $24, $0A, $21, $0A, $29, $0A, $29, $0A, $24
LB0B8:  .byte $0A, $21, $0A, $29, $0A, $29, $0A, $22, $0A, $26, $0A, $22, $0A, $29, $0A, $22
LB0C8:  .byte $0A, $26, $0A, $22, $0A, $29, $0A, $22, $0A, $26, $0A, $22, $0A, $29, $0A, $22
LB0D8:  .byte $0A, $26, $0A, $22, $0A, $2B, $0A, $22, $0A, $27, $0A, $22, $0A, $2B, $0A, $22
LB0E8:  .byte $0A, $27, $0A, $22, $0A, $2B, $0A, $22, $0A, $27, $0A, $22, $0A, $2B, $0A, $22
LB0F8:  .byte $0A, $27, $0A, $22, $0A, $2D, $0A, $24, $0A, $29, $0A, $24, $0A, $2D, $0A, $24
LB108:  .byte $0A, $29, $0A, $24, $0A, $2D, $0A, $24, $0A, $29, $0A, $24, $0A, $2D, $0A, $24
LB118:  .byte $0A, $29, $0A, $24, $0A, $FF, $00, $96, $FD, $FB, $0F, $FD, $00, $00, $80, $FC
LB128:  .byte $30, $0A, $3C, $0A, $14, $0A, $50, $0A, $3C, $0A, $14, $0A, $50, $0A, $3C, $0A
LB138:  .byte $14, $0A, $50, $0A, $3C, $0A, $14, $0A, $50, $0F, $3C, $0F, $14, $0E, $3C, $0E
LB148:  .byte $14, $0C, $3C, $0C, $14, $0E, $3C, $0E, $14, $0F, $3C, $0F, $14, $0F, $3C, $0F
LB158:  .byte $14, $11, $3C, $11, $14, $11, $3C, $11, $14, $0A, $3C, $0A, $14, $0A, $50, $0A
LB168:  .byte $3C, $0A, $14, $0A, $50, $0A, $3C, $0A, $14, $0A, $50, $0A, $3C, $0A, $14, $0A
LB178:  .byte $50, $0F, $3C, $0F, $14, $0E, $3C, $0E, $14, $0C, $3C, $0C, $14, $0E, $3C, $0E
LB188:  .byte $14, $0F, $3C, $0F, $14, $0F, $3C, $0F, $14, $11, $3C, $11, $14, $11, $3C, $11
LB198:  .byte $14, $FC, $31, $0F, $14, $0F, $14, $0F, $14, $0F, $14, $0C, $14, $0C, $14, $0C
LB1A8:  .byte $14, $0C, $14, $05, $14, $05, $14, $05, $14, $05, $14, $0A, $14, $0A, $14, $0A
LB1B8:  .byte $14, $0A, $14, $0F, $14, $0F, $14, $0F, $14, $0F, $14, $0E, $14, $0E, $14, $0E
LB1C8:  .byte $14, $0E, $14, $0C, $14, $0C, $14, $0C, $14, $0C, $14, $05, $14, $05, $14, $05
LB1D8:  .byte $14, $05, $14, $07, $14, $07, $14, $07, $0A, $07, $0A, $07, $0A, $07, $0A, $09
LB1E8:  .byte $14, $09, $14, $09, $0A, $09, $0A, $09, $0A, $09, $0A, $0A, $14, $0A, $14, $0A
LB1F8:  .byte $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0E, $14, $0E, $14, $0E, $0A, $0E, $0A, $0E
LB208:  .byte $0A, $0E, $0A, $0F, $14, $0F, $14, $0F, $0A, $0F, $0A, $0F, $0A, $0F, $0A, $0F
LB218:  .byte $14, $0F, $14, $0F, $0A, $0F, $0A, $0F, $0A, $0F, $0A, $05, $14, $05, $14, $05
LB228:  .byte $0A, $05, $0A, $05, $0A, $05, $0A, $05, $14, $05, $14, $05, $0A, $05, $0A, $05
LB238:  .byte $0A, $05, $0A, $FF, $00, $E6, $FE, $05, $88, $8C, $90, $8E, $8B, $03, $87, $88
LB248:  .byte $88, $08, $87, $86, $86, $85, $85, $84, $84, $83, $83, $04, $8C, $90, $8D, $88
LB258:  .byte $08, $87, $88, $88, $88, $88, $88, $88, $88, $1D, $87, $87, $87, $87, $86, $86
LB268:  .byte $86, $86, $86, $86, $85, $85, $85, $85, $85, $85, $85, $85, $84, $84, $84, $84
LB278:  .byte $84, $84, $84, $84, $84, $84, $83, $83, $08, $0F, $0F, $0F, $0F, $0F, $0F, $0F
LB288:  .byte $0F, $10, $0F, $0F, $0F, $0F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LB298:  .byte $00, $00, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $06, $86, $8D, $90
LB2A8:  .byte $8D, $8A, $86, $04, $87, $87, $87, $87, $18, $86, $86, $86, $86, $85, $85, $85
LB2B8:  .byte $85, $84, $84, $84, $84, $83, $83, $83, $83, $82, $82, $82, $82, $81, $81, $81
LB2C8:  .byte $80, $80, $04, $8A, $8E, $90, $8E, $8B, $03, $87, $88, $88, $08, $87, $86, $86
LB2D8:  .byte $85, $85, $84, $84, $83, $83, $FB, $0E, $FD, $00, $0A, $20, $FC, $29, $26, $0E
LB2E8:  .byte $28, $07, $29, $07, $28, $0E, $26, $0E, $26, $0E, $28, $07, $29, $07, $28, $0E
LB2F8:  .byte $26, $0E, $26, $0E, $28, $07, $29, $07, $2B, $0E, $29, $07, $28, $07, $29, $0E
LB308:  .byte $28, $07, $26, $07, $28, $0E, $26, $07, $24, $07, $24, $0E, $26, $07, $28, $07
LB318:  .byte $26, $0E, $24, $0E, $24, $0E, $26, $07, $28, $07, $26, $0E, $24, $0E, $24, $0E
LB328:  .byte $26, $07, $28, $07, $29, $0E, $28, $07, $26, $07, $28, $0E, $26, $07, $24, $07
LB338:  .byte $26, $0E, $24, $07, $22, $07, $22, $0E, $24, $07, $26, $07, $24, $0E, $22, $0E
LB348:  .byte $22, $0E, $24, $07, $26, $07, $24, $0E, $22, $0E, $22, $0E, $24, $07, $26, $07
LB358:  .byte $28, $0E, $26, $07, $24, $07, $26, $0E, $24, $07, $22, $07, $24, $0E, $22, $07
LB368:  .byte $21, $07, $21, $07, $22, $07, $24, $07, $25, $07, $24, $0E, $22, $0E, $21, $07
LB378:  .byte $22, $07, $24, $07, $25, $07, $24, $0E, $22, $0E, $21, $07, $22, $07, $24, $07
LB388:  .byte $25, $07, $24, $0E, $22, $0E, $21, $07, $22, $07, $24, $07, $25, $07, $24, $0E
LB398:  .byte $22, $0E, $FB, $0A, $FC, $2D, $2C, $0E, $2D, $0E, $2A, $0E, $2C, $0E, $2D, $07
LB3A8:  .byte $2C, $07, $2D, $07, $2C, $07, $2A, $0E, $2D, $0E, $2C, $0E, $2D, $0E, $2A, $0E
LB3B8:  .byte $2C, $0E, $2D, $07, $2C, $07, $2D, $07, $2C, $07, $2A, $0E, $2D, $0E, $2C, $0E
LB3C8:  .byte $2D, $0E, $2A, $0E, $2C, $0E, $2D, $07, $2C, $07, $2D, $07, $2C, $07, $2A, $0E
LB3D8:  .byte $2D, $0E, $2C, $0E, $2D, $0E, $2A, $0E, $2C, $0E, $2D, $07, $2C, $07, $2D, $07
LB3E8:  .byte $2C, $07, $2A, $0E, $2D, $0E, $2A, $0E, $2C, $0E, $28, $0E, $2A, $0E, $2C, $07
LB3F8:  .byte $2A, $07, $2C, $07, $2A, $07, $28, $0E, $2C, $0E, $2A, $0E, $2C, $0E, $28, $0E
LB408:  .byte $2A, $0E, $2C, $07, $2A, $07, $2C, $07, $2A, $07, $28, $0E, $2C, $0E, $2A, $0E
LB418:  .byte $2C, $0E, $28, $0E, $2A, $0E, $2C, $07, $2A, $07, $2C, $07, $2A, $07, $28, $0E
LB428:  .byte $2C, $0E, $2A, $0E, $2C, $0E, $28, $0E, $2A, $0E, $2C, $07, $2A, $07, $2C, $07
LB438:  .byte $2A, $07, $28, $0E, $2C, $0E, $2C, $0E, $2D, $0E, $2A, $0E, $2C, $0E, $2D, $07
LB448:  .byte $2C, $07, $2D, $07, $2C, $07, $2A, $0E, $2D, $0E, $2C, $0E, $2D, $0E, $2A, $0E
LB458:  .byte $2C, $0E, $2D, $07, $2C, $07, $2D, $07, $2C, $07, $2A, $0E, $2D, $0E, $2C, $0E
LB468:  .byte $2D, $0E, $2A, $0E, $2C, $0E, $2D, $07, $2C, $07, $2D, $07, $2C, $07, $2A, $0E
LB478:  .byte $2D, $0E, $2C, $0E, $2D, $0E, $2A, $0E, $2C, $0E, $2D, $07, $2C, $07, $2D, $07
LB488:  .byte $2C, $07, $2A, $0E, $2D, $0E, $2A, $0E, $2C, $0E, $28, $0E, $2A, $0E, $2C, $07
LB498:  .byte $2A, $07, $2C, $07, $2A, $07, $28, $0E, $2C, $0E, $2A, $0E, $2C, $0E, $28, $0E
LB4A8:  .byte $2A, $0E, $2C, $07, $2A, $07, $2C, $07, $2A, $07, $28, $0E, $2C, $0E, $2A, $0E
LB4B8:  .byte $2C, $0E, $28, $0E, $2A, $0E, $2C, $07, $2A, $07, $2C, $07, $2A, $07, $28, $0E
LB4C8:  .byte $2C, $0E, $2A, $0E, $2C, $0E, $28, $0E, $2A, $0E, $2C, $07, $2A, $07, $2C, $07
LB4D8:  .byte $2A, $07, $28, $0E, $2C, $0E, $FF, $00, $00, $FE, $FB, $0C, $FD, $00, $00, $00
LB4E8:  .byte $FC, $2A, $21, $0E, $1D, $0E, $1F, $0E, $1D, $0E, $21, $0E, $1F, $07, $1D, $07
LB4F8:  .byte $1A, $07, $1C, $07, $1D, $0E, $21, $0E, $1D, $0E, $1F, $0E, $1D, $0E, $21, $0E
LB508:  .byte $1F, $07, $1D, $07, $1A, $07, $1C, $07, $1D, $0E, $1F, $0E, $1C, $0E, $1D, $0E
LB518:  .byte $1C, $0E, $1F, $0E, $1D, $07, $1C, $07, $18, $07, $1A, $07, $1C, $0E, $1F, $0E
LB528:  .byte $1C, $0E, $1D, $0E, $1C, $0E, $1F, $0E, $1D, $07, $1C, $07, $18, $07, $1A, $07
LB538:  .byte $1C, $0E, $1D, $0E, $1A, $0E, $1C, $0E, $1A, $0E, $1D, $0E, $1C, $07, $1A, $07
LB548:  .byte $16, $07, $18, $07, $1A, $0E, $1D, $0E, $1A, $0E, $1C, $0E, $1A, $0E, $1D, $0E
LB558:  .byte $1C, $07, $1A, $07, $16, $07, $18, $07, $1A, $0E, $1C, $07, $1F, $07, $21, $07
LB568:  .byte $22, $07, $21, $0E, $1F, $0E, $1C, $07, $1F, $07, $21, $07, $22, $07, $21, $0E
LB578:  .byte $1F, $0E, $1C, $07, $1F, $07, $21, $07, $22, $07, $21, $0E, $1F, $0E, $1C, $07
LB588:  .byte $1F, $07, $21, $07, $22, $07, $21, $0E, $1F, $0E, $FB, $0A, $FC, $2C, $20, $0E
LB598:  .byte $21, $0E, $1E, $0E, $20, $0E, $21, $07, $20, $07, $21, $07, $20, $07, $1E, $0E
LB5A8:  .byte $21, $0E, $20, $0E, $21, $0E, $1E, $0E, $20, $0E, $21, $07, $20, $07, $21, $07
LB5B8:  .byte $20, $07, $1E, $0E, $21, $0E, $20, $0E, $21, $0E, $1E, $0E, $20, $0E, $21, $07
LB5C8:  .byte $20, $07, $21, $07, $20, $07, $1E, $0E, $21, $0E, $20, $0E, $21, $0E, $1E, $0E
LB5D8:  .byte $20, $0E, $21, $07, $20, $07, $21, $07, $20, $07, $1E, $0E, $21, $0E, $1E, $0E
LB5E8:  .byte $20, $0E, $1C, $0E, $1E, $0E, $20, $07, $1E, $07, $20, $07, $1E, $07, $1C, $0E
LB5F8:  .byte $20, $0E, $1E, $0E, $20, $0E, $1C, $0E, $1E, $0E, $20, $07, $1E, $07, $20, $07
LB608:  .byte $1E, $07, $1C, $0E, $20, $0E, $1E, $0E, $20, $0E, $1C, $0E, $1E, $0E, $20, $07
LB618:  .byte $1E, $07, $20, $07, $1E, $07, $1C, $0E, $20, $0E, $1E, $0E, $20, $0E, $1C, $0E
LB628:  .byte $1E, $0E, $20, $07, $1E, $07, $20, $07, $1E, $07, $1C, $0E, $20, $0E, $20, $0E
LB638:  .byte $21, $0E, $1E, $0E, $20, $0E, $21, $07, $20, $07, $21, $07, $20, $07, $1E, $0E
LB648:  .byte $21, $0E, $20, $0E, $21, $0E, $1E, $0E, $20, $0E, $21, $07, $20, $07, $21, $07
LB658:  .byte $20, $07, $1E, $0E, $21, $0E, $20, $0E, $21, $0E, $1E, $0E, $20, $0E, $21, $07
LB668:  .byte $20, $07, $21, $07, $20, $07, $1E, $0E, $21, $0E, $20, $0E, $21, $0E, $1E, $0E
LB678:  .byte $20, $0E, $21, $07, $20, $07, $21, $07, $20, $07, $1E, $0E, $21, $0E, $1E, $0E
LB688:  .byte $20, $0E, $1C, $0E, $1E, $0E, $20, $07, $1E, $07, $20, $07, $1E, $07, $1C, $0E
LB698:  .byte $20, $0E, $1E, $0E, $20, $0E, $1C, $0E, $1E, $0E, $20, $07, $1E, $07, $20, $07
LB6A8:  .byte $1E, $07, $1C, $0E, $20, $0E, $1E, $0E, $20, $0E, $1C, $0E, $1E, $0E, $20, $07
LB6B8:  .byte $1E, $07, $20, $07, $1E, $07, $1C, $0E, $20, $0E, $1E, $0E, $20, $0E, $1C, $0E
LB6C8:  .byte $1E, $0E, $20, $07, $1E, $07, $20, $07, $1E, $07, $1C, $0E, $20, $0E, $FF, $00
LB6D8:  .byte $0C, $FE, $FB, $0F, $FD, $00, $0A, $25, $FC, $2B, $0E, $0E, $0C, $0E, $0C, $0E
LB6E8:  .byte $0E, $0E, $FE, $38, $0E, $0E, $0C, $0E, $0C, $0E, $0E, $0E, $FE, $38, $0C, $0E
LB6F8:  .byte $0A, $0E, $0A, $0E, $0C, $0E, $FE, $38, $0C, $0E, $0A, $0E, $0A, $0E, $0C, $0E
LB708:  .byte $FE, $38, $0A, $0E, $09, $0E, $09, $0E, $0A, $0E, $FE, $38, $0A, $0E, $09, $0E
LB718:  .byte $09, $0E, $0A, $0E, $FE, $38, $09, $0E, $15, $0E, $13, $0E, $15, $0E, $09, $0E
LB728:  .byte $15, $0E, $13, $0E, $15, $0E, $13, $0E, $13, $0E, $13, $0E, $10, $0E, $10, $0E
LB738:  .byte $10, $0E, $0D, $0E, $0A, $0E, $06, $1C, $12, $1C, $06, $1C, $12, $1C, $FE, $0E
LB748:  .byte $10, $0E, $0F, $0E, $0D, $0E, $12, $07, $10, $07, $0F, $07, $0D, $07, $FE, $07
LB758:  .byte $09, $07, $08, $07, $04, $07, $06, $1C, $12, $1C, $06, $1C, $12, $1C, $FE, $0E
LB768:  .byte $10, $0E, $0F, $0E, $0D, $0E, $12, $07, $10, $07, $0F, $07, $0D, $07, $FE, $07
LB778:  .byte $09, $07, $08, $07, $04, $07, $04, $1C, $10, $1C, $04, $1C, $10, $1C, $FE, $0E
LB788:  .byte $0E, $0E, $0D, $0E, $0B, $0E, $10, $07, $0E, $07, $0D, $07, $0B, $07, $FE, $07
LB798:  .byte $08, $07, $06, $07, $02, $07, $04, $1C, $10, $1C, $04, $1C, $10, $1C, $FE, $0E
LB7A8:  .byte $0E, $0E, $0D, $0E, $0B, $0E, $10, $07, $0E, $07, $0D, $07, $0B, $07, $FE, $07
LB7B8:  .byte $08, $07, $06, $07, $02, $07, $06, $1C, $12, $1C, $06, $1C, $12, $1C, $FE, $0E
LB7C8:  .byte $10, $0E, $0F, $0E, $0D, $0E, $12, $07, $10, $07, $0F, $07, $0D, $07, $FE, $07
LB7D8:  .byte $09, $07, $08, $07, $04, $07, $06, $1C, $12, $1C, $06, $1C, $12, $1C, $FE, $0E
LB7E8:  .byte $10, $0E, $0F, $0E, $0D, $0E, $12, $07, $10, $07, $0F, $07, $0D, $07, $FE, $07
LB7F8:  .byte $09, $07, $08, $07, $04, $07, $04, $1C

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
