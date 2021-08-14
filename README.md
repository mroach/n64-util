# N64 Utils

## Background

When I got an Everdrive 64, I wanted to apply de-blur patches in the `/ED64/patches` directory.
This requires patches to be named with the CRC1 of the ROM. Finding this was tedious,
especially as most tools for ROM info discovery are Windows GUI utilities and I wanted
something cross-platform and command-line based so I could script patch application.

## Philosophy

* Written in Ruby to keep it simple and reasonably portable.
* No external dependencies. All Ruby standard library.

## n64_rom_info

Given a directory or file path, shows all info by reading the ROM headers.

Example usage and output:

```shell
$ ./n64_rom_info ~/roms/n64/
File Name                                                   Format ROM Title            Ver     Region CIC  CRC 1          Size
-------------------------------------------------------------------------------------------------------------------------------
1080 Snowboarding (Japan, USA) (En,Ja).z64                     z64 1080 SNOWBOARDING    1.0  asia_ntsc 6103 0x1FBAF161   16 MiB
Banjo-Kazooie (USA) (Rev A).z64                                z64 Banjo-Kazooie        1.1         us 6103 0xCD7559AC   16 MiB
Banjo-Tooie (USA).z64                                          z64 BANJO TOOIE          1.0         us 6105 0xC2E9AA9A   32 MiB
Conker's Bad Fur Day (USA).z64                                 z64 CONKER BFD           1.0         us 6105 0x30C7AC50   64 MiB
Diddy Kong Racing (USA) (En,Fr) (Rev A).z64                    z64 Diddy Kong Racing    1.1         us 6103 0xE402430D   12 MiB
Donkey Kong 64 (USA).z64                                       z64 DONKEY KONG 64       1.0         us 6105 0xEC58EABF   32 MiB
F-1 World Grand Prix II (Europe) (En,Fr,De,Es).n64             v64 F1 WORLD GRAND PRIX2 1.0         eu 6102 0x874965A3   12 MiB
F-ZERO X (E) [!].z64                                           z64 F-ZERO X             1.0         eu 6106 0x776646F6   16 MiB
F-Zero X (Europe).n64                                          v64 F-ZERO X             1.0         eu 6106 0x776646F6   16 MiB
F-Zero X (Europe).z64                                          z64 F-ZERO X             1.0         eu 6106 0x776646F6   16 MiB
F-Zero X (USA).z64                                             z64 F-ZERO X             1.0         us 6106 0xB30ED978   16 MiB
Goldeneye.v64                                                  v64 GOLDENEYE            1.0         us 6102 0xDCBC50D1   16 MiB
Jet Force Gemini (USA).z64                                     z64 JET FORCE GEMINI     1.0         us 6105 0x8A6009B6   32 MiB
Killer Instinct Gold (USA) (Rev B).z64                         z64 Killer Instinct Gold 1.2         us 6102 0xF908CA4C   12 MiB
Legend of Zelda, The - Majora's Mask (USA).z64                 z64 ZELDA MAJORA'S MASK  1.0         us 6105 0x5354631C   32 MiB
Legend of Zelda, The - Ocarina of Time (U) (V1.2) [!].z64      z64 THE LEGEND OF ZELDA  1.2         us 6105 0x693BA2AE   32 MiB
Legend of Zelda, The - Ocarina of Time (USA) (Rev B).z64       z64 THE LEGEND OF ZELDA  1.2         us 6105 0x693BA2AE   32 MiB
Lylat Wars (Europe) (En,Fr,De).z64                             z64 STARFOX64            1.0         eu 7102 0xF4CBE92C   12 MiB
Paper Mario (USA).z64                                          z64 PAPER MARIO          1.0         us 6103 0x65EEE53A   40 MiB
Perfect Dark (USA) (Rev A).z64                                 z64 Perfect Dark         1.1         us 6105 0x41F2B98F   32 MiB
Pilotwings 64 (USA).z64                                        z64 Pilot Wings64        1.0         us 6102 0xC851961C    8 MiB
Sin and Punishment.v64                                         v64 TSUMI TO BATSU       1.0         jp 6102 0xB6BC0FB0   32 MiB
Sin and Punishment.z64                                         z64 TSUMI TO BATSU       1.0         jp 6102 0xB6BC0FB0   32 MiB
Star Fox 64 (USA) (Rev A).z64                                  z64 STARFOX64            1.1         us 6101 0xBA780BA0   12 MiB
Star Wars - Rogue Squadron (USA) (Rev A).z64                   z64 Rogue Squadron       1.0         us 6102 0x66A24BEC   16 MiB
Super Mario 64 (USA).z64                                       z64 SUPER MARIO 64       1.0         us 6102 0x635A2BFF    8 MiB
Super Smash Bros. (USA).n64                                    v64 SMASH BROTHERS       1.0         us 6103 0x916B8B5B   16 MiB
Super Smash Bros. (USA).z64                                    z64 SMASH BROTHERS       1.0         us 6103 0x916B8B5B   16 MiB
Tsumi to Batsu - Hoshi no Keishousha (Japan).n64               v64 TSUMI TO BATSU       1.0         jp 6102 0xB6BC0FB0   32 MiB
Tsumi to Batsu - Hoshi no Keishousha (Japan).z64               z64 TSUMI TO BATSU       1.0         jp 6102 0xB6BC0FB0   32 MiB
Wave Race 64 (USA) (Rev A).z64                                 z64 WAVE RACE 64         1.1         us 6102 0x492F4B61    8 MiB
```

