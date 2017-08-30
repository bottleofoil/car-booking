class ApplicationController < ActionController::API

    def render_error(status, code, message)
        render json: {error: code, error_message: message}, status: status
    end
end
