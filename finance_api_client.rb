require 'httparty'

class FinanceApiClient
  include HTTParty
  base_uri ENV.fetch('FINANCE_API_URL')

  def initialize(version)
    @version = version
  end

  def create_person(name:, last_name:, birthday:)
    consume('people') { { person: { name:, last_name:, birthday: } } }
  end

  def create_terminal(alias:)
    consume('terminals') { { terminal: { alias: } } }
  end

  def create_account(person_id:, balance:)
    consume('accounts') { { account: { person_id:, balance: } } }
  end

  def create_transaction(account_id:, amount:, terminal_id:, request_id:)
    consume('transactions', request_id:) { { transaction: { account_id:, terminal_id:, amount:, timestamp: Time.now } } }
  end

  private

  def endpoint_for(resource:)
    "/api/#{@version}/#{resource}"
  end

  def consume(resource, request_id: SecureRandom.uuid, method: :post)
    uri = endpoint_for(resource:)

    options = { headers: { 'X-Request-ID' => request_id, 'Accept' => 'application/json' } }
    options[:body] = yield if block_given?

    self.class.send(method, uri, options)
  end
end
