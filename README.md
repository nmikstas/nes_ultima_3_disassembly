# nes_ultima_3_disassembly

Disassembly of the nes version of Ultima Exodus.
There is a total of 16 banks in Ultima. Each bank is 16Kb in size.
Bank00 through Bank0E are swapped out in lower memory while Bank0F stays in upper memory.

## Nifty Tools

A [map viewer](https://nmikstas.github.io/portfolio/NesUltimaExodusMapViewer/Map_Viewer.html) for the game I made while working on the disassembly.
Any one of the overhead maps can be selected and shown in a browser. All the NPCs for each map are also present. + and - buttons can be used to zoom in/zoom out on the maps.

## Folder Structure

* Completion_Map - Contains a .png file showing a visual representation of how much of the disassembly is complete.
* Helpers - Various helper programs that were used to aid in the disassembly. Includes the map viewer.
* Ophis - The Ophis assembler.
* Output_Files - When the build script is run, the assembled output files are placed here.
* Source_Files - The disassembled Ultima files.

## Assembling the Code

Running the build_script from the main directory will assemble the 16 bank files and create 16 binary files in the Output_Files directory.
An md5sum will also be calculated on the output binaries and compared to the md5sum of the original binaries.
