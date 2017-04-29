require 'spec_helper'

feature 'user access to the list of his dossier' do

  let(:user) { create(:user) }
  let!(:last_updated_dossier) { create(:dossier, :with_entreprise, user: user, state: 'replied')}
  let!(:dossier1) { create(:dossier, :with_entreprise, user: user, state: 'replied') }
  let!(:dossier2) { create(:dossier, :with_entreprise) }

  before do
    dossier1.update_column(:updated_at, "19/07/2052 15:35".to_time)
    dossier1.procedure.update_column(:libelle, 'PLOP')
    last_updated_dossier.procedure.update_column(:libelle, 'PLIP')

    visit new_user_session_path
    within('#new_user') do
      page.find_by_id('user_email').set user.email
      page.find_by_id('user_password').set user.password
      page.click_on 'Se connecter'
    end
  end
  scenario 'the list of dossier is displayed' do
    expect(page).to have_content(dossier1.procedure.libelle)
    expect(page).not_to have_content(dossier2.procedure.libelle)
  end

  scenario 'the list must be order by last updated' do
    expect(page.body).to match(/#{last_updated_dossier.procedure.libelle}.*#{dossier1.procedure.libelle}/m)
  end

  scenario 'the state of dossier is displayed' do
    expect(page).to have_css("#dossier_#{dossier1.id}_state")
  end

  context 'when user clicks on a projet in list', js: true do
    before do
      page.find("#tr_dossier_#{dossier1.id}").click
    end
    scenario 'user is redirected to dossier page' do
      expect(page).to have_css('#users_recapitulatif_dossier_show')
    end
  end
end
