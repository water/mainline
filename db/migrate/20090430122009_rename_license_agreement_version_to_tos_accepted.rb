class RenameLicenseAgreementVersionToTosAccepted < ActiveRecord::Migration
  def self.up
    add_column :users, :terms_of_use, :boolean
    User.all.each do |u|
      u.update_attributes({
        terms_of_use: !! u.accepted_license_agreement_version
      })
    end
    remove_column :users, :accepted_license_agreement_version
    User.update_all(["terms_of_use = ?", false])
  end

  def self.down
    rename_column :users, :terms_of_use, :accepted_license_agreement_version
    change_column :users, :accepted_license_agreement_version, :string
  end
end
