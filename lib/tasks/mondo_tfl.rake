namespace :mondo_tfl do
  task attach_receipts: :environment do
    User.all.each do |user|
      puts "#{user.name}"
      grs = GenerateReceiptsService.new(user: user)
      grs.attach
    end
  end

  task clear_receipts: :environment do
    User.all.each do |user|
      txs = user.transactions
      txs.each do |tx|
        tx.attachments.first.deregister if tx.attachments.first
      end
    end
  end
end
