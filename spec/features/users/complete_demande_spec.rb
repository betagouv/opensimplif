require 'spec_helper'

feature 'user path for dossier creation' do
  let(:user) { create(:user) }
  let(:procedure) { create(:procedure, :published, :with_type_de_champ) }

  # TODO: Test 'dossier' creation without dealing with SIRET

  context 'user cannot access non-published procedures' do
    let(:procedure) { create(:procedure) }

    before do
      visit new_users_dossiers_path(procedure_id: procedure.id)
    end

    scenario 'user is on home page', vcr: {cassette_name: 'complete_demande_spec'} do
      expect(page).to have_content('La procédure n\'existe pas')
    end
  end
end
