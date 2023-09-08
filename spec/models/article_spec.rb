# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  body       :text
#  status     :integer          default(0), not null
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_articles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Article, type: :model do
  context "title, bodyが入力されているとき" do
    let(:user) { create(:user) }
    let(:current_user_id) { user.id }
    it "記事が作られる" do
      article = build(:article, user_id: current_user_id)
      expect(article).to be_valid
    end
  end

  context "titleが空欄のとき" do
    let(:user) { create(:user) }
    let(:current_user_id) { user.id }
    it "エラーが発生する" do
      article = build(:article, user_id: current_user_id, title: nil)
      expect(article).to be_invalid
      expect(article.errors.details[:title][0][:error]).to eq :blank
    end
  end

  context "bodyが空欄のとき" do
    let(:user) { create(:user) }
    let(:current_user_id) { user.id }
    it "エラーが発生する" do
      article = build(:article, user_id: current_user_id, body: nil)
      expect(article).to be_invalid
      expect(article.errors.details[:body][0][:error]).to eq :blank
    end
  end

  context "titleとbodyが空欄のとき" do
    let(:user) { create(:user) }
    let(:current_user_id) { user.id }
    it "エラーが発生する" do
      article = build(:article, user_id: current_user_id, title: nil, body: nil)
      expect(article).to be_invalid
      expect(article.errors.details[:title][0][:error]).to eq :blank
      expect(article.errors.details[:body][0][:error]).to eq :blank
    end
  end

  describe "正常系" do
    context "タイトルと本文が入力されているとき" do
      let(:article) { build(:article) }

      it "下書き状態の記事が作成できる" do
        expect(article).to be_valid
        expect(article.status).to eq "draft"
      end
    end

    context "status が下書き状態のとき" do
      let(:article) { build(:article, :draft) }
      it "記事を下書き状態で作成できる" do
        expect(article).to be_valid
        expect(article.status).to eq "draft"
      end
    end

    context "status が公開状態のとき" do
      let(:article) { build(:article, :published) }
      it "記事を公開状態で作成できる" do
        expect(article).to be_valid
        expect(article.status).to eq "published"
      end
    end
  end
end
