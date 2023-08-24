require "rails_helper"

RSpec.describe "Api::V1::Auth::Registrations", type: :request do
  describe "POST /api/v1/auth" do
    subject { post(api_v1_user_registration_path, params: params) }

    context "必要なパラメーターを送信したとき" do
      let(:params) do
        { registration: attributes_for(:user) }
      end

      it "トークン情報が確認できる(=新規登録ができる)" do
        expect { subject }.to change { User.count }.by(1)
        expect(response.header["access-token"]).not_to be_blank
        res = JSON.parse(response.body)
        expect(res["data"]["name"]).to eq params[:registration][:name]
        expect(res["data"]["email"]).to eq params[:registration][:email]
        expect(response).to have_http_status(:ok)
      end
    end

    context "不適切なパラメーターを送信したとき" do
      let(:params) { attributes_for(:user) }

      it "トークン情報が確認できない(=エラーが発生する)" do
        expect { subject }.to raise_error { ActionController::ParameterMissing }
      end
    end
  end
end
