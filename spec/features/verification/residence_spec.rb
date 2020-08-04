require 'rails_helper'

feature 'Residence' do

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
    ENV["SOAP_URL_SVD"] = ""
    ENV["SOAP_URL_PET"] = ""
    ENV["SOAP_URL_VER"] = ""
    ENV["SOAP_URL_VER1"] = ""
    ENV["SOAP_URL_AMB"] = ""
    ENV["SOAP_URL_NS8"] = ""

    allow_any_instance_of(SaraNet).to(receive(:verify_residence).and_return(true))
    allow_any_instance_of(ConectorRegistroEntidadesJuridicas).to(receive(:validUserAsoc?).and_return(true))
    allow_any_instance_of(ConectorRegistroEntidadesJuridicas).to(receive(:validUserFund?).and_return(true))    
  end

  background { create(:geozone) }

  scenario 'Verify resident' do
    user = create(:user)
    login_as(user)

    visit account_path
    click_link 'Verify my account'

    fill_in 'residence_document_number', with: "12345678Z"
    select 'DNI', from: 'residence_document_type'
    select_date '31-December-1980', from: 'residence_date_of_birth'
    fill_in 'residence_postal_code', with: '28013'
    check 'residence_terms_of_service'

    click_button 'Verify residence'

    #expect(page).to have_content 'Residence verified'
  end

  xscenario 'When trying to verify a deregistered account old votes are reassigned' do
    erased_user = create(:user, document_number: '12345678Z', document_type: '1', erased_at: Time.current)
    vote = create(:vote, voter: erased_user)
    new_user = create(:user)

    login_as(new_user)

    visit account_path
    click_link 'Verify my account'

    fill_in 'residence_document_number', with: '12345678Z'
    select 'DNI', from: 'residence_document_type'
    select_date '31-December-1980', from: 'residence_date_of_birth'
    fill_in 'residence_postal_code', with: '28013'
    check 'residence_terms_of_service'

    click_button 'Verify residence'

    #expect(page).to have_content 'Residence verified'

    expect(vote.reload.voter).to eq(new_user)
    expect(erased_user.reload.document_number).to be_blank
    expect(new_user.reload.document_number).to eq('12345678Z')
  end

  scenario 'Error on verify' do
    user = create(:user)
    login_as(user)

    visit account_path
    click_link 'Verify my account'

    click_button 'Verify residence'

    expect(page).to have_content(/\d errors? prevented the verification of your residence/)
  end

  scenario 'Error on postal code not in census' do
    user = create(:user)
    login_as(user)

    visit account_path
    click_link 'Verify my account'

    fill_in 'residence_document_number', with: "12345678Z"
    select 'DNI', from: 'residence_document_type'
    select '1997', from: 'residence_date_of_birth_1i'
    select 'January', from: 'residence_date_of_birth_2i'
    select '1', from: 'residence_date_of_birth_3i'
    fill_in 'residence_postal_code', with: '12345'
    check 'residence_terms_of_service'

    click_button 'Verify residence'

    expect(page).to have_content 'In order to be verified, you must be registered'
  end

  scenario 'Error on census' do
    user = create(:user)
    login_as(user)

    visit account_path
    click_link 'Verify my account'

    fill_in 'residence_document_number', with: "12345678Z"
    select 'DNI', from: 'residence_document_type'
    select '1997', from: 'residence_date_of_birth_1i'
    select 'January', from: 'residence_date_of_birth_2i'
    select '1', from: 'residence_date_of_birth_3i'
    fill_in 'residence_postal_code', with: '28013'
    check 'residence_terms_of_service'

    click_button 'Verify residence'

    #expect(page).to have_content 'The Census was unable to verify your information'
  end

  xscenario '5 tries allowed' do
    user = create(:user)
    login_as(user)

    visit account_path
    click_link 'Verify my account'

    5.times do
      fill_in 'residence_document_number', with: "12345678Z"
      select 'DNI', from: 'residence_document_type'
      select '1997', from: 'residence_date_of_birth_1i'
      select 'January', from: 'residence_date_of_birth_2i'
      select '1', from: 'residence_date_of_birth_3i'
      fill_in 'residence_postal_code', with: '28013'
      check 'residence_terms_of_service'

      click_button 'Verify residence'
      #expect(page).to have_content 'The Census was unable to verify your information'
    end

    click_button 'Verify residence'
    expect(page).to have_content "You have reached the maximum number of attempts. Please try again later."
    expect(page).to have_current_path(account_path)

    visit new_residence_path
    expect(page).to have_content "You have reached the maximum number of attempts. Please try again later."
    expect(page).to have_current_path(account_path)
  end
end
