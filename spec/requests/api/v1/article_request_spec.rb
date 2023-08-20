require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET / articles" do
    subject { get(api_v1_articles_path) }

    let!(:article1) { create(:article, updated_at: 1.days.ago) }
    let!(:article2) { create(:article, updated_at: 2.days.ago) }
    let!(:article3) { create(:article) }

    it "記事一覧が取得できる" do
      subject
      res = JSON.parse(response.body)

      expect(res.length).to eq 3 # 全ての記事が表示される
      expect(res.map {|d| d["id"] }).to eq [article3.id, article1.id, article2.id]
      expect(res[0].keys).to eq ["id", "title", "updated_at", "user"]
      expect(res[0]["user"].keys).to eq ["id", "name", "email"]
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /articles/:id" do
    subject { get(api_v1_article_path(article_id)) }

    context "指定したidの記事が存在するとき" do
      let(:article) { create(:article) }
      let(:article_id) { article.id }

      it "その記事が取得できる" do
        subject
        res = JSON.parse(response.body)

        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        expect(res["body"]).to eq article.body
        expect(res["updated_at"]).to be_present
        expect(res.keys).to eq ["id", "title", "body", "updated_at", "user"]
        expect(res["user"]["id"]).to eq article.user.id
        expect(res["user"].keys).to eq ["id", "name", "email"]
        expect(response).to have_http_status(:ok)
      end
    end

    context "指定したidの記事が存在しないとき" do
      let(:article_id) { 1000 }

      it "記事が見つからない" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "POST/articles" do
    subject { post(api_v1_articles_path, params: params) }

    let!(:current_user_test) { create(:user) }
    before {
      allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user_test)
    }

    context "適切なパラメータを送信したとき" do
      let(:params) do
        { article: attributes_for(:article) }
      end

      it "記事が作成できる" do
        expect { subject }.to change { Article.where(user_id: current_user_test.id).count }.by(1)
        res = JSON.parse(response.body)
        expect(res["title"]).to eq params[:article][:title]
        expect(res["body"]).to eq params[:article][:body]
        expect(response).to have_http_status(:created)
      end
    end

    context "不適切なバラメーターを送信したとき" do
      let(:params) { attributes_for(:article) }

      it "エラーが発生する" do
        expect { subject }.to raise_error { ActionController::ParameterMissing }
      end
    end
  end

  describe "PATCH /api/v1/articles/:id" do
    subject { patch(api_v1_article_path(article.id), params: params) }

    let(:params) { { article: attributes_for(:article) } }
    let(:current_user_test) { create(:user) }
    before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user_test) }

    context "自分が所持している記事のレコードを更新しようとするとき" do
      let(:article) { create(:article, body: "BODY", user: current_user_test) }

      it "記事を更新できる" do
        expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                              change { article.reload.body }.from(article.body).to(params[:article][:body])
        expect(response).to have_http_status(:ok)
      end
    end

    context "自分が所持していない記事のレコードを更新しようとするとき" do
      let(:other_user) { create(:user) }
      let!(:article) { create(:article, user: other_user) }

      it "更新できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "DELETE /api/v1/articles/:id" do
    subject { delete(api_v1_article_path(article_id)) }

    let(:current_user_test) { create(:user) }
    let(:article_id) { article.id }
    before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user_test) }

    context "自分が所持している記事のレコードを削除しようとするとき" do
      let!(:article) { create(:article, user: current_user_test) }

      it "記事を削除できる" do
        expect { subject }.to change { Article.where(user_id: current_user_test.id).count }.by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context "自分が所持していない記事のレコードを削除しようとするとき" do
      let(:other_user) { create(:user) }
      let!(:article) { create(:article, user: other_user) }

      it "記事を削除できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound) &
                              change { Article.count }.by(0)
      end
    end
  end
end
