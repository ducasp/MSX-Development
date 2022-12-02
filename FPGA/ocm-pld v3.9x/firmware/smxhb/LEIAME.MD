# SMX-HB

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

# Novidades em relação a v3.9c

    - Melhorias do KdL na controladora de SDRAM permitindo que coisas como a
      VRAM de 1MB funcionem com o controlador do Victor Trucco

    - Correção: havia um bug no z80 causando alguns problemas ao tentar jogar
      Lilly's Saga, correção feita pelo Hara-san

# Notas de liberação da versão

OCM-PLD v3.9d é uma extensão da OCM v3.9 do KdL. O que essa versão tem de
diferente:

    - SMX-HB: É um dispositivo geração "1.75". Seu FPGA tem cerca de 1/3 menos
      células como resultado da falta de componentes. Seu uso principal é de
      substituir a placa princial de um Hotbit, tendo (praticamente) toda a
      experiência OCM-SM. Por ter um teclado próprio de MSX, tem suas
      peculiaridades:

        - Permite o debounce das portas de joystick ser desligado, talvez possa
        ajudar com problemas que algumas pessoas estavam tendo com paddles.
        Para desligar o debounce use o comando SETSMART -89 , para religar use
        SETSMART -8A , ao desligar e religar a placa, o padrão é debounce
        ligado.

        - Suporte a um terceiro mapa de teclados, então tem o mapa da versão
        (us/br/fr/es), japonês e um para o teclado do Hotbit. O teclado do
        Hotbit não segue o padrão dos teclados de PC portanto seu mapa é bem
        diferente dos teclados PS/2. A chave DIP 9 em OFF é o padrão, uso do
        mapa Hotbit, configurada em ON irá usar o mapa da versão do firmware,
        útil quando quiser conectar um teclado PS/2 externo.

        - Correção: a tecla Select não estava funcionando na versão 3.7.1 que
        as placas foram enviadas, agora funciona.

        - Melhoria: SELECT + CIMA e SELECT + BAIXO substitui Page Up e Page
        Down, sendo possível ativar o disparo automático usando apenas teclas
        do Hotbit. Também temos SELECT + F1 a F4 sbustituindo F9 a F12, sendo
        possível utilizar a maioria dos atalhos de teclados do OCM.

        - Ausente: não há suporte a OPL3, não cabe no FPGA do SMX-HB. Também
        não foi possível suportar emulação de paddle na versão frankysnd pela
        mesma razão.

- Para todos dispositivos:

    - Melhoria: Victor Trucco fez melhorias no controlador de SDRAM que agora é
      capaz de trabalhar com diferentes chips. Alguns SM-X mini e SMX-HB usam
      chips que precisam dessa melhoria pra funcionar. O KdL gentilmente ajudou
      trabalhando no código do Victor Trucco e extrapolando ele para alguns
      cenários não cobertos, agora o controlador é compatível com o mapa de RAM
      da OCM 3.9, obrigado KdL! :)

    - Novidade: Emulação de Paddle usando um mouse PS/2. Para habilitar o modo
      VAUS (Arkanoid/Taito) use SETSMART -8E, to habilitar o modo MSX use
      SETSMART -8F, para desabilitar (padrão) use SETSMART -8D. Note que um
      paddle MSX apenas funciona corretamente se o Z80 estiver a 3.58MHz, como
      um veradeiro paddle MSX em um MSX com CPU turbo.

    - Correção: Não era possível mover apenas um ponto no eixo X. Também
      adicionei quatro níveis de sensibilidade que podem ser alternados com o
      clique do terceiro botão do mouse (se seu mouse não for compatível com o
      padrão intellimouse / três botões, a sensibilidade estará fixa próximo ao
      que era originalmente).

    - Correção: a emulação de Mouse MSX não funcionava muito bem se um controle
      SEGA de quatro ou oito botões estivesse conectado com um Joymega. Agora o
      mouse é detectado adequadamente, porém, o controle só retoma o uso da
      porta de Joystick se apertar os botões A, B, C ou START (ou 1 e 2 em 
      controles de 2 botões).

    - Correção: ao mudar de controle para mouse e vice versa, agora a porta de
      controles é "desconectada" por 1 segundo. Em um MSX real não é possível
      mudar de controle para mouse (e vice versa) sem desconectar o mesmo da
      porta, HIDTEST e jogos/programas que usem a HIDLIB dependem desse evento
      de desconexão e posterior conexão para detectar a troca de dispositivo.

    - Melhoria: a emulação de mouse MSX do MC2+ foi portada para todos. É uma
      forma melhor que contam com time-out para retornar sozinho ao primeiro
      estado após algum tempo sem leitura, assim como um mouse MSX real.

    - Correção: havia um bug no z80 causando alguns problemas ao tentar jogar
      Lilly's Saga, correção feita pelo Hara-san

Todo código fonte e binários alterados em relação ao OCM 3.9:
(c)2022 Oduvaldo Pavan Junior - ducasp@gmail.com

Todo código fonte do OCM 3.9 é um trabalho de muitas pessoas, incluindo KdL e
Hara-san que são grandes contribuidores!

Todo código adicional pode ser reutilizado, re-escrito, trabalhos derivados
podem ser vendidos DESDE QUE o código fonte das mudanças seja publicado também.
Para o código original do OCM 3.9, verifique a licença do mesmo.
