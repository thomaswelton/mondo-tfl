namespace :mt do
  task pull_and_attach: :environment do
    Rake::Task["mt:pull_journeys"].invoke
    Rake::Task["mt:attach_receipts"].invoke
  end

  task pull_journeys: :environment do
    User.all.each do |user|
      puts "#{user.name}"
      puts "Refreshing Token"
      user.request_new_token
      begin
        pjs = PullJourneysService.new(user: user)
        puts "Requesting Journeys for #{user.name} <#{user.uid}>"
        pjs.pull
      rescue => e
        puts "ERROR PULLING JOURNEYS FOR USER: #{user.name} <#{user.uid}> #{e}"
      end
    end
  end

  task attach_receipts: :environment do
    User.all.each do |user|
      next unless user.mondo.account_id
      puts "#{user.name}"
      puts "Refreshing Token"
      user.request_new_token
      grs = GenerateReceiptsService.new(user: user)
      puts "\tattaching receipts"
      grs.attach
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
