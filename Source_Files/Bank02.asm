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

;The dungeon data is 16 X 16 bytes for each dungeon level. Below is a list of data values and
;what they translate to in the dungeon. The data values have been assigned constants to hopefully
;make the dungeon data more readable at a glance.
;$00=Wall               -> XXX
;$01=Door               -> _I_
;$02=Fake wall          -> _H_
;$03=Stairs up          -> _U_
;$04=Stairs down        -> _D_
;$05=Stairs up and down -> _B_
;$06=Mark               -> _M_
;$07=Fountain           -> _F_
;$08=Sign               -> _S_
;$09=Darkness           -> _K_
;$0A=Gremlins           -> _G_
;$0B=Chest              -> _C_
;$0C=Trap               -> _T_
;$0D=Floor              -> ___
;$0E=Time lord          -> _L_
;$0F=Not used

;----------------------------------------------------------------------------------------------------

;Cave of Fire, floor 1.
L0000:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L0010:  .byte XXX, _U_, _S_, ___, _H_, ___, ___, ___, ___, ___, _H_, _K_, XXX, _C_, _C_, _C_
L0020:  .byte XXX, XXX, XXX, ___, XXX, XXX, XXX, ___, _T_, ___, XXX, _K_, XXX, ___, _C_, _C_
L0030:  .byte XXX, ___, _I_, ___, XXX, ___, XXX, ___, ___, ___, XXX, _K_, _H_, ___, ___, _C_
L0040:  .byte XXX, ___, XXX, _F_, XXX, ___, XXX, XXX, XXX, XXX, XXX, _K_, XXX, _H_, XXX, XXX
L0050:  .byte XXX, ___, XXX, ___, _I_, ___, ___, ___, _F_, ___, XXX, _K_, _K_, _K_, _K_, _K_
L0060:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, _H_
L0070:  .byte XXX, ___, _I_, ___, XXX, ___, XXX, ___, ___, ___, ___, _T_, ___, ___, ___, ___
L0080:  .byte XXX, ___, XXX, _I_, XXX, XXX, XXX, ___, XXX, _H_, XXX, XXX, XXX, _H_, XXX, ___
L0090:  .byte XXX, _H_, XXX, ___, _I_, ___, ___, ___, _H_, ___, ___, ___, ___, ___, _H_, ___
L00A0:  .byte XXX, ___, XXX, ___, XXX, XXX, XXX, _H_, XXX, ___, XXX, ___, XXX, ___, XXX, _H_
L00B0:  .byte XXX, ___, _I_, ___, XXX, ___, ___, ___, XXX, ___, ___, _D_, ___, ___, XXX, ___
L00C0:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___
L00D0:  .byte XXX, ___, XXX, ___, _I_, ___, XXX, ___, _H_, ___, ___, ___, ___, ___, _H_, ___
L00E0:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, _H_, XXX, XXX, XXX, _H_, XXX, ___
L00F0:  .byte XXX, _C_, _I_, ___, XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___

;----------------------------------------------------------------------------------------------------

;Cave of Fire, floor 2.
L8100:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L8110:  .byte XXX, _C_, _H_, ___, _C_, ___, ___, _C_, ___, _C_, ___, ___, _C_, ___, _H_, _C_
L8120:  .byte XXX, _H_, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, _H_
L8130:  .byte XXX, ___, ___, ___, XXX, ___, XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___
L8140:  .byte XXX, ___, XXX, XXX, XXX, ___, XXX, XXX, XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX
L8150:  .byte XXX, ___, ___, ___, ___, _D_, ___, ___, ___, ___, ___, ___, XXX, _F_, _F_, _F_
L8160:  .byte XXX, ___, XXX, XXX, XXX, XXX, XXX, _H_, XXX, ___, XXX, ___, _H_, ___, ___, ___
L8170:  .byte XXX, ___, XXX, ___, ___, ___, XXX, ___, XXX, ___, XXX, ___, XXX, XXX, XXX, XXX
L8180:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, ___, ___
L8190:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, ___, ___, XXX, ___, ___, ___
L81A0:  .byte XXX, _H_, XXX, ___, XXX, ___, XXX, ___, XXX, XXX, _H_, XXX, XXX, XXX, _I_, XXX
L81B0:  .byte XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, _S_, _U_, XXX, ___, ___, ___
L81C0:  .byte XXX, ___, XXX, XXX, XXX, XXX, XXX, ___, XXX, ___, ___, _S_, _H_, ___, XXX, XXX
L81D0:  .byte XXX, ___, XXX, ___, ___, ___, XXX, ___, _I_, _T_, ___, ___, XXX, ___, ___, ___
L81E0:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, XXX, XXX, _I_, XXX, XXX, XXX, XXX, _I_, XXX
L81F0:  .byte XXX, ___, ___, ___, XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___

;----------------------------------------------------------------------------------------------------

;Cave of Fire, floor 3.
L8200:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L8210:  .byte XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___
L8220:  .byte XXX, XXX, ___, XXX, XXX, XXX, ___, XXX, XXX, XXX, ___, XXX, XXX, XXX, ___, XXX
L8230:  .byte XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, ___, ___, ___, ___
L8240:  .byte XXX, XXX, XXX, ___, XXX, _S_, XXX, ___, XXX, ___, XXX, ___, XXX, XXX, XXX, ___
L8250:  .byte XXX, ___, ___, ___, _S_, _U_, XXX, ___, ___, ___, XXX, ___, ___, XXX, ___, ___
L8260:  .byte XXX, XXX, ___, XXX, ___, XXX, XXX, XXX, ___, XXX, XXX, XXX, ___, XXX, ___, XXX
L8270:  .byte XXX, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, ___, ___, ___, ___, ___
L8280:  .byte XXX, ___, XXX, XXX, XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___, XXX, ___
L8290:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, ___, XXX, ___, XXX, ___, ___, XXX, ___
L82A0:  .byte XXX, XXX, XXX, XXX, ___, XXX, XXX, XXX, ___, XXX, ___, XXX, ___, XXX, XXX, XXX
L82B0:  .byte XXX, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, ___, _D_, ___, ___, ___, ___
L82C0:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, XXX, XXX, ___, XXX, XXX, XXX, ___, XXX, ___
L82D0:  .byte XXX, ___, ___, ___, XXX, ___, ___, XXX, ___, ___, ___, ___, ___, ___, XXX, ___
L82E0:  .byte XXX, XXX, ___, XXX, XXX, XXX, ___, XXX, ___, XXX, XXX, XXX, ___, XXX, XXX, XXX
L82F0:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, XXX, ___, ___, ___, ___, ___

;----------------------------------------------------------------------------------------------------

;Cave of Fire, floor 4.
L8300:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L8310:  .byte XXX, ___, ___, ___, _C_, XXX, _C_, ___, ___, ___, XXX, ___, ___, ___, XXX, _C_
L8320:  .byte XXX, _C_, XXX, ___, XXX, XXX, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___
L8330:  .byte XXX, XXX, XXX, ___, ___, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___
L8340:  .byte XXX, _C_, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, _C_
L8350:  .byte XXX, ___, ___, ___, XXX, _D_, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, XXX
L8360:  .byte XXX, _C_, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, _C_
L8370:  .byte XXX, XXX, XXX, ___, ___, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___
L8380:  .byte XXX, ___, XXX, ___, XXX, XXX, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, _C_
L8390:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, XXX, ___, ___, ___, XXX, XXX
L83A0:  .byte XXX, ___, XXX, XXX, XXX, ___, XXX, XXX, XXX, ___, XXX, XXX, XXX, XXX, XXX, _C_
L83B0:  .byte XXX, _T_, ___, ___, ___, ___, ___, ___, ___, ___, XXX, _U_, XXX, ___, ___, ___
L83C0:  .byte XXX, XXX, XXX, ___, XXX, XXX, XXX, ___, XXX, XXX, XXX, _S_, XXX, ___, XXX, ___
L83D0:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, XXX, ___, ___, ___, XXX, ___
L83E0:  .byte XXX, ___, XXX, XXX, XXX, ___, XXX, XXX, XXX, ___, XXX, XXX, XXX, XXX, XXX, ___
L83F0:  .byte XXX, ___, ___, XXX, _C_, ___, _C_, XXX, ___, ___, ___, ___, ___, ___, ___, ___

;----------------------------------------------------------------------------------------------------

;Cave of Fire, floor 5.
L8400:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L8410:  .byte XXX, _F_, _H_, ___, ___, _S_, _I_, _K_, _K_, _K_, _K_, _K_, _G_, _G_, _G_, _G_
L8420:  .byte XXX, _H_, XXX, ___, XXX, XXX, XXX, _K_, _K_, _K_, _K_, _G_, _G_, _G_, _G_, _G_
L8430:  .byte XXX, ___, ___, ___, ___, ___, XXX, _K_, _K_, _K_, _G_, _G_, ___, ___, _G_, _G_
L8440:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, XXX, XXX, _G_, _G_, ___, ___, ___, ___, _G_
L8450:  .byte XXX, _S_, XXX, ___, ___, _U_, _H_, ___, XXX, _G_, ___, ___, ___, ___, ___, ___
L8460:  .byte XXX, _I_, XXX, XXX, XXX, _H_, XXX, ___, XXX, XXX, XXX, XXX, XXX, ___, ___, ___
L8470:  .byte XXX, _K_, _K_, _K_, XXX, ___, ___, ___, ___, ___, ___, ___, XXX, ___, ___, ___
L8480:  .byte XXX, _K_, _K_, _K_, XXX, XXX, XXX, ___, XXX, _H_, XXX, ___, XXX, ___, ___, ___
L8490:  .byte XXX, _K_, _K_, _K_, _G_, _G_, XXX, ___, _H_, _F_, _H_, ___, XXX, _K_, ___, ___
L84A0:  .byte XXX, _K_, _K_, _G_, _G_, ___, XXX, ___, XXX, _H_, XXX, ___, XXX, _G_, _K_, ___
L84B0:  .byte XXX, _G_, _G_, _G_, ___, ___, XXX, ___, ___, ___, ___, _D_, _G_, _G_, _G_, _K_
L84C0:  .byte XXX, _G_, _G_, ___, ___, ___, XXX, XXX, XXX, XXX, XXX, _G_, _G_, _G_, _G_, _T_
L84D0:  .byte XXX, _G_, _G_, _G_, ___, ___, ___, ___, ___, _K_, _G_, _G_, _G_, _G_, _T_, _C_
L84E0:  .byte XXX, XXX, XXX, _G_, _G_, ___, ___, ___, ___, ___, _K_, _G_, _G_, _T_, _C_, _C_
L84F0:  .byte XXX, _D_, _T_, _T_, _T_, ___, ___, ___, ___, ___, ___, _K_, _T_, _C_, _C_, _C_

;----------------------------------------------------------------------------------------------------

;Cave of Fire, floor 6.
L8500:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L8510:  .byte XXX, _C_, _C_, _T_, _T_, ___, ___, ___, ___, ___, ___, ___, XXX, _D_, ___, _D_
L8520:  .byte XXX, _C_, _T_, _T_, ___, ___, ___, ___, XXX, ___, ___, ___, XXX, XXX, XXX, XXX
L8530:  .byte XXX, _T_, _T_, ___, ___, ___, ___, ___, ___, ___, XXX, ___, ___, ___, _T_, _T_
L8540:  .byte XXX, _T_, ___, ___, XXX, XXX, XXX, XXX, XXX, ___, ___, ___, XXX, ___, ___, _T_
L8550:  .byte XXX, ___, ___, ___, XXX, _D_, _S_, ___, XXX, _K_, ___, ___, ___, ___, XXX, ___
L8560:  .byte XXX, ___, ___, ___, XXX, _S_, ___, ___, XXX, _I_, XXX, ___, ___, ___, ___, ___
L8570:  .byte XXX, ___, XXX, ___, XXX, ___, ___, ___, ___, ___, _I_, _K_, ___, ___, XXX, ___
L8580:  .byte XXX, ___, ___, ___, XXX, XXX, XXX, ___, XXX, ___, XXX, XXX, XXX, ___, ___, ___
L8590:  .byte XXX, XXX, ___, ___, ___, _K_, _I_, ___, ___, ___, ___, ___, XXX, ___, ___, ___
L85A0:  .byte XXX, ___, ___, XXX, ___, ___, XXX, _I_, XXX, ___, ___, _S_, XXX, ___, XXX, ___
L85B0:  .byte XXX, ___, ___, ___, ___, ___, ___, _K_, XXX, ___, _K_, _U_, XXX, ___, ___, ___
L85C0:  .byte XXX, _T_, ___, ___, ___, ___, XXX, ___, XXX, XXX, XXX, XXX, XXX, ___, ___, _T_
L85D0:  .byte XXX, _T_, _T_, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, _T_, _T_
L85E0:  .byte XXX, XXX, XXX, _T_, ___, ___, ___, ___, XXX, ___, ___, XXX, ___, _T_, _T_, _C_
L85F0:  .byte XXX, _B_, XXX, _T_, _T_, ___, XXX, ___, ___, ___, ___, ___, _T_, _T_, _C_, _C_

;----------------------------------------------------------------------------------------------------

;Cave of Fire, floor 7.
L8600:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L8610:  .byte XXX, ___, ___, ___, XXX, _T_, ___, ___, ___, ___, XXX, ___, ___, _U_, XXX, _B_
L8620:  .byte XXX, ___, XXX, ___, ___, ___, ___, _T_, XXX, ___, XXX, ___, XXX, XXX, XXX, _T_
L8630:  .byte XXX, ___, ___, _S_, XXX, XXX, XXX, _S_, _T_, ___, ___, ___, XXX, _T_, XXX, XXX
L8640:  .byte XXX, XXX, ___, _T_, XXX, ___, ___, ___, XXX, XXX, XXX, _S_, _T_, _T_, XXX, _D_
L8650:  .byte XXX, _T_, ___, _T_, _S_, _U_, ___, ___, XXX, _S_, _T_, _T_, _T_, _T_, XXX, ___
L8660:  .byte XXX, _S_, ___, XXX, _T_, _S_, XXX, ___, ___, ___, XXX, XXX, XXX, _T_, XXX, ___
L8670:  .byte XXX, ___, ___, XXX, _T_, _T_, XXX, ___, ___, ___, XXX, _T_, _T_, _T_, XXX, _H_
L8680:  .byte XXX, ___, XXX, XXX, _T_, XXX, XXX, ___, XXX, XXX, XXX, _T_, XXX, XXX, XXX, _D_
L8690:  .byte XXX, ___, ___, ___, ___, ___, _S_, ___, ___, ___, _S_, _T_, XXX, _T_, XXX, ___
L86A0:  .byte XXX, XXX, _T_, _T_, XXX, XXX, XXX, XXX, ___, ___, XXX, XXX, XXX, _T_, XXX, ___
L86B0:  .byte XXX, _T_, _T_, _T_, _T_, _T_, XXX, _S_, ___, ___, ___, _D_, _S_, _T_, XXX, ___
L86C0:  .byte XXX, _T_, _T_, XXX, _T_, _T_, XXX, _T_, XXX, XXX, _S_, _S_, XXX, _T_, XXX, _D_
L86D0:  .byte XXX, _T_, _T_, XXX, _T_, _T_, _T_, _T_, XXX, _T_, _T_, _T_, XXX, _T_, XXX, XXX
L86E0:  .byte XXX, XXX, XXX, XXX, XXX, XXX, _T_, _T_, XXX, _T_, _T_, XXX, XXX, XXX, XXX, _T_
L86F0:  .byte XXX, _B_, XXX, _T_, _T_, _T_, _T_, _T_, _T_, _T_, _T_, _T_, _T_, _T_, _T_, _T_

