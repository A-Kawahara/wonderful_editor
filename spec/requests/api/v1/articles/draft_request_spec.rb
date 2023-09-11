require "rails_helper"

RSpec.describe "Articles::DraftsController", type: :request do
  describe "GET / api/v1/articles/drafts" do
    subject { get(api_v1_articles_drafts_path, headers: headers) }

    let!(:user) { create(:user) }
    let!(:headers) { user.create_new_auth_token }

    let!(:article1) { create(:article, :draft, updated_at: 1.days.ago, user: user) }
    let!(:article2) { create(:article, :draft, updated_at: 2.days.ago, user: user) }
    let!(:article3) { create(:article, :draft, user: user) }

    before { create(:article, :published, user: user) }

    it "下書き記事一覧が降順に取得できる" do
      subject
      res = JSON.parse(response.body)

      expect(res.length).to eq 3 # 全ての記事が表示される
      expect(res.map {|d| d["id"] }).to eq [article3.id, article1.id, article2.id]
      expect(res[0].keys).to eq ["id", "title", "status", "updated_at", "user"]
      expect(res[0]["user"].keys).to eq ["id", "name", "email"]
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET / api/v1/articles/drafts/:id" do
    subject { get(api_v1_articles_draft_path(article_id), headers: headers) }

    let!(:user) { create(:user) }
    let!(:headers) { user.create_new_auth_token }

    context "指定したidの下書き記事が存在するとき" do
      let(:article) { create(:article, :draft, user: user) }
      let(:article_id) { article.id }

      it "その記事が取得できる" do
        subject
        res = JSON.parse(response.body)

        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        expect(res["body"]).to eq article.body
        expect(res["status"]).to eq "draft"
        expect(res["updated_at"]).to be_present
        expect(res.keys).to eq ["id", "title", "body", "status", "updated_at", "user"]
        expect(res["user"]["id"]).to eq article.user.id
        expect(res["user"].keys).to eq ["id", "name", "email"]
        expect(response).to have_http_status(:ok)
      end
    end

    context "指定したidの記事が公開記事のとき" do
      let(:article) { create(:article, :published, user: user) }
      let(:article_id) { article.id }

      it "記事が見つからない" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context "指定したidの下書き記事が存在しないどき" do
      let(:article_id) { 1000 }

      it "記事が見つからない" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
