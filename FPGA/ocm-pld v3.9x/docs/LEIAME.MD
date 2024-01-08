# OCM-PLD v3.9.2plus

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/R6R2BRGX6)

# Tabelinha Marota pra escolha de Versão

| Versão do Firmware | OPL3 Mono | OPL3 Estéreo | SN76489 | SMS VDP | PS/2 Mouse -> MSX Mouse | Paddle usando Mouse PS/2 | 2x PSG | MIDI Out | Turbo-R PCM | Segunda Mapper 4MB |
| :----------------- | :-------: | :----------: | :-----: | :-----: | :---------------------: | :----------------------: | :----: | :------: | :---------: | :----------------: |
| MC2P               | Sim       | Sim          | Sim     | Sim     | Sim                     | Sim                      | Sim    | Sim      | Sim         | Sim                |
| SM-X/SX2           | Sim       | Não          | Não     | Não     | Sim                     | Sim                      | Sim    | Sim      | Sim         | Sim                |
| SM-X/SX2 Franky    | Não       | Não          | Sim     | Sim     | Sim                     | Sim                      | Sim    | Sim      | Sim         | Sim                |
| SM-X/SX2 Snd       | Sim       | Não          | Sim     | Não     | Sim                     | Sim                      | Sim    | Sim      | Sim         | Sim                |
| SM-X Mini          | Sim       | Não          | Não     | Não     | Sim                     | Sim                      | Sim    | Sim      | Sim         | Não                |
| SM-X Mini Franky   | Não       | Não          | Sim     | Sim     | Sim                     | Sim                      | Sim    | Sim      | Sim         | Não                |
| SM-X Mini Snd      | Sim       | Não          | Sim     | Não     | Sim                     | Sim                      | Sim    | Sim      | Sim         | Não                |
| SM-X HB            | Não       | Não          | Não     | Não     | Sim                     | Sim                      | Sim    | Sim      | Sim         | Não                |
| SM-X HB Franky     | Não       | Não          | Sim     | Sim     | Não                     | Não                      | Não    | Não      | Não         | Não                |
| SM-X HB Snd        | Não       | Não          | Sim     | Não     | Sim                     | Não                      | Sim    | Sim      | Sim         | Não                |

NOTA: NUNCA, JAMAIS PENSE EM USAR MC2P SE NÃO TEM UM MC2P, SM-X SE SEU
DISPOSITIVO NÃO É SM-X, ETC... A Tabelinha é para auxiliar na escolha de qual
versão para seu dispositivo tem as características que quer. Se seu dispositivo
não tem uma característica ou a combinação que quer, NÃO USE UM FIRMWARE DE
OUTRO DISPOSITIVO, IRÁ BRICAR SEU DISPOSITIVO E SÓ IRÁ VOLTAR A FUNCIONAR SE
USAR UMA USB BLASTER E UM PC. VOCÊ FOI AVISADO!

# Estou perdido e não sei o que escolher

O arquivo ESCOLHENDO.TXT irá lhe ajudar, mas se quer a versão curta da estória:
primeiro baixe o arquivo ocmsm_XXXX_3.9.2plus.7z aonde XXXX é o seu dispositvo.
IMPORTANTE: SM-X HB Mini É UM DISPOSITIVO SM-X HB E USA OS ARQUIVOS DO SM-X HB.
NUNCA JAMAIS PENSE EM USAR SM-X Mini PARA UM SM-X HB Mini! Via de regra a
versão mais divertida e interessante para a maioria, na minha opinião, é a
FRANKY com a língua do seu teclado PS/2, dual EPBIOS e backslash. Essa versão
permite rodar jogos do Coleco (COL4MMM, use versão COM - Franky), SG1000 
(SG1000 ou SSMS) e de Master System (SSMS ou jogos convertidos). Note que no
SMX-HB se abre mão do Mouse PS/2 como mouse MSX, MIDI e PCM do Turbo-R quando
utilizando essa versão.

# Não gosto de ler manuais, como atualizo?

Leia acima, e pegue a versão correta pro seu dispositivo, dentro do arquivo há
um arquivo PLD e outro arquivo JIC. Copie o arquivo PLD junto com o arquivo
SMXFLASH.COM pro seu cartão, e no MSX DOS execute SMXFLASH OCM-SM.PLD

