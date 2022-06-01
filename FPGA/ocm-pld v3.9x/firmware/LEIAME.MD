# FIRMWARE

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/R6R2BRGX6)

IMPORTANTE! LEIA TUDO E SEJA CUIDADOSO! NÃO É DIVERTIDO BRICAR SEU MSX FPGA!
NÃO É TÃO SIMPLES RESTAURAR ELE USANDO JIC / USB BLASTER JÁ QUE IRÁ PRECISAR DO
USB BLASTER, INSTALAR O QUARTUS PARA USAR O PROGRAMMER, E NO CASO DO SMX-HB A
PORTA JTAG NÃO É ACESSÍVEL COM O MÓDULO FPGA NA PLACA, PRECISANDO RETIRAR O
MESMO DA PLACA E CONECTAR A UMA FONTE EXTERNA. VOCÊ FOI AVISADO! AVISADO MESMO!

APENAS USE O SMXFLASH.COM para atualizar seu FPGA MSX de segunda geração (SM-X,
SMX-HB, SM-X Mini, SX2). NÃO USE O SMXFLASH NO MULTICORE 2+! No caso do MC2+
o arquivo MCP substitui o MCP anterior e isso é tudo que é necessário. APENAS
USE UM FIRMWARE QUE É PARA O SEU DISPOSITIVO. CADA DISPOSITIVO UTILIZA CONEXÕES
DIFRENTES, ALGUNS USAM FPGAs DIFERENTES, ENTÃO NUNCA SEQUER PENSE EM USAR O PLD
DOS DISPOSITIVOS DE PRIMEIRA GERAÇÃO TAMPOUCO EM UTILIZAR UM PLD DE DISPOSITIVO
DE SEGUNDA GERAÇÃO QUE NÃO TENHA O NOME DO SEU DISPOSITIVO NO ARQUIVO ZIP.

A versão do SMXFLASH.COM disponível junto aos firmwares no pacote
flashandconfigtools.zip também funciona com o NEXTOR. Versões anteriores do
SMXFLASH.COM dependem do Kernel do MSX DOS 2 para funcionar. Qual a razão para
usar outra versão? Não tenho idéia. Leia o documento inteiro e seja cuidadoso
para não ter problemas. No MSX DOS / Nextor, use a seguinte linha de comando
para atualizar (exceto MC2+, MC2+ apenas substitua o arquivo de core com a 
extensão .MCP pelo novo arquivo do pacote):

SMXFLASH OCM_SM.PLD

Aguarde até que o SMXFLASH retorne ao prompt do DOS dizendo que terminou. Caso
haja uma mensagem de erro após ter iniciado a apagar ou escrever, tente
novamente até que funcione, pois se desligar o dispositivo com um update não
terminado, seu dispositivo irá BRICAR e precisará de um USB Blaster e o arquivo
JIC para restaurar o mesmo, processo que é um pé...

Também, fique ciente que se houver queda de energia durante a atualização, é
bem provável que seu dispositivo irá BRICAR e precisará utilizar o USB Blaster
e arquivo JIC para restaurar o mesmo...

Como escolher um firmware? (exceto MC2+, MC2+ tem um único firmware)

1 - Obviamente irá baixar os arquivos para seu dispositivo.(ex.: tenho um SM-X,
então pego arquivos das pastas que começam com smx_)

2 - Próximo passo é entender se quer a versão simples ou a versão com som da
Franky. Se não tem uma Franky ou Playsoniq, a versão Franky é pra você. Caso
tenha uma das duas, a versão Franky irá causar conflitos, então é melhor ir
para a versão simples. NOTA: donos de SMX-HB tem um fator extra a considerar,
a versão com som da Franky não suporta emulação de Paddle Arkanoid ou MSX com
mouse PS/2. Caso pretenda usar Paddles emulados, a versão simples é a única
opção.

3 - (FUTURO, NÃO NO MOMENTO) Seu dispositivo de segunda geração tem suporte a
versão Franky completa. Se no item anterior escolheria a versão com som Franky,
parece que a escolha da versão Franky completa (que suporta o VDM do Master
System) é certa... Nem sempre... Infelizmente não é possível ter o VDP / CRAM /
VRAM do Master System junto com a OPL3. Então, se gosta do VGMPLAY e toca VGMs
da OPL3 ou tem outros usos para a OPL3, pode preferir usar a versão som Franky.

4 - EITA! A pasta tem 16 arquivos diferentes!!! Não tenho idéia do que
escolher...

    - Não se preoucupe, primeiro, vamos diminuir para quatro arquivos, isso é
    feito através do mapa do seu teclado PS/2, Francês, Espanhol, Brasileiro ou
    Estados Unidos. IMPORTANTE: SD-BIOS não altera o mapa do teclado, então é
    importante escolher o correto :)
    - Agora, vamos diminuir para dois arquivos. Você prefere a barra invertida
    como barra invertida ou como o símbolo do Yene (MSX's Japoneses)? Baseado 
    nisso, escolhe backslash ou yen. Se utilizar SD-BIOS, isto não é relevante
    já que a SD-BIOS irá sobrepujar essa escolha
    - Finalmente, SINGLE EPBIOS ou DUAL EPBIOS. Na DUAL EPBIOS, caso não use a
    SD-BIOS, pode facilmente trocar entre Kernel Nextor ou MSX Dos 2 mudando a
    chave DIP 7. Na posição de 4096 MB de memória irá usar o Kernel Nextor (
    necessário desligar e religar o dispositivo para mudança ser efetiva), na
    posição de 2048 MB de memória irá usar o Kernel MSX Dos 2. Single EPBIOS
    utiliza apenas o Kernel MSX Dos 2. Se usar SD-BIOS, então isso não é
    relevante já que a SD-BIOS irár sobrepujar essa escolha

5 - Agora já tem seu arquivo de firmware, apenas use ele :)

Todo código fonte e binários alterados em relação ao OCM 3.9:
(c)2022 Oduvaldo Pavan Junior - ducasp@gmail.com

Todo código fonte do OCM 3.9 é um trabalho de muitas pessoas, incluindo KdL e
Hara-san que são grandes contribuidores!

Todo código adcional pode ser reutilizado, re-escrito, trabalhos derivados
podem ser vendidos DESDE QUE o código fonte das mudanças seja publicado também.
Para o código original do OCM 3.9, verifique a licença do mesmo.
