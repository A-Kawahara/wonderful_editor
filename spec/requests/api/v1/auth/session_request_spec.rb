RSpec.describe "Api/V1::Auth::Sessions", type: :request do
  describe "POST /api/v1/auth/sign_in" do
    subject { post(api_v1_user_session_path, params: params) }

    context "適切なパラメーター(email, password)を送信したとき" do
      let(:sign_in_user) { create(:user) }
      let(:params) { { email: sign_in_user.email, password: sign_in_user.password } }

      it "ログインができる" do
        subject
        expect(response).to have_http_status(:ok)
        header = response.header
        expect(header["access-token"]).to be_present
        expect(header["client"]).to be_present
        expect(header["expiry"]).to be_present
        expect(header["uid"]).to be_present
        expect(header["token-type"]).to be_present
      end
    end

    context "emailが不適切なとき" do
      let(:sign_in_user) { create(:user) }
      let(:params) { { email: "sample@email.com", password: sign_in_user.password } }

      it "エラーが発生する" do
        subject
        res = JSON.parse(response.body)
        header = response.header
        expect(res["errors"]).to include "Invalid login credentials. Please try again."
        expect(header["access-token"]).to be_blank
        expect(header["client"]).to be_blank
        expect(headers["uid"]).to be_blank
        expect(response).to have_http_status(:unauthorized)
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "passwordが不適切なとき" do
      let(:user) { create(:user) }
      let(:params) { attributes_for(:user, email: user.email, password: "password") }

      it "エラーが発生する" do
        subject
        res = JSON.parse(response.body)
        header = response.header
        expect(res["errors"]).to include "Invalid login credentials. Please try again."
        expect(header["access-token"]).to be_blank
        expect(header["client"]).to be_blank
        expect(headers["uid"]).to be_blank
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/v1/auth/sign_out" do
    subject { delete(destroy_api_v1_user_session_path, headers: headers) }

    context "ログアウトを実行したとき" do
      let(:user) { create(:user) }
      let!(:headers) { user.create_new_auth_token }

      it "トークン情報を無効にしてログアウトできる" do
        subject
        expect(response).to have_http_status(:ok)
        header = response.header
        expect(header["access-token"]).to be_blank
        expect(header["client"]).to be_blank
      end
    end

    context "誤った情報を送信したとき" do
      let(:user) { create(:user) }
      let!(:headers) { { "access-token" => "", "token-type" => "", "client" => "", "expiry" => "", "uid" => "" } }

      it "ログアウトできない" do
        subject
        expect(response).to have_http_status(:not_found)
        res = JSON.parse(response.body)
        expect(res["errors"]).to include "User was not found or was not logged in."
      end
    end
  end
end
