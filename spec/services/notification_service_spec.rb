require 'rails_helper'

describe NotificationService do
  describe '.notify' do
    subject { service.notify }

    let(:service) { described_class.new type_notif, notification_text, dossier.id }

    let(:type_notif) { 'commentaire' }
    let(:notification_text) { 'Nouveau commentaire sur XXX' }
    let(:dossier) { create :dossier }

    it { expect { subject }.to change(Notification, :count).by 1 }
  end
end
