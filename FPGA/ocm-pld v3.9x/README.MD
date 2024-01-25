# OCM-PLD v3.9.2plus

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/R6R2BRGX6)

# Quer ler em Português?

A versão em português desse documento está logo abaixo :)

# Version Selection Cheat Sheet

| Firmware Version | OPL3 Mono | OPL3 Stereo | SN76489 | SMS VDP | PS/2 Mouse as MSX Mouse | Paddle using PS/2 Mouse | 2x PSG | MIDI Out | Turbo-R PCM | Second 4MB Mapper |
| :--------------- | :-------: | :---------: | :-----: | :-----: | :---------------------: | :---------------------: | :----: | :------: | :---------: | :---------------: |
| MC2P             | Yes       | Yes         | Yes     | Yes     | Yes                     | Yes                     | Yes    | Yes      | Yes         | Yes               |
| SM-X/SX2         | Yes       | No          | No      | No      | Yes                     | Yes                     | Yes    | Yes      | Yes         | Yes               |
| SM-X/SX2 Franky  | No        | No          | Yes     | Yes     | Yes                     | Yes                     | Yes    | Yes      | Yes         | Yes               |
| SM-X/SX2 Snd     | Yes       | No          | Yes     | No      | Yes                     | Yes                     | Yes    | Yes      | Yes         | Yes               |
| SM-X Mini        | Yes       | No          | No      | No      | Yes                     | Yes                     | Yes    | Yes      | Yes         | No                |
| SM-X Mini Franky | No        | No          | Yes     | Yes     | Yes                     | Yes                     | Yes    | Yes      | Yes         | No                |
| SM-X Mini Snd    | Yes       | No          | Yes     | No      | Yes                     | Yes                     | Yes    | Yes      | Yes         | No                |
| SM-X HB          | No        | No          | No      | No      | Yes                     | Yes                     | Yes    | Yes      | Yes         | No                |
| SM-X HB Franky   | No        | No          | Yes     | Yes     | No                      | No                      | No     | No       | No          | No                |
| SM-X HB Snd      | No        | No          | Yes     | No      | Yes                     | No                      | Yes    | Yes      | Yes         | No                |

NOTE: NEVER, EVER THINK ABOUT USING MC2P IF YOU DON'T HAVE MC2P, SM-X IF YOUR
DEVICE IS OTHER THAN SM-X, ETC... Cheat Sheet is only to help you choose what
version for your device has the features you want. If your device doesn't have
a feature or the combination of features you want, DO NOT USE THE FIRMWARE OF
OTHER DEVICE, IT WILL BRICK YOUR DEVICE AND YOU WILL ONLY BE ABLE TO RECOVER IT
USING USB BLASTER AND A PC. YOU'VE BEEN WARNED!

# I'm lost and don't know what version to choose for my device

CHOOSING.TXT file will help you, but the Lazy Couch Penguin version is: first
get ocmsm_XXXX_3.9.2plus.7z file where XXXX is your device name. IMPORTANT:
SM-X HB Mini IS A SM-X HB DEVICE AND USES SM-X HB FILES. NEVER, EVER THINK ON
USING SM-X Mini FOR SM-X HB Mini! My first recommendation as the version I use
and find it funnier and more interesting is the FRANKY version, language that
matches the layout of your PS/2 keyboard, dual EPBIOS and backslash. It allows
you to play Coleco (COL4MMM, use COM - Franky version), SG1000 (SG1000 or SSMS)
and Sega Master System (SSMS or converted games). Note that for SMX-HB you
won't have PS/2 Mouse as MSX Mouse, Turbo-R MIDI, second PSG and PCM when using
that version.

# I don't like to read manuals, how do I upgrade?

Read the above note and download the right version for your device, in the file
you will find a PLD file and a JIC file. Copy the PLD file and SMXFLASH.COM to
your card, and when in MSX DOS run SMXFLASH OCM-SM.PLD

However, you might not enjoy the new features as much if you don't read the
MINI-MANUAL-EN-US.txt file