;----------------------------------------------------------------------------------------------------

;Cave of Fire, floor 8.
L8700:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L8710:  .byte XXX, _G_, _C_, _G_, XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, _U_
L8720:  .byte XXX, _C_, _T_, _C_, _I_, ___, ___, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___
L8730:  .byte XXX, _G_, _C_, _G_, XXX, ___, ___, XXX, _C_, _C_, _C_, _C_, _C_, _C_, XXX, XXX
L8740:  .byte XXX, XXX, XXX, XXX, XXX, XXX, _H_, XXX, _C_, _C_, _C_, _C_, _C_, _C_, _T_, _U_
L8750:  .byte XXX, XXX, _C_, _C_, _C_, XXX, ___, XXX, _C_, _C_, _C_, _C_, _C_, _C_, XXX, XXX
L8760:  .byte XXX, XXX, _C_, _C_, _C_, _I_, ___, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L8770:  .byte XXX, XXX, _C_, _C_, _C_, XXX, _G_, _G_, XXX, _F_, ___, _F_, ___, ___, XXX, XXX
L8780:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, _C_, XXX, ___, ___, ___, ___, ___, ___, _U_
L8790:  .byte XXX, XXX, XXX, ___, ___, ___, XXX, XXX, XXX, ___, _F_, ___, _F_, ___, XXX, XXX
L87A0:  .byte XXX, _S_, _I_, ___, _M_, ___, XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L87B0:  .byte XXX, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, _U_, _K_, _K_, XXX, XXX
L87C0:  .byte XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, ___, ___, XXX, _K_, _K_, _K_, XXX, _U_
L87D0:  .byte XXX, ___, XXX, XXX, ___, ___, ___, XXX, ___, ___, XXX, _K_, _K_, _K_, _I_, ___
L87E0:  .byte XXX, ___, XXX, XXX, ___, _M_, ___, _I_, _S_, ___, XXX, XXX, XXX, _I_, XXX, ___
L87F0:  .byte XXX, _U_, XXX, XXX, ___, ___, ___, XXX, ___, ___, ___, ___, ___, ___, ___, ___

;----------------------------------------------------------------------------------------------------

;Cave of Madness, floor 1.
L8800:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L8810:  .byte XXX, _B_, _S_, ___, XXX, ___, XXX, _C_, ___, _C_, XXX, _C_, XXX, ___, ___, ___
L8820:  .byte XXX, _S_, ___, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, _K_
L8830:  .byte XXX, ___, ___, XXX, XXX, ___, XXX, XXX, _G_, XXX, XXX, XXX, XXX, ___, XXX, ___
L8840:  .byte XXX, XXX, ___, XXX, ___, ___, ___, XXX, _I_, XXX, ___, ___, XXX, ___, XXX, ___
L8850:  .byte XXX, ___, ___, ___, ___, XXX, ___, ___, ___, ___, ___, ___, XXX, ___, XXX, ___
L8860:  .byte XXX, XXX, XXX, XXX, ___, ___, XXX, XXX, XXX, XXX, XXX, ___, XXX, ___, XXX, ___
L8870:  .byte XXX, _C_, ___, XXX, XXX, ___, _T_, _F_, ___, ___, ___, ___, XXX, ___, XXX, ___
L8880:  .byte XXX, ___, ___, _G_, _I_, ___, XXX, _F_, XXX, ___, ___, ___, XXX, ___, XXX, ___
L8890:  .byte XXX, _C_, ___, XXX, XXX, ___, XXX, ___, ___, ___, ___, XXX, XXX, ___, XXX, _S_
L88A0:  .byte XXX, XXX, XXX, XXX, ___, ___, XXX, ___, ___, ___, XXX, XXX, ___, ___, XXX, _I_
L88B0:  .byte XXX, _C_, ___, XXX, ___, ___, ___, ___, ___, XXX, XXX, ___, ___, XXX, XXX, _D_
L88C0:  .byte XXX, XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___, ___, XXX, XXX, ___, ___
L88D0:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, XXX, XXX, _D_, ___, _D_
L88E0:  .byte XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___, ___, ___, ___
L88F0:  .byte XXX, ___, _K_, ___, ___, ___, ___, ___, ___, _S_, _I_, _D_, ___, _D_, ___, _D_

;----------------------------------------------------------------------------------------------------

;Cave of Madness, floor 2.
L8900:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___, ___, ___, XXX, XXX, XXX, XXX, XXX, XXX
L8910:  .byte XXX, _B_, XXX, ___, _H_, _G_, XXX, ___, ___, _K_, XXX, _C_, _H_, ___, _H_, _C_
L8920:  .byte XXX, XXX, XXX, _H_, XXX, _H_, XXX, _T_, ___, ___, XXX, _H_, XXX, _H_, XXX, _H_
L8930:  .byte XXX, _C_, _H_, ___, _H_, _G_, XXX, ___, ___, _G_, XXX, _G_, _H_, _C_, _H_, ___
L8940:  .byte XXX, _H_, XXX, _H_, XXX, _H_, XXX, ___, ___, ___, XXX, _H_, XXX, _H_, XXX, _H_
L8950:  .byte XXX, ___, _H_, _G_, _H_, ___, _I_, ___, ___, ___, _I_, ___, _H_, _C_, _H_, _G_
L8960:  .byte XXX, XXX, XXX, XXX, XXX, _I_, XXX, ___, _K_, ___, XXX, _I_, XXX, XXX, XXX, XXX
L8970:  .byte _K_, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, _T_, ___, ___
L8980:  .byte ___, ___, ___, _G_, ___, ___, _K_, ___, _F_, ___, _K_, ___, ___, ___, ___, ___
L8990:  .byte ___, ___, _T_, ___, ___, ___, ___, ___, ___, ___, ___, ___, _G_, ___, _K_, ___
L89A0:  .byte XXX, XXX, XXX, XXX, XXX, _I_, XXX, ___, _K_, ___, XXX, _I_, XXX, XXX, XXX, XXX
L89B0:  .byte XXX, _G_, _H_, _C_, _H_, ___, _I_, ___, ___, ___, _I_, _S_, ___, ___, ___, _U_
L89C0:  .byte XXX, _H_, XXX, _H_, XXX, _H_, XXX, ___, ___, ___, XXX, _H_, XXX, XXX, XXX, XXX
L89D0:  .byte XXX, _G_, _H_, _T_, _H_, _C_, XXX, _K_, ___, ___, XXX, _C_, XXX, _B_, XXX, _B_
L89E0:  .byte XXX, _H_, XXX, _H_, XXX, _H_, XXX, ___, ___, _T_, XXX, XXX, XXX, XXX, XXX, XXX
L89F0:  .byte XXX, _C_, _H_, _C_, _H_, _G_, XXX, ___, _G_, ___, XXX, _B_, XXX, _B_, XXX, _B_

;----------------------------------------------------------------------------------------------------

;Cave of Madness, floor 3.
L8A00:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, _S_, XXX, XXX, XXX, XXX
L8A10:  .byte XXX, _B_, XXX, _K_, ___, ___, ___, ___, ___, ___, ___, ___, XXX, ___, ___, ___
L8A20:  .byte XXX, XXX, XXX, _K_, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___, XXX, ___
L8A30:  .byte ___, ___, XXX, _K_, ___, ___, ___, ___, ___, ___, ___, ___, XXX, ___, XXX, ___
L8A40:  .byte XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___, XXX, ___, XXX, XXX
L8A50:  .byte XXX, ___, _H_, _M_, XXX, _K_, _K_, _K_, XXX, ___, ___, ___, XXX, ___, ___, ___
L8A60:  .byte XXX, ___, XXX, XXX, XXX, ___, XXX, ___, XXX, ___, XXX, XXX, XXX, XXX, XXX, _G_
L8A70:  .byte XXX, ___, ___, ___, ___, ___, XXX, ___, XXX, ___, ___, ___, ___, ___, _G_, _G_
L8A80:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L8A90:  .byte ___, ___, ___, ___, ___, ___, ___, ___, XXX, ___, ___, ___, ___, ___, ___, ___
L8AA0:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX
L8AB0:  .byte _K_, _K_, XXX, _G_, ___, ___, ___, ___, ___, ___, XXX, ___, ___, ___, ___, ___
L8AC0:  .byte XXX, ___, XXX, _G_, XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___, XXX, XXX, XXX, XXX
L8AD0:  .byte XXX, ___, XXX, _G_, ___, ___, ___, ___, ___, ___, ___, ___, XXX, _B_, XXX, _B_
L8AE0:  .byte XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L8AF0:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, _S_, _U_, XXX, _B_, XXX, _B_

;----------------------------------------------------------------------------------------------------

;Cave of Madness, floor 4.
L8B00:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___, XXX, XXX, XXX, XXX
L8B10:  .byte XXX, _B_, XXX, _C_, _C_, _C_, XXX, ___, ___, ___, XXX, ___, XXX, ___, ___, _C_
L8B20:  .byte XXX, XXX, XXX, _C_, _C_, _C_, XXX, ___, XXX, ___, XXX, ___, ___, ___, XXX, XXX
L8B30:  .byte XXX, _C_, _C_, _C_, _C_, _T_, XXX, ___, XXX, ___, XXX, XXX, XXX, ___, ___, _C_
L8B40:  .byte XXX, _C_, _C_, _C_, XXX, _H_, XXX, ___, ___, ___, XXX, _C_, ___, ___, XXX, XXX
L8B50:  .byte XXX, _C_, _C_, _T_, _H_, ___, ___, ___, XXX, ___, XXX, XXX, XXX, ___, ___, _C_
L8B60:  .byte XXX, XXX, XXX, XXX, XXX, ___, XXX, ___, XXX, ___, XXX, _C_, ___, ___, XXX, XXX
L8B70:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, XXX, XXX, XXX, ___, ___, _C_
L8B80:  .byte XXX, ___, XXX, XXX, ___, XXX, XXX, ___, ___, _F_, XXX, _C_, ___, ___, XXX, XXX
L8B90:  .byte ___, ___, ___, ___, ___, ___, ___, ___, _F_, XXX, XXX, XXX, XXX, ___, ___, _C_
L8BA0:  .byte XXX, XXX, XXX, ___, XXX, ___, XXX, XXX, XXX, XXX, XXX, _C_, ___, ___, XXX, XXX
L8BB0:  .byte XXX, ___, ___, ___, XXX, ___, ___, ___, ___, ___, XXX, XXX, XXX, ___, ___, _C_
L8BC0:  .byte XXX, ___, XXX, ___, ___, ___, XXX, XXX, XXX, ___, ___, ___, XXX, _S_, XXX, XXX
L8BD0:  .byte XXX, ___, ___, ___, XXX, ___, ___, ___, ___, ___, XXX, ___, XXX, _U_, XXX, _B_
L8BE0:  .byte XXX, XXX, XXX, ___, XXX, ___, XXX, XXX, XXX, ___, ___, ___, XXX, XXX, XXX, XXX
L8BF0:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, XXX, ___, XXX, _B_, XXX, _B_

;----------------------------------------------------------------------------------------------------

;Cave of Madness, floor 5.
L8C00:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L8C10:  .byte XXX, _B_, XXX, _C_, XXX, ___, ___, ___, XXX, ___, ___, ___, _K_, ___, XXX, _T_
L8C20:  .byte XXX, XXX, XXX, ___, _T_, ___, XXX, ___, _K_, ___, XXX, ___, XXX, ___, _K_, ___
L8C30:  .byte XXX, _C_, ___, _T_, _T_, _T_, ___, ___, XXX, ___, ___, ___, _K_, ___, XXX, ___
L8C40:  .byte XXX, XXX, XXX, XXX, _H_, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___
L8C50:  .byte XXX, _C_, _C_, _C_, _C_, _C_, _C_, _C_, _C_, _C_, _C_, _C_, _C_, _C_, XXX, ___
L8C60:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___
L8C70:  .byte XXX, _C_, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, _K_, ___, XXX, ___
L8C80:  .byte XXX, ___, _K_, ___, XXX, ___, _K_, ___, XXX, ___, _K_, ___, XXX, ___, _K_, ___
L8C90:  .byte XXX, _C_, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, _K_, ___, XXX, ___
L8CA0:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___
L8CB0:  .byte XXX, _C_, _C_, _C_, _C_, _C_, _C_, _C_, _C_, _C_, _C_, _C_, _C_, _C_, XXX, ___
L8CC0:  .byte XXX, XXX, XXX, XXX, _H_, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, _S_
L8CD0:  .byte XXX, _C_, XXX, _T_, _T_, _T_, XXX, ___, ___, ___, XXX, ___, ___, ___, _S_, _U_
L8CE0:  .byte XXX, ___, _K_, ___, XXX, ___, _K_, ___, XXX, ___, _K_, ___, XXX, XXX, XXX, XXX
L8CF0:  .byte XXX, _C_, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, XXX, XXX, _B_, XXX, _B_

;----------------------------------------------------------------------------------------------------

;Cave of Madness, floor 6.
L8D00:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L8D10:  .byte XXX, _B_, XXX, _C_, _C_, _T_, _T_, _T_, _T_, ___, ___, ___, ___, ___, ___, ___
L8D20:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___, XXX, XXX, XXX, XXX, XXX, ___
L8D30:  .byte XXX, _G_, _C_, _G_, XXX, ___, ___, ___, XXX, ___, XXX, ___, ___, ___, ___, ___
L8D40:  .byte XXX, _G_, XXX, _G_, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, XXX, XXX, XXX
L8D50:  .byte XXX, ___, ___, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, _K_
L8D60:  .byte XXX, _H_, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, _H_, XXX, _K_
L8D70:  .byte XXX, ___, _T_, _T_, _T_, _T_, _T_, _T_, _T_, _T_, _T_, _T_, _T_, ___, _H_, _K_
L8D80:  .byte XXX, _I_, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, _K_
L8D90:  .byte XXX, _C_, ___, _C_, ___, _C_, XXX, _G_, _G_, _G_, _G_, _G_, _G_, _G_, XXX, _K_
L8DA0:  .byte XXX, ___, _C_, ___, _C_, ___, XXX, _G_, XXX, _G_, XXX, _G_, XXX, _G_, XXX, _K_
L8DB0:  .byte XXX, _C_, ___, _C_, ___, _C_, XXX, _G_, _G_, _G_, _G_, _G_, _G_, _G_, XXX, _K_
L8DC0:  .byte XXX, ___, _C_, ___, _C_, ___, XXX, _G_, XXX, _G_, XXX, ___, XXX, ___, XXX, _K_
L8DD0:  .byte XXX, _C_, ___, _C_, ___, _C_, XXX, _G_, _G_, _G_, ___, ___, ___, _S_, _H_, _K_
L8DE0:  .byte XXX, ___, _C_, ___, _C_, ___, XXX, _G_, XXX, _G_, XXX, ___, XXX, ___, XXX, XXX
L8DF0:  .byte XXX, _C_, ___, _C_, ___, _C_, XXX, _G_, _G_, _G_, ___, _S_, ___, _U_, XXX, _B_

