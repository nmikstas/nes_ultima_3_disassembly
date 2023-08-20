.org $8000

.include "Ultima_3_Defines.asm"

;----------------------------------------------------------------------------------------------------

;Forward declarations.

.alias  Reset1                  $C000
.alias  DisplayText1            $C003
.alias  ChooseChar1             $C00C
.alias  ShowDialog1             $C00F
.alias  ShowSelectWnd1          $C012
.alias  ShowWindow1             $C015
.alias  _ShowSelectWnd1         $C018
.alias  BinToBCD1               $C021
.alias  FlashAndSound1          $C04E
.alias  RESET                   $FFA0
.alias  ConfigMMC               $FFBC
.alias  NMI                     $FFF0
.alias  IRQ                     $FFF0

;----------------------------------------------------------------------------------------------------

L8000:  LDX #$00
L8002:  LDA ScreenBlocks,X
L8005:  AND #$1F
L8007:  STA ScreenBlocks,X
L800A:  INX
L800B:  CPX #SPRT_HIDE
L800D:  BNE L8002
L800F:  JSR L809F
L8012:  JSR L8134
L8015:  LDA #$02
L8017:  STA $2D
L8019:  LDX #$67
L801B:  LDA #$03
L801D:  STA $19
L801F:  LDA #$FF
L8021:  STA $18
L8023:  LDY $2D
L8025:  LDA ScreenBlocks,X
L8028:  BIT $8331
L802B:  BNE L8057
L802D:  AND #$10
L802F:  BNE L8057
L8031:  LDA ScreenBlocks,X
L8034:  AND #$0F
L8036:  CMP #$02
L8038:  BEQ L8050
L803A:  CMP #$04
L803C:  BEQ L8050
L803E:  CMP #$08
L8040:  BEQ L8050
L8042:  CMP #$0C
L8044:  BEQ L8050
L8046:  CMP #$05
L8048:  BNE L8057
L804A:  LDA MapProperties
L804C:  CMP #MAP_PROP_OV
L804E:  BEQ L8057
L8050:  TYA
L8051:  PHA
L8052:  JSR L823D
L8055:  PLA
L8056:  TAY
L8057:  DEY
L8058:  BEQ L8062
L805A:  TXA
L805B:  CLC
L805C:  ADC $18
L805E:  TAX
L805F:  JMP L8025
L8062:  DEC $19
L8064:  LDY $19
L8066:  CPY #$FF
L8068:  BEQ L8074
L806A:  LDA $809B,Y
L806D:  STA $18
L806F:  LDY $2D
L8071:  JMP L805A
L8074:  TXA
L8075:  AND #$0F
L8077:  CMP #$0D
L8079:  BEQ L808C
L807B:  CMP #$0E
L807D:  BNE L8080
L807F:  RTS
L8080:  INC $2D
L8082:  INC $2D
L8084:  TXA
L8085:  SEC
L8086:  SBC #$10
L8088:  TAX
L8089:  JMP L801B
L808C:  INC $2D
L808E:  LDA #$00
L8090:  STA $19
L8092:  LDX #$DE
L8094:  LDA #$F0
L8096:  STA $18
L8098:  JMP L8023

L809B:  .byte $F0, $01, $10, $FF

L809F:  LDA MapProperties
L80A1:  AND #MAP_MOON_PH
L80A3:  BEQ L80A6
L80A5:  RTS
L80A6:  LDA $4A
L80A8:  CMP #$07
L80AA:  BCS L80B7
L80AC:  LDA #$07
L80AE:  SEC
L80AF:  SBC $4A
L80B1:  TAY
L80B2:  LDX #$00
L80B4:  JSR L80FB
L80B7:  LDA $4A
L80B9:  CMP #$38
L80BB:  BCC L80CE
L80BD:  LDA $4A
L80BF:  SEC
L80C0:  SBC #$37
L80C2:  TAY
L80C3:  STY $2D
L80C5:  SEC
L80C6:  LDA #$10
L80C8:  SBC $2D
L80CA:  TAX
L80CB:  JSR L80FB
L80CE:  LDA $49
L80D0:  CMP #$07
L80D2:  BCS L80DF
L80D4:  LDA #$07
L80D6:  SEC
L80D7:  SBC $49
L80D9:  TAY
L80DA:  LDX #$00
L80DC:  JSR L8117
L80DF:  LDA $49
L80E1:  CMP #$39
L80E3:  BCC L80FA
L80E5:  LDA $49
L80E7:  SEC
L80E8:  SBC #$38
L80EA:  TAY
L80EB:  STY $2D
L80ED:  SEC
L80EE:  LDA #$0F
L80F0:  SBC $2D
L80F2:  ASL
L80F3:  ASL
L80F4:  ASL
L80F5:  ASL
L80F6:  TAX
L80F7:  JSR L8117
L80FA:  RTS
L80FB:  STX $19
L80FD:  LDX $19
L80FF:  LDA #$0F
L8101:  STA $2D
L8103:  LDA #$40
L8105:  STA ScreenBlocks,X
L8108:  TXA
L8109:  CLC
L810A:  ADC #$10
L810C:  TAX
L810D:  DEC $2D
L810F:  BNE L8103
L8111:  INC $19
L8113:  DEY
L8114:  BNE L80FD
L8116:  RTS
L8117:  STX $19
L8119:  LDX $19
L811B:  LDA #$10
L811D:  STA $2D
L811F:  LDA #$40
L8121:  STA ScreenBlocks,X
L8124:  INX
L8125:  DEC $2D
L8127:  BNE L8121
L8129:  CLC
L812A:  LDA $19
L812C:  ADC #$10
L812E:  STA $19
L8130:  DEY
L8131:  BNE L8119
L8133:  RTS
L8134:  LDY #$00
L8136:  JSR L8149
L8139:  LDY #$21
L813B:  JSR L8149
L813E:  LDY #$41
L8140:  JSR L8149
L8143:  LDY #$61
L8145:  JSR L8149
L8148:  RTS
L8149:  LDX $82B1,Y
L814C:  LDA ScreenBlocks,X
L814F:  JSR L821F
L8152:  BCS L815B
L8154:  INY
L8155:  TYA
L8156:  AND #$07
L8158:  BNE L8149
L815A:  RTS
L815B:  STY $35
L815D:  LDX $82B1,Y
L8160:  LDA ScreenBlocks,X
L8163:  JSR L821F
L8166:  BCC L816F
L8168:  INY
L8169:  TYA
L816A:  AND #$07
L816C:  BNE L815D
L816E:  DEY
L816F:  TYA
L8170:  SEC
L8171:  SBC $35
L8173:  STA $36
L8175:  LDY $35
L8177:  TYA
L8178:  LSR
L8179:  LSR
L817A:  LSR
L817B:  LSR
L817C:  LSR
L817D:  TAX
L817E:  STA $33
L8180:  LDA $8299,X
L8183:  STA $31
L8185:  LDA $82A5,X
L8188:  STA $32
L818A:  LDX $82B1,Y
L818D:  JSR L827B
L8190:  STY $34
L8192:  LDA #$03
L8194:  CLC
L8195:  ADC $36
L8197:  STA $35
L8199:  LDX $82B9,Y
L819C:  LDA ScreenBlocks,X
L819F:  JSR L821F
L81A2:  BCS L81AB
L81A4:  INY
L81A5:  DEC $35
L81A7:  BNE L8199
L81A9:  BEQ L81D7
L81AB:  LDX $33
L81AD:  LDA $8299,X
L81B0:  STA $31
L81B2:  LDA $82A5,X
L81B5:  STA $32
L81B7:  LDX $82B9,Y
L81BA:  JSR L827B
L81BD:  LDX $33
L81BF:  LDA $829D,X
L81C2:  STA $31
L81C4:  LDA $82A9,X
L81C7:  STA $32
L81C9:  LDX $82B9,Y
L81CC:  JSR L827B
L81CF:  INY
L81D0:  TYA
L81D1:  AND #$1F
L81D3:  CMP #$09
L81D5:  BNE L81C9
L81D7:  LDY $34
L81D9:  LDA #$03
L81DB:  CLC
L81DC:  ADC $36
L81DE:  STA $35
L81E0:  LDX $82C3,Y
L81E3:  LDA ScreenBlocks,X
L81E6:  JSR L821F
L81E9:  BCS L81F2
L81EB:  INY
L81EC:  DEC $35
L81EE:  BNE L81E0
L81F0:  BEQ L821E
L81F2:  LDX $33
L81F4:  LDA $8299,X
L81F7:  STA $31
L81F9:  LDA $82A5,X
L81FC:  STA $32
L81FE:  LDX $82C3,Y
L8201:  JSR L827B
L8204:  LDX $33
L8206:  LDA $82A1,X
L8209:  STA $31
L820B:  LDA $82AD,X
L820E:  STA $32
L8210:  LDX $82C3,Y
L8213:  JSR L827B
L8216:  INY
L8217:  TYA
L8218:  AND #$1F
L821A:  CMP #$09
L821C:  BNE L8210
L821E:  RTS
L821F:  CMP #$02
L8221:  BEQ L823B
L8223:  CMP #$04
L8225:  BEQ L823B
L8227:  CMP #$08
L8229:  BEQ L823B
L822B:  CMP #$0C
L822D:  BEQ L823B
L822F:  CMP #$05
L8231:  BNE L8239
L8233:  LDA MapProperties
L8235:  CMP #MAP_PROP_OV
L8237:  BNE L823B
L8239:  CLC
L823A:  RTS
L823B:  SEC
L823C:  RTS
L823D:  TXA
L823E:  PHA
L823F:  LDY #$00
L8241:  AND #$0F
L8243:  CMP #$07
L8245:  BEQ L8270
L8247:  BCS L824B
L8249:  LDY #$01
L824B:  STY $30
L824D:  LDY #$02
L824F:  TXA
L8250:  AND #$F0
L8252:  CMP #$70
L8254:  BEQ L8270
L8256:  BCS L825A
L8258:  LDY #$00
L825A:  TYA
L825B:  CLC
L825C:  ADC $30
L825E:  ASL
L825F:  TAX
L8260:  LDA $8273,X
L8263:  STA $31
L8265:  LDA $8274,X
L8268:  STA $32
L826A:  PLA
L826B:  PHA
L826C:  TAX
L826D:  JSR L827B
L8270:  PLA
L8271:  TAX
L8272:  RTS

L8273:  .byte $F1, $00, $EF, $0F, $11, $00, $0F, $0F

L827B:  TXA
L827C:  CLC
L827D:  ADC $31
L827F:  TAX
L8280:  AND #$0F
L8282:  CMP $32
L8284:  BEQ L8298
L8286:  TXA
L8287:  AND #$F0
L8289:  CMP #$F0
L828B:  BEQ L8298
L828D:  LDA ScreenBlocks,X
L8290:  ORA #$40
L8292:  STA ScreenBlocks,X
L8295:  JMP L827B
L8298:  RTS

L8299:  .byte $01, $F0, $FF, $10, $F1, $EF, $0F, $11, $11, $F1, $EF, $0F, $00, $00, $0F, $00
L82A9:  .byte $00, $0F, $0F, $00, $00, $00, $0F, $0F, $78, $79, $7A, $7B, $7C, $7D, $7E, $7F
L82B9:  .byte $68, $68, $69, $6A, $6B, $6C, $6D, $6E, $6F, $6F, $88, $88, $89, $8A, $8B, $8C
L82C9:  .byte $8D, $8E, $8F, $8F, $00, $00, $00, $00, $00, $67, $57, $47, $37, $27, $17, $07
L82D9:  .byte $00, $66, $66, $56, $46, $36, $26, $16, $06, $06, $00, $68, $68, $58, $48, $38
L82E9:  .byte $28, $18, $08, $08, $00, $00, $00, $00, $00, $76, $75, $74, $73, $72, $71, $70
L82F9:  .byte $00, $86, $86, $85, $84, $83, $82, $81, $80, $80, $00, $66, $66, $65, $64, $63
L8309:  .byte $62, $61, $60, $60, $00, $00, $00, $00, $00, $87, $97, $A7, $B7, $C7, $D7, $E7
L8319:  .byte $00, $88, $88, $98, $A8, $B8, $C8, $D8, $E8, $E8, $00, $86, $86, $96, $A6, $B6
L8329:  .byte $C6, $D6, $E6, $E6, $00, $00, $00, $00, $C0, $00, $00, $00, $00, $00, $C8, $BB
L8339:  .byte $BB, $BB, $8C, $00, $C3, $33, $30, $00, $33, $33, $C2, $22, $22, $00, $00, $00
L8349:  .byte $00, $00, $33, $33, $33, $00, $16, $66, $10, $03, $33, $33, $30, $00, $CB, $BB
L8359:  .byte $BB, $BB, $BC, $00, $C3, $33, $30, $00, $33, $33, $C2, $22, $22, $2C, $88, $8C
L8369:  .byte $00, $00, $33, $33, $33, $00, $06, $66, $00, $03, $33, $33, $30, $00, $C9, $99
L8379:  .byte $99, $99, $9C, $00, $C3, $33, $30, $00, $33, $33, $C2, $22, $22, $2C, $66, $6C
L8389:  .byte $10, $00, $33, $33, $33, $00, $16, $66, $10, $03, $33, $33, $30, $00, $CB, $BB
L8399:  .byte $BB, $BB, $BC, $00, $C3, $33, $30, $00, $33, $33, $C8, $88, $88, $8C, $66, $6C
L83A9:  .byte $11, $00, $00, $00, $00, $01, $16, $66, $11, $00, $00, $00, $00, $00, $CB, $BB
L83B9:  .byte $BB, $BB, $BC, $00, $C3, $33, $30, $00, $33, $33, $88, $88, $88, $88, $66, $68
L83C9:  .byte $11, $10, $00, $00, $00, $11, $16, $66, $11, $10, $00, $00, $00, $00, $8B, $BB
L83D9:  .byte $BB, $BB, $BC, $00, $C3, $33, $30, $06, $66, $66, $66, $66, $66, $66, $66, $66
L83E9:  .byte $66, $66, $66, $66, $66, $66, $66, $66, $66, $66, $66, $66, $66, $66, $66, $66
L83F9:  .byte $66, $66, $6C, $00, $C3, $33, $30

L8400:  LDA #$00
L8402:  LDX #$00
L8404:  STA $30
L8406:  LDA $30
L8408:  CLC
L8409:  ADC $71
L840B:  CMP #$0F
L840D:  BCC L8411
L840F:  SBC #$0F
L8411:  PHA
L8412:  AND #$1E
L8414:  ASL
L8415:  ASL
L8416:  STA $2F
L8418:  LDA $72
L841A:  LSR
L841B:  CMP #$08
L841D:  BCC L8422
L841F:  CLC
L8420:  ADC #$38
L8422:  ADC $2F
L8424:  TAY
L8425:  LDA #$08
L8427:  STA $28
L8429:  CPY #$40
L842B:  BCC L842F
L842D:  LDA #$48
L842F:  CLC
L8430:  ADC $2F
L8432:  STA $2E
L8434:  PLA
L8435:  AND #$01
L8437:  BNE L844B
L8439:  LDA $72
L843B:  AND #$01
L843D:  BEQ L8445
L843F:  JSR L84DE
L8442:  JMP L845A
L8445:  JSR L846C
L8448:  JMP L845A
L844B:  LDA $72
L844D:  AND #$01
L844F:  BEQ L8457
L8451:  JSR L8523
L8454:  JMP L845A
L8457:  JSR L84A3
L845A:  INC $30
L845C:  LDA $30
L845E:  CMP #$0F
L8460:  BCC L8406
L8462:  RTS
L8463:  LDA $2E
L8465:  CLC
L8466:  ADC #$38
L8468:  AND #$7F
L846A:  TAY
L846B:  RTS
L846C:  JSR L858D
L846F:  STA $2C
L8471:  INX
L8472:  JSR L858D
L8475:  STA $2B
L8477:  INX
L8478:  STX $2D
L847A:  LDX $2B
L847C:  LDA $856D,X
L847F:  ASL
L8480:  ASL
L8481:  LDX $2C
L8483:  ORA $856D,X
L8486:  AND #$0F
L8488:  STA $2F
L848A:  LDA AttribBuffer,Y
L848D:  AND #$F0
L848F:  ORA $2F
L8491:  STA AttribBuffer,Y
L8494:  INY
L8495:  CPY $2E
L8497:  BNE L849C
L8499:  JSR L8463
L849C:  LDX $2D
L849E:  DEC $28
L84A0:  BNE L846C
L84A2:  RTS
L84A3:  JSR L858D
L84A6:  STA $2C
L84A8:  INX
L84A9:  JSR L858D
L84AC:  STA $2B
L84AE:  INX
L84AF:  STX $2D
L84B1:  LDX $2B
L84B3:  LDA $856D,X
L84B6:  ASL
L84B7:  ASL
L84B8:  LDX $2C
L84BA:  ORA $856D,X
L84BD:  AND #$0F
L84BF:  ASL
L84C0:  ASL
L84C1:  ASL
L84C2:  ASL
L84C3:  STA $2F
L84C5:  LDA AttribBuffer,Y
L84C8:  AND #$0F
L84CA:  ORA $2F
L84CC:  STA AttribBuffer,Y
L84CF:  INY
L84D0:  CPY $2E
L84D2:  BNE L84D7
L84D4:  JSR L8463
L84D7:  LDX $2D
L84D9:  DEC $28
L84DB:  BNE L84A3
L84DD:  RTS
L84DE:  JSR L858D
L84E1:  STA $2C
L84E3:  INX
L84E4:  JSR L858D
L84E7:  STA $2B
L84E9:  INX
L84EA:  STX $2D
L84EC:  LDX $2C
L84EE:  LDA $856D,X
L84F1:  ASL
L84F2:  ASL
L84F3:  AND #$0C
L84F5:  STA $2F
L84F7:  LDA AttribBuffer,Y
L84FA:  AND #$F3
L84FC:  ORA $2F
L84FE:  STA AttribBuffer,Y
L8501:  INY
L8502:  CPY $2E
L8504:  BNE L8509
L8506:  JSR L8463
L8509:  LDX $2B
L850B:  LDA $856D,X
L850E:  AND #$03
L8510:  STA $2F
L8512:  LDA AttribBuffer,Y
L8515:  AND #$FC
L8517:  ORA $2F
L8519:  STA AttribBuffer,Y
L851C:  LDX $2D
L851E:  DEC $28
L8520:  BNE L84DE
L8522:  RTS
L8523:  JSR L858D
L8526:  STA $2C
L8528:  INX
L8529:  JSR L858D
L852C:  STA $2B
L852E:  INX
L852F:  STX $2D
L8531:  LDX $2C
L8533:  LDA $856D,X
L8536:  ROR
L8537:  ROR
L8538:  ROR
L8539:  AND #$C0
L853B:  STA $2F
L853D:  LDA AttribBuffer,Y
L8540:  AND #$3F
L8542:  ORA $2F
L8544:  STA AttribBuffer,Y
L8547:  INY
L8548:  CPY $2E
L854A:  BNE L854F
L854C:  JSR L8463
L854F:  LDX $2B
L8551:  LDA $856D,X
L8554:  ASL
L8555:  ASL
L8556:  ASL
L8557:  ASL
L8558:  AND #$30
L855A:  STA $2F
L855C:  LDA AttribBuffer,Y
L855F:  AND #$CF
L8561:  ORA $2F
L8563:  STA AttribBuffer,Y
L8566:  LDX $2D
L8568:  DEC $28
L856A:  BNE L8523
L856C:  RTS

L856D:  .byte $03, $03, $03, $01, $02, $02, $02, $02, $02, $02, $02, $03, $02, $01, $01, $02
L857D:  .byte $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $01, $02, $00, $00

L858D:  LDA ScreenBlocks,X
L8590:  BIT $8331
L8593:  BEQ L85A8
L8595:  AND #$E0
L8597:  CMP #$60
L8599:  AND #$A0
L859B:  BCS L859F
L859D:  LDA #$C0
L859F:  ROL
L85A0:  ROL
L85A1:  ROL
L85A2:  ROL
L85A3:  ORA #$18
L85A5:  JMP L85B3
L85A8:  AND #$10
L85AA:  BEQ L85B0
L85AC:  LDA #$03
L85AE:  BNE L85B3
L85B0:  LDA ScreenBlocks,X
L85B3:  AND #$1F
L85B5:  RTS

L85B6:  .byte $66, $60, $00, $00, $00, $00, $00, $C3, $33, $30, $00, $33, $33, $C0, $00, $00
L85C6:  .byte $C8, $88, $8B, $B6, $00, $0C, $88, $88, $88, $8B, $BB, $88, $88, $88, $8C, $00
L85D6:  .byte $06, $BB, $88, $88, $C0, $00, $00, $C3, $33, $30, $00, $33, $33, $C0, $00, $00
L85E6:  .byte $C9, $9B, $BB, $B0, $00, $0C, $9B, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $9C, $00
L85F6:  .byte $00, $BB, $BB, $99, $C1, $00, $01, $C3, $33, $30

L8600:  LDY $AA
L8602:  LDA MapProperties
L8604:  AND #MAP_MOON_PH
L8606:  BEQ L8616
L8608:  TYA
L8609:  AND #$03
L860B:  BEQ L8613
L860D:  TYA
L860E:  ADC #$03
L8610:  AND #$FC
L8612:  TAY
L8613:  DEY
L8614:  DEY
L8615:  DEY
L8616:  DEY
L8617:  BNE L861B
L8619:  LDY #$50
L861B:  STY $AA
L861D:  TYA
L861E:  AND #$03
L8620:  BNE L8635
L8622:  LDX #$00
L8624:  LDA $91,X
L8626:  STA $99
L8628:  INX
L8629:  LDA $91,X
L862B:  STA $9A
L862D:  INX
L862E:  JSR L86F0
L8631:  CPX #$08
L8633:  BNE L8624
L8635:  LDX #$00
L8637:  LDA $91,X
L8639:  STA $99
L863B:  LDA $92,X
L863D:  STA $9A
L863F:  TXA
L8640:  PHA
L8641:  LSR
L8642:  JSR L87AB
L8645:  LDY #CHR_COND
L8647:  LDA (CrntChrPtr),Y
L8649:  CMP #$03
L864B:  BCC L8650
L864D:  JMP L86E4
L8650:  LDY #CHR_MARKS
L8652:  LDA (CrntChrPtr),Y
L8654:  AND #$02
L8656:  BNE L8676
L8658:  LDA MapProperties
L865A:  AND #$03
L865C:  BNE L8676
L865E:  LDA ScreenBlocks,X
L8661:  AND #$1F
L8663:  CMP #$07
L8665:  BNE L8676
L8667:  LDA #$FF
L8669:  STA $2E
L866B:  LDA #$CE
L866D:  LDY #$2D
L866F:  JSR L8793
L8672:  LDA #SFX_MARK_DMG+INIT
L8674:  STA ThisSFX
L8676:  LDA ThisMap
L8678:  CMP #$14
L867A:  BEQ L8683
L867C:  CMP #$06
L867E:  BEQ L8683
L8680:  JMP L86A1
L8683:  LDY #CHR_MARKS
L8685:  LDA (CrntChrPtr),Y
L8687:  AND #$01
L8689:  BNE L86A1
L868B:  LDA ScreenBlocks,X
L868E:  AND #$1F
L8690:  CMP #$0E
L8692:  BNE L86A1
L8694:  LDY #$2D
L8696:  LDA #$00
L8698:  STA (CrntChrPtr),Y
L869A:  INY
L869B:  STA (CrntChrPtr),Y
L869D:  LDA #SFX_MARK_DMG+INIT
L869F:  STA ThisSFX
L86A1:  LDY #CHR_HIT_PNTS+1
L86A3:  LDA (CrntChrPtr),Y
L86A5:  BNE L86E4
L86A7:  DEY
L86A8:  LDA (CrntChrPtr),Y
L86AA:  BNE L86E4
L86AC:  LDY #$0B
L86AE:  LDA #$03
L86B0:  STA (CrntChrPtr),Y
L86B2:  LDA $0B
L86B4:  BNE L86B2
L86B6:  LDA $0F
L86B8:  STA $13
L86BA:  LDA $10
L86BC:  STA $14
L86BE:  LDA $11
L86C0:  STA $15
L86C2:  LDA $12
L86C4:  STA $16
L86C6:  LDA #$29
L86C8:  STA TextIndex
L86CA:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L86CD:  JSR BinToBCD1           ;($C021)Convert binary number to BCD.
L86D0:  PLA
L86D1:  PHA
L86D2:  ASL
L86D3:  ASL
L86D4:  ASL
L86D5:  TAX
L86D6:  LDA #SPRT_HIDE
L86D8:  STA $7304,X
L86DB:  STA $7308,X
L86DE:  STA $730C,X
L86E1:  STA $7310,X
L86E4:  PLA
L86E5:  TAX
L86E6:  INX
L86E7:  INX
L86E8:  CPX #$08
L86EA:  BEQ L86EF
L86EC:  JMP L8637
L86EF:  RTS
L86F0:  LDA #$00
L86F2:  STA $2A
L86F4:  LDY #CHR_COND
L86F6:  LDA (CrntChrPtr),Y
L86F8:  CMP #$03
L86FA:  BCC L86FD
L86FC:  RTS
L86FD:  CMP #$02
L86FF:  BNE L8707
L8701:  LDA $AA
L8703:  LSR
L8704:  LSR
L8705:  AND #$01
L8707:  CMP #$01
L8709:  BNE L870F
L870B:  LDA #$FF
L870D:  STA $2A
L870F:  STA $29
L8711:  LDA $AA
L8713:  AND #$0F
L8715:  BNE L872E
L8717:  LDY #CHR_FOOD+1
L8719:  LDA (CrntChrPtr),Y
L871B:  BNE L872E
L871D:  LDY #CHR_FOOD
L871F:  LDA (CrntChrPtr),Y
L8721:  BNE L872E
L8723:  LDA $29
L8725:  SEC
L8726:  SBC #$05
L8728:  STA $29
L872A:  LDA #$FF
L872C:  STA $2A
L872E:  LDY #$2F
L8730:  LDA (CrntChrPtr),Y
L8732:  LDY #$38
L8734:  CMP (CrntChrPtr),Y
L8736:  BCS L873E
L8738:  ADC #$01
L873A:  LDY #$2F
L873C:  STA (CrntChrPtr),Y
L873E:  LDA $AA
L8740:  CMP #$50
L8742:  BEQ L8748
L8744:  CMP #$28
L8746:  BNE L875E
L8748:  CLC
L8749:  LDA #$01
L874B:  ADC $29
L874D:  STA $29
L874F:  LDA #$00
L8751:  ADC $2A
L8753:  STA $2A
L8755:  LDY #$2B
L8757:  LDA #$FF
L8759:  STA $2E
L875B:  JSR L8793
L875E:  LDA $2A
L8760:  STA $2E
L8762:  LDA $29
L8764:  STA $2D
L8766:  BEQ L876D
L8768:  LDY #$2D
L876A:  JSR L8793
L876D:  LDY #$36
L876F:  LDA (CrntChrPtr),Y
L8771:  STA $29
L8773:  INY
L8774:  LDA (CrntChrPtr),Y
L8776:  STA $2A
L8778:  LDY #$2E
L877A:  CMP (CrntChrPtr),Y
L877C:  BCC L8787
L877E:  BNE L8792
L8780:  DEY
L8781:  LDA $29
L8783:  CMP (CrntChrPtr),Y
L8785:  BCS L8792
L8787:  LDY #$2D
L8789:  LDA $29
L878B:  STA (CrntChrPtr),Y
L878D:  INY
L878E:  LDA $2A
L8790:  STA (CrntChrPtr),Y
L8792:  RTS
L8793:  CLC
L8794:  ADC (CrntChrPtr),Y
L8796:  STA $2D
L8798:  LDA $2E
L879A:  INY
L879B:  ADC (CrntChrPtr),Y
L879D:  BPL L87A3
L879F:  LDA #$00
L87A1:  STA $2D
L87A3:  STA (CrntChrPtr),Y
L87A5:  DEY
L87A6:  LDA $2D
L87A8:  STA (CrntChrPtr),Y
L87AA:  RTS
L87AB:  ASL
L87AC:  ASL
L87AD:  ASL
L87AE:  ASL
L87AF:  TAX
L87B0:  LDA $7307,X
L87B3:  LSR
L87B4:  LSR
L87B5:  LSR
L87B6:  LSR
L87B7:  STA $29
L87B9:  LDA $7304,X
L87BC:  AND #$F0
L87BE:  ORA $29
L87C0:  TAX
L87C1:  RTS

