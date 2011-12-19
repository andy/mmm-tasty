class Array
  def shuffle
    self.sort { Kernel::rand(3) - 1 }
  end
end