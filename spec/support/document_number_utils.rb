class DocumentNumberUtils
  class << self
    def generate
      numbers = 9.times.map { rand(10) }
      numbers << generate_digit(numbers)
      numbers << generate_digit(numbers)
      numbers.join
    end

    private

    def generate_digit(numbers)
      multipliers = (numbers.size + 1).downto(2)
      sum = numbers.zip(multipliers).sum { |number, multiplier| number * multiplier }
      mod = sum % 11
      mod < 2 ? 0 : 11 - mod
    end
  end
end
