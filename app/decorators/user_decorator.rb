class UserDecorator < Draper::Decorator
  delegate_all

  def gender_fr
    return 'Mr' if gender == 'male'
    return 'Mme' if gender == 'female'
  end
end
