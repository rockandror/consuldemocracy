require "rails_helper"

describe Users::SessionsController do
  describe "Sign out" do
    describe "when SAML SLO is enabled" do
      before do
        allow(Devise.omniauth_configs[:saml]).to receive(:options).and_return({ idp_slo_service_url: "remote-cas-slo-url.example" })
        request.env["devise.mapping"] = Devise.mappings[:user] # If using Devise
        # request.env["omniauth.auth"] = OmniAuth.config.add_mock(:saml, options: { idp_slo_service_url: "remote-cas-slo-url.example"})
      end

      it "redirects to service provider omniauth saml single logout" do
        session[:saml_uid] = "ext-johndoe"
        session[:saml_session_index] = "_123123123123"

        delete :destroy

        expect(response).to redirect_to("/users/auth/saml/spslo")
      end
    end
  end
end