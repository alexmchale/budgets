namespace :accounts do

  task :poll => [ :environment ] do

    Account.find_in_batches do |accounts|
      accounts.each do |account|
        account.poll
      end
    end

  end

  task :recur => [ :environment ] do

    Recurrence.find_in_batches do |recurrences|
      recurrences.each do |recurrence|
        recurrence.create_transactions
      end
    end

  end

end
