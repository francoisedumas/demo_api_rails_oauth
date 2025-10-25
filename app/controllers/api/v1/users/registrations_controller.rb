# frozen_string_literal: true

module Api
  module V1
    module Users
      class RegistrationsController < BaseController
        skip_before_action :doorkeeper_authorize!, only: %i[create]

        include DoorkeeperRegisterable

        def create
          client_app = Doorkeeper::Application.find_by(uid: params[:client_id])

          # Verify both client_id and client_secret
          if client_app.nil? || client_app.secret != params[:client_secret]
            return render json: { error: 'Invalid client credentials' }, status: :unauthorized
          end

          user = User.new(user_params)

          if user.save
            render json: render_user(user, client_app), status: :ok
          else
            render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

        def user_params
          params.permit(:email, :password, :password_confirmation)
        end
      end
    end
  end
end
