require 'spec_helper'

feature 'backoffice: flux de commentaires' do
  let(:gestionnaire) { create(:gestionnaire) }
  let(:dossier) { create(:dossier, :with_entreprise) }
  let(:dossier_id) { dossier.id }

  let(:champ1) { dossier.champs.first }
  let(:champ2) { create(:champ, dossier: dossier, type_de_champ: create(:type_de_champ_public, libelle: "subtitle")) }

  let!(:commentaire1) { create(:commentaire, dossier: dossier, champ: champ1) }
  let!(:commentaire2) { create(:commentaire, dossier: dossier) }
  let!(:commentaire3) { create(:commentaire, dossier: dossier, champ: champ2) }
  let!(:commentaire4) { create(:commentaire, dossier: dossier, champ: champ1) }

  before do
    login_as gestionnaire, scope: :gestionnaire
    visit backoffice_dossier_path(dossier)
  end

  scenario "seuls les commentaires généraux sont affichés" do
    comments = find(".commentaires")
    expect(comments).to have_selector(".content", count: 1)
  end

  scenario "affichage des commentaires du champs", js: true do
    pending 'later: open simplif'
    find("#liste_champs th", text: champ1.libelle).click_link("COM")
    expect(page).to have_css("#modalCommentairesDossierParChamp.in")

    modal = find("#modalCommentairesDossierParChamp")
    expect(modal).to have_css(".description", count: 2)
  end

  scenario "crée un commentaire sur un champ", js: true do
    pending 'later: open simplif'
    # ouverture modale
    find("#liste_champs th", text: champ1.libelle).click_link("COM")

    # ajout du commentaire
    form = find("#modalCommentairesDossierParChamp").find("#commentaire_new")
    form.fill_in("texte_commentaire", with: "le corps du commentaire sur le champ #{champ1.libelle}")
    form.click_on("Poster")

    # le commentaire ne s'ajoute pas aux commentaires généraux
    comments = find("#commentaires_flux")
    expect(comments).to have_selector(".description", count: 1)

    # ajout du commentaire aux commentaires du champs
    find("#liste_champs th", text: champ1.libelle).click_link("COM")
    modal = find("#modalCommentairesDossierParChamp")
    expect(modal).to have_css(".description", count: 3)
  end
end
