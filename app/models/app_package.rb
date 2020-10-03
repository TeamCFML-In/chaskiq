# frozen_string_literal: true

class AppPackage < ApplicationRecord
  has_many :app_package_integrations, dependent: :destroy
  has_many :apps, through: :app_package_integrations
  belongs_to :author, class_name: 'Agent', optional: true

  #belongs_to :author, classify_name: 'Agent', optional: true 

  acts_as_taggable_on :tags, :capabilities

  store :settings, accessors: %i[
    definitions
    icon
    editor_definitions
    credentials
    initialize_url
    configure_url
    submit_url
    sheet_url
  ], coder: JSON

  validates :name, presence: true, uniqueness: true
  validates :initialize_url, url: true, if: ->{ is_external? }
  validates :configure_url, url: true, if: ->{ is_external? }
  validates :submit_url, url: true, if: ->{ submit_url.present? }
  validates :sheet_url, url: true, if: ->{ sheet_url.present? }

  before_save :set_default_definitions

  def is_external?
    external = message_api_klass rescue nil
    external.nil?
  end

  # for authorizations
  def process_global_hook(params)
    self.message_api_klass.process_global_hook(params)
  end

  def set_default_definitions
    return if definitions.present?
    self.definitions = []
  end

  # message api
  def message_api_klass
    @message_api_klass ||= "MessageApis::#{self.name.classify}".constantize
  end

end
