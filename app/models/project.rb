class Project < ApplicationRecord
  has_many :nodes, dependent: :destroy
end
