namespace :mt do
  task pull_and_attach: :environment do
    Rake::Task["mt:refresh_user_tokens"].invoke
    Rake::Task["mt:pull_journeys"].invoke
    Rake::Task["mt:attach_receipts"].invoke
  end

  task refresh_user_tokens: :environment do
    User.all.each do |user|
      begin
        puts "#{user.name}"
        puts "Refreshing Token"
        user.request_new_token
      rescue => e
        puts "ERROR Refreshing token for USER: #{user.name} <#{user.uid}> #{e}."
      end
    end
  end

  task pull_journeys: :environment do
    User.all.each do |user|
      begin
        puts "Requesting Journeys for #{user.name} <#{user.uid}>"
        pjs = PullJourneysService.new(user: user)
        pjs.call
      rescue => e
        puts "ERROR requesting journeys for USER: #{user.name} <#{user.uid}> #{e}."
      end
    end
  end

  task attach_receipts: :environment do
    User.all.each do |user|
      begin
        puts "Attaching Receipts to #{user.name} <#{user.uid}>"
        grs = GenerateReceiptsService.new(user: user)
        grs.call
      rescue => e
        puts "ERROR attaching receipts for USER: #{user.name} <#{user.uid}> #{e}."
      end
    end
  end

  task clear_receipts: :environment do
    User.all.each do |user|
      next unless user.mondo.account_id
      txs = user.transactions
      txs.each do |tx|
        tx.attachments.first.deregister if tx.attachments.first
      end
    end
  end
end
