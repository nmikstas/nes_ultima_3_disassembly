.org $8000

.include "Ultima_3_Defines.asm"

;----------------------------------------------------------------------------------------------------

;Forward declarations.

.alias  Reset1                  $C000
.alias  DisplayText1            $C003
.alias  LoadPPU1                $C006
.alias  RESET                   $FFA0
.alias  ConfigMMC               $FFBC
.alias  NMI                     $FFF0
.alias  IRQ                     $FFF0

;----------------------------------------------------------------------------------------------------

;Tile patterns for the intro GFX.

IntroGFXTiles:
L8000:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L8010:  .byte $00, $60, $39, $1F, $0F, $0F, $0F, $0F, $30, $1E, $06, $00, $00, $00, $00, $00
L8020:  .byte $0C, $7C, $F8, $F0, $E0, $C0, $C0, $C0, $00, $02, $06, $0C, $18, $30, $30, $30
L8030:  .byte $10, $38, $1F, $0F, $07, $03, $03, $03, $0C, $06, $00, $00, $00, $00, $00, $00
L8040:  .byte $0C, $3C, $F0, $F0, $C0, $C0, $C0, $C0, $02, $03, $0E, $0C, $38, $30, $30, $30
L8050:  .byte $00, $00, $01, $1F, $1F, $07, $03, $03, $00, $00, $00, $00, $00, $00, $00, $00
L8060:  .byte $0C, $38, $F0, $F0, $F0, $F0, $F0, $F0, $03, $06, $0E, $0C, $0C, $0C, $0C, $0C
L8070:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L8080:  .byte $00, $00, $00, $00, $00, $00, $10, $10, $00, $00, $00, $00, $04, $0C, $0C, $0C
L8090:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L80A0:  .byte $00, $00, $00, $00, $3C, $7C, $FC, $FC, $00, $00, $00, $00, $00, $02, $03, $03
L80B0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L80C0:  .byte $00, $00, $00, $00, $08, $19, $3F, $FF, $00, $00, $00, $00, $04, $04, $00, $00
L80D0:  .byte $00, $00, $00, $00, $F0, $F8, $FC, $FC, $00, $00, $00, $00, $0C, $06, $03, $03
L80E0:  .byte $00, $00, $00, $00, $3F, $7F, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
L80F0:  .byte $00, $00, $00, $00, $C0, $E0, $F0, $F0, $00, $00, $00, $00, $30, $18, $0C, $0C
L8100:  .byte $00, $00, $00, $00, $F1, $5B, $55, $51, $00, $00, $00, $00, $00, $00, $00, $00
L8110:  .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $00, $00, $00, $00, $00, $00, $00, $00
L8120:  .byte $C0, $C0, $C0, $C0, $C0, $C0, $C0, $C0, $30, $30, $30, $30, $30, $30, $30, $30
L8130:  .byte $03, $03, $03, $03, $03, $03, $03, $03, $00, $00, $00, $00, $00, $00, $00, $00
L8140:  .byte $C0, $C0, $C0, $C0, $C0, $C0, $C0, $C0, $30, $30, $30, $30, $30, $30, $30, $30
L8150:  .byte $03, $03, $03, $03, $03, $03, $03, $03, $00, $00, $00, $00, $00, $00, $00, $00
L8160:  .byte $F0, $F0, $F0, $F0, $F0, $F0, $F0, $F0, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C
L8170:  .byte $00, $00, $00, $00, $01, $07, $3F, $FF, $00, $00, $00, $00, $00, $00, $00, $00
L8180:  .byte $30, $30, $70, $F0, $FF, $FF, $FC, $FC, $0C, $0C, $0C, $0C, $00, $00, $03, $03
L8190:  .byte $00, $00, $00, $00, $F0, $F0, $00, $00, $00, $00, $00, $00, $00, $00, $F0, $F0
L81A0:  .byte $FC, $F8, $70, $00, $00, $04, $0C, $3C, $03, $07, $0E, $3C, $03, $03, $03, $03
L81B0:  .byte $0F, $0F, $00, $00, $03, $03, $03, $03, $00, $00, $03, $03, $03, $03, $00, $00
L81C0:  .byte $FC, $F8, $01, $02, $FC, $F0, $00, $00, $03, $07, $FF, $FE, $FC, $FC, $FC, $FC
L81D0:  .byte $3F, $3F, $00, $00, $3F, $3E, $30, $30, $C0, $C0, $3F, $3F, $3F, $3F, $0F, $0F
L81E0:  .byte $C7, $83, $20, $40, $83, $03, $03, $03, $38, $7C, $E7, $C3, $C3, $C3, $C0, $C0
L81F0:  .byte $F0, $F4, $04, $0C, $F8, $E0, $00, $00, $0C, $0C, $FC, $FC, $FC, $FC, $FC, $FC
L8200:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $CC, $CC, $FC, $FC, $C0, $C0
L8210:  .byte $0F, $0F, $00, $00, $0F, $0F, $0C, $0C, $00, $00, $0F, $0F, $0F, $0F, $03, $03
L8220:  .byte $C0, $10, $10, $30, $E0, $80, $00, $00, $30, $F0, $F0, $F0, $F0, $F0, $F0, $F0
L8230:  .byte $03, $03, $00, $00, $03, $03, $03, $03, $00, $00, $03, $03, $03, $03, $00, $00
L8240:  .byte $80, $10, $10, $30, $E0, $80, $00, $00, $70, $F0, $F0, $F0, $F0, $F8, $F8, $FC
L8250:  .byte $03, $03, $00, $00, $03, $03, $03, $03, $00, $00, $03, $03, $03, $03, $00, $00
L8260:  .byte $F0, $E4, $04, $0C, $F8, $E0, $00, $00, $0C, $1C, $FC, $FC, $FC, $FC, $FC, $FC
L8270:  .byte $03, $03, $00, $00, $03, $03, $03, $03, $00, $00, $03, $03, $03, $03, $00, $00
L8280:  .byte $F0, $E4, $04, $0C, $F8, $E0, $00, $00, $0C, $1C, $FC, $FC, $FC, $FC, $FC, $FC
L8290:  .byte $03, $03, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00
L82A0:  .byte $FC, $F9, $01, $03, $FE, $F8, $C0, $C0, $03, $07, $FF, $FF, $FF, $FF, $3F, $3F
L82B0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L82C0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $FC, $FC, $FC, $FC, $FC, $FC, $FE, $FF
L82D0:  .byte $30, $30, $30, $30, $30, $30, $70, $F0, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F
L82E0:  .byte $03, $03, $03, $03, $03, $03, $03, $03, $C0, $C0, $C0, $C0, $C0, $E0, $E0, $F0
L82F0:  .byte $00, $00, $00, $00, $04, $04, $08, $08, $FC, $FC, $FC, $FC, $FC, $FC, $F8, $F8
L8300:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $C0, $C0, $FC, $FC, $CC, $CC, $FF, $FF
L8310:  .byte $0C, $0C, $0C, $04, $04, $00, $00, $00, $03, $03, $03, $03, $03, $03, $01, $00
L8320:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $F0, $F8, $FF, $FF, $FF, $FF, $FF, $FF
L8330:  .byte $04, $1C, $00, $00, $00, $00, $01, $0F, $03, $03, $FF, $FF, $FF, $FF, $FF, $FF
L8340:  .byte $00, $02, $04, $0C, $38, $70, $C0, $00, $FE, $FE, $FC, $FC, $F8, $F0, $C0, $00
L8350:  .byte $03, $03, $03, $03, $02, $04, $08, $30, $00, $00, $00, $00, $01, $03, $07, $0F
L8360:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $FC, $FC, $FC, $FC, $FC, $FE, $FE, $FF
L8370:  .byte $03, $03, $03, $03, $03, $03, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00
L8380:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $FC, $FC, $FC, $FE, $FF, $FF, $FF, $FF
L8390:  .byte $00, $00, $00, $10, $10, $20, $41, $87, $00, $10, $30, $70, $F0, $E0, $C0, $80
L83A0:  .byte $C0, $C0, $C0, $C0, $C0, $C0, $C0, $C0, $3F, $3F, $3F, $3F, $3F, $3F, $3F, $3F
L83B0:  .byte $03, $03, $03, $03, $03, $03, $07, $0F, $00, $00, $00, $00, $80, $80, $C0, $E0
L83C0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L83D0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L83E0:  .byte $03, $03, $03, $07, $07, $0F, $00, $00, $00, $00, $00, $00, $00, $01, $00, $00
L83F0:  .byte $10, $10, $20, $40, $80, $00, $00, $00, $F0, $F0, $E0, $C0, $80, $00, $00, $00
L8400:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $03, $03, $3F, $3F, $33, $33, $FF, $FF
L8410:  .byte $00, $00, $40, $E1, $F7, $FC, $7C, $3C, $00, $20, $30, $18, $08, $03, $02, $02
L8420:  .byte $00, $00, $F8, $FE, $FF, $7F, $3F, $1F, $00, $00, $07, $01, $00, $80, $00, $00
L8430:  .byte $00, $00, $00, $00, $00, $80, $80, $C0, $00, $00, $00, $80, $C0, $60, $60, $30
L8440:  .byte $00, $00, $1F, $0F, $0F, $0F, $0F, $0F, $00, $00, $00, $00, $00, $00, $00, $00
L8450:  .byte $00, $00, $F8, $FC, $00, $00, $00, $F8, $00, $00, $04, $02, $FE, $80, $80, $04
L8460:  .byte $00, $00, $78, $3C, $1E, $0F, $07, $03, $00, $00, $04, $02, $01, $00, $00, $00
L8470:  .byte $00, $00, $0C, $0C, $1C, $38, $F0, $E0, $00, $00, $02, $02, $02, $84, $08, $10
L8480:  .byte $00, $00, $07, $1F, $1E, $3C, $38, $38, $00, $00, $00, $00, $01, $02, $04, $04
L8490:  .byte $00, $00, $F0, $F8, $3C, $1C, $1C, $1C, $00, $00, $08, $04, $C2, $02, $02, $02
L84A0:  .byte $00, $00, $3F, $1F, $0E, $0E, $0E, $0E, $00, $00, $00, $00, $01, $01, $01, $01
L84B0:  .byte $00, $00, $F0, $FC, $3C, $1C, $1C, $1C, $00, $00, $0C, $02, $C2, $02, $02, $02
L84C0:  .byte $00, $00, $1C, $1C, $1C, $1C, $3C, $38, $00, $00, $02, $02, $02, $02, $02, $06
L84D0:  .byte $00, $00, $0E, $0E, $0E, $0E, $0E, $0E, $00, $00, $01, $01, $01, $01, $01, $01
L84E0:  .byte $00, $00, $07, $0F, $1E, $1C, $1E, $0F, $00, $00, $00, $00, $01, $02, $00, $00
L84F0:  .byte $00, $00, $F8, $FC, $1C, $00, $00, $E0, $00, $00, $04, $02, $E2, $1C, $00, $18
L8500:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $33, $33, $3F, $3F, $03, $03
L8510:  .byte $0C, $00, $0F, $30, $3F, $7F, $40, $C0, $03, $00, $00, $0F, $3F, $7F, $3F, $3E
L8520:  .byte $0F, $07, $E0, $10, $F3, $F3, $03, $03, $00, $00, $07, $F7, $F3, $FB, $38, $10
L8530:  .byte $C0, $D0, $10, $30, $E0, $80, $00, $00, $30, $30, $F0, $F0, $F8, $F8, $F8, $FC
L8540:  .byte $0F, $0E, $11, $11, $20, $40, $7F, $00, $00, $01, $0F, $0F, $1F, $3F, $7F, $00
L8550:  .byte $F8, $00, $00, $00, $04, $08, $F0, $00, $04, $F8, $00, $00, $FC, $F8, $F0, $00
L8560:  .byte $03, $06, $08, $11, $62, $44, $78, $00, $00, $01, $07, $0F, $1E, $3C, $78, $00
L8570:  .byte $C0, $08, $C4, $E2, $32, $1A, $0C, $00, $30, $F8, $3C, $DE, $2E, $16, $0C, $00
L8580:  .byte $3C, $3C, $24, $20, $21, $10, $0F, $00, $04, $04, $1C, $1C, $1E, $1F, $0F, $00
L8590:  .byte $1C, $1C, $22, $46, $84, $18, $E0, $00, $02, $02, $1E, $3E, $7C, $F8, $E0, $00
L85A0:  .byte $0C, $1C, $12, $22, $41, $40, $7F, $00, $02, $02, $0E, $1E, $3E, $3F, $7F, $00
L85B0:  .byte $1C, $1C, $22, $46, $84, $18, $E0, $00, $02, $02, $1E, $3E, $7C, $F8, $E0, $00
L85C0:  .byte $38, $38, $24, $20, $11, $08, $07, $00, $04, $04, $1C, $1C, $0E, $07, $07, $00
L85D0:  .byte $1C, $1C, $12, $66, $84, $18, $E0, $00, $02, $02, $0E, $1E, $7C, $F8, $E0, $00
L85E0:  .byte $03, $00, $1C, $20, $23, $00, $0F, $00, $04, $03, $00, $18, $1C, $1F, $0F, $00
L85F0:  .byte $F8, $3C, $32, $22, $C4, $08, $F0, $00, $04, $C2, $2E, $1E, $3C, $F8, $F0, $00
L8600:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L8610:  .byte $C0, $C0, $C0, $C0, $C0, $40, $00, $00, $3E, $3F, $3F, $3F, $3F, $3F, $3F, $0F
L8620:  .byte $04, $08, $00, $02, $02, $04, $18, $60, $03, $07, $9F, $FE, $FE, $FC, $F8, $E0
L8630:  .byte $00, $00, $00, $00, $C0, $40, $40, $00, $FC, $FC, $FE, $FE, $3F, $3F, $3F, $3F
L8640:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $C0, $E0
L8650:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $00, $00, $00
L8660:  .byte $00, $02, $02, $16, $36, $2E, $6E, $6E, $04, $0C, $0C, $54, $F4, $CC, $C4, $C4
L8670:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $00, $00, $00, $00, $00, $00
L8680:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $03, $03, $03, $03, $03, $03, $03, $03
L8690:  .byte $00, $02, $C1, $E1, $F1, $F1, $7A, $3C, $3C, $7C, $3E, $1E, $0E, $0E, $04, $00
L86A0:  .byte $58, $0C, $9E, $00, $A7, $96, $00, $E6, $00, $00, $00, $00, $00, $00, $00, $00
L86B0:  .byte $00, $00, $07, $1F, $3E, $3C, $7D, $FE, $00, $00, $0E, $3F, $7C, $7C, $78, $E2
L86C0:  .byte $00, $E0, $FC, $FF, $3F, $E3, $C4, $07, $00, $E0, $FC, $7F, $1A, $C1, $00, $00
L86D0:  .byte $00, $00, $3F, $FF, $C7, $C7, $FB, $FD, $00, $00, $3F, $73, $44, $C0, $00, $00
L86E0:  .byte $00, $00, $80, $C0, $F8, $FC, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
L86F0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L8700:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L8710:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L8720:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L8730:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00
L8740:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $F0, $38, $00, $00, $00, $00, $00, $00
L8750:  .byte $00, $00, $5E, $7F, $FE, $7F, $3F, $09, $A8, $FC, $AA, $FB, $FA, $03, $03, $01
L8760:  .byte $6E, $24, $01, $FF, $DB, $FF, $FF, $24, $C0, $00, $DB, $7E, $58, $78, $40, $24
L8770:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF
L8780:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $C0, $C0, $C0, $C0, $C0, $C0, $C0, $C0
L8790:  .byte $3C, $5E, $8F, $8F, $87, $83, $40, $00, $00, $20, $70, $70, $78, $7C, $3E, $3C
L87A0:  .byte $00, $A4, $00, $42, $00, $24, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L87B0:  .byte $27, $1B, $0D, $07, $07, $01, $01, $01, $00, $00, $00, $00, $00, $00, $00, $00
L87C0:  .byte $FF, $DD, $0C, $4E, $67, $63, $E2, $FB, $00, $00, $00, $00, $00, $00, $80, $80
L87D0:  .byte $F8, $EC, $DE, $DF, $EF, $B7, $8F, $E7, $F8, $C0, $80, $80, $80, $00, $00, $00
L87E0:  .byte $F8, $EC, $DE, $DF, $EF, $B7, $8F, $E7, $80, $00, $00, $00, $00, $00, $00, $00
L87F0:  .byte $D0, $16, $C0, $00, $D0, $03, $4C, $BD, $87, $88, $98, $0A, $0A, $0A, $0A, $18

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

;Name table 0 values for the intro image.

IntroGFXNT:
L8800:  .byte $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A
L8820:  .byte $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A
L8840:  .byte $6A, $6A, $6A, $6A, $20, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $67, $50, $6A, $6A, $6A, $6A
L8860:  .byte $7A, $7A, $7A, $7A, $78, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $69, $00, $00, $00, $00, $00, $00, $00, $00, $68, $7A, $7A, $7A, $7A
L8880:  .byte $6A, $6A, $6A, $6A, $78, $00, $00, $00, $00, $00, $00, $00, $00, $00, $65, $66, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $68, $6A, $6A, $6A, $6A
L88A0:  .byte $7A, $7A, $7A, $7A, $78, $00, $00, $00, $00, $00, $79, $00, $00, $00, $75, $76, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $68, $7A, $7A, $7A, $7A
L88C0:  .byte $6A, $6A, $6A, $6A, $78, $00, $00, $00, $00, $00, $00, $00, $00, $6B, $6C, $6D, $6E, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $68, $6A, $6A, $6A, $6A
L88E0:  .byte $7A, $7A, $7A, $7A, $78, $00, $00, $00, $00, $00, $00, $00, $00, $7D, $7C, $7E, $7E, $6E, $00, $00, $00, $00, $00, $00, $00, $00, $00, $68, $7A, $7A, $7A, $7A
L8900:  .byte $6A, $6A, $6A, $6A, $78, $00, $00, $00, $00, $00, $00, $00, $00, $7B, $6A, $6A, $6A, $6A, $6A, $00, $00, $00, $00, $00, $00, $00, $00, $68, $6A, $6A, $6A, $6A
L8920:  .byte $7A, $7A, $7A, $7A, $78, $00, $00, $00, $00, $00, $00, $00, $00, $00, $7A, $7A, $7A, $7A, $7A, $7A, $00, $00, $00, $00, $00, $00, $00, $68, $7A, $7A, $7A, $7A
L8940:  .byte $6A, $6A, $6A, $6A, $78, $00, $00, $01, $02, $03, $04, $05, $06, $00, $08, $00, $0A, $00, $00, $00, $00, $00, $00, $00, $10, $00, $00, $68, $6A, $6A, $6A, $6A
L8960:  .byte $7A, $7A, $7A, $7A, $78, $00, $00, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $00, $0C, $0D, $0E, $0F, $41, $42, $43, $00, $00, $68, $7A, $7A, $7A, $7A
L8980:  .byte $6A, $6A, $6A, $6A, $78, $00, $00, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $1B, $1C, $1D, $1E, $1F, $51, $52, $53, $00, $00, $68, $6A, $6A, $6A, $6A
L89A0:  .byte $7A, $7A, $7A, $7A, $78, $00, $00, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $2C, $2D, $2E, $2F, $61, $62, $63, $64, $00, $68, $7A, $7A, $7A, $7A
L89C0:  .byte $6A, $6A, $6A, $6A, $78, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3E, $3F, $00, $00, $73, $74, $00, $68, $6A, $6A, $6A, $6A
L89E0:  .byte $7A, $7A, $7A, $7A, $78, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $68, $7A, $7A, $7A, $7A
L8A00:  .byte $6A, $6A, $6A, $6A, $78, $00, $00, $00, $00, $00, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F, $00, $00, $00, $00, $00, $68, $6A, $6A, $6A, $6A
L8A20:  .byte $7A, $7A, $7A, $7A, $78, $00, $00, $00, $00, $00, $54, $55, $56, $57, $58, $59, $5A, $5B, $5C, $5D, $5E, $5F, $00, $00, $00, $00, $00, $68, $7A, $7A, $7A, $7A
L8A40:  .byte $6A, $6A, $6A, $6A, $78, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $68, $6A, $6A, $6A, $6A
L8A60:  .byte $7A, $7A, $7A, $7A, $30, $77, $77, $77, $77, $77, $77, $77, $77, $77, $77, $77, $77, $77, $77, $77, $77, $77, $77, $77, $77, $77, $77, $40, $7A, $7A, $7A, $7A
L8A80:  .byte $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A
L8AA0:  .byte $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A
L8AC0:  .byte $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A
L8AE0:  .byte $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A
L8B00:  .byte $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A
L8B20:  .byte $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A
L8B40:  .byte $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A
L8B60:  .byte $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A
L8B80:  .byte $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A, $6A
L8BA0:  .byte $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A, $7A
L8BC0:  .byte $55, $05, $05, $05, $05, $05, $05, $55, $55, $00, $00, $54, $10, $00, $00, $55, $55, $80, $A0, $A4, $A5, $A0, $20, $55, $55, $08, $0A, $0A, $0A, $2A, $22, $55
L8BE0:  .byte $55, $00, $0C, $0F, $0F, $03, $00, $55, $05, $05, $05, $05, $05, $05, $05, $05, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

;This section of code is a copy of the code at $B800. It does not appear to be accessed in the game.