;----------------------------------------------------------------------------------------------------

;Cave of Madness, floor 7.
L8E00:  .byte XXX, XXX, XXX, ___, ___, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_
L8E10:  .byte XXX, _B_, XXX, ___, ___, _C_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_
L8E20:  .byte XXX, XXX, XXX, ___, ___, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _C_, _K_, _K_
L8E30:  .byte ___, ___, ___, ___, ___, _K_, _K_, _K_, _K_, _C_, _K_, _K_, _K_, _K_, _K_, _K_
L8E40:  .byte ___, ___, ___, ___, ___, _K_, _T_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_
L8E50:  .byte _K_, _T_, _K_, _K_, _K_, _K_, _K_, ___, ___, ___, ___, _T_, _K_, _K_, _K_, _K_
L8E60:  .byte _K_, _K_, _K_, _C_, _K_, _K_, ___, _S_, _S_, _S_, _S_, ___, _K_, _C_, _K_, _K_
L8E70:  .byte _K_, _K_, _K_, _K_, _K_, ___, _S_, _F_, _F_, _F_, _F_, _S_, ___, _K_, _K_, _K_
L8E80:  .byte _K_, _K_, _K_, _K_, _K_, _T_, ___, _S_, _S_, _S_, _S_, ___, _K_, _K_, _K_, _K_
L8E90:  .byte _K_, _C_, _K_, _K_, _K_, _K_, _K_, ___, ___, ___, ___, _K_, _K_, _T_, _K_, _K_
L8EA0:  .byte _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _C_, _K_, _K_, _K_, _K_, _K_, _K_
L8EB0:  .byte _K_, _K_, _K_, _K_, _C_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_
L8EC0:  .byte _K_, _K_, _T_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, ___
L8ED0:  .byte _K_, _K_, _K_, _K_, _K_, _K_, _K_, _C_, _K_, _K_, _K_, _K_, _T_, ___, ___, ___
L8EE0:  .byte _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, ___, ___, _S_
L8EF0:  .byte _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, _K_, ___, ___, _S_, _U_

;----------------------------------------------------------------------------------------------------

;Cave of Madness, floor 8.
L8F00:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L8F10:  .byte XXX, _U_, _S_, ___, ___, ___, XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___
L8F20:  .byte XXX, _S_, XXX, XXX, XXX, ___, XXX, XXX, XXX, ___, XXX, XXX, _H_, XXX, XXX, ___
L8F30:  .byte XXX, ___, ___, ___, XXX, ___, _K_, _T_, _T_, _K_, XXX, _C_, _C_, _C_, XXX, ___
L8F40:  .byte XXX, XXX, XXX, ___, XXX, ___, XXX, XXX, XXX, XXX, XXX, _C_, _C_, _C_, XXX, ___
L8F50:  .byte XXX, ___, ___, ___, XXX, ___, ___, ___, ___, ___, XXX, _C_, _C_, _C_, XXX, ___
L8F60:  .byte XXX, ___, XXX, ___, XXX, XXX, XXX, XXX, XXX, ___, XXX, _C_, _C_, _C_, XXX, ___
L8F70:  .byte XXX, ___, XXX, ___, ___, ___, ___, ___, XXX, ___, XXX, _C_, _C_, _C_, XXX, ___
L8F80:  .byte XXX, ___, XXX, XXX, XXX, ___, XXX, ___, XXX, ___, XXX, XXX, XXX, XXX, XXX, ___
L8F90:  .byte XXX, ___, ___, _M_, XXX, ___, XXX, ___, ___, ___, ___, ___, XXX, ___, ___, ___
L8FA0:  .byte XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___, XXX, ___, XXX, XXX
L8FB0:  .byte XXX, ___, XXX, _C_, _C_, _C_, XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___
L8FC0:  .byte XXX, ___, XXX, _C_, _C_, _C_, XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___
L8FD0:  .byte XXX, ___, XXX, _C_, _C_, _C_, XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___
L8FE0:  .byte XXX, ___, XXX, XXX, _H_, XXX, XXX, XXX, XXX, XXX, XXX, ___, XXX, XXX, XXX, ___
L8FF0:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, XXX, _M_, ___, ___

;----------------------------------------------------------------------------------------------------

;Cave of Gold, floor 1.
L9000:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L9010:  .byte XXX, _U_, _S_, ___, ___, XXX, ___, ___, ___, ___, ___, ___, _I_, ___, ___, _D_
L9020:  .byte XXX, _S_, XXX, XXX, ___, XXX, XXX, XXX, ___, XXX, XXX, ___, XXX, XXX, XXX, ___
L9030:  .byte XXX, ___, XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, XXX, ___
L9040:  .byte XXX, ___, ___, ___, XXX, XXX, XXX, ___, XXX, ___, XXX, _I_, XXX, ___, XXX, _I_
L9050:  .byte XXX, XXX, XXX, ___, XXX, _C_, _H_, ___, XXX, ___, XXX, ___, XXX, ___, ___, ___
L9060:  .byte XXX, ___, XXX, ___, XXX, _H_, XXX, ___, XXX, _I_, XXX, ___, XXX, XXX, XXX, ___
L9070:  .byte XXX, ___, XXX, ___, ___, ___, ___, ___, _I_, ___, ___, ___, ___, ___, _I_, ___
L9080:  .byte XXX, ___, ___, ___, XXX, XXX, XXX, _I_, XXX, XXX, XXX, XXX, _F_, ___, XXX, ___
L9090:  .byte XXX, ___, XXX, ___, ___, ___, _I_, ___, XXX, _C_, ___, XXX, XXX, XXX, XXX, ___
L90A0:  .byte XXX, ___, XXX, ___, XXX, XXX, XXX, ___, XXX, ___, ___, ___, ___, ___, ___, ___
L90B0:  .byte XXX, ___, ___, ___, _I_, ___, ___, ___, XXX, XXX, ___, ___, ___, ___, ___, _M_
L90C0:  .byte XXX, _I_, XXX, ___, XXX, XXX, XXX, ___, _F_, XXX, ___, ___, XXX, XXX, _I_, XXX
L90D0:  .byte XXX, ___, XXX, ___, ___, ___, XXX, ___, ___, XXX, ___, ___, XXX, ___, ___, ___
L90E0:  .byte XXX, ___, XXX, XXX, XXX, ___, XXX, _I_, XXX, XXX, ___, ___, _I_, ___, ___, _C_
L90F0:  .byte XXX, _D_, ___, ___, _I_, ___, ___, ___, ___, ___, ___, _M_, XXX, ___, _C_, _F_

;----------------------------------------------------------------------------------------------------

;Cave of Gold, floor 2.
L9100:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L9110:  .byte XXX, _F_, ___, _I_, ___, ___, ___, XXX, ___, ___, ___, ___, ___, XXX, ___, _U_
L9120:  .byte XXX, ___, ___, XXX, ___, ___, ___, ___, ___, ___, XXX, ___, ___, _I_, ___, ___
L9130:  .byte XXX, ___, ___, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, _I_, XXX
L9140:  .byte XXX, ___, XXX, XXX, ___, ___, ___, ___, ___, ___, XXX, ___, _F_, XXX, ___, ___
L9150:  .byte XXX, ___, ___, XXX, ___, ___, ___, ___, ___, ___, _I_, ___, ___, XXX, XXX, _I_
L9160:  .byte XXX, ___, ___, XXX, ___, ___, XXX, XXX, _I_, XXX, XXX, _I_, XXX, XXX, ___, ___
L9170:  .byte XXX, _I_, XXX, XXX, XXX, XXX, XXX, _F_, _S_, ___, XXX, ___, ___, ___, ___, ___
L9180:  .byte XXX, ___, ___, ___, ___, ___, _I_, _S_, _D_, _S_, _I_, ___, XXX, XXX, XXX, XXX
L9190:  .byte XXX, ___, ___, ___, ___, ___, XXX, ___, _S_, ___, XXX, ___, ___, ___, ___, ___
L91A0:  .byte XXX, ___, ___, XXX, XXX, _I_, XXX, XXX, _I_, XXX, XXX, XXX, XXX, XXX, ___, ___
L91B0:  .byte XXX, ___, ___, XXX, ___, ___, _I_, ___, ___, ___, ___, ___, _C_, XXX, XXX, _I_
L91C0:  .byte XXX, ___, ___, XXX, _F_, ___, XXX, ___, XXX, ___, ___, XXX, ___, XXX, ___, ___
L91D0:  .byte XXX, XXX, _I_, XXX, XXX, XXX, XXX, ___, ___, ___, ___, ___, ___, XXX, ___, ___
L91E0:  .byte XXX, ___, ___, _I_, ___, ___, XXX, XXX, XXX, XXX, _I_, XXX, XXX, XXX, ___, ___
L91F0:  .byte XXX, _U_, ___, XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, _F_

;----------------------------------------------------------------------------------------------------

;Cave of Gold, floor 3.
L9200:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L9210:  .byte XXX, _D_, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, _D_
L9220:  .byte XXX, ___, XXX, ___, XXX, XXX, XXX, ___, XXX, ___, XXX, XXX, XXX, ___, XXX, ___
L9230:  .byte XXX, ___, ___, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, ___, ___
L9240:  .byte XXX, ___, XXX, ___, XXX, _C_, XXX, XXX, XXX, XXX, XXX, _C_, XXX, ___, XXX, ___
L9250:  .byte XXX, ___, XXX, ___, _C_, _C_, _C_, XXX, _S_, XXX, _C_, _C_, _C_, ___, XXX, ___
L9260:  .byte XXX, ___, XXX, XXX, XXX, _C_, _C_, XXX, ___, XXX, _C_, _C_, XXX, XXX, XXX, ___
L9270:  .byte XXX, ___, ___, ___, XXX, XXX, XXX, XXX, ___, XXX, XXX, XXX, XXX, ___, ___, ___
L9280:  .byte XXX, ___, XXX, ___, XXX, _S_, ___, ___, _B_, ___, ___, _S_, XXX, ___, XXX, ___
L9290:  .byte XXX, ___, ___, ___, XXX, XXX, XXX, XXX, ___, XXX, XXX, XXX, XXX, ___, ___, ___
L92A0:  .byte XXX, ___, XXX, XXX, XXX, _C_, _C_, XXX, ___, XXX, _C_, _C_, XXX, XXX, XXX, ___
L92B0:  .byte XXX, ___, XXX, ___, _C_, _C_, _C_, XXX, _S_, XXX, _C_, _C_, _C_, ___, XXX, ___
L92C0:  .byte XXX, ___, XXX, ___, XXX, _C_, XXX, XXX, XXX, XXX, XXX, _C_, XXX, ___, XXX, ___
L92D0:  .byte XXX, ___, ___, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, ___, ___
L92E0:  .byte XXX, ___, XXX, ___, XXX, XXX, XXX, ___, XXX, ___, XXX, XXX, XXX, ___, XXX, ___
L92F0:  .byte XXX, _D_, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, _D_

;----------------------------------------------------------------------------------------------------

;Cave of Gold, floor 4.
L9300:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L9310:  .byte XXX, _U_, _T_, _T_, _T_, _T_, ___, ___, XXX, ___, ___, _G_, _G_, _G_, _G_, _U_
L9320:  .byte XXX, _T_, _T_, _T_, _T_, _T_, _T_, ___, XXX, ___, _G_, _G_, _G_, _G_, _G_, _G_
L9330:  .byte XXX, _T_, _T_, _T_, _T_, _T_, _T_, _T_, XXX, _G_, _G_, _G_, _G_, _G_, _G_, _G_
L9340:  .byte XXX, _T_, _T_, _T_, _T_, _S_, _T_, _T_, XXX, _G_, _G_, _S_, _G_, _G_, _G_, _G_
L9350:  .byte XXX, _T_, _T_, _T_, _S_, _D_, _S_, _T_, XXX, _G_, _S_, _D_, _S_, _G_, _G_, _G_
L9360:  .byte XXX, ___, _T_, _T_, _T_, _S_, XXX, XXX, XXX, XXX, XXX, _S_, _G_, _G_, _G_, _G_
L9370:  .byte XXX, ___, ___, _T_, _T_, _T_, XXX, _K_, _K_, _K_, XXX, _G_, _G_, _G_, ___, ___
L9380:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, _K_, _B_, _K_, XXX, XXX, XXX, XXX, XXX, XXX
L9390:  .byte XXX, ___, ___, _K_, _K_, _K_, XXX, _K_, _K_, _K_, XXX, _C_, _C_, _C_, ___, ___
L93A0:  .byte XXX, ___, _K_, _K_, _K_, _S_, XXX, XXX, XXX, XXX, XXX, _S_, _C_, _C_, _C_, ___
L93B0:  .byte XXX, _K_, _K_, _K_, _S_, _D_, _S_, _K_, XXX, _C_, _S_, _D_, _S_, _C_, _C_, _C_
L93C0:  .byte XXX, _K_, _K_, _K_, _K_, _S_, _K_, _K_, XXX, _C_, _C_, _S_, _C_, _C_, _C_, _C_
L93D0:  .byte XXX, _K_, _K_, _K_, _K_, _K_, _K_, _K_, XXX, _C_, _C_, _C_, _C_, _C_, _C_, _C_
L93E0:  .byte XXX, _K_, _K_, _K_, _K_, _K_, _K_, ___, XXX, ___, _C_, _C_, _C_, _C_, _C_, _C_
L93F0:  .byte XXX, _U_, _K_, _K_, _K_, _K_, ___, ___, XXX, ___, ___, _C_, _C_, _C_, _C_, _U_

;----------------------------------------------------------------------------------------------------

;Cave of Gold, floor 5.
L9400:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L9410:  .byte XXX, _C_, _C_, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, _C_, _C_
L9420:  .byte XXX, _C_, XXX, ___, XXX, ___, XXX, ___, ___, ___, XXX, ___, XXX, ___, XXX, _C_
L9430:  .byte XXX, ___, ___, ___, ___, ___, XXX, XXX, ___, XXX, XXX, ___, ___, ___, ___, ___
L9440:  .byte XXX, XXX, XXX, ___, XXX, XXX, XXX, XXX, _I_, XXX, XXX, XXX, XXX, ___, XXX, XXX
L9450:  .byte XXX, ___, ___, ___, XXX, _U_, _S_, ___, ___, ___, _S_, _U_, XXX, ___, ___, ___
L9460:  .byte XXX, ___, XXX, XXX, XXX, _S_, ___, _D_, XXX, _D_, ___, _S_, XXX, XXX, XXX, ___
L9470:  .byte XXX, ___, ___, XXX, XXX, ___, _D_, XXX, XXX, XXX, _D_, ___, XXX, XXX, ___, ___
L9480:  .byte XXX, XXX, ___, ___, _I_, ___, XXX, XXX, _B_, XXX, XXX, ___, _I_, ___, ___, XXX
L9490:  .byte XXX, ___, ___, XXX, XXX, ___, _D_, XXX, XXX, XXX, _D_, ___, XXX, XXX, ___, ___
L94A0:  .byte XXX, ___, XXX, XXX, XXX, _S_, ___, _D_, XXX, _D_, ___, _S_, XXX, XXX, XXX, ___
L94B0:  .byte ___, ___, ___, ___, XXX, _U_, _S_, ___, ___, ___, _S_, _U_, XXX, ___, ___, ___
L94C0:  .byte XXX, XXX, XXX, ___, XXX, XXX, XXX, XXX, _I_, XXX, XXX, XXX, XXX, ___, XXX, XXX
L94D0:  .byte XXX, ___, ___, ___, ___, ___, XXX, XXX, ___, XXX, XXX, ___, ___, ___, ___, ___
L94E0:  .byte XXX, _C_, XXX, ___, XXX, ___, XXX, ___, ___, ___, XXX, ___, XXX, ___, XXX, _C_
L94F0:  .byte XXX, _C_, _C_, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, _C_, _C_

