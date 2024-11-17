require 'dotenv/load'
require 'faker'
require 'colorize'
require 'logger'
require_relative 'loggable'
require_relative 'finance_api_client'

class TestRunner
  include Loggable

  set_logger Logger.new($stdout)

  attr_reader :api_version, :terminal_id, :person_id, :account_id, :transaction_ids

  def initialize(api_version)
    @api_version = api_version
    @api_client = FinanceApiClient.new(api_version)
    @transaction_ids = []
  end

  def run(iterations)
    create_terminal
    create_person
    create_account
    simulate_transactions iterations
    print_report iterations
  end

  private

  def print_result(response)
    if response.success?
      append 'success'.green
      flush ' ID: %s', response['id'].to_s.blue
      yield if block_given?
    else
      append 'failed'.red
      flush ' with code %s', response.code.to_s.yellow
    end
  end

  def create_person
    name = Faker::Name.first_name
    last_name = Faker::Name.last_name
    birthday = Faker::Date.birthday(min_age: 18, max_age: 65).strftime('%Y-%m-%d')

    append 'Creating person %s %s born in %s: ', name.blue, last_name.blue, birthday.blue
    response = @api_client.create_person(name:, last_name:, birthday:)
    print_result(response) { @person_id = response['id'] }
  end

  def create_terminal
    name = Faker::Name.gender_neutral_first_name

    append 'Creating terminal %s: ', name.blue
    response = @api_client.create_terminal(alias: name)
    print_result(response) { @terminal_id = response['id'] }
  end

  def create_account
    balance = Faker::Number.decimal(l_digits: 4, r_digits: 2)

    append 'Creating account with balance %s: ', balance.to_s.blue
    response = @api_client.create_account(person_id:, balance: balance)
    print_result(response) { @account_id = response['id'] }
  end

  def simulate_transactions(iterations)
    iterations.times do |tid|
      amount = Faker::Number.decimal(l_digits: 3, r_digits: 2)
      request_id = SecureRandom.uuid

      create_transaction(desc: 'Creating'.green, tid:, amount:, request_id:)
      create_transaction(desc: 'Repeating'.red, tid:, amount:, request_id:) if tid % 4 == 0
    end
  end

  def create_transaction(desc:, tid:, amount:, request_id:)
    append '%s transaction #%s with amount %s: ', desc, tid.next.to_s.blue, amount.to_s.blue
    response = @api_client.create_transaction(account_id:, amount:, terminal_id:, request_id:)
    print_result(response) { @transaction_ids << response['id'] }
  end

  def print_report(expected_transactions)
    unique_transactions = transaction_ids.uniq.size
    log 'Expected %s unique transactions, got %s', expected_transactions.to_s.blue, unique_transactions.to_s.blue

    result = unique_transactions == expected_transactions ? 'IS'.green : 'IS NOT'.red
    log 'Based on this information we can assume the API %s %s idempotent', api_version.yellow, result
  end
end
