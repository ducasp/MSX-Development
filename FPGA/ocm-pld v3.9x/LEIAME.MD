# OCM-PLD v3.9.1a

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/R6R2BRGX6)

# Novidades em relação a v3.9d

- Incorporadas todas mudanças da 3.9.1 que ainda não estavam na 3.9d, verifique
  o release original da 3.9.1 do KdL. Nota: o novo controlador PS2 está ausente
  já que pelo meu entendimento com ele teclados que hoje funcionam na 3.9.0
  podem não funcionar com o novo controlador a menos que faça algumas mudanças
  propostas no hardware. Também o novo IPL está ausente no MC2P já que requer
  uma memória flash que não existe em sistemas multi-core.

# Notas de liberação da versão

OCM-PLD v3.9.1a é uma extensão da OCM v3.9.1 do KdL. O que essa versão tem de
diferente:

- Novos dispositivos suportados:

    - SMX-HB e SMX-HB MINI: É um dispositivo geração "1.75". Seu FPGA tem cerca
      de 1/3 menos células como resultado da falta de components. Seu uso
      principal é de substituir a placa princial de um Hotbit (HB), tendo
      (praticamente) toda a experiência OCM-SM. Por ter um teclado próprio de
      MSX (HB apenas), tem suas peculiaridades (algumas não se aplicam ao HB
      MINI que usa apenas teclados PS/2):

        - Permite o debounce das portas de joystick ser desligado, talvez possa
        ajudar com problemas que algumas pessoas estavam tendo com paddles.
        Para desligar o debounce use o comando SETSMART -89 , para religar use
        SETSMART -8A , ao desligar e religar a placa, o padrão é debounce
        ligado. NOTA: temporariamente essa opção está indisponível e o debounce
        está permanentemente ativado independente da seleção. (HB e HB MINI)

        - Suporte a um terceiro mapa de teclados, então tem o mapa da versão
        (us/br/fr/es), japonês e um para o teclado do Hotbit. O teclado do
        Hotbit não segue o padrão dos teclados de PC portanto seu mapa é bem
        diferente dos teclados PS/2. A chave DIP 9 em OFF é o padrão, uso do
        mapa Hotbit, configurada em ON irá usar o mapa da versão do firmware,
        útil quando quiser conectar um teclado PS/2 externo. (HB MINI usar a
        DIP 9 em ON)

        - Correção: a tecla Select não estava funcionando na versão 3.7.1 que
        as placas foram enviadas, agora funciona. (HB)

        - Melhoria: SELECT + CIMA e SELECT + BAIXO substitui Page Up e Page
        Down, sendo possível ativar o disparo automático usando apenas teclas
        do Hotbit. Também temos SELECT + F1 a F4 sbustituindo F9 a F12, sendo
        possível utilizar a maioria dos atalhos de teclados do OCM. (HB)

        - Ausente: não há suporte a OPL3, não cabe no FPGA do SMX-HB. Também
        não foi possível suportar emulação de paddle na versão frankysnd pela
        mesma razão. (HB e HB MINI)

    - Multicore 2+: parecido com o MiSTER, porém com um FPGA menor que o mesmo(
    mais que o dobro dos OCM segunda geração, mas cerca da metade do MiSTER) e
    sem o ARM embutido no FPGA que é utilizado para interface com dispositivos
    USB (MC2+ usa controles SEGA, Mega Drive ou Master System e mouse/teclados
    PS/2). Uma vantagem sobre o MiSTER é o slot de expansão aonde podem ser
    colocadas expansões que permitem utilizar cartuchos/interfaces reais dos
    dispositivos. Existe uma expansão SM-X que dá três slots de MSX e o Wi-Fi
    usando ESP-01.

        - Legado: tudo que a versão OCM 3.8 do Roberto Focosi e Victor Trucco
        tem a mais foi trazido, então tem suporte a extensão SM-X, uso de
        imagens de disco para não ter que dedicar um cartão SD para MSX, mapas
        do teclado todos em uma única versão escolhidos pelo menu OSD, etc.

        - Correção: no uso de imagens ao invés do cartão SD dedicado, erros de
        escrita occorriam às vezes, agora deve estar funcionando sempre.

        - Melhoria: MC2+ usa controles SEGA. Inicialmente, a versão 3.7.1 que
        eu havia feito primeiro usava apenas dois botões de qualquer cotrole, e
        permitia chamar o OSD com MODE + START usando controle de 8 botões, o
        Focosi na 3.8 dele optou por uma solução simples que também usava apenas
        dois botões mas não permitia mais chamar o OSD. Agora nessa versão eu
        fiz com que os dois controles fossem mapeados internamentes para um 
        "Joymega" interno. Com isso, dá para usar 4 ou 8 botões aonde o Joymega
        funciona (desde que use um controle com 4 ou 8 botões), chamar o OSD na
        combinação de START + MODE, tudo automático.

        - Comportamento único: o MC2+ não tem DIP switch, utiliza um OSD que é
        chamado pela tecla F12, portanto alterar o turbo da CPU com F12 key foi
        desabilitado e pode ser ajustado apenas pelo menu OSD (F12 ou MODE+START
        no controle 1) ou utilizando I/O chaveado ou software que configure a
        velocidade da CPU. Como o uso de F12 é necessário para chamar e depois 
        tirar o OSD da tela, ter a velocidade da CPU sendo alterada por essa
        tecla não funcionava bem.

        - Comportamento único: a emulação de paddle é ligada/desligada apenas
        pelo menu OSD, os comandos SETSMART para paddle não tem efeito no MC2+.

        - Melhoria: as configurações do DIP são feitas pelo OSD. Se estiver
        utilizando uma imagem de disco, as mudanças são salvas no cartão SD e
        retauradas novamente quando o OSD é chamado ou ao religar. Ao usar um
        cartão SD diretamente, como o cartão é "controlado" pelo MSX, não é
        possível ao microcontrolador do OSD salvar configurações no cartão,
        então nesse caso sempre que o menu OSD é chamado as configurações que
        aparecem são configurações padrão, já que o microcontrolador do OSD não
        sabe das mudanças no FPGA e não pode salvar as mesmas no cartão que
        está dedicado para o MSX. Por isso alterei algumas das configurações
        de forma que os valores padrões atendam a maioria. Lembre: ao usar um
        cartão dedicado ao MSX ao invés de imagem, configure tudo que deseja
        ANTES de sair do OSD. Ao entrar novamente no OSD, as configurações
        padrão serão restauradas, então terá que configurar tudo novamente.
        Infelizmente, no momento não há maneira de contornar isso (a não ser
        utilizar uma imagem de SD ao invés de um SD dedicado).

        - Novidade: se tiver a expansão "ZX Next" do MC2+ mas não tiver a
        expansão SM-X, poderá usar a do ZX Next após habilitar a mesma no OSD.
        Atualmente a única característica adicionada com isso é o uso de Wi-Fi.
        IMPORTANTE: SM-X / dipositivos OCM de segunda geração usam um firmware
        customizado para o ESP, e o ZX Nest utiliza um firmware "AT" padrão da
        Espressif. Para o Wi-Fi funcionar no MSX, necessita um segundo módulo
        ESP-01 com o firmware customizado, assim pode colocar o ESP do MSX na
        extensão quando for usar MSX, e colocar o ESP original de volta quando
        for usar a extensão para ZX Next. Instruções de como gravar o firmware
        customizado do ESP estão disponíveis em:
        https://youtu.be/uoaiEamWUUg