Or for a single file:

```shell
$ ./n64_rom_info ~/Downloads/n64/Tsumi\ to\ Batsu\ -\ Hoshi\ no\ Keishousha\ \(Japan\).z64
Title:        TSUMI TO BATSU
File format:  Z64 (Big-endian, Native)
File size:    32.00 MiB
ROM ID:       GU
Media:        Cartridge
Version:      0
Region:       Japan
CIC:          CIC-NUS-6102
CRC 1:        0xB6BC0FB0
CRC 2:        0xE3812198
```

It's also possible to output the data in JSON, making it easier to consumer from another application:

```shell
$ ./n64_rom_info --output=json ~/Downloads/n64/Tsumi\ to\ Batsu\ -\ Hoshi\ no\ Keishousha\ \(Japan\).z64
{
  "title": "TSUMI TO BATSU",
  "rom_id": "GU",
  "version": 0,
  "file_format": "z64",
  "file_size": 33554432,
  "file_path": "/home/mroach/Downloads/n64/Tsumi to Batsu - Hoshi no Keishousha (Japan).z64",
  "file_name": "Tsumi to Batsu - Hoshi no Keishousha (Japan).z64",
  "region": "jp",
  "media_format": "N",
  "cic": 6102,
  "crc1": "B6BC0FB0",
  "crc2": "E3812198"
}
```


## n64_rom_formats

Nintendo 64 ROMs are distributed in multiple format:

* **z64** - Big-endian.
* **v64** - Big-endian, byte-swapped.
* **n64** - Little-endian.

The native format for the Nintendo 64 is big-endian, so **z64**.
Many distributed ROMs have the correct extension, but some don't.
The `n64_rom_formats` tool scans a directory for all ROMs that are not in the native `z64` format.

* If the file extension is wrong, it will suggest how to rename it.
* For all ROMs, it will suggest converting it to the native format.

```shell
$ ./n64_rom_formats ~/Downloads/n64
Super Smash Bros. (USA).n64 is in v64 format.
Its file extension is wrong. To fix:
  $ mv "/home/mroach/Downloads/n64/Super Smash Bros. (USA).n64" "/home/mroach/Downloads/n64/Super Smash Bros. (USA).v64"

To convert the file to the native file format:
  $ objcopy -I binary -O binary --reverse-bytes=2 "/home/mroach/Downloads/n64/Super Smash Bros. (USA).n64" "/home/mroach/Downloads/n64/Super Smash Bros. (USA).z64"
```