L87C2:  .byte $00, $00, $00, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33
L87D2:  .byte $33, $33, $33, $33, $33, $33, $33, $33, $33, $30, $00, $00, $00, $00, $00, $00
L87E2:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L87F2:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

L8800:  LDA #$00
L8802:  PHA
L8803:  ASL
L8804:  TAX
L8805:  LDA $91,X
L8807:  STA $99
L8809:  LDA $92,X
L880B:  STA $9A
L880D:  JSR L881C
L8810:  JSR L885F
L8813:  PLA
L8814:  CLC
L8815:  ADC #$01
L8817:  CMP #$04
L8819:  BNE L8802
L881B:  RTS
L881C:  LDA #$00
L881E:  STA $37
L8820:  LDY #$0A
L8822:  LDA (CrntChrPtr),Y
L8824:  STA $31
L8826:  LSR
L8827:  STA $33
L8829:  LDY #$09
L882B:  LDA (CrntChrPtr),Y
L882D:  STA $32
L882F:  LSR
L8830:  STA $34
L8832:  CMP $33
L8834:  BCS L8838
L8836:  LDA $33
L8838:  STA $35
L883A:  LDA $34
L883C:  CMP $33
L883E:  BCC L8842
L8840:  LDA $33
L8842:  STA $36
L8844:  LDY #$06
L8846:  LDA (CrntChrPtr),Y
L8848:  TAX
L8849:  LDA $8854,X
L884C:  TAX
L884D:  LDA $31,X
L884F:  LDY #$38
L8851:  STA (CrntChrPtr),Y
L8853:  RTS

L8854:  .byte $06, $00, $01, $06, $02, $06, $03, $02, $04, $03, $05

L885F:  LDY #$33
L8861:  LDA (CrntChrPtr),Y
L8863:  STA $B5
L8865:  LDA #$64
L8867:  STA $B6
L8869:  JSR Multiply            ;($8885)Multiply 2 bytes for a 16 byte result.
L886C:  CLC
L886D:  LDA $B7
L886F:  ADC #$32
L8871:  STA $B7
L8873:  LDA $B8
L8875:  ADC #$00
L8877:  STA $B8
L8879:  LDY #$36
L887B:  LDA $B7
L887D:  STA (CrntChrPtr),Y
L887F:  INY
L8880:  LDA $B8
L8882:  STA (CrntChrPtr),Y
L8884:  RTS

;----------------------------------------------------------------------------------------------------

Multiply:
L8885:  TXA                     ;
L8886:  PHA                     ;
L8887:  LDA #$00                ;
L8889:  STA MultOutLB           ;
L888B:  LDX #$08                ;
L888D:* LSR MultIn0             ;
L888F:  BCC +                   ;Take 2 8-bit number and multiply them
L8891:  CLC                     ;together. The result is a 16-byte number.
L8892:  ADC MultIn1             ;
L8894:* ROR                     ;
L8895:  ROR MultOutLB           ;
L8897:  DEX                     ;
L8898:  BNE --                  ;
L889A:  STA MultOutUB           ;
L889C:  PLA                     ;
L889D:  TAX                     ;
L889E:  RTS                     ;

;----------------------------------------------------------------------------------------------------

;Unused.
L889F:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L88AF:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L88BF:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L88CF:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L88DF:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L88EF:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L88FF:  .byte $00

;----------------------------------------------------------------------------------------------------

SherryTalk:
L8900:  LDA #MUS_CASTLE+INIT    ;Start the Lord British castle music.
L8902:  STA InitNewMusic        ;

L8904:  LDA #$6F                ;I AM SHERRY. THINK ME BEAUTIFUL? text.
L8906:  STA TextIndex           ;

L8908:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L890B:  JSR SelectYesNo         ;($98F7)Show a YES/NO dialog box.
L890E:  BCC +                   ;Did player hit B button? If not, branch.

L8910:  JMP DialogExit          ;($94A9)Exit dialog routines.

L8913:* CMP #WND_NO             ;Did player select no?
L8915:  BEQ +                   ;If so, branch.

L8917:  LDA #$8C                ;THANK YOU. NEXT TIME BRING SOME FLOWERS text.
L8919:  STA TextIndex           ;

L891B:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L891E:  JMP DialogExit          ;($94A9)Exit dialog routines.

L8921:* LDA #$6F                ;I AM SHERRY. THINK ME BEAUTIFUL? text.
L8923:  STA TextIndex           ;

L8925:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L8928:  JSR SelectYesNo         ;($98F7)Show a YES/NO dialog box.
L892B:  BCC +                   ;Did player hit B button? If not, branch.

L892D:  JMP DialogExit          ;($94A9)Exit dialog routines.

L8930:* CMP #WND_NO             ;Did player select no?
L8932:  BEQ --                  ;If so, branch.

L8934:  LDA #$99                ;FLATTERY WILL GET YOU NOWHERE text.
L8936:  STA TextIndex           ;

L8938:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L893B:  JMP DialogExit          ;($94A9)Exit dialog routines.

;----------------------------------------------------------------------------------------------------

SaveGame:
L893E:  LDY #SG_BOAT_X          ;
L8940:  LDA BoatXPos            ;
L8943:  STA (SGDatPtr),Y        ;Save boat X,Y position.
L8945:  INY                     ;
L8946:  LDA BoatYPos            ;
L8949:  STA (SGDatPtr),Y        ;

L894B:  LDY #SG_HORSE           ;
L894D:  LDA OnHorse             ;Save horse status.
L894F:  STA (SGDatPtr),Y        ;

L8951:  LDY #SG_BRIB_PRAY       ;
L8953:  LDA BribePray           ;Save bribe and pray command status.
L8955:  STA (SGDatPtr),Y        ;

L8957:  LDY #SG_PARTY_X         ;
L8959:  LDA MapXPos             ;
L895B:  STA (SGDatPtr),Y        ;Save party's X,Y position on the map.
L895D:  INY                     ;
L895E:  LDA MapYPos             ;
L8960:  STA (SGDatPtr),Y        ;

L8962:  LDY #SG_MAP_PROPS       ;
L8964:  LDA MapProperties       ;Save current map properties.
L8966:  STA (SGDatPtr),Y        ;

L8968:  INY                     ;
L8969:  LDA ThisMap             ;Save current map.
L896B:  STA (SGDatPtr),Y        ;

L896D:  LDA #>Ch1Data           ;
L896F:  STA ChrSrcPtrUB         ;Get pointer to first character's data.
L8971:  LDA #<Ch1Data           ;
L8973:  STA ChrSrcPtrLB         ;

L8975:  LDA #SG_CHR1_INDEX      ;Get the index to the first character data.
L8977:  STA GenByte30

SaveChrsLoop:
L8979:  LDY GenByte30           ;
L897B:  LDA (SGDatPtr),Y        ;Get the index to the first character data in the save game.
L897D:  STA MultIn0             ;

L897F:  LDA #$40                ;*64. 64 bytes of data per character.
L8981:  STA MultIn1             ;
L8983:  JSR Multiply            ;($8885)Multiply 2 bytes for a 16 byte result.

L8986:  CLC                     ;
L8987:  LDA SGDatPtrLB          ;
L8989:  ADC MultOutLB           ;
L898B:  STA ChrDestPtrLB        ;Calculate address to desired character data slot.
L898D:  LDA SGDatPtrUB          ;
L898F:  ADC MultOutUB           ;
L8991:  STA ChrDestPtrUB        ;

L8993:  INC ChrDestPtrUB        ;Index is offset by 256 bytes.
L8995:  LDY #$00                ;

L8997:* LDA (ChrSrcPtr),Y       ;
L8999:  STA (ChrDestPtr),Y      ;
L899B:  INY                     ;Save character data into the save game slot.
L899C:  CPY #$40                ;
L899E:  BNE -                   ;

L89A0:  CLC                     ;
L89A1:  LDA ChrSrcPtrLB         ;Move pointer to the next character data slot.
L89A3:  ADC #$40                ;
L89A5:  STA ChrSrcPtrLB         ;

L89A7:  INC GenByte30           ;
L89A9:  LDA GenByte30           ;Has all 4 character's data been placed in the save game slot?
L89AB:  CMP #SG_CHR4_INDEX+1    ;If not, branch to save another character's data.
L89AD:  BNE SaveChrsLoop        ;

L89AF:  LDY #SG_CHR1_INDEX      ;
L89B1:  LDA Ch1Index            ;
L89B4:  STA (SGDatPtr),Y        ;
L89B6:  INY                     ;
L89B7:  LDA Ch2Index            ;
L89BA:  STA (SGDatPtr),Y        ;
L89BC:  INY                     ;Save the character pool indexes of the 4 active characters.
L89BD:  LDA Ch3Index            ;
L89C0:  STA (SGDatPtr),Y        ;
L89C2:  INY                     ;
L89C3:  LDA Ch4Index            ;
L89C6:  STA (SGDatPtr),Y        ;
L89C8:  RTS                     ;

;----------------------------------------------------------------------------------------------------

;Unused.
L89C9:  .byte $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33
L89D9:  .byte $33, $33, $30, $00, $00, $00, $00, $00, $00, $00, $00, $03, $33, $33, $33, $33
L89E9:  .byte $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33
L89F9:  .byte $33, $33, $30, $00, $00, $00, $00

;----------------------------------------------------------------------------------------------------

FortuneTalk:
L8A00:  LDA #$64                ;ANY WAY I MAY AID THEE? DO YOU WISH TO KNOW YOUR FORTUNE text.
L8A02:  STA TextIndex           ;
L8A04:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.

L8A07:  JSR SelectYesNo         ;($98F7)Show a YES/NO dialog box.
L8A0A:  BCC +                   ;Did player push the A button? If so, branch.
L8A0C:  JMP DialogExit          ;($94A9)Exit dialog routines.

L8A0F:* CMP #$01                ;Did player select NO?
L8A11:  BNE +                   ;If not, branch.

L8A13:  LDA #$66                ;THAT MAY BE WISE text.
L8A15:  JMP LastText            ;($9475)Show last tesxt before exiting.

L8A18:* JSR ChooseChar1         ;($C00C)Select a character from a list.
L8A1B:  BCC +                   ;Did player push the A button? If so, branch.
L8A1D:  JMP DialogExit          ;($94A9)Exit dialog routines.

L8A20:* JSR L9D5E
L8A23:  LDA #$67
L8A25:  STA TextIndex2
L8A28:  LDA #$0A
L8A2A:  STA Wnd2XPos
L8A2D:  LDA #$06
L8A2F:  STA Wnd2YPos
L8A32:  LDA #$0C
L8A34:  STA Wnd2Width
L8A37:  LDA #$0E
L8A39:  STA Wnd2Height
L8A3C:  LDA #$05
L8A3E:  STA NumMenuItems
L8A40:  LDA #$00
L8A42:  STA $9D
L8A44:  JSR _ShowSelectWnd1     ;($C018)Show a window where player makes a selection, variant.
L8A47:  BCC L8A4C
L8A49:  JMP DialogExit          ;($94A9)Exit dialog routines.
L8A4C:  ASL
L8A4D:  PHA
L8A4E:  CLC
L8A4F:  ADC #$01
L8A51:  STA $B5
L8A53:  LDA #$64
L8A55:  STA $B6
L8A57:  JSR Multiply            ;($8885)Multiply 2 bytes for a 16 byte result.
L8A5A:  LDY #$30
L8A5C:  LDA (CrntChrPtr),Y
L8A5E:  SEC
L8A5F:  SBC $B7
L8A61:  STA $2D
L8A63:  INY
L8A64:  LDA (CrntChrPtr),Y
L8A66:  SBC $B8
L8A68:  BCS L8A70
L8A6A:  PLA
L8A6B:  LDA #$68
L8A6D:  JMP LastText            ;($9475)Show last tesxt before exiting.
L8A70:  STA (CrntChrPtr),Y
L8A72:  DEY
L8A73:  LDA $2D
L8A75:  STA (CrntChrPtr),Y
L8A77:  JSR L9D5E
L8A7A:  CLC
L8A7B:  PLA
L8A7C:  LDX $70
L8A7E:  ADC $8A90,X
L8A81:  ADC #$C0
L8A83:  STA TextIndex
L8A85:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L8A88:  LDA #$69
L8A8A:  JMP LastText            ;($9475)Show last tesxt before exiting.
L8A8D:  JMP DialogExit          ;($94A9)Exit dialog routines.

L8A90:  .byte $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01
L8AA0:  .byte $00, $01, $00, $01, $00

L8AA5:  PHA
L8AA6:  LDY $70
L8AA8:  LDA $8E56,Y
L8AAB:  TAY
L8AAC:  PLA
L8AAD:  CMP $8ABB,Y
L8AB0:  BCC L8AB9
L8AB2:  CMP $8ABC,Y
L8AB5:  BCS L8AB9
L8AB7:  CLC
L8AB8:  RTS
L8AB9:  SEC
L8ABA:  RTS

;----------------------------------------------------------------------------------------------------

;Unused.
L8ABB:  .byte $00, $07, $07, $0E, $01, $00, $01, $01, $01, $00, $01, $01, $01, $01, $00, $01
L8ACB:  .byte $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $02, $03, $00, $00, $01, $03
L8ADB:  .byte $04, $64, $00, $64, $00, $C8, $00, $F4, $01, $33, $33, $33, $33, $30, $00, $0C
L8AEB:  .byte $BB, $BB, $BB, $BB, $BC, $BB, $B8, $99, $99, $98, $88, $C0, $03, $33, $33, $33
L8AFB:  .byte $33, $00, $00, $00, $00

;----------------------------------------------------------------------------------------------------

HealerTalk:
L8B00:  LDA #$6A
L8B02:  STA TextIndex
L8B04:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L8B07:  LDX $70
L8B09:  LDA $8ABF,X
L8B0C:  CLC
L8B0D:  ADC #$6B
L8B0F:  STA TextIndex2
L8B12:  LDA #$0A
L8B14:  STA Wnd2XPos
L8B17:  LDA #$06
L8B19:  STA Wnd2YPos
L8B1C:  LDA #$14
L8B1E:  STA Wnd2Width
L8B21:  LDA #$08
L8B23:  ADC $8ABF,X
L8B26:  ADC $8ABF,X
L8B29:  STA Wnd2Height
L8B2C:  CLC
L8B2D:  LDA #$03
L8B2F:  ADC $8ABF,X
L8B32:  STA NumMenuItems
L8B34:  LDA #$00
L8B36:  STA $9D
L8B38:  JSR _ShowSelectWnd1     ;($C018)Show a window where player makes a selection, variant.
L8B3B:  BCC L8B40
L8B3D:  JMP DialogExit          ;($94A9)Exit dialog routines.
L8B40:  PHA
L8B41:  LDX $70
L8B43:  LDA $8ABF,X
L8B46:  ASL
L8B47:  ASL
L8B48:  STA $30
L8B4A:  PLA
L8B4B:  CLC
L8B4C:  ADC $30
L8B4E:  TAX
L8B4F:  LDA $8AD4,X
L8B52:  PHA
L8B53:  CMP #$04
L8B55:  BEQ L8B5E
L8B57:  LDA #$F9
L8B59:  STA TextIndex
L8B5B:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L8B5E:  JSR ChooseChar1         ;($C00C)Select a character from a list.
L8B61:  PLA
L8B62:  BCC L8B67
L8B64:  JMP DialogExit          ;($94A9)Exit dialog routines.
L8B67:  PHA
L8B68:  JSR L9D5E
L8B6B:  PLA
L8B6C:  CMP #$04
L8B6E:  BNE L8B73
L8B70:  JMP L8CC0
L8B73:  PHA
L8B74:  ASL
L8B75:  TAX
L8B76:  LDA $8ADD,X
L8B79:  STA $2E
L8B7B:  LDA $8ADC,X
L8B7E:  STA $2D
L8B80:  LDY #$30
L8B82:  SEC
L8B83:  LDA (CrntChrPtr),Y
L8B85:  SBC $2D
L8B87:  INY
L8B88:  LDA (CrntChrPtr),Y
L8B8A:  SBC $2E
L8B8C:  PLA
L8B8D:  BCS L8B94
L8B8F:  LDA #$68
L8B91:  JMP LastText            ;($9475)Show last tesxt before exiting.
L8B94:  TAX
L8B95:  LDA $99
L8B97:  PHA
L8B98:  LDA $9A
L8B9A:  PHA
L8B9B:  TXA
L8B9C:  PHA
L8B9D:  CMP #$03
L8B9F:  BNE L8BA5
L8BA1:  LDA #CHR_NO_CHK_DEAD
L8BA3:  STA ChkCharDead
L8BA5:  JSR $C042
L8BA8:  PLA
L8BA9:  STA $30
L8BAB:  BCC L8BBA
L8BAD:  CMP #$03
L8BAF:  BNE L8BB5
L8BB1:  LDA #CHR_CHK_DEAD
L8BB3:  STA ChkCharDead
L8BB5:  PLA
L8BB6:  PLA
L8BB7:  JMP DialogExit          ;($94A9)Exit dialog routines.
L8BBA:  CMP #$03
L8BBC:  BNE L8BC2
L8BBE:  LDA #CHR_CHK_DEAD
L8BC0:  STA ChkCharDead
L8BC2:  PLA
L8BC3:  STA $2A
L8BC5:  PLA
L8BC6:  STA $29
L8BC8:  LDA $30
L8BCA:  BNE L8BF7
L8BCC:  LDY #$0B
L8BCE:  LDA (CrntChrPtr),Y
L8BD0:  CMP #$02
L8BD2:  BNE L8BF2
L8BD4:  LDA #$00
L8BD6:  STA (CrntChrPtr),Y
L8BD8:  LDA #$64
L8BDA:  STA $2D
L8BDC:  LDA #$00
L8BDE:  STA $2E
L8BE0:  JSR L8CF1
L8BE3:  JSR L9D5E
L8BE6:  LDA #$EB
L8BE8:  STA TextIndex
L8BEA:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L8BED:  LDA #$76
L8BEF:  JMP LastText            ;($9475)Show last tesxt before exiting.
L8BF2:  LDA #$75
L8BF4:  JMP LastText            ;($9475)Show last tesxt before exiting.
L8BF7:  CMP #$01
L8BF9:  BNE L8C26
L8BFB:  LDY #$0B
L8BFD:  LDA (CrntChrPtr),Y
L8BFF:  CMP #$01
L8C01:  BNE L8C21
L8C03:  LDA #$00
L8C05:  STA (CrntChrPtr),Y
L8C07:  LDA #$64
L8C09:  STA $2D
L8C0B:  LDA #$00
L8C0D:  STA $2E
L8C0F:  JSR L8CF1
L8C12:  JSR L9D5E
L8C15:  LDA #$EB
L8C17:  STA TextIndex
L8C19:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L8C1C:  LDA #$76
L8C1E:  JMP LastText            ;($9475)Show last tesxt before exiting.
L8C21:  LDA #$75
L8C23:  JMP LastText            ;($9475)Show last tesxt before exiting.
L8C26:  CMP #$02
L8C28:  BNE L8C52
L8C2A:  LDY #$36
L8C2C:  LDA (CrntChrPtr),Y
L8C2E:  STA $2D
L8C30:  INY
L8C31:  LDA (CrntChrPtr),Y
L8C33:  STA $2E
L8C35:  JSR AddHP               ;($94AA)Add to character's hit points.
L8C38:  LDA #$C8
L8C3A:  STA $2D
L8C3C:  LDA #$00
L8C3E:  STA $2E
L8C40:  JSR L8CF1
L8C43:  JSR L9D5E
L8C46:  LDA #$EB
L8C48:  STA TextIndex
L8C4A:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L8C4D:  LDA #$76
L8C4F:  JMP LastText            ;($9475)Show last tesxt before exiting.
L8C52:  LDY #$0B
L8C54:  LDA (CrntChrPtr),Y
L8C56:  CMP #$03
L8C58:  BNE L8CB4
L8C5A:  LDA $99
L8C5C:  PHA
L8C5D:  LDA $9A
L8C5F:  PHA
L8C60:  LDA #$F4
L8C62:  STA $2D
L8C64:  LDA #$01
L8C66:  STA $2E
L8C68:  JSR L8CF1
L8C6B:  JSR L9D5E
L8C6E:  PLA
L8C6F:  STA $9A
L8C71:  PLA
L8C72:  STA $99
L8C74:  LDA #$70
L8C76:  STA TextIndex
L8C78:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L8C7B:  LDA #$02
L8C7D:  JSR L992C
L8C80:  BEQ L8CA9
L8C82:  LDY #$0B
L8C84:  LDA #$00
L8C86:  STA (CrntChrPtr),Y
L8C88:  LDY #$2D
L8C8A:  LDA #$96
L8C8C:  STA (CrntChrPtr),Y
L8C8E:  INY
L8C8F:  LDA #$00
L8C91:  STA (CrntChrPtr),Y
L8C93:  JSR $C03F
L8C96:  LDA #$EC
L8C98:  STA TextIndex
L8C9A:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L8C9D:  LDA #$EB
L8C9F:  STA TextIndex
L8CA1:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L8CA4:  LDA #$76
L8CA6:  JMP LastText            ;($9475)Show last tesxt before exiting.
L8CA9:  LDY #$0B
L8CAB:  LDA #$04
L8CAD:  STA (CrntChrPtr),Y
L8CAF:  LDA #$71
L8CB1:  JMP LastText            ;($9475)Show last tesxt before exiting.
L8CB4:  BCC L8CBB
L8CB6:  LDA #$75
L8CB8:  JMP LastText            ;($9475)Show last tesxt before exiting.
L8CBB:  LDA #$75
L8CBD:  JMP LastText            ;($9475)Show last tesxt before exiting.
L8CC0:  LDY #$2D
L8CC2:  SEC
L8CC3:  LDA (CrntChrPtr),Y
L8CC5:  SBC #$64
L8CC7:  STA $2D
L8CC9:  INY
L8CCA:  LDA (CrntChrPtr),Y
L8CCC:  SBC #$00
L8CCE:  BCS L8CD5
L8CD0:  LDA #$72
L8CD2:  JMP LastText            ;($9475)Show last tesxt before exiting.
L8CD5:  LDY #$2E
L8CD7:  STA (CrntChrPtr),Y
L8CD9:  DEY
L8CDA:  LDA $2D
L8CDC:  STA (CrntChrPtr),Y
L8CDE:  LDA #$1E
L8CE0:  STA $2D
L8CE2:  LDA #$00
L8CE4:  STA $2E
L8CE6:  JSR AddGold             ;(L947A)Increase character's gold.
L8CE9:  JSR L9D5E
L8CEC:  LDA #$73
L8CEE:  JMP LastText            ;($9475)Show last tesxt before exiting.
L8CF1:  LDA $2A
L8CF3:  STA $9A
L8CF5:  LDA $29
L8CF7:  STA $99
L8CF9:  JSR L98DB
L8CFC:  RTS

L8CFD:  .byte $00, $00, $00

WeaponTalk:
L8D00:  LDA #$77
L8D02:  STA TextIndex
L8D04:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L8D07:  JSR L98AA
L8D0A:  BCC L8D0F
L8D0C:  JMP DialogExit          ;($94A9)Exit dialog routines.
L8D0F:  CMP #$01
L8D11:  BNE L8D16
L8D13:  JMP L8DDC
L8D16:  JSR ChooseChar1         ;($C00C)Select a character from a list.
L8D19:  BCC L8D1E
L8D1B:  JMP DialogExit          ;($94A9)Exit dialog routines.
L8D1E:  JSR L9D5E
L8D21:  LDX $70
L8D23:  LDA $8E56,X
L8D26:  CLC
L8D27:  ADC #$AE
L8D29:  STA TextIndex2
L8D2C:  LDA #$0C
L8D2E:  STA Wnd2XPos
L8D31:  LDA #$08
L8D33:  STA Wnd2YPos
L8D36:  LDA #$12
L8D38:  STA Wnd2Width
L8D3B:  LDA #$10
L8D3D:  STA Wnd2Height
L8D40:  LDA #$07
L8D42:  STA NumMenuItems
L8D44:  LDA #$00
L8D46:  STA $9D
L8D48:  JSR ShowSelectWnd1      ;($C012)Show a window where player makes a selection.
L8D4B:  BCC L8D50
L8D4D:  JMP DialogExit          ;($94A9)Exit dialog routines.
L8D50:  STA $30
L8D52:  LDX $70
L8D54:  LDA $8E56,X
L8D57:  ASL
L8D58:  ASL
L8D59:  ORA $30
L8D5B:  TAX
L8D5C:  LDA $8E6B,X
L8D5F:  PHA
L8D60:  JSR L941B
L8D63:  PLA
L8D64:  BCC L8D83
L8D66:  PHA
L8D67:  LDA #$83
L8D69:  STA TextIndex
L8D6B:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L8D6E:  JSR SelectYesNo         ;($98F7)Show a YES/NO dialog box.
L8D71:  BCC L8D77
L8D73:  PLA
L8D74:  JMP DialogExit          ;($94A9)Exit dialog routines.
L8D77:  CMP #$01
L8D79:  BEQ L8D7F
L8D7B:  PLA
L8D7C:  JMP L8D83
L8D7F:  PLA
L8D80:  JMP L8D1E
L8D83:  PHA
L8D84:  JSR L9437
L8D87:  PLA
L8D88:  BCC L8D99
L8D8A:  LDA #$84
L8D8C:  STA TextIndex
L8D8E:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L8D91:  BCC L8D96
L8D93:  JMP DialogExit          ;($94A9)Exit dialog routines.
L8D96:  JMP L8DBE
L8D99:  PHA
L8D9A:  ASL
L8D9B:  TAX
L8D9C:  LDA $8E7C,X
L8D9F:  STA $2E
L8DA1:  LDA $8E7B,X
L8DA4:  STA $2D
L8DA6:  JSR L98DB
L8DA9:  PLA
L8DAA:  BCC L8DBB
L8DAC:  LDA #$68
L8DAE:  STA TextIndex
L8DB0:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L8DB3:  BCC L8DB8
L8DB5:  JMP DialogExit          ;($94A9)Exit dialog routines.
L8DB8:  JMP L8DBE
L8DBB:  JSR L9463
L8DBE:  JSR L9D5E
L8DC1:  LDA #$85
L8DC3:  STA TextIndex
L8DC5:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L8DC8:  JSR SelectYesNo         ;($98F7)Show a YES/NO dialog box.
L8DCB:  BCC L8DD0
L8DCD:  JMP DialogExit          ;($94A9)Exit dialog routines.
L8DD0:  CMP #$01
L8DD2:  BEQ L8DD7
L8DD4:  JMP L8D07
L8DD7:  LDA #$86
L8DD9:  JMP LastText            ;($9475)Show last tesxt before exiting.
L8DDC:  JSR ChooseChar1         ;($C00C)Select a character from a list.
L8DDF:  BCC L8DE4
L8DE1:  JMP DialogExit          ;($94A9)Exit dialog routines.
L8DE4:  JSR L9D5E
L8DE7:  JSR L9C40
L8DEA:  BCC L8DEF
L8DEC:  JMP DialogExit          ;($94A9)Exit dialog routines.
L8DEF:  PHA
L8DF0:  JSR L8EB3
L8DF3:  PLA
L8DF4:  BCC L8E00
L8DF6:  LDA #$ED
L8DF8:  STA TextIndex
L8DFA:  JSR ShowDialog1         ;($C00F)Show dialog in lower screen window.
L8DFD:  JMP L8DBE
L8E00:  PHA
L8E01:  JSR L8AA5
L8E04:  PLA
L8E05:  BCC L8E11
L8E07:  LDA #$F1
L8E09:  STA TextIndex
L8E0B:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L8E0E:  JMP L8DBE
L8E11:  PHA
L8E12:  ASL
L8E13:  TAX
L8E14:  LDA $8E97,X
L8E17:  STA $A0
L8E19:  LDA $8E98,X
L8E1C:  STA $A1
L8E1E:  LDA #$D6
L8E20:  STA TextIndex
L8E22:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L8E25:  JSR SelectYesNo         ;($98F7)Show a YES/NO dialog box.
L8E28:  BCC L8E2E
L8E2A:  PLA
L8E2B:  JMP DialogExit          ;($94A9)Exit dialog routines.
L8E2E:  CMP #$01
L8E30:  BNE L8E36
L8E32:  PLA
L8E33:  JMP L8DBE
L8E36:  PLA
L8E37:  PHA
L8E38:  ASL
L8E39:  TAX
L8E3A:  LDA $8E97,X
L8E3D:  STA $2D
L8E3F:  LDA $8E98,X
L8E42:  STA $2E
L8E44:  JSR AddGold             ;(L947A)Increase character's gold.
L8E47:  PLA
L8E48:  CLC
L8E49:  ADC #$0C
L8E4B:  TAY
L8E4C:  LDA (CrntChrPtr),Y
L8E4E:  SEC
L8E4F:  SBC #$01
L8E51:  STA (CrntChrPtr),Y
L8E53:  JMP L8DBE

