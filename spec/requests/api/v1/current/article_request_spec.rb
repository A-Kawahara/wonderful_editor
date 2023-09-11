require "rails_helper"

RSpec.describe "Current::ArticlesController", type: :request do
  describe "GET / api/v1/current/articles" do
    subject { get(api_v1_current_articles_path, headers: headers) }

    let!(:user) { create(:user) }
    let!(:headers) { user.create_new_auth_token }

    let!(:article1) { create(:article, :published, updated_at: 1.days.ago, user: user) }
    let!(:article2) { create(:article, :published, updated_at: 2.days.ago, user: user) }
    let!(:article3) { create(:article, :published, user: user) }

    before { create(:article, :draft, user: user) }

    it "自分が書いた公開記事一覧が降順に取得できる" do
      subject
      res = JSON.parse(response.body)

      expect(res.length).to eq 3 # 全ての記事が表示される
      expect(res.map {|d| d["id"] }).to eq [article3.id, article1.id, article2.id]
      expect(res[0].keys).to eq ["id", "title", "status", "updated_at", "user"]
      expect(res[0]["user"].keys).to eq ["id", "name", "email"]
      expect(response).to have_http_status(:ok)
    end
  end
end
