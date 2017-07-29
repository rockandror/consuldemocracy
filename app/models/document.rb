class Document < ActiveRecord::Base
  include DocumentUploader::Attachment.new(:attachment)

  belongs_to :user
  belongs_to :documentable, polymorphic: true

  validates :title, presence: true
  validates :attachment, presence: true
  validates :user, presence: true
  validates :documentable_id, presence: true
  validates :documentable_type, presence: true
end