_ShowIntroText:
L8C00:  LDA #MUS_NONE+INIT     ;Prepare to silence music.
L8C02:  STA InitNewMusic       ;
L8C04:  JSR ResetNameTable2    ;($8D47)Reset nametable offsets and select nametable 0.

L8C07:  LDX #$00               ;Prep palette data load.
L8C09:  JSR _getPalPointers    ;($8D2B)Load sprite and background palette pointers.

L8C0C:  JSR _IntroInitPPU1     ;($8E05)Initialize the PPU.

L8C0F:  LDA #$10                ;Wait for 16 frames.
L8C11:  JSR _WaitForAFrames     ;($8D23)Wait a certain number of frames before continuing.

L8C14:  LDA #<_IntroTextData    ;
L8C16:  STA GenPtr2BLB          ;Set a pointer to the intro text data.
L8C18:  LDA #>_IntroTextData    ;
L8C1A:  STA GenPtr2BUB          ;

_IntroTextLoop:
L8C1C:  LDA #$1E                ;Keep screen blank for 30 frames.
L8C1E:  JSR _WaitForAFrames     ;($8D23)Wait a certain number of frames before continuing.

L8C21:  LDA TXTSrcPtrLB         ;
L8C23:  PHA                     ;Save pointer on stack before clearing out the PPU again.
L8C24:  LDA TXTSrcPtrUB         ;
L8C26:  PHA                     ;

L8C27:  JSR _IntroInitPPU1      ;($8E05)Initialize the PPU.

L8C2A:  PLA                     ;
L8C2B:  STA TXTSrcPtrUB         ;Restore pointer from the stack.
L8C2D:  PLA                     ;
L8C2E:  STA TXTSrcPtrLB         ;

_GetIntroTextString:
L8C30:  LDY #$00                ;
L8C32:  LDA (TXTSrcPtr),Y       ;Get screen X position of text to display.
L8C34:  STA TXTXPos             ;
L8C36:  INY                     ;

L8C37:  LDA (TXTSrcPtr),Y       ;
L8C39:  STA TXTYPos             ;Get screen Y position of text to display.
L8C3B:  INY                     ;

L8C3C:  LDX #$00                ;Prepare to write to the text buffer.

L8C3E:* LDA (TXTSrcPtr),Y       ;
L8C40:  STA TextBuffer,X        ;
L8C43:  INY                     ;
L8C44:  INX                     ;Copy text into the buffer until the end marker is reached.
L8C45:  CMP #TXT_END            ;
L8C47:  BEQ +                   ;
L8C49:  JMP -                   ;

L8C4C:* LDA #$01                ;
L8C4E:  STA TXTClrRows          ;Clear a single row for the text string.
L8C50:  TXA                     ;
L8C51:  STA TXTClrCols          ;Clear a number of cols that match the length of the text string.

L8C53:  TYA                     ;
L8C54:  CLC                     ;
L8C55:  ADC TXTSrcPtrLB         ;
L8C57:  STA TXTSrcPtrLB         ;Update the text pointer to point to the next block of intro text.
L8C59:  LDA TXTSrcPtrUB         ;
L8C5B:  ADC #$00                ;
L8C5D:  STA TXTSrcPtrUB         ;

L8C5F:  LDA TXTYPos             ;Is Y=31? This represents the end of the text
L8C61:  CMP #$1E                ;string for the current display.
L8C63:  BCS _GotTextStrings     ;If so, branch to start fading in.

L8C65:  LDA TXTSrcPtrLB         ;
L8C67:  PHA                     ;Save pointer to stack before prepping to show text.
L8C68:  LDA TXTSrcPtrUB         ;
L8C6A:  PHA                     ;

L8C6B:  LDA #TXT_DBL_SPACE      ;Indicate buffer already filled. Double space contents.
L8C6D:  STA TextIndex           ;
L8C6F:  JSR DisplayText1        ;($C003)Display text on the screen.

L8C72:  PLA                     ;
L8C73:  STA TXTSrcPtrUB         ;Restore pointer from stack after done loading text.
L8C75:  PLA                     ;
L8C76:  STA TXTSrcPtrLB         ;

L8C78:  JMP _GetIntroTextString ;($8C30)Get the next intro text string.

_GotTextStrings:
L8C7B:  PHA                     ;Save A on the stack.

L8C7C:  LDX #$00                ;Start at the beginning of the palette pointer table.
L8C7E:* JSR _getPalPointers     ;($8D2B)Load sprite and background palette pointers.

L8C81:  LDA #$01                ;Wait for 1 frame.
L8C83:  JSR _WaitForAFrames     ;($8D23)Wait a certain number of frames before continuing.

L8C86:  CPX #$0A                ;Is the text done fading in?
L8C88:  BNE -                   ;If not, branch back to keep fading in.

L8C8A:  LDA #$5A                ;Display text for 90 frames.
L8C8C:  JSR _WaitForAFrames     ;($8D23)Wait a certain number of frames before continuing.

L8C8F:* JSR _getPalPointers     ;($8D2B)Load sprite and background palette pointers.

L8C92:  LDA #$02                ;Wait for 2 frames.
L8C94:  JSR _WaitForAFrames     ;($8D23)Wait a certain number of frames before continuing.

L8C97:  CPX #$12                ;Is the text done fading out?
L8C99:  BNE -                   ;If not, branch back to keep fading out.

L8C9B:  PLA                     ;Did we finish getting all the text string to display?
L8C9C:  CMP #$1E                ;If not, branch to get more strings.
L8C9E:  BNE +                   ;
L8CA0:  JMP _IntroTextLoop      ;($B81C)Show the intro text.

L8CA3:* LDA #>IntroGFXTiles     ;
L8CA5:  STA PPUSrcPtrUB         ;Get a pointer to the intro GFX tiles.
L8CA7:  LDA #<IntroGFXTiles     ;
L8CA9:  STA PPUSrcPtrLB         ;

L8CAB:  STA PPUDstPtrLB         ;Pattern table 1, lower address byte.
L8CAD:  STA PPUByteCntLB        ;Byte count to load, lower byte.

L8CAF:  LDA #PPU_PT1_UB         ;Pattern table 1, upper address byte.
L8CB1:  STA PPUDstPtrUB         ;

L8CB3:  LDA #$08                ;Prepare to load the first half of pattern table 1 with intro GFX.
L8CB5:  STA PPUByteCntUB        ;

L8CB7:  JSR LoadPPU1            ;($C006)Load values into the PPU.

L8CBA:  LDA #>IntroGFXNT        ;Pointer to intro GFX for name table 0 load.
L8CBC:  STA PPUSrcPtrUB         ;

L8CBE:  LDA #PPU_NT0_UB         ;PPU address to name table 0.
L8CC0:  STA PPUDstPtrUB         ;

L8CC2:  LDA #$04                ;Prepare to load 1K of data into PPU(fill NT0).
L8CC4:  STA PPUByteCntUB        ;
L8CC6:  JSR LoadPPU1            ;($C006)Load values into the PPU.

L8CC9:  LDA #$0A                ;Wait for 10 frames.
L8CCB:  JSR _WaitForAFrames     ;($8D23)Wait a certain number of frames before continuing.

L8CCE:  LDX #$12                ;Load first GFX fade-in palette.
L8CD0:  JSR _getPalPointers     ;($8D2B)Load sprite and background palette pointers.

L8CD3:  LDA #$04                ;Wait for 4 frames.
L8CD5:  JSR _WaitForAFrames     ;($8D23)Wait a certain number of frames before continuing.

L8CD8:  LDX #$14                ;Load second GFX fade-in palette.
L8CDA:  JSR _getPalPointers     ;($8D2B)Load sprite and background palette pointers.

L8CDD:  LDA #$04                ;Wait for 4 frames.
L8CDF:  JSR _WaitForAFrames     ;($8D23)Wait a certain number of frames before continuing.

L8CE2:  LDX #$16                ;Load third GFX fade-in palette.
L8CE4:  JSR _getPalPointers     ;($8D2B)Load sprite and background palette pointers.

L8CE7:  LDA #$04                ;Wait for 4 frames.
L8CE9:  JSR _WaitForAFrames     ;($8D23)Wait a certain number of frames before continuing.

L8CEC:  LDX #$18                ;Load fourth GFX fade-in palette.
L8CEE:  JSR _getPalPointers     ;($8D2B)Load sprite and background palette pointers.

L8CF1:  LDA #$1E                ;Wait for 30 frames.
L8CF3:  JSR _WaitForAFrames     ;($8D23)Wait a certain number of frames before continuing.

L8CF6:  LDA #MUS_DUNGEON+INIT   ;Start the dungeon music.
L8CF8:  STA InitNewMusic        ;

L8CFA:  LDX #$00                ;
L8CFC:* LDA _PushStartText,X    ;
L8CFF:  STA TextBuffer,X        ;Copy all 16 bytes of the PUSH START text into the buffer.
L8D02:  INX                     ;
L8D03:  CPX #$11                ;
L8D05:  BNE -                   ;

L8D07:  LDA #$0A                ;
L8D09:  STA TXTXPos             ;Set X,Y position of text to 10,24.
L8D0B:  LDA #$18                ;
L8D0D:  STA TXTYPos             ;

L8D0F:  LDA #$0C                ;
L8D11:  STA TXTClrCols          ;Clear 3 rows and 12 columns while showing text.
L8D13:  LDA #$03                ;
L8D15:  STA TXTClrRows          ;

L8D17:  LDA #TXT_SNGL_SPACE     ;Indicate buffer already filled. Single space contents.
L8D19:  STA TextIndex           ;
L8D1B:  JSR DisplayText1        ;($C003)Display text on the screen.

L8D1E:  LDA #SCREEN_ON          ;
L8D20:  STA CurPPUConfig1       ;Turn the screen on.
L8D22:  RTS                     ;

;----------------------------------------------------------------------------------------------------

_WaitForAFrames:
L8D23:  CLC                     ;
L8D24:  ADC Increment0          ;Add the frame increment to A.
L8D26:* CMP Increment0          ;
L8D28:  BNE -                   ;Wait a number of frames equal to A before continuing.
L8D2A:  RTS                     ;

;----------------------------------------------------------------------------------------------------

_getPalPointers:
L8D2B:  LDA _IntroBkPalPtrTbl,X ;
L8D2E:  STA GenPtr29LB          ;
L8D30:  INX                     ;Get pointer to background palette data.
L8D31:  LDA _IntroBkPalPtrTbl,X ;
L8D34:  STA GenPtr29UB          ;
L8D36:  INX                     ;

L8D37:  LDA #<_IntroSprPalData  ;
L8D39:  STA GenPtr2DLB          ;Get pointer to sprite palette data.
L8D3B:  LDA #>_IntroSprPalData  ;
L8D3D:  STA GenPtr2DUB          ;

L8D3F:  TXA                     ;Save X on the stack.
L8D40:  PHA                     ;

L8D41:  JSR _GetPalData         ;($8D60)Write palette data to PPU buffer.

L8D44:  PLA                     ;
L8D45:  TAX                     ;Restore X from the stack.
L8D46:  RTS                     ;

;----------------------------------------------------------------------------------------------------

ResetNameTable2:
L8D47:  LDA #$00                ;
L8D49:  STA NTXPosLB            ;
L8D4B:  STA NTXPosUB            ;
L8D4D:  STA NTYPosLB            ;
L8D4F:  STA NTYPosUB            ;
L8D51:  STA NTXPosLB16          ;Reset all nametable offset values and select nametable 0;
L8D53:  STA NTXPosUB16          ;
L8D55:  STA NTYPosLB16          ;
L8D57:  STA NTYPosUB16          ;
L8D59:  LDA CurPPUConfig0       ;
L8D5B:  AND #$FC                ;
L8D5D:  STA CurPPUConfig0       ;
L8D5F:  RTS                     ;

;----------------------------------------------------------------------------------------------------

_GetPalData:
L8D60:  LDY #$00                ;
L8D62:  LDX #$00                ;
L8D64:* LDA (GenPtr29),Y        ;
L8D66:  STA PaletteBuffer,X     ;Load 16 bytes of palette data into buffer.
L8D69:  INY                     ;
L8D6A:  INX                     ;
L8D6B:  CPY #$10                ;
L8D6D:  BNE -                   ;

L8D6F:  LDY #$00                ;
L8D71:* LDA (GenPtr2D),Y        ;
L8D73:  STA PaletteBuffer,X     ;
L8D76:  INY                     ;Load another 16 bytes of palette data into buffer.
L8D77:  INX                     ;
L8D78:  CPY #$10                ;
L8D7A:  BNE -                   ;

L8D7C:  LDA #$20                ;Buffer has 32 bytes of palette data in it.
L8D7E:  JSR _SetPPUBufNewSize   ;($B9C0)Wait for PPU buffer to be able to accomodate new data.

L8D81:  LDA #PPU_PAL_UB         ;
L8D83:  STA PPUBufBase,X        ;
L8D86:  INX                     ;PPU target address is $3F00(palettes).
L8D87:  LDA #PPU_PAL_LB         ;
L8D89:  STA PPUBufBase,X        ;

L8D8C:  LDY #$00                ;
L8D8E:* LDA (GenPtr29),Y        ;
L8D90:  INX                     ;
L8D91:  STA PPUBufBase,X        ;Copy 16 bytes of background palette data into PPU buffer.
L8D94:  INY                     ;
L8D95:  CPY #$10                ;
L8D97:  BNE -                   ;

L8D99:  LDY #$00                ;
L8D9B:* LDA (GenPtr2D),Y        ;
L8D9D:  INX                     ;
L8D9E:  STA PPUBufBase,X        ;Copy 16 bytes of sprite palette data into PPU buffer.
L8DA1:  INY                     ;
L8DA2:  CPY #$10                ;
L8DA4:  BNE -                   ;

L8DA6:  LDA #$01                ;Prepare to write a single byte to the PPU.
L8DA8:  JSR _SetPPUBufNewSize   ;($B9C0)Wait for PPU buffer to be able to accomodate new data.

L8DAB:  LDA #PPU_PT0_UB         ;
L8DAD:  STA PPUBufBase,X        ;
L8DB0:  INX                     ;PPU target address is $0000(pattern tables).
L8DB1:  LDA #PPU_PT0_LB         ;
L8DB3:  STA PPUBufBase,X        ;
L8DB6:  INX                     ;

L8DB7:  LDA #$00                ;Write a single blank byte to the PPU buffer.
L8DB9:  STA PPUBufBase,X        ;

L8DBC:  JSR _SetPPUUpdate       ;($B9FB)Check if PPU update flag needs to be set.
L8DBF:  RTS                     ;

;----------------------------------------------------------------------------------------------------

_SetPPUBufNewSize:
L8DC0:  PHA                     ;Save A on the stack.
L8DC1:  CLC                     ;
L8DC2:  ADC PPUBufLength        ;Update the buffer length by adding A to it.
L8DC5:  BCS WaitForPPUUpdate2   ;Branch if buffer length has exceeded 256 bytes.

L8DC7:  TAX                     ;
L8DC8:  LDA DisSpriteAnim       ;Are animations and NPC movements disabled?
L8DCA:  ORA DisNPCMovement      ;If so, branch. Buffer might be big.
L8DCC:  BEQ _ChkBufLen20        ;

L8DCE:  TXA                     ;Is the PPU buffer currently over 96 bytes in length?
L8DCF:  CMP #$60                ;If so, wait for the buffer to be emptied.
L8DD1:  BCC UpdatePPUBufLen2    ;

L8DD3:  JMP WaitForPPUUpdate2   ;($8DDB)Wait for the next PPU update to complete.

_ChkBufLen20:
L8DD6:  TXA                     ;Is the buffer under 32 bytes of data?
L8DD7:  CMP #$20                ;If so, branch to update buffer length.
L8DD9:  BCC UpdatePPUBufLen2    ;

WaitForPPUUpdate2:
L8DDB:  LDA #$01                ;Indicate the PPU has waiting data.
L8DDD:  STA UpdatePPU           ;
L8DDF:* LDA UpdatePPU           ;Has the PPU been updated with the new data?
L8DE1:  BNE -                   ;If not, branch to wait.

UpdatePPUBufLen2:
L8DE3:  LDA #$00                ;Clear PPU update flag.
L8DE5:  STA UpdatePPU           ;

L8DE7:  LDX PPUBufLength        ;Set the index to the next available spot in the PPU buffer.
L8DEA:  INX                     ;

L8DEB:  CLC                     ;
L8DEC:  PLA                     ;
L8DED:  ADC #$02                ;Set the PPU string length. Add 2 for the PPU destination address.
L8DEF:  STA PPUBufBase,X        ;
L8DF2:  INX                     ;

L8DF3:  SEC                     ;
L8DF4:  ADC PPUBufLength        ;Add thei PPU string length to the total PPU buffer length.
L8DF7:  STA PPUBufLength        ;
L8DFA:  RTS                     ;

;----------------------------------------------------------------------------------------------------

_SetPPUUpdate:
L8DFB:  LDA PPUBufLength        ;
L8DFE:  BEQ +                   ;Is there data in the PPU buffer?
L8E00:  LDA #$01                ;If so, set the flag indicating the PPU needs to be updated.
L8E02:  STA UpdatePPU           ;
L8E04:* RTS                     ;

;----------------------------------------------------------------------------------------------------

_IntroInitPPU1:
L8E05:  LDA #SCREEN_OFF         ;Turn off the screen.
L8E07:  STA CurPPUConfig1       ;

L8E09:  LDA #$D4                ;Prepare to hide sprites 53 through 63.
L8E0B:  STA HideUprSprites      ;

L8E0D:  LDY #$00                ;Prepare to initialize all sprites.
L8E0F:  LDA #$F0                ;

L8E11:* STA SpriteBuffer,Y      ;
L8E14:  INY                     ;
L8E15:  INY                     ;Initialize all sprites in the buffer.
L8E16:  INY                     ;
L8E17:  INY                     ;
L8E18:  BNE -                   ;

L8E1A:  LDY #$00                ;Prepare to zero out the GFX blocks buffer.
L8E1C:  LDA #$00                ;

L8E1E:* STA BlocksBuffer,Y      ;
L8E21:  INY                     ;Zero out the GFX blocks buffer.
L8E22:  BNE -                   ;

L8E24:  LDA #>BlocksBuffer      ;
L8E26:  STA GenPtr29UB          ;Set pointer to the source of PPU data.
L8E28:  LDA #<BlocksBuffer      ;
L8E2A:  STA GenPtr29LB          ;

L8E2C:  LDA #PPU_NT0_UB         ;
L8E2E:  STA GenPtr2BUB          ;Set pointer to name table 0 PPU destination.
L8E30:  LDA #PPU_NT0_LB         ;
L8E32:  STA GenPtr2BLB          ;

L8E34:  LDA #$01                ;
L8E36:  STA GenWord2DUB         ;Prepare to load 256 bytes of data into the PPU.
L8E38:  LDA #$00                ;
L8E3A:  STA GenWord2DLB         ;

L8E3C:* JSR LoadPPU1            ;($C006)Load values into the PPU.

L8E3F:  INC GenPtr2BUB          ;
L8E41:  LDA GenPtr2BUB          ;Has all the data been loaded into the PPU?
L8E43:  CMP #PPU_NT1_UB         ;If not, branch to load some more.
L8E45:  BNE -                   ;

L8E47:  LDY #$00                ;Prepare to fill attribute table 0 with $55.
L8E49:  LDA #$55                ;

L8E4B:* STA BlocksBuffer,Y      ;
L8E4E:  INY                     ;Load 64 bytes into the blocks buffer.
L8E4F:  CPY #$40                ;
L8E51:  BNE -                   ;

L8E53:  LDA #>BlocksBuffer      ;
L8E55:  STA GenPtr29UB          ;Set pointer to the source of PPU data.
L8E57:  LDA #<BlocksBuffer      ;
L8E59:  STA GenPtr29LB          ;

L8E5B:  LDA #PPU_AT0_UB         ;
L8E5D:  STA GenPtr2BUB          ;Set pointer to attribute table 0 PPU destination.
L8E5F:  LDA #PPU_AT0_LB         ;
L8E61:  STA GenPtr2BLB          ;

L8E63:  LDA #$00                ;
L8E65:  STA GenWord2DUB         ;Prepare to load 64 bytes of data into the PPU.
L8E67:  LDA #$40                ;
L8E69:  STA GenWord2DLB         ;

L8E6B:  JSR LoadPPU1            ;($C006)Load values into the PPU.

L8E6E:  LDA #SCREEN_ON          ;
L8E70:  STA CurPPUConfig1       ;Turn on the display.
L8E72:  RTS                     ;

;----------------------------------------------------------------------------------------------------

_IntroBkPalPtrTbl:
L8E73:  .word _IntroTxtPal1, _IntroTxtPal2, _IntroTxtPal3, _IntroTxtPal4
L8E7B:  .word _IntroTxtPal5, _IntroTxtPal4, _IntroTxtPal3, _IntroTxtPal2
L8E83:  .word _IntroTxtPal1, _IntroGFXPal1, _IntroGFXPal2, _IntroGFXPal3
L8E8B:  .word _IntroGFXPal4

;----------------------------------------------------------------------------------------------------

;The following palettes fade the intro text in and out on the screen.

_IntroTxtPal1:
L8E8D:  .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

_IntroTxtPal2:
L8E9D:  .byte $0F, $00, $0F, $0F, $0F, $00, $0F, $0F, $0F, $00, $0F, $0F, $0F, $00, $0F, $0F

