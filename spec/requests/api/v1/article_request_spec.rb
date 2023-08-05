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
    subject { post(api_v1_articles_path, params: params)}

    let(:params) { { article: attributes_for(:article) } }
    let(:current_user) { create(:user) }
    before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) }

    let (:current_user_test) {create(:user)}

    let (:params) do
      { article: attributes_for(:article)}
    end
      
    before {allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user_test)}
  
    context "適切なパラメータを送信したとき" do
      
      it "記事が作成できる" do
        # binding.pry
        expect { subject }.to change { Article.where(user_id: current_user_test.id).count }.by(1)
        res = JSON.parse (response.body)
        expect(res["title"]).to eq params[:article][:title]
        expect(res["body"]).to eq params[:article][:body]
        expect(response).to have_http_status(200)
       end
     end
    
    context "不適切なバラメーターを送信したとき" do
      let(:params) { attributes_for(:article)}
  
      it "エラーが発生する" do
        expect{ subject }.to raise_error{ActionController::ParameterMissing}
      end
    end	
    end

end
