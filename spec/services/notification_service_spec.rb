require 'spec_helper'

describe NotificationService do

  describe '.notify' do
    let(:dossier) { create :dossier }
    let(:service) { described_class.new type_notif, dossier.id }

    subject { service.notify }

    context 'when is the first notification for dossier_id and type_notif and alread_read is false' do
      let(:type_notif) { 'commentaire' }

      it { expect { subject }.to change(Notification, :count).by (1) }
    end
  end

  describe 'text_for_notif' do
    pending
  end
end