;----------------------------------------------------------------------------------------------------

;Cave of Gold, floor 6.
L9500:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L9510:  .byte XXX, _K_, _K_, _K_, _K_, _K_, _K_, XXX, XXX, XXX, _K_, _K_, _K_, _K_, _K_, _K_
L9520:  .byte XXX, _K_, XXX, _H_, XXX, _K_, _K_, _K_, XXX, _K_, _K_, _K_, XXX, _H_, XXX, _K_
L9530:  .byte XXX, _K_, _H_, _D_, XXX, XXX, _K_, _K_, XXX, _K_, _K_, XXX, XXX, _D_, _H_, _K_
L9540:  .byte XXX, _K_, XXX, XXX, XXX, XXX, XXX, _I_, XXX, _I_, XXX, XXX, XXX, XXX, XXX, _K_
L9550:  .byte XXX, _K_, _K_, XXX, XXX, XXX, ___, _S_, XXX, _S_, ___, XXX, XXX, XXX, _K_, _K_
L9560:  .byte XXX, _K_, _K_, _K_, XXX, ___, ___, _U_, XXX, _U_, ___, ___, XXX, _K_, _K_, _K_
L9570:  .byte XXX, XXX, _K_, _K_, _I_, _S_, _U_, XXX, XXX, XXX, _U_, _S_, _I_, _K_, _K_, XXX
L9580:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, _B_, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L9590:  .byte XXX, _K_, _K_, _K_, _I_, _S_, _U_, XXX, XXX, XXX, _U_, _S_, _I_, _K_, _K_, XXX
L95A0:  .byte XXX, _K_, XXX, _K_, XXX, ___, ___, _U_, XXX, _U_, ___, ___, XXX, _K_, _K_, _K_
L95B0:  .byte XXX, _K_, _K_, _K_, XXX, XXX, ___, _S_, XXX, _S_, ___, XXX, XXX, XXX, _K_, _K_
L95C0:  .byte XXX, _K_, XXX, XXX, XXX, XXX, XXX, _I_, XXX, _I_, XXX, XXX, XXX, XXX, XXX, _K_
L95D0:  .byte XXX, _K_, _H_, _D_, XXX, XXX, _K_, _K_, XXX, _K_, _K_, XXX, XXX, _D_, _H_, _K_
L95E0:  .byte XXX, _K_, XXX, _H_, XXX, _K_, _K_, _K_, XXX, _K_, _K_, _K_, XXX, _H_, XXX, _K_
L95F0:  .byte XXX, _K_, _K_, _K_, _K_, _K_, _K_, XXX, XXX, XXX, _K_, _K_, _K_, _K_, _K_, _K_

;----------------------------------------------------------------------------------------------------

;Cave of Gold, floor 7.
L9600:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L9610:  .byte XXX, ___, ___, _G_, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, _G_, ___, ___
L9620:  .byte XXX, ___, XXX, _S_, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, _S_, XXX, ___
L9630:  .byte XXX, _G_, _S_, _B_, _S_, _G_, _T_, ___, ___, ___, _T_, _G_, _S_, _B_, _S_, _G_
L9640:  .byte XXX, ___, XXX, _S_, XXX, XXX, XXX, XXX, _T_, XXX, XXX, XXX, XXX, _S_, XXX, ___
L9650:  .byte XXX, ___, ___, _G_, XXX, _C_, _C_, _C_, _C_, _C_, _C_, _C_, XXX, _G_, ___, ___
L9660:  .byte XXX, XXX, XXX, _T_, XXX, _C_, _C_, _C_, XXX, _C_, _C_, _C_, XXX, _T_, XXX, XXX
L9670:  .byte XXX, ___, ___, ___, XXX, _C_, _C_, XXX, XXX, XXX, _C_, _C_, XXX, ___, ___, ___
L9680:  .byte XXX, ___, XXX, ___, _T_, _C_, XXX, XXX, _B_, XXX, XXX, _C_, _T_, ___, XXX, ___
L9690:  .byte XXX, ___, ___, ___, XXX, _C_, _C_, XXX, XXX, XXX, _C_, _C_, XXX, ___, ___, ___
L96A0:  .byte XXX, XXX, XXX, _T_, XXX, _C_, _C_, _C_, XXX, _C_, _C_, _C_, XXX, _T_, XXX, XXX
L96B0:  .byte XXX, ___, ___, _G_, XXX, _C_, _C_, _C_, _C_, _C_, _C_, _C_, XXX, _G_, ___, ___
L96C0:  .byte XXX, ___, XXX, _S_, XXX, XXX, XXX, XXX, _T_, XXX, XXX, XXX, XXX, _S_, XXX, ___
L96D0:  .byte XXX, _G_, _S_, _B_, _S_, _G_, _T_, ___, ___, ___, _T_, _G_, _S_, _B_, _S_, _G_
L96E0:  .byte XXX, ___, XXX, _S_, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, _S_, XXX, ___
L96F0:  .byte XXX, ___, ___, _G_, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, _G_, ___, ___

;----------------------------------------------------------------------------------------------------

;Cave of Gold, floor 8.
L9700:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L9710:  .byte XXX, _C_, _H_, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, _H_, _C_
L9720:  .byte XXX, _H_, XXX, ___, XXX, XXX, XXX, _T_, XXX, _T_, XXX, XXX, XXX, ___, XXX, _H_
L9730:  .byte XXX, ___, ___, _U_, _T_, _S_, ___, ___, ___, ___, ___, _S_, _T_, _U_, ___, ___
L9740:  .byte XXX, ___, XXX, _T_, XXX, XXX, XXX, XXX, _H_, XXX, XXX, XXX, XXX, _T_, XXX, ___
L9750:  .byte XXX, ___, XXX, _S_, XXX, _M_, ___, ___, ___, ___, ___, _F_, XXX, _S_, XXX, ___
L9760:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, _H_, XXX, _H_, XXX, ___, XXX, ___, XXX, ___
L9770:  .byte XXX, ___, _T_, ___, XXX, ___, _H_, _K_, _S_, _K_, _H_, ___, XXX, ___, _T_, ___
L9780:  .byte XXX, ___, XXX, ___, _H_, ___, XXX, _S_, _U_, _S_, XXX, ___, _H_, ___, XXX, ___
L9790:  .byte XXX, ___, _T_, ___, XXX, ___, _H_, _K_, _S_, _K_, _H_, ___, XXX, ___, _T_, ___
L97A0:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, _H_, XXX, _H_, XXX, ___, XXX, ___, XXX, ___
L97B0:  .byte XXX, ___, XXX, _S_, XXX, _F_, ___, ___, ___, ___, ___, _M_, XXX, _S_, XXX, ___
L97C0:  .byte XXX, ___, XXX, _T_, XXX, XXX, XXX, XXX, _H_, XXX, XXX, XXX, XXX, _T_, XXX, ___
L97D0:  .byte XXX, ___, ___, _U_, _T_, _S_, ___, ___, ___, ___, ___, _S_, _T_, _U_, ___, ___
L97E0:  .byte XXX, _H_, XXX, ___, XXX, XXX, XXX, _T_, XXX, _T_, XXX, XXX, XXX, ___, XXX, _H_
L97F0:  .byte XXX, _C_, _H_, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, _H_, _C_

;----------------------------------------------------------------------------------------------------

;Cave of Death, floor 1.
L9800:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L9810:  .byte XXX, _U_, ___, ___, XXX, _G_, ___, ___, ___, _G_, XXX, ___, XXX, ___, XXX, ___
L9820:  .byte XXX, ___, XXX, ___, XXX, XXX, XXX, ___, XXX, XXX, XXX, ___, ___, ___, ___, ___
L9830:  .byte XXX, ___, ___, _S_, ___, ___, ___, ___, ___, ___, ___, ___, ___, XXX, ___, XXX
L9840:  .byte XXX, XXX, XXX, ___, ___, XXX, XXX, XXX, XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX
L9850:  .byte XXX, _G_, XXX, ___, XXX, XXX, _C_, ___, XXX, ___, XXX, ___, ___, ___, ___, ___
L9860:  .byte XXX, ___, XXX, ___, XXX, _C_, ___, _G_, _H_, ___, _I_, ___, ___, XXX, ___, ___
L9870:  .byte XXX, ___, ___, ___, XXX, ___, _G_, ___, XXX, ___, XXX, ___, ___, ___, ___, ___
L9880:  .byte XXX, ___, XXX, ___, XXX, XXX, _H_, XXX, XXX, ___, XXX, XXX, XXX, ___, XXX, XXX
L9890:  .byte XXX, _G_, XXX, ___, ___, ___, ___, ___, ___, ___, XXX, ___, ___, ___, ___, ___
L98A0:  .byte XXX, XXX, XXX, ___, XXX, XXX, _I_, XXX, XXX, XXX, XXX, ___, ___, XXX, ___, ___
L98B0:  .byte XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, _D_, ___, ___, ___, ___
L98C0:  .byte XXX, XXX, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, XXX, XXX, XXX
L98D0:  .byte XXX, ___, ___, XXX, XXX, ___, XXX, ___, ___, ___, XXX, ___, XXX, _D_, ___, ___
L98E0:  .byte XXX, XXX, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, _T_, ___
L98F0:  .byte ___, ___, ___, XXX, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___

;----------------------------------------------------------------------------------------------------

;Cave of Death, floor 2.
L9900:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L9910:  .byte XXX, _C_, _H_, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, _H_, _C_
L9920:  .byte XXX, _H_, XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___, XXX, _H_
L9930:  .byte XXX, ___, ___, ___, XXX, ___, ___, ___, _H_, ___, ___, _M_, XXX, ___, ___, ___
L9940:  .byte XXX, ___, XXX, ___, XXX, ___, _F_, ___, XXX, ___, ___, ___, XXX, ___, XXX, ___
L9950:  .byte XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___
L9960:  .byte XXX, XXX, XXX, _T_, XXX, XXX, XXX, _H_, XXX, _H_, XXX, XXX, XXX, XXX, ___, XXX
L9970:  .byte XXX, _C_, ___, ___, ___, _C_, XXX, _H_, XXX, _H_, XXX, _C_, XXX, ___, ___, ___
L9980:  .byte XXX, ___, ___, XXX, ___, ___, XXX, _H_, XXX, _H_, XXX, ___, XXX, ___, XXX, ___
L9990:  .byte XXX, _C_, ___, ___, ___, _C_, XXX, _H_, XXX, _H_, XXX, ___, ___, ___, ___, ___
L99A0:  .byte XXX, XXX, XXX, _T_, XXX, XXX, XXX, _H_, XXX, _H_, XXX, XXX, _I_, XXX, XXX, ___
L99B0:  .byte XXX, ___, ___, ___, ___, ___, XXX, _H_, XXX, _H_, XXX, _U_, _S_, _D_, XXX, ___
L99C0:  .byte XXX, ___, XXX, XXX, XXX, XXX, XXX, ___, XXX, ___, _I_, _S_, _K_, _S_, _I_, ___
L99D0:  .byte XXX, ___, ___, ___, ___, ___, XXX, ___, ___, ___, XXX, _D_, _S_, _U_, XXX, ___
L99E0:  .byte XXX, _H_, XXX, ___, XXX, ___, ___, ___, XXX, XXX, XXX, XXX, _I_, XXX, XXX, _H_
L99F0:  .byte XXX, _C_, _H_, ___, ___, ___, XXX, ___, _H_, ___, ___, ___, ___, ___, _H_, _C_

;----------------------------------------------------------------------------------------------------

;Cave of Death, floor 3.
L9A00:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L9A10:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, _H_, ___, _H_, ___
L9A20:  .byte XXX, ___, _H_, _H_, _H_, _H_, _H_, _H_, _H_, _H_, _H_, ___, XXX, _H_, XXX, _H_
L9A30:  .byte XXX, ___, _H_, _H_, _H_, _H_, _H_, _H_, _H_, _H_, _H_, ___, XXX, ___, _H_, _T_
L9A40:  .byte XXX, ___, _H_, _H_, _T_, _H_, _H_, _H_, _T_, _H_, _H_, ___, XXX, _H_, XXX, _H_
L9A50:  .byte XXX, ___, _H_, _H_, _H_, _C_, _C_, _C_, _H_, _H_, _H_, ___, XXX, _T_, _H_, ___
L9A60:  .byte XXX, ___, _H_, _H_, _H_, _C_, _C_, _C_, _H_, _H_, _H_, ___, XXX, _H_, XXX, _H_
L9A70:  .byte XXX, ___, _H_, _H_, _H_, _C_, _C_, _C_, _H_, _H_, _H_, ___, XXX, ___, _H_, ___
L9A80:  .byte XXX, ___, _H_, _H_, _T_, _H_, _H_, _H_, _T_, _H_, _H_, ___, XXX, _H_, XXX, _H_
L9A90:  .byte XXX, ___, _H_, _H_, _H_, _H_, _H_, _H_, _H_, _H_, _H_, ___, XXX, _S_, _H_, ___
L9AA0:  .byte XXX, ___, _H_, _H_, _H_, _H_, _H_, _H_, _H_, _H_, _H_, ___, XXX, _H_, XXX, _H_
L9AB0:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, _D_, XXX, _U_, _H_, _S_
L9AC0:  .byte XXX, _H_, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, _H_
L9AD0:  .byte XXX, ___, _H_, ___, _H_, ___, _H_, _T_, _H_, _S_, _H_, _U_, XXX, _F_, _C_, _C_
L9AE0:  .byte XXX, _H_, XXX, _H_, XXX, _H_, XXX, _H_, XXX, _H_, XXX, _H_, XXX, _C_, _C_, _C_
L9AF0:  .byte XXX, ___, _H_, _T_, _H_, ___, _H_, ___, _H_, ___, _H_, _S_, _H_, _C_, _C_, _C_

;----------------------------------------------------------------------------------------------------

