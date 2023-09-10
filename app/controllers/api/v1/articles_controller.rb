module Api::V1
  class ArticlesController < BaseApiController
    skip_before_action :authenticate_user!, only: %i[index show]

    def index
      articles = Article.published.order(updated_at: :desc)
      render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
    end

    def show
      article = Article.published.find(params[:id])
      render json: article, serializer: Api::V1::ArticleSerializer
    end

    def create
      article = current_user.articles.new(article_params)

      if article.save
        render json: article, status: :created, serializer: Api::V1::ArticleSerializer
      else
        render json: article.errors, status: :unprocessable_entity
      end
    end

    def update
      article = current_user.articles.find(params[:id])

      if article.update!(article_params)
        render json: article, status: :ok, serializer: Api::V1::ArticleSerializer
      else
        render json: article.errors, status: :unprocessable_entity
      end
    end

    def destroy
      article = current_user.articles.find(params[:id])
      article.destroy!
    end

    private

      def article_params
        params.require(:article).permit(:title, :body, :status)
      end
  end
end
