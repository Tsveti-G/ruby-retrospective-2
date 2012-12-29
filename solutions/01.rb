class Integer
  def prime_divisors
    i = 2
    result = []
    number = self.abs
    while number != 1
      if number%i == 0
        number /= i while number%i == 0
        result << i
      end
      i += 1
    end
    result
  end
end

class Range
  def fizzbuzz
    result = []
    self.each do |number|
      if number%3 == 0 and number%5 == 0
        result << :fizzbuzz
      elsif number%3 == 0
        result << :fizz
      elsif number%5 == 0
        result << :buzz
      else
        result << number
      end
    end
    result
  end
end

class Hash
  def group_values
    keys = self.keys
    values = self.values
    array = []
    result = {}
    values.each do |item|
      i = 0
      next if item == nil
      while i < values.size
        if item == values[i]
          array << keys[i]
          values[i] = nil
        end
        i += 1
      end
      result[item] = array
      array = []
    end
    result
  end
end

class Array
  def densities
    result = []
    temp = 0
    self.each do |symbol|
      i = 0
      while i < self.size
        temp += 1 if symbol == self[i]
        i += 1
      end
      result << temp
      temp = 0
    end
    result
  end
end
