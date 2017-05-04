class RootController < ApplicationController
  def index
    begin
      route = Rails.application.routes.recognize_path(request.referrer)
    rescue ActionController::RoutingError
      route = Rails.application.routes.recognize_path(new_user_session_path)
    end

    if user_signed_in? && !route[:controller].match('users').nil?
      return redirect_to simplifications_path

    elsif administrateur_signed_in? && !route[:controller].match('admin').nil?
      return redirect_to admin_procedures_path

    elsif user_signed_in?
      return redirect_to simplifications_path

    elsif administrateur_signed_in?
      return redirect_to admin_procedures_path
    end

    @demo_environment_host = 'https://tps-dev.apientreprise.fr' unless Rails.env.development?

    render 'landing'
  end
end
