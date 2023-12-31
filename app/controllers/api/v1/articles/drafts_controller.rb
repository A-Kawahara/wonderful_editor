module Api::V1
  class Articles::DraftsController < BaseApiController
    def index
      articles = current_user.articles.draft.order(updated_at: :desc)
      render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
    end

    def show
      article = current_user.articles.draft.find(params[:id])
      render json: article, serializer: Api::V1::ArticleSerializer
    end
  end
end