L8E56:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L8E66:  .byte $00, $00, $00, $02, $00, $00, $01, $02, $03, $04, $05, $06, $00, $07, $08, $09
L8E76:  .byte $0A, $0B, $0C, $0D, $00, $05, $00, $1E, $00, $3C, $00, $7D, $00, $5E, $01, $C8
L8E86:  .byte $00, $FA, $00, $90, $01, $1A, $04, $20, $03, $B0, $04, $8C, $0A, $96, $19, $C6
L8E96:  .byte $11, $04, $00, $19, $00, $32, $00, $64, $00, $18, $01, $A0, $00, $C8, $00, $40
L8EA6:  .byte $01, $48, $03, $80, $02, $C0, $03, $70, $08, $78, $14, $38, $0E

L8EB3:  PHA
L8EB4:  LDY #$34
L8EB6:  LDA (CrntChrPtr),Y
L8EB8:  SEC
L8EB9:  SBC #$01
L8EBB:  STA $30
L8EBD:  PLA
L8EBE:  BCC L8ECF
L8EC0:  CMP $30
L8EC2:  BNE L8ECF
L8EC4:  CLC
L8EC5:  ADC #$0C
L8EC7:  TAY
L8EC8:  LDA (CrntChrPtr),Y
L8ECA:  TAY
L8ECB:  CMP #$01
L8ECD:  BEQ L8ED0
L8ECF:  CLC
L8ED0:  RTS

L8ED1:  .byte $33, $33, $33, $33, $33, $33, $33, $33, $00, $00, $00, $00, $00, $00, $00, $00
L8EE1:  .byte $00, $00, $00, $00, $00, $00, $00, $03, $33, $33, $33, $33, $33, $33, $33, $33
L8EF1:  .byte $33, $33, $33, $33, $33, $33, $30, $00, $00, $00, $00, $00, $00, $00, $00

ArmoryTalk:
L8F00:  LDA #$78
L8F02:  STA TextIndex
L8F04:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L8F07:  JSR L98AA
L8F0A:  BCC L8F0F
L8F0C:  JMP DialogExit          ;($94A9)Exit dialog routines.
L8F0F:  CMP #$01
L8F11:  BNE L8F16
L8F13:  JMP L9349
L8F16:  JSR ChooseChar1         ;($C00C)Select a character from a list.
L8F19:  BCC L8F1E
L8F1B:  JMP DialogExit          ;($94A9)Exit dialog routines.
L8F1E:  JSR L9D5E
L8F21:  LDA #$0C
L8F23:  STA Wnd2XPos
L8F26:  LDA #$08
L8F28:  STA Wnd2YPos
L8F2B:  LDA #$12
L8F2D:  STA Wnd2Width
L8F30:  LDA #$0E
L8F32:  STA Wnd2Height
L8F35:  LDA #$06
L8F37:  STA NumMenuItems
L8F39:  LDA #$00
L8F3B:  STA $9D
L8F3D:  LDA #$AB
L8F3F:  STA TextIndex2
L8F42:  JSR ShowSelectWnd1      ;($C012)Show a window where player makes a selection.
L8F45:  BCC L8F4A
L8F47:  JMP DialogExit          ;($94A9)Exit dialog routines.
L8F4A:  PHA
L8F4B:  JSR L97AC
L8F4E:  PLA
L8F4F:  BCC L8F6E
L8F51:  PHA
L8F52:  LDA #$83
L8F54:  STA TextIndex
L8F56:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L8F59:  JSR SelectYesNo         ;($98F7)Show a YES/NO dialog box.
L8F5C:  BCC L8F62
L8F5E:  PLA
L8F5F:  JMP DialogExit          ;($94A9)Exit dialog routines.
L8F62:  CMP #$01
L8F64:  BEQ L8F6A
L8F66:  PLA
L8F67:  JMP L8F6E
L8F6A:  PLA
L8F6B:  JMP L8F1E
L8F6E:  PHA
L8F6F:  JSR L97C8
L8F72:  PLA
L8F73:  BCC L8F84
L8F75:  LDA #$84
L8F77:  STA TextIndex
L8F79:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L8F7C:  BCC L8F81
L8F7E:  JMP DialogExit          ;($94A9)Exit dialog routines.
L8F81:  JMP L8FA9
L8F84:  PHA
L8F85:  ASL
L8F86:  TAX
L8F87:  LDA $9795,X
L8F8A:  STA $2E
L8F8C:  LDA $9794,X
L8F8F:  STA $2D
L8F91:  JSR L98DB
L8F94:  PLA
L8F95:  BCC L8FA6
L8F97:  LDA #$68
L8F99:  STA TextIndex
L8F9B:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L8F9E:  BCC L8FA3
L8FA0:  JMP DialogExit          ;($94A9)Exit dialog routines.
L8FA3:  JMP L8FA9
L8FA6:  JSR L93C0
L8FA9:  JSR L9D5E
L8FAC:  LDA #$85
L8FAE:  STA TextIndex
L8FB0:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L8FB3:  JSR SelectYesNo         ;($98F7)Show a YES/NO dialog box.
L8FB6:  BCC L8FBB
L8FB8:  JMP DialogExit          ;($94A9)Exit dialog routines.
L8FBB:  CMP #$01
L8FBD:  BEQ L8FC2
L8FBF:  JMP L8F07
L8FC2:  LDA #$86
L8FC4:  JMP LastText            ;($9475)Show last tesxt before exiting.
L8FC7:  PHA
L8FC8:  LDY #$35
L8FCA:  LDA (CrntChrPtr),Y
L8FCC:  SEC
L8FCD:  SBC #$01
L8FCF:  STA $30
L8FD1:  PLA
L8FD2:  BCC L8FE2
L8FD4:  CMP $30
L8FD6:  BNE L8FE2
L8FD8:  CLC
L8FD9:  ADC #$1B
L8FDB:  TAY
L8FDC:  LDA (CrntChrPtr),Y
L8FDE:  CMP #$01
L8FE0:  BEQ L8FE3
L8FE2:  CLC
L8FE3:  RTS

L8FE4:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L8FF4:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

GroceryTalk:
L9000:  LDA #$79
L9002:  STA TextIndex
L9004:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L9007:  JSR ChooseChar1         ;($C00C)Select a character from a list.
L900A:  BCC L900F
L900C:  JMP DialogExit          ;($94A9)Exit dialog routines.
L900F:  JSR L9D5E
L9012:  LDA #$0A
L9014:  STA Wnd2XPos
L9017:  LDA #$04
L9019:  STA Wnd2YPos
L901C:  LDA #$0C
L901E:  STA Wnd2Width
L9021:  LDA #$0A
L9023:  STA Wnd2Height
L9026:  LDA #$03
L9028:  STA NumMenuItems
L902A:  LDA #$00
L902C:  STA $9D
L902E:  LDA #$B1
L9030:  STA TextIndex2
L9033:  JSR _ShowSelectWnd1     ;($C018)Show a window where player makes a selection, variant.
L9036:  BCC L903B
L9038:  JMP DialogExit          ;($94A9)Exit dialog routines.
L903B:  PHA
L903C:  TAX
L903D:  LDA $9088,X
L9040:  STA $2D
L9042:  LDA #$00
L9044:  STA $2E
L9046:  JSR L98DB
L9049:  PHP
L904A:  JSR L9D5E
L904D:  PLP
L904E:  PLA
L904F:  BCC L9060
L9051:  LDA #$68
L9053:  STA TextIndex
L9055:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L9058:  BCC L905D
L905A:  JMP DialogExit          ;($94A9)Exit dialog routines.
L905D:  JMP L906D
L9060:  TAX
L9061:  LDA $9088,X
L9064:  STA $2D
L9066:  LDA #$00
L9068:  STA $2E
L906A:  JSR L908B
L906D:  LDA #$85
L906F:  STA TextIndex
L9071:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L9074:  JSR SelectYesNo         ;($98F7)Show a YES/NO dialog box.
L9077:  BCC L907C
L9079:  JMP DialogExit          ;($94A9)Exit dialog routines.
L907C:  CMP #$01
L907E:  BEQ L9083
L9080:  JMP L900F
L9083:  LDA #$86
L9085:  JMP LastText            ;($9475)Show last tesxt before exiting.

L9088:  .byte $0A, $32, $64

L908B:  LDY #$2B
L908D:  LDA (CrntChrPtr),Y
L908F:  CLC
L9090:  ADC $2D
L9092:  STA $2D
L9094:  INY
L9095:  LDA (CrntChrPtr),Y
L9097:  ADC $2E
L9099:  STA $2E
L909B:  CMP #$27
L909D:  BCC L90AF
L909F:  BNE L90A7
L90A1:  LDA $2D
L90A3:  CMP #$0F
L90A5:  BCC L90AF
L90A7:  LDA #$27
L90A9:  STA $2E
L90AB:  LDA #$0F
L90AD:  STA $2D
L90AF:  LDY #$2B
L90B1:  LDA $2D
L90B3:  STA (CrntChrPtr),Y
L90B5:  INY
L90B6:  LDA $2E
L90B8:  STA (CrntChrPtr),Y
L90BA:  RTS

L90BB:  .byte $44, $44, $44, $44, $44, $44, $44, $44, $22, $24, $44, $44, $44, $44, $44, $44
L90CB:  .byte $24, $24, $42, $24, $22, $22, $44, $44, $44, $44, $00, $00, $44, $44, $40, $00
L90DB:  .byte $04, $40, $00, $44, $44, $44, $44, $42, $22, $22, $44, $C8, $88, $88, $88, $C4
L90EB:  .byte $22, $24, $22, $44, $24, $42, $44, $44, $44, $40, $00, $04, $44, $44, $44, $00
L90FB:  .byte $04, $00, $00, $04, $44

PubTalk:
L9100:  LDA #$88
L9102:  STA TextIndex
L9104:  LDA #$0A
L9106:  STA $A0
L9108:  LDA #$00
L910A:  STA $A1
L910C:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L910F:  LDA #$00
L9111:  STA $48
L9113:  JSR SelectYesNo         ;($98F7)Show a YES/NO dialog box.
L9116:  CMP #$01
L9118:  BEQ L9122
L911A:  JSR ChooseChar1         ;($C00C)Select a character from a list.
L911D:  BCC L9125
L911F:  JMP DialogExit          ;($94A9)Exit dialog routines.
L9122:  JMP L918E
L9125:  JSR L9D5E
L9128:  LDA #$0A
L912A:  STA $2D
L912C:  LDA #$00
L912E:  STA $2E
L9130:  JSR L98DB
L9133:  BCC L913A
L9135:  LDA #$68
L9137:  JMP LastText            ;($9475)Show last tesxt before exiting.
L913A:  JSR L9D5E
L913D:  LDA #$74
L913F:  STA TextIndex
L9141:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L9144:  INC $48
L9146:  LDA $48
L9148:  CMP #$03
L914A:  BCS L9156
L914C:  LDA #$82
L914E:  STA TextIndex
L9150:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L9153:  JMP L9113
L9156:  CMP #$03
L9158:  BNE L916C
L915A:  LDX $70
L915C:  LDA $9193,X
L915F:  STA TextIndex
L9161:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L9164:  BCC L9169
L9166:  JMP DialogExit          ;($94A9)Exit dialog routines.
L9169:  JMP L914C
L916C:  CMP #$04
L916E:  BNE L917F
L9170:  LDA #$7E
L9172:  STA TextIndex
L9174:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L9177:  BCC L917C
L9179:  JMP DialogExit          ;($94A9)Exit dialog routines.
L917C:  JMP L914C
L917F:  LDX $70
L9181:  LDA $91A7,X
L9184:  STA TextIndex
L9186:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L9189:  BCC L918E
L918B:  JMP DialogExit          ;($94A9)Exit dialog routines.
L918E:  LDA #$89
L9190:  JMP LastText            ;($9475)Show last tesxt before exiting.

L9193:  .byte $7E, $B9, $7E, $7E, $BA, $7E, $7E, $B7, $7E, $7E, $B8, $BD, $7E, $BE, $7E, $7E 
L91A3:  .byte $7E, $BC, $BB, $BF, $7E, $7F, $7E, $7E, $BA, $7E, $7E, $B7, $7E, $7E, $B8, $BD
L91B3:  .byte $7E, $7F, $7E, $7E, $7E, $BC, $BB, $BF, $44, $77, $77, $74, $44, $44, $24, $24
L91C3:  .byte $44, $44, $44, $00, $04, $44, $00, $04, $44, $22, $22, $22, $22, $24, $44, $40
L91D3:  .byte $00, $44, $44, $44, $44, $40, $00, $04, $44, $77, $77, $74, $44, $44, $22, $22
L91E3:  .byte $22, $44, $44, $00, $04, $44, $00, $04, $44, $42, $22, $24, $42, $44, $44, $40
L91F3:  .byte $00, $44, $44, $44, $44, $40, $00, $44, $44, $77, $77, $74, $44

;----------------------------------------------------------------------------------------------------

GuildTalk:
L9200:  LDA #$7A
L9202:  STA TextIndex
L9204:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L9207:  JSR ChooseChar1         ;($C00C)Select a character from a list.
L920A:  BCC L920F
L920C:  JMP DialogExit          ;($94A9)Exit dialog routines.

L920F:  JSR L9D5E
L9212:  LDA #$0C
L9214:  STA Wnd2XPos
L9217:  LDA #$08
L9219:  STA Wnd2YPos
L921C:  LDA #$12
L921E:  STA Wnd2Width
L9221:  LDA #$0C
L9223:  STA Wnd2Height
L9226:  LDA #$05
L9228:  STA NumMenuItems
L922A:  LDA #$00
L922C:  STA $9D
L922E:  LDA #$AC
L9230:  STA TextIndex2
L9233:  JSR ShowSelectWnd1      ;($C012)Show a window where player makes a selection.
L9236:  BCC L923B
L9238:  JMP DialogExit          ;($94A9)Exit dialog routines.
L923B:  TAX
L923C:  LDA $929B,X
L923F:  PHA
L9240:  JSR L92A0
L9243:  PLA
L9244:  BCC L9255
L9246:  LDA #$84
L9248:  STA TextIndex
L924A:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L924D:  BCC L9252
L924F:  JMP DialogExit          ;($94A9)Exit dialog routines.
L9252:  JMP L9278
L9255:  PHA
L9256:  TAX
L9257:  LDA $9296,X
L925A:  STA $2D
L925C:  LDA #$00
L925E:  STA $2E
L9260:  JSR L98DB
L9263:  PLA
L9264:  BCC L9275
L9266:  LDA #$68
L9268:  STA TextIndex
L926A:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L926D:  BCC L9272
L926F:  JMP DialogExit          ;($94A9)Exit dialog routines.
L9272:  JMP L9278
L9275:  JSR L92B3
L9278:  JSR L9D5E
L927B:  LDA #$85
L927D:  STA TextIndex
L927F:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L9282:  JSR SelectYesNo         ;($98F7)Show a YES/NO dialog box.
L9285:  BCC L928A
L9287:  JMP DialogExit          ;($94A9)Exit dialog routines.
L928A:  CMP #$01
L928C:  BEQ L9291
L928E:  JMP L9207
L9291:  LDA #$86
L9293:  JMP LastText            ;($9475)Show last tesxt before exiting.

L9296:  .byte $1E, $32, $4B, $5A, $64, $00, $01, $02, $03, $04

L92A0:  CMP #$07
L92A2:  BCC L92A5
L92A4:  RTS
L92A5:  CLC
L92A6:  ADC #$22
L92A8:  TAY
L92A9:  LDA (CrntChrPtr),Y
L92AB:  CLC
L92AC:  ADC #$01
L92AE:  CMP #$64
L92B0:  BCC L92B2
L92B2:  RTS
L92B3:  CLC
L92B4:  ADC #$22
L92B6:  TAY
L92B7:  LDA (CrntChrPtr),Y
L92B9:  CLC
L92BA:  ADC #$01
L92BC:  CPY #$22
L92BE:  BNE L92C3
L92C0:  CLC
L92C1:  ADC #$04
L92C3:  CMP #$64
L92C5:  BCC L92C9
L92C7:  LDA #$63
L92C9:  STA (CrntChrPtr),Y
L92CB:  RTS

L92CC:  .byte $44, $44, $44, $44, $44, $44, $40, $00, $44, $44, $40, $00, $04, $44, $44, $44
L92DC:  .byte $77, $77, $74, $44, $04, $42, $22, $22, $22, $44, $44, $42, $22, $44, $44, $44
L92EC:  .byte $44, $44, $44, $44, $44, $44, $40, $00, $44, $44, $40, $00, $44, $44, $44, $44
L92FC:  .byte $77, $77, $74, $44

StableTalk:
L9300:  LDA #$8B
L9302:  STA TextIndex
L9304:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L9307:  JSR SelectYesNo         ;($98F7)Show a YES/NO dialog box.
L930A:  CMP #$01
L930C:  BNE L9313
L930E:  LDA #$8E
L9310:  JMP LastText            ;($9475)Show last tesxt before exiting.
L9313:  LDA OnHorse
L9315:  BEQ L931C
L9317:  LDA #$8D
L9319:  JMP LastText            ;($9475)Show last tesxt before exiting.
L931C:  JSR ChooseChar1         ;($C00C)Select a character from a list.
L931F:  BCC L9324
L9321:  JMP DialogExit          ;($94A9)Exit dialog routines.
L9324:  JSR L9D5E
L9327:  LDA #$03
L9329:  STA $2E
L932B:  LDA #$20
L932D:  STA $2D
L932F:  JSR L98DB
L9332:  BCC L933B
L9334:  LDA #$68
L9336:  STA $30
L9338:  JMP LastText            ;($9475)Show last tesxt before exiting.
L933B:  JSR L9D5E
L933E:  LDA #$01
L9340:  STA OnHorse
L9342:  LDA #$8F
L9344:  STA $30
L9346:  JMP LastText            ;($9475)Show last tesxt before exiting.

L9349:  JSR ChooseChar1         ;($C00C)Select a character from a list.
L934C:  BCC L9351
L934E:  JMP DialogExit          ;($94A9)Exit dialog routines.
L9351:  JSR L9D5E
L9354:  JSR L9D00
L9357:  BCC L935C
L9359:  JMP DialogExit          ;($94A9)Exit dialog routines.
L935C:  PHA
L935D:  JSR L8FC7
L9360:  PLA
L9361:  BCC L936D
L9363:  LDA #$ED
L9365:  STA TextIndex
L9367:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L936A:  JMP L8FA9
L936D:  CMP #$06
L936F:  BCC L937B
L9371:  LDA #$F1
L9373:  STA TextIndex
L9375:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L9378:  JMP L8FA9
L937B:  PHA
L937C:  ASL
L937D:  TAX
L937E:  LDA $97A0,X
L9381:  STA $A0
L9383:  LDA $97A1,X
L9386:  STA $A1
L9388:  LDA #$D6
L938A:  STA TextIndex
L938C:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L938F:  JSR SelectYesNo         ;($98F7)Show a YES/NO dialog box.
L9392:  BCC L9398
L9394:  PLA
L9395:  JMP DialogExit          ;($94A9)Exit dialog routines.
L9398:  CMP #$01
L939A:  BNE L93A0
L939C:  PLA
L939D:  JMP L8FA9
L93A0:  PLA
L93A1:  PHA
L93A2:  ASL
L93A3:  TAX
L93A4:  LDA $97A0,X
L93A7:  STA $2D
L93A9:  LDA $97A1,X
L93AC:  STA $2E
L93AE:  JSR AddGold             ;(L947A)Increase character's gold.
L93B1:  PLA
L93B2:  CLC
L93B3:  ADC #$1B
L93B5:  TAY
L93B6:  LDA (CrntChrPtr),Y
L93B8:  SEC
L93B9:  SBC #$01
L93BB:  STA (CrntChrPtr),Y
L93BD:  JMP L8FA9
L93C0:  CMP #$07
L93C2:  BCC L93C5
L93C4:  RTS
L93C5:  CLC
L93C6:  ADC #$1B
L93C8:  TAY
L93C9:  LDA (CrntChrPtr),Y
L93CB:  CLC
L93CC:  ADC #$01
L93CE:  CMP #$64
L93D0:  BCC L93D4
L93D2:  LDA #$63
L93D4:  STA (CrntChrPtr),Y
L93D6:  RTS

L93D7L:  .byte $04, $4C, $BB, $BB, $BB, $BC, $47, $77, $44, $00, $00, $00, $00, $00, $00, $C0
L93E7L:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $0C, $00, $00, $04, $04, $44, $00
L93F7L:  .byte $00, $08, $99, $99, $99, $9C, $47, $77, $74

InnTalk:
L9400:  LDA #$90
L9402:  STA TextIndex
L9404:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L9407:  JSR SelectYesNo         ;($98F7)Show a YES/NO dialog box.
L940A:  CMP #$01
L940C:  BNE L9412
L940E:  SEC
L940F:  JMP DialogExit          ;($94A9)Exit dialog routines.
L9412:  JSR L893E
L9415:  LDA #$91
L9417:  CLC
L9418:  JMP LastText            ;($9475)Show last tesxt before exiting.
L941B:  CMP #$0E
L941D:  BNE L9421
L941F:  CLC
L9420:  RTS

L9421:  .byte $48, $A0, $06, $B1, $99, $AA, $68, $DD, $2C, $94, $60, $0F, $02, $01, $06, $0F
L9431:  .byte $0F, $0F, $02, $02

L9435:  ORA ($0A,X)
L9437:  CLC
L9438:  ADC #$0C
L943A:  STA $30
L943C:  LDX #$00
L943E:  LDY #$0C
L9440:  LDA (CrntChrPtr),Y
L9442:  BEQ L9449
L9444:  INX
L9445:  CPY $30
L9447:  BEQ L9453
L9449:  INY
L944A:  CPX #$09
L944C:  BCC L944F
L944E:  RTS
L944F:  CPY #$1B
L9451:  BNE L9440
L9453:  CLC
L9454:  LDA $30
L9456:  TAY
L9457:  LDA (CrntChrPtr),Y
L9459:  CLC
L945A:  ADC #$01
L945C:  CMP #$64
L945E:  BCC L9462
L9460:  LDA #$63
L9462:  RTS
L9463:  CLC
L9464:  ADC #$0C
L9466:  TAY
L9467:  LDA (CrntChrPtr),Y
L9469:  CLC
L946A:  ADC #$01
L946C:  CMP #$64
L946E:  BCC L9472
L9470:  LDA #$63
L9472:  STA (CrntChrPtr),Y
L9474:  RTS

;----------------------------------------------------------------------------------------------------

LastText:
L9475:  STA TextIndex           ;Set the text and display it.
L9477:  JMP ShowDialog1         ;($C00F)Show dialog in bottom screen window.

;----------------------------------------------------------------------------------------------------

AddGold:
L947A:  LDY #CHR_GOLD
L947C:  LDA (CrntChrPtr),Y
L947E:  CLC
L947F:  ADC $2D
L9481:  STA $2D
L9483:  INY
L9484:  LDA (CrntChrPtr),Y
L9486:  ADC $2E
L9488:  STA $2E
L948A:  CMP #$27
L948C:  BCC L949E
L948E:  BNE L9496
L9490:  LDA $2D
L9492:  CMP #$0F
L9494:  BCC L949E
L9496:  LDA #$27
L9498:  STA $2E
L949A:  LDA #$0F
L949C:  STA $2D
L949E:  LDY #CHR_GOLD
L94A0:  LDA $2D
L94A2:  STA (CrntChrPtr),Y
L94A4:  INY
L94A5:  LDA $2E
L94A7:  STA (CrntChrPtr),Y

;----------------------------------------------------------------------------------------------------

DialogExit:
L94A9:  RTS                     ;Exit from dialog routines.

;----------------------------------------------------------------------------------------------------

AddHP:
L94AA:  LDY #CHR_HIT_PNTS
L94AC:  LDA (CrntChrPtr),Y
L94AE:  CLC
L94AF:  ADC $2D
L94B1:  STA $2D
L94B3:  INY
L94B4:  LDA (CrntChrPtr),Y
L94B6:  ADC $2E
L94B8:  STA $2E
L94BA:  LDY #$37
L94BC:  CMP (CrntChrPtr),Y
L94BE:  BCC L94D4
L94C0:  BNE L94C9
L94C2:  LDA $2D
L94C4:  DEY
L94C5:  CMP (CrntChrPtr),Y
L94C7:  BCC L94D4
L94C9:  LDY #$36
L94CB:  LDA (CrntChrPtr),Y
L94CD:  STA $2D
L94CF:  INY
L94D0:  LDA (CrntChrPtr),Y
L94D2:  STA $2E
L94D4:  LDY #CHR_HIT_PNTS
L94D6:  LDA $2D
L94D8:  STA (CrntChrPtr),Y
L94DA:  INY
L94DB:  LDA $2E
L94DD:  STA (CrntChrPtr),Y
L94DF:  RTS

