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

  describe 'notification_text' do
    let(:attribute_change) { 'attribute' }
    let(:service) { described_class.new(type_notif, 1, attribute_change) }

    subject { service.notification.liste.first }

    context 'comment' do
      let(:type_notif) { 'commentaire' }

      it { is_expected.to eq 'Un nouveau commentaire sur le dossier.' }
    end

    context 'comment' do
      let(:type_notif) { 'commentaire_champ' }

      it { is_expected.to eq 'Un nouveau commentaire sur un champ.' }
    end

    context 'comment' do
      let(:type_notif) { 'commentaire_piece' }

      it { is_expected.to eq 'Un nouveau commentaire sur une pièce.' }
    end

    context 'cerfa' do
      let(:type_notif) { 'cerfa' }

      it { is_expected.to eq 'Un nouveau formulaire a été déposé.' }
    end

    context 'piece_justificative' do
      let(:type_notif) { 'piece_justificative' }

      it { is_expected.to eq attribute_change }
    end

    context 'champs' do
      let(:type_notif) { 'champs' }

      it { is_expected.to eq attribute_change }
    end

    context 'submitted' do
      let(:type_notif) { 'submitted' }

      it { is_expected.to eq 'Le dossier n°1 a été déposé.' }
    end
  end
end