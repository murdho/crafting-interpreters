# frozen_string_literal: true

# Source: https://github.com/rails/rails/blob/main/activesupport/lib/active_support/core_ext/big_decimal/conversions.rb

require "bigdecimal"
require "bigdecimal/util"

module ActiveSupport
  module BigDecimalWithDefaultFormat # :nodoc:
    def to_s(format = "F")
      super(format)
    end
  end
end

BigDecimal.prepend(ActiveSupport::BigDecimalWithDefaultFormat)