;Cave of Death, floor 4.
L9B00:  .byte XXX, _C_, XXX, ___, XXX, ___, XXX, ___, XXX, _G_, XXX, ___, XXX, ___, XXX, ___
L9B10:  .byte ___, ___, ___, _C_, ___, ___, ___, _C_, ___, ___, XXX, ___, XXX, ___, _C_, ___
L9B20:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___
L9B30:  .byte ___, ___, ___, _G_, ___, ___, ___, _K_, ___, ___, XXX, ___, XXX, _G_, ___, ___
L9B40:  .byte XXX, _C_, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___
L9B50:  .byte ___, ___, ___, _T_, ___, _D_, ___, _G_, ___, _C_, XXX, ___, XXX, ___, _C_, ___
L9B60:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___
L9B70:  .byte ___, _C_, ___, ___, ___, ___, ___, _C_, ___, ___, XXX, ___, XXX, _T_, ___, _K_
L9B80:  .byte XXX, ___, XXX, _C_, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___
L9B90:  .byte ___, ___, ___, ___, ___, _G_, ___, _K_, ___, ___, _H_, ___, _H_, ___, ___, ___
L9BA0:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, _H_, XXX, _S_, XXX, _H_, XXX, XXX
L9BB0:  .byte ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, _S_, _U_, _S_, ___, ___, ___
L9BC0:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, _H_, XXX, _S_, XXX, _H_, XXX, XXX
L9BD0:  .byte ___, _C_, ___, _K_, ___, ___, ___, _G_, ___, ___, _H_, ___, _H_, _C_, ___, _G_
L9BE0:  .byte XXX, ___, XXX, ___, XXX, _C_, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, _K_
L9BF0:  .byte ___, ___, ___, _G_, ___, _K_, ___, _T_, ___, _C_, XXX, ___, XXX, _K_, _G_, _T_

;----------------------------------------------------------------------------------------------------

;Cave of Death, floor 5.
L9C00:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L9C10:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, XXX, ___, ___, ___, ___, ___, ___, ___
L9C20:  .byte XXX, ___, XXX, XXX, _H_, XXX, XXX, ___, XXX, ___, XXX, XXX, XXX, XXX, XXX, _G_
L9C30:  .byte XXX, ___, XXX, ___, ___, ___, XXX, ___, XXX, ___, XXX, ___, ___, ___, XXX, _G_
L9C40:  .byte XXX, ___, _H_, ___, _F_, ___, _H_, ___, XXX, ___, XXX, ___, _F_, ___, XXX, _G_
L9C50:  .byte XXX, ___, XXX, ___, ___, _B_, XXX, ___, XXX, ___, XXX, ___, ___, ___, XXX, _G_
L9C60:  .byte XXX, ___, XXX, XXX, _H_, XXX, XXX, ___, XXX, ___, XXX, XXX, XXX, _H_, XXX, _G_
L9C70:  .byte XXX, ___, ___, ___, ___, ___, ___, _F_, XXX, ___, ___, ___, ___, ___, XXX, _G_
L9C80:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___, XXX, _G_
L9C90:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, XXX, _C_, _C_, _C_, XXX, ___, XXX, _G_
L9CA0:  .byte XXX, ___, XXX, XXX, XXX, XXX, XXX, ___, XXX, _C_, _C_, ___, XXX, ___, XXX, _G_
L9CB0:  .byte XXX, ___, XXX, ___, ___, ___, XXX, ___, XXX, _C_, ___, _D_, _S_, ___, XXX, _G_
L9CC0:  .byte XXX, ___, XXX, ___, _F_, ___, XXX, ___, XXX, XXX, XXX, _S_, XXX, ___, XXX, _G_
L9CD0:  .byte XXX, ___, XXX, ___, ___, ___, _H_, ___, ___, ___, ___, ___, ___, _F_, XXX, _G_
L9CE0:  .byte XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, _G_
L9CF0:  .byte XXX, ___, _G_, _G_, _G_, _G_, _G_, _G_, _G_, _G_, _G_, _G_, _G_, _G_, _G_, _G_

;----------------------------------------------------------------------------------------------------

;Cave of Death, floor 6.
L9D00:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L9D10:  .byte XXX, _C_, ___, _C_, ___, _C_, ___, _C_, ___, _C_, ___, _C_, ___, _C_, ___, _C_
L9D20:  .byte XXX, ___, XXX, _H_, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, _H_, XXX, ___
L9D30:  .byte XXX, _C_, _H_, _S_, ___, ___, ___, ___, ___, _S_, _T_, _T_, _T_, _S_, _H_, _C_
L9D40:  .byte XXX, ___, XXX, _T_, XXX, XXX, XXX, XXX, _H_, XXX, XXX, XXX, XXX, ___, XXX, ___
L9D50:  .byte XXX, _C_, XXX, _T_, XXX, _B_, ___, ___, _S_, _T_, _T_, _T_, XXX, ___, XXX, _C_
L9D60:  .byte XXX, ___, XXX, _T_, XXX, ___, XXX, XXX, _H_, XXX, XXX, _T_, XXX, ___, XXX, ___
L9D70:  .byte XXX, _C_, XXX, _S_, XXX, ___, XXX, ___, ___, ___, XXX, _T_, XXX, ___, XXX, _C_
L9D80:  .byte XXX, ___, XXX, ___, _H_, _S_, _H_, ___, ___, ___, _H_, _S_, _H_, ___, XXX, ___
L9D90:  .byte XXX, _C_, XXX, ___, XXX, _T_, XXX, ___, ___, ___, XXX, ___, XXX, _S_, XXX, _C_
L9DA0:  .byte XXX, ___, XXX, ___, XXX, _T_, XXX, XXX, _H_, XXX, XXX, ___, XXX, _T_, XXX, ___
L9DB0:  .byte XXX, _C_, XXX, ___, XXX, _T_, _T_, _T_, _S_, ___, ___, _U_, XXX, _T_, XXX, _C_
L9DC0:  .byte XXX, ___, XXX, ___, XXX, XXX, XXX, XXX, _H_, XXX, XXX, XXX, XXX, _T_, XXX, ___
L9DD0:  .byte XXX, _C_, _H_, _S_, _T_, _T_, _T_, _S_, ___, ___, ___, ___, ___, _S_, _H_, _C_
L9DE0:  .byte XXX, ___, XXX, _H_, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, _H_, XXX, ___
L9DF0:  .byte XXX, _C_, ___, _C_, ___, _C_, ___, _C_, ___, _C_, ___, _C_, ___, _C_, ___, _C_

;----------------------------------------------------------------------------------------------------

;Cave of Death, floor 7.
L9E00:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L9E10:  .byte XXX, ___, ___, ___, ___, ___, XXX, ___, ___, _T_, ___, ___, ___, ___, ___, _C_
L9E20:  .byte XXX, ___, _C_, ___, ___, ___, ___, _G_, ___, ___, ___, ___, ___, _T_, ___, ___
L9E30:  .byte XXX, _T_, _G_, XXX, ___, _C_, ___, ___, _T_, ___, _C_, ___, ___, ___, ___, ___
L9E40:  .byte XXX, ___, ___, ___, ___, _S_, ___, ___, ___, ___, ___, XXX, ___, _G_, ___, ___
L9E50:  .byte XXX, ___, ___, _C_, _S_, _U_, _S_, ___, _C_, _G_, ___, _T_, ___, ___, _C_, ___
L9E60:  .byte XXX, _C_, ___, ___, ___, _S_, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___
L9E70:  .byte XXX, ___, ___, ___, ___, ___, _T_, XXX, ___, ___, _T_, _C_, ___, ___, ___, ___
L9E80:  .byte XXX, ___, _T_, _G_, ___, ___, ___, _C_, ___, ___, ___, ___, XXX, _G_, ___, _T_
L9E90:  .byte XXX, ___, ___, ___, _C_, XXX, ___, ___, ___, _G_, ___, ___, ___, ___, ___, ___
L9EA0:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, _T_, ___, ___, ___, ___, _T_, _C_, ___
L9EB0:  .byte XXX, ___, _C_, ___, ___, ___, ___, ___, _C_, ___, ___, _D_, ___, ___, ___, ___
L9EC0:  .byte XXX, ___, XXX, _T_, ___, ___, _C_, ___, ___, ___, XXX, ___, ___, ___, ___, ___
L9ED0:  .byte XXX, ___, ___, _G_, ___, ___, XXX, ___, ___, ___, ___, ___, ___, ___, ___, XXX
L9EE0:  .byte XXX, _T_, _C_, ___, ___, ___, ___, _T_, ___, _C_, ___, ___, _T_, ___, _G_, ___
L9EF0:  .byte XXX, ___, ___, XXX, ___, _C_, ___, ___, ___, ___, ___, ___, ___, _C_, ___, ___

;----------------------------------------------------------------------------------------------------

;Cave of Death, floor 8.
L9F00:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L9F10:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, XXX, ___, ___, ___, XXX, _C_, XXX, _C_
L9F20:  .byte XXX, ___, XXX, _H_, XXX, ___, XXX, ___, ___, ___, XXX, ___, XXX, ___, _C_, _C_
L9F30:  .byte XXX, ___, _H_, _M_, _H_, ___, XXX, ___, XXX, ___, XXX, ___, ___, ___, XXX, _C_
L9F40:  .byte XXX, ___, XXX, _H_, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, _C_, _C_
L9F50:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, XXX, _C_, XXX, _C_
L9F60:  .byte XXX, ___, XXX, XXX, XXX, ___, XXX, XXX, _H_, XXX, XXX, XXX, XXX, XXX, XXX, XXX
L9F70:  .byte XXX, ___, ___, ___, ___, ___, XXX, _T_, _T_, _T_, _T_, _T_, _T_, _T_, _T_, _T_
L9F80:  .byte XXX, XXX, ___, XXX, XXX, ___, _H_, _T_, XXX, XXX, XXX, XXX, XXX, XXX, XXX, _T_
L9F90:  .byte XXX, ___, ___, ___, ___, ___, XXX, _T_, XXX, _F_, _H_, ___, ___, ___, XXX, _T_
L9FA0:  .byte XXX, ___, XXX, XXX, XXX, ___, XXX, _T_, XXX, _H_, XXX, _H_, XXX, ___, XXX, _T_
L9FB0:  .byte XXX, ___, ___, ___, ___, ___, XXX, _T_, XXX, ___, _H_, _U_, XXX, ___, XXX, _T_
L9FC0:  .byte XXX, XXX, XXX, ___, XXX, XXX, XXX, _T_, XXX, ___, XXX, XXX, XXX, ___, _H_, _S_
L9FD0:  .byte XXX, _C_, ___, ___, ___, _C_, XXX, _T_, XXX, ___, ___, ___, ___, ___, XXX, ___
L9FE0:  .byte XXX, XXX, _C_, XXX, _C_, XXX, XXX, _T_, XXX, XXX, XXX, XXX, _H_, XXX, XXX, ___
L9FF0:  .byte XXX, _C_, _C_, _C_, _C_, _C_, XXX, _T_, _T_, _T_, _T_, _T_, _S_, ___, ___, _F_

;----------------------------------------------------------------------------------------------------

;Cave of Fool, floor 1.
LA000:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
LA010:  .byte XXX, _U_, ___, _S_, ___, _H_, _C_, ___, ___, ___, _I_, ___, ___, ___, _I_, ___
LA020:  .byte XXX, XXX, XXX, XXX, ___, XXX, XXX, ___, XXX, XXX, XXX, XXX, XXX, ___, XXX, _I_
LA030:  .byte XXX, ___, ___, ___, ___, ___, XXX, ___, ___, _I_, ___, ___, XXX, ___, ___, ___
LA040:  .byte XXX, ___, XXX, XXX, XXX, ___, XXX, ___, XXX, XXX, XXX, ___, XXX, XXX, XXX, ___
LA050:  .byte XXX, _I_, XXX, ___, ___, ___, XXX, ___, XXX, ___, ___, ___, ___, ___, ___, ___
LA060:  .byte XXX, ___, XXX, _I_, XXX, _H_, XXX, ___, XXX, _I_, XXX, XXX, XXX, XXX, XXX, ___
LA070:  .byte XXX, ___, ___, ___, XXX, ___, XXX, ___, XXX, ___, ___, _T_, ___, ___, XXX, _I_
LA080:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, XXX, XXX, XXX, XXX, _I_, XXX, ___
LA090:  .byte XXX, _H_, XXX, ___, ___, ___, ___, ___, _H_, ___, ___, ___, ___, ___, _I_, ___
LA0A0:  .byte XXX, ___, XXX, XXX, XXX, XXX, XXX, ___, XXX, ___, XXX, XXX, XXX, ___, XXX, ___
LA0B0:  .byte XXX, ___, ___, _I_, ___, ___, ___, ___, XXX, ___, XXX, _D_, XXX, ___, XXX, _I_
LA0C0:  .byte XXX, ___, XXX, XXX, XXX, ___, XXX, XXX, XXX, ___, XXX, ___, XXX, ___, XXX, ___
LA0D0:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, XXX, ___, _H_, ___, ___, ___, ___, ___
LA0E0:  .byte XXX, _I_, XXX, ___, XXX, XXX, XXX, ___, XXX, ___, XXX, XXX, XXX, ___, XXX, _H_
LA0F0:  .byte XXX, ___, _I_, ___, ___, ___, ___, ___, _H_, ___, ___, ___, ___, ___, _H_, _F_

;----------------------------------------------------------------------------------------------------

;Cave of Fool, floor 2.
LA100:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
LA110:  .byte XXX, _C_, _H_, ___, ___, ___, ___, ___, XXX, ___, ___, _I_, ___, ___, _H_, _C_
LA120:  .byte XXX, _H_, XXX, ___, XXX, XXX, XXX, ___, XXX, ___, XXX, XXX, XXX, ___, XXX, _H_
LA130:  .byte XXX, ___, ___, ___, ___, ___, XXX, _I_, XXX, ___, ___, ___, XXX, ___, ___, ___
LA140:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, XXX, XXX, ___
LA150:  .byte XXX, ___, XXX, ___, _T_, _D_, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, _I_
LA160:  .byte XXX, ___, XXX, XXX, XXX, XXX, XXX, _I_, XXX, _I_, XXX, XXX, XXX, ___, XXX, ___
LA170:  .byte XXX, ___, ___, _I_, ___, ___, _I_, ___, ___, ___, _I_, ___, ___, ___, ___, ___
LA180:  .byte XXX, XXX, XXX, XXX, XXX, ___, XXX, ___, _S_, ___, XXX, ___, XXX, XXX, XXX, XXX
LA190:  .byte XXX, ___, ___, ___, ___, ___, _I_, ___, ___, ___, _I_, ___, ___, _I_, ___, ___
LA1A0:  .byte XXX, ___, XXX, ___, XXX, XXX, XXX, _I_, XXX, _I_, XXX, XXX, XXX, XXX, XXX, ___
LA1B0:  .byte XXX, _I_, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, _U_, ___, ___, XXX, ___
LA1C0:  .byte XXX, ___, XXX, XXX, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___
LA1D0:  .byte XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, _I_, XXX, ___, ___, ___, ___, ___
LA1E0:  .byte XXX, _H_, XXX, ___, XXX, XXX, XXX, ___, XXX, ___, XXX, XXX, XXX, ___, XXX, _H_
LA1F0:  .byte XXX, _C_, _H_, ___, ___, _I_, ___, ___, XXX, ___, ___, ___, ___, ___, _H_, _C_

;----------------------------------------------------------------------------------------------------

