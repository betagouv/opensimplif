require 'spec_helper'

describe 'layouts/left_panels/_left_panel_backoffice_dossierscontroller_show.html.haml', type: :view do
  let!(:dossier) { create(:dossier, :with_entreprise,  state: state) }
  let(:state) { 'draft' }
  let(:gestionnaire) { create(:gestionnaire) }

  before do
    sign_in gestionnaire
    assign(:facade, (DossierFacades.new dossier.id, gestionnaire.email))

    @request.env['PATH_INFO'] = 'backoffice/user'

    render
  end

  subject { rendered }

  it 'dossier number is present' do
    expect(rendered).to have_selector('#dossier_id')
    expect(rendered).to have_content(dossier.id)
  end
end