- Para dispositivos/firmwares suportando OPL3:

    - Correção: Arrumei a OPL3, tinha dois problemas que faziam OPL3 não
      funcionar com a última versão do VGMPlay:

        - IRQ estava desconectado, então os temporizadores programados não
          geravam interrupção, e com apenas a interrupção do VDP, a música 
          tocava muito devagar.

        - Mesmo com IRQ conectado, a velocidade melhorou mas estava lenta. O
          temporizador tem uma escala que estava com valor incorreto para o
          clock utilizado, causando os temporizadores demorarem mais que o
          programado para acionar a interrupção.

      O VGMPlay 1.3 depende dos temporizadores da OPL3 quando a mesma está
      presente, como um temporizador de alta resolução, e não ter o IRQ ligado
      e não ter a escala correta nos temporizadores causava o mal funcionamento
      do mesmo...

    - Correção para dispositivos segunda geração: originalmente a OPL3 estava
      apenas com um canal conectado, descartando qualquer som tocando apenas no
      canal desconectado. Imagino que a razão disso é que ao conectar e mixar
      ambos canais, o uso de recursos FPGA vão além do que os FPGA de segunda
      geração tem disponível (o sequenciador de cada canal usa vários registros
      e ao ter um canal conectado apenas, o Quartus simplesmente corta esses
      registradores já que a saída não é conectada a nada). Fiz um pequeno
      truque para resolver essa situação, permitindo que todo o conteúdo seja
      tocado em apenas um canal sem ter que renderizar ambos e mixar depois. :P
      Tente por exemplo a terceira música da trilha sonora do Doom antes e
      depois da correção para sentir a diferença. :)

    - Melhoria pro MC2+: como o MC2+ tem um FPGA enorme, a OPL3 funciona em
      estéreo real. Permiti que a OPL3 possa ser usada em MONO pelo OSD.

