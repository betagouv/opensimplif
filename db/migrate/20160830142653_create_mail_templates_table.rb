class CreateMailTemplatesTable < ActiveRecord::Migration
  def change
    create_table :mail_templates do |t|
      t.string :object
      t.text :body
      t.string :type
    end

    add_belongs_to :mail_templates, :procedure
  end
end
