class Issue < ApplicationRecord
  belongs_to :node, touch: true

  has_many :evidence, dependent: :destroy
  has_many :affected, through: :evidence, source: :node

  def self.set_project_scope(project_id)
    default_scope do
      joins(:node).where("nodes.project_id" => project_id).readonly(false)
    end
  end
end
