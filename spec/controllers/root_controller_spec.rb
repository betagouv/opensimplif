require 'spec_helper'

describe RootController, type: :controller do
  subject { get :index }

  context 'when User is connected' do
    before do
      sign_in create(:user)
    end

    it { expect(subject).to redirect_to(users_dossiers_path) }
  end

  context 'when Gestionnaire is connected' do
    let(:gestionnaire) { create(:gestionnaire) }

    before do
      sign_in gestionnaire
    end

    context 'when gestionnaire is affect to a procedure' do
      before do
        create :assign_to, procedure: (create :procedure), gestionnaire: gestionnaire
      end

      it { expect(subject).to redirect_to(backoffice_dossiers_procedure_path(id: Procedure.all.first.id)) }
    end

    context 'when gestionnaire is not affect to a procedure' do
      render_views

      before do
        subject
      end

      it { expect(response.body).to have_css('#landing') }
    end
  end

  context 'when Administrateur is connected' do
    before do
      sign_in create(:administrateur)
    end

    it { expect(subject).to redirect_to(admin_procedures_path) }
  end

  context 'when nobody is connected' do
    render_views

    before do
      stub_request(:get, "https://api.github.com/repos/sgmap/tps/releases/latest").
          to_return(:status => 200, :body => '{"tag_name": "plip", "body": "blabla", "published_at": "2016-02-09T16:46:47Z"}', :headers => {})

      subject
    end

    it { expect(response.body).to have_css('#landing') }

  end

  context 'environment is not development' do
    render_views

    before do
      Rails.env.stub(:development? => false)
      subject
    end

    it { expect(response.body).to have_link('Démonstration', href: "https://tps-dev.apientreprise.fr#{ users_sign_in_demo_path }") }

  end

  context 'environment is development' do
    render_views

    before do
      Rails.env.stub(:development? => true)
      subject
    end

    it { expect(response.body).to have_link('Démonstration', href: users_sign_in_demo_path) }

  end

  context 'when opensimplif features is true' do
    pending
    # let(:gestionnaire) { create(:gestionnaire) }
    #
    # before do
    #   sign_in gestionnaire
    #
    #   allow_any_instance_of(Features).to receive(:opensimplif).and_return(true)
    # end
    #
    # it { expect(subject).to redirect_to(simplifications_path) }
  end

  context "unified login" do
    render_views

    before do
      subject
    end

    it "won't have gestionnaire login link" do
      expect(response.body).to have_css("a[href='#{new_user_session_path}']")
    end
  end

end
