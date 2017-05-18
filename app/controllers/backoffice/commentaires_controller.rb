class Backoffice::CommentairesController < CommentairesController
  before_action :authenticate_gestionnaire!

  def gestionnaire?
    true
  end
end