;----------------------------------------------------------------------------------------------------

;Unused.
L94E0:  .byte $00, $22, $44, $44, $22, $24, $44, $42, $22, $44, $44, $44, $44, $44, $44, $44
L94F0:  .byte $44, $44, $40, $00, $44, $44, $00, $04, $44, $44, $44, $44, $44, $47, $74, $44

;----------------------------------------------------------------------------------------------------

TempleTalk:
L9500:  LDA #$92
L9502:  STA TextIndex
L9504:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L9507:  LDA #$0A
L9509:  STA Wnd2XPos
L950C:  LDA #$06
L950E:  STA Wnd2YPos
L9511:  LDA #$0E
L9513:  STA Wnd2Width
L9516:  LDA #$02
L9518:  STA NumMenuItems
L951A:  LDA #$00
L951C:  STA $9D
L951E:  LDA #$93
L9520:  STA TextIndex2
L9523:  JSR ShowSelectWnd1      ;($C012)Show a window where player makes a selection.
L9526:  BCC L952B
L9528:  JMP DialogExit          ;($94A9)Exit dialog routines.
L952B:  CMP #$01
L952D:  BEQ L9534
L952F:  LDA #$94
L9531:  JMP LastText            ;($9475)Show last tesxt before exiting.
L9534:  LDA #$96
L9536:  STA TextIndex
L9538:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L953B:  LDA #$F9
L953D:  STA TextIndex
L953F:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L9542:  JSR ChooseChar1         ;($C00C)Select a character from a list.
L9545:  BCC L954A
L9547:  JMP DialogExit          ;($94A9)Exit dialog routines.
L954A:  JSR L9D5E
L954D:  LDY #$30
L954F:  INY
L9550:  LDA (CrntChrPtr),Y
L9552:  CMP #$03
L9554:  BCS L9564
L9556:  BNE L955F
L9558:  DEY
L9559:  LDA (CrntChrPtr),Y
L955B:  CMP #$84
L955D:  BCS L9564
L955F:  LDA #$68
L9561:  JMP LastText            ;($9475)Show last tesxt before exiting.
L9564:  LDA $99
L9566:  PHA
L9567:  LDA $9A
L9569:  PHA
L956A:  LDA #CHR_NO_CHK_DEAD
L956C:  STA ChkCharDead
L956E:  JSR $C042
L9571:  LDA #CHR_CHK_DEAD
L9573:  STA ChkCharDead
L9575:  PLA
L9576:  STA $2A
L9578:  PLA
L9579:  STA $29
L957B:  BCC L9580
L957D:  JMP DialogExit          ;($94A9)Exit dialog routines.
L9580:  LDY #$0B
L9582:  LDA (CrntChrPtr),Y
L9584:  CMP #$03
L9586:  BCS L958D
L9588:  LDA #$75
L958A:  JMP LastText            ;($9475)Show last tesxt before exiting.
L958D:  LDA #$03
L958F:  STA $2E
L9591:  LDA #$84
L9593:  STA $2D
L9595:  LDA $99
L9597:  PHA
L9598:  LDA $9A
L959A:  PHA
L959B:  JSR L8CF1
L959E:  JSR L9D5E
L95A1:  PLA
L95A2:  STA $9A
L95A4:  PLA
L95A5:  STA $99
L95A7:  LDA $00
L95A9:  AND #$07
L95AB:  BNE L95B8
L95AD:  LDA #$04
L95AF:  LDY #$0B
L95B1:  STA (CrntChrPtr),Y
L95B3:  LDA #$97
L95B5:  JMP LastText            ;($9475)Show last tesxt before exiting.
L95B8:  LDY #$0B
L95BA:  LDA #$00
L95BC:  STA (CrntChrPtr),Y
L95BE:  LDY #$2D
L95C0:  LDA #$96
L95C2:  STA (CrntChrPtr),Y
L95C4:  INY
L95C5:  LDA #$00
L95C7:  STA (CrntChrPtr),Y
L95C9:  JSR $C03F
L95CC:  LDA #$EA
L95CE:  STA TextIndex
L95D0:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L95D3:  JMP DialogExit          ;($94A9)Exit dialog routines.
L95D6:  JSR L9D5E
L95D9:  LDA #$9E
L95DB:  JMP LastText            ;($9475)Show last tesxt before exiting.
L95DE:  LDA #$D8
L95E0:  STA TextIndex
L95E2:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L95E5:  BCC L95EA
L95E7:  JMP DialogExit          ;($94A9)Exit dialog routines.
L95EA:  JMP L965D

L95ED:  .byte $0A, $32, $64, $02, $02, $03, $05, $07, $0C, $40, $50, $60, $04, $44, $44, $77
L95FD:  .byte $77, $74, $44

CasinoTalk:
L9600:  LDA #$98
L9602:  STA TextIndex
L9604:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L9607:  JSR SelectYesNo         ;($98F7)Show a YES/NO dialog box.
L960A:  CMP #$01
L960C:  BNE L9613
L960E:  LDA #$9A
L9610:  JMP LastText            ;($9475)Show last tesxt before exiting.
L9613:  JSR ChooseChar1         ;($C00C)Select a character from a list.
L9616:  BCC L961B
L9618:  JMP DialogExit          ;($94A9)Exit dialog routines.
L961B:  JSR L9D5E
L961E:  LDA #$0A
L9620:  STA Wnd2XPos
L9623:  LDA #$06
L9625:  STA Wnd2YPos
L9628:  LDA #$0A
L962A:  STA Wnd2Width
L962D:  LDA #$0A
L962F:  STA Wnd2Height
L9632:  LDA #$03
L9634:  STA NumMenuItems
L9636:  LDA #$00
L9638:  STA $9D
L963A:  LDA #$9B
L963C:  STA TextIndex2
L963F:  JSR _ShowSelectWnd1     ;($C018)Show a window where player makes a selection, variant.
L9642:  BCC L9647
L9644:  JMP DialogExit          ;($94A9)Exit dialog routines.
L9647:  STA $48
L9649:  TAX
L964A:  LDA $95ED,X
L964D:  STA $2D
L964F:  LDA #$00
L9651:  STA $2E
L9653:  JSR L98DB
L9656:  BCC L965D
L9658:  LDA #$68
L965A:  JMP LastText            ;($9475)Show last tesxt before exiting.
L965D:  LDA #$0A
L965F:  STA Wnd2XPos
L9662:  LDA #$06
L9664:  STA Wnd2YPos
L9667:  LDA #$08
L9669:  STA Wnd2Width
L966C:  LDA #$08
L966E:  STA Wnd2Height
L9671:  LDA #$03
L9673:  STA NumMenuItems
L9675:  LDA #$00
L9677:  STA $9D

L9679:  LDA #$9C                ;STN SCR PPR text.
L967B:  STA TextIndex2          ;
L967E:  JSR ShowSelectWnd1      ;($C012)Show a window where player makes a selection.

L9681:  BCC L9686
L9683:  JMP DialogExit          ;($94A9)Exit dialog routines.
L9686:  PHA
L9687:  JSR L99AE
L968A:  LDA #SFX_CASINO+INIT
L968C:  STA ThisSFX
L968E:  LDA #$78
L9690:  STA $7303
L9693:  LDA #$03
L9695:  JSR L992C
L9698:  STA $2C
L969A:  PLA
L969B:  STA $2B
L969D:  LDY #$00
L969F:  STY $2D
L96A1:  LDX #$03
L96A3:  LDA $95F0,Y
L96A6:  STA $30
L96A8:  LDA $00
L96AA:  CMP $00
L96AC:  BEQ L96AA
L96AE:  DEC $30
L96B0:  BNE L96A8
L96B2:  DEX
L96B3:  LDA $95F6,X
L96B6:  STA $7300
L96B9:  CPX $2D
L96BB:  BNE L96A3
L96BD:  INY
L96BE:  CPY #$05
L96C0:  BCC L96A1
L96C2:  CPY #$05
L96C4:  BNE L96CD
L96C6:  LDA $2C
L96C8:  STA $2D
L96CA:  JMP L96A1
L96CD:  LDA $2B
L96CF:  CMP $2D
L96D1:  BNE L96D6
L96D3:  JMP L95DE
L96D6:  CLC
L96D7:  ADC #$01
L96D9:  CMP #$03
L96DB:  BNE L96DF
L96DD:  LDA #$00
L96DF:  CMP $2D
L96E1:  BEQ L96E6
L96E3:  JMP L95D6
L96E6:  LDX $48
L96E8:  LDA $95ED,X
L96EB:  ASL
L96EC:  CLC
L96ED:  STA $2D
L96EF:  LDA #$00
L96F1:  STA $2E
L96F3:  JSR AddGold             ;(L947A)Increase character's gold.
L96F6:  JSR L9D5E
L96F9:  LDA #$9D
L96FB:  JMP LastText            ;($9475)Show last tesxt before exiting.

L96FE:  .byte $04, $44

ShrineTalk:
L9700:  LDA ThisMap
L9702:  SEC
L9703:  SBC #$15
L9705:  TAX
L9706:  LDA $9778,X
L9709:  STA TextIndex
L970B:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L970E:  JSR ChooseChar1         ;($C00C)Select a character from a list.
L9711:  BCC L9716
L9713:  JMP DialogExit          ;($94A9)Exit dialog routines.
L9716:  JSR L9D5E
L9719:  LDA #$64
L971B:  STA $2D
L971D:  LDA #$00
L971F:  STA $2E
L9721:  JSR L98DB
L9724:  BCC L972B
L9726:  LDA #$68
L9728:  JMP LastText            ;($9475)Show last tesxt before exiting.
L972B:  LDY #$05
L972D:  LDA (CrntChrPtr),Y
L972F:  ASL
L9730:  ASL
L9731:  STA $30
L9733:  LDA $70
L9735:  SEC
L9736:  SBC #$15
L9738:  AND #$03
L973A:  PHA
L973B:  TAX
L973C:  LDA $977C,X
L973F:  TAY
L9740:  PLA
L9741:  ORA $30
L9743:  TAX
L9744:  LDA (CrntChrPtr),Y
L9746:  CLC
L9747:  ADC #$01
L9749:  CMP $9780,X
L974C:  BCC L9751
L974E:  LDA $9780,X
L9751:  STA (CrntChrPtr),Y
L9753:  JSR L881C
L9756:  LDA #$02
L9758:  JSR FlashAndSound1      ;($C04E)Flash screen with SFX.
L975B:  LDA #$A0
L975D:  STA TextIndex
L975F:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L9762:  JSR L9D5E
L9765:  JSR SelectYesNo         ;($98F7)Show a YES/NO dialog box.
L9768:  BCC L976D
L976A:  JMP DialogExit          ;($94A9)Exit dialog routines.
L976D:  CMP #$00
L976F:  BEQ L9716
L9771:  LDA #$A1
L9773:  STA $30
L9775:  JMP LastText            ;($9475)Show last tesxt before exiting.

L9778:  .byte $7B, $7C, $7D, $9F, $09, $0A, $07, $08, $4B, $4B, $4B, $4B, $4B, $32, $4B, $63
L9788:  .byte $32, $4B, $63, $4B, $4B, $63, $4B, $32, $63, $4B, $19, $63, $4B, $00, $C3, $00
L9798:  .byte $3F, $02, $C4, $09, $F2, $17, $3A, $20, $3C, $00, $A0, $00, $CC, $01, $D0, $07
L97A8:  .byte $24, $13, $C8, $19

L97AC:  CMP #$07
L97AE:  BNE L97B2
L97B0:  CLC
L97B1:  RTS
L97B2:  PHA
L97B3:  LDY #$06
L97B5:  LDA (CrntChrPtr),Y
L97B7:  TAX
L97B8:  PLA
L97B9:  CMP $97BD,X
L97BC:  RTS

L97BD:  .byte $07, $03, $01, $02, $04, $02, $01, $02, $01, $01, $06

L97C8:  CLC
L97C9:  ADC #$1B
L97CB:  TAY
L97CC:  LDA (CrntChrPtr),Y
L97CE:  CLC
L97CF:  ADC #$01
L97D1:  CMP #$64
L97D3:  BCC L97D5
L97D5:  RTS

L97D6:  .byte $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44
L97E6:  .byte $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44
L97F6:  .byte $44, $44, $44, $44, $44, $44, $44, $44, $44, $44

LBTalk:
L9800:  JSR ChooseChar1         ;($C00C)Select a character from a list.
L9803:  BCC L9808
L9805:  JMP DialogExit          ;($94A9)Exit dialog routines.
L9808:  LDA #$8A
L980A:  STA $C1
L980C:  LDY #$3B
L980E:  LDA (CrntChrPtr),Y
L9810:  AND #$08
L9812:  BNE L9843
L9814:  LDA #$05
L9816:  STA $30
L9818:  JSR L9872
L981B:  BCS L9833

L981D:  LDA #$CB                ;WELCOME BACK! I WILL GIVE YOU MORE POWER text.
L981F:  STA TextIndex           ;
L9821:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.

L9824:  LDA #SFX_SPELL_B+INIT
L9826:  STA ThisSFX
L9828:  LDA #$01
L982A:  JSR FlashAndSound1      ;($C04E)Flash screen with SFX.
L982D:  JSR L8800
L9830:  JMP DialogExit          ;($94A9)Exit dialog routines.
L9833:  LDA $29
L9835:  CMP #$06
L9837:  BCS L983E
L9839:  LDA #$CA
L983B:  JMP LastText            ;($9475)Show last tesxt before exiting.
L983E:  LDA #$D0
L9840:  JMP LastText            ;($9475)Show last tesxt before exiting.
L9843:  LDA #$19
L9845:  STA $30
L9847:  JSR L9872
L984A:  BCS L9862
L984C:  LDA #$CB
L984E:  STA TextIndex
L9850:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L9853:  LDA #SFX_SPELL_B+INIT
L9855:  STA ThisSFX
L9857:  LDA #$01
L9859:  JSR FlashAndSound1      ;($C04E)Flash screen with SFX.
L985C:  JSR L8800
L985F:  JMP DialogExit          ;($94A9)Exit dialog routines.
L9862:  LDA $29
L9864:  CMP #$19
L9866:  BCS L986D
L9868:  LDA #$CA
L986A:  JMP LastText            ;($9475)Show last tesxt before exiting.
L986D:  LDA #$CC
L986F:  JMP LastText            ;($9475)Show last tesxt before exiting.
L9872:  LDY #$39
L9874:  LDA (CrntChrPtr),Y
L9876:  STA $29
L9878:  INY
L9879:  LDA (CrntChrPtr),Y
L987B:  STA $2A
L987D:  LDA #$00
L987F:  LDX #$10
L9881:  ROL $29
L9883:  ROL $2A
L9885:  ROL
L9886:  CMP #$64
L9888:  BCC L988C
L988A:  SBC #$64
L988C:  ROL $29
L988E:  ROL $2A
L9890:  DEX
L9891:  BNE L9885
L9893:  INC $29
L9895:  LDA $29
L9897:  CMP $30
L9899:  BCC L989D
L989B:  LDA $30
L989D:  STA $30
L989F:  LDY #$33
L98A1:  LDA (CrntChrPtr),Y
L98A3:  CMP $30
L98A5:  LDA $30
L98A7:  STA (CrntChrPtr),Y
L98A9:  RTS
L98AA:  LDA #$0A
L98AC:  STA Wnd2XPos
L98AF:  LDA #$04
L98B1:  STA Wnd2YPos
L98B4:  LDA #$0A
L98B6:  STA Wnd2Width
L98B9:  LDA #$06
L98BB:  STA Wnd2Height
L98BE:  LDA #$02
L98C0:  STA NumMenuItems
L98C2:  LDA #$00
L98C4:  STA $9D
L98C6:  LDA #$80
L98C8:  STA TextIndex2
L98CB:  JSR ShowSelectWnd1      ;($C012)Show a window where player makes a selection.
L98CE:  PHP
L98CF:  PHA
L98D0:  JSR L99AE
L98D3:  PLA
L98D4:  PLP
L98D5:  BCS L98D8
L98D7:  RTS
L98D8:  LDA #$01
L98DA:  RTS
L98DB:  LDY #$30
L98DD:  SEC
L98DE:  LDA (CrntChrPtr),Y
L98E0:  SBC $2D
L98E2:  STA $2D
L98E4:  INY
L98E5:  LDA (CrntChrPtr),Y
L98E7:  SBC $2E
L98E9:  BCS L98EE
L98EB:  DEY
L98EC:  SEC
L98ED:  RTS
L98EE:  STA (CrntChrPtr),Y
L98F0:  DEY
L98F1:  LDA $2D
L98F3:  STA (CrntChrPtr),Y
L98F5:  CLC
L98F6:  RTS

SelectYesNo:
L98F7:  LDA #$0C
L98F9:  STA Wnd2XPos
L98FC:  LDA #$08
L98FE:  STA Wnd2YPos
L9901:  LDA #$06
L9903:  STA Wnd2Width
L9906:  LDA #$06
L9908:  STA Wnd2Height
L990B:  LDA #$02
L990D:  STA NumMenuItems
L990F:  LDA #$00
L9911:  STA $9D
L9913:  LDA #$65
L9915:  STA TextIndex2
L9918:  JSR ShowSelectWnd1      ;($C012)Show a window where player makes a selection.
L991B:  PHP
L991C:  PHA
L991D:  JSR L99AE
L9920:  LDA $C8
L9922:  STA HideUprSprites
L9924:  PLA
L9925:  PLP
L9926:  BCS L9929
L9928:  RTS
L9929:  LDA #$01
L992B:  RTS
L992C:  STA $B5
L992E:  LDA $BA
L9930:  CLC
L9931:  ADC $00
L9933:  ADC $01
L9935:  STA $B6
L9937:  JSR Multiply            ;($8885)Multiply 2 bytes for a 16 byte result.
L993A:  LDA $B7
L993C:  ADC $B8
L993E:  STA $BA
L9940:  LDA $B8
L9942:  RTS

;----------------------------------------------------------------------------------------------------

DoBinToBCD:
L9943:  PHA                     ;Save A on the stack before beginning.

L9944:  LDA #TP_ZERO            ;
L9946:  STA BCDOutput0          ;
L9948:  STA BCDOutput1          ;Set all the output digits to zero.
L994A:  STA BCDOutput2          ;
L994C:  STA BCDOutput3          ;

L994E:* SEC                     ;
L994F:  LDA BinInputLB          ;
L9951:  SBC #$E8                ;
L9953:  STA BinInputLB          ;Keep subtracting 1,000 until number goes negative.
L9955:  LDA BinInputUB          ;
L9957:  SBC #$03                ;
L9959:  STA BinInputUB          ;
L995B:  BCC +                   ;

L995D:  INC BCDOutput0          ;Increment thousands digit for each subtrct loop.
L995F:  JMP -                   ;

L9962:* CLC                     ;
L9963:  LDA BinInputLB          ;
L9965:  ADC #$E8                ;
L9967:  STA BinInputLB          ;Undo last 1,000 subtract to put number positive again.
L9969:  LDA BinInputUB          ;
L996B:  ADC #$03                ;
L996D:  STA BinInputUB          ;

L996F:* SEC                     ;
L9970:  LDA BinInputLB          ;
L9972:  SBC #$64                ;
L9974:  STA BinInputLB          ;Keep subtracting 100 until number goes negative.
L9976:  LDA BinInputUB          ;
L9978:  SBC #$00                ;
L997A:  STA BinInputUB          ;
L997C:  BCC +                   ;

L997E:  INC BCDOutput1          ;Increment hundreds digit for each subtrct loop.
L9980:  JMP -                   ;

L9983:* CLC                     ;
L9984:  LDA BinInputLB          ;
L9986:  ADC #$64                ;
L9988:  STA BinInputLB          ;Undo last 100 subtract to put number positive again.
L998A:  LDA BinInputUB          ;
L998C:  ADC #$00                ;
L998E:  STA BinInputUB          ;

L9990:* SEC                     ;
L9991:  LDA BinInputLB          ;
L9993:  SBC #$0A                ;Keep subtracting 100 until number goes negative.
L9995:  STA BinInputLB          ;
L9997:  BCC +                   ;

L9999:  INC BCDOutput2          ;Increment tens digit for each subtrct loop.
L999B:  JMP -                   ;

L999E:* CLC                     ;
L999F:  LDA BinInputLB          ;Undo last 10 subtract to put number positive again.
L99A1:  ADC #$0A                ;
L99A3:  STA BinInputLB          ;

L99A5:  CLC                     ;
L99A6:  LDA BCDOutput3          ;Add remainng value to the ones digit.
L99A8:  ADC BinInputLB          ;
L99AA:  STA BCDOutput3          ;

L99AC:  PLA                     ;Restore A from the stack and return.
L99AD:  RTS                     ;

;----------------------------------------------------------------------------------------------------

L99AE:  PHA
L99AF:  TXA
L99B0:  PHA
L99B1:  LDX #$C4
L99B3:  LDA $7300,X
L99B6:  CMP #SPRT_HIDE
L99B8:  BEQ L99C4
L99BA:  TXA
L99BB:  CLC
L99BC:  ADC #$04
L99BE:  TAX
L99BF:  BEQ L99DC
L99C1:  JMP L99B3
L99C4:  LDA $7300
L99C7:  STA $7300,X
L99CA:  LDA $7301
L99CD:  STA $7301,X
L99D0:  LDA $7302
L99D3:  STA $7302,X
L99D6:  LDA $7303
L99D9:  STA $7303,X
L99DC:  PLA
L99DD:  TAX
L99DE:  PLA
L99DF:  RTS

;----------------------------------------------------------------------------------------------------

NoWaitDialog:
L99E0:  LDA HideUprSprites      ;Make a copy of HideUprSprites
L99E2:  STA HideUprSprites_     ;

L99E4:  LDA #TXT_NO_WAIT        ;Indicate NPC text will immediately move on after done.
L99E6:  STA TextWait            ;This is because a selection menu will pop up next.

L99E8:  JMP ShowDialog1         ;($C00F)Show dialog in bottom screen window.

;----------------------------------------------------------------------------------------------------

L99EB:  .byte $66, $66, $66, $66, $66, $60, $00, $00, $00, $00, $01, $1C, $B9, $9B, $B9, $9B
L99FB:  .byte $C1, $00, $33, $33, $33

L9A00:  LDA #$9B
L9A02:  STA $2A
L9A04:  LDA #$09
L9A06:  STA $29
L9A08:  LDA #$0C
L9A0A:  STA Wnd2Width
L9A0D:  LDA #$09
L9A0F:  STA $2E
L9A11:  LDA #$22
L9A13:  PHA

L9A14:  LDA #$06
L9A16:  STA $2C
L9A18:  LDA #$00
L9A1A:  STA $2B
L9A1C:  LDY #$00
L9A1E:  LDA ($29),Y
L9A20:  STA ($2B),Y
L9A22:  INY
L9A23:  CMP #$FF
L9A25:  BNE L9A1E
L9A27:  LDA #$00
L9A29:  STA $2D
L9A2B:  STA NumMenuItems
L9A2D:  STA $9D
L9A2F:  LDX #$00
L9A31:  PLA
L9A32:  PHA
L9A33:  TAY
L9A34:  TYA
L9A35:  PHA
L9A36:  LDA (CrntChrPtr),Y
L9A38:  BEQ L9AAD
L9A3A:  INC NumMenuItems
L9A3C:  CPY #$0C
L9A3E:  BCC L9A4D
L9A40:  CPY #$1B
L9A42:  BCS L9A4D
L9A44:  TYA
L9A45:  SEC
L9A46:  SBC #$0B
L9A48:  LDY #$34
L9A4A:  JMP L9A5B
L9A4D:  CPY #$1B
L9A4F:  BCC L9A76
L9A51:  CPY #$22
L9A53:  BCS L9A76
L9A55:  TYA
L9A56:  SEC
L9A57:  SBC #$1A
L9A59:  LDY #$35
L9A5B:  CMP (CrntChrPtr),Y
L9A5D:  BNE L9A6C
L9A5F:  LDY $2D
L9A61:  LDA #$09
L9A63:  STA $0580,Y
L9A66:  INY
L9A67:  STY $2D
L9A69:  JMP L9A76
L9A6C:  LDY $2D
L9A6E:  LDA #$00
L9A70:  STA $0580,Y
L9A73:  INY
L9A74:  STY $2D
L9A76:  LDY $2D
L9A78:  LDA $0600,X
L9A7B:  CMP #$FD
L9A7D:  BEQ L9A87
L9A7F:  STA $0580,Y
L9A82:  INX
L9A83:  INY
L9A84:  JMP L9A78
L9A87:  STY $2D
L9A89:  PLA
L9A8A:  PHA
L9A8B:  TAY
L9A8C:  LDA (CrntChrPtr),Y
L9A8E:  STA $A0
L9A90:  LDA #$00
L9A92:  STA $A1
L9A94:  JSR L9943
L9A97:  LDA $A4
L9A99:  LDY $2D
L9A9B:  STA $0580,Y
L9A9E:  INY
L9A9F:  LDA $A5
L9AA1:  STA $0580,Y
L9AA4:  INY
L9AA5:  LDA #$FD
L9AA7:  STA $0580,Y
L9AAA:  INY
L9AAB:  STY $2D
L9AAD:  LDA $0600,X
L9AB0:  INX
L9AB1:  CMP #$FD
L9AB3:  BNE L9AAD
L9AB5:  PLA
L9AB6:  TAY
L9AB7:  INY
L9AB8:  DEC $2E
L9ABA:  BEQ L9ABF
L9ABC:  JMP L9A34
L9ABF:  LDA NumMenuItems
L9AC1:  BEQ L9AFF

L9AC3:  LDA #$0A
L9AC5:  STA Wnd2XPos

L9AC8:  LDA #$06
L9ACA:  STA Wnd2YPos

L9ACD:  LDA NumMenuItems
L9ACF:  CLC
L9AD0:  ADC #$01
L9AD2:  ASL
L9AD3:  STA Wnd2Height
L9AD6:  LDA #$FF
L9AD8:  STA TextIndex2
L9ADB:  JSR ShowSelectWnd1      ;($C012)Show a window where player makes a selection.
L9ADE:  STA $30
L9AE0:  PLA
L9AE1:  TAY
L9AE2:  BCS L9AFE
L9AE4:  LDA #$00
L9AE6:  STA $2E
L9AE8:  LDA (CrntChrPtr),Y
L9AEA:  BNE L9AF2
L9AEC:  INC $2E
L9AEE:  INY
L9AEF:  JMP L9AE8
L9AF2:  LDA $30
L9AF4:  BEQ L9AFB
L9AF6:  DEC $30
L9AF8:  JMP L9AEC
L9AFB:  LDA $2E
L9AFD:  CLC
L9AFE:  RTS
L9AFF:  PLA
L9B00:  LDA #$30
L9B02:  STA TextIndex
L9B04:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L9B07:  SEC
L9B08:  RTS

