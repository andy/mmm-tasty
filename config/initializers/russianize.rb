module Russianize
  def pluralize(one, two, three, include_self = false)
    n = self.ceil.to_i
    word = case n % 100
    when 10..20: three
    else
      case n % 10
      when 1: one
      when 2..4: two
      else three
      end
    end
    "#{include_self ? n.to_s + " " : ""}#{word}"
  end
end

class Fixnum
  include Russianize
end

class Float
  include Russianize
end