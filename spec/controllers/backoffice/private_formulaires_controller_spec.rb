require 'spec_helper'

describe Backoffice::PrivateFormulairesController, type: :controller do
  let(:gestionnaire) { create :gestionnaire }
  let(:dossier) { create :dossier, state: :initiated }
  let(:dossier_champs_first) { 'plop' }

  before do
    create :assign_to, procedure_id: dossier.procedure.id, gestionnaire_id: gestionnaire.id

    sign_in gestionnaire
  end

  describe '#PATCH update' do
    subject { patch :update, params: {dossier_id: dossier.id, champs: {"'#{dossier.champs_private.first.id}'" => dossier_champs_first}} }

    context 'without errors' do
      before { subject }

      it { expect(response.status).to eq 200 }
      it { expect(Dossier.find(dossier.id).champs_private.first.value).to eq dossier_champs_first }
      it { expect(flash[:notice]).to be_present }
    end

    context 'with errors' do
      before { expect(ChampsService).to receive(:save_formulaire) { [{message: 'Erreur 1'}, {message: 'Erreur 2'}] } }
      before { subject }

      it { expect(flash.alert).to eq 'Erreur 1<br>Erreur 2' }
    end
  end
end
