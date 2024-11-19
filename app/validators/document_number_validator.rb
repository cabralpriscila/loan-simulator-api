class DocumentNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    
    document_number = value.to_s.gsub(/[^\d]/, '')

    unless document_number.match?(/^\d{11}$/)
      record.errors.add(attribute, :invalid_format, message: 'formato inválido')
      return
    end

    if document_number.chars.uniq.size == 1
      record.errors.add(attribute, :invalid, message: 'não é válido')
      return
    end

    sum = 0
    9.times { |i| sum += document_number[i].to_i * (10 - i) }
    result = sum % 11
    first_digit = result < 2 ? 0 : 11 - result

    sum = 0
    10.times { |i| sum += document_number[i].to_i * (11 - i) }
    result = sum % 11
    second_digit = result < 2 ? 0 : 11 - result

    unless document_number[-2].to_i == first_digit && document_number[-1].to_i == second_digit
      record.errors.add(attribute, :invalid, message: 'não é válido')
    end
  end
end