class Customer < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :document_number, presence: true, document_number: true
  validates :phone, format: { with: /\A\(\d{2}\)\s\d{4,5}-\d{4}\z/ }, allow_blank: true
  validates :zip_code, format: { with: /\A\d{5}-\d{3}\z/ }, allow_blank: true
  validates :birthdate, presence: true
  validates :income, presence: true, numericality: { greater_than: 0 }
end
