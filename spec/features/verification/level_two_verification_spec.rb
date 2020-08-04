require 'rails_helper'

feature 'Level two verification' do

  # MOCK SaraNET
  before(:each) do
    ENV['SOAP_PLATINO_PKCS12_PASSWORD'] = ""
    ENV['SARA_WSDL_URL'] = ""
    ENV['SOAP_VERIFICAR_IDENTIDAD_NIF_FUNCIONARIO'] = ""
    ENV['SOAP_VERIFICAR_IDENTIDAD_IDENTIFICADOR_SOLICITANTE'] = ""
    ENV['SOAP_VERIFICAR_IDENTIDAD_NOMBRE_SOLICITANTE'] = ""
    ENV['SOAP_VERIFICAR_IDENTIDAD_COD_PROCEDIMIENTO'] = ""
    ENV['SOAP_VERIFICAR_IDENTIDAD_NOMBRE_PROCEDIMIENTO'] = ""
    ENV['SOAP_VERIFICAR_IDENTIDAD_FINALIDAD'] = ""
    ENV['SOAP_VERIFICAR_IDENTIDAD_ID_EXPEDIENTE'] = ""
    ENV['SOAP_VERIFICAR_RESIDENCIA_NIF_FUNCIONARIO'] = ""
    ENV['SOAP_VERIFICAR_RESIDENCIA_IDENTIFICADOR_SOLICITANTE'] = ""
    ENV['SOAP_VERIFICAR_RESIDENCIA_NOMBRE_SOLICITANTE'] = ""
    ENV['SOAP_VERIFICAR_RESIDENCIA_COD_PROCEDIMIENTO'] = ""
    ENV['SOAP_VERIFICAR_RESIDENCIA_NOMBRE_PROCEDIMIENTO'] = ""
    ENV['SOAP_VERIFICAR_RESIDENCIA_FINALIDAD'] = ""
    ENV['SOAP_VERIFICAR_RESIDENCIA_ID_EXPEDIENTE'] = ""

    allow_any_instance_of(SaraNet).to(receive(:verify_residence).and_return(true))
  
    allow_any_instance_of(ConectorRegistroEntidadesJuridicas).to(receive(:validUserAsoc?).and_return(true))
    allow_any_instance_of(ConectorRegistroEntidadesJuridicas).to(receive(:validUserFund?).and_return(true))      
  end

  scenario 'Verification with residency and sms' do
    create(:geozone)
    user = create(:user)
    login_as(user)

    visit account_path
    click_link 'Verify my account'

    verify_residence

    #fill_in 'sms_phone', with: "611111111"
    #click_button 'Send'

    #expect(page).to have_content 'Security code confirmation'

    #user = user.reload
    #fill_in 'sms_confirmation_code', with: user.sms_confirmation_code
    #click_button 'Send'

    #expect(page).to have_content 'Code correct'
  end

  context "In Spanish, with no fallbacks" do
    before do
      skip unless I18n.available_locales.include?(:es)
      allow(I18n.fallbacks).to receive(:[]).and_return([:es])
    end

    scenario "Works normally" do
      user = create(:user)
      login_as(user)

      visit verification_path(locale: :es)
      verify_residence
    end
  end

end
