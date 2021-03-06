module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def log_out
      reset_session
      redirect_to root_path, notice: 'You have successfully logged out.'
    end

    def self.provides_callback_for(provider)
      class_eval %{
        def #{provider}
          @user = User.find_for_oauth(env['omniauth.auth'], current_user)
          if @user.persisted?
            sign_in @user, event: :authentication
            set_flash_message(:notice, :success, kind: "#{provider}".capitalize) if is_navigational_format?
            redirect_to root_url
          else
            session["devise.#{provider}_data"] = env["omniauth.auth"]
            redirect_to root_url
          end
        end
      }
    end

    User.omniauth_providers.each do |provider|
      provides_callback_for provider
    end

    def after_sign_in_path_for(resource)
      if resource.email_verified?
        super resource
      else
        finish_signup_user_path(resource)
      end
    end
  end
end