Porém, não irá aproveitar muito as novidades se não ler o MINI-MANUAL-PT-BR.txt

# Novidades em relação a v3.9.1plus

- Incorporadas todas mudanças da 3.9.2 que ainda não estavam na 3.9.1plus,
  verifique o release original da 3.9.2 do KdL. Nota: o novo controlador PS2
  está ausente já que pelo meu entendimento com ele teclados que hoje funcionam
  na 3.9.0 podem não funcionar com o novo controlador a menos que faça algumas
  mudanças propostas no hardware.

- Nas versões com SN76489, corrigido o problema de as vezes o ficar tocando uma
  nota continuamente após um reset.

- Nas versões com SN76489, foi atualizado para uma versão mais atual do JT89
  que corrige o problema de som no Populous do SMS.

- Nas versões com Franky, foi corrigido o VDP 3,3% mais rápido que o original,
  que causava o vídeo a 62Hz de frequência horizontal, jogos ligeiramente mais
  rápidos e alguns monitores / TVs não reconhecerem a saída de vídeo do Master
  System.

- SMX-HB com Franky: devido às novidades da 3.9.2, infelizmente o segundo PSG
  teve que ser removido nessa versão para dar espaço às novidades.

# Notas de liberação da versão

OCM-PLD v3.9.2plus é uma extensão da OCM v3.9.2 do KdL. O que essa versão tem
de diferente:

- Novos dispositivos suportados:

    - SMX-HB, SMX-HB EX e SMX-HB MINI: É um dispositivo geração "1.75". Seu
      FPGA tem cerca de 1/3 menos células como resultado da falta de
      componentes. Seu uso principal é de substituir a placa princial de um
      Hotbit (HB) ou Expert (HB EX), tendo (praticamente) toda a experiência
      OCM-SM. A versão MINI é como os SM-X originais, funcionando sozinha com
      teclado PS/2 e com gabinete próprio. Por ter um teclado próprio de MSX
      (HB e EX apenas), tem suas peculiaridades (algumas não se aplicam ao HB
      MINI que usa apenas teclados PS/2):

        - Suporte a um terceiro mapa de teclados, então tem o mapa da versão
        (us/br/fr/es/it) e japonês se usar PS/2 e um para o teclado do Hotbit
        ou Expert. Os teclados do Hotbit/Expert não seguem o padrão dos
        teclados de PC portanto seu mapa é bem diferente dos teclados PS/2. A
        chave DIP 9 em OFF é o padrão, uso do mapa Hotbit/Expert, configurada
        em ON irá usar o mapa da versão do firmware, útil quando quiser
        conectar um teclado PS/2 externo. (HB MINI usar a DIP 9 em ON)

        - Correção: a tecla Select não estava funcionando na versão 3.7.1 que
        as placas foram enviadas, agora funciona. (HB)

        - Melhoria: SELECT + CIMA e SELECT + BAIXO substitui Page Up e Page
        Down, sendo possível ativar o disparo automático usando apenas teclas
        do Hotbit. Também temos SELECT + F1 a F4 sbustituindo F9 a F12, sendo
        possível utilizar a maioria dos atalhos de teclados do OCM. (HB)

        - Ausente: não há suporte a OPL3, não cabe no FPGA do SMX-HB. Também
        não foi possível suportar emulação de paddle nas versões franky/snd
        pela mesma razão. No firmware HB, a versão Franky também abre mão do
        mouse PS/2 emulando mouse MSX, Turbo-R MIDI como saída pela porta 2 de
        joystick e Turbo-R PCM. (HB, EX e HB MINI)

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
      funcionar com a última versão do VGMPlay (OCM do KdL a partir da 3.9.1
      também tem essas correções):

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

    - Correção para dispositivos segunda geração (OCM do KdL a partir da 3.9.1
      também tem essa correção): originalmente a OPL3 estava apenas com um
      canal conectado, descartando qualquer som tocando apenas no canal
      desconectado. A razão disso é que ao conectar e mixar ambos canais, o uso
      de recursos de memória do FPGA vão além do que os FPGA de segunda geração
      tem disponível (o sequenciador de cada canal usa vários registros
      e ao ter um canal conectado apenas, o Quartus simplesmente corta esses
      registradores já que a saída não é conectada a nada). Fiz um pequeno
      truque para resolver essa situação, permitindo que todo o conteúdo seja
      tocado em apenas um canal sem ter que renderizar ambos e mixar depois. :P
      Tente por exemplo a terceira música da trilha sonora do Doom antes e
      depois da correção para sentir a diferença. :)

    - Melhoria pro MC2+: como o MC2+ tem um FPGA enorme, a OPL3 funciona em
      estéreo real. Permiti que a OPL3 possa ser usada em MONO pelo OSD.

    - Novidade (OCM do KdL a partir da 3.9.1 também tem): Segundo PSG nas
      portas 0x10-0x13. Também permite que os registradores do segundo PSG
      sejam lidos. Diferente do build KdL, aqui o segundo PSG está ativado
      por padrão.

