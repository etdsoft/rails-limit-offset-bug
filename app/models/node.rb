class Node < ApplicationRecord
  belongs_to :project, touch: true
  has_many :evidence, dependent: :destroy

  def self.set_project_scope(project_id)
    default_scope { where(project_id: project_id) }
  end
end