L9B09:  .byte $9D, $98, $9B, $8C, $91, $8E, $9C, $FD, $94, $8E, $A2, $00, $00, $00, $00, $FD
L9B19:  .byte $90, $8E, $96, $00, $00, $00, $00, $FD, $99, $98, $A0, $8D, $8E, $9B, $00, $FD
L9B29:  .byte $9D, $8E, $97, $9D, $00, $00, $00, $FD, $90, $98, $95, $8D, $00, $99, $92, $8C
L9B39:  .byte $94, $FD, $9C, $95, $9F, $9B, $00, $99, $92, $8C, $94, $FD, $9C, $95, $9F, $9B
L9B49:  .byte $00, $91, $98, $9B, $97, $FD, $8C, $96, $99, $9C, $00, $91, $9B, $9D, $00, $FD
L9B59:  .byte $FF, $36, $66, $33, $33, $33, $33, $00, $00, $03, $33, $33, $33, $11, $10, $11
L9B69:  .byte $13, $33, $33, $36, $63, $33, $33, $33, $33, $00, $C8, $88, $88, $8C, $00, $33
L9B79:  .byte $33, $06, $66, $03, $33, $33, $33, $00, $00, $99, $99, $99, $91, $10, $00, $01
L9B89:  .byte $11, $33, $33, $06, $60, $33, $33, $33, $30, $0C, $8B, $BB, $BB, $B8, $C0, $33
L9B99:  .byte $33, $00, $00, $03, $33, $33, $33, $00, $00, $06, $66, $66, $00, $00, $00, $00
L9BA9:  .byte $06, $66, $66, $66, $66, $03, $33, $33, $00, $0C, $BB, $BB, $BB, $BB, $C0, $33
L9BB9:  .byte $33, $00, $00, $01, $33, $33, $33, $00, $00, $06, $66, $66, $00, $00, $00, $00
L9BC9:  .byte $06, $66, $66, $66, $66, $00, $33, $30, $00, $68, $99, $99, $99, $99, $C0, $33
L9BD9:  .byte $33, $30, $00, $11, $33, $33, $33, $00, $00, $06, $66, $66, $00, $00, $00, $00
L9BE9:  .byte $06, $66, $66, $66, $66, $66, $66, $66, $06, $66, $66, $66, $66, $69, $C0, $33
L9BF9:  .byte $33, $30, $11, $11, $33, $33, $33, $A9, $9C, $85, $2A, $A9, $57, $85, $29, $A9
L9C09:  .byte $10, $8D, $D2, $03, $A9, $07, $85, $2E, $A9, $0C, $48, $4C, $14, $9A, $A9, $9C
L9C19:  .byte $85, $2A, $A9, $9D, $85, $29, $A9, $10, $8D, $D2, $03, $A9, $07, $85, $2E, $A9
L9C29:  .byte $13, $48, $4C, $14, $9A, $33, $33, $30, $00, $6C, $99, $BB, $B9, $99, $C0, $33
L9C39:  .byte $33, $11, $11, $13, $33, $33, $33

L9C40:  LDA #$9C
L9C42:  STA $2A
L9C44:  LDA #$57
L9C46:  STA $29
L9C48:  LDA #$10
L9C4A:  STA Wnd2Width
L9C4D:  LDA #$0F
L9C4F:  STA $2E
L9C51:  LDA #$0C
L9C53:  PHA
L9C54:  JMP $9A14

L9C57:  .byte $8D, $8A, $90, $90, $8E, $9B, $00, $00, $00, $FD, $96, $8A, $8C, $8E, $00, $00
L9C67:  .byte $00, $00, $00, $FD, $9C, $95, $92, $97, $90, $00, $00, $00, $00, $FD, $8A, $A1
L9C77:  .byte $00, $00, $00, $00, $00, $00, $00, $FD, $8B, $95, $98, $A0, $90, $9E, $97, $00
L9C87:  .byte $00, $FD, $9C, $A0, $98, $9B, $8D, $00, $00, $00, $00, $FD, $9C, $99, $8E, $8A
L9C97:  .byte $9B, $00, $00, $00, $00, $FD, $8B, $9B, $98, $8A, $8D, $00, $8A, $A1, $00, $FD
L9CA7:  .byte $8B, $98, $A0, $00, $00, $00, $00, $00, $00, $FD, $92, $9B, $98, $97, $00, $9C
L9CB7:  .byte $A0, $9B, $8D, $FD, $90, $95, $98, $9F, $8E, $9C, $00, $00, $00, $FD, $8F, $9D
L9CC7:  .byte $9B, $04, $9C, $00, $8A, $A1, $00, $FD, $9C, $95, $9F, $00, $8B, $98, $A0, $00
L9CD7:  .byte $00, $FD, $9C, $9E, $97, $00, $9C, $A0, $9B, $8D, $00, $FD, $96, $A2, $9C, $9D
L9CE7:  .byte $92, $8C, $00, $A0, $43, $FD, $FF, $33, $33, $33, $33, $33, $33, $33, $33, $33
L9CF7:  .byte $33, $33, $33, $33, $36, $63, $33, $33, $33

L9D00:  LDA #$9D
L9D02:  STA $2A
L9D04:  LDA #$17
L9D06:  STA $29
L9D08:  LDA #$10
L9D0A:  STA Wnd2Width
L9D0D:  LDA #$07
L9D0F:  STA $2E
L9D11:  LDA #$1B
L9D13:  PHA
L9D14:  JMP $9A14

L9D17:  .byte $8C, $95, $98, $9D, $91, $00, $00, $00, $00, $FD, $95, $8E, $8A, $9D, $91, $8E
L9D27:  .byte $9B, $00, $00, $FD, $8B, $9B, $98, $97, $A3, $8E, $00, $00, $00, $FD, $92, $9B
L9D37:  .byte $98, $97, $00, $00, $00, $00, $00, $FD, $9C, $9D, $8E, $8E, $95, $00, $00, $00
L9D47:  .byte $00, $FD, $8D, $9B, $90, $97, $00, $8A, $9B, $96, $00, $FD, $96, $A2, $9C, $9D
L9D57:  .byte $92, $8C, $00, $8A, $43, $FD, $FF

;----------------------------------------------------------------------------------------------------

L9D5E:  PHA
L9D5F:  LDA #$02
L9D61:  STA WndXPos
L9D63:  LDA #$02
L9D65:  STA WndYPos
L9D67:  LDA #$08
L9D69:  STA WndWidth
L9D6B:  LDA #$04
L9D6D:  STA WndHeight
L9D6F:  JSR ShowWindow1         ;($C015)Show a window on the screen.

L9D72:  LDY #CHR_GOLD
L9D74:  LDA (CrntChrPtr),Y
L9D76:  STA BinInputLB
L9D78:  INY
L9D79:  LDA (CrntChrPtr),Y
L9D7B:  STA BinInputUB
L9D7D:  JSR L9943
L9D80:  LDY #$00
L9D82:  LDX #$00
L9D84:  LDA BCDOutputBase,Y
L9D87:  CPX #$01
L9D89:  LDX #$01
L9D8B:  BCS L9D99
L9D8D:  CMP #$38
L9D8F:  BNE L9D99
L9D91:  CPY #$03
L9D93:  BEQ L9D99
L9D95:  LDX #$00
L9D97:  LDA #$00
L9D99:  STA TextBuffer,Y
L9D9C:  INY
L9D9D:  CPY #$04
L9D9F:  BNE L9D84
L9DA1:  LDA #$90
L9DA3:  STA TextBuffer,Y
L9DA6:  INY
L9DA7:  LDA #$99
L9DA9:  STA TextBuffer,Y
L9DAC:  INY
L9DAD:  LDA #$FF
L9DAF:  STA TextBuffer,Y
L9DB2:  LDA #$03
L9DB4:  STA $2A
L9DB6:  LDA #$04
L9DB8:  STA $29
L9DBA:  LDA #$06
L9DBC:  STA $2E
L9DBE:  LDA #$01
L9DC0:  STA $2D
L9DC2:  LDA #$FF
L9DC4:  STA $30
L9DC6:  JSR DisplayText1        ;($C003)Display text on the screen.
L9DC9:  PLA
L9DCA:  CLC
L9DCB:  RTS

;----------------------------------------------------------------------------------------------------

L9DCC:  .byte $33, $33, $33, $33, $33, $33, $33, $33, $33, $30, $00, $00, $11, $11, $11, $33
L9DDC:  .byte $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $66, $33, $33, $33, $33
L9DEC:  .byte $33, $33, $33, $33, $33, $33, $33, $33, $30, $00, $0C, $88, $88, $8C, $11, $13
L9DFC:  .byte $33, $33, $33, $33

L9E00:  LDA #$48
L9E02:  STA TextIndex
L9E04:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L9E07:  LDA #$B4
L9E09:  JSR L9E64
L9E0C:  LDX #$00
L9E0E:  TXA
L9E0F:  PHA
L9E10:  CLC
L9E11:  ADC #$49
L9E13:  STA $30
L9E15:  LDA #$D8
L9E17:  STA HideUprSprites
L9E19:  JSR NoWaitDialog        ;($99E0)Show dialog follwed by another menu.
L9E1C:  LDA #$4D
L9E1E:  STA TextIndex2
L9E21:  LDA #$16
L9E23:  STA Wnd2XPos
L9E26:  LDA #$10
L9E28:  STA Wnd2YPos
L9E2B:  LDA #$0A
L9E2D:  STA Wnd2Width
L9E30:  LDA #$0C
L9E32:  STA Wnd2Height
L9E35:  LDA #$04
L9E37:  STA NumMenuItems
L9E39:  LDA #$00
L9E3B:  STA $9D
L9E3D:  JSR _ShowSelectWnd1     ;($C018)Show a window where player makes a selection, variant.
L9E40:  BCS L9E1C
L9E42:  TAY
L9E43:  PLA
L9E44:  TAX
L9E45:  TYA
L9E46:  CMP $9E6C,X
L9E49:  BNE L9E62
L9E4B:  LDA #SFX_CHST_OPEN+INIT
L9E4D:  STA ThisSFX
L9E4F:  TXA
L9E50:  PHA
L9E51:  ASL
L9E52:  ASL
L9E53:  ASL
L9E54:  ASL
L9E55:  TAX
L9E56:  PLA
L9E57:  TAX
L9E58:  INX
L9E59:  CPX #$04
L9E5B:  BNE L9E0E
L9E5D:  JMP L9E60
L9E60:  CLC
L9E61:  RTS
L9E62:  SEC
L9E63:  RTS
L9E64:  CLC
L9E65:  ADC $00
L9E67:  CMP $00
L9E69:  BNE L9E67
L9E6B:  RTS

L9E6C:  .byte $02, $01, $03, $00, $66, $66, $66, $60, $00, $BB, $BB, $BB, $B9, $AA, $C0, $03
L9E7C:  .byte $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $11, $10, $06, $66, $66, $66
L9E8C:  .byte $66, $66, $66, $66, $66, $66, $66, $60, $00, $CB, $CB, $BB, $B9, $AA, $C0, $03
L9E9C:  .byte $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $11, $11, $00, $33, $33, $33
L9EAC:  .byte $33, $00, $11, $33, $33, $33, $33, $00, $00, $88, $CB, $BB, $B9, $AA, $C0, $03
L9EBC:  .byte $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $31, $11, $13, $33, $33, $33
L9ECC:  .byte $33, $31, $13, $33, $33, $33, $33, $33, $00, $00, $8C, $BB, $B9, $AC, $80, $03
L9EDC:  .byte $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33
L9EEC:  .byte $33, $33, $33, $33, $33, $33, $33, $33, $30, $00, $08, $88, $88, $88, $00, $03
L9EFC:  .byte $33, $33, $33, $33

L9F00:  JSR ChooseChar1         ;($C00C)Select a character from a list.
L9F03:  BCC L9F08
L9F05:  JMP DialogExit          ;($94A9)Exit dialog routines.
L9F08:  JSR L9D5E
L9F0B:  LDA #$DD
L9F0D:  STA TextIndex2
L9F10:  LDA #$0A
L9F12:  STA Wnd2XPos
L9F15:  LDA #$06
L9F17:  STA Wnd2YPos
L9F1A:  LDA #$0A
L9F1C:  STA Wnd2Width
L9F1F:  LDA #$0A
L9F21:  STA Wnd2Height
L9F24:  LDA #$03
L9F26:  STA NumMenuItems
L9F28:  LDA #$00
L9F2A:  STA $9D
L9F2C:  JSR _ShowSelectWnd1     ;($C018)Show a window where player makes a selection, variant.
L9F2F:  BCC L9F34
L9F31:  JMP DialogExit          ;($94A9)Exit dialog routines.
L9F34:  ASL
L9F35:  TAX
L9F36:  LDY #$30
L9F38:  LDA $9FD4,X
L9F3B:  STA $2B
L9F3D:  LDA $9FD5,X
L9F40:  STA $2C
L9F42:  SEC
L9F43:  LDA (CrntChrPtr),Y
L9F45:  SBC $2B
L9F47:  INY
L9F48:  LDA (CrntChrPtr),Y
L9F4A:  SBC $2C
L9F4C:  BCS L9F59
L9F4E:  LDY #$30
L9F50:  LDA (CrntChrPtr),Y
L9F52:  STA $2B
L9F54:  INY
L9F55:  LDA (CrntChrPtr),Y
L9F57:  STA $2C
L9F59:  LDA $2B
L9F5B:  PHA
L9F5C:  LDA $2C
L9F5E:  PHA
L9F5F:  LDA $99
L9F61:  PHA
L9F62:  LDA $9A
L9F64:  PHA
L9F65:  JSR $C042
L9F68:  PLA
L9F69:  STA $2A
L9F6B:  PLA
L9F6C:  STA $29
L9F6E:  PLA
L9F6F:  STA $2C
L9F71:  PLA
L9F72:  STA $2B
L9F74:  BCC L9F79
L9F76:  JMP DialogExit          ;($94A9)Exit dialog routines.
L9F79:  LDY #$30
L9F7B:  CLC
L9F7C:  LDA (CrntChrPtr),Y
L9F7E:  STA $2D
L9F80:  ADC $2B
L9F82:  STA $2B
L9F84:  INY
L9F85:  LDA (CrntChrPtr),Y
L9F87:  STA $2E
L9F89:  ADC $2C
L9F8B:  STA $2C
L9F8D:  CMP #$27
L9F8F:  BCC L9FA1
L9F91:  BNE L9F99
L9F93:  LDA $2B
L9F95:  CMP #$0F
L9F97:  BCC L9FA1
L9F99:  LDA #$27
L9F9B:  STA $2C
L9F9D:  LDA #$0F
L9F9F:  STA $2B
L9FA1:  SEC
L9FA2:  LDA $2B
L9FA4:  SBC $2D
L9FA6:  STA $2D
L9FA8:  LDA $2C
L9FAA:  SBC $2E
L9FAC:  STA $2E
L9FAE:  LDY #$30
L9FB0:  LDA $2B
L9FB2:  STA (CrntChrPtr),Y
L9FB4:  INY
L9FB5:  LDA $2C
L9FB7:  STA (CrntChrPtr),Y
L9FB9:  LDA $29
L9FBB:  STA $99
L9FBD:  LDA $2A
L9FBF:  STA $9A
L9FC1:  LDA $2D
L9FC3:  STA $A0
L9FC5:  LDA $2E
L9FC7:  STA $A1
L9FC9:  JSR L98DB
L9FCC:  LDA #$DE
L9FCE:  STA TextIndex
L9FD0:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
L9FD3:  RTS

L9FD4:  .word $000A             ;10
L9FD6:  .word $0064             ;100
L9FD8:  .word $03E8             ;1000

;----------------------------------------------------------------------------------------------------

;Unused.
L9FDA:  .byte $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33
L9FEA:  .byte $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33, $33
L9FFA:  .byte $33, $33, $33, $33, $33, $33

;----------------------------------------------------------------------------------------------------

MarkOfSnakeDat:
LA000:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA010:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA020:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA030:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA040:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA050:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA060:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA070:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA080:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A5, $A6, $A7, $A8, $A4, $A4, $A4, $A4, $A4, $A4
LA090:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A9, $B1, $B2, $AA, $A4, $A4, $A4, $A4, $A4, $A4
LA0A0:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $AB, $B3, $B4, $AC, $A4, $A4, $A4, $A4, $A4, $A4
LA0B0:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $AD, $AE, $AF, $B0, $A4, $A4, $A4, $A4, $A4, $A4
LA0C0:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA0D0:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA0E0:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA0F0:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4

MarkOfForceDat:
LA100:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA110:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA120:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA130:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA140:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA150:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA160:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA170:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA180:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A5, $A6, $A7, $A8, $A4, $A4, $A4, $A4, $A4, $A4
LA190:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A9, $B5, $B6, $AA, $A4, $A4, $A4, $A4, $A4, $A4
LA1A0:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $AB, $B7, $B8, $AC, $A4, $A4, $A4, $A4, $A4, $A4
LA1B0:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $AD, $AE, $AF, $B0, $A4, $A4, $A4, $A4, $A4, $A4
LA1C0:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA1D0:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA1E0:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA1F0:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4

MarkOfKingsDat:
LA200:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA210:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA220:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA230:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA240:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA250:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA260:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA270:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA280:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A5, $A6, $A7, $A8, $A4, $A4, $A4, $A4, $A4, $A4
LA290:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A9, $B9, $BA, $AA, $A4, $A4, $A4, $A4, $A4, $A4
LA2A0:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $AB, $BB, $BC, $AC, $A4, $A4, $A4, $A4, $A4, $A4
LA2B0:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $AD, $AE, $AF, $B0, $A4, $A4, $A4, $A4, $A4, $A4
LA2C0:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA2D0:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA2E0:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA2F0:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4

MarkOfFireDat:
LA300:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA310:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA320:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA330:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA340:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA350:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA360:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA370:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA380:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A5, $A6, $A7, $A8, $A4, $A4, $A4, $A4, $A4, $A4
LA390:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A9, $BD, $BE, $AA, $A4, $A4, $A4, $A4, $A4, $A4
LA3A0:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $AB, $BF, $C0, $AC, $A4, $A4, $A4, $A4, $A4, $A4
LA3B0:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $AD, $AE, $AF, $B0, $A4, $A4, $A4, $A4, $A4, $A4
LA3C0:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA3D0:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA3E0:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4
LA3F0:  .byte $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4, $A4

FountainDat:
LA400:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA410:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA420:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA430:  .byte $00, $00, $00, $00, $00, $00, $C7, $C7, $C7, $C7, $C7, $00, $00, $00, $00, $00
LA440:  .byte $00, $00, $00, $00, $00, $C1, $C5, $C5, $C5, $C5, $C5, $C3, $C7, $00, $00, $00
LA450:  .byte $00, $00, $00, $C7, $C1, $C5, $C5, $C5, $C5, $D4, $C5, $C5, $C5, $C3, $00, $00
LA460:  .byte $00, $C7, $C1, $C5, $C5, $C5, $C5, $C5, $C5, $D5, $C5, $C5, $C5, $C5, $C3, $00
LA470:  .byte $C1, $C5, $C5, $C5, $C5, $C5, $C5, $C5, $D6, $D7, $C5, $C5, $C5, $C5, $C5, $C3
LA480:  .byte $C4, $C5, $C5, $C5, $C5, $C5, $C5, $C5, $C5, $D9, $C5, $C5, $C5, $C5, $C5, $C6
LA490:  .byte $C4, $C5, $C5, $C5, $CC, $CB, $CE, $CC, $CB, $DB, $CD, $CD, $CE, $C5, $C5, $C6
LA4A0:  .byte $C8, $C9, $C5, $CF, $D2, $D3, $D1, $D0, $D2, $D2, $D2, $D2, $D3, $C5, $C9, $CA
LA4B0:  .byte $C8, $C9, $C5, $C5, $D4, $C5, $C5, $C5, $C5, $D4, $C5, $C5, $C5, $C5, $C9, $CA
LA4C0:  .byte $C8, $C9, $C9, $C9, $D8, $C9, $C5, $C5, $C5, $C5, $C5, $C5, $C9, $C9, $C9, $CA
LA4D0:  .byte $C8, $C9, $C9, $C9, $D8, $C9, $C5, $C5, $C5, $C5, $C5, $C5, $C9, $C9, $C9, $CA
LA4E0:  .byte $C8, $C9, $C9, $C9, $D4, $C9, $C9, $C9, $C9, $C9, $C9, $C9, $C9, $C9, $C9, $CA
LA4F0:  .byte $C8, $C9, $C9, $DA, $D9, $DA, $C9, $C9, $C9, $C9, $C9, $C9, $C9, $C9, $C9, $CA

TimeLordDat:
LA500:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA510:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA520:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA530:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA540:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA550:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA560:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA570:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA580:  .byte $00, $00, $00, $00, $00, $A4, $A5, $A6, $A7, $A8, $00, $00, $00, $00, $00, $00
LA590:  .byte $00, $00, $00, $00, $00, $A9, $AA, $AB, $AC, $AD, $00, $00, $00, $00, $00, $00
LA5A0:  .byte $00, $00, $00, $00, $00, $AE, $AF, $B0, $B1, $B2, $B3, $00, $00, $00, $00, $00
LA5B0:  .byte $00, $00, $00, $00, $00, $B4, $B5, $B6, $B7, $B8, $B9, $00, $00, $00, $00, $00
LA5C0:  .byte $00, $00, $00, $00, $00, $BA, $BB, $BC, $BD, $BE, $BF, $00, $00, $00, $00, $00
LA5D0:  .byte $00, $00, $00, $00, $00, $C0, $C1, $C2, $C3, $C4, $C5, $00, $00, $00, $00, $00
LA5E0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA5F0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

;----------------------------------------------------------------------------------------------------

LA600:  LDX #$00
LA602:  STX $2E
LA604:  LDA $2E
LA606:  ASL
LA607:  TAY
LA608:  LDA $0091,Y
LA60B:  STA $99
LA60D:  LDA $0092,Y
LA610:  STA $9A
LA612:  LDA #$00
LA614:  STA $0580,X
LA617:  INX
LA618:  LDA #$FD
LA61A:  STA $0580,X
LA61D:  INX
LA61E:  LDY #$00
LA620:  LDA (CrntChrPtr),Y
LA622:  STA $0580,X
LA625:  INX
LA626:  INY
LA627:  CPY #$05
LA629:  BNE LA620
LA62B:  LDY #$0B
LA62D:  LDA (CrntChrPtr),Y
LA62F:  TAY
LA630:  LDA $A742,Y
LA633:  STA $0580,X
LA636:  INX
LA637:  LDY #$06
LA639:  LDA (CrntChrPtr),Y
LA63B:  TAY
LA63C:  LDA $A727,Y
LA63F:  STA $0580,X
LA642:  INX
LA643:  LDY #$05
LA645:  LDA (CrntChrPtr),Y
LA647:  TAY
LA648:  LDA $A732,Y
LA64B:  STA $0580,X
LA64E:  INX
LA64F:  LDY #$06
LA651:  LDA (CrntChrPtr),Y
LA653:  TAY
LA654:  LDA $A737,Y
LA657:  STA $0580,X
LA65A:  INX
LA65B:  LDA #$FD
LA65D:  STA $0580,X
LA660:  INX
LA661:  LDA #$91
LA663:  STA $0580,X
LA666:  INX
LA667:  LDY #$2D
LA669:  LDA (CrntChrPtr),Y
LA66B:  STA $A0
LA66D:  INY
LA66E:  LDA (CrntChrPtr),Y
LA670:  STA $A1
LA672:  JSR L9943
LA675:  LDY #$04
LA677:  JSR LA70B
LA67A:  LDA #$00
LA67C:  STA $0580,X
LA67F:  INX
LA680:  LDA #$96
LA682:  STA $0580,X
LA685:  INX
LA686:  LDY #$2F
LA688:  LDA (CrntChrPtr),Y
LA68A:  STA $A0
LA68C:  LDA #$00
LA68E:  STA $A1
LA690:  JSR L9943
LA693:  LDY #$02
LA695:  JSR LA70B
LA698:  LDA #$FD
LA69A:  STA $0580,X
LA69D:  INX
LA69E:  LDA #$8F
LA6A0:  STA $0580,X
LA6A3:  INX
LA6A4:  LDY #$2B
LA6A6:  LDA (CrntChrPtr),Y
LA6A8:  STA $A0
LA6AA:  INY
LA6AB:  LDA (CrntChrPtr),Y
LA6AD:  STA $A1
LA6AF:  JSR L9943
LA6B2:  LDY #$04
LA6B4:  JSR LA70B
LA6B7:  LDA #$00
LA6B9:  STA $0580,X
LA6BC:  INX
LA6BD:  LDA #$95
LA6BF:  STA $0580,X
LA6C2:  INX
LA6C3:  LDY #$33
LA6C5:  LDA (CrntChrPtr),Y
LA6C7:  STA $A0
LA6C9:  LDA #$00
LA6CB:  STA $A1
LA6CD:  JSR L9943
LA6D0:  LDY #$02
LA6D2:  JSR LA70B
LA6D5:  LDA #$FD
LA6D7:  STA $0580,X
LA6DA:  INC $2E
LA6DC:  LDA $2E
LA6DE:  CMP #$04
LA6E0:  BEQ LA6E6
LA6E2:  INX
LA6E3:  JMP LA604
LA6E6:  LDA #$FF
LA6E8:  STA $0580,X
LA6EB:  LDA #$15
LA6ED:  STA $2A
LA6EF:  LDA #$03
LA6F1:  STA $29
LA6F3:  LDA #$09
LA6F5:  STA $2E
LA6F7:  LDA #$10
LA6F9:  STA $2D
LA6FB:  LDA #$FE
LA6FD:  STA $30
LA6FF:  LDA #$01
LA701:  STA $A6
LA703:  JSR $C003
LA706:  LDA #$00
LA708:  STA $A6
LA70A:  RTS
LA70B:  TYA
LA70C:  PHA
LA70D:  SEC
LA70E:  SBC #$04
LA710:  EOR #$FF
LA712:  CLC
LA713:  ADC #$01
LA715:  TAY
LA716:  PLA
LA717:  PHA
LA718:  LDA $00A2,Y
LA71B:  STA $0580,X
LA71E:  INX
LA71F:  INY
LA720:  PLA
LA721:  SEC
LA722:  SBC #$01
LA724:  BNE LA717
LA726:  RTS

LA727:  .byte $96, $8F, $96, $96, $8F, $96, $8F, $8F, $96, $96, $96, $91, $8E, $8D, $8B, $8F
LA737:  .byte $8F, $8C, $A0, $9D, $99, $8B, $95, $92, $8D, $8A, $9B, $90, $99, $8C, $8D, $8A
LA747:  .byte $88, $88, $88, $88, $88, $88, $88, $88, $88, $88, $88, $88, $88, $88, $88, $88
LA757:  .byte $88, $88, $88, $88, $88, $88, $82, $22, $22, $22, $22, $22, $22, $22, $22, $22
LA767:  .byte $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
LA777:  .byte $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
LA787:  .byte $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
LA797:  .byte $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
LA7A7:  .byte $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
LA7B7:  .byte $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
LA7C7:  .byte $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
LA7D7:  .byte $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
LA7E7:  .byte $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
LA7F7:  .byte $22, $22, $22, $22, $22, $22, $22, $22, $22

