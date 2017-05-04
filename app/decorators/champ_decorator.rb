class ChampDecorator < Draper::Decorator
  delegate_all

  def value
    return object.value == 'on' ? 'Oui' : 'Non' if type_champ == 'checkbox'
    object.value
  end
end
