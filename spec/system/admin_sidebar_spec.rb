# frozen_string_literal: true

require "spec_helper"

describe "Admin sidebar with stratified sortitions" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let!(:component) do
    create(:component, manifest_name: "stratified_sortitions", participatory_space: participatory_process, name: { en: "Citizens panel draw" })
  end
  let(:allowed_emails) { "" }

  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with("STRATIFIED_SORTITIONS_ALLOWED_EMAILS", "").and_return(allowed_emails)

    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
  end

  it "hides the stratified sortitions component" do
    expect(page).to have_no_link("Citizens panel draw")
  end

  context "when the admin email is allowed" do
    let(:allowed_emails) { " other@example.org, #{user.email.upcase} " }

    it "shows the stratified sortitions component" do
      expect(page).to have_link("Citizens panel draw")
    end
  end
end
