class User < ActiveRecord::Base

  include BCrypt

  has_one :account

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password_hash, presence: true

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  def self.find_by_email(email)
    where("LOWER(email) = ?", email.to_s.downcase.strip).first if email.present?
  end

end
