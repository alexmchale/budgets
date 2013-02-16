namespace :accounts do

  task :poll => [ :environment ] do

    Account.find_in_batches do |accounts|
      accounts.each do |account|
        account.poll
      end
    end

  end

end