_IntroTxtPal3:
L8EAD:  .byte $0F, $14, $0F, $0F, $0F, $14, $0F, $0F, $0F, $14, $0F, $0F, $0F, $14, $0F, $0F

_IntroTxtPal4:
L8EBD:  .byte $0F, $22, $0F, $0F, $0F, $22, $0F, $0F, $0F, $22, $0F, $0F, $0F, $22, $0F, $0F

_IntroTxtPal5:
L8ECD:  .byte $0F, $30, $0F, $0F, $0F, $30, $0F, $0F, $0F, $30, $0F, $0F, $0F, $30, $0F, $0F

;----------------------------------------------------------------------------------------------------

;The following palettes fade the intro graphics in and out on the screen.

_IntroGFXPal1:
L8EDD:  .byte $2F, $01, $01, $0C, $2F, $01, $01, $01, $2F, $01, $03, $01, $2F, $02, $05, $00

_IntroGFXPal2:
L8EED:  .byte $2F, $01, $11, $1C, $2F, $01, $11, $01, $2F, $11, $03, $01, $2F, $12, $05, $00

_IntroGFXPal3:
L8EFD:  .byte $2F, $01, $21, $1C, $2F, $01, $11, $11, $2F, $11, $13, $01, $2F, $12, $15, $00

_IntroGFXPal4:
L8F0D:  .byte $2F, $01, $31, $2C, $2F, $01, $21, $11, $2F, $21, $13, $01, $2F, $22, $15, $00

;----------------------------------------------------------------------------------------------------

_IntroSprPalData:
L8F1D:  .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

;----------------------------------------------------------------------------------------------------

_IntroTextData:
L8F2D:  .byte $08, $0C ;X=8, Y=12.
;              O    R    I    G    I    N    A    L    _    V    E    R    S    I    O    N
L8F2F:  .byte $98, $9B, $92, $90, $92, $97, $8A, $95, $00, $9F, $8E, $9B, $9C, $92, $98, $97
;             END
L8F3F:  .byte $FF

L8F40:  .byte $05, $10 ;X=5, Y=16.
;             CPY   _    O    R    I    G    I    N    _    S    Y    S    T    E    M    S
L8F42:  .byte $88, $00, $98, $9B, $92, $90, $92, $97, $00, $9C, $A2, $9C, $9D, $8E, $96, $9C
;              _    I    N    C    .   END
L8F52:  .byte $00, $92, $97, $8C, $86, $FF

L8F58:  .byte $00, $1E, $FF ;X=0, Y=30.

L8F5B:  .byte $07, $0C ;X=7, Y=12.
;              F    A    M    I    C    O    M    _    _    V    E    R    S    I    O    N
L8F5D:  .byte $8F, $8A, $96, $92, $8C, $98, $96, $00, $00, $9F, $8E, $9B, $9C, $92, $98, $97
;             END
L8F6D:  .byte $FF

L8F6E:  .byte $06, $10 ;X=6, Y=16.
;             CPY   _    P    O    N    Y    _    C    A    N    Y    O    N    _    I    N
L8F70:  .byte $88, $00, $99, $98, $97, $A2, $00, $8C, $8A, $97, $A2, $98, $97, $00, $92, $97
;              C    .   END
L8F80:  .byte $8C, $86, $FF

L8F83:  .byte $00, $1E, $FF ;X=0, Y=30.

L8F86:  .byte $0B, $0C ;X=11, Y=12.
;              P    R    O    D    U    C    E    D   END
L8F88:  .byte $99, $9B, $98, $8D, $9E, $8C, $8E, $8D, $FF

L8F91:  .byte $0E, $0E ;X=14, Y=14.
;              B    Y    _   END
L8F93:  .byte $8B, $A2, $00, $FF

L8F97:  .byte $07, $10 ;X=7, Y=16.
;              N    E    W    T    O    P    I    A    _    P    L    A    N    N    I    N
L8F99:  .byte $97, $8E, $A0, $9D, $98, $99, $92, $8A, $00, $99, $95, $8A, $97, $97, $92, $97
;              G   END
L8FA9:  .byte $90, $FF

L8FAB:  .byte $00, $1F, $FF ;X=0, Y=31.

;----------------------------------------------------------------------------------------------------

_PushStartText:
;              \n   _    P    U    S    H    _    S    T    A    R    T    _    \n   _   END
L8FAE:  .byte $FD, $00, $99, $9E, $9C, $91, $00, $9C, $9D, $8A, $9B, $9D, $00, $FD, $00, $FF

;----------------------------------------------------------------------------------------------------

;Unused.
L8FBE:  .byte $8F, $A0, $07, $91, $99, $E8, $BD, $E4, $8F, $A0, $08, $91, $99, $E8, $BD, $E4
L8FCE:  .byte $8F, $A0, $09, $91, $99, $E8, $BD, $E4, $8F, $A0, $0A, $91, $99, $E6, $30, $A5
L8FDE:  .byte $30, $C9, $04, $D0, $B5, $60, $00, $02, $19, $0F, $05, $05, $00, $00, $01, $02
L8FEE:  .byte $05, $0F, $05, $19, $00, $00, $02, $04, $05, $0F, $19, $05, $00, $00, $03, $02
L8FFE:  .byte $0F, $19

;----------------------------------------------------------------------------------------------------

;Unused map data from Bank 6.
L9000:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB
L9010:  .byte $BC, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L9020:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB
L9030:  .byte $BC, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L9040:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB
L9050:  .byte $BC, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L9060:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB
L9070:  .byte $BC, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L9080:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB
L9090:  .byte $BC, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L90A0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB
L90B0:  .byte $BC, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L90C0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB
L90D0:  .byte $BC, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L90E0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB
L90F0:  .byte $BC, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L9100:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB
L9110:  .byte $BC, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L9120:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB
L9130:  .byte $BC, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L9140:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB
L9150:  .byte $BC, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L9160:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $C8, $88, $88, $88, $88, $8B
L9170:  .byte $B8, $88, $88, $88, $88, $88, $CB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L9180:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB
L9190:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L91A0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB
L91B0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L91C0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB, $BC, $88, $88, $88, $88
L91D0:  .byte $88, $88, $88, $88, $8C, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L91E0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB, $BC, $BB, $BB, $BB, $BB
L91F0:  .byte $BB, $BB, $BB, $BB, $BC, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L9200:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB, $B8, $BB, $BB, $BB, $99
L9210:  .byte $99, $BB, $BB, $BB, $B8, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L9220:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $9B
L9230:  .byte $B9, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L9240:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $88, $88, $88, $88, $88, $88
L9250:  .byte $88, $88, $88, $88, $88, $88, $8B, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L9260:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L9270:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L9280:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L9290:  .byte $BB, $BB, $BB, $BB, $BB, $C8, $88, $88, $88, $88, $88, $88, $88, $88, $88, $88
L92A0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L92B0:  .byte $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L92C0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L92D0:  .byte $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L92E0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L92F0:  .byte $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $C8, $88, $88, $88, $CB, $BB, $BB
L9300:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L9310:  .byte $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $CB, $BB, $BB
L9320:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L9330:  .byte $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $C9, $99, $99, $99, $CB, $BB, $BB
L9340:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L9350:  .byte $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $CB, $BB, $BB
L9360:  .byte $88, $88, $88, $88, $88, $88, $88, $88, $88, $88, $88, $88, $88, $CB, $BB, $BB
L9370:  .byte $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $CB, $BB, $BB
L9380:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB
L9390:  .byte $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $CB, $BB, $BB
L93A0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB
L93B0:  .byte $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $CB, $BB, $BB
L93C0:  .byte $BB, $B9, $99, $BB, $BB, $99, $9B, $BB, $B9, $99, $BB, $B9, $99, $CB, $BB, $BB
L93D0:  .byte $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $CB, $BB, $BB
L93E0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $B9, $BB, $CB, $BB, $BB
L93F0:  .byte $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $CB, $BB, $BB
L9400:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $B9, $BB, $CB, $BB, $BB
L9410:  .byte $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $CB, $BB, $BB
L9420:  .byte $BB, $B9, $99, $BB, $BB, $99, $9B, $BB, $B9, $99, $BB, $B9, $99, $CB, $BB, $BB
L9430:  .byte $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $CB, $BB, $BB
L9440:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB
L9450:  .byte $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $CB, $BB, $BB
L9460:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB
L9470:  .byte $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $CB, $BB, $BB
L9480:  .byte $88, $88, $88, $88, $88, $88, $88, $88, $88, $88, $88, $88, $88, $8B, $BB, $BB
L9490:  .byte $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $CB, $BB, $BB
L94A0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L94B0:  .byte $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $8B, $BB, $BB, $BB, $CB, $BB, $BB
L94C0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L94D0:  .byte $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB
L94E0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $C8, $88, $88, $88
L94F0:  .byte $88, $88, $88, $8C, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB
L9500:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB
L9510:  .byte $BB, $BB, $BB, $BC, $BB, $88, $88, $88, $88, $88, $88, $88, $88, $88, $88, $88
L9520:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $99
L9530:  .byte $99, $BB, $BB, $BC, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L9540:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB
L9550:  .byte $BB, $BB, $BB, $BC, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L9560:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB, $B8, $88, $88
L9570:  .byte $88, $88, $8B, $BC, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L9580:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB
L9590:  .byte $BB, $BB, $BB, $BC, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L95A0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB
L95B0:  .byte $BB, $BB, $BB, $BC, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L95C0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB
L95D0:  .byte $BB, $BB, $BB, $BC, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L95E0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BC, $88, $88, $88, $88, $88, $8B, $BB, $BB, $BB
L95F0:  .byte $BB, $BB, $BB, $B8, $88, $88, $88, $88, $88, $CB, $BB, $BB, $BB, $BB, $BB, $BB
L9600:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BC, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L9610:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $BB
L9620:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BC, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L9630:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $BB
L9640:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BC, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L9650:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $BB
L9660:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BC, $BB, $BB, $BB, $BB, $BB, $BC, $88, $88, $88
L9670:  .byte $88, $88, $88, $CB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $BB
L9680:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BC, $BB, $BB, $BB, $BB, $BB, $BC, $BB, $BB, $BB
L9690:  .byte $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $BB
L96A0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BC, $BB, $BB, $BB, $BB, $BB, $BC, $BB, $BB, $BB
L96B0:  .byte $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $BB
L96C0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BC, $BB, $BB, $BB, $BB, $BB, $BC, $BB, $BB, $99
L96D0:  .byte $99, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $BB
L96E0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BC, $BB, $BB, $BB, $BB, $BB, $BC, $BB, $BB, $9B
L96F0:  .byte $B9, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $BB
L9700:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BC, $BB, $BB, $BB, $BB, $BB, $BC, $BB, $BB, $99
L9710:  .byte $99, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $BB
L9720:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BC, $BB, $BB, $BB, $BB, $BB, $BC, $BB, $BB, $BB
L9730:  .byte $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $BB
L9740:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BC, $BB, $BB, $BB, $BB, $BB, $BC, $BB, $BB, $BB
L9750:  .byte $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $BB
L9760:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BC, $BB, $BB, $BB, $BB, $BB, $B8, $BB, $BB, $BB
L9770:  .byte $BB, $BB, $BB, $8B, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $BB
L9780:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BC, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L9790:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $BB
L97A0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BC, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L97B0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $BB
L97C0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BC, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L97D0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $CB, $BB, $BB, $BB, $BB, $BB, $BB
L97E0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $B8, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB
L97F0:  .byte $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $BB, $8B, $BB, $BB, $BB, $BB, $BB, $BB

;----------------------------------------------------------------------------------------------------

;Unused NPC data from Bank 6.
L9800:  .byte $81, $FB, $1F, $11, $81, $FB, $18, $1F, $81, $FB, $36, $18, $81, $FB, $1F, $28

;----------------------------------------------------------------------------------------------------

;Unused.
L9810:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
L9820:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
L9830:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
L9840:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
L9850:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
L9860:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
L9870:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
L9880:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
L9890:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
L98A0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

;----------------------------------------------------------------------------------------------------

;Unused.
L98B0:  .byte $08, $00, $00, $0C, $32, $08, $07, $FB, $32, $03, $00, $00, $1F, $0C, $FB, $32
L98C0:  .byte $FD, $09, $23, $19, $0F, $FB, $08, $00, $0C, $31, $0F, $FB, $08, $00, $00, $00
L98D0:  .byte $00, $1F, $0F, $FB, $08, $FD, $00, $00, $00, $00, $00, $00, $19, $03, $28, $32
L98E0:  .byte $08, $FD, $00, $00, $00, $39, $3D, $00, $12, $26, $0B, $00, $00, $00, $00, $00
L98F0:  .byte $38, $3D, $FD, $00, $00, $00, $3A, $3D, $00, $07, $26, $03, $0B, $00, $00, $00

;----------------------------------------------------------------------------------------------------

ShowEndCredits:
L9900:  JSR ResetNameTableE3    ;($9994)Reset nametable offsets and select nametable 0.
L9903:  JSR ClrPPUData          ;($99AD)Clear PPU data buffers.

L9906:  LDA Increment0          ;
L9908:  CLC                     ;Prepare to wait 64 frames.
L9909:  ADC #$40                ;

L990B:* CMP Increment0          ;Has 64 frames elapsed?
L990D:  BNE -                   ;If not, branch to wait more frames.

L990F:  LDA #<CreditsData       ;
L9911:  STA EndCreditPtrLB      ;Get a pointer to the end credits data.
L9913:  LDA #>CreditsData       ;
L9915:  STA EndCreditPtrUB      ;

L9917:  LDA #$00                ;No effect.
L9919:  STA NotUsedA6           ;

EndTextLoop:
L991B:  LDY #$00                ;
L991D:* LDA #$00                ;
L991F:  STA TextBuffer,Y        ;Clear out the text buffer.
L9922:  INY                     ;
L9923:  CPY #$1F                ;
L9925:  BNE -                   ;

L9927:  LDA #TXT_END            ;Set empty text string length at 32 bytes.
L9929:  STA TextBuffer,Y        ;

L992C:  LDA #$01                ;
L992E:  STA TXTClrRows          ;Clear 1 row and 32 columns for the text.
L9930:  LDA #$20                ;
L9932:  STA TXTClrCols          ;

L9934:  LDA #$01                ;
L9936:  STA TXTYPos             ;text position X,Y = 0,1.
L9938:  LDA #$00                ;This clears out text at top of the screen.
L993A:  STA TXTXPos             ;

L993C:  LDA #TXT_DBL_SPACE      ;Text is double spaced.
L993E:  STA TextIndex           ;
L9940:  JSR DisplayText1        ;($C003)Display text on the screen(empty string).

L9943:  LDA EndCreditPtrLB      ;
L9945:  STA PPUSrcPtrLB         ;Copy end credits pointer to text source pointer.
L9947:  LDA EndCreditPtrUB      ;
L9949:  STA PPUSrcPtrUB         ;

L994B:  LDY #$00                ;
L994D:  LDA (PPUSrcPtr),Y       ;Get the X offset for this string in the current line.
L994F:  TAX                     ;
L9950:  INY                     ;

EndTxtLineLoop:
L9951:  LDA (PPUSrcPtr),Y       ;Have we reached a new line character?
L9953:  CMP #TXT_NEWLINE        ;If so, the end of the credits has been reached. Branch to spinlock.
L9955:  BEQ Spinlock            ;

L9957:  STA TextBuffer,X        ;
L995A:  INY                     ;Put character in text buffer and increment to next data byte.
L995B:  INX                     ;

L995C:  CMP #TXT_END            ;Have we reached the end of this string of text?
L995E:  BEQ +                   ;If so, branch.
L9960:  JMP EndTxtLineLoop      ;($9951)Loop to get full line of end credit text.

L9963:* LDA #$01                ;
L9965:  STA TXTClrRows          ;Prepare to clear another row of 32 columns for next text line.
L9967:  LDA #$20                ;
L9969:  STA TXTClrCols          ;

L996B:  TYA                     ;
L996C:  CLC                     ;
L996D:  ADC EndCreditPtrLB      ;
L996F:  STA EndCreditPtrLB      ;Add current text index to base pointer to move to next string.
L9971:  LDA #$00                ;
L9973:  ADC EndCreditPtrUB      ;
L9975:  STA EndCreditPtrUB      ;

L9977:  LDA #$1D                ;
L9979:  STA TXTYPos             ;Line of text starts at bottom of screen. X,Y=0,29.
L997B:  LDA #$00                ;
L997D:  STA TXTXPos             ;

L997F:  LDA #TXT_DBL_SPACE      ;Text is double spaced.
L9981:  STA TextIndex           ;
L9983:  JSR DisplayText1        ;($C003)Display text on the screen.

L9986:  LDA #$04                ;Scroll screen up 16 pixels.
L9988:  STA ScrollDirAmt        ;

L998A:* LDA ScrollDirAmt        ;Wait until screen has finished scrolling.
L998C:  BNE -                   ;

L998E:  JMP EndTextLoop         ;($991B)Get next string of end credits.

Spinlock:
L9991:  JMP Spinlock            ;($9991)End of credits reached. Spinlock until reset.

;----------------------------------------------------------------------------------------------------

ResetNameTableE3:
L9994:  LDA #$00                ;
L9996:  STA NTXPosLB            ;
L9998:  STA NTXPosUB            ;
L999A:  STA NTYPosLB            ;
L999C:  STA NTYPosUB            ;
L999E:  STA NTXPosLB16          ;
L99A0:  STA NTXPosUB16          ;Reset all nametable offset values and select nametable 0;
L99A2:  STA NTYPosLB16          ;
L99A4:  STA NTYPosUB16          ;
L99A6:  LDA CurPPUConfig0       ;
L99A8:  AND #$FC                ;
L99AA:  STA CurPPUConfig0       ;
L99AC:  RTS                     ;

;----------------------------------------------------------------------------------------------------

ClrPPUData:
L99AD:  LDA #SCREEN_OFF         ;Turn screen off.
L99AF:  STA CurPPUConfig1       ;

L99B1:  LDA #$D4                ;Hide the upper 10 sprites.
L99B3:  STA HideUprSprites      ;

L99B5:  LDY #$00                ;Prepare to hide all sprites off screen.
L99B7:  LDA #$F0                ;

L99B9:* STA SpriteBuffer,Y      ;
L99BC:  INY                     ;
L99BD:  INY                     ;Hide all 64 sprites off screen.
L99BE:  INY                     ;
L99BF:  INY                     ;
L99C0:  BNE -                   ;

L99C2:  LDY #$00                ;Prepare to zero out the blocks buffer.
L99C4:  LDA #$00                ;

L99C6:* STA BlocksBuffer,Y      ;
L99C9:  INY                     ;Zero out the blocks buffer.
L99CA:  BNE -                   ;

L99CC:  LDA #>BlocksBuffer      ;
L99CE:  STA PPUSrcPtrUB         ;Source Pointer to empty blocks buffer
L99D0:  LDA #<BlocksBuffer      ;
L99D2:  STA PPUSrcPtrLB         ;

L99D4:  LDA #PPU_NT0_UB         ;
L99D6:  STA PPUDstPtrUB         ;Destination pointer to name table 0.
L99D8:  LDA #PPU_NT0_LB         ;
L99DA:  STA PPUDstPtrLB         ;

L99DC:  LDA #$01                ;
L99DE:  STA PPUByteCntUB        ;Prepare to load 256 bytes into the PPU.
L99E0:  LDA #$00                ;
L99E2:  STA PPUByteCntLB        ;

L99E4:* JSR LoadPPU1            ;($C006)Load values into the PPU.

L99E7:  INC PPUDstPtrUB         ;
L99E9:  LDA PPUDstPtrUB         ;Keep loading blank data in the PPU
L99EB:  CMP #PPU_NT1_UB         ; until Name table zero is zeroed out.
L99ED:  BNE -                   ;

L99EF:  LDY #$00                ;Prepare to load attribute table 0.
L99F1:  LDA #$55                ;

L99F3:* STA BlocksBuffer,Y      ;
L99F6:  INY                     ;Set all 64 bytes of attribute table 0 to point to palette index 1.
L99F7:  CPY #$40                ;
L99F9:  BNE -                   ;

L99FB:  LDA #>BlocksBuffer      ;
L99FD:  STA PPUSrcPtrUB         ;Source pointer to blocks buffer.
L99FF:  LDA #<BlocksBuffer      ;
L9A01:  STA PPUSrcPtrLB         ;

L9A03:  LDA #PPU_AT0_UB         ;
L9A05:  STA PPUDstPtrUB         ;Destination pointer to attribute table 0.
L9A07:  LDA #PPU_AT0_LB         ;
L9A09:  STA PPUDstPtrLB         ;

L9A0B:  LDA #$00                ;
L9A0D:  STA PPUByteCntUB        ;Prepare to load 64 bytes into the PPU.
L9A0F:  LDA #$40                ;
L9A11:  STA PPUByteCntLB        ;

L9A13:  JSR LoadPPU1            ;($C006)Load values into the PPU.

L9A16:  LDA #SCREEN_ON          ;
L9A18:  STA CurPPUConfig1       ;Turn screen on.
L9A1A:  RTS                     ;

;----------------------------------------------------------------------------------------------------------------------------------------

