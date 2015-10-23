module Penman
  class SeedCode
    def initialize(seed_code = [])
      @seed_code = seed_code
    end

    def << (seed_line)
      @seed_code << seed_line
    end

    def print_with_leading_spaces(num_spaces)
      spaces = "\n" + ' ' * num_spaces
      @seed_code.join(spaces)
    end

    def print_with_leading_tabs(num_tabs)
      tabs = "\n" + "\t" * num_tabs
      @seed_code.join(tabs)
    end
  end
end
