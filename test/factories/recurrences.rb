# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recurrence do
    account nil
    frequency "MyString"
    starts_at "2013-01-12"
    ends_at "2013-01-12"
  end
end
