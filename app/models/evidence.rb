class Evidence < ApplicationRecord
  belongs_to :issue, touch: true
  belongs_to :node, touch: true


  def self.set_project_scope(project_id)
    default_scope do
      joins(:node).where("nodes.project_id" => project_id).readonly(false)
    end
  end
end
