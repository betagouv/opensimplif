require 'spec_helper'

describe Procedure do
  describe 'assocations' do
    it { is_expected.to have_many(:types_de_piece_justificative) }
    it { is_expected.to have_many(:types_de_champ) }
    it { is_expected.to have_many(:dossiers) }
    it { is_expected.to have_many(:mail_templates) }
    it { is_expected.to have_one(:mail_received) }
    it { is_expected.to have_one(:module_api_carto) }
    it { is_expected.to belong_to(:administrateur) }
    it { is_expected.to have_many(:preference_list_dossiers) }
  end

  describe 'attributes' do
    it { is_expected.to have_db_column(:libelle) }
    it { is_expected.to have_db_column(:description) }
    it { is_expected.to have_db_column(:organisation) }
    it { is_expected.to have_db_column(:direction) }
    it { is_expected.to have_db_column(:euro_flag) }
    it { is_expected.to have_db_column(:logo) }
    it { is_expected.to have_db_column(:logo_secure_token) }
    it { is_expected.to have_db_column(:cerfa_flag) }
    it { is_expected.to have_db_column(:published) }

    describe 'mail_received' do
      let(:procedure) { create :procedure }

      before do
        create :mail_received, procedure: procedure
      end

      it { expect(procedure.mail_received).not_to be_nil }
    end

  end

  describe '#build_default_mails' do
    subject { build :procedure }

    it 'call the fonction build_default_mails' do
      expect(subject).to receive(:build_default_mails)
      subject.save
    end

    describe 'accessible values' do

      before do
        subject.save
      end

      it { expect(subject.mail_templates.size).to eq 1 }
      it { expect(subject.mail_received).not_to be_nil }
    end
  end

  describe 'validation' do
    context 'libelle' do
      it { is_expected.not_to allow_value(nil).for(:libelle) }
      it { is_expected.not_to allow_value('').for(:libelle) }
      it { is_expected.to allow_value('Demande de subvention').for(:libelle) }
    end

    context 'description' do
      it { is_expected.not_to allow_value(nil).for(:description) }
      it { is_expected.not_to allow_value('').for(:description) }
      it { is_expected.to allow_value('Description Demande de subvention').for(:description) }
    end

    context 'lien_demarche' do
      it { is_expected.to allow_value(nil).for(:lien_demarche) }
      it { is_expected.to allow_value('').for(:lien_demarche) }
      it { is_expected.to allow_value('http://localhost').for(:lien_demarche) }
    end
  end

  describe '#types_de_champ_ordered' do
    let(:procedure) { create(:procedure) }
    let!(:type_de_champ_0) { create(:type_de_champ_public, procedure: procedure, order_place: 1) }
    let!(:type_de_champ_1) { create(:type_de_champ_public, procedure: procedure, order_place: 0) }
    subject { procedure.types_de_champ_ordered }
    it { expect(subject.first).to eq(type_de_champ_1) }
    it { expect(subject.last).to eq(type_de_champ_0) }
  end

  describe '#switch_types_de_champ' do
    let(:procedure) { create(:procedure) }
    let(:index) { 0 }
    subject { procedure.switch_types_de_champ index }

    context 'when procedure have no types_de_champ' do
      it { expect(subject).to eq(false) }
    end
    context 'when procedure have 2 types de champ' do
      let!(:type_de_champ_0) { create(:type_de_champ_public, procedure: procedure, order_place: 0) }
      let!(:type_de_champ_1) { create(:type_de_champ_public, procedure: procedure, order_place: 1) }
      context 'when index is not the last element' do
        it { expect(subject).to eq(true) }
        it 'switch order place' do
          procedure.switch_types_de_champ index
          type_de_champ_0.reload
          type_de_champ_1.reload
          expect(type_de_champ_0.order_place).to eq(1)
          expect(type_de_champ_1.order_place).to eq(0)
        end
      end
      context 'when index is the last element' do
        let(:index) { 1 }
        it { expect(subject).to eq(false) }
      end
    end
  end

  describe 'locked?' do
    let(:procedure) { create(:procedure, published: published) }

    subject { procedure.locked? }

    context 'when procedure is in draft status' do
      let(:published) { false }
      it { is_expected.to be_falsey }
    end

    context 'when procedure is in draft status' do
      let(:published) { true }
      it { is_expected.to be_truthy }
    end
  end

  describe 'active' do
    let(:procedure) { create(:procedure, published: published, archived: archived) }
    subject { Procedure.active(procedure.id) }

    context 'when procedure is in draft status and not archived' do
      let(:published) { false }
      let(:archived) { false }
      it { expect { subject }.to raise_error(ActiveRecord::RecordNotFound) }
    end

    context 'when procedure is published and not archived' do
      let(:published) { true }
      let(:archived) { false }
      it { is_expected.to be_truthy }
    end

    context 'when procedure is published and archived' do
      let(:published) { true }
      let(:archived) { true }
      it { expect { subject }.to raise_error(ActiveRecord::RecordNotFound) }
    end

    context 'when procedure is in draft status and archived' do
      let(:published) { false }
      let(:archived) { true }
      it { expect { subject }.to raise_error(ActiveRecord::RecordNotFound) }
    end
  end

  describe 'clone' do
    let(:archived) { false }
    let(:published) { false }
    let(:procedure) { create(:procedure, archived: archived, published: published) }
    let!(:type_de_champ_0) { create(:type_de_champ_public, procedure: procedure, order_place: 0) }
    let!(:type_de_champ_1) { create(:type_de_champ_public, procedure: procedure, order_place: 1) }
    let!(:type_de_champ_private_0) { create(:type_de_champ_private, procedure: procedure, order_place: 0) }
    let!(:type_de_champ_private_1) { create(:type_de_champ_private, procedure: procedure, order_place: 1) }
    let!(:piece_justificative_0) { create(:type_de_piece_justificative, procedure: procedure, order_place: 0) }
    let!(:piece_justificative_1) { create(:type_de_piece_justificative, procedure: procedure, order_place: 1) }

    before do
      procedure.mail_received.object = "Je vais être cloné"
    end

    subject { procedure.clone }

    it 'should duplicate specific objects with different id' do
      expect(subject.id).not_to eq(procedure.id)
      expect(subject).to have_same_attributes_as(procedure)
      expect(subject.module_api_carto).to have_same_attributes_as(procedure.module_api_carto)

      expect(subject.types_de_piece_justificative.size).to eq procedure.types_de_piece_justificative.size
      expect(subject.types_de_champ.size).to eq procedure.types_de_champ.size
      expect(subject.types_de_champ_private.size).to eq procedure.types_de_champ_private.size
      expect(subject.mail_templates.size).to eq procedure.mail_templates.size

      subject.types_de_champ.zip(procedure.types_de_champ).each do |stc, ptc|
        expect(stc).to have_same_attributes_as(ptc)
      end

      subject.types_de_champ_private.zip(procedure.types_de_champ_private).each do |stc, ptc|
        expect(stc).to have_same_attributes_as(ptc)
      end

      subject.types_de_piece_justificative.zip(procedure.types_de_piece_justificative).each do |stc, ptc|
        expect(stc).to have_same_attributes_as(ptc)
      end

      subject.mail_templates.zip(procedure.mail_templates).each do |stc, ptc|
        expect(stc).to have_same_attributes_as(ptc)
      end
    end

    it 'should not duplicate specific related objects' do
      expect(subject.dossiers).to eq([])
      expect(subject.gestionnaires).to eq([])
      expect(subject.assign_to).to eq([])
    end

    describe 'procedure status is reset' do
      let(:archived) { true }
      let(:published) { true }
      it 'Not published nor archived' do
        expect(subject.archived).to be_falsey
        expect(subject.published).to be_falsey
        expect(subject.path).to be_nil
      end
    end
  end

  describe 'publish' do
    let(:procedure) { create(:procedure, :published) }
    let(:procedure_path) { ProcedurePath.find(procedure.procedure_path.id) }

    it 'is available from a valid path' do
      expect(procedure.path).to match(/fake_path/)
      expect(procedure.published).to be_truthy
    end

    it 'is correctly set in ProcedurePath table' do
      expect(ProcedurePath.where(path: procedure.path).count).to eq(1)
      expect(procedure_path.procedure_id).to eq(procedure.id)
      expect(procedure_path.administrateur_id).to eq(procedure.administrateur_id)
    end
  end

  describe 'archive' do
    let(:procedure) { create(:procedure, :published) }
    let(:procedure_path) { ProcedurePath.find(procedure.procedure_path.id) }
    before do
      procedure.archive
      procedure.reload
    end

    it 'is not available from a valid path anymore' do
      expect(procedure.path).to eq procedure_path.path
      expect(procedure.published).to be_truthy
      expect(procedure.archived).to be_truthy
    end

    it 'is not in ProcedurePath table anymore' do
      expect(ProcedurePath.where(path: procedure.path).count).to eq(1)
      expect(ProcedurePath.find_by_procedure_id(procedure.id)).not_to be_nil
    end
  end

  describe 'total_dossier' do

    let(:procedure) { create :procedure }

    before do
      create :dossier, procedure: procedure, state: :initiated
      create :dossier, procedure: procedure, state: :draft
      create :dossier, procedure: procedure, state: :replied
    end

    subject { procedure.total_dossier }

    it { is_expected.to eq 2 }
  end
end
