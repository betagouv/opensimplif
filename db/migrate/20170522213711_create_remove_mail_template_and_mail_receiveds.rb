class CreateRemoveMailTemplateAndMailReceiveds < ActiveRecord::Migration[5.0]
  def up
    drop_table :mail_templates
  end

  def down
    create_table :mail_templates do |t|
      t.string :object
      t.text :body
      t.string :type
    end

    add_belongs_to :mail_templates, :procedure
  end
end
