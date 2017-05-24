require 'rails_helper'

describe 'users/carte/show.html.haml', type: :view do
  let(:state) { 'draft' }
  let(:dossier) { create(:dossier, state: state) }
  let(:dossier_id) { dossier.id }

  before do
    assign(:dossier, dossier)
  end

  context 'sur la page de la carte d\'une demande' do
    before do
      render
    end
    it 'le formulaire envoie vers /users/dossiers/:dossier_id/carte en #POST' do
      expect(rendered).to have_selector("form[action='/users/dossiers/#{dossier_id}/carte'][method=post]")
    end

    it 'la carte est bien présente' do
      expect(rendered).to have_selector('#map')
    end

    context 'présence des inputs hidden' do
      it 'stockage du json des polygons dessinés' do
        expect(rendered).to have_selector('input[type=hidden][id=json_latlngs][name=json_latlngs]', visible: false)
      end
    end

    context 'si la page précédente n\'est pas recapitulatif' do
      it 'le bouton "Etape suivante" est présent' do
        expect(rendered).to have_selector('#etape_suivante')
      end
    end

    context 'si la page précédente est recapitulatif' do
      let(:state) { 'initiated' }

      it 'le bouton "Etape suivante" n\'est pas présent' do
        expect(rendered).not_to have_selector('#etape_suivante')
      end

      it 'le bouton "Modification terminée" est présent' do
        expect(rendered).to have_selector('#modification_terminee')
      end

      it 'le lien de retour au récapitulatif est présent' do
        expect(rendered).to have_selector("a[href='/backoffice/dossiers/#{dossier_id}']")
      end
    end
  end
end
