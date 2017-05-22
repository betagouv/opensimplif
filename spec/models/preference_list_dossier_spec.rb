require 'rails_helper'

describe PreferenceListDossier do
  it { is_expected.to have_db_column(:libelle) }
  it { is_expected.to have_db_column(:table) }
  it { is_expected.to have_db_column(:attr) }
  it { is_expected.to have_db_column(:attr_decorate) }
  it { is_expected.to have_db_column(:bootstrap_lg) }
  it { is_expected.to have_db_column(:order) }
  it { is_expected.to have_db_column(:filter) }
  it { is_expected.to have_db_column(:gestionnaire_id) }

  it { is_expected.to belong_to(:gestionnaire) }
  it { is_expected.to belong_to(:procedure) }

  describe '.available_columns_for' do
    let(:procedure_id) { nil }

    subject { PreferenceListDossier.available_columns_for procedure_id }

    describe 'dossier' do
      subject { super()[:dossier] }

      it { expect(subject.size).to eq 3 }

      describe 'dossier_id' do
        subject { super()[:dossier_id] }

        it { expect(subject[:libelle]).to eq 'N°' }
        it { expect(subject[:table]).to be_nil }
        it { expect(subject[:attr]).to eq 'id' }
        it { expect(subject[:attr_decorate]).to eq 'id' }
        it { expect(subject[:bootstrap_lg]).to eq 1 }
        it { expect(subject[:order]).to be_nil }
        it { expect(subject[:filter]).to be_nil }
      end

      describe 'created_at' do
        subject { super()[:created_at] }

        it { expect(subject[:libelle]).to eq 'Créé le' }
        it { expect(subject[:table]).to be_nil }
        it { expect(subject[:attr]).to eq 'created_at' }
        it { expect(subject[:attr_decorate]).to eq 'first_creation' }
        it { expect(subject[:bootstrap_lg]).to eq 2 }
        it { expect(subject[:order]).to be_nil }
        it { expect(subject[:filter]).to be_nil }
      end

      describe 'updated_at' do
        subject { super()[:updated_at] }

        it { expect(subject[:libelle]).to eq 'Mise à jour le' }
        it { expect(subject[:table]).to be_nil }
        it { expect(subject[:attr]).to eq 'updated_at' }
        it { expect(subject[:attr_decorate]).to eq 'last_update' }
        it { expect(subject[:bootstrap_lg]).to eq 2 }
        it { expect(subject[:order]).to be_nil }
        it { expect(subject[:filter]).to be_nil }
      end
    end

    describe 'user' do
      subject { super()[:user] }

      it { expect(subject.size).to eq 1 }

      describe 'email' do
        subject { super()[:email] }

        it { expect(subject[:libelle]).to eq 'Email' }
        it { expect(subject[:table]).to eq 'user' }
        it { expect(subject[:attr]).to eq 'email' }
        it { expect(subject[:attr_decorate]).to eq 'email' }
        it { expect(subject[:bootstrap_lg]).to eq 2 }
        it { expect(subject[:order]).to be_nil }
        it { expect(subject[:filter]).to be_nil }
      end
    end

    context 'when a procedure ID is pasted' do
      let(:procedure) { (create :procedure, :with_type_de_champ) }
      let(:procedure_id) { procedure.id }

      describe 'champs' do
        subject { super()[:champs] }

        it { expect(subject.size).to eq 1 }

        describe 'first champs' do
          subject { super()["type_de_champ_#{procedure.types_de_champ.first.id}"] }

          it { expect(subject[:libelle]).to eq 'Description' }
          it { expect(subject[:table]).to eq 'champs' }
          it { expect(subject[:attr]).to eq procedure.types_de_champ.first.id }
          it { expect(subject[:attr_decorate]).to eq 'value' }
          it { expect(subject[:bootstrap_lg]).to eq 2 }
          it { expect(subject[:order]).to be_nil }
          it { expect(subject[:filter]).to be_nil }
        end
      end
    end
  end
end