LA800:  LDX #$00
LA802:  LDA #$00
LA804:  STA $75,X
LA806:  INX
LA807:  CPX #$08
LA809:  BNE LA804
LA80B:  JSR GetPlyrDngPos       ;($B628)Get current block player is standing on in dungeon.
LA80E:  CMP #$06
LA810:  BEQ LA81A
LA812:  CMP #$07
LA814:  BEQ LA81A
LA816:  CMP #$0E
LA818:  BNE LA81D
LA81A:  JMP $AB6A
LA81D:  JSR $B313
LA820:  LDX #$00
LA822:  LDA #$04
LA824:  STA $2C
LA826:  LDA ($41),Y
LA828:  CMP #$03
LA82A:  BCS LA864
LA82C:  CMP #$01
LA82E:  BNE LA835
LA830:  LDA #$80
LA832:  JMP LA837
LA835:  LDA #$00
LA837:  STA $19
LA839:  LDA $B04A,X
LA83C:  BEQ LA842
LA83E:  ORA $19
LA840:  STA $75
LA842:  INX
LA843:  LDA $B04A,X
LA846:  BEQ LA84C
LA848:  ORA $19
LA84A:  STA $77
LA84C:  INX
LA84D:  LDA $B04A,X
LA850:  BEQ LA856
LA852:  ORA $19
LA854:  STA $79
LA856:  INX
LA857:  LDA $B04A,X
LA85A:  BEQ LA860
LA85C:  ORA $19
LA85E:  STA $7B
LA860:  INX
LA861:  JMP LA868
LA864:  INX
LA865:  INX
LA866:  INX
LA867:  INX
LA868:  LDA $7D
LA86A:  AND #$01
LA86C:  BNE LA881
LA86E:  TYA
LA86F:  AND #$F0
LA871:  STA $2F
LA873:  TYA
LA874:  AND #$0F
LA876:  CLC
LA877:  ADC $2E
LA879:  AND #$0F
LA87B:  CLC
LA87C:  ADC $2F
LA87E:  JMP LA885
LA881:  TYA
LA882:  CLC
LA883:  ADC $2E
LA885:  TAY
LA886:  DEC $2C
LA888:  BNE LA826
LA88A:  LDA #$03
LA88C:  STA $2C
LA88E:  LDA $7D
LA890:  AND #$01
LA892:  BNE LA8AA
LA894:  TYA
LA895:  AND #$F0
LA897:  STA $2F
LA899:  TYA
LA89A:  AND #$0F
LA89C:  CLC
LA89D:  ADC $2E
LA89F:  CLC
LA8A0:  ADC $2E
LA8A2:  AND #$0F
LA8A4:  CLC
LA8A5:  ADC $2F
LA8A7:  JMP LA8B1
LA8AA:  TYA
LA8AB:  CLC
LA8AC:  ADC $2E
LA8AE:  CLC
LA8AF:  ADC $2E
LA8B1:  TAY
LA8B2:  LDA ($41),Y
LA8B4:  CMP #$03
LA8B6:  BCS LA8F0
LA8B8:  CMP #$01
LA8BA:  BNE LA8C1
LA8BC:  LDA #$80
LA8BE:  JMP LA8C3
LA8C1:  LDA #$00
LA8C3:  STA $19
LA8C5:  LDA $B04A,X
LA8C8:  BEQ LA8CE
LA8CA:  ORA $19
LA8CC:  STA $76
LA8CE:  INX
LA8CF:  LDA $B04A,X
LA8D2:  BEQ LA8D8
LA8D4:  ORA $19
LA8D6:  STA $78
LA8D8:  INX
LA8D9:  LDA $B04A,X
LA8DC:  BEQ LA8E2
LA8DE:  ORA $19
LA8E0:  STA $7A
LA8E2:  INX
LA8E3:  LDA $B04A,X
LA8E6:  BEQ LA8EC
LA8E8:  ORA $19
LA8EA:  STA $7C
LA8EC:  INX
LA8ED:  JMP LA8F4
LA8F0:  INX
LA8F1:  INX
LA8F2:  INX
LA8F3:  INX
LA8F4:  LDA $7D
LA8F6:  AND #$01
LA8F8:  BNE LA90D
LA8FA:  TYA
LA8FB:  AND #$F0
LA8FD:  STA $2F
LA8FF:  TYA
LA900:  AND #$0F
LA902:  SEC
LA903:  SBC $2E
LA905:  AND #$0F
LA907:  CLC
LA908:  ADC $2F
LA90A:  JMP LA911
LA90D:  TYA
LA90E:  SEC
LA90F:  SBC $2E
LA911:  TAY
LA912:  DEC $2C
LA914:  BNE LA8B2
LA916:  LDA $7D
LA918:  AND #$01
LA91A:  BEQ LA931
LA91C:  LDA $30
LA91E:  AND #$F0
LA920:  STA $2F
LA922:  LDA $30
LA924:  AND #$0F
LA926:  CLC
LA927:  ADC $2D
LA929:  AND #$0F
LA92B:  CLC
LA92C:  ADC $2F
LA92E:  JMP LA936
LA931:  LDA $30
LA933:  CLC
LA934:  ADC $2D
LA936:  STA $30
LA938:  TAY
LA939:  CPX #$70
LA93B:  BEQ LA940
LA93D:  JMP LA822
LA940:  JSR $ADB4
LA943:  LDX #$00
LA945:  LDA #SPRT_HIDE
LA947:  STA $7300,X
LA94A:  INX
LA94B:  INX
LA94C:  INX
LA94D:  INX
LA94E:  BNE LA947
LA950:  JSR $B212
LA953:  LDA $00
LA955:  CLC
LA956:  ADC #$02
LA958:  CMP $00
LA95A:  BNE LA958
LA95C:  JSR $C024
LA95F:  LDA #$20
LA961:  STA $2A
LA963:  LDA #$A3
LA965:  STA $29
LA967:  LDA #$10
LA969:  STA $2C
LA96B:  LDY #$00
LA96D:  LDA #$10
LA96F:  STA $2E
LA971:  JSR $B918
LA974:  LDA $2A
LA976:  STA $0300,X
LA979:  INX
LA97A:  LDA $29
LA97C:  STA $0300,X
LA97F:  LDA #$10
LA981:  STA $2E
LA983:  INX
LA984:  LDA $0400,Y
LA987:  STA $0300,X
LA98A:  INY
LA98B:  DEC $2E
LA98D:  BNE LA983
LA98F:  CLC
LA990:  LDA $29
LA992:  ADC #$20
LA994:  STA $29
LA996:  LDA $2A
LA998:  ADC #$00
LA99A:  STA $2A
LA99C:  DEC $2C
LA99E:  BNE LA96D
LA9A0:  LDA #$01
LA9A2:  JSR $B918
LA9A5:  LDA #$20
LA9A7:  STA $0300,X
LA9AA:  INX
LA9AB:  LDA #$6A
LA9AD:  STA $0300,X
LA9B0:  LDA $B2
LA9B2:  CLC
LA9B3:  ADC #$39
LA9B5:  INX
LA9B6:  STA $0300,X
LA9B9:  LDA #$01
LA9BB:  JSR $B918
LA9BE:  LDA #$20
LA9C0:  STA $0300,X
LA9C3:  INX
LA9C4:  LDA #$72
LA9C6:  STA $0300,X
LA9C9:  LDY $7D
LA9CB:  LDA $AB66,Y
LA9CE:  INX
LA9CF:  STA $0300,X
LA9D2:  JMP $AA00

LA9D5:  .byte $44, $44, $44, $00, $00, $04, $42, $22, $22, $42, $24, $42, $24, $44, $11, $11
LA9E5:  .byte $11, $14, $44, $42, $22, $24, $33, $44, $44, $44, $44, $43, $33, $44, $41, $11
LA9F5:  .byte $44, $44, $41, $00, $00, $44, $44, $42, $22, $22, $24

LAA00:  LDA #$24
LAA02:  STA $2A
LAA04:  LDA #$A3
LAA06:  STA $29
LAA08:  LDA #$10
LAA0A:  STA $2C
LAA0C:  LDY #$00
LAA0E:  LDA #$10
LAA10:  STA $2E
LAA12:  JSR LB918
LAA15:  LDA $2A
LAA17:  STA PPUBuffer,X
LAA1A:  INX
LAA1B:  LDA $29
LAA1D:  STA PPUBuffer,X
LAA20:  LDA #$10
LAA22:  STA $2E
LAA24:  INX
LAA25:  LDA $0400,Y
LAA28:  STA PPUBuffer,X
LAA2B:  INY
LAA2C:  DEC $2E
LAA2E:  BNE LAA24
LAA30:  CLC
LAA31:  LDA $29
LAA33:  ADC #$20
LAA35:  STA $29
LAA37:  LDA $2A
LAA39:  ADC #$00
LAA3B:  STA $2A
LAA3D:  DEC $2C
LAA3F:  BNE LAA0E
LAA41:  LDA #$01
LAA43:  JSR LB918
LAA46:  LDA #$24
LAA48:  STA PPUBuffer,X
LAA4B:  INX
LAA4C:  LDA #$6A
LAA4E:  STA PPUBuffer,X
LAA51:  LDA $B2
LAA53:  CLC
LAA54:  ADC #$39
LAA56:  INX
LAA57:  STA PPUBuffer,X
LAA5A:  LDA #$01
LAA5C:  JSR LB918
LAA5F:  LDA #$24
LAA61:  STA PPUBuffer,X
LAA64:  INX
LAA65:  LDA #$72
LAA67:  STA PPUBuffer,X
LAA6A:  LDY $7D
LAA6C:  LDA $AB66,Y
LAA6F:  INX
LAA70:  STA PPUBuffer,X
LAA73:  JSR GetPlyrDngPos       ;($B628)Get current block player is standing on in dungeon.
LAA76:  CMP #$08
LAA78:  BNE LAAB9
LAA7A:  JSR LADA0
LAA7D:  LDA MapTypeNIndex
LAA7F:  ASL
LAA80:  ASL
LAA81:  ASL
LAA82:  CLC
LAA83:  ADC DungeonLevel
LAA85:  ASL
LAA86:  TAX
LAA87:  LDA CvNamePtrTbl,X
LAA8A:  STA $29
LAA8C:  LDA CvNamePtrTbl+1,X
LAA8F:  STA $2A
LAA91:  LDY #$00
LAA93:  LDA ($29),Y
LAA95:  STA $0580,Y
LAA98:  CMP #$FF
LAA9A:  BEQ LAAA0
LAA9C:  INY
LAA9D:  JMP LAA93
LAAA0:  LDA #$FF
LAAA2:  STA TextIndex
LAAA4:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
LAAA7:  JSR BinToBCD1           ;($C021)Convert binary number to BCD.
LAAAA:  LDA #$00
LAAAC:  STA $10
LAAAE:  STA $14
LAAB0:  LDA $03
LAAB2:  AND #$FE
LAAB4:  STA $03
LAAB6:  JMP LAAF2
LAAB9:  CMP #$0A
LAABB:  BNE LAAEE
LAABD:  JSR LADA0
LAAC0:  LDA $00
LAAC2:  AND #$03
LAAC4:  ASL
LAAC5:  TAX
LAAC6:  LDA $91,X
LAAC8:  STA $99
LAACA:  LDA $92,X
LAACC:  STA $9A
LAACE:  LDY #$2B
LAAD0:  LDA (CrntChrPtr),Y
LAAD2:  SEC
LAAD3:  SBC #$64
LAAD5:  STA (CrntChrPtr),Y
LAAD7:  INY
LAAD8:  LDA (CrntChrPtr),Y
LAADA:  SBC #$00
LAADC:  STA (CrntChrPtr),Y
LAADE:  BCS LAAE9
LAAE0:  LDA #$00
LAAE2:  LDY #$2B
LAAE4:  STA (CrntChrPtr),Y
LAAE6:  INY
LAAE7:  STA (CrntChrPtr),Y
LAAE9:  LDA #$36
LAAEB:  JMP LAAA2
LAAEE:  CMP #$0C
LAAF0:  BNE LAAF2
LAAF2:  JSR LB953
LAAF5:  RTS

;----------------------------------------------------------------------------------------------------

CvNamePtrTbl:
LAAF6:  .word CvDeathLv1, CvDeathLv2, CvDeathLv3, CvDeathLv4
LAAFE:  .word CvDeathLv5, CvDeathLv6, CvDeathLv7, CvDeathLv8
LAB06:  .word CvGoldLv1, CvGoldLv2, CvGoldLv3, CvGoldLv4
LAB0E:  .word CvGoldLv5, CvGoldLv6, CvGoldLv7, CvGoldLv8
LAB16:  .word CvMoonLv1, CvMoonLv2, CvMoonLv3, CvMoonLv4
LAB1E:  .word CvMoonLv5, CvMoonLv6, CvMoonLv7, CvMoonLv8
LAB26:  .word CvFireLv1, CvFireLv2, CvFireLv3, CvFireLv4
LAB2E:  .word CvFireLv5, CvFireLv6, CvFireLv7, CvFireLv8
LAB36:  .word CvFoolLv1, CvFoolLv2, CvFoolLv3, CvFoolLv4
LAB3E:  .word CvFoolLv5, CvFoolLv6, CvFoolLv7, CvFoolLv8
LAB46:  .word CvMadnessLv1, CvMadnessLv2, CvMadnessLv3, CvMadnessLv4
LAB4E:  .word CvMadnessLv5, CvMadnessLv6, CvMadnessLv7, CvMadnessLv8
LAB56:  .word CvSolLv1, CvSolLv2, CvSolLv3, CvSolLv4
LAB5E:  .word CvSolLv5, CvSolLv6, CvSolLv7, CvSolLv8

LAB66:  .byte $97, $8E, $9C, $A0

;----------------------------------------------------------------------------------------------------


LAB6A:  CMP #$06
LAB6C:  BEQ LAB71
LAB6E:  JMP LABFE
LAB71:  LDA #$00
LAB73:  STA $04
LAB75:  STA $2001
LAB78:  LDA #$06
LAB7A:  STA $30
LAB7C:  LDA #$00
LAB7E:  STA $2F
LAB80:  JSR LAD52
LAB83:  PHA
LAB84:  ASL
LAB85:  TAX
LAB86:  LDA $AD42,X
LAB89:  STA $29
LAB8B:  LDA $AD43,X
LAB8E:  STA $2A
LAB90:  JSR LAD01
LAB93:  JSR $C027
LAB96:  JSR LADA0
LAB99:  LDA #$1E
LAB9B:  STA $04
LAB9D:  LDA $ED
LAB9F:  CMP #$02
LABA1:  BEQ LABDC
LABA3:  CMP #$01
LABA5:  BEQ LABDC
LABA7:  LDA $C7
LABA9:  ORA #$80
LABAB:  STA $C7
LABAD:  PLA
LABAE:  PHA
LABAF:  TAX
LABB0:  LDA $AD4E,X
LABB3:  STA TextIndex
LABB5:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
LABB8:  JSR ChooseChar1         ;($C00C)Select a character from a list.
LABBB:  BCS LABD9
LABBD:  PLA
LABBE:  PHA
LABBF:  TAX
LABC0:  LDA $AD3E,X
LABC3:  STA $30
LABC5:  LDY #$3B
LABC7:  LDA (CrntChrPtr),Y
LABC9:  ORA $30
LABCB:  STA (CrntChrPtr),Y
LABCD:  LDA #$38
LABCF:  STA $30
LABD1:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
LABD4:  LDA #$32
LABD6:  JSR LAD0E
LABD9:  JSR BinToBCD1           ;($C021)Convert binary number to BCD.
LABDC:  LDA #$00
LABDE:  STA $10
LABE0:  STA $14
LABE2:  LDA $03
LABE4:  AND #$FE
LABE6:  STA $03
LABE8:  PLA
LABE9:  ASL
LABEA:  TAX
LABEB:  LDA $AD42,X
LABEE:  STA $29
LABF0:  LDA $AD43,X
LABF3:  STA $2A
LABF5:  JSR LAD01
LABF8:  JMP LAAAA
LABFB:  JMP LAAA7
LABFE:  CMP #$07
LAC00:  BEQ LAC05
LAC02:  JMP LACC1
LAC05:  LDA #$00
LAC07:  STA $04
LAC09:  STA $2001
LAC0C:  LDA #$A4
LAC0E:  STA $2A
LAC10:  LDA #$00
LAC12:  STA $29
LAC14:  JSR LAD01
LAC17:  JSR $C027
LAC1A:  JSR LADA0
LAC1D:  LDA #$1E
LAC1F:  STA $04
LAC21:  LDA $ED
LAC23:  CMP #$02
LAC25:  BEQ LACA4
LAC27:  CMP #$01
LAC29:  BEQ LACA4
LAC2B:  LDA #$07
LAC2D:  STA $30
LAC2F:  LDA #$02
LAC31:  STA $2F
LAC33:  JSR LAD52
LAC36:  PHA
LAC37:  LDA #$80
LAC39:  ORA $C7
LAC3B:  STA $C7
LAC3D:  LDA #$39
LAC3F:  STA TextIndex
LAC41:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
LAC44:  JSR ChooseChar1         ;($C00C)Select a character from a list.
LAC47:  PLA
LAC48:  BCS LACA1
LAC4A:  PHA
LAC4B:  TAX
LAC4C:  LDA $AD4A,X
LAC4F:  STA TextIndex
LAC51:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
LAC54:  PLA
LAC55:  CMP #$00
LAC57:  BNE LAC72
LAC59:  LDY #$36
LAC5B:  LDA (CrntChrPtr),Y
LAC5D:  STA $29
LAC5F:  INY
LAC60:  LDA (CrntChrPtr),Y
LAC62:  STA $2A
LAC64:  LDY #$2D
LAC66:  LDA $29
LAC68:  STA (CrntChrPtr),Y
LAC6A:  INY
LAC6B:  LDA $2A
LAC6D:  STA (CrntChrPtr),Y
LAC6F:  JMP LACA1
LAC72:  CMP #$01
LAC74:  BNE LAC89
LAC76:  LDY #$0B
LAC78:  LDA (CrntChrPtr),Y
LAC7A:  CMP #$01
LAC7C:  BEQ LAC82
LAC7E:  CMP #$02
LAC80:  BNE LAC86
LAC82:  LDA #$00
LAC84:  STA (CrntChrPtr),Y
LAC86:  JMP LACA1
LAC89:  CMP #$02
LAC8B:  BNE LAC95
LAC8D:  LDA #$32
LAC8F:  JSR LAD0E
LAC92:  JMP LACA1
LAC95:  LDY #$0B
LAC97:  LDA (CrntChrPtr),Y
LAC99:  CMP #$02
LAC9B:  BCS LACA1
LAC9D:  LDA #$01
LAC9F:  STA (CrntChrPtr),Y
LACA1:  JSR BinToBCD1           ;($C021)Convert binary number to BCD.
LACA4:  LDA #$00
LACA6:  STA $10
LACA8:  STA $14
LACAA:  LDA $03
LACAC:  AND #$FE
LACAE:  STA $03
LACB0:  LDA #$A4
LACB2:  STA $2A
LACB4:  LDA #$00
LACB6:  STA $29
LACB8:  JSR LAD01
LACBB:  JSR $C027
LACBE:  JMP LAAAA
LACC1:  LDA #$00
LACC3:  STA $04
LACC5:  LDA #$A5
LACC7:  STA $2A
LACC9:  LDA #$00
LACCB:  STA $29
LACCD:  JSR LAD01
LACD0:  JSR $C027
LACD3:  JSR LADA0
LACD6:  LDA #$1E
LACD8:  STA $04
LACDA:  LDA #$59
LACDC:  STA TextIndex
LACDE:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
LACE1:  JSR BinToBCD1           ;($C021)Convert binary number to BCD.
LACE4:  LDA #$00
LACE6:  STA $10
LACE8:  STA $14
LACEA:  LDA $03
LACEC:  AND #$FE
LACEE:  STA $03
LACF0:  LDA #$A5
LACF2:  STA $2A
LACF4:  LDA #$00
LACF6:  STA $29
LACF8:  JSR LAD01
LACFB:  JSR $C027
LACFE:  JMP LAAAA
LAD01:  LDY #$00
LAD03:  LDA ($29),Y
LAD05:  STA $0400,Y
LAD08:  INY
LAD09:  BNE LAD03
LAD0B:  JMP LA943
LAD0E:  STA $30
LAD10:  STA $A0
LAD12:  LDY #$2D
LAD14:  LDA (CrntChrPtr),Y
LAD16:  SEC
LAD17:  SBC $30
LAD19:  STA (CrntChrPtr),Y
LAD1B:  INY
LAD1C:  LDA (CrntChrPtr),Y
LAD1E:  SBC #$00
LAD20:  STA (CrntChrPtr),Y
LAD22:  BCS LAD36
LAD24:  LDA #$00
LAD26:  STA (CrntChrPtr),Y
LAD28:  DEY
LAD29:  STA (CrntChrPtr),Y
LAD2B:  LDY #$0B
LAD2D:  LDA #$03
LAD2F:  STA (CrntChrPtr),Y
LAD31:  LDA #$29
LAD33:  JMP LAD38
LAD36:  LDA #$22
LAD38:  STA TextIndex
LAD3A:  JSR ShowDialog1         ;($C00F)Show dialog in bottom screen window.
LAD3D:  RTS

LAD3E:  .byte $08, $02, $01, $04, $00, $A2, $00, $A3, $00, $A1, $00, $A0, $3A, $3D, $3C, $3B
LAD4E:  .byte $40, $41, $3F, $37

LAD52:  LDA $49
LAD54:  ASL
LAD55:  ASL
LAD56:  ASL
LAD57:  ASL
LAD58:  CLC
LAD59:  ADC $4A
LAD5B:  STA $2B
LAD5D:  LDA $42
LAD5F:  STA $2C
LAD61:  LDA #$78
LAD63:  STA $2A
LAD65:  LDA #$00
LAD67:  STA $29
LAD69:  LDA #$00
LAD6B:  STA $2E
LAD6D:  LDY #$00
LAD6F:  LDA ($29),Y
LAD71:  CMP $30
LAD73:  BNE LAD81
LAD75:  LDA $2A
LAD77:  CMP $2C
LAD79:  BNE LAD7F
LAD7B:  CPY $2B
LAD7D:  BEQ LAD89
LAD7F:  INC $2E
LAD81:  INY
LAD82:  BNE LAD6F
LAD84:  INC $2A
LAD86:  JMP LAD6F
LAD89:  LDA MapTypeNIndex
LAD8B:  ASL
LAD8C:  ASL
LAD8D:  CLC
LAD8E:  ADC $2F
LAD90:  TAX
LAD91:  LDA $B95D,X
LAD94:  STA $29
LAD96:  LDA $B95E,X
LAD99:  STA $2A
LAD9B:  LDY $2E
LAD9D:  LDA ($29),Y
LAD9F:  RTS
LADA0:  LDA #$01
LADA2:  STA $10
LADA4:  STA $14
LADA6:  LDA $03
LADA8:  ORA #$01
LADAA:  STA $03
LADAC:  LDA #$D4
LADAE:  STA HideUprSprites
LADB0:  JSR $C04B
LADB3:  RTS
LADB4:  LDA #$00
LADB6:  LDX #$00
LADB8:  STA $0400,X
LADBB:  INX
LADBC:  BNE LADB8
LADBE:  LDA #$00
LADC0:  STA $19
LADC2:  LDA $75
LADC4:  STA $17
LADC6:  AND #$07
LADC8:  BEQ LAE01
LADCA:  TAX
LADCB:  LDA $77
LADCD:  AND #$07
LADCF:  CMP #$05
LADD1:  BNE LADF6
LADD3:  TXA
LADD4:  CMP #$03
LADD6:  BEQ LADE9
LADD8:  CMP #$04
LADDA:  BNE LADF6
LADDC:  LDA #$B0
LADDE:  STA $2A
LADE0:  LDA #$BA
LADE2:  STA $29
LADE4:  LDX #$02
LADE6:  JMP LADFE
LADE9:  LDA #$B0
LADEB:  STA $2A
LADED:  LDA #$BA
LADEF:  STA $29
LADF1:  LDX #$01
LADF3:  JMP LADFE
LADF6:  LDA #$B0
LADF8:  STA $2A
LADFA:  LDA #$C2
LADFC:  STA $29
LADFE:  JSR LAF08
LAE01:  LDA #$01
LAE03:  STA $19
LAE05:  LDA $76
LAE07:  STA $17
LAE09:  AND #$07
LAE0B:  BEQ LAE44
LAE0D:  TAX
LAE0E:  LDA $78
LAE10:  AND #$07
LAE12:  CMP #$05
LAE14:  BNE LAE39
LAE16:  TXA
LAE17:  CMP #$03
LAE19:  BEQ LAE2C
LAE1B:  CMP #$04
LAE1D:  BNE LAE39
LAE1F:  LDA #$B0
LAE21:  STA $2A
LAE23:  LDA #$BE
LAE25:  STA $29
LAE27:  LDX #$02
LAE29:  JMP LAE41
LAE2C:  LDA #$B0
LAE2E:  STA $2A
LAE30:  LDA #$BE
LAE32:  STA $29
LAE34:  LDX #$01
LAE36:  JMP LAE41
LAE39:  LDA #$B0
LAE3B:  STA $2A
LAE3D:  LDA #$CE
LAE3F:  STA $29
LAE41:  JSR LAF08
LAE44:  LDA #$02
LAE46:  STA $19
LAE48:  LDA $77
LAE4A:  STA $17
LAE4C:  AND #$07
LAE4E:  BEQ LAE6C
LAE50:  CMP #$07
LAE52:  BNE LAE60
LAE54:  LDA #$B1
LAE56:  STA $2A
LAE58:  LDA #$0A
LAE5A:  STA $29
LAE5C:  JSR LAF6B
LAE5F:  RTS
LAE60:  TAX
LAE61:  LDA #$B0
LAE63:  STA $2A
LAE65:  LDA #$DA
LAE67:  STA $29
LAE69:  JSR LAF08
LAE6C:  LDA #$03
LAE6E:  STA $19
LAE70:  LDA $78
LAE72:  STA $17
LAE74:  AND #$07
LAE76:  BEQ LAE84
LAE78:  TAX
LAE79:  LDA #$B0
LAE7B:  STA $2A
LAE7D:  LDA #$E6
LAE7F:  STA $29
LAE81:  JSR LAF08
LAE84:  LDA #$04
LAE86:  STA $19
LAE88:  LDA $79
LAE8A:  STA $17
LAE8C:  AND #$07
LAE8E:  BEQ LAEAC
LAE90:  CMP #$07
LAE92:  BNE LAEA0
LAE94:  LDA #$B1
LAE96:  STA $2A
LAE98:  LDA #$0F
LAE9A:  STA $29
LAE9C:  JSR LAF6B
LAE9F:  RTS
LAEA0:  TAX
LAEA1:  LDA #$B0
LAEA3:  STA $2A
LAEA5:  LDA #$F2
LAEA7:  STA $29
LAEA9:  JSR LAF08
LAEAC:  LDA #$05
LAEAE:  STA $19
LAEB0:  LDA $7A
LAEB2:  STA $17
LAEB4:  AND #$07
LAEB6:  BEQ LAEC4
LAEB8:  TAX
LAEB9:  LDA #$B0
LAEBB:  STA $2A
LAEBD:  LDA #$FE
LAEBF:  STA $29
LAEC1:  JSR LAF08
LAEC4:  LDA #$06
LAEC6:  STA $19
LAEC8:  LDA $7B
LAECA:  STA $17
LAECC:  AND #$07
LAECE:  BEQ LAEEF
LAED0:  CMP #$07
LAED2:  BNE LAEE3
LAED4:  LDA #$00
LAED6:  STA $0477
LAED9:  STA $0478
LAEDC:  STA $0487
LAEDF:  STA $0488
LAEE2:  RTS
LAEE3:  TAX
LAEE4:  LDA #$B1
LAEE6:  STA $2A
LAEE8:  LDA #$0A
LAEEA:  STA $29
LAEEC:  JSR LAF08
LAEEF:  LDA #$07
LAEF1:  STA $19
LAEF3:  LDA $7C
LAEF5:  STA $17
LAEF7:  AND #$07
LAEF9:  BEQ LAF07
LAEFB:  TAX
LAEFC:  LDA #$B1
LAEFE:  STA $2A
LAF00:  LDA #$0A
LAF02:  STA $29
LAF04:  JSR LAF08
LAF07:  RTS
LAF08:  LDA #$00
LAF0A:  STA $30
LAF0C:  TXA
LAF0D:  AND #$01
LAF0F:  BNE LAF5C
LAF11:  TXA
LAF12:  PHA
LAF13:  DEX
LAF14:  LDA $2A
LAF16:  PHA
LAF17:  LDA $29
LAF19:  PHA
LAF1A:  LDA #$01
LAF1C:  STA $30
LAF1E:  LDA $17
LAF20:  PHA
LAF21:  LDA $17
LAF23:  AND #$7F
LAF25:  STA $17
LAF27:  JSR LAF5C
LAF2A:  PLA
LAF2B:  STA $17
LAF2D:  PLA
LAF2E:  STA $29
LAF30:  PLA
LAF31:  STA $2A
LAF33:  PLA
LAF34:  TAX
LAF35:  DEX
LAF36:  TXA
LAF37:  ASL
LAF38:  TAY
LAF39:  LDA ($29),Y
LAF3B:  TAX
LAF3C:  INY
LAF3D:  LDA ($29),Y
LAF3F:  STA $2A
LAF41:  STX $29
LAF43:  LDY #$00
LAF45:  LDA ($29),Y
LAF47:  STA $2E
LAF49:  INY
LAF4A:  LDA ($29),Y
LAF4C:  TAX
LAF4D:  INY
LAF4E:  LDA ($29),Y
LAF50:  STA $0400,X
LAF53:  INY
LAF54:  DEC $2E
LAF56:  BNE LAF4A
LAF58:  JSR LAFBB
LAF5B:  RTS
LAF5C:  TXA
LAF5D:  DEX
LAF5E:  TXA
LAF5F:  ASL
LAF60:  TAY
LAF61:  LDA ($29),Y
LAF63:  TAX
LAF64:  INY
LAF65:  LDA ($29),Y
LAF67:  STA $2A
LAF69:  STX $29
LAF6B:  LDY #$00
LAF6D:  LDA ($29),Y
LAF6F:  CMP #$FF
LAF71:  BEQ LAFBB
LAF73:  TAX
LAF74:  AND #$0F
LAF76:  STA $2E
LAF78:  INY
LAF79:  LDA ($29),Y
LAF7B:  STA $2D
LAF7D:  AND #$0F
LAF7F:  STA $2F
LAF81:  INY
LAF82:  LDA $30
LAF84:  BNE LAF8F
LAF86:  INY
LAF87:  LDA ($29),Y
LAF89:  STA $30
LAF8B:  INY
LAF8C:  JMP LAF95
LAF8F:  LDA ($29),Y
LAF91:  STA $30
LAF93:  INY
LAF94:  INY
LAF95:  LDA $30
LAF97:  STA $0400,X
LAF9A:  TXA
LAF9B:  AND #$0F
LAF9D:  CMP $2F
LAF9F:  BEQ LAFA5
LAFA1:  INX
LAFA2:  JMP LAF95
LAFA5:  TXA
LAFA6:  CMP $2D
LAFA8:  BEQ LAFB5
LAFAA:  AND #$F0
LAFAC:  CLC
LAFAD:  ADC #$10
LAFAF:  ADC $2E
LAFB1:  TAX
LAFB2:  JMP LAF95
LAFB5:  LDA ($29),Y
LAFB7:  CMP #$FF
LAFB9:  BNE LAF73
LAFBB:  LDA $2A
LAFBD:  PHA
LAFBE:  LDA $29
LAFC0:  PHA
LAFC1:  LDA $17
LAFC3:  BPL LAFF9
LAFC5:  CMP #$86
LAFC7:  BEQ LAFD1
LAFC9:  CMP #$87
LAFCB:  BNE LAFF9
LAFCD:  LDA $19
LAFCF:  BEQ LAFF9
LAFD1:  LDA $19
LAFD3:  ASL
LAFD4:  ASL
LAFD5:  TAX
LAFD6:  LDA $B02A,X
LAFD9:  STA $29
LAFDB:  LDA $B02B,X
LAFDE:  STA $2A
LAFE0:  LDA $17
LAFE2:  CMP #$86
LAFE4:  BEQ LAFF0
LAFE6:  LDA $B02C,X
LAFE9:  STA $29
LAFEB:  LDA $B02D,X
LAFEE:  STA $2A
LAFF0:  JSR LB012
LAFF3:  LDA $17
LAFF5:  AND #$7F
LAFF7:  STA $17
LAFF9:  JSR GetPlyrDngPos       ;($B628)Get current block player is standing on in dungeon.
LAFFC:  CMP #$03
LAFFE:  BCS LB00B
LB000:  LDA #$B5
LB002:  STA $2A
LB004:  LDA #$CB
LB006:  STA $29
LB008:  JSR LB012
LB00B:  PLA
LB00C:  STA $29
LB00E:  PLA
LB00F:  STA $2A
LB011:  RTS
LB012:  LDY #$00
LB014:  LDA ($29),Y
LB016:  BEQ LB029
LB018:  STA $2E
LB01A:  INY
LB01B:  LDA ($29),Y
LB01D:  TAX
LB01E:  INY
LB01F:  LDA ($29),Y
LB021:  STA $0400,X
LB024:  INY
LB025:  DEC $2E
LB027:  BNE LB01B
LB029:  RTS

