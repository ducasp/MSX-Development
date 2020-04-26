This is the source code and binaries for the original ANSIDRV for MSX2 and better or for V9990

This code was gently sent to me after request by Sonyc AKA T, Tobias Keizer, the author of this original work

It is intended to be used with Turbo Pascal

These are the instructions to use by Carlos de Santana (Sd-Snatcher @ MSXRC):

This is the code of the library of ansi driver used in Pascal:

type

OpenStringb     = String[255]; 

Procedure LOAD_ansi;
var

  driver: file of byte;
  by,by2 : byte; 
   
  BytePtr  : ^Byte;  
  inta:integer; 
  doll: char;    
Begin 

		Inta:=$b000;

        Assign (driver,'ANSI-DRV.BIN')          ;   { Assign file name    }
        Reset  (driver)                   ;   { Open for read       }

 		repeat
 			read(driver,by); 
 			mem[inta]:=by;
 			inta:=inta+1;
        until eof(driver);
        close(driver);  
End;


Procedure Ansi_INIT;
Begin
    Inline (    
				$CD/$00/$b0		
             ); 
End; 

Procedure Ansi_STOP;
Begin
    Inline (    
				$CD/$03/$b0		
             ); 
End;                                  

Procedure Ansi_PRINT(STR:OpenStringb );
Begin
    Inline (    
        		$21/STR/		
    		    $CD/$09/$b0		
             ); 
End; 



Procedure Ansi_PRINTchar(STR:char);
begin 

  
	Inline (    
   				$3A/STR/
	    		$CD/$06/$b0		
          	); 

end;

Inline is directly z80 machine code.

The driver is loaded at b000

-Init driver:
CALL b000
-stop driver:
CALL b003
-print character :
LD A, Character
CALL b006
-print String:
LD HL, STRING$
CALL b009
