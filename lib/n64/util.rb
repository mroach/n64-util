# frozen_string_literal: true

module N64
  module Util
    extend self

    def byteswap(bytes, size)
      bytes
        .unpack("c*")
        .each_slice(size)
        .flat_map { |chunk| chunk.reverse.compact }
        .pack("c*")
    end

    def format_hex(bytes, min_length: 8, prefix: "0x")
      format("%s%0#{min_length}X", prefix, bytes)
    end

    def format_file_size(size, base: 1024, precision: 2)
      exp = (Math.log(size) / Math.log(base)).to_i
      format("%.#{precision}f %s", (size / base**exp), ["B", "KiB", "MiB"][exp])
    end
  end
end
