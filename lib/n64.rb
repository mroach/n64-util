# frozen_string_literal: true

module N64
  ROM_EXTENSIONS = ["n64", "v64", "z64"].freeze
  PATCH_EXTENSIONS = ["aps", "ips"]
end

require_relative "n64/util"
require_relative "n64/rom_info"