- Para firmwares suportando Franky SN76489 apenas:

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

- Para firmwares suportando Franky VDP:

        - VDP do Master System embutido. A troca de vídeo é automática, assim
          que o VDP do Franky gera interrupções o vídeo dele é mostrado. Quando
          esse VDP para de gerar interrupções, o vídeo do MSX será mostrado.

- Para todos dispositivos / firmwares:

    - Melhoria (OCM do KdL a partir da 3.9.1 também tem): Victor Trucco e KdL
      melhoraram o controlador de SDRAM que agora é capaz de trabalhar com
      diferentes chips. Alguns SM-X mini e SMX-HB usam chips que precisam dessa
      melhoria pra funcionar. MC2P, SX2 e SM-X padrão podem ativar uma segunda
      mapper com mais 4MB (essa mapper foi feita pelo KdL).

    - Novidade: Emulação de Paddle usando um mouse PS/2. Para habilitar o modo
      VAUS (Arkanoid/Taito) use SETSMART -8E, para habilitar o modo MSX use
      SETSMART -8F, para desabilitar (padrão) use SETSMART -8D. Note que um
      paddle MSX apenas funciona corretamente se o Z80 estiver a 3.58MHz, como
      um verdadeiro paddle MSX em um MSX com CPU turbo. A única exceção é nos
      firmwares para SMX-HB Snd/Franky, já que não há espaço no FPGA para o
      SN76489, o segundo PSG e o paddle juntos.

    - Correção (OCM do KdL a partir da 3.9.1 também tem): Não era possível
      mover apenas um ponto no eixo X.

    - Correção (OCM do KdL a partir da 3.9.1 também tem): a emulação de Mouse
      MSX não funcionava muito bem se um controle SEGA de quatro ou oito botões
      estivesse conectado com um Joymega. Agora o mouse é detectado
      adequadamente, porém, o controle só retoma o uso da porta de Joystick se
      apertar os botões A, B, C ou START (ou 1 e 2 em controles de 2 botões).

    - Correção (OCM do KdL a partir da 3.9.1 também tem): ao mudar de controle
      para mouse e vice versa, agora a porta de controles é "desconectada" por
      1 segundo. Em um MSX real não é possível mudar de controle para mouse (e
      vice versa) sem desconectar o mesmo da porta, HIDTEST e jogos/programas
      que usem a HIDLIB dependem desse evento de desconexão e posterior conexão
      para detectar a troca de dispositivo.

    - Melhoria (OCM do KdL a partir da 3.9.1 também tem): a emulação de mouse
      MSX do MC2+ foi portada para todos. É uma forma melhor que conta com time
      -out para retornar sozinho ao primeiro estado após algum tempo sem
      leitura, assim como um mouse MSX real.

    - Correção (OCM do KdL a partir da 3.9.1 também tem): havia um bug no z80
      causando alguns problemas ao tentar jogar Lilly's Saga, correção feita
      pelo Hara-san.

Todo código fonte e binários alterados em relação ao OCM 3.9.2:
(c)2022-2024 Oduvaldo Pavan Junior - ducasp@gmail.com

Todo código fonte do OCM 3.9.2 é um trabalho de muitas pessoas, incluindo KdL e
Hara-san que são grandes contribuidores!

Todo código adicional pode ser reutilizado, re-escrito, trabalhos derivados
podem ser vendidos DESDE QUE o código fonte das mudanças seja publicado também.
Para o código original do OCM 3.9.2, verifique a licença do mesmo.
