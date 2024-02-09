require "rails_helper"

describe Layout::MainLinksComponent, type: :component do
  it "renders main links" do
    I18n.with_locale(:es) { render_inline Layout::MainLinksComponent.new }

    expect(page).to have_link "Cabildo Abierto", href: "/_cabildo_que-es-el-cabildo-abierto"
    expect(page).to have_link "Transparencia", href: "https://transparencia.tenerife.es/"
    expect(page).to have_link "Participación y colaboración", href: "/_participacion_que-hacemos"
    expect(page).to have_link "Datos Abiertos", href: "https://datos.tenerife.es/es/"
    expect(page).to have_link "Ética Pública", href: "/_etica_codigo-de-buen-gobierno-y-seguimiento"
  end
end
