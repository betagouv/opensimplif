require 'rails_helper'

describe Users::CommentairesController, type: :controller do
  let(:dossier) { create(:dossier) }
  let(:dossier_id) { dossier.id }
  let(:email_commentaire) { 'test@test.com' }
  let(:texte_commentaire) { 'Commentaire de test' }

  before do
    allow(ClamavService).to receive(:safe_file?).and_return(true)
  end

  describe '#POST create' do
    context 'successful creation of a comment' do
      subject do
        sign_in dossier.user
        post :create, params: {dossier_id: dossier_id, texte_commentaire: texte_commentaire}
      end

      it 'redirects to recapitulative page' do
        subject
        expect(response).to redirect_to(backoffice_dossier_path(dossier_id))
      end

      it 'does not send a notification email' do
        expect(NotificationMailer).not_to receive(:new_answer)
        expect(WelcomeMailer).not_to receive(:deliver_now!)

        subject
      end

      it 'creates an internal notification' do
        expect { subject }.to change(Notification, :count).by 1
      end
    end

    context 'when document is uploaded with a comment', vcr: {cassette_name: 'controllers_sers_commentaires_controller_upload_doc'} do
      let(:document_upload) { Rack::Test::UploadedFile.new('./spec/support/files/piece_justificative_0.pdf', 'application/pdf') }

      subject do
        sign_in dossier.user
        post :create, params: {dossier_id: dossier_id, texte_commentaire: texte_commentaire, piece_justificative: {content: document_upload}}
      end

      it 'creates a new piece justificative' do
        expect { subject }.to change(PieceJustificative, :count).by(1)
      end

      it 'clamav check the pj' do
        expect(ClamavService).to receive(:safe_file?)
        subject
      end

      describe 'piece justificative created' do
        it 'does not have a type, but has a content' do
          subject

          expect(PieceJustificative.last.type_de_piece_justificative).to be_nil
          expect(PieceJustificative.last.content).not_to be_nil
        end
      end

      describe 'comment created' do
        it 'has a piece justificative reference' do
          subject

          expect(Commentaire.last.piece_justificative).not_to be_nil
          expect(Commentaire.last.piece_justificative).to eq PieceJustificative.last
        end
      end
    end

    describe 'change dossier state after post a comment' do
      context 'when user is connected' do
        context 'when dossier is replied' do
          before do
            sign_in dossier.user
            dossier.replied!

            post :create, params: {dossier_id: dossier_id, texte_commentaire: texte_commentaire}
            dossier.reload
          end

          subject { dossier.state }

          it { is_expected.to eq('updated') }
        end
      end
    end
  end
end