;Cave of Fool, floor 3.
LA200:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
LA210:  .byte XXX, XXX, ___, ___, _H_, ___, ___, ___, _C_, _C_, ___, ___, _H_, ___, ___, XXX
LA220:  .byte XXX, ___, _T_, ___, XXX, _C_, _C_, ___, ___, ___, _C_, _C_, XXX, ___, _T_, ___
LA230:  .byte XXX, ___, ___, XXX, XXX, XXX, XXX, XXX, _H_, XXX, XXX, XXX, XXX, XXX, ___, ___
LA240:  .byte XXX, _I_, XXX, XXX, ___, ___, ___, XXX, ___, XXX, ___, _C_, _C_, XXX, XXX, _I_
LA250:  .byte XXX, ___, ___, XXX, ___, _B_, ___, XXX, ___, _H_, ___, _C_, ___, XXX, ___, ___
LA260:  .byte XXX, ___, ___, XXX, ___, ___, _T_, XXX, XXX, XXX, _C_, ___, ___, XXX, XXX, ___
LA270:  .byte XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, ___
LA280:  .byte XXX, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, _H_, ___, ___, ___, XXX, ___
LA290:  .byte XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, XXX, XXX, XXX, ___, ___, ___
LA2A0:  .byte XXX, XXX, XXX, _H_, XXX, XXX, XXX, XXX, XXX, ___, XXX, ___, XXX, XXX, XXX, XXX
LA2B0:  .byte XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, _H_, XXX, _D_, ___, _S_, ___, ___
LA2C0:  .byte XXX, ___, XXX, ___, _H_, ___, XXX, ___, ___, ___, XXX, ___, XXX, XXX, XXX, ___
LA2D0:  .byte XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, _H_, XXX, ___, XXX, ___
LA2E0:  .byte XXX, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___
LA2F0:  .byte XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___

;----------------------------------------------------------------------------------------------------

;Cave of Fool, floor 4.
LA300:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
LA310:  .byte XXX, XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___
LA320:  .byte XXX, ___, ___, ___, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___
LA330:  .byte XXX, ___, ___, _S_, _I_, ___, ___, ___, XXX, ___, _I_, ___, _I_, ___, XXX, ___
LA340:  .byte XXX, ___, XXX, _I_, XXX, ___, ___, ___, XXX, ___, XXX, _I_, XXX, _I_, XXX, ___
LA350:  .byte XXX, ___, XXX, ___, ___, _U_, XXX, ___, XXX, ___, XXX, ___, _I_, ___, _I_, ___
LA360:  .byte XXX, ___, XXX, ___, ___, XXX, XXX, ___, XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX
LA370:  .byte XXX, ___, XXX, ___, ___, ___, ___, _D_, XXX, ___, ___, ___, ___, ___, ___, ___
LA380:  .byte XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___
LA390:  .byte XXX, ___, XXX, ___, ___, ___, ___, ___, XXX, ___, ___, _K_, ___, ___, XXX, ___
LA3A0:  .byte XXX, ___, XXX, _I_, XXX, XXX, XXX, ___, XXX, ___, XXX, _H_, XXX, ___, XXX, ___
LA3B0:  .byte XXX, ___, XXX, ___, _I_, ___, XXX, ___, XXX, _K_, _H_, _U_, _H_, _K_, XXX, ___
LA3C0:  .byte XXX, ___, XXX, _I_, XXX, _I_, XXX, ___, XXX, ___, XXX, _H_, XXX, _H_, XXX, ___
LA3D0:  .byte XXX, ___, XXX, ___, _I_, ___, XXX, ___, XXX, ___, ___, _K_, _H_, ___, ___, ___
LA3E0:  .byte XXX, ___, XXX, XXX, XXX, _I_, XXX, ___, XXX, XXX, XXX, XXX, XXX, ___, ___, ___
LA3F0:  .byte XXX, ___, ___, ___, ___, ___, XXX, ___, ___, ___, ___, ___, ___, ___, ___, XXX

;----------------------------------------------------------------------------------------------------

;Cave of Fool, floor 5.
LA400:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
LA410:  .byte XXX, ___, _T_, ___, ___, _T_, ___, ___, ___, _T_, ___, ___, ___, ___, ___, _T_
LA420:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___
LA430:  .byte XXX, _T_, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, _T_, ___, ___
LA440:  .byte XXX, ___, XXX, ___, XXX, _G_, XXX, _G_, XXX, _G_, XXX, ___, XXX, ___, XXX, ___
LA450:  .byte XXX, ___, ___, ___, _G_, ___, ___, ___, ___, ___, _G_, ___, ___, ___, ___, _T_
LA460:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, _S_, XXX, ___, XXX, ___, XXX, ___, XXX, ___
LA470:  .byte XXX, _T_, ___, ___, _G_, ___, _S_, _B_, _S_, ___, _G_, ___, ___, _T_, ___, ___
LA480:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, _S_, XXX, ___, XXX, ___, XXX, ___, XXX, ___
LA490:  .byte XXX, ___, _T_, ___, _G_, ___, ___, ___, ___, ___, _G_, ___, ___, ___, ___, _T_
LA4A0:  .byte XXX, ___, XXX, ___, XXX, _G_, XXX, _G_, XXX, _G_, XXX, XXX, XXX, XXX, XXX, XXX
LA4B0:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, XXX, _D_, _K_, _K_, _K_, _K_
LA4C0:  .byte XXX, ___, XXX, _T_, XXX, ___, XXX, ___, XXX, ___, XXX, _K_, XXX, XXX, XXX, _H_
LA4D0:  .byte XXX, ___, ___, ___, ___, ___, ___, _T_, ___, ___, XXX, _K_, XXX, _F_, ___, ___
LA4E0:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, _K_, XXX, ___, ___, ___
LA4F0:  .byte XXX, _T_, ___, ___, ___, ___, ___, ___, ___, _T_, XXX, _K_, _H_, ___, ___, _F_

;----------------------------------------------------------------------------------------------------

;Cave of Fool, floor 6.
LA500:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
LA510:  .byte XXX, _D_, ___, ___, XXX, _C_, _C_, _C_, ___, ___, ___, ___, ___, ___, XXX, _D_
LA520:  .byte XXX, ___, XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___, XXX, ___
LA530:  .byte XXX, ___, XXX, ___, ___, ___, ___, ___, ___, ___, ___, _C_, XXX, ___, XXX, ___
LA540:  .byte XXX, ___, XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, XXX, _C_, XXX, ___, XXX, ___
LA550:  .byte XXX, ___, XXX, ___, XXX, _D_, ___, ___, ___, ___, XXX, _C_, XXX, ___, XXX, ___
LA560:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, _H_, XXX, ___, XXX, XXX, XXX, ___, XXX, ___
LA570:  .byte XXX, ___, XXX, ___, XXX, ___, _H_, _U_, _H_, ___, XXX, ___, XXX, ___, XXX, ___
LA580:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, _H_, XXX, ___, XXX, _I_, XXX, ___, XXX, ___
LA590:  .byte XXX, ___, XXX, ___, XXX, ___, ___, ___, ___, ___, XXX, _D_, XXX, ___, ___, ___
LA5A0:  .byte XXX, ___, XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, XXX, _S_, XXX, XXX, XXX, XXX
LA5B0:  .byte XXX, ___, XXX, _C_, _C_, _C_, XXX, ___, _I_, _D_, _S_, _U_, _S_, _D_, _I_, ___
LA5C0:  .byte XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, _S_, XXX, XXX, XXX, XXX
LA5D0:  .byte XXX, ___, ___, ___, ___, ___, ___, _C_, _C_, _C_, XXX, _D_, XXX, _D_, ___, ___
LA5E0:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, _I_, XXX, ___, _F_, ___
LA5F0:  .byte XXX, _D_, ___, ___, ___, ___, ___, ___, ___, ___, _H_, ___, _H_, ___, ___, _D_

;----------------------------------------------------------------------------------------------------

;Cave of Fool, floor 7.
LA600:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
LA610:  .byte XXX, _U_, _S_, ___, ___, ___, ___, _T_, ___, ___, ___, ___, ___, ___, _S_, _U_
LA620:  .byte XXX, _S_, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, _S_
LA630:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___
LA640:  .byte XXX, ___, XXX, ___, XXX, _S_, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___
LA650:  .byte XXX, ___, ___, ___, _S_, _U_, _S_, ___, ___, ___, ___, _T_, ___, ___, ___, ___
LA660:  .byte XXX, ___, XXX, ___, XXX, _S_, XXX, _T_, XXX, ___, XXX, ___, XXX, ___, XXX, ___
LA670:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, _T_
LA680:  .byte XXX, _T_, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, _S_, XXX, ___, XXX, ___
LA690:  .byte XXX, ___, ___, ___, ___, _T_, ___, ___, ___, ___, _S_, _U_, _S_, ___, ___, ___
LA6A0:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, _S_, XXX, _S_, XXX, _S_, XXX, ___
LA6B0:  .byte XXX, ___, ___, _T_, ___, ___, ___, ___, _S_, _U_, _S_, _D_, _S_, _U_, _S_, ___
LA6C0:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, _S_, XXX, _S_, XXX, _S_, XXX, ___
LA6D0:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, _S_, _U_, _S_, _U_, _S_, ___
LA6E0:  .byte XXX, _S_, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, _S_, XXX, _S_, XXX, _S_
LA6F0:  .byte XXX, _U_, _S_, ___, ___, ___, ___, _T_, ___, ___, ___, ___, ___, ___, _S_, _U_

;----------------------------------------------------------------------------------------------------

;Cave of Fool, floor 8.
LA700:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
LA710:  .byte XXX, _C_, _C_, _C_, _C_, _K_, _H_, ___, ___, ___, ___, _H_, _K_, _C_, _C_, _C_
LA720:  .byte XXX, _C_, _C_, XXX, _C_, _C_, XXX, _F_, _F_, _F_, _F_, XXX, _C_, _C_, _C_, _C_
LA730:  .byte XXX, _C_, _C_, _C_, _C_, _T_, XXX, XXX, XXX, XXX, XXX, XXX, _C_, _C_, XXX, _C_
LA740:  .byte XXX, _C_, _C_, _C_, _T_, ___, ___, ___, _G_, ___, ___, ___, _T_, _C_, _C_, _C_
LA750:  .byte XXX, _C_, _C_, _T_, ___, ___, ___, ___, ___, ___, ___, ___, ___, _T_, _C_, _C_
LA760:  .byte XXX, _C_, _T_, ___, ___, ___, XXX, ___, ___, ___, ___, ___, ___, ___, _T_, _C_
LA770:  .byte XXX, _T_, ___, ___, ___, ___, ___, ___, ___, ___, XXX, _G_, ___, ___, ___, _T_
LA780:  .byte XXX, ___, XXX, ___, ___, ___, ___, XXX, _H_, XXX, ___, ___, ___, ___, ___, ___
LA790:  .byte XXX, _G_, ___, ___, ___, XXX, ___, _H_, _M_, _H_, ___, ___, ___, XXX, ___, _G_
LA7A0:  .byte XXX, ___, ___, ___, ___, ___, ___, XXX, _H_, XXX, ___, _S_, ___, ___, ___, ___
LA7B0:  .byte XXX, _T_, ___, ___, ___, ___, _G_, ___, ___, ___, _S_, _U_, _S_, ___, _G_, _T_
LA7C0:  .byte XXX, _C_, _T_, ___, ___, ___, XXX, ___, ___, ___, ___, _S_, ___, ___, _T_, _C_
LA7D0:  .byte XXX, _C_, _C_, _T_, ___, ___, ___, ___, XXX, ___, ___, ___, ___, _T_, _C_, _C_
LA7E0:  .byte XXX, _C_, _C_, _C_, _T_, ___, ___, ___, ___, ___, ___, _G_, _T_, _C_, _C_, _C_
LA7F0:  .byte XXX, _C_, _C_, _C_, _C_, _T_, ___, ___, _G_, ___, ___, _T_, _C_, _C_, _C_, _C_

;----------------------------------------------------------------------------------------------------

;Cave of Sol, floor 1.
LA800:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
LA810:  .byte XXX, _U_, _S_, ___, XXX, ___, ___, ___, ___, _I_, ___, XXX, ___, _C_, _C_, _C_
LA820:  .byte XXX, _S_, ___, ___, _H_, ___, XXX, XXX, XXX, ___, _H_, ___, ___, ___, _C_, _C_
LA830:  .byte XXX, ___, ___, _F_, XXX, ___, ___, ___, _I_, ___, XXX, ___, ___, ___, ___, _C_
LA840:  .byte XXX, XXX, _H_, XXX, XXX, XXX, XXX, XXX, XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX
LA850:  .byte XXX, ___, ___, ___, XXX, _C_, _C_, _K_, XXX, ___, ___, ___, ___, ___, ___, ___
LA860:  .byte XXX, ___, XXX, ___, XXX, _C_, XXX, _H_, XXX, XXX, XXX, ___, XXX, XXX, XXX, ___
LA870:  .byte XXX, ___, XXX, ___, XXX, _K_, _H_, _T_, ___, ___, ___, ___, XXX, ___, ___, ___
LA880:  .byte XXX, _I_, XXX, _I_, XXX, XXX, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, XXX
LA890:  .byte XXX, ___, ___, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, XXX, ___, ___, ___
LA8A0:  .byte XXX, XXX, _H_, XXX, XXX, ___, XXX, ___, XXX, XXX, XXX, ___, XXX, XXX, XXX, _H_
LA8B0:  .byte XXX, ___, ___, ___, XXX, ___, ___, ___, ___, ___, ___, _D_, ___, _G_, ___, ___
LA8C0:  .byte XXX, ___, ___, ___, XXX, ___, XXX, XXX, XXX, XXX, XXX, ___, XXX, XXX, _H_, XXX
LA8D0:  .byte XXX, _C_, ___, ___, XXX, ___, _H_, ___, ___, ___, XXX, _G_, XXX, ___, ___, _C_
LA8E0:  .byte XXX, _C_, _C_, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, _H_, ___, _C_, _C_
LA8F0:  .byte XXX, _C_, _C_, _C_, XXX, ___, ___, ___, XXX, ___, _H_, ___, XXX, _C_, _C_, _C_

;----------------------------------------------------------------------------------------------------

;Cave of Sol, floor 2.
LA900:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
LA910:  .byte XXX, _S_, ___, ___, ___, ___, ___, ___, _K_, ___, ___, ___, ___, ___, ___, _S_
LA920:  .byte XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, _H_, XXX, XXX, XXX, XXX, XXX, XXX, ___
LA930:  .byte XXX, ___, XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, XXX, ___
LA940:  .byte XXX, ___, XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, XXX, ___
LA950:  .byte XXX, ___, XXX, ___, ___, _D_, ___, ___, ___, ___, ___, _D_, ___, ___, XXX, ___
LA960:  .byte XXX, ___, XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, XXX, ___
LA970:  .byte XXX, ___, XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, XXX, ___
LA980:  .byte XXX, _K_, _H_, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, _H_, _K_
LA990:  .byte XXX, ___, XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, XXX, ___
LA9A0:  .byte XXX, ___, XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, XXX, ___
LA9B0:  .byte XXX, ___, XXX, ___, ___, _D_, ___, ___, ___, ___, ___, _U_, ___, ___, XXX, ___
LA9C0:  .byte XXX, ___, XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, XXX, ___
LA9D0:  .byte XXX, ___, XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, XXX, ___
LA9E0:  .byte XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, _H_, XXX, XXX, XXX, XXX, XXX, XXX, ___
LA9F0:  .byte XXX, _S_, ___, ___, ___, ___, ___, ___, _K_, ___, ___, ___, ___, ___, ___, _S_

