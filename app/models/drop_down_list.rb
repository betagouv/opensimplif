class DropDownList < ActiveRecord::Base
  belongs_to :type_de_champ

  def options
    value.split(%r{[\r\n]|[\r]|[\n]|[\n\r]}).reject(&:empty?)
  end
end
