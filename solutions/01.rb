class Integer
  def prime_divisors
    2.upto(abs).select { |n| remainder(n).zero? and n.prime? }
  end

  def prime?
    2.upto(pred).all? { |n| remainder(n).nonzero? }
  end
end

class Range
  def fizzbuzz
    map do |number|
      if    number % 15 == 0 then :fizzbuzz
      elsif number % 3  == 0 then :fizz
      elsif number % 5  == 0 then :buzz
      else number
      end
    end
  end
end

class Hash
  def group_values
    each_with_object({}) do |(key, value), result|
      result[value] ||= []
      result[value] << key
    end
  end
end

class Array
  def densities
    map { |item| count item }
  end
end
