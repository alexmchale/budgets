# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :transaction do
    amount 1
    payee "MyString"
    description "MyString"
    paid_at "2013-01-10 04:48:21"
    transaction_type "MyString"
  end
end
