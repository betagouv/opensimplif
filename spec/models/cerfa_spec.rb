require 'spec_helper'

describe Cerfa do
  describe 'database columns' do
    it { is_expected.to have_db_column(:content) }
    it { is_expected.to have_db_column(:original_filename) }
    it { is_expected.to have_db_column(:content_secure_token) }
    it { is_expected.to have_db_column(:created_at) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:dossier) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'empty?', vcr: { cassette_name: 'models_cerfa_empty' } do
    subject { create(:cerfa, content: content) }
    context 'when content exist' do
      let(:content) { File.open('./spec/support/files/piece_justificative_388.pdf') }
      it { expect(subject).not_to be_empty }
    end
    context 'when content is nil' do
      let(:content) { nil }
      it { expect(subject).to be_empty }
    end
  end
end