CreditsData:
;             X=12  C    R    E    D    I    T    S   END
L9A1B:  .byte $0C, $8C, $9B, $8E, $8D, $92, $9D, $9C, $FF
L9A24:  .byte $01, $00, $FF     ;New line.
L9A27:  .byte $01, $00, $FF     ;New line.
L9A2A:  .byte $01, $00, $FF     ;New line.
;             X=6   O    R    I    G    I    N    A    L    _    D    E    S    I    G    N    E    D    _    B    Y   END
L9A2D:  .byte $06, $98, $9B, $92, $90, $92, $97, $8A, $95, $00, $8D, $8E, $9C, $92, $90, $97, $8E, $8D, $00, $8B, $A2, $FF
L9A43:  .byte $01, $00, $FF     ;New line
;             X=7   R    I    C    H    A    R    D    _    A    .    G    A    R    R    I    O    T    T   END
L9A46:  .byte $07, $9B, $92, $8C, $91, $8A, $9B, $8D, $00, $8A, $86, $90, $8A, $9B, $9B, $92, $98, $9D, $9D, $FF
L9A5A:  .byte $01, $00, $FF     ;New line.
L9A5D:  .byte $01, $00, $FF     ;New line.
L9A60:  .byte $01, $00, $FF     ;New line.
;             X=8    P   R    O    D    U    C    E    R   END
L9A63:  .byte $0B, $99, $9B, $98, $8D, $9E, $8C, $8E, $9B, $FF
L9A6D:  .byte $01, $00, $FF     ;New line.
;             X=7   M    A    S    A    I    C    H    I    R    O    _    H    I    R    A    N    O   END
L9A70:  .byte $07, $96, $8A, $9C, $8A, $92, $8C, $91, $92, $9B, $98, $00, $91, $92, $9B, $8A, $97, $98, $FF
;             X=9   Y    A    S    U    O    _    H    A    T    T    O    R    I   END
L9A83:  .byte $09, $A2, $8A, $9C, $9E, $98, $00, $91, $8A, $9D, $9D, $98, $9B, $92, $FF
L9A92:  .byte $01, $00, $FF     ;New line.
L9A95:  .byte $01, $00, $FF     ;New line.
;             X=11  D    I    R    E    C    T    O    R   END
L9A98:  .byte $0B, $8D, $92, $9B, $8E, $8C, $9D, $98, $9B, $FF
L9AA2:  .byte $01, $00, $FF     ;New line.
;             X=8   K    U    N    I    H    I    K    O    _    K    A    G    A    W    A   END
L9AA5:  .byte $08, $94, $9E, $97, $92, $91, $92, $94, $98, $00, $94, $8A, $90, $8A, $A0, $8A, $FF
;             X=9   J    U    N    I    C    H    I    _    I    S    H    I    I   END
L9AB6:  .byte $09, $93, $9E, $97, $92, $8C, $91, $92, $00, $92, $9C, $91, $92, $92, $FF
L9AC5:  .byte $01, $00, $FF     ;New line.
L9AC8:  .byte $01, $00, $FF     ;New line.
;             X=10  C    O    O    R    D    I    N    A    T    O    R   END
L9ACB:  .byte $0A, $8C, $98, $98, $9B, $8D, $92, $97, $8A, $9D, $98, $9B, $FF
L9AD8:  .byte $01, $00, $FF     ;New line.
;             X=9   K    O    J    I    _    I    C    H    I    K    A    W    A   END
L9ADB:  .byte $09, $94, $98, $93, $92, $00, $92, $8C, $91, $92, $94, $8A, $A0, $8A, $FF
;             X=10  M    A    S    U    K    O    _    M    O    R    I   END
L9AEA:  .byte $0A, $96, $8A, $9C, $9E, $94, $98, $00, $96, $98, $9B, $92, $FF
L9AF7:  .byte $01, $00, $FF     ;New line.
L9AFA:  .byte $01, $00, $FF     ;New line.
;             X=8   S    A    L    E    S    _    P    R    O    M    O    T    I    O    N   END
L9AFD:  .byte $08, $9C, $8A, $95, $8E, $9C, $00, $99, $9B, $98, $96, $98, $9D, $92, $98, $97, $FF
L9B0E:  .byte $01, $00, $FF     ;New line.
;             X=9   M    U    T    S    U    K    O    _    A    R    A    T    S   END
L9B11:  .byte $09, $96, $9E, $9D, $9C, $9E, $94, $98, $00, $8A, $9B, $8A, $9D, $8A, $FF
L9B20:  .byte $01, $00, $FF     ;New line.
L9B23:  .byte $01, $00, $FF     ;New line.
L9B26:  .byte $01, $00, $FF     ;New line.
;             X=8   C    H    I    E    F    _    P    R    O    G    R    A    M    M    E    R   END
L9B29:  .byte $08, $8C, $91, $92, $8E, $8F, $00, $99, $9B, $98, $90, $9B, $8A, $96, $96, $8E, $9B, $FF
L9B3B:  .byte $01, $00, $FF     ;New line.
;             X=9   T    A    K    A    A    K    I    _    U    S    H    I    K    I   END
L9B3E:  .byte $09, $9D, $8A, $94, $8A, $8A, $94, $92, $00, $9E, $9C, $91, $92, $94, $92, $FF
L9B4E:  .byte $01, $00, $FF     ;New line.
L9B51:  .byte $01, $00, $FF     ;New line.
;             X=12  P    R    O    G    R    A    M    M    E    R   END
L9B54:  .byte $0B, $99, $9B, $98, $90, $9B, $8A, $96, $96, $8E, $9B, $FF
L9B60:  .byte $01, $00, $FF     ;New line.
;             X=7   Y    O    S    H    I    H    I    K    O    _    N    A    K    A    Z    A    W    A   END
L9B63:  .byte $07, $A2, $98, $9C, $91, $92, $91, $92, $94, $98, $00, $97, $8A, $94, $8A, $A3, $8A, $A0, $8A, $FF
;             X=9   T    O    M    O    H    I    R    O    _    H    O    R    I   END
L9B77:  .byte $09, $9D, $98, $96, $98, $91, $92, $9B, $98, $00, $91, $98, $9B, $92, $FF
;             X=12  N    A    O    K    I    _    K    O    G    A   END
L9B86:  .byte $0B, $97, $8A, $98, $94, $92, $00, $94, $98, $90, $8A, $FF
;             X=12  S    A    E    K    O    _    S    U    D    A   END
L9B92:  .byte $0B, $9C, $8A, $8E, $94, $98, $00, $9C, $9E, $8D, $8A, $FF
L9B9E:  .byte $01, $00, $FF     ;New line.
L9BA1:  .byte $01, $00, $FF     ;New line.
;             X=7   C    H    A    R    A    C    T    E    R    _    D    E    S    I    G    N    E    R   END
L9BA4:  .byte $07, $8C, $91, $8A, $9B, $8A, $8C, $9D, $8E, $9B, $00, $8D, $8E, $9C, $92, $90, $97, $8E, $9B, $FF
L9BB8:  .byte $01, $00, $FF     ;New line.
;             X=8   A    T    S    U    S    H    I    _    F    U    J    I    M    O    R    I   END
L9BBB:  .byte $08, $8A, $9D, $9C, $9E, $9C, $91, $92, $00, $8F, $9E, $93, $92, $96, $98, $9B, $92, $FF
L9BCD:  .byte $01, $00, $FF     ;New line.
L9BE0:  .byte $01, $00, $FF     ;New line.
;             X=7   W    O    R    D    S    _    A    R    R    A    N    G    E    M    E    N    T   END
L9BE3:  .byte $07, $A0, $98, $9B, $8D, $9C, $00, $8A, $9B, $9B, $8A, $97, $90, $8E, $96, $8E, $97, $9D, $FF
L9BF6:  .byte $01, $00, $FF     ;New line.
;             X=8   Y    A    S    U    S    H    I    _    A    K    I    M    O    T    O   END
L9BF9:  .byte $08, $A2, $8A, $9C, $9E, $9C, $91, $92, $00, $8A, $94, $92, $96, $98, $9D, $98, $FF
L9C0A:  .byte $01, $00, $FF     ;New line.
L9C0D:  .byte $01, $00, $FF     ;New line.
;             X=13  M    U    S    I    C   END
L9C10:  .byte $0D, $96, $9E, $9C, $92, $8C, $FF
L9C17:  .byte $01, $00, $FF     ;New line.
;             X=8   T    S    U    G    U    T    O    S    H    I    _    G    O    T    O   END
L9C1A:  .byte $08, $9D, $9C, $9E, $90, $9E, $9D, $98, $9C, $91, $92, $00, $90, $98, $9D, $98, $FF
L9C1B:  .byte $01, $00, $FF     ;New line.
L9C1E:  .byte $01, $00, $FF     ;New line.
;             X=10  I    L    L    U    S    T    R    A    T    O    R   END
L9C21:  .byte $0A, $92, $95, $95, $9E, $9C, $9D, $9B, $8A, $9D, $98, $9B, $FF
L9C2E:  .byte $01, $00, $FF     ;New line.
;             X=8   T    A    D    A    S    H    I    _    T    S    U    K    A    D    A   END
L9C31:  .byte $08, $9D, $8A, $8D, $8A, $9C, $91, $92, $00, $9D, $9C, $9E, $94, $8A, $8D, $8A, $FF
L9C42:  .byte $01, $00, $FF     ;New line.
L9C45:  .byte $01, $00, $FF     ;New line.
L9C48:  .byte $01, $00, $FF     ;New line.
;             X=7   S    P    E    C    I    A    L    _    T    H    A    N    K    S    _    T    O   END
L9C4B:  .byte $07, $9C, $99, $8E, $8C, $92, $8A, $95, $00, $9D, $91, $8A, $97, $94, $9C, $00, $9D, $98, $FF
L9C5E:  .byte $01, $00, $FF     ;New line.
;             X=9   A    Y    A    _    N    I    S    H    I    T    A    N    I   END
L9C61:  .byte $09, $8A, $A2, $8A, $00, $97, $92, $9C, $91, $92, $9D, $8A, $97, $92, $FF
;             X=9   S    A    B    U    R    O    _    Y    A    M    A    D    A   END
L9C70:  .byte $09, $9C, $8A, $8B, $9E, $9B, $98, $00, $A2, $8A, $96, $8A, $8D, $8A, $FF
;             X=7   Y    A    S    U    H    I    R    O    _    K    A    W    A    S    H    I    M    A   END
L9C7F:  .byte $07, $A2, $8A, $9C, $9E, $91, $92, $9B, $98, $00, $94, $8A, $A0, $8A, $9C, $91, $92, $96, $8A, $FF
;             X=8   K    O    N    O    _    P    R    O    D    U    C    T    I    O    N   END
L9C93:  .byte $08, $94, $98, $97, $98, $00, $99, $9B, $98, $8D, $9E, $8C, $9D, $92, $98, $97, $FF
L9CA4:  .byte $01, $00, $FF     ;New line.
L9CA7:  .byte $01, $00, $FF     ;New line.
L9CAA:  .byte $01, $00, $FF     ;New line.
L9CAD:  .byte $01, $00, $FF     ;New line.
L9CB0:  .byte $01, $00, $FF     ;New line.
L9CB3:  .byte $01, $00, $FF     ;New line.
L9CB6:  .byte $01, $00, $FF     ;New line.
L9CB9:  .byte $01, $00, $FF     ;New line.
L9CBC:  .byte $01, $00, $FF     ;New line.
L9CBF:  .byte $01, $00, $FF     ;New line.
L9CC2:  .byte $01, $00, $FF     ;New line.
L9CC5:  .byte $01, $00, $FF     ;New line.
L9CC8:  .byte $01, $00, $FF     ;New line.
L9CCB:  .byte $01, $00, $FF     ;New line.
;             X=10  P    R    O    D    U    C    E    D    _    B    Y   END
L9CCE:  .byte $0A, $99, $9B, $98, $8D, $9E, $8C, $8E, $8D, $00, $8B, $A2, $FF
L9CDB:  .byte $01, $00, $FF     ;New line.
;             X=7   N    E    W    T    O    P    I    A    _    P    L    A    N    N    I    N    G   END
L9CDE:  .byte $07, $97, $8E, $A0, $9D, $98, $99, $92, $8A, $00, $99, $95, $8A, $97, $97, $92, $97, $90, $FF
L9CF1:  .byte $01, $00, $FF     ;New line.
L9CF4:  .byte $01, $00, $FF     ;New line.
L9CF7:  .byte $01, $00, $FF     ;New line.
L9CFA:  .byte $01, $00, $FF     ;New line.
L9CFD:  .byte $01, $00, $FF     ;New line.
L9D00:  .byte $01, $00, $FF     ;New line.
L9D03:  .byte $01, $00, $FF     ;New line.
L9D06:  .byte $01, $00, $FF     ;New line.
L9D09:  .byte $01, $00, $FF     ;New line.
L9D0C:  .byte $01, $00, $FF     ;New line.
L9D0F:  .byte $01, $00, $FF     ;New line.
L9D12:  .byte $01, $00, $FF     ;New line.
L9D15:  .byte $01, $00, $FF     ;New line.
L9D18:  .byte $01, $00, $FF     ;New line.
;             X=4   U    L    T    I    M    A    _    A    N    D    _    L    O    R    D    _    B    R    I    T    I    S    H   END
L9D1B:  .byte $04, $9E, $95, $9D, $92, $96, $8A, $00, $8A, $97, $8D, $00, $95, $98, $9B, $8D, $00, $8B, $9B, $92, $9D, $92, $9C, $91, $FF
;             X=7   A    R    E    _    T    R    A    D    E    _    M    A    R    K    S    _    O    F   END
L9D34:  .byte $07, $8A, $9B, $8E, $00, $9D, $9B, $8A, $8D, $8E, $00, $96, $8A, $9B, $94, $9C, $00, $98, $8F, $FF
;             X=7   R    I    C    H    A    R    D    _    A    .    G    A    R    R    I    O    T    T   END
L9D48:  .byte $07, $9B, $92, $8C, $91, $8A, $9B, $8D, $00, $8A, $86, $90, $8A, $9B, $9B, $92, $98, $9D, $9D, $FF
L9D5C:  .byte $01, $00, $FF     ;New line.
L9D5F:  .byte $01, $00, $FF     ;New line.
L9D62:  .byte $01, $00, $FF     ;New line.
L9D65:  .byte $01, $00, $FF     ;New line.
L9D68:  .byte $01, $00, $FF     ;New line.
L9D6B:  .byte $01, $00, $FF     ;New line.
L9D6E:  .byte $01, $00, $FF     ;New line.
L9D71:  .byte $01, $00, $FF     ;New line.
L9D74:  .byte $01, $00, $FF     ;New line.
L9D77:  .byte $01, $00, $FF     ;New line.
L9D7A:  .byte $01, $00, $FF     ;New line.
L9D7D:  .byte $01, $00, $FF     ;New line.
L9D80:  .byte $01, $00, $FF     ;New line.
L9D83:  .byte $01, $00, $FF     ;New line.
;             X=7   O    R    I    G    I    N    A    L    _    V    E    R    S    I    O    N   END
L9D86:  .byte $07, $98, $9B, $92, $90, $92, $97, $8A, $95, $00, $9F, $8E, $9B, $9C, $92, $98, $97, $FF
;             X=14  O    F   END
L9D98:  .byte $0E, $98, $8F, $FF
;             X=12  U    L    T    I    M    A   END
L9D9C:  .byte $0C, $9E, $95, $9D, $92, $96, $8A, $FF
L9DA4:  .byte $01, $00, $FF     ;New line.
;             X=5  CPY   _    O    R    I    G    I    N    _    S    Y    S    T    E    M    S    _    I    N    C    .   END
L9DA7:  .byte $05, $88, $00, $98, $9B, $92, $90, $92, $97, $00, $9C, $A2, $9C, $9D, $8E, $96, $9C, $00, $92, $97, $8C, $86, $FF
L9DBE:  .byte $01, $00, $FF     ;New line.
L9DC1:  .byte $01, $00, $FF     ;New line.
L9DC4:  .byte $01, $00, $FF     ;New line.
L9DC7:  .byte $01, $00, $FF     ;New line.
L9DCA:  .byte $01, $00, $FF     ;New line.
L9DCD:  .byte $01, $00, $FF     ;New line.
L9DD0:  .byte $01, $00, $FF     ;New line.
L9DD3:  .byte $01, $00, $FF     ;New line.
L9DD6:  .byte $01, $00, $FF     ;New line.
L9DD9:  .byte $01, $00, $FF     ;New line.
L9DDC:  .byte $01, $00, $FF     ;New line.
L9DDF:  .byte $01, $00, $FF     ;New line.
L9DE2:  .byte $01, $00, $FF     ;New line.
L9DE5:  .byte $01, $00, $FF     ;New line.
;             X=7   F    A    M    I    C    O    M    _    V    E    R    S    I    O    N   END
L9DE8:  .byte $07, $8F, $8A, $96, $92, $8C, $98, $96, $00, $9F, $8E, $9B, $9C, $92, $98, $97, $FF
;             X=14  O    F   END
L9DF9:  .byte $0E, $98, $8F, $FF
;             X=12  U    L    T    I    M    A   END
L9DFD:  .byte $0C, $9E, $95, $9D, $92, $96, $8A, $FF
L9E05:  .byte $01, $00, $FF     ;New line.
;             X=6  CPY   _    P    O    N    Y    _    C    A    N    Y    O    N    _    I    N    C    .   END
L9E08:  .byte $06, $88, $00, $99, $98, $97, $A2, $00, $8C, $8A, $97, $A2, $98, $97, $00, $92, $97, $8C, $86, $FF
L9E1C:  .byte $01, $00, $FF     ;New line.
L9E1F:  .byte $01, $00, $FF     ;New line.
L9E22:  .byte $01, $00, $FF     ;New line.
L9E25:  .byte $01, $00, $FF     ;New line.
L9E28:  .byte $01, $00, $FF     ;New line.
L9E2B:  .byte $01, $00, $FF     ;New line.
L9E2E:  .byte $01, $00, $FF     ;New line.
L9E31:  .byte $01, $00, $FF     ;New line.
L9E34:  .byte $01, $00, $FF     ;New line.
L9E37:  .byte $01, $00, $FF     ;New line.
L9E3A:  .byte $01, $00, $FF     ;New line.
L9E3D:  .byte $01, $00, $FF     ;New line.
L9E40:  .byte $01, $00, $FF     ;New line.
L9E43:  .byte $01, $00, $FF     ;New line.
;             X=7   T    H    A    N    K    S    _    F    O    R    _    P    L    A    Y    I    N    G   END
L9E46:  .byte $07, $9D, $91, $8A, $97, $94, $9C, $00, $8F, $98, $9B, $00, $99, $95, $8A, $A2, $92, $97, $90, $FF
L9E5A:  .byte $01, $00, $FF     ;New line.
;             X=7   S    E    E    _    Y    O    U    _    N    E    X    T    _    G    A    M    E   END
L9E5D:  .byte $07, $9C, $8E, $8E, $00, $A2, $98, $9E, $00, $97, $8E, $A1, $9D, $00, $90, $8A, $96, $8E, $FF
L9E70:  .byte $01, $00, $FF     ;New line.
L9E73:  .byte $01, $00, $FF     ;New line.
L9E76:  .byte $01, $00, $FF     ;New line.
L9E79:  .byte $01, $00, $FF     ;New line.
L9E7C:  .byte $01, $00, $FF     ;New line.
;             X=1   _   \n    _   END
L9E7F:  .byte $01, $00, $FD, $00, $FF
;             X=13  E    N    D   END
L9E84:  .byte $0D, $8E, $97, $8D, $FF
L9E89:  .byte $01, $00, $FF     ;New line.
L9E8C:  .byte $01, $00, $FF     ;New line.
L9E8F:  .byte $01, $00, $FF     ;New line.
L9E92:  .byte $01, $00, $FF     ;New line.
L9E95:  .byte $01, $00, $FF     ;New line.
L9E98:  .byte $01, $00, $FF     ;New line.
;             X=1   _   \n   END
L9E9B:  .byte $01, $00, $FD, $FF

;----------------------------------------------------------------------------------------------------------------------------------------

;Unused.
L9E9F:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
L9EAF:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
L9EBF:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
L9ECF:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
L9EDF:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
L9EEF:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
L9EFF:  .byte $FF

;----------------------------------------------------------------------------------------------------

