class CommentaireDecorator < Draper::Decorator
  delegate_all

  def created_at_fr
    created_at.localtime.strftime('%d/%m/%Y - %H:%M')
  end
end