;----------------------------------------------------------------------------------------------------

;Cave of Sol, floor 3.
LAA00:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
LAA10:  .byte XXX, _S_, _H_, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, _H_, _S_
LAA20:  .byte XXX, _H_, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, _H_
LAA30:  .byte XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___
LAA40:  .byte XXX, ___, XXX, XXX, XXX, XXX, XXX, ___, XXX, ___, XXX, XXX, XXX, ___, XXX, XXX
LAA50:  .byte XXX, ___, ___, ___, XXX, _U_, XXX, ___, ___, ___, XXX, _U_, XXX, ___, ___, ___
LAA60:  .byte XXX, XXX, XXX, ___, XXX, ___, XXX, XXX, XXX, XXX, XXX, ___, XXX, XXX, XXX, ___
LAA70:  .byte XXX, ___, ___, ___, XXX, ___, ___, ___, ___, _H_, ___, ___, ___, _H_, ___, ___
LAA80:  .byte XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, _T_, XXX, XXX, XXX, XXX, XXX, XXX, ___
LAA90:  .byte XXX, ___, ___, _H_, ___, ___, ___, _H_, ___, ___, ___, ___, XXX, ___, ___, ___
LAAA0:  .byte XXX, ___, XXX, XXX, XXX, ___, XXX, XXX, XXX, XXX, XXX, ___, XXX, XXX, XXX, ___
LAAB0:  .byte XXX, ___, ___, ___, XXX, _U_, XXX, ___, ___, ___, XXX, _D_, XXX, ___, ___, ___
LAAC0:  .byte XXX, ___, XXX, XXX, XXX, XXX, XXX, ___, XXX, ___, XXX, XXX, XXX, XXX, XXX, ___
LAAD0:  .byte XXX, ___, ___, ___, _H_, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___
LAAE0:  .byte XXX, _H_, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, _H_
LAAF0:  .byte XXX, _S_, _H_, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, _H_, _S_

;----------------------------------------------------------------------------------------------------

;Cave of Sol, floor 4.
LAB00:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
LAB10:  .byte XXX, _D_, ___, ___, XXX, _C_, ___, ___, ___, ___, ___, _C_, XXX, ___, ___, _D_
LAB20:  .byte XXX, ___, ___, ___, XXX, XXX, XXX, ___, _F_, ___, XXX, XXX, XXX, ___, ___, ___
LAB30:  .byte XXX, ___, ___, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, ___, ___
LAB40:  .byte XXX, XXX, XXX, ___, XXX, _H_, XXX, _H_, XXX, _H_, XXX, _H_, XXX, ___, XXX, XXX
LAB50:  .byte XXX, _C_, XXX, ___, _H_, ___, ___, ___, ___, ___, ___, ___, _H_, ___, XXX, _C_
LAB60:  .byte XXX, ___, XXX, XXX, XXX, ___, ___, ___, ___, ___, ___, ___, XXX, XXX, XXX, ___
LAB70:  .byte XXX, ___, ___, ___, _H_, ___, ___, XXX, _H_, XXX, ___, ___, _H_, ___, ___, ___
LAB80:  .byte XXX, ___, _F_, ___, XXX, ___, ___, XXX, _C_, XXX, ___, ___, XXX, ___, _F_, ___
LAB90:  .byte XXX, ___, ___, ___, _H_, ___, ___, XXX, XXX, XXX, ___, ___, _H_, ___, ___, ___
LABA0:  .byte XXX, ___, XXX, XXX, XXX, ___, ___, ___, ___, ___, ___, ___, XXX, XXX, XXX, ___
LABB0:  .byte XXX, _C_, XXX, ___, _H_, ___, ___, ___, ___, ___, ___, _U_, _H_, ___, XXX, _C_
LABC0:  .byte XXX, XXX, XXX, ___, XXX, _H_, XXX, _H_, XXX, _H_, XXX, _H_, XXX, ___, XXX, XXX
LABD0:  .byte XXX, ___, ___, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, ___, ___
LABE0:  .byte XXX, ___, ___, ___, XXX, XXX, XXX, ___, _F_, ___, XXX, XXX, XXX, ___, ___, ___
LABF0:  .byte XXX, _D_, ___, ___, XXX, ___, ___, ___, ___, ___, ___, ___, XXX, ___, ___, _D_

;----------------------------------------------------------------------------------------------------

;Cave of Sol, floor 5.
LAC00:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
LAC10:  .byte XXX, _U_, _T_, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, _T_, _U_
LAC20:  .byte XXX, _T_, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, _T_
LAC30:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___
LAC40:  .byte XXX, ___, XXX, ___, _F_, ___, XXX, ___, _F_, ___, XXX, ___, _F_, ___, XXX, ___
LAC50:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___
LAC60:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___
LAC70:  .byte XXX, ___, ___, ___, ___, ___, ___, _S_, ___, _S_, ___, ___, ___, ___, ___, ___
LAC80:  .byte XXX, ___, XXX, ___, _F_, ___, XXX, ___, _D_, ___, XXX, ___, _F_, ___, XXX, ___
LAC90:  .byte XXX, ___, ___, ___, ___, ___, ___, _S_, ___, _S_, ___, ___, ___, ___, ___, ___
LACA0:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___
LACB0:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___
LACC0:  .byte XXX, ___, XXX, ___, _F_, ___, XXX, ___, _F_, ___, XXX, ___, _F_, ___, XXX, ___
LACD0:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___
LACE0:  .byte XXX, _T_, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, _T_
LACF0:  .byte XXX, _U_, _T_, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, _T_, _U_

;----------------------------------------------------------------------------------------------------

;Cave of Sol, floor 6.
LAD00:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
LAD10:  .byte XXX, _D_, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, _D_
LAD20:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, ___, ___, ___, XXX, ___, XXX, ___, XXX, ___
LAD30:  .byte XXX, ___, ___, ___, _H_, ___, XXX, ___, ___, ___, XXX, ___, _H_, ___, ___, ___
LAD40:  .byte XXX, XXX, XXX, _H_, XXX, ___, XXX, XXX, ___, XXX, XXX, ___, XXX, _H_, XXX, XXX
LAD50:  .byte XXX, ___, ___, ___, ___, ___, _C_, XXX, _I_, XXX, _C_, ___, ___, ___, ___, ___
LAD60:  .byte XXX, ___, XXX, XXX, XXX, _C_, XXX, XXX, ___, XXX, XXX, _C_, XXX, XXX, XXX, ___
LAD70:  .byte XXX, ___, ___, ___, XXX, XXX, XXX, _F_, _S_, _F_, XXX, XXX, XXX, ___, ___, ___
LAD80:  .byte XXX, XXX, ___, ___, ___, _I_, ___, _S_, _U_, _S_, ___, _I_, ___, ___, ___, XXX
LAD90:  .byte XXX, ___, ___, ___, XXX, XXX, XXX, _F_, _S_, _F_, XXX, XXX, XXX, ___, ___, ___
LADA0:  .byte XXX, ___, XXX, XXX, XXX, _C_, XXX, XXX, ___, XXX, XXX, _C_, XXX, XXX, XXX, ___
LADB0:  .byte XXX, ___, ___, ___, ___, ___, _C_, XXX, _I_, XXX, _C_, ___, ___, ___, ___, ___
LADC0:  .byte XXX, XXX, XXX, _H_, XXX, ___, XXX, XXX, ___, XXX, XXX, ___, XXX, _H_, XXX, XXX
LADD0:  .byte XXX, ___, ___, ___, _H_, ___, XXX, ___, ___, ___, XXX, ___, _H_, ___, ___, ___
LADE0:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, ___, ___, ___, XXX, ___, XXX, ___, XXX, ___
LADF0:  .byte XXX, _D_, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, _D_

;----------------------------------------------------------------------------------------------------

;Cave of Sol, floor 7.
LAE00:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
LAE10:  .byte XXX, _U_, _S_, ___, ___, XXX, _G_, ___, _D_, ___, _G_, XXX, ___, ___, _S_, _U_
LAE20:  .byte XXX, _S_, XXX, ___, XXX, XXX, XXX, ___, XXX, ___, XXX, XXX, XXX, ___, XXX, _S_
LAE30:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___
LAE40:  .byte XXX, ___, XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___, XXX, ___
LAE50:  .byte XXX, XXX, XXX, ___, XXX, _G_, ___, ___, ___, _F_, ___, _G_, XXX, ___, XXX, XXX
LAE60:  .byte XXX, _G_, XXX, ___, XXX, ___, _F_, XXX, ___, XXX, ___, ___, XXX, ___, XXX, _G_
LAE70:  .byte XXX, ___, ___, ___, XXX, ___, XXX, XXX, ___, XXX, XXX, ___, XXX, ___, ___, ___
LAE80:  .byte XXX, _D_, XXX, ___, XXX, ___, ___, ___, _D_, ___, ___, ___, XXX, ___, XXX, _D_
LAE90:  .byte XXX, ___, ___, ___, XXX, ___, XXX, XXX, ___, XXX, XXX, ___, XXX, ___, ___, ___
LAEA0:  .byte XXX, _G_, XXX, ___, XXX, ___, ___, XXX, _F_, XXX, ___, ___, XXX, ___, XXX, _G_
LAEB0:  .byte XXX, XXX, XXX, ___, XXX, _G_, ___, _F_, ___, ___, ___, _G_, XXX, ___, XXX, XXX
LAEC0:  .byte XXX, ___, XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___, XXX, ___
LAED0:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___, ___
LAEE0:  .byte XXX, _S_, XXX, ___, XXX, XXX, XXX, ___, XXX, ___, XXX, XXX, XXX, ___, XXX, _S_
LAEF0:  .byte XXX, _U_, _S_, ___, ___, XXX, _G_, ___, _D_, ___, _G_, XXX, ___, ___, _S_, _U_

;----------------------------------------------------------------------------------------------------

;Cave of Sol, floor 8.
LAF00:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
LAF10:  .byte XXX, _C_, XXX, ___, ___, _K_, ___, _S_, _U_, XXX, _F_, ___, ___, ___, ___, ___
LAF20:  .byte XXX, _C_, XXX, ___, ___, XXX, XXX, XXX, XXX, XXX, XXX, ___, XXX, ___, XXX, _C_
LAF30:  .byte XXX, ___, ___, _K_, XXX, XXX, _C_, _C_, XXX, ___, ___, ___, ___, ___, XXX, XXX
LAF40:  .byte XXX, _K_, XXX, XXX, XXX, ___, ___, _C_, XXX, ___, ___, XXX, XXX, ___, XXX, _C_
LAF50:  .byte XXX, ___, ___, _K_, XXX, ___, ___, XXX, XXX, ___, ___, ___, XXX, ___, ___, _K_
LAF60:  .byte XXX, _C_, XXX, ___, XXX, _K_, XXX, XXX, XXX, XXX, XXX, ___, XXX, XXX, XXX, ___
LAF70:  .byte XXX, XXX, XXX, _K_, ___, ___, _H_, _H_, ___, _H_, _H_, ___, ___, _K_, ___, _S_
LAF80:  .byte XXX, _U_, XXX, XXX, XXX, XXX, XXX, XXX, _U_, XXX, XXX, XXX, XXX, XXX, XXX, _U_
LAF90:  .byte XXX, _S_, _K_, ___, XXX, ___, _H_, _H_, ___, _H_, _H_, ___, ___, ___, XXX, XXX
LAFA0:  .byte XXX, _K_, XXX, ___, XXX, ___, XXX, XXX, XXX, XXX, XXX, _C_, XXX, ___, XXX, _C_
LAFB0:  .byte XXX, _C_, XXX, ___, _K_, ___, ___, ___, XXX, _C_, XXX, XXX, XXX, _K_, ___, ___
LAFC0:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___, XXX, ___, XXX, _C_, XXX, XXX, XXX, _K_
LAFD0:  .byte XXX, ___, _K_, ___, ___, ___, _K_, ___, XXX, ___, _K_, ___, XXX, _C_, XXX, ___
LAFE0:  .byte XXX, _K_, XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___, XXX, XXX, XXX, ___, XXX, ___
LAFF0:  .byte XXX, ___, ___, _C_, _C_, _C_, _M_, XXX, _U_, _S_, ___, _K_, ___, ___, ___, _M_

;----------------------------------------------------------------------------------------------------

;Cave of Moon, floor 1.
LB000:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
LB010:  .byte XXX, _U_, ___, ___, XXX, _F_, _H_, ___, ___, ___, ___, ___, ___, ___, ___, ___
LB020:  .byte XXX, ___, XXX, ___, XXX, XXX, XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___
LB030:  .byte XXX, ___, ___, _S_, ___, ___, XXX, ___, ___, ___, ___, ___, ___, ___, ___, ___
LB040:  .byte XXX, XXX, XXX, ___, XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, XXX, _I_, XXX, XXX
LB050:  .byte XXX, _F_, XXX, ___, ___, ___, ___, ___, ___, ___, XXX, ___, ___, ___, ___, ___
LB060:  .byte XXX, _H_, XXX, XXX, XXX, ___, XXX, _H_, XXX, ___, XXX, ___, XXX, XXX, XXX, ___
LB070:  .byte XXX, ___, ___, ___, XXX, ___, _H_, _F_, _H_, ___, XXX, ___, ___, ___, ___, ___
LB080:  .byte XXX, ___, ___, ___, XXX, ___, XXX, _H_, XXX, ___, XXX, XXX, XXX, ___, XXX, XXX
LB090:  .byte XXX, ___, ___, ___, XXX, ___, ___, ___, ___, ___, ___, ___, XXX, ___, ___, ___
LB0A0:  .byte XXX, ___, ___, ___, XXX, XXX, XXX, XXX, XXX, ___, XXX, ___, XXX, XXX, XXX, ___
LB0B0:  .byte XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, _D_, XXX, ___, ___, ___
LB0C0:  .byte XXX, ___, ___, ___, XXX, ___, XXX, ___, XXX, XXX, XXX, XXX, XXX, ___, XXX, XXX
LB0D0:  .byte XXX, ___, ___, ___, _I_, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, ___, ___
LB0E0:  .byte XXX, ___, ___, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___
LB0F0:  .byte XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, _D_

;----------------------------------------------------------------------------------------------------

