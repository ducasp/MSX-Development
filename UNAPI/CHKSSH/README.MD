# CHKSSH v1.10

UNAPI SSH Checker / Key Manager.

(c) 2026 Oduvaldo Pavan Junior - ducasp@gmail.com

## DESCRIPTION

CHKSSH detects and displays information about the first available UNAPI SSH implementation on your MSX, and also provides basic SSH key management operations (generate, import, export).

## USAGE

```
CHKSSH
CHKSSH c
CHKSSH g
CHKSSH <file>
CHKSSH <file> k
CHKSSH <file> p
```

| Command | Action |
|---|---|
| `CHKSSH` (no args) | Print this help text |
| `CHKSSH c` | Show SSH implementation capabilities (connections, supported features, key info) |
| `CHKSSH g` | Ask the SSH implementation to generate a new key pair |
| `CHKSSH <file>` | Import a private key PEM file into the ESP32 device |
| `CHKSSH <file> k` | Export the private key from the ESP32 device to a file |
| `CHKSSH <file> p` | Export the public key from the ESP32 device to a file |

### Examples

```
CHKSSH c
CHKSSH g
CHKSSH TESTPK.PEM
CHKSSH MYKEY.PEM k
CHKSSH MYKEY.PUB p
```

## COMPILATION NOTES

Requires SDCC, Fusion-C library and Konamiman's ASM.LIB.

Set the paths in the Makefile to point to your Fusion-C installation, then run:

```
make
```

## LICENSE

Redistribution and use of this source code or any derivative works, are
permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. Redistributions may not be sold, nor may they be used in a commercial
   product or activity without specific prior written permission.
4. Source code of derivative works MUST be published to the public.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
