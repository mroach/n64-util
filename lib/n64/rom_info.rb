# frozen_string_literal: true
require "zlib"

# Inspects the header of a ROM to get basic information
#
# http://en64.shoutwiki.com/wiki/ROM#Cartridge_ROM_Header
module N64
  class RomInfo
    REGION_CODES = {
      "7" => :beta,
      "A" => :asia_ntsc,
      "B" => :br,
      "C" => :cn,
      "D" => :de,
      "E" => :us,
      "F" => :fr,
      "G" => :gw64_ntsc,
      "H" => :nl,
      "I" => :it,
      "J" => :jp,
      "K" => :kr,
      "L" => :gw64_pal,
      "N" => :ca,
      "P" => :eu,
      "S" => :es,
      "U" => :au,
      "W" => :nordic,
      "X" => :eu,
      "Y" => :eu,
    }.freeze

    REGION_NAMES = {
      au:        "Australia",
      br:        "Brazil",
      ca:        "Canada",
      cn:        "China",
      de:        "Germany",
      es:        "Spain",
      eu:        "Europe",
      fr:        "France",
      it:        "Italy",
      jp:        "Japan",
      nl:        "Netherlands",
      us:        "United States",

      asia_ntsc: "Asia (NTSC)",
      beta:      "Beta",
      gw64_ntsc: "Gateway 64 (NTSC)",
      gw64_pal:  "Gateway 64 (PAL)",
      nordic:    "Nordic",
    }.freeze

    MEDIA_FORMATS = {
      "N" => "Cartridge",
      "D" => "64DD Disk",
      "C" => "Cartridge part of an expandable game",
      "E" => "64DD Expansion",
      "Z" => "Aleck64 Cartridge",
    }.freeze

    CIC_CHECKSUM_MAP = {
      0x587BD543 => 5101,
      0x6170A4A1 => 6101,
      0x90BB6CB5 => 6102,
      0x0B050EE0 => 6103,
      0x98BC2C86 => 6105,
      0xACC8580A => 6106,
      0x009E9EA3 => 7102,
      0x0E018159 => 8303,
    }.freeze

    # https://en.wikipedia.org/wiki/List_of_Nintendo_64_ROM_file_formats
    HEADER_Z64 = [0x80, 0x37, 0x12, 0x40].freeze
    HEADER_V64 = [0x37, 0x80, 0x40, 0x12].freeze
    HEADER_N64 = [0x40, 0x12, 0x37, 0x80].freeze

    FILE_FORMATS = {
      z64: "Z64 (Big-endian, Native)",
      v64: "V64 (Big-endian, byte-swapped)",
      n64: "N64 (Little-endian)",
    }.freeze

    attr_reader :path, :file_format

    def initialize(path)
      @path = path
      @file_format = detect_file_format
    end

    def detect_file_format
      case raw_read(0x00, 0x04).unpack("CCCC")
      when HEADER_Z64
        :z64
      when HEADER_V64
        :v64
      when HEADER_N64
        :n64
      end
    end

    def file_size
      File.stat(path).size
    end

    def cic
      boot_code = read_bytes(0x40, 4032)
      crc32 = Zlib.crc32(boot_code)

      if (cic_id = CIC_CHECKSUM_MAP[crc32])
        cic_id
      else
        [:unknown, crc32]
      end
    end

    def crc1
      read_uint32_be(0x10)
    end

    def crc2
      read_uint32_be(0x14)
    end

    def region
      code = read_byte(0x3E, "A")

      if (id = REGION_CODES[code])
        id
      else
        [:unknown, code]
      end
    end

    # Storage medium of the ROM.
    # Typically cartridge, but can be 64DD or an expansion module.
    def media_format
      # Media format occupies 4 bytes but only the last is used, the rest are NUL
      read_bytes(0x38, 4).unpack("AAAA").last
    end

    # String identifier of the software (game)
    # e.g. SUPER MARIO 64
    def title
      read_bytes(0x20, 20).strip
    end

    # Universal identifier for the software (game) on the cartridge.
    #
    # Examples:
    #   SM => Super Mario 64
    #   ZL => Legend of Zelda: Ocarina of Time
    def rom_id
      read_bytes(0x3C, 2)
    end

    def version
      read_byte(0x3F)
    end

    def file_name
      File.basename(path)
    end

    def to_h
      hex_prefix = ""

      {
        title: title,
        rom_id: rom_id,
        version: version,
        file_format: file_format,
        file_size: file_size,
        file_path: path,
        file_name: file_name,
        region: region,
        media_format: media_format,
        cic: cic,
        crc1: Util.format_hex(crc1, prefix: hex_prefix),
        crc2: Util.format_hex(crc2, prefix: hex_prefix),
      }
    end

    def to_s
      hex_prefix = "0x"

      <<~EOF
        Title:        #{title}
        File format:  #{FILE_FORMATS[file_format]}
        File size:    #{Util.format_file_size(file_size)}
        ROM ID:       #{rom_id}
        Media:        #{MEDIA_FORMATS[media_format] || media_format}
        Version:      #{version}
        Region:       #{REGION_NAMES[region] || region}
        CIC:          CIC-NUS-#{cic}
        CRC 1:        #{Util.format_hex(crc1, prefix: hex_prefix)}
        CRC 2:        #{Util.format_hex(crc2, prefix: hex_prefix)}
      EOF
    end

    private

    def read_uint32_be(at_byte)
      read_bytes(at_byte, 4).unpack("N").first
    end

    # since byte-swapping may be required depending on the ROM file format,
    # always fetch 2 bytes starting with the even byte and then return the one requested.
    def read_byte(address, unpack_with = "C")
      fmt = "#{unpack_with}#{unpack_with}"

      if address.odd?
        read_bytes(address - 1, 2).unpack(fmt).last
      else
        read_bytes(address, 2).unpack(fmt).first
      end
    end

    def read_bytes(start, len)
      bytes = raw_read(start, len)

      case file_format
      when :z64
        bytes
      when :v64
        Util.byteswap(bytes, 2)
      when :n64
        Util.byteswap(bytes, 4)
      else
        raise NotImplementedError, "No support for #{file_format}"
      end
    end

    def raw_read(start, len)
      File.binread(path, len, start)
    end
  end
end