- Para dispositivos/firmwares suportando SN76489 e 2xPSG:

    - Novidade: suporte parcial a uma "Franky" embutida. Esse suporte parcial
      é suficiente para que SG1000, COL4MMM (usando as versões COM\Franky),
      VGMPLAY, ROBOPLAY e Sofarun (lembre de configurar de forma que use o VDP
      do MSX e PSG do Franky para SMS/SG1000). Como a Franky utiliza as portas
      0x48 e 0x49 que fazem parte das portas reservadas para I/O chaveado, irá
      estar desabilitado inicialmente, já que o módulo que carrega a BIOS MSX
      deixa o dispositivo de I/O chaveado selecionado após o boot. Há várias
      opções para habilitar o som da Franky:

        - A última versão do COL4MMM automaticamente desabilita o I/O chaveado,
        então não é necessário nada para que funcione. :)re.

        - VGMPLAY também desabilita automaticante o I/O chaveado, então se usar
        o VGMPLAY e tocar uma música que usa o SN76489, após sair do VGMPLAY
        poderá utilizar qualquer outro software que o som irá funcionar.

        - Enviar pelo BASIC o comando OUT &H40,0 que desabilita o I/O chaveado.

        - Usar SETSMART -8C para reservar as portas 0x48 e 0x49 para o Franky,
        ao fazer isso qualquer programa que dependa dessas portas para ler
        informações do OCM não irá obter a informação correta.

    - Novidade: Segundo PSG nas porta 0x10-0x13. Também permite que os
      regsitradores do segundo PSG sejam lidos.

- Para todos dispositivos / firmwares:

    - Melhoria: Victor Trucco fez melhorias no controlador de SDRAM que agora é
      capaz de trabalhar com diferentes chips. Alguns SM-X mini e SMX-HB usam
      chips que precisam dessa melhoria pra funcionar. O KdL gentilmente ajudou
      trabalhando no código do Victor Trucco e extrapolando ele para alguns
      cenários não cobertos, agora o controlador é compatível com o mapa de RAM
      da OCM 3.9, obrigado KdL! :)

    - Novidade: Emulação de Paddle usando um mouse PS/2. Para habilitar o modo
      VAUS (Arkanoid/Taito) use SETSMART -8E, para habilitar o modo MSX use
      SETSMART -8F, para desabilitar (padrão) use SETSMART -8D. Note que um
      paddle MSX apenas funciona corretamente se o Z80 estiver a 3.58MHz, como
      um verdadeiro paddle MSX em um MSX com CPU turbo. A única exceção é o
      firmware para SMX-HB com som Franky, já que não há espaço no FPGA para o
      SN76489, o segundo PSG e o paddle.

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
      forma melhor que conta com time-out para retornar sozinho ao primeiro
      estado após algum tempo sem leitura, assim como um mouse MSX real.

    - Correção: havia um bug no z80 causando alguns problemas ao tentar jogar
      Lilly's Saga, correção feita pelo Hara-san

- Futuro, dispositivos que terão um build Franky Completo:

    - Ausente: salvo pelo MC2+, o FPGA nos dispositivos OCM segunda geração não
      tem espaço suficiente para ter OPL3 junto com o VDP e PSG do Franky, logo
      esse build não terá suporte a OPL3. O MC2+ terá também a OPL3 junto com o
      Franky completo.

    - Novidade: ainda está em desenvolvimente, por favor aguarde, logo teremos
      o Franky com VDP e PSG :P

Todo código fonte e binários alterados em relação ao OCM 3.9.1:
(c)2022-2023 Oduvaldo Pavan Junior - ducasp@gmail.com

Todo código fonte do OCM 3.9.1 é um trabalho de muitas pessoas, incluindo KdL e
Hara-san que são grandes contribuidores!

Todo código adicional pode ser reutilizado, re-escrito, trabalhos derivados
podem ser vendidos DESDE QUE o código fonte das mudanças seja publicado também.
Para o código original do OCM 3.9.1, verifique a licença do mesmo.
