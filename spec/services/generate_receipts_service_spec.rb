require 'rails_helper'

describe 'GenerateReceiptsServiceSpec' do
  describe '#call' do
    before :each do
      FakeWeb.allow_net_connect = false
      FakeWeb.register_uri(:get, 'https://api.getmondo.co.uk/accounts', body: {accounts: accounts}.to_json, content_type: 'application/javascript')
    end

    it 'should do nothing and return 0 when no transactions are returned from mondo' do
      gsr = GenerateReceiptsService.new(user: user)
      allow(gsr.mondo).to receive(:transactions) {[]}
      expect(gsr.call).to eq(0)
    end

    it 'should do nothing and return 0 if there are 0 TFL transactions' do
      gsr = GenerateReceiptsService.new(user: user)
      tx = Mondo::Transaction.new(transactions(:non_tfl), gsr.mondo)
      allow(gsr.mondo).to receive(:transactions) { [tx] }
      expect(gsr.call).to eq(0)
    end

    it 'should request all transactions from mondo if no journeys' do
      gsr = GenerateReceiptsService.new(user: user)
      expect(gsr.mondo).to receive(:transactions).with(hash_including(since: nil)).once.and_return []
      gsr.call
    end

    it 'should request transactions from mondo since the last matched journey' do
      journey = user.journeys.first
      journey.mondo_transaction_id = 'tx_1234'
      journey.save
      gsr = GenerateReceiptsService.new(user: user)
      expect(gsr.mondo).to receive(:transactions).with(hash_including(since: 'tx_1234')).once.and_return []
      gsr.call
    end

    it 'should deregister existing attachments if set to overwrite' do
      gsr = GenerateReceiptsService.new(user: user, overwrite: true)
      tx = Mondo::Transaction.new(transactions(:with_attachments).first, gsr.mondo)
      allow(gsr.mondo).to receive(:transactions) { [tx] }
      tx.attachments.map { |attachment| expect(attachment).to receive(:deregister).once }
      gsr.call
    end

    context 'when transactions are matched to journeys' do
      before :each do
        @gsr = GenerateReceiptsService.new(user: user)
        @txs = transactions(:first_import).map { |tx| Mondo::Transaction.new(tx, @gsr.mondo) }
        @txs.map { |tx| allow(tx).to receive(:register_attachment) }
        allow(@gsr.mondo).to receive(:transactions) { @txs }
        allow(@gsr).to receive(:mondo_image_receipt_url_for) { 'https://upload-attachment-here.com' }
      end

      it 'should return number matched transactions' do
        expect(@gsr.call).to eq(4)
      end

      it 'should register each attachment with the url given by Mondo' do
        @txs.map { |tx| expect(tx).to receive(:register_attachment).with(hash_including(file_url: 'https://upload-attachment-here.com')) }
        @gsr.call
      end

      it 'should update each journey with the transaction id' do
        @gsr.call
        expect(user.journeys[0].mondo_transaction_id).to eq('tx_1')
        expect(user.journeys[1].mondo_transaction_id).to eq('tx_2')
        expect(user.journeys[2].mondo_transaction_id).to eq('tx_2')
        expect(user.journeys[3].mondo_transaction_id).to eq('tx_3')
        expect(user.journeys[4].mondo_transaction_id).to eq('tx_4')
      end

      it 'should return 0 if we run twice on the same data' do
        expect(@gsr.call).to eq(4)
        expect(@gsr.call).to eq(0)
      end

      it 'should return 0 if we have new transaction date but no journeys to match to' do
        expect(@gsr.call).to eq(4)
        expect(@gsr.call).to eq(0)
        @txs = transactions(:second_import).map { |tx| Mondo::Transaction.new(tx, @gsr.mondo) }
        allow(@gsr.mondo).to receive(:transactions) { @txs }
        expect(@gsr.call).to eq(0)
      end

      it 'should return 0 if we have new journeys but no new transactions' do
        expect(@gsr.call).to eq(4)
        expect(@gsr.call).to eq(0)
        user.journeys.create!(card: user.cards.first, from: 'someplace', to: 'somewhere', date: Date.today.to_s, time: '06:00 - 06:30', fare: 130, tapped_in_mod: 360, tapped_out_mod: 390)
        expect(@gsr.call).to eq(0)
      end

      it 'should return 1 if we have a new journey AND a new transaction that MATCH' do
        expect(@gsr.call).to eq(4)
        expect(@gsr.call).to eq(0)
        new_txs = transactions(:second_import).map { |tx| Mondo::Transaction.new(tx, @gsr.mondo) }
        new_txs.map { |tx| allow(tx).to receive(:register_attachment) }
        allow(@gsr.mondo).to receive(:transactions) { new_txs }
        user.journeys.create!(card: user.cards.first, from: 'someplace', to: 'somewhere', date: '2016-05-22', time: '06:00 - 06:30', fare: 150, tapped_in_mod: 360, tapped_out_mod: 390)
        expect(@gsr.call).to eq(1)
      end

      it 'should not add journeys to a transaction that has already been processed'
      # i.e if we were to request transactions since (1 week before the last transaction), then it shouldn't match
      # unmatched journeys with the transactions that already have journeys matched to them.
      #
      # i'm currently operating on the assumption that transactions are always settled in order
      # i.e. another transaction can't be pushed into the feed at an earler date.
      # which makes sense as we're using the pagination since: <date>
      #

    end
  end
end

def user
  @user ||= begin
    user = User.create!(provider: 'Mondo',
                             uid: 'mondo_user_id',
                           token: '12345',
                   refresh_token: '67890',
                      expires_at: 2.days.from_now,
                            name: 'Mark Watney',
                    tfl_username: 'mark.watney@nasa.gov',
                    tfl_password: 'londonisbetterthanmars')
    card = user.cards.create(last_4_digits: 1234, expiry: '01/2036', network: 'MasterCard')
    journeys.each do |j|
      user.journeys.create!(card: card, from: j[:from], to: j[:to], date: j[:date], time: j[:time], fare: j[:fare], tapped_in_mod: j[:tapped_in_mod], tapped_out_mod: j[:tapped_out_mod])
    end
    user
  end
end

def transactions(key)
  HashWithIndifferentAccess.new(YAML.load(File.read('./spec/fixtures/transactions.yml')))[key]
end

def accounts
  YAML.load(File.read('./spec/fixtures/accounts.yml')).map { |a| HashWithIndifferentAccess.new(a) }
end

def journeys
  YAML.load(File.read('./spec/fixtures/journeys.yml')).map { |j| HashWithIndifferentAccess.new(j) }
end
