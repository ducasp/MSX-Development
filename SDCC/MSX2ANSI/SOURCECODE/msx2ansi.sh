ASMFILE=msx2ansi
if [ "$1" != "" ]; then
	ASMFILE=$1
fi
sdasz80 -o ${ASMFILE}.asm
sdar -rc msx2ansi.lib msx2ansi.rel