;Unused tile patterns from Bank 6.
L9F00:  .byte $A0, $50, $AA, $55, $AA, $55, $2A, $15, $50, $A0, $55, $AA, $55, $AA, $15, $2A
L9F10:  .byte $00, $00, $00, $00, $A0, $50, $A8, $54, $00, $00, $00, $00, $50, $A0, $54, $A8
L9F20:  .byte $00, $00, $AA, $55, $2A, $15, $02, $01, $00, $00, $55, $AA, $15, $2A, $01, $02
L9F30:  .byte $00, $00, $80, $40, $A0, $50, $A8, $54, $00, $00, $40, $80, $50, $A0, $54, $A8
L9F40:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9F50:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9F60:  .byte $00, $00, $00, $00, $02, $01, $00, $00, $00, $00, $00, $00, $01, $02, $00, $00
L9F70:  .byte $00, $00, $00, $00, $AC, $5C, $00, $00, $00, $00, $00, $00, $5C, $AC, $00, $00
L9F80:  .byte $00, $00, $00, $00, $00, $00, $A0, $50, $00, $00, $00, $00, $00, $00, $50, $A0
L9F90:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9FA0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9FB0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9FC0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9FD0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9FE0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
L9FF0:  .byte $AA, $55, $2A, $15, $02, $01, $00, $00, $55, $AA, $15, $2A, $01, $02, $00, $00
LA000:  .byte $AA, $55, $AA, $55, $A0, $50, $A0, $50, $55, $AA, $55, $AA, $50, $A0, $50, $A0
LA010:  .byte $AA, $55, $AA, $55, $AF, $5F, $3F, $3F, $55, $AA, $55, $AA, $50, $A0, $00, $00
LA020:  .byte $AA, $55, $F8, $F4, $F0, $F0, $F3, $F3, $55, $AA, $07, $0B, $0F, $0F, $0C, $0C
LA030:  .byte $A0, $50, $3F, $3F, $FF, $FF, $FF, $FF, $50, $A0, $C0, $C0, $00, $00, $00, $00
LA040:  .byte $00, $00, $00, $00, $FE, $FD, $FE, $FD, $00, $00, $00, $00, $01, $02, $01, $02
LA050:  .byte $00, $00, $00, $00, $00, $00, $8A, $45, $00, $00, $00, $00, $00, $00, $45, $8A
LA060:  .byte $2A, $15, $00, $00, $00, $00, $AA, $55, $15, $2A, $00, $00, $00, $00, $55, $AA
LA070:  .byte $20, $10, $00, $00, $0F, $0F, $FF, $FF, $10, $20, $00, $00, $00, $00, $00, $00
LA080:  .byte $00, $00, $03, $03, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LA090:  .byte $00, $00, $A2, $51, $E0, $D0, $FA, $F5, $00, $00, $51, $A2, $10, $20, $05, $0A
LA0A0:  .byte $AC, $50, $AC, $53, $A8, $57, $E8, $D7, $53, $A3, $50, $A0, $54, $A8, $14, $28
LA0B0:  .byte $00, $00, $00, $00, $C0, $30, $0C, $3C, $C0, $C0, $FC, $FC, $0F, $0F, $CF, $CF
LA0C0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA0D0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $03, $03, $0F, $0F, $0C, $0C
LA0E0:  .byte $00, $00, $00, $00, $C0, $C0, $C0, $C0, $00, $00, $FC, $FC, $CF, $CF, $03, $03
LA0F0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA100:  .byte $28, $14, $08, $04, $00, $00, $00, $00, $14, $28, $04, $08, $00, $00, $00, $00
LA110:  .byte $3F, $3F, $00, $00, $2B, $17, $2F, $1F, $00, $00, $3F, $3F, $14, $28, $10, $20
LA120:  .byte $C3, $C3, $0F, $0F, $FF, $FF, $FF, $FF, $3C, $3C, $F0, $F0, $00, $00, $00, $00
LA130:  .byte $FF, $FF, $FF, $FF, $FC, $FC, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LA140:  .byte $FE, $FD, $38, $34, $00, $00, $88, $44, $01, $02, $04, $08, $00, $00, $44, $88
LA150:  .byte $02, $01, $2A, $15, $AA, $55, $2A, $15, $01, $02, $15, $2A, $55, $AA, $15, $2A
LA160:  .byte $AB, $57, $AF, $5F, $BF, $7F, $FF, $FF, $54, $A8, $50, $A0, $40, $80, $00, $00
LA170:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LA180:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LA190:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LA1A0:  .byte $FA, $F5, $FE, $FD, $FF, $FF, $FF, $FF, $05, $0A, $01, $02, $00, $00, $00, $00
LA1B0:  .byte $00, $00, $A0, $50, $E8, $D4, $F8, $F4, $FF, $FF, $5C, $AC, $14, $28, $04, $08
LA1C0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA1D0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $0C, $0C, $0C, $0C, $0F, $0F, $03, $03
LA1E0:  .byte $F0, $F0, $30, $30, $A0, $50, $C0, $30, $03, $03, $03, $03, $5F, $AF, $0C, $0C
LA1F0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA200:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA210:  .byte $3F, $3F, $3F, $3F, $0F, $0F, $00, $00, $00, $00, $0C, $0C, $00, $00, $00, $00
LA220:  .byte $FC, $FC, $F8, $F4, $E8, $D4, $00, $00, $00, $00, $04, $08, $14, $28, $00, $00
LA230:  .byte $2F, $1F, $AF, $5F, $AB, $57, $0F, $0F, $10, $20, $50, $A0, $54, $A8, $00, $00
LA240:  .byte $AA, $55, $FE, $FD, $FF, $FF, $FF, $FF, $55, $AA, $01, $02, $00, $00, $00, $00
LA250:  .byte $2B, $17, $AB, $57, $FF, $FF, $FF, $FF, $14, $28, $54, $A8, $00, $00, $00, $00
LA260:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LA270:  .byte $FF, $FF, $FE, $FD, $FA, $F5, $E8, $D4, $00, $00, $01, $02, $05, $0A, $17, $2B
LA280:  .byte $AA, $55, $80, $40, $0C, $00, $0C, $33, $55, $AA, $7F, $BF, $F3, $F3, $C0, $C0
LA290:  .byte $BF, $7F, $AF, $5F, $2B, $17, $0B, $07, $40, $80, $50, $A0, $D4, $E8, $F4, $F8
LA2A0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LA2B0:  .byte $F0, $F0, $F0, $F0, $F0, $F0, $C0, $C0, $00, $00, $00, $00, $00, $00, $00, $00
LA2C0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA2D0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $03, $03, $03, $03, $03, $03, $0F, $0F
LA2E0:  .byte $C0, $30, $C0, $30, $C0, $30, $CC, $30, $0C, $0C, $0C, $0C, $0F, $0F, $03, $03
LA2F0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA300:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA310:  .byte $00, $00, $0A, $05, $2A, $15, $2B, $17, $00, $00, $05, $0A, $15, $2A, $14, $28
LA320:  .byte $2A, $15, $00, $00, $A2, $51, $E2, $D1, $15, $2A, $00, $00, $51, $A2, $11, $22
LA330:  .byte $80, $40, $AF, $5F, $BF, $7F, $FF, $FF, $40, $80, $50, $A0, $40, $80, $00, $00
LA340:  .byte $3F, $3F, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LA350:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LA360:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LA370:  .byte $E8, $D7, $E8, $D4, $FA, $F5, $FE, $FD, $14, $28, $17, $2B, $05, $0A, $01, $02
LA380:  .byte $CC, $3F, $0C, $33, $0C, $00, $80, $40, $0C, $0C, $C0, $C0, $F3, $F3, $7F, $BF
LA390:  .byte $CB, $07, $0B, $07, $2B, $17, $AF, $5F, $34, $38, $F4, $F8, $D4, $E8, $50, $A0
LA3A0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LA3B0:  .byte $C0, $C0, $C0, $C0, $F0, $F0, $FC, $FC, $00, $00, $00, $00, $30, $30, $0C, $0C
LA3C0:  .byte $00, $00, $0A, $05, $00, $00, $03, $03, $00, $00, $05, $0A, $00, $00, $00, $00
LA3D0:  .byte $00, $03, $28, $17, $3A, $35, $FE, $FD, $0C, $0C, $14, $28, $05, $0A, $01, $02
LA3E0:  .byte $CC, $30, $CC, $30, $C0, $30, $80, $70, $03, $03, $03, $03, $0F, $0F, $4C, $8C
LA3F0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA400:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA410:  .byte $2F, $1F, $2B, $17, $0A, $05, $02, $01, $10, $20, $14, $28, $05, $0A, $0D, $0E
LA420:  .byte $EA, $D5, $FF, $FF, $FF, $FF, $FF, $FF, $15, $2A, $00, $00, $00, $00, $00, $00
LA430:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LA440:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $AA, $55, $00, $00, $00, $00, $00, $00, $55, $AA
LA450:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $AA, $55, $00, $00, $00, $00, $00, $00, $55, $AA
LA460:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LA470:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LA480:  .byte $AA, $55, $FF, $FF, $FF, $FF, $FF, $FF, $55, $AA, $00, $00, $00, $00, $00, $00
LA490:  .byte $BF, $7F, $FF, $FF, $FF, $FF, $FF, $FF, $40, $80, $00, $00, $00, $00, $00, $00
LA4A0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LA4B0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LA4C0:  .byte $FF, $FF, $FF, $FF, $AF, $5F, $EB, $D7, $00, $00, $00, $00, $50, $A0, $14, $28
LA4D0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LA4E0:  .byte $A0, $50, $E8, $D4, $F8, $F4, $F0, $F0, $5C, $AC, $14, $28, $04, $08, $00, $00
LA4F0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA500:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA510:  .byte $00, $00, $00, $00, $03, $03, $03, $03, $0F, $0F, $03, $03, $00, $00, $00, $00
LA520:  .byte $AF, $5F, $2B, $17, $0A, $05, $C2, $C1, $50, $A0, $D4, $E8, $F5, $FA, $3D, $3E
LA530:  .byte $EA, $D5, $AA, $55, $A0, $50, $A3, $53, $15, $2A, $55, $AA, $5F, $AF, $5C, $AC
LA540:  .byte $AA, $55, $00, $00, $0C, $03, $0C, $33, $55, $AA, $FF, $FF, $F0, $F0, $C0, $C0
LA550:  .byte $AA, $55, $2A, $15, $02, $01, $F0, $F0, $55, $AA, $D5, $EA, $FD, $FE, $0F, $0F
LA560:  .byte $AA, $55, $AA, $55, $AA, $55, $2A, $15, $55, $AA, $55, $AA, $55, $AA, $D5, $EA
LA570:  .byte $FF, $FF, $AF, $5F, $AA, $55, $AA, $55, $00, $00, $50, $A0, $55, $AA, $55, $AA
LA580:  .byte $FF, $FF, $FF, $FF, $BF, $7F, $AF, $5F, $00, $00, $00, $00, $40, $80, $50, $A0
LA590:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LA5A0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LA5B0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LA5C0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FC, $FC, $00, $00, $00, $00, $00, $00, $00, $00
LA5D0:  .byte $FF, $FF, $CF, $CF, $C3, $C3, $F3, $F3, $00, $00, $00, $00, $00, $00, $00, $00
LA5E0:  .byte $F0, $F0, $F0, $F0, $A0, $50, $80, $40, $00, $00, $00, $00, $50, $A0, $40, $80
LA5F0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA600:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA610:  .byte $03, $03, $0F, $0F, $0E, $0D, $0A, $05, $00, $00, $00, $00, $01, $02, $05, $0A
LA620:  .byte $F2, $F1, $C3, $C3, $0F, $0F, $3F, $3F, $3D, $3E, $3C, $3C, $F0, $F0, $C0, $C0
LA630:  .byte $A3, $53, $E1, $D2, $E0, $D0, $F8, $F4, $5C, $AC, $1D, $2E, $1F, $2F, $07, $0B
LA640:  .byte $0F, $33, $0F, $3F, $3F, $3F, $3C, $3C, $C0, $C0, $C0, $C0, $C0, $C0, $CC, $CC
LA650:  .byte $FE, $FD, $FF, $FF, $FF, $FF, $0F, $0F, $01, $02, $00, $00, $00, $00, $00, $00
LA660:  .byte $02, $01, $A0, $40, $AC, $53, $AC, $53, $FD, $FE, $5F, $BF, $50, $A0, $50, $A0
LA670:  .byte $AA, $55, $2A, $15, $00, $00, $CF, $33, $55, $AA, $D5, $EA, $FF, $FF, $00, $00
LA680:  .byte $AB, $57, $AA, $55, $2A, $15, $2A, $15, $54, $A8, $55, $AA, $D5, $EA, $D5, $EA
LA690:  .byte $FF, $FF, $FE, $FD, $BA, $75, $AA, $55, $00, $00, $01, $02, $45, $8A, $55, $AA
LA6A0:  .byte $AF, $5F, $AF, $5F, $BF, $7F, $FF, $FF, $50, $A0, $50, $A0, $40, $80, $00, $00
LA6B0:  .byte $FF, $FF, $FF, $FF, $FE, $FD, $FA, $F5, $00, $00, $00, $00, $01, $02, $05, $0A
LA6C0:  .byte $AC, $5C, $AF, $5F, $BF, $7F, $FF, $FF, $50, $A0, $50, $A0, $40, $80, $00, $00
LA6D0:  .byte $00, $00, $3C, $3C, $30, $30, $F3, $F3, $00, $00, $00, $00, $00, $00, $00, $00
LA6E0:  .byte $00, $00, $00, $00, $0C, $0C, $CC, $CC, $00, $00, $3F, $3F, $FF, $FF, $F3, $F3
LA6F0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $C0, $C0, $C0, $C0
LA700:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA710:  .byte $28, $14, $2B, $17, $2F, $1F, $0F, $0F, $17, $2B, $14, $28, $10, $20, $00, $00
LA720:  .byte $3F, $3F, $FF, $FF, $FF, $FF, $FF, $FF, $C0, $C0, $00, $00, $00, $00, $00, $00
LA730:  .byte $FA, $F5, $FE, $FD, $FF, $FF, $FF, $FF, $05, $0A, $01, $02, $00, $00, $00, $00
LA740:  .byte $00, $00, $00, $00, $80, $40, $F8, $F4, $C0, $C0, $F0, $F0, $7F, $BF, $07, $0B
LA750:  .byte $02, $01, $00, $00, $00, $00, $00, $00, $01, $02, $00, $00, $00, $00, $C3, $C3
LA760:  .byte $AC, $53, $AC, $50, $80, $40, $0F, $0F, $50, $A0, $53, $A3, $7F, $BF, $F0, $F0
LA770:  .byte $C0, $30, $02, $01, $AA, $55, $AA, $55, $0F, $0F, $FD, $FE, $55, $AA, $55, $AA
LA780:  .byte $2A, $15, $AA, $55, $AB, $57, $BF, $7F, $D5, $EA, $55, $AA, $54, $A8, $40, $80
LA790:  .byte $AF, $5F, $FF, $FF, $FF, $FF, $FF, $FF, $50, $A0, $00, $00, $00, $00, $00, $00
LA7A0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FE, $FD, $00, $00, $00, $00, $00, $00, $01, $02
LA7B0:  .byte $E8, $D4, $A0, $50, $A0, $50, $A8, $54, $17, $2B, $5F, $AF, $5F, $AF, $57, $AB
LA7C0:  .byte $10, $20, $54, $A8, $74, $B8, $74, $B8, $DF, $EF, $57, $AB, $77, $BB, $47, $8B
LA7D0:  .byte $83, $43, $03, $03, $02, $01, $02, $01, $40, $80, $C0, $C0, $C1, $C2, $01, $02
LA7E0:  .byte $C0, $C0, $FC, $FC, $A0, $50, $B0, $70, $3F, $3F, $00, $00, $50, $A0, $40, $80
LA7F0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA800:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA810:  .byte $0F, $0F, $0A, $05, $02, $01, $02, $01, $00, $00, $05, $0A, $01, $02, $01, $02
LA820:  .byte $FF, $FF, $AF, $5F, $AA, $55, $AA, $55, $00, $00, $50, $A0, $55, $AA, $55, $AA
LA830:  .byte $FF, $FF, $FF, $FF, $BF, $7F, $AB, $57, $00, $00, $00, $00, $40, $80, $54, $A8
LA840:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LA850:  .byte $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00
LA860:  .byte $FF, $FF, $FF, $FF, $FE, $FD, $EA, $D5, $00, $00, $00, $00, $01, $02, $15, $2A
LA870:  .byte $AA, $55, $EB, $D7, $AA, $55, $AA, $55, $55, $AA, $14, $28, $55, $AA, $55, $AA
LA880:  .byte $FF, $FF, $FF, $FF, $AF, $5F, $AB, $57, $00, $00, $00, $00, $50, $A0, $54, $A8
LA890:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LA8A0:  .byte $FA, $F5, $FA, $F5, $F0, $F0, $FC, $FC, $05, $0A, $05, $0A, $00, $00, $00, $00
LA8B0:  .byte $A8, $54, $A8, $57, $A8, $57, $80, $40, $57, $AB, $54, $A8, $54, $A8, $40, $80
LA8C0:  .byte $F0, $30, $C0, $00, $00, $00, $00, $00, $0F, $0F, $3C, $3C, $F0, $F0, $00, $00
LA8D0:  .byte $00, $00, $28, $14, $20, $10, $A0, $50, $00, $00, $14, $28, $10, $20, $50, $A0
LA8E0:  .byte $AC, $5C, $EC, $DC, $AC, $5C, $A8, $54, $50, $A0, $10, $20, $50, $A0, $54, $A8
LA8F0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA900:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LA910:  .byte $00, $00, $02, $01, $02, $01, $0A, $05, $00, $00, $01, $02, $01, $02, $05, $0A
LA920:  .byte $AA, $55, $AA, $55, $AA, $55, $AA, $55, $55, $AA, $55, $AA, $55, $AA, $55, $AA
LA930:  .byte $AA, $55, $AA, $55, $AA, $55, $80, $40, $55, $AA, $55, $AA, $55, $AA, $40, $80
LA940:  .byte $BF, $7F, $AB, $57, $80, $40, $00, $00, $40, $80, $54, $A8, $40, $80, $00, $00
LA950:  .byte $FF, $FF, $FA, $F5, $0A, $05, $00, $00, $00, $00, $05, $0A, $05, $0A, $00, $00
LA960:  .byte $AA, $55, $AA, $55, $AA, $55, $2A, $15, $55, $AA, $55, $AA, $55, $AA, $15, $2A
LA970:  .byte $2A, $15, $0A, $05, $8A, $45, $88, $44, $15, $2A, $05, $0A, $45, $8A, $44, $88
LA980:  .byte $AA, $55, $2A, $15, $2A, $15, $2A, $15, $55, $AA, $15, $2A, $15, $2A, $15, $2A
LA990:  .byte $AF, $5F, $AB, $57, $AA, $55, $AA, $55, $50, $A0, $54, $A8, $55, $AA, $55, $AA
LA9A0:  .byte $F0, $F0, $C3, $C3, $FF, $FF, $BF, $7F, $00, $00, $00, $00, $00, $00, $40, $80
LA9B0:  .byte $0F, $0F, $3F, $3F, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LA9C0:  .byte $F0, $F0, $FC, $FC, $FC, $FC, $FC, $FC, $00, $00, $00, $00, $00, $00, $00, $00
LA9D0:  .byte $A8, $54, $28, $14, $00, $00, $02, $01, $54, $A8, $14, $28, $00, $00, $01, $02
LA9E0:  .byte $28, $14, $00, $00, $A0, $50, $80, $40, $14, $28, $00, $00, $50, $A0, $7F, $BF
LA9F0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAA00:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAA10:  .byte $0B, $07, $02, $01, $00, $00, $00, $00, $07, $0B, $01, $02, $00, $00, $00, $00
LAA20:  .byte $A8, $54, $80, $40, $00, $00, $00, $00, $54, $A8, $40, $80, $00, $00, $00, $00
LAA30:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAA40:  .byte $02, $01, $00, $00, $00, $00, $00, $00, $01, $02, $00, $00, $00, $00, $00, $00
LAA50:  .byte $80, $40, $00, $00, $00, $00, $00, $00, $40, $80, $00, $00, $00, $00, $00, $00
LAA60:  .byte $0A, $05, $00, $00, $00, $00, $00, $00, $05, $0A, $00, $00, $00, $00, $00, $00
LAA70:  .byte $00, $00, $28, $14, $AA, $55, $AA, $55, $00, $00, $14, $28, $55, $AA, $55, $AA
LAA80:  .byte $AA, $55, $0A, $05, $AA, $55, $AC, $53, $55, $AA, $05, $0A, $55, $AA, $50, $A0
LAA90:  .byte $AA, $55, $AA, $55, $8C, $73, $CC, $33, $55, $AA, $55, $AA, $40, $80, $00, $00
LAAA0:  .byte $AB, $57, $AA, $55, $CA, $35, $CC, $33, $54, $A8, $55, $AA, $05, $0A, $00, $00
LAAB0:  .byte $FF, $FF, $BF, $7F, $AF, $5F, $AA, $55, $00, $00, $40, $80, $50, $A0, $55, $AA
LAAC0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LAAD0:  .byte $0E, $0D, $0F, $0F, $03, $03, $F0, $F0, $01, $02, $00, $00, $00, $00, $00, $00
LAAE0:  .byte $AC, $5C, $A8, $54, $FA, $F5, $F8, $F4, $5F, $AF, $57, $AB, $05, $0A, $04, $08
LAAF0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAB00:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAB10:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAB20:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF
LAB30:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $C0, $C0
LAB40:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAB50:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAB60:  .byte $00, $00, $02, $01, $00, $03, $0C, $03, $00, $00, $01, $02, $00, $00, $00, $00
LAB70:  .byte $A8, $57, $8C, $73, $CC, $33, $CC, $33, $54, $A8, $40, $80, $00, $00, $00, $00
LAB80:  .byte $CC, $33, $CC, $33, $CC, $33, $CC, $33, $00, $00, $00, $00, $00, $00, $00, $00
LAB90:  .byte $CC, $33, $CC, $33, $CC, $33, $CC, $33, $00, $00, $00, $00, $00, $00, $00, $00
LABA0:  .byte $CC, $33, $CC, $33, $CC, $33, $CC, $33, $00, $00, $00, $00, $00, $00, $00, $00
LABB0:  .byte $EA, $15, $EA, $15, $EA, $15, $AA, $55, $15, $2A, $15, $2A, $15, $2A, $55, $AA
LABC0:  .byte $BF, $7F, $AF, $5F, $AB, $57, $2A, $15, $40, $80, $50, $A0, $54, $A8, $15, $2A
LABD0:  .byte $FC, $FC, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LABE0:  .byte $00, $00, $F0, $F0, $FC, $FC, $FC, $FC, $00, $00, $00, $00, $00, $00, $00, $00
LABF0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAC00:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAC10:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $03, $03, $03, $03, $03, $03
LAC20:  .byte $15, $2A, $1D, $2E, $C0, $C0, $F3, $F3, $D5, $EA, $DD, $EE, $00, $00, $00, $00
LAC30:  .byte $00, $00, $00, $00, $C0, $C0, $C0, $C0, $C0, $C0, $F0, $F0, $30, $30, $30, $30
LAC40:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $03, $03, $0F, $0F
LAC50:  .byte $00, $00, $00, $03, $0C, $03, $AC, $53, $00, $00, $3C, $3C, $F0, $F0, $50, $A0
LAC60:  .byte $0C, $33, $CC, $33, $CC, $33, $CC, $33, $00, $00, $00, $00, $00, $00, $00, $00
LAC70:  .byte $CC, $33, $CC, $33, $CC, $33, $CC, $33, $00, $00, $00, $00, $00, $00, $00, $00
LAC80:  .byte $CC, $33, $CC, $33, $CC, $33, $CC, $33, $00, $00, $00, $00, $00, $00, $00, $00
LAC90:  .byte $CC, $33, $CC, $33, $CC, $33, $CC, $33, $00, $00, $00, $00, $00, $00, $00, $00
LACA0:  .byte $CE, $31, $CE, $30, $CA, $35, $EA, $15, $01, $02, $01, $03, $05, $0A, $15, $2A
LACB0:  .byte $AA, $55, $AA, $55, $82, $41, $A0, $50, $55, $AA, $55, $AA, $41, $82, $50, $A0
LACC0:  .byte $2A, $15, $22, $11, $22, $11, $02, $01, $15, $2A, $11, $22, $11, $22, $01, $02
LACD0:  .byte $BF, $7F, $AB, $57, $AA, $55, $A8, $54, $40, $80, $54, $A8, $55, $AA, $54, $A8
LACE0:  .byte $FF, $FF, $FF, $FF, $0F, $0F, $0F, $0F, $00, $00, $00, $00, $00, $00, $00, $00
LACF0:  .byte $00, $00, $C0, $C0, $C0, $C0, $C0, $C0, $00, $00, $00, $00, $00, $00, $00, $00
LAD00:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAD10:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $03, $03, $00, $00, $00, $00, $00, $00
LAD20:  .byte $00, $00, $00, $00, $0C, $0C, $0C, $0C, $F3, $F3, $F3, $F3, $3F, $3F, $3F, $3F
LAD30:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $F0, $F0, $C0, $C0, $00, $00, $00, $00
LAD40:  .byte $02, $01, $03, $03, $00, $00, $00, $00, $0D, $0E, $0F, $0F, $0F, $0F, $00, $00
LAD50:  .byte $A8, $57, $F0, $F0, $00, $00, $00, $00, $54, $A8, $0F, $0F, $F8, $F8, $00, $00
LAD60:  .byte $C0, $03, $00, $00, $00, $00, $00, $00, $3C, $3C, $F0, $F0, $00, $00, $00, $00
LAD70:  .byte $CC, $33, $0C, $33, $0C, $03, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAD80:  .byte $CC, $03, $C0, $00, $00, $00, $03, $03, $00, $00, $03, $03, $0F, $0F, $00, $00
LAD90:  .byte $CC, $33, $0C, $03, $C0, $C3, $FC, $F3, $00, $00, $F0, $F0, $3C, $3C, $00, $00
LADA0:  .byte $EA, $15, $EA, $15, $EA, $15, $00, $00, $15, $2A, $15, $2A, $15, $2A, $00, $00
LADB0:  .byte $AF, $5F, $BF, $7F, $FF, $FF, $FC, $FC, $50, $A0, $40, $80, $03, $03, $00, $00
LADC0:  .byte $3F, $3F, $3F, $3F, $3F, $3F, $0F, $0F, $00, $00, $00, $00, $30, $30, $00, $00
LADD0:  .byte $A8, $54, $EA, $D5, $FA, $F5, $FA, $F5, $54, $A8, $15, $2A, $05, $0A, $05, $0A
LADE0:  .byte $03, $03, $0F, $0F, $80, $40, $A8, $54, $00, $00, $00, $00, $40, $80, $54, $A8
LADF0:  .byte $C0, $C0, $00, $00, $08, $04, $28, $14, $00, $00, $00, $00, $04, $08, $14, $28
LAE00:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAE10:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAE20:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAE30:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAE40:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAE50:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAE60:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAE70:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAE80:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAE90:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAEA0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAEB0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAEC0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LAED0:  .byte $2A, $15, $02, $01, $00, $00, $00, $00, $15, $2A, $01, $02, $00, $00, $00, $00
LAEE0:  .byte $AA, $55, $AA, $55, $2A, $15, $02, $01, $55, $AA, $55, $AA, $15, $2A, $01, $02
LAEF0:  .byte $A8, $54, $A0, $50, $A8, $54, $AA, $55, $54, $A8, $50, $A0, $54, $A8, $55, $AA
LAF00:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LAF10:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LAF20:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LAF30:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LAF40:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LAF50:  .byte $00, $00, $0C, $03, $00, $03, $00, $00, $FF, $FF, $F0, $F0, $FC, $FC, $FF, $FF
LAF60:  .byte $00, $00, $CC, $33, $CC, $33, $CC, $33, $FF, $FF, $00, $00, $00, $00, $00, $00
LAF70:  .byte $00, $00, $C0, $30, $CC, $33, $CC, $33, $FF, $FF, $0F, $0F, $00, $00, $00, $00
LAF80:  .byte $00, $00, $00, $00, $00, $00, $C0, $30, $FF, $FF, $FF, $FF, $FF, $FF, $0F, $0F
LAF90:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LAFA0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LAFB0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LAFC0:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LAFD0:  .byte $00, $00, $0C, $03, $0C, $00, $3C, $3C, $FF, $FF, $F0, $F0, $F3, $F3, $C3, $C3
LAFE0:  .byte $00, $00, $C0, $03, $CC, $3F, $0C, $33, $FF, $FF, $3C, $3C, $00, $00, $C0, $C0
LAFF0:  .byte $00, $00, $C0, $30, $0C, $30, $0C, $00, $FF, $FF, $0F, $0F, $C3, $C3, $F3, $F3