# New in relation to v3.9.1plus

- Picked up all 3.9.2 updates that weren't on 3.9.1plus, check the original
  3.9.2 KdL release. Note: new PS2 controller is absent since I've understood
  that some keyboards that work today on OCM 3.9 and lower might stop working
  with the new controller if the proposed hardware updates are not made.

- Version that have SN76489, the issue were some note kept playing after a
  reset has been fixed.

- Versions that have SN76489, it was updated with the latest JT89 version, it
  fixes a sound issue with SMS Populous.

- Versions that have Franky, the issue where VDP runs 3,3% faster and caused
  video output @62Hz Horizontal Frequency has been fixed, some games played
  slightly faster and some monitors / TVs did not recognize SMS video output
  due to that refresh rate.

- SMX-HB Franky version: given the updates from 3.9.2, unfortunately PSG 2 had
  to go to leave space for the updates. Sorry!

- All versions: OPLL / MSX Music improvement, test register bit 2 functionality
  (Phase Lock) has been implemented, now FMPCM works correctly.

# Release notes

OCM-PLD v3.9.2plus is an extension on KdL OCM release v3.9.2. What this
extension brings to the table:

- New supported devices:

    - SMX-HB, SMX-HB EX and SMX-HB MINI: It is a 1.75gen device. Its FPGA has
      about 1/3 less logic cells as result of components shortage. It is meant
      to replace the motherboard of Hotbit / Expert MSX Computers (HB / HB EX),
      adding (almost) the full OCM-SM experience. HB MINI is like the original
      SM-X in the fact it uses PS/2 keyboards and has its own case. As being a
      device with real MSX Keyboard (HB and EX ONLY), it has its own needs
      (some doesn't apply to HB MINI that uses only PS/2 keyboards):

        - I've added support to a third keyboard map table, so you have the one
        from the build (us/br/fr/es/it) and japanese if using PS/2 and one for
        the MSX keyboard Hotbit/Expert have. Hotbit and Expert keyboards are
        not standard and their mapping are very peculiar as PS/2 keyboards have
        a different mapping. DIP switch 9 set to OFF is the default, using the
        MSX Keyboard mapping, if set to ON it will use the mapping the firmware
        has built-in, that is handy when you want to use an external PS/2
        keyboard. (HB MINI always should have DIP 9 set to on)

        - Fix: Select key was not working on original 3.7.1 based release, it
        works now. (HB)

        - Improvement: SELECT + UP and SELECT + DOWN replaces Page Up and Page
        Down, so it is possible to activate the autofire module using only
        SMX-HB internal keyboard. Also, SELECT + F1 to F4 replaces F9 to F12,
        making it possible to use most of the keyboard shortcuts. (HB)

        - Missing: it doesn't support OPL3 as it won't fit on the FPGA used. It
          doesn't support paddle emulation on franky/snd version due to the
          same reason. In HB firmware, Franky version also doesn't have the
          following features: PS/2 mouse as MSX mouse, Turbo-R MIDI out through
          joystick port 2 and Turbo-R PCM. (HB, EX and HB MINI)

    - Multicore 2+: it is like a MiSTER device, but with less FPGA capacity (
    more than double of second gen devices, but about half of MiSTER) and also
    without an extra ARM core to help with USB devices (so it uses SEGA Genesis
    / Mega Drive controllers or SEGA Master System controllers and PS/2 mouse
    and keyboards). One advantage it has over MiSTER is that it was made with
    an expansion slot that you can insert expansions that allows to use real
    cartridges/interfaces for the device. There is a SM-X expansion available
    that adds three MSX Slots and ESP Wi-Fi.

        - Legacy: all features from OCM 3.8 build by Roberto Focosi and Victor
        Trucco were ported, so it supports the external slots extension, usage
        of images instead of needing a dedicated SD card, keyboard layout
        selection using OSD menu, etc.

        - Fix: when using images instead of dedicated SD card, writing to the
        card could cause errors / failures, now it should be working fine
        everytime.

        - Improvement: MC2+ has SEGA Genesis / Mega Drive joystick port. As
        such, my initial 3.7.1 version used only two buttons of any joystick
        and allowed invoking OSD using MODE + START on an eight button joystick
        , Focosi release ditched invoking OSD for sake of simplicity of design,
        I've restored invoking OSD and now ALL 8 buttons can be used on Joymega
        compatible games/software as well, for both joysticks. It also works
        with 4 buttons joysticks (Joymega) and 2 buttons joysticks (Master
        System joystick detected as regular MSX joystick).

        - Unique behavior: since MC2+ doesn't have dip switches but uses OSD
        being invoked through F12 key, turbo changing through F12 key was
        removed and it can be adjusted only on the OSD menu (F12 or MODE+START
        on joystick 1) or using switched I/O or software that sets the CPU
        speed. Since you need to hit F12 to invoke OSD and hit it back to
        remove it, it was not nice having F12 also switching the CPU clock.

        - Unique behavior: paddle emulation is turned on/off through the OSD
        menu, SETSMART commands for paddle won't have any effect.

        - Improvement: in general all DIP settings are done through the OSD. If
        you are using a disk image, settings are saved / kept on the SD Card,
        and restored back when OSD is invoked. When using a dedicated SD Card,
        since the card is owned by the MSX as a whole, it is not possible to
        save settings in it as the SD Card I/O is not assigned to the MC2+
        microcontroller that makes the OSD a reality, so whenever you pop up
        the OSD, settings are reset to "default values", since microcontroller
        doesn't know settings on FPGA and could not save the settings into the
        SD Card to read back when invoked again. Due to that I've changed a few
        of those settings to alow sane defaults. Remember: if using dedicated
        SD card, set all settings the way you want before exiting OSD. If you
        invoke OSD again the default values will be loaded and your settings
        all lost / need to set it again. There is no other way around it
        currently.

        - Extra: if you have a ZX Next Expansion for MC2+ but doesn't have the
        SM-X one, you can use it after enabling it on the OSD. Currently the
        only feature supported is use of Wi-Fi / ESP. IMPORTANT: SM-X / Second
        Gen OCM devices use a customized ESP firmware, and ZX Next use standard
        "AT" firmware from Espressif. In order to make this feature useful, you
        need to have a second ESP-01 module flashed with the customized ESP
        firmware, so you can just put it into the extension when using it for
        MSX, and put back the original one when using it for ZX Next.
        Instructions on how to flash the custom ESP firmware are available at:
        https://youtu.be/uoaiEamWUUg

- For devices/builds supporting OPL3:

    - Fix: I've fixed OPL3, it had two issues that prevented it to work with
      the latest VGMPlay version (KdL's OCM 3.9.1 or newer also incorporates
      those fixes):

        - IRQ was not connected, so timers programmed wouldn't trigger,
          instead only the VDP interrupt, to slow, so music would play darn
          slow with VGMPlay.

        - Even after fixing that, playing speed was almost half of the correct
          speed for VGMs. The timer scaler was not properly set causing it to
          trigger slower than programmed.

      Since VGMPlay 1.3 relies on OPL3 timer when present to drive a high speed
      interrupt, not having IRQ and not having the proper scaler for timer
      caused its timing to be slow, darn slow...

    - Fix for second gen devices (KdL's OCM 3.9.1 or newer also incorporates
      those fixes): I've fixed OPL3 sound rendering as it was discarding all
      information that is on right output channel only, unfortunately we do not
      have enough FPGA resources to run the sequencer for two channels, but a
      clever trick allows all songs content to be properly played in MONO glory
      :P Try as an example Doom soundtrack track 3 before updating and after
      updating it. :)

    - Improvement for Multicore 2+: since MC2+ has a really large FPGA, OPL3
      works in real stereo mode since it can acommodate the extra registers
      needed for it that do not fit on regular second gen devices.

    - Extra (KdL's OCM 3.9.1 or newer also incorporates this): Second PSG on
      ports 0x10 to 0x13. It also allows the PSG registers to be read back.
      Unlike KdL's build, this one has the second PSG enabled as standard.

- For firmwares supporting Franky's SN76489 only:

    - Extra: I've added partial support to a built-in Franky. That partial
      support is good enough to work with SG1000, COL4MMM (using COM\Franky
      versions) VGMPLAY, ROBOPLAY and Sofarun (remember to set it to use MSX
      VDP and Franky's PSG). As Franky sound uses I/O ports 0x48 and 0x49, and
      those ports are part of the switched I/O, it is usually disabled, as OCM
      IPL loader will leave switched I/O selected after booting. There are 
      different ways to enable Franky sound:

        - Latest release of COL4MMM automatically disables switched I/O, so no
        need for a SETSMART command or using VGMPLAY before.

        - VGMPLAY will automatically disable switched I/O, so you can play a
        VGM song that uses SN76489 and after exiting VGMPLAY you can use other
        software.

        - De-select the internal switched I/O by sending the basic command
        OUT &H40,0

        - Use SETSMART -8C to enable the I/O ports 0x48 and 0x49 for that, so
        any program relying on reading OCM information on those ports won't
        get it.

- For firmwares with Franky VDP:

        - Sega Master System VDP embedded. Video switch is automatic, as soon
          as Franky VDP generates interrupts its video output is shown. When
          that VDP stops generating interruptions, MSX video is shown.

- For all devices:

    - Improved (KdL's OCM 3.9.1 or newer also incorporates this): Victor Trucco
      and KdL made improvements on the SDRAM controller so it is able to work
      with different chips. Some SM-X mini and SMX-HB use chips that need this
      to work. MC2P, SX2 and standard SM-X can activate a second 4MB memory
      mapper (this mapper was implemented by KdL).

    - Extra: I've added Paddle emulation when using a PS/2 mouse. To enable
      VAUS (Arkanoid/Taito) Paddle emulation use SETSMART -8E, to enable MSX
      standard paddle emulation use SETSMART -8F, to disable it (default) use
      SETSMART -8D. Note that MSX Standard paddle only works properly if Z80
      clock is 3.58MHz, like a real MSX Standard paddle on a MSX machine with
      turbo CPU. Supported on all builds except SMX-HB Snd/Franky.

    - Fix (KdL's OCM 3.9.1 or newer also incorporates this): I've fixed mouse
      emulation. It was not possible to move a single pixel on X axis.

    - Fix (KdL's OCM 3.9.1 or newer also incorporates this): Mouse emulation
      would not work nice if you had an eight button mega drive joystick
      connected with joymega. Now it detects properly.

    - Fix (KdL's OCM 3.9.1 or newer also incorporates this): When switching
      from mouse to joystick or joystick to mouse, joystick port is
      "disconnected" for 1 second. On a real MSX it is not possible to change
      from joystick to mouse without disconnecting each one so HIDTEST and
      software that uses HIDLIB to detect rely on the device being disconnected
      for a while to detect its removal and then be able to see the new device
      being connected.

    - Improvement (KdL's OCM 3.9.1 or newer also incorporates this): ported the
      Multicore 2+ Mouse emulation to all devices. It is a better approach as
      it has a time-out to return to the first state after a few time without
      communication, like a real MSX mouse.

    - Fix (KdL's OCM 3.9.1 or newer also incorporates this): there was a bug in
      z80 implementation causing issues while playing Lilly's Saga, fix
      provided by Hara-san.

All source code and binaries that changed in relation to OCM 3.9.2:
(c)2022-2024 Oduvaldo Pavan Junior - ducasp@gmail.com

All source code from OCM 3.9.2 originally is a work of many people, including
KdL and Hara-san that are really huge contributors to it!

All code can be re-used, re-written, derivative work can be sold, as long as the
source code of changes is made public as well.

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

- Todas versões: OPLL / MSX Music melhorado, implementação da funcionalidade do
  registro de testes ativada pelo bit 2 (Phase Lock), agora o FMPCM funciona de
  forma correta.

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
