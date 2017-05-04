class SiretFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :format) unless value =~ %r{^\d{14}$}
    unless !value.nil? && (luhn_checksum(value) % 10).zero?
      record.errors.add(attribute, :checksum)
    end
  end

  private

  def luhn_checksum(value)
    accum = 0
    value.reverse.each_char.map(&:to_i).each_with_index do |digit, index|
      t = index.even? ? digit : digit * 2
      t -= 9 if t >= 10
      accum += t
    end
    accum
  end
end
