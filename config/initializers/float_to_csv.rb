# for Performance object
class Float
  def to_csv
    "\"#{self.to_s.tr('.',',')}\""
  end
end