;----------------------------------------------------------------------------------------------------

TextConvert:
LB000:  LDA #$01                ;Start with a newline count of 1.
LB002:  STA NewLineCount        ;

LB004:  LDX #$00                ;Zero out the text buffer index.

TextConvertLoop:
LB006:  LDA TextBuffer,X        ;
LB009:  TAY                     ;Get the 6-bit text code and use it as an index
LB00A:  LDA TextConvTbl,Y       ;into the table below to find the correct tile
LB00D:  STA TextBuffer,X        ;index for that particular character.
LB010:  INX                     ;

LB011:  CMP #TXT_ONE            ;Is this a one time message?
LB013:  BEQ ChkOneMessage       ;If so branch to see if it has already beed displayed.

LB015:  CMP #TXT_END            ;Is this the end of the message?
LB017:  BEQ EndTextString       ;If so, branch to end the text.

LB019:  CMP #TXT_NEWLINE        ;Is the current character a newline?
LB01B:  BNE TextConvertLoop     ;If not, branch to check the next text byte.

LB01D:  INC NewLineCount        ;Keep track of the number of newlines in this message.
LB01F:  JMP TextConvertLoop     ;($B006)Grap the next 6-bit text code to convert.

EndTextString:
LB022:  LDA ActiveMessage       ;Are we in the middle of a multi part message?
LB024:  BEQ SetTxtPtr           ;If so, branch.

LB026:  LDA NewLineCount        ;Do we have 5 or more newlines in this message?
LB028:  CMP #$05                ;If so, no need to add a newline at the front.
LB02A:  BCS SetTxtPtr           ;

LB02C:  LDX #$7E                ;Prepare to right shift buffer and add newline at front.

TxtShiftRight:
LB02E:  LDA TextBuffer,X        ;
LB031:  STA TextBuffer+1,X      ;Shift the contents of the buffer to the right by 1 byte.
LB034:  DEX                     ;
LB035:  BNE TxtShiftRight       ;

LB037:  LDA TextBuffer          ;
LB03A:  STA TextBuffer+1        ;Add a newline to the front to make the text look nice.
LB03D:  LDA #TXT_NEWLINE        ;
LB03F:  STA TextBuffer          ;

SetTxtPtr:
LB042:  LDA #<TextBuffer        ;
LB044:  STA TextCharPtrLB       ;Point the character pointer to the beginning of the buffer.
LB046:  LDA #>TextBuffer        ;
LB048:  STA TextCharPtrUB       ;

LB04A:  CLC                     ;Clear one time message indicator.
LB04B:  RTS                     ;

ChkOneMessage:
LB04C:  LDA LastTalkedNPC0      ;
LB04E:  CMP LastTalkedNPC1      ;Has player talked to this NPC twice in a row?
LB050:  BNE +                   ;If so, set carry to get their second message.
LB052:  SEC                     ;
LB053:  RTS                     ;

LB054:* LDY #$00                ;Zero out index.

TxtShiftLeft:
LB056:* LDA TextBuffer+1,Y      ;Left shift the text buffer by one byte. This
LB059:  STA TextBuffer,Y        ;gets rid of the one message control byte.
LB05C:  INY                     ;
LB05D:  CMP #$3F                ;Have we reached the end of the buffer contents?
LB05F:  BNE -                   ;If not, branch to shift more bytes.

LB061:  LDX #$00                ;Start at beginning now that one time message control byte removed.
LB063:  JMP TextConvertLoop     ;($B006)Grap the next 6-bit text code to convert.

;----------------------------------------------------------------------------------------------------

;This function does not appear to be used in this Bank. This function is repeated in Bank F.

UncompressText:
LB066:  LDA (TextCharPtr),Y     ;
LB068:  STA TextBuffer,X        ;
LB06B:  INY                     ;
LB06C:  LDA (TextCharPtr),Y     ;
LB06E:  STA TextBuffer+1,X      ;Store the 3 compressed data bytes in the text buffer.
LB071:  INY                     ;
LB072:  LDA (TextCharPtr),Y     ;
LB074:  STA TextBuffer+2,X      ;
LB077:  INY                     ;

LB078:  AND #$3F                ;6 LSBs of 3rd byte are stripped off to form 4th uncompressed byte.
LB07A:  STA TextBuffer+3,X      ;

LB07D:  LDA TextBuffer+1,X      ;
LB080:  ASL TextBuffer+2,X      ;
LB083:  ROL                     ;Combine 2nd byte 4 LSBs and 3rd byte
LB084:  ASL TextBuffer+2,X      ;2 MSBs to form 3rd uncompressed byte.
LB087:  ROL                     ;
LB088:  AND #$3F                ;
LB08A:  STA TextBuffer+2,X      ;

LB08D:  LDA TextBuffer,X        ;
LB090:  ASL TextBuffer+1,X      ;
LB093:  ROL                     ;
LB094:  ASL TextBuffer+1,X      ;
LB097:  ROL                     ;Combine 1st byte 2 LSBs and 2nd byte
LB098:  ASL TextBuffer+1,X      ;4 MSBs to form 2nd uncompressed byte.
LB09B:  ROL                     ;
LB09C:  ASL TextBuffer+1,X      ;
LB09F:  ROL                     ;
LB0A0:  AND #$3F                ;
LB0A2:  STA TextBuffer+1,X      ;

LB0A5:  LDA TextBuffer,X        ;
LB0A8:  LSR                     ;Get 6 MSBs of 1st byte to form 1st uncompressed byte.
LB0A9:  LSR                     ;
LB0AA:  STA TextBuffer,X        ;

LB0AD:  INX                     ;
LB0AE:  INX                     ;
LB0AF:  INX                     ;Increment index to next available buffer slot.
LB0B0:  INX                     ;
LB0B1:  RTS                     ;

;----------------------------------------------------------------------------------------------------

;The table below converts the 6-bit text value into an 8-bit pattern table index.
;There are control characters along with printed text characters. below is a list
;of those control characters and a description of what they do.
;
;NAME - Displays the name of a player's character.
;ENMY - Displays the name of an enemy.
;AMNT - Displays a numerical amount.
;ONE  - A message preceded by this only displays once. When the player talks to
;       the character a second time, a different message will be displayed. The
;       second message appears right below the original message.
;Y/N  - A yes/no dialog box will pop up with the message.
;\n   - New line.
;END  - Indicates the end of the message.
;BRIB - After the message is displayed, the party will gain the bribe command.
;PRAY - After the message is displayed, the party will gain the pray command.
;
;Control characters $F8 and $F9 are not used in the game but there is actual
;code that runs behind them. The code does not appear to do anything useful.
;Control character $F2 has no code to support it and is ignored.

TextConvTbl:
;              A    B    C    D    E    F    G    H    I    J    K    L    M    N    O    P
LB0B2:  .byte $8A, $8B, $8C, $8D, $8E, $8F, $90, $91, $92, $93, $94, $95, $96, $97, $98, $99
;              Q    R    S    T    U    V    W    X    Y    Z    !    ?    .    ,    -    "
LB0C2:  .byte $9A, $9B, $9C, $9D, $9E, $9F, $A0, $A1, $A2, $A3, $7C, $7D, $43, $42, $7B, $05
;              0    1    2    3    4    5    6    7    8    9    +    -    '   SPC   :   SPC
LB0D2:  .byte $38, $39, $3A, $3B, $3C, $3D, $3E, $3F, $40, $41, $01, $02, $04, $00, $03, $00
;             NAME ENMY AMNT AMNT ONE  Y/N  NONE NONE PRAY BRIB NONE SPC  SPC  SPC   \n  END 
LB0E2:  .byte $F3, $F4, $F5, $F5, $F6, $F7, $F8, $F9, $F0, $F1, $F2, $00, $00, $00, $FD, $FF

;----------------------------------------------------------------------------------------------------

