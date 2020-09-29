require "rails_helper"

describe "Residence" do
  let(:burgos_response) do
    {
      get_habita_datos_response: {
        get_habita_datos_return: {
          datos_habitante: {
            item: {
              fecha_nacimiento_string: "31-12-1980",
              identificador_documento: "12345678Z",
              descripcion_sexo: "Varón",
              nombre: "José",
              apellido1: "García"
            }
          },
          datos_vivienda: {
            item: {
              codigo_postal: "09001",
              codigo_distrito: "01"
            }
          }
        }
      }
    }
  end

  before do
    create(:geozone)
    allow_any_instance_of(RemoteCensusApi).to receive(:stubbed_valid_response).and_return(burgos_response)
  end

  scenario "Verify resident throught RemoteCensusApi" do
    Setting["feature.remote_census"] = true

    access_user_data = "get_habita_datos_response.get_habita_datos_return.datos_habitante.item"
    access_residence_data = "get_habita_datos_response.get_habita_datos_return.datos_vivienda.item"
    Setting["remote_census.response.date_of_birth"] = "#{access_user_data}.fecha_nacimiento_string"
    Setting["remote_census.response.postal_code"] = "#{access_residence_data}.codigo_postal"
    Setting["remote_census.response.valid"] = access_user_data
    user = create(:user)
    login_as(user)

    visit account_path
    click_link "Verify my account"

    fill_in "residence_document_number", with: "12345678Z"
    select "DNI", from: "residence_document_type"
    select_date "31-December-1980", from: "residence_date_of_birth"
    fill_in "residence_postal_code", with: "09001"
    check "residence_terms_of_service"
    click_button "Verify residence"

    expect(page).to have_content "Residence verified"
    Setting["feature.remote_census"] = nil
  end
end
