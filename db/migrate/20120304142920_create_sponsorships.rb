class CreateSponsorships < ActiveRecord::Migration
  def change
    create_table :sponsorships do |t|
      t.references :organisation
      t.references :plaque
      t.timestamps
    end
    Plaque.find(:all).each do |p|
      s = Sponsorship.new
      s.plaque = p
      s.organisation = p.organisation
      s.save
    end
  end
end
