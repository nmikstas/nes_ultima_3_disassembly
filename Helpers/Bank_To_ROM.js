"use strict";

const bank = document.getElementById("bank");
const addressInput = document.getElementById("address-input");
const bankClearBtn = document.getElementById("bank-clear");
const bankCalcBtn = document.getElementById("bank-calc");
const ROMResult = document.getElementById("rom-address");

const headerLength = 0x10;

bankClearBtn.addEventListener("click", () =>
{
    ROMResult.innerHTML = "";
    addressInput.value = "";
});

bankCalcBtn.addEventListener("click", () =>
{
    let bankNum = parseInt(bank.options[bank.selectedIndex].value);
    let bankAdr = parseInt(addressInput.value, 16);
    let bankOffset = (bankNum === 15) ? 0xC000 : 0x8000; 

    

    let value = bankNum * 0x4000 + headerLength + (bankAdr - bankOffset);
    ROMResult.innerHTML = "0x" + value.toString(16).toUpperCase();
});