;Unused tile patterns from Bank 6.
LB0F2:  .byte $C0, $30, $C0, $00, $C0, $30, $C3, $C3, $0F, $0F, $3F, $3F, $0F, $0F, $00, $00
LB102:  .byte $00, $00, $00, $00, $0C, $03, $FF, $FF, $FF, $FF, $FF, $FF, $F0, $F0, $08, $37
LB112:  .byte $00, $00, $00, $00, $A0, $50, $C4, $C8, $FF, $FF, $FF, $FF, $5F, $AF, $00, $00
LB122:  .byte $0C, $33, $CC, $3F, $CC, $33, $FF, $FF, $C0, $C0, $00, $0C, $00, $00, $3F, $3F
LB132:  .byte $0F, $0F, $C0, $00, $CC, $33, $C0, $C0, $F0, $F0, $3F, $3F, $00, $00, $F0, $F0
LB142:  .byte $00, $00, $0C, $33, $CC, $33, $0F, $0F, $FF, $FF, $C0, $C0, $00, $00, $3C, $3C
LB152:  .byte $00, $00, $C0, $00, $CC, $30, $C0, $C0, $FC, $FC, $3F, $3F, $03, $03, $00, $00
LB162:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $C0, $C0, $C0, $C0, $00, $00
LB172:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $03, $03
LB182:  .byte $03, $03, $03, $03, $00, $00, $FC, $FC, $00, $00, $02, $02, $00, $00, $FF, $FF
LB192:  .byte $FF, $FF, $FF, $FF, $03, $03, $00, $00, $00, $00, $00, $00, $3C, $3C, $FF, $FF
LB1A2:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF
LB1B2:  .byte $EF, $DF, $FF, $FF, $BC, $7C, $2A, $00, $3A, $38, $AA, $00, $EB, $E3, $FC, $FC
LB1C2:  .byte $00, $00, $00, $00, $03, $03, $AB, $03, $FF, $FF, $FF, $FF, $FC, $FC, $FF, $FF
LB1D2:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $FC, $FC
LB1E2:  .byte $FC, $FC, $FC, $FC, $F0, $F0, $03, $03, $03, $03, $03, $03, $0F, $0F, $0C, $30
LB1F2:  .byte $0C, $00, $0C, $30, $C0, $30, $C3, $C3, $F3, $F3, $C3, $C3, $0F, $0F, $0C, $30
LB202:  .byte $00, $30, $00, $30, $0C, $30, $C3, $C3, $CF, $CF, $CF, $CF, $C3, $C3, $A8, $54
LB212:  .byte $2A, $15, $2A, $15, $0A, $05, $57, $AB, $D5, $EA, $D5, $EA, $F5, $FA, $0C, $30
LB222:  .byte $00, $00, $AA, $55, $AA, $55, $C3, $C3, $FF, $FF, $55, $AA, $55, $AA, $00, $00
LB232:  .byte $AA, $55, $A0, $50, $80, $40, $FF, $FF, $55, $AA, $5F, $AF, $7F, $BF, $0C, $30
LB242:  .byte $00, $00, $0C, $03, $0C, $33, $C3, $C3, $FF, $FF, $F0, $F0, $C0, $C0, $CC, $33
LB252:  .byte $0C, $30, $00, $00, $C0, $00, $00, $00, $C0, $C0, $F0, $F0, $30, $30, $00, $00
LB262:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $03, $03, $3F, $3F, $FF, $FF, $00, $00
LB272:  .byte $00, $00, $00, $00, $00, $00, $F0, $F0, $FC, $FC, $FF, $FF, $FF, $FF, $00, $00
LB282:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $C0, $C0, $00, $00
LB292:  .byte $00, $00, $00, $00, $02, $01, $3F, $3F, $FF, $FF, $FF, $FF, $FD, $FE, $FF, $FF
LB2A2:  .byte $3E, $3D, $03, $03, $A0, $50, $02, $00, $C3, $C3, $FE, $FC, $5F, $AF, $FC, $FC
LB2B2:  .byte $F0, $F0, $F0, $F0, $02, $01, $AB, $03, $AF, $8F, $AF, $0F, $FD, $FE, $0F, $0F
LB2C2:  .byte $3F, $3F, $FF, $FF, $FF, $FF, $F0, $F0, $C0, $C0, $00, $00, $00, $00, $FF, $FF
LB2D2:  .byte $F0, $F0, $C0, $C3, $00, $00, $00, $00, $0F, $0F, $3C, $3C, $FF, $FF, $C0, $C3
LB2E2:  .byte $0C, $03, $CC, $33, $0C, $33, $3C, $3C, $F0, $F0, $00, $00, $C0, $C0, $C0, $00
LB2F2:  .byte $00, $00, $0C, $30, $CC, $30, $3F, $3F, $FF, $FF, $C3, $C3, $03, $03, $0C, $03
LB302:  .byte $00, $03, $0C, $03, $0C, $30, $F0, $F0, $FC, $FC, $F0, $F0, $C3, $C3, $0A, $05
LB312:  .byte $0A, $05, $2A, $15, $2A, $15, $F5, $FA, $F5, $FA, $D5, $EA, $D5, $EA, $A8, $54
LB322:  .byte $A8, $54, $A8, $54, $AA, $55, $57, $AB, $57, $AB, $57, $AB, $55, $AA, $00, $00
LB332:  .byte $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $0C, $33
LB342:  .byte $0C, $03, $00, $03, $02, $01, $C0, $C0, $F0, $F0, $FC, $FC, $FD, $FE, $C0, $00
LB352:  .byte $C0, $00, $C0, $00, $A0, $50, $33, $33, $3F, $3F, $3F, $3F, $5F, $AF, $0A, $05
LB362:  .byte $2A, $15, $2A, $15, $AA, $55, $F5, $FA, $D5, $EA, $D5, $EA, $55, $AA, $A8, $54
LB372:  .byte $AA, $55, $AA, $55, $AA, $55, $57, $AB, $55, $AA, $55, $AA, $55, $AA, $00, $00
LB382:  .byte $00, $00, $82, $41, $80, $40, $C3, $C3, $FF, $FF, $7D, $BE, $7F, $BF, $2A, $15
LB392:  .byte $AA, $55, $AF, $5F, $BF, $7F, $D5, $EA, $55, $AA, $50, $A0, $40, $80, $A8, $54
LB3A2:  .byte $E8, $D7, $FE, $FD, $FE, $FD, $57, $AB, $14, $28, $01, $02, $01, $02, $3F, $33
LB3B2:  .byte $CF, $33, $FC, $33, $C0, $00, $E0, $C0, $00, $00, $20, $00, $3F, $3F, $BC, $7C
LB3C2:  .byte $B0, $70, $00, $03, $0C, $03, $43, $83, $4F, $8F, $FC, $FC, $F0, $F0, $0C, $03
LB3D2:  .byte $CC, $33, $CC, $33, $CC, $30, $F0, $F0, $00, $00, $00, $00, $03, $03, $0C, $03
LB3E2:  .byte $C0, $03, $CC, $03, $0C, $03, $F0, $F0, $3C, $3C, $30, $30, $F0, $F0, $CC, $30
LB3F2:  .byte $C0, $30, $C0, $00, $00, $00, $03, $03, $0F, $0F, $3F, $3F, $FF, $FF, $00, $30
LB402:  .byte $0C, $33, $0C, $33, $0C, $03, $CF, $CF, $C0, $C0, $C0, $C0, $F0, $F0, $0A, $05
LB412:  .byte $00, $00, $C0, $00, $C0, $33, $F5, $FA, $FF, $FF, $3F, $3F, $0C, $0C, $AA, $55
LB422:  .byte $AA, $55, $0A, $05, $C0, $00, $55, $AA, $55, $AA, $F5, $FA, $3F, $3F, $80, $40
LB432:  .byte $A0, $50, $AA, $55, $AA, $55, $7F, $BF, $5F, $AF, $55, $AA, $55, $AA, $0A, $05
LB442:  .byte $2A, $15, $AA, $55, $AA, $55, $F5, $FA, $D5, $EA, $55, $AA, $55, $AA, $AA, $55
LB452:  .byte $AA, $55, $AA, $55, $AA, $55, $55, $AA, $55, $AA, $55, $AA, $55, $AA, $AA, $55
LB462:  .byte $AA, $55, $AA, $55, $AA, $55, $55, $AA, $55, $AA, $55, $AA, $55, $AA, $AA, $55
LB472:  .byte $A8, $54, $A8, $54, $AA, $55, $55, $AA, $57, $AB, $57, $AB, $55, $AA, $00, $00
LB482:  .byte $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $BF, $7F
LB492:  .byte $3F, $3F, $3F, $3F, $FF, $FF, $40, $80, $C0, $C0, $C0, $C0, $00, $00, $FF, $FF
LB4A2:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $80, $40
LB4B2:  .byte $A0, $50, $E8, $D7, $A8, $57, $7F, $BF, $5F, $AF, $14, $28, $54, $A8, $0C, $33
LB4C2:  .byte $C0, $30, $C3, $03, $CE, $0D, $C0, $C0, $0F, $0F, $3E, $3C, $33, $33, $00, $00
LB4D2:  .byte $0C, $33, $CC, $33, $CC, $30, $FF, $FF, $C0, $C0, $00, $00, $03, $03, $0C, $33
LB4E2:  .byte $CC, $33, $CC, $33, $CC, $33, $C0, $C0, $00, $00, $00, $00, $00, $00, $00, $00
LB4F2:  .byte $C0, $00, $C0, $30, $C0, $30, $FF, $FF, $3F, $3F, $0F, $0F, $0F, $0F, $0C, $03
LB502:  .byte $0C, $33, $0C, $33, $0C, $33, $F0, $F0, $C0, $C0, $C0, $C0, $C0, $C0, $CC, $33
LB512:  .byte $CC, $33, $CC, $33, $0C, $03, $00, $00, $00, $00, $00, $00, $F0, $F0, $C0, $30
LB522:  .byte $CC, $33, $CC, $33, $CC, $33, $0F, $0F, $00, $00, $00, $00, $00, $00, $0A, $05
LB532:  .byte $00, $00, $CC, $30, $CC, $F3, $F5, $FA, $FF, $FF, $03, $03, $40, $40, $80, $40
LB542:  .byte $00, $00, $00, $00, $00, $00, $7F, $BF, $FF, $FF, $FF, $FF, $FF, $FF, $AA, $55
LB552:  .byte $0A, $05, $00, $00, $00, $00, $55, $AA, $F5, $FA, $FF, $FF, $FF, $FF, $AA, $55
LB562:  .byte $AA, $55, $AA, $55, $AF, $5F, $55, $AA, $55, $AA, $55, $AA, $50, $A0, $AA, $55
LB572:  .byte $AF, $5F, $FF, $FF, $FF, $FF, $55, $AA, $50, $A0, $00, $00, $00, $00, $BF, $7F
LB582:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $40, $80, $00, $00, $00, $00, $00, $00, $FF, $FF
LB592:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF
LB5A2:  .byte $FE, $FD, $FE, $FD, $FA, $F5, $00, $00, $01, $02, $01, $02, $05, $0A, $A8, $57
LB5B2:  .byte $A0, $50, $80, $40, $00, $03, $54, $A8, $5F, $AF, $7F, $BF, $FC, $FC, $0F, $03
LB5C2:  .byte $0C, $33, $0C, $03, $CC, $03, $F2, $F0, $C0, $C0, $F0, $F0, $30, $30, $0C, $00
LB5D2:  .byte $0C, $33, $0C, $33, $0F, $33, $F3, $F3, $C0, $C0, $C0, $C0, $C3, $C3, $0C, $33
LB5E2:  .byte $0C, $03, $00, $00, $00, $00, $C0, $C0, $F0, $F0, $3F, $3F, $03, $03, $CC, $30
LB5F2:  .byte $C0, $30, $F0, $30, $EC, $10, $03, $03, $0F, $0F, $2F, $0F, $33, $33, $0C, $30
LB602:  .byte $0C, $30, $0C, $30, $0C, $30, $C3, $C3, $C3, $C3, $C3, $C3, $C3, $C3, $00, $00
LB612:  .byte $CC, $30, $0C, $33, $0C, $03, $FF, $FF, $03, $03, $C0, $C0, $F0, $F0, $0C, $33
LB622:  .byte $00, $03, $C0, $00, $CC, $33, $C0, $C0, $FC, $FC, $3F, $3F, $00, $00, $CC, $F3
LB632:  .byte $CC, $30, $00, $00, $00, $00, $80, $80, $03, $03, $FF, $FF, $FF, $FF, $00, $00
LB642:  .byte $00, $00, $0C, $03, $CE, $31, $FF, $FF, $FF, $FF, $F0, $F0, $01, $02, $02, $01
LB652:  .byte $AA, $55, $AB, $57, $AF, $5F, $FD, $FE, $55, $AA, $54, $A8, $50, $A0, $BF, $7F
LB662:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $40, $80, $00, $00, $00, $00, $00, $00, $FF, $FF
LB672:  .byte $FF, $FF, $FE, $FD, $FA, $F5, $00, $00, $00, $00, $01, $02, $05, $0A, $FF, $FF
LB682:  .byte $AB, $57, $AA, $55, $AA, $55, $00, $00, $54, $A8, $55, $AA, $55, $AA, $FF, $FF
LB692:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $F8, $F4
LB6A2:  .byte $F8, $F4, $F0, $F0, $F2, $F1, $07, $0B, $07, $0B, $0F, $0F, $0D, $0E, $0C, $03
LB6B2:  .byte $0C, $33, $AC, $53, $A8, $54, $F0, $F0, $C0, $C0, $50, $A0, $57, $AB, $CC, $03
LB6C2:  .byte $CC, $03, $00, $03, $00, $33, $30, $30, $30, $30, $FC, $FC, $CC, $CC, $00, $00
LB6D2:  .byte $C0, $00, $C0, $30, $C0, $30, $F0, $F0, $3C, $3C, $0C, $0C, $0F, $0F, $00, $00
LB6E2:  .byte $00, $00, $03, $03, $0F, $0F, $03, $03, $00, $00, $00, $00, $C0, $C0, $30, $30
LB6F2:  .byte $00, $00, $00, $00, $C0, $C0, $EF, $CF, $FF, $FF, $FF, $FF, $3F, $3F, $0C, $33
LB702:  .byte $0C, $03, $0C, $03, $0C, $33, $C0, $C0, $F0, $F0, $F0, $F0, $C0, $C0, $00, $03
LB712:  .byte $00, $00, $CC, $30, $CC, $33, $FC, $FC, $FF, $FF, $03, $03, $00, $00, $CC, $33
LB722:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $FC, $FF, $FF, $FF, $FF, $FF, $CC, $33
LB732:  .byte $CC, $33, $0C, $03, $0C, $00, $00, $00, $00, $00, $C0, $F0, $F3, $F3, $CA, $35
LB742:  .byte $CA, $35, $CE, $31, $CC, $33, $05, $0A, $05, $0A, $01, $02, $00, $00, $BF, $7F
LB752:  .byte $BF, $7F, $AF, $5F, $AB, $57, $40, $80, $40, $80, $50, $A0, $54, $A8, $FF, $FF
LB762:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $FA, $F5
LB772:  .byte $EA, $D5, $EA, $D5, $FA, $F5, $05, $0A, $15, $2A, $15, $2A, $05, $0A, $AB, $57
LB782:  .byte $AB, $57, $AF, $5F, $AF, $5F, $54, $A8, $54, $A8, $50, $A0, $50, $A0, $FF, $FF
LB792:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00, $FA, $F5
LB7A2:  .byte $FE, $FD, $FF, $FF, $FF, $FF, $05, $0A, $01, $02, $00, $00, $00, $00, $A8, $57
LB7B2:  .byte $AA, $55, $AA, $55, $A8, $54, $54, $A8, $55, $AA, $55, $AA, $57, $AB, $C0, $33
LB7C2:  .byte $C0, $03, $0C, $03, $0F, $33, $0C, $0C, $3C, $3C, $F0, $F0, $C1, $C1, $CC, $33
LB7D2:  .byte $CC, $33, $CC, $30, $C0, $30, $00, $00, $00, $00, $03, $03, $0F, $0F, $0F, $0F
LB7E2:  .byte $0E, $0D, $2A, $15, $28, $14, $F0, $F0, $F1, $F2, $D5, $EA, $D7, $EB, $80, $40
LB7F2:  .byte $80, $40, $0C, $00, $0C, $30, $7F, $BF, $7F, $BF, $F3, $F3, $C3, $C3

;----------------------------------------------------------------------------------------------------

ShowIntroText:
LB800:  LDA #MUS_NONE+INIT      ;Prepare to silence music.
LB802:  STA InitNewMusic        ;
LB804:  JSR ResetNameTable1     ;($B947)Reset nametable offsets and select nametable 0.

LB807:  LDX #$00                ;Prep palette data load.
LB809:  JSR getPalPointers      ;($B92B)Load sprite and background palette pointers.

LB80C:  JSR IntroInitPPU1       ;($BA05)Initialize the PPU.

LB80F:  LDA #$10                ;Wait for 16 frames.
LB811:  JSR WaitForAFrames      ;($B923)Wait a certain number of frames before continuing.

LB814:  LDA #<IntroTextData     ;
LB816:  STA TXTSrcPtrLB         ;Set a pointer to the intro text data.
LB818:  LDA #>IntroTextData     ;
LB81A:  STA TXTSrcPtrUB         ;

IntroTextLoop:
LB81C:  LDA #$1E                ;Keep screen blank for 30 frames.
LB81E:  JSR WaitForAFrames      ;($B923)Wait a certain number of frames before continuing.

LB821:  LDA TXTSrcPtrLB         ;
LB823:  PHA                     ;Save pointer on stack before clearing out the PPU again.
LB824:  LDA TXTSrcPtrUB         ;
LB826:  PHA                     ;

LB827:  JSR IntroInitPPU1       ;($BA05)Initialize the PPU.

LB82A:  PLA                     ;
LB82B:  STA TXTSrcPtrUB         ;Restore pointer from the stack.
LB82D:  PLA                     ;
LB82E:  STA TXTSrcPtrLB         ;

GetIntroTextString:
LB830:  LDY #$00                ;
LB832:  LDA (TXTSrcPtr),Y       ;Get screen X position of text to display.
LB834:  STA TXTXPos             ;
LB836:  INY                     ;

LB837:  LDA (TXTSrcPtr),Y       ;
LB839:  STA TXTYPos             ;Get screen Y position of text to display.
LB83B:  INY                     ;

LB83C:  LDX #$00                ;Prepare to write to the text buffer.

LB83E:* LDA (TXTSrcPtr),Y       ;
LB840:  STA TextBuffer,X        ;
LB843:  INY                     ;
LB844:  INX                     ;Copy text into the buffer until the end marker is reached.
LB845:  CMP #TXT_END            ;
LB847:  BEQ +                   ;
LB849:  JMP -                   ;

LB84C:* LDA #$01                ;
LB84E:  STA TXTClrRows          ;Clear a single row for the text string.
LB850:  TXA                     ;
LB851:  STA TXTClrCols          ;Clear a number of cols that match the length of the text string.

LB853:  TYA                     ;
LB854:  CLC                     ;
LB855:  ADC TXTSrcPtrLB         ;
LB857:  STA TXTSrcPtrLB         ;Update the text pointer to point to the next block of intro text.
LB859:  LDA TXTSrcPtrUB         ;
LB85B:  ADC #$00                ;
LB85D:  STA TXTSrcPtrUB         ;

LB85F:  LDA TXTYPos             ;Is Y=31? This represents the end of the text
LB861:  CMP #$1E                ;string for the current display.
LB863:  BCS GotTextStrings      ;If so, branch to start fading in.

LB865:  LDA TXTSrcPtrLB         ;
LB867:  PHA                     ;Save pointer to stack before prepping to show text.
LB868:  LDA TXTSrcPtrUB         ;
LB86A:  PHA                     ;

LB86B:  LDA #TXT_DBL_SPACE      ;Indicate buffer already filled. Double space contents.
LB86D:  STA TextIndex           ;
LB86F:  JSR DisplayText1        ;($C003)Display text on the screen.

LB872:  PLA                     ;
LB873:  STA TXTSrcPtrUB         ;Restore pointer from stack after done loading text.
LB875:  PLA                     ;
LB876:  STA TXTSrcPtrLB         ;

LB878:  JMP GetIntroTextString  ;($B830)Get the next intro text string.

GotTextStrings:
LB87B:  PHA                     ;Save A on the stack.

LB87C:  LDX #$00                ;Start at the beginning of the palette pointer table.
LB87E:* JSR getPalPointers      ;($B92B)Load sprite and background palette pointers.

LB881:  LDA #$01                ;Wait for 1 frame.
LB883:  JSR WaitForAFrames      ;($B923)Wait a certain number of frames before continuing.

LB886:  CPX #$0A                ;Is the text done fading in?
LB888:  BNE -                   ;If not, branch back to keep fading in.

LB88A:  LDA #$5A                ;Display text for 90 frames.
LB88C:  JSR WaitForAFrames      ;($B923)Wait a certain number of frames before continuing.

LB88F:* JSR getPalPointers      ;($B92B)Load sprite and background palette pointers.

LB892:  LDA #$02                ;Wait for 2 frames.
LB894:  JSR WaitForAFrames      ;($B923)Wait a certain number of frames before continuing.

LB897:  CPX #$12                ;Is the text done fading out?
LB899:  BNE -                   ;If not, branch back to keep fading out.

LB89B:  PLA                     ;Did we finish getting all the text string to display?
LB89C:  CMP #$1E                ;If not, branch to get more strings.
LB89E:  BNE +                   ;
LB8A0:  JMP IntroTextLoop       ;($B81C)Show the intro text.

LB8A3:* LDA #>IntroGFXTiles     ;
LB8A5:  STA PPUSrcPtrUB         ;Get a pointer to the intro GFX tiles.
LB8A7:  LDA #<IntroGFXTiles     ;
LB8A9:  STA PPUSrcPtrLB         ;

LB8AB:  STA PPUDstPtrLB         ;Pattern table 1, lower address byte.
LB8AD:  STA PPUByteCntLB        ;Byte count to load, lower byte.

LB8AF:  LDA #PPU_PT1_UB         ;Pattern table 1, upper address byte.
LB8B1:  STA PPUDstPtrUB         ;

LB8B3:  LDA #$08                ;Prepare to load the first half of pattern table 1 with intro GFX.
LB8B5:  STA PPUByteCntUB        ;

LB8B7:  JSR LoadPPU1            ;($C006)Load values into the PPU.

LB8BA:  LDA #>IntroGFXNT        ;Pointer to intro GFX for name table 0 load.
LB8BC:  STA PPUSrcPtrUB         ;

LB8BE:  LDA #PPU_NT0_UB         ;PPU address to name table 0.
LB8C0:  STA PPUDstPtrUB         ;

LB8C2:  LDA #$04                ;Prepare to load 1K of data into PPU(fill NT0).
LB8C4:  STA PPUByteCntUB        ;
LB8C6:  JSR LoadPPU1            ;($C006)Load values into the PPU.

LB8C9:  LDA #$0A                ;Wait for 10 frames.
LB8CB:  JSR WaitForAFrames      ;($B923)Wait a certain number of frames before continuing.

LB8CE:  LDX #$12                ;Load first GFX fade-in palette.
LB8D0:  JSR getPalPointers      ;($B92B)Load sprite and background palette pointers.

LB8D3:  LDA #$04                ;Wait for 4 frames.
LB8D5:  JSR WaitForAFrames      ;($B923)Wait a certain number of frames before continuing.

LB8D8:  LDX #$14                ;Load second GFX fade-in palette.
LB8DA:  JSR getPalPointers      ;($B92B)Load sprite and background palette pointers.

LB8DD:  LDA #$04                ;Wait for 4 frames.
LB8DF:  JSR WaitForAFrames      ;($B923)Wait a certain number of frames before continuing.

LB8E2:  LDX #$16                ;Load third GFX fade-in palette.
LB8E4:  JSR getPalPointers      ;($B92B)Load sprite and background palette pointers.

LB8E7:  LDA #$04                ;Wait for 4 frames.
LB8E9:  JSR WaitForAFrames      ;($B923)Wait a certain number of frames before continuing.

LB8EC:  LDX #$18                ;Load fourth GFX fade-in palette.
LB8EE:  JSR getPalPointers      ;($B92B)Load sprite and background palette pointers.

LB8F1:  LDA #$1E                ;Wait for 30 frames.
LB8F3:  JSR WaitForAFrames      ;($B923)Wait a certain number of frames before continuing.

LB8F6:  LDA #MUS_DUNGEON+INIT   ;Start the dungeon music.
LB8F8:  STA InitNewMusic        ;

LB8FA:  LDX #$00                ;
LB8FC:* LDA PushStartText,X     ;
LB8FF:  STA TextBuffer,X        ;Copy all 16 bytes of the PUSH START text into the buffer.
LB902:  INX                     ;
LB903:  CPX #$11                ;
LB905:  BNE -                   ;

LB907:  LDA #$0A                ;
LB909:  STA TXTXPos             ;Set X,Y position of text to 10,24.
LB90B:  LDA #$18                ;
LB90D:  STA TXTYPos             ;

LB90F:  LDA #$0C                ;
LB911:  STA TXTClrCols          ;Clear 3 rows and 12 columns while showing text.
LB913:  LDA #$03                ;
LB915:  STA TXTClrRows          ;

LB917:  LDA #TXT_SNGL_SPACE     ;Indicate buffer already filled. Single space contents.
LB919:  STA TextIndex           ;
LB91B:  JSR DisplayText1        ;($C003)Display text on the screen.

LB91E:  LDA #SCREEN_ON          ;
LB920:  STA CurPPUConfig1       ;Turn the screen on.
LB922:  RTS                     ;

;----------------------------------------------------------------------------------------------------

WaitForAFrames:
LB923:  CLC                     ;
LB924:  ADC Increment0          ;Add the frame increment to A.
LB926:* CMP Increment0          ;
LB928:  BNE -                   ;Wait a number of frames equal to A before continuing.
LB92A:  RTS                     ;

;----------------------------------------------------------------------------------------------------

getPalPointers:
LB92B:  LDA IntroBkPalPtrTbl,X  ;
LB92E:  STA GenPtr29LB          ;
LB930:  INX                     ;Get pointer to background palette data.
LB931:  LDA IntroBkPalPtrTbl,X  ;
LB934:  STA GenPtr29UB          ;
LB936:  INX                     ;

LB937:  LDA #<IntroSprPalData   ;
LB939:  STA GenPtr2DLB          ;Get pointer to sprite palette data.
LB93B:  LDA #>IntroSprPalData   ;
LB93D:  STA GenPtr2DUB          ;

LB93F:  TXA                     ;Save X on the stack.
LB940:  PHA                     ;

LB941:  JSR GetPalData          ;($B960)Write palette data to PPU buffer.

LB944:  PLA                     ;
LB945:  TAX                     ;Restore X from the stack.
LB946:  RTS                     ;

;----------------------------------------------------------------------------------------------------

ResetNameTable1:
LB947:  LDA #$00                ;
LB949:  STA NTXPosLB            ;
LB94B:  STA NTXPosUB            ;
LB94D:  STA NTYPosLB            ;
LB94F:  STA NTYPosUB            ;
LB951:  STA NTXPosLB16          ;Reset all nametable offset values and select nametable 0;
LB953:  STA NTXPosUB16          ;
LB955:  STA NTYPosLB16          ;
LB957:  STA NTYPosUB16          ;
LB959:  LDA CurPPUConfig0       ;
LB95B:  AND #$FC                ;
LB95D:  STA CurPPUConfig0       ;
LB95F:  RTS                     ;

;----------------------------------------------------------------------------------------------------

GetPalData:
LB960:  LDY #$00                ;
LB962:  LDX #$00                ;
LB964:* LDA (GenPtr29),Y        ;
LB966:  STA PaletteBuffer,X     ;Load 16 bytes of palette data into buffer.
LB969:  INY                     ;
LB96A:  INX                     ;
LB96B:  CPY #$10                ;
LB96D:  BNE -                   ;

LB96F:  LDY #$00                ;
LB971:* LDA (GenPtr2D),Y        ;
LB973:  STA PaletteBuffer,X     ;
LB976:  INY                     ;Load another 16 bytes of palette data into buffer.
LB977:  INX                     ;
LB978:  CPY #$10                ;
LB97A:  BNE -                   ;

LB97C:  LDA #$20                ;Buffer has 32 bytes of palette data in it.
LB97E:  JSR SetPPUBufNewSize    ;($B9C0)Wait for PPU buffer to be able to accomodate new data.

