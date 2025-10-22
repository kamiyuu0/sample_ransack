class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # エラーハンドリング（テスト環境でのみ有効）
  if Rails.env.test?
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

    private

    def render_not_found
      respond_to do |format|
        format.html { render file: "#{Rails.root}/public/404.html", status: :not_found }
        format.json { render json: { error: "Not Found" }, status: :not_found }
      end
    end
  end
end