LB02A:  .byte $5A, $B4, $CB, $B5, $AD, $B4, $CB, $B5, $79, $B4, $00, $B5, $CC, $B4, $00, $B5
LB03A:  .byte $A2, $B4, $A1, $B5, $F5, $B4, $A1, $B5, $01, $10, $10, $FF, $FF, $F0, $F0, $01
LB04A:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LB05A:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $02, $00, $00, $00
LB06A:  .byte $03, $04, $00, $00, $00, $05, $06, $00, $00, $00, $07, $00, $02, $00, $00, $00
LB07A:  .byte $03, $04, $00, $00, $00, $05, $06, $00, $00, $00, $00, $00, $04, $00, $00, $00
LB08A:  .byte $05, $06, $00, $00, $00, $07, $00, $00, $00, $00, $00, $00, $04, $00, $00, $00
LB09A:  .byte $05, $06, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $06, $00, $00, $00
LB0AA:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $06, $00, $00, $00
LB0BA:  .byte $51, $B1, $5B, $B1, $56, $B1, $64, $B1, $28, $B1, $99, $B1, $1E, $B1, $87, $B1
LB0CA:  .byte $14, $B1, $6D, $B1, $2D, $B1, $A2, $B1, $23, $B1, $90, $B1, $19, $B1, $7A, $B1
LB0DA:  .byte $50, $B1, $F7, $B1, $3C, $B1, $DD, $B1, $32, $B1, $AB, $B1, $50, $B1, $F7, $B1
LB0EA:  .byte $41, $B1, $EA, $B1, $37, $B1, $C4, $B1, $11, $B2, $11, $B2, $50, $B1, $11, $B2
LB0FA:  .byte $46, $B1, $F7, $B1, $11, $B2, $11, $B2, $50, $B1, $11, $B2, $4B, $B1, $04, $B2
LB10A:  .byte $22, $DD, $E3, $E3, $FF, $55, $AA, $E4, $E4, $FF, $20, $D1, $D4, $E3, $FF, $2E
LB11A:  .byte $DF, $D4, $E3, $FF, $60, $91, $D4, $E4, $FF, $6E, $9F, $D4, $E4, $FF, $70, $81
LB12A:  .byte $D4, $00, $FF, $7E, $8F, $D4, $00, $FF, $52, $A4, $D5, $E4, $FF, $5B, $AD, $D5
LB13A:  .byte $E4, $FF, $72, $84, $D5, $00, $FF, $7B, $8D, $D5, $00, $FF, $75, $86, $D6, $00
LB14A:  .byte $FF, $79, $8A, $D6, $00, $FF, $FF, $50, $A1, $D4, $E4, $FF, $5E, $AF, $D4, $E4
LB15A:  .byte $FF, $04, $40, $B8, $41, $B9, $B0, $BC, $B1, $BD, $04, $4E, $BA, $4F, $BB, $BE
LB16A:  .byte $BE, $BF, $BF, $06, $00, $D7, $10, $D4, $11, $D7, $E0, $D4, $E1, $D8, $F0, $D8
LB17A:  .byte $06, $0F, $DA, $1E, $DA, $1F, $D4, $EE, $D9, $EF, $D4, $FF, $D9, $04, $50, $B8
LB18A:  .byte $51, $B9, $A0, $BC, $A1, $BD, $04, $5E, $BA, $5F, $BB, $AE, $BE, $AF, $BF, $04
LB19A:  .byte $60, $A4, $61, $A5, $90, $A8, $91, $A9, $04, $6E, $A6, $6F, $A7, $9E, $AA, $9F
LB1AA:  .byte $AB, $0C, $22, $DB, $32, $D5, $33, $DB, $42, $D5, $43, $D5, $44, $DB, $B2, $D5
LB1BA:  .byte $B3, $D5, $B4, $DC, $C2, $D5, $C3, $DC, $D2, $DC, $0C, $2D, $DE, $3C, $DE, $3D
LB1CA:  .byte $D5, $4B, $DE, $4C, $D5, $4D, $D5, $BB, $DD, $BC, $D5, $BD, $D5, $CC, $DD, $CD
LB1DA:  .byte $D5, $DD, $DD, $06, $62, $C0, $63, $C1, $64, $C2, $92, $C6, $93, $C7, $94, $C8
LB1EA:  .byte $06, $6B, $C3, $6C, $C4, $6D, $C5, $9B, $C9, $9C, $CA, $9D, $CB, $06, $55, $DF
LB1FA:  .byte $65, $D6, $66, $DF, $95, $D6, $96, $E0, $A5, $E0, $06, $5A, $E2, $69, $E2, $6A
LB20A:  .byte $D6, $99, $E1, $9A, $D6, $AA, $E1, $FF

LB212:  JSR LB313
LB215:  LDA $7D
LB217:  AND #$01
LB219:  BNE LB234
LB21B:  TYA
LB21C:  AND #$F0
LB21E:  STA $2F
LB220:  TYA
LB221:  AND #$0F
LB223:  CLC
LB224:  ADC $2E
LB226:  CLC
LB227:  ADC $2E
LB229:  CLC
LB22A:  ADC $2E
LB22C:  AND #$0F
LB22E:  CLC
LB22F:  ADC $2F
LB231:  JMP LB23E
LB234:  TYA
LB235:  CLC
LB236:  ADC $2E
LB238:  CLC
LB239:  ADC $2E
LB23B:  CLC
LB23C:  ADC $2E
LB23E:  STA $30
LB240:  TAY
LB241:  LDA #$0D
LB243:  STA $75
LB245:  STA $76
LB247:  STA $77
LB249:  STA $78
LB24B:  LDX #$03
LB24D:  LDA ($41),Y
LB24F:  CMP #$06
LB251:  BCC LB257
LB253:  CMP #$0B
LB255:  BNE LB259
LB257:  STA $75,X
LB259:  LDA $7D
LB25B:  AND #$01
LB25D:  BEQ LB274
LB25F:  LDA $30
LB261:  AND #$F0
LB263:  STA $2F
LB265:  LDA $30
LB267:  AND #$0F
LB269:  CLC
LB26A:  ADC $2D
LB26C:  AND #$0F
LB26E:  CLC
LB26F:  ADC $2F
LB271:  JMP LB279
LB274:  LDA $30
LB276:  CLC
LB277:  ADC $2D
LB279:  STA $30
LB27B:  TAY
LB27C:  DEX
LB27D:  BPL LB24D
LB27F:  LDA #$44
LB281:  STA $17
LB283:  LDX #$00
LB285:  LDA $75,X
LB287:  CMP #$0D
LB289:  BEQ LB2DE
LB28B:  CMP #$0B
LB28D:  BNE LB2A6
LB28F:  STX $19
LB291:  STY $18
LB293:  TXA
LB294:  ASL
LB295:  TAY
LB296:  LDA $B30D,Y
LB299:  STA $29
LB29B:  LDA $B30E,Y
LB29E:  STA $2A
LB2A0:  JSR LB2E8
LB2A3:  JMP LB2DA
LB2A6:  CMP #$03
LB2A8:  BCC LB2E3
LB2AA:  STX $19
LB2AC:  STY $18
LB2AE:  TXA
LB2AF:  ASL
LB2B0:  ASL
LB2B1:  TAY
LB2B2:  LDA $75,X
LB2B4:  CMP #$04
LB2B6:  BEQ LB2C5
LB2B8:  LDA $B301,Y
LB2BB:  STA $29
LB2BD:  LDA $B302,Y
LB2C0:  STA $2A
LB2C2:  JSR LB2E8
LB2C5:  LDX $19
LB2C7:  LDA $75,X
LB2C9:  CMP #$03
LB2CB:  BEQ LB2DA
LB2CD:  LDA $B303,Y
LB2D0:  STA $29
LB2D2:  LDA $B304,Y
LB2D5:  STA $2A
LB2D7:  JSR LB2E8
LB2DA:  LDX $19
LB2DC:  LDY $18
LB2DE:  INX
LB2DF:  CPX #$03
LB2E1:  BNE LB285
LB2E3:  CPX #$00
LB2E5:  BEQ LB2DE
LB2E7:  RTS
LB2E8:  LDX $17
LB2EA:  TYA
LB2EB:  PHA
LB2EC:  LDY #$00
LB2EE:  LDA ($29),Y
LB2F0:  CMP #$FF
LB2F2:  BEQ LB2FC
LB2F4:  STA $7300,X
LB2F7:  INY
LB2F8:  INX
LB2F9:  JMP LB2EE
LB2FC:  STX $17
LB2FE:  PLA
LB2FF:  TAY
LB300:  RTS

LB301:  .byte $E0, $B3, $79, $B3, $1D, $B4, $B6, $B3, $36, $B4, $CF, $B3, $47, $B4, $58, $B4
LB311:  .byte $59, $B4

LB313:  LDA $7D
LB315:  ASL
LB316:  TAX
LB317:  LDA $B042,X
LB31A:  STA $2E
LB31C:  INX
LB31D:  LDA $B042,X
LB320:  STA $2D
LB322:  LDA $49
LB324:  ASL
LB325:  ASL
LB326:  ASL
LB327:  ASL
LB328:  CLC
LB329:  ADC $4A
LB32B:  PHA
LB32C:  LDA $7D
LB32E:  AND #$01
LB330:  BNE LB355
LB332:  PLA
LB333:  PHA
LB334:  AND #$F0
LB336:  STA $2F
LB338:  PLA
LB339:  AND #$0F
LB33B:  SEC
LB33C:  SBC $2E
LB33E:  SEC
LB33F:  SBC $2E
LB341:  SEC
LB342:  SBC $2E
LB344:  AND #$0F
LB346:  CLC
LB347:  ADC $2F
LB349:  SEC
LB34A:  SBC $2D
LB34C:  SEC
LB34D:  SBC $2D
LB34F:  SEC
LB350:  SBC $2D
LB352:  JMP LB375
LB355:  PLA
LB356:  PHA
LB357:  AND #$F0
LB359:  STA $2F
LB35B:  PLA
LB35C:  AND #$0F
LB35E:  SEC
LB35F:  SBC $2D
LB361:  SEC
LB362:  SBC $2D
LB364:  SEC
LB365:  SBC $2D
LB367:  AND #$0F
LB369:  CLC
LB36A:  ADC $2F
LB36C:  SEC
LB36D:  SBC $2E
LB36F:  SEC
LB370:  SBC $2E
LB372:  SEC
LB373:  SBC $2E
LB375:  STA $30
LB377:  TAY
LB378:  RTS

;----------------------------------------------------------------------------------------------------

;Unused.
LB379:  .byte $78, $E6, $01, $4C, $78, $E7, $01, $5C, $80, $E4, $01, $4C, $80, $E8, $01, $54
LB389:  .byte $80, $E5, $01, $5C, $88, $E6, $01, $4C, $88, $E7, $01, $5C, $90, $E4, $01, $4C
LB399:  .byte $90, $E8, $01, $54, $90, $E5, $01, $5C, $98, $E6, $01, $4C, $98, $E7, $01, $5C
LB3A9:  .byte $A0, $E4, $01, $4C, $A0, $E8, $01, $54, $A0, $E5, $01, $5C, $FF, $70, $E6, $01
LB3B9:  .byte $50, $70, $E7, $01, $58, $78, $E4, $01, $50, $78, $E5, $01, $58, $80, $E6, $01
LB3C9:  .byte $50, $80, $E7, $01, $58, $FF, $68, $E9, $01, $50, $68, $EA, $01, $58, $70, $E9
LB3D9:  .byte $01, $50, $70, $EA, $01, $58, $FF, $28, $E4, $01, $4C, $28, $E8, $01, $54, $28
LB3E9:  .byte $E5, $01, $5C, $30, $E6, $01, $4C, $30, $E7, $01, $5C, $38, $E4, $01, $4C, $38
LB3F9:  .byte $E8, $01, $54, $38, $E5, $01, $5C, $40, $E6, $01, $4C, $40, $E7, $01, $5C, $48
LB409:  .byte $E4, $01, $4C, $48, $E8, $01, $54, $48, $E5, $01, $5C, $50, $E6, $01, $4C, $50
LB419:  .byte $E7, $01, $5C, $FF, $48, $E6, $01, $50, $48, $E7, $01, $58, $50, $E4, $01, $50
LB429:  .byte $50, $E5, $01, $58, $58, $E6, $01, $50, $58, $E7, $01, $58, $FF, $58, $E9, $01
LB439:  .byte $50, $58, $EA, $01, $58, $60, $E9, $01, $50, $60, $EA, $01, $58, $FF, $98, $E0
LB449:  .byte $02, $50, $98, $E2, $02, $58, $A0, $E1, $02, $50, $A0, $E3, $02, $58, $FF, $FF
LB459:  .byte $FF, $0F, $10, $E5, $20, $EB, $30, $EB, $40, $EB, $50, $EB, $60, $EB, $70, $EB
LB469:  .byte $80, $EB, $90, $EB, $A0, $EB, $B0, $EB, $C0, $EB, $D0, $EB, $E0, $EB, $F0, $EC
LB479:  .byte $14, $32, $E6, $42, $EB, $52, $EB, $62, $EB, $72, $EB, $82, $EB, $92, $EB, $A2
LB489:  .byte $EB, $B2, $EB, $C2, $EB, $D2, $EC, $43, $E6, $53, $EB, $63, $EB, $73, $EB, $83
LB499:  .byte $EF, $93, $EB, $A3, $EB, $B3, $EB, $C3, $EC, $05, $65, $E7, $75, $EB, $85, $EF
LB4A9:  .byte $95, $EB, $A5, $EC, $0F, $1F, $E8, $2F, $EB, $3F, $EB, $4F, $EB, $5F, $EB, $6F
LB4B9:  .byte $EB, $7F, $EB, $8F, $EB, $9F, $EB, $AF, $EB, $BF, $EB, $CF, $EB, $DF, $EB, $EF
LB4C9:  .byte $EB, $FF, $ED, $14, $4C, $E9, $5C, $EB, $6C, $EB, $7C, $EB, $8C, $EB, $9C, $EB
LB4D9:  .byte $AC, $EB, $BC, $EB, $CC, $ED, $3D, $E9, $4D, $EB, $5D, $EB, $6D, $EB, $7D, $EB
LB4E9:  .byte $8D, $EF, $9D, $EB, $AD, $EB, $BD, $EB, $CD, $EB, $DD, $ED, $05, $6A, $EA, $7A
LB4F9:  .byte $EB, $8A, $EF, $9A, $EB, $AA, $ED, $50, $44, $EB, $54, $EB, $64, $EB, $74, $EB
LB509:  .byte $84, $EB, $94, $EB, $A4, $EB, $B4, $EB, $C4, $EB, $D4, $EB, $45, $EB, $55, $EB
LB519:  .byte $65, $EB, $75, $EB, $85, $EB, $95, $EB, $A5, $EB, $B5, $EB, $C5, $EB, $D5, $EB
LB529:  .byte $46, $EB, $56, $EB, $66, $EB, $76, $EB, $86, $EB, $96, $EB, $A6, $EB, $B6, $EB
LB539:  .byte $C6, $EB, $D6, $EB, $47, $EB, $57, $EB, $67, $EB, $77, $EB, $87, $EB, $97, $EB
LB549:  .byte $A7, $EB, $B7, $EB, $C7, $EB, $D7, $EB, $48, $EB, $58, $EB, $68, $EB, $78, $EB
LB559:  .byte $88, $EB, $98, $EB, $A8, $EB, $B8, $EB, $C8, $EB, $D8, $EB, $49, $EB, $59, $EB
LB569:  .byte $69, $EB, $79, $EB, $89, $EB, $99, $EB, $A9, $EB, $B9, $EB, $C9, $EB, $D9, $EB
LB579:  .byte $4A, $EB, $5A, $EB, $6A, $EB, $7A, $EB, $8A, $EB, $9A, $EE, $AA, $EB, $BA, $EB
LB589:  .byte $CA, $EB, $DA, $EB, $4B, $EB, $5B, $EB, $6B, $EB, $7B, $EB, $8B, $EB, $9B, $EB
LB599:  .byte $AB, $EB, $BB, $EB, $CB, $EB, $DB, $EB, $14, $66, $EB, $76, $EB, $86, $EB, $96
LB5A9:  .byte $EB, $A6, $EB, $67, $EB, $77, $EB, $87, $EB, $97, $EB, $A7, $EB, $68, $EB, $78
LB5B9:  .byte $EB, $88, $EB, $98, $EB, $A8, $EB, $69, $EB, $79, $EB, $89, $EF, $99, $EB, $A9
LB5C9:  .byte $EB, $00, $2E, $00, $EB, $01, $EB, $02, $EB, $03, $EB, $04, $EB, $05, $EB, $06
LB5D9:  .byte $EB, $07, $EB, $08, $EB, $09, $EB, $0A, $EB, $0B, $EB, $0C, $EB, $0D, $EB, $0E
LB5E9:  .byte $EB, $0F, $EB, $10, $EB, $20, $EB, $30, $EB, $40, $EB, $50, $EB, $60, $EB, $70
LB5F9:  .byte $EB, $80, $EB, $90, $EB, $A0, $EB, $B0, $EB, $C0, $EB, $D0, $EB, $E0, $EB, $F0
LB609:  .byte $EB, $1F, $EB, $2F, $EB, $3F, $EB, $4F, $EB, $5F, $EB, $6F, $EB, $7F, $EB, $8F
LB619:  .byte $EB, $9F, $EB, $AF, $EB, $BF, $EB, $CF, $EB, $DF, $EB, $EF, $EB, $FF, $EB

;----------------------------------------------------------------------------------------------------

GetPlyrDngPos:
LB628:  LDA MapYPos             ;
LB62A:  ASL                     ;
LB62B:  ASL                     ;*16 16 columns per dungeon map.
LB62C:  ASL                     ;
LB62D:  ASL                     ;

LB62E:  CLC                     ;Add player's X position to get current offset on dungeon map.
LB62F:  ADC MapXPos             ;

LB631:  TAY                     ;
LB632:  LDA (MapDatPtr),Y       ;Load current dungeon block into A.
LB634:  RTS                     ;

;----------------------------------------------------------------------------------------------------

CvDeathLv1:
;              C    A    V    E    _    O    F    \n   D    E    A    T    H   END
LB635:  .byte $8C, $8A, $9F, $8E, $00, $98, $8F, $FD, $8D, $8E, $8A, $9D, $91, $FF

CvDeathLv2:
;              S    E    C    R    E    T    \n   S    L    I    D    E    S    !   END
LB643:  .byte $9C, $8E, $8C, $9B, $8E, $9D, $FD, $9C, $95, $92, $8D, $8E, $9C, $7C, $FF

CvDeathLv3:
;              B    E    W    A    R    E    \n   T    R    A    P    S    !   END
LB652:  .byte $8B, $8E, $A0, $8A, $9B, $8E, $FD, $9D, $9B, $8A, $99, $9C, $7C, $FF

CvDeathLv4:
;              E    V    E    R    \n   A    D    V    E    N    T    U    R    E    !   END
LB660:  .byte $8E, $9F, $8E, $9B, $FD, $8A, $8D, $9F, $8E, $97, $9D, $9E, $9B, $8E, $7C, $FF

CvDeathLv5:
;              G    R    E    M    L    I    N    S    !   END
LB670:  .byte $90, $9B, $8E, $96, $95, $92, $97, $9C, $7C, $FF

CvDeathLv6:
;              C    I    R    C    L    E    \n   D    E    A    T    H    !   END
LB67A:  .byte $8C, $92, $9B, $8C, $95, $8E, $FD, $8D, $8E, $8A, $9D, $91, $7C, $FF

CvDeathLv7:
;              C    O    L    L    A    S    A    L    \n   C    A    V    E    R    N    !
LB688:  .byte $8C, $98, $95, $95, $8A, $9C, $8A, $95, $FD, $8C, $8A, $9F, $8E, $9B, $97, $7C
;             END
LB698:  .byte $FF

CvDeathLv8:
;              T    R    A    P    S    _    T    O    \n   G    O    L    D    !   END
LB699:  .byte $9D, $9B, $8A, $99, $9C, $00, $9D, $98, $FD, $90, $98, $95, $8D, $7C, $FF

;----------------------------------------------------------------------------------------------------

CvGoldLv1:
;              C    A    V    E    _    O    F    _    G    O    L    D   END
LB6A8:  .byte $8C, $8A, $9F, $8E, $00, $98, $8F, $00, $90, $98, $95, $8D, $FF

CvGoldLv2:
;              G    O    _    B    A    C    K    !   END
LB6B5:  .byte $90, $98, $00, $8B, $8A, $8C, $94, $7C, $FF

CvGoldLv3:
;              N    O    T    _    H    E    R    E    !   END
LB6BE:  .byte $97, $98, $9D, $00, $91, $8E, $9B, $8E, $7C, $FF

CvGoldLv4:
;              Q    U    A    R    T    E    R    \n   E    A    C    H    !   END
LB6C8:  .byte $9A, $9E, $8A, $9B, $9D, $8E, $9B, $FD, $8E, $8A, $8C, $91, $7C, $FF

CvGoldLv5:
;              D    E    A    T    H    \n   A    W    A    I    T    S    !   END
LB6D6:  .byte $8D, $8E, $8A, $9D, $91, $FD, $8A, $A0, $8A, $92, $9D, $9C, $7C, $FF

CvGoldLv6:
;              M    A    P    _    W    E    L    L    !   END
LB6E4:  .byte $96, $8A, $99, $00, $A0, $8E, $95, $95, $7C, $FF

CvGoldLv7:
;              G    R    E    M    L    I    N    S    !   END
LB6EE:  .byte $90, $9B, $8E, $96, $95, $92, $97, $9C, $7C, $FF

CvGoldLv8:
;              G    O    _    B    A    C    K    !   END
LB6F8:  .byte $90, $98, $00, $8B, $8A, $8C, $94, $7C, $FF

;----------------------------------------------------------------------------------------------------