LB981:  LDA #PPU_PAL_UB         ;
LB983:  STA PPUBufBase,X        ;
LB986:  INX                     ;PPU target address is $3F00(palettes).
LB987:  LDA #PPU_PAL_LB         ;
LB989:  STA PPUBufBase,X        ;

LB98C:  LDY #$00                ;
LB98E:* LDA (GenPtr29),Y        ;
LB990:  INX                     ;
LB991:  STA PPUBufBase,X        ;Copy 16 bytes of background palette data into PPU buffer.
LB994:  INY                     ;
LB995:  CPY #$10                ;
LB997:  BNE -                   ;

LB999:  LDY #$00                ;
LB99B:* LDA (GenPtr2D),Y        ;
LB99D:  INX                     ;
LB99E:  STA PPUBufBase,X        ;Copy 16 bytes of sprite palette data into PPU buffer.
LB9A1:  INY                     ;
LB9A2:  CPY #$10                ;
LB9A4:  BNE -                   ;

LB9A6:  LDA #$01                ;Prepare to write a single byte to the PPU.
LB9A8:  JSR SetPPUBufNewSize    ;($B9C0)Wait for PPU buffer to be able to accomodate new data.

LB9AB:  LDA #PPU_PT0_UB         ;
LB9AD:  STA PPUBufBase,X        ;
LB9B0:  INX                     ;PPU target address is $0000(pattern tables).
LB9B1:  LDA #PPU_PT0_LB         ;
LB9B3:  STA PPUBufBase,X        ;
LB9B6:  INX                     ;

LB9B7:  LDA #$00                ;Write a single blank byte to the PPU buffer.
LB9B9:  STA PPUBufBase,X        ;

LB9BC:  JSR SetPPUUpdate        ;($B9FB)Check if PPU update flag needs to be set.
LB9BF:  RTS                     ;

;----------------------------------------------------------------------------------------------------

SetPPUBufNewSize:
LB9C0:  PHA                     ;Save A on the stack.
LB9C1:  CLC                     ;
LB9C2:  ADC PPUBufLength        ;Update the buffer length by adding A to it.
LB9C5:  BCS WaitForPPUUpdate1   ;Branch if buffer length has exceeded 256 bytes.

LB9C7:  TAX                     ;
LB9C8:  LDA DisSpriteAnim       ;Are animations and NPC movements disabled?
LB9CA:  ORA DisNPCMovement      ;If so, branch. Buffer might be big.
LB9CC:  BEQ ChkBufLen20         ;

LB9CE:  TXA                     ;Is the PPU buffer currently over 96 bytes in length?
LB9CF:  CMP #$60                ;If so, wait for the buffer to be emptied.
LB9D1:  BCC UpdatePPUBufLen1    ;

LB9D3:  JMP WaitForPPUUpdate1   ;($B9DB)Wait for the next PPU update to complete.

ChkBufLen20:
LB9D6:  TXA                     ;Is the buffer under 32 bytes of data?
LB9D7:  CMP #$20                ;If so, branch to update buffer length.
LB9D9:  BCC UpdatePPUBufLen1    ;

WaitForPPUUpdate1:
LB9DB:  LDA #$01                ;Indicate the PPU has waiting data.
LB9DD:  STA UpdatePPU           ;
LB9DF:* LDA UpdatePPU           ;Has the PPU been updated with the new data?
LB9E1:  BNE -                   ;If not, branch to wait.

UpdatePPUBufLen1:
LB9E3:  LDA #$00                ;Clear PPU update flag.
LB9E5:  STA UpdatePPU           ;

LB9E7:  LDX PPUBufLength        ;Set the index to the next available spot in the PPU buffer.
LB9EA:  INX                     ;

LB9EB:  CLC                     ;
LB9EC:  PLA                     ;
LB9ED:  ADC #$02                ;Set the PPU string length. Add 2 for the PPU destination address.
LB9EF:  STA PPUBufBase,X        ;
LB9F2:  INX                     ;

LB9F3:  SEC                     ;
LB9F4:  ADC PPUBufLength        ;Add thei PPU string length to the total PPU buffer length.
LB9F7:  STA PPUBufLength        ;
LB9FA:  RTS                     ;

;----------------------------------------------------------------------------------------------------

SetPPUUpdate:
LB9FB:  LDA PPUBufLength        ;
LB9FE:  BEQ +                   ;Is there data in the PPU buffer?
LBA00:  LDA #$01                ;If so, set the flag indicating the PPU needs to be updated.
LBA02:  STA UpdatePPU           ;
LBA04:* RTS                     ;

;----------------------------------------------------------------------------------------------------

IntroInitPPU1:
LBA05:  LDA #SCREEN_OFF         ;Turn off the screen.
LBA07:  STA CurPPUConfig1       ;

LBA09:  LDA #$D4                ;Prepare to hide sprites 53 through 63.
LBA0B:  STA HideUprSprites      ;

LBA0D:  LDY #$00                ;Prepare to initialize all sprites.
LBA0F:  LDA #$F0                ;

LBA11:* STA SpriteBuffer,Y      ;
LBA14:  INY                     ;
LBA15:  INY                     ;Initialize all sprites in the buffer.
LBA16:  INY                     ;
LBA17:  INY                     ;
LBA18:  BNE -                   ;

LBA1A:  LDY #$00                ;Prepare to zero out the GFX blocks buffer.
LBA1C:  LDA #$00                ;

LBA1E:* STA BlocksBuffer,Y      ;
LBA21:  INY                     ;Zero out the GFX blocks buffer.
LBA22:  BNE -                   ;

LBA24:  LDA #>BlocksBuffer      ;
LBA26:  STA GenPtr29UB          ;Set pointer to the source of PPU data.
LBA28:  LDA #<BlocksBuffer      ;
LBA2A:  STA GenPtr29LB          ;

LBA2C:  LDA #PPU_NT0_UB         ;
LBA2E:  STA GenPtr2BUB          ;Set pointer to name table 0 PPU destination.
LBA30:  LDA #PPU_NT0_LB         ;
LBA32:  STA GenPtr2BLB          ;

LBA34:  LDA #$01                ;
LBA36:  STA GenWord2DUB         ;Prepare to load 256 bytes of data into the PPU.
LBA38:  LDA #$00                ;
LBA3A:  STA GenWord2DLB         ;

LBA3C:* JSR LoadPPU1            ;($C006)Load values into the PPU.

LBA3F:  INC GenPtr2BUB          ;
LBA41:  LDA GenPtr2BUB          ;Has all the data been loaded into the PPU?
LBA43:  CMP #PPU_NT1_UB         ;If not, branch to load some more.
LBA45:  BNE -                   ;

LBA47:  LDY #$00                ;Prepare to fill attribute table 0 with $55.
LBA49:  LDA #$55                ;

LBA4B:* STA BlocksBuffer,Y      ;
LBA4E:  INY                     ;Load 64 bytes into the blocks buffer.
LBA4F:  CPY #$40                ;
LBA51:  BNE -                   ;

LBA53:  LDA #>BlocksBuffer      ;
LBA55:  STA GenPtr29UB          ;Set pointer to the source of PPU data.
LBA57:  LDA #<BlocksBuffer      ;
LBA59:  STA GenPtr29LB          ;

LBA5B:  LDA #PPU_AT0_UB         ;
LBA5D:  STA GenPtr2BUB          ;Set pointer to attribute table 0 PPU destination.
LBA5F:  LDA #PPU_AT0_LB         ;
LBA61:  STA GenPtr2BLB          ;

LBA63:  LDA #$00                ;
LBA65:  STA GenWord2DUB         ;Prepare to load 64 bytes of data into the PPU.
LBA67:  LDA #$40                ;
LBA69:  STA GenWord2DLB         ;

LBA6B:  JSR LoadPPU1            ;($C006)Load values into the PPU.

LBA6E:  LDA #SCREEN_ON          ;
LBA70:  STA CurPPUConfig1       ;Turn on the display.
LBA72:  RTS                     ;

;----------------------------------------------------------------------------------------------------

IntroBkPalPtrTbl:
LBA73:  .word IntroTxtPal1, IntroTxtPal2, IntroTxtPal3, IntroTxtPal4
LBA7B:  .word IntroTxtPal5, IntroTxtPal4, IntroTxtPal3, IntroTxtPal2
LBA83:  .word IntroTxtPal1, IntroGFXPal1, IntroGFXPal2, IntroGFXPal3
LBA8B:  .word IntroGFXPal4

;----------------------------------------------------------------------------------------------------

;The following palettes fade the intro text in and out on the screen.

IntroTxtPal1:
LBA8D:  .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

IntroTxtPal2:
LBA9D:  .byte $0F, $00, $0F, $0F, $0F, $00, $0F, $0F, $0F, $00, $0F, $0F, $0F, $00, $0F, $0F

IntroTxtPal3:
LBAAD:  .byte $0F, $14, $0F, $0F, $0F, $14, $0F, $0F, $0F, $14, $0F, $0F, $0F, $14, $0F, $0F

IntroTxtPal4:
LBABD:  .byte $0F, $22, $0F, $0F, $0F, $22, $0F, $0F, $0F, $22, $0F, $0F, $0F, $22, $0F, $0F

IntroTxtPal5:
LBACD:  .byte $0F, $30, $0F, $0F, $0F, $30, $0F, $0F, $0F, $30, $0F, $0F, $0F, $30, $0F, $0F

;----------------------------------------------------------------------------------------------------

;The following palettes fade the intro graphics in and out on the screen.

IntroGFXPal1:
LBADD:  .byte $2F, $01, $01, $0C, $2F, $01, $01, $01, $2F, $01, $03, $01, $2F, $02, $05, $00

IntroGFXPal2:
LBAED:  .byte $2F, $01, $11, $1C, $2F, $01, $11, $01, $2F, $11, $03, $01, $2F, $12, $05, $00

IntroGFXPal3:
LBAFD:  .byte $2F, $01, $21, $1C, $2F, $01, $11, $11, $2F, $11, $13, $01, $2F, $12, $15, $00

IntroGFXPal4:
LBB0D:  .byte $2F, $01, $31, $2C, $2F, $01, $21, $11, $2F, $21, $13, $01, $2F, $22, $15, $00

;----------------------------------------------------------------------------------------------------

IntroSprPalData:
LBB1D:  .byte $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F

;----------------------------------------------------------------------------------------------------

IntroTextData:
LBB2D:  .byte $08, $0A ;X=8, Y=10.
;              O    R    I    G    I    N    A    L    _    V    E    R    S    I    O    N
LBB2F:  .byte $98, $9B, $92, $90, $92, $97, $8A, $95, $00, $9F, $8E, $9B, $9C, $92, $98, $97
;             END
LBB3F:  .byte $FF

LBB40:  .byte $0B, $0E ;X=11, Y=14.
;              O    F    _    U    L    T    I    M    A   END
LBB42:  .byte $98, $8F, $00, $9E, $95, $9D, $92, $96, $8A, $FF

LBB4C:  .byte $03, $12 ;X=3, Y=18.
;             CPY   1    9    8    3    _    O    R    I    G    I    N    _    S    Y    S
LBB4E:  .byte $88, $39, $41, $40, $3B, $00, $98, $9B, $92, $90, $92, $97, $00, $9C, $A2, $9C
;              T    E    M    S    _    I    N    C    .   END
LBB5E:  .byte $9D, $8E, $96, $9C, $00, $92, $97, $8C, $43, $FF

LBB68:  .byte $00, $1E, $FF ;X=0, Y=30.

LBB6B:  .byte $09, $0A ;X=9, Y=10.
;              N    E    S    _    _    V    E    R    S    I    O    N   END
LBB6D:  .byte $97, $8E, $9C, $00, $00, $9F, $8E, $9B, $9C, $92, $98, $97, $FF

LBB7A:  .byte $0B, $0E ;X=11, Y=14.
;              O    F    _    U    L    T    I    M    A   END
LBB7C:  .byte $98, $8F, $00, $9E, $95, $9D, $92, $96, $8A, $FF

LBB86:  .byte $04, $12 ;X=4, Y=18.
;             CPY   1    9    8    8    _    P    O    N    Y    C    A    N    Y    O    N
LBB88:  .byte $88, $39, $41, $40, $40, $00, $99, $98, $97, $A2, $8C, $8A, $97, $A2, $98, $97
;              _    I    N    C    .   END
LBB98:  .byte $00, $92, $97, $8C, $43, $FF

LBB9E:  .byte $00, $1E, $FF ;X=0, Y=30.

LBBA1:  .byte $0B, $0C ;X=11, Y=12.
;              P    R    O    D    U    C    E    D   END
LBBA3:  .byte $99, $9B, $98, $8D, $9E, $8C, $8E, $8D, $FF

LBBAC:  .byte $0E, $0E ;X=14, Y=14.
;            B    Y    _   END
LBBAE:  .byte $8B, $A2, $00, $FF

LBBB2:  .byte $07, $10 ;X=7, Y=16.
;              N    E    W    T    O    P    I    A    _    P    L    A    N    N    I    N
LBBB4:  .byte $97, $8E, $A0, $9D, $98, $99, $92, $8A, $00, $99, $95, $8A, $97, $97, $92, $97
;              G   END
LBBC4:  .byte $90, $FF

LBBC6:  .byte $00, $1E, $FF ;X=0, Y=30.

LBBC9:  .byte $0B, $0C ;X=11, Y=12.
;              L    I    C    E    N    C    E    D   END
LBBCB:  .byte $95, $92, $8C, $8E, $97, $8C, $8E, $8D, $FF

LBBD4:  .byte $0E, $0E ;X=14, Y=14.
;              B    Y    _   END
LBBD6:  .byte $8B, $A2, $00, $FF

LBBDA:  .byte $05, $10 ;X=5, y=16.
;              N    I    N    T    E    N    D    O    _    O    F    _    A    M    E    R
LBBDC:  .byte $97, $92, $97, $9D, $8E, $97, $8D, $98, $00, $98, $8F, $00, $8A, $96, $8E, $9B
;              I    C    A    _    I    N    C    .   END
LBBEC:  .byte $92, $8C, $8A, $00, $92, $97, $8C, $43, $FF

LBBF5:  .byte $00, $1E, $FF ;X=0, Y=30.

LBBF8:  .byte $0A, $0C ;X=10, Y=12.
;              P    R    E    S    E    N    T    E    D   END
LBBFA:  .byte $99, $9B, $8E, $9C, $8E, $97, $9D, $8E, $8D, $FF

LBC04:  .byte $0E, $0E ;X=14, Y=14.
;              B    Y    _   END
LBC06:  .byte $8B, $A2, $00, $FF

LBC0A:  .byte $0B, $10 ;X=11, Y=16.
;              F    C    I    _    I    N    C    .   END
LBC0C:  .byte $8F, $8C, $92, $00, $92, $97, $8C, $43, $FF

LBC15:  .byte $00, $1F, $FF ;X=0, Y=31.

;----------------------------------------------------------------------------------------------------

PushStartText:
;              \n   _    P    U    S    H    _    S    T    A    R    T    _    \n   _   END
LBC18:  .byte $FD, $00, $99, $9E, $9C, $91, $00, $9C, $9D, $8A, $9B, $9D, $00, $FD, $00, $FF

;----------------------------------------------------------------------------------------------------

;Unused tile patterns from Bank 6.
LBC28:  .byte $C0, $C0, $CC, $CC, $FF, $FF, $F0, $F0, $00, $30, $C0, $30, $03, $03, $CF, $0F
LBC38:  .byte $CF, $CF, $0F, $0F, $FC, $FC, $30, $30, $00, $00, $F0, $F0, $FF, $FF, $FC, $FC
LBC48:  .byte $FF, $FF, $0F, $0F, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
LBC58:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $3F, $3F, $03, $03, $00, $00, $00, $00, $00, $00
LBC68:  .byte $FC, $FC, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $3F, $3F, $3C, $3C
LBC78:  .byte $00, $00, $00, $00, $C0, $C0, $C0, $C0, $FF, $FF, $FF, $FF, $FF, $FF, $0F, $0F
LBC88:  .byte $00, $00, $00, $00, $00, $00, $00, $00, $F0, $F0, $C0, $C0, $0C, $0F, $08, $37
LBC98:  .byte $0F, $0F, $3F, $3F, $F8, $F0, $CC, $CC, $0C, $03, $CC, $33, $CC, $33, $C0, $03
LBCA8:  .byte $F0, $F0, $00, $00, $00, $00, $3C, $3C, $FC, $33, $CC, $33, $CC, $33, $C0, $30
LBCB8:  .byte $30, $30, $00, $00, $00, $00, $0F, $0F, $C0, $30, $C0, $00, $00, $03, $0C, $33
LBCC8:  .byte $0F, $0F, $3F, $3F, $FC, $FC, $C0, $C0, $00, $03, $0C, $03, $CC, $33, $CC, $33
LBCD8:  .byte $FC, $FC, $F0, $F0, $00, $00, $00, $00, $CC, $0F, $C8, $37, $CC, $3F, $C0, $03
LBCE8:  .byte $38, $30, $0C, $0C, $08, $00, $3C, $3C, $CC, $30, $0C, $30, $0C, $00, $CC, $30
LBCF8:  .byte $03, $03, $C3, $C3, $F3, $F3, $03, $03, $00, $00, $00, $00, $00, $00, $00, $00
LBD08:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $CC, $30, $CC, $00, $CC, $30, $CC, $03
LBD18:  .byte $03, $03, $33, $33, $03, $03, $30, $30, $CC, $30, $C0, $00, $CC, $33, $C0, $00
LBD28:  .byte $03, $03, $3F, $3F, $00, $00, $3F, $3F, $CF, $0F, $CF, $0F, $CF, $0F, $00, $03
LBD38:  .byte $30, $30, $30, $30, $30, $30, $FC, $FC, $FC, $FC, $C0, $C0, $C0, $C0, $00, $00
LBD48:  .byte $08, $08, $00, $00, $00, $00, $C0, $C0, $00, $00, $00, $00, $00, $00, $00, $00
LBD58:  .byte $0F, $0F, $0F, $0F, $3F, $3F, $3F, $3F, $00, $00, $00, $00, $00, $00, $00, $00
LBD68:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LBD78:  .byte $F0, $F0, $C0, $C0, $C0, $C0, $00, $00, $00, $00, $00, $00, $C0, $C0, $00, $00
LBD88:  .byte $03, $03, $00, $00, $80, $80, $00, $00, $0C, $3C, $0C, $30, $0C, $0C, $00, $00
LBD98:  .byte $CB, $C3, $C3, $C3, $FB, $FB, $3F, $3F, $C0, $30, $CC, $33, $0C, $30, $00, $00
LBDA8:  .byte $0F, $0F, $00, $00, $C0, $C0, $F0, $F0, $00, $03, $0C, $33, $00, $03, $00, $00
LBDB8:  .byte $FC, $FC, $C0, $C0, $00, $00, $00, $00, $CC, $33, $CC, $33, $CC, $33, $0C, $30
LBDC8:  .byte $00, $00, $00, $00, $00, $00, $03, $03, $CC, $30, $C0, $00, $00, $00, $00, $00
LBDD8:  .byte $03, $03, $3F, $3F, $FF, $FF, $F0, $F0, $00, $00, $0C, $03, $00, $00, $00, $00
LBDE8:  .byte $FF, $FF, $F0, $F0, $03, $03, $00, $00, $CC, $00, $CC, $00, $0C, $00, $0C, $30
LBDF8:  .byte $33, $33, $33, $33, $F3, $F3, $03, $03, $00, $00, $00, $00, $00, $00, $00, $00
LBE08:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $C0, $00, $CC, $00, $FC, $30, $00, $00
LBE18:  .byte $3F, $3F, $33, $33, $23, $23, $FF, $FF, $CC, $33, $C0, $00, $CC, $30, $00, $00
LBE28:  .byte $00, $00, $3F, $3F, $03, $03, $FF, $FF, $C0, $33, $C0, $03, $CC, $33, $00, $00
LBE38:  .byte $0C, $0C, $3C, $3C, $00, $00, $FF, $FF, $00, $00, $00, $00, $C0, $30, $00, $00
LBE48:  .byte $F0, $F0, $FC, $FC, $0F, $0F, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LBE58:  .byte $0F, $0F, $00, $00, $C0, $C0, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LBE68:  .byte $00, $00, $00, $00, $00, $00, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LBE78:  .byte $00, $00, $03, $03, $0F, $0F, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LBE88:  .byte $00, $00, $F0, $F0, $FC, $FC, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LBE98:  .byte $0F, $0F, $00, $00, $0F, $0F, $FF, $FF, $03, $03, $00, $00, $00, $00, $00, $00
LBEA8:  .byte $C2, $C2, $00, $00, $C0, $C0, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LBEB8:  .byte $00, $00, $3C, $3C, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LBEC8:  .byte $03, $03, $00, $00, $C0, $C0, $FF, $FF, $00, $00, $00, $00, $00, $00, $00, $00
LBED8:  .byte $C0, $C0, $00, $00, $0F, $0F, $FF, $FF, $00, $00, $00, $00, $00, $03, $00, $00
LBEE8:  .byte $00, $00, $00, $00, $C0, $C0, $FF, $FF, $0C, $00, $0C, $00, $CC, $30, $00, $00
LBEF8:  .byte $33, $33, $F3, $F3, $03, $03, $FF, $FF

;----------------------------------------------------------------------------------------------------

;Unused.
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