;Cave of Moon, floor 2.
LB100:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
LB110:  .byte XXX, _T_, _H_, ___, ___, ___, ___, ___, ___, ___, ___, ___, _S_, ___, ___, ___
LB120:  .byte XXX, _H_, XXX, ___, XXX, ___, XXX, ___, XXX, XXX, XXX, XXX, _I_, XXX, XXX, ___
LB130:  .byte XXX, ___, ___, ___, XXX, ___, XXX, ___, ___, ___, XXX, _C_, _G_, _C_, XXX, ___
LB140:  .byte XXX, ___, XXX, XXX, XXX, ___, XXX, XXX, XXX, _S_, _I_, _G_, _C_, _G_, _I_, _S_
LB150:  .byte XXX, ___, ___, ___, ___, _D_, ___, ___, ___, ___, XXX, _C_, _G_, _C_, XXX, ___
LB160:  .byte XXX, ___, XXX, XXX, XXX, ___, XXX, XXX, XXX, ___, XXX, XXX, _I_, XXX, XXX, ___
LB170:  .byte XXX, ___, ___, ___, XXX, ___, XXX, _M_, ___, ___, XXX, ___, _S_, ___, ___, ___
LB180:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, XXX, XXX, _I_, XXX, XXX, XXX, XXX
LB190:  .byte XXX, ___, XXX, ___, _S_, ___, ___, ___, XXX, ___, ___, ___, ___, ___, ___, ___
LB1A0:  .byte XXX, ___, XXX, XXX, _I_, XXX, XXX, XXX, XXX, ___, XXX, XXX, XXX, XXX, XXX, ___
LB1B0:  .byte XXX, ___, XXX, _C_, _G_, _C_, XXX, ___, _I_, ___, XXX, _U_, ___, ___, XXX, ___
LB1C0:  .byte XXX, _S_, _I_, _G_, _C_, _G_, _I_, _S_, XXX, ___, XXX, ___, XXX, _I_, XXX, ___
LB1D0:  .byte XXX, ___, XXX, _C_, _G_, _C_, XXX, ___, XXX, ___, XXX, ___, _I_, ___, ___, ___
LB1E0:  .byte XXX, ___, XXX, XXX, _I_, XXX, XXX, ___, XXX, ___, XXX, XXX, XXX, ___, XXX, XXX
LB1F0:  .byte XXX, ___, ___, ___, _S_, ___, ___, ___, XXX, ___, ___, ___, ___, ___, XXX, _B_

;----------------------------------------------------------------------------------------------------

;Cave of Moon, floor 3.
LB200:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
LB210:  .byte XXX, _C_, _H_, ___, ___, ___, ___, _K_, ___, _K_, ___, ___, ___, ___, _H_, _C_
LB220:  .byte XXX, _H_, XXX, ___, XXX, XXX, XXX, XXX, _I_, XXX, XXX, XXX, XXX, ___, XXX, _H_
LB230:  .byte XXX, ___, ___, ___, XXX, ___, ___, ___, ___, ___, ___, ___, XXX, ___, ___, ___
LB240:  .byte XXX, ___, XXX, XXX, XXX, _S_, XXX, XXX, XXX, XXX, XXX, ___, XXX, XXX, XXX, ___
LB250:  .byte XXX, ___, XXX, ___, _S_, _U_, XXX, _C_, _C_, _C_, XXX, ___, ___, ___, XXX, ___
LB260:  .byte XXX, ___, XXX, ___, XXX, XXX, XXX, _C_, _C_, _C_, XXX, XXX, XXX, ___, XXX, ___
LB270:  .byte XXX, _K_, XXX, ___, XXX, _C_, XXX, _C_, _C_, _C_, _C_, _C_, XXX, ___, XXX, _K_
LB280:  .byte XXX, ___, _I_, ___, XXX, _C_, _C_, _C_, _D_, _C_, _C_, _C_, XXX, ___, _I_, ___
LB290:  .byte XXX, _K_, XXX, ___, XXX, _C_, _C_, _C_, _C_, _C_, _C_, _C_, XXX, ___, XXX, _K_
LB2A0:  .byte XXX, ___, XXX, ___, XXX, XXX, XXX, _C_, _C_, _C_, XXX, XXX, XXX, ___, XXX, ___
LB2B0:  .byte XXX, ___, XXX, ___, ___, ___, XXX, _C_, _C_, _C_, XXX, _D_, _S_, ___, XXX, ___
LB2C0:  .byte XXX, ___, XXX, XXX, XXX, ___, XXX, XXX, XXX, XXX, XXX, _S_, XXX, XXX, XXX, ___
LB2D0:  .byte XXX, ___, ___, ___, XXX, ___, ___, ___, ___, ___, ___, ___, XXX, ___, ___, ___
LB2E0:  .byte XXX, _H_, XXX, ___, XXX, XXX, XXX, XXX, _I_, XXX, XXX, XXX, XXX, ___, XXX, XXX
LB2F0:  .byte XXX, _C_, _H_, ___, ___, ___, ___, _K_, ___, _K_, ___, ___, ___, ___, XXX, _B_

;----------------------------------------------------------------------------------------------------

;Cave of Moon, floor 4.
LB300:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
LB310:  .byte XXX, _G_, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, _G_
LB320:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___
LB330:  .byte XXX, ___, ___, ___, ___, ___, XXX, ___, XXX, ___, XXX, ___, ___, ___, ___, ___
LB340:  .byte XXX, XXX, XXX, ___, XXX, XXX, XXX, _I_, XXX, _I_, XXX, XXX, XXX, ___, XXX, XXX
LB350:  .byte XXX, ___, ___, ___, XXX, _D_, ___, ___, _S_, ___, ___, _F_, XXX, ___, ___, ___
LB360:  .byte XXX, ___, XXX, XXX, XXX, ___, ___, XXX, _T_, XXX, ___, ___, XXX, XXX, XXX, ___
LB370:  .byte XXX, ___, ___, ___, _I_, ___, XXX, XXX, _H_, XXX, XXX, ___, _I_, ___, ___, ___
LB380:  .byte XXX, XXX, XXX, XXX, XXX, _S_, _T_, _H_, _B_, _H_, _T_, _S_, XXX, XXX, XXX, XXX
LB390:  .byte XXX, ___, ___, ___, _I_, ___, XXX, XXX, _H_, XXX, XXX, ___, _I_, ___, ___, ___
LB3A0:  .byte XXX, ___, XXX, XXX, XXX, ___, ___, XXX, _T_, XXX, ___, ___, XXX, XXX, XXX, ___
LB3B0:  .byte XXX, ___, ___, ___, XXX, _F_, ___, ___, _S_, ___, ___, _U_, XXX, ___, ___, ___
LB3C0:  .byte XXX, XXX, XXX, ___, XXX, XXX, XXX, _I_, XXX, _I_, XXX, XXX, XXX, ___, XXX, XXX
LB3D0:  .byte XXX, ___, ___, ___, ___, ___, XXX, ___, XXX, ___, XXX, ___, ___, ___, ___, ___
LB3E0:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___
LB3F0:  .byte XXX, _G_, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, _B_

;----------------------------------------------------------------------------------------------------

;Cave of Moon, floor 5.
LB400:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
LB410:  .byte XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, ___, ___, ___, ___
LB420:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, XXX, XXX, XXX, XXX, ___
LB430:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, ___, ___
LB440:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, XXX, XXX, XXX, XXX, ___, XXX, XXX, XXX, XXX
LB450:  .byte XXX, ___, XXX, ___, ___, _U_, XXX, _C_, _C_, _C_, XXX, ___, ___, ___, ___, ___
LB460:  .byte XXX, ___, XXX, XXX, XXX, XXX, XXX, _C_, XXX, _C_, XXX, XXX, XXX, XXX, XXX, ___
LB470:  .byte XXX, ___, ___, ___, XXX, _C_, _C_, _C_, _T_, _C_, _C_, _C_, XXX, ___, ___, ___
LB480:  .byte XXX, XXX, XXX, ___, XXX, _C_, XXX, _T_, _U_, _T_, XXX, _C_, XXX, ___, XXX, XXX
LB490:  .byte XXX, ___, ___, ___, XXX, _C_, _C_, _C_, _T_, _C_, _C_, _C_, XXX, ___, ___, ___
LB4A0:  .byte XXX, ___, XXX, XXX, XXX, XXX, XXX, _C_, XXX, _C_, XXX, XXX, XXX, XXX, XXX, ___
LB4B0:  .byte XXX, ___, ___, ___, ___, ___, XXX, _C_, _C_, _C_, XXX, _D_, ___, ___, XXX, ___
LB4C0:  .byte XXX, XXX, XXX, XXX, XXX, ___, XXX, XXX, XXX, XXX, XXX, ___, XXX, ___, XXX, ___
LB4D0:  .byte XXX, ___, ___, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, XXX, ___, XXX, ___
LB4E0:  .byte XXX, ___, XXX, XXX, XXX, XXX, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, _S_
LB4F0:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, _S_, _B_

;----------------------------------------------------------------------------------------------------

;Cave of Moon, floor 6.
LB500:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
LB510:  .byte XXX, ___, ___, ___, ___, ___, ___, ___, _H_, ___, ___, ___, ___, ___, ___, ___
LB520:  .byte XXX, ___, XXX, XXX, XXX, _H_, XXX, ___, XXX, ___, XXX, _H_, XXX, _H_, XXX, ___
LB530:  .byte XXX, ___, ___, ___, _H_, _C_, _H_, ___, _H_, ___, ___, ___, _H_, ___, ___, ___
LB540:  .byte XXX, _H_, XXX, ___, XXX, _H_, XXX, ___, XXX, _H_, XXX, ___, XXX, ___, XXX, _H_
LB550:  .byte XXX, ___, ___, ___, _H_, _D_, _H_, ___, ___, ___, ___, ___, _H_, ___, ___, ___
LB560:  .byte XXX, ___, XXX, _H_, XXX, _S_, XXX, _H_, XXX, XXX, XXX, _H_, XXX, _H_, XXX, ___
LB570:  .byte XXX, ___, ___, ___, _H_, ___, _H_, ___, ___, ___, ___, ___, ___, ___, XXX, ___
LB580:  .byte XXX, _H_, XXX, ___, XXX, ___, XXX, ___, XXX, _H_, XXX, _H_, XXX, ___, XXX, ___
LB590:  .byte XXX, ___, ___, ___, _H_, ___, XXX, ___, _H_, ___, ___, ___, _H_, ___, XXX, ___
LB5A0:  .byte XXX, ___, XXX, _H_, XXX, ___, XXX, ___, XXX, ___, XXX, _S_, XXX, ___, XXX, ___
LB5B0:  .byte XXX, ___, _H_, ___, ___, ___, _H_, ___, XXX, ___, _H_, _U_, _H_, ___, ___, ___
LB5C0:  .byte XXX, ___, XXX, ___, XXX, _H_, XXX, ___, XXX, ___, XXX, _H_, XXX, XXX, XXX, _H_
LB5D0:  .byte XXX, ___, _H_, ___, ___, ___, _H_, ___, _H_, ___, ___, ___, ___, ___, _H_, _C_
LB5E0:  .byte XXX, ___, XXX, _H_, XXX, ___, XXX, ___, XXX, _H_, XXX, XXX, XXX, ___, XXX, XXX
LB5F0:  .byte XXX, ___, ___, ___, ___, ___, XXX, ___, ___, ___, ___, ___, ___, ___, XXX, _B_

;----------------------------------------------------------------------------------------------------

;Cave of Moon, floor 7.
LB600:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
LB610:  .byte XXX, ___, _I_, ___, ___, ___, ___, ___, _I_, ___, XXX, ___, XXX, ___, ___, ___
LB620:  .byte XXX, ___, XXX, ___, XXX, _C_, XXX, ___, XXX, _I_, XXX, ___, ___, ___, XXX, _C_
LB630:  .byte XXX, _S_, XXX, ___, XXX, XXX, XXX, ___, XXX, ___, ___, ___, XXX, XXX, XXX, XXX
LB640:  .byte XXX, _S_, XXX, ___, ___, ___, ___, ___, XXX, XXX, XXX, ___, ___, ___, _C_, _C_
LB650:  .byte XXX, _T_, XXX, XXX, XXX, _U_, XXX, XXX, XXX, _C_, ___, ___, XXX, XXX, XXX, XXX
LB660:  .byte XXX, _S_, XXX, ___, ___, ___, ___, ___, XXX, XXX, XXX, ___, ___, ___, _C_, _C_
LB670:  .byte XXX, _S_, XXX, ___, XXX, XXX, XXX, ___, XXX, ___, ___, ___, XXX, XXX, XXX, XXX
LB680:  .byte XXX, ___, XXX, ___, XXX, _C_, XXX, ___, XXX, _I_, XXX, ___, ___, ___, _C_, _C_
LB690:  .byte XXX, ___, _I_, ___, ___, ___, ___, ___, ___, ___, XXX, ___, XXX, ___, _C_, _C_
LB6A0:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, _I_, XXX, XXX, XXX, XXX
LB6B0:  .byte XXX, ___, ___, _C_, ___, _C_, ___, ___, ___, _C_, XXX, _D_, _H_, ___, ___, ___
LB6C0:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, XXX, XXX, ___, _F_, ___
LB6D0:  .byte XXX, _C_, ___, _C_, ___, ___, ___, _C_, ___, _C_, ___, ___, XXX, ___, ___, ___
LB6E0:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, XXX
LB6F0:  .byte XXX, _C_, ___, ___, ___, _C_, ___, _C_, ___, ___, ___, ___, _H_, ___, XXX, _B_

;----------------------------------------------------------------------------------------------------

;Cave of Moon, floor 8.
LB700:  .byte XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX
LB710:  .byte XXX, _L_, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___
LB720:  .byte XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___, XXX, ___
LB730:  .byte XXX, ___, ___, ___, _H_, _S_, XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___
LB740:  .byte XXX, XXX, XXX, _H_, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, ___
LB750:  .byte XXX, ___, ___, _S_, XXX, _T_, _C_, _T_, _C_, _T_, _C_, _T_, XXX, ___, ___, ___
LB760:  .byte XXX, ___, XXX, XXX, XXX, _C_, XXX, _C_, XXX, _C_, XXX, _C_, XXX, ___, XXX, XXX
LB770:  .byte XXX, ___, ___, ___, XXX, _T_, _C_, _T_, _C_, _T_, _C_, _T_, XXX, ___, ___, ___
LB780:  .byte XXX, XXX, XXX, ___, XXX, _C_, XXX, _C_, XXX, _C_, XXX, _C_, XXX, XXX, XXX, ___
LB790:  .byte XXX, ___, ___, ___, XXX, _T_, _C_, _T_, _C_, _T_, _C_, _T_, XXX, ___, ___, ___
LB7A0:  .byte XXX, ___, XXX, XXX, XXX, _C_, XXX, _C_, XXX, _C_, XXX, _T_, XXX, ___, XXX, XXX
LB7B0:  .byte XXX, ___, ___, ___, XXX, _T_, _C_, _T_, _C_, _T_, _T_, _U_, XXX, ___, _C_, _M_
LB7C0:  .byte XXX, XXX, XXX, ___, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, XXX, _H_, XXX, XXX
LB7D0:  .byte XXX, ___, ___, ___, XXX, ___, ___, ___, XXX, ___, ___, ___, _H_, _F_, ___, ___
LB7E0:  .byte XXX, ___, XXX, XXX, XXX, ___, XXX, ___, XXX, ___, XXX, _C_, XXX, ___, ___, ___
LB7F0:  .byte XXX, ___, ___, ___, ___, ___, XXX, ___, ___, ___, XXX, _M_, XXX, ___, ___, _U_

;----------------------------------------------------------------------------------------------------

;Unused.
LB800:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB810:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB820:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB830:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB840:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB850:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB860:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB870:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB880:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB890:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB8A0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB8B0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB8C0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB8D0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB8E0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB8F0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB900:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB910:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB920:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB930:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB940:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB950:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB960:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB970:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB980:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB990:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB9A0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB9B0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB9C0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB9D0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB9E0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
LB9F0:  .byte $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
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