CvMoonLv1:
;              C    A    V    E    _    O    F    _    M    O    O    N   END
LB701:  .byte $8C, $8A, $9F, $8E, $00, $98, $8F, $00, $96, $98, $98, $97, $FF

CvMoonLv2:
;              G    R    E    M    L    I    N    \n   G    O    L    D    !   END
LB70E:  .byte $90, $9B, $8E, $96, $95, $92, $97, $FD, $90, $98, $95, $8D, $7C, $FF

CvMoonLv3:
;              G    O    L    D    E    N    \n   C    E    N    T    E    R    !   END
LB71C:  .byte $90, $98, $95, $8D, $8E, $97, $FD, $8C, $8E, $97, $9D, $8E, $9B, $7C, $FF

CvMoonLv4:
;              S    T    A    I    R    _    T    O    \n   H    E    A    V    E    N    !
LB72B:  .byte $9C, $9D, $8A, $92, $9B, $00, $9D, $98, $FD, $91, $8E, $8A, $9F, $8E, $97, $7C
;             END
LB73B:  .byte $FF

CvMoonLv5:
;              T    I    M    E    _    R    U    N    S    \n   S    H    O    R    T    !
LB73C:  .byte $9D, $92, $96, $8E, $00, $9B, $9E, $97, $9C, $FD, $9C, $91, $98, $9B, $9D, $7C
;             END
LB74C:  .byte $FF

CvMoonLv6:
;              L    O    N    G    _    M    A    R    C    H    !   END
LB74D:  .byte $95, $98, $97, $90, $00, $96, $8A, $9B, $8C, $91, $7C, $FF

CvMoonLv7:
;              T    R    A    P    !   END
LB759:  .byte $9D, $9B, $8A, $99, $7C, $FF

CvMoonLv8:
;              V    E    R    Y    _    N    E    A    R    \n   N    O    W    !   END
LB75F:  .byte $9F, $8E, $9B, $A2, $00, $97, $8E, $8A, $9B, $FD, $97, $98, $A0, $7C, $FF

;----------------------------------------------------------------------------------------------------

CvFireLv1:
;              C    A    V    E    _    O    F    _    F    I    R    E   END
LB76E:  .byte $8C, $8A, $9F, $8E, $00, $98, $8F, $00, $8F, $92, $9B, $8E, $FF

CvFireLv2:
;              T    R    A    P    P    E    D    \n   D    O    O    R    !   END
LB77B:  .byte $9D, $9B, $8A, $99, $99, $8E, $8D, $FD, $8D, $98, $98, $9B, $7C, $FF

CvFireLv3:
;              T    W    I    S    T    Y    _    M    A    Z    E    !   END
LB789:  .byte $9D, $A0, $92, $9C, $9D, $A2, $00, $96, $8A, $A3, $8E, $7C, $FF

CvFireLv4:
;              W    I    N    D    Y    _    W    A    L    K    !   END
LB796:  .byte $A0, $92, $97, $8D, $A2, $00, $A0, $8A, $95, $94, $7C, $FF

CvFireLv5:
;              G    R    E    M    L    I    N    \n   C    I    T    Y    !   END
LB7A2:  .byte $90, $9B, $8E, $96, $95, $92, $97, $FD, $8C, $92, $9D, $A2, $7C, $FF

CvFireLv6:
;              D    E    V    I    L    S    _    D    E    N    !   END
LB7B0:  .byte $8D, $8E, $9F, $92, $95, $9C, $00, $8D, $8E, $97, $7C, $FF

CvFireLv7:
;              G    O    _    B    A    C    K    !    \n   P    I    T    S    !   END
LB7BC:  .byte $90, $98, $00, $8B, $8A, $8C, $94, $7C, $FD, $99, $92, $9D, $9C, $7C, $FF

CvFireLv8:
;              C    H    A    M    B    E    R    _    O    F    \n   F    I    R    E    !
LB7CB:  .byte $8C, $91, $8A, $96, $8B, $8E, $9B, $00, $98, $8F, $FD, $8F, $92, $9B, $8E, $7C
;              !
LB7DB:  .byte $FF

;----------------------------------------------------------------------------------------------------

CvFoolLv1:
;              C    A    V    E    _    O    F    _    F    O    O    L   END
LB7DC:  .byte $8C, $8A, $9F, $8E, $00, $98, $8F, $00, $8F, $98, $98, $95, $FF

CvFoolLv2:
;              S    E    C    R    E    T    \n   C    O    R    N    E    R    S    !   END
LB7E9:  .byte $9C, $8E, $8C, $9B, $8E, $9D, $FD, $8C, $98, $9B, $97, $8E, $9B, $9C, $7C, $FF

CvFoolLv3:
;              T    R    A    P    _    &    \n   T    R    E    A    S    U    R    E   END
LB7F9:  .byte $9D, $9B, $8A, $99, $00, $06, $FD, $9D, $9B, $8E, $8A, $9C, $9E, $9B, $8E, $FF

CvFoolLv4:
;              B    E    W    A    R    E    \n   T    H    E    _    W    I    N    D   END
LB809:  .byte $8B, $8E, $A0, $8A, $9B, $8E, $FD, $9D, $91, $8E, $00, $A0, $92, $97, $8D, $FF

CvFoolLv5:
;              D    A    N    G    E    R    !   END
LB819:  .byte $8D, $8A, $97, $90, $8E, $9B, $7C, $FF

CvFoolLv6:
;              M    A    P    _    W    E    L    L    !   END
LB821:  .byte $96, $8A, $99, $00, $A0, $8E, $95, $95, $7C, $FF

CvFoolLv7:
;              R    E    A    C    H    _    U    P    !   END
LB82B:  .byte $9B, $8E, $8A, $8C, $91, $00, $9E, $99, $7C, $FF

CvFoolLv8:
;              W    I    N    D    Y    _    S    E    C    R    E    T   END
LB835:  .byte $A0, $92, $97, $8D, $A2, $00, $9C, $8E, $8C, $9B, $8E, $9D, $FF

;----------------------------------------------------------------------------------------------------

CvMadnessLv1:
;              C    A    V    E    _    O    F    \n   M    A    D    N    E    S    S   END
LB842:  .byte $8C, $8A, $9F, $8E, $00, $98, $8F, $FD, $96, $8A, $8D, $97, $8E, $9C, $9C, $FF

CvMadnessLv2:
;              T    E    R    R    O    R    \n   T    U    N    N    E    L    S    !   END
LB852:  .byte $9D, $8E, $9B, $9B, $98, $9B, $FD, $9D, $9E, $97, $97, $8E, $95, $9C, $7C, $FF

CvMadnessLv3:
;              L    O    N    G    _    M    A    R    C    H    !   END
LB862:  .byte $95, $98, $97, $90, $00, $96, $8A, $9B, $8C, $91, $7C, $FF

CvMadnessLv4:
;              M    I    S    T    Y    _    C    A    V    E    !   END
LB86E:  .byte $96, $92, $9C, $9D, $A2, $00, $8C, $8A, $9F, $8E, $7C, $FF

CvMadnessLv5:
;              C    A    V    E    _    O    F    \n   M    A    D    N    E    S    S   END
LB87A:  .byte $8C, $8A, $9F, $8E, $00, $98, $8F, $FD, $96, $8A, $8D, $97, $8E, $9C, $9C, $FF

CvMadnessLv6:
;              G    O    L    D    _    T    R    A    P    _    &    \n   G    R    E    M
LB88A:  .byte $90, $98, $95, $8D, $00, $9D, $9B, $8A, $99, $00, $06, $FD, $90, $9B, $8E, $96
;              L    I    N    S    !   END
LB89A:  .byte $95, $92, $97, $9C, $7C, $FF

CvMadnessLv7:
;              G    O    L    D    \n   P    R    E    V    A    I    L    S    !   END
LB8A0:  .byte $8D, $8A, $9B, $94, $FD, $99, $9B, $8E, $9F, $8A, $92, $95, $9C, $7C, $FF

CvMadnessLv8:
;              D    R    Y    _    H    O    L    E    !   END
LB8AF:  .byte $8D, $9B, $A2, $00, $91, $98, $95, $8E, $7C, $FF

;----------------------------------------------------------------------------------------------------

CvSolLv1:
;              C    A    V    E    _    O    F    _    S    O    L   END
LB8B9:  .byte $8C, $8A, $9F, $8E, $00, $98, $8F, $00, $9C, $98, $95, $FF

CvSolLv2:
;              P    R    A    Y    \n   T    H    E    _    A    L    T    E    R    !   END
LB8C5:  .byte $99, $9B, $8A, $A2, $FD, $9D, $91, $8E, $00, $8A, $95, $9D, $8A, $9B, $7C, $FF

CvSolLv3:
;              P    R    A    Y    \n   T    H    E    _    S    H    R    I    N    E    S
LB8D5:  .byte $99, $9B, $8A, $A2, $FD, $9D, $91, $8E, $00, $9C, $91, $9B, $92, $97, $8E, $9C
;              !   END
LB8E5:  .byte $7C, $FF

CvSolLv4:
;              _
LB8E7:  .byte $FF

CvSolLv5:
;              D    O    N    '    T    _    D    R    I    N    K    !   END
LB8E8:  .byte $8D, $98, $97, $04, $9D, $00, $8D, $9B, $92, $97, $94, $7C, $FF

CvSolLv6:
;              D    O    N    '    T    _    D    R    I    N    K    !   END
LB8F5:  .byte $8D, $98, $97, $04, $9D, $00, $8D, $9B, $92, $97, $94, $7C, $FF

CvSolLv7:
;              G    R    E    M    L    I    N    S    !   END
LB902:  .byte $90, $9B, $8E, $96, $95, $92, $97, $9C, $7C, $FF

CvSolLv8:
;              W    I    N    D    Y    _    G    O    L    D    !   END
LB90C:  .byte $A0, $92, $97, $8D, $A2, $00, $90, $98, $95, $8D, $7C, $FF

;----------------------------------------------------------------------------------------------------

LB918:  PHA
LB919:  CLC
LB91A:  ADC $0300
LB91D:  BCS LB933
LB91F:  TAX
LB920:  LDA $9E
LB922:  ORA $9F
LB924:  BEQ LB92E
LB926:  TXA
LB927:  CMP #$60
LB929:  BCC LB93B
LB92B:  JMP LB933
LB92E:  TXA
LB92F:  CMP #$20
LB931:  BCC LB93B
LB933:  LDA #$01
LB935:  STA $0E
LB937:  LDA $0E
LB939:  BNE LB937
LB93B:  LDA #$00
LB93D:  STA $0E
LB93F:  LDX $0300
LB942:  INX
LB943:  CLC
LB944:  PLA
LB945:  ADC #$02
LB947:  STA $0300,X
LB94A:  INX
LB94B:  SEC
LB94C:  ADC $0300
LB94F:  STA $0300
LB952:  RTS
LB953:  LDA $0300
LB956:  BEQ LB95C
LB958:  LDA #$01
LB95A:  STA $0E
LB95C:  RTS

LB95D:  .byte $79, $B9, $7B, $B9, $84, $B9, $88, $B9, $92, $B9, $95, $B9, $9C, $B9, $9E, $B9
LB969:  .byte $A9, $B9, $AA, $B9, $B2, $B9, $B5, $B9, $BE, $B9, $C0, $B9

LB975:  .byte $00, $00, $02, $00

LB979:  .byte $03, $03, $01, $03, $00, $00, $01, $00, $00, $01, $00, $03, $03, $01, $00, $03
LB989:  .byte $01, $03, $01, $01, $00, $01, $01, $00, $00, $00, $01, $01, $00, $02, $00, $02
LB999:  .byte $01, $01, $03, $00, $02, $01, $00, $00, $00, $01, $02, $03, $02, $01, $00, $01
LB9A9:  .byte $02, $01, $03, $00, $02, $00, $01, $00, $03, $01, $03, $03, $02, $01, $03, $00
LB9B9:  .byte $02, $03, $01, $01, $03, $02, $02, $03, $02, $02, $02, $02, $02, $02, $02, $02
LB9C9:  .byte $01, $00, $01, $00, $00, $02, $03, $01, $02, $00, $01, $7F, $7F, $FF, $3F, $11
LB9D9:  .byte $FF, $7F, $7E, $00, $00, $00, $C0, $E0, $E0, $80, $C0, $00, $00, $C0, $E0, $F0
LB9E9:  .byte $F0, $F0, $F8, $D0, $D8, $D8, $3C, $00, $00, $08, $1C, $F8, $FC, $FC, $FE, $FF
LB9F9:  .byte $FF, $F6, $E0, $8E, $A4, $0A, $0B, $8E, $A4, $16, $0B, $8E, $A4, $0B, $20, $8E
LBA09:  .byte $A4, $28, $1D, $8E, $A4, $28, $23, $8E, $A7, $28, $21, $8E, $A7, $28, $1F, $03
LBA19:  .byte $F2, $10, $09, $10, $A9, $0F, $0C, $02, $B5, $2B, $03, $82, $B4, $3A, $09, $8C
LBA29:  .byte $B3, $3A, $0B, $81, $A7, $3D, $20, $8C, $B3, $3A, $36, $82, $B4, $2D, $38, $0C
LBA39:  .byte $AA, $32, $31, $0D, $AF, $29, $33, $84, $F3, $10, $36, $09, $B2, $19, $2D, $0C
LBA49:  .byte $A6, $04, $21, $06, $F4, $34, $23, $11, $F5, $34, $1E, $09, $AE, $32, $20, $0C
LBA59:  .byte $B0, $35, $21, $8C, $B1, $38, $23, $90, $B6, $38, $20, $0C, $A3, $19, $16, $0C
LBA69:  .byte $E5, $32, $0D, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBA79:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBA89:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $0F, $CF, $CF, $00, $3F
LBA99:  .byte $3F, $3F, $7F, $00, $00, $00, $00, $00, $00, $00, $00, $E0, $F0, $F0, $F0, $F8
LBAA9:  .byte $F8, $F8, $F0, $98, $1E, $06, $E0, $00, $00, $00, $00, $E0, $E6, $E6, $00, $F0
LBAB9:  .byte $F8, $F8, $FC, $00, $00, $00, $00, $00, $00, $C0, $E0, $0F, $1F, $1F, $1F, $3F
LBAC9:  .byte $3F, $FF, $9F, $73, $30, $00, $0F, $00, $00, $00, $00, $0F, $0F, $0F, $00, $1F
LBAD9:  .byte $3F, $3F, $7F, $00, $00, $00, $00, $00, $00, $06, $0E, $E0, $F0, $F0, $F0, $F8
LBAE9:  .byte $F8, $FE, $F2, $9C, $18, $00, $E0, $00, $00, $00, $00, $E0, $E0, $E0, $00, $F0
LBAF9:  .byte $F8, $F8, $FC, $82, $95, $0F, $1E, $0C, $9E, $18, $21, $82, $95, $0F, $33, $87
LBB09:  .byte $F6, $32, $33, $0F, $99, $2D, $31, $01, $9F, $30, $2C, $0F, $03, $38, $2B, $0C
LBB19:  .byte $08, $26, $22, $14, $F1, $2C, $22, $86, $F4, $2A, $1D, $09, $97, $2C, $14, $0C
LBB29:  .byte $9C, $1A, $16, $84, $F7, $08, $0E, $13, $DD, $0A, $09, $13, $DD, $0E, $0A, $13
LBB39:  .byte $DD, $0B, $12, $92, $F5, $31, $0C, $09, $96, $30, $11, $90, $9B, $35, $10, $0C
LBB49:  .byte $07, $24, $0F, $8C, $A0, $28, $23, $8F, $A2, $1A, $2A, $FF, $FF, $FF, $FF, $FF
LBB59:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBB69:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LBB79:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $3F
LBB89:  .byte $3F, $3F, $1F, $03, $03, $01, $07, $00, $00, $00, $00, $0C, $04, $07, $01, $0F
LBB99:  .byte $1F, $1F, $3F, $00, $00, $00, $10, $10, $D0, $D0, $F0, $E0, $F0, $F0, $F8, $F8
LBBA9:  .byte $F8, $F0, $F0, $70, $1C, $8C, $E0, $F0, $F0, $70, $00, $E0, $E4, $EC, $80, $00
LBBB9:  .byte $00, $80, $F8, $00, $00, $00, $00, $00, $0D, $0D, $06, $0F, $1F, $1F, $1F, $3F
LBBC9:  .byte $3F, $3F, $19, $07, $03, $00, $07, $00, $00, $00, $00, $08, $04, $07, $00, $0F
LBBD9:  .byte $1F, $1F, $3F, $00, $00, $00, $10, $30, $D0, $D6, $FE, $E0, $F0, $F0, $F8, $F8
LBBE9:  .byte $F8, $F6, $F6, $78, $10, $00, $E0, $F0, $F8, $78, $00, $E0, $E0, $E0, $00, $00
LBBF9:  .byte $00, $80, $FC

LBC00:  LDA #$01
LBC02:  STA $10
LBC04:  STA $14
LBC06:  STA $9E
LBC08:  LDA $03
LBC0A:  ORA #$01
LBC0C:  STA $03
LBC0E:  LDX #$00
LBC10:  LDY #$40
LBC12:  JSR LBCAF
LBC15:  LDY #$00
LBC17:  LDA ($41),Y
LBC19:  TAX
LBC1A:  LDA $BCA1,X
LBC1D:  STA ScreenBlocks,Y
LBC20:  INY
LBC21:  BNE LBC17
LBC23:  LDA #$24
LBC25:  STA $2A
LBC27:  LDA #$A3
LBC29:  STA $29
LBC2B:  LDA #$10
LBC2D:  STA $2C
LBC2F:  LDY #$00
LBC31:  LDA #$10
LBC33:  STA $2E
LBC35:  JSR LB918
LBC38:  LDA $2A
LBC3A:  STA $0300,X
LBC3D:  INX
LBC3E:  LDA $29
LBC40:  STA $0300,X
LBC43:  LDA #$10
LBC45:  STA $2E
LBC47:  INX
LBC48:  LDA ScreenBlocks,Y
LBC4B:  STA $0300,X
LBC4E:  INY
LBC4F:  DEC $2E
LBC51:  BNE LBC47
LBC53:  CLC
LBC54:  LDA $29
LBC56:  ADC #$20
LBC58:  STA $29
LBC5A:  LDA $2A
LBC5C:  ADC #$00
LBC5E:  STA $2A
LBC60:  DEC $2C
LBC62:  BNE LBC31
LBC64:  LDA $49
LBC66:  ASL
LBC67:  ASL
LBC68:  ASL
LBC69:  CLC
LBC6A:  ADC #$28
LBC6C:  STA $7300
LBC6F:  LDA $4A
LBC71:  ASL
LBC72:  ASL
LBC73:  ASL
LBC74:  CLC
LBC75:  ADC #$18
LBC77:  STA $7303
LBC7A:  JSR LBD00
LBC7D:  JSR $C04B
LBC80:  LDA #$BD
LBC82:  STA $2A
LBC84:  LDA #$4B
LBC86:  STA $29
LBC88:  JSR LBD6B
LBC8B:  LDA #$00
LBC8D:  STA $9E
LBC8F:  LDA #$1E
LBC91:  STA $04
LBC93:  JSR LB953
LBC96:  LDA #$FF
LBC98:  STA $9B
LBC9A:  JSR LBDAE
LBC9D:  JSR $C027
LBCA0:  RTS

LBCA1:  .byte  $F4, $F5, $F6, $F8, $F7, $F9, $FA, $FA, $FA, $FA, $FA, $FA, $FA, $00

LBCAF:  LDA #SPRT_HIDE
LBCB1:  STA $7300,X
LBCB4:  INX
LBCB5:  INX
LBCB6:  INX
LBCB7:  INX
LBCB8:  DEY
LBCB9:  BNE LBCB1
LBCBB:  RTS

LBCBC:  .byte $37, $6F, $FE, $DF, $FF, $F6, $EF, $EE, $E5, $F5, $54, $52, $DF, $FF, $BD, $FA
LBCCC:  .byte $F0, $E0, $C2, $C0, $AC, $F1, $FE, $B0, $C7, $FC, $FF, $FC, $E0, $D2, $E0, $F0
LBCDC:  .byte $F8, $7C, $DF, $FF, $3F, $FF, $3F, $E3, $0D, $7F, $8F, $35, $FF, $FB, $3E, $1F
LBCEC:  .byte $0F, $07, $4B, $07, $4A, $2A, $AF, $A7, $77, $F7, $6F, $FF, $03, $43, $07, $0F
LBCFC:  .byte $5F

LBCFD:  LDA $FBFF,X
LBD00:  LDX #$00
LBD02:  LDA #$0E
LBD04:  STA ScreenBlocks,X
LBD07:  INX
LBD08:  BNE LBD04
LBD0A:  LDA #$09
LBD0C:  STA $2E
LBD0E:  LDA #$21
LBD10:  STA $30
LBD12:  LDX $30
LBD14:  LDA #$04
LBD16:  LDY #$09
LBD18:  STA ScreenBlocks,X
LBD1B:  INX
LBD1C:  DEY
LBD1D:  BNE LBD18
LBD1F:  CLC
LBD20:  LDA $30
LBD22:  ADC #$10
LBD24:  STA $30
LBD26:  DEC $2E
LBD28:  BNE LBD12
LBD2A:  LDA #$03
LBD2C:  STA $2E
LBD2E:  LDA #$54
LBD30:  STA $30
LBD32:  LDX $30
LBD34:  LDA #$00
LBD36:  LDY #$03
LBD38:  STA ScreenBlocks,X
LBD3B:  INX
LBD3C:  DEY
LBD3D:  BNE LBD38
LBD3F:  CLC
LBD40:  LDA $30
LBD42:  ADC #$10
LBD44:  STA $30
LBD46:  DEC $2E
LBD48:  BNE LBD32
LBD4A:  RTS

LBD4B:  .byte $2F, $30, $30, $00, $2F, $30, $30, $30, $2F, $3F, $18, $28, $2F, $3F, $18, $28
LBD5B:  .byte $2F, $30, $30, $00, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F, $2F

LBD6B:  LDY #$00
LBD6D:  LDA ($29),Y
LBD6F:  STA $7500,Y
LBD72:  INY
LBD73:  CPY #$20
LBD75:  BNE LBD6D
LBD77:  LDA #$20
LBD79:  JSR LB918
LBD7C:  LDA #$3F
LBD7E:  STA $0300,X
LBD81:  INX
LBD82:  LDA #$00
LBD84:  STA $0300,X
LBD87:  LDY #$00
LBD89:  LDA ($29),Y
LBD8B:  INX
LBD8C:  STA $0300,X
LBD8F:  INY
LBD90:  CPY #$20
LBD92:  BNE LBD89
LBD94:  LDA #$01
LBD96:  JSR LB918
LBD99:  LDA #$00
LBD9B:  STA $0300,X
LBD9E:  INX
LBD9F:  LDA #$00
LBDA1:  STA $0300,X
LBDA4:  INX
LBDA5:  LDA #$00
LBDA7:  STA $0300,X
LBDAA:  JSR LB953
LBDAD:  RTS
LBDAE:  LDA #$00
LBDB0:  STA $A9
LBDB2:  STA $0A
LBDB4:  LDA $00
LBDB6:  CMP $00
LBDB8:  BEQ LBDB6
LBDBA:  LDA $0A
LBDBC:  BEQ LBDAE
LBDBE:  LDA $09
LBDC0:  AND $9B
LBDC2:  BEQ LBDAE
LBDC4:  RTS

;----------------------------------------------------------------------------------------------------

;Unused tile patterns.
LBDC5:  .byte $F5, $54, $52, $DF, $FF, $BD, $FA, $F0, $E0, $C2, $C0, $AC, $F1, $FE, $B0, $C7
LBDD5:  .byte $FC, $FF, $FC, $E0, $D2, $E0, $F0, $F8, $7C, $DF, $FF, $3F, $FF, $3F, $E3, $0D
LBDE5:  .byte $7F, $8F, $35, $FF, $FB, $3E, $1F, $0F, $07, $4B, $07, $4A, $2A, $AF, $A7, $77
LBDF5:  .byte $F7, $6F, $FF, $03, $43, $07, $0F, $5F, $BD, $FF, $FB, $00, $06, $0E, $14, $24
LBE05:  .byte $7C, $C4, $84, $00, $00, $00, $00, $00, $00, $00, $00, $00, $7C, $26, $26, $7C
LBE15:  .byte $46, $C6, $FC, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $66, $66, $C0
LBE25:  .byte $C4, $CC, $78, $00, $00, $00, $00, $00, $00, $00, $00, $00, $F8, $6C, $66, $66
LBE35:  .byte $C6, $CC, $F8, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FE, $70, $60, $7E
LBE45:  .byte $E0, $C0, $FE, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FE, $70, $60, $7E
LBE55:  .byte $E0, $C0, $C0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $66, $66, $C0
LBE65:  .byte $DE, $CC, $78, $00, $00, $00, $00, $00, $00, $00, $00, $00, $66, $66, $66, $7E
LBE75:  .byte $CC, $CC, $CC, $00, $00, $00, $00, $00, $00, $00, $00, $00, $18, $18, $18, $18
LBE85:  .byte $30, $30, $30, $00, $00, $00, $00, $00, $00, $00, $00, $00, $06, $06, $0C, $0C
LBE95:  .byte $CC, $D8, $78, $00, $00, $00, $00, $00, $00, $00, $00, $00, $32, $2C, $38, $70
LBEA5:  .byte $58, $CC, $86, $00, $00, $00, $00, $00, $00, $00, $00, $00, $30, $30, $60, $60
LBEB5:  .byte $C0, $C0, $FE, $00, $00, $00, $00, $00, $00, $00, $00, $00, $46, $6E, $7E, $56
LBEC5:  .byte $84, $8C, $8C, $00, $00, $00, $00, $00, $00, $00, $00, $00, $46, $66, $76, $5E
LBED5:  .byte $CC, $CC, $CC, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $66, $66, $EE
LBEE5:  .byte $CC, $CC, $78, $00, $00, $00, $00, $00, $00, $00, $00, $00, $7C, $66, $66, $66
LBEF5:  .byte $FC, $C0, $C0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $66, $66, $C6
LBF05:  .byte $DC, $CC, $76, $00, $00, $00, $00, $00, $00, $00, $00, $00, $7C, $66, $66, $66
LBF15:  .byte $FC, $C8, $C6, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3C, $66, $60, $3C
LBF25:  .byte $86, $C6, $7C, $00, $00, $00, $00, $00, $00, $00, $00, $00, $7E, $18, $18, $18
LBF35:  .byte $30, $30, $30, $00, $00, $00, $00, $00, $00, $00, $00, $00, $66, $66, $66, $C6
LBF45:  .byte $CE, $CC, $78, $00, $00, $00, $00, $00, $00, $00, $00, $00, $72, $32, $32, $34
LBF55:  .byte $64, $78, $70, $00, $00, $00, $00, $00, $00, $00, $00, $00, $E2, $62, $42, $5A
LBF65:  .byte $BA, $CC, $84, $00, $00, $00, $00, $00, $00, $00, $00, $00, $C2, $2C, $38, $10
LBF75:  .byte $38, $CC, $86, $00, $00, $00, $00, $00, $00, $00, $00, $00, $62, $36, $1C, $18
LBF85:  .byte $10, $30, $60, $00, $00, $00, $00, $00, $00, $00, $00, $00, $7E, $0C, $18, $30
LBF95:  .byte $60, $C0, $FC, $00, $00, $00, $00, $00, $00, $00, $00

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
