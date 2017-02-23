require 'spec_helper'

describe Users::RecapitulatifController, type: :controller do
  let(:dossier) { create(:dossier, state: 'initiated') }
  let(:bad_dossier_id) { Dossier.count + 100000 }

  before do
    sign_in dossier.user
  end

  describe 'GET #show' do
    it 'returns http success' do
      get :show, params: {dossier_id: dossier.id}
      expect(response).to have_http_status(:success)
    end

    it 'redirection vers siret si mauvais dossier ID' do
      get :show, params: {dossier_id: bad_dossier_id}
      expect(response).to redirect_to('/')
    end

    it_behaves_like "not owner of dossier", :show

    describe 'before_action authorized_routes?' do
      context 'when dossier have draft state' do
        before do
          dossier.state = 'draft'
          dossier.save

          get :show, params: {dossier_id: dossier.id}
        end

        it { is_expected.to redirect_to root_path }
      end
    end

  end

  describe 'POST #initiate' do
    context 'when an user initiate his dossier' do
      before do
        post :initiate, params: {dossier_id: dossier.id}
      end

      it 'dossier change his state for closed' do
        dossier.reload
        expect(dossier.state).to eq('initiated')
      end

      it 'a message informe user what his dossier is initiated' do
        expect(flash[:notice]).to include('Dossier soumis avec succès.')
      end
    end
  end

  describe 'POST #submit' do
    context 'when an user depose his dossier' do
      let(:deposit_datetime) { Time.local(2016, 8, 1, 10, 5, 0) }

      before do
        dossier.validated!
        Timecop.freeze(deposit_datetime) { post :submit, params: {dossier_id: dossier.id} }
        dossier.reload
      end

      it 'dossier change his state for submitted' do
        expect(dossier.state).to eq('submitted')
      end

      it 'dossier deposit datetime is filled' do
        expect(dossier.deposit_datetime).to eq deposit_datetime
      end

      it 'a message informe user what his dossier is initiated' do
        expect(flash[:notice]).to include('Dossier déposé avec succès.')
      end

      it 'Notification email is send' do
        expect(NotificationMailer).to receive(:dossier_submitted).and_return(NotificationMailer)
        expect(NotificationMailer).to receive(:deliver_now!)

        dossier.validated!
        post :submit, params: {dossier_id: dossier.id}
      end

      it 'Internal notification is created' do
        expect(Notification.where(dossier_id: dossier.id, type_notif: 'submitted').first).not_to be_nil
      end
    end
  end